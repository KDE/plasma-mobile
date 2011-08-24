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

#include "activewebbrowser.h"

#include <QApplication>
#include <QDesktopWidget>

#include <KAction>
#include <KCmdLineArgs>
#include <KIcon>
#include <KStandardAction>

#include <Plasma/Theme>

#include "activebrowserwindow.h"
#include "kdeclarativewebview.h"
#include "view.h"


ActiveWebbrowser::ActiveWebbrowser(const KCmdLineArgs *args)
    : KApplication()
{
    qmlRegisterType<KDeclarativeWebView>("org.kde.kdewebkit", 0, 1, "WebView");

    //kDebug() << "ARGS:" << args << args->count();
    //const QString url = args->count() ? args->arg(0) : homeUrl;
}

ActiveWebbrowser::~ActiveWebbrowser()
{
}

void ActiveWebbrowser::openUrl(const QString& url)
{
    ActiveBrowserWindow *mainWindow = new ActiveBrowserWindow(url);
    mainWindow->setUseGL(m_useGL);
    mainWindow->show();
}

void ActiveWebbrowser::setUseGL(const bool on)
{
    m_useGL = on;
    //m_widget->setUseGL(on);
}

bool ActiveWebbrowser::useGL() const
{
    return m_useGL;
}

#include "activewebbrowser.moc"
