// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "qqml.h"
#include <QObject>
#include <QPropertyAnimation>

#include <Plasma/Applet>

#include "dragstate.h"
#include "homescreen.h"

class DragState;
class HomeScreen;

/**
 * @short The homescreen state, containing information on positioning panels as well as any swipe events.
 *
 * @author Devin Lin <devin@kde.org>
 */

class HomeScreenState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(HomeScreenState::SwipeState swipeState READ swipeState NOTIFY swipeStateChanged)
    Q_PROPERTY(HomeScreenState::ViewState viewState READ viewState NOTIFY viewStateChanged)
    Q_PROPERTY(DragState *dragState READ dragState CONSTANT)

    Q_PROPERTY(qreal viewWidth READ viewWidth WRITE setViewWidth NOTIFY viewWidthChanged)
    Q_PROPERTY(qreal viewHeight READ viewHeight WRITE setViewHeight NOTIFY viewHeightChanged)
    Q_PROPERTY(qreal viewTopPadding READ viewTopPadding WRITE setViewTopPadding NOTIFY viewTopPaddingChanged)
    Q_PROPERTY(qreal viewBottomPadding READ viewBottomPadding WRITE setViewBottomPadding NOTIFY viewBottomPaddingChanged)
    Q_PROPERTY(qreal viewLeftPadding READ viewLeftPadding WRITE setViewLeftPadding NOTIFY viewLeftPaddingChanged)
    Q_PROPERTY(qreal viewRightPadding READ viewRightPadding WRITE setViewRightPadding NOTIFY viewRightPaddingChanged)

    Q_PROPERTY(HomeScreenState::PageOrientation pageOrientation READ pageOrientation NOTIFY pageOrientationChanged)
    Q_PROPERTY(HomeScreenState::FavouritesBarLocation favouritesBarLocation READ favouritesBarLocation NOTIFY favouritesBarLocationChanged)
    Q_PROPERTY(int pageRows READ pageRows NOTIFY pageRowsChanged)
    Q_PROPERTY(int pageColumns READ pageColumns NOTIFY pageColumnsChanged)

    // page measurements
    Q_PROPERTY(qreal pageViewX READ pageViewX WRITE setPageViewX NOTIFY pageViewXChanged)
    Q_PROPERTY(qreal pageWidth READ pageWidth WRITE setPageWidth NOTIFY pageWidthChanged)
    Q_PROPERTY(qreal pageHeight READ pageHeight WRITE setPageHeight NOTIFY pageHeightChanged)
    Q_PROPERTY(qreal pageContentWidth READ pageContentWidth NOTIFY pageContentWidthChanged)
    Q_PROPERTY(qreal pageContentHeight READ pageContentHeight NOTIFY pageContentHeightChanged)

    // cell measurements
    Q_PROPERTY(qreal pageCellWidth READ pageCellWidth NOTIFY pageCellWidthChanged)
    Q_PROPERTY(qreal pageCellHeight READ pageCellHeight NOTIFY pageCellHeightChanged)
    Q_PROPERTY(qreal pageDelegateLabelHeight READ pageDelegateLabelHeight WRITE setPageDelegateLabelHeight NOTIFY pageDelegateLabelHeightChanged)
    Q_PROPERTY(qreal pageDelegateLabelSpacing READ pageDelegateLabelSpacing WRITE setPageDelegateLabelSpacing NOTIFY pageDelegateLabelSpacingChanged)

    // folder measurements and state
    Q_PROPERTY(qreal folderViewX READ folderViewX WRITE setFolderViewX NOTIFY folderViewXChanged)
    Q_PROPERTY(qreal folderPageWidth READ folderPageWidth WRITE setFolderPageWidth NOTIFY folderPageWidthChanged)
    Q_PROPERTY(qreal folderPageHeight READ folderPageHeight WRITE setFolderPageHeight NOTIFY folderPageHeightChanged)
    Q_PROPERTY(qreal folderPageContentWidth READ folderPageContentWidth WRITE setFolderPageContentWidth NOTIFY folderPageContentWidthChanged)
    Q_PROPERTY(qreal folderPageContentHeight READ folderPageContentHeight WRITE setFolderPageContentHeight NOTIFY folderPageContentHeightChanged)
    Q_PROPERTY(qreal folderOpenProgress READ folderOpenProgress WRITE setFolderOpenProgress NOTIFY folderOpenProgressChanged)
    Q_PROPERTY(FolioApplicationFolder *currentFolder READ currentFolderRaw NOTIFY currentFolderChanged)
    Q_PROPERTY(qreal folderGridLength READ folderGridLength NOTIFY folderGridLengthChanged)

    Q_PROPERTY(qreal settingsOpenProgress READ settingsOpenProgress WRITE setSettingsOpenProgress NOTIFY settingsOpenProgressChanged)

    Q_PROPERTY(qreal appDrawerOpenProgress READ appDrawerOpenProgress NOTIFY appDrawerOpenProgressChanged)
    Q_PROPERTY(qreal appDrawerY READ appDrawerY WRITE setAppDrawerY NOTIFY appDrawerYChanged)

    Q_PROPERTY(qreal searchWidgetOpenProgress READ searchWidgetOpenProgress NOTIFY searchWidgetOpenProgressChanged)
    Q_PROPERTY(qreal searchWidgetY READ searchWidgetY WRITE setSearchWidgetY NOTIFY searchWidgetYChanged)

    Q_PROPERTY(qreal delegateDragX READ delegateDragX NOTIFY delegateDragXChanged)
    Q_PROPERTY(qreal delegateDragY READ delegateDragY NOTIFY delegateDragYChanged)

    Q_PROPERTY(int currentPage READ currentPage NOTIFY pageNumChanged)
    Q_PROPERTY(int currentFolderPage READ currentFolderPage NOTIFY folderPageNumChanged)

