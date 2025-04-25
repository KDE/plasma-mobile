// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "homescreenstate.h"
#include "favouritesmodel.h"
#include "foliosettings.h"
#include "pagelistmodel.h"

#include <algorithm>

// TODO don't hardcode, use something more device dependent?
constexpr qreal APP_DRAWER_OPEN_DIST = 300;
constexpr qreal SEARCH_WIDGET_OPEN_DIST = 300;

// pixels to move before we determine the swipe type
constexpr qreal DETERMINE_SWIPE_THRESHOLD = 10;

constexpr qreal VERTICAL_FAVOURITES_BAR_THRESHOLD = 400;

QPropertyAnimation *HomeScreenState::setupAnimation(QByteArray property, int duration, QEasingCurve::Type curve, qreal endValue)
{
    auto anim = new QPropertyAnimation{this, property, this};
    anim->setDuration(duration);
    anim->setEndValue(endValue);
    anim->setEasingCurve(curve);
    return anim;
}

HomeScreenState::HomeScreenState(HomeScreen *parent)
    : QObject{parent}
    , m_homeScreen{parent}
    , m_dragState{new DragState{this, parent}}
    , m_appDrawerY{APP_DRAWER_OPEN_DIST}
    , m_searchWidgetY{SEARCH_WIDGET_OPEN_DIST}
{
}

void HomeScreenState::init()
{
    const int expoDuration = 800;
    const int cubicDuration = 400;

    m_openAppDrawerAnim = setupAnimation("appDrawerY", expoDuration, QEasingCurve::OutExpo, 0);

    connect(m_openAppDrawerAnim, &QPropertyAnimation::valueChanged, this, [this]() {
        // the animation runs too long to connect to QPropertyAnimation::finished
        // instead just have the end behaviour execute once we are 90% through
        if (m_appDrawerOpenProgress > 0.9) {
            setViewState(ViewState::AppDrawerView);
            Q_EMIT appDrawerOpened();
        }
    });

    m_closeAppDrawerAnim = setupAnimation("appDrawerY", expoDuration, QEasingCurve::OutExpo, APP_DRAWER_OPEN_DIST);

    connect(m_closeAppDrawerAnim, &QPropertyAnimation::valueChanged, this, [this]() {
        // the animation runs too long to connect to QPropertyAnimation::finished
        // instead just have the end behaviour execute once we are 90% through
        if (m_appDrawerOpenProgress < 0.1) {
            if (m_viewState == ViewState::AppDrawerView) {
                // confirm view state is still AppDrawerView before setting to prevent oddities
                setViewState(ViewState::PageView);
            }
            Q_EMIT appDrawerClosed();
        }
    });

    m_openSearchWidgetAnim = setupAnimation("searchWidgetY", cubicDuration, QEasingCurve::OutCubic, 0);

    connect(m_openSearchWidgetAnim, &QPropertyAnimation::finished, this, [this]() {
        setViewState(ViewState::SearchWidgetView);
    });

    m_closeSearchWidgetAnim = setupAnimation("searchWidgetY", cubicDuration, QEasingCurve::OutCubic, SEARCH_WIDGET_OPEN_DIST);

    connect(m_closeSearchWidgetAnim, &QPropertyAnimation::finished, this, [this]() {
        setViewState(ViewState::PageView);
    });

    m_pageAnim = setupAnimation("pageViewX", cubicDuration, QEasingCurve::OutCubic, 0);

    m_openFolderAnim = setupAnimation("folderOpenProgress", cubicDuration, QEasingCurve::OutCubic, 1.0);

    connect(m_openFolderAnim, &QPropertyAnimation::finished, this, [this]() {
        setViewState(ViewState::FolderView);
    });

    m_closeFolderAnim = setupAnimation("folderOpenProgress", cubicDuration, QEasingCurve::OutCubic, 0.0);

    connect(m_closeFolderAnim, &QPropertyAnimation::finished, this, [this]() {
        setViewState(ViewState::PageView);
        setCurrentFolder(nullptr);
        setFolderViewX(0); // reset to first page
        m_folderPageNum = 0;
        Q_EMIT folderPageNumChanged();

        Q_EMIT leftCurrentFolder();
    });

    m_folderPageAnim = setupAnimation("folderViewX", cubicDuration, QEasingCurve::OutCubic, 0);

    m_openSettingsAnim = setupAnimation("settingsOpenProgress", cubicDuration, QEasingCurve::OutExpo, 1.0);

    connect(m_openSettingsAnim, &QPropertyAnimation::finished, this, [this]() {
        setViewState(ViewState::SettingsView);
    });

    m_closeSettingsAnim = setupAnimation("settingsOpenProgress", cubicDuration, QEasingCurve::InOutExpo, 0.0);

    connect(m_closeSettingsAnim, &QPropertyAnimation::finished, this, [this]() {
        setViewState(ViewState::PageView);
    });

    connect(this, &HomeScreenState::viewWidthChanged, this, [this]() {
        // TODO: we only support 2 orientations at the moment since we don't know what the device rotated to
        setPageOrientation(m_viewWidth > m_viewHeight ? RotateCounterClockwise : RegularPosition);
    });
    connect(this, &HomeScreenState::viewHeightChanged, this, [this]() {
        setPageOrientation(m_viewWidth > m_viewHeight ? RotateCounterClockwise : RegularPosition);
    });
    connect(this, &HomeScreenState::pageOrientationChanged, this, [this]() {
        Q_EMIT pageRowsChanged();
        Q_EMIT pageColumnsChanged();
    });

    connect(this, &HomeScreenState::pageWidthChanged, [this]() {
        calculatePageContentWidth();
        calculateFolderGridLength();
    });
    connect(this, &HomeScreenState::pageHeightChanged, [this]() {
        calculatePageContentHeight();
        calculateFolderGridLength();
    });
    connect(this, &HomeScreenState::pageContentWidthChanged, [this]() {
        calculatePageCellWidth();
        calculateFolderGridLength();
    });
    connect(this, &HomeScreenState::pageColumnsChanged, [this]() {
        calculatePageCellWidth();
        calculateFolderGridLength();
    });
    connect(this, &HomeScreenState::pageContentHeightChanged, [this]() {
        calculatePageCellHeight();
        calculateFolderGridLength();
    });
    connect(this, &HomeScreenState::pageRowsChanged, [this]() {
        calculatePageCellHeight();
        calculateFolderGridLength();
    });

    connect(m_homeScreen->folioSettings(), &FolioSettings::delegateIconSizeChanged, this, &HomeScreenState::calculateFolderGridLength);

    connect(this, &HomeScreenState::viewWidthChanged, this, [this]() {
        Q_EMIT favouritesBarLocationChanged();
    });
    connect(this, &HomeScreenState::viewHeightChanged, this, [this]() {
        Q_EMIT favouritesBarLocationChanged();
    });

    connect(m_homeScreen->folioSettings(), &FolioSettings::homeScreenRowsChanged, this, [this]() {
        Q_EMIT pageRowsChanged();
        Q_EMIT pageColumnsChanged();
    });
    connect(m_homeScreen->folioSettings(), &FolioSettings::homeScreenColumnsChanged, this, [this]() {
        Q_EMIT pageRowsChanged();
        Q_EMIT pageColumnsChanged();
    });
}

HomeScreenState::ViewState HomeScreenState::viewState() const
{
    return m_viewState;
}

void HomeScreenState::setViewState(ViewState viewState)
{
    if (viewState != m_viewState) {
        m_viewState = viewState;
        Q_EMIT viewStateChanged();
    }
}

HomeScreenState::SwipeState HomeScreenState::swipeState() const
{
    return m_swipeState;
}

void HomeScreenState::setSwipeState(SwipeState swipeState)
{
    if (swipeState != m_swipeState) {
        m_swipeState = swipeState;
        Q_EMIT swipeStateChanged();
    }
}

DragState *HomeScreenState::dragState() const
{
    return m_dragState;
}

qreal HomeScreenState::viewWidth() const
{
    return m_viewWidth;
}

void HomeScreenState::setViewWidth(qreal viewWidth)
{
    if (m_viewWidth != viewWidth) {
        m_viewWidth = viewWidth;
        Q_EMIT viewWidthChanged();
    }
}

qreal HomeScreenState::viewHeight() const
{
    return m_viewHeight;
}

void HomeScreenState::setViewHeight(qreal viewHeight)
{
    if (m_viewHeight != viewHeight) {
        m_viewHeight = viewHeight;
        Q_EMIT viewHeightChanged();
    }
}

qreal HomeScreenState::viewTopPadding() const
{
    return m_viewTopPadding;
}

void HomeScreenState::setViewTopPadding(qreal viewTopPadding)
{
    if (m_viewTopPadding != viewTopPadding) {
        m_viewTopPadding = viewTopPadding;
        Q_EMIT viewTopPaddingChanged();
    }
}

qreal HomeScreenState::viewBottomPadding() const
{
    return m_viewBottomPadding;
}

