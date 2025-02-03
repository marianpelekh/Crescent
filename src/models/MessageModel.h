#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QVariant>

struct Message
{
        QString sender;
        QString text;
};

class MessageModel : public QAbstractListModel
{
        Q_OBJECT
        Q_PROPERTY(QString chatId READ chatId WRITE setChatId NOTIFY chatIdChanged)

    public:
        enum Role : int {
            SenderRole = Qt::UserRole + 1,
            TextRole
        };

        explicit MessageModel(QObject *parent = nullptr);

        Q_INVOKABLE void addMessage(const QString &sender, const QString &text);
        void loadMessagesForChat(const QString &chatId);

        int rowCount(const QModelIndex &parent = QModelIndex()) const override;
        QVariant data(const QModelIndex &index, int role) const override;
        QHash<int, QByteArray> roleNames() const override;

        QString chatId() const;
        void setChatId(const QString &id);

    signals:
        void chatIdChanged();

    private:
        QHash<QString, QList<Message>> m_chatMessages;
        QList<Message> m_messages;
        QString m_chatId;
};
