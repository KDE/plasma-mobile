// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "foliosettings.h"
#include "favouritesmodel.h"
#include "pagelistmodel.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QTextStream>

using namespace Qt::Literals::StringLiterals;

// The config group all of the settings are under
const QString CFG_GROUP_FOLIO = QStringLiteral("Folio");

const QString CFG_KEY_FAVORITES = QStringLiteral("favorites");
const QString CFG_KEY_PAGES = QStringLiteral("pages");

const QString CFG_KEY_HOMESCREEN_ROWS = QStringLiteral("homeScreenRows");
const QString CFG_KEY_HOMESCREEN_COLS = QStringLiteral("homeScreenColumns");
const QString CFG_KEY_SHOW_PAGES_APPLABELS = QStringLiteral("showPagesAppLabels");
const QString CFG_KEY_SHOW_FAVORITES_APPLABELS = QStringLiteral("showFavoritesAppLabels");
const QString CFG_KEY_LOCK_LAYOUT = QStringLiteral("lockLayout");
const QString CFG_KEY_DELEGATE_ICON_SIZE = QStringLiteral("delegateIconSize");
const QString CFG_KEY_SHOW_FAVORITES_BAR_BACKGROUND = QStringLiteral("showFavoritesBarBackground");
const QString CFG_KEY_PAGE_TRANSITION_EFFECT = QStringLiteral("pageTransitionEffect");
const QString CFG_KEY_SHOW_WALLPAPER_BLUR = QStringLiteral("wallpaperBlurEffect");
const QString CFG_KEY_DOUBLE_TAP_TO_LOCK = QStringLiteral("doubleTapToLock");

FolioSettings::FolioSettings(HomeScreen *parent)
    : QObject{parent}
    , m_homeScreen{parent}
{
}

QString FolioSettings::favorites() const
{
    return generalConfigGroup().readEntry(CFG_KEY_FAVORITES, u"{}"_s);
}

void FolioSettings::setFavorites(const QString &favoritesJson)
{
    // Saved separately from other options, since it's changed from the homescreen (not settings window)
    generalConfigGroup().writeEntry(CFG_KEY_FAVORITES, favoritesJson);
    Q_EMIT m_homeScreen->configNeedsSaving();
}

QString FolioSettings::pages() const
{
    return generalConfigGroup().readEntry(CFG_KEY_PAGES, u"{}"_s);
}

