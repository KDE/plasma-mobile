// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "keyboardnavigation.h"

KeyboardNavigation::KeyboardNavigation(HomeScreen *parent)
    : QObject{parent}
    , m_homeScreen{parent}
{
}

FolioDelegate *KeyboardNavigation::focusedDelegate() const
{
    return m_focusedDelegate.get();
}

void KeyboardNavigation::setFocusedDelegate(FolioDelegate::Ptr delegate)
{
    if (delegate != m_focusedDelegate) {
        m_focusedDelegate = delegate;
        Q_EMIT focusedDelegateChanged();
    }
}

void KeyboardNavigation::moveKeyboardNavigate(Direction direction)
{
    HomeScreenState *homeScreenState = m_homeScreen->homeScreenState();
    FavouritesModel *favouritesModel = m_homeScreen->favouritesModel();

    if (homeScreenState->viewState() == HomeScreenState::SearchWidgetView || homeScreenState->viewState() == HomeScreenState::SettingsView
        || homeScreenState->viewState() == HomeScreenState::AppDrawerView) {
        // No behaviour, these are handled in the QML components themselves.
        setFocusedDelegate(nullptr);

    } else if (homeScreenState->viewState() == HomeScreenState::FolderView) {
        moveKeyboardNavigateInFolder(direction);

    } else if (homeScreenState->viewState() == HomeScreenState::PageView) {
        if (favouritesModel->contains(m_focusedDelegate)) {
            // If delegate is in the favourites bar.
            moveKeyboardNavigateInFavorites(direction);
        } else {
            // If delegate is on the current page.
            moveKeyboardNavigateInPage(direction);
        }
    }
}

void KeyboardNavigation::moveKeyboardNavigateInFolder(Direction direction)
{
    HomeScreenState *homeScreenState = m_homeScreen->homeScreenState();

    // If current folder is invalid, ignore.
    if (!homeScreenState->currentFolder()) {
        setFocusedDelegate(nullptr);
        return;
    }

    // Get neighbour of current delegate in the folder.
    auto pair = homeScreenState->currentFolder()->getNeighborDelegate(m_focusedDelegate, direction);
    FolioDelegate::Ptr neighbor = pair.first;
    int newPage = pair.second;

    // If neighbour exists, navigate to it.
    if (neighbor) {
        setFocusedDelegate(neighbor);
        homeScreenState->goToFolderPage(newPage, false); // Navigate to new page
        return;
    }

    // Otherwise, select the folder delegate itself and exit the folder.
    setFocusedDelegate(getFolioDelegateForFolder(homeScreenState->currentFolder()));
    homeScreenState->closeFolder();
}

void KeyboardNavigation::moveKeyboardNavigateInFavorites(Direction direction)
{
    HomeScreenState *homeScreenState = m_homeScreen->homeScreenState();
    FavouritesModel *favouritesModel = m_homeScreen->favouritesModel();
    PageListModel *pageListModel = m_homeScreen->pageListModel();

    int index = favouritesModel->indexOf(m_focusedDelegate);

    PageModel *currentPage = pageListModel->getPage(homeScreenState->currentPage());
    if (!currentPage) {
        setFocusedDelegate(nullptr);
        return;
    }

    // Handle each case for every position of the favourites bar.
    switch (homeScreenState->favouritesBarLocation()) {
    case HomeScreenState::FavouritesBarLocation::Bottom:
        switch (direction) {
        case Direction::Up:
            // Go to bottom of current page
            setFocusedDelegate(currentPage->getLastDelegate());
            break;
        case Direction::Down:
            homeScreenState->openAppDrawer();
            break;
        case Direction::Left:
            setFocusedDelegate(favouritesModel->getEntryAt(index - 1));
            break;
        case Direction::Right:
            setFocusedDelegate(favouritesModel->getEntryAt(index + 1));
            break;
        default:
            break;
        }
        break;
    case HomeScreenState::FavouritesBarLocation::Left:
        switch (direction) {
        case Direction::Up:
            // Go up in favourites bar
            setFocusedDelegate(favouritesModel->getEntryAt(index - 1));
            if (!m_focusedDelegate) {
                homeScreenState->openSearchWidget();
            }
            break;
        case Direction::Down:
            // Go down in favourites bar
            setFocusedDelegate(favouritesModel->getEntryAt(index + 1));
            if (!m_focusedDelegate) {
                homeScreenState->openAppDrawer();
            }
            break;
        case Direction::Left: {
            // Go to previous page
            homeScreenState->goToPage(homeScreenState->currentPage() - 1, false);
            PageModel *newCurrentPage = pageListModel->getPage(homeScreenState->currentPage());
            if (newCurrentPage != currentPage) {
                // Only set if page changed
                setFocusedDelegate(newCurrentPage->getLastDelegate());
            }
            break;
        }
        case Direction::Right:
            // Go to current page
            setFocusedDelegate(currentPage->getFirstDelegate());
            break;
        default:
            break;
        }
        break;
    case HomeScreenState::FavouritesBarLocation::Right:
        switch (direction) {
        case Direction::Up:
            // Go up in favourites bar
            setFocusedDelegate(favouritesModel->getEntryAt(index - 1));
            if (!m_focusedDelegate) {
                homeScreenState->openSearchWidget();
            }
            break;
        case Direction::Down:
            // Go down in favourites bar
            setFocusedDelegate(favouritesModel->getEntryAt(index + 1));
            if (!m_focusedDelegate) {
                homeScreenState->openAppDrawer();
            }
            break;
        case Direction::Left:
            // Go to current page
            setFocusedDelegate(currentPage->getLastDelegate());
            break;
        case Direction::Right: {
            // Go to next page
            homeScreenState->goToPage(homeScreenState->currentPage() + 1, false);
            PageModel *newCurrentPage = pageListModel->getPage(homeScreenState->currentPage());
            if (newCurrentPage != currentPage) {
                // Only set if page changed
                setFocusedDelegate(newCurrentPage->getFirstDelegate());
            }
            break;
        }
        default:
            break;
        }
        break;
    default:
        break;
    }
}

