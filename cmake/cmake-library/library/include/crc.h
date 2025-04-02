#include <iostream>

using namespace std;

#if defined(_WIN32)

#ifdef DLL_LIBRARY
    #define CAPI_EXPORT __declspec(dllexport)
#else
    #define CAPI_EXPORT
  //#define CAPI_EXPORT __declspec(dllimport)
#endif

#endif

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

#define SWAP16(A) ((((uint16_t)(A)&0xff00)>>8)|(((uint16_t)(A)&0x00ff)<<8))
#define SWAP32(A) ((((uint32_t)(A)&0xff000000)>>24)|(((uint32_t)(A)&0x00ff0000)>>8)|(((uint32_t)(A)&0x0000ff00)<<8)|(((uint32_t)(A)&0x000000ff)<<24))

CAPI_EXPORT void invert_byte(unsigned char *dstBuf, unsigned char *srcBuf);

CAPI_EXPORT void invert_word(unsigned short *dstBuf, unsigned short *srcBuf);

CAPI_EXPORT uint16_t check_crc(uint8_t *buffer, int start, int len);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus
