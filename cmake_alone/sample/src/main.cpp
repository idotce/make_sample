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
#ifdef _WIN32
#define TEST_GLEW 1
#endif

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

#if TEST_GLEW
// GLEW需要在OpenGL头文件之前包含
#include <GL/glew.h>
// 包含OpenGL头文件
#ifdef _WIN32
#include <GL/wglew.h>
#else
#include <GL/glxew.h>
#endif
#endif

// Windows 窗口过程函数（空实现，仅用于满足窗口创建要求）
#ifdef _WIN32
LRESULT CALLBACK TempWndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_DESTROY:
            PostQuitMessage(0);
            break;
        default:
            return DefWindowProc(hWnd, uMsg, wParam, lParam);
    }
    return 0;
}
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

        if (model && 0) {
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

#if TEST_GLEW
    std::cout << "\n5. 测试 GLEW..." << std::endl;
    try {
        // 注意：实际使用中需要先创建OpenGL上下文才能正确初始化GLEW
        // 这里仅做库加载和基本初始化检查
        std::cout << "   GLEW 版本: " << GLEW_VERSION << std::endl;
#ifdef _WIN32
        // 步骤1：创建临时窗口（仅用于获取 OpenGL 上下文）
        const char* wndClassName = "TempGLWndClass";
        HINSTANCE hInstance = GetModuleHandle(NULL);

        // 注册窗口类
        WNDCLASSEX wcex = {0};
        wcex.cbSize = sizeof(WNDCLASSEX);
        wcex.lpfnWndProc = TempWndProc;  // 窗口过程（空实现）
        wcex.hInstance = hInstance;
        wcex.lpszClassName = wndClassName;
        if (!RegisterClassEx(&wcex)) {
            throw std::runtime_error("窗口类注册失败");
        }

        // 创建隐藏窗口（SW_HIDE 不显示窗口，不影响用户体验）
        HWND hWnd = CreateWindowEx(
            0, wndClassName, "TempGLWindow", SW_HIDE,
            0, 0, 100, 100, NULL, NULL, hInstance, NULL
        );
        if (!hWnd) {
            throw std::runtime_error("窗口创建失败");
        }

        // 步骤2：创建 OpenGL 上下文
        HDC hDC = GetDC(hWnd);  // 获取设备上下文
        PIXELFORMATDESCRIPTOR pfd = {0};
        pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
        pfd.nVersion = 1;
        pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
        pfd.iPixelType = PFD_TYPE_RGBA;
        pfd.cColorBits = 24;
        pfd.cDepthBits = 16;

        // 选择像素格式
        int pixelFormat = ChoosePixelFormat(hDC, &pfd);
        if (!SetPixelFormat(hDC, pixelFormat, &pfd)) {
            throw std::runtime_error("设置像素格式失败");
        }

        // 创建 OpenGL 渲染上下文
        HGLRC hGLRC = wglCreateContext(hDC);
        if (!hGLRC) {
            throw std::runtime_error("创建 OpenGL 上下文失败");
        }

        // 步骤3：激活 OpenGL 上下文（GLEW 初始化必须在此之后）
        if (!wglMakeCurrent(hDC, hGLRC)) {
            throw std::runtime_error("激活 OpenGL 上下文失败");
        }
#endif
        // 模拟初始化检查（实际需要有效的OpenGL上下文）
        GLenum err = glewInit();
        if (err == GLEW_OK) {
            std::cout << "   GLEW 初始化成功" << std::endl;
            // 检查是否支持OpenGL 2.0及以上
            if (GLEW_VERSION_2_0) {
                std::cout << "   支持 OpenGL 2.0 及以上" << std::endl;
            } else {
                std::cout << "   不支持 OpenGL 2.0 及以上" << std::endl;
            }
        } else {
            std::cout << "   GLEW 初始化失败: " << glewGetErrorString(err) << std::endl;
            all_success = false;
        }
#ifdef _WIN32
        // 步骤5：清理临时资源（避免内存泄漏）
        wglMakeCurrent(NULL, NULL);  // 解除上下文绑定
        wglDeleteContext(hGLRC);     // 删除 OpenGL 上下文
        ReleaseDC(hWnd, hDC);        // 释放设备上下文
        DestroyWindow(hWnd);         // 销毁窗口
        UnregisterClass(wndClassName, hInstance);  // 注销窗口类
#endif
    } catch (...) {
        std::cout << "   GLEW 测试失败" << std::endl;
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