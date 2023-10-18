// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <utility>

#include <QMap>
#include <QString>
#include <QVariant>

#include <KConfigGroup>
#include <KSharedConfig>

// applications-blacklistrc
// NOTE: we only write these entries if they are not already defined in the config
const QMap<QString, QMap<QString, QVariant>> APPLICATIONS_BLACKLIST_SETTINGS = {
    {"Applications",
     {{"blacklist",
       "cuttlefish,org.kde.plasma.themeexplorer,org.kde.klipper,ciborium,syncmonitorhelper,org.kde.okular,wordview,assistant,assistant-qt5,designer,designer-"
       "qt5,linguist,linguist-qt5,org.kde.perusecreator,UserFeedbackConsole,org.kde.kuserfeedback-console,avahi-discover,bssh,bvnc,ktelnetservice5,qv4l2,"
       "qvidcap"}}}};

// kdeglobals
// NOTE: we only write these entries if they are not already defined in the config
const QMap<QString, QMap<QString, QVariant>> KDEGLOBALS_SETTINGS = {{"General", {{"BrowserApplication", "angelfish"}}}};

// kwinrc
QMap<QString, QMap<QString, QVariant>> getKwinrcSettings(KSharedConfig::Ptr m_mobileConfig)
{
    auto group = KConfigGroup{m_mobileConfig, QStringLiteral("General")};
    bool convergenceModeEnabled = group.readEntry("convergenceModeEnabled", false);

    return {
        {"Plugins", {{"blurEnabled", false}, {"convergentwindowsEnabled", true}}},
        {"Windows", {{"Placement", convergenceModeEnabled ? "PlacementDefault" : "Maximizing"}}},
        {"Wayland", {{"InputMethod", "/usr/share/applications/com.github.maliit.keyboard.desktop"}, {"VirtualKeyboardEnabled", true}}},
        {"org.kde.kdecoration2",
         {{"NoPlugin", !convergenceModeEnabled},
          {"ButtonsOnRight", convergenceModeEnabled ? "HIAX" : "H"}}} // ButtonsOnRight changes depending on whether the device is in convergence mode
    };
}
