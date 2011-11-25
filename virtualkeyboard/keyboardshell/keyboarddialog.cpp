/*
 *   Copyright 2007-2008 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2 as
 *   published by the Free Software Foundation
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

#include "keyboarddialog.h"

#include <cmath>

#include <QAction>
#include <QApplication>
#include <QDesktopWidget>
#include <QDBusInterface>
#include <QDBusPendingCallWatcher>
#include <QDBusReply>
#include <QFileInfo>
#include <QDir>
#include <QPushButton>
#include <QGraphicsLinearLayout>
#include <QTimer>

#include <KStandardDirs>
#include <KWindowSystem>
#include <KIcon>
#include <KIconLoader>
#include <KCmdLineArgs>

#include <Plasma/Applet>
#include <Plasma/PopupApplet>
#include <Plasma/Corona>
#include <Plasma/Containment>
#include <Plasma/IconWidget>
#include <Plasma/WindowEffects>

KeyboardDialog::KeyboardDialog(Plasma::Corona *corona, Plasma::Containment *containment, const QString &pluginName, int appletId, const QVariantList &appletArgs, QWidget *parent)
    : Plasma::Dialog(parent),
      m_applet(0),
      m_containment(0),
      m_corona(corona),
      m_location(Plasma::Floating),
      m_switchKeyboardLayoutScheduled(false)
{
    setContainment(containment);
    m_closeButton = new Plasma::IconWidget(m_containment);
    m_closeButton->setSvg("widgets/configuration-icons", "close");
    m_closeButton->setMaximumSize(QSize(KIconLoader::SizeMedium, KIconLoader::SizeMedium));
    connect(m_closeButton, SIGNAL(clicked()), this, SLOT(hide()));

    m_keyboardLayoutButton = new Plasma::IconWidget(m_containment);
    m_keyboardLayoutButton->setMaximumSize(QSize(KIconLoader::SizeMedium, KIconLoader::SizeMedium));
    connect(m_keyboardLayoutButton, SIGNAL(clicked()), this, SLOT(nextKeyboardLayout()));
    QDBusConnection dbus = QDBusConnection::sessionBus();
    dbus.connect("org.kde.keyboard", "/Layouts", "org.kde.KeyboardLayouts", "currentLayoutChanged", this, SLOT(currentKeyboardLayoutChanged()));
    dbus.connect("org.kde.keyboard", "/Layouts", "org.kde.KeyboardLayouts", "layoutListChanged", this, SLOT(refreshKeyboardLayoutInformation()));

    m_moveButton = new Plasma::IconWidget(m_containment);
    m_moveButton->setSvg("keyboardshell/arrows", "up-arrow");
    m_moveButton->setMaximumWidth(KIconLoader::SizeMedium);
    connect(m_moveButton, SIGNAL(clicked()), this, SLOT(swapScreenEdge()));

    m_containment->setFormFactor(Plasma::Planar);
    m_containment->setLocation(Plasma::BottomEdge);
    KWindowSystem::setType(winId(), NET::Dock);
    setAttribute(Qt::WA_X11DoNotAcceptFocus);
    setWindowFlags(Qt::X11BypassWindowManagerHint);

    QFileInfo info(pluginName);
    if (!info.isAbsolute()) {
        info = QFileInfo(QDir::currentPath() + "/" + pluginName);
    }

    if (info.exists()) {
        m_applet = Plasma::Applet::loadPlasmoid(info.absoluteFilePath(), appletId, appletArgs);
    }

    if (!m_applet) {
        m_applet = Plasma::Applet::load(pluginName, appletId, appletArgs);
    }

    // ensure that the keyboard knows when to reset itself
    connect(this, SIGNAL(dialogVisible(bool)), m_applet, SLOT(dialogStatusChanged(bool)));
    m_containment->addApplet(m_applet, QPointF(-1, -1), false);

    QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(m_containment);
    lay->addItem(m_applet);
    m_controlButtonsLayouts = new QGraphicsLinearLayout(Qt::Vertical);
    lay->addItem(m_controlButtonsLayouts);
    m_controlButtonsLayouts->addItem(m_closeButton);
    m_controlButtonsLayouts->addItem(m_moveButton);
    m_controlButtonsLayouts->addItem(m_keyboardLayoutButton);
    setGraphicsWidget(m_containment);

    if (!m_applet) {
#ifndef NDEBUG
        kWarning() << "Keyboard Plasmoid not found .. failing!";
#endif
        exit(1);
    }

    m_applet->setFlag(QGraphicsItem::ItemIsMovable, false);
    setWindowTitle(m_applet->name());
    setWindowIcon(SmallIcon(m_applet->icon()));

    connect(this, SIGNAL(sceneRectAboutToChange()), this, SLOT(updateGeometry()));
    QDesktopWidget *desktop = QApplication::desktop();
    connect(desktop, SIGNAL(resized(int )), this, SLOT(updateGeometry()));

    setFixedHeight(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());

    QRect screenGeom = desktop->screenGeometry(desktop->screenNumber(this));
    screenGeom.setWidth(screenGeom.width()-100);
    setFixedWidth(screenGeom.width());

    hide();
    setLocation(Plasma::BottomEdge);
    refreshKeyboardLayoutInformation();
}

KeyboardDialog::~KeyboardDialog()
{
    emit storeApplet(m_applet);
}

void KeyboardDialog::setContainment(Plasma::Containment *c)
{
    if (m_containment) {
        disconnect(m_containment, 0, this, 0);
    }

    m_containment = c;
    m_containment->setScreen(0);
    updateGeometry();
}

Plasma::Applet *KeyboardDialog::applet()
{
    return m_applet;
}

Plasma::Location KeyboardDialog::location() const
{
    return m_location;
}

Plasma::FormFactor KeyboardDialog::formFactor() const
{
    return m_containment->formFactor();
}

void KeyboardDialog::nextKeyboardLayout()
{
    m_switchKeyboardLayoutScheduled = true;
    refreshKeyboardLayoutInformation();
}

void KeyboardDialog::refreshKeyboardLayoutInformation()
{
    QDBusInterface keyboards("org.kde.keyboard", "/Layouts");
    QDBusPendingReply<QStringList> reply = keyboards.asyncCall("getLayoutsList");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);
    connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)),
            this, SLOT(layoutsReceived(QDBusPendingCallWatcher*)));
}

void KeyboardDialog::layoutsReceived(QDBusPendingCallWatcher *watcher)
{
    QDBusReply<QStringList> reply(*watcher);
    QTimer::singleShot(0, watcher, SLOT(deleteLater()));
    if (!reply.isValid()) {
        return;
    }

    m_keyboardLayouts = reply.value();
    if (m_keyboardLayouts.size() < 2) {
        m_keyboardLayoutButton->hide();
        m_controlButtonsLayouts->removeItem(m_keyboardLayoutButton);
    } else {
        if (!m_keyboardLayoutButton->isVisible()) {
            m_keyboardLayoutButton->show();
            m_controlButtonsLayouts->addItem(m_keyboardLayoutButton);
        }
        QDBusInterface keyboards("org.kde.keyboard", "/Layouts");
        QDBusPendingReply<QString> reply = keyboards.asyncCall("getCurrentLayout");
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);
        connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)),
                this, SLOT(currentLayoutReceived(QDBusPendingCallWatcher*)));
    }
}

void KeyboardDialog::currentLayoutReceived(QDBusPendingCallWatcher *watcher)
{
    QDBusReply<QString> reply(*watcher);
    QTimer::singleShot(0, watcher, SLOT(deleteLater()));
    if (!reply.isValid()) {
        return;
    }

    const QString layout = reply.value();
    int index = m_keyboardLayouts.indexOf(layout);
    if (index == -1) {
        refreshKeyboardLayoutInformation();
        return;
    }

    if (m_switchKeyboardLayoutScheduled) {
        m_switchKeyboardLayoutScheduled = false;
        index = (index + 1) % m_keyboardLayouts.count();

        QDBusInterface keyboards("org.kde.keyboard", "/Layouts");
        keyboards.asyncCall("setLayout", m_keyboardLayouts.at(index));
        return;
    }

    QIcon icon;
    if (m_iconMap.contains(layout)) {
        icon = m_iconMap[layout];
    } else {
        QString file;
        if (layout == "epo") {
            file = KStandardDirs::locate("data", "kcmkeyboard/pics/epo.png");
        } else {
            QString countryCode;
            if (countryCode == "nec_vndr/jp") {
                countryCode = "jp";
            } else if (layout.length() < 3) {
                countryCode = layout;
            }

            file = KStandardDirs::locate("locale", QString("l10n/%1/flag.png").arg(countryCode));
        }

        if (!file.isEmpty()) {
            icon.addFile(file);
        }
    }

    if (icon.isNull()) {
        m_keyboardLayoutButton->setIcon(QIcon());
        m_keyboardLayoutButton->setText(layout);
        m_iconMap.insert(layout, QIcon());
    } else {
        m_iconMap.insert(layout, icon);
        m_keyboardLayoutButton->setIcon(icon);
        m_keyboardLayoutButton->setText(QString());
    }
}

void KeyboardDialog::currentKeyboardLayoutChanged()
{
    refreshKeyboardLayoutInformation();
}

void KeyboardDialog::swapScreenEdge()
{
    switch (m_location) {
    case Plasma::TopEdge:
        setLocation(Plasma::BottomEdge);
        break;
    case Plasma::RightEdge:
        setLocation(Plasma::LeftEdge);
        break;
    case Plasma::LeftEdge:
        setLocation(Plasma::RightEdge);
        break;
    case Plasma::BottomEdge:
        setLocation(Plasma::TopEdge);
        break;
    default:
        break;
    }
}

void KeyboardDialog::setLocation(const Plasma::Location location)
{
    if (location == m_location) {
        return;
    }

    const Plasma::Location oldLocation = m_location;
    m_location = location;

    QDesktopWidget *desktop = QApplication::desktop();
    const QRect screenGeom = desktop->screenGeometry(desktop->screenNumber(this));

    switch (location) {
    case Plasma::TopEdge:
        setFixedSize(screenGeom.width() - 100, static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());
        move(screenGeom.left() + 50, screenGeom.top());
        m_moveButton->setSvg("keyboardshell/arrows", "down-arrow");
        break;
    case Plasma::RightEdge:
        setFixedSize(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).width(), screenGeom.height() - 100);
        move(screenGeom.right() - width(), screenGeom.top() + 50);
        m_moveButton->setSvg("keyboardshell/arrows", "left-arrow");
        break;
    case Plasma::LeftEdge:
        setFixedSize(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).width(), screenGeom.height() - 100);
        move(screenGeom.left(), screenGeom.top() + 50);
        m_moveButton->setSvg("keyboardshell/arrows", "right-arrow");
        break;
    case Plasma::BottomEdge:
        setFixedSize(screenGeom.width() - 100, static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());
        move(screenGeom.left() + 50, screenGeom.height() - height());
        m_moveButton->setSvg("keyboardshell/arrows", "up-arrow");
        break;
    default:
        // we don't support this location, so just revert back
        m_location = oldLocation;
        break;
    }

    if (isVisible()) {
        Plasma::WindowEffects::slideWindow(this, m_location);
    }
}

void KeyboardDialog::showEvent(QShowEvent *event)
{
    KWindowSystem::setType(winId(), NET::Dock);
    unsigned long state = NET::Sticky | NET::StaysOnTop | NET::KeepAbove;
    KWindowSystem::setState(winId(), state);
    KWindowSystem::raiseWindow(effectiveWinId());
    Plasma::Dialog::showEvent(event);

    //FIXME: this is an hack for the applet disabing itself in panic when doesn't immediately find a view
    Plasma::PopupApplet *pa = qobject_cast<Plasma::PopupApplet *>(m_applet);
    if (pa) {
        pa->graphicsWidget()->setEnabled(true);
    }
}

void KeyboardDialog::resizeEvent(QResizeEvent *event)
{
    if (event->oldSize() == event->size()) {
        return;
    }

    Plasma::Dialog::resizeEvent(event);
    QDesktopWidget *desktop = QApplication::desktop();
    switch (m_location) {
    case Plasma::TopEdge:
        move((desktop->size().width() / 2) - (event->size().width() / 2), desktop->screenGeometry().y());
        break;
    case Plasma::RightEdge:
        move(desktop->size().width() - event->size().width(), (desktop->size().height() / 2) - (event->size().height() / 2));
         break;
    case Plasma::LeftEdge:
        move(desktop->screenGeometry().x(), (desktop->size().height() / 2) - (event->size().width() / 2));
        break;
    case Plasma::BottomEdge:
        move((desktop->size().width() / 2) - (event->size().width() / 2), desktop->size().height() - event->size().height());
        break;
    default:
        break;
    }
}


#include "keyboarddialog.moc"

