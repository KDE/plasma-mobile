// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QObject>

#include <KConfigGroup>
#include <KSharedConfig>

class DevicePresets : public QObject
{
    Q_OBJECT

public:
    DevicePresets(QObject *parent = nullptr);

    void initialize();

private:
    KSharedConfig::Ptr m_mobileConfig;
};
