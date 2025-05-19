#include <iostream>
#include <cstdint>
#include "crc.h"

using namespace std;

extern "C" {

void invert_byte(unsigned char *dstBuf, unsigned char *srcBuf)
{
    unsigned char tmp = 0;
    for (int i=0; i<8; i++) {
        if (srcBuf[0]&(1<<i)) {
            tmp |= 1<<(7-i);
        }
    }
    dstBuf[0] = tmp;
}

void invert_word(unsigned short *dstBuf, unsigned short *srcBuf)
{
    unsigned short tmp = 0;
    for (int i=0; i<16; i++) {
        if (srcBuf[0]&(1<<i)) {
            tmp |= 1<<(15-i);
        }
    }
    dstBuf[0] = tmp;
}

uint16_t check_crc(uint8_t *buffer, int start, int len)
{
    uint16_t wCPoly = 0x1021; // 0x8005
    uint16_t wCRCin = 0x0000; // 0xFFFF
    bool RefIn = false;        // true
    bool RefOut = false;       // true
    uint16_t XorOut = 0x0000; // 0x0000

    uint8_t wChar = 0;
    for (int n=start; n<start+len; n++) {
        wChar = buffer[n];

        if (RefIn) invert_byte(&wChar, &wChar);
        wCRCin ^= (wChar<<8);
        for (int i=0; i<8; i++) {
            if (wCRCin & 0x8000) {
                wCRCin = (wCRCin<<1)^wCPoly;
            }
            else {
                wCRCin = wCRCin<<1;
            }
        }
    }

    if (RefOut) invert_word(&wCRCin, &wCRCin);

    wCRCin ^= XorOut;
    return wCRCin;
}

}  // extern "C"
