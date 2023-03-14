/*
    SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include "distroinfo.h"
#include "hardwareinfo.h"
#include "softwareinfo.h"
#include <KQuickAddons/ConfigModule>

#ifndef INFO_H
#define INFO_H

class Info : public KQuickAddons::ConfigModule
{
    Q_OBJECT

    Q_PROPERTY(DistroInfo *distroInfo READ distroInfo NOTIFY distroInfoChanged)
    Q_PROPERTY(SoftwareInfo *softwareInfo READ softwareInfo NOTIFY softwareInfoChanged)
    Q_PROPERTY(HardwareInfo *hardwareInfo READ hardwareInfo NOTIFY hardwareInfoChanged)
    DistroInfo *distroInfo() const;
    SoftwareInfo *softwareInfo() const;
    HardwareInfo *hardwareInfo() const;

public:
    Info(QObject *parent, const KPluginMetaData &metaData, const QVariantList &args);

    Q_INVOKABLE void copyInfoToClipboard() const;

Q_SIGNALS:
    void distroInfoChanged();
    void softwareInfoChanged();
    void hardwareInfoChanged();

private:
    DistroInfo *m_distroInfo;
    SoftwareInfo *m_softwareInfo;
    HardwareInfo *m_hardwareInfo;
};

#endif // INFO_H
