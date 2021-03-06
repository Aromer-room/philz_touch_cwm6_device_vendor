# Copyright (C) 2013 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This file sets variables that control the way modules are built
# thorughout the system. It should not be used to conditionally
# disable makefiles (the proper mechanism to control what gets
# included in a build is to use PRODUCT_PACKAGES in a product
# definition file).
#

# WARNING: This line must come *before* including the proprietary
# variant, so that it gets overwritten by the parent (which goes
# against the traditional rules of inheritance).

# inherit from common msm8960
-include device/htc/msm8960-common/BoardConfigCommon.mk

TARGET_SPECIFIC_HEADER_PATH := device/htc/m7-common/include

# Kernel
BOARD_KERNEL_BASE := 0x80600000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE := console=ttyHSL0,115200,n8 androidboot.hardware=qcom user_debug=31
# PhilZ needs special args for stock kernels
# BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01800000
# PhilZ: start use stock kernels
ifeq ($(TARGET_DEVICE),m7spr)
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01408000
TARGET_PREBUILT_KERNEL := device/htc/m7-common/recovery/sprint/kernel_stock_sprint-FW_3.05.651.6
TARGET_EXFAT_MODULE := device/htc/m7-common/recovery/sprint/texfat.ko
else ifeq ($(TARGET_DEVICE),m7vzw)
TARGET_PREBUILT_KERNEL := device/htc/m7-common/recovery/verizon/kernel_stock_vzw
BOARD_KERNEL_CMDLINE := console=ttyHSL0,115200,n8 androidboot.hardware=qcom user_debug=31 androidboot.selinux=permissive
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01808000
TARGET_EXFAT_MODULE := device/htc/m7-common/recovery/verizon/texfat.ko
else
# m7 GSM unified (m7ul, m7att, m7tmo)
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01808000
TARGET_PREBUILT_KERNEL := device/htc/m7-common/recovery/kernel-stock_FW_4.19.401.8
TARGET_EXFAT_MODULE := device/htc/m7-common/recovery/ko_modules/texfat.ko
endif

TARGET_KERNEL_CONFIG := m7_defconfig
# TARGET_KERNEL_SOURCE := kernel/htc/msm8960

# exfat kernel module
PRODUCT_COPY_FILES += \
    $(TARGET_EXFAT_MODULE):recovery/root/lib/modules/texfat.ko

# Audio
BOARD_USES_FLUENCE_INCALL := true  # use DMIC in call only
BOARD_USES_SEPERATED_AUDIO_INPUT := true  # use distinct voice recognition use case
BOARD_USES_SEPERATED_VOICE_SPEAKER := true  # use distinct voice speaker use case
BOARD_USES_SEPERATED_VOIP := true  # use distinct VOIP use cases
BOARD_AUDIO_AMPLIFIER := device/htc/m7-common/libaudioamp
BOARD_HAVE_HTC_CSDCLIENT := true

# Bluetooth
BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/htc/m7-common/bluetooth
BOARD_BLUEDROID_VENDOR_CONF := device/htc/m7-common/bluetooth/libbt_vndcfg.txt
BOARD_BLUETOOTH_USES_HCIATTACH_PROPERTY := false

# Camera
COMMON_GLOBAL_CFLAGS += -DHTC_CAMERA_HARDWARE
COMMON_GLOBAL_CFLAGS += -DNEEDS_VECTORIMPL_SYMBOLS
USE_DEVICE_SPECIFIC_CAMERA := true

# Graphics
OVERRIDE_RS_DRIVER := libRSDriver_adreno.so
HAVE_ADRENO_SOURCE := false

# RIL
BOARD_PROVIDES_LIBRIL := true

# USB
TARGET_USE_CUSTOM_LUN_FILE_PATH := /sys/devices/platform/msm_hsusb/gadget/lun%d/file

# We have the new GPS driver
BOARD_HAVE_NEW_QC_GPS := true

# Tuning
BOARD_HARDWARE_CLASS := device/htc/m7-common/cmhw

# Wifi
WPA_SUPPLICANT_VERSION           := VER_0_8_X
BOARD_WLAN_DEVICE                := bcmdhd
BOARD_WPA_SUPPLICANT_DRIVER      := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_HOSTAPD_DRIVER             := NL80211
BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WIFI_DRIVER_FW_PATH_PARAM        := "/sys/module/bcmdhd/parameters/firmware_path"
WIFI_DRIVER_FW_PATH_STA          := "/system/etc/firmware/fw_bcm4335_b0.bin"
WIFI_DRIVER_FW_PATH_AP           := "/system/etc/firmware/fw_bcm4335_apsta_b0.bin"
WIFI_DRIVER_FW_PATH_P2P          := "/system/etc/firmware/fw_bcm4335_p2p_b0.bin"

# Filesystem
BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 16776704
BOARD_FLASH_BLOCK_SIZE := 131072

# Custom Recovery
# PhilZ needs init.rc to insmod HTC texfat.ko module + fix charger
TARGET_RECOVERY_INITRC := device/htc/m7-common/rootdir/etc/init.philz-m7-common.rc
ifeq ($(TARGET_DEVICE),m7spr)
TARGET_RECOVERY_FSTAB := device/htc/m7-common/rootdir/etc/fstab.qcom.spr
else
TARGET_RECOVERY_FSTAB := device/htc/m7-common/rootdir/etc/fstab.qcom.gsm
endif
BOARD_USE_CUSTOM_RECOVERY_FONT := \"roboto_23x41.h\"
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_RECOVERY_SWIPE := true
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_EXT4 := true

# Charge mode
# PhilZ uses stock kernel that has no lpm.rc - we use init.rc instead
# BOARD_CHARGING_MODE_BOOTING_LPM := /sys/htc_lpm/lpm_mode

# inherit from the proprietary version
-include vendor/htc/m7-common/BoardConfigVendor.mk
