export PLATFORM=/Applications/Xcode.app/Contents/Developer/Platforms/
export MACOSX=$PLATFORM/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/System/Library/Frameworks/

/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
    -arch armv7 -c -o TestConnection TestConnection.m \
    -isysroot $PLATFORM/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
    -framework Foundation -lobjc
