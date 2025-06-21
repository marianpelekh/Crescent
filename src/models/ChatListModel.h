#pragma once

#include <QAbstractListModel>
#include <QtQmlIntegration>
#include <qobject.h>
#include <qscopedpointer.h>

#include "ChatModel.h"

class ChatListModel : public QAbstractListModel {
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
  enum ChatRoles {
    IdRole = Qt::UserRole + 1,
    TypeRole,
    NameRole,
    DescriptionRole,
    ImageURLRole,
    CreatedAtRole
  };

  explicit ChatListModel(QObject *parent = nullptr);

  Q_INVOKABLE void clearSearch();
  int rowCount(const QModelIndex &parent = QModelIndex()) const override;
  int count() const;
  int searchCount() const;
  void setSearch(const bool &search);
  QVariant data(const QModelIndex &index, int role) const override;
  QHash<int, QByteArray> roleNames() const override;

public slots:
  void loadChats();
  void searchChats(const QString &name);
signals:
  void countChanged();

private:
  QVector<QSharedPointer<Chat>> m_chats;
  QVector<QSharedPointer<Chat>> m_searched_chats;
  bool m_searchActive = false;
};