void HomeScreenState::setViewBottomPadding(qreal viewBottomPadding)
{
    if (m_viewBottomPadding != viewBottomPadding) {
        m_viewBottomPadding = viewBottomPadding;
        Q_EMIT viewBottomPaddingChanged();
    }
}

qreal HomeScreenState::viewLeftPadding() const
{
    return m_viewLeftPadding;
}

void HomeScreenState::setViewLeftPadding(qreal viewLeftPadding)
{
    if (m_viewLeftPadding != viewLeftPadding) {
        m_viewLeftPadding = viewLeftPadding;
        Q_EMIT viewLeftPaddingChanged();
    }
}

qreal HomeScreenState::viewRightPadding() const
{
    return m_viewRightPadding;
}

void HomeScreenState::setViewRightPadding(qreal viewRightPadding)
{
    if (m_viewRightPadding != viewRightPadding) {
        m_viewRightPadding = viewRightPadding;
        Q_EMIT viewRightPaddingChanged();
    }
}

HomeScreenState::PageOrientation HomeScreenState::pageOrientation() const
{
    return m_pageOrientation;
}

void HomeScreenState::setPageOrientation(PageOrientation pageOrientation)
{
    if (m_pageOrientation != pageOrientation) {
        m_pageOrientation = pageOrientation;
        Q_EMIT pageOrientationChanged();
    }
}

HomeScreenState::FavouritesBarLocation HomeScreenState::favouritesBarLocation() const
{
    // TODO need to determine screen rotation and bottom of screen to have Left and Right accordingly
    return m_viewHeight < VERTICAL_FAVOURITES_BAR_THRESHOLD && m_viewWidth > m_viewHeight ? Right : Bottom;
}

int HomeScreenState::pageRows() const
{
    if (m_pageOrientation == RegularPosition || m_pageOrientation == RotateUpsideDown) {
        return m_homeScreen->folioSettings()->homeScreenRows();
    } else {
        return m_homeScreen->folioSettings()->homeScreenColumns();
    }
}

int HomeScreenState::pageColumns() const
{
    if (m_pageOrientation == RegularPosition || m_pageOrientation == RotateUpsideDown) {
        return m_homeScreen->folioSettings()->homeScreenColumns();
    } else {
        return m_homeScreen->folioSettings()->homeScreenRows();
    }
}

qreal HomeScreenState::pageViewX() const
{
    return m_pageViewX;
}

void HomeScreenState::setPageViewX(qreal pageViewX)
{
    if (m_pageViewX != pageViewX) {
        m_pageViewX = pageViewX;
        Q_EMIT pageViewXChanged();
    }
}

qreal HomeScreenState::pageWidth() const
{
    return m_pageWidth;
}

void HomeScreenState::setPageWidth(qreal pageWidth)
{
    if (m_pageWidth != pageWidth) {
        m_pageWidth = pageWidth;
        Q_EMIT pageWidthChanged();

        // make sure we snap
        goToPage(m_pageNum, true);
        goToFolderPage(m_folderPageNum, true);
    }
}

qreal HomeScreenState::pageHeight() const
{
    return m_pageHeight;
}

void HomeScreenState::setPageHeight(qreal pageHeight)
{
    if (m_pageHeight != pageHeight) {
        m_pageHeight = pageHeight;
        Q_EMIT pageHeightChanged();
    }
}

qreal HomeScreenState::pageContentWidth() const
{
    return m_pageContentWidth;
}

void HomeScreenState::calculatePageContentWidth()
{
    const qreal pageContentWidth = std::round(m_pageWidth * 0.95); // 0.05 on both sides

    if (m_pageContentWidth != pageContentWidth) {
        m_pageContentWidth = pageContentWidth;
        Q_EMIT pageContentWidthChanged();
    }
}

qreal HomeScreenState::pageContentHeight() const
{
    return m_pageContentHeight;
}

void HomeScreenState::calculatePageContentHeight()
{
    const qreal pageContentHeight = std::round(m_pageHeight * 0.95); // 0.05 on both sides

    if (m_pageContentHeight != pageContentHeight) {
        m_pageContentHeight = pageContentHeight;
        Q_EMIT pageContentHeightChanged();
    }
}

qreal HomeScreenState::pageCellWidth() const
{
    return m_pageCellWidth;
}

void HomeScreenState::calculatePageCellWidth()
{
    qreal pageCellWidth = (pageColumns() == 0) ? 0 : qMax(0.0, std::round(m_pageContentWidth / pageColumns()));

    if (m_pageCellWidth != pageCellWidth) {
        m_pageCellWidth = pageCellWidth;
        Q_EMIT pageCellWidthChanged();
    }
}

