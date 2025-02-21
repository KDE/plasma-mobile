// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "favouritesmodel.h"
#include "homescreenstate.h"

#include <QByteArray>
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QModelIndex>
#include <QProcess>
#include <QQuickWindow>

#include <KApplicationTrader>
#include <KConfigGroup>
#include <KIO/ApplicationLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KService>
#include <KSharedConfig>
#include <KSycoca>

FavouritesModel::FavouritesModel(HomeScreen *parent)
    : QAbstractListModel{parent}
    , m_homeScreen{parent}
{
}

int FavouritesModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_delegates.count();
}

QVariant FavouritesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_delegates.size()) {
        return QVariant();
    }

    switch (role) {
    case DelegateRole:
        return QVariant::fromValue(m_delegates.at(index.row()).delegate.get());
    }

    return QVariant();
}

QHash<int, QByteArray> FavouritesModel::roleNames() const
{
    return {{DelegateRole, "delegate"}};
}

void FavouritesModel::removeEntry(int row)
{
    if (row < 0 || row >= m_delegates.size()) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);
    // HACK: do not deleteLater(), because the delegate might still be used somewhere else
    // m_delegates[row].delegate->deleteLater();
    m_delegates.removeAt(row);
    endRemoveRows();

    save();
}

void FavouritesModel::moveEntry(int fromRow, int toRow)
{
    if (fromRow < 0 || toRow < 0 || fromRow >= m_delegates.size() || toRow >= m_delegates.size() || fromRow == toRow) {
        return;
    }
    if (toRow > fromRow) {
        ++toRow;
    }

    beginMoveRows(QModelIndex(), fromRow, fromRow, QModelIndex(), toRow);
    if (toRow > fromRow) {
        auto delegate = m_delegates.at(fromRow);
        m_delegates.insert(toRow, delegate);
        m_delegates.takeAt(fromRow);

    } else {
        auto delegate = m_delegates.takeAt(fromRow);
        m_delegates.insert(toRow, delegate);
    }
    endMoveRows();

    save();
}

bool FavouritesModel::canAddEntry(int row, FolioDelegate::Ptr delegate)
{
    if (!delegate) {
        return false;
    }

    if (row < 0 || row > m_delegates.size()) {
        return false;
    }

    return true;
}

bool FavouritesModel::addEntry(int row, FolioDelegate::Ptr delegate)
{
    if (!canAddEntry(row, delegate)) {
        return false;
    }

    if (row == m_delegates.size()) {
        beginInsertRows(QModelIndex(), row, row);
        m_delegates.append({delegate, 0});
        endInsertRows();
    } else if (m_delegates[row].delegate->type() == FolioDelegate::None) {
        replaceGhostEntry(delegate);
    } else {
        beginInsertRows(QModelIndex(), row, row);
        m_delegates.insert(row, {delegate, 0});
        endInsertRows();
    }

    // ensure saves are connected when requested by the delegate
    connectSaveRequests(delegate);

    save();

    return true;
}

FolioDelegate::Ptr FavouritesModel::getEntryAt(int row)
{
    if (row < 0 || row >= m_delegates.size()) {
        return nullptr;
    }

    return m_delegates[row].delegate;
}

bool FavouritesModel::isFull() const
{
    auto homeScreenState = m_homeScreen->homeScreenState();
    bool isLocationBottom = homeScreenState->favouritesBarLocation() == HomeScreenState::Bottom;

    // we should not include the ghost entry in the delegate count
    int count = 0;
    for (const auto &delegate : m_delegates) {
        if (delegate.delegate->type() == FolioDelegate::None) {
            continue;
        }
        ++count;
    }

    if (isLocationBottom) {
        return count >= homeScreenState->pageColumns();
    } else {
        return count >= homeScreenState->pageRows();
    }
}

int FavouritesModel::getGhostEntryPosition()
{
    for (int i = 0; i < m_delegates.size(); i++) {
        if (m_delegates[i].delegate->type() == FolioDelegate::None) {
            return i;
        }
    }
    return -1;
}

