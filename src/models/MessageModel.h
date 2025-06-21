#pragma once

#include "../core/Message.h"
#include "../core/MessageManager.h"
#include <QAbstractListModel>
#include <QObject>
#include <QVariant>
#include <QtQmlIntegration>
#include <qabstractitemmodel.h>
#include <qcontainerfwd.h>
#include <qsharedpointer.h>
#include <qtmetamacros.h>

class MessageModel : public QAbstractListModel {
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(QString chatId READ chatId WRITE setChatId NOTIFY chatIdChanged)

public:
  enum Role : int {
    IdRole,
    SenderRole = Qt::UserRole + 1,
    StatusRole,
    TextRole,
    CreatedAtRole
  };

  explicit MessageModel(QObject *parent = nullptr);

  Q_INVOKABLE void addMessage(const QString &sender, const QString &text);
  Q_INVOKABLE void removeMessage(const QString &id);
  // Q_INVOKABLE void addMessageToTempChat(const QString &receiverId, const QString &sender, const QString &text);
  // Q_INVOKABLE void flushPendingMessages(const QString &receiverId, const QString &chatId);
  void loadMessagesForChat(const QString &chatId);

  int rowCount(const QModelIndex &parent = QModelIndex()) const override;
  QVariant data(const QModelIndex &index, int role) const override;
  QHash<int, QByteArray> roleNames() const override;

  QString chatId() const;
  void setChatId(const QString &id);
public slots:
  void onMessageSent(const QString &chatId,
                     const QString &tempId,
                     const QString &id,
                     const QString &createdAt);
  void updateMessageStatus(const QString &id, const QString &status);

signals:
  void chatIdChanged();

  // protected:
  //   bool canFetchMore(const QModelIndex &parent) const override;
  //   void fetchMore(const QModelIndex &parent) override;
private slots:
  void handleMessagesReceived(const QString &chatId,
                              const QList<Message> &messages);

private:
  QSharedPointer<MessageManager> m_mesman;
  QHash<QString, QList<Message>> m_chatMessages;
  QList<Message> m_messages;
  QList<Message> m_pendingMessages;
  QString m_chatId;
  QTimer *m_updateTimer;
  QSet<QString> m_knownIds;
};
