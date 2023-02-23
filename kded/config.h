// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <utility>

#include <QMap>
#include <QString>
#include <QVariant>

// kwinrc
const QMap<QString, QMap<QString, QVariant>> KWINRC_SETTINGS = {
    {"Plugins", {{"blurEnabled", false}}},
    {"Wayland", {{"InputMethod", "/usr/share/applications/com.github.maliit.keyboard.desktop"}, {"VirtualKeyboardEnabled", true}}},
    {"Windows",
     {
         {"Placement", "Maximizing"},
     }},
    {"org.kde.kdecoration2", {{"NoPlugin", true}}},
};

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
