#
# Copyright (C) 2021-2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Add common definitions for Qualcomm
$(call inherit-product, hardware/qcom-caf/common/common.mk)

# A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=erofs \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script

# Bring-up: on-screen boot report (userdebug only)
ifeq ($(TARGET_BUILD_VARIANT),userdebug)
PRODUCT_PACKAGES += \
    bringup-report.sh \
    su \
    init.ovaltine.bringup.rc

# Bring-up: ADB force-authorization and root access
PRODUCT_ADB_KEYS ?= $(LOCAL_PATH)/init/adb_keys

PRODUCT_PROPERTY_OVERRIDES += \
    ro.adb.secure=0 \
    persist.sys.debug_enabled=1 \
    service.adb.root=1

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.adb.secure=0 \
    persist.sys.debug_enabled=1 \
    service.adb.root=1

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init/adb_keys:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/adb_keys \
    $(LOCAL_PATH)/init/adb_keys:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/adb_keys \
    $(LOCAL_PATH)/init/adb_keys:$(TARGET_COPY_OUT_VENDOR)/etc/security/adb_keys
endif

# IFAA
PRODUCT_PACKAGES += \
    IFAAService

# Audio
PRODUCT_PACKAGES += \
    audiohalservice.qti \
    libagmipcservice \
    libpalipcservice \
    libaudiocorehal.qti \
    libaudiocorehal.default \
    libaudioeffecthal.qti \
    libsoundtriggerhal.qti \
    android.hardware.bluetooth.audio-impl \
    audioadsprpcd \
    audio.bluetooth.default \
    audio.r_submix.default \
    audio.usb.default \
    lib_bt_aptx \
    lib_bt_ble \
    lib_bt_bundle \
    libagm_compress_plugin \
    libagm_mixer_plugin \
    libagm_pcm_plugin \
    libbatterylistener \
    libeffectproxy \
    libfmpal \
    libhapticgenerator \
    libldnhncr \
    libpalclient \
    libqcompostprocbundle \
    libqcomvisualizer \
    libqcomvoiceprocessing \
    libreverbwrapper \
    libvisualizer \
    libvolumelistener

AUDIO_HAL_DIR := hardware/qcom-caf/sm8450-6.6/audio/primary-hal
QCV_FAMILY_SKUS := cape taro

PRODUCT_COPY_FILES += \
    $(AUDIO_HAL_DIR)/configs/common/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(AUDIO_HAL_DIR)/configs/taro/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(AUDIO_HAL_DIR)/configs/taro/card-defs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/card-defs.xml \
    $(AUDIO_HAL_DIR)/configs/taro/microphone_characteristics.xml:$(TARGET_COPY_OUT_VENDOR)/etc/microphone_characteristics.xml \
    $(AUDIO_HAL_DIR)/configs/parrot/vendor_audio_interfaces.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/vendor_audio_interfaces.xml \
    hardware/interfaces/audio/aidl/default/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects_config.xml \
    $(LOCAL_PATH)/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/audio_policy_configuration.xml \
    $(LOCAL_PATH)/audio/audio_policy_configuration_a2dp_offload_disabled.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration_a2dp_offload_disabled.xml \
    $(LOCAL_PATH)/audio/bluetooth_hearing_aid_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_hearing_aid_audio_policy_configuration.xml

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration_7_0.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.audio.pro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.pro.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

# Bluetooth
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

# Boot control
PRODUCT_PACKAGES += \
    android.hardware.boot-service.qti \
    android.hardware.boot-service.qti.recovery

# Camera
PRODUCT_PACKAGES += \
    vendor.oplus.hardware.performance-service

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.concurrent.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.concurrent.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml

# Dalvik
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

# DebugFS
PRODUCT_SET_DEBUGFS_RESTRICTIONS := true

# Display
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@4.0-impl-qti-display \
    mapper.qti \
    init.qti.display_boot.rc \
    init.qti.display_boot.sh \
    vendor.qti.hardware.display.allocator-service \
    vendor.qti.hardware.display.demura-service

