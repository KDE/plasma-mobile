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

#include "activesettings.h"


#include <KAction>
#include <KCmdLineArgs>
#include <KIcon>
#include <KRun>
#include <KStandardAction>

#include "activesettingswindow.h"
#include "view.h"


ActiveWebbrowser::ActiveWebbrowser(const KCmdLineArgs *args)
    : KApplication()
{
    Q_UNUSED(args);
    //qmlRegisterType<KDeclarativeWebSettings>();
    //qmlRegisterType<KDeclarativeWebView>("org.kde.kdewebkit", 0, 1, "WebView");
    setStartDragDistance(20);
}

ActiveWebbrowser::~ActiveWebbrowser()
{
}

void ActiveWebbrowser::newWindow(const QString& url)
{
    ActiveBrowserWindow *browserWindow = new ActiveBrowserWindow(url);
    connect(browserWindow, SIGNAL(newWindow(const QString&)), SLOT(newWindow(const QString&)));
    browserWindow->show();
}

void ActiveWebbrowser::setUseGL(const bool on)
{
    /* not switchable at runtime for now, if we want this, we can add
     * some housekeeping for the windows, let's keep it KISS for now.
     */
    m_useGL = on;
}

bool ActiveWebbrowser::useGL() const
{
    return m_useGL;
}
/*
void View::newWindow(const QString &url)
{
    KRun::runCommand(QString("active-webbrowser '%1'").arg(url), this);
}
*/
#include "activesettings.moc"
