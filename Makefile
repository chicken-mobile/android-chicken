NDK_PATH ?= /opt/google/android/ndk
PLATFORM=android-14
CHICKEN_VERSION=4.8.2

PWD=$(shell pwd)
export PATH := /usr/lib/ccache:$(PWD)/toolchain/$(PLATFORM)/bin:$(PATH)


all: cross-chicken

target/: toolchain/$(PLATFORM)/ build/target/chicken-$(CHICKEN_VERSION)/
	cd build/target/chicken-$(CHICKEN_VERSION)/; \
		CCACHE_CC=arm-linux-androideabi-gcc $(MAKE) \
			PLATFORM=android \
			HOSTSYSTEM=arm-linux-androideabi \
			TARGET_FEATURES="-no-feature x86 -feature arm" \
			ARCH= \
			PREFIX=/data/data/com.bevuta.androidChickenTest \
			C_INSTALL_EGG_HOME=/data/data/com.bevuta.androidChickenTest/lib \
			DESTDIR=$(PWD)/target \
		install

cross-chicken: target/ build/cross/chicken-$(CHICKEN_VERSION)/
	cd build/cross/chicken-$(CHICKEN_VERSION)/; \
		$(MAKE) \
			PLATFORM=linux \
			TARGETSYSTEM=arm-linux-androideabi \
			PREFIX=$(PWD)/host \
			TARGET_PREFIX=$(PWD)/target/data/data/com.bevuta.androidChickenTest \
			TARGET_RUN_PREFIX=/data/data/com.bevuta.androidChickenTest \
		install


toolchain/$(PLATFORM)/:
	$(NDK_PATH)/build/tools/make-standalone-toolchain.sh --platform=$(PLATFORM) --install-dir=./toolchain/$(PLATFORM)/

chicken-$(CHICKEN_VERSION).tar.gz:
	wget -c http://code.call-cc.org/releases/current/chicken-$(CHICKEN_VERSION).tar.gz -O chicken-$(CHICKEN_VERSION).tar.gz
	touch chicken-$(CHICKEN_VERSION).tar.gz

build/target/chicken-$(CHICKEN_VERSION)/: chicken-$(CHICKEN_VERSION).tar.gz
	mkdir -p build/target/
	cd build/target;  \
		tar xzvf $(PWD)/chicken-$(CHICKEN_VERSION).tar.gz; \
		cd chicken-$(CHICKEN_VERSION); \
			touch .

build/cross/chicken-$(CHICKEN_VERSION)/: chicken-$(CHICKEN_VERSION).tar.gz
	mkdir -p build/cross/
	cd build/cross/; \
		tar xzvf ../../chicken-$(CHICKEN_VERSION).tar.gz; \
		touch chicken-$(CHICKEN_VERSION)

clean: 
	rm -rf toolchain
	rm -rf build
	rm -rf target
	rm -rf host
