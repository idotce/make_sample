#include <stdio.h>

int main(int argc, char* argv[])
{
#if defined(__GNUC__)
    printf("__GNUC__\r\n");
#endif
#if defined(__clang__)
    printf("__clang__\r\n");
#endif
#ifdef __CUDACC__
    printf("__CUDACC__\n");
#endif
#if (defined __ARM_NEON) || (defined __ARM_NEON__)
    printf("__ARM_NEON\n");
#endif

#if defined(__aarch64__)
  #define ARCH_ARM64 1
#else
  #define ARCH_ARM64 0
#endif
    printf("__aarch64__ = %d\n", ARCH_ARM64);

    #define align ((32+3)/4*4)
    printf("align = %d\n", align);

    return 0;
}
