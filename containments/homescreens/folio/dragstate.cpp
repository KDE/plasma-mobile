// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "dragstate.h"
#include "favouritesmodel.h"
#include "pagelistmodel.h"

#include <KLocalizedString>
#include <algorithm>

// TODO don't hardcode, use page widths
const int PAGE_CHANGE_THRESHOLD = 30;

const QString DEFAULT_FOLDER_NAME = i18n("Folder");

DelegateDragPosition::DelegateDragPosition(QObject *parent)
    : QObject{parent}
{
}

DelegateDragPosition::~DelegateDragPosition() = default;

void DelegateDragPosition::copyFrom(DelegateDragPosition *position)
{
    setPage(position->page());
    setPageRow(position->pageRow());
    setPageColumn(position->pageColumn());
    setFavouritesPosition(position->favouritesPosition());
    setFolderPosition(position->folderPosition());
    setFolder(position->folder());
    setLocation(position->location());
}

DelegateDragPosition::Location DelegateDragPosition::location() const
{
    return m_location;
}

void DelegateDragPosition::setLocation(Location location)
{
    if (m_location != location) {
        m_location = location;
        Q_EMIT locationChanged();
    }
}

int DelegateDragPosition::page() const
{
    return m_page;
}

void DelegateDragPosition::setPage(int page)
{
    if (m_page != page) {
        m_page = page;
        Q_EMIT pageChanged();
    }
}

int DelegateDragPosition::pageRow() const
{
    return m_pageRow;
}

void DelegateDragPosition::setPageRow(int pageRow)
{
    if (m_pageRow != pageRow) {
        m_pageRow = pageRow;
        Q_EMIT pageRowChanged();
    }
}

int DelegateDragPosition::pageColumn() const
{
    return m_pageColumn;
}

void DelegateDragPosition::setPageColumn(int pageColumn)
{
    if (m_pageColumn != pageColumn) {
        m_pageColumn = pageColumn;
        Q_EMIT pageColumnChanged();
    }
}

int DelegateDragPosition::favouritesPosition() const
{
    return m_favouritesPosition;
}

void DelegateDragPosition::setFavouritesPosition(int favouritesPosition)
{
    if (m_favouritesPosition != favouritesPosition) {
        m_favouritesPosition = favouritesPosition;
        Q_EMIT favouritesPositionChanged();
    }
}

int DelegateDragPosition::folderPosition() const
{
    return m_folderPosition;
}

void DelegateDragPosition::setFolderPosition(int folderPosition)
{
    if (m_folderPosition != folderPosition) {
        m_folderPosition = folderPosition;
        Q_EMIT folderPositionChanged();
    }
}

FolioApplicationFolder::Ptr DelegateDragPosition::folder() const
{
    return m_folder;
}

FolioApplicationFolder *DelegateDragPosition::folderRaw() const
{
    return m_folder.get();
}

void DelegateDragPosition::setFolder(FolioApplicationFolder::Ptr folder)
{
    if (m_folder != folder) {
        m_folder = folder;
        Q_EMIT folderChanged();
    }
}

