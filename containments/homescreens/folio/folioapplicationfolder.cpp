// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "folioapplicationfolder.h"
#include "homescreenstate.h"

#include <QJsonArray>
#include <algorithm>

FolioApplicationFolder::FolioApplicationFolder(HomeScreen *parent, QString name)
    : QObject{parent}
    , m_homeScreen{parent}
    , m_name{name}
    , m_applicationFolderModel{new ApplicationFolderModel{this}}
{
}

FolioApplicationFolder *FolioApplicationFolder::fromJson(QJsonObject &obj, HomeScreen *parent)
{
    QString name = obj[QStringLiteral("name")].toString();
    QList<FolioApplication *> apps;
    for (auto storageId : obj[QStringLiteral("apps")].toArray()) {
        if (KService::Ptr service = KService::serviceByStorageId(storageId.toString())) {
            apps.append(new FolioApplication(parent, service));
        }
    }

    FolioApplicationFolder *folder = new FolioApplicationFolder(parent, name);
    folder->setApplications(apps);
    return folder;
}

QJsonObject FolioApplicationFolder::toJson() const
{
    QJsonObject obj;
    obj[QStringLiteral("type")] = "folder";
    obj[QStringLiteral("name")] = m_name;

    QJsonArray arr;
    for (auto delegate : m_delegates) {
        if (delegate.delegate->type() != FolioDelegate::Application) {
            continue;
        }
        arr.append(QJsonValue::fromVariant(delegate.delegate->application()->storageId()));
    }

    obj[QStringLiteral("apps")] = arr;

    return obj;
}

QString FolioApplicationFolder::name() const
{
    return m_name;
}

void FolioApplicationFolder::setName(QString &name)
{
    m_name = name;
    Q_EMIT nameChanged();
    Q_EMIT saveRequested();
}

QList<FolioApplication *> FolioApplicationFolder::appPreviews()
{
    QList<FolioApplication *> previews;
    // we give a maximum of 4 icons
    for (int i = 0; i < std::min<int>(m_delegates.size(), 4); ++i) {
        if (!m_delegates[i].delegate->application()) {
            continue;
        }
        previews.push_back(m_delegates[i].delegate->application());
    }
    return previews;
}

ApplicationFolderModel *FolioApplicationFolder::applications()
{
    return m_applicationFolderModel;
}

void FolioApplicationFolder::setApplications(QList<FolioApplication *> applications)
{
    if (m_applicationFolderModel) {
        m_applicationFolderModel->deleteLater();
    }

    m_delegates.clear();
    for (auto *app : applications) {
        m_delegates.append({new FolioDelegate{app, m_homeScreen}, 0, 0});
    }
    m_applicationFolderModel = new ApplicationFolderModel{this};
    m_applicationFolderModel->evaluateDelegatePositions();

    Q_EMIT applicationsChanged();
    Q_EMIT applicationsReset();
    Q_EMIT saveRequested();
}

void FolioApplicationFolder::moveEntry(int fromRow, int toRow)
{
    m_applicationFolderModel->moveEntry(fromRow, toRow);
}

bool FolioApplicationFolder::addDelegate(FolioDelegate *delegate, int row)
{
    return m_applicationFolderModel->addDelegate(delegate, row);
}

void FolioApplicationFolder::removeDelegate(int row)
{
    m_applicationFolderModel->removeDelegate(row);
}

int FolioApplicationFolder::dropInsertPosition(int page, qreal x, qreal y)
{
    return m_applicationFolderModel->dropInsertPosition(page, x, y);
}

bool FolioApplicationFolder::isDropPositionOutside(qreal x, qreal y)
{
    return m_applicationFolderModel->isDropPositionOutside(x, y);
}

