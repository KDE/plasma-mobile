/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

// KDE
#include <KAboutData>
#include <KCmdLineArgs>
#include <KDebug>
#include <KService>
#include <KConfigGroup>

#include <Plasma/Theme>

// Own
#include "activesettings.h"

static const char description[] = I18N_NOOP("Plasma Active Settings");

static const char version[] = "0.2";
static const char HOME_URL[] = "http://plasma-active.org";

int main(int argc, char **argv)
{
    KAboutData about("active-settings", 0, ki18n("Plasma Active Settings"), version, ki18n(description),
                     KAboutData::License_GPL, ki18n("Copyright 2011 Sebastian Kügler"), KLocalizedString(), 0, "sebas@kde.org");
                     about.addAuthor( ki18n("Sebastian Kügler"), KLocalizedString(), "sebas@kde.org" );
    KCmdLineArgs::init(argc, argv, &about);

    KService::Ptr service = KService::serviceByDesktopName("active-settings");
    const QString homeUrl = service ? service->property("X-KDE-PluginInfo-Website", QVariant::String).toString() : HOME_URL;
    about.setProgramIconName(service ? service->icon() : "preferences-desktop");
    KCmdLineOptions options;
    options.add("+[module]", ki18n( "Settings module to open" ), "startpage");
    KCmdLineArgs::addCmdLineOptions(options);

    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();

    ActiveSettings app(args);
    const QString module = args->count() ? args->arg(0) : QString();

    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");

    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);

    app.newWindow(module);
    args->clear();
    return app.exec();
}