void FavouritesModel::setGhostEntry(int row)
{
    bool found = false;

    // check if a ghost entry already exists, then swap them
    for (int i = 0; i < m_delegates.size(); i++) {
        if (m_delegates[i].delegate->type() == FolioDelegate::None) {
            found = true;

            if (row != i) {
                moveEntry(i, row);
            }
        }
    }

    // if it doesn't, add a new empty delegate
    if (!found) {
        FolioDelegate::Ptr ghost = std::make_shared<FolioDelegate>(m_homeScreen);
        addEntry(row, ghost);
    }
}

void FavouritesModel::replaceGhostEntry(FolioDelegate::Ptr delegate)
{
    for (int i = 0; i < m_delegates.size(); i++) {
        if (m_delegates[i].delegate->type() == FolioDelegate::None) {
            m_delegates[i].delegate->deleteLater();
            m_delegates[i].delegate = delegate;

            Q_EMIT dataChanged(createIndex(i, 0), createIndex(i, 0), {DelegateRole});
            break;
        }
    }
}

void FavouritesModel::deleteGhostEntry()
{
    for (int i = 0; i < m_delegates.size(); i++) {
        if (m_delegates[i].delegate->type() == FolioDelegate::None) {
            auto ghostEntry = m_delegates[i].delegate;
            removeEntry(i);

            // ensure ghost entry is deleted
            ghostEntry->deleteLater();
        }
    }
}

QJsonArray FavouritesModel::exportToJson()
{
    QJsonArray arr;
    for (int i = 0; i < m_delegates.size(); i++) {
        FolioDelegate::Ptr delegate = m_delegates[i].delegate;

        // if this delegate is empty, ignore it
        if (!delegate || delegate->type() == FolioDelegate::None) {
            continue;
        }

        arr.append(delegate->toJson());
    }
    return arr;
}

void FavouritesModel::save()
{
    if (!m_homeScreen) {
        return;
    }

    QJsonArray arr = exportToJson();
    QByteArray data = QJsonDocument(arr).toJson(QJsonDocument::Compact);

    m_homeScreen->config().writeEntry("Favourites", QString::fromStdString(data.toStdString()));
    Q_EMIT m_homeScreen->configNeedsSaving();
}

