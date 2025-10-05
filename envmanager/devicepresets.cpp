// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "devicepresets.h"

#include <QFile>
#include <QFileInfo>
#include <QList>
#include <utility>

using namespace Qt::Literals::StringLiterals;

const QString GENERAL_CONFIG_FILE = u"plasmamobilerc"_s;
const QString WRITE_TO_CONFIG_FILE = u"plasma-mobile/plasmamobilerc"_s;
const QString DEVICE_CONFIG_GROUP = u"Device"_s;

DevicePresets::DevicePresets(QObject *parent)
    : QObject{parent}
    , m_mobileConfig{KSharedConfig::openConfig(WRITE_TO_CONFIG_FILE, KConfig::SimpleConfig)}
{
}

void setKey(KConfigGroup &fallbackGroup, KConfigGroup &fromGroup, KConfigGroup &toGroup, QString fromKey, QString toKey)
{
    if (fromGroup.hasKey(fromKey)) {
        toGroup.writeEntry(toKey, fromGroup.readEntry(fromKey), KConfigGroup::Notify);
    } else if (fallbackGroup.hasKey(fromKey)) {
        toGroup.writeEntry(toKey, fallbackGroup.readEntry(fromKey), KConfigGroup::Notify);
    } else {
        toGroup.deleteEntry(toKey, KConfigGroup::Notify);
    }
}

void DevicePresets::initialize()
{
    // Open mobile config to read from all locations (/etc/xdg/plasmamobilerc, ~/.config/plasmamobilerc, etc.)
    auto mobileConfig = KSharedConfig::openConfig(GENERAL_CONFIG_FILE);
    auto deviceGroup = KConfigGroup{mobileConfig, DEVICE_CONFIG_GROUP};

    // Read device id
    const QString device = deviceGroup.readEntry(u"device"_s, {});

    QString presetFile = QStandardPaths::locate(QStandardPaths::GenericDataLocation, u"plasma-mobile-device-presets/"_s + device + ".conf");
    if (!QFile{presetFile}.exists()) {
        presetFile = QStandardPaths::locate(QStandardPaths::GenericDataLocation, u"plasma-mobile-device-presets/default.conf"_s);
        if (!QFile{presetFile}.exists()) {
            qWarning() << "Failed to find any device preset file";
            return;
        }
    }

    // Open preset file /usr/share/plasma-mobile-device-presets/device.conf
    auto presetConfig = KSharedConfig::openConfig(QFileInfo{presetFile}.absoluteFilePath(), KConfig::SimpleConfig);
    if (!presetConfig) {
        return;
    }

    // Write presets to ~/.config/plasma-mobile/plasmamobilerc
    // This is then read by components/mobileshellstate (PanelSettingsDBusObjectManager)
    auto presetPanelsGroup = KConfigGroup{presetConfig, u"Panels"_s};
    auto mobilePanelsGroup = KConfigGroup{m_mobileConfig, u"Panels"_s};

    // <Preset file group name, plasmamobilerc group name>
    QList<std::pair<QString, QString>> groupPairs = {{u"Top"_s, u"WhenOnTop"_s},
                                                     {u"Bottom"_s, u"WhenOnBottom"_s},
                                                     {u"Left"_s, u"WhenOnLeft"_s},
                                                     {u"Right"_s, u"WhenOnRight"_s}};

    // Convert preset file settings into plasmamobilerc ones
    for (const auto &p : groupPairs) {
        auto presetGroup = KConfigGroup{&presetPanelsGroup, p.first};
        auto writeGroup = KConfigGroup{&mobilePanelsGroup, p.second};

        // Try to read the value from presetGroup first (ex. [Panels][Top] statusBarHeight=...)
        // If it doesn't exist, then fallback to parent group (ex. [Panels] statusBarHeight=...)
        setKey(presetPanelsGroup, presetGroup, writeGroup, u"statusBarHeight"_s, u"statusBarHeight"_s);
        setKey(presetPanelsGroup, presetGroup, writeGroup, u"navigationPanelHeight"_s, u"navigationPanelHeight"_s);
        setKey(presetPanelsGroup, presetGroup, writeGroup, u"leftPadding"_s, u"statusBarLeftPadding"_s);
        setKey(presetPanelsGroup, presetGroup, writeGroup, u"leftPadding"_s, u"navigationPanelLeftPadding"_s);
        setKey(presetPanelsGroup, presetGroup, writeGroup, u"rightPadding"_s, u"statusBarRightPadding"_s);
        setKey(presetPanelsGroup, presetGroup, writeGroup, u"rightPadding"_s, u"navigationPanelRightPadding"_s);
        setKey(presetPanelsGroup, presetGroup, writeGroup, u"centerSpacing"_s, u"statusBarCenterSpacing"_s);

        writeGroup.sync();
    }

    m_mobileConfig->sync();
}
