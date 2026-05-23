import serial
import time
import sys
import os
import re
import subprocess
import shutil
import paramiko
import tkinter as tk
from tkinter import simpledialog, messagebox, ttk
import logging
import tftpy
import threading
import msvcrt

# Dynamic Application Path matching
if getattr(sys, 'frozen', False):
    application_path = os.path.dirname(sys.executable)
else:
    application_path = os.path.dirname(os.path.abspath(__file__))

UBOOT_YMODEM_FILE = os.path.join(application_path, 'u-boot-mt7621-kt-km12-007h.bin')
CONFIG_FILE_CANDIDATES = [
    os.path.join(application_path, 'dist', 'config_backup.bin'),
    os.path.join(application_path, 'config_backup.bin')
]
CONFIG_FILE = next((p for p in CONFIG_FILE_CANDIDATES if os.path.exists(p)), CONFIG_FILE_CANDIDATES[0])

UBOOT_TFTP_FILE = b'u-boot-mt7621-kt-km12-007h.bin'
FIRMWARE_FILE = b'openwrt-ramips-mt7621-kt_km12-007h-squashfs-factory.bin'
FACTORY_FILE = b'VIKOOMLINK-factory.bin'

ROUTER_IP = "192.168.1.20"

LOGS_DIR = os.path.join(application_path, 'logs')
os.makedirs(LOGS_DIR, exist_ok=True)
SESSION_LOG_FILE = os.path.join(
    LOGS_DIR,
    f"auto_flash_{time.strftime('%Y%m%d-%H%M%S')}.log"
)

def configure_logging():
    formatter = logging.Formatter('%(asctime)s - %(message)s')
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)

    for handler in list(root_logger.handlers):
        root_logger.removeHandler(handler)

    file_handler = logging.FileHandler(SESSION_LOG_FILE, encoding='utf-8')
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(formatter)

    root_logger.addHandler(file_handler)

    # Keep TFTP logs enabled, but let console filter hide them.
    for logger_name in ('tftpy', 'tftpy.TftpServer', 'tftpy.TftpStates', 'tftpy.TftpContexts'):
        tftp_logger = logging.getLogger(logger_name)
        tftp_logger.handlers.clear()
        tftp_logger.setLevel(logging.INFO)
        tftp_logger.propagate = True

configure_logging()
logging.info(f"Session log file: {SESSION_LOG_FILE}")

logging.info(f"Using config file for MAC patching: {CONFIG_FILE}")

SERIAL_RX_BUFFER = bytearray()
SERIAL_RX_LOCK = threading.Lock()
SERIAL_READER_STOP_EVENT = None
SERIAL_READER_THREAD = None
SERIAL_READER_ACTIVE = False
KEYBOARD_PASSTHROUGH_ENABLED = True
AUTOBOOT_INTERCEPT_ENABLED = False
AUTOBOOT_INTERCEPTED = False
BOOT_MENU_ARROW_SENT = False
AUTOBOOT_INTERCEPT_START_IDX = 0


def buffer_contains(text):
    """Check if the full serial RX buffer contains the given text."""
    b_text = text.encode('utf-8') if isinstance(text, str) else text
    with SERIAL_RX_LOCK:
        return b_text in SERIAL_RX_BUFFER

def buffer_contains_since_intercept(text):
    """Check if data received AFTER the last enable_autoboot_interception() call
    contains the given text.  Used to avoid matching stale boot menu text from
    previous boot cycles."""
    b_text = text.encode('utf-8') if isinstance(text, str) else text
    with SERIAL_RX_LOCK:
        return b_text in SERIAL_RX_BUFFER[AUTOBOOT_INTERCEPT_START_IDX:]

def enable_autoboot_interception():
    """Enable pre-emptive autoboot interception in the serial reader thread.

    This is the UNIFIED mechanism used by ALL flashing stages:
    1. Reader thread sends SPACE every 50 ms to stop the countdown.
    2. Reader thread sends DOWN arrow when menu text is detected,
       moving the highlight from option 1 to option 2.
    3. Non-blocking read keeps the loop responsive.

    Call this BEFORE any command that triggers a reboot (reset, mtkautoboot)
    and call ``disable_autoboot_interception()`` after the boot menu has
    been captured and navigated.

    IMPORTANT: Records the current buffer position so the reader thread
    only checks NEW data arriving after this call.  This prevents stale
    "U-Boot Boot Menu" / "Hit any key" text from a previous boot cycle
    from being matched, which would prematurely set AUTOBOOT_INTERCEPTED
    and stop the SPACE key sending.
    """
    global AUTOBOOT_INTERCEPT_ENABLED, AUTOBOOT_INTERCEPTED, BOOT_MENU_ARROW_SENT, AUTOBOOT_INTERCEPT_START_IDX
    with SERIAL_RX_LOCK:
        AUTOBOOT_INTERCEPT_START_IDX = len(SERIAL_RX_BUFFER)
    AUTOBOOT_INTERCEPT_ENABLED = True
    AUTOBOOT_INTERCEPTED = False
    BOOT_MENU_ARROW_SENT = False
    logging.info("[Autoboot] Interception enabled (buffer start_idx=%d).", AUTOBOOT_INTERCEPT_START_IDX)

def disable_autoboot_interception():
    """Disable autoboot interception (counterpart of enable_autoboot_interception)."""
    global AUTOBOOT_INTERCEPT_ENABLED
    AUTOBOOT_INTERCEPT_ENABLED = False

def serial_reader_thread(ser, stop_event):
    global SERIAL_READER_ACTIVE, AUTOBOOT_INTERCEPTED, BOOT_MENU_ARROW_SENT
    last_preemptive_send = 0
    try:
        while not stop_event.is_set():
            try:
                n = ser.in_waiting
                if n > 0:
                    chunk = ser.read(n)
                else:
                    chunk = ser.read(1)
            except Exception:
                break

            if not chunk:
                continue

            try:
                sys.stdout.buffer.write(chunk)
                sys.stdout.flush()
            except Exception:
                pass

            with SERIAL_RX_LOCK:
                SERIAL_RX_BUFFER.extend(chunk)
                # Keep a reasonable rolling history.
                if len(SERIAL_RX_BUFFER) > 2_000_000:
                    del SERIAL_RX_BUFFER[:1_000_000]

            # Autoboot interception – react as fast as possible so the
            # countdown is stopped before it reaches zero.
            # Send a DOWN arrow to stop the countdown AND navigate the
            # menu highlight from option 1 to option 2 (Upgrade firmware).
            if AUTOBOOT_INTERCEPT_ENABLED and not AUTOBOOT_INTERCEPTED:
                with SERIAL_RX_LOCK:
                    # Only check data that arrived AFTER enable_autoboot_interception()
                    # was called.  This prevents stale "U-Boot Boot Menu" text from
                    # a previous boot cycle from being matched.
                    new_data = bytes(SERIAL_RX_BUFFER[AUTOBOOT_INTERCEPT_START_IDX:])
                if b'Hit any key to stop autoboot:' in new_data or b'U-Boot Boot Menu' in new_data:
                    try:
                        ser.write(b'\x1b[B')  # VT100 Down-arrow
                        AUTOBOOT_INTERCEPTED = True
                        BOOT_MENU_ARROW_SENT = True
                        logging.info("[Autoboot] Intercepted countdown with DOWN arrow from reader thread!")
                    except Exception:
                        pass
    finally:
        SERIAL_READER_ACTIVE = False

def start_serial_reader(ser):
    global SERIAL_READER_STOP_EVENT, SERIAL_READER_THREAD, SERIAL_READER_ACTIVE
    with SERIAL_RX_LOCK:
        SERIAL_RX_BUFFER.clear()

    SERIAL_READER_STOP_EVENT = threading.Event()
    SERIAL_READER_THREAD = threading.Thread(target=serial_reader_thread, args=(ser, SERIAL_READER_STOP_EVENT), daemon=True)
    SERIAL_READER_ACTIVE = True
    SERIAL_READER_THREAD.start()

def stop_serial_reader():
    global SERIAL_READER_STOP_EVENT, SERIAL_READER_THREAD, SERIAL_READER_ACTIVE
    SERIAL_READER_ACTIVE = False
    if SERIAL_READER_STOP_EVENT is not None:
        SERIAL_READER_STOP_EVENT.set()
    if SERIAL_READER_THREAD is not None and SERIAL_READER_THREAD.is_alive():
        try:
            SERIAL_READER_THREAD.join(timeout=1.0)
        except Exception:
            pass
    SERIAL_READER_STOP_EVENT = None
    SERIAL_READER_THREAD = None

def start_tftp_server():
    try:
        logging.info(f"Starting embedded TFTP Server on path: {application_path}")
        server = tftpy.TftpServer(application_path)
        server.listen('0.0.0.0', 69)
    except Exception as e:
        logging.error(f"Failed to start TFTP Server failed: {e}")

