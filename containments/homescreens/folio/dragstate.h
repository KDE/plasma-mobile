// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QTimer>

#include "folioapplicationfolder.h"
#include "foliodelegate.h"
#include "homescreenstate.h"

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
    Q_PROPERTY(FolioApplicationFolder *folder READ folder NOTIFY folderChanged)

public:
    enum Location { Pages, Favourites, AppDrawer, Folder };
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
    FolioApplicationFolder *folder() const;
    void setFolder(FolioApplicationFolder *folder);

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
    FolioApplicationFolder *m_folder{nullptr};
};

Q_DECLARE_METATYPE(DelegateDragPosition);

class DragState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(DelegateDragPosition *candidateDropPosition READ candidateDropPosition CONSTANT)
    Q_PROPERTY(DelegateDragPosition *startPosition READ startPosition CONSTANT)
    Q_PROPERTY(FolioDelegate *dropDelegate READ dropDelegate NOTIFY dropDelegateChanged)

public:
    DragState(HomeScreenState *state = nullptr, QObject *parent = nullptr);

    DelegateDragPosition *candidateDropPosition() const;
    DelegateDragPosition *startPosition() const;
    FolioDelegate *dropDelegate() const;
    void setDropDelegate(FolioDelegate *dropDelegate);

Q_SIGNALS:
    void dropDelegateChanged();
    void delegateDroppedAndPlaced();

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

    // deletes the delegate at m_candidateDropPosition
    void createDropPositionDelegate();

    // whether m_startPosition = m_candidateDropPosition
    bool isStartPositionEqualDropPosition();

    // we need to adjust so that the coord is in the center of the delegate
    qreal getDraggedDelegateX();
    qreal getDraggedDelegateY();

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
    FolioDelegate *m_dropDelegate{nullptr};

    // where we are hovering over, potentially to drop the delegate
    DelegateDragPosition *const m_candidateDropPosition{nullptr};

    // this is the original start position of the drag
    DelegateDragPosition *const m_startPosition{nullptr};

    HomeScreenState *m_state{nullptr};
};
