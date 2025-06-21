#pragma once

#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QSslConfiguration>
#include <QUrl>
#include <qcontainerfwd.h>
#include <qtmetamacros.h>

class RestAPIManager : public QObject
{
        Q_OBJECT

        QNetworkAccessManager *m_manager;
        QString m_baseUrl;
        QMap<QByteArray, QByteArray> m_headers;

        explicit RestAPIManager();

        QNetworkRequest createRequest(const QString &endpoint);

    public:
        using ResponseCallback = std::function<void(const int httpCode, const QVariant &)>;

        void setBaseUrl(const QString &url) { m_baseUrl = url; }
        void setAuthorizationHeader(const QString &token);

        // Основні методи
        void get(const QString &endpoint, RestAPIManager::ResponseCallback callback = nullptr);
        void post(const QString &endpoint, const QVariant &data, RestAPIManager::ResponseCallback callback = nullptr);
        // void put(const QString &endpoint, const QVariant &data, replyCallback);
        // void del(const QString &endpoint, replyCallback);

        static RestAPIManager *instance();

    signals:
        void requestCompleted(const QVariant &response);
        void requestFailed(const QString &error);

    private slots:
        void handleReply(QNetworkReply *reply, RestAPIManager::ResponseCallback callback = nullptr);
        void handleSslErrors(const QList<QSslError> &errors);
};
