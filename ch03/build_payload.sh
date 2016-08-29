export PLATFORM=/Developer/Platforms/iPhoneOS.platform
export MACOSX=/Developer/SDKs/MacOSX10.7.sdk/System/Library/Frameworks/
$PLATFORM/Developer/usr/bin/arm-apple-darwin10-llvm-gcc-4.2 \
    -c -o watchdog.o watchdog.c \
    -isysroot $PLATFORM/Developer/SDKs/iPhoneOS5.0.sdk \
    -F$MACOSX

$PLATFORM/Developer/usr/bin/arm-apple-darwin10-llvm-gcc-4.2 \
    -c -o usbmux.o usbmux.c \
    -isysroot $PLATFORM/Developer/SDKs/iPhoneOS5.0.sdk \
    -F$MACOSX

$PLATFORM/Developer/usr/bin/arm-apple-darwin10-llvm-gcc-4.2 \
    -o payload payload.c watchdog.o usbmux.o \
    -isysroot $PLATFORM/Developer/SDKs/iPhoneOS5.0.sdk/ \
    -framework IOKit -framework CoreFoundation 