def get_com_port():
    port = simpledialog.askstring("منفذ السيريال", "الرجاء إدخال رقم منفذ السيريال (مثال: COM13):", initialvalue="COM13")
    if not port:
        return None
    if not port.upper().startswith("COM"):
        port = "COM" + port
    return port.upper()

def confirm_step(step_title, details):
    return messagebox.askyesno(
        f"تأكيد: {step_title}",
        f"{details}\n\nهل تريد المتابعة؟"
    )

def wait_for_prompt(ser, expected_strings, error_strings=None, timeout=None):
    start_time = time.time()
    buffer = b""

    start_idx = 0
    if SERIAL_READER_ACTIVE:
        with SERIAL_RX_LOCK:
            start_idx = len(SERIAL_RX_BUFFER)

    while timeout is None or (time.time() - start_time) < timeout:
        if SERIAL_READER_ACTIVE:
            with SERIAL_RX_LOCK:
                if len(SERIAL_RX_BUFFER) > start_idx:
                    buffer = bytes(SERIAL_RX_BUFFER[start_idx:])
                else:
                    buffer = b""
        else:
            if ser.in_waiting:
                chunk = ser.read(ser.in_waiting)
                try:
                    # Interactive printing like Tera Term
                    sys.stdout.buffer.write(chunk)
                    sys.stdout.flush()
                except:
                    pass
                buffer += chunk
            
        # Check for errors first
        if error_strings and buffer:
            for err in error_strings:
                b_err = err.encode('utf-8') if isinstance(err, str) else err
                if b_err in buffer:
                    return {"status": "error", "match": b_err, "buffer": buffer}

        if buffer:
            # Check expected
            for s in expected_strings:
                b_s = s.encode('utf-8') if isinstance(s, str) else s
                if b_s in buffer:
                    return {"status": "success", "match": b_s, "buffer": buffer}

        try:
            time.sleep(0.05)
        except KeyboardInterrupt:
            return {"status": "interrupted", "buffer": buffer}
    return {"status": "timeout", "buffer": buffer}

def decode_buffer_text(buffer):
    if not buffer:
        return ""
    return buffer.decode('utf-8', 'ignore')

def run_uboot_command(ser, command, timeout=120, error_strings=None):
    if isinstance(command, bytes):
        cmd_bytes = command
        cmd_text = command.decode('utf-8', 'ignore')
    else:
        cmd_text = command
        cmd_bytes = command.encode('utf-8')

    if not cmd_bytes.endswith(b'\r\n'):
        cmd_bytes += b'\r\n'

    logging.info(f"[U-Boot] >>> {cmd_text}")
    ser.write(cmd_bytes)

    res = wait_for_prompt(
        ser,
        [b'KM12-007H=>', b'=>'],
        error_strings=error_strings,
        timeout=timeout,
    )
    output = decode_buffer_text(res.get('buffer', b''))
    return res, output

def run_uboot_menu_command(ser, command, timeout=90):
    if isinstance(command, bytes):
        cmd_bytes = command
        cmd_text = command.decode('utf-8', 'ignore')
    else:
        cmd_text = command
        cmd_bytes = command.encode('utf-8')

    if not cmd_bytes.endswith(b'\r\n'):
        cmd_bytes += b'\r\n'

    logging.info(f"[U-Boot] >>> {cmd_text}")
    ser.write(cmd_bytes)
    return wait_for_boot_menu_with_retry(
        ser,
        cmd_text,
        timeout=timeout,
        attempts=2,
        accept_prompt=False,
        ask_user_on_retry=False,
    )

def ensure_uboot_prompt(ser, timeout=30):
    ser.write(b'\r\n')
    res = wait_for_prompt(ser, [b'KM12-007H=>', b'=>'], timeout=timeout)
    return res['status'] == 'success'

def wait_for_boot_menu(ser, timeout=120, accept_prompt=False):
    global AUTOBOOT_INTERCEPTED, BOOT_MENU_ARROW_SENT

    # Choose the correct buffer search function: when autoboot interception
    # is active, only check data that arrived AFTER enable_autoboot_interception()
    # so we don't match stale boot menu text from a previous boot cycle.
    _buf_has = buffer_contains_since_intercept if AUTOBOOT_INTERCEPT_ENABLED else buffer_contains

    # ── Fast full-buffer pre-check ──────────────────────────────────────
    # If the autoboot was already intercepted by the reader thread (or the
    # menu text arrived before this call), we can return immediately
    # instead of blocking in wait_for_prompt which uses start_idx.
    if AUTOBOOT_INTERCEPTED:
        if (_buf_has(b'Press UP/DOWN to move')
                or _buf_has(b'U-Boot Boot Menu')
                or _buf_has(b'ENTER to select')):
            return True
        if accept_prompt and _buf_has(b'KM12-007H=>'):
            return True
        # Autoboot was stopped but menu text hasn't appeared yet – wait
        # a short while for the menu to render.
        menu_expected = [b'ENTER to select', b'Press UP/DOWN to move', b'U-Boot Boot Menu']
        if accept_prompt:
            menu_expected.append(b'KM12-007H=>')
        menu_res = wait_for_prompt(
            ser, menu_expected,
            error_strings=[b'Web failsafe UI started'],
            timeout=30,
        )
        if menu_res['status'] == 'success':
            return True
        if menu_res['status'] == 'error':
            logging.warning('[U-Boot] Failsafe path detected after autoboot intercept.')
            return False
        # Fall through to the normal retry loop if the short wait timed out.

    # Also check: boot menu might already be fully visible in the buffer
    # even though autoboot was not explicitly intercepted (e.g. the
    # countdown expired or was handled elsewhere).
    if (_buf_has(b'Press UP/DOWN to move')
            or _buf_has(b'U-Boot Boot Menu')
            or _buf_has(b'ENTER to select')):
        # Send a DOWN arrow to stop the countdown and move highlight to option 2.
        if _buf_has(b'Hit any key to stop autoboot:'):
            ser.write(b'\x1b[B')  # VT100 Down-arrow
            AUTOBOOT_INTERCEPTED = True
            BOOT_MENU_ARROW_SENT = True
            time.sleep(0.2)
        return True
    if accept_prompt and _buf_has(b'KM12-007H=>'):
        return True

    # ── Normal retry loop ───────────────────────────────────────────────
    for _ in range(3):
        expected = [b'Hit any key to stop autoboot:', b'ENTER to select', b'Press UP/DOWN to move', b'U-Boot Boot Menu']
        if accept_prompt:
            expected.append(b'KM12-007H=>')

        res = wait_for_prompt(
            ser,
            expected,
            error_strings=[b'Web failsafe UI started', b'Error: no Image found', b'Failed to read NMBM'],
            timeout=timeout,
        )
        if res['status'] == 'error':
            logging.warning('[U-Boot] Failsafe path detected while waiting for boot menu.')
            return False

        if res['status'] != 'success':
            ser.write(b'\r\n')
            time.sleep(0.5)
            continue

        match = res.get('match', b'')
        if accept_prompt and b'KM12-007H=>' in match:
            return True

        if b'Hit any key to stop autoboot:' in match:
            # Send a DOWN arrow to reliably stop the autoboot countdown
            # and move the menu highlight to option 2 (Upgrade firmware).
            ser.write(b'\x1b[B')  # VT100 Down-arrow
            AUTOBOOT_INTERCEPTED = True
            BOOT_MENU_ARROW_SENT = True
            time.sleep(0.2)

            # The boot menu text is typically printed *before* the autoboot
            # prompt, so it is already sitting in the buffer.  Check the
            # full buffer first before waiting for new data.
            if (_buf_has(b'Press UP/DOWN to move')
                    or _buf_has(b'U-Boot Boot Menu')):
                return True

            if accept_prompt and _buf_has(b'KM12-007H=>'):
                return True

            # Fallback: wait for new data in case the menu redraws.
            menu_expected = [b'ENTER to select', b'Press UP/DOWN to move', b'U-Boot Boot Menu']
            if accept_prompt:
                menu_expected.append(b'KM12-007H=>')
            menu_res = wait_for_prompt(
                ser,
                menu_expected,
                timeout=60
            )
            return menu_res['status'] == 'success'

        return True

    return False

