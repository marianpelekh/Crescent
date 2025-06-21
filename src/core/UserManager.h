#include <QImage>
#include <QNetworkAccessManager>
#include <QQmlEngine>
#include <QtQmlIntegration>
#include <qcontainerfwd.h>
#include <qobject.h>
#include <qtmetamacros.h>

struct user_t {
    QString user_id;
  QString username;
  QString name;
  // std::string surname;
  QImage avatar;

  QString avatarBase64() const { return m_avatarBase64; }
  void setAvatarBase64(const QString &b64) { m_avatarBase64 = b64; }

private:
  Q_GADGET
  Q_PROPERTY(QString user_id MEMBER user_id)
  Q_PROPERTY(QString username MEMBER username)
  Q_PROPERTY(QString name MEMBER name)
  Q_PROPERTY(QString avatarBase64 READ avatarBase64 NOTIFY profileReceived)
  QString m_avatarBase64;
};
class UserManager : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON
  explicit UserManager();

public:
  static UserManager *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
  static UserManager *instance();
  Q_INVOKABLE void get_me();
  Q_INVOKABLE QString username();
  Q_INVOKABLE QString avatar();
  Q_INVOKABLE QString name();
  Q_INVOKABLE QString user_id();
signals:
  user_t profileReceived(const user_t &user);
  void errorOccurred(const QString &error);
private slots:
  void handleAvatarDownload(QNetworkReply *reply);

private:
  user_t m_currentUser;
  QNetworkAccessManager m_networkManager;
  QMap<QUrl, QImage> m_avatarCache;
};
