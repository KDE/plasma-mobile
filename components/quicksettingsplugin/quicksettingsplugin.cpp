// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "quicksettingsplugin.h"
#include "paginatemodel.h"
#include "quicksetting.h"
#include "quicksettingsmodel.h"
#include "savedquicksettings.h"
#include "savedquicksettingsmodel.h"

#include <QQmlContext>
#include <QQuickItem>

void QuickSettingsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.private.mobileshell.quicksettingsplugin"));

    qmlRegisterType<QuickSetting>(uri, 1, 0, "QuickSetting");
    qmlRegisterType<QuickSettingsModel>(uri, 1, 0, "QuickSettingsModel");
    qmlRegisterType<PaginateModel>(uri, 1, 0, "PaginateModel");
    qmlRegisterType<SavedQuickSettings>(uri, 1, 0, "SavedQuickSettings");
    qmlRegisterType<SavedQuickSettingsModel>(uri, 1, 0, "SavedQuickSettingsModel");
}
