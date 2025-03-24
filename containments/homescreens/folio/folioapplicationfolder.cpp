// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "folioapplicationfolder.h"

#include <QJsonArray>
#include <algorithm>

FolioApplicationFolder::FolioApplicationFolder(HomeScreen *parent, QString name)
    : QObject{parent}
    , m_homeScreen{parent}
    , m_name{name}
    , m_applicationFolderModel{new ApplicationFolderModel{this}}
{
}

FolioApplicationFolder::Ptr FolioApplicationFolder::fromJson(QJsonObject &obj, HomeScreen *parent)
{
    QString name = obj[QStringLiteral("name")].toString();
    QList<FolioApplication::Ptr> apps;
    for (auto storageId : obj[QStringLiteral("apps")].toArray()) {
        if (KService::Ptr service = KService::serviceByStorageId(storageId.toString())) {
            apps.append(std::make_shared<FolioApplication>(parent, service));
        }
    }

    FolioApplicationFolder::Ptr folder = std::make_shared<FolioApplicationFolder>(parent, name);
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
        previews.push_back(m_delegates[i].delegate->application().get());
    }
    return previews;
}

ApplicationFolderModel *FolioApplicationFolder::applications()
{
    return m_applicationFolderModel;
}

void FolioApplicationFolder::setApplications(QList<FolioApplication::Ptr> applications)
{
    if (m_applicationFolderModel) {
        m_applicationFolderModel->deleteLater();
    }

    m_delegates.clear();
    for (FolioApplication::Ptr app : applications) {
        m_delegates.append({FolioDelegate::Ptr{new FolioDelegate{app, m_homeScreen}}, 0, 0, 0});
    }
    m_applicationFolderModel = new ApplicationFolderModel{this};
    m_applicationFolderModel->evaluateDelegateIndexes();

    Q_EMIT applicationsChanged();
    Q_EMIT applicationsReset();
    Q_EMIT saveRequested();
}

void FolioApplicationFolder::moveEntry(int fromRow, int toRow)
{
    m_applicationFolderModel->moveEntry(fromRow, toRow);
}

bool FolioApplicationFolder::addDelegate(FolioDelegate::Ptr delegate, int row)
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

std::pair<FolioDelegate::Ptr, int> FolioApplicationFolder::getNeighborDelegate(FolioDelegate::Ptr delegate, Enums::Direction direction)
{
    if (!delegate) {
        // If there is no delegate, just return the first element (if it exists)
        return {m_applicationFolderModel->getDelegate(0), 0};
    }

    int rowIndex = -1;
    int columnIndex = -1;
    int pageIndex = -1;

    // Find delegate and the position it is at
    for (const ApplicationDelegate &d : m_delegates) {
        if (d.delegate == delegate) {
            rowIndex = d.rowIndex;
            columnIndex = d.columnIndex;
            pageIndex = d.pageIndex;
            break;
        }
    }

    if (rowIndex == -1) {
        // Delegate was not found
        return {nullptr, 0};
    }

    int gridLength = m_applicationFolderModel->numGridLengthOnPage();

    // Add delta position for neighbour's coordinate.
    switch (direction) {
    case Enums::Direction::Up:
        rowIndex--;
        break;
    case Enums::Direction::Down:
        rowIndex++;
        break;
    case Enums::Direction::Left:
        columnIndex--;
        break;
    case Enums::Direction::Right:
        columnIndex++;
        break;
    default:
        break;
    }

    if (rowIndex < 0 || rowIndex >= gridLength) {
        // Above or below the folder
        return {nullptr, 0};
    }

    if (columnIndex >= gridLength) {
        // Go to next page
        pageIndex++;
        columnIndex = 0;
    }
    if (columnIndex < 0) {
        // Go to previous page
        pageIndex--;
        columnIndex = gridLength - 1;
    }

    // Find new delegate at coordinate
    for (const ApplicationDelegate &d : m_delegates) {
        if (d.rowIndex == rowIndex && d.columnIndex == columnIndex && d.pageIndex == pageIndex) {
            return {d.delegate, pageIndex};
        }
    }

    return {nullptr, 0};
}

ApplicationFolderModel::ApplicationFolderModel(FolioApplicationFolder *parent)
    : QAbstractListModel{parent}
    , m_folder{parent}
{
    HomeScreenState *homeScreenState = m_folder->m_homeScreen->homeScreenState();
    connect(homeScreenState, &HomeScreenState::folderPageWidthChanged, this, [this]() {
        evaluateDelegateIndexes();
    });
    connect(homeScreenState, &HomeScreenState::folderPageHeightChanged, this, [this]() {
        evaluateDelegateIndexes();
    });
    connect(homeScreenState, &HomeScreenState::folderPageContentWidthChanged, this, [this]() {
        evaluateDelegateIndexes();
    });
    connect(homeScreenState, &HomeScreenState::folderPageContentHeightChanged, this, [this]() {
        evaluateDelegateIndexes();
    });
    connect(homeScreenState, &HomeScreenState::viewWidthChanged, this, [this]() {
        evaluateDelegateIndexes();
    });
    connect(homeScreenState, &HomeScreenState::viewHeightChanged, this, [this]() {
        evaluateDelegateIndexes();
    });
    connect(homeScreenState, &HomeScreenState::pageCellWidthChanged, this, [this]() {
        evaluateDelegateIndexes();
    });
    connect(homeScreenState, &HomeScreenState::pageCellHeightChanged, this, [this]() {
        evaluateDelegateIndexes();
    });

    // Listen to application removal events and delete delegates
    connect(m_folder->m_homeScreen->applicationListModel(), &ApplicationListModel::applicationRemoved, this, [this](const QString &storageId) {
        for (int i = 0; i < m_folder->m_delegates.size(); i++) {
            auto delegate = m_folder->m_delegates[i].delegate;

            if (delegate->type() == FolioDelegate::Application && delegate->application()->storageId() == storageId) {
                removeDelegate(i);
            }
        }
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
        return QVariant::fromValue(m_folder->m_delegates.at(index.row()).delegate.get());
    case columnIndexRole:
        return QVariant::fromValue(m_folder->m_delegates.at(index.row()).columnIndex);
    case rowIndexRole:
        return QVariant::fromValue(m_folder->m_delegates.at(index.row()).rowIndex);
    case pageIndexRole:
        return QVariant::fromValue(m_folder->m_delegates.at(index.row()).pageIndex);
    }

    return QVariant();
}

QHash<int, QByteArray> ApplicationFolderModel::roleNames() const
{
    return {{DelegateRole, "delegate"}, {columnIndexRole, "columnIndex"}, {rowIndexRole, "rowIndex"}, {pageIndexRole, "pageIndex"}};
}

FolioDelegate::Ptr ApplicationFolderModel::getDelegate(int index)
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

    evaluateDelegateIndexes();

    Q_EMIT m_folder->applicationsChanged();
    Q_EMIT m_folder->saveRequested();
}

bool ApplicationFolderModel::canAddDelegate(FolioDelegate::Ptr delegate, int index)
{
    if (index < 0 || index > m_folder->m_delegates.size()) {
        return false;
    }

    if (!delegate) {
        return false;
    }

    return true;
}

bool ApplicationFolderModel::addDelegate(FolioDelegate::Ptr delegate, int index)
{
    if (!canAddDelegate(delegate, index)) {
        return false;
    }

    if (index == m_folder->m_delegates.size()) {
        beginInsertRows(QModelIndex(), index, index);
        m_folder->m_delegates.append({delegate, 0, 0, 0});
        evaluateDelegateIndexes(false);
        endInsertRows();
    } else if (m_folder->m_delegates[index].delegate->type() == FolioDelegate::None) {
        replaceGhostEntry(delegate);
    } else {
        beginInsertRows(QModelIndex(), index, index);
        m_folder->m_delegates.insert(index, {delegate, 0, 0, 0});
        evaluateDelegateIndexes(false);
        endInsertRows();
    }

    evaluateDelegateIndexes();

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

    evaluateDelegateIndexes();

    Q_EMIT m_folder->applicationsChanged();
    Q_EMIT m_folder->saveRequested();
}

QPointF ApplicationFolderModel::getDelegatePosition(int index)
{
    if (index < 0 || index >= m_folder->m_delegates.size()) {
        return {0, 0};
    }
    auto delegate = m_folder->m_delegates[index];
    qreal pageContentSize = m_folder->m_homeScreen->homeScreenState()->folderPageContentWidth();
    qreal topMargin = verticalPageMargin();
    qreal leftMargin = horizontalPageMargin();

    int cellSize = pageContentSize / numGridLengthOnPage();

    qreal cellWitdhRecenter = (cellSize - m_folder->m_homeScreen->homeScreenState()->pageCellWidth()) / 2;
    qreal cellHeightRecenter = (cellSize - m_folder->m_homeScreen->homeScreenState()->pageCellHeight()) / 2;

    qreal xPosition = cellWitdhRecenter + leftMargin + delegate.columnIndex * cellSize;
    qreal yPosition = cellHeightRecenter + topMargin + delegate.rowIndex * cellSize;

    return {xPosition, yPosition};
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
    FolioDelegate::Ptr ghost = nullptr;

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
        ghost = std::make_shared<FolioDelegate>(m_folder->m_homeScreen);
    }

    // add empty delegate at new position
    addDelegate(ghost, index);
}

void ApplicationFolderModel::replaceGhostEntry(FolioDelegate::Ptr delegate)
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
    qreal pageContentWidth = m_folder->m_homeScreen->homeScreenState()->folderPageContentWidth();
    qreal cellSize = (pageContentWidth) / numGridLengthOnPage();

    int row = (y - topMarginFromScreenEdge()) / cellSize;
    row = std::max(0, std::min(numGridLengthOnPage(), row));

    // the index that the position is over
    int leftColumn = std::max(0.0, x - leftMarginFromScreenEdge()) / cellSize;
    leftColumn = std::min(numGridLengthOnPage() - 1, leftColumn);

    qreal leftColumnPosition = leftColumn * cellSize + leftMarginFromScreenEdge();

    int column = leftColumn + 1;

    // if it's the left half of this position or it's the last column on this row, return itself
    if ((x < leftColumnPosition + cellSize * 0.5) || (leftColumn == numGridLengthOnPage() - 1)) {
        column = leftColumn;
    }

    // calculate the position based on the page, row and column it is at
    int pos = (page * numGridLengthOnPage() * numGridLengthOnPage()) + (row * numGridLengthOnPage()) + column;
    // make sure it's in bounds
    return std::min((int)m_folder->m_delegates.size(), std::max(0, pos));
}

bool ApplicationFolderModel::isDropPositionOutside(qreal x, qreal y)
{
    return (x < leftMarginFromScreenEdge()) || (x > (m_folder->m_homeScreen->homeScreenState()->viewWidth() - leftMarginFromScreenEdge()))
        || (y < topMarginFromScreenEdge()) || (y > m_folder->m_homeScreen->homeScreenState()->viewHeight() - topMarginFromScreenEdge());
}

void ApplicationFolderModel::evaluateDelegateIndexes(bool emitSignal)
{
    int rows = numGridLengthOnPage();
    int columns = numGridLengthOnPage();
    int numOfDelegates = m_folder->m_delegates.size();

    int index = 0;
    int page = 0;

    while (index < m_folder->m_delegates.size()) {
        int prevIndex = index;

        // determine the row and column index page-by-page
        for (int row = 0; row < rows && index < numOfDelegates; row++) {
            for (int column = 0; column < columns && index < numOfDelegates; column++) {
                m_folder->m_delegates[index].columnIndex = column;
                m_folder->m_delegates[index].rowIndex = row;
                m_folder->m_delegates[index].pageIndex = page;
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
        Q_EMIT dataChanged(createIndex(0, 0), createIndex(m_folder->m_delegates.size() - 1, 0), {columnIndexRole});
        Q_EMIT dataChanged(createIndex(0, 0), createIndex(m_folder->m_delegates.size() - 1, 0), {rowIndexRole});
        Q_EMIT dataChanged(createIndex(0, 0), createIndex(m_folder->m_delegates.size() - 1, 0), {pageIndexRole});
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
    int numOfDelegatesOnPage = numGridLengthOnPage() * numGridLengthOnPage();
    return std::ceil(((qreal)m_folder->m_delegates.size()) / numOfDelegatesOnPage);
}

int ApplicationFolderModel::numGridLengthOnPage()
{
    return m_folder->m_homeScreen->homeScreenState()->folderGridLength();
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