def wait_for_boot_menu_with_retry(ser, step_label, timeout=120, attempts=3, accept_prompt=False, ask_user_on_retry=True):
    global AUTOBOOT_INTERCEPTED, BOOT_MENU_ARROW_SENT
    for i in range(attempts):
        if wait_for_boot_menu(ser, timeout=timeout, accept_prompt=accept_prompt):
            return True

        if i == attempts - 1:
            break

        if ask_user_on_retry:
            retry = messagebox.askyesno(
                "تعذر الوصول للبوتلودر",
                f"تعذر الوصول إلى قائمة/موجّه U-Boot أثناء خطوة: {step_label}.\n"
                f"المحاولة {i+1}/{attempts}.\n\n"
                "هل تريد إعادة المحاولة؟"
            )
            if not retry:
                return False
        else:
            logging.warning(f"[Retry] step={step_label} attempt={i+1}/{attempts}")

        # Try forcing a reset before next attempt to exit failsafe/hung states.
        try:
            ser.write(b'\r\n')
            time.sleep(0.2)
            ser.write(b'reset\r\n')
        except Exception:
            pass
        # Re-enable autoboot interception for the retry so the reader
        # thread can catch the countdown again after the new reboot.
        enable_autoboot_interception()
        time.sleep(1)

    return False

def wait_for_expected_prompt(ser, expected_strings, timeout, step_label):
    res = wait_for_prompt(ser, expected_strings, timeout=timeout)
    if res['status'] != 'success':
        logging.error(f"[Flow] Expected prompt not reached during step: {step_label}")
        return False
    return True

def wait_and_send(ser, expected_strings, payload, timeout, step_label):
    if not wait_for_expected_prompt(ser, expected_strings, timeout, step_label):
        return False
    ser.write(payload)
    return True

def select_boot_menu_option_with_arrows(ser, option_number, timeout=25):
    global BOOT_MENU_ARROW_SENT
    if option_number < 0 or option_number > 6:
        return False

    # Check if the menu is already visible in the full buffer before
    # blocking on new data (the text may have arrived earlier).
    if not buffer_contains(b'Press UP/DOWN to move, ENTER to select'):
        if not wait_for_expected_prompt(
            ser,
            [b'Press UP/DOWN to move, ENTER to select'],
            timeout,
            f"select menu option {option_number}"
        ):
            return False

    # A robust delay is critical here! The MTK U-Boot takes a moment
    # after printing the menu to actually start polling for keystrokes.
    # If sent too fast, the selection is simply ignored.
    time.sleep(1.0)

    # U-Boot bootmenu supports direct number key selection which is deeply reliable.
    # The OpenWrt MTK U-Boot instantly highlights and executes numeric options on getc.
    # We MUST NOT append \\r or \\n, as they will get queued and blindly answer
    # the very next interactive prompt (like 'Reboot after upgrading?'), permanently
    # desyncing the serial workflow state.
    ser.write(str(option_number).encode('ascii'))
    BOOT_MENU_ARROW_SENT = False
    return True

def run_live_uart_terminal(ser):
    logging.info("[Manual] Live UART mode enabled. You can now type directly like Tera Term.")
    logging.info("[Manual] Close this window to disconnect.")
    print("\n--- Live UART Terminal ---")
    print("--- يمكنك الكتابة والتفاعل مباشرة مع الراوتر (مثل Tera Term) ---")   # You can type and interact directly with the router (like Tera Term)
    print("--- استخدم الأسهم للتنقل بالقوائم واضغط Enter للتأكيد ---")           # Use arrow keys to navigate menus and press Enter to confirm
    print("--- أغلق النافذة للخروج ---\n")                                        # Close this window to exit
    while True:
        try:
            if not ser.is_open:
                break
            time.sleep(0.05)
        except (KeyboardInterrupt, Exception):
            break

def enter_uboot_console_from_menu(ser, timeout=30):
    # Send explicit menu selection (arrow-key navigation to option 0),
    # then wait for U-Boot prompt.
    if not select_boot_menu_option_with_arrows(ser, 0, timeout=20):
        return False

    res = wait_for_prompt(ser, [b'KM12-007H=>', b'=>'], timeout=timeout)
    if res['status'] == 'success':
        return True

    # One more quick retry: navigate again in case the first keypress
    # landed during a menu redraw.
    time.sleep(0.3)
    for _ in range(6):
        ser.write(b'\x1b[B')
        time.sleep(0.1)
    ser.write(b'\r')
    res = wait_for_prompt(ser, [b'KM12-007H=>', b'=>'], timeout=8)
    return res['status'] == 'success'

def reboot_into_bootloader_console(ser):
    if not ensure_uboot_prompt(ser, timeout=20):
        if not wait_for_boot_menu(ser, timeout=60):
            return False
        if not enter_uboot_console_from_menu(ser, timeout=30):
            return False

    enable_autoboot_interception()
    ser.write(b'reset\r\n')
    try:
        if not wait_for_boot_menu(ser, timeout=120):
            return False
        return enter_uboot_console_from_menu(ser, timeout=30)
    finally:
        disable_autoboot_interception()

def force_reboot_then_enter_console(ser):
    # Reach console first (from either menu or prompt), then force a clean reboot.
    if not ensure_uboot_prompt(ser, timeout=8):
        if not wait_for_boot_menu_with_retry(ser, "الوصول لقائمة البوتلودر", timeout=90, attempts=3):
            return False
        if not enter_uboot_console_from_menu(ser, timeout=30):
            return False

    enable_autoboot_interception()
    ser.write(b'reset\r\n')
    try:
        if not wait_for_boot_menu_with_retry(ser, "الرجوع للقائمة بعد إعادة التشغيل", timeout=120, attempts=3):
            return False
        return enter_uboot_console_from_menu(ser, timeout=30)
    finally:
        disable_autoboot_interception()

def return_to_boot_menu_with_mtkautoboot(ser):
    if not ensure_uboot_prompt(ser, timeout=20):
        return False
    enable_autoboot_interception()
    try:
        return run_uboot_menu_command(ser, 'mtkautoboot', timeout=90)
    finally:
        disable_autoboot_interception()

def enter_console_after_ymodem(ser):
    # Autoboot intercept should already be enabled by the caller
    # (run_serial_workflow).  Ensure it stays active during this function.
    enable_autoboot_interception()
    try:
        # Prefer explicit menu path (send 0), then allow prompt fallback if output raced.
        menu_ready = wait_for_boot_menu_with_retry(
            ser,
            "بعد YMODEM",
            timeout=70,
            attempts=3,
            accept_prompt=False,
            ask_user_on_retry=False,
        )

        if menu_ready:
            if enter_uboot_console_from_menu(ser, timeout=30):
                return True
            # Rare race: prompt may have appeared while selecting.
            return ensure_uboot_prompt(ser, timeout=6)

        # If menu detection failed, allow quick prompt fallback.
        return ensure_uboot_prompt(ser, timeout=6)
    finally:
        disable_autoboot_interception()

def extract_nand_suffix_from_md_output(md_output):
    for raw_line in md_output.splitlines():
        line = raw_line.strip()
        match = re.search(r'^[0-9a-fA-F]+:\s*([0-9a-fA-F]{2}(?:\s+[0-9a-fA-F]{2}){5})\b', line)
        if match:
            return ''.join(match.group(1).split()).lower()
    return None

def backup_partition_to_tftp(ser, partition_name, offset_hex, tftp_server_ip='192.168.1.2', forced_suffix=None):
    suffix = forced_suffix

    if not suffix:
        # User requested this exact pattern for Config: nand read + md.b in one command.
        read_md_cmd = f"nand read 0x84000000 {offset_hex} 0x80000; md.b 0x84040004 0x6"
        read_res, read_out = run_uboot_command(
            ser,
            read_md_cmd,
            timeout=140,
            error_strings=[b'failed', b'ERROR:', b'Error:']
        )
        if read_res['status'] != 'success' or 'bytes read: OK' not in read_out:
            return None, None, f"فشل قراءة القسم {partition_name} من NAND."

        suffix = extract_nand_suffix_from_md_output(read_out)
        if not suffix:
            return None, None, f"لم يتم استخراج بصمة الاسم من مخرجات md.b للقسم {partition_name}."
    else:
        read_cmd = f"nand read 0x84000000 {offset_hex} 0x80000"
        read_res, read_out = run_uboot_command(
            ser,
            read_cmd,
            timeout=120,
            error_strings=[b'failed', b'ERROR:', b'Error:']
        )
        if read_res['status'] != 'success' or 'bytes read: OK' not in read_out:
            return None, None, f"فشل قراءة القسم {partition_name} من NAND."

    backup_name = f"{partition_name}-nand-{suffix}.bin"
    put_cmd = f"tftpput 0x84000000 0x80000 {tftp_server_ip}:{backup_name}"
    put_res, put_out = run_uboot_command(
        ser,
        put_cmd,
        timeout=180,
        error_strings=[b'failed', b'ERROR:', b'Error:']
    )

    out_lower = put_out.lower()
    if put_res['status'] != 'success' or 'bytes transferred' not in out_lower or '(80000 hex)' not in out_lower:
        return None, None, f"فشل رفع النسخة الاحتياطية للقسم {partition_name} عبر TFTP."

    logging.info(f"[Recovery] Backup created: {backup_name}")
    return backup_name, suffix, None

