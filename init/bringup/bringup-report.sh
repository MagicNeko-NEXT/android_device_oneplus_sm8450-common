#!/vendor/bin/sh
# Bring-up only (userdebug): show a static status report on the panel console,
# so a boot without USB can still be read from a photo. Starts at init. Kernel
# messages stop going to the panel; they stay in dmesg.

sleep 25
mount -t debugfs debugfs /sys/kernel/debug 2>/dev/null

T=/dev/tty0
n=0
while [ $n -lt 90 ]; do
  n=$((n+1))
  # Keep the console quiet (init and drivers keep raising it).
  echo 0 > /sys/module/printk/parameters/ignore_loglevel 2>/dev/null
  echo "1 1 1 1" > /proc/sys/kernel/printk 2>/dev/null
  {
    printf '\033[2J\033[H'
    echo "=== BOOT REPORT $n  up $(cut -d' ' -f1 /proc/uptime)  /data=[$(grep -c ' /data ' /proc/mounts)] boot_completed=[$(getprop sys.boot_completed)] ==="
    echo "USB: udc=[$(ls /sys/class/udc 2>/dev/null)] config=[$(getprop sys.usb.config)] state=[$(getprop sys.usb.state)] adbd=[$(getprop init.svc.adbd)] dwc3_msm=$(grep -c '^dwc3_msm ' /proc/modules)"
    echo "SVC: composer=[$(getprop init.svc.vendor.qti.hardware.display.composer)] allocator=[$(getprop init.svc.vendor.qti.hardware.display.allocator)] sf=[$(getprop init.svc.surfaceflinger)] zygote=[$(getprop init.svc.zygote)] msm_drm=$(grep -c '^msm_drm ' /proc/modules)"
    echo "--- deferred ($(grep -c . /sys/kernel/debug/devices_deferred 2>/dev/null)) ---"
    head -6 /sys/kernel/debug/devices_deferred 2>/dev/null | cut -c1-134
    echo "--- newest tombstone ---"
    TS=$(ls -t /data/tombstones/tombstone_* 2>/dev/null | grep -v '\.pb$' | head -1)
    if [ -n "$TS" ]; then
      grep -m1 '^Cmdline:' "$TS" | cut -c1-134
      grep -m1 -E '^signal|^Abort message' "$TS" | cut -c1-134
      grep -m1 '^Abort message' "$TS" | cut -c1-268 | fold -w 134
      grep -E '^ +#[0-9]{2} pc' "$TS" | head -8 | cut -c1-134
    else
      echo "(none)"
    fi
    echo "--- logcat composer/sf errors ---"
    logcat -d -b main,system,crash '*:E' 2>/dev/null \
      | grep -iE 'composer|hwc|sdm|SurfaceFlinger|gralloc|allocator|drm|FATAL|DEBUG' \
      | tail -14 | cut -c1-134
    echo "--- dmesg usb ---"
    dmesg | grep -iE 'dwc3|a600000|eusb|repeater|hsphy|UDC' | grep -v sync_state | tail -4 | cut -c1-134
  } > $T 2>&1
  sleep 20
done
