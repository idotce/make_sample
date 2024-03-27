#include <atltime.h>

int _tmain(int argc, _TCHAR* argv[])
{
    CTime ct;
    printf("day of week %d\n",ct.GetDayOfWeek());

    system("PAUSE");
    return 0;
}
