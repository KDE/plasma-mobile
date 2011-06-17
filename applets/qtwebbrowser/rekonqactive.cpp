/*
 * Copyright 2009 Richard Moore <rich@kde.org>
 * Copyright 2009 Omat Holding B.V. <info@omat.nl>
 * Copyright 2009-2010 Sebastian Kügler <sebas@kde.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) version 3, or any
 * later version accepted by the membership of KDE e.V. (or its
 * successor approved by the membership of KDE e.V.), which shall
 * act as a proxy defined in Section 6 of version 3 of the license.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 */

#include <iostream>

// Qt
//#include <QDir>
//#include <QBoxLayout>
//#include <QWidget>

// KDE
#include <KApplication>
#include <KAboutData>
#include <KCmdLineArgs>
#include <KDebug>
#include <KDE/KLocale>
#include <KToolBar>

// Own
//#include "webapp.h"
//#include "view.h" // needed for listWebApps

static const char description[] =
I18N_NOOP("Web browser for Plasma Active");

static const char version[] = "0.1";

void output(const QString &msg)
{
    std::cout << msg.toLocal8Bit().constData() << std::endl;
}

int main(int argc, char **argv)
{
    // FIXME: selkie icon instead of internet-web-browser
    KAboutData about("internet-web-browser", 0, ki18n("Rekonq Active"), version, ki18n(description),
                     KAboutData::License_GPL, ki18n("Copyright 2011 Sebastian Kügler"), KLocalizedString(), 0, "sebas@kde.org");
                     about.addAuthor( ki18n("Sebastian Kügler"), KLocalizedString(), "sebas@kde.org" );
    KCmdLineArgs::init(argc, argv, &about);

    KCmdLineOptions options;
    options.add("+[url]", ki18n( "URL to open" ), "http://dot.kde.org");
    KCmdLineArgs::addCmdLineOptions(options);
    KApplication app;

    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();

    //kDebug() << "ARGS:" << args << args->count();
    if (args->count() == 0) {
        output("Usage: rekonq-active [url]\n");
        return 1;
    } else {
        //WebApp *webapp = new WebApp();
        //QString package = QString(args->arg(0));
    }
    return 0;
}
