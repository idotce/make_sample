#include <string>
#include <iostream>
#include <atltime.h>
#if 1
#include <sstream>
#include <locale>
#include <iomanip>
#include <ctime>
#include <chrono>
#endif

// https://en.cppreference.com/w/cpp/io/manip/get_time

using namespace std;

int _tmain(int argc, _TCHAR* argv[])
{
    CTime ct(2022, 1, 1, 0, 0, 0);
    printf("day of week %d\n",ct.GetDayOfWeek());
    CString s = ct.Format("%Y %m %d %U %w"); // %Y %m %d  %H %M %S
    printf("day %s\n", s.GetBuffer());

#if 1
    struct tm tm1 = {0};
    istringstream ss("2022-50-6");
    ss >> get_time(&tm1, "%Y-%W-%w");
    cout << put_time(&tm1, "%c %Y %W %w") << '\n';
#endif
#if 1
    struct tm tm2 = {0};
    time_t tt2 = mktime(&tm2);
    struct tm *_tm2 = localtime(&tt2);
    cout << put_time(_tm2, "%c %Y %W %w") << '\n';
#endif
#if 1
    using chrono::system_clock;
    time_t tt3 = system_clock::to_time_t(system_clock::now());
    struct tm *_tm3 = localtime(&tt3);
    cout << put_time(_tm3, "%c %Y %W %w") << '\n';
#endif

    system("PAUSE");
    return EXIT_SUCCESS;
}
