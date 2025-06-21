#pragma once
#include <QDateTime>
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QVariant>
#include <QtQmlIntegration>


class AuthManager : public QObject
{
        Q_OBJECT
        QML_ELEMENT
        QML_SINGLETON

        QString m_access_token;
        QString m_refresh_token;
        bool m_access_saved;
        bool m_refresh_saved;
        bool m_isCheckingTokens;

        explicit AuthManager(QObject *parent = nullptr);

        QJsonObject parseJwt(const QString &token) const;
        void deleteSavedTokens();
        void loadTokens();
        void validateTokens();
        void refreshToken();
        
        private slots:
        void handleSignInResponse(int httpCode, const QVariant &response);
        void handleSignUpResponse(int httpCode, const QVariant &response);
        void handleRefreshResponse(int httpCode, const QVariant &response);
        void saveTokens(const QString &access, const QString &refresh);
        void handleError(const QVariant &error);
        
        public:
        bool isAccessTokenValid() const;
        static AuthManager *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
        static AuthManager *instance();
        QString getAccessToken() const;
        Q_INVOKABLE void checkExistingTokens();

    public slots:
        void signInUser(const QString &login, const QString &password);
        void signUpUser(const QString &email, const QString &username, const QString &name, const QString &password);
        void signOutUser();

    signals:
        void userAuthenticated();
        void userDeaunthenticated();
        void authError(const QString &errorMsg);
};
