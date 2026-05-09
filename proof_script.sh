#!/bin/bash
simulate_98_custom() {
    BOARD="$1"
    echo "--- محاكاة الجهاز: $BOARD ---"
    # محاكاة مخرجات ubus
    ubus_output="{\"board_name\":\"$BOARD\"}"
    
    # استخراج المنطق من 98_custom
    MODEL_NAME=$(echo "$ubus_output" | python3 -c "import sys, json; data=json.load(sys.stdin); bn=data['board_name']; print('DV02-012H' if bn=='kt,dv02-012h' else 'AR07-102H' if bn=='kt,ar07-102h' else 'AR06-012H' if bn=='kt,ar06-012h' else 'OpenWrt')")
    
    echo "اسم الموديل المكتشف: $MODEL_NAME"
    echo "الاسم في النظام (Hostname): KT-$MODEL_NAME"
    echo "اسم شبكة الواي فاي (SSID): ${MODEL_NAME}-5G_XXXX"
}

simulate_98_custom "kt,dv02-012h"
simulate_98_custom "kt,ar07-102h"