void FolioSettings::setPages(const QString &pagesJson)
{
    // Saved separately from other options, since it's changed from the homescreen (not settings window)
    generalConfigGroup().writeEntry(CFG_KEY_PAGES, pagesJson);
    Q_EMIT m_homeScreen->configNeedsSaving();
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

FolioSettings::WallpaperBlurEffect FolioSettings::wallpaperBlurEffect() const
{
    return m_wallpaperBlurEffect;
}

void FolioSettings::setWallpaperBlurEffect(WallpaperBlurEffect wallpaperBlurEffect)
{
    if (m_wallpaperBlurEffect != wallpaperBlurEffect) {
        m_wallpaperBlurEffect = wallpaperBlurEffect;
        Q_EMIT wallpaperBlurEffectChanged();
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

    auto generalGroup = generalConfigGroup();

    generalGroup.writeEntry(CFG_KEY_HOMESCREEN_ROWS, m_homeScreenRows);
    generalGroup.writeEntry(CFG_KEY_HOMESCREEN_COLS, m_homeScreenColumns);
    generalGroup.writeEntry(CFG_KEY_SHOW_PAGES_APPLABELS, m_showPagesAppLabels);
    generalGroup.writeEntry(CFG_KEY_SHOW_FAVORITES_APPLABELS, m_showFavouritesAppLabels);
    generalGroup.writeEntry(CFG_KEY_LOCK_LAYOUT, m_lockLayout);
    generalGroup.writeEntry(CFG_KEY_DELEGATE_ICON_SIZE, m_delegateIconSize);
    generalGroup.writeEntry(CFG_KEY_SHOW_FAVORITES_BAR_BACKGROUND, m_showFavouritesBarBackground);
    generalGroup.writeEntry(CFG_KEY_PAGE_TRANSITION_EFFECT, (int)m_pageTransitionEffect);
    generalGroup.writeEntry(CFG_KEY_SHOW_WALLPAPER_BLUR, (int)m_wallpaperBlurEffect);
    generalGroup.writeEntry(CFG_KEY_DOUBLE_TAP_TO_LOCK, m_doubleTapToLock);

    Q_EMIT m_homeScreen->configNeedsSaving();
}

void FolioSettings::load()
{
    if (!m_homeScreen) {
        return;
    }

    migrateConfigFromPlasma6_4();

    auto generalGroup = generalConfigGroup();

    m_homeScreenRows = generalGroup.readEntry(CFG_KEY_HOMESCREEN_ROWS, 5);
    m_homeScreenColumns = generalGroup.readEntry(CFG_KEY_HOMESCREEN_COLS, 4);
    m_showPagesAppLabels = generalGroup.readEntry(CFG_KEY_SHOW_PAGES_APPLABELS, true);
    m_showFavouritesAppLabels = generalGroup.readEntry(CFG_KEY_SHOW_FAVORITES_APPLABELS, false);
    m_lockLayout = generalGroup.readEntry(CFG_KEY_LOCK_LAYOUT, false);
    m_delegateIconSize = generalGroup.readEntry(CFG_KEY_DELEGATE_ICON_SIZE, 48);
    m_showFavouritesBarBackground = generalGroup.readEntry(CFG_KEY_SHOW_FAVORITES_BAR_BACKGROUND, true);
    m_pageTransitionEffect = static_cast<PageTransitionEffect>(generalGroup.readEntry(CFG_KEY_PAGE_TRANSITION_EFFECT, (int)SlideTransition));
    m_wallpaperBlurEffect = static_cast<WallpaperBlurEffect>(generalGroup.readEntry(CFG_KEY_SHOW_WALLPAPER_BLUR, (int)Full));
    m_doubleTapToLock = generalGroup.readEntry(CFG_KEY_DOUBLE_TAP_TO_LOCK, true);

    Q_EMIT homeScreenRowsChanged();
    Q_EMIT homeScreenColumnsChanged();
    Q_EMIT showPagesAppLabels();
    Q_EMIT showFavouritesAppLabelsChanged();
    Q_EMIT lockLayoutChanged();
    Q_EMIT delegateIconSizeChanged();
    Q_EMIT showFavouritesBarBackgroundChanged();
    Q_EMIT pageTransitionEffectChanged();
    Q_EMIT wallpaperBlurEffectChanged();
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
    obj[QStringLiteral("Favorites")] = favourites;
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

    // Parse JSON
    // TODO: error checking

    if (obj.find(QStringLiteral("Favorites")) != obj.end()) {
        m_homeScreen->favouritesModel()->loadFromJson(obj[QStringLiteral("Favorites")].toArray());
    } else {
        // For legacy purposes, the key used to have a different spelling
        m_homeScreen->favouritesModel()->loadFromJson(obj[QStringLiteral("Favourites")].toArray());
    }
    m_homeScreen->pageListModel()->loadFromJson(obj[QStringLiteral("Pages")].toArray());

    m_homeScreen->favouritesModel()->save();
    m_homeScreen->pageListModel()->save();

    return true;
}

KConfigGroup FolioSettings::generalConfigGroup() const
{
    if (!m_homeScreen) {
        return KConfigGroup{};
    }

    return m_homeScreen->config().group(CFG_GROUP_FOLIO);
}

void FolioSettings::migrateConfigFromPlasma6_4()
{
    // Migrate config options (from before Plasma 6.5) from the root config group to [General]
    // When adding new config options, do not update this function!

    auto oldConfigGroup = m_homeScreen->config();
    auto generalGroup = generalConfigGroup();

    // Function to migrate a single key
    auto migrate = [&oldConfigGroup, &generalGroup]<typename T>(const QString &newKey, const QString &oldKey, const T &oldDefaultValue) {
        if (!oldConfigGroup.hasKey(oldKey) || generalGroup.hasKey(newKey)) {
            return;
        }
        generalGroup.writeEntry(newKey, oldConfigGroup.readEntry(oldKey, oldDefaultValue));
        oldConfigGroup.deleteEntry(oldKey);
    };

    migrate(CFG_KEY_FAVORITES, u"Favourites"_s, u"{}"_s);
    migrate(CFG_KEY_PAGES, u"Pages"_s, u"[[]]"_s);
    migrate(CFG_KEY_HOMESCREEN_ROWS, u"homeScreenRows"_s, 5);
    migrate(CFG_KEY_HOMESCREEN_COLS, u"homeScreenColumns"_s, 4);
    migrate(CFG_KEY_SHOW_PAGES_APPLABELS, u"showPagesAppLabels"_s, true);
    migrate(CFG_KEY_SHOW_FAVORITES_APPLABELS, u"showFavoritesAppLabels"_s, false);
    migrate(CFG_KEY_LOCK_LAYOUT, u"lockLayout"_s, false);
    migrate(CFG_KEY_DELEGATE_ICON_SIZE, u"delegateIconSize"_s, 48);
    migrate(CFG_KEY_SHOW_FAVORITES_BAR_BACKGROUND, u"showFavoritesBarBackground"_s, true);
    migrate(CFG_KEY_PAGE_TRANSITION_EFFECT, u"pageTransitionEffect"_s, (int)SlideTransition);
    migrate(CFG_KEY_SHOW_WALLPAPER_BLUR, u"wallpaperBlurEffect"_s, (int)Full);

    m_homeScreen->config().sync();
}
