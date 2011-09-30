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

#include <Plasma/Theme>

#include "aboutapp.h"

AboutApp::AboutApp()
    : KMainWindow()
{
    setAcceptDrops(true);
    addAction(KStandardAction::close(this, SLOT(close()), this));
    addAction(KStandardAction::quit(this, SLOT(close()), this));
    m_widget = new AppView(this);

    restoreWindowSize(config("Window"));
    setCentralWidget(m_widget);

    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);

    connect(m_widget, SIGNAL(titleChanged(QString)), SLOT(setCaption(QString)));
}

AboutApp::~AboutApp()
{
    saveWindowSize(config("Window"));
}

KConfigGroup AboutApp::config(const QString &group)
{
    return KConfigGroup(KSharedConfig::openConfig("active-aboutapprc"), group);
}

QString AboutApp::name()
{
    return "About Plasma Active";
    //return m_widget->options()->name;
}

QIcon AboutApp::icon()
{
    return KIcon("active-about");
}

void AboutApp::setUseGL(const bool on)
{
    m_widget->setUseGL(on);
}

bool AboutApp::useGL() const
{
    return m_widget->useGL();
}

#include "aboutapp.moc"
