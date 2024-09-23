TARGET = test

# android (/data/local/tmp/)
# aarch64-linux-gnu-
# apt install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
# -g -O3 -mcpu=cortex-a53 -Wall

# cortex-a7
# arm-linux-gnueabi-
# arm-linux-gnueabihf-
# apt install gcc-arm-linux-gnueabi g++-arm-linux-gnueabi
# -g -O3 -mcpu=cortex-a7 -mfpu=neon -Wall
# -g -O3 -mcpu=cortex-a7 -mfpu=neon -mfloat-abi=hard -Wall

CROSS_COMPILE=aarch64-linux-gnu-

PWDDIR = $(shell pwd)

OBJ_DIR = obj
BIN_DIR = bin

MKDIR = mkdir
RMDIR = rm -r -f
#RMDIR = rmdir /q /s

CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)g++

DEFINES = \
	-D_GNU_SOURCE

INCLUDES = \
	-I.

LIBS =
#LIBS = -lgdi32 -lopengl32 -lglu32

CFLAGS = \
	-g -O3 -mcpu=cortex-a53 -Wall -std=c99 \
	$(DEFINES) \
	$(INCLUDES)

CXXFLAGS = \
	-g -O3 -mcpu=cortex-a53 -Wall -std=c++11 \
	$(DEFINES) \
	$(INCLUDES)

LDFLAGS = \
	$(LIBS) -static

C_FILES = $(wildcard *.c src/*.c)
CXX_FILES = $(wildcard *.cpp src/*.cpp)
OBJ_FILES = $(addprefix $(OBJ_DIR)/, $(C_FILES:.c=.o) $(CXX_FILES:.cpp=.o))

all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	@${MKDIR} -p ${BIN_DIR}
	$(LD) -o $(BIN_DIR)/$@ $^ $(LDFLAGS)

$(OBJ_DIR)/%.o: %.c
	@${MKDIR} -p ${subst /,\,${dir ${@}}}
	$(CC) -o $@ -c $< $(CFLAGS)

$(OBJ_DIR)/%.o: %.cpp
	@${MKDIR} -p ${subst /,\,${dir ${@}}}
	$(CXX) -o $@ -c $< $(CXXFLAGS)

clean:
	@${RMDIR} ${OBJ_DIR}
	@${RMDIR} ${BIN_DIR}

install:
	@ERROR
