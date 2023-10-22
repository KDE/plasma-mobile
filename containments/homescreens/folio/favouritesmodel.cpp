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

FavouritesModel *FavouritesModel::self()
{
    static FavouritesModel *inst = new FavouritesModel();
    return inst;
}

FavouritesModel::FavouritesModel(QObject *parent)
    : QAbstractListModel{parent}
{
    connect(HomeScreenState::self(), &HomeScreenState::pageWidthChanged, this, [this]() {
        evaluateDelegatePositions(true);
    });
    connect(HomeScreenState::self(), &HomeScreenState::pageHeightChanged, this, [this]() {
        evaluateDelegatePositions(true);
    });
    connect(HomeScreenState::self(), &HomeScreenState::pageCellWidthChanged, this, [this]() {
        evaluateDelegatePositions(true);
    });
    connect(HomeScreenState::self(), &HomeScreenState::pageCellHeightChanged, this, [this]() {
        evaluateDelegatePositions(true);
    });
    connect(HomeScreenState::self(), &HomeScreenState::favouritesBarLocationChanged, this, [this]() {
        evaluateDelegatePositions(true);
    });
    connect(HomeScreenState::self(), &HomeScreenState::pageOrientationChanged, this, [this]() {
        evaluateDelegatePositions(true);
    });
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
        return QVariant::fromValue(m_delegates.at(index.row()).delegate);
    case XPositionRole:
        return QVariant::fromValue(m_delegates.at(index.row()).xPosition);
    }

    return QVariant();
}

QHash<int, QByteArray> FavouritesModel::roleNames() const
{
    return {{DelegateRole, "delegate"}, {XPositionRole, "xPosition"}};
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

    evaluateDelegatePositions();

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

    evaluateDelegatePositions();

    save();
}

bool FavouritesModel::addEntry(int row, FolioDelegate *delegate)
{
    if (!delegate) {
        return false;
    }

    if (row < 0 || row > m_delegates.size()) {
        return false;
    }

    if (row == m_delegates.size()) {
        beginInsertRows(QModelIndex(), row, row);
        m_delegates.append({delegate, 0});
        evaluateDelegatePositions(false);
        endInsertRows();
    } else if (m_delegates[row].delegate->type() == FolioDelegate::None) {
        replaceGhostEntry(delegate);
    } else {
        beginInsertRows(QModelIndex(), row, row);
        m_delegates.insert(row, {delegate, 0});
        evaluateDelegatePositions(false);
        endInsertRows();
    }

    evaluateDelegatePositions();

    save();

    return true;
}

FolioDelegate *FavouritesModel::getEntryAt(int row)
{
    if (row < 0 || row >= m_delegates.size()) {
        return nullptr;
    }

    return m_delegates[row].delegate;
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
        FolioDelegate *ghost = new FolioDelegate{this};
        addEntry(row, ghost);
    }
}

void FavouritesModel::replaceGhostEntry(FolioDelegate *delegate)
{
    for (int i = 0; i < m_delegates.size(); i++) {
        if (m_delegates[i].delegate->type() == FolioDelegate::None) {
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
            removeEntry(i);
        }
    }
}

void FavouritesModel::save()
{
    if (!m_applet) {
        return;
    }

    QJsonArray arr;
    for (int i = 0; i < m_delegates.size(); i++) {
        FolioDelegate *delegate = m_delegates[i].delegate;

        // if this delegate is empty, ignore it
        if (!delegate || delegate->type() == FolioDelegate::None) {
            continue;
        }

        arr.append(delegate->toJson());
    }
    QByteArray data = QJsonDocument(arr).toJson(QJsonDocument::Compact);

    m_applet->config().writeEntry("Favourites", QString::fromStdString(data.toStdString()));
    Q_EMIT m_applet->configNeedsSaving();
}

