

# try to autodetect package name
PACKAGE_NAME     := $(shell csi -s find-package.scm ../../AndroidManifest.xml)
ANDROID_PLATFORM := $(shell csi -s find-platform.scm ../../project.properties)

# let's try to find the android ndk path through `which ndk-build`
WHICH_NDK_BUILD  := $(shell which ndk-build)
ANDROID_NDK      := $(shell dirname $(WHICH_NDK_BUILD))


# hacky: we're using $(shell pwd)/executable because relative
# filenames apparently doesn't work in places like HOSTSYSTEM and
# DESTDIR when `make -C another-directory`. So pass absolute directory
# filenames:
ALOCAL_PATH    := $(shell pwd)

CHICKEN_CORE       := $(ALOCAL_PATH)/chicken-core/
ANDROID_TOOLCHAIN  := $(ALOCAL_PATH)/toolchain/
CHICKEN_TARGET_OUT := $(ALOCAL_PATH)/target/
CHICKEN_HOST_OUT   := $(ALOCAL_PATH)/host/

# the target prefix. this way, the chicken runtime should look for
# eggs under /data/data/$(PACKAGE_NAME)/lib/chicken/7.
SYS_PREFIX := /data/data/$(PACKAGE_NAME)

# files which are expected to be present after a successful chicken
# target and host build. we're including $(PACKAGE_NAME) here so that
# both target and host
CHICKEN_TARGET_OUT_BUILT := $(CHICKEN_TARGET_OUT)$(SYS_PREFIX)/lib/libchicken.so
CHICKEN_HOST_OUT_BUILT   := $(CHICKEN_HOST_OUT)$(PACKAGE_NAME)/bin/android-chicken

# path of arm-linux-androideabi-gcc etc. must be absolute so that
# aosp-chicken-install will work when it's no longer on PATH.
TARGET_COMPILER_PATH := $(ANDROID_TOOLCHAIN)/bin/

CHICKEN_PATH := $(CHICKEN_TARGET_OUT)$(SYS_PREFIX)/



# ******************** chicken ********************

all: android-toolchain chicken-sources chicken-boot chicken-target chicken-host

android-toolchain: $(ANDROID_TOOLCHAIN)/

$(ANDROID_TOOLCHAIN)/:
	mkdir -p $(ANDROID_TOOLCHAIN) && \
	$(ANDROID_NDK)/build/tools/make-standalone-toolchain.sh \
	  --platform=$(ANDROID_PLATFORM) \
	  --system=linux-x86 \
	  --install-dir=$(ANDROID_TOOLCHAIN)

chicken-sources: $(CHICKEN_CORE)/

$(CHICKEN_CORE)/:
	git clone https://github.com/chicken-mobile/chicken-core.git \
		-b android-soname-fix-maybe \
		$(CHICKEN_CORE)

# build chicken-boot unless binary already present
chicken-boot: $(CHICKEN_CORE)/chicken-boot

# build chicken-bootstrap (so we can compile scm -> c files)
$(CHICKEN_CORE)/chicken-boot:
	echo $(CHICKEN_CORE)
	make -C $(CHICKEN_CORE) \
		PLATFORM=linux ARCH= confclean boot-chicken

# build chicken target runtime if not already present
chicken-target: $(CHICKEN_TARGET_OUT_BUILT)

# build chicken target runtime (copy this to target android system on device)
$(CHICKEN_TARGET_OUT_BUILT):
	mkdir -p $(CHICKEN_TARGET_OUT)
	make -C $(CHICKEN_CORE) \
		PLATFORM=android \
		CHICKEN=$(CHICKEN_CORE)/chicken-boot \
		HOSTSYSTEM=$(TARGET_COMPILER_PATH)/arm-linux-androideabi  \
		TARGET_FEATURES="-no-feature x86 -no-feature x86-64 -feature arm -feature android" \
		DEBUGBUILD=$(DEBUGBUILD) \
		ARCH= \
		PREFIX=$(SYS_PREFIX) \
		DESTDIR=$(CHICKEN_TARGET_OUT) \
		EGGDIR=$(SYS_PREFIX)/lib/ \
		confclean clean all install

# build chicken-host (android-csc and friends) unless already present
chicken-host: $(CHICKEN_HOST_OUT_BUILT)

# build chicken host (the chicken which will be on your machine and
# used when invoking `android-chicken-install` for example). See
# http://wiki.call-cc.org/man/4/Cross%20development#building-the-cross-chicken
$(CHICKEN_HOST_OUT_BUILT):
	mkdir -p $(CHICKEN_HOST_OUT)
	$(MAKE) -C $(CHICKEN_CORE) \
		ARCH= \
		PLATFORM=linux \
		CHICKEN=$(CHICKEN_CORE)/chicken-boot \
		TARGET_C_COMPILER=$(TARGET_COMPILER_PATH)/arm-linux-androideabi-gcc \
		TARGETSYSTEM=arm-linux-androideabi \
		TARGET_FEATURES="-no-feature x86 -no-feature x86-64 -feature arm -feature android" \
		DEBUGBUILD=$(DEBUGBUILD) \
		PREFIX=$(CHICKEN_HOST_OUT)$(PACKAGE_NAME) \
		TARGET_PREFIX=$(CHICKEN_TARGET_OUT)$(SYS_PREFIX) \
		TARGET_RUN_PREFIX=$(SYS_PREFIX) \
		PROGRAM_PREFIX=android- \
		confclean clean all install
	echo chicken-host built. try 'export PATH=$(CHICKEN_HOST_OUT)$(PACKAGE_NAME):\$PPATH ; android-csc -cflags'


# ******************** libs util ********************
# helper to copy unit/eggs/*.so files to project libs folder
LIBS_OUT     := $(shell pwd)/../../libs/armeabi/

.PHONY: libs
libs:
	mkdir -p $(LIBS_OUT)
	csi -s move-libs.scm $(CHICKEN_TARGET_OUT)$(SYS_PREFIX) $(LIBS_OUT)
