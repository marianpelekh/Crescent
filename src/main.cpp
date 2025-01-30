#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <qqml.h>


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    app.setOrganizationName("Crescent");
    app.setApplicationName("crescent");

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/Qml/main.qml"));

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
