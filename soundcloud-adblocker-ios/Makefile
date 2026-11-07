export TARGET = iphone:latest:14.0
export ARCHS = arm64 arm64e
export THEOS_DEVICE_IP = 127.0.0.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SoundCloudAdBlocker
SoundCloudAdBlocker_FILES = Tweak.xm
SoundCloudAdBlocker_CFLAGS = -fobjc-arc
SoundCloudAdBlocker_FRAMEWORKS = UIKit Foundation AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk