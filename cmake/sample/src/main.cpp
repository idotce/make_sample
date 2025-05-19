#include <iostream>
#include <cstring>
#include <cstdint>

using namespace std;

//### Apple ###

const unsigned char ascii_table[34] = {
    '0','1','2','3','4','5','6','7','8','9',
    'A','B','C','D','E','F','G','H','J','K',
    'L','M','N','P','Q','R','S','T','U','V',
    'W','X','Y','Z'
};

void ascii_crc(uint8_t *buff, int len)
{
    unsigned int value = 0;
    int table_len = 34;

    for (int i=0; i<16; i++) {
        int cidx = 0;
        for (int idx=0; idx<table_len; idx++) {
            if (buff[i] == ascii_table[idx]) {
                cidx = idx;
                break;
            }
        }
        value = value + cidx + cidx * (i%2) * 2;
    }

    if (value%table_len == 0) {
        buff[16] = 0x30;
    }
    else {
        buff[16] = ascii_table[table_len - (value%table_len)];
    }
}

int addCheckDigit(char *serialNumber) {
    static char digits[] = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    int length = strlen(serialNumber);
    int radix = 34; // always base 34
    int total = 0; // Start total at 0
    int index; // loop counter

    // Loop over characters from right to left with the rightmost character being odd
    for (index = 1; index <= length; ++index) {
        char digit = serialNumber[length - index];
        char *foundDigit = strchr(digits, digit);
        if (!foundDigit) { // Invalid digit, check digit can't be calculated
            printf("Invalid digit %d %c!\n", index, digit);
            return 0;
        }
        int value = foundDigit - digits;
        if ((index & 1) == 1) { // odd digit, add 3 times value
            total += 3*value;
        } else { // even digit, just add value
            total += value;
        }
    }

    // Compute and append check digit
    int checkValue = total % radix;
    printf("checkValue:%d!\n", checkValue);
    char checkDigit = (checkValue > 0) ? digits[radix - checkValue] : '0';
    serialNumber[length] = checkDigit;
    serialNumber[length+1] = '\0';
    return 1;
}

int verifyCheckDigit(const char *serialNumber) {
    static char digits[] = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    int length = strlen(serialNumber);
    int radix = 34; // always base 34
    int total = 0; // Start total at 0
    int index; // loop counter

    // Loop over characters from right to left with the rightmost character being even
    for (index = 0; index < length; ++index) {
        char digit = serialNumber[length - index - 1];
        char *foundDigit = strchr(digits, digit);
        if (!foundDigit) {
            // Invalid digit, check digit can't be calculated
            printf("Invalid digit!\n");
            return 0;
        }
        int value = foundDigit - digits;
        if ((index & 1) == 1) {
            // odd digit, add 3 times value
            total += 3*value;
        } else { // even digit, just add value
            total += value;
        }
    }
    // verify that total is an even multiple of radix
    return (total % radix) == 0;
}

//### CRC ###

#define SWAP16(A) ((((uint16_t)(A)&0xff00)>>8)|(((uint16_t)(A)&0x00ff)<<8))
#define SWAP32(A) ((((uint32_t)(A)&0xff000000)>>24)|(((uint32_t)(A)&0x00ff0000)>>8)|(((uint32_t)(A)&0x0000ff00)<<8)|(((uint32_t)(A)&0x000000ff)<<24))

uint8_t test[] = { '1', '2', '3', '4', '5', '6', '7', '8' };

// CRC16_CCITT：      多项式x16+x12+x5+1（0x1021-0x8408），初始值0x0000，低位在前，高位在后，结果与0x0000异或
// CRC16_CCITT_FALSE：多项式x16+x12+x5+1（0x1021-0x8408），初始值0xFFFF，低位在后，高位在前，结果与0x0000异或
// CRC16_XMODEM：     多项式x16+x12+x5+1（0x1021-0x8408），初始值0x0000，低位在后，高位在前，结果与0x0000异或
// CRC16_X25：        多项式x16+x12+x5+1（0x1021-0x8408），初始值0x0000，低位在前，高位在后，结果与0xFFFF异或
// CRC16_MODBUS：     多项式x16+x15+x5+1（0x8005-0xa001），初始值0xFFFF，低位在前，高位在后，结果与0x0000异或
// CRC16_IBM：        多项式x16+x15+x5+1（0x8005-0xa001），初始值0x0000，低位在前，高位在后，结果与0x0000异或
// CRC16_MAXIM：      多项式x16+x15+x5+1（0x8005-0xa001），初始值0x0000，低位在前，高位在后，结果与0xFFFF异或
// CRC16_USB：        多项式x16+x15+x5+1（0x8005-0xa001），初始值0xFFFF，低位在前，高位在后，结果与0xFFFF异或

// https://crccalc.com/
// https://www.sohu.com/a/353749128_505888

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

uint16_t crc16(uint8_t *buffer, int offset, int len)
{
    uint16_t poly = 0x1021; // 0x8005
    uint16_t init = 0x0000; // 0xFFFF
    //uint16_t xoro = 0x0000; // 0x0000
    uint16_t crc = init;

    for (int n=offset; n<offset+len; n++) {
        crc ^= (buffer[n]<<8);
        for (int i=0; i<8; i++) {
            if (crc & 0x8000) {
                crc = (crc<<1)^poly;
            }
            else {
                crc = crc<<1;
            }
        }
    }

    //crc ^= xoro;
    return crc & 0xFFFF;
}

uint16_t crc8(uint8_t *buffer, int offset, int len)
{
    uint8_t poly = 0x31;
    uint8_t init = 0xFF;
    //uint16_t xoro = 0x00; // 0x00
    uint8_t crc = init;

    for (int n=offset; n<offset+len; n++) {
        crc ^= buffer[n];
        for (int i=0; i<8; i++) {
            if (crc & 0x80) {
                crc = (crc<<1)^poly;
            }
            else {
                crc = crc<<1;
            }
        }
    }

    //crc ^= xoro;
    return crc & 0xFF;
}

int main(int argc, char* argv[])
{
    //### Apple ###
    char test1[20] = "DWH3244TYNJFAKQC"; // U
    char test2[20] = "FGJ0293BMKWLX7PA"; // P

    addCheckDigit((char *)test1);
    //ascii_crc(test1, 17);
    printf("%s\n", test1);
    addCheckDigit((char *)test2);
    //ascii_crc(test2, 17);
    printf("%s\n", test2);

    //### CRC ###
    uint32_t reg = 0x01020304;
    uint8_t *pReg = (uint8_t *)&reg;
    uint32_t nreg = SWAP32(reg);
    uint8_t *pnReg = (uint8_t *)&nreg;
    int numOfReg = 4;
    int index = numOfReg;
#ifdef USE_TEST
    while (index--) {
        printf("%d    0x%02x\r\n", index, pReg[index]);
    }
    printf("use_test = yes");
#else
    for (int i=0; i<numOfReg; i++) {
        printf("%d    0x%02x\r\n", i, pnReg[i]);
    }
    printf("use_test = no");
#endif
    printf("0x%04x\r\n", check_crc(test, 0, sizeof(test)));
    uint8_t dat3[3] = {0x74, 0x00, 0x02}; // 0x248a
    uint16_t test3 = crc16(dat3, 0, 3);
    printf("0x%04x\n", test3);
    uint8_t dat4[3] = {0x74, 0x00, 0x02}; // 0x64, 0x2f
    uint16_t test4 = crc8(dat4, 0, 3);
    printf("0x%02x\n", test4);
    //
    system("PAUSE");
    return EXIT_SUCCESS;
}
