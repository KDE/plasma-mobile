/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
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
#include <KApplication>
#include <KAboutData>
#include <KCmdLineArgs>
#include <KDebug>
#include <KDE/KLocale>
#include <KToolBar>

// Own
#include "imageviewer.h"

static const char description[] = I18N_NOOP("Image viewer for Plasma Active");

static const char version[] = "0.1";

int main(int argc, char **argv)
{
    // FIXME: selkie icon instead of internet-web-browser
    KAboutData about("active-image-viewer", 0, ki18n("Active image viewer"), version, ki18n(description),
                     KAboutData::License_GPL, ki18n("Copyright 2011 Marco Martin"), KLocalizedString(), 0, "mart@kde.org");
                     about.addAuthor( ki18n("Marco Martin"), KLocalizedString(), "mart@kde.org" );
    KCmdLineArgs::init(argc, argv, &about);

    KCmdLineOptions options;
    options.add("+[url]", ki18n( "URL of the image to open" ));
    KCmdLineArgs::addCmdLineOptions(options);
    KApplication app;

    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();

    //kDebug() << "ARGS:" << args << args->count();
    QString url;
    if (args->count() > 0) {
        url = args->arg(0);
    }

    ImageViewer *mainWindow = new ImageViewer(url);
    mainWindow->show();
    args->clear();
    return app.exec();
}
