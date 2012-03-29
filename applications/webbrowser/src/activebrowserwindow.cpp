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

#include "activebrowserwindow.h"

#include <QApplication>
#include <QDesktopWidget>
#include <QDeclarativeContext>

#include <KAction>
#include <KActionCollection>
#include <KIcon>
#include <KStandardAction>

#include <Plasma/Theme>

#include "view.h"

ActiveBrowserWindow::ActiveBrowserWindow(const QString &url, QWidget *parent)
    : QMainWindow(parent)
{
    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);

    setAcceptDrops(true);
    addAction(KStandardAction::close(this, SLOT(close()), this));
    addAction(KStandardAction::quit(this, SLOT(close()), this));
    m_widget = new View(url, this);
    connect(m_widget, SIGNAL(newWindow(QString)), SIGNAL(newWindow(QString)));

    KConfigGroup config(KGlobal::config(), "Window");
    const QByteArray geom = config.readEntry("Geometry", QByteArray());
    if (geom.isEmpty()) {
        setGeometry(qApp->desktop()->screenGeometry());
    } else {
        restoreGeometry(geom);
    }
    setCentralWidget(m_widget);
    connect(m_widget, SIGNAL(titleChanged(QString)), SLOT(setCaption(QString)));

    m_actions = new KActionCollection(this);
    m_actions->setConfigGroup("Shortcuts");
    m_actions->addAssociatedWidget(this);
    KAction *backAction = m_actions->addAction("back");
    backAction->setAutoRepeat(false);
    backAction->setShortcut(Qt::Key_Back);

    m_widget->rootContext()->setContextProperty("application", this);
}

ActiveBrowserWindow::~ActiveBrowserWindow()
{
}

View* ActiveBrowserWindow::view()
{
    return m_widget;
}

void ActiveBrowserWindow::closeEvent(QCloseEvent *)
{
    KConfigGroup config(KGlobal::config(), "Window");
    config.writeEntry("Geometry", saveGeometry());
}

QString ActiveBrowserWindow::name()
{
    return "Active Browser";
}

QIcon ActiveBrowserWindow::icon()
{
    return KIcon("internet-web-browser");
}

void ActiveBrowserWindow::setUseGL(const bool on)
{
    m_widget->setUseGL(on);
}

bool ActiveBrowserWindow::useGL() const
{
    return m_widget->useGL();
}

void ActiveBrowserWindow::setCaption(const QString &caption)
{
    setWindowTitle(caption);
}

QAction *ActiveBrowserWindow::action(const QString &name)
{
    return m_actions->action(name);
}

#include "activebrowserwindow.moc"
