// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QDBusArgument>
#include <QList>

class VibrationEvent
{
public:
    double amplitude;
    quint32 duration;
};

using VibrationEventList = QList<VibrationEvent>;

Q_DECLARE_METATYPE(VibrationEvent)
Q_DECLARE_METATYPE(VibrationEventList)

inline QDBusArgument &operator<<(QDBusArgument &argument, const VibrationEvent &e)
{
    argument.beginStructure();
    argument << e.amplitude;
    argument << e.duration;
    argument.endStructure();
    return argument;
}

inline const QDBusArgument &operator>>(const QDBusArgument &argument, VibrationEvent &e)
{
    argument.beginStructure();
    argument >> e.amplitude;
    argument >> e.duration;
    argument.endStructure();
    return argument;
}
