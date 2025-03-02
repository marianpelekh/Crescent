#include "NetworkManager.h"
#include <qcontainerfwd.h>
#include <qnetworkrequest.h>

NetworkManager::NetworkManager(QObject *parent) : QObject(parent)
{

    connect(&m_networkAccessManager, &QNetworkAccessManager::finished, this, &NetworkManager::onRestApiFinished);

    // connect(&m_webSocket, &QWebSocket::connected, this, &NetworkManager::onWsConnected);
    // connect(&m_webSocket, &QWebSocket::textMessageReceived, this, &NetworkManager::onWsTextMessageReceived);
    // connect(&m_webSocket, &QWebSocket::disconnected, this, &NetworkManager::onWsDisconnected);
    connect(&m_networkAccessManager, &QNetworkAccessManager::sslErrors, [](QNetworkReply *reply, const QList<QSslError> &errors) {
        qWarning() << "Ignoring SSL errors:" << errors;
        reply->ignoreSslErrors();
    });
    QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
    sslConfig.setPeerVerifyMode(QSslSocket::VerifyNone); // Тільки для тестування!
    sslConfig.setProtocol(QSsl::TlsV1_2OrLater);
    m_networkAccessManager.setStrictTransportSecurityEnabled(true);
    m_networkAccessManager.setRedirectPolicy(QNetworkRequest::NoLessSafeRedirectPolicy);
}

NetworkManager::~NetworkManager()
{
    // wsClose();
}
void NetworkManager::handleSslErrors(QNetworkReply *reply, const QList<QSslError> &errors)
{
    Q_UNUSED(reply)
    QStringList errorMessages;
    for (const auto &error : errors) {
        errorMessages << error.errorString();
    }
    emit sslErrors(errorMessages.join("; "));
}
void NetworkManager::checkServerHealth(const QString &url)
{
    QNetworkRequest request(url);
    QNetworkReply *reply = m_networkAccessManager.get(request);
    connect(reply, &QNetworkReply::finished, [=]() {
        qDebug() << "Health check:" << reply->readAll();
        reply->deleteLater();
    });
}
void NetworkManager::refreshToken()
{
    QUrl url(m_baseUrl + "v1/auth/refresh");
    QJsonObject data;
    data["refresh_token"] = m_refreshToken; // Потрібно також додати це поле

    QNetworkRequest request(url);
    QNetworkReply *reply = m_networkAccessManager.post(request, QJsonDocument(data).toJson());
    reply->setProperty("requestType", "refreshToken");
}
void NetworkManager::handleError(QNetworkReply *reply, const QString &requestType)
{
    const QString errorMsg = reply->errorString();
    const int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    if (requestType == "login") {
        emit loginFailed(QString("Login error (%1): %2").arg(statusCode).arg(errorMsg));
    } else if (requestType == "fetchProfile") {
        emit profileError(QString("Profile error (%1): %2").arg(statusCode).arg(errorMsg));
    }

    emit networkError(errorMsg);
}
void NetworkManager::onRestApiFinished(QNetworkReply *reply)
{
    const QString requestType = reply->property("requestType").toString();
    const int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    const QByteArray data = reply->readAll();

    if (reply->error() != QNetworkReply::NoError || statusCode >= 400) {
        handleError(reply, requestType);
        return;
    }

    if (requestType == "login") {
        processLoginResponse(data);
    } else if (requestType == "fetchProfile") {
        processProfileResponse(data);
    } else {
        qWarning() << "Unknown request type:" << requestType;
    }
}

void NetworkManager::processLoginResponse(const QByteArray &data)
{
    QJsonParseError parseError;
    QJsonDocument json = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError || !json.isObject()) {
        emit loginFailed("Invalid JSON response");
        return;
    }

    const QJsonObject tokens = json.object()["tokens"].toObject();
    if (tokens.isEmpty()) {
        emit loginFailed("Missing tokens in response");
        return;
    }

    m_accessToken = tokens["access"].toString();
    m_refreshToken = tokens["refresh"].toString();
    emit loginSuccess(m_accessToken);
}
void NetworkManager::processProfileResponse(const QByteArray &data)
{
    QJsonDocument json = QJsonDocument::fromJson(data);
    emit profileReceived(json["username"].toString(), json["avatar_url"].toString());
}
void NetworkManager::loginUser(const QString &username, const QString &password)
{
    QUrl url(m_baseUrl + "v1/auth/login");
    QJsonObject data;
    data["username"] = username;
    data["password"] = password;

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = m_networkAccessManager.post(request, QJsonDocument(data).toJson());
    reply->setProperty("requestType", "login"); // Позначка для ідентифікації
}

void NetworkManager::fetchUserProfile()
{
    QUrl url(m_baseUrl + "v1/users/me");
    QNetworkRequest request(url);
    request.setRawHeader("Authorization", "Bearer " + m_accessToken.toUtf8());

    QNetworkReply *reply = m_networkAccessManager.get(request);
    reply->setProperty("requestType", "fetchProfile");
}
void NetworkManager::updateAvatar(const QString &imagePath)
{
    // TODO: Реалізуйте логіку оновлення аватара
    qWarning() << "Avatar update not implemented yet. Path:" << imagePath;
    emit avatarUpdated();
}
/*
void NetworkManager::wsConnect()
{
    QString wsUrl = m_baseUrl;

    wsUrl.replace("https://", "wss://");

    wsUrl += "ws";

    QUrl url(wsUrl);
    if (m_webSocket.state() == QAbstractSocket::ConnectedState) {
        m_webSocket.close();
    }
    m_webSocket.open(url);
}
void NetworkManager::wsSendMessage(const QString &message)
{
    if (m_webSocket.state() == QAbstractSocket::ConnectedState) {
        m_webSocket.sendTextMessage(message);
    }
}

void NetworkManager::wsClose()
{
    if (m_webSocket.state() == QAbstractSocket::ConnectedState) {
        m_webSocket.close();
    }
}

void NetworkManager::onWsConnected() { emit wsConnected(); }

void NetworkManager::onWsTextMessageReceived(const QString &message) { emit wsMessageReceived(message); }

void NetworkManager::onWsDisconnected() { emit wsDisconnected(); }*/