qreal HomeScreenState::pageCellHeight() const
{
    return m_pageCellHeight;
}

void HomeScreenState::calculatePageCellHeight()
{
    qreal pageCellHeight = (pageRows() == 0) ? 0 : std::round(m_pageContentHeight / pageRows());

    if (m_pageCellHeight != pageCellHeight) {
        m_pageCellHeight = pageCellHeight;
        Q_EMIT pageCellHeightChanged();
    }
}

qreal HomeScreenState::pageDelegateLabelHeight() const
{
    return m_pageDelegateLabelHeight;
}

void HomeScreenState::setPageDelegateLabelHeight(qreal pageDelegateLabelHeight)
{
    if (m_pageDelegateLabelHeight != pageDelegateLabelHeight) {
        m_pageDelegateLabelHeight = pageDelegateLabelHeight;
        Q_EMIT pageDelegateLabelHeightChanged();
    }
}

qreal HomeScreenState::pageDelegateLabelSpacing() const
{
    return m_pageDelegateLabelSpacing;
}

void HomeScreenState::setPageDelegateLabelSpacing(qreal pageDelegateLabelSpacing)
{
    if (m_pageDelegateLabelSpacing != pageDelegateLabelSpacing) {
        m_pageDelegateLabelSpacing = pageDelegateLabelSpacing;
        Q_EMIT pageDelegateLabelSpacingChanged();
    }
}

qreal HomeScreenState::folderViewX() const
{
    return m_folderViewX;
}

void HomeScreenState::setFolderViewX(qreal folderViewX)
{
    if (m_folderViewX != folderViewX) {
        m_folderViewX = folderViewX;
        Q_EMIT folderViewXChanged();
    }
}

qreal HomeScreenState::folderPageWidth() const
{
    return m_folderPageWidth;
}

void HomeScreenState::setFolderPageWidth(qreal folderPageWidth)
{
    if (m_folderPageWidth != folderPageWidth) {
        m_folderPageWidth = folderPageWidth;
        Q_EMIT folderPageWidthChanged();
    }
}

qreal HomeScreenState::folderPageHeight() const
{
    return m_folderPageHeight;
}

void HomeScreenState::setFolderPageHeight(qreal folderPageHeight)
{
    if (m_folderPageHeight != folderPageHeight) {
        m_folderPageHeight = folderPageHeight;
        Q_EMIT folderPageHeightChanged();
    }
}

qreal HomeScreenState::folderPageContentWidth() const
{
    return m_folderPageContentWidth;
}

void HomeScreenState::setFolderPageContentWidth(qreal folderPageContentWidth)
{
    if (m_folderPageContentWidth != folderPageContentWidth) {
        m_folderPageContentWidth = folderPageContentWidth;
        Q_EMIT folderPageContentWidthChanged();
    }
}

qreal HomeScreenState::folderPageContentHeight() const
{
    return m_folderPageContentHeight;
}

void HomeScreenState::setFolderPageContentHeight(qreal folderPageContentHeight)
{
    if (m_folderPageContentHeight != folderPageContentHeight) {
        m_folderPageContentHeight = folderPageContentHeight;
        Q_EMIT folderPageContentHeightChanged();
    }
}

qreal HomeScreenState::folderOpenProgress() const
{
    return m_folderOpenProgress;
}

void HomeScreenState::setFolderOpenProgress(qreal folderOpenProgress)
{
    if (m_folderOpenProgress != folderOpenProgress) {
        m_folderOpenProgress = folderOpenProgress;
        Q_EMIT folderOpenProgressChanged();
    }
}

FolioApplicationFolder::Ptr HomeScreenState::currentFolder() const
{
    return m_currentFolder;
}

FolioApplicationFolder *HomeScreenState::currentFolderRaw() const
{
    return m_currentFolder.get();
}

void HomeScreenState::setCurrentFolder(FolioApplicationFolder::Ptr folder)
{
    if (m_currentFolder != folder) {
        m_currentFolder = folder;
        Q_EMIT currentFolderChanged();
    }
}

int HomeScreenState::folderGridLength() const
{
    return m_folderGridLength;
}

void HomeScreenState::calculateFolderGridLength()
{
    const int folderGridLength = std::max(2, qRound(std::min(m_viewWidth, m_viewHeight) * 0.6 / m_homeScreen->folioSettings()->delegateIconSize() * 0.6));

    if (m_folderGridLength != folderGridLength) {
        m_folderGridLength = folderGridLength;
        Q_EMIT folderGridLengthChanged();
        goToFolderPage(m_folderPageNum, true);
    }
}

qreal HomeScreenState::settingsOpenProgress()
{
    return m_settingsOpenProgress;
}

