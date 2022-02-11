// SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <ModemManagerQt/Manager>
#include <ModemManagerQt/modem3gpp.h>

#include <QObject>

// We make the assumption that there is only one modem.
class SignalIndicator : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int strength READ strength NOTIFY strengthChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool simLocked READ simLocked NOTIFY simLockedChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(bool wwanEnabled READ wwanEnabled WRITE setWwanEnabled NOTIFY wwanEnabledChanged)

public:
    SignalIndicator();

    int strength() const;
    QString name() const;
    bool simLocked() const;
    bool available() const;
    bool wwanEnabled() const;

    void setWwanEnabled(bool wwanEnabled);

Q_SIGNALS:
    void strengthChanged();
    void nameChanged();
    void simLockedChanged();
    void availableChanged();
    void wwanEnabledChanged();

private:
    ModemManager::Modem::Ptr m_modem;
    ModemManager::Modem3gpp::Ptr m_3gppModem;
    void updateModem();
};
