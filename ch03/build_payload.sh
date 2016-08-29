export PLATFORM=/Applications/Xcode.app/Contents/Developer/Platforms/
export MACOSX=$PLATFORM/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/System/Library/Frameworks/

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
    -arch armv7 -c -o watchdog.o watchdog.c \
    -isysroot $PLATFORM/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
    -F$MACOSX

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
    -arch armv7 -c -o usbmux.o usbmux.c \
    -isysroot $PLATFORM/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
    -F$MACOSX

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
    -arch armv7 -o payload_datatheft payload_datatheft.c watchdog.o usbmux.o \
    -isysroot $PLATFORM/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
    -framework IOKit -framework CoreFoundation 

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
    -arch armv7 -o payload_rawtheft payload_rawtheft.c watchdog.o usbmux.o \
    -isysroot $PLATFORM/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
    -framework IOKit -framework CoreFoundation 
