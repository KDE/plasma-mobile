// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include "enums.h"
#include "folioapplicationfolder.h"
#include "foliodelegate.h"
#include "homescreen.h"
#include "homescreenstate.h"

class FolioDelegate;
class FolioApplicationFolder;
class HomeScreen;

class KeyboardNavigation : public QObject
{
    Q_OBJECT
    Q_PROPERTY(FolioDelegate *focusedDelegate READ focusedDelegate NOTIFY focusedDelegateChanged)

public:
    KeyboardNavigation(HomeScreen *parent = nullptr);

    // HACK: for now, since we can't have HomeScreenState dep
    enum DelegateLocation {
        PageView,
        FolderView
    };

    /**
     * Get the currently focused FolioDelegate. If the view is currently the search or app drawer,
     * then it will always return null (as keyboard control will be managed in QML).
     *
     * @returns the focused FolioDelegate
     */
    FolioDelegate *focusedDelegate() const;

    /**
     * Set the delegate that is the focus.
     *
     * @param delegate the delegate to focus on
     */
    void setFocusedDelegate(std::shared_ptr<FolioDelegate> delegate, DelegateLocation viewState = DelegateLocation::PageView);

Q_SIGNALS:
    void focusedDelegateChanged();

    void requestAppDrawer();

public Q_SLOTS:
    /**
     * Called by QML when keyboard navigation moves up from app drawer.
     */
    void navigateFromAppDrawer();

    /**
     * Called by QML when keyboard navigation moves down from search widget.
     */
    void navigateFromSearchWidget();

    /**
     * Called by QML to begin keyboard navigation on current page.
     */
    void startKeyboardNavigateOnPage();

    /**
     * Called by QML to move the focused homescreen delegate one position in the given direction.
     *
     * @param direction the direction to move in
     */
    void moveKeyboardNavigate(Enums::Direction direction);

private:
    void moveKeyboardNavigateInFolder(Enums::Direction direction);
    void moveKeyboardNavigateInFavorites(Enums::Direction direction);
    void moveKeyboardNavigateInPage(Enums::Direction direction);

    void openAppDrawer();
    std::shared_ptr<FolioDelegate> getFolioDelegateForFolder(std::shared_ptr<FolioApplicationFolder> folder);

    std::shared_ptr<FolioDelegate> m_focusedDelegate{nullptr};
    DelegateLocation m_focusedDelegateViewState{DelegateLocation::PageView};

    HomeScreen *m_homeScreen;
};
