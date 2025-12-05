// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "panelsettingsdbusobjectmanager.h"
#include "panelsadaptor.h"

#include <kscreen/configmonitor.h>
#include <kscreen/getconfigoperation.h>
#include <kscreen/output.h>

using namespace Qt::Literals::StringLiterals;

const QString CONFIG_FILE = u"plasmamobilerc"_s;
const QString PANELS_CONFIG_GROUP = u"Panels"_s;

// Orientations
const QString TOP_CONFIG_GROUP = u"WhenOnTop"_s;
const QString LEFT_CONFIG_GROUP = u"WhenOnLeft"_s;
const QString RIGHT_CONFIG_GROUP = u"WhenOnRight"_s;
const QString BOTTOM_CONFIG_GROUP = u"WhenOnBottom"_s;

QString mapRotationToTopPosition(KScreen::Output::Rotation rotation)
{
    switch (rotation) {
    case KScreen::Output::Rotation::Left:
        return RIGHT_CONFIG_GROUP;
    case KScreen::Output::Rotation::Inverted:
        return BOTTOM_CONFIG_GROUP;
    case KScreen::Output::Rotation::Right:
        return LEFT_CONFIG_GROUP;
    default:
        return TOP_CONFIG_GROUP;
    }
}

QString mapRotationToBottomPosition(KScreen::Output::Rotation rotation)
{
    switch (rotation) {
    case KScreen::Output::Rotation::Left:
        return LEFT_CONFIG_GROUP;
    case KScreen::Output::Rotation::Inverted:
        return TOP_CONFIG_GROUP;
    case KScreen::Output::Rotation::Right:
        return RIGHT_CONFIG_GROUP;
    default:
        return BOTTOM_CONFIG_GROUP;
    }
}

PanelSettingsDBusObjectManager::PanelSettingsDBusObjectManager(QObject *parent)
    : QObject{parent}
{
}

void PanelSettingsDBusObjectManager::registerObjects()
{
    if (m_initialized) {
        return;
    }

    // Fetch kscreen config
    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this](auto *op) {
        m_kscreenConfig = qobject_cast<KScreen::GetConfigOperation *>(op)->config();
        if (!m_kscreenConfig) {
            qDebug() << "PanelSettingsDBusObjectManager: Failed to get kscreen config, attempting again";
            registerObjects();
            return;
        }

        m_initialized = true;

        KScreen::ConfigMonitor::instance()->addConfig(m_kscreenConfig);

        // Listen to all new screens and create a new output
        connect(m_kscreenConfig.data(), &KScreen::Config::outputAdded, this, [this](const auto &output) {
            if (!output) {
                return;
            }

            auto *obj = new PanelSettingsDBusObject{this};
            obj->registerObject(output);
            m_dbusObjects.push_back(obj);
        });

        // Remove the corresponding object when a screen is removed
        connect(m_kscreenConfig.data(), &KScreen::Config::outputRemoved, this, [this](const auto outputId) {
            for (int i = 0; i < m_dbusObjects.size(); ++i) {
                if (m_dbusObjects[i]->outputId() == outputId) {
                    m_dbusObjects[i]->deleteLater();
                    m_dbusObjects.remove(i);
                    break;
                }
            }
        });

        // Add all current screens as dbus objects
        for (KScreen::OutputPtr output : m_kscreenConfig->outputs()) {
            if (!output) {
                continue;
            }

            auto *obj = new PanelSettingsDBusObject{this};
            obj->registerObject(output);
            m_dbusObjects.push_back(obj);
        }
    });
}

PanelSettingsDBusObject::PanelSettingsDBusObject(QObject *parent)
    : QObject{parent}
    , m_config{KSharedConfig::openConfig(CONFIG_FILE)}
{
    // Listen to config changes and reload
    m_configWatcher = KConfigWatcher::create(m_config);
    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) -> void {
        Q_UNUSED(names)
        Q_UNUSED(group)
        updateFields();
    });
}

void PanelSettingsDBusObject::registerObject(KScreen::OutputPtr output)
{
    m_output = output;

    if (!m_output) {
        return;
    }
    m_outputId = m_output->id();
    m_outputName = m_output->name();

    // Listen to when the rotation or scale changes to refresh the fields
    connect(m_output.data(), &KScreen::Output::rotationChanged, this, &PanelSettingsDBusObject::updateFields);
    connect(m_output.data(), &KScreen::Output::scaleChanged, this, &PanelSettingsDBusObject::updateFields);
    updateFields();

    new PlasmashellMobilePanelsAdaptor{this};

    // Register the screen DBus object
    QString objectName = m_output->name().replace("-", ""); // DBus doesn't allow dashes
    QDBusConnection::sessionBus().registerObject(QStringLiteral("/Mobile/Panels/") + objectName, this);
}

