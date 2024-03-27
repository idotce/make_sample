TARGET = base
LIB_TARGET = libbase.dylib

IOSMIN = 7.1
ARCH = -arch armv7 -arch arm64
PWDDIR = $(shell pwd)

OBJ_DIR = obj
BIN_DIR = bin

SDKROOT = $(shell xcrun --sdk iphoneos --show-sdk-path)

CC = clang $(ARCH) -miphoneos-version-min=$(IOSMIN) -isysroot $(SDKROOT)
CXX = clang++ $(ARCH) -miphoneos-version-min=$(IOSMIN) -isysroot $(SDKROOT)
LD = clang $(ARCH) -miphoneos-version-min=$(IOSMIN) -isysroot $(SDKROOT)

DEFINES = \
	-D_GNU_SOURCE

INCLUDES =

LIBS = \
	-L$(PWDDIR)/bin

CFLAGS = \
	-g -O2 -Wall -std=c99 \
	$(DEFINES) \
	$(INCLUDES)

CXXFLAGS = \
	-g -O2 -Wall -std=c++11 \
	$(DEFINES) \
	$(INCLUDES)

LDFLAGS = \
	-Wl,-segalign,4000 \
	$(LIBS)

C_FILES = $(wildcard *.c src/*.c)
CXX_FILES = $(wildcard *.cpp src/*.cpp)
OBJ_FILES = $(addprefix $(OBJ_DIR)/, $(C_FILES:.c=.o) $(CXX_FILES:.cpp=.o))

LIB_C_FILES = $(wildcard lib/*.c)
LIB_OBJ_FILES = $(addprefix $(OBJ_DIR)/, $(LIB_C_FILES:.c=.o))

all: $(LIB_TARGET) $(TARGET)

$(LIB_TARGET): $(LIB_OBJ_FILES)
	@mkdir -p $(BIN_DIR)
	$(LD) -o $(BIN_DIR)/$@ $^ $(LDFLAGS) -dynamiclib

$(LIB_OBJ_FILES)/%.o: %.c
	@mkdir -p $(shell dirname $@)
	$(CC) -o $@ -c $< $(CFLAGS)

$(TARGET): $(OBJ_FILES)
	@mkdir -p $(BIN_DIR)
	$(LD) -o $(BIN_DIR)/$@ $^ $(LDFLAGS) -lbase
	ldid -S $(BIN_DIR)/$@

$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(shell dirname $@)
	$(CC) -o $@ -c $< $(CFLAGS)

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(shell dirname $@)
	$(CXX) -o $@ -c $< $(CXXFLAGS)

clean:
	@rm -rf $(OBJ_DIR) $(BIN_DIR)

install:
	@scp -P $(THEOS_DEVICE_PORT) $(BIN_DIR)/$(TARGET) root@$(THEOS_DEVICE_IP):
