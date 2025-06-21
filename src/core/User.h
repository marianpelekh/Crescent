#pragma once

#include <QDate>
#include <QObject>
#include <qobject.h>

struct User : public QObject
{
        Q_OBJECT
        QString username;
        QString visible_name;
        QString email;
        QDate birthdate;

        enum Status {
            Online,
            Offline
        } status;
};