void PanelSettingsDBusObject::updateFields()
{
    if (!m_output) {
        return;
    }

    auto group = KConfigGroup{m_config, PANELS_CONFIG_GROUP};
    auto topGroup = KConfigGroup{&group, mapRotationToTopPosition(m_output->rotation())};
    auto bottomGroup = KConfigGroup{&group, mapRotationToBottomPosition(m_output->rotation())};

    // Divide values by the display's scale for scaling independent sizing
    setStatusBarHeight(topGroup.readEntry(u"statusBarHeight"_s, -1.0) / m_output->scale());
    setStatusBarLeftPadding(topGroup.readEntry(u"statusBarLeftPadding"_s, 0.0) / m_output->scale());
    setStatusBarRightPadding(topGroup.readEntry(u"statusBarRightPadding"_s, 0.0) / m_output->scale());
    setStatusBarCenterSpacing(topGroup.readEntry(u"statusBarCenterSpacing"_s, 0.0) / m_output->scale());
    setNavigationPanelHeight(bottomGroup.readEntry(u"navigationPanelHeight"_s, -1.0) / m_output->scale());
    setNavigationPanelLeftPadding(bottomGroup.readEntry(u"navigationPanelLeftPadding"_s, 0.0) / m_output->scale());
    setNavigationPanelRightPadding(bottomGroup.readEntry(u"navigationPanelRightPadding"_s, 0.0) / m_output->scale());
}

int PanelSettingsDBusObject::outputId() const
{
    return m_outputId;
}

QString PanelSettingsDBusObject::outputName() const
{
    return m_outputName;
}

qreal PanelSettingsDBusObject::statusBarHeight() const
{
    return m_statusBarHeight;
}

void PanelSettingsDBusObject::setStatusBarHeight(qreal statusBarHeight)
{
    if (statusBarHeight == m_statusBarHeight) {
        return;
    }
    m_statusBarHeight = statusBarHeight;
    Q_EMIT statusBarHeightChanged();
}

qreal PanelSettingsDBusObject::statusBarLeftPadding() const
{
    return m_statusBarLeftPadding;
}

void PanelSettingsDBusObject::setStatusBarLeftPadding(qreal statusBarLeftPadding)
{
    if (statusBarLeftPadding == m_statusBarLeftPadding) {
        return;
    }
    m_statusBarLeftPadding = statusBarLeftPadding;
    Q_EMIT statusBarLeftPaddingChanged();
}

qreal PanelSettingsDBusObject::statusBarRightPadding() const
{
    return m_statusBarRightPadding;
}

void PanelSettingsDBusObject::setStatusBarRightPadding(qreal statusBarRightPadding)
{
    if (statusBarRightPadding == m_statusBarRightPadding) {
        return;
    }
    m_statusBarRightPadding = statusBarRightPadding;
    Q_EMIT statusBarRightPaddingChanged();
}

qreal PanelSettingsDBusObject::statusBarCenterSpacing() const
{
    return m_statusBarCenterSpacing;
}

void PanelSettingsDBusObject::setStatusBarCenterSpacing(qreal statusBarCenterSpacing)
{
    if (statusBarCenterSpacing == m_statusBarCenterSpacing) {
        return;
    }
    m_statusBarCenterSpacing = statusBarCenterSpacing;
    Q_EMIT statusBarCenterSpacingChanged();
}

qreal PanelSettingsDBusObject::navigationPanelHeight() const
{
    return m_navigationPanelHeight;
}

void PanelSettingsDBusObject::setNavigationPanelHeight(qreal navigationPanelHeight)
{
    if (navigationPanelHeight == m_navigationPanelHeight) {
        return;
    }
    m_navigationPanelHeight = navigationPanelHeight;
    Q_EMIT navigationPanelHeightChanged();
}

qreal PanelSettingsDBusObject::navigationPanelLeftPadding() const
{
    return m_navigationPanelLeftPadding;
}

void PanelSettingsDBusObject::setNavigationPanelLeftPadding(qreal navigationPanelLeftPadding)
{
    if (navigationPanelLeftPadding == m_navigationPanelLeftPadding) {
        return;
    }
    m_navigationPanelLeftPadding = navigationPanelLeftPadding;
    Q_EMIT navigationPanelLeftPaddingChanged();
}

qreal PanelSettingsDBusObject::navigationPanelRightPadding() const
{
    return m_navigationPanelRightPadding;
}

void PanelSettingsDBusObject::setNavigationPanelRightPadding(qreal navigationPanelRightPadding)
{
    if (navigationPanelRightPadding == m_navigationPanelRightPadding) {
        return;
    }
    m_navigationPanelRightPadding = navigationPanelRightPadding;
    Q_EMIT navigationPanelRightPaddingChanged();
}
