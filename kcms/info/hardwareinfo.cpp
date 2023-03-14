/*
    SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
    SPDX-FileCopyrightText: 2012-2019 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include "hardwareinfo.h"

#include <KCoreAddons>
#include <KFormat>

#include <solid/device.h>
#include <solid/processor.h>

#include <KLocalizedString>

#ifdef Q_OS_LINUX
#include <sys/sysinfo.h>
#elif defined(Q_OS_FREEBSD)
#include <sys/sysctl.h>
#include <sys/types.h>
#endif

HardwareInfo::HardwareInfo(QObject *parent)
    : QObject(parent)
{
}

int HardwareInfo::processorCount() const
{
    return Solid::Device::listFromType(Solid::DeviceInterface::Processor).count();
}

QString HardwareInfo::processors() const
{
    const auto list = Solid::Device::listFromType(Solid::DeviceInterface::Processor);

    // Format processor string
    // Group by processor name
    QMap<QString, int> processorMap;
    for (const auto &device : list) {
        const QString name = device.product();
        auto it = processorMap.find(name);
        if (it == processorMap.end()) {
            processorMap.insert(name, 1);
        } else {
            ++it.value();
        }
    }
    // Create a formatted list of grouped processors
    QStringList names;
    names.reserve(processorMap.count());
    for (auto it = processorMap.constBegin(); it != processorMap.constEnd(); ++it) {
        const int count = it.value();
        QString name = it.key();
        name.replace(QStringLiteral("(TM)"), QChar(8482));
        name.replace(QStringLiteral("(R)"), QChar(174));
        name = name.simplified();
        names.append(QStringLiteral("%1 × %2").arg(count).arg(name));
    }

    const QString processorLabel = names.join(QLatin1String(", "));

    return processorLabel;
}

QString HardwareInfo::memory() const
{
    qlonglong totalRam = -1;
#ifdef Q_OS_LINUX
    struct sysinfo info {
    };
    if (sysinfo(&info) == 0)
        // manpage "sizes are given as multiples of mem_unit bytes"
        totalRam = qlonglong(info.totalram) * info.mem_unit;
#elif defined(Q_OS_FREEBSD)
    /* Stuff for sysctl */
    size_t len;

    unsigned long memory;
    len = sizeof(memory);
    sysctlbyname("hw.physmem", &memory, &len, NULL, 0);

    totalRam = memory;
#endif

    return KFormat().formatByteSize(totalRam);
}
