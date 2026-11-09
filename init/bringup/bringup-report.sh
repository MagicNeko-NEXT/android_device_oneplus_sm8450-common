#!/vendor/bin/sh
# Bring-up only (userdebug): draw a static status report on the panel console
# every 30 s, so a normal boot without USB can still be read from a photo.
# Kernel messages stop going to the panel after the first report; they stay
# in dmesg and the report shows the relevant tails.

sleep 60
mount -t debugfs debugfs /sys/kernel/debug 2>/dev/null
echo N > /sys/module/printk/parameters/ignore_loglevel 2>/dev/null
dmesg -n 1 2>/dev/null

T=/dev/tty0
n=0
while [ $n -lt 60 ]; do
  n=$((n+1))
  {
    printf '\033[2J\033[H'
    echo "=== BOOT REPORT $n  uptime $(cut -d' ' -f1 /proc/uptime)  boot_completed=[$(getprop sys.boot_completed)] ==="
    echo "udc=[$(ls /sys/class/udc 2>/dev/null)] usb.config=[$(getprop sys.usb.config)] usb.state=[$(getprop sys.usb.state)]"
    echo "msm_drm=[$(grep -c '^msm_drm ' /proc/modules)] dwc3_msm=[$(grep -c '^dwc3_msm ' /proc/modules)] modules=$(grep -c . /proc/modules)"
    echo "composer=[$(getprop init.svc.vendor.qti.hardware.display.composer)] sf=[$(getprop init.svc.surfaceflinger)] zygote=[$(getprop init.svc.zygote)] adbd=[$(getprop init.svc.adbd)]"
    echo "--- deferred ($(grep -c . /sys/kernel/debug/devices_deferred 2>/dev/null)) ---"
    head -8 /sys/kernel/debug/devices_deferred 2>/dev/null | cut -c1-134
    echo "--- dmesg usb/drm ---"
    dmesg | grep -iE 'dwc3|a600000|eusb|repeater|msm_drm|sde_kms|dsi_display|\[drm\]' \
      | grep -vE 'sync_state|UDC core: g1' | tail -12 | cut -c1-134
    echo "--- logcat crash ---"
    logcat -d -b crash 2>/dev/null | grep -vE '^-+ beginning' | tail -14 | cut -c1-134
    echo "--- logcat display errors ---"
    logcat -d '*:E' 2>/dev/null | grep -iE 'composer|hwc|sdm|SurfaceFlinger|drm|gralloc|allocator' \
      | tail -12 | cut -c1-134
  } > $T 2>&1
  sleep 30
done