DragState::DragState(HomeScreenState *state, HomeScreen *parent)
    : QObject{parent}
    , m_homeScreen{parent}
    , m_state{state}
    , m_changePageTimer{new QTimer{this}}
    , m_openFolderTimer{new QTimer{this}}
    , m_leaveFolderTimer{new QTimer{this}}
    , m_changeFolderPageTimer{new QTimer{this}}
    , m_folderInsertBetweenTimer{new QTimer{this}}
    , m_favouritesInsertBetweenTimer{new QTimer{this}}
    , m_candidateDropPosition{new DelegateDragPosition{this}}
    , m_startPosition{new DelegateDragPosition{this}}
{
    if (!state) {
        return;
    }

    // 500 ms hold before page timer changes
    m_changePageTimer->setInterval(500);
    m_changePageTimer->setSingleShot(true);

    m_openFolderTimer->setInterval(1000);
    m_openFolderTimer->setSingleShot(true);

    m_leaveFolderTimer->setInterval(500);
    m_leaveFolderTimer->setSingleShot(true);

    m_changeFolderPageTimer->setInterval(500);
    m_changeFolderPageTimer->setSingleShot(true);

    m_folderInsertBetweenTimer->setInterval(250);
    m_folderInsertBetweenTimer->setSingleShot(true);

    m_favouritesInsertBetweenTimer->setInterval(250);
    m_favouritesInsertBetweenTimer->setSingleShot(true);

    connect(m_changePageTimer, &QTimer::timeout, this, &DragState::onChangePageTimerFinished);
    connect(m_openFolderTimer, &QTimer::timeout, this, &DragState::onOpenFolderTimerFinished);
    connect(m_leaveFolderTimer, &QTimer::timeout, this, &DragState::onLeaveFolderTimerFinished);
    connect(m_changeFolderPageTimer, &QTimer::timeout, this, &DragState::onChangeFolderPageTimerFinished);
    connect(m_folderInsertBetweenTimer, &QTimer::timeout, this, &DragState::onFolderInsertBetweenTimerFinished);
    connect(m_favouritesInsertBetweenTimer, &QTimer::timeout, this, &DragState::onFavouritesInsertBetweenTimerFinished);

    connect(m_state, &HomeScreenState::delegateDragFromPageStarted, this, &DragState::onDelegateDragFromPageStarted);
    connect(m_state, &HomeScreenState::delegateDragFromAppDrawerStarted, this, &DragState::onDelegateDragFromAppDrawerStarted);
    connect(m_state, &HomeScreenState::delegateDragFromFavouritesStarted, this, &DragState::onDelegateDragFromFavouritesStarted);
    connect(m_state, &HomeScreenState::delegateDragFromFolderStarted, this, &DragState::onDelegateDragFromFolderStarted);
    connect(m_state, &HomeScreenState::delegateDragFromWidgetListStarted, this, &DragState::onDelegateDragFromWidgetListStarted);
    connect(m_state, &HomeScreenState::swipeStateChanged, this, [this]() {
        if (m_state->swipeState() == HomeScreenState::DraggingDelegate) {
            onDelegateDraggingStarted();
        }
    });
    connect(m_state, &HomeScreenState::delegateDragEnded, this, &DragState::onDelegateDropped);

    connect(m_state, &HomeScreenState::pageNumChanged, this, [this]() {
        m_candidateDropPosition->setPageRow(m_state->currentPage());
    });

    connect(m_state, &HomeScreenState::delegateDragXChanged, this, &DragState::onDelegateDragPositionChanged);
    connect(m_state, &HomeScreenState::delegateDragYChanged, this, &DragState::onDelegateDragPositionChanged);

    connect(m_state, &HomeScreenState::leftCurrentFolder, this, &DragState::onLeaveCurrentFolder);
}

DelegateDragPosition *DragState::candidateDropPosition() const
{
    return m_candidateDropPosition;
}

DelegateDragPosition *DragState::startPosition() const
{
    return m_startPosition;
}

FolioDelegate::Ptr DragState::dropDelegate() const
{
    return m_dropDelegate;
}

FolioDelegate *DragState::dropDelegateRaw() const
{
    return m_dropDelegate.get();
}

void DragState::setDropDelegate(FolioDelegate::Ptr dropDelegate)
{
    m_dropDelegate = dropDelegate;
    Q_EMIT dropDelegateChanged();
}

void DragState::onDelegateDragPositionChanged()
{
    if (!m_state) {
        return;
    }

    // we want to update the candidate drop position variable in this function!

    qreal x = getPointerX();
    qreal y = getPointerY();

    bool inFolder = m_state->viewState() == HomeScreenState::FolderView;
    bool inFavouritesArea = !inFolder;

    // the favourites bar can be in different locations, so account for each
    switch (m_state->favouritesBarLocation()) {
    case HomeScreenState::Bottom:
        inFavouritesArea = inFavouritesArea && y > m_state->pageHeight();
        break;
    case HomeScreenState::Left:
        inFavouritesArea = inFavouritesArea && x < m_state->viewWidth() - m_state->pageHeight();
        break;
    case HomeScreenState::Right:
        inFavouritesArea = inFavouritesArea && x > m_state->pageWidth();
        break;
    }

    // stop the favourites insertion timer if the delegate has moved out
    if (!inFavouritesArea) {
        m_favouritesInsertBetweenTimer->stop();

        // clear any ghost entries in the favourites model
        m_homeScreen->favouritesModel()->deleteGhostEntry();
    }

    if (inFavouritesArea || inFolder) {
        m_openFolderTimer->stop();
    }

    if (m_state->viewState() == HomeScreenState::FolderView) {
        // if we are in a folder
        onDelegateDragPositionOverFolderViewChanged();

    } else if (inFavouritesArea) {
        // we are in the favourites bar area
        onDelegateDragPositionOverFavouritesChanged();
    } else {
        // we are in the homescreen pages area
        onDelegateDragPositionOverPageViewChanged();
    }
}

