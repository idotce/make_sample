#include <iostream>
#include <vector>
#include <functional>
#include <windows.h>
#include <atlstr.h>

using namespace std;

struct WinInfo {
    HWND hwnd;
    std::string desc;
};

class Enumerator
{
public:
    using EnumCallback = std::function<void(const WinInfo &)>;
    static bool Runner(EnumCallback callback) {
        return ::EnumWindows(EnumWindowsProc, (LPARAM)&callback);
    }

private:
    static BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam) {
        HWND desktop = ::GetDesktopWindow();
        HWND parent = ::GetAncestor(hwnd, GA_PARENT);

        _TCHAR szTitle[MAX_PATH] = { 0 };
        ::GetWindowText(hwnd, szTitle, MAX_PATH);

        if (parent != nullptr && parent != desktop) return TRUE;
        if (_tcscmp(szTitle, _T("")) == 0) return TRUE;
        // if (::IsIconic(hwnd)) return TRUE;
        //if (!::IsWindowVisible(hwnd)) return TRUE;

        // [https://docs.microsoft.com/en-us/windows/win32/api/dwmapi/ne-dwmapi-dwmwindowattribute]
       // DWORD flag = 0;
       // DwmGetWindowAttribute(hwnd, DWMWA_CLOAKED, &flag, sizeof(flag));
       // if (flag) return TRUE;

        if (lParam) {
            WinInfo win_info{hwnd, (LPCSTR)CT2A(szTitle, CP_ACP)};
            EnumCallback *callback_ptr = reinterpret_cast<EnumCallback *>(lParam);
            callback_ptr->operator()(win_info);
        }

        return TRUE;
    }
};

int main(int argc, char* argv[])
{
    std::vector<WinInfo> win_vec;
    Enumerator::Runner([&win_vec](const WinInfo &win_info) {
        win_vec.push_back(win_info);
    });

    for (const auto &win : win_vec) {
        _TCHAR szTitle[MAX_PATH] = { 0 };
        ::GetWindowText(win.hwnd, szTitle, MAX_PATH);

        printf("0x%08x - %s\r\n", win.hwnd, win.desc.c_str());
    }

    system("PAUSE");
    return EXIT_SUCCESS;
}