def backup_config_factory_pair(ser):
    config_backup, config_suffix, err = backup_partition_to_tftp(ser, 'config', '0x80000')
    if err:
        return None, None, err

    factory_backup, _, err = backup_partition_to_tftp(ser, 'factory', '0x100000', forced_suffix=config_suffix)
    if err:
        return None, None, err

    return config_backup, factory_backup, None

def backup_config_factory_before_bootloader_upgrade(ser):
    logging.info('[Recovery] Creating mandatory backup for Config and Factory before bootloader flashing...')

    if not ensure_uboot_prompt(ser, timeout=10):
        if not enter_uboot_console_from_menu(ser, timeout=30):
            return None, None, 'تعذر الدخول إلى U-Boot console قبل النسخ الاحتياطي.'

    if not confirm_step(
        "نسخ احتياطي Config/Factory",
        "سيتم الآن أخذ نسخة احتياطية للقسمين Config وFactory عبر TFTP."
    ):
        return None, None, 'تم إلغاء عملية النسخ الاحتياطي من قبل المستخدم.'

    config_backup, factory_backup, err = backup_config_factory_pair(ser)
    if err:
        return None, None, err

    # Repair NMBM tables for Config and Factory right after backup
    if not repair_nmbm_partitions(ser):
        return None, None, 'فشل إصلاح جداول NMBM للقسمين Config وFactory بعد النسخ الاحتياطي.'

    if not return_to_boot_menu_with_mtkautoboot(ser):
        return None, None, 'تم النسخ الاحتياطي والإصلاح لكن فشل الرجوع إلى القائمة الرئيسية عبر mtkautoboot.'

    return config_backup, factory_backup, None

def scrub_nand_chip_with_confirm(ser):
    logging.warning('[Recovery] Running nand scrub.chip...')

    ser.write(b'nand scrub.chip\r\n')

    confirm_res = wait_for_prompt(ser, [b'Really scrub this NAND flash? <y/N>'], timeout=30)
    if confirm_res['status'] != 'success':
        return False, 'لم يظهر طلب تأكيد scrub على السيريال.'

    ser.write(b'y\r\n')
    done_res = wait_for_prompt(
        ser,
        [b'KM12-007H=>', b'=>'],
        error_strings=[b'failed', b'ERROR:', b'Error:'],
        timeout=360,
    )
    done_out = decode_buffer_text(done_res.get('buffer', b''))
    if done_res['status'] != 'success':
        return False, 'فشل تنفيذ scrub أو انتهت المهلة قبل الرجوع إلى موجّه U-Boot.'

    if '100% complete' not in done_out or 'OK' not in done_out:
        logging.warning('[Recovery] scrub finished but expected success markers were not fully matched.')

    return True, ''

def flash_partition_from_tftp(ser, image_name, offset_hex):
    cmd = (
        f"tftpboot 0x84000000 {image_name}; "
        f"nand erase {offset_hex} 0x80000; "
        f"nand write 0x84000000 {offset_hex} 0x80000"
    )
    res, out = run_uboot_command(
        ser,
        cmd,
        timeout=240,
        error_strings=[b'failed', b'ERROR:', b'Error:']
    )
    if res['status'] != 'success':
        return False, f"فشل تنفيذ أمر التفليش للصورة {image_name}."

    if 'bytes written: OK' not in out:
        return False, f"لم يظهر تأكيد نجاح الكتابة (bytes written: OK) للصورة {image_name}."

    return True, ''

def is_bootloader_device_type_error(output_text):
    text = output_text.lower()
    return (
        'incorrect device type in u-boot' in text
        or ('flash erasure' in text and 'failed' in text)
    )

def perform_emergency_bootloader_recovery(ser, config_backup_name=None, factory_backup_name=None):
    logging.warning('[Recovery] Bootloader fallback path activated.')

    if not ensure_uboot_prompt(ser, timeout=30):
        return False, 'لم يتم الوصول إلى موجّه U-Boot قبل بدء وضع الإنقاذ.'

    if not config_backup_name or not factory_backup_name:
        config_backup_name, factory_backup_name, err = backup_config_factory_pair(ser)
        if err:
            return False, err
    else:
        logging.info(f"[Recovery] Reusing existing backups: {config_backup_name}, {factory_backup_name}")

    ok, err = scrub_nand_chip_with_confirm(ser)
    if not ok:
        return False, err

    bootloader_name = UBOOT_TFTP_FILE.decode('ascii', 'ignore')
    ok, err = flash_partition_from_tftp(ser, bootloader_name, '0x0')
    if not ok:
        return False, err

    ok, err = flash_partition_from_tftp(ser, config_backup_name, '0x80000')
    if not ok:
        return False, err

    ok, err = flash_partition_from_tftp(ser, factory_backup_name, '0x100000')
    if not ok:
        return False, err

    logging.info('[Recovery] Emergency recovery completed successfully.')
    return True, ''

def keyboard_listener_thread(ser):
    # Map Windows scan-codes (returned by msvcrt.getch() after a \xe0 or
    # \x00 prefix) to the VT100/ANSI escape sequences that U-Boot expects.
    SPECIAL_KEY_MAP = {
        72: b'\x1b[A',   # Up arrow
        80: b'\x1b[B',   # Down arrow
        75: b'\x1b[D',   # Left arrow
        77: b'\x1b[C',   # Right arrow
        71: b'\x1b[H',   # Home
        79: b'\x1b[F',   # End
        83: b'\x1b[3~',  # Delete
        73: b'\x1b[5~',  # Page Up
        81: b'\x1b[6~',  # Page Down
    }
    while True:
        try:
            if not KEYBOARD_PASSTHROUGH_ENABLED:
                time.sleep(0.02)
                continue
            if msvcrt.kbhit():
                c = msvcrt.getch()
                if c in (b'\xe0', b'\x00'):
                    # Special-key prefix – read the actual scan code.
                    scan = msvcrt.getch()
                    seq = SPECIAL_KEY_MAP.get(scan[0])
                    if seq:
                        ser.write(seq)
                elif c == b'\r':
                    # Translate Enter to CR so U-Boot recognises it
                    # (matches the convention used by menu navigation).
                    ser.write(b'\r')
                else:
                    ser.write(c)
        except Exception:
            pass
        time.sleep(0.01)

def send_ymodem(ser, filename):
    import os

    progress_win = None
    progress_bar = None
    progress_label = None

    def calc_crc(data):
        crc = 0
        for b in data:
            crc ^= (b << 8)
            for _ in range(8):
                if crc & 0x8000:
                    crc = (crc << 1) ^ 0x1021
                else:
                    crc <<= 1
                crc &= 0xFFFF
        return crc

    # Flush any old data
    ser.reset_input_buffer()
    
    logging.info("[YMODEM] Waiting for receiver signal (C)...")
    ser.timeout = 5
    while True:
        c = ser.read(1)
        if c == b'C':
            break
        elif not c: # timeout
            logging.error("[YMODEM] Failed to receive 'C'.")
            return False

    logging.info("[YMODEM] Sending Block 0 (Filename)...")
    name = os.path.basename(filename).encode('utf-8')
    fsize = os.path.getsize(filename)

    try:
        progress_win = tk.Toplevel()
        progress_win.title("YMODEM Transfer")
        progress_win.geometry("460x130")
        progress_win.resizable(False, False)
        progress_win.attributes("-topmost", True)

        ttk.Label(progress_win, text=f"Uploading: {os.path.basename(filename)}").pack(pady=(12, 4))
        progress_bar = ttk.Progressbar(progress_win, orient='horizontal', length=420, mode='determinate', maximum=fsize)
        progress_bar.pack(pady=6)
        progress_label = ttk.Label(progress_win, text=f"0% - 0/{fsize} bytes")
        progress_label.pack(pady=(2, 8))
        progress_win.update_idletasks()
    except Exception:
        progress_win = None

    size_str = str(fsize).encode('utf-8')
    payload = name + b'\x00' + size_str + b'\x00'
    payload = payload.ljust(128, b'\x00')
    crc = calc_crc(payload)
    
    blk0 = b'\x01\x00\xFF' + payload + bytes([(crc >> 8) & 0xFF, crc & 0xFF])
    ser.write(blk0)
    
    ack = ser.read(1)
    if ack != b'\x06':
        logging.error(f"[YMODEM] Block 0 Failed! Received: {repr(ack)}")
        return False
        
    logging.info("[YMODEM] Block 0 OK. Waiting for C to start data...")
    while True:
        c = ser.read(1)
        if c == b'C':
            break

    logging.info(f"[YMODEM] Transmitting file ({fsize} bytes)...")
    seq = 1
    sent_bytes = 0
    with open(filename, 'rb') as f:
        while True:
            chunk = f.read(1024)
            if not chunk:
                break
            
            chunk_length = len(chunk)
            chunk = chunk.ljust(1024, b'\x1A') # Pad with SUB (EOF) for YMODEM
            crc = calc_crc(chunk)
            seq_byte = seq & 0xFF
            seq_cmp = 0xFF - seq_byte
            
            block = bytes([0x02, seq_byte, seq_cmp]) + chunk + bytes([(crc >> 8) & 0xFF, crc & 0xFF])
            
            retry = 0
            while retry < 5:
                ser.write(block)
                ack = ser.read(1)
                if ack == b'\x06': # ACK
                    seq += 1
                    sent_bytes += chunk_length
                    if progress_win and progress_bar and progress_label:
                        try:
                            progress_bar['value'] = sent_bytes
                            percent = min(100, int((sent_bytes / fsize) * 100))
                            progress_label.config(text=f"{percent}% - {sent_bytes}/{fsize} bytes")
                            progress_win.update_idletasks()
                            progress_win.update()
                        except Exception:
                            progress_win = None
                    break
                elif ack == b'\x18': # CAN
                    logging.error("[YMODEM] Transfer canceled by receiver!")
                    if progress_win:
                        try:
                            progress_win.destroy()
                        except Exception:
                            pass
                    return False
                retry += 1
            if retry >= 5:
                logging.error(f"[YMODEM] Failed to send data block {seq}! Retries exhausted.")
                if progress_win:
                    try:
                        progress_win.destroy()
                    except Exception:
                        pass
                return False

    logging.info("[YMODEM] Sending EOT...")
    ser.write(b'\x04')
    ser.read(1) # wait ACK
    
    logging.info("[YMODEM] Closing transmission...")
    null_payload = b'\x00' * 128
    crc = calc_crc(null_payload)
    blk_end = b'\x01\x00\xFF' + null_payload + bytes([(crc >> 8) & 0xFF, crc & 0xFF])
    ser.write(blk_end)
    ser.read(1)

    if progress_win and progress_bar and progress_label:
        try:
            progress_bar['value'] = fsize
            progress_label.config(text=f"100% - {fsize}/{fsize} bytes")
            progress_win.update_idletasks()
            progress_win.update()
            time.sleep(0.2)
            progress_win.destroy()
        except Exception:
            pass
    
    logging.info("[YMODEM] Transfer completed successfully!")
    return True

