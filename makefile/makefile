CC=gcc
CFLAGS=-c -Wall
LDFLAGS=
SRCS_APP=main.app.c
SRCS_BOOT=main.boot.c
INCLUDE_DIRS=-I .

ifeq ($(OS),Windows_NT)
	SRCS_APP+=hid-win.c
	SRCS_APP+=rs232.c
	SRCS_BOOT+=hid-win.c
	SRCS_BOOT+=rs232.c
	LIBS=-lsetupapi -lhid
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		SRCS_APP+=hid-mac.c
		SRCS_APP+=rs232.c
		SRCS_BOOT+=hid-mac.c
		SRCS_BOOT+=rs232.c
		LIBS=-framework IOKit -framework CoreFoundation
	else
		SRCS_APP+=hid-libusb.c
		SRCS_APP+=rs232.c
		SRCS_BOOT+=hid-libusb.c
		SRCS_BOOT+=rs232.c
		LIBS=`pkg-config libusb-1.0 --libs` -lrt -lpthread
		INCLUDE_DIRS+=`pkg-config libusb-1.0 --cflags`
		CFLAGS+=-std=gnu99
		LDFLAGS+=-no-pie
		endif
endif

OBJS_APP=$(SRCS_APP:.c=.o)
OBJS_BOOT=$(SRCS_BOOT:.c=.o)

EXEC_APP = hid.app.exe
EXEC_BOOT = hid.boot.exe

all: $(SRCS_APP) $(SRCS_BOOT) $(EXEC_APP) $(EXEC_BOOT)

$(EXEC_APP): $(OBJS_APP)
	$(CC) $(LDFLAGS) $(OBJS_APP) $(LIBS) -o $@

$(EXEC_BOOT): $(OBJS_BOOT)
	$(CC) $(LDFLAGS) $(OBJS_BOOT) $(LIBS) -o $@

.c.o:
	$(CC) $(CFLAGS) $(INCLUDE_DIRS) $< -o $@

clean:
	rm -f $(OBJS_APP) $(OBJS_BOOT) $(EXEC_APP) $(EXEC_APP).exe $(EXEC_BOOT) $(EXEC_BOOT).exe
