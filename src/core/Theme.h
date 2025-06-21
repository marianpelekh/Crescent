#pragma once

#include <QColor>
#include <QCoreApplication>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QObject>
#include <QVariantMap>
#include <qqmlintegration.h>
#include <unordered_map>

class Theme : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

  Q_PROPERTY(QVariantMap palette READ palette NOTIFY themeChanged)

public:
  static Theme &instance();

  explicit Theme(QObject *parent = nullptr);

  Q_INVOKABLE QColor getColor(const QString &name) const;
  Q_INVOKABLE QStringList availableThemes();
  Q_INVOKABLE void loadNamedTheme(const QString &name);

  QVariantMap palette() const;

  void loadFromFile(const QString &path);

signals:
  void themeChanged();

private:
  Theme(const Theme &) = delete;
  Theme &operator=(const Theme &) = delete;

  std::unordered_map<QString, QColor> colors;
};
