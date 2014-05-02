# Chicken Scheme for Android

These files will setup a cross compiler toolchain for the use of
Chicken Scheme on Android. With the help of the Chicken cross compiler
we can build native binaries with csc for Android.

## Prerequisites

* Android [SDK](http://developer.android.com/sdk/) and [NDK](http://developer.android.com/tools/sdk/ndk/)
* A [Chicken](http://code.call-cc.org) installation. Version 4.8.0 or higher is recommended.
* The `ssax`, `sxpath` and `sxml` eggs
* `ndk-build` on your path

## Build

Place this directory in your jni folder of your Android project. Eg.
<project>/jni/chicken/.

Entering `make` will create a bootstrapping compiler and host- and
target parts of a CHICKEN cross-compilation installation in
`host/$(PACKAGE_NAME)` and `target/`, respectively.

If you include this `Android.mk` from your project's `Android.mk`
file, you get a `chicken` prebuilt LOCAL_MODULE which other Android
libraries can depend on, like this:

```make
# jni/Android.mk
include $(CLEAR_VARS)
LOCAL_MODULE    := hello-jni
LOCAL_SRC_FILES := hello-jni.c
LOCAL_SHARED_LIBRARIES := chicken
include $(BUILD_SHARED_LIBRARY)

# include the chicken prebuilt library
include jni/chicken/Android.mk
```
## Installing Eggs

With a successful build of cross-chicken, you can install eggs by
running `/host/$(PACKAGE_NAME)/bin/android-chicken-install`.

You can add the `host/$(PACKAGE_NAME)/bin` directory of this repo to
`PATH`, and you can use `android-chicken-install` as chicken-install.
It will install two versions of each egg: one for the host (which runs
egg macros, if I have understood things correctly) and one for the
target (normal runtime).

For more information, please consult the Makefile.

Now do:
```bash
# builds your android shared lib and the prebuilt libchicken.so
ndk-build # and cleans ./libs, need to copy eggs again
# copies eggs and units with the required "lib" prefix so that the installer picks them up:
make -C jni/chicken libs
# I've run into problems if I don't clean first
ant clean debug
adb install -r bin/Project-debug.apk
```

## Warning

If you change the package-name in your `AndroidManifest.xml`, you may have to delete `jni/chicken/target` and `jni/chicken/host` so that the cross-chicken picks this up.

## Troubleshooting

### java.lang.UnsatisfiedLinkError

If you see this, it's unfortunately quite common..

```
Caused by: java.lang.UnsatisfiedLinkError: could not load needed library 
'./obj/local/armeabi/libchicken.so' for 'libmain.so' 
(Library './obj/local/armeabi/libchicken.so' not found)
```

- Check that your shared object actually is in the apk
- Check that it contains the lib prefix
- Make sure that you load libchicken.so from Java before any other
 libraries:

```java
static {
    System.loadLibrary("chicken");
    System.loadLibrary("SDL2");
    System.loadLibrary("hello-jni");
}
```

### "Application terminated normally"

Are you compiling a .scm into .c and embedding Chicken? Try
`(return-to-host)` at the end of the scm file.


## TODOs

### Plugin loading extensions with "lib" prefix

Sadly, Android requires all libraries to be prefixed with `lib`, 
and this build-system adds that prefix to so-files. Place this
before any (use) calls:

```scheme
(define %##sys#find-extension ##sys#find-extension)
(define (##sys#find-extension p inc?)
  ;;(info (string-append "##sys#find-extension: looking for " p ".so or " (string-append "lib" p ".so")))
  (or (%##sys#find-extension p inc?)
      (%##sys#find-extension (string-append "lib" p) inc?)))
```

### Copy libs with ndk-build

We can't simply invoke the `libs` make target along with
chicken-target etc, because it gets run before the cleaning of
./libs/. Currently, we need to do `ndk-build && make -C jni/chicken
libs`.

Maybe there is a way to do get this running after the libs cleanup.

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
