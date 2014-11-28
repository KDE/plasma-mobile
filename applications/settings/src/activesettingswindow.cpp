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

#include "activesettingswindow.h"

#include <QApplication>
#include <QDesktopWidget>

#include <KAction>
#include <KStandardAction>

#include <Plasma/Theme>

#include "view.h"

ActiveSettingsWindow::ActiveSettingsWindow(const QString &url, QWindow *parent)
    : QQuickWindow(parent)
{
    QQuickWindow::setDefaultAlphaBuffer(true);

    //setAcceptDrops(true);
//     addAction(KStandardAction::close(this, SLOT(close()), this));
//     addAction(KStandardAction::quit(this, SLOT(close()), this));
    m_widget = new View(url, this);

    KConfigGroup config(KSharedConfig::openConfig(), "Window");
    const QByteArray geom = config.readEntry("Geometry", QByteArray());
    if (geom.isEmpty()) {
        setGeometry(qApp->desktop()->screenGeometry());
    } else {
#warning "Port restoreGeometry"
        //restoreGeometry(geom);
    }
    //setCentralWidget(m_widget);
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
    KConfigGroup config(KSharedConfig::openConfig(), "Window");
    config.writeEntry("Geometry", geometry());
}

QString ActiveSettingsWindow::name()
{
    return "Settings";
}

QIcon ActiveSettingsWindow::icon()
{
    return QIcon::fromTheme("preferences-desktop");
}

#include "activesettingswindow.moc"
