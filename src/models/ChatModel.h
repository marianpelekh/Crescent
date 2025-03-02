#pragma once

#include <QObject>
#include <qdatetime.h>

class Chat : public QObject
{
        Q_OBJECT
        QString chatId;
        QString chatType;
        QString chatName;
        QString description;
        QString imageURL;
        QDateTime createdAt;

    public:
        Chat(QObject *parent = nullptr);
        ~Chat();
};
