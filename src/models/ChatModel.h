#pragma once

#include <QDateTime>
#include <QObject>

class Chat : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString chatId READ chatId CONSTANT)
  Q_PROPERTY(QString chatType READ chatType)
  Q_PROPERTY(QString chatName READ chatName)
  Q_PROPERTY(QString description READ description)
  Q_PROPERTY(QString imageURL READ imageURL)
  Q_PROPERTY(QDateTime createdAt READ createdAt CONSTANT)

private:
  QString m_chatId;
  QString m_chatType;
  QString m_chatName;
  QString m_description;
  QString m_imageURL;
  QDateTime m_createdAt;

public:
  explicit Chat(const QString &id, const QString &type, const QString &name,
                const QString &description, const QString &imageURL,
                const QDateTime &createdAt, QObject *parent = nullptr);

  QString chatId() const;
  QString chatType() const;
  QString chatName() const;
  QString description() const;
  QString imageURL() const;
  QDateTime createdAt() const;
  void setChatId(const QString &id) { m_chatId = id; };
};
