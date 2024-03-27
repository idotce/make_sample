#include <string>
#include <iostream>
#if 0
#include <sstream>
#include <locale>
#include <iomanip>
#include <ctime>
#include <chrono>
#endif
#include <atltime.h>

// using namespace std;
// https://en.cppreference.com/w/cpp/io/manip/get_time

int main(int argc, char* argv[])
{
#if 0
    struct std::tm tm = {};
    std::istringstream ss("2022-50-6");
    ss >> std::get_time(&tm, "%Y-%W-%w");

    //std::time_t timestamp = std::mktime(&tm);
    //struct std::tm *ptm = std::localtime(&timestamp);
    //std::cout << std::put_time(ptm,"%c %Y %W %w") << '\n';

    std::cout << std::put_time(&tm, "%c %Y %W %w") << '\n';


    using std::chrono::system_clock;
    std::time_t tt = system_clock::to_time_t(system_clock::now());

    ptm = std::localtime(&tt);
    std::cout << std::put_time(ptm,"%c %W %w") << '\n';
#endif
    CTime ct(2022, 1, 1, 0, 0, 0);
    printf("day of week %d\n",ct.GetDayOfWeek());
    CString s = ct.Format("%Y %m %d %U %w"); // %Y %m %d  %H %M %S
    printf("day %s\n", s.GetBuffer());

    system("PAUSE");
    return EXIT_SUCCESS;
}
