#include <sys/cdefs.h>
#include <ncurses.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <sys/stat.h>
#include <pthread.h>
#include <sys/ioctl.h>

#ifdef CLK_TCK
#undef CLK_TCK
#endif
#define CLK_TCK (sysconf(_SC_CLK_TCK))
