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

// KDE

#include <KDebug>
#include <KIcon>
#include <KLineEdit>
#include <KIconLoader>
#include <plasma/widgets/iconwidget.h>
#include <plasma/tooltipmanager.h>

AppSwitcher::AppSwitcher(QObject *parent, const QVariantList &args)
    : Plasma::Applet(parent, args)
{
    setBackgroundHints(NoBackground);
    //setAspectRatioMode(Plasma::Square);
    resize(80, 80);
}

void AppSwitcher::init()
{
    QGraphicsLinearLayout *layout = new QGraphicsLinearLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(0);

    Plasma::IconWidget *icon = new Plasma::IconWidget(KIcon("dashboard-show"), QString(), this);
    registerAsDragHandle(icon);
    icon->setMinimumSize(16, 16);
    setMinimumSize(16, 16);
    layout->addItem(icon);
  
    setImmutability(Plasma::SystemImmutable);
    
    //### FIXME doesn't work well
    /*Plasma::ToolTipManager::self()->registerWidget(this);
    Plasma::ToolTipContent toolTipData(i18n("Show the hildon application switcher"), QString(),
                                       icon->icon().pixmap(IconSize(KIconLoader::Desktop)));
    Plasma::ToolTipManager::self()->setContent(this, toolTipData);*/
    setAspectRatioMode(Plasma::ConstrainedSquare);

    connect(icon, SIGNAL(pressed(bool)),this, SLOT(toggleAppSwitcher(bool)));
    connect(this, SIGNAL(activate()), this, SLOT(toggleAppSwitcher()));
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
#ifdef Q_WS_MAEMO_5
    QDBusMessage signal = QDBusMessage::createSignal("/com/nokia/hildon_desktop", "com.nokia.hildon_desktop", "exit_app_view");
    QDBusConnection::sessionBus().send(signal);
#endif
}

#include "appswitcher.moc"
