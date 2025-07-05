/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>

#include <qqmlregistration.h>
#include <qtmetamacros.h>

class WaydroidState : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(bool sessionRunning READ sessionRunning NOTIFY sessionRunningChanged)

public:
    WaydroidState(QObject *parent = nullptr);

    enum Status {
        NotSupported = 0,
        NotInitialized,
        Initialiazing,
        Initialized,
        FailedToInitialize
    };
    Q_ENUM(Status)

    enum SystemType {
        Vanilla = 0,
        Foss,
        Gapps
    };
    Q_ENUM(SystemType)

    enum RomType {
        Lineage = 0,
        Bliss
    };
    Q_ENUM(RomType)

    Q_INVOKABLE void checkSupports();
    Q_INVOKABLE void initialize(const SystemType systemType, const RomType romType, const bool forced = false);
    Q_INVOKABLE void startSession();
    Q_INVOKABLE void stopSession();

    Status status() const;
    bool sessionRunning() const;

Q_SIGNALS:
    void statusChanged();
    void sessionRunningChanged();

private:
    Status m_status{Status::NotInitialized};
    bool m_sessionRunning{false};
};
