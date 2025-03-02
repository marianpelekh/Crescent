#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <qcontainerfwd.h>
#include <qqml.h>

// #include "core/LoginUser.h"
#include "core/NetworkManager.h"
#include "core/Theme.h"
#include "models/MessageModel.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    app.setOrganizationName("Crescent");
    app.setApplicationName("crescent");

    qmlRegisterSingletonInstance("Crescent.Theme", 1, 0, "Theme", &Theme::instance());
    qmlRegisterType<MessageModel>("Crescent.Models", 1, 0, "MessageModel");

    NetworkManager networkManager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("messageModel", new MessageModel());
    engine.rootContext()->setContextProperty("networkManager", &networkManager);

    QTcpSocket socket;
    socket.connectToHost("192.168.0.192", 9080);
    if (!socket.waitForConnected(3000)) {
        qDebug() << "Server connection failed:" << socket.errorString();
    } else {
        qDebug() << "Connected to server successfully";
    }
    qDebug() << "SSL supported:" << QSslSocket::supportsSsl() << "\nSSL version:" << QSslSocket::sslLibraryVersionString();
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));

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
