/*
    SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include "info.h"

#include <KLocalizedString>
#include <KPluginFactory>
#include <QClipboard>
#include <QFile>
#include <QGuiApplication>
#include <QJsonArray>

K_PLUGIN_CLASS_WITH_JSON(Info, "kcm_mobile_info.json")

Info::Info(QObject *parent, const KPluginMetaData &metaData)
    : KQuickConfigModule(parent, metaData)
    , m_distroInfo(new DistroInfo(this))
    , m_softwareInfo(new SoftwareInfo(this))
    , m_hardwareInfo(new HardwareInfo(this))
{
    setButtons({});

    QFile vendorInfoFile;

    vendorInfoFile.setFileName("/etc/vendorinfo.json");
    vendorInfoFile.open(QIODevice::ReadOnly);
    m_vendorInfo = QJsonDocument::fromJson(vendorInfoFile.readAll());

    qDebug() << "Info module loaded.";
}

void Info::copyInfoToClipboard() const
{
    QString clipboardText = QStringLiteral(
                                      "Operating System: %1\n"
                                      "KDE Plasma Version: %2\n"
                                      "KDE Frameworks Version: %3\n"
                                      "Qt Version: %4\n"
                                      "Kernel Version: %5\n"
                                      "OS-Type: %6\n"
                                      "Processor: %7\n"
                                      "Memory: %8\n")
                                      .arg(distroInfo()->name(),
                                           softwareInfo()->plasmaVersion(),
                                           softwareInfo()->frameworksVersion(),
                                           softwareInfo()->qtVersion(),
                                           softwareInfo()->kernelRelease(),
                                           softwareInfo()->osType(),
                                           hardwareInfo()->processors(),
                                           hardwareInfo()->memory());

    // add vendor information if available
    if (!vendorInfoTitle().isEmpty()) {
        for (const auto &li : vendorInfo()) {
            const auto &m = li.toMap();
            clipboardText.append(QString("%1: %2\n").arg(
                m[QStringLiteral("Key")].toString(),
                m[QStringLiteral("Value")].toString()
            ));
        }
    }

    QGuiApplication::clipboard()->setText(clipboardText);
}

DistroInfo *Info::distroInfo() const
{
    return m_distroInfo;
}

SoftwareInfo *Info::softwareInfo() const
{
    return m_softwareInfo;
}

HardwareInfo *Info::hardwareInfo() const
{
    return m_hardwareInfo;
}

QString Info::vendorInfoTitle() const
{
    return m_vendorInfo[QStringLiteral("Title")].toString();
}

QVariantList Info::vendorInfo() const
{
    return m_vendorInfo[QStringLiteral("Content")].toArray().toVariantList();
}

#include "info.moc"
