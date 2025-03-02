#include "MessageModel.h"

MessageModel::MessageModel(QObject *parent) : QAbstractListModel(parent) {}

void MessageModel::addMessage(const QString &sender, const QString &text)
{
    if (m_chatId.isEmpty())
        return;

    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_messages.append({sender, text});
    m_chatMessages[m_chatId] = m_messages;
    endInsertRows();
}
// void MessageModel::loadMessagesForChat(const QString &chatId)
// {
//     beginResetModel();
//     m_messages = m_chatMessages.value(chatId, {}); // Завантажуємо історію чату
//     m_chatId = chatId;
//     endResetModel();
// }
void MessageModel::loadMessagesForChat(const QString &chatId)
{
    beginResetModel();
    m_messages.clear();

    // write a real one function when server will give responses
    if (chatId == "1") {
        m_messages.emplace_back(Message{"Harry", "Hi!"});
        m_messages.emplace_back(Message{"You", "Hey there!"});
        m_messages.emplace_back(Message{"Harry", "What r you doin'?"});
    } else if (chatId == "2") {
        m_messages.emplace_back(Message{"Tom", "How's it going?"});
        m_messages.emplace_back(Message{"You", "All good, you?"});
    }

    endResetModel();
}

int MessageModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_messages.count();
}

QVariant MessageModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_messages.count())
        return QVariant();

    const Message &message = m_messages[index.row()];
    switch (role) {
    case SenderRole:
        return message.sender;
    case TextRole:
        return message.text;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> MessageModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[SenderRole] = "sender";
    roles[TextRole] = "text";
    return roles;
}

QString MessageModel::chatId() const { return m_chatId; }

void MessageModel::setChatId(const QString &id)
{
    if (m_chatId == id)
        return;

    m_chatId = id;
    emit chatIdChanged();
    loadMessagesForChat(m_chatId);
}