public:
    enum SwipeState {
        None,
        DeterminingSwipeType,
        SwipingPages, // main homescreen view
        SwipingOpenAppDrawer,
        SwipingCloseAppDrawer,
        SwipingAppDrawerGrid,
        SwipingOpenSearchWidget,
        SwipingCloseSearchWidget,
        SwipingFolderPages,
        AwaitingDraggingDelegate,
        DraggingDelegate,
    };
    Q_ENUM(SwipeState)

    enum ViewState {
        SearchWidgetView,
        PageView,
        AppDrawerView,
        FolderView,
        SettingsView,
    };
    Q_ENUM(ViewState)

    enum FavouritesBarLocation { Bottom, Left, Right };
    Q_ENUM(FavouritesBarLocation)

    enum PageOrientation {
        RegularPosition, // rows and columns are read as normal
        RotateClockwise, // swap the rows and columns
        RotateCounterClockwise, // swap the rows and columns, and then flip the rows
        RotateUpsideDown, // flip the rows and flip the columns
    };
    Q_ENUM(PageOrientation)

    HomeScreenState(HomeScreen *parent = nullptr);
    void init(); // separate function due to dependencies on other classes

    // the current state of swipe interaction
    SwipeState swipeState() const;

    // the current view
    ViewState viewState() const;

    // drag state object
    DragState *dragState() const;

    qreal viewWidth() const;
    void setViewWidth(qreal viewWidth);

    qreal viewHeight() const;
    void setViewHeight(qreal viewHeight);

    qreal viewTopPadding() const;
    void setViewTopPadding(qreal viewTopPadding);

    qreal viewBottomPadding() const;
    void setViewBottomPadding(qreal viewBottomPadding);

    qreal viewLeftPadding() const;
    void setViewLeftPadding(qreal viewLeftPadding);

    qreal viewRightPadding() const;
    void setViewRightPadding(qreal viewRightPadding);

    // whether to swap rows and columns in the layout
    // this happens if the width of the screen is larger than the height
    PageOrientation pageOrientation() const;
    void setPageOrientation(PageOrientation pageOrientation);

    FavouritesBarLocation favouritesBarLocation() const;

    // the number of rows on a page
    int pageRows() const;

    // the number of columns on a page
    int pageColumns() const;

    // the current horizontal position of the pageview
    // starts at 0, each page is m_pageWidth wide
    // first page is at -m_pageWidth, second is at -m_pageWidth * 2, etc.
    qreal pageViewX() const;
    void setPageViewX(qreal pageViewX);

    // the width of a single pageview page (set from QML)
    qreal pageWidth() const;
    void setPageWidth(qreal pageWidth);

    qreal pageHeight() const;
    void setPageHeight(qreal pageHeight);

    qreal pageContentWidth() const;
    void calculatePageContentWidth();

    qreal pageContentHeight() const;
    void calculatePageContentHeight();

    qreal pageCellWidth() const;
    void calculatePageCellWidth();

    qreal pageCellHeight() const;
    void calculatePageCellHeight();

    qreal pageDelegateLabelHeight() const;
    void setPageDelegateLabelHeight(qreal pageDelegateLabelHeight);

    qreal pageDelegateLabelSpacing() const;
    void setPageDelegateLabelSpacing(qreal pageDelegateLabelSpacing);

    qreal folderViewX() const;
    void setFolderViewX(qreal folderViewX);

    qreal folderPageWidth() const;
    void setFolderPageWidth(qreal folderPageWidth);

    qreal folderPageHeight() const;
    void setFolderPageHeight(qreal folderPageHeight);

    qreal folderPageContentWidth() const;
    void setFolderPageContentWidth(qreal folderPageContentWidth);

    qreal folderPageContentHeight() const;
    void setFolderPageContentHeight(qreal folderPageContentHeight);

    qreal folderOpenProgress() const;
    void setFolderOpenProgress(qreal folderOpenProgress);

    int folderGridLength() const;
    void calculateFolderGridLength();

    std::shared_ptr<FolioApplicationFolder> currentFolder() const;
    FolioApplicationFolder *currentFolderRaw() const;
    void setCurrentFolder(std::shared_ptr<FolioApplicationFolder> folder);

    // the progress for the opening of the settings view
    qreal settingsOpenProgress();
    void setSettingsOpenProgress(qreal settingsOpenProgress);

    // between 0-1, the progress for the opening of the app drawer
    qreal appDrawerOpenProgress();

    // the position of the app drawer
    // 0: the app drawer is open
    // APP_DRAWER_OPEN_DIST: - the app drawer is closed
    qreal appDrawerY();
    void setAppDrawerY(qreal appDrawerY);

    // between 0-1, the progress for the opening of the search widget
    qreal searchWidgetOpenProgress();

    // the position of the search widget
    // 0: the search widget
    // SEARCH_WIDGET_OPEN_DIST: - the app drawer is closed
    qreal searchWidgetY();
    void setSearchWidgetY(qreal searchWidgetY);

    // the top left x-position of the delegate being dragged
    qreal delegateDragX();
    void setDelegateDragX(qreal delegateDragX);

    // the top left y-position of the delegate being dragged
    qreal delegateDragY();
    void setDelegateDragY(qreal delegateDragY);

    // the offset from delegateDragX where the mouse/finger is
    qreal delegateDragPointerOffsetX();
    void setDelegateDragPointerOffsetX(qreal delegateDragPointerOffsetX);

    // the offset from delegateDragY where the mouse/finger is
    qreal delegateDragPointerOffsetY();
    void setDelegateDragPointerOffsetY(qreal delegateDragPointerOffsetY);

    int currentPage();
    void setCurrentPage(int currentPage);

    int currentFolderPage();

    // QML helpers
    Q_INVOKABLE FolioDelegate *getPageDelegateAt(int page, int row, int column);
    Q_INVOKABLE FolioDelegate *getFavouritesDelegateAt(int position);
    Q_INVOKABLE FolioDelegate *getFolderDelegateAt(int position);
    Q_INVOKABLE QPointF getPageDelegateScreenPosition(int page, int row, int column);
    Q_INVOKABLE QPointF getFavouritesDelegateScreenPosition(int position);
    Q_INVOKABLE QPointF getFolderDelegateScreenPosition(int position);

