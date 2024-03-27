#include <iostream>

using namespace std;

int main(int argc, char* argv[])
{
    uint32_t i = 0x01020304;
    float f = 0.5;
    uint32_t *pi;
    uint8_t *pb;

    pi = (uint32_t *)&i;
    pb = (uint8_t *)&i;
    printf("int  0x%08x  [%02x %02x %02x %02x]\r\n", *pi, pb[0], pb[1], pb[2], pb[3]);

    pi = (uint32_t *)&f;
    pb = (uint8_t *)&f;
    printf("float  0x%08x  [%02x %02x %02x %02x]\r\n", *pi, pb[0], pb[1], pb[2], pb[3]);

    system("PAUSE");
    return EXIT_SUCCESS;
}
