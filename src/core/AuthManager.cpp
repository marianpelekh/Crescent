#include "AuthManager.h"
#include <QCborValue>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <qt6keychain/keychain.h>

#include "core/RestAPIManager.h"

static const char SERVICE_NAME[] = "app.crescent.com";

AuthManager::AuthManager(QObject *parent) : QObject(parent) {
  QTimer::singleShot(0, this, &AuthManager::checkExistingTokens);
}

AuthManager *AuthManager::instance() {
  static AuthManager instance;
  return &instance;
}

AuthManager *AuthManager::create(QQmlEngine *, QJSEngine *) {
  return instance();
}

// ================= JWT VALIDATION =================
QJsonObject AuthManager::parseJwt(const QString &token) const {
  
  QStringList parts = token.split('.');
  if (parts.size() != 3)
    return QJsonObject();

  QByteArray payload = QByteArray::fromBase64(
      parts[1].toUtf8(),
      QByteArray::Base64UrlEncoding | QByteArray::OmitTrailingEquals);
  return QJsonDocument::fromJson(payload).object();
}

bool AuthManager::isAccessTokenValid() const {
  if (m_access_token.isEmpty())
    return false;

  QJsonObject payload = parseJwt(m_access_token);
  qint64 exp = payload["exp"].toVariant().toLongLong();
  qint64 current = QDateTime::currentSecsSinceEpoch();

  return (exp > current + 30);
}

// ================= TOKEN MANAGEMENT =================
// void AuthManager::checkExistingTokens() {
//   try {
//     qDebug() << "Checking existing tokens";
//     // Read access token
//     auto *readAccess = new QKeychain::ReadPasswordJob(SERVICE_NAME, this);
//     readAccess->setKey("access_token");
//     connect(readAccess, &QKeychain::Job::finished, this,
//             [this](QKeychain::Job *job) {
//               if (!job->error()) {
//                 m_access_token =
//                     qobject_cast<QKeychain::ReadPasswordJob
//                     *>(job)->textData();

//                 // Read refresh token
//                 auto *readRefresh =
//                     new QKeychain::ReadPasswordJob(SERVICE_NAME, this);
//                 readRefresh->setKey("refresh_token");
//                 connect(readRefresh, &QKeychain::Job::finished, this,
//                         [this](QKeychain::Job *job) {
//                           if (!job->error()) {
//                             m_refresh_token =
//                                 qobject_cast<QKeychain::ReadPasswordJob
//                                 *>(job)
//                                     ->textData();
//                             validateTokens();
//                           } else {
//                             qWarning() << "Failed to read refresh token:"
//                                        << job->errorString();
//                             m_refresh_token.clear(); // Важливо очистити
//                             deleteSavedTokens();
//                           }
//                         });
//                 readRefresh->start();
//               } else {
//                 qWarning() << "Failed to read access token:"
//                            << job->errorString();
//                 emit authError(tr("No saved session"));
//                 emit userDeaunthenticated();
//                 return;
//               }
//             });
//     readAccess->start();
//   } catch (std::exception &e) {
//     qDebug() << "Error checking tokens";
//     signOutUser();
//   }
// }



// void AuthManager::checkExistingTokens() {
//   if (m_isCheckingTokens)
//     return; // Уникнення рекурсії
//   m_isCheckingTokens = true;
//   qDebug() << "Checking existing tokens";

//   // Спочатку намагаємося зчитати access_token
//   auto *readAccess = new QKeychain::ReadPasswordJob(SERVICE_NAME, this);
//   readAccess->setKey("access_token");
//   connect(
//       readAccess, &QKeychain::Job::finished, this, [this](QKeychain::Job *job) {
//         if (!job->error()) {
//           m_access_token =
//               qobject_cast<QKeychain::ReadPasswordJob *>(job)->textData();
//         } else {
//           qWarning() << "No access token, will try refresh token:"
//                      << job->errorString();
//           m_access_token.clear();
//         }

//         // Потім читаємо refresh_token незалежно від результату access
//         auto *readRefresh = new QKeychain::ReadPasswordJob(SERVICE_NAME, this);
//         readRefresh->setKey("refresh_token");
//         connect(readRefresh, &QKeychain::Job::finished, this,
//                 [this](QKeychain::Job *job2) {
//                   if (!job2->error()) {
//                     m_refresh_token =
//                         qobject_cast<QKeychain::ReadPasswordJob *>(job2)
//                             ->textData();
//                     // Далі перевіряємо токени: якщо access валідний — emit,
//                     // якщо ні, але є refresh — refreshToken(), інакше — чистимо
//                     // та deauth
//                     validateTokens();
//                   } else {
//                     qWarning() << "Failed to read refresh token:"
//                                << job2->errorString();
//                     m_refresh_token.clear();
//                     // Якщо навіть refresh немає — завершуємо сесію
//                     // emit authError(tr("No valid session"));
//                     emit userDeaunthenticated();
//                     if (m_refresh_token.isEmpty() || !isAccessTokenValid()) {
//                       deleteSavedTokens();
//                     }
//                   }
//                   m_isCheckingTokens = false;
//                 });
//         readRefresh->start();
//       });
//   readAccess->start();
// }
void AuthManager::checkExistingTokens() {
  if (m_isCheckingTokens)
    return;
  m_isCheckingTokens = true;
  qDebug() << "Checking existing tokens";

  auto *readAccess = new QKeychain::ReadPasswordJob(SERVICE_NAME, this);
  readAccess->setKey("access_token");
  connect(readAccess, &QKeychain::Job::finished, this, [this](QKeychain::Job *job) {
    if (!job->error()) {
      m_access_token = qobject_cast<QKeychain::ReadPasswordJob *>(job)->textData();
    } else {
      m_access_token.clear();
    }

    auto *readRefresh = new QKeychain::ReadPasswordJob(SERVICE_NAME, this);
    readRefresh->setKey("refresh_token");
    connect(readRefresh, &QKeychain::Job::finished, this, [this](QKeychain::Job *job2) {
      if (!job2->error()) {
        m_refresh_token = qobject_cast<QKeychain::ReadPasswordJob *>(job2)->textData();
      } else {
        m_refresh_token.clear();
      }
      validateTokens(); // Validate after both tokens are read
      m_isCheckingTokens = false;
    });
    readRefresh->start();
  });
  readAccess->start();
}
void AuthManager::validateTokens() {
  if (isAccessTokenValid()) {
    qDebug() << "Access token is valid";
    emit userAuthenticated();
    return;
  }

  if (!m_refresh_token.isEmpty()) {
    qDebug() << "Starting token refresh...";
    refreshToken();
  } else {
    qWarning() << "No refresh token available";
    // deleteSavedTokens();
    emit userDeaunthenticated();
  }
}

void AuthManager::refreshToken() {
  RestAPIManager *api = RestAPIManager::instance();
  QJsonObject data{{"refresh_token", m_refresh_token}};

  qDebug() << "Sending refresh token:" << m_refresh_token;
  api->post(
      "/v1/auth/refresh", QJsonDocument(data).toJson(),
      [this](int httpCode, const QVariant &response) {
        qDebug() << "Refresh response. HTTP code:" << httpCode
                 << "Body:" << response;
        if (httpCode == 200 && response.canConvert<QJsonDocument>()) {
          QJsonObject tokens =
              response.value<QJsonDocument>().object()["tokens"].toObject();
          saveTokens(tokens["access"].toString(), tokens["refresh"].toString());
          RestAPIManager::instance()->setAuthorizationHeader(
              tokens["access"].toString());
          emit userAuthenticated();
        } else {
          qWarning() << "Refresh failed. Deleting tokens.";
          deleteSavedTokens();
          emit authError(tr("Session expired. Please login again"));
        }
      });
}

void AuthManager::deleteSavedTokens() {
  auto *deleteAccess = new QKeychain::DeletePasswordJob(SERVICE_NAME, this);
  deleteAccess->setKey("access_token");

  auto *deleteRefresh = new QKeychain::DeletePasswordJob(SERVICE_NAME, this);
  deleteRefresh->setKey("refresh_token");

  // Чекаємо завершення обох операцій
  QEventLoop loop;
  connect(deleteAccess, &QKeychain::Job::finished, &loop, &QEventLoop::quit);
  connect(deleteRefresh, &QKeychain::Job::finished, &loop, &QEventLoop::quit);
  deleteAccess->start();
  deleteRefresh->start();
  loop.exec();

  m_access_token.clear();
  m_refresh_token.clear();
  RestAPIManager::instance()->setAuthorizationHeader("");
  qDebug() << "Tokens are deleted";
}

QString AuthManager::getAccessToken() const { return m_access_token; }

