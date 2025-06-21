#include "ChatModel.h"

Chat::Chat(const QString &id, const QString &type, const QString &name, const QString &description, const QString &imageURL,
           const QDateTime &createdAt, QObject *parent)
    : QObject(parent)
    , m_chatId(id)
    , m_chatType(type)
    , m_chatName(name)
    , m_description(description)
    , m_imageURL(imageURL)
    , m_createdAt(createdAt)
{
}

QString Chat::chatId() const { return m_chatId; }
QString Chat::chatType() const { return m_chatType; }
QString Chat::chatName() const { return m_chatName; }
QString Chat::description() const { return m_description; }
QString Chat::imageURL() const { return m_imageURL; }
QDateTime Chat::createdAt() const { return m_createdAt; }
