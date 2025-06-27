// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "foliosettings.h"
#include "favouritesmodel.h"
#include "pagelistmodel.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QTextStream>

const QString CFG_KEY_HOMESCREEN_ROWS = QStringLiteral("homeScreenRows");
const QString CFG_KEY_HOMESCREEN_COLS = QStringLiteral("homeScreenColumns");
const QString CFG_KEY_SHOW_PAGES_APPLABELS = QStringLiteral("showPagesAppLabels");
const QString CFG_KEY_SHOW_FAVORITES_APPLABELS = QStringLiteral("showFavoritesAppLabels");
const QString CFG_KEY_LOCK_LAYOUT = QStringLiteral("lockLayout");
const QString CFG_KEY_DELEGATE_ICON_SIZE = QStringLiteral("delegateIconSize");
const QString CFG_KEY_SHOW_FAVORITES_BAR_BACKGROUND = QStringLiteral("showFavoritesBarBackground");
const QString CFG_KEY_PAGE_TRANSITION_EFFECT = QStringLiteral("pageTransitionEffect");
const QString CFG_KEY_SHOW_WALLPAPER_BLUR = QStringLiteral("showWallpaperBlur");
const QString CFG_KEY_DOUBLE_TAP_TO_LOCK = QStringLiteral("doubleTapToLock");

FolioSettings::FolioSettings(HomeScreen *parent)
    : QObject{parent}
    , m_homeScreen{parent}
{
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

bool FolioSettings::lockLayout() const
{
    return m_lockLayout;
}

void FolioSettings::setLockLayout(bool lockLayout)
{
    if (m_lockLayout != lockLayout) {
        m_lockLayout = lockLayout;
        Q_EMIT lockLayoutChanged();
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

bool FolioSettings::doubleTapToLock() const
{
    return m_doubleTapToLock;
}

void FolioSettings::setDoubleTapToLock(bool doubleTapToLock)
{
    if (m_doubleTapToLock != doubleTapToLock) {
        m_doubleTapToLock = doubleTapToLock;
        Q_EMIT doubleTapToLockChanged();
        save();
    }
}

void FolioSettings::save()
{
    if (!m_homeScreen) {
        return;
    }

    m_homeScreen->config().writeEntry(CFG_KEY_HOMESCREEN_ROWS, m_homeScreenRows);
    m_homeScreen->config().writeEntry(CFG_KEY_HOMESCREEN_COLS, m_homeScreenColumns);
    m_homeScreen->config().writeEntry(CFG_KEY_SHOW_PAGES_APPLABELS, m_showPagesAppLabels);
    m_homeScreen->config().writeEntry(CFG_KEY_SHOW_FAVORITES_APPLABELS, m_showFavouritesAppLabels);
    m_homeScreen->config().writeEntry(CFG_KEY_LOCK_LAYOUT, m_lockLayout);
    m_homeScreen->config().writeEntry(CFG_KEY_DELEGATE_ICON_SIZE, m_delegateIconSize);
    m_homeScreen->config().writeEntry(CFG_KEY_SHOW_FAVORITES_BAR_BACKGROUND, m_showFavouritesBarBackground);
    m_homeScreen->config().writeEntry(CFG_KEY_PAGE_TRANSITION_EFFECT, (int)m_pageTransitionEffect);
    m_homeScreen->config().writeEntry(CFG_KEY_SHOW_WALLPAPER_BLUR, m_showWallpaperBlur);
    m_homeScreen->config().writeEntry(CFG_KEY_DOUBLE_TAP_TO_LOCK, m_doubleTapToLock);

    Q_EMIT m_homeScreen->configNeedsSaving();
}

void FolioSettings::load()
{
    if (!m_homeScreen) {
        return;
    }

    m_homeScreenRows = m_homeScreen->config().readEntry(CFG_KEY_HOMESCREEN_ROWS, 5);
    m_homeScreenColumns = m_homeScreen->config().readEntry(CFG_KEY_HOMESCREEN_COLS, 4);
    m_showPagesAppLabels = m_homeScreen->config().readEntry(CFG_KEY_SHOW_PAGES_APPLABELS, true);
    m_showFavouritesAppLabels = m_homeScreen->config().readEntry(CFG_KEY_SHOW_FAVORITES_APPLABELS, false);
    m_lockLayout = m_homeScreen->config().readEntry(CFG_KEY_LOCK_LAYOUT, false);
    m_delegateIconSize = m_homeScreen->config().readEntry(CFG_KEY_DELEGATE_ICON_SIZE, 48);
    m_showFavouritesBarBackground = m_homeScreen->config().readEntry(CFG_KEY_SHOW_FAVORITES_BAR_BACKGROUND, true);
    m_pageTransitionEffect = static_cast<PageTransitionEffect>(m_homeScreen->config().readEntry(CFG_KEY_PAGE_TRANSITION_EFFECT, (int)SlideTransition));
    m_showWallpaperBlur = m_homeScreen->config().readEntry(CFG_KEY_SHOW_WALLPAPER_BLUR, true);
    m_doubleTapToLock = m_homeScreen->config().readEntry(CFG_KEY_DOUBLE_TAP_TO_LOCK, true);

    Q_EMIT homeScreenRowsChanged();
    Q_EMIT homeScreenColumnsChanged();
    Q_EMIT showPagesAppLabels();
    Q_EMIT showFavouritesAppLabelsChanged();
    Q_EMIT lockLayoutChanged();
    Q_EMIT delegateIconSizeChanged();
    Q_EMIT showWallpaperBlurChanged();
    Q_EMIT doubleTapToLockChanged();
}

bool FolioSettings::saveLayoutToFile(QString path)
{
    if (!m_homeScreen) {
        return false;
    }

    if (path.startsWith(QStringLiteral("file://"))) {
        path = path.replace(QStringLiteral("file://"), QString());
    }

    QJsonArray favourites = m_homeScreen->favouritesModel()->exportToJson();
    QJsonArray pages = m_homeScreen->pageListModel()->exportToJson();

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
    if (!m_homeScreen) {
        return false;
    }

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
    m_homeScreen->favouritesModel()->loadFromJson(obj[QStringLiteral("Favourites")].toArray());
    m_homeScreen->pageListModel()->loadFromJson(obj[QStringLiteral("Pages")].toArray());

    m_homeScreen->favouritesModel()->save();
    m_homeScreen->pageListModel()->save();

    return true;
}
