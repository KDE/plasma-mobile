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

#include "kdeclarativemainwindow.h"
#include "kdeclarativeview.h"

#include <QDeclarativeContext>

#include <KAction>
#include <KStandardAction>

#include <Plasma/Theme>



class KDeclarativeMainWindowPrivate
{
public:
    KDeclarativeView *view;
};


KDeclarativeMainWindow::KDeclarativeMainWindow()
    : KMainWindow(),
      d(new KDeclarativeMainWindowPrivate())
{
    setAcceptDrops(true);
    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);
    addAction(KStandardAction::close(this, SLOT(close()), this));
    addAction(KStandardAction::quit(this, SLOT(close()), this));

    d->view = new KDeclarativeView(this);

    restoreWindowSize(config("Window"));
    setCentralWidget(d->view);

    connect(d->view, SIGNAL(titleChanged(QString)), SLOT(setCaption(QString)));
}

KDeclarativeMainWindow::~KDeclarativeMainWindow()
{
    saveWindowSize(config("Window"));
}


KConfigGroup KDeclarativeMainWindow::config(const QString &group)
{
    return KConfigGroup(KSharedConfig::openConfig("imageviewerrc"), group);
}

void KDeclarativeMainWindow::setUseGL(const bool on)
{
    d->view->setUseGL(on);
}

bool KDeclarativeMainWindow::useGL() const
{
    return d->view->useGL();
}

#include "kdeclarativemainwindow.moc"
