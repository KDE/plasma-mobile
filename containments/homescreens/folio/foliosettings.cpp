// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "foliosettings.h"

FolioSettings::FolioSettings(QObject *parent)
    : QObject{parent}
{
}

FolioSettings *FolioSettings::self()
{
    static FolioSettings *settings = new FolioSettings;
    return settings;
}

int FolioSettings::homeScreenRows() const
{
    // ensure that this is fetched fast and cached (it is called extremely often)
    return m_homeScreenRows;
}

void FolioSettings::setHomeScreenRows(int homeScreenRows)
{
    if (m_homeScreenRows != homeScreenRows) {
        m_homeScreenRows = homeScreenRows;
        Q_EMIT homeScreenRowsChanged();
        save();
    }
}

int FolioSettings::homeScreenColumns() const
{
    return m_homeScreenColumns;
}

void FolioSettings::setHomeScreenColumns(int homeScreenColumns)
{
    if (m_homeScreenColumns != homeScreenColumns) {
        m_homeScreenColumns = homeScreenColumns;
        Q_EMIT homeScreenColumnsChanged();
        save();
    }
}

bool FolioSettings::showPagesAppLabels() const
{
    return m_showPagesAppLabels;
}

void FolioSettings::setShowPagesAppLabels(bool showPagesAppLabels)
{
    if (m_showPagesAppLabels != showPagesAppLabels) {
        m_showPagesAppLabels = showPagesAppLabels;
        Q_EMIT showPagesAppLabelsChanged();
        save();
    }
}

bool FolioSettings::showFavouritesAppLabels() const
{
    return m_showFavouritesAppLabels;
}

void FolioSettings::setShowFavouritesAppLabels(bool showFavouritesAppLabels)
{
    if (m_showFavouritesAppLabels != showFavouritesAppLabels) {
        m_showFavouritesAppLabels = showFavouritesAppLabels;
        Q_EMIT showFavouritesAppLabelsChanged();
        save();
    }
}

int FolioSettings::delegateIconSize() const
{
    return m_delegateIconSize;
}

void FolioSettings::setDelegateIconSize(int delegateIconSize)
{
    if (m_delegateIconSize != delegateIconSize) {
        m_delegateIconSize = delegateIconSize;
        Q_EMIT delegateIconSizeChanged();
        save();
    }
}

bool FolioSettings::showFavouritesBarBackground() const
{
    return m_showFavouritesBarBackground;
}

void FolioSettings::setShowFavouritesBarBackground(bool showFavouritesBarBackground)
{
    if (m_showFavouritesBarBackground != showFavouritesBarBackground) {
        m_showFavouritesBarBackground = showFavouritesBarBackground;
        Q_EMIT showFavouritesBarBackgroundChanged();
        save();
    }
}

void FolioSettings::setApplet(Plasma::Applet *applet)
{
    m_applet = applet;
}

void FolioSettings::save()
{
    if (!m_applet) {
        return;
    }

    m_applet->config().writeEntry("homeScreenRows", m_homeScreenRows);
    m_applet->config().writeEntry("homeScreenColumns", m_homeScreenColumns);
    m_applet->config().writeEntry("showPagesAppLabels", m_showPagesAppLabels);
    m_applet->config().writeEntry("showFavouritesAppLabels", m_showFavouritesAppLabels);
    m_applet->config().writeEntry("delegateIconSize", m_delegateIconSize);
    m_applet->config().writeEntry("showFavouritesBarBackground", m_showFavouritesBarBackground);

    Q_EMIT m_applet->configNeedsSaving();
}

void FolioSettings::load()
{
    if (!m_applet) {
        return;
    }

    m_homeScreenRows = m_applet->config().readEntry("homeScreenRows", 5);
    m_homeScreenColumns = m_applet->config().readEntry("homeScreenColumns", 4);
    m_showPagesAppLabels = m_applet->config().readEntry("showPagesAppLabels", true);
    m_showFavouritesAppLabels = m_applet->config().readEntry("showFavoritesAppLabels", false);
    m_delegateIconSize = m_applet->config().readEntry("delegateIconSize", 48);
    m_showFavouritesBarBackground = m_applet->config().readEntry("showFavoritesBarBackground", true);

    Q_EMIT homeScreenRowsChanged();
    Q_EMIT homeScreenColumnsChanged();
    Q_EMIT showPagesAppLabels();
    Q_EMIT showFavouritesAppLabelsChanged();
    Q_EMIT delegateIconSizeChanged();
}
