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

#include "activesettingswindow.h"

#include <QApplication>
#include <QDesktopWidget>

#include <KAction>
#include <KIcon>
#include <KStandardAction>

#include <Plasma/Theme>

#include "view.h"

ActiveSettingsWindow::ActiveSettingsWindow(const QString &url, QWidget *parent)
    : QMainWindow(parent)
{
    setAcceptDrops(true);
    addAction(KStandardAction::close(this, SLOT(close()), this));
    addAction(KStandardAction::quit(this, SLOT(close()), this));
    m_widget = new View(url, this);

    KConfigGroup config(KGlobal::config(), "Window");
    const QByteArray geom = config.readEntry("Geometry", QByteArray());
    if (geom.isEmpty()) {
        setGeometry(qApp->desktop()->screenGeometry());
    } else {
        restoreGeometry(geom);
    }
    setCentralWidget(m_widget);

    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    /*
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);
    */
}

ActiveSettingsWindow::~ActiveSettingsWindow()
{
}

View* ActiveSettingsWindow::view()
{
    return m_widget;
}

void ActiveSettingsWindow::closeEvent(QCloseEvent *)
{
    KConfigGroup config(KGlobal::config(), "Window");
    config.writeEntry("Geometry", saveGeometry());
}

QString ActiveSettingsWindow::name()
{
    return "Settings";
}

QIcon ActiveSettingsWindow::icon()
{
    return KIcon("preferences-desktop");
}

#include "activesettingswindow.moc"