void DragState::onDelegateDragPositionOverFolderViewChanged()
{
    // if the drag position changes while in the folder view
    qreal x = getPointerX();
    qreal y = getPointerY();

    FolioApplicationFolder::Ptr folder = m_state->currentFolder();
    if (!folder) {
        return;
    }

    // if the drop position is not in the folder, but outside (going to page view)
    if (folder->isDropPositionOutside(x, y)) {
        if (!m_leaveFolderTimer->isActive()) {
            m_leaveFolderTimer->start();
        }
        return;
    } else if (m_leaveFolderTimer->isActive()) {
        // cancel timer if we are back in the folder
        m_leaveFolderTimer->stop();
    }

    // the potential folder index that can be dropped at
    int dropIndex = folder->dropInsertPosition(m_state->currentFolderPage(), x, y);

    // if the delegate has moved to another position, cancel the insert timer
    if (dropIndex != m_folderInsertBetweenIndex) {
        m_folderInsertBetweenTimer->stop();
    }

    // start the insertion timer (so that the user has time to move the delegate away)
    if (!m_folderInsertBetweenTimer->isActive()) {
        m_folderInsertBetweenTimer->start();
        m_folderInsertBetweenIndex = dropIndex;
    }

    const qreal leftPagePosition = folder->applications()->leftMarginFromScreenEdge();
    const qreal rightPagePosition = m_state->viewWidth() - leftPagePosition;

    // determine if the delegate is near the edge of a page (to switch pages).
    // -> start the change page timer if we at the page edge.
    if (x <= leftPagePosition + PAGE_CHANGE_THRESHOLD || x >= rightPagePosition - PAGE_CHANGE_THRESHOLD) {
        if (!m_changeFolderPageTimer->isActive()) {
            m_changeFolderPageTimer->start();
        }
    } else {
        if (m_changeFolderPageTimer->isActive()) {
            m_changeFolderPageTimer->stop();
        }
    }
}

void DragState::onDelegateDragPositionOverFavouritesChanged()
{
    // the drag position changed while over the favourites strip

    qreal x = getPointerX();
    qreal y = getPointerY();
    FavouritesModel *favouritesModel = m_homeScreen->favouritesModel();
    int dropIndex = favouritesModel->dropInsertPosition(x, y);

    // if the drop position changed, cancel the open folder timer
    if (m_candidateDropPosition->location() != DelegateDragPosition::Favourites || m_candidateDropPosition->favouritesPosition() != dropIndex) {
        if (m_openFolderTimer->isActive()) {
            m_openFolderTimer->stop();
        }
    }

    // if the delegate has moved to another position, cancel the insert timer
    if (dropIndex != m_favouritesInsertBetweenIndex) {
        m_favouritesInsertBetweenTimer->stop();
    }

    // ignore this event if the favourites area is full already
    if (favouritesModel->isFull()) {
        return;
    }

    // ignore widget drop delegates (since they can't be placed in the favourites)
    if (m_dropDelegate && m_dropDelegate->type() == FolioDelegate::Widget) {
        return;
    }

    if (favouritesModel->dropPositionIsEdge(x, y)) {
        // if we need to make space for the delegate

        // start the insertion timer (so that the user has time to move the delegate away)
        if (!m_favouritesInsertBetweenTimer->isActive()) {
            m_favouritesInsertBetweenTimer->start();
            m_favouritesInsertBetweenIndex = dropIndex;
        }
    } else {
        // if we are hovering over the center of a folder or app

        // delete ghost entry if there is one
        int ghostEntryPosition = favouritesModel->getGhostEntryPosition();
        if (ghostEntryPosition != -1 && ghostEntryPosition != dropIndex) {
            if (dropIndex > ghostEntryPosition) {
                // correct index if deleting the ghost will change the index
                dropIndex--;
            }
            favouritesModel->deleteGhostEntry();
        }

        // update the current drop position
        m_candidateDropPosition->setFavouritesPosition(dropIndex);
        m_candidateDropPosition->setLocation(DelegateDragPosition::Favourites);

        // start folder open timer if hovering over a folder
        // get delegate being hovered over
        FolioDelegate::Ptr delegate = favouritesModel->getEntryAt(dropIndex);

        // check delegate is a folder and the drop delegate is an app
        if (delegate && delegate->type() == FolioDelegate::Folder && m_dropDelegate && m_dropDelegate->type() == FolioDelegate::Application) {
            if (!m_openFolderTimer->isActive()) {
                m_openFolderTimer->start();
            }
        }
    }
}

