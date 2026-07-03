import os
import pty
import sys
import select

# Command to run
cmd = ['rsync', '-avz', '--progress', '/home/galal/openwrt/', 'root@192.168.137.252:/home/galal/openwrt/']
password = "123456\n"

print("Starting rsync copy to 192.168.137.252...", flush=True)

pid, fd = pty.fork()

if pid == 0:
    # Child process
    os.execvp(cmd[0], cmd)
else:
    # Parent process
    password_sent = False
    buffer = b""
    while True:
        try:
            r, w, x = select.select([fd], [], [], 1.0)
            if fd in r:
                data = os.read(fd, 1024)
                if not data:
                    break
                # Print to stdout
                sys.stdout.buffer.write(data)
                sys.stdout.flush()
                
                buffer += data
                if b"password" in buffer.lower() and not password_sent:
                    os.write(fd, password.encode())
                    password_sent = True
                    buffer = b""
        except OSError:
            break

print("\nCopy completed!", flush=True)
