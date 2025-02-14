#pragma once

#include <QColor>
#include <QCoreApplication>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QObject>
#include <qqmlintegration.h>
#include <unordered_map>

class Theme : public QObject
{
        Q_OBJECT
        QML_ELEMENT

    public:
        static Theme &instance();

        Q_INVOKABLE QColor getColor(const QString &name) const;
        void loadFromFile(const QString &path);

    signals:
        void themeChanged();

    private:
        explicit Theme(QObject *parent = nullptr);
        Theme(const Theme &) = delete;
        Theme &operator=(const Theme &) = delete;

        std::unordered_map<QString, QColor> colors;
};
