#include "mongoose.h"

const char *getdeviceattr() {
  static const char *json_fmt =
  "{"
    "\"result\": 0,"
    "\"info\": {"
      "\"uuid\": \"%s\","
      "\"softver\": \"%s\","
      "\"otaver\": \"%s\","
      "\"hwver\": \"%s\","
      "\"ssid\": \"%s\","
      "\"bssid\": \"%s\","
      "\"camnum\": %d,"
      "\"curcamid\": %d,"
      "\"wifireboot\": %d"
    "}"
  "}";

  // 在实际应用中，这些值可能是动态获取的
  const char *uuid = "12ad3f5b8c9d";
  const char *softver = "v1.2.3";
  const char *otaver = "v1.20230312.1";
  const char *hwver = "v1.2";
  const char *ssid = "rtwap";
  const char *bssid = "12ad3f5b8c9d";
  int camnum = 2;
  int curcamid = 0;
  int wifireboot = 0;

  // 计算需要的缓冲区大小
  size_t len = snprintf(NULL, 0, json_fmt, uuid, softver, otaver, hwver,
                       ssid, bssid, camnum, curcamid, wifireboot);
  char *buf = malloc(len + 1);
  snprintf(buf, len + 1, json_fmt, uuid, softver, otaver, hwver,
           ssid, bssid, camnum, curcamid, wifireboot);
  return buf;
}

const char *capability() {
  static const char *json_fmt =
    "{"
      "\"result\": 0,"
      "\"info\": {"
        "\"value\": \"000100\""
      "}"
    "}";
  return json_fmt;
}

const char *getproductinfo() {
  static const char *json_fmt =
  "{"
    "\"result\": 0,"
    "\"info\": {"
      "\"model\": \"x1\","
      "\"company\": \"alibaba\","
      "\"soc\": \"eeasytech\","
      "\"sp\": \"FH\""
    "}"
  "}";

  return json_fmt;
}

const char *getmediainfo() {
  static const char *json_fmt =
  "{"
    "\"result\": 0,"
    "\"info\": {"
      "\"rtsp\": \"rtsp://192.168.1.1/video0\","
      "\"transport\": \"tcp\","
      "\"port\": 6035"
    "}"
  "}";

  return json_fmt;
}
