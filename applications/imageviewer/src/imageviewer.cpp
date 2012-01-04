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

#include <KAction>
#include <KIcon>
#include <KStandardAction>
#include <KConfigGroup>

#include <Plasma/Theme>

#include "imageviewer.h"

ImageViewer::ImageViewer(const QString &url)
    : KMainWindow()
{
    setAcceptDrops(true);
    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);
    addAction(KStandardAction::close(this, SLOT(close()), this));
    addAction(KStandardAction::quit(this, SLOT(close()), this));
    m_widget = new KDeclarativeView(this);
    m_widget->setPackageName("org.kde.active.imageviewer");

    restoreWindowSize(config("Window"));
    setCentralWidget(m_widget);

    connect(m_widget, SIGNAL(titleChanged(QString)), SLOT(setCaption(QString)));
}

ImageViewer::~ImageViewer()
{
    saveWindowSize(config("Window"));
}

KConfigGroup ImageViewer::config(const QString &group)
{
    return KConfigGroup(KSharedConfig::openConfig("imageviewerrc"), group);
}

QString ImageViewer::name()
{
    return "Active image viewer";
    //return m_widget->options()->name;
}

QIcon ImageViewer::icon()
{
    return KIcon("gwenview");
}

void ImageViewer::setUseGL(const bool on)
{
    m_widget->setUseGL(on);
}

bool ImageViewer::useGL() const
{
    return m_widget->useGL();
}

#include "imageviewer.moc"
