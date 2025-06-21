#pragma once

#include <qobject.h>
#include <qqmlengine.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
class ChatManager : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON
  explicit ChatManager();

public:
  static ChatManager *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
  static ChatManager *instance();
public slots:
  void createChat(const QString &target_user_id);
  void deleteChat(const QString &chat_id);
signals:
  QString chatCreated(const QString &chat_id);
  void chatCreationFailed();
  void chatDeleted();
  void chatDeletionFailed();
};