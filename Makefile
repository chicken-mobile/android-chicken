NDK_PATH=/opt/google/android/ndk
PLATFORM=android-14

PWD=$(shell pwd)
export PATH := /usr/lib/ccache:$(PWD)/toolchain/$(PLATFORM)/bin:$(PATH)


all: cross-chicken

target/: toolchain/$(PLATFORM)/ build/target/chicken-4.8.0/
	cd build/target/chicken-4.8.0/; \
		CCACHE_CC=arm-linux-androideabi-gcc $(MAKE) \
			PLATFORM=android \
			HOSTSYSTEM=arm-linux-androideabi \
			TARGET_FEATURES="-no-feature x86 -feature arm" \
			ARCH= \
			PREFIX=/data/data/com.bevuta.androidChickenTest \
			C_INSTALL_EGG_HOME=/data/data/com.bevuta.androidChickenTest\lib \
			DESTDIR=$(PWD)/target \
		install

cross-chicken: target/ build/cross/chicken-4.8.0/
	cd build/cross/chicken-4.8.0/; \
		$(MAKE) \
			PLATFORM=linux \
			TARGETSYSTEM=arm-linux-androideabi \
			PREFIX=$(PWD)/host \
			TARGET_PREFIX=$(PWD)/target/data/data/com.bevuta.androidChickenTest \
			TARGET_RUN_PREFIX=/data/data/com.bevuta.androidChickenTest \
		install


toolchain/$(PLATFORM)/:
	$(NDK_PATH)/build/tools/make-standalone-toolchain.sh --platform=$(PLATFORM) --install-dir=./toolchain/$(PLATFORM)/

chicken-4.8.0.tar.gz: 
	wget -c http://code.call-cc.org/releases/current/chicken-4.8.0.tar.gz -O chicken-4.8.0.tar.gz
	touch chicken-4.8.0.tar.gz

build/target/chicken-4.8.0/: chicken-4.8.0.tar.gz
	mkdir -p build/target/
	cd build/target;  \
		tar xzvf $(PWD)/chicken-4.8.0.tar.gz; \
		cd chicken-4.8.0; \
			patch -p1 < $(PWD)/patches/add_linux_platform_target.patch; \
			touch .

build/cross/chicken-4.8.0/: chicken-4.8.0.tar.gz
	mkdir -p build/cross/
	cd build/cross/; \
		tar xzvf ../../chicken-4.8.0.tar.gz; \
		touch chicken-4.8.0

clean: 
	rm -rf toolchain
	rm -rf build
	rm -rf target
	rm -rf host
