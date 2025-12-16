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

void DevicePresets::initialize()
{
    // Open mobile config to read from all locations (/etc/xdg/plasmamobilerc, ~/.config/plasmamobilerc, etc.)
    auto mobileConfig = KSharedConfig::openConfig(GENERAL_CONFIG_FILE);
    auto deviceGroup = KConfigGroup{mobileConfig, DEVICE_CONFIG_GROUP};

    // Read device id
    const QString device = deviceGroup.readEntry(u"device"_s, {});

    QString presetFile = QStandardPaths::locate(QStandardPaths::GenericDataLocation, u"plasma-mobile-device-presets/default.conf"_s);

    // Loop over detected devices and see if file exists
    QString candidatePresetFile;
    for (const QString &detectedDevice : detectDeviceString()) {
        candidatePresetFile = QStandardPaths::locate(QStandardPaths::GenericDataLocation, u"plasma-mobile-device-presets/"_s + detectedDevice + ".conf");
        if (!candidatePresetFile.isEmpty()) {
            presetFile = candidatePresetFile;
            break;
        }
    }

    // Config-specified device has highest priority
    candidatePresetFile = QStandardPaths::locate(QStandardPaths::GenericDataLocation, u"plasma-mobile-device-presets/"_s + device + ".conf");
    if (!candidatePresetFile.isEmpty()) {
        presetFile = candidatePresetFile;
    } else if (!device.isEmpty()) {
        qWarning() << "Failed to find device preset file for" << device << "as defined in config";
    }

    if (QFile{presetFile}.exists()) {
        qDebug() << "Using device preset file at" << presetFile;
    } else {
        qDebug() << "No device preset file could be found.";
        return;
    }

    // Open preset file /usr/share/plasma-mobile-device-presets/[device].conf
    auto presetConfig = KSharedConfig::openConfig(QFileInfo{presetFile}.absoluteFilePath(), KConfig::SimpleConfig);

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

void DevicePresets::setKey(KConfigGroup &fallbackGroup, KConfigGroup &fromGroup, KConfigGroup &toGroup, const QString &fromKey, const QString &toKey)
{
    if (fromGroup.hasKey(fromKey)) {
        toGroup.writeEntry(toKey, fromGroup.readEntry(fromKey), KConfigGroup::Notify);
    } else if (fallbackGroup.hasKey(fromKey)) {
        toGroup.writeEntry(toKey, fallbackGroup.readEntry(fromKey), KConfigGroup::Notify);
    } else {
        toGroup.deleteEntry(toKey, KConfigGroup::Notify);
    }
}

QStringList DevicePresets::detectDeviceString()
{
    // On some systems, this file contains an identifier for the device
    QFile deviceinfoFile{u"/sys/firmware/devicetree/base/compatible"_s};
    if (!deviceinfoFile.exists()) {
        return {};
    }

    if (!deviceinfoFile.open(QIODevice::ReadOnly)) {
        return {};
    }

    QByteArray data = deviceinfoFile.readAll();
    deviceinfoFile.close();

    // Split by null bytes and convert to QStringList
    QStringList result;
    const QList<QByteArray> parts = data.split('\0');
    for (const QByteArray &part : parts) {
        if (!part.isEmpty()) {
            result.append(QString::fromUtf8(part));
        }
    }

    return result;
}
