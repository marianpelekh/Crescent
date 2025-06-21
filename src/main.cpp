#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <qcontainerfwd.h>
#include <qqml.h>

#include "core/AuthManager.h"
#include "core/RestAPIManager.h"
#include "core/UserManager.h"
#include "models/ChatListModel.h"
// #include "models/MessageModel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    auto api = RestAPIManager::instance();
    // api->setBaseUrl("https://192.168.0.192:8031");
    api->setBaseUrl("https://95.46.140.123:8031");
    // api->setBaseUrl("https://gi.edu.ua:8031");
    api->get("/ready", [](const int &httpCode, const QVariant &response) { qDebug().noquote() << response.toString(); });

    auto authman = AuthManager::instance();

    app.setOrganizationName("Crescent");
    app.setApplicationName("crescent");

    // qmlRegisterSingletonInstance("Crescent.Theme", 1, 0, "Theme", &Theme::instance());
    // qmlRegisterType<MessageModel>("Crescent.Models", 127.0.0.11, 0, "MessageModel");

    QQmlApplicationEngine engine;
    QTcpSocket socket;
    // socket.connectToHost("192.168.0.192", 8031);
    socket.connectToHost("95.46.140.123", 8031);
    // socket.connectToHost("gi.edu.ua", 8031);

    if (!socket.waitForConnected(3000)) {
        qDebug() << "Server connection failed:" << socket.errorString();
    } else {
        qDebug() << "Connected to server successfully";
    }
    qDebug() << "SSL supported:" << QSslSocket::supportsSsl() << "\nSSL version:" << QSslSocket::sslLibraryVersionString();
    const QUrl url(QStringLiteral("qrc:/Crescent/Main/main.qml"));

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
