// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include <Plasma/Applet>

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

public:
    FolioSettings(QObject *parent = nullptr);

    static FolioSettings *self();

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

    Q_INVOKABLE void load();

    Q_INVOKABLE bool saveLayoutToFile(QString path);
    Q_INVOKABLE bool loadLayoutFromFile(QString path);

    Q_INVOKABLE void setApplet(Plasma::Applet *applet);

Q_SIGNALS:
    void homeScreenRowsChanged();
    void homeScreenColumnsChanged();
    void showPagesAppLabelsChanged();
    void showFavouritesAppLabelsChanged();
    void delegateIconSizeChanged();
    void showFavouritesBarBackgroundChanged();
    void pageTransitionEffectChanged();

private:
    void save();

    int m_homeScreenRows{5};
    int m_homeScreenColumns{4};
    bool m_showPagesAppLabels{false};
    bool m_showFavouritesAppLabels{false};
    qreal m_delegateIconSize{48};
    bool m_showFavouritesBarBackground{false};
    PageTransitionEffect m_pageTransitionEffect{SlideTransition};

    Plasma::Applet *m_applet{nullptr};
};
