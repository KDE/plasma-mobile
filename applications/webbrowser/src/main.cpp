/***************************************************************************
 *                                                                         *
 *   Copyright 2014 Sebastian Kügler <sebas@kde.org>                       *
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

// Qt
#include <QGuiApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QDebug>

// Frameworks
#include <KAboutData>
#include <KConfigGroup>
#include <KLocalizedString>
#include <Plasma/Theme>

// Own
#include "view.h"

static const char description[] = I18N_NOOP("Angelfish Browser");
static const char version[] = "0.1";
static const char HOME_URL[] = "http://plasma-mobile.org";

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    KLocalizedString::setApplicationDomain("active-settings");

    // About data
    KAboutData aboutData("angelfish", i18n("Web Browser"), version, i18n("Touch-friendly web browser."), KAboutLicense::GPL, i18n("Copyright 2015, Sebastian Kügler"));
    aboutData.addAuthor(i18n("Sebastian Kügler"), i18n("Maintainer"), "sebas@kde.org");
    KAboutData::setApplicationData(aboutData);

    app.setWindowIcon(QIcon::fromTheme("internet-web-browser"));


    const static auto _url = QStringLiteral("url");
    QCommandLineOption url = QCommandLineOption(QStringList() << QStringLiteral("u") << _url,
                               i18n("Start at URL"), i18n("url"));

    const static auto _f = QStringLiteral("fullscreen");
    QCommandLineOption fullscreen = QCommandLineOption(QStringList() << QStringLiteral("f") << _f,
                               i18n("Start full-screen"));

    QCommandLineParser parser;
    parser.addOption(url);
    parser.addOption(fullscreen);

    aboutData.setupCommandLine(&parser);

    parser.process(app);
    aboutData.processCommandLine(&parser);

    QString u = parser.value(url);

    KConfigGroup cg(KSharedConfig::openConfig("angelfishrc"), "Browser");
    const QString themeName = cg.readEntry("theme", "default");
    if (u.isEmpty()) {
        qDebug() << "u: " << u;
        u = cg.readEntry("startPage", QString());
    }

    Plasma::Theme theme;
    qDebug() << "Setting theme, package " << themeName << u;
    theme.setUseGlobalSettings(false);
    theme.setThemeName(themeName); // needs to happen after setUseGlobalSettings, since that clears themeName

    auto settingsapp = new AngelFish::View(u);
    if (parser.isSet(fullscreen)) {
        settingsapp->setVisibility(QWindow::FullScreen);
    }

    return app.exec();
}
