# alemprator-mtax — ALemprator MT AX Tools

Prebuilt MIPS little-endian (mipsel_24kc) backend utilities extracted from the
device rootfs for Alemprator MT AX units. The binaries are statically linked
and UPX-packed; they are installed to `/usr/bin/`.

These tools are low-level device helpers. Most expect to run on the router
itself and operate directly on MTD partitions, EEPROM data, LEDs, wireless
interfaces and UCI. Use them with care — incorrect arguments (e.g. the wrong
MTD partition or MAC) can corrupt device calibration/identity data.

## Tools

### `alemprator`
Device identity / MAC tool ("ALemprator Guide Device Tools").
Reads/writes the device MAC stored in an MTD partition.

Usage (from embedded strings):
```
alemprator
  -p [num]   Partition number (default 1)
  -o [hex]   Offset (default 60004)
  -m [mac]   Full MAC, 6-char (merge), or empty (random)
```
Operates on `/dev/mtdblock<num>`. Prints `Error: mtd%s not found!` when the
partition is absent.

### `alempratore`
EEPROM manager ("ALemprator EEPROM Manager").
Reads/writes the Wi-Fi calibration EEPROM (e.g.
`/lib/firmware/mediatek/mt7915_eeprom_dbdc.bin`) and MTD blocks.

Usage (from embedded strings):
```
alie x [-o hex] [-b size] [-m num] [-sr path]
  -o hex    Offset
  -b size   Size
  -m num    Number/selector
  -sr path  Source/reset path
```
Supports a custom dump (`Custom Dump: Offset 0x%lX, Size 0x%lX`) and a reset
from a file (`Open file for reset failed`).

### `alemprator_f`
Factory / default provisioning helper. Writes initial `setup.default` UCI keys
such as `WS`, `WS5`, `K`, `lan_ipaddr`, `lan_netmask`, `R0H`, `R1H` via
`uci -q set setup.default.*`. Used to seed device baseline configuration.

### `alemprator_l`
LED control helper. Iterates `/sys/class/leds/*`, sets each LED trigger to
`none` and brightness to `0`, then restarts `/etc/init.d/led`. Used to force a
known LED state.

### `alemprator_m`
Wireless interface toggle/reload helper. Reads `wireless.<iface>.disabled`,
toggles it (disable then enable), commits wireless and calls
`ubus call network.interface.wlan reload`. Used to bounce the radio.

### `alemprator_m_l`
Mode-aware LED helper. Inspects the LED sysfs entries
(`blue:wds`, `green:mesh`, `blue:mesh`), reads the wireless interface mode
(`mesh`/`ap`/`sta`) and drives the `led_mesh_switch` LED section accordingly.

### `alemprator_c`
Proprietary helper (UPX-packed, no embedded usage string). Part of the MT AX
backend toolset; treat as internal.

### `alemprator_s`
Proprietary helper (UPX-packed, no embedded usage string). Part of the MT AX
backend toolset; treat as internal.

## Notes
- All binaries target `mipsel_24kc` only (set via `PKGARCH`).
- Sources are not included in this package; these are extracted artifacts.
- See the package `Makefile` for the exact install list under `/usr/bin`.
