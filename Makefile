ARCHS = arm64
TARGET = iphone:clang:latest:11.0
PACKAGE_VERSION = 1.3.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTClassicVideoQuality

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
