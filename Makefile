include config.mk

PWD=$(shell pwd)
export PATH := $(PWD)/toolchain/$(ANDROID_PLATFORM)/bin:$(PATH)

TARGET_BASEPATH ?= /data/data/$(PACKAGE_NAME)

.PHONY: all clean spotless host target update

all: update build/host/

toolchain/$(ANDROID_PLATFORM)/:
	mkdir -p toolchain/$(ANDROID_PLATFORM) && \
	$(NDK_PATH)/build/tools/make-standalone-toolchain.sh \
	  --platform=$(ANDROID_PLATFORM) \
	  --system=$(HOST_ARCH) \
	  --install-dir=toolchain/$(ANDROID_PLATFORM)

src/chicken-core/:
	git clone https://github.com/chicken-mobile/chicken-core.git -b android src/chicken-core

src/chicken-core/chicken-boot: src/chicken-core/
	cd src/chicken-core; \
		rm -f chicken; \
		$(MAKE) PLATFORM=linux confclean boot-chicken; \
		touch *.scm

build/target/: src/chicken-core/ toolchain/$(ANDROID_PLATFORM)/ src/chicken-core/chicken-boot
	$(MAKE) target

update: src/chicken-core/
	cd src/chicken-core; git pull

target:
	mkdir -p build/target
	cd src/chicken-core; \
		PATH=$$PWD/toolchain/$(ANDROID_PLATFORM)/bin:$$PATH $(MAKE) PLATFORM=android \
			CHICKEN=./chicken-boot \
			HOSTSYSTEM=arm-linux-androideabi \
			TARGET_FEATURES="-no-feature x86 -no-feature x86-64 -feature arm -feature android" \
			DEBUGBUILD=$(DEBUGBUILD) \
			ARCH= \
			PREFIX=$(TARGET_BASEPATH) \
			DESTDIR=$(PWD)/build/target \
			EGGDIR=$(TARGET_BASEPATH)/lib \
		confclean clean all install
	mkdir -p build/target/$(TARGET_BASEPATH)/lib/chicken/7
	mv build/target/$(TARGET_BASEPATH)/lib/*.import.* build/target/$(TARGET_BASEPATH)/lib/chicken/7/

build/host/: src/chicken-core/ build/target/
	$(MAKE) host

host:
	mkdir -p build/host
	cd src/chicken-core; \
		$(MAKE) PLATFORM=linux \
			CHICKEN=./chicken-boot \
			TARGETSYSTEM=arm-linux-androideabi \
			TARGET_FEATURES="-no-feature x86 -no-feature x86-64 -feature arm -feature android" \
			TARGET_C_COMPILER=$$PWD/../../toolchain/$(ANDROID_PLATFORM)/bin/arm-linux-androideabi-gcc \
			DEBUGBUILD=$(DEBUGBUILD) \
			PREFIX=$(PWD)/build/host \
			TARGET_PREFIX=$(PWD)/build/target/$(TARGET_BASEPATH) \
			TARGET_RUN_PREFIX=$(TARGET_BASEPATH) \
			PROGRAM_PREFIX=android- \
		confclean clean all install

spotless: clean
	rm -rf src

clean: 
	rm -rf toolchain
	rm -rf build
