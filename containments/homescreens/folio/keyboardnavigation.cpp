// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "keyboardnavigation.h"

KeyboardNavigation::KeyboardNavigation(HomeScreen *parent)
    : QObject{parent}
    , m_homeScreen{parent}
{
    connect(m_homeScreen->homeScreenState(), &HomeScreenState::viewStateChanged, this, [this]() {
        switch (m_homeScreen->homeScreenState()->viewState()) {
        case HomeScreenState::FolderView:
            // Select first delegate in folder if moving from homescreen pages.
            if (m_focusedDelegate != nullptr && m_focusedDelegateViewState == DelegateLocation::PageView) {
                FolioApplicationFolder::Ptr folder = m_homeScreen->homeScreenState()->currentFolder();

                if (folder && folder->applications()->getDelegate(0)) {
                    setFocusedDelegate(folder->applications()->getDelegate(0), DelegateLocation::FolderView);
                }
            }
            break;
        case HomeScreenState::PageView:
            // TODO reselect folder when moving out of it
            break;
        case HomeScreenState::SearchWidgetView:
        case HomeScreenState::SettingsView:
        case HomeScreenState::AppDrawerView:
        default:
            // Reset focused delegate if we move outside of the folder or pages view.
            setFocusedDelegate(nullptr);
            break;
        }
    });
}

FolioDelegate *KeyboardNavigation::focusedDelegate() const
{
    return m_focusedDelegate.get();
}

void KeyboardNavigation::setFocusedDelegate(FolioDelegate::Ptr delegate, KeyboardNavigation::DelegateLocation viewState)
{
    if (delegate != m_focusedDelegate) {
        m_focusedDelegateViewState = viewState;
        m_focusedDelegate = delegate;
        Q_EMIT focusedDelegateChanged();

        // TODO
        qDebug() << "selected delegate" << delegate.get();
    }
}

void KeyboardNavigation::navigateFromAppDrawer()
{
    HomeScreenState *homeScreenState = m_homeScreen->homeScreenState();
    PageListModel *pageListModel = m_homeScreen->pageListModel();
    FavouritesModel *favouritesModel = m_homeScreen->favouritesModel();

    PageModel *currentPage = pageListModel->getPage(homeScreenState->currentPage());
    if (!currentPage) {
        setFocusedDelegate(nullptr);
        return;
    }

    switch (homeScreenState->favouritesBarLocation()) {
    case HomeScreenState::FavouritesBarLocation::Bottom:
        setFocusedDelegate(favouritesModel->getEntryAt(0));

        if (!m_focusedDelegate) {
            // If there are no elements in the favourites model, just select an item on the current page.
            setFocusedDelegate(currentPage->getLastDelegate());
        }
        break;
    case HomeScreenState::FavouritesBarLocation::Left:
    case HomeScreenState::FavouritesBarLocation::Right:
        setFocusedDelegate(currentPage->getLastDelegate());
        break;
    default:
        break;
    }
}

void KeyboardNavigation::navigateFromSearchWidget()
{
    startKeyboardNavigateOnPage();
}

void KeyboardNavigation::startKeyboardNavigateOnPage()
{
    HomeScreenState *homeScreenState = m_homeScreen->homeScreenState();
    PageListModel *pageListModel = m_homeScreen->pageListModel();

    PageModel *currentPage = pageListModel->getPage(homeScreenState->currentPage());
    if (!currentPage) {
        setFocusedDelegate(nullptr);
        return;
    }

    // Select first delegate on page.
    setFocusedDelegate(currentPage->getFirstDelegate());
}

void KeyboardNavigation::moveKeyboardNavigate(Enums::Direction direction)
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

void KeyboardNavigation::moveKeyboardNavigateInFolder(Enums::Direction direction)
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
        setFocusedDelegate(neighbor, DelegateLocation::FolderView);
        homeScreenState->goToFolderPage(newPage, false); // Navigate to new page
        return;
    }

    // Otherwise, select the folder delegate itself and exit the folder.
    setFocusedDelegate(getFolioDelegateForFolder(homeScreenState->currentFolder()));
    homeScreenState->closeFolder();
}

