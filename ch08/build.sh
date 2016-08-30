export PLATFORM=/Applications/Xcode.app/Contents/Developer/Platforms/
export MACOSX=$PLATFORM/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/System/Library/Frameworks/

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
    -arch armv7 -c -o injection.o injection.c \
    -isysroot $PLATFORM/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
    -fPIC

#/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld \
/Applications/Xcode.app/Contents/Developer/usr/bin/ld \
    -dylib -lsystem -lobjc \
    -o injection.dylib injection.o \
    -syslibroot $PLATFORM/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/