void FavouritesModel::load()
{
    if (!m_applet) {
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(m_applet->config().readEntry("Favourites", "{}").toUtf8());

    beginResetModel();

    m_delegates.clear();

    for (QJsonValueRef r : doc.array()) {
        QJsonObject obj = r.toObject();
        FolioDelegate *delegate = FolioDelegate::fromJson(obj, this);

        if (delegate) {
            if (delegate->type() == FolioDelegate::Folder) {
                connect(delegate->folder(), &FolioApplicationFolder::saveRequested, this, &FavouritesModel::save);
            }

            m_delegates.append({delegate, 0});
        }
    }

    evaluateDelegatePositions(false);
    endResetModel();
}

void FavouritesModel::setApplet(Plasma::Applet *applet)
{
    m_applet = applet;
}

bool FavouritesModel::dropPositionIsEdge(qreal x, qreal y) const
{
    qreal startPosition = getDelegateRowStartPos();
    bool isLocationBottom = HomeScreenState::self()->favouritesBarLocation() == HomeScreenState::Bottom;
    qreal cellLength = isLocationBottom ? HomeScreenState::self()->pageCellWidth() : HomeScreenState::self()->pageCellHeight();

    qreal pos = isLocationBottom ? x : y;

    if (pos < startPosition) {
        return true;
    }

    qreal currentPos = startPosition;

    for (int i = 0; i < m_delegates.size(); i++) {
        // if it is within the centre 70% of a delegate, it is not at an edge
        if (pos >= (currentPos + cellLength * 0.15) && pos <= (currentPos + cellLength * 0.85)) {
            return false;
        }

        currentPos += cellLength;
    }

    return true;
}

int FavouritesModel::dropInsertPosition(qreal x, qreal y) const
{
    qreal startPosition = getDelegateRowStartPos();
    bool isLocationBottom = HomeScreenState::self()->favouritesBarLocation() == HomeScreenState::Bottom;
    qreal cellLength = isLocationBottom ? HomeScreenState::self()->pageCellWidth() : HomeScreenState::self()->pageCellHeight();

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

    qreal screenHeight = HomeScreenState::self()->viewHeight();
    qreal screenWidth = HomeScreenState::self()->viewWidth();
    qreal pageHeight = HomeScreenState::self()->pageHeight();
    qreal pageWidth = HomeScreenState::self()->pageWidth();
    qreal screenTopPadding = HomeScreenState::self()->viewTopPadding();
    qreal screenBottomPadding = HomeScreenState::self()->viewBottomPadding();
    qreal screenLeftPadding = HomeScreenState::self()->viewLeftPadding();
    qreal screenRightPadding = HomeScreenState::self()->viewRightPadding();
    qreal cellHeight = HomeScreenState::self()->pageCellHeight();
    qreal cellWidth = HomeScreenState::self()->pageCellWidth();

    qreal startPosition = getDelegateRowStartPos();

    switch (HomeScreenState::self()->favouritesBarLocation()) {
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

void FavouritesModel::evaluateDelegatePositions(bool emitSignal)
{
    bool isLocationBottom = HomeScreenState::self()->favouritesBarLocation() == HomeScreenState::Bottom;
    qreal cellLength = isLocationBottom ? HomeScreenState::self()->pageCellWidth() : HomeScreenState::self()->pageCellHeight();
    qreal startPosition = getDelegateRowStartPos();
    qreal currentPos = startPosition;

    for (int i = 0; i < m_delegates.size(); ++i) {
        m_delegates[adjustIndex(i)].xPosition = qRound(currentPos);
        currentPos += cellLength;
    }

    if (emitSignal) {
        Q_EMIT dataChanged(createIndex(0, 0), createIndex(m_delegates.size() - 1, 0), {XPositionRole});
    }
}

qreal FavouritesModel::getDelegateRowStartPos() const
{
    const int length = m_delegates.size();
    const bool isLocationBottom = HomeScreenState::self()->favouritesBarLocation() == HomeScreenState::Bottom;
    const qreal cellLength = isLocationBottom ? HomeScreenState::self()->pageCellWidth() : HomeScreenState::self()->pageCellHeight();
    const qreal pageLength = isLocationBottom ? HomeScreenState::self()->pageWidth() : HomeScreenState::self()->pageHeight();

    const qreal topMargin = HomeScreenState::self()->viewTopPadding();
    const qreal leftMargin = HomeScreenState::self()->viewLeftPadding();
    const qreal panelOffset = isLocationBottom ? leftMargin : topMargin;

    return (pageLength / 2) - (((qreal)length) / 2) * cellLength + panelOffset;
}

int FavouritesModel::adjustIndex(int index) const
{
    if (HomeScreenState::self()->favouritesBarLocation() == HomeScreenState::Bottom
        || HomeScreenState::self()->favouritesBarLocation() == HomeScreenState::Left) {
        return index;
    } else {
        // if it's on the right side of the screen, we flip the order of the delegates
        return qMax(0, m_delegates.size() - index - 1);
    }
}
