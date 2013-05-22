# Configuration for building a custom Cross-CHICKEN
#
# Copy this file to "config.mk" and make all necessary changes to reflect the configuration
# of your environment.


# Path to Android NDK tools
NDK_PATH         ?= /opt/google/android/ndk

# Platform-ID
ANDROID_PLATFORM ?= android-14

# Name of the final application-package
PACKAGE_NAME     ?= com.example.xyz

# Host-system architecture, on which the application is built
HOST_ARCH        ?= linux-x86_64

# Target-system architecture, on which the application will run
ARCH     	 ?= armeabi

# Enable this to build libraries with debug-information
#DEBUGBUILD       ?= 1
