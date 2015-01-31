ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = AnySpot
AnySpot_FILES = Tweak.xm
AnySpot_FRAMEWORKS = UIKit
AnySpot_CFLAGS = -Wno-error

include $(THEOS_MAKE_PATH)/tweak.mk

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
