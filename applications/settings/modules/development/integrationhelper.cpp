/*
 *  Copyright 2012 Aaron Seigo <aseigo@kde.org>
 *  Copyright 2012 Marco Martin <mart@kde.org>
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

#include "integrationhelper.h"

#include <QProcess>
#include <QFile>
#include <QDebug>


IntegrationHelper::IntegrationHelper(QObject *parent)
    : QObject(parent)
{
}

ActionReply IntegrationHelper::enable(const QVariantMap &args)
{
    Q_UNUSED(args)
    QStringList enableArgs;
    enableArgs << "ar" << "-r" << "'http://repo.pub.meego.com//Project:/KDE:/Integration/Project_KDE_Devel_CE_UX_PlasmaActive_i586/Project:KDE:Integration.repo'";

    int rv = QProcess::execute("zypper", enableArgs);

    if (rv == 0) {
        return ActionReply::SuccessReply;
    } else {
        ActionReply reply(ActionReply::HelperError);
        reply.setErrorCode(rv);
        return reply;
    }
}

ActionReply IntegrationHelper::disable(const QVariantMap &args)
{
    Q_UNUSED(args)
    QStringList disableArgs;
    disableArgs << "rr" << "Project_KDE_Integration";

    int rv = QProcess::execute("zypper", disableArgs);

    if (rv == 0) {
        return ActionReply::SuccessReply;
    } else {
        ActionReply reply(ActionReply::HelperError);
        reply.setErrorCode(rv);
        return reply;
    }
}

KDE4_AUTH_HELPER_MAIN("org.kde.active.integration", IntegrationHelper)
