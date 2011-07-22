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

#include <QApplication>
#include <QDesktopWidget>

#include <KAction>
#include <KIcon>
#include <KStandardAction>

#include <Plasma/Theme>

#include "activebrowserwindow.h"

ActiveBrowserWindow::ActiveBrowserWindow(const QString &url, QWidget *parent)
    : QMainWindow(parent)
{
    setAcceptDrops(true);
    addAction(KStandardAction::close(this, SLOT(close()), this));
    addAction(KStandardAction::quit(this, SLOT(close()), this));
    m_widget = new View(url, this);
    const QByteArray geom = config("Window").readEntry("Geometry", QByteArray());
    if (geom.isEmpty()) {
        setGeometry(qApp->desktop()->screenGeometry());
    } else {
        restoreGeometry(geom);
    }
    setCentralWidget(m_widget);

    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);

    connect(m_widget, SIGNAL(titleChanged(QString)), SLOT(setCaption(QString)));
}

ActiveBrowserWindow::~ActiveBrowserWindow()
{
}

void ActiveBrowserWindow::closeEvent(QCloseEvent *)
{
    kDebug() << "going to save" << saveGeometry();
    config("Window").writeEntry("Geometry", saveGeometry());
}

KConfigGroup ActiveBrowserWindow::config(const QString &group)
{
    return KConfigGroup(KSharedConfig::openConfig("rekonqactiverc"), group);
}

QString ActiveBrowserWindow::name()
{
    return "Rekonq Active";
    //return m_widget->options()->name;
}

QIcon ActiveBrowserWindow::icon()
{
    return KIcon("internet-web-browser");
}

#include "activebrowserwindow.moc"
