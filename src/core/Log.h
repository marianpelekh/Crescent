#pragma once

#include <QDebug>

#define LOCATION QString("\n\t(%1:%2)").arg(__FILE__).arg(__LINE__)

#define Log_Info(message) qDebug().noquote() << "[\033[1;37mInfo\033[0m]" << message << LOCATION
#define Log_Warning(message) qWarning().noquote() << "[\033[1;33mWarning\033[0m]" << message << LOCATION
#define Log_Error(message)                                                                                                          \
    qCritical().noquote() << "[\033[1;31mError\033[0m]" << message << LOCATION;                                                     \
    exit(-1)

#ifdef NDEBUG
#define Log_Debug(message)
#else
#define Log_Debug(message) qDebug().noquote() << "[\033[1;32mDebug\033[0m]" << message << LOCATION
#endif
