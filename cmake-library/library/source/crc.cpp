#include <iostream>
#include "crc.h"

using namespace std;

// CRC16_CCITT��      ����ʽx16+x12+x5+1��0x1021-0x8408������ʼֵ0x0000����λ��ǰ����λ�ں󣬽����0x0000���
// CRC16_CCITT_FALSE������ʽx16+x12+x5+1��0x1021-0x8408������ʼֵ0xFFFF����λ�ں󣬸�λ��ǰ�������0x0000���
// CRC16_XMODEM��     ����ʽx16+x12+x5+1��0x1021-0x8408������ʼֵ0x0000����λ�ں󣬸�λ��ǰ�������0x0000���
// CRC16_X25��        ����ʽx16+x12+x5+1��0x1021-0x8408������ʼֵ0x0000����λ��ǰ����λ�ں󣬽����0xFFFF���
// CRC16_MODBUS��     ����ʽx16+x15+x5+1��0x8005-0xa001������ʼֵ0xFFFF����λ��ǰ����λ�ں󣬽����0x0000���
// CRC16_IBM��        ����ʽx16+x15+x5+1��0x8005-0xa001������ʼֵ0x0000����λ��ǰ����λ�ں󣬽����0x0000���
// CRC16_MAXIM��      ����ʽx16+x15+x5+1��0x8005-0xa001������ʼֵ0x0000����λ��ǰ����λ�ں󣬽����0xFFFF���
// CRC16_USB��        ����ʽx16+x15+x5+1��0x8005-0xa001������ʼֵ0xFFFF����λ��ǰ����λ�ں󣬽����0xFFFF���

// https://crccalc.com/
// https://www.sohu.com/a/353749128_505888

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
