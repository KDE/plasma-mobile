// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "foliosettings.h"
#include "favouritesmodel.h"
#include "pagelistmodel.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QTextStream>

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

FolioSettings::PageTransitionEffect FolioSettings::pageTransitionEffect() const
{
    return m_pageTransitionEffect;
}

void FolioSettings::setPageTransitionEffect(PageTransitionEffect pageTransitionEffect)
{
    if (m_pageTransitionEffect != pageTransitionEffect) {
        m_pageTransitionEffect = pageTransitionEffect;
        Q_EMIT pageTransitionEffectChanged();
        save();
    }
}

bool FolioSettings::showWallpaperBlur() const
{
    return m_showWallpaperBlur;
}

void FolioSettings::setShowWallpaperBlur(bool showWallpaperBlur)
{
    if (m_showWallpaperBlur != showWallpaperBlur) {
        m_showWallpaperBlur = showWallpaperBlur;
        Q_EMIT showWallpaperBlurChanged();
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
    m_applet->config().writeEntry("pageTransitionEffect", (int)m_pageTransitionEffect);
    m_applet->config().writeEntry("showWallpaperBlur", m_showWallpaperBlur);

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
    m_pageTransitionEffect = static_cast<PageTransitionEffect>(m_applet->config().readEntry("pageTransitionEffect", (int)SlideTransition));
    m_showWallpaperBlur = m_applet->config().readEntry("showWallpaperBlur", true);

    Q_EMIT homeScreenRowsChanged();
    Q_EMIT homeScreenColumnsChanged();
    Q_EMIT showPagesAppLabels();
    Q_EMIT showFavouritesAppLabelsChanged();
    Q_EMIT delegateIconSizeChanged();
    Q_EMIT showWallpaperBlurChanged();
}

bool FolioSettings::saveLayoutToFile(QString path)
{
    if (path.startsWith(QStringLiteral("file://"))) {
        path = path.replace(QStringLiteral("file://"), QString());
    }

    QJsonArray favourites = FavouritesModel::self()->exportToJson();
    QJsonArray pages = PageListModel::self()->exportToJson();

    QJsonObject obj;
    obj[QStringLiteral("Favourites")] = favourites;
    obj[QStringLiteral("Pages")] = pages;

    QByteArray data = QJsonDocument(obj).toJson(QJsonDocument::Compact);

    QFile file{path};
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        file.write(data);
    } else {
        qDebug() << "failed to write to file:" << file.errorString();
        return false;
    }
    file.close();

    return true;
}

bool FolioSettings::loadLayoutFromFile(QString path)
{
    if (path.startsWith(QStringLiteral("file://"))) {
        path = path.replace(QStringLiteral("file://"), QString());
    }

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "failed to open file:" << file.errorString();
        return false;
    }

    QTextStream in(&file);
    QString contents = in.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(contents.toUtf8());
    QJsonObject obj = doc.object();

    // TODO error checking
    FavouritesModel::self()->loadFromJson(obj[QStringLiteral("Favourites")].toArray());
    PageListModel::self()->loadFromJson(obj[QStringLiteral("Pages")].toArray());

    FavouritesModel::self()->save();
    PageListModel::self()->save();

    return true;
}