def repair_nmbm_partitions(ser):
    """Repair NMBM tables for Config and Factory partitions."""
    logging.info("=== Repairing Config/Factory NMBM tables ===")

    if not ensure_uboot_prompt(ser, timeout=20):
        logging.error('U-Boot prompt not available for NMBM repair stage.')
        return False

    if not confirm_step(
        "إصلاح جداول NMBM",
        "سيتم الآن تنفيذ أوامر إصلاح جداول NMBM لقسمي Config وFactory."
    ):
        return False

    # NMBM Config repair
    res, _ = run_uboot_command(
        ser,
        'nand read 0x84000000 0x80000 0x80000; nmbm nmbm0 erase 0x80000 0x80000; nmbm nmbm0 write 0x84000000 0x80000 0x80000',
        timeout=120,
        error_strings=[b'failed', b'Fail', b'ERROR:', b'Error:']
    )
    if res['status'] != 'success':
        return False

    # NMBM Factory repair
    res, _ = run_uboot_command(
        ser,
        'nand read 0x84000000 0x100000 0x80000; nmbm nmbm0 erase 0x100000 0x80000; nmbm nmbm0 write 0x84000000 0x100000 0x80000',
        timeout=120,
        error_strings=[b'failed', b'Fail', b'ERROR:', b'Error:']
    )
    if res['status'] != 'success':
        return False

    logging.info("NMBM partition repair completed successfully.")
    return True

def flash_strong_eeprom_if_requested(ser):
    """Ask user about flashing the strong EEPROM and flash it if requested.

    Returns:
        'flashed' - EEPROM was successfully flashed.
        'skipped' - User chose not to flash.
        None      - An error occurred.
    """
    logging.info("=== Strong EEPROM flash check ===")

    if not ensure_uboot_prompt(ser, timeout=20):
        logging.error('U-Boot prompt not available for EEPROM flash stage.')
        return None

    # Enable autoboot intercept while the dialog is shown so that if the
    # device reboots (e.g. hardware watchdog) while the user is deciding,
    # the countdown is caught and we can re-enter the console afterwards.
    enable_autoboot_interception()

    user_wants_flash = messagebox.askyesno(
        "تأكيد",
        "هل تريد كتابة ملف الأيبروم القوي (VIKOOMLINK-factory.bin) للراوتر؟\n"
        "اختر 'لا' للحفاظ على الماك أدرس والوايرلس الأصلي للراوتر."
    )

    # After the dialog, check if the device rebooted while the user was
    # reading the message.  If so, re-enter the U-Boot console.
    if AUTOBOOT_INTERCEPTED:
        logging.warning("Device rebooted while waiting for user input. Re-entering U-Boot console...")
        if not wait_for_boot_menu(ser, timeout=30):
            disable_autoboot_interception()
            logging.error("Failed to reach boot menu after device reboot during dialog.")
            return None
        if not enter_uboot_console_from_menu(ser, timeout=30):
            disable_autoboot_interception()
            logging.error("Failed to enter U-Boot console after device reboot during dialog.")
            return None

    disable_autoboot_interception()

    # Re-verify we are still at the U-Boot prompt before proceeding.
    if not ensure_uboot_prompt(ser, timeout=10):
        logging.error("U-Boot prompt lost after EEPROM dialog.")
        return None

    if not user_wants_flash:
        logging.info("User skipped strong EEPROM flash.")
        return 'skipped'

    strong_cmd = (
        b'tftpboot 0x84000000 ' + FACTORY_FILE +
        b'; nmbm nmbm0 erase 0x100000 0x80000; nmbm nmbm0 write 0x84000000 0x100000 0x80000'
    )
    res, _ = run_uboot_command(
        ser,
        strong_cmd,
        timeout=180,
        error_strings=[b'failed', b'Fail', b'ERROR:', b'Error:']
    )
    if res['status'] != 'success':
        return None

    logging.info("Strong EEPROM flash completed successfully.")
    return 'flashed'

