// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "prepareutil.h"

#include <kscreen/configmonitor.h>
#include <kscreen/getconfigoperation.h>
#include <kscreen/output.h>
#include <kscreen/setconfigoperation.h>

#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>

PrepareUtil::PrepareUtil(QObject *parent)
    : QObject{parent}
    , m_colorsSettings{new ColorsSettings(this)}
{
    m_brightnessInterface =
        new org::kde::Solid::PowerManagement::Actions::BrightnessControl(QStringLiteral("org.kde.Solid.PowerManagement"),
                                                                         QStringLiteral("/org/kde/Solid/PowerManagement/Actions/BrightnessControl"),
                                                                         QDBusConnection::sessionBus(),
                                                                         this);

    fetchBrightness();
    fetchMaxBrightness();

    connect(m_brightnessInterface, &org::kde::Solid::PowerManagement::Actions::BrightnessControl::brightnessChanged, this, &PrepareUtil::fetchBrightness);
    connect(m_brightnessInterface, &org::kde::Solid::PowerManagement::Actions::BrightnessControl::brightnessMaxChanged, this, &PrepareUtil::fetchMaxBrightness);

    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this](auto *op) {
        m_config = qobject_cast<KScreen::GetConfigOperation *>(op)->config();

        int scaling = 100;

        // to determine the scaling value:
        // try to take the primary display's scaling, otherwise use the scaling of any of the displays
        for (KScreen::OutputPtr output : m_config->outputs()) {
            scaling = output->scale() * 100;
            if (output->isPrimary()) {
                break;
            }
        }

        m_scaling = scaling;
        Q_EMIT scalingChanged();
    });

    // watch for brightness interface
    m_brightnessInterfaceWatcher = new QDBusServiceWatcher(QStringLiteral("org.kde.Solid.PowerManagement.Actions.BrightnessControl"),
                                                           QDBusConnection::sessionBus(),
                                                           QDBusServiceWatcher::WatchForOwnerChange,
                                                           this);

    connect(m_brightnessInterfaceWatcher, &QDBusServiceWatcher::serviceRegistered, this, [this]() -> void {
        Q_EMIT brightnessAvailableChanged();
    });

    connect(m_brightnessInterfaceWatcher, &QDBusServiceWatcher::serviceUnregistered, this, [this]() -> void {
        Q_EMIT brightnessAvailableChanged();
    });

    // set property initially
    m_usingDarkTheme = m_colorsSettings->colorScheme() == "BreezeDark";
}

int PrepareUtil::scaling() const
{
    return m_scaling;
}

void PrepareUtil::setScaling(int scaling)
{
    if (!m_config) {
        return;
    }

    const auto outputs = m_config->outputs();
    qreal scalingNum = ((double)scaling) / 100;

    for (KScreen::OutputPtr output : outputs) {
        output->setScale(scalingNum);
    }

    auto setop = new KScreen::SetConfigOperation(m_config, this);
    setop->exec();

    m_scaling = scaling;
    Q_EMIT scalingChanged();
}

QStringList PrepareUtil::scalingOptions()
{
    return {"50%", "75%", "100%", "125%", "150%", "175%", "200%", "225%", "250%", "275%", "300%"};
}

int PrepareUtil::brightness() const
{
    return m_brightness;
}

void PrepareUtil::setBrightness(int brightness)
{
    m_brightnessInterface->setBrightness(brightness);
}

int PrepareUtil::maxBrightness() const
{
    return m_maxBrightness;
}

bool PrepareUtil::brightnessAvailable() const
{
    return m_brightnessInterface->isValid();
}

bool PrepareUtil::usingDarkTheme() const
{
    return m_usingDarkTheme;
}

void PrepareUtil::setUsingDarkTheme(bool usingDarkTheme)
{
    // use plasma-apply-colorscheme since it has logic for notifying the shell of changes
    if (usingDarkTheme) {
        QProcess::execute("plasma-apply-colorscheme", {QStringLiteral("BreezeDark")});
    } else {
        QProcess::execute("plasma-apply-colorscheme", {QStringLiteral("BreezeLight")});
    }

    m_usingDarkTheme = usingDarkTheme;
    Q_EMIT usingDarkThemeChanged();
}

void PrepareUtil::fetchBrightness()
{
    QDBusPendingReply<int> reply = m_brightnessInterface->brightness();
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](QDBusPendingCallWatcher *watcher) {
        QDBusPendingReply<int> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Getting brightness failed:" << reply.error().name() << reply.error().message();
        } else if (m_brightness != reply.value()) {
            m_brightness = reply.value();
            Q_EMIT brightnessChanged();
        }
        watcher->deleteLater();
    });
}

void PrepareUtil::fetchMaxBrightness()
{
    QDBusPendingReply<int> reply = m_brightnessInterface->brightnessMax();
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](QDBusPendingCallWatcher *watcher) {
        QDBusPendingReply<int> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Getting max brightness failed:" << reply.error().name() << reply.error().message();
        } else if (m_maxBrightness != reply.value()) {
            m_maxBrightness = reply.value();
            Q_EMIT maxBrightnessChanged();
        }
        watcher->deleteLater();
    });
}
