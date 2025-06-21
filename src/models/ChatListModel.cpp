#include "ChatListModel.h"
#include "../core/MessageManager.h"
#include "../core/UserManager.h"
#include "ChatModel.h"
#include "MessageModel.h"
#include <../core/AuthManager.h>
#include <../core/RestAPIManager.h>
#include <QDateTime>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <qlogging.h>

ChatListModel::ChatListModel(QObject *parent) : QAbstractListModel(parent) {}

int ChatListModel::rowCount(const QModelIndex &parent) const {
  return m_searchActive ? m_searched_chats.count() : m_chats.count();
}

int ChatListModel::count() const { return rowCount(); }

QVariant ChatListModel::data(const QModelIndex &index, int role) const {
  if (!index.isValid() || index.row() < 0 || index.row() >= rowCount())
    return {};

  auto &list = m_searchActive ? m_searched_chats : m_chats;
  auto chatPtr = list.at(index.row());
  if (chatPtr.isNull())
    return {};

  switch (role) {
  case IdRole:
    return chatPtr->chatId();
  case TypeRole:
    return chatPtr->chatType();
  case NameRole:
    return chatPtr->chatName();
  case DescriptionRole:
    return chatPtr->description();
  case ImageURLRole: {
    QString fn =
        chatPtr->imageURL(); // e.g. "assets/noimage.png"
                             // if it’s our “no image” asset, emit a qrc URL:
    if (fn == "assets/noimage.png") {
      return QUrl(QStringLiteral("qrc:/images/noimage.png"));
    }
    // otherwise it should be in res/chats/…, on disk:
    QString fullPath = QCoreApplication::applicationDirPath() + "/res/chats/" +
                       chatPtr->chatId() + "/" + QFileInfo(fn).fileName();
    // this produces e.g. "file:///…/res/chats/36a5…/cat.jpg"
    return QUrl::fromLocalFile(fullPath);
  }
  case CreatedAtRole:
    return chatPtr->createdAt();
  default:
    return {};
  }
}

QHash<int, QByteArray> ChatListModel::roleNames() const {
  QHash<int, QByteArray> roles;
  roles[IdRole] = "chatId";
  roles[TypeRole] = "chatType";
  roles[NameRole] = "chatName";
  roles[DescriptionRole] = "description";
  roles[ImageURLRole] = "chatImage";
  roles[CreatedAtRole] = "createdAt";
  return roles;
}

int ChatListModel::searchCount() const { return m_searched_chats.size(); }

