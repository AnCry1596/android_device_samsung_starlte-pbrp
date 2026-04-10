# Inherit from the common Open Source product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Inherit from common PBRP product configuration
$(call inherit-product, vendor/pb/config/common.mk)

# Inherit from the device-specific product configuration
$(call inherit-product, device/samsung/starlte/device.mk)

# Device identifier
PRODUCT_DEVICE := starlte
PRODUCT_NAME := pbrp_starlte
PRODUCT_MODEL := Galaxy S9
PRODUCT_BRAND := samsung
PRODUCT_MANUFACTURER := samsung
