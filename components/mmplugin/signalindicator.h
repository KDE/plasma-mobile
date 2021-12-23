// SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <ModemManagerQt/Manager>
#include <ModemManagerQt/modem3gpp.h>
#include <QObject>

class SignalIndicator : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int strength READ strength NOTIFY strengthChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool simLocked READ simLocked NOTIFY simLockedChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)

public:
    SignalIndicator();

    int strength() const;
    QString name() const;
    bool simLocked() const;
    bool available() const;

Q_SIGNALS:
    void strengthChanged();
    void nameChanged();
    void simLockedChanged();
    void availableChanged();

private:
    ModemManager::Modem::Ptr m_modem;
    ModemManager::Modem3gpp::Ptr m_3gppModem;
    void updateModem();
};
