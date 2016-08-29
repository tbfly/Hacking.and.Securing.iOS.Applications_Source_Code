export PLATFORM=/Developer/Platforms/iPhoneOS.platform

$PLATFORM/Developer/usr/bin/arm-apple-darwin10-llvm-gcc-4.2 \
    -c syscalls.S -o syscalls.o

$PLATFORM/Developer/usr/bin/arm-apple-darwin10-llvm-gcc-4.2 \
   -c launchd.c -o launchd.o \
   -isysroot $PLATFORM/Developer/SDKs/iPhoneOS5.0.sdk \
   -I$PLATFORM/Developer/SDKs/iPhoneOS5.0.sdk/usr/include \
   -I.

$PLATFORM/Developer/usr/bin/arm-apple-darwin10-llvm-gcc-4.2 \
    -o launchd launchd.o syscalls.o \
    -static -nostartfiles -nodefaultlibs -nostdlib -Wl,-e,_main

