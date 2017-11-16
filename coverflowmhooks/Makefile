include theos/makefiles/common.mk

TWEAK_NAME = CoverflowM
CoverflowM_FILES = /mnt/d/codes/coverflowm/coverflowmhooks/iCarousel/iCarousel.m /mnt/d/codes/coverflowm/coverflowmhooks/Tweak.xm
CoverflowM_FRAMEWORKS = CydiaSubstrate Foundation UIKit QuartzCore CoreGraphics MediaPlayer
CoverflowM_PRIVATE_FRAMEWORKS = MediaPlayerUI
CoverflowM_CFLAGS = -fobjc-arc
CoverflowM_LDFLAGS = -Wl,-segalign,4000

CoverflowM_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
