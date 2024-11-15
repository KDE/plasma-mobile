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
const QMap<QString, QMap<QString, QVariant>> APPLICATIONS_BLACKLIST_DEFAULT_SETTINGS = {
    {"Applications",
     {{"blacklist",
       "assistant,assistant-qt5,avahi-discover,bssh,bvnc,ciborium,cuttlefish,designer,designer-qt5,htop,ktelnetservice5,linguist,linguist-qt5,"
       "org.kde.kcharselect,org.kde.kfind,org.kde.klipper,org.kde.kmag,org.kde.kmenuedit,org.kde.kmousetool,org.kde.krfb,"
       "org.kde.kuserfeedback-console,org.kde.kwalletmanager5,org.kde.okular,org.kde.perusecreator,org.kde.plasma.themeexplorer,org.kde.plasma-welcome,"
       "nvtop,qt5-qdbusviewer,qv4l2,qvidcap,syncmonitorhelper,UserFeedbackConsole,waydroid.com.android.calculator2,waydroid.com.android.camera2,"
       "waydroid.com.android.contacts,waydroid.com.android.deskclock,waydroid.com.android.documentsui,waydroid.com.android.gallery3d,"
       "waydroid.com.android.inputmethod.latin,waydroid.com.android.settings,waydroid.org.lineageos.eleven,waydroid.org.lineageos.etar,"
       "waydroid.org.lineageos.jelly,waydroid.org.lineageos.recorder,wordview"}}}};

// kdeglobals
// NOTE: we only write these entries if they are not already defined in the config
const QMap<QString, QMap<QString, QVariant>> KDEGLOBALS_DEFAULT_SETTINGS = {{"General", {{"BrowserApplication", "angelfish"}}}};

const QMap<QString, QMap<QString, QVariant>> KDEGLOBALS_SETTINGS = {{"KDE", {{"LookAndFeelPackage", "org.kde.breeze.mobile"}}}};

// kwinrc
QMap<QString, QMap<QString, QVariant>> getKwinrcSettings(KSharedConfig::Ptr m_mobileConfig)
{
    auto group = KConfigGroup{m_mobileConfig, QStringLiteral("General")};
    bool convergenceModeEnabled = group.readEntry("convergenceModeEnabled", false);

    return {{"Windows",
             {
                 {"Placement", convergenceModeEnabled ? "Centered" : "Maximizing"} // maximize all windows by default if we aren't in convergence mode
             }},
            {"Plugins",
             {
                 {"blurEnabled", false}, // disable blur for performance reasons, we could reconsider in the future for more powerful devices
                 {"convergentwindowsEnabled", true}, // enable our convergent window plugin
                 {"mobiletaskswitcherEnabled", true} // ensure the mobile task switcher plugin is enabled
             }},
            {"Wayland",
             {
                 {"InputMethod", "/usr/share/applications/com.github.maliit.keyboard.desktop"}, // ensure maliit is our vkbd
                 {"VirtualKeyboardEnabled", true} // enable vkbd
             }},
            {"org.kde.kdecoration2",
             {
                 {"ButtonsOnRight", convergenceModeEnabled ? "HIAX" : "H"}, // ButtonsOnRight changes depending on whether the device is in convergence mode
                 {"NoPlugin", false} // ensure that the window decoration plugin is always enabled, otherwise we get Qt default window decorations
             }},
            {"Input",
             {
                 {"TabletMode", convergenceModeEnabled ? "off" : "auto"} // TabletMode changes depending on whether the device is in convergence mode
             }}};
}

// Have a separate list here because we need to trigger DBus calls to load/unload each effect/script.
// Make sure that the effect/script is added to the kwinrc "Plugins" section above!
const QList<QString> KWIN_EFFECTS = {"blur", "mobiletaskswitcher"};
const QList<QString> KWIN_SCRIPTS = {"convergentwindows"};
