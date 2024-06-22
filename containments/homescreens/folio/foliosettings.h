// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include <Plasma/Applet>

#include "homescreen.h"

class HomeScreen;

class FolioSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int homeScreenRows READ homeScreenRows WRITE setHomeScreenRows NOTIFY homeScreenRowsChanged)
    Q_PROPERTY(int homeScreenColumns READ homeScreenColumns WRITE setHomeScreenColumns NOTIFY homeScreenColumnsChanged)
    Q_PROPERTY(bool showPagesAppLabels READ showPagesAppLabels WRITE setShowPagesAppLabels NOTIFY showPagesAppLabelsChanged)
    Q_PROPERTY(bool showFavouritesAppLabels READ showFavouritesAppLabels WRITE setShowFavouritesAppLabels NOTIFY showFavouritesAppLabelsChanged)
    Q_PROPERTY(int delegateIconSize READ delegateIconSize WRITE setDelegateIconSize NOTIFY delegateIconSizeChanged)
    Q_PROPERTY(bool showFavouritesBarBackground READ showFavouritesBarBackground WRITE setShowFavouritesBarBackground NOTIFY showFavouritesBarBackgroundChanged)
    Q_PROPERTY(
        FolioSettings::PageTransitionEffect pageTransitionEffect READ pageTransitionEffect WRITE setPageTransitionEffect NOTIFY pageTransitionEffectChanged)
    Q_PROPERTY(bool showWallpaperBlur READ showWallpaperBlur WRITE setShowWallpaperBlur NOTIFY showWallpaperBlurChanged)

public:
    FolioSettings(HomeScreen *parent = nullptr);

    // ensure that existing enum values are the same when modifying, since this value is saved
    enum PageTransitionEffect {
        SlideTransition = 0,
        CubeTransition = 1,
        FadeTransition = 2,
        StackTransition = 3,
        RotationTransition = 4,
    };
    Q_ENUM(PageTransitionEffect)

    // number of rows and columns in the config for the homescreen
    // NOTE: use HomeScreenState.pageRows() instead in UI logic since we may have the rows and
    //       columns swapped (in landscape layouts)
    int homeScreenRows() const;
    void setHomeScreenRows(int homeScreenRows);

    int homeScreenColumns() const;
    void setHomeScreenColumns(int homeScreenColumns);

    bool showPagesAppLabels() const;
    void setShowPagesAppLabels(bool showPagesAppLabels);

    bool showFavouritesAppLabels() const;
    void setShowFavouritesAppLabels(bool showFavouritesAppLabels);

    int delegateIconSize() const;
    void setDelegateIconSize(int delegateIconSize);

    bool showFavouritesBarBackground() const;
    void setShowFavouritesBarBackground(bool showFavouritesBarBackground);

    PageTransitionEffect pageTransitionEffect() const;
    void setPageTransitionEffect(PageTransitionEffect pageTransitionEffect);

    bool showWallpaperBlur() const;
    void setShowWallpaperBlur(bool showWallpaperBlur);

    Q_INVOKABLE void load();

    Q_INVOKABLE bool saveLayoutToFile(QString path);
    Q_INVOKABLE bool loadLayoutFromFile(QString path);

Q_SIGNALS:
    void homeScreenRowsChanged();
    void homeScreenColumnsChanged();
    void showPagesAppLabelsChanged();
    void showFavouritesAppLabelsChanged();
    void delegateIconSizeChanged();
    void showFavouritesBarBackgroundChanged();
    void pageTransitionEffectChanged();
    void showWallpaperBlurChanged();

private:
    void save();

    HomeScreen *m_homeScreen{nullptr};

    int m_homeScreenRows{5};
    int m_homeScreenColumns{4};
    bool m_showPagesAppLabels{false};
    bool m_showFavouritesAppLabels{false};
    qreal m_delegateIconSize{48};
    bool m_showFavouritesBarBackground{false};
    PageTransitionEffect m_pageTransitionEffect{SlideTransition};
    bool m_showWallpaperBlur{false};
};
