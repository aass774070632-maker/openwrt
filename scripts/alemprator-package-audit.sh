#!/bin/sh

set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
PACKAGES="alemprator-firstboot luci-app-setup luci-app-alemprator-ota alemprator-suite"
TMP_DIR="$(mktemp -d)"
OWNERS_FILE="$TMP_DIR/owners.tsv"
TRAPS=""

cleanup() {
	rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

extract_targets() {
	package_name="$1"
	makefile="$ROOT/package/$package_name/Makefile"

	[ -f "$makefile" ] || return 0

	awk -v pkg="$package_name" '
		function normalize(raw, cleaned) {
			cleaned = raw
			gsub(/^[[:space:]]+|[[:space:]]+$/, "", cleaned)
			gsub(/\$\(1\)/, "", cleaned)
			gsub(/\r/, "", cleaned)
			return cleaned
		}
		function emit(type, raw, cleaned) {
			cleaned = normalize(raw)
			gsub(/\/+$/, "", cleaned)
			if (cleaned == "")
				return
			if (cleaned !~ /^\//)
				return
			print cleaned "\t" pkg "\t" type
		}
		function emit_install(type, source_raw, target_raw, source, target, n, parts) {
			source = normalize(source_raw)
			target = normalize(target_raw)
			if (target == "" || target !~ /^\//)
				return
			if (target ~ /\/$/) {
				n = split(source, parts, "/")
				if (n == 0)
					return
				target = target parts[n]
			}
			gsub(/\/+$/, "", target)
			print target "\t" pkg "\t" type
		}
		{ sub(/\r$/, "") }
		$0 ~ /^define Package\/.+\/install$/ { in_install = 1; next }
		$0 ~ /^endef$/ { if (in_install) in_install = 0 }
		!in_install { next }
		/\$\(INSTALL_(BIN|CONF|DATA)\)/ {
			source = $(NF - 1)
			target = $NF
			emit_install("file", source, target)
			next
		}
		/\$\(INSTALL_DIR\)/ {
			for (i = 2; i <= NF; i++)
				emit("dir", $i)
			next
		}
		/\$\(LN\)/ {
			target = $NF
			emit("symlink", target)
			next
		}
	' "$makefile"
}

for package_name in $PACKAGES; do
	extract_targets "$package_name"
done | sort -u > "$OWNERS_FILE"

echo "== Alemprator package ownership audit =="
echo "root=$ROOT"
echo
echo "[Owned install targets]"
cat "$OWNERS_FILE"
echo
echo "[Duplicate file ownership]"

duplicates_found=0
awk -F '\t' '
	$3 != "file" && $3 != "symlink" { next }
	{
		owners[$1] = owners[$1] ? owners[$1] ", " $2 : $2
		count[$1]++
	}
	END {
		for (path in count) {
			if (count[path] > 1) {
				print path "\t" owners[path]
			}
		}
	}
' "$OWNERS_FILE" | sort | while IFS='\t' read -r path owners; do
	duplicates_found=1
	printf '%s\t%s\n' "$path" "$owners"
done

if awk -F '\t' '$3 == "file" || $3 == "symlink" { count[$1]++ } END { for (path in count) if (count[path] > 1) exit 1 }' "$OWNERS_FILE"; then
	echo "none"
	dup_exit=0
else
	dup_exit=1
fi

echo
echo "[Controller overlap checkpoints]"
printf '%s\n' "setup.default <- luci-app-setup uci-defaults + alemprator-firstboot uci-defaults/init"
printf '%s\n' "network.lan <- luci-app-setup init + alemprator-firstboot uci-defaults"
printf '%s\n' "wireless wizardvlan <- luci-app-setup view/uci-defaults + alemprator-firstboot provisioning"
printf '%s\n' "/etc/model + firmware-version <- luci-app-alemprator-ota"

exit "$dup_exit"