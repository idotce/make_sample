#include <iostream>
#include <cstdint>
#include "crc.h"

using namespace std;

uint8_t test[] = { '1', '2', '3', '4', '5', '6', '7', '8' };

int main(int argc, char* argv[])
{
    uint32_t reg = 0x01020304;
    uint8_t *pReg = (uint8_t *)&reg;
    uint32_t nreg = SWAP32(reg);
    uint8_t *pnReg = (uint8_t *)&nreg;
    int numOfReg = 4;
    int index = numOfReg;

    while (index--) {
        printf("%d    0x%02x\r\n", index, pReg[index]);
    }

    printf("\r\n");

    for (int i=0; i<numOfReg; i++) {
        printf("%d    0x%02x\r\n", i, pnReg[i]);
    }

    printf("0x%04x\r\n", check_crc(test, 0, sizeof(test)));

    system("PAUSE");
    return EXIT_SUCCESS;
}
