// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include "enums.h"
#include "folioapplicationfolder.h"
#include "foliodelegate.h"
#include "homescreen.h"

class FolioDelegate;
class FolioApplicationFolder;
class HomeScreen;

class KeyboardNavigation : public QObject
{
    Q_OBJECT
    Q_PROPERTY(FolioDelegate *focusedDelegate READ focusedDelegate NOTIFY focusedDelegateChanged)

public:
    KeyboardNavigation(HomeScreen *parent = nullptr);

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
    void setFocusedDelegate(std::shared_ptr<FolioDelegate> delegate);

Q_SIGNALS:
    void focusedDelegateChanged();

public Q_SLOTS:
    /**
     * Moves the focused homescreen delegate one position in the given direction.
     *
     * @param direction the direction to move in
     */
    void moveKeyboardNavigate(Direction direction);

private:
    void moveKeyboardNavigateInFolder(Direction direction);
    void moveKeyboardNavigateInFavorites(Direction direction);
    void moveKeyboardNavigateInPage(Direction direction);

    std::shared_ptr<FolioDelegate> getFolioDelegateForFolder(std::shared_ptr<FolioApplicationFolder> folder);

    std::shared_ptr<FolioDelegate> m_focusedDelegate{nullptr};

    HomeScreen *m_homeScreen;
};
