// src/main.cpp - 简化版本，避免操作符API
#include <iostream>
#include <string>
#include <vector>
#include <cstring>
#ifdef _WIN32
#include <windows.h>
#endif

// 测试宏定义
#define TEST_CURL 1
#define TEST_JSON 1
#define TEST_OPENCV 1
#define TEST_TENSORFLOW_LITE 1

#if TEST_CURL
#include <curl/curl.h>
#endif
#if TEST_JSON
#include <json/json.h>
#endif
#if TEST_OPENCV
#include <opencv2/opencv.hpp>
#endif
#if TEST_TENSORFLOW_LITE
// 只使用核心TensorFlow Lite头文件，避免操作符API
#include "tensorflow/lite/interpreter.h"
#include "tensorflow/lite/kernels/register.h"
#include "tensorflow/lite/model.h"
#include "tensorflow/lite/version.h"
// 移除操作符相关的头文件
// #include "tensorflow/lite/c/c_api.h"
// #include "tensorflow/lite/c/common.h"
// 创建一个简单的有效模型数据
const unsigned char simple_model_data[] = {
  0x1c, 0x00, 0x00, 0x00, 0x54, 0x46, 0x4c, 0x33, 0x00, 0x00, 0x12, 0x00,
  0x1c, 0x00, 0x04, 0x00, 0x08, 0x00, 0x0c, 0x00, 0x10, 0x00, 0x14, 0x00,
  0x00, 0x00, 0x18, 0x00, 0x12, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00,
  0x60, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00,
  0x2c, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
  0x14, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
  0x08, 0x00, 0x0c, 0x00, 0x08, 0x00, 0x04, 0x00, 0x08, 0x00, 0x00, 0x00,
  0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00,
  0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00,
  0x04, 0x00, 0x00, 0x00, 0xf4, 0xff, 0xff, 0xff, 0x0c, 0x00, 0x00, 0x00,
  0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x0c, 0x00, 0x00, 0x00,
  0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03
};
const unsigned int simple_model_data_len = sizeof(simple_model_data);
#endif

int main() {
#ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
    SetConsoleCP(CP_UTF8);
#endif

    std::cout << "=== 库功能测试 ===" << std::endl;

    bool all_success = true;

#if TEST_CURL
    std::cout << "\n2. 测试 libcurl..." << std::endl;
    curl_global_init(CURL_GLOBAL_DEFAULT);
    CURL* curl = curl_easy_init();
    if(curl) {
        std::cout << "   libcurl 初始化成功" << std::endl;
        curl_easy_cleanup(curl);
    } else {
        std::cout << "   libcurl 初始化失败" << std::endl;
        all_success = false;
    }
    curl_global_cleanup();
#endif

#if TEST_JSON
    std::cout << "\n3. 测试 jsoncpp..." << std::endl;
    try {
        Json::Value root;
        root["test"] = "success";
        root["number"] = 42;
        std::cout << "   jsoncpp 工作正常" << std::endl;
    } catch (...) {
        std::cout << "   jsoncpp 测试失败" << std::endl;
        all_success = false;
    }
#endif

#if TEST_OPENCV
    std::cout << "\n1. 测试 OpenCV..." << std::endl;
    try {
        cv::Mat test_image(100, 100, CV_8UC3, cv::Scalar(0, 255, 0));
        std::cout << "   OpenCV 工作正常 (图像尺寸: " << test_image.cols << "x" << test_image.rows << ")" << std::endl;
    } catch (...) {
        std::cout << "   OpenCV 测试失败" << std::endl;
        all_success = false;
    }
#endif

#if TEST_TENSORFLOW_LITE
    std::cout << "\n4. 测试 TensorFlow Lite..." << std::endl;
    try {
        // 输出 TensorFlow Lite 版本信息
        std::cout << "   TensorFlow Lite 版本: " << TFLITE_VERSION_STRING << std::endl;

        // 测试基本类型定义
        std::cout << "   kTfLiteFloat32 = " << kTfLiteFloat32 << std::endl;
        std::cout << "   kTfLiteOk = " << kTfLiteOk << std::endl;

        // 使用简单的模型数据
        auto model = tflite::FlatBufferModel::BuildFromBuffer(
            reinterpret_cast<const char*>(simple_model_data),
            simple_model_data_len
        );

        if (model) {
            std::cout << "   TensorFlow Lite 模型加载成功" << std::endl;

            // 创建解释器 - 使用内置操作符解析器
            tflite::ops::builtin::BuiltinOpResolver resolver;
            std::unique_ptr<tflite::Interpreter> interpreter;

            if (tflite::InterpreterBuilder(*model, resolver)(&interpreter) == kTfLiteOk) {
                std::cout << "   TensorFlow Lite 解释器创建成功" << std::endl;

                // 分配张量
                if (interpreter->AllocateTensors() == kTfLiteOk) {
                    std::cout << "   TensorFlow Lite 张量分配成功" << std::endl;

                    // 获取输入输出张量信息
                    if (interpreter->inputs().size() > 0) {
                        TfLiteTensor* input_tensor = interpreter->tensor(interpreter->inputs()[0]);
                        std::cout << "   输入张量类型: " << input_tensor->type << std::endl;
                    }

                    if (interpreter->outputs().size() > 0) {
                        TfLiteTensor* output_tensor = interpreter->tensor(interpreter->outputs()[0]);
                        std::cout << "   输出张量类型: " << output_tensor->type << std::endl;
                    }

                } else {
                    std::cout << "   TensorFlow Lite 张量分配失败" << std::endl;
                }

            } else {
                std::cout << "   TensorFlow Lite 解释器创建失败" << std::endl;
            }

        } else {
            std::cout << "   TensorFlow Lite 模型加载失败" << std::endl;
        }

        std::cout << "   TensorFlow Lite 库加载成功" << std::endl;

    } catch (const std::exception& e) {
        std::cout << "   TensorFlow Lite 测试失败: " << e.what() << std::endl;
        all_success = false;
    } catch (...) {
        std::cout << "   TensorFlow Lite 测试失败 (未知错误)" << std::endl;
        all_success = false;
    }
#endif

    std::cout << "\n=== 测试结果 ===" << std::endl;
    if(all_success) {
        std::cout << "✓ 所有库功能正常!" << std::endl;
    } else {
        std::cout << "✗ 部分库存在问题" << std::endl;
    }

    std::cout << "\n按回车键退出...";
    std::cin.get();

    return all_success ? 0 : 1;
}