// ================= AUTH ACTIONS =================
void AuthManager::signInUser(const QString &login, const QString &password) {
  RestAPIManager *api = RestAPIManager::instance();
  QJsonObject data{{"login", login}, {"password", password}};

  api->post("/v1/auth/login", QJsonDocument(data).toJson(),
            [this](int httpCode, const QVariant &response) {
              handleSignInResponse(httpCode, response);
            });
}

void AuthManager::signUpUser(const QString &email, const QString &username,
                             const QString &name, const QString &password) {
  RestAPIManager *api = RestAPIManager::instance();
  QJsonObject data{{"email", email},
                   {"username", username},
                   {"name", name},
                   {"password", password}};

  api->post("/v1/auth/register", QJsonDocument(data).toJson(),
            [this](int httpCode, const QVariant &response) {
              handleSignUpResponse(httpCode, response);
            });
}

void AuthManager::signOutUser() {
  qDebug() << "User signed out";
  emit userDeaunthenticated();
  deleteSavedTokens();
}

// ================= RESPONSE HANDLERS =================
void AuthManager::handleSignInResponse(int httpCode, const QVariant &response) {
  qDebug() << "HTTP Code:" << httpCode << "Response:" << response;

  if (httpCode == 200 && response.canConvert<QJsonDocument>()) {
    QJsonObject root = response.value<QJsonDocument>().object();
    if (root.contains("tokens")) {
      QJsonObject tokens = root["tokens"].toObject();
      if (tokens.contains("access") && tokens.contains("refresh")) {
        saveTokens(tokens["access"].toString(), tokens["refresh"].toString());
        emit userAuthenticated();
        return;
      }
    }
    qCritical() << "Invalid tokens format in response";
    handleError("Invalid server response");
  } else {
    handleError(httpCode);
  }
}

void AuthManager::handleSignUpResponse(int httpCode, const QVariant &response) {
  if (httpCode == 200) {
    if (response.canConvert<QJsonDocument>()) {
      QJsonObject tokens =
          response.value<QJsonDocument>().object()["tokens"].toObject();
      saveTokens(tokens["access"].toString(), tokens["refresh"].toString());
      RestAPIManager::instance()->setAuthorizationHeader(m_access_token);
      emit userAuthenticated();
    } else {
      qDebug() << response;
      handleError("Server response error");
    }
  } else {
    handleError(QString("Sign up error: %1").arg(httpCode));
  }
}

void AuthManager::handleRefreshResponse(int httpCode,
                                        const QVariant &response) {}

void AuthManager::saveTokens(const QString &accessToken,
                             const QString &refreshToken) {
  m_access_token = accessToken;
  m_refresh_token = refreshToken;

  // Save access token
  auto *writeAccess = new QKeychain::WritePasswordJob(SERVICE_NAME, this);
  writeAccess->setKey("access_token");
  writeAccess->setTextData(accessToken);
  writeAccess->start();

  connect(writeAccess, &QKeychain::Job::finished, this,
          [this](QKeychain::Job *job) {
            if (job->error()) {
              qCritical() << "Failed to save access token:"
                          << job->errorString();
            }
          });

  // Save refresh token
  auto *writeRefresh = new QKeychain::WritePasswordJob(SERVICE_NAME, this);
  writeRefresh->setKey("refresh_token");
  writeRefresh->setTextData(refreshToken);
  writeRefresh->start();

  connect(writeRefresh, &QKeychain::Job::finished, this,
          [this](QKeychain::Job *job) {
            if (job->error()) {
              qCritical() << "Failed to save refresh token:"
                          << job->errorString();
            }
          });
}

void AuthManager::handleError(const QVariant &error) {
  QString errorMsg;
  int httpCode = 0;
  bool isHttpCode = false;

  if (error.canConvert<int>()) {
    httpCode = error.toInt();
    isHttpCode = true;
    errorMsg = QString::number(httpCode);
  } else if (error.canConvert<QJsonDocument>()) {
    QJsonObject json = error.value<QJsonDocument>().object();
    errorMsg = json["message"].toString(tr("Unknown error"));
  } else {
    errorMsg = error.toString();
  }

  qWarning() << "Auth error:" << errorMsg;

  // Delete tokens only on authentication-related errors
  if (isHttpCode && (httpCode == 401 || httpCode == 403)) {
    deleteSavedTokens();
  }

  emit authError(errorMsg);
}
