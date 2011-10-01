/*
 * Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License version 2 as
 * published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusPendingReply>

// kde-workspace/libs
#include <kworkspace/kworkspace.h>

#include "powermanagementjob.h"

#include <kdebug.h>

PowerManagementJob::PowerManagementJob(const QString &operation, QMap<QString, QVariant> &parameters, QObject *parent) :
    ServiceJob(parent->objectName(), operation, parameters, parent)
{
}

PowerManagementJob::~PowerManagementJob()
{
}

void PowerManagementJob::start()
{
    const QString operation = operationName();
    kDebug() << "starting operation  ... " << operation;

    if (operation == "suspend") {
        // suspend the device
        setResult(suspend());
        return;
    } else if (operation == "requestShutDown") {
        // Show the shutdown dialog
        setResult(requestShutDown());
        return;
    }
    kDebug() << "don't know what to do with " << operation;
    setResult(false);
}

bool PowerManagementJob::suspend()
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.Solid.PowerManagement",
                                                      "/org/kde/Solid/PowerManagement",
                                                      "org.kde.Solid.PowerManagement",
                                                      "suspendToRam");
    QDBusConnection::sessionBus().asyncCall(msg);
    return true;
}

bool PowerManagementJob::requestShutDown()
{
    KWorkSpace::requestShutDown();
    return true;
}

#include "powermanagementjob.moc"