Q_SIGNALS:
    void swipeStateChanged();
    void viewStateChanged();
    void viewWidthChanged();
    void viewHeightChanged();
    void viewTopPaddingChanged();
    void viewBottomPaddingChanged();
    void viewLeftPaddingChanged();
    void viewRightPaddingChanged();
    void pageOrientationChanged();
    void favouritesBarLocationChanged();
    void pageRowsChanged();
    void pageColumnsChanged();
    void pageViewXChanged();
    void pageWidthChanged();
    void pageHeightChanged();
    void pageContentWidthChanged();
    void pageContentHeightChanged();
    void pageCellWidthChanged();
    void pageCellHeightChanged();
    void pageDelegateLabelHeightChanged();
    void pageDelegateLabelSpacingChanged();
    void folderViewXChanged();
    void folderPageWidthChanged();
    void folderPageHeightChanged();
    void folderPageContentWidthChanged();
    void folderPageContentHeightChanged();
    void folderOpenProgressChanged();
    void folderGridLengthChanged();
    void currentFolderChanged();
    void settingsOpenProgressChanged();
    void appDrawerOpenProgressChanged();
    void appDrawerYChanged();
    void appDrawerClosed();
    void appDrawerOpened();
    void searchWidgetOpenProgressChanged();
    void searchWidgetYChanged();
    void delegateDragXChanged();
    void delegateDragYChanged();
    void delegateDragEnded();
    void delegateDragFromPageStarted(int page, int row, int column);
    void delegateDragFromFavouritesStarted(int position);
    void delegateDragFromAppDrawerStarted(QString storageId);
    void delegateDragFromFolderStarted(FolioApplicationFolder *folder, int position);
    void delegateDragFromWidgetListStarted(QString appletPluginId);
    void pageNumChanged();
    void folderPageNumChanged();

    void leftCurrentFolder();
    void folderAboutToOpen(qreal x, qreal y); // the position on the screen where the delegate is at, for animations
    void appDrawerGridYChanged(qreal y);
    void appDrawerGridFlickRequested();

