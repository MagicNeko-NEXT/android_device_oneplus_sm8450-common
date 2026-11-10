#!/vendor/bin/sh
# Bring-up only (userdebug): show a static status report on the panel console,
# so a boot without USB can still be read from a photo. Starts at init. Kernel
# messages stop going to the panel; they stay in dmesg.

sleep 25
mount -t debugfs debugfs /sys/kernel/debug 2>/dev/null
mount -t configfs none /config 2>/dev/null

if [ -e /dev/tty0 ]; then
  T=/dev/tty0
else
  T=/dev/console
fi
n=0
while [ $n -lt 90 ]; do
  n=$((n+1))
  # Ensure ADB gadget is bound if UDC is ready
  if [ -d /sys/class/udc/a600000.dwc3 ]; then
    UDC_CUR=$(cat /config/usb_gadget/g1/UDC 2>/dev/null)
    if [ "$UDC_CUR" != "a600000.dwc3" ]; then
      mkdir -p /config/usb_gadget/g1/configs/b.1/strings/0x409 2>/dev/null
      echo "adb" > /config/usb_gadget/g1/configs/b.1/strings/0x409/configuration 2>/dev/null
      mkdir -p /config/usb_gadget/g1/functions/ffs.adb 2>/dev/null
      mkdir -p /dev/usb-ffs/adb 2>/dev/null
      mount -t functionfs adb /dev/usb-ffs/adb 2>/dev/null
      start adbd 2>/dev/null
      if [ -e /dev/usb-ffs/adb/ep1 ] || [ "$(getprop sys.usb.ffs.ready)" = "1" ]; then
        ln -sf /config/usb_gadget/g1/functions/ffs.adb /config/usb_gadget/g1/configs/b.1/f1 2>/dev/null
        ln -sf /config/usb_gadget/g1/configs/b.1 /config/usb_gadget/g1/os_desc/b.1 2>/dev/null
        echo 0x18d1 > /config/usb_gadget/g1/idVendor 2>/dev/null
        echo 0x4ee7 > /config/usb_gadget/g1/idProduct 2>/dev/null
        echo "" > /config/usb_gadget/g1/UDC 2>/dev/null
        echo a600000.dwc3 > /config/usb_gadget/g1/UDC 2>/dev/null
        setprop sys.usb.config adb
        setprop sys.usb.state adb
      fi
    fi
  fi
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
      grep -m1 '^signal' "$TS" | cut -c1-134
      AB=$(grep -m1 '^Abort message' "$TS")
      if [ -n "$AB" ]; then
        echo "$AB" | cut -c1-134
        [ ${#AB} -gt 134 ] && echo "$AB" | cut -c135-268
      fi
      grep -E '^ +#[0-9]{2} pc' "$TS" | head -16 | cut -c1-134
    else
      echo "(none)"
    fi
    echo "--- logcat composer ---"
    logcat -d -b main,system,crash 2>/dev/null \
      | grep -iE 'composer|sdm|sde|hwc' \
      | tail -14 | cut -c1-134
    echo "--- dmesg usb ---"
    dmesg | grep -iE 'dwc3|a600000|eusb|repeater|hsphy|UDC' | grep -v sync_state | tail -4 | cut -c1-134
  } > $T 2>&1
  sleep 20
done
