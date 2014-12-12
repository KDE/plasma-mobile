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
// #include <iostream>
// #include <iomanip>

// Qt
#include <QGuiApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QDebug>

// Frameworks
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

    app.setApplicationVersion(version);

    const static auto _url = QStringLiteral("url");
    QCommandLineOption url = QCommandLineOption(QStringList() << QStringLiteral("u") << _url,
                               i18n("Start at URL"), i18n("url"));

    const static auto _f = QStringLiteral("fullscreen");
    QCommandLineOption fullscreen = QCommandLineOption(QStringList() << QStringLiteral("f") << _f,
                               i18n("Start full-screen"));

    QCommandLineParser parser;
    parser.addVersionOption();
    parser.setApplicationDescription(description);
    parser.addHelpOption();
    parser.addOption(url);
    parser.addOption(fullscreen);

    parser.process(app);

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
    theme.setThemeName(themeName); // nees to happen after setUseGlobalSettings, since that clears themeName

    auto settingsapp = new AngelFish::View(u);
    if (parser.isSet(fullscreen)) {
        settingsapp->setVisibility(QWindow::FullScreen);
    }

    return app.exec();
}
