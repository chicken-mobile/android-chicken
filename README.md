# Chicken Scheme for Android

These files will setup a cross compiler toolchain for the use of Chicken Scheme on Android. With the help of the Chicken cross compiler we can build native binaries with csc for Android.

## Prerequisites

* Android [SDK](http://developer.android.com/sdk/) and [NDK](http://developer.android.com/tools/sdk/ndk/)
* A [Chicken](http://code.call-cc.org) installation. Version 4.8.0 or higher is recommended.

## Configuration

* Copy `default-config.mk` into `config.mk` and make the necessary changes to reflect your working environment.

## Build

Entering `make` will create a bootstrapping compiler and host- and target parts of a CHICKEN cross-compilation installation in `build/host` and `build/target`, respectively. You can then install eggs by running `build/host/bin/android-chicken-install`.

For more information, please consult the Makefile.

Use `adb` to copy binaries to Android.

## Example

https://github.com/chicken-mobile/example

## Installing Eggs

Add the `host/bin` and `toolchain/android-14/bin` directories of this repo to `PATH`. Now you can use `chicken-install` as usual (be careful with directories precedence in PATH in case it already points to an existent Chicken installation).

## Warning

This build includes some hardcoded paths which must be changed if you change an Android package name. I will try to clean up this and provide a way to have multiple toolchains for the different platforms regardless of the package name used.

If you have any issues, please report them. I will try to fix them as soon as possible.

If you want to contribute I'm happy to receive your improvements :)

You will find us on irc at irc.f0o.de in #mobile-chicken