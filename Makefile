ARCHS = arm64
TARGET = iphone:clang:latest:11.0
PACKAGE_VERSION = 1.0.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTClassicVideoQuality

YTClassicVideoQuality_FILES = Tweak.x
YTClassicVideoQuality_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
