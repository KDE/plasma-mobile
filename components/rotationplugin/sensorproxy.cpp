// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "sensorproxy.h"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusServiceWatcher>
#include <QVariantMap>

static constexpr auto SERVICE = "net.hadess.SensorProxy";
static constexpr auto PATH = "/net/hadess/SensorProxy";
static constexpr auto INTERFACE = "net.hadess.SensorProxy";
static constexpr auto PROPERTIES_INTERFACE = "org.freedesktop.DBus.Properties";

static SensorProxy::Orientation mapOrientation(const QString &orientation)
{
    if (orientation == QLatin1String("normal")) {
        return SensorProxy::Orientation::TopUp;
    }
    if (orientation == QLatin1String("bottom-up")) {
        return SensorProxy::Orientation::TopDown;
    }
    if (orientation == QLatin1String("left-up")) {
        return SensorProxy::Orientation::LeftUp;
    }
    if (orientation == QLatin1String("right-up")) {
        return SensorProxy::Orientation::RightUp;
    }
    return SensorProxy::Orientation::Undefined;
}

SensorProxy::SensorProxy(QObject *parent)
    : QObject{parent}
    , m_serviceWatcher{new QDBusServiceWatcher(QString::fromLatin1(SERVICE),
                                               QDBusConnection::systemBus(),
                                               QDBusServiceWatcher::WatchForRegistration | QDBusServiceWatcher::WatchForUnregistration,
                                               this)}
{
    connect(m_serviceWatcher, &QDBusServiceWatcher::serviceRegistered, this, [this]() {
        const bool shouldReclaim = m_claimed;
        m_claimed = false;
        if (shouldReclaim) {
            claimAccelerometer();
        }
        refreshProperties();
    });
    connect(m_serviceWatcher, &QDBusServiceWatcher::serviceUnregistered, this, [this]() {
        setAvailable(false);
        setOrientation(Orientation::Undefined);
    });

    QDBusConnection::systemBus().connect(QString::fromLatin1(SERVICE),
                                         QString::fromLatin1(PATH),
                                         QString::fromLatin1(PROPERTIES_INTERFACE),
                                         QStringLiteral("PropertiesChanged"),
                                         this,
                                         SLOT(propertiesChanged(QString, QVariantMap, QStringList)));

    refreshProperties();
}

SensorProxy::~SensorProxy()
{
    releaseAccelerometer();
}

bool SensorProxy::available() const
{
    return m_available;
}

SensorProxy::Orientation SensorProxy::orientation() const
{
    return m_orientation;
}

void SensorProxy::claimAccelerometer()
{
    if (m_claimed) {
        return;
    }

    QDBusInterface sensorProxy(QString::fromLatin1(SERVICE), QString::fromLatin1(PATH), QString::fromLatin1(INTERFACE), QDBusConnection::systemBus());
    sensorProxy.asyncCall(QStringLiteral("ClaimAccelerometer"));
    m_claimed = true;
}

void SensorProxy::releaseAccelerometer()
{
    if (!m_claimed) {
        return;
    }

    QDBusInterface sensorProxy(QString::fromLatin1(SERVICE), QString::fromLatin1(PATH), QString::fromLatin1(INTERFACE), QDBusConnection::systemBus());
    sensorProxy.asyncCall(QStringLiteral("ReleaseAccelerometer"));
    m_claimed = false;
}

void SensorProxy::refreshProperties()
{
    QDBusInterface properties(QString::fromLatin1(SERVICE), QString::fromLatin1(PATH), QString::fromLatin1(PROPERTIES_INTERFACE), QDBusConnection::systemBus());

    const QDBusReply<QVariantMap> reply = properties.call(QStringLiteral("GetAll"), QString::fromLatin1(INTERFACE));
    if (!reply.isValid()) {
        setAvailable(false);
        setOrientation(Orientation::Undefined);
        return;
    }

    const QVariantMap propertiesMap = reply.value();
    setAvailable(propertiesMap.value(QStringLiteral("HasAccelerometer")).toBool());
    setOrientation(mapOrientation(propertiesMap.value(QStringLiteral("AccelerometerOrientation")).toString()));
}

void SensorProxy::propertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidatedProperties)
{
    if (interface != QLatin1String(INTERFACE)) {
        return;
    }

    if (changedProperties.contains(QStringLiteral("HasAccelerometer"))) {
        setAvailable(changedProperties.value(QStringLiteral("HasAccelerometer")).toBool());
    }

    if (changedProperties.contains(QStringLiteral("AccelerometerOrientation"))) {
        setOrientation(mapOrientation(changedProperties.value(QStringLiteral("AccelerometerOrientation")).toString()));
    }

    if (invalidatedProperties.contains(QStringLiteral("HasAccelerometer")) || invalidatedProperties.contains(QStringLiteral("AccelerometerOrientation"))) {
        refreshProperties();
    }
}

void SensorProxy::setAvailable(bool available)
{
    if (m_available == available) {
        return;
    }

    m_available = available;
    Q_EMIT availableChanged();
}

void SensorProxy::setOrientation(Orientation orientation)
{
    if (m_orientation == orientation) {
        return;
    }

    m_orientation = orientation;
    Q_EMIT orientationChanged();
}
