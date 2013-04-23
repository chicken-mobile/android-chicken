NDK_PATH=/opt/google/android/ndk
PLATFORM=android-14

PWD=$(shell pwd)
export PATH := $(PWD)/toolchain/$(PLATFORM)/bin:$(PATH)

all: build/host/

toolchain/$(PLATFORM)/:
	mkdir -p toolchain/$(PLATFORM) && \
	$(NDK_PATH)/build/tools/make-standalone-toolchain.sh \
	  --platform=$(PLATFORM) \
	  --install-dir=toolchain/$(PLATFORM)

src/chicken-core/:
	cd src; \
		git clone https://github.com/chicken-mobile/chicken-core.git -b android


build/target/: src/chicken-core/ toolchain/$(PLATFORM)/
	mkdir build/target; \
	cd src/chicken-core; \
		$(MAKE) PLATFORM=android confclean; \
		$(MAKE) \
			PLATFORM=android \
			HOSTSYSTEM=arm-linux-androideabi \
			TARGET_FEATURES="-no-feature x86 -feature arm" \
			ARCH= \
			PREFIX=/proc/self/cwd \
			DESTDIR=$(PWD)/build/target \
			EGGDIR=/proc/self/cwd/lib \
		install

build/host/: src/chicken-core/ build/target/
	mkdir build/host; \
	cd src/chicken-core; \
		$(MAKE) PLATFORM=linux confclean; \
		$(MAKE) \
			PLATFORM=linux \
			TARGETSYSTEM=arm-linux-androideabi \
			PREFIX=$(PWD)/build/host \
			TARGET_PREFIX=$(PWD)/build/target/proc/self/cwd \
			TARGET_RUN_PREFIX=/proc/self/cwd \
			PROGRAM_PREFIX=android- \
		install
clean: 
	rm -rf build/*
