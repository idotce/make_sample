PWDDIR = $(shell pwd)
ROOTDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TARGET = base
OUTDIR = out

ARCH ?=
CROSS ?=
CC = $(CROSS)gcc
CXX = $(CROSS)g++
LD = $(CROSS)g++

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
	#
	MKDIR = mkdir -p
	RMDIR = rmdir /s /q
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
	#
	MKDIR = mkdir -p
	RMDIR = rm -rf
endif

.PHONY: all
all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	$(LD) -o $(OUTDIR)/$@ $^ $(LDFLAGS)

$(OUTDIR)/%.o: %.c $(OUTDIR)
	@${MKDIR} -p ${dir ${@}}
	$(CC) -o $@ -c $< $(CFLAGS)

$(OUTDIR)/%.o: %.cpp $(OUTDIR)
	@${MKDIR} -p ${dir ${@}}
	$(CXX) -o $@ -c $< $(CXXFLAGS)

$(OUTDIR):
	@${MKDIR} $@

.PHONY: clean
clean:
	@${RMDIR} ${OUTDIR}

.PHONY: test
test:
	@echo PWDDIR = [$(PWDDIR)]
	@echo ROOTDIR = [$(ROOTDIR)]
	@echo OS = [$(OS)]
	@echo UNAME_S = [$(UNAME_S)]
	@echo windir = [$(windir)]
	@echo WINDIR= [$(WINDIR)]