ApplicationFolderModel::ApplicationFolderModel(FolioApplicationFolder *folder)
    : QAbstractListModel{folder}
    , m_folder{folder}
{
    HomeScreenState *homeScreenState = folder->m_homeScreen->homeScreenState();
    connect(homeScreenState, &HomeScreenState::folderPageWidthChanged, this, [this]() {
        evaluateDelegatePositions();
    });
    connect(homeScreenState, &HomeScreenState::folderPageHeightChanged, this, [this]() {
        evaluateDelegatePositions();
    });
    connect(homeScreenState, &HomeScreenState::folderPageContentWidthChanged, this, [this]() {
        evaluateDelegatePositions();
    });
    connect(homeScreenState, &HomeScreenState::folderPageContentHeightChanged, this, [this]() {
        evaluateDelegatePositions();
    });
    connect(homeScreenState, &HomeScreenState::viewWidthChanged, this, [this]() {
        evaluateDelegatePositions();
    });
    connect(homeScreenState, &HomeScreenState::viewHeightChanged, this, [this]() {
        evaluateDelegatePositions();
    });
    connect(homeScreenState, &HomeScreenState::pageCellWidthChanged, this, [this]() {
        evaluateDelegatePositions();
    });
    connect(homeScreenState, &HomeScreenState::pageCellHeightChanged, this, [this]() {
        evaluateDelegatePositions();
    });
}

int ApplicationFolderModel::rowCount(const QModelIndex & /*parent*/) const
{
    return m_folder->m_delegates.size();
}

QVariant ApplicationFolderModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case DelegateRole:
        return QVariant::fromValue(m_folder->m_delegates.at(index.row()).delegate);
    case XPositionRole:
        return QVariant::fromValue(m_folder->m_delegates.at(index.row()).xPosition);
    case YPositionRole:
        return QVariant::fromValue(m_folder->m_delegates.at(index.row()).yPosition);
    }

    return QVariant();
}

QHash<int, QByteArray> ApplicationFolderModel::roleNames() const
{
    return {{DelegateRole, "delegate"}, {XPositionRole, "xPosition"}, {YPositionRole, "yPosition"}};
}

FolioDelegate *ApplicationFolderModel::getDelegate(int index)
{
    if (index < 0 || index >= m_folder->m_delegates.size()) {
        return nullptr;
    }
    return m_folder->m_delegates[index].delegate;
}

void ApplicationFolderModel::moveEntry(int fromRow, int toRow)
{
    if (fromRow < 0 || toRow < 0 || fromRow >= m_folder->m_delegates.size() || toRow >= m_folder->m_delegates.size() || fromRow == toRow) {
        return;
    }
    if (toRow > fromRow) {
        ++toRow;
    }

    beginMoveRows(QModelIndex(), fromRow, fromRow, QModelIndex(), toRow);
    if (toRow > fromRow) {
        auto delegate = m_folder->m_delegates.at(fromRow);
        m_folder->m_delegates.insert(toRow, delegate);
        m_folder->m_delegates.takeAt(fromRow);
    } else {
        auto delegate = m_folder->m_delegates.takeAt(fromRow);
        m_folder->m_delegates.insert(toRow, delegate);
    }
    endMoveRows();

    evaluateDelegatePositions();

    Q_EMIT m_folder->applicationsChanged();
    Q_EMIT m_folder->saveRequested();
}

bool ApplicationFolderModel::canAddDelegate(FolioDelegate *delegate, int index)
{
    if (index < 0 || index > m_folder->m_delegates.size()) {
        return false;
    }

    if (!delegate) {
        return false;
    }

    return true;
}

bool ApplicationFolderModel::addDelegate(FolioDelegate *delegate, int index)
{
    if (!canAddDelegate(delegate, index)) {
        return false;
    }

    if (index == m_folder->m_delegates.size()) {
        beginInsertRows(QModelIndex(), index, index);
        m_folder->m_delegates.append({delegate, 0, 0});
        evaluateDelegatePositions(false);
        endInsertRows();
    } else if (m_folder->m_delegates[index].delegate->type() == FolioDelegate::None) {
        replaceGhostEntry(delegate);
    } else {
        beginInsertRows(QModelIndex(), index, index);
        m_folder->m_delegates.insert(index, {delegate, 0, 0});
        evaluateDelegatePositions(false);
        endInsertRows();
    }

    evaluateDelegatePositions();

    Q_EMIT m_folder->applicationsChanged();
    Q_EMIT m_folder->saveRequested();

    return true;
}

