/*
 *   Copyright 2009 by Alexis Menard <menard@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2,
 *   or (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "appswitcher.h"

//Qt
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusConnection>
#include <QGraphicsLinearLayout>
#include <QGraphicsView>

// KDE

#include <KDebug>
#include <KIcon>
#include <KLineEdit>
#include <KIconLoader>
#include <KWindowSystem>
#include <plasma/widgets/iconwidget.h>
#include <plasma/tooltipmanager.h>
#include <Plasma/Theme>
#include <Plasma/WindowEffects>

AppSwitcher::AppSwitcher(QObject *parent, const QVariantList &args)
    : Plasma::Applet(parent, args)
{
    setBackgroundHints(NoBackground);
    resize(80, 80);
}

void AppSwitcher::init()
{
    QGraphicsLinearLayout *layout = new QGraphicsLinearLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(0);

    Plasma::IconWidget *icon = new Plasma::IconWidget(this);
    if (!Plasma::Theme::defaultTheme()->imagePath("icons/dashboard").isEmpty()) {
        icon->setSvg("icons/dashboard", "dashboard-show");
    } else {
        icon->setIcon(KIcon("dashboard-show"));
    }
    icon->setMinimumSize(16, 16);
    setMinimumSize(16, 16);
    layout->addItem(icon);

    setImmutability(Plasma::SystemImmutable);

    setAspectRatioMode(Plasma::ConstrainedSquare);

    connect(icon, SIGNAL(clicked()), this, SLOT(toggleAppSwitcher()));
}

AppSwitcher::~AppSwitcher()
{
}

void AppSwitcher::toggleAppSwitcher(bool pressed)
{
    if (!pressed) {
        return;
    }

    toggleAppSwitcher();
}

void AppSwitcher::toggleAppSwitcher()
{
    Plasma::WindowEffects::presentWindows(view()->effectiveWinId() , KWindowSystem::currentDesktop());
}

#include "appswitcher.moc"