def run_serial_workflow(port):
    try:
        ser = serial.Serial(port, 115200, timeout=1)
    except Exception as e:
        messagebox.showerror("خطأ", f"لا يمكن فتح المنفذ {port}:\n{str(e)}")
        return False

    start_serial_reader(ser)

    def close_serial_session():
        stop_serial_reader()
        try:
            ser.close()
        except Exception:
            pass

    def abort_or_manual(error_text):
        if messagebox.askyesno(
            "خطأ",
            f"{error_text}\n\nهل تريد التحويل إلى وضع UART اليدوي المباشر (مثل Tera Term)؟"
        ):
            run_live_uart_terminal(ser)
        close_serial_session()
        return False

    logging.info(f"Connected to {port}. Waiting for Ymodem prompt (Please trigger the NAND glitch)...")
    
    # Start live terminal typing feature
    threading.Thread(target=keyboard_listener_thread, args=(ser,), daemon=True).start()
    
    res = wait_for_prompt(ser, [b'Accepted mode is Ymoden-1K.', b'Ymodem'], timeout=None)

    if not confirm_step(
        "YMODEM جاهز",
        "تم اكتشاف وضع Accepted mode is Ymoden-1K.\nسيتم الآن رفع ملف البوتلودر عبر YMODEM."
    ):
        close_serial_session()
        return False
    
    logging.info("Initiating UBOOT transfer via YMODEM...")
    if not os.path.exists(UBOOT_YMODEM_FILE):
        messagebox.showerror("خطأ", f"ملف البوت لودر غير موجود في نفس المجلد!\n{UBOOT_YMODEM_FILE}")
        close_serial_session()
        return False

    global KEYBOARD_PASSTHROUGH_ENABLED, AUTOBOOT_INTERCEPT_ENABLED, AUTOBOOT_INTERCEPTED, BOOT_MENU_ARROW_SENT
    stop_serial_reader()
    KEYBOARD_PASSTHROUGH_ENABLED = False
    try:
        success = send_ymodem(ser, UBOOT_YMODEM_FILE)
    finally:
        KEYBOARD_PASSTHROUGH_ENABLED = True
        # Enable autoboot interception BEFORE restarting the serial reader
        # so the reader thread can catch the countdown as soon as it appears.
        enable_autoboot_interception()
        if ser.is_open:
            start_serial_reader(ser)

    if not success:
        return abort_or_manual("فشل إرسال البوت لودر عبر YMODEM! تأكد من بقاء الراوتر في وضع الاستقبال ثم أعد المحاولة.")

    time.sleep(2)

    logging.info("Waiting for U-Boot then entering console (option 0)...")
    if not enter_console_after_ymodem(ser):
        return abort_or_manual("تعذر الوصول إلى U-Boot console بعد رفع البوتلودر عبر YMODEM.")

    config_backup_name, factory_backup_name, backup_err = backup_config_factory_before_bootloader_upgrade(ser)
    if backup_err:
        messagebox.showerror("خطأ في النسخ الاحتياطي", f"فشل إنشاء نسخة احتياطية لـ Config/Factory:\n{backup_err}")
        close_serial_session()
        return False

    logging.info(f"[Recovery] Mandatory backups ready: {config_backup_name}, {factory_backup_name}")
    if not confirm_step(
        "بدء ترقية البوتلودر",
        "سيتم الآن اختيار 3 من القائمة وبدء خطوات ترقية البوتلودر عبر TFTP."
    ):
        close_serial_session()
        return False

    # Select menu option using arrows to avoid accidental command concatenation.
    if not select_boot_menu_option_with_arrows(ser, 3, timeout=25):
        messagebox.showerror("خطأ", "تعذر اختيار خيار ترقية البوتلودر من القائمة.")
        close_serial_session()
        return False

    if not wait_and_send(ser, [b'Reboot after upgrading? (Y/n):'], b'y\r', 15, "تأكيد إعادة التشغيل بعد ترقية البوتلودر"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى سؤال تأكيد إعادة التشغيل في مسار ترقية البوتلودر.")
        close_serial_session()
        return False

    # TFTP for UBOOT
    if not wait_and_send(ser, [b'Select (enter for default):'], b'\r', 15, "اختيار طريقة التحميل"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى قائمة طرق التحميل لترقية البوتلودر.")
        close_serial_session()
        return False
    if not wait_and_send(ser, [b"Input U-Boot's IP address:"], b'\r', 15, "إدخال IP البوتلودر"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى خطوة إدخال عنوان U-Boot IP.")
        close_serial_session()
        return False
    if not wait_and_send(ser, [b"Input TFTP server's IP address:"], b'\r', 15, "إدخال IP خادم TFTP"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى خطوة إدخال عنوان خادم TFTP.")
        close_serial_session()
        return False
    if not wait_and_send(ser, [b"Input IP netmask:"], b'\r', 15, "إدخال Netmask"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى خطوة إدخال Netmask.")
        close_serial_session()
        return False
    if not wait_for_expected_prompt(ser, [b"Input file name:"], 15, "انتظار اسم ملف البوتلودر"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى خطوة إدخال اسم ملف البوتلودر.")
        close_serial_session()
        return False

    logging.info("[TFTP] Waiting 4 seconds for Windows network adapter (ARP/Link) to wake up...")
    time.sleep(4)

    ser.write(UBOOT_TFTP_FILE + b'\r\n')
    
    logging.info("Verifying Bootloader flash process...")
    res = wait_for_prompt(ser, [b'*** Bootloader upgrade completed! ***'], error_strings=[b'failed!', b'ERROR:', b'Error:'], timeout=120)
    bootloader_auto_rebooting = False
    if res['status'] == 'success':
        logging.info("Bootloader upgrade successful!")
        # The device reboots automatically after upgrade (user answered 'y'
        # to "Reboot after upgrading?").  Enable autoboot interception
        # immediately so the reader thread catches the "Hit any key to stop
        # autoboot:" countdown and keeps the boot menu active.
        enable_autoboot_interception()
        bootloader_auto_rebooting = True
    elif res['status'] == 'error':
        error_output = decode_buffer_text(res.get('buffer', b''))
        if is_bootloader_device_type_error(error_output):
            logging.warning('Detected bootloader device mismatch.')
            continue_recovery = messagebox.askyesno(
                "فشل تفليش البوتلودر",
                "لم يتم تفليش البوتلودر بنجاح (incorrect device type / flash erasure failed).\n\n"
                "هل تريد المتابعة بمسار الإنقاذ التلقائي؟\n"
                "سيتم أخذ نسخة احتياطية لـ Config وFactory ثم Scrub ثم إعادة التفليش."
            )
            if not continue_recovery:
                logging.info('User chose not to continue with emergency recovery. Stopping process.')
                ser.close()
                return False

            logging.warning('User approved emergency recovery flow. Starting fallback sequence...')
            recover_ok, recover_err = perform_emergency_bootloader_recovery(
                ser,
                config_backup_name=config_backup_name,
                factory_backup_name=factory_backup_name,
            )
            if not recover_ok:
                logging.error(f"Emergency recovery failed: {recover_err}")
                messagebox.showerror("فشل الإنقاذ", f"فشل مسار الإنقاذ التلقائي للبوتلودر:\n{recover_err}")
                close_serial_session()
                return False
        else:
            logging.error("Bootloader flash failed with non-recoverable error.")
            return abort_or_manual("فشل تفليش البوتلودر بخطأ غير قابل للمعالجة تلقائياً.")
    else:
        logging.error("Bootloader flash timed out!")
        return abort_or_manual("انتهت مهلة تفليش البوتلودر ولم يظهر تأكيد النجاح.")

    # Reboot after bootloader stage, then enter console for strong EEPROM flash.
    logging.info("Bootloader stage done. Rebooting and entering U-Boot console for EEPROM flash...")
    if not confirm_step(
        "إعادة تشغيل ثم تفليش الأيبروم",
        "تم إنهاء مرحلة البوتلودر. سيتم الآن إعادة التشغيل ثم الدخول إلى U-Boot console لسؤالك عن تفليش الأيبروم القوية."
    ):
        close_serial_session()
        return False

    if bootloader_auto_rebooting:
        # Device is already rebooting after the bootloader upgrade.
        # Autoboot interception was enabled above so the reader thread
        # should have caught the countdown, keeping the boot menu active.
        # Wait for the menu then navigate to U-Boot console (option 0).
        try:
            if not wait_for_boot_menu_with_retry(
                ser, "الرجوع للقائمة بعد ترقية البوتلودر",
                timeout=120, attempts=3
            ):
                messagebox.showerror("خطأ", "فشل الوصول لقائمة البوتلودر بعد إعادة التشغيل التلقائية بعد ترقية البوتلودر.")
                close_serial_session()
                return False

            if not enter_uboot_console_from_menu(ser, timeout=30):
                messagebox.showerror("خطأ", "فشل الدخول إلى U-Boot console من القائمة بعد مرحلة البوتلودر.")
                close_serial_session()
                return False
        finally:
            disable_autoboot_interception()
    else:
        # Emergency recovery path – device is still at U-Boot console
        # and needs an explicit reboot to activate the new bootloader.
        if not force_reboot_then_enter_console(ser):
            messagebox.showerror("خطأ", "فشل إعادة التشغيل والدخول إلى U-Boot console بعد مرحلة البوتلودر.")
            close_serial_session()
            return False

    eeprom_result = flash_strong_eeprom_if_requested(ser)
    if eeprom_result is None:
        messagebox.showerror("خطأ", "فشل تفليش الأيبروم القوية.")
        close_serial_session()
        return False

    if eeprom_result == 'flashed':
        # After successful EEPROM flash, reboot then select option 2 for firmware upgrade.
        logging.info("Strong EEPROM flashed. Rebooting to boot menu for firmware upgrade...")
        if not confirm_step(
            "إعادة التشغيل لتفليش السوفتوير",
            "تم تفليش الأيبروم القوي بنجاح.\nسيتم إعادة التشغيل ثم اختيار 2 لتفليش السوفتوير."
        ):
            close_serial_session()
            return False

        enable_autoboot_interception()
        ser.write(b'reset\r\n')
        try:
            if not wait_for_boot_menu_with_retry(ser, "إعادة التشغيل بعد الأيبروم", timeout=120, attempts=3):
                messagebox.showerror("خطأ", "فشل الوصول لقائمة البوتلودر بعد إعادة التشغيل.")
                close_serial_session()
                return False
        finally:
            disable_autoboot_interception()

        if not select_boot_menu_option_with_arrows(ser, 2, timeout=25):
            messagebox.showerror("خطأ", "تعذر اختيار خيار تفليش السوفتوير من القائمة.")
            close_serial_session()
            return False
    else:
        # EEPROM skipped – use mtkautoboot to return to boot menu.
        if not confirm_step(
            "الانتقال لتفليش السوفتوير",
            "سيتم تنفيذ mtkautoboot للعودة للقائمة الرئيسية ثم اختيار 2 لتفليش السوفتوير."
        ):
            close_serial_session()
            return False

        if not return_to_boot_menu_with_mtkautoboot(ser):
            messagebox.showerror("خطأ", "فشل الرجوع إلى القائمة الرئيسية عبر mtkautoboot قبل تفليش الفيرموير.")
            close_serial_session()
            return False

        if not select_boot_menu_option_with_arrows(ser, 2, timeout=25):
            messagebox.showerror("خطأ", "تعذر اختيار خيار تفليش السوفتوير من القائمة.")
            close_serial_session()
            return False

    if not wait_and_send(ser, [b'Run firmware after upgrading? (Y/n):'], b'y\r', 15, "تأكيد تشغيل الفيرموير بعد الترقية"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى سؤال Run firmware after upgrading.")
        close_serial_session()
        return False

    if not wait_and_send(ser, [b'Select (enter for default):'], b'\r', 15, "اختيار طريقة رفع الفيرموير"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى قائمة طرق التحميل لتفليش الفيرموير.")
        close_serial_session()
        return False
    if not wait_and_send(ser, [b"Input U-Boot's IP address:"], b'\r', 15, "إدخال IP U-Boot في مسار الفيرموير"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى خطوة IP U-Boot في مسار الفيرموير.")
        close_serial_session()
        return False
    if not wait_and_send(ser, [b"Input TFTP server's IP address:"], b'\r', 15, "إدخال IP TFTP في مسار الفيرموير"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى خطوة IP خادم TFTP في مسار الفيرموير.")
        close_serial_session()
        return False
    if not wait_and_send(ser, [b"Input IP netmask:"], b'\r', 15, "إدخال Netmask في مسار الفيرموير"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى خطوة Netmask في مسار الفيرموير.")
        close_serial_session()
        return False
    if not wait_for_expected_prompt(ser, [b"Input file name:"], 15, "انتظار اسم ملف الفيرموير"):
        messagebox.showerror("خطأ", "تعذر الوصول إلى خطوة إدخال اسم ملف الفيرموير.")
        close_serial_session()
        return False

    logging.info("[TFTP] Waiting 4 seconds for Windows network adapter (ARP/Link) to wake up...")
    time.sleep(4)

    if not confirm_step(
        "إرسال ملف السوفتوير",
        f"سيتم الآن إرسال الملف:\n{FIRMWARE_FILE.decode('ascii', 'ignore')}"
    ):
        close_serial_session()
        return False

    ser.write(FIRMWARE_FILE + b'\r\n')
    
    logging.info("Verifying Firmware flash process...")
    res = wait_for_prompt(ser, [b'*** Firmware image write completed! ***'], error_strings=[b'failed!', b'ERROR:', b'Error:'], timeout=180)
    if res['status'] == 'error' or res['status'] == 'timeout':
        logging.error("Firmware flash failed!")
        close_serial_session()
        return False
    
    # Wait for the exact moment OpenWrt kernel starts booting
    wait_for_prompt(ser, [b'Loading FIT image', b'Loading kernel'], timeout=60)
    
    logging.info("Kernel boot started! Delaying 25 seconds transparently to bypass Failsafe Mode...")
    # This acts as a transparent 25-second delay while actively streaming serial logs to the UI without freezing
    wait_for_prompt(ser, [b'IMPOSSIBLE_STRING_NEVER_APPEARS_39485'], timeout=25)

    # Start thread to periodically press Enter so we can safely trigger the shell prompt after boot
    def poke_enter_thread(ser, stop_event):
        while not stop_event.is_set():
            try:
                ser.write(b'\r\n')
            except:
                pass
            time.sleep(2)
            
    stop_poker = threading.Event()
    t_poke = threading.Thread(target=poke_enter_thread, args=(ser, stop_poker), daemon=True)
    t_poke.start()
    
    res = wait_for_prompt(ser, [b'root@KT-KM12-007H:~#', b'root@OpenWrt:/#'], timeout=120)
    stop_poker.set()  # Stop pressing Enter
    
    if res['status'] == 'success':
        # Send command to get MACs
        logging.info("System booted! Extracting MAC addresses...")
        time.sleep(2)
        # Clear buffer
        ser.read(ser.in_waiting)
        # Send exact requested command
        ser.write(b'for i in $(ls /sys/class/net); do echo "$i: $(cat /sys/class/net/$i/address)"; done\r\n')
        
        # Read the buffer to capture the output until the terminal prompt returns
        mac_res = wait_for_prompt(ser, [b'root@KT-KM12-007H:~#', b'root@OpenWrt:/#'], timeout=10)
        buffer_str = ""
        if 'buffer' in mac_res:
            buffer_str = mac_res['buffer'].decode('utf-8', 'ignore')
            
        allowed = ['lan', 'wan', 'phy0-ap0', 'phy1-ap0']
        found_macs = []
        for line in buffer_str.split('\n'):
            line = line.strip().replace('\r', '')
            # Parse output format: "lan: 00:11:22:33:44:55"
            try:
                if ":" in line:
                    parts = line.split(":", 1)
                    iface = parts[0].strip()
                    mac = parts[1].strip()
                    if iface in allowed and len(mac.split(":")) >= 6:
                        found_macs.append(f"{iface}: {mac}")
            except:
                pass
        
        if found_macs:
            mac_text = "\n".join(found_macs)
            logging.info(f"\nExtracted MAC Addresses:\n{mac_text}")
            messagebox.showinfo("الماكات الحالية في الراوتر", f"تم إقلاع الراوتر بنجاح!\n\nهذه هي الماكات الحالية:\n{mac_text}\n\nقارنها مع ظهر الراوتر لمعرفة إن كنت بحاجة لـ (إصلاح وتعديل الماك).")
        else:
            messagebox.showwarning("تنبيه", "تم الإقلاع لكن لم نعثر على الماكات المطلوبة في المخرجات.")
    else:
        messagebox.showwarning("تنبيه", "تأخر إقلاع OpenWrt. يرجى المتابعة يدوياً لمعرفة الماك.")

    if messagebox.askyesno("إنهاء الاتصال", "هل تريد إغلاق المنفذ التسلسلي والعودة للنافذة الرئيسية؟\nاختر 'لا' لإبقاء نافذة الأوامر السوداء مفتوحة للتحكم اليدوي والمراقبة المستمرة كبرنامج Tera Term."):
        close_serial_session()
        return True
    else:
        logging.info("المنفذ لا يزال مفتوحاً. يمكنك الآن كتابة أي أوامر والتفاعل اليدوي بحرية تامة.")
        logging.info("لإنهاء الاتصال بشكل كامل، قم بإغلاق نافذة البرنامج.")
        run_live_uart_terminal(ser)
        close_serial_session()
        return True

def edit_mac_in_file(mac_address):
    mac_clean = mac_address.replace(":", "").replace("-", "").strip()
    if len(mac_clean) != 12:
        return False, "الماك أدرس يجب أن يتكون من 12 حرف أو رقم."

    try:
        new_mac_bytes = bytes.fromhex(mac_clean)
    except ValueError:
        return False, "الماك أدرس يحتوي على أحرف غير صالحة (يجب أن يكون Hex فقط)."

    def format_mac(raw_bytes):
        return ":".join(f"{b:02X}" for b in raw_bytes)
        
    if not os.path.exists(CONFIG_FILE):
        paths_text = "\n".join(CONFIG_FILE_CANDIDATES)
        return False, (
            "لم يتم العثور على ملف الكونفيج المطلوب للتعديل.\n"
            f"المسارات التي تم فحصها:\n{paths_text}"
        )
        
    try:
        with open(CONFIG_FILE, 'rb') as f:
            data = bytearray(f.read())
            
        target_offset = 40004

        if len(data) < target_offset + 6:
            return False, "حجم ملف الكونفيج أصغر من المتوقع ولا يمكن تعديل الماك بأمان."

        old_mac_bytes = bytes(data[target_offset:target_offset + 6])

        if old_mac_bytes == new_mac_bytes:
            return True, (
                "لم يتم إجراء تغيير لأن الماك الموجود في الملف مطابق للمدخل.\n"
                f"الملف: {CONFIG_FILE}\n"
                f"MAC الحالي: {format_mac(old_mac_bytes)}"
            )
            
        for i in range(6):
            data[target_offset + i] = new_mac_bytes[i]
            
        with open(CONFIG_FILE, 'wb') as f:
            f.write(data)

        # Verify bytes after write to make sure edit was applied.
        with open(CONFIG_FILE, 'rb') as f:
            verify_data = f.read()
        verify_mac_bytes = verify_data[target_offset:target_offset + 6]
        if verify_mac_bytes != new_mac_bytes:
            return False, "فشل التحقق بعد الحفظ: لم تتطابق قيمة الماك داخل الملف."

        return True, (
            "تم تعديل الماك داخل الملف بنجاح.\n"
            f"الملف: {CONFIG_FILE}\n"
            f"قبل: {format_mac(old_mac_bytes)}\n"
            f"بعد: {format_mac(verify_mac_bytes)}"
        )
    except Exception as e:
        return False, str(e)

def perform_ssh_updates():
    logging.info(f"[SSH] Starting MAC patching using native OpenSSH to {ROUTER_IP}...")

    ssh_path = shutil.which("ssh")
    scp_path = shutil.which("scp")
    if not ssh_path or not scp_path:
        missing = []
        if not ssh_path:
            missing.append("ssh")
        if not scp_path:
            missing.append("scp")
        missing_text = ", ".join(missing)
        logging.error(f"[SSH] Missing system tools: {missing_text}")
        messagebox.showerror(
            "أدوات SSH غير متوفرة",
            f"لم يتم العثور على {missing_text} في النظام.\n"
            "قم بتثبيت OpenSSH Client من إعدادات ويندوز ثم أعد المحاولة."
        )
        return False, False
    
    ssh_opts = [
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=NUL",
        "-o", "ConnectTimeout=5",
        "-o", "LogLevel=ERROR",
        "-o", "BatchMode=yes"
    ]
    
    connected = False
    for i in range(15):  # 75 seconds total wait max
        try:
            # Check SSH connection
            cmd = [ssh_path] + ssh_opts + [f"root@{ROUTER_IP}", "echo connected"]
            result = subprocess.run(cmd, capture_output=True, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
            if "connected" in result.stdout:
                connected = True
                break

            if "Permission denied" in result.stderr:
                logging.error(f"[SSH Auth]: {result.stderr.strip()}")
                messagebox.showerror(
                    "خطأ مصادقة SSH",
                    "تم رفض تسجيل الدخول عبر SSH. تأكد من إعدادات المستخدم root وكلمة المرور/المفتاح."
                )
                return False, False
        except Exception as e:
            logging.error(f"[SSH] Connection probe failed: {e}")
            break
        logging.info(f"[SSH] Waiting for router to reply on SSH (Attempt {i+1}/15)...")
        time.sleep(5)
            
    if not connected:
        messagebox.showerror("خطأ", f"فشل الاتصال بالراوتر. تأكد من أن الراوتر يعمل، والكمبيوتر متصل به.\nالآيبي: {ROUTER_IP}")
        return False, False
        
    logging.info("[SCP] Router is awake! Uploading patched Config.bin (-O legacy mode)...")
    try:
        # Try SCP with -O (Legacy protocol requirement for Dropbear)
        scp_cmd = [scp_path, "-O"] + ssh_opts + [CONFIG_FILE, f"root@{ROUTER_IP}:/tmp/Config.bin"]
        proc = subprocess.run(scp_cmd, capture_output=True, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        if proc.returncode != 0 and "unknown option" in proc.stderr.lower():
            # Fallback if Windows OpenSSH is older
            scp_cmd = [scp_path] + ssh_opts + [CONFIG_FILE, f"root@{ROUTER_IP}:/tmp/Config.bin"]
            proc = subprocess.run(scp_cmd, capture_output=True, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        
        if proc.returncode != 0:
            logging.error(f"[SCP Error]: {proc.stderr}")
            messagebox.showerror("خطأ في النقل", f"فشل رفع الملف إلى الراوتر:\n{proc.stderr}")
            return False, False
            
    except Exception as e:
        logging.error(f"[SCP] File transfer failed: {e}")
        return False, False
    
    logging.info("[SSH] Extracting and writing Config MTD partition...")
    commands = (
        "insmod mtd-rw i_want_a_brick=1; "
        "sleep 1; "
        "mtd unlock /dev/mtd1; "
        "sleep 1; "
        "mtd write /tmp/Config.bin Config"
    )
    
    try:
        ssh_cmd = [ssh_path] + ssh_opts + [f"root@{ROUTER_IP}", "sh", "-c", commands]
        proc = subprocess.run(ssh_cmd, capture_output=True, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        if proc.returncode != 0:
            logging.error(f"[SSH Command Error]: {proc.stderr}")
            messagebox.showerror("خطأ في تنفيذ أوامر SSH", f"فشل تنفيذ الأوامر على الراوتر:\n{proc.stderr}")
            return False, False
    except Exception as e:
        logging.error(f"[SSH] Command execution failed: {e}")
        return False, False

    if not messagebox.askyesno("تأكيد إعادة التشغيل", "تمت كتابة ملف Config على الراوتر بنجاح.\n\nهل تريد إعادة تشغيل الراوتر الآن؟"):
        logging.info("[SSH] Reboot skipped by user.")
        return True, False

    try:
        reboot_cmd = [ssh_path] + ssh_opts + [f"root@{ROUTER_IP}", "reboot"]
        reboot_proc = subprocess.run(reboot_cmd, capture_output=True, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        if reboot_proc.returncode != 0:
            logging.error(f"[SSH Reboot Error]: {reboot_proc.stderr}")
            messagebox.showerror("خطأ في إعادة التشغيل", f"تمت الكتابة لكن فشل أمر إعادة التشغيل:\n{reboot_proc.stderr}")
            return False, False
        logging.info("[SSH] Config successfully flashed! Reboot command sent.")
    except Exception as e:
        logging.error(f"[SSH] Reboot command failed: {e}")
        return False, False
        
    return True, True

class AppGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("مدير تفليش وإصلاح الراوتر - إصدار محمول ومستقل")
        self.root.geometry("480x350")
        
        lbl = tk.Label(root, text="برنامج التحكم الشامل المستقل (Portable)", font=("Arial", 16, "bold"))
        lbl.pack(pady=20)
        
        btn_flash = tk.Button(root, text="1. التفليش العادي الذكي (سيريال)", command=self.do_flash, font=("Arial", 14), width=35, height=2, bg="#4CAF50", fg="white")
        btn_flash.pack(pady=10)
        
        btn_repair = tk.Button(root, text="2. إصلاح الروتر وتعديل الماك (SSH)", command=self.do_repair, font=("Arial", 14), width=35, height=2, bg="#2196F3", fg="white")
        btn_repair.pack(pady=10)
        
        lbl_info = tk.Label(root, text="جميع الملفات وسيرفر TFTP يعملون بأمان من نفس هذا المجلد.", font=("Arial", 9), fg="gray")
        lbl_info.pack(side="bottom", pady=10)

    def do_flash(self):
        port = get_com_port()
        if not port: return
        
        self.root.withdraw()
        
        try:
            # 1. Run the Serial Flashing and detect errors automatically
            run_serial_workflow(port)
        except KeyboardInterrupt:
            logging.info("[User] تم إيقاف العملية بواسطة المستخدم (Ctrl+C).")
            try:
                stop_serial_reader()
            except Exception:
                pass
            messagebox.showinfo(
                "تم الإيقاف",
                "تم إيقاف العملية بواسطة المستخدم.\n"
                "يمكنك إعادة المحاولة أو استخدام برنامج Tera Term للتحكم اليدوي."
            )
            self.root.deiconify()
            return
        
        # 2. Ask user if they need to fix the MAC
        if messagebox.askyesno("خطوة اختيارية", "العملية اكتملت.\n\nهل تريد تنفيذ الخيار الثاني (إصلاح / تعديل الماك) الآن مباشرة؟"):
            self.do_repair_logic()
        
        self.root.deiconify()

    def do_repair(self):
        self.root.withdraw()
        self.do_repair_logic()
        self.root.deiconify()
        
    def do_repair_logic(self):
        new_mac = simpledialog.askstring("إدخال الماك", "أدخل رقم الماك الصحيح (المكتوب خلف الراوتر):")
        if not new_mac:
            messagebox.showwarning("تنبيه", "تم إلغاء عملية التعديل والإصلاح.")
            return
            
        success, err = edit_mac_in_file(new_mac)
        if not success:
            messagebox.showerror("خطأ في الماك", f"فشل في تعديل الملف:\n{err}")
            return

        messagebox.showinfo("نتيجة تعديل الملف", err)
            
        messagebox.showinfo(
            "تنبيه",
            f"سيتم الآن رفع ملف الكونفيج المعدل إلى الراوتر:\n{CONFIG_FILE}\n\n"
            f"آيبي الراوتر: {ROUTER_IP}\n"
            "تأكد أن الراوتر يعمل وأن سلك الشبكة موصول."
        )
        
        ssh_ok, reboot_done = perform_ssh_updates()
        if ssh_ok:
            if reboot_done:
                messagebox.showinfo("نجاح", "تمت كتابة ملف الـ Config بنجاح وإرسال أمر إعادة تشغيل الراوتر.\nيرجى فتح صفحة الويب للراوتر للتأكد من تعديل الماك.")
            else:
                messagebox.showinfo("نجاح", "تمت كتابة ملف الـ Config بنجاح بدون إعادة تشغيل.\nيمكنك إعادة تشغيل الراوتر يدوياً متى أردت.")

if __name__ == '__main__':
    # Start embedded TFTP Server
    tftp_thread = threading.Thread(target=start_tftp_server, daemon=True)
    tftp_thread.start()
    
    root = tk.Tk()
    app = AppGUI(root)
    root.mainloop()