void HomeScreenState::setSettingsOpenProgress(qreal settingsOpenProgress)
{
    if (m_settingsOpenProgress != settingsOpenProgress) {
        m_settingsOpenProgress = settingsOpenProgress;
        Q_EMIT settingsOpenProgressChanged();
    }
}

qreal HomeScreenState::appDrawerOpenProgress()
{
    return m_appDrawerOpenProgress;
}

qreal HomeScreenState::appDrawerY()
{
    return m_appDrawerY;
}

void HomeScreenState::setAppDrawerY(qreal appDrawerY)
{
    m_appDrawerY = appDrawerY;
    m_appDrawerOpenProgress = 1 - qBound(0.0, m_appDrawerY, APP_DRAWER_OPEN_DIST) / APP_DRAWER_OPEN_DIST;
    Q_EMIT appDrawerYChanged();
    Q_EMIT appDrawerOpenProgressChanged();
}

qreal HomeScreenState::searchWidgetOpenProgress()
{
    return m_searchWidgetOpenProgress;
}

qreal HomeScreenState::searchWidgetY()
{
    return m_searchWidgetOpenProgress;
}

void HomeScreenState::setSearchWidgetY(qreal searchWidgetY)
{
    m_searchWidgetY = searchWidgetY;
    m_searchWidgetOpenProgress = 1 - qBound(0.0, m_searchWidgetY, SEARCH_WIDGET_OPEN_DIST) / SEARCH_WIDGET_OPEN_DIST;
    Q_EMIT searchWidgetYChanged();
    Q_EMIT searchWidgetOpenProgressChanged();
}

qreal HomeScreenState::delegateDragX()
{
    return m_delegateDragX;
}

void HomeScreenState::setDelegateDragX(qreal delegateDragX)
{
    m_delegateDragX = delegateDragX;
    Q_EMIT delegateDragXChanged();
}

qreal HomeScreenState::delegateDragY()
{
    return m_delegateDragY;
}

void HomeScreenState::setDelegateDragY(qreal delegateDragY)
{
    m_delegateDragY = delegateDragY;
    Q_EMIT delegateDragYChanged();
}

qreal HomeScreenState::delegateDragPointerOffsetX()
{
    return m_delegateDragPointerOffsetX;
}

void HomeScreenState::setDelegateDragPointerOffsetX(qreal delegateDragPointerOffsetX)
{
    m_delegateDragPointerOffsetX = delegateDragPointerOffsetX;
}

qreal HomeScreenState::delegateDragPointerOffsetY()
{
    return m_delegateDragPointerOffsetY;
}

void HomeScreenState::setDelegateDragPointerOffsetY(qreal delegateDragPointerOffsetY)
{
    m_delegateDragPointerOffsetY = delegateDragPointerOffsetY;
}

int HomeScreenState::currentPage()
{
    return m_pageNum;
}

void HomeScreenState::setCurrentPage(int currentPage)
{
    if (m_pageNum != currentPage) {
        m_pageNum = currentPage;
        Q_EMIT pageNumChanged();
    }
}

int HomeScreenState::currentFolderPage()
{
    return m_folderPageNum;
}

FolioDelegate *HomeScreenState::getPageDelegateAt(int page, int row, int column)
{
    PageModel *pageModel = m_homeScreen->pageListModel()->getPage(page);
    if (!pageModel) {
        return nullptr;
    }

    FolioDelegate::Ptr delegate = pageModel->getDelegate(row, column);
    if (!delegate) {
        return nullptr;
    }

    return delegate.get();
}

FolioDelegate *HomeScreenState::getFavouritesDelegateAt(int position)
{
    return m_homeScreen->favouritesModel()->getEntryAt(position).get();
}

FolioDelegate *HomeScreenState::getFolderDelegateAt(int position)
{
    if (!m_currentFolder) {
        return nullptr;
    }

    return m_currentFolder->applications()->getDelegate(position).get();
}

QPointF HomeScreenState::getPageDelegateScreenPosition(int page, int row, int column)
{
    Q_UNUSED(page)
    qreal x = m_viewLeftPadding + ((m_pageWidth - m_pageContentWidth) / 2) + (m_pageCellWidth * column);
    qreal y = m_viewTopPadding + ((m_pageHeight - m_pageContentHeight) / 2) + (m_pageCellHeight * row);
    return QPointF{x, y};
}

QPointF HomeScreenState::getFavouritesDelegateScreenPosition(int position)
{
    return m_homeScreen->favouritesModel()->getDelegateScreenPosition(position);
}

