#include "Theme.h"

Theme &Theme::instance() {
  static Theme instance;
  return instance;
}

Theme::Theme(QObject *parent) : QObject(parent) {
  loadFromFile(":/themes/ice.json");
}

void Theme::loadFromFile(const QString &path) {
  if (path.isEmpty()) {
    qWarning("Empty theme path");
    return;
  }

  QFile file(path);
  if (!file.open(QIODevice::ReadOnly)) {
    qWarning("Could not open theme file.");
    return;
  }

  QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
  file.close();

  if (!doc.isObject()) {
    qWarning("Incorrect format of JSON theme.");
    return;
  }

  QJsonObject json = doc.object();
  colors.clear();
  for (auto it = json.begin(); it != json.end(); ++it) {
    if (it.value().isString()) {
      colors[it.key()] = QColor(it.value().toString());
    }
  }

  qDebug() << "Theme loaded " << path;

  if (!colors.empty()) {
    emit themeChanged();
  }
}

QColor Theme::getColor(const QString &name) const {
  auto it = colors.find(name);
  return (it != colors.end()) ? it->second : QColor();
}

QVariantMap Theme::palette() const {
  QVariantMap map;
  for (const auto &pair : colors) {
    map.insert(pair.first, pair.second);
  }
  return map;
}

static const QMap<QString, QString> themeMap = {
    {"Dark", ":/themes/dark.json"},
    {"Light", ":/themes/light.json"},
    {"Ice", ":/themes/ice.json"},
    {"Paper", ":/themes/paper.json"},
    {"Acid", ":/themes/acid.json"}};

QStringList Theme::availableThemes() {
  return themeMap.keys();
}

void Theme::loadNamedTheme(const QString &name) {
  if (themeMap.contains(name)) {
    loadFromFile(themeMap.value(name));
  } else {
    qWarning() << "Theme not found:" << name;
    loadFromFile(":/themes/ice.json");
  }
}
