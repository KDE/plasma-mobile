/*
    SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
    SPDX-FileCopyrightText: 2012-2019 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include "softwareinfo.h"
#include <sys/utsname.h>

#include <KConfigGroup>
#include <KCoreAddons>
#include <KDesktopFile>
#include <KLocalizedString>
#include <QDebug>
#include <QStandardPaths>

SoftwareInfo::SoftwareInfo(QObject *parent)
    : QObject(parent)
{
}

QString SoftwareInfo::kernelRelease() const
{
    struct utsname utsName {
    };
    uname(&utsName);

    return QString::fromLatin1(utsName.release);
}

QString SoftwareInfo::frameworksVersion() const
{
    return KCoreAddons::versionString();
}

QString SoftwareInfo::qtVersion() const
{
    return QString::fromLatin1(qVersion());
}

QString SoftwareInfo::plasmaVersion() const
{
    const QStringList &filePaths = QStandardPaths::locateAll(QStandardPaths::GenericDataLocation, QStringLiteral("wayland-sessions/plasma.desktop"));

    if (filePaths.length() < 1) {
        return QString();
    }

    // Despite the fact that there can be multiple desktop files we simply take
    // the first one as users usually don't have xsessions/ in their $HOME
    // data location, so the first match should (usually) be the only one and
    // reflect the plasma session run.
    KDesktopFile desktopFile(filePaths.first());
    return desktopFile.desktopGroup().readEntry("X-KDE-PluginInfo-Version", QString());
}

QString SoftwareInfo::osType() const
{
    const int bits = QT_POINTER_SIZE == 8 ? 64 : 32;

    return QString::number(bits);
}
