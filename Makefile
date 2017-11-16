include theos/makefiles/common.mk

SUBPROJECTS += coverflowmhooks
SUBPROJECTS += coverflowmsettings

include $(THEOS_MAKE_PATH)/aggregate.mk

all::
	
