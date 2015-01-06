/***************************************************************************
 *                                                                         *
 *   Copyright 2011-2015 Sebastian Kügler <sebas@kde.org>                  *
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


// Qt
#include <QGuiApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QDebug>

// Frameworks
#include <KAboutData>
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

    KLocalizedString::setApplicationDomain("active-settings");

    // About data
    KAboutData aboutData("activesettings", i18n("Settings"), version, i18n("Touch-friendly settings application."), KAboutLicense::GPL, i18n("Copyright 2011-2015, Sebastian Kügler"));
    aboutData.addAuthor(i18n("Sebastian Kügler"), i18n("Maintainer"), "sebas@kde.org");
    KAboutData::setApplicationData(aboutData);

    app.setWindowIcon(QIcon::fromTheme("preferences-system"));

    const static auto _l = QStringLiteral("list");
    const static auto _m = QStringLiteral("module");
    const static auto _f = QStringLiteral("fullscreen");
    const static auto _ui = QStringLiteral("layout");

    QCommandLineOption _list = QCommandLineOption(QStringList() << QStringLiteral("l") << _l,
                               i18n("List available settings modules"));
    QCommandLineOption _module = QCommandLineOption(QStringList() << QStringLiteral("m") << _m,
                                i18n("Settings module to open"), i18n("modulename"));
    QCommandLineOption _fullscreen = QCommandLineOption(QStringList() << QStringLiteral("f") << _f,
                                i18n("Start window fullscreen"));
    QCommandLineOption _layout = QCommandLineOption(QStringList() << _ui,
                                i18n("Package to use for the UI (default org.kde.active.settings)"), i18n("packagename"));

    QCommandLineParser parser;
    parser.addOption(_list);
    parser.addOption(_module);
    parser.addOption(_fullscreen);
    parser.addOption(_layout);
    aboutData.setupCommandLine(&parser);

    parser.process(app);
    aboutData.processCommandLine(&parser);

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
            std::cout << info.pluginName().toLocal8Bit().data()
                      << ' '
                      << std::setw(nameWidth - info.pluginName().length() + 2)
                      << '.' << ' '
                      << description.toLocal8Bit().data() << std::endl;
        }
        return 0;
    }

    const QString module = parser.value(_m);
    QString ui = parser.value(_ui);

    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-active-settings");

    const QString themeName = cg.readEntry("name", "default");
    ui = cg.readEntry("package", ui);

    Plasma::Theme theme;
    qDebug() << "Setting theme, package " << themeName << ui;
    theme.setUseGlobalSettings(false);
    theme.setThemeName(themeName); // nees to happen after setUseGlobalSettings, since that clears themeName

    auto settingsapp = new View(module, ui);
    if (parser.isSet(_fullscreen)) {
        settingsapp->setVisibility(QWindow::FullScreen);
    }

    return app.exec();
}
