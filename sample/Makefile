PWD=$(shell pwd)

CHICKEN_PATH             = $(PWD)/..
CHICKEN_HOST_PATH        = $(CHICKEN_PATH)/host
CHICKEN_TARGET_PATH      = $(CHICKEN_PATH)/target/data/data/$(PACKAGE)
CHICKEN_TARGET_EGGS_PATH = $(CHICKEN_TARGET_PATH)/lib/chicken/6

SDK_PATH     = /opt/google/android/sdk
NDK_PATH     = /opt/google/android/ndk

ARCH     = armeabi
PLATFORM = android-14
TARGET   = 11
NAME     = androidChickenTest
PACKAGE  = com.bevuta.androidChickenTest
ACTIVITY = ChickenTest

export PATH := $(SDK_PATH)/platform-tools:$(SDK_PATH)/tools:$(PATH)
export PATH := $(SDK_PATH)/tools:$(PATH)
export PATH := $(NDK_PATH):$(PATH)
export PATH := $(CHICKEN_PATH)/toolchain/$(PLATFORM)/bin:$(CHICKEN_HOST_PATH)/bin:$(PATH)
export PATH := /usr/lib/ccache:$(PATH)


all: run

run: install
	cd $(NAME); ant debug install
	adb shell am start -n $(PACKAGE)/.$(ACTIVITY)

run*: install
	adb shell killall $(PACKAGE)
	adb shell am start -n $(PACKAGE)/.$(ACTIVITY)

install: $(PWD)/$(NAME)/ $(PWD)/$(NAME)/libs/$(ARCH)/libchicken.so \
		$(foreach egg-path,$(shell ls $(CHICKEN_TARGET_EGGS_PATH)/*.so), \
			$(PWD)/$(NAME)/libs/$(ARCH)/lib$(shell basename $(egg-path))) \
		$(foreach scm-path,$(shell ls $(PWD)/scm/*.scm), \
			$(PWD)/$(NAME)/libs/$(ARCH)/lib$(shell basename $(scm-path) .scm).so)

$(PWD)/$(NAME)/libs/$(ARCH)/libchicken.so: $(CHICKEN_TARGET_PATH)/lib/libchicken.so
	cp $(CHICKEN_TARGET_PATH)/lib/libchicken.so $(PWD)/$(NAME)/libs/$(ARCH)/libchicken.so

$(PWD)/$(NAME)/libs/$(ARCH)/lib%.so: $(CHICKEN_TARGET_EGGS_PATH)/%.so
	cp $< $@
	adb push $@ /data/data/$(PACKAGE)/libs/$(shell basename $@)

$(PWD)/$(NAME)/libs/$(ARCH)/lib%.so: $(PWD)/scm/%.scm
	csc -s -llog -I scm/include -o $@ $<
	adb push $@ /data/data/$(PACKAGE)/libs/$(shell basename $@)

$(PWD)/$(NAME)/:
	mkdir -p $(PWD)/$(NAME)
	android create project -p $(PWD)/$(NAME) -t $(TARGET) -k $(PACKAGE) -a $(ACTIVITY)
	mkdir -p $(PWD)/$(NAME)/libs/$(ARCH)/

clean:
	rm -rf $(NAME)
