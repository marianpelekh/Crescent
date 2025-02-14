#pragma once

#include <QObject>
#include <qcontainerfwd.h>
#include <qqmlintegration.h>

class LoginUser : public QObject
{
        Q_OBJECT
        QML_ELEMENT
    public:
        explicit LoginUser(QObject *parent = nullptr);
        ~LoginUser();
        Q_INVOKABLE void receiveUserInfo(const QString userId, const QString password);
    signals:
        void loginSucceed();
        void loginFailed();
};
