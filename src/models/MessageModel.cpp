#include "MessageModel.h"
#include <qlogging.h>
#include <string>

MessageModel::MessageModel(QObject *parent)
    : QAbstractListModel(parent), m_mesman(MessageManager::instance()) {
  connect(m_mesman.data(), &MessageManager::messagesReceived, this,
          &MessageModel::handleMessagesReceived);
  m_updateTimer = new QTimer(this);
  connect(m_updateTimer, &QTimer::timeout, this, [this]() {
    if (!m_chatId.isEmpty()) {
      m_mesman->getMessages(
          m_chatId); // Викликаємо оновлення для поточного чату
    }
  });
  connect(m_mesman.get(),
        &MessageManager::messageSent,
        this,
        &MessageModel::onMessageSent,
        Qt::QueuedConnection);
}

void MessageModel::addMessage(const QString &sender, const QString &text) {
  if (m_chatId.isEmpty())
    return;

  qDebug() << "addMessage";

  Message message;
  message.tempId =  QUuid::createUuid().toString();
  message.sender = sender;
  message.text = text;
  message.status = "pending";
  message.created_at = QDateTime::currentDateTime().toString(
      Qt::ISODate); // або як ти зберігаєш дату

  beginInsertRows(QModelIndex(), m_messages.count(), m_messages.count());
  m_messages.append(message);
  endInsertRows();

  m_mesman->sendMessage(m_chatId, message.sender, message.text, message.tempId);

  m_chatMessages[m_chatId] = m_messages;
}

void MessageModel::removeMessage(const QString &id) {
  if (m_chatId.isEmpty())
    return;

  for (int i = 0; i < m_messages.size(); ++i) {
    if (m_messages[i].id == id || m_messages[i].tempId == id) {
      beginRemoveRows(QModelIndex(), i, i);
      m_messages.removeAt(i);
      endRemoveRows();

      m_chatMessages[m_chatId] = m_messages;
      break;
    }
  }

  m_mesman->deleteMessage(m_chatId, id);
}


// void MessageModel::addMessageToTempChat(const QString &receiverId, const QString &sender, const QString &text) {
//     Message message;
//     message.tempId = QUuid::createUuid().toString();
//     message.sender = sender;
//     message.text = text;
//     message.created_at = QDateTime::currentDateTime().toString(Qt::ISODate);

//     beginInsertRows(QModelIndex(), m_messages.count(), m_messages.count());
//     m_messages.append(message);
//     endInsertRows();

//     // Кешуємо повідомлення тимчасово, без реального chatId
//     m_pendingMessages[receiverId].append(message);
// }

// void MessageModel::flushPendingMessages(const QString &receiverId, const QString &chatId) {
//     if (!m_pendingMessages.contains(receiverId)) return;

//     QList<Message> pending = m_pendingMessages.take(receiverId);
//     for (const Message &msg : pending) {
//         m_mesman->sendMessage(chatId, msg.sender, msg.text, msg.tempId);
//     }
// }



void MessageModel::onMessageSent(const QString &chatId,
                                 const QString &tempId,
                                 const QString &id,
                                 const QString &createdAt) {
    auto it = std::find_if(m_messages.begin(), m_messages.end(),
        [&tempId](const Message &m){ return m.tempId == tempId; });
    if (it == m_messages.end()) return;
    int row = std::distance(m_messages.begin(), it);
    // qDebug() << it->text + " " << it->id + " " << it->created_at;
    it->tempId = id;
    it->created_at = createdAt;
    // qDebug() << it->text + " " << it->id + " " << it->created_at;
    QModelIndex idx = index(row);
    // emit dataChanged(idx, idx, { RoleId, RoleCreatedAt });
}

// void MessageModel::loadMessagesForChat(const QString &chatId) {
//   if (m_chatId == chatId && !m_messages.isEmpty()) {
//     return;
//   }
//   beginResetModel();
//   m_messages = m_chatMessages.value(chatId, {});
//   m_mesman->getMessages(chatId);
//   m_chatId = chatId;
//   endResetModel();
// }
void MessageModel::loadMessagesForChat(const QString &chatId) {
  if (m_chatId == chatId && !m_messages.isEmpty()) {
    return;
  }

  // Зупиняємо попередній таймер
  if (m_updateTimer->isActive()) {
    m_updateTimer->stop();
  }

  m_chatId = chatId;
  emit chatIdChanged();
  m_messages = m_chatMessages.value(chatId, {});
  beginResetModel();
  endResetModel();

  // Запускаємо таймер для симуляції
  m_updateTimer->start(1000); // Оновлення кожну секунду

  // Первинне завантаження
  m_mesman->getMessages(chatId);
}

// void MessageModel::handleMessagesReceived(const QString &chatId,
//                                           const QList<Message> &messages) {

//   m_chatMessages.insert(chatId, messages);
//   if (chatId == m_chatId) {
//     beginResetModel();
//     m_messages = messages;
//     endResetModel();
//   }
// }
int MessageModel::rowCount(const QModelIndex &parent) const {
  Q_UNUSED(parent);
  return m_messages.count();
}
void MessageModel::handleMessagesReceived(const QString &chatId,
                                          const QList<Message> &messages) {
  if (chatId != m_chatId)
    return;

  // Додаємо лише нові повідомлення, яких ще немає в m_messages
  QList<Message> newMessages;

  // Вважаємо, що ID унікальні (або CreatedAtRole)
  QSet<QString> knownIds;
  for (const Message &msg : m_messages)
    knownIds.insert(msg.id);

  QSet<QString> knownTimestamps;
  for (const Message &msg : m_messages) {
    knownIds.insert(msg.id);
    knownTimestamps.insert(msg.created_at);
  }

  for (const Message &msg : messages) {
    if (!msg.id.isEmpty() && knownIds.contains(msg.id))
      continue;
    if (knownTimestamps.contains(msg.created_at))
      continue;

    if (!knownIds.contains(msg.id)) {
      newMessages.append(msg);
    }
  }

  if (newMessages.isEmpty())
    return;

  // Сортуємо, якщо потрібно
  std::sort(newMessages.begin(), newMessages.end(),
            [](const Message &a, const Message &b) {
              return a.created_at < b.created_at;
            });

  // Додаємо в кінець
  beginInsertRows(QModelIndex(), m_messages.count(),
                  m_messages.count() + newMessages.count() - 1);
  m_messages.append(newMessages);
  endInsertRows();

  // Оновлюємо кеш
  m_chatMessages[chatId] = m_messages;
}

QVariant MessageModel::data(const QModelIndex &index, int role) const {
  if (!index.isValid() || index.row() >= m_messages.count())
    return QVariant();

  const Message &message = m_messages[index.row()];
  switch (role) {
  case IdRole:
    return message.id;
  case SenderRole:
    return message.sender;
    case StatusRole:
    return message.status;
  case TextRole:
    return message.text;
  case CreatedAtRole:
    return message.created_at;
  default:
    return QVariant();
  }
}

QHash<int, QByteArray> MessageModel::roleNames() const {
  QHash<int, QByteArray> roles;
  roles[IdRole] = "id";
  roles[SenderRole] = "sender";
  roles[StatusRole] = "status";
  roles[TextRole] = "text";
  roles[CreatedAtRole] = "created_at";
  return roles;
}

QString MessageModel::chatId() const { return m_chatId; }

void MessageModel::setChatId(const QString &id) {
  if (m_chatId == id)
    return;

  m_chatId = id;
  emit chatIdChanged();
  loadMessagesForChat(m_chatId);
}

void MessageModel::updateMessageStatus(const QString &id, const QString &status) {
  
}