void FavouritesModel::load()
{
    if (!m_homeScreen) {
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(m_homeScreen->config().readEntry("Favourites", "{}").toUtf8());
    loadFromJson(doc.array());
}

void FavouritesModel::loadFromJson(QJsonArray arr)
{
    beginResetModel();

    m_delegates.clear();

    for (QJsonValueRef r : arr) {
        QJsonObject obj = r.toObject();
        FolioDelegate::Ptr delegate = FolioDelegate::fromJson(obj, m_homeScreen);

        if (delegate) {
            connectSaveRequests(delegate);
            m_delegates.append({delegate, 0});
        }
    }

    endResetModel();
}

void FavouritesModel::connectSaveRequests(FolioDelegate::Ptr delegate)
{
    if (delegate->type() == FolioDelegate::Folder && delegate->folder()) {
        connect(delegate->folder().get(), &FolioApplicationFolder::saveRequested, this, &FavouritesModel::save);
    }
}

bool FavouritesModel::dropPositionIsEdge(qreal x, qreal y) const
{
    auto homeScreenState = m_homeScreen->homeScreenState();

    qreal startPosition = getDelegateRowStartPos();
    bool isLocationBottom = homeScreenState->favouritesBarLocation() == HomeScreenState::Bottom;
    qreal cellLength = isLocationBottom ? homeScreenState->pageCellWidth() : homeScreenState->pageCellHeight();

    qreal pos = isLocationBottom ? x : y;

    if (pos < startPosition) {
        return true;
    }

    qreal currentPos = startPosition;

    for (int i = 0; i < m_delegates.size(); i++) {
        // if it is within the center 70% of a delegate, it is not at an edge
        if (pos >= (currentPos + cellLength * 0.15) && pos <= (currentPos + cellLength * 0.85)) {
            return false;
        }

        currentPos += cellLength;
    }

    return true;
}

int FavouritesModel::dropInsertPosition(qreal x, qreal y) const
{
    auto homeScreenState = m_homeScreen->homeScreenState();

    qreal startPosition = getDelegateRowStartPos();
    bool isLocationBottom = homeScreenState->favouritesBarLocation() == HomeScreenState::Bottom;
    qreal cellLength = isLocationBottom ? homeScreenState->pageCellWidth() : homeScreenState->pageCellHeight();

    qreal pos = isLocationBottom ? x : y;

    if (pos < startPosition) {
        return adjustIndex(0);
    }

    qreal currentPos = startPosition;
    for (int i = 0; i < m_delegates.size(); i++) {
        if (pos < currentPos + cellLength * 0.85) {
            return adjustIndex(i);
        } else if (pos < currentPos + cellLength) {
            return adjustIndex(i + 1);
        }

        currentPos += cellLength;
    }
    return adjustIndex(m_delegates.size());
}

QPointF FavouritesModel::getDelegateScreenPosition(int position) const
{
    position = adjustIndex(position);

    auto homeScreenState = m_homeScreen->homeScreenState();
    qreal screenHeight = homeScreenState->viewHeight();
    qreal screenWidth = homeScreenState->viewWidth();
    qreal pageHeight = homeScreenState->pageHeight();
    qreal pageWidth = homeScreenState->pageWidth();
    qreal screenTopPadding = homeScreenState->viewTopPadding();
    qreal screenBottomPadding = homeScreenState->viewBottomPadding();
    qreal screenLeftPadding = homeScreenState->viewLeftPadding();
    qreal screenRightPadding = homeScreenState->viewRightPadding();
    qreal cellHeight = homeScreenState->pageCellHeight();
    qreal cellWidth = homeScreenState->pageCellWidth();

    qreal startPosition = getDelegateRowStartPos();

    switch (homeScreenState->favouritesBarLocation()) {
    case HomeScreenState::Bottom: {
        qreal favouritesHeight = screenHeight - pageHeight - screenBottomPadding - screenTopPadding;
        qreal x = screenLeftPadding + startPosition + cellWidth * position;
        qreal y = screenTopPadding + pageHeight + (favouritesHeight / 2) - (cellHeight / 2);
        return {x, y};
    }
    case HomeScreenState::Left: {
        qreal favouritesWidth = screenWidth - screenLeftPadding - pageWidth - screenRightPadding;
        qreal x = screenLeftPadding + (favouritesWidth / 2) - (cellWidth / 2);
        qreal y = startPosition + cellHeight * position;
        return {x, y};
    }
    case HomeScreenState::Right: {
        qreal favouritesWidth = screenWidth - screenLeftPadding - pageWidth - screenRightPadding;
        qreal x = screenLeftPadding + pageWidth + (favouritesWidth / 2) - (cellWidth / 2);
        qreal y = startPosition + cellHeight * position;
        return {x, y};
    }
    }
    return {0, 0};
}

qreal FavouritesModel::getDelegateRowStartPos() const
{
    auto homeScreenState = m_homeScreen->homeScreenState();

    const int length = m_delegates.size();
    const bool isLocationBottom = homeScreenState->favouritesBarLocation() == HomeScreenState::Bottom;
    const qreal cellLength = isLocationBottom ? homeScreenState->pageCellWidth() : homeScreenState->pageCellHeight();
    const qreal pageLength = isLocationBottom ? homeScreenState->pageWidth() : homeScreenState->pageHeight();

    const qreal topMargin = homeScreenState->viewTopPadding();
    const qreal leftMargin = homeScreenState->viewLeftPadding();
    const qreal panelOffset = isLocationBottom ? leftMargin : topMargin;

    return (pageLength / 2) - (((qreal)length) / 2) * cellLength + panelOffset;
}

int FavouritesModel::adjustIndex(int index) const
{
    auto homeScreenState = m_homeScreen->homeScreenState();

    if (homeScreenState->favouritesBarLocation() == HomeScreenState::Bottom || homeScreenState->favouritesBarLocation() == HomeScreenState::Left) {
        return index;
    } else {
        // if it's on the right side of the screen, we flip the order of the delegates
        return qMax(0, m_delegates.size() - index - 1);
    }
}
