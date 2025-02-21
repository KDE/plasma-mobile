// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QTimer>

#include "folioapplicationfolder.h"
#include "foliodelegate.h"
#include "homescreen.h"
#include "homescreenstate.h"

class HomeScreen;
class HomeScreenState;

class DelegateDragPosition : public QObject
{
    Q_OBJECT
    Q_PROPERTY(DelegateDragPosition::Location location READ location NOTIFY locationChanged)
    Q_PROPERTY(int page READ page NOTIFY pageChanged)
    Q_PROPERTY(int pageRow READ pageRow NOTIFY pageRowChanged)
    Q_PROPERTY(int pageColumn READ pageColumn NOTIFY pageColumnChanged)
    Q_PROPERTY(int favouritesPosition READ favouritesPosition NOTIFY favouritesPositionChanged)
    Q_PROPERTY(int folderPosition READ folderPosition NOTIFY folderPositionChanged)
    Q_PROPERTY(FolioApplicationFolder *folder READ folderRaw NOTIFY folderChanged)

public:
    enum Location { Pages, Favourites, AppDrawer, Folder, WidgetList };
    Q_ENUM(Location)

    DelegateDragPosition(QObject *parent = nullptr);
    ~DelegateDragPosition();

    void copyFrom(DelegateDragPosition *position);

    Location location() const;
    void setLocation(Location location);

    int page() const;
    void setPage(int page);

    int pageRow() const;
    void setPageRow(int pageRow);

    int pageColumn() const;
    void setPageColumn(int pageColumn);

    int favouritesPosition() const;
    void setFavouritesPosition(int favouritesPosition);

    int folderPosition() const;
    void setFolderPosition(int folderPosition);

    // TODO: what if the folder becomes invalid? we need to clear it
    std::shared_ptr<FolioApplicationFolder> folder() const;
    FolioApplicationFolder *folderRaw() const;
    void setFolder(std::shared_ptr<FolioApplicationFolder> folder);

Q_SIGNALS:
    void locationChanged();
    void pageChanged();
    void pageRowChanged();
    void pageColumnChanged();
    void favouritesPositionChanged();
    void folderPositionChanged();
    void folderChanged();

private:
    Location m_location{DelegateDragPosition::Pages};
    int m_page{0};
    int m_pageRow{0};
    int m_pageColumn{0};
    int m_favouritesPosition{0};
    int m_folderPosition{0};
    std::shared_ptr<FolioApplicationFolder> m_folder{nullptr};
};

Q_DECLARE_METATYPE(DelegateDragPosition);

class DragState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(DelegateDragPosition *candidateDropPosition READ candidateDropPosition CONSTANT)
    Q_PROPERTY(DelegateDragPosition *startPosition READ startPosition CONSTANT)
    Q_PROPERTY(FolioDelegate *dropDelegate READ dropDelegateRaw NOTIFY dropDelegateChanged)

public:
    DragState(HomeScreenState *state = nullptr, HomeScreen *parent = nullptr);

    DelegateDragPosition *candidateDropPosition() const;
    DelegateDragPosition *startPosition() const;

    std::shared_ptr<FolioDelegate> dropDelegate() const;
    FolioDelegate *dropDelegateRaw() const;
    void setDropDelegate(std::shared_ptr<FolioDelegate> dropDelegate);

Q_SIGNALS:
    void dropDelegateChanged();
    void delegateDroppedAndPlaced();

    // if you drop a new delegate on an invalid spot
    void newDelegateDropAbandoned();

private Q_SLOTS:
    void onDelegateDragPositionChanged();
    void onDelegateDragPositionOverFolderViewChanged();
    void onDelegateDragPositionOverFavouritesChanged();
    void onDelegateDragPositionOverPageViewChanged();

    void onDelegateDraggingStarted();
    void onDelegateDragFromPageStarted(int page, int row, int column);
    void onDelegateDragFromFavouritesStarted(int position);
    void onDelegateDragFromAppDrawerStarted(QString storageId);
    void onDelegateDragFromFolderStarted(FolioApplicationFolder *folder, int position);
    void onDelegateDragFromWidgetListStarted(QString appletPluginId);
    void onDelegateDropped();

    void onLeaveCurrentFolder();

    void onChangePageTimerFinished();
    void onOpenFolderTimerFinished();
    void onLeaveFolderTimerFinished();
    void onChangeFolderPageTimerFinished();
    void onFolderInsertBetweenTimerFinished();
    void onFavouritesInsertBetweenTimerFinished();

private:
    // deletes the delegate at m_startPosition
    void deleteStartPositionDelegate();

    // places the delegate at m_candidateDropPosition, returning whether it was successful
    bool createDropPositionDelegate();

    // whether m_startPosition = m_candidateDropPosition
    bool isStartPositionEqualDropPosition();

    // we need to adjust so that the coord is in the center of the delegate
    qreal getDraggedDelegateX();
    qreal getDraggedDelegateY();

    // position of the dragging pointer
    qreal getPointerX();
    qreal getPointerY();

    HomeScreen *m_homeScreen{nullptr};
    HomeScreenState *m_state{nullptr};

    QTimer *m_changePageTimer{nullptr};
    QTimer *m_openFolderTimer{nullptr};
    QTimer *m_leaveFolderTimer{nullptr};
    QTimer *m_changeFolderPageTimer{nullptr};

    // inserting between apps in a folder
    QTimer *m_folderInsertBetweenTimer{nullptr};
    int m_folderInsertBetweenIndex{0};

    // inserting between apps in the favourites strip
    QTimer *m_favouritesInsertBetweenTimer{nullptr};
    int m_favouritesInsertBetweenIndex{0};

    // the delegate that is being dropped
    std::shared_ptr<FolioDelegate> m_dropDelegate{nullptr};

    // where we are hovering over, potentially to drop the delegate
    DelegateDragPosition *const m_candidateDropPosition{nullptr};

    // this is the original start position of the drag
    DelegateDragPosition *const m_startPosition{nullptr};

    // when dropping a new widget, this is the applet name
    QString m_createdAppletPluginId{};
};