QPointF HomeScreenState::getFolderDelegateScreenPosition(int position)
{
    if (!m_currentFolder || position < 0 || position >= m_currentFolder->applications()->rowCount()) {
        return {0, 0};
    }
    auto pos = m_currentFolder->applications()->getDelegatePosition(position);

    qreal x = pos.x() + (m_viewWidth - m_viewLeftPadding - m_viewRightPadding - m_folderPageWidth) / 2;
    qreal y = pos.y() + (m_viewHeight - m_viewTopPadding - m_viewBottomPadding - m_folderPageHeight) / 2;
    x += m_viewLeftPadding;
    y += m_viewTopPadding;

    return {x, y};
}

void HomeScreenState::openAppDrawer()
{
    // Ensure search widget is closed when app drawer opens
    closeSearchWidget();

    cancelAppDrawerAnimations();
    m_openAppDrawerAnim->setStartValue(m_appDrawerY);
    m_openAppDrawerAnim->start();
}

void HomeScreenState::closeAppDrawer()
{
    cancelAppDrawerAnimations();
    m_closeAppDrawerAnim->setStartValue(m_appDrawerY);
    m_closeAppDrawerAnim->start();
}

void HomeScreenState::openSearchWidget()
{
    // Ensure app drawer is closed when search widget opens
    closeAppDrawer();

    cancelSearchWidgetAnimations();
    m_openSearchWidgetAnim->setStartValue(m_searchWidgetY);
    m_openSearchWidgetAnim->start();
}

void HomeScreenState::closeSearchWidget()
{
    cancelSearchWidgetAnimations();
    m_closeSearchWidgetAnim->setStartValue(m_searchWidgetY);
    m_closeSearchWidgetAnim->start();
}

void HomeScreenState::goToPage(int page, bool snap)
{
    if (page < 0) {
        page = 0;
    }

    const int numOfPages = m_homeScreen->pageListModel()->rowCount();
    if (page >= numOfPages) {
        page = std::max(0, numOfPages - 1);
    }

    setCurrentPage(page);

    if (snap) {
        // Skip the animation and go straight to the intended page
        m_pageAnim->setStartValue(-page * m_pageWidth);
    } else {
        m_pageAnim->setStartValue(m_pageViewX);
    }
    m_pageAnim->setEndValue(-page * m_pageWidth);
    m_pageAnim->start();
}

void HomeScreenState::goToFolderPage(int page, bool snap)
{
    if (!m_currentFolder) {
        return;
    }

    if (page < 0) {
        page = 0;
    }

    int numOfPages = m_currentFolder->applications()->numTotalPages();
    if (page >= numOfPages) {
        page = std::max(0, numOfPages - 1);
    }

    m_folderPageNum = page;
    Q_EMIT folderPageNumChanged();

    if (snap) {
        // Skip the animation and go straight to the intended page
        m_folderPageAnim->setStartValue(-page * m_folderPageWidth);
    } else {
        m_folderPageAnim->setStartValue(m_folderViewX);
    }
    m_folderPageAnim->setEndValue(-page * m_folderPageWidth);
    m_folderPageAnim->start();
}

void HomeScreenState::openFolder(qreal delegateX, qreal delegateY, FolioApplicationFolder *folder)
{
    setCurrentFolder(folder->shared_from_this());

    m_openFolderAnim->stop();
    m_closeFolderAnim->stop();
    m_openFolderAnim->setStartValue(m_folderOpenProgress);
    m_openFolderAnim->start();

    Q_EMIT folderAboutToOpen(delegateX, delegateY);
}

void HomeScreenState::closeFolder()
{
    m_openFolderAnim->stop();
    m_closeFolderAnim->stop();
    m_closeFolderAnim->setStartValue(m_folderOpenProgress);
    m_closeFolderAnim->start();
}

void HomeScreenState::openSettingsView()
{
    m_closeSettingsAnim->stop();
    m_openSettingsAnim->stop();
    m_openSettingsAnim->setStartValue(m_settingsOpenProgress);
    m_openSettingsAnim->start();
}

void HomeScreenState::closeSettingsView()
{
    m_openSettingsAnim->stop();
    m_closeSettingsAnim->stop();
    m_closeSettingsAnim->setStartValue(m_settingsOpenProgress);
    m_closeSettingsAnim->start();
}

void HomeScreenState::startDelegateDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY)
{
    // start drag and drop positions
    setDelegateDragX(startX);
    setDelegateDragY(startY);
    setDelegateDragPointerOffsetX(pointerOffsetX);
    setDelegateDragPointerOffsetY(pointerOffsetY);

    // end current swipe
    swipeEnded();

    // start the delegate drag
    setSwipeState(SwipeState::AwaitingDraggingDelegate);
}

