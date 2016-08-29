OBJS_DIR = ./obj
SRCS = hello.c \
       hello2.c \
       launchd.c

CFLAGS =  -g -O2 -Wall -Wmissing-prototypes -std=c99 -ffast-math -fno-strict-aliasing
CXXFLAGS =  -g -O2 -Wall -fno-strict-aliasing
LDFLAGS = -framework CoreFoundation -framework Security -framework SystemConfiguration

IPHONEOS_DEPLOYMENT_TARGET = 7.0
IPHONEOS_DEPLOYMENT_BASE = 9.2
ARCH = arm64

Developer=/Applications/Xcode.app/Contents/Developer
PLATFORM_PHONE_DEVELOPER_BIN_DIR = $(Developer)/Platforms/iPhoneOS.platform/Developer/usr/bin
SDKROOT_PHONE = $(Developer)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS$(IPHONEOS_DEPLOYMENT_BASE).sdk

EXTRA_CFLAGS += -arch $(ARCH) -stdlib=libstdc++ -pipe $(INCLUDE) -isysroot $(SDKROOT_PHONE)
EXTRA_CFLAGS += -miphoneos-version-min=$(IPHONEOS_DEPLOYMENT_TARGET)

AR = $(PLATFORM_PHONE_DEVELOPER_BIN_DIR)/ar
CC = /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
CXX = /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++

CFLAGS +=  $(EXTRA_CFLAGS)
LDFLAGS += $(EXTRA_LDFLAGS)
CXXFLAGS += $(EXTRA_CFLAGS)
LIBTOOL = $(Developer)/Toolchains/XcodeDefault.xctoolchain/usr/bin/libtool

.SUFFIXES: .o-arm64
MODULES_ARM = ${SRCS:%.c=$(OBJS_DIR)/%.o-arm64}
MODULES_ARM := ${MODULES_ARM:%.cpp=$(OBJS_DIR)/%.o-arm64}
MODULES_ARM := ${MODULES_ARM:%.cc=$(OBJS_DIR)/%.o-arm64}
MODULES_ARM := ${MODULES_ARM:%.mm=$(OBJS_DIR)/%.o-arm64}

TARGET = hello hello2 launchd 

default: all
all: $(TARGET) 

$(TARGET): $(MODULES_ARM)
	$(LIBTOOL) -arch_only $(ARCH) -o $@ $(MODULES_ARM) $(LDFLAGS)

$(OBJS_DIR)/%.o-arm64 : %.S
	@mkdir -p $(@D)
	$(CC) $(CXXFLAGS) -c $< -o $@

$(OBJS_DIR)/%.o-arm64 : %.c
	@mkdir -p $(@D)
	$(CC) $(CXXFLAGS) -c $< -o $@

$(OBJS_DIR)/%.o-arm64 : %.cc
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJS_DIR)/%.o-arm64 : %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJS_DIR)/%.o-arm64 : %.mm
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -rf core *.dSYM $(MODULES_ARM) $(TARGET)
