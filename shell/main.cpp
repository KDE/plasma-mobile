/***************************************************************************
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>                      *
 *   Copyright 2009 Marco Martin <notmart@gmail.com>                       *
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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

#include <KApplication>
#include <KAboutData>
#include <KCmdLineArgs>
#include <KLocale>
#include <KIcon>

#include "plasmaapp.h"

static const char description[] = I18N_NOOP( "The mobile version of the KDE workspace" );
static const char version[] = "0.1";

extern "C"
KDE_EXPORT int kdemain(int argc, char **argv)
{
    KAboutData aboutData(argv[0], 0, ki18n("Plasma Workspace"),
                         version, ki18n(description), KAboutData::License_GPL,
                         ki18n("Copyright 2006-2009, The KDE Team"));
    aboutData.addAuthor(ki18n("Alexis Menard"),
                        ki18n("Author and maintainer"),
                        "menard@kde.org");
    aboutData.addAuthor(ki18n("Marco Martin"),
                        ki18n("Author and maintainer"),
                        "mart@kde.org");

    QApplication::setGraphicsSystem("raster");
    KCmdLineArgs::init(argc, argv, &aboutData);

    KCmdLineOptions options;
    options.add("nodesktop", ki18n("Starts as a normal application instead of as the primary user interface"));
    options.add("screen <geometry>", ki18n("The geometry of the screen"), "800x480");
#ifndef QT_NO_OPENGL
    options.add("opengl", ki18n("use a QGLWidget for the viewport"));
#endif
    options.add("fullscreen", ki18n("Starts the application in fullscreen"));
    KCmdLineArgs::addCmdLineOptions(options);

    PlasmaApp *app = PlasmaApp::self();

    QApplication::setWindowIcon(KIcon("plasma"));
    app->disableSessionManagement(); // autostarted
    int rc = app->exec();
    delete app;
    return rc;
}

