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

## Embedding custom libs is hard

If your APK contains ./libs/armeabi/file.so, it will not end up under
/data/data/package/lib because the installer on the device won't copy
shared objects that don't start with "lib". So we can't simply copy
your eggs or tcp.import.so, for example, over to ./libs/armeabi/.

However, if you rename tcp.import.so to libtcp.import.so, ndk-build deletes
it with a `rm -f ./libs/lib*.so` in the beginning of the ndk-build
process.

We could have used assets if they had been extracted to the device
file system, however, they are only available through Java API and are
uncompressed from the APK on the fly.

### move-libs.scm: A possible solution

- Since all so's need to beging with "lib", we can hack chicken so it
  looks for (conc "lib" filename) when loading extensions. eg. it
  looks for libtcp.import.so when you do (use tcp).

- Make a script that copies chicken's so-files and eggs to
  ./libs/armeabi/ with the "lib" prefixed.

- Run this script *after* ndk-build.

Sigh .... all of this just because Android won't install lib files
that don't start with lib.

### Another possible solution

Use ./assets/, then extract all un-prefixes so's on startup from Java
at runtime. Meh.
