/*
 *  Copyright 2012 Aaron Seigo <aseigo@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "sshdhelper.h"

#include <QProcess>
#include <QFile>
#include <QDebug>

static const QLatin1String startCommand("systemctl start sshd.service");
static const QLatin1String startAtBootCommand("systemctl enabled sshd.service");
static const QLatin1String stopCommand("systemctl stop sshd.service");
static const QLatin1String stopAtBootCommand("systemctl disabled sshd.service");

SshdHelper::SshdHelper(QObject *parent)
    : QObject(parent)
{
}

ActionReply SshdHelper::start(const QVariantMap &args)
{
    Q_UNUSED(args)
    int rv = QProcess::execute(startCommand);

    if (rv == 0) {
        rv = QProcess::execute(startAtBootCommand);
    }

    if (rv == 0) {
        return ActionReply::SuccessReply;
    } else {
        ActionReply reply(ActionReply::HelperError);
        reply.setErrorCode(rv);
        return reply;
    }
}

ActionReply SshdHelper::stop(const QVariantMap &args)
{
    Q_UNUSED(args)
    int rv = QProcess::execute(stopCommand);

    if (rv == 0) {
        rv = QProcess::execute(stopAtBootCommand);
    }

    if (rv == 0) {
        return ActionReply::SuccessReply;
    } else {
        ActionReply reply(ActionReply::HelperError);
        reply.setErrorCode(rv);
        return reply;
    }
}

KDE4_AUTH_HELPER_MAIN("org.kde.active.sshdcontrol", SshdHelper)
