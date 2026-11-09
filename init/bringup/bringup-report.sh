#!/vendor/bin/sh
# Bring-up only (userdebug): draw a static status report on the panel console
# every 20 s, so a boot without USB can still be read from a photo. Starts at
# init, before /data is mounted. Kernel messages stop going to the panel after
# the first report; they stay in dmesg and the report shows the relevant tails.

sleep 25
mount -t debugfs debugfs /sys/kernel/debug 2>/dev/null
echo N > /sys/module/printk/parameters/ignore_loglevel 2>/dev/null
dmesg -n 1 2>/dev/null

T=/dev/tty0
n=0
while [ $n -lt 90 ]; do
  n=$((n+1))
  {
    printf '\033[2J\033[H'
    echo "=== BOOT REPORT $n  up $(cut -d' ' -f1 /proc/uptime)  vold=[$(getprop vold.decrypt)] boot_completed=[$(getprop sys.boot_completed)] ==="
    echo "udc=[$(ls /sys/class/udc 2>/dev/null)] usb.config=[$(getprop sys.usb.config)] usb.state=[$(getprop sys.usb.state)] adbd=[$(getprop init.svc.adbd)]"
    echo "mods=$(grep -c . /proc/modules) dwc3_msm=$(grep -c '^dwc3_msm ' /proc/modules) tmecom=$(grep -c '^tmecom_intf ' /proc/modules) msm_qmp=$(grep -c '^msm_qmp ' /proc/modules) ipcc=$(grep -c '^qcom_ipcc ' /proc/modules) i2c_geni=$(grep -c '^i2c_msm_geni ' /proc/modules) /data=[$(grep -c ' /data ' /proc/mounts)]"
    echo "--- deferred ($(grep -c . /sys/kernel/debug/devices_deferred 2>/dev/null)) ---"
    head -22 /sys/kernel/debug/devices_deferred 2>/dev/null | cut -c1-134
    echo "--- dmesg tme/qmp/ipcc/hwkm/ice ---"
    dmesg | grep -iE 'tmecom|tmecon|qmp|ipcc|hwkm|ice|mailbox|mbox' | tail -10 | cut -c1-134
    echo "--- dmesg usb/i2c ---"
    dmesg | grep -iE 'dwc3|a600000|eusb|repeater|hsphy|ssphy|a98000|geni_i2c|I2C probed|SE Wrapper' \
      | grep -vE 'sync_state|UDC core: g1' | tail -8 | cut -c1-134
  } > $T 2>&1
  sleep 20
done
