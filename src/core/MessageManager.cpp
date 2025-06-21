#include "MessageManager.h"
#include "AuthManager.h"
#include "RestAPIManager.h"
#include <qdebug.h>
MessageManager::MessageManager() {}
MessageManager *MessageManager::instance() {
  static MessageManager instance;
  return &instance;
}
MessageManager *MessageManager::create(QQmlEngine *, QJSEngine *) {
  return instance();
}
void MessageManager::sendMessage(const QString &chat_id, const QString &sender,
                                 const QString &text,
                                 const QString &temp_message_id) {
  RestAPIManager *api = RestAPIManager::instance();
  api->setAuthorizationHeader(AuthManager::instance()->getAccessToken());

  QJsonObject body;
  //   body["sender"] = sender;
  body["text"] = text;
  body["created_at"] = QDateTime::currentDateTime().toString(Qt::ISODate);
  qDebug() << "Sending JSON:"
           << QJsonDocument(body).toJson(QJsonDocument::Compact);
  api->post(
      "/v1/chats/" + chat_id + "/message", body,
      [this, chat_id, temp_message_id](int code, const QVariant &response) {
        if (code == 200 && response.canConvert<QJsonDocument>()) {
          QJsonObject json = response.value<QJsonDocument>().object();

          qDebug() << "Message sent successfully:" << json;
          emit messageSent(chat_id, temp_message_id,
                           json.value("id").toString(),
                           json.value("created_at").toString());
        } else {
          qWarning() << "Failed to send message. Code:" << code
                     << "Response:" << response;
        }
      });
}

void MessageManager::getMessages(const QString &chat_id) {
  RestAPIManager *api = RestAPIManager::instance();
  api->setAuthorizationHeader(AuthManager::instance()->getAccessToken());

  QList<Message> messages;

  api->get("/v1/chats/" + chat_id + "/message/all",
           [this, chat_id](int code, const QVariant &response) {
             if (code == 200) {
               if (response.canConvert<QJsonDocument>()) {
                 QJsonDocument doc = response.value<QJsonDocument>();

                 // Перевірка чи відповідь є масивом
                 if (!doc.isArray()) {
                   qWarning() << "Invalid response format - expected array";
                   emit errorOccurred("Invalid server response");
                   return;
                 }

                 QJsonArray messagesArray = doc.array();
                 QList<Message> tempList;

                 for (const QJsonValue &value : messagesArray) {
                   if (!value.isObject()) {
                     qWarning() << "Invalid message format";
                     continue;
                   }

                   QJsonObject msg = value.toObject();

                   Message message;
                   message.id = msg["id"].toString();
                   message.sender = msg["sender_username"].toString();
                   message.text = msg["text"].toString();
                   message.status = "sent";
                   QString dbTimeStr =
                       msg["created_at"]
                           .toString(); // Наприклад: "2025-05-24 13:55:42"

                   QDateTime utcTime =
                       QDateTime::fromString(dbTimeStr, "yyyy-MM-dd HH:mm:ss");
                   // utcTime.setTimeZone(QTimeZone("UTC"));

                   QDateTime localTime =
                       utcTime.toLocalTime(); // отримуємо локальний
                   QString localTimeStr =
                       localTime.toString("yyyy-MM-dd HH:mm:ss");
                   message.created_at = localTimeStr;

                   // Опціональні поля
                   if (msg.contains("media") && !msg["media"].isNull()) {
                     message.media = msg["media"].toString();
                   }

                   if (msg["forwarded"].toInt() == 1) {
                     message.forwarded = true;
                     message.forwarded_by = msg["forwarded_by"].toString();
                   }

                   tempList.append(message);
                 }

                 emit messagesReceived(chat_id, tempList);
               }
             } else {
               qWarning() << "Request failed with code:" << code;
               emit errorOccurred(QString("Server error: %1").arg(code));
             }
           });
}

void MessageManager::deleteMessage(const QString &chatId, const QString &messageId) {
  // RestAPIManager *api = RestAPIManager::instance();
  // api->setAuthorizationHeader(AuthManager::instance()->getAccessToken());

  // api->delete("/v1/chats/" + chatId + "/message/" + messageId,
  //     [=](int code, const QVariant &response) {
  //       if (code == 200) {
  //         qDebug() << "Message deleted successfully";
  //       } else {
  //         qWarning() << "Failed to delete message. Code:" << code
  //                    << "Response:" << response;
  //       }
  //     });
}