void KeyboardNavigation::moveKeyboardNavigateInFavorites(Enums::Direction direction)
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
        case Enums::Direction::Up:
            // Go to bottom of current page
            setFocusedDelegate(currentPage->getLastDelegate());
            break;
        case Enums::Direction::Down:
            openAppDrawer();
            setFocusedDelegate(nullptr);
            break;
        case Enums::Direction::Left:
            if (index - 1 >= 0) {
                setFocusedDelegate(favouritesModel->getEntryAt(index - 1));
            }
            break;
        case Enums::Direction::Right:
            if (favouritesModel->rowCount() > index + 1) {
                setFocusedDelegate(favouritesModel->getEntryAt(index + 1));
            }
            break;
        default:
            break;
        }
        break;
    case HomeScreenState::FavouritesBarLocation::Left:
        switch (direction) {
        case Enums::Direction::Up:
            // Go up in favourites bar
            setFocusedDelegate(favouritesModel->getEntryAt(index - 1));
            if (!m_focusedDelegate) {
                homeScreenState->openSearchWidget();
            }
            break;
        case Enums::Direction::Down:
            // Go down in favourites bar
            setFocusedDelegate(favouritesModel->getEntryAt(index + 1));
            if (!m_focusedDelegate) {
                openAppDrawer();
            }
            break;
        case Enums::Direction::Left: {
            // Go to previous page
            homeScreenState->goToPage(homeScreenState->currentPage() - 1, false);
            PageModel *newCurrentPage = pageListModel->getPage(homeScreenState->currentPage());
            if (newCurrentPage != currentPage) {
                // Only set if page changed
                setFocusedDelegate(newCurrentPage->getLastDelegate());
            }
            break;
        }
        case Enums::Direction::Right:
            // Go to current page
            setFocusedDelegate(currentPage->getFirstDelegate());
            break;
        default:
            break;
        }
        break;
    case HomeScreenState::FavouritesBarLocation::Right:
        switch (direction) {
        case Enums::Direction::Up:
            // Go up in favourites bar
            setFocusedDelegate(favouritesModel->getEntryAt(index - 1));
            if (!m_focusedDelegate) {
                homeScreenState->openSearchWidget();
            }
            break;
        case Enums::Direction::Down:
            // Go down in favourites bar
            setFocusedDelegate(favouritesModel->getEntryAt(index + 1));
            if (!m_focusedDelegate) {
                openAppDrawer();
            }
            break;
        case Enums::Direction::Left:
            // Go to current page
            setFocusedDelegate(currentPage->getLastDelegate());
            break;
        case Enums::Direction::Right: {
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

void KeyboardNavigation::moveKeyboardNavigateInPage(Enums::Direction direction)
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
    FolioDelegate::Ptr nextDelegate = currentPage->getNeighborDelegate(m_focusedDelegate, direction);

    if (nextDelegate) {
        setFocusedDelegate(nextDelegate);
        return;
    }

    // If there is no delegate in this direction, we need to change view.
    switch (direction) {
    case Enums::Direction::Up:
        homeScreenState->openSearchWidget();
        break;
    case Enums::Direction::Down: {
        bool hasFavoritesBarNext = homeScreenState->favouritesBarLocation() == HomeScreenState::FavouritesBarLocation::Bottom;

        if (hasFavoritesBarNext) {
            setFocusedDelegate(favouritesModel->getEntryAt(0));
        }
        if (!m_focusedDelegate || !hasFavoritesBarNext) {
            // If favourites bar has no items, or it is not in this location, open app drawer.
            openAppDrawer();
        }
        break;
    }
    case Enums::Direction::Left: {
        bool hasFavoritesBarNext = homeScreenState->favouritesBarLocation() == HomeScreenState::FavouritesBarLocation::Left;

        if (hasFavoritesBarNext) {
            setFocusedDelegate(favouritesModel->getEntryAt(0));
        }
        if (!m_focusedDelegate || !hasFavoritesBarNext) {
            // If favourites bar has no items, or it is not in this location, go left a page.
            homeScreenState->goToPage(homeScreenState->currentPage() - 1, false);

            PageModel *newCurrentPage = pageListModel->getPage(homeScreenState->currentPage());
            if (newCurrentPage && newCurrentPage != currentPage) {
                // Select delegate on new page if page changed.
                setFocusedDelegate(newCurrentPage->getLastDelegate());
            }
        }
        break;
    }
    case Enums::Direction::Right: {
        bool hasFavoritesBarNext = homeScreenState->favouritesBarLocation() == HomeScreenState::FavouritesBarLocation::Right;

        if (hasFavoritesBarNext) {
            setFocusedDelegate(favouritesModel->getEntryAt(0));
        }
        if (!m_focusedDelegate || !hasFavoritesBarNext) {
            // If favourites bar has no items, or it is not in this location, go right a page.
            homeScreenState->goToPage(homeScreenState->currentPage() + 1, false);

            PageModel *newCurrentPage = pageListModel->getPage(homeScreenState->currentPage());
            if (newCurrentPage && newCurrentPage != currentPage) {
                // Select delegate on new page if page changed.
                setFocusedDelegate(newCurrentPage->getFirstDelegate());
            }
        }
        break;
    }
    default:
        break;
    }
}

void KeyboardNavigation::openAppDrawer()
{
    m_homeScreen->homeScreenState()->openAppDrawer();
    Q_EMIT requestAppDrawer();
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
