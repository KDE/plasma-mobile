/*
 * SPDX-FileCopyrightText: 2015 David Edmundson <david@davidedmundson.co.uk>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 */

#include "statisticsprovider.h"

#include <QDBusArgument>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusMessage>
#include <QDBusMetaType> // qDBusRegisterMetaType
#include <QDBusPendingReply>
#include <QDebug>

const QDBusArgument &operator<<(QDBusArgument &argument, const HistoryReply &data)
{
    argument.beginStructure();
    argument << data.time << data.value << data.charging;
    argument.endStructure();
    return argument;
}

const QDBusArgument &operator>>(const QDBusArgument &arg, HistoryReply &attrs)
{
    arg.beginStructure();
    arg >> attrs.time >> attrs.value >> attrs.charging;
    arg.endStructure();
    return arg;
}

StatisticsProvider::StatisticsProvider(QObject *parent)
    : QObject(parent)
{
    m_type = StatisticsProvider::ChargeType;
    m_duration = 120;

    qDBusRegisterMetaType<HistoryReply>();
    qDBusRegisterMetaType<QList<HistoryReply>>();
}

void StatisticsProvider::setDevice(const QString &device)
{
    if (device == m_device) {
        return;
    }

    m_device = device;
    Q_EMIT deviceChanged();

    load();
}

void StatisticsProvider::setDuration(uint duration)
{
    if (duration == m_duration) {
        return;
    }

    m_duration = duration;
    Q_EMIT durationChanged();

    load();
}

void StatisticsProvider::setType(StatisticsProvider::HistoryType type)
{
    if (m_type == type) {
        return;
    }

    m_type = type;
    Q_EMIT typeChanged();

    load();
}

void StatisticsProvider::classBegin()
{
}

void StatisticsProvider::componentComplete()
{
    m_isComplete = true;
    load();
}

QVariantList StatisticsProvider::asPoints() const
{
    QVariantList points;
    points.reserve(m_values.count());
    foreach (const HistoryReply &h, m_values) {
        points.append(QPointF(h.time, h.value));
    }

    if (!points.isEmpty()) {
        points.takeLast();
    }

    return points;
}

int StatisticsProvider::count() const
{
    return m_values.count();
}

int StatisticsProvider::firstDataPointTime() const
{
    if (m_values.isEmpty()) {
        return 0;
    }

    return m_values.first().time;
}

int StatisticsProvider::lastDataPointTime() const
{
    if (m_values.isEmpty()) {
        return 0;
    }

    return m_values.last().time;
}

int StatisticsProvider::largestValue() const
{
    if (m_values.isEmpty()) {
        return 0;
    }

    int max = 0; // TODO std::max or something?
    for (auto it = m_values.constBegin(), end = m_values.constEnd(); it != end; ++it) {
        if ((*it).value > max) {
            max = (*it).value;
        }
    }
    return max;
}

void StatisticsProvider::refresh()
{
    load();
}

void StatisticsProvider::load()
{
    if (!m_isComplete || m_device.isEmpty()) {
        return;
    }

    auto msg = QDBusMessage::createMethodCall(QStringLiteral("org.freedesktop.UPower"),
                                              m_device,
                                              QStringLiteral("org.freedesktop.UPower.Device"),
                                              QStringLiteral("GetHistory"));
    if (m_type == RateType) {
        msg << QLatin1String("rate");
    } else { // m_type must = ChargeType
        msg << QLatin1String("charge");
    }

    uint resolution = 100;
    msg << m_duration << resolution;

    QDBusPendingReply<QList<HistoryReply>> reply = QDBusConnection::systemBus().asyncCall(msg);

    auto *watcher = new QDBusPendingCallWatcher(reply, this);
    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](QDBusPendingCallWatcher *watcher) {
        QDBusPendingReply<QList<HistoryReply>> reply = *watcher;
        watcher->deleteLater();
        m_values.clear();

        if (reply.isError()) {
            qWarning() << "Failed to get device history from UPower" << reply.error().message();
            return;
        }

        foreach (const HistoryReply &r, reply.value()) {
            if (r.value > 0) { // we get back some values which contain no value, possibly to indicate if charging changes, ignore them
                m_values.prepend(r);
            }
        }

        Q_EMIT dataChanged();
    });
}