void ChatListModel::loadChats() {
  qDebug() << "Load chats";
  RestAPIManager *api = RestAPIManager::instance();
  api->setAuthorizationHeader(AuthManager::instance()->getAccessToken());
  api->get("/v1/chats", [this](int code, const QVariant &response) {
    if (code == 200 && response.canConvert<QJsonDocument>()) {
      beginResetModel();
      m_chats.clear();

      QJsonDocument doc;
      if (response.canConvert<QJsonDocument>()) {
        doc = response.value<QJsonDocument>();
      } else if (response.canConvert<QByteArray>()) {
        doc = QJsonDocument::fromJson(response.toByteArray());
      }

      QJsonArray arr;
      if (doc.isArray()) {
        arr = doc.array();
      } else if (doc.isObject() && doc.object().contains("chats")) {
        arr = doc.object().value("chats").toArray();
      }

      for (const QJsonValue &val : arr) {
        QJsonObject obj = val.toObject();
        auto chatPtr = QSharedPointer<Chat>::create(
            obj.value("id").toString(), obj.value("type").toString(),
            obj.value("title").toString(), obj.value("description").toString(),
            obj.value("chat_img").toString(),
            QDateTime::fromString(obj.value("created_at").toString(),
                                  Qt::ISODate),
            this);
        m_chats.push_back(chatPtr);
      }
      for (const auto &chat : m_chats) {
        qDebug() << "Chat ID:" << chat->chatId() << "Type:" << chat->chatType()
                 << "Title:" << chat->chatName()
                 << "Description:" << chat->description()
                 << "Image URL:" << chat->imageURL()
                 << "Created at:" << chat->createdAt();
      }
      endResetModel();
      emit countChanged();
    } else {
      qWarning() << "Error of loading chats";
    }
  });
}
void ChatListModel::searchChats(const QString &name) {
  m_searchActive = true;

  RestAPIManager *api = RestAPIManager::instance();
  api->setAuthorizationHeader(AuthManager::instance()->getAccessToken());

  QString endpoint = "/v1/chats/search?query=" + QUrl::toPercentEncoding(name);
  api->get(endpoint, [this](int code, const QVariant &response) {
    if (code == 200 && response.canConvert<QJsonDocument>()) {
      beginResetModel();
      m_searched_chats.clear();

      QJsonDocument doc;
      if (response.canConvert<QJsonDocument>()) {
        doc = response.value<QJsonDocument>();
      } else if (response.canConvert<QByteArray>()) {
        doc = QJsonDocument::fromJson(response.toByteArray());
      }

      QJsonArray arr;
      if (doc.isArray()) {
        arr = doc.array();
      } else if (doc.isObject() && doc.object().contains("chats")) {
        arr = doc.object().value("chats").toArray();
      }

      for (const QJsonValue &val : arr) {
        QJsonObject obj = val.toObject();
        auto chatPtr = QSharedPointer<Chat>::create(
            obj.value("id").toString(), obj.value("type").toString(),
            obj.value("title").toString(), obj.value("description").toString(),
            obj.value("chat_img").toString(),
            QDateTime::fromString(obj.value("created_at").toString(),
                                  Qt::ISODate),
            this);
        m_searched_chats.push_back(chatPtr);
      }

      for (const auto &chat : m_searched_chats) {
        qDebug() << "Found Chat ID or User ID:" << chat->chatId()
                 << "Type:" << chat->chatType() << "Title:" << chat->chatName()
                 << "Description:" << chat->description()
                 << "Image URL:" << chat->imageURL()
                 << "Created at:" << chat->createdAt();
      }

      endResetModel();
      emit countChanged();
    } else {
      qWarning() << "Error searching chats. HTTP code:" << code;
      m_searched_chats.clear();
      endResetModel();
      emit countChanged();
    }
  });
}

void ChatListModel::setSearch(const bool &search) { m_searchActive = search; }

Q_INVOKABLE void ChatListModel::clearSearch() {
  if (m_searchActive) {
    beginResetModel();
    m_searchActive = false;
    m_searched_chats.clear();
    endResetModel();
    emit countChanged();
  } else {
    qDebug() << "Search already cleared";
  }
}

// QSharedPointer<Chat> ChatListModel::getOrCreateTempChat(const QString
// &userId, const QString &userName) {
//     if (m_tempChats.contains(userId))
//         return m_tempChats[userId];

//     auto tempChat = QSharedPointer<Chat>::create(userId, "private", userName,
//     "", "", QDateTime::currentDateTime(), this); m_tempChats[userId] =
//     tempChat; emit countChanged(); // якщо потрібно відобразити return
//     tempChat;
// }

// void ChatListModel::sendMessageToTempChat(const QString &receiverId, const
// QString &receiverName, const QString &messageText) {
//     auto tempChat = getOrCreateTempChat(receiverId, receiverName);

//     // 1. Створити чат на сервері
//     QVariantMap body;
//     body["sender_id"] = UserManager::instance()->user_id();
//     body["receiver_id"] = receiverId;

//     RestAPIManager::instance()->post("/v1/chats/new/",
//     QJsonObject::fromVariantMap(body), [=](int code, const QVariant
//     &response) {
//         if (code == 200 || code == 201) {
//             QString newChatId;

//             if (response.canConvert<QJsonDocument>()) {
//                 QJsonObject obj = response.value<QJsonDocument>().object();
//                 newChatId = obj.value("chat_id").toString();  // Припускаємо,
//                 що сервер повертає саме це поле
//             }

//             if (!newChatId.isEmpty()) {
//                 // 2. Оновити тимчасовий чат
//                 tempChat->setChatId(newChatId);

//                 // 3. Перемістити до m_chats
//                 beginResetModel();
//                 m_chats.append(tempChat);
//                 m_tempChats.remove(receiverId);
//                 endResetModel();
//                 emit countChanged();

//                 // 4. Надіслати повідомлення вже з новим chatId
//                 addMessageToTempChat(newChatId,
//                 UserManager::instance()->user_id(), messageText,
//                 QUuid::createUuid().toString());
//             }
//         } else {
//             qWarning() << "Failed to create chat. Code:" << code;
//         }
//     });
// }