void DragState::onDelegateDragPositionOverPageViewChanged()
{
    // the drag position changed while over the homescreen pages strip

    qreal delegateX = getDraggedDelegateX();
    qreal delegateY = getDraggedDelegateY();
    qreal x = getPointerX();
    qreal y = getPointerY();
    int page = m_state->currentPage();

    // calculate the row and column the delegate is over
    qreal pageHorizontalMargin = (m_state->pageWidth() - m_state->pageContentWidth()) / 2;
    qreal pageVerticalMargin = (m_state->pageHeight() - m_state->pageContentHeight()) / 2;

    int row = 0;
    int column = 0;

    if (m_dropDelegate && m_dropDelegate->type() == FolioDelegate::Widget) {
        // for widgets, we use their top left position to determine where they are placed (since they are larger than one cell)
        row = (delegateY - pageVerticalMargin) / m_state->pageCellHeight();
        column = (delegateX - pageHorizontalMargin) / m_state->pageCellWidth();
    } else {
        // otherwise, we base it on the pointer position
        row = (y - pageVerticalMargin) / m_state->pageCellHeight();
        column = (x - pageHorizontalMargin) / m_state->pageCellWidth();
    }

    // ensure it's in bounds
    row = std::max(0, std::min(m_state->pageRows() - 1, row));
    column = std::max(0, std::min(m_state->pageColumns() - 1, column));

    // if the drop position changed, cancel the open folder timer
    if (m_candidateDropPosition->location() != DelegateDragPosition::Pages || m_candidateDropPosition->pageRow() != row
        || m_candidateDropPosition->pageColumn() != column) {
        if (m_openFolderTimer->isActive()) {
            m_openFolderTimer->stop();
        }
    }

    // update the current drop position
    m_candidateDropPosition->setPage(page);
    m_candidateDropPosition->setPageRow(row);
    m_candidateDropPosition->setPageColumn(column);
    m_candidateDropPosition->setLocation(DelegateDragPosition::Pages);

    // start folder open timer if hovering over a folder
    PageModel *pageModel = m_homeScreen->pageListModel()->getPage(page);
    if (pageModel) {
        // get delegate being hovered over
        FolioDelegate::Ptr delegate = pageModel->getDelegate(row, column);

        // check delegate is a folder and the drop delegate is an app
        if (delegate && delegate->type() == FolioDelegate::Folder && m_dropDelegate && m_dropDelegate->type() == FolioDelegate::Application) {
            if (!m_openFolderTimer->isActive()) {
                m_openFolderTimer->start();
            }
        }
    }

    const int leftPagePosition = 0;
    const int rightPagePosition = m_state->pageWidth();

    // determine if the delegate is near the edge of a page (to switch pages).
    // -> start the change page timer if we at the page edge.
    if (qAbs(leftPagePosition - x) <= PAGE_CHANGE_THRESHOLD || qAbs(rightPagePosition - x) <= PAGE_CHANGE_THRESHOLD) {
        if (!m_changePageTimer->isActive()) {
            m_changePageTimer->start();
        }
    } else {
        if (m_changePageTimer->isActive()) {
            m_changePageTimer->stop();
        }
    }
}

void DragState::onDelegateDraggingStarted()
{
    // remove the delegate from the model
    // NOTE: we only delete here (and not from the event trigger, ex. onDelegateDragFromPageStarted)
    //       because the actual dragging only started when this is called
    deleteStartPositionDelegate();
}

void DragState::onDelegateDragFromPageStarted(int page, int row, int column)
{
    // fetch delegate at start position
    PageModel *pageModel = m_homeScreen->pageListModel()->getPage(page);
    if (pageModel) {
        setDropDelegate(pageModel->getDelegate(row, column));
    } else {
        setDropDelegate(nullptr);
    }

    // set start location
    m_startPosition->setPage(page);
    m_startPosition->setPageRow(row);
    m_startPosition->setPageColumn(column);
    m_startPosition->setLocation(DelegateDragPosition::Pages);
}

