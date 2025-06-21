#include "ChatManager.h"
#include "AuthManager.h"
#include "RestAPIManager.h"
#include <qjsondocument.h>
#include <qlogging.h>
#include <qvariant.h>

ChatManager::ChatManager() {}
ChatManager *ChatManager::instance() {
  static ChatManager instance;
  return &instance;
}
ChatManager *ChatManager::create(QQmlEngine *, QJSEngine *) {
  return instance();
}
void ChatManager::createChat(const QString &target_user_id) {
    qDebug() << "Creating new chat";
    if (AuthManager::instance()->getAccessToken().isEmpty()) {
        qWarning() << "ChatManager::createPrivateChat: Access token is empty";
        return;
    }
    RestAPIManager *api = RestAPIManager::instance();
    api->setAuthorizationHeader(AuthManager::instance()->getAccessToken());
    QJsonObject body;
    body["target_user_id"] = target_user_id;
    api->post("/v1/chats/new", body, [this](int code, const QVariant &response){
        if (code == 200 && response.canConvert<QJsonDocument>()) {
        QJsonObject json = response.value<QJsonDocument>().object();

        emit chatCreated(json["chat_id"].toString());
        } else {
            emit chatCreationFailed();
            qWarning() << "Failed to send message. Code:" << code
                     << "Response:" << response;
        }
    });
}

void ChatManager:: deleteChat(const QString &chat_id){};