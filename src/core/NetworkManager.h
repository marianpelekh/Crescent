#pragma once

#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QWebSocket>

class NetworkManager : public QObject
{
        Q_OBJECT
    public:
        explicit NetworkManager(QObject *parent = nullptr);
        ~NetworkManager();
        void handleSslErrors(QNetworkReply *reply, const QList<QSslError> &errors);
        void checkServerHealth(const QString &url);
        void processLoginResponse(const QByteArray &data);
        void processProfileResponse(const QByteArray &data);

        // RestApi
        Q_INVOKABLE void loginUser(const QString &username, const QString &password);
        Q_INVOKABLE void fetchUserProfile();
        Q_INVOKABLE void updateAvatar(const QString &imagePath);
        Q_INVOKABLE void refreshToken();
        // WebSockets
        void wsConnect();
        void wsSendMessage(const QString &message);
        void wsClose();
    signals:
        void restApiResponseReceived(int statusCode, const QJsonObject &response);
        void loginSuccess(const QString &token);
        void loginFailed(const QString &error);
        void profileReceived(const QString &username, const QString &avatarUrl);
        void profileError(const QString &reason);
        void avatarUpdated();

        // void wsMessageReceived(const QString &message);
        // void wsConnected();
        // void wsDisconnected();
        void networkError(const QString &errorDescription);
        void sslErrors(const QString &errorDescription);

    private slots:
        // RestApi
        void onRestApiFinished(QNetworkReply *reply);
        // WebSocket
        // void onWsConnected();
        // void onWsTextMessageReceived(const QString &message);
        // void onWsDisconnected();

    private:
        void handleError(QNetworkReply *reply, const QString &requestType);
        QNetworkAccessManager m_networkAccessManager;
        QWebSocket m_webSocket;
        QString m_accessToken;
        QString m_refreshToken;
        const QString m_baseUrl = "https://192.168.0.192:9080/";
};
