#include "LoginUser.h"

LoginUser::LoginUser(QObject *parent) : QObject(parent) {};

LoginUser::~LoginUser() {};

void LoginUser::receiveUserInfo(const QString login, const QString password)
{
    // Temporarily
    if (login == "CatTheBread" && password == "123123") {
        emit loginSucceed();
    } else {
        emit loginFailed();
    }
}
