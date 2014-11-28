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

#include <QGuiApplication>

// Qt
#include <QCommandLineParser>
#include <QCommandLineOption>

// Frameworks
#include <KConfigGroup>
#include <KLocalizedString>
#include <KService>
#include <KServiceTypeTrader>
#include <Plasma/Theme>

// Own
#include "view.h"

static const char description[] = I18N_NOOP("Plasma Active Settings");

static const char version[] = "2.0";
static const char HOME_URL[] = "http://plasma-active.org";

int main(int argc, char **argv)
{

    QGuiApplication app(argc, argv);

    app.setApplicationVersion(version);

    const static auto _l = QStringLiteral("list");
    const static auto _m = QStringLiteral("module");

    QCommandLineOption _list = QCommandLineOption(QStringList() << QStringLiteral("l") << _l,
                               i18n("List available settings modules"));
    QCommandLineOption _module = QCommandLineOption(QStringList() << QStringLiteral("m") << _m,
                                i18n("Settings module to open"), QStringLiteral("modulename"));

    QCommandLineParser parser;
    parser.addVersionOption();
    parser.setApplicationDescription(description);
    parser.addHelpOption();
    parser.addOption(_list);
    parser.addOption(_module);

    parser.process(app);

    if (parser.isSet(_list)) {
        QString query;
        KService::List services = KServiceTypeTrader::self()->query("Active/SettingsModule", query);

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

    const QString module = parser.value(_m);

    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");

    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme theme;
    theme.setUseGlobalSettings(false);
    theme.setThemeName(themeName); // nees to happen after setUseGlobalSettings, since that clears themeName

    new View(module);

    return app.exec();
}
