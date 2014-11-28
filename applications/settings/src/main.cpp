/***************************************************************************
 *                                                                         *
 *   Copyright 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
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

// std
#include <iostream>
#include <iomanip>

// KDE
#include <K4AboutData>
#include <KCmdLineArgs>
#include <KConfigGroup>
#include <KDebug>
#include <KService>
#include <KServiceTypeTrader>

#include <Plasma/Theme>

// Own
#include "activesettings.h"

static const char description[] = I18N_NOOP("Plasma Active Settings");

static const char version[] = "2.0";
static const char HOME_URL[] = "http://plasma-active.org";

int main(int argc, char **argv)
{
    K4AboutData about("active-settings", 0, ki18n("Plasma Active Settings"), version, ki18n(description),
                     K4AboutData::License_GPL, ki18n("Copyright 2011 Sebastian Kügler"), KLocalizedString(), 0, "sebas@kde.org");
                     about.addAuthor( ki18n("Sebastian Kügler"), KLocalizedString(), "sebas@kde.org" );
    KCmdLineArgs::init(argc, argv, &about);

    KService::Ptr service = KService::serviceByDesktopName("active-settings");
    about.setProgramIconName(service ? service->icon() : "preferences-desktop");
    KCmdLineOptions options;
    options.add("+[module]", ki18n( "Settings module to open" ), "startpage");
    options.add("list", ki18n("Displays a list of known modules"));

    KCmdLineArgs::addCmdLineOptions(options);

    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();

    if (args->isSet("list")) {
        //listPlugins(Plasma::Applet::listAppletInfo());
        //kDebug() << "Available modules are:";
        QString query;
        KService::List services = KServiceTypeTrader::self()->query("Active/SettingsModule", query);

        //kDebug() << "Found " << services.count() << " modules";
        int nameWidth = 0;
        foreach (const KService::Ptr &service, services) {
            KPluginInfo info(service);
            const int len = info.pluginName().length();
            if (len > nameWidth) {
                nameWidth = len;
            }
        }

        QSet<QString> seen;
        std::cout << std::setfill('.');

        foreach (const KService::Ptr &service, services) {
            if (service->noDisplay()) {
                continue;
            }

            KPluginInfo info(service);
            if (seen.contains(info.pluginName())) {
                continue;
            }
            seen.insert(info.pluginName());

            QString description;
            if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
                description = service->genericName();
            } else if (!service->comment().isEmpty()) {
                description = service->comment();
            }
            //kDebug() << service->property("X-KDE-PluginInfo-Name") << " :: " << description;
            std::cout << info.pluginName().toLocal8Bit().data()
                      << ' '
                      << std::setw(nameWidth - info.pluginName().length() + 2)
                      << '.' << ' '
                      << description.toLocal8Bit().data() << std::endl;
        }
        return 0;
    }

    ActiveSettings app(args);
    const QString module = args->count() ? args->arg(0) : QString();

    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");

    const QString themeName = cg.readEntry("name", "air-mobile");
    auto theme = new Plasma::Theme(themeName, &app);
    theme->setUseGlobalSettings(false);

    app.newWindow(module);
    args->clear();
    return app.exec();
}
