#pragma once

#include "Message.h"
#include <QObject>
#include <QQmlEngine>
#include <QtQmlIntegration>
#include <qcontainerfwd.h>
#include <qobject.h>
#include <qtmetamacros.h>

class MessageManager : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON
  explicit MessageManager();

public:
  static MessageManager *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
  static MessageManager *instance();
public slots:
  void sendMessage(const QString &chat_id, const QString &sender,
                   const QString &text, const QString &temp_message_id);
  void getMessages(const QString &chat_id);
  Q_INVOKABLE void deleteMessage(const QString &chatId, const QString &messageId);
signals:
  void messageSent(const QString &chatId, const QString &tempId,
                   const QString &id, const QString &createdAt);
  void messageReceived();
  void errorOccurred(QString);
  void messagesReceived(const QString &chatId, const QList<Message> &messages);
};