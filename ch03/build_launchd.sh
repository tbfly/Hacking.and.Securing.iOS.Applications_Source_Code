
export PLATFORM=/Applications/Xcode.app/Contents/Developer/Platforms/

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
   -arch armv7 -c syscalls.S -o syscalls.o

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
   -arch armv7 -fno-stack-protector -c launchd.c -o launchd.o \
   -isysroot $PLATFORM/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
   -I$PLATFORM/Developer/SDKs/iPhoneOS.sdk/usr/include \
   -I.

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
    -arch armv7 -o launchd launchd.o syscalls.o \
    -static -nostdlib -Wl,-e,_main

