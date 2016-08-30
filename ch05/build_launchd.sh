
export PLATFORM=/Applications/Xcode.app/Contents/Developer/Platforms/

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
   -arch armv7 -c ../ch03/syscalls.S -o syscalls.o

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
   -arch armv7 -fno-stack-protector -c launchd_keytheft.c -o launchd_keytheft \
   -isysroot $PLATFORM/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
   -I$PLATFORM/Developer/SDKs/iPhoneOS.sdk/usr/include \
   -I.

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
    -arch armv7 -o launchd_keytheft launchd_keytheft.o syscalls.o \
    -static -nostdlib -Wl,-e,_main

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
   -arch armv7 -fno-stack-protector -c launchd_spytheft.c -o launchd_spytheft \
   -isysroot $PLATFORM/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
   -I$PLATFORM/Developer/SDKs/iPhoneOS.sdk/usr/include \
   -I.

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
    -arch armv7 -o launchd_spytheft launchd_spytheft.o syscalls.o \
    -static -nostdlib -Wl,-e,_main