void HomeScreenState::startDelegatePageDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY, int page, int row, int column)
{
    startDelegateDrag(startX, startY, pointerOffsetX, pointerOffsetY);
    Q_EMIT delegateDragFromPageStarted(page, row, column);
}

void HomeScreenState::startDelegateFavouritesDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY, int position)
{
    startDelegateDrag(startX, startY, pointerOffsetX, pointerOffsetY);
    Q_EMIT delegateDragFromFavouritesStarted(position);
}

void HomeScreenState::startDelegateAppDrawerDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY, QString storageId)
{
    startDelegateDrag(startX, startY, pointerOffsetX, pointerOffsetY);
    Q_EMIT delegateDragFromAppDrawerStarted(storageId);

    // we start dragging the delegate immediately from the app drawer, because we don't have a context menu to deal with!
    // NOTE: this has to happen after delegateDragFromAppDrawerStarted, because slots for that expect SwipeState::AwaitingDraggingDelegate
    setSwipeState(SwipeState::DraggingDelegate);
}

void HomeScreenState::startDelegateFolderDrag(qreal startX,
                                              qreal startY,
                                              qreal pointerOffsetX,
                                              qreal pointerOffsetY,
                                              FolioApplicationFolder *folder,
                                              int position)
{
    startDelegateDrag(startX, startY, pointerOffsetX, pointerOffsetY);
    Q_EMIT delegateDragFromFolderStarted(folder, position);
}

void HomeScreenState::startDelegateWidgetListDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY, QString appletPluginId)
{
    startDelegateDrag(startX, startY, pointerOffsetX, pointerOffsetY);
    Q_EMIT delegateDragFromWidgetListStarted(appletPluginId);

    // we start dragging the delegate immediately from the app drawer, because we don't have a context menu to deal with!
    // NOTE: this has to happen after delegateDragFromAppDrawerStarted, because slots for that expect SwipeState::AwaitingDraggingDelegate
    setSwipeState(SwipeState::DraggingDelegate);
}

void HomeScreenState::cancelDelegateDrag()
{
    swipeEnded();
}

void HomeScreenState::swipeStarted(qreal deltaX, qreal deltaY)
{
    if (m_swipeState != SwipeState::None) {
        return;
    }

    setSwipeState(SwipeState::DeterminingSwipeType);

    // the user interaction has already moved a bit (for swipe detection),
    // so we call the move event too.
    swipeMoved(deltaX, deltaY, deltaX, deltaY);
}

void HomeScreenState::swipeEnded()
{
    switch (m_swipeState) {
    case SwipeState::SwipingOpenAppDrawer:
    case SwipeState::SwipingCloseAppDrawer:
        if (m_movingUp) {
            closeAppDrawer();
        } else {
            openAppDrawer();
        }
        break;
    case SwipeState::SwipingAppDrawerGrid:
        Q_EMIT appDrawerGridFlickRequested();
        break;
    case SwipeState::SwipingOpenSearchWidget:
    case SwipeState::SwipingCloseSearchWidget:
        if (m_movingUp) {
            openSearchWidget();
        } else {
            closeSearchWidget();
        }
        break;
    case SwipeState::SwipingPages: {
        int page = std::max(0.0, -m_pageViewX) / m_pageWidth;

        // m_movingRight refers to finger movement
        if (m_movingRight || m_pageViewX > 0) {
            goToPage(page, false);
        } else {
            goToPage(page + 1, false);
        }
        break;
    }
    case SwipeState::SwipingFolderPages: {
        int page = std::max(0.0, -m_folderViewX) / m_folderPageWidth;

        // m_movingRight refers to finger movement
        if (m_movingRight || m_folderViewX > 0) {
            goToFolderPage(page, false);
        } else {
            goToFolderPage(page + 1, false);
        }
        break;
    }
    case SwipeState::DraggingDelegate:
        Q_EMIT delegateDragEnded();
        break;
    case SwipeState::AwaitingDraggingDelegate:
    case SwipeState::DeterminingSwipeType:
        break;
    default:
        break;
    }

    setSwipeState(SwipeState::None);
}

void HomeScreenState::swipeCancelled()
{
    setSwipeState(SwipeState::None);
}

