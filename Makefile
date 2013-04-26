include config.mk

PWD=$(shell pwd)
export PATH := $(PWD)/toolchain/$(ANDROID_PLATFORM)/bin:$(PATH)


.PHONY: all clean spotless

all: build/host/

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
		$(MAKE) PLATFORM=linux confclean boot-chicken; \
		touch *.scm

build/target/: src/chicken-core/ toolchain/$(ANDROID_PLATFORM)/ build/chicken-boot
	mkdir -p build/target
	cd src/chicken-core; \
		$(MAKE) PLATFORM=android confclean; \
		$(MAKE) PLATFORM=android \
			CHICKEN=./chicken-boot \
			HOSTSYSTEM=arm-linux-androideabi \
			TARGET_FEATURES="-no-feature x86 -feature arm" \
			DEBUGBUILD=$(DEBUGBUILD) \
			ARCH= \
			PREFIX=/data/data/$(PACKAGE_NAME) \
			DESTDIR=$(PWD)/build/target \
			EGGDIR=/data/data/$(PACKAGE_NAME)/lib \
		install
	mkdir -p build/target/data/data/$(PACKAGE_NAME)/lib/chicken/7
	mv build/target/data/data/$(PACKAGE_NAME)/lib/*.import.* build/target/data/data/$(PACKAGE_NAME)/lib/chicken/7/

build/host/: src/chicken-core/ build/target/
	mkdir -p build/host
	cd src/chicken-core; \
		$(MAKE) PLATFORM=linux confclean; \
		$(MAKE) PLATFORM=linux \
			CHICKEN=./chicken-boot \
			TARGETSYSTEM=arm-linux-androideabi \
			DEBUGBUILD=$(DEBUGBUILD) \
			PREFIX=$(PWD)/build/host \
			TARGET_PREFIX=$(PWD)/build/target/data/data/$(PACKAGE_NAME) \
			TARGET_RUN_PREFIX=/data/data/$(PACKAGE_NAME) \
			PROGRAM_PREFIX=android- \
		install

spotless: clean
	rm -rf src

clean: 
	rm -rf toolchain
	rm -rf build
