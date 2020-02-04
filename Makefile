include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CyBuy
CyBuy_FILES = Tweak.xm DeviceViewController.m
CyBuy_FRAMEWORKS = Foundation
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Cydia"
