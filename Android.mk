LOCAL_PATH := $(call my-dir)

# try to autodetect package name
PACKAGE_NAME       := $(shell csi -s $(LOCAL_PATH)/find-package.scm AndroidManifest.xml)
CHICKEN_TARGET_OUT := $(shell pwd)/$(LOCAL_PATH)/target/
SYS_PREFIX         := /data/data/$(PACKAGE_NAME)

# target chicken dir, containing ./lib and ./include
CHICKEN_PATH := $(CHICKEN_TARGET_OUT)$(SYS_PREFIX)/


# This is really silly, but here we go. We want to make a
# PREBUILT_SHARED_LIBRARY that points to a libchicken.so. We want
# libchicken.so depend on the make-target `chicken-core`. However, if
# libchicken.so is missing, ndk-build exits before we get to process
# its dependencies. Hence we drop the Android build system entirely
# and drop to standard Makefile like this:
CHICKEN_DUMMY := $(shell make -C $(LOCAL_PATH) 1>&2 ; echo $$?)
ifneq ($(CHICKEN_DUMMY),0)
$(error Could not build Chicken from Makefile)
endif

include $(CLEAR_VARS)
LOCAL_PATH              := $(CHICKEN_PATH)
LOCAL_MODULE            := chicken
LOCAL_SRC_FILES         := lib/libchicken.so
LOCAL_EXPORT_C_INCLUDES := $(CHICKEN_PATH)/include/chicken/
include $(PREBUILT_SHARED_LIBRARY)

