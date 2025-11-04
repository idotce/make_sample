#include <iostream>
#include "opencv2/opencv.hpp"
#include "opencv2/core/version.hpp"

int main() {
    // 打印OpenCV版本信息（多种方式）
    std::cout << "=== OpenCV 版本信息 ===" << std::endl;
    std::cout << "CV_VERSION: " << CV_VERSION << std::endl;
    std::cout << "getVersionString: " << cv::getVersionString() << std::endl;

    #ifdef OPENCV_VERSION
    std::cout << "OPENCV_VERSION: " << OPENCV_VERSION << std::endl;
    #endif

    #ifdef OPENCV_VERSION_MAJOR
    std::cout << "版本: " << OPENCV_VERSION_MAJOR << "."
              << OPENCV_VERSION_MINOR << "."
              << OPENCV_VERSION_PATCH << std::endl;
    #endif

    // 检查模块是否可用
    std::cout << "\n=== 模块检查 ===" << std::endl;
    #ifdef HAVE_OPENCV_IMGCODECS
    std::cout << "IMGCODECS模块: 可用" << std::endl;
    #else
    std::cout << "IMGCODECS模块: 不可用" << std::endl;
    #endif

    #ifdef HAVE_OPENCV_IMGPROC
    std::cout << "IMGPROC模块: 可用" << std::endl;
    #else
    std::cout << "IMGPROC模块: 不可用" << std::endl;
    #endif

    // 读取图片
    std::cout << "\n=== 图片处理 ===" << std::endl;
    cv::Mat image = cv::imread("input.jpg");

    // 检查图片是否成功加载
    if (image.empty()) {
        std::cerr << "错误: 无法加载图片 'input.jpg'" << std::endl;
        std::cerr << "请确保:" << std::endl;
        std::cerr << "1. 图片文件存在于当前目录" << std::endl;
        std::cerr << "2. OpenCV编译时包含了正确的图像编解码器" << std::endl;
        return -1;
    }

    std::cout << "图片加载成功!" << std::endl;
    std::cout << "图片尺寸: " << image.cols << " x " << image.rows << std::endl;
    std::cout << "通道数: " << image.channels() << std::endl;
    std::cout << "数据类型: " << image.type() << std::endl;

    // 转换为灰度图
    cv::Mat grayImage;
    cv::cvtColor(image, grayImage, cv::COLOR_BGR2GRAY);

    std::cout << "灰度图转换完成!" << std::endl;
    std::cout << "灰度图尺寸: " << grayImage.cols << " x " << grayImage.rows << std::endl;
    std::cout << "灰度图通道数: " << grayImage.channels() << std::endl;

    // 保存灰度图
    bool success = cv::imwrite("gray_image.jpg", grayImage);

    if (success) {
        std::cout << "灰度图已保存为 'gray_image.jpg'" << std::endl;
    } else {
        std::cerr << "错误: 无法保存灰度图" << std::endl;
        std::cerr << "请检查写权限和磁盘空间" << std::endl;
        return -1;
    }

    // 显示构建信息
    std::cout << "\n=== 构建信息 ===" << std::endl;
    std::cout << "构建编译器: " << cv::getBuildInformation().substr(0, 200) << "..." << std::endl;

    // 可选：显示原图和灰度图
    std::cout << "\n=== 显示图片 ===" << std::endl;
    cv::namedWindow("原图", cv::WINDOW_AUTOSIZE);
    cv::namedWindow("灰度图", cv::WINDOW_AUTOSIZE);

    cv::imshow("原图", image);
    cv::imshow("灰度图", grayImage);

    std::cout << "按任意键关闭窗口..." << std::endl;
    cv::waitKey(0);

    std::cout << "程序执行完成!" << std::endl;
    return 0;
}