void DragState::onDelegateDragFromFavouritesStarted(int position)
{
    // fetch delegate at start position
    setDropDelegate(m_homeScreen->favouritesModel()->getEntryAt(position));

    // set start location
    m_startPosition->setFavouritesPosition(position);
    m_startPosition->setLocation(DelegateDragPosition::Favourites);
}

void DragState::onDelegateDragFromAppDrawerStarted(QString storageId)
{
    // fetch delegate at start position
    if (KService::Ptr service = KService::serviceByStorageId(storageId)) {
        FolioApplication::Ptr app = std::make_shared<FolioApplication>(m_homeScreen, service);
        setDropDelegate(std::make_shared<FolioDelegate>(app, m_homeScreen));
    } else {
        setDropDelegate(nullptr);
    }

    // set start location
    m_startPosition->setLocation(DelegateDragPosition::AppDrawer);
}

void DragState::onDelegateDragFromFolderStarted(FolioApplicationFolder *folder, int position)
{
    // fetch delegate at start position
    setDropDelegate(folder->applications()->getDelegate(position));

    // set start location
    m_startPosition->setFolder(folder->shared_from_this());
    m_startPosition->setFolderPosition(position);
    m_startPosition->setLocation(DelegateDragPosition::Folder);
}

void DragState::onDelegateDragFromWidgetListStarted(QString appletPluginId)
{
    // default widget has dimensions of 1x1, and id of -1
    m_createdAppletPluginId = appletPluginId;
    FolioWidget::Ptr widget = std::make_shared<FolioWidget>(m_homeScreen, -1, 1, 1);
    setDropDelegate(std::make_shared<FolioDelegate>(widget, m_homeScreen));

    // set start location
    m_startPosition->setLocation(DelegateDragPosition::WidgetList);
}

void DragState::onDelegateDropped()
{
    if (!m_dropDelegate) {
        return;
    }

    // add dropped delegate
    bool success = createDropPositionDelegate();

    // delete empty pages at the end if they exist
    // (it can be created if user drags app to new page, but doesn't place it there)
    m_homeScreen->pageListModel()->deleteEmptyPagesAtEnd();

    // clear ghost position if there is one
    m_homeScreen->favouritesModel()->deleteGhostEntry();

    // reset timers
    m_folderInsertBetweenTimer->stop();
    m_changeFolderPageTimer->stop();
    m_leaveFolderTimer->stop();
    m_changePageTimer->stop();
    m_favouritesInsertBetweenTimer->stop();

    // emit corresponding signal
    // -> if we couldn't drop a new delegate at a spot, emit newDelegateDropAbandoned()
    // -> otherwise, emit delegateDroppedAndPlaced()
    if (!success && (m_startPosition->location() == DelegateDragPosition::WidgetList || m_startPosition->location() == DelegateDragPosition::AppDrawer)) {
        Q_EMIT newDelegateDropAbandoned();
    } else {
        Q_EMIT delegateDroppedAndPlaced();
    }
}

void DragState::onLeaveCurrentFolder()
{
    if (!m_state) {
        return;
    }

    // reset timers
    m_folderInsertBetweenTimer->stop();
    m_changeFolderPageTimer->stop();
    m_leaveFolderTimer->stop();

    if (m_candidateDropPosition->location() == DelegateDragPosition::Folder && m_candidateDropPosition->folder()) {
        // clear ghost entry
        m_candidateDropPosition->folder()->applications()->deleteGhostEntry();
    }
}

void DragState::onChangePageTimerFinished()
{
    if (!m_state || (m_state->swipeState() != HomeScreenState::DraggingDelegate)) {
        return;
    }

    const int leftPagePosition = 0;
    const int rightPagePosition = m_state->pageWidth();

    PageListModel *pageListModel = m_homeScreen->pageListModel();

    qreal x = getPointerX();
    if (qAbs(leftPagePosition - x) <= PAGE_CHANGE_THRESHOLD) {
        // if we are at the left edge, go left
        int page = m_state->currentPage() - 1;
        if (page >= 0) {
            m_state->goToPage(page, false);
        }

    } else if (qAbs(rightPagePosition - x) <= PAGE_CHANGE_THRESHOLD) {
        // if we are at the right edge, go right
        int page = m_state->currentPage() + 1;

        // if we are at the right-most page, try to create a new one if the current page isn't empty
        if (page == pageListModel->rowCount() && !pageListModel->isLastPageEmpty()) {
            pageListModel->addPageAtEnd();
        }

        // go to page if it exists
        if (page < pageListModel->rowCount()) {
            m_state->goToPage(page, false);
        }
    }
}

