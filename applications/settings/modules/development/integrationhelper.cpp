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

#include <KConfigGroup>
#include <KGlobal>
#include <KSharedConfig>

IntegrationHelper::IntegrationHelper(QObject *parent)
    : QObject(parent)
{
}

ActionReply IntegrationHelper::enable(const QVariantMap &args)
{
    Q_UNUSED(args)
    QStringList enableArgs;
    KConfigGroup confGroup(KGlobal::config(), "General");
    const QString devRepo = confGroup.readEntry("integrationBranch",
                                                "http://repo.merproject.org/obs/kde:/devel:/ux:/integration/latest_i586/kde:devel:ux:integration.repo");
    enableArgs << "ar" << "-r" << devRepo;

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
