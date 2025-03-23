/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "taskpanel.h"

#include <QDBusConnection>
#include <QDBusPendingReply>
#include <QDebug>
#include <QGuiApplication>

// register type for Keyboards.KWinVirtualKeyboard.forceActivate();
Q_DECLARE_METATYPE(QDBusPendingReply<>)

TaskPanel::TaskPanel(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment(parent, data, args)
{

}

void TaskPanel::triggerTaskSwitcher() const
{
    QDBusMessage message = QDBusMessage::createMethodCall("org.kde.kglobalaccel", "/component/kwin", "org.kde.kglobalaccel.Component", "invokeShortcut");
    message.setArguments({QStringLiteral("Mobile Task Switcher")});

    // this does not block, so it won't necessarily be called before the method returns
    QDBusConnection::sessionBus().send(message);
}

K_PLUGIN_CLASS(TaskPanel)

#include "taskpanel.moc"
