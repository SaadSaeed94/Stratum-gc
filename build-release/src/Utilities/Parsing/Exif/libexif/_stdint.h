
#pragma once
#include <stdint.h>

/* ssize_t is POSIX, not available on Windows/MSVC */
#ifdef _MSC_VER
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#else
#include <sys/types.h>
#endif