void ApplicationFolderModel::removeDelegate(int index)
{
    if (index < 0 || index >= m_folder->m_delegates.size()) {
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);
    // HACK: do not deleteLater(), because the delegate might still be used somewhere else
    // m_folder->m_delegates[index].app->deleteLater();
    m_folder->m_delegates.removeAt(index);
    endRemoveRows();

    evaluateDelegatePositions();

    Q_EMIT m_folder->applicationsChanged();
    Q_EMIT m_folder->saveRequested();
}

QPointF ApplicationFolderModel::getDelegatePosition(int index)
{
    if (index < 0 || index >= m_folder->m_delegates.size()) {
        return {0, 0};
    }
    auto delegate = m_folder->m_delegates[index];
    return {delegate.xPosition, delegate.yPosition};
}

int ApplicationFolderModel::getGhostEntryPosition()
{
    for (int i = 0; i < m_folder->m_delegates.size(); i++) {
        if (m_folder->m_delegates[i].delegate->type() == FolioDelegate::None) {
            return i;
        }
    }
    return -1;
}

void ApplicationFolderModel::setGhostEntry(int index)
{
    FolioDelegate *ghost = nullptr;

    // check if a ghost entry already exists
    for (int i = 0; i < m_folder->m_delegates.size(); i++) {
        auto delegate = m_folder->m_delegates[i].delegate;
        if (delegate->type() == FolioDelegate::None) {
            ghost = delegate;

            // remove it
            removeDelegate(i);

            // correct index if necessary due to deletion
            if (index > i) {
                index--;
            }
        }
    }

    if (!ghost) {
        ghost = new FolioDelegate{m_folder->m_homeScreen};
    }

    // add empty delegate at new position
    addDelegate(ghost, index);
}

void ApplicationFolderModel::replaceGhostEntry(FolioDelegate *delegate)
{
    for (int i = 0; i < m_folder->m_delegates.size(); i++) {
        if (m_folder->m_delegates[i].delegate->type() == FolioDelegate::None) {
            m_folder->m_delegates[i].delegate = delegate;

            Q_EMIT dataChanged(createIndex(i, 0), createIndex(i, 0), {DelegateRole});
            break;
        }
    }
}

void ApplicationFolderModel::deleteGhostEntry()
{
    for (int i = 0; i < m_folder->m_delegates.size(); i++) {
        if (m_folder->m_delegates[i].delegate->type() == FolioDelegate::None) {
            removeDelegate(i);
        }
    }
}

int ApplicationFolderModel::dropInsertPosition(int page, qreal x, qreal y)
{
    qreal cellWidth = m_folder->m_homeScreen->homeScreenState()->pageCellWidth();
    qreal cellHeight = m_folder->m_homeScreen->homeScreenState()->pageCellHeight();

    int row = (y - topMarginFromScreenEdge()) / cellHeight;
    row = std::max(0, std::min(numRowsOnPage(), row));

    // the index that the position is over
    int leftColumn = std::max(0.0, x - leftMarginFromScreenEdge()) / cellWidth;
    leftColumn = std::min(numColumnsOnPage() - 1, leftColumn);

    qreal leftColumnPosition = leftColumn * cellWidth + leftMarginFromScreenEdge();

    int column = leftColumn + 1;

    // if it's the left half of this position or it's the last column on this row, return itself
    if ((x < leftColumnPosition + cellWidth * 0.5) || (leftColumn == numColumnsOnPage() - 1)) {
        column = leftColumn;
    }

    // calculate the position based on the page, row and column it is at
    int pos = (page * numRowsOnPage() * numColumnsOnPage()) + (row * numColumnsOnPage()) + column;
    // make sure it's in bounds
    return std::min((int)m_folder->m_delegates.size(), std::max(0, pos));
}

bool ApplicationFolderModel::isDropPositionOutside(qreal x, qreal y)
{
    return (x < leftMarginFromScreenEdge()) || (x > (m_folder->m_homeScreen->homeScreenState()->viewWidth() - leftMarginFromScreenEdge()))
        || (y < topMarginFromScreenEdge()) || (y > m_folder->m_homeScreen->homeScreenState()->viewHeight() - topMarginFromScreenEdge());
}

void ApplicationFolderModel::evaluateDelegatePositions(bool emitSignal)
{
    qreal pageWidth = m_folder->m_homeScreen->homeScreenState()->folderPageWidth();
    qreal topMargin = verticalPageMargin();
    qreal leftMargin = horizontalPageMargin();

    qreal cellWidth = m_folder->m_homeScreen->homeScreenState()->pageCellWidth();
    qreal cellHeight = m_folder->m_homeScreen->homeScreenState()->pageCellHeight();

    int rows = numRowsOnPage();
    int columns = numColumnsOnPage();
    int numOfDelegates = m_folder->m_delegates.size();

    int index = 0;
    int page = 0;

    while (index < m_folder->m_delegates.size()) {
        int prevIndex = index;

        // determine positions page-by-page
        for (int row = 0; row < rows && index < numOfDelegates; row++) {
            for (int column = 0; column < columns && index < numOfDelegates; column++) {
                m_folder->m_delegates[index].xPosition = qRound(page * pageWidth + leftMargin + column * cellWidth);
                m_folder->m_delegates[index].yPosition = qRound(topMargin + row * cellHeight);
                index++;
            }
        }

        // prevent infinite loop
        if (prevIndex == index) {
            break;
        }
        page++;
    }

    if (emitSignal) {
        Q_EMIT dataChanged(createIndex(0, 0), createIndex(m_folder->m_delegates.size() - 1, 0), {XPositionRole});
        Q_EMIT dataChanged(createIndex(0, 0), createIndex(m_folder->m_delegates.size() - 1, 0), {YPositionRole});
    }

    Q_EMIT numberOfPagesChanged();
}

QPointF ApplicationFolderModel::getDelegateStartPosition(int page)
{
    qreal pageWidth = m_folder->m_homeScreen->homeScreenState()->folderPageWidth();

    qreal x = pageWidth * page + leftMarginFromScreenEdge();
    qreal y = topMarginFromScreenEdge();
    return QPointF{x, y};
}

int ApplicationFolderModel::numTotalPages()
{
    int numOfDelegatesOnPage = numRowsOnPage() * numColumnsOnPage();
    return std::ceil(((qreal)m_folder->m_delegates.size()) / numOfDelegatesOnPage);
}

int ApplicationFolderModel::numRowsOnPage()
{
    HomeScreenState *homeScreenState = m_folder->m_homeScreen->homeScreenState();
    qreal contentHeight = homeScreenState->folderPageContentHeight();
    qreal cellHeight = homeScreenState->pageCellHeight();

    return std::max(0.0, contentHeight / cellHeight);
}

int ApplicationFolderModel::numColumnsOnPage()
{
    HomeScreenState *homeScreenState = m_folder->m_homeScreen->homeScreenState();
    qreal contentWidth = homeScreenState->folderPageContentWidth();
    qreal cellWidth = homeScreenState->pageCellWidth();

    return std::max(0.0, contentWidth / cellWidth);
}

qreal ApplicationFolderModel::leftMarginFromScreenEdge()
{
    HomeScreenState *homeScreenState = m_folder->m_homeScreen->homeScreenState();
    qreal viewWidth = homeScreenState->viewWidth();
    qreal folderPageWidth = homeScreenState->folderPageWidth();

    return (viewWidth - folderPageWidth) / 2 + horizontalPageMargin();
}

qreal ApplicationFolderModel::topMarginFromScreenEdge()
{
    HomeScreenState *homeScreenState = m_folder->m_homeScreen->homeScreenState();
    qreal viewHeight = homeScreenState->viewHeight();
    qreal folderPageHeight = homeScreenState->folderPageHeight();

    return (viewHeight - folderPageHeight) / 2 + verticalPageMargin();
}

qreal ApplicationFolderModel::horizontalPageMargin()
{
    HomeScreenState *homeScreenState = m_folder->m_homeScreen->homeScreenState();
    qreal pageWidth = homeScreenState->folderPageWidth();
    qreal pageContentWidth = homeScreenState->folderPageContentWidth();

    return (pageWidth - pageContentWidth) / 2;
}

qreal ApplicationFolderModel::verticalPageMargin()
{
    HomeScreenState *homeScreenState = m_folder->m_homeScreen->homeScreenState();
    qreal pageHeight = homeScreenState->folderPageHeight();
    qreal pageContentHeight = homeScreenState->folderPageContentHeight();

    return (pageHeight - pageContentHeight) / 2;
}