ifeq ($(TARGET_USES_PREBUILT_HWC),true)
PRODUCT_PACKAGES += \
    vendor.qti.hardware.display.composer-service.rc \
    vendor.qti.hardware.display.composer-service.xml
else
PRODUCT_PACKAGES += \
    vendor.qti.hardware.display.composer-service
endif

# DPPS runtime dependency: libdpps.so's DT_NEEDED is libtinyxml2-v34.so (OOS16 generation blob).
# hardware/lineage/compat already has this VNDK-34 prebuilt (vndk/v34/arm64),
# but LineageOS/crDroid don't install it by default; libdpps loads via dlopen, so the build can't see the dependency,
# and without an explicit install the load fails silently and DPPS degrades to Dummy.
PRODUCT_PACKAGES += \
    libtinyxml2-v34

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm-service.clearkey \
    wvmkiller

# Fastboot
PRODUCT_PACKAGES += \
    android.hardware.fastboot-service.example_recovery \
    fastbootd

# GPS
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml

# Graphics
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-service.qti \
    android.hardware.health-service.qti_recovery

# Hotword enrollment
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/privapp-permissions-hotword.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-hotword.xml

# IPACM
PRODUCT_PACKAGES += \
    ipacm \
    IPACM_cfg.xml

# t16: also put fstab in the vendor ramdisk's first_stage_ramdisk/
#   Why: AOSP docs (vendor-boot-partitions) require the device fstab in
#           $(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/,
#           otherwise first-stage init can't find fstab and never reaches the boot animation.
#   See AOSP's own usage (same form):
#     device/google/cuttlefish/shared/minidroid/device.mk:107
#     device/generic/goldfish/board/emu64a/details.mk:20
#   Why not prebuilt_etc: in this tree prebuilt_etc + vendor_ramdisk_available
#           only outputs to vendor_ramdisk/system/etc/, and the build graph
#           has no first_stage_ramdisk at all (measured 0 matches).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init/fstab.qcom:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.qcom

# Init
PRODUCT_PACKAGES += \
    fstab.qcom \
    fstab.qcom.vendor_ramdisk \
    init.class_main.sh \
    init.kernel.post_boot-cape.sh \
    init.kernel.post_boot-taro.sh \
    init.oplus.hw.rc \
    init.oplus.hw.recovery.rc \
    init.oplus.rc \
    init.qcom.early_boot.sh \
    init.qcom.rc \
    init.qcom.recovery.rc \
    init.qcom.sh \
    init.qcom.usb.rc \
    init.qcom.usb.sh \
    init.target.rc \
    ueventd.oplus.rc \
    ueventd.qcom.rc

