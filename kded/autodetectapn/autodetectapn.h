// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-GPL

#pragma once

#include <kdedmodule.h>

#include <QCoroDBusPendingReply>

#include <ModemManagerQt/GenericTypes>
#include <ModemManagerQt/ModemDevice>
#include <NetworkManagerQt/ModemDevice>

class AutoDetectAPN : public KDEDModule
{
    Q_OBJECT

public:
    AutoDetectAPN(QObject *parent, const QList<QVariant> &);

    struct APNEntry {
        QString apn;
        QString carrier;
        QString protocol;
    };

    std::optional<APNEntry> findAPN(const QString &operatorCode, const QString &gid1, const QString &spn, const QString &imsi) const;

private:
    QCoro::Task<void> checkAndAddAutodetectedAPN();
    NetworkManager::ModemDevice::Ptr findNMModem(ModemManager::Modem::Ptr mmModem);
};