public Q_SLOTS:
    void openAppDrawer();
    void closeAppDrawer();
    void openSearchWidget();
    void closeSearchWidget();

    void goToPage(int page, bool snap);

    void goToFolderPage(int page, bool snap);
    void openFolder(qreal delegateX, qreal delegateY, FolioApplicationFolder *folder);
    void closeFolder();

    void openSettingsView();
    void closeSettingsView();

    void startDelegatePageDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY, int page, int row, int column);
    void startDelegateFavouritesDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY, int position);
    void startDelegateAppDrawerDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY, QString storageId);
    void startDelegateFolderDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY, FolioApplicationFolder *folder, int position);
    void startDelegateWidgetListDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY, QString appletPluginId);
    void cancelDelegateDrag();

    // from SwipeArea
    void swipeStarted(qreal deltaX, qreal deltaY);
    void swipeEnded();
    void swipeCancelled();
    void swipeMoved(qreal totalDeltaX, qreal totalDeltaY, qreal deltaX, qreal deltaY);

private:
    void setViewState(ViewState viewState);
    void setSwipeState(SwipeState swipeState);

    void setAppDrawerOpenProgress(qreal progress);
    void setSearchWidgetOpenProgress(qreal progress);

    void startDelegateDrag(qreal startX, qreal startY, qreal pointerOffsetX, qreal pointerOffsetY);

    void cancelAppDrawerAnimations();
    void cancelSearchWidgetAnimations();

    // check if we passed the swipe threshold, and determine the swipe type after
    void determineSwipeTypeAfterThreshold(qreal totalDeltaX, qreal totalDeltaY);

    QPropertyAnimation *setupAnimation(QByteArray property, int duration, QEasingCurve::Type curve, qreal endValue);

    HomeScreen *m_homeScreen{nullptr};

    SwipeState m_swipeState{SwipeState::None};
    ViewState m_viewState{ViewState::PageView};

    DragState *m_dragState{nullptr};

    qreal m_viewWidth{0};
    qreal m_viewHeight{0};
    qreal m_viewTopPadding{0};
    qreal m_viewBottomPadding{0};
    qreal m_viewLeftPadding{0};
    qreal m_viewRightPadding{0};

    PageOrientation m_pageOrientation{PageOrientation::RegularPosition};

    qreal m_pageViewX{0};
    qreal m_pageWidth{0};
    qreal m_pageHeight{0};
    qreal m_pageContentWidth{0};
    qreal m_pageContentHeight{0};

    qreal m_pageCellWidth{0};
    qreal m_pageCellHeight{0};
    qreal m_pageDelegateLabelHeight{0};
    qreal m_pageDelegateLabelSpacing{0};

    qreal m_folderViewX{0};
    qreal m_folderPageWidth{0};
    qreal m_folderPageHeight{0};
    qreal m_folderPageContentWidth{0};
    qreal m_folderPageContentHeight{0};
    qreal m_folderOpenProgress{0};
    std::shared_ptr<FolioApplicationFolder> m_currentFolder{nullptr};
    int m_folderGridLength{0};

    qreal m_settingsOpenProgress{0};

    qreal m_appDrawerOpenProgress{0};
    qreal m_appDrawerY{0};
    qreal m_searchWidgetOpenProgress{0};
    qreal m_searchWidgetY{0};
    qreal m_delegateDragX{0};
    qreal m_delegateDragY{0};
    qreal m_delegateDragPointerOffsetX{0};
    qreal m_delegateDragPointerOffsetY{0};

    int m_pageNum{0};
    int m_folderPageNum{0};

    bool m_movingUp{false};
    bool m_movingRight{false};

    QPropertyAnimation *m_openAppDrawerAnim{nullptr};
    QPropertyAnimation *m_closeAppDrawerAnim{nullptr};
    QPropertyAnimation *m_openSearchWidgetAnim{nullptr};
    QPropertyAnimation *m_closeSearchWidgetAnim{nullptr};
    QPropertyAnimation *m_pageAnim{nullptr};
    QPropertyAnimation *m_openFolderAnim{nullptr};
    QPropertyAnimation *m_closeFolderAnim{nullptr};
    QPropertyAnimation *m_folderPageAnim{nullptr};
    QPropertyAnimation *m_openSettingsAnim{nullptr};
    QPropertyAnimation *m_closeSettingsAnim{nullptr};
};
