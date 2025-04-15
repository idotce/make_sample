#PWDDIR = $(shell pwd)
#ROOTDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TARGET = test
OUTDIR = out

ifeq ($(OS), Windows_NT)
	MKDIR = mkdir
	RMDIR = rd /q /s
else
	MKDIR = mkdir
	RMDIR = rm -rf
endif

ARCH ?=
CROSS_COMPILE ?=
CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)g++

DEFINES = \
	-D_GNU_SOURCE

INCLUDES = \
	-I.

LIBS =
#LIBS = -lgdi32 -lopengl32 -lglu32

CFLAGS = $(DEFINES) $(INCLUDES) \
	-O3 -Wall -std=c99

CXXFLAGS = $(DEFINES) $(INCLUDES) \
	-O3 -Wall -std=c++11

LDFLAGS = $(LIBS)

ifneq ($(ARCH),)
	include makefile.$(ARCH)
endif

C_FILES = src/main.c # $(wildcard *.c src/*.c)
CXX_FILES = # $(wildcard *.cpp src/*.cpp)
OBJ_FILES = $(addprefix $(OUTDIR)/, $(C_FILES:.c=.o) $(CXX_FILES:.cpp=.o))

ifeq ($(OS), Windows_NT)
	# C_FILES += src/hid-win.c
	# LIBS = -lsetupapi -lhid
	LDFLAGS += -static
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S), Darwin)
		# C_FILES += src/hid-mac.c
		# LIBS = -framework IOKit -framework CoreFoundation
	else
		# C_FILES += src/hid-libusb.c # src/hid-linux.c
		# INCLUDES += `pkg-config libusb-1.0 --cflags`
		# LIBS = `pkg-config libusb-1.0 --libs` -lrt -lpthread -ludev
		CFLAGS += -std=gnu99
		LDFLAGS += -no-pie
	endif
endif

all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	$(LD) -o $(OUTDIR)/$@ $^ $(LDFLAGS)

$(OUTDIR)/%.o: %.c
	@${MKDIR} -p ${dir ${@}}
	$(CC) -o $@ -c $< $(CFLAGS)

$(OUTDIR)/%.o: %.cpp
	@${MKDIR} -p ${dir ${@}}
	$(CXX) -o $@ -c $< $(CXXFLAGS)

clean:
	@${RMDIR} ${OUTDIR}

install:
	@ERROR
