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

public:
    FolioSettings(QObject *parent = nullptr);

    static FolioSettings *self();

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

    Q_INVOKABLE void load();

    Q_INVOKABLE void setApplet(Plasma::Applet *applet);

Q_SIGNALS:
    void homeScreenRowsChanged();
    void homeScreenColumnsChanged();
    void showPagesAppLabelsChanged();
    void showFavouritesAppLabelsChanged();
    void delegateIconSizeChanged();
    void showFavouritesBarBackgroundChanged();

private:
    void save();

    int m_homeScreenRows{5};
    int m_homeScreenColumns{4};
    bool m_showPagesAppLabels{false};
    bool m_showFavouritesAppLabels{false};
    qreal m_delegateIconSize{48};
    bool m_showFavouritesBarBackground{false};

    Plasma::Applet *m_applet{nullptr};
};
