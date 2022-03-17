// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include "mobileshellsettings.h"
#include "qqml.h"
#include "quicksetting.h"
#include "savedquicksettingsmodel.h"

#include <KPackage/Package>
#include <KPluginMetaData>

#include <QAbstractListModel>
#include <QQmlListProperty>

#include "mobileshell_export.h"

namespace MobileShell
{

class MOBILESHELL_EXPORT SavedQuickSettings : public QObject
{
    Q_OBJECT

public:
    SavedQuickSettings(QObject *parent = nullptr);

    SavedQuickSettingsModel *enabledQuickSettingsModel() const;
    SavedQuickSettingsModel *disabledQuickSettingsModel() const;

private:
    void refreshModel();
    void saveModel();

    MobileShellSettings *m_settings;
    QList<KPluginMetaData> m_validPackages;
    QList<KPluginMetaData> m_enabledPackages;
    QList<KPluginMetaData> m_disabledPackages;

    SavedQuickSettingsModel *m_enabledQSModel;
    SavedQuickSettingsModel *m_disabledQSModel;
};

} // namespace MobileShell
