with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'r') as f:
    text = f.read()

# Fix DHCP options
old_dhcp_1 = 'case "$options" in *192.168.10*|*192.168.20*|*/hotspot*) uci -q delete "dhcp.$section.dhcp_option" && mark_changed ;; esac'
new_dhcp_1 = 'case "$options" in */hotspot*) uci -q delete "dhcp.$section.dhcp_option" && mark_changed ;; esac'

old_dhcp_2 = 'case "$value" in *192.168.10*|*192.168.20*|*/hotspot*) uci -q delete "dhcp.$section.option114" && mark_changed ;; esac'
new_dhcp_2 = 'case "$value" in */hotspot*) uci -q delete "dhcp.$section.option114" && mark_changed ;; esac'

# Wait, the previous block also had '*tun0*|*tun1*|*hotspot*|*hotspot2*|*192.168.10*|*192.168.20*)' for chilli?
# No, looking at the cat output right above this, chilli is fixed:
# case "$dhcpif:$network" in
#        *hotspot_openwrt*|*" hotspot "*|*" hotspot2 "*) delete_section "chilli.$section" ;;
# esac
# So chilli is indeed fixed! ONLY DHCP failed.

text = text.replace(old_dhcp_1, new_dhcp_1)
text = text.replace(old_dhcp_2, new_dhcp_2)

with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'w') as f:
    f.write(text)

