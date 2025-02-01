#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <qqml.h>

#include "core/Theme.h"
#include "models/MessageModel.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    app.setOrganizationName("Crescent");
    app.setApplicationName("crescent");

    qmlRegisterSingletonInstance("Crescent.Theme", 1, 0, "Theme", &Theme::instance());
    qmlRegisterType<MessageModel>("Crescent.Models", 1, 0, "MessageModel");

    QQmlApplicationEngine engine;

    MessageModel messageModel;
    engine.rootContext()->setContextProperty("messageModel", &messageModel);

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
