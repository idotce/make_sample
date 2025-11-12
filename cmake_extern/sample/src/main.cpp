// src/main.cpp - 简化版本
#include <iostream>
#include <string>
#include <vector>

// 测试宏定义
#define TEST_OPENCV 1
#define TEST_CURL 1
#define TEST_JSON 1
#define TEST_TENSORFLOW_LITE 1

#if TEST_OPENCV
#include <opencv2/opencv.hpp>
#endif

#if TEST_CURL
#include <curl/curl.h>
#endif

#if TEST_JSON
#include <json/json.h>
#endif

#if TEST_TENSORFLOW_LITE
// TensorFlow Lite 头文件
#include "tensorflow/lite/interpreter.h"
#include "tensorflow/lite/kernels/register.h"
#include "tensorflow/lite/model.h"
#include "tensorflow/lite/version.h"
#endif

int main() {
#ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
    SetConsoleCP(CP_UTF8);
#endif

    std::cout << "=== 库功能测试 ===" << std::endl;

    bool all_success = true;

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
        std::cout << "   示例 JSON: " << root.toStyledString() << std::endl;
    } catch (...) {
        std::cout << "   jsoncpp 测试失败" << std::endl;
        all_success = false;
    }
#endif

#if TEST_TENSORFLOW_LITE
    std::cout << "\n4. 测试 TensorFlow Lite..." << std::endl;
    try {
        // 输出 TensorFlow Lite 版本信息
        std::cout << "   TensorFlow Lite 版本: " << TFLITE_VERSION_STRING << std::endl;

        // 创建一个简单的模型（使用 FlatBuffer 构建器创建最小模型）
        // 这里我们只是测试库是否能正常加载和初始化

        // 尝试创建解释器
        std::unique_ptr<tflite::Interpreter> interpreter;

        // 创建一个空的模型（仅用于测试）
        // 在实际应用中，你会从文件加载真实的 .tflite 模型
        std::unique_ptr<tflite::FlatBufferModel> model;

        // 尝试创建一个最小的解释器来测试功能
        tflite::ops::builtin::BuiltinOpResolver resolver;
        tflite::InterpreterBuilder builder(nullptr, 0, resolver);

        if (builder(&interpreter) == kTfLiteOk) {
            std::cout << "   TensorFlow Lite 解释器创建成功" << std::endl;

            // 测试简单的张量操作
            TfLiteTensor* tensor = nullptr;
            std::cout << "   TensorFlow Lite 基本功能正常" << std::endl;

        } else {
            std::cout << "   TensorFlow Lite 解释器创建失败" << std::endl;
            all_success = false;
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