void DragState::onOpenFolderTimerFinished()
{
    if (!m_state || m_state->swipeState() != HomeScreenState::DraggingDelegate || m_state->viewState() != HomeScreenState::PageView
        || (m_candidateDropPosition->location() != DelegateDragPosition::Pages && m_candidateDropPosition->location() != DelegateDragPosition::Favourites)) {
        return;
    }

    FolioApplicationFolder::Ptr folder = nullptr;
    QPointF screenPosition;

    switch (m_candidateDropPosition->location()) {
    case DelegateDragPosition::Pages: {
        // get current page
        PageModel *page = m_homeScreen->pageListModel()->getPage(m_candidateDropPosition->page());
        if (!page) {
            return;
        }

        // get delegate being hovered over
        FolioDelegate::Ptr delegate = page->getDelegate(m_candidateDropPosition->pageRow(), m_candidateDropPosition->pageColumn());
        if (!delegate || delegate->type() != FolioDelegate::Folder) {
            return;
        }

        folder = delegate->folder();
        screenPosition =
            m_state->getPageDelegateScreenPosition(m_candidateDropPosition->page(), m_candidateDropPosition->pageRow(), m_candidateDropPosition->pageColumn());
        break;
    }
    case DelegateDragPosition::Favourites: {
        // get delegate being hovered over in favourites bar
        FolioDelegate::Ptr delegate = m_homeScreen->favouritesModel()->getEntryAt(m_candidateDropPosition->favouritesPosition());
        if (!delegate || delegate->type() != FolioDelegate::Folder) {
            return;
        }

        folder = delegate->folder();
        screenPosition = m_homeScreen->homeScreenState()->getFavouritesDelegateScreenPosition(m_candidateDropPosition->favouritesPosition());
        break;
    }
    default:
        break;
    }

    // open the folder
    m_state->openFolder(screenPosition.x(), screenPosition.y(), folder.get());
}

void DragState::onLeaveFolderTimerFinished()
{
    if (!m_state || (m_state->swipeState() != HomeScreenState::DraggingDelegate) || !m_state->currentFolder()) {
        return;
    }

    // check if the drag position is outside of the folder
    if (m_state->currentFolder()->isDropPositionOutside(getPointerX(), getPointerY())) {
        m_state->closeFolder();
    }
}

void DragState::onChangeFolderPageTimerFinished()
{
    if (!m_state || (m_state->swipeState() != HomeScreenState::DraggingDelegate) || !m_state->currentFolder()) {
        return;
    }

    FolioApplicationFolder::Ptr folder = m_state->currentFolder();
    qreal x = getPointerX();
    qreal y = getPointerY();

    // check if the drag position is outside of the folder
    if (folder->isDropPositionOutside(x, y)) {
        return;
    }

    const qreal leftPagePosition = folder->applications()->leftMarginFromScreenEdge();
    const qreal rightPagePosition = m_state->viewWidth() - leftPagePosition;

    if (x <= leftPagePosition + PAGE_CHANGE_THRESHOLD) {
        // if we are at the left edge, go left
        int page = m_state->currentFolderPage() - 1;
        if (page >= 0) {
            m_state->goToFolderPage(page, false);
        }

    } else if (x >= rightPagePosition - PAGE_CHANGE_THRESHOLD) {
        // if we are at the right edge, go right
        int page = m_state->currentFolderPage() + 1;

        // go to page if it exists
        if (page < folder->applications()->numTotalPages()) {
            m_state->goToFolderPage(page, false);
        }
    }
}

void DragState::onFolderInsertBetweenTimerFinished()
{
    if (!m_state || (m_state->swipeState() != HomeScreenState::DraggingDelegate) || !m_state->currentFolder()) {
        return;
    }

    FolioApplicationFolder::Ptr folder = m_state->currentFolder();

    // update the candidate drop position
    m_candidateDropPosition->setFolder(folder);
    m_candidateDropPosition->setFolderPosition(m_folderInsertBetweenIndex);
    m_candidateDropPosition->setLocation(DelegateDragPosition::Folder);

    // insert it at this position, shifting existing apps to the side
    // TODO the ghost entry may shift the m_folderInsertBetweenIndex, perhaps we should update??
    folder->applications()->setGhostEntry(m_folderInsertBetweenIndex);
}

void DragState::onFavouritesInsertBetweenTimerFinished()
{
    // update the candidate drop position
    m_candidateDropPosition->setFavouritesPosition(m_favouritesInsertBetweenIndex);
    m_candidateDropPosition->setLocation(DelegateDragPosition::Favourites);

    // insert it at this position, shifting existing apps to the side
    m_homeScreen->favouritesModel()->setGhostEntry(m_favouritesInsertBetweenIndex);
}

void DragState::deleteStartPositionDelegate()
{
    // delete the delegate at the start position
    switch (m_startPosition->location()) {
    case DelegateDragPosition::Pages: {
        PageModel *page = m_homeScreen->pageListModel()->getPage(m_startPosition->page());
        if (page) {
            page->removeDelegate(m_startPosition->pageRow(), m_startPosition->pageColumn());
        }
        break;
    }
    case DelegateDragPosition::Favourites:
        m_homeScreen->favouritesModel()->removeEntry(m_startPosition->favouritesPosition());
        break;
    case DelegateDragPosition::Folder:
        m_startPosition->folder()->removeDelegate(m_startPosition->folderPosition());
        break;
    case DelegateDragPosition::AppDrawer:
    case DelegateDragPosition::WidgetList:
    default:
        break;
    }
}

bool DragState::createDropPositionDelegate()
{
    if (!m_dropDelegate) {
        return false;
    }

    // whether the drop goes successfully
    bool added = false;

    // creates the delegate at the drop position
    switch (m_candidateDropPosition->location()) {
    case DelegateDragPosition::Pages: {
        // locate the page we are dropping on
        PageModel *page = m_homeScreen->pageListModel()->getPage(m_candidateDropPosition->page());
        if (!page) {
            break;
        }

        int row = m_candidateDropPosition->pageRow();
        int column = m_candidateDropPosition->pageColumn();

        // delegate to add
        FolioPageDelegate::Ptr delegate = std::make_shared<FolioPageDelegate>(row, column, m_dropDelegate, m_homeScreen);

        // delegate that exists at the drop position
        FolioPageDelegate::Ptr existingDelegate = page->getDelegate(row, column);

        // if a delegate already exists at the spot, check if we can insert/create a folder
        if (existingDelegate) {
            if (delegate->type() == FolioDelegate::Application) {
                if (existingDelegate->type() == FolioDelegate::Folder) {
                    // add the app to the existing folder

                    auto existingFolder = existingDelegate->folder();
                    existingFolder->addDelegate(delegate, existingFolder->applications()->rowCount());

                    added = true;
                    break;
                } else if (existingDelegate->type() == FolioDelegate::Application && !isStartPositionEqualDropPosition()) {
                    // create a folder from the two apps

                    FolioApplicationFolder::Ptr folder = std::make_shared<FolioApplicationFolder>(m_homeScreen, DEFAULT_FOLDER_NAME);
                    folder->addDelegate(delegate, 0);
                    folder->addDelegate(existingDelegate, 0);
                    FolioPageDelegate::Ptr folderDelegate = std::make_shared<FolioPageDelegate>(row, column, folder, m_homeScreen);

                    page->removeDelegate(row, column);
                    page->addDelegate(folderDelegate);

                    added = true;
                    break;
                }
            }
        }

        // default behavior for widgets, folders or dropping an app at an empty spot

        added = page->addDelegate(delegate);

        // if we couldn't add the delegate, try again but at the start position (return to start)
        if (!added && !isStartPositionEqualDropPosition()) {
            m_candidateDropPosition->copyFrom(m_startPosition);
            added = createDropPositionDelegate();
        }
        break;
    }
    case DelegateDragPosition::Favourites: {
        // delegate that exists at the drop position
        FolioDelegate::Ptr existingDelegate = m_homeScreen->favouritesModel()->getEntryAt(m_candidateDropPosition->favouritesPosition());

        // if a delegate already exists at the spot, check if we can insert/create a folder
        if (existingDelegate) {
            if (m_dropDelegate->type() == FolioDelegate::Application) {
                if (existingDelegate->type() == FolioDelegate::Folder) {
                    // add the app to the existing folder

                    auto existingFolder = existingDelegate->folder();
                    existingFolder->addDelegate(m_dropDelegate, existingFolder->applications()->rowCount());

                    added = true;
                    break;
                } else if (existingDelegate->type() == FolioDelegate::Application && !isStartPositionEqualDropPosition()) {
                    // create a folder from the two apps

                    FolioApplicationFolder::Ptr folder = std::make_shared<FolioApplicationFolder>(m_homeScreen, DEFAULT_FOLDER_NAME);
                    folder->addDelegate(m_dropDelegate, 0);
                    folder->addDelegate(existingDelegate, 0);
                    FolioDelegate::Ptr folderDelegate = std::make_shared<FolioDelegate>(folder, m_homeScreen);

                    m_homeScreen->favouritesModel()->removeEntry(m_candidateDropPosition->favouritesPosition());
                    m_homeScreen->favouritesModel()->addEntry(m_candidateDropPosition->favouritesPosition(), folderDelegate);

                    added = true;
                    break;
                }
            }
        }

        // otherwise, just add the delegate at this position

        added = m_homeScreen->favouritesModel()->addEntry(m_candidateDropPosition->favouritesPosition(), m_dropDelegate);

        // if we couldn't add the delegate, try again but at the start position
        if (!added && !isStartPositionEqualDropPosition()) {
            m_candidateDropPosition->copyFrom(m_startPosition);
            added = createDropPositionDelegate();
        }

        // correct position when we delete from an entry earlier in the favourites
        if (added) {
            if (m_startPosition->location() == DelegateDragPosition::Favourites
                && m_startPosition->favouritesPosition() > m_candidateDropPosition->favouritesPosition()) {
                m_startPosition->setFavouritesPosition(m_startPosition->favouritesPosition() - 1);
            }
        }
        break;
    }
    case DelegateDragPosition::Folder: {
        FolioApplicationFolder::Ptr folder = m_candidateDropPosition->folder();
        if (!folder) {
            break;
        }

        // only support dropping apps into folders
        if (m_dropDelegate->type() != FolioDelegate::Application) {
            break;
        }

        added = folder->addDelegate(m_dropDelegate, m_candidateDropPosition->folderPosition());

        // if we couldn't add the delegate, try again but at the start position
        if (!added && !isStartPositionEqualDropPosition()) {
            m_candidateDropPosition->copyFrom(m_startPosition);
            added = createDropPositionDelegate();
        }

        if (added) {
            folder->applications()->deleteGhostEntry();
        }
        break;
    }
    case DelegateDragPosition::AppDrawer:
    case DelegateDragPosition::WidgetList:
    default:
        break;
    }

    // if we are dropping a new widget, we need to now create the applet in the containment
    if (added && m_startPosition->location() == DelegateDragPosition::WidgetList && m_dropDelegate->type() == FolioDelegate::Widget && m_homeScreen) {
        Plasma::Applet *applet = m_homeScreen->createApplet(m_createdAppletPluginId);

        // associate the new delegate with the Plasma::Applet
        m_dropDelegate->widget()->setApplet(applet);
    }

    return added;
}

bool DragState::isStartPositionEqualDropPosition()
{
    return m_startPosition->location() == m_candidateDropPosition->location() && m_startPosition->page() == m_candidateDropPosition->page()
        && m_startPosition->pageRow() == m_candidateDropPosition->pageRow() && m_startPosition->pageColumn() == m_candidateDropPosition->pageColumn()
        && m_startPosition->favouritesPosition() == m_candidateDropPosition->favouritesPosition()
        && m_startPosition->folder() == m_candidateDropPosition->folder() && m_startPosition->folderPosition() == m_candidateDropPosition->folderPosition();
}

qreal DragState::getDraggedDelegateX()
{
    // adjust to get the position of the center of the delegate
    return m_state->delegateDragX() + m_state->pageCellWidth() / 2;
}

qreal DragState::getDraggedDelegateY()
{
    // adjust to get the position of the center of the delegate
    return m_state->delegateDragY() + m_state->pageCellHeight() / 2;
}

qreal DragState::getPointerX()
{
    return m_state->delegateDragX() + m_state->delegateDragPointerOffsetX();
}

qreal DragState::getPointerY()
{
    return m_state->delegateDragY() + m_state->delegateDragPointerOffsetY();
}