void KeyboardNavigation::moveKeyboardNavigateInPage(Direction direction)
{
    HomeScreenState *homeScreenState = m_homeScreen->homeScreenState();
    FavouritesModel *favouritesModel = m_homeScreen->favouritesModel();
    PageListModel *pageListModel = m_homeScreen->pageListModel();

    PageModel *currentPage = pageListModel->getPage(homeScreenState->currentPage());
    if (!currentPage) {
        setFocusedDelegate(nullptr);
        return;
    }

    if (!m_focusedDelegate) {
        // If there is no delegate, just set it to the first element.
        setFocusedDelegate(currentPage->getFirstDelegate());
        return;
    }

    // Set focused delegate to next neighbor in direction.
    setFocusedDelegate(currentPage->getNeighborDelegate(m_focusedDelegate, direction));

    // If there is no delegate in this direction, we need to change view.
    if (!m_focusedDelegate) {
        switch (direction) {
        case Direction::Up:
            homeScreenState->openSearchWidget();
            break;
        case Direction::Down:
            if (homeScreenState->favouritesBarLocation() == HomeScreenState::FavouritesBarLocation::Bottom) {
                setFocusedDelegate(favouritesModel->getEntryAt(0));
            }
            if (!m_focusedDelegate) {
                // If favourites bar has no items, or it is not in this location, open app drawer.
                homeScreenState->openAppDrawer();
            }
            break;
        case Direction::Left:
            if (homeScreenState->favouritesBarLocation() == HomeScreenState::FavouritesBarLocation::Left) {
                setFocusedDelegate(favouritesModel->getEntryAt(0));
            }
            if (!m_focusedDelegate) {
                // If favourites bar has no items, or it is not in this location, go left a page.
                homeScreenState->goToPage(homeScreenState->currentPage() - 1, false);

                PageModel *newCurrentPage = pageListModel->getPage(homeScreenState->currentPage());
                if (newCurrentPage && newCurrentPage != currentPage) {
                    // Select delegate on new page if page changed.
                    setFocusedDelegate(newCurrentPage->getLastDelegate());
                }
            }
            break;
        case Direction::Right:
            if (homeScreenState->favouritesBarLocation() == HomeScreenState::FavouritesBarLocation::Right) {
                setFocusedDelegate(favouritesModel->getEntryAt(0));
            }
            if (!m_focusedDelegate) {
                // If favourites bar has no items, or it is not in this location, go right a page.
                homeScreenState->goToPage(homeScreenState->currentPage() + 1, false);

                PageModel *newCurrentPage = pageListModel->getPage(homeScreenState->currentPage());
                if (newCurrentPage && newCurrentPage != currentPage) {
                    // Select delegate on new page if page changed.
                    setFocusedDelegate(newCurrentPage->getFirstDelegate());
                }
            }
            break;
        default:
            break;
        }
    }
}

FolioDelegate::Ptr KeyboardNavigation::getFolioDelegateForFolder(FolioApplicationFolder::Ptr folder)
{
    // Try to obtain FolioDelegate from favourites model
    FolioDelegate::Ptr delegate = m_homeScreen->favouritesModel()->getEntryFromFolder(folder);
    if (delegate) {
        return delegate;
    }

    // Otherwise, the folder is on a page
    for (int i = 0; i < m_homeScreen->pageListModel()->rowCount(); ++i) {
        PageModel *pageModel = m_homeScreen->pageListModel()->getPage(i);
        if (!pageModel) {
            continue;
        }

        FolioDelegate::Ptr delegate = std::static_pointer_cast<FolioDelegate>(pageModel->getDelegateFromFolder(folder));
        if (delegate) {
            return delegate;
        }
    }

    return nullptr;
}
