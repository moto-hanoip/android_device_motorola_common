#!/vendor/bin/sh
# For when utags is loaded
# Set the properties contained
echo 1 > /proc/config/reload
echo 1 > /proc/hw/reload
exclude_dirs=("all" "reload")

for dir in /proc/hw/*; do
    exclude=0
    for exclude_dir in "${exclude_dirs[@]}"; do
        if [ "$(basename "$dir")" = "$exclude_dir" ]; then
            exclude=1
            break
        fi
    done

    if [ "$exclude" -eq 0 ]; then
        ascii=$(cat "$dir/ascii")
        if [ -z "$ascii" ]; then
            continue
        fi
        if [ "${dir:9}" = "nfc" ]; then
            nfc="$ascii"
        fi
        echo "ro.vendor.hw.${dir:9}" "$ascii"
        setprop "ro.vendor.hw.${dir:9}" "$ascii"
    fi
done

# Set RAM property based on system RAM
# Get amount of RAM in the system
MemTotalStr=$(cat /proc/meminfo | grep MemTotal)
MemTotal=${MemTotalStr:16:8}
let RamSizeGB="( $MemTotal / 1048576 ) + 1"

setprop ro.vendor.hw.ram "$RamSizeGB"GB

# SKU handling
if [ -n "$nfc" ] && [ "$nfc" != "false" ]; then
    setprop vendor.boot.product.hardware.sku n
else
    setprop vendor.boot.product.hardware.sku d
fi
