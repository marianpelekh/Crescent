#include "RestAPIManager.h"
#include <qdebug.h>
#include <qlogging.h>
#include <qnetworkreply.h>

#include "AuthManager.h"

RestAPIManager *RestAPIManager::instance() {
  static RestAPIManager instance;
  return &instance;
}

RestAPIManager::RestAPIManager()
    : QObject(nullptr), m_manager(new QNetworkAccessManager(this)) {
  setBaseUrl("https://95.46.140.123:8031");
  // setBaseUrl("https://192.168.0.192:8031");
      // setBaseUrl("https://gi.edu.ua:8031");
  QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
  sslConfig.setProtocol(QSsl::TlsV1_2OrLater);
  sslConfig.setPeerVerifyMode(QSslSocket::VerifyNone);
  QSslConfiguration::setDefaultConfiguration(sslConfig);
}

void RestAPIManager::setAuthorizationHeader(const QString &token) {
  m_headers["Authorization"] = "Bearer " + token.toUtf8();
}

QNetworkRequest RestAPIManager::createRequest(const QString &endpoint) {
  QUrl url(m_baseUrl + endpoint);
  QNetworkRequest request(url);

  for (auto it = m_headers.constBegin(); it != m_headers.constEnd(); ++it) {
    request.setRawHeader(it.key(), it.value());
  }

  request.setSslConfiguration(QSslConfiguration::defaultConfiguration());

  return request;
}

void RestAPIManager::get(const QString &endpoint,
                         RestAPIManager::ResponseCallback callback) {
  if (!AuthManager::instance()->isAccessTokenValid()) {
    qWarning() << "Cannot make request: not authenticated";
    AuthManager::instance()->checkExistingTokens();
    return;
  }
  QNetworkRequest request = createRequest(endpoint);
  QNetworkReply *reply = m_manager->get(request);
  connect(reply, &QNetworkReply::finished, this,
          [this, reply, callback]() { handleReply(reply, callback); });
  connect(reply, &QNetworkReply::sslErrors, this,
          &RestAPIManager::handleSslErrors);
}

void RestAPIManager::post(const QString &endpoint, const QVariant &data,
                          RestAPIManager::ResponseCallback callback) {
  QNetworkRequest request = createRequest(endpoint);
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

  QByteArray payload;

  if (data.canConvert<QJsonObject>()) {
    payload = QJsonDocument(data.toJsonObject()).toJson();
  } else if (data.canConvert<QJsonDocument>()) {
    payload = data.value<QJsonDocument>().toJson();
  } else if (data.canConvert<QString>()) {
    payload = data.toString().toUtf8(); // на крайній випадок
  } else {
    qWarning() << "Unsupported data type for POST body";
  }

  QNetworkReply *reply = m_manager->post(request, payload);
  connect(reply, &QNetworkReply::finished, this,
          [this, reply, callback]() { handleReply(reply, callback); });
  connect(reply, &QNetworkReply::sslErrors, this,
          &RestAPIManager::handleSslErrors);
}

void RestAPIManager::handleReply(QNetworkReply *reply,
                                 RestAPIManager::ResponseCallback callback) {
  reply->deleteLater();
  int httpCode =
      reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

  // Зчитуємо тіло один раз
  QByteArray raw = reply->readAll();

  //   QString shortRaw = raw.left(200);
  //   qDebug() << "RestAPIManager | HTTP Code:" << httpCode
  //            << "Response:" << shortRaw;

  if (reply->error() == QNetworkReply::NoError) {
    QJsonDocument jsonDoc = QJsonDocument::fromJson(raw);
    QVariant responseVariant;
if (!jsonDoc.isNull()) {
  responseVariant = QVariant::fromValue(jsonDoc);
} else {
  responseVariant = QVariant(raw);
}

    emit requestCompleted(raw);
    callback(httpCode, responseVariant);
  } else if (reply->error() == QNetworkReply::AuthenticationRequiredError) {
    AuthManager::instance()->checkExistingTokens();
    qWarning() << "Auth error in RestAPIManager::handleReply:"
               << reply->errorString();
  } else if (reply->error() == QNetworkReply::InternalServerError) {
    // AuthManager::instance()->signOutUser();
    // AuthManager::instance()->checkExistingTokens();
    qWarning() << "Internal server error";
  } else {
    emit requestFailed(reply->errorString());
    qWarning() << "RestAPIManager::handleReply:" << reply->errorString();
  }
}

void RestAPIManager::handleSslErrors(const QList<QSslError> &errors) {
  QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
  if (!reply)
    return;

  for (const QSslError &error : errors) {
    qWarning() << error.errorString();
  }

  reply->ignoreSslErrors();
}
