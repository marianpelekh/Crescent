#include "Theme.h"

Theme &Theme::instance()
{
    static Theme instance;
    return instance;
}

Theme::Theme(QObject *parent) : QObject(parent) { loadFromFile("themes/default.json"); }

void Theme::loadFromFile(const QString &path)
{
    QString absolutePath = QCoreApplication::applicationDirPath() + "/" + path;
    QFile file(absolutePath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning("Could not open theme file.");
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    if (!doc.isObject()) {
        qWarning("Uncorrect format of JSON theme.");
        return;
    }

    QJsonObject json = doc.object();
    for (auto it = json.begin(); it != json.end(); ++it) {
        if (it.value().isString()) {
            colors[it.key()] = QColor(it.value().toString());
        }
    }

    emit themeChanged();
}

QColor Theme::getColor(const QString &name) const
{
    auto it = colors.find(name);
    return (it != colors.end()) ? it->second : QColor();
}