$(call soong_config_set,libinit,vendor_init_lib,//$(LOCAL_PATH):libinit_oplus)

# Kernel
PRODUCT_ENABLE_UFFD_GC := false

# Lineage Health
PRODUCT_PACKAGES += \
    vendor.lineage.health-service.default

$(call soong_config_set,lineage_health,charging_control_charging_path,/sys/class/oplus_chg/battery/mmi_charging_enable)

# LiveDisplay
PRODUCT_PACKAGES += \
    vendor.lineage.livedisplay-service.oplus

# SunlightEnhancement uses the SDM backend; on sm8450 with the current display blobs it aborts during Init
# (Failed to initialize SDM backend), so livedisplay-service restarts repeatedly.
# Upstream (Bruno Martins, 4d80841 / 49e4076) disables it and leaves HBM to display config.
$(call soong_config_set_bool,OPLUS_LINEAGE_LIVEDISPLAY_HAL,ENABLE_SE,false)

# PictureAdjustment uses the SDM backend; disp_api_init() returns non-zero when SDMController is constructed,
# triggering LOG(FATAL) and an endless livedisplay-service restart (see tombstone: Failed to initialize SDM backend).
# Disabled so the service can start. (Nobody fixed this upstream, so it has to be disabled here)
# [2026-11-01] PA enabled for testing: composer holds SDM exclusively, expected hctx_=0 silent failure without a crash
# [2026-11-01] PA disabled: testing showed PictureAdjustment::PictureAdjustment, when the backend isn't ready,
# aborts directly via LOG(FATAL) (Abort message: PictureAdjustment backend not ready, exiting.),
# causing endless livedisplay-service SIGABRT and taking AF down with it (same binary).
# The root cause is composer holding the DRM master exclusively, so PA can never get SDM; hence disabled.
$(call soong_config_set_bool,OPLUS_LINEAGE_LIVEDISPLAY_HAL,ENABLE_PA,false)

# [2026-11-01] AntiFlicker (DC dimming/anti-flicker) enabled. Uses only /dev/oplus_display PWM_TURBO and
# DIMLAYER_BL_EN ioctls (both implemented in the driver's panel_ioctls[]), and doesn't touch the SDM backend.
$(call soong_config_set_bool,OPLUS_LINEAGE_LIVEDISPLAY_HAL,ENABLE_AF,true)

#   ENABLE_DM=false: this panel's (BOE rm692e5) DTSI has no mdss-dsi-seed-* commands,
#   so IDisplayModes via PANEL_IOCTL_SET_SEED does nothing; more importantly, once dm.xml is in the package the device gets
#   lineagehardware:FEATURE_DISPLAY_MODES, and in Settings display_settings.xml's
#   LineagePartsPreference(replacesKey="color_mode") replaces AOSP's Colors entry,
#   leaving neither usable. Only with it removed does AOSP's ColorModePreference appear,
#   with config_availableColorModes=[0,7,9] matching the NATIVE/SRGB/DISPLAY_P3 that SDM STC actually provides.
$(call soong_config_set_bool,OPLUS_LINEAGE_LIVEDISPLAY_HAL,ENABLE_DM,false)

# AdaptiveBacklight (auto brightness enhancement / CABC).
# The default branch is an empty array ⇒ vintf_fragment isn't packaged and cflags become -DENABLE_AB=false,
# so the AIDL interface IAdaptiveBacklight doesn't exist in VINTF ⇒ the framework can't get it,
# and auto brightness degrades to a bare mapping without backlight enhancement, showing as sluggish and jumpy.
# Why it's safe (service.cpp):
#   SDMController is only constructed when (ENABLE_DM || ENABLE_PA), and AB isn't in that condition;
#   AdaptiveBacklight itself only does open("/dev/oplus_display") + ioctl(CABC),
#   and doesn't touch the SDM backend ⇒ the SE/PA style Init abort restart loop can't recur.
$(call soong_config_set_bool,OPLUS_LINEAGE_LIVEDISPLAY_HAL,ENABLE_AB,true)

# Media
PRODUCT_COPY_FILES += \
    $(AUDIO_HAL_DIR)/configs/common/codec2/media_codecs_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_c2_audio.xml \
    $(AUDIO_HAL_DIR)/configs/common/codec2/service/1.0/c2audio.vendor.base-arm64.policy:vendor/etc/seccomp_policy/c2audio.vendor.base-arm64.policy \
    $(AUDIO_HAL_DIR)/configs/common/codec2/service/1.0/c2audio.vendor.ext-arm64.policy:vendor/etc/seccomp_policy/c2audio.vendor.ext-arm64.policy

# Oplus dummy services
PRODUCT_PACKAGES += \
    liboplus-uah-client \
    vendor.oplus.hardware.commondcs-service \
    vendor.oplus.hardware.osense.client-service

# Overlays
$(call inherit-product, hardware/oplus/overlay/generic/generic.mk)
$(call inherit-product, hardware/oplus/overlay/qssi/qssi.mk)

DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay-lineage

PRODUCT_ENFORCE_RRO_TARGETS := *
PRODUCT_PACKAGES += \
    CarrierConfigResCommon \
    FrameworksResTarget \
    NcmTetheringOverlay \
    OPlusFrameworksResCommon \
    OPlusSettingsResCommon \
    OPlusSystemUIResCommon \
    WifiResTarget

# Partitions
PRODUCT_PACKAGES += \
    vendor_bt_firmware_mountpoint \
    vendor_dsp_mountpoint \
    vendor_firmware_mnt_mountpoint

PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Power
PRODUCT_PACKAGES += \
    android.hardware.power-service-qti

$(call soong_config_set,qtipower,tap_to_wake_node,/proc/touchpanel/double_tap_enable)

# QTI fwk-detect
PRODUCT_PACKAGES += \
    libvndfwk_detect_jni.qti.vendor # Needed by CNE app

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors-service.oplus-multihal \
    sensors.dynamic_sensor_hal \
    sensors.oplus

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/hals.conf

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.ambient_temperature.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.ambient_temperature.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.hifi_sensors.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.hifi_sensors.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.relative_humidity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.relative_humidity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml

# Shipping API
# Linux 6.6 has no kernel entry at FCM level 7, and level 7 can't declare its own
# kernel level.
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

BOARD_SHIPPING_API_LEVEL := 31
PRODUCT_SHIPPING_API_LEVEL := $(BOARD_SHIPPING_API_LEVEL)

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    hardware/oplus

# Storage
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Telephony
PRODUCT_PACKAGES += \
    extphonelib \
    extphonelib-product \
    extphonelib.xml \
    extphonelib_product.xml \
    ims-ext-common \
    ims_ext_common.xml \
    qti-telephony-hidl-wrapper \
    qti-telephony-hidl-wrapper-prd \
    qti_telephony_hidl_wrapper.xml \
    qti_telephony_hidl_wrapper_prd.xml \
    qti-telephony-utils \
    qti-telephony-utils-prd \
    qti_telephony_utils.xml \
    qti_telephony_utils_prd.xml \
    telephony-ext

PRODUCT_BOOT_JARS += \
    telephony-ext

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml

$(call inherit-product, hardware/oplus/oplus-fwk/oplus-fwk.mk)

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal-service.qti

# Touch
PRODUCT_PACKAGES += \
    vendor.lineage.touch-service.oplus

# Update engine
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

# USB
PRODUCT_PACKAGES += \
    android.hardware.usb-service.qti \
    android.hardware.usb.gadget-service.qti \
    oplus_usb_compositions.conf

PRODUCT_SOONG_NAMESPACES += \
    vendor/qcom/opensource/usb/etc

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml

# Vendor service manager
PRODUCT_PACKAGES += \
    vndservicemanager

# Verified Boot
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml

# Vibrator
$(call soong_config_set_bool,OPLUS_LINEAGE_VIBRATOR_HAL,USE_EFFECT_STREAM,true)

PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator.service.oplus

PRODUCT_COPY_FILES += \
    vendor/qcom/opensource/vibrator/excluded-input-devices.xml:$(TARGET_COPY_OUT_VENDOR)/etc/excluded-input-devices.xml

# WiFi
PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    hostapd \
    libwifi-hal-ctrl \
    libwifi-hal-qcom \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.aware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.aware.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.rtt.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.rtt.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnel_migration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnel_migration.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml

# WiFi firmware symlinks
PRODUCT_PACKAGES += \
    firmware_wlanmdsp.otaupdate_symlink \
    firmware_wlan_mac.bin_symlink \
    firmware_WCNSS_qcom_cfg.ini_symlink

# Inherit from the proprietary files makefile.
$(call inherit-product, vendor/oneplus/sm8450-common/sm8450-common-vendor.mk)



# ===== 2026-10-06 touch HAL added: power HAL keeps requesting vendor.oplus.hardware.touch.IOplusTouch
#       not found → HintManagerService blocks forever → system_server service init hangs → stuck at boot =====
PRODUCT_PACKAGES += \
    vendor-oplus-hardware-touch-V2-service \
    touchDaemon \
    manifest_touch_aidl.xml
