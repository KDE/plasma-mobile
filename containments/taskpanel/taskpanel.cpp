/***************************************************************************
 *   Copyright (C) 2015 Marco Martin <mart@kde.org>                        *
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

#include "taskpanel.h"

#include <QtQml>
#include <QDebug>
#include <QDBusMessage>
#include <QDBusConnection>

#include <Plasma/Package>

static const QString s_kwinService = QStringLiteral("org.kde.KWin");

TaskPanel::TaskPanel(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
{
    setHasConfigurationInterface(true);
}

TaskPanel::~TaskPanel()
{
}

void TaskPanel::executeScript(const QString &script)
{
    //Plasma::Package p = 
    qWarning()<<"AAAAAA"<<package().filePath("scripts", script + ".js")<<package().path();
    QDBusMessage message = QDBusMessage::createMethodCall(s_kwinService, "/Scripting", QString(), "loadScript");
    QList<QVariant> arguments;
    arguments << QVariant(package().filePath("scripts", script + ".js"));
    message.setArguments(arguments);
    QDBusMessage reply = QDBusConnection::sessionBus().call(message);
    if (reply.type() == QDBusMessage::ErrorMessage) {
        qWarning() << reply.errorMessage();
    } else {
        const int id = reply.arguments().first().toInt();
        QDBusConnection::sessionBus().connect(s_kwinService, "/" + QString::number(id), QString(), "print", this, SLOT(print(QString)));
        QDBusConnection::sessionBus().connect(s_kwinService, "/" + QString::number(id), QString(), "printError", this, SLOT(print(QString)));
        message = QDBusMessage::createMethodCall(s_kwinService, "/" + QString::number(id), QString(), "run");
        reply = QDBusConnection::sessionBus().call(message);
        if (reply.type() == QDBusMessage::ErrorMessage) {
            qWarning() << reply.errorMessage();
        }
    }
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(taskpanel, TaskPanel, "metadata.json")

#include "taskpanel.moc"
