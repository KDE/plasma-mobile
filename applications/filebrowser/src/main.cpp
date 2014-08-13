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

// Qt
#include <QApplication>
#include <qcommandlineparser.h>

#include <klocalizedstring.h>
// Own
#include "filebrowser.h"

static const char description[] = I18N_NOOP("File browser for Plasma Active");

static const char version[] = "0.2";
static QCommandLineParser parser;

int main(int argc, char **argv)
{

    KLocalizedString::setApplicationDomain("active-filebrowser");

    QApplication app(argc, argv);
    app.setApplicationName("active-filebrowser");
    app.setApplicationDisplayName(i18n("Files"));
    app.setOrganizationDomain("kde.org");
    app.setApplicationVersion(version);
    app.setQuitOnLastWindowClosed(false);
    app.setWindowIcon(QIcon::fromTheme("system-file-manager"));
    parser.setApplicationDescription(description);

    QCommandLineOption res(QStringList() << QStringLiteral("t") <<
                           QStringLiteral("resourceType <type>"),
                           i18n("resource type to restrict the browser, such as Image or Document"));

    QCommandLineOption mime(QStringList() << QStringLiteral("m") <<
                           QStringLiteral("mimeTypes <type,type>"),
                           i18n("comma separatedlist of mime types to restrict the browser"));

    parser.addVersionOption();
    parser.addHelpOption();
    parser.addOption(res);
    parser.addOption(mime);
    parser.process(app);

    if (parser.isSet(res) && parser.value(res) == "File/Image") {
        app.setWindowIcon(QIcon::fromTheme("active-image-viewer"));
    }

    FileBrowser *mainWindow = new FileBrowser();
    mainWindow->setResourceType(parser.value(res));
    mainWindow->setMimeTypes(parser.value(mime));
    mainWindow->show();
    return app.exec();
}
