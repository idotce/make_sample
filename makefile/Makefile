TARGET = test

PWDDIR = $(shell pwd)

OBJ_DIR = obj
BIN_DIR = bin

MKDIR = mkdir
RMDIR = rm -r -f
#RMDIR = rmdir /q /s

CC = gcc
CXX = g++
LD = g++

DEFINES = \
	-D_GNU_SOURCE

INCLUDES =

LIBS =
#LIBS = -lgdi32 -lopengl32 -lglu32

CFLAGS = \
	-g -O2 -Wall -std=c99 \
	$(DEFINES) \
	$(INCLUDES)

CXXFLAGS = \
	-g -O2 -Wall -std=c++11 \
	$(DEFINES) \
	$(INCLUDES)

LDFLAGS = \
	$(LIBS)

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