void HomeScreenState::swipeMoved(qreal totalDeltaX, qreal totalDeltaY, qreal deltaX, qreal deltaY)
{
    m_movingUp = deltaY > 0;

    switch (m_swipeState) {
    case SwipeState::DeterminingSwipeType:
        // check if we can determine the type of swipe this is
        determineSwipeTypeAfterThreshold(totalDeltaX, totalDeltaY);
        break;
    case SwipeState::SwipingOpenSearchWidget:
    case SwipeState::SwipingCloseSearchWidget:
        setSearchWidgetY(m_searchWidgetY - deltaY);
        break;
    case SwipeState::SwipingOpenAppDrawer:
    case SwipeState::SwipingCloseAppDrawer:
        setAppDrawerY(m_appDrawerY + deltaY);
        break;
    case SwipeState::SwipingAppDrawerGrid:
        Q_EMIT appDrawerGridYChanged(deltaY);
        break;
    case SwipeState::SwipingPages:
        m_movingRight = deltaX > 0;
        setPageViewX(m_pageViewX + deltaX);
        break;
    case SwipeState::SwipingFolderPages:
        m_movingRight = deltaX > 0;
        setFolderViewX(m_folderViewX + deltaX);
        break;
    case SwipeState::AwaitingDraggingDelegate:
        setSwipeState(SwipeState::DraggingDelegate);
        break;
    case SwipeState::DraggingDelegate:
        setDelegateDragX(m_delegateDragX + deltaX);
        setDelegateDragY(m_delegateDragY + deltaY);
        break;
    default:
        break;
    }
}

void HomeScreenState::determineSwipeTypeAfterThreshold(qreal totalDeltaX, qreal totalDeltaY)
{
    // we check if the x or y movement has passed a certain threshold before determining the swipe type

    if (qAbs(totalDeltaX) >= DETERMINE_SWIPE_THRESHOLD && (m_viewState == ViewState::PageView || m_viewState == ViewState::SettingsView)) {
        // select horizontal swipe mode (only if in page view)
        setSwipeState(SwipeState::SwipingPages);

        // ensure no animations are running when starting a swipe
        m_pageAnim->stop();

    } else if (qAbs(totalDeltaX) >= DETERMINE_SWIPE_THRESHOLD && m_viewState == ViewState::FolderView) {
        // select horizontal swipe mode (only if in page view)
        setSwipeState(SwipeState::SwipingFolderPages);

        // ensure no animations are running when starting a swipe
        m_folderPageAnim->stop();

    } else if (qAbs(totalDeltaY) >= DETERMINE_SWIPE_THRESHOLD) {
        // select vertical swipe mode

        if (m_movingUp) {
            // moving up
            switch (m_viewState) {
            case ViewState::PageView:
                // if the app drawer is still being opened
                if (m_openAppDrawerAnim->state() == QPropertyAnimation::Running) {
                    setSwipeState(SwipeState::SwipingOpenAppDrawer);
                    cancelAppDrawerAnimations();
                } else {
                    setSwipeState(SwipeState::SwipingOpenSearchWidget);
                    cancelSearchWidgetAnimations();
                }
                break;
            case ViewState::AppDrawerView:
                setSwipeState(SwipeState::SwipingCloseAppDrawer);
                cancelAppDrawerAnimations();
                break;
            case ViewState::SearchWidgetView:
                setSwipeState(SwipeState::SwipingCloseSearchWidget);
                cancelSearchWidgetAnimations();
            case ViewState::FolderView:
            case ViewState::SettingsView:
                // no vertical behaviour in folder or settings view
            default:
                break;
            }
        } else {
            // moving down
            switch (m_viewState) {
            case ViewState::PageView:
                if (m_openSearchWidgetAnim->state() == QPropertyAnimation::Running) {
                    setSwipeState(SwipeState::SwipingOpenSearchWidget);
                    cancelSearchWidgetAnimations();
                } else {
                    setSwipeState(SwipeState::SwipingOpenAppDrawer);
                    cancelAppDrawerAnimations();
                }
                break;
            case ViewState::SearchWidgetView:
                setSwipeState(SwipeState::SwipingCloseSearchWidget);
                cancelSearchWidgetAnimations();
                break;
            case ViewState::AppDrawerView:
                setSwipeState(SwipeState::SwipingAppDrawerGrid);
                // don't call cancelAppDrawerAnimations(), so we don't have it half open
            case ViewState::FolderView:
            case ViewState::SettingsView:
                // no vertical behaviour in folder or settings view
            default:
                break;
            }
        }
    }
}

void HomeScreenState::cancelAppDrawerAnimations()
{
    m_openAppDrawerAnim->stop();
    m_closeAppDrawerAnim->stop();
}

void HomeScreenState::cancelSearchWidgetAnimations()
{
    m_openSearchWidgetAnim->stop();
    m_closeSearchWidgetAnim->stop();
}
