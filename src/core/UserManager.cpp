// UserManager.cpp
#include "UserManager.h"
#include <QBuffer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <qimage.h>

#include "AuthManager.h"
#include "RestAPIManager.h"

UserManager::UserManager() {}
UserManager *UserManager::instance() {
  static UserManager instance;
  return &instance;
}
UserManager *UserManager::create(QQmlEngine *, QJSEngine *) {
  return instance();
}

void UserManager::get_me() {
  qDebug() << "Get me start";
  if (AuthManager::instance()->getAccessToken().isEmpty()) {
    qWarning() << "UserManager::get_me(): Access token is empty";
    return;
  }
  RestAPIManager *api = RestAPIManager::instance();
  api->setAuthorizationHeader(AuthManager::instance()->getAccessToken());

  api->get("/v1/users/me", [this](int code, const QVariant &response) {
    if (code == 200 && response.canConvert<QJsonDocument>()) {
      QJsonObject json = response.value<QJsonDocument>().object();

      m_currentUser.user_id = json["user_id"].toString();
      m_currentUser.username = json["username"].toString();
      m_currentUser.name = json["name"].toString();

      QUrl avatarUrl(json["avatar_url"].toString());
      QNetworkReply *reply = m_networkManager.get(QNetworkRequest(avatarUrl));
      connect(reply, &QNetworkReply::finished,
              [this, reply]() { this->handleAvatarDownload(reply); });
      qDebug() << "Get me end";
    } else {
      emit errorOccurred("Failed to load user profile");
      AuthManager::instance()->signOutUser();
    }
  });
}

void UserManager::handleAvatarDownload(QNetworkReply *reply) {
  reply->deleteLater();
  QUrl url = reply->request().url();
  QByteArray data = reply->readAll();
  if (reply->error() == QNetworkReply::NoError &&
      m_currentUser.avatar.loadFromData(data)) {
    m_avatarCache[url] = m_currentUser.avatar;
  } else if (m_avatarCache.contains(url)) {
    m_currentUser.avatar = m_avatarCache[url];
  } else {
    QImage defaultAvatar("://images/base_avatar.png");
    if (defaultAvatar.isNull()) {
      qWarning() << "Default avatar not found in resources!";
    } else {
      m_currentUser.avatar = defaultAvatar;
    }
  }
  QByteArray byteArray;
  QBuffer buffer(&byteArray);
  buffer.open(QIODevice::WriteOnly);
  m_currentUser.avatar.save(&buffer, "PNG");
  m_currentUser.setAvatarBase64(QString::fromLatin1(byteArray.toBase64()));

  qDebug() << "Profile received" << m_currentUser.username;
  emit profileReceived(m_currentUser);
}

QString UserManager::user_id() { return m_currentUser.user_id; }

QString UserManager::username() { return m_currentUser.username; }

QString UserManager::name() { return m_currentUser.name; }

QString UserManager::avatar() { return m_currentUser.avatarBase64(); }