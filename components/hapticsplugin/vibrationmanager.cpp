// SPDX-FileCopyrightText: 2023-2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "vibrationmanager.h"

#include <KConfigGroup>
#include <KSharedConfig>

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QDBusVariant>
#include <QPointer>

#include <algorithm>

using namespace Qt::Literals::StringLiterals;

const QString FEEDBACKD_SERVICE = u"org.sigxcpu.Feedback"_s;
const QString FEEDBACKD_PATH = u"/org/sigxcpu/Feedback"_s;
const QString FEEDBACKD_INTERFACE = u"org.sigxcpu.Feedback"_s;

VibrationManager::VibrationManager(QObject *parent)
    : QObject{parent}
{
    qDBusRegisterMetaType<VibrationEvent>();
    qDBusRegisterMetaType<VibrationEventList>();

    loadDeviceTuning();
}

void VibrationManager::loadDeviceTuning()
{
    // Written by envmanager from the device preset into ~/.config/plasma-mobile/plasmamobilerc
    auto config = KSharedConfig::openConfig(QStringLiteral("plasmamobilerc"));
    const KConfigGroup group{config, QStringLiteral("Haptics")};

    m_amplitude = std::clamp(group.readEntry("amplitude", 1.0), 0.0, 1.0);
}

QString VibrationManager::profile()
{
    connectToFeedbackd();
    return m_profile;
}

void VibrationManager::connectToFeedbackd()
{
    if (m_connectedToFeedbackd) {
        return;
    }
    m_connectedToFeedbackd = true;

    auto bus = QDBusConnection::sessionBus();
    m_propertiesInterface = new OrgFreedesktopDBusPropertiesInterface(FEEDBACKD_SERVICE, FEEDBACKD_PATH, bus, this);
    connect(m_propertiesInterface, &OrgFreedesktopDBusPropertiesInterface::PropertiesChanged, this, &VibrationManager::onFeedbackPropertiesChanged);

    auto *watcher = new QDBusServiceWatcher(FEEDBACKD_SERVICE, bus, QDBusServiceWatcher::WatchForRegistration, this);
    connect(watcher, &QDBusServiceWatcher::serviceRegistered, this, [this]() {
        fetchProfile();
    });

    fetchProfile();
}

QCoro::Task<void> VibrationManager::fetchProfile()
{
    QPointer<VibrationManager> guard(this);
    const QDBusPendingReply<QDBusVariant> reply = co_await m_propertiesInterface->Get(FEEDBACKD_INTERFACE, u"Profile"_s);

    if (!guard) {
        co_return;
    }

    m_profileFetched = true;
    if (reply.isValid()) {
        setProfile(reply.value().variant().toString());
    } else {
        qWarning() << "Failed to fetch feedbackd profile:" << reply.error().message();
    }
}

void VibrationManager::onFeedbackPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated)
{
    Q_UNUSED(invalidated)
    if (interface != FEEDBACKD_INTERFACE) {
        return;
    }

    const auto it = changed.constFind(u"Profile"_s);
    if (it != changed.constEnd()) {
        setProfile(it->toString());
    }
}

void VibrationManager::setProfile(const QString &profile)
{
    if (m_profile == profile) {
        return;
    }
    m_profile = profile;
    Q_EMIT profileChanged();
}

QCoro::Task<void> VibrationManager::vibrateTask(int durationMs)
{
    QPointer<VibrationManager> guard(this);

    // Only create interface when needed.
    if (!m_interface) {
        m_interface = new OrgSigxcpuFeedbackHapticInterface(FEEDBACKD_SERVICE, FEEDBACKD_PATH, QDBusConnection::sessionBus(), this);
    }

    // On first use, wait for the profile so that we don't vibrate when the device is silenced
    if (!m_connectedToFeedbackd) {
        connectToFeedbackd();
    }
    if (!m_profileFetched) {
        co_await fetchProfile();
        if (!guard) {
            co_return;
        }
    }

    // Respect the feedbackd profile (ex. set by the alert slider)
    if (m_profile == u"silent"_s) {
        co_return;
    }

    const QString appId = QStringLiteral("org.kde.plasmashell");
    const VibrationEvent event{m_amplitude, static_cast<quint32>(std::max(1, durationMs))};
    const VibrationEventList pattern = {event};

    QDBusPendingReply<bool> reply = co_await m_interface->Vibrate(appId, pattern);

    if (!guard) {
        co_return;
    }

    if (!reply.isValid() || !reply.value()) {
        qWarning() << "feedbackd vibration failed";
    }
}

QCoro::QmlTask VibrationManager::vibrate(int durationMs)
{
    return vibrateTask(durationMs);
}
