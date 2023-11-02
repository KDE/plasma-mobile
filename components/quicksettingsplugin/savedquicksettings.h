// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include "qqml.h"
#include "quicksetting.h"
#include "quicksettingsconfig.h"
#include "savedquicksettingsmodel.h"

#include <KPackage/Package>
#include <KPluginMetaData>

#include <QAbstractListModel>
#include <QQmlListProperty>
#include <QTimer>

/**
 * @short A model that reads quick settings configurations
 * from the config and presents models to display them.
 *
 * @author Devin Lin <devin@kde.org>
 **/
class SavedQuickSettings : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(SavedQuickSettingsModel *enabledModel READ enabledQuickSettingsModel CONSTANT)
    Q_PROPERTY(SavedQuickSettingsModel *disabledModel READ disabledQuickSettingsModel CONSTANT)

public:
    SavedQuickSettings(QObject *parent = nullptr);
    ~SavedQuickSettings();

    SavedQuickSettingsModel *enabledQuickSettingsModel() const;
    SavedQuickSettingsModel *disabledQuickSettingsModel() const;

    Q_INVOKABLE void enableQS(int index);
    Q_INVOKABLE void disableQS(int index);

private:
    void refreshModel();
    void saveModel();

    QuickSettingsConfig *m_settings;
    QList<KPluginMetaData> m_validPackages;
    QList<KPluginMetaData> m_enabledPackages;
    QList<KPluginMetaData> m_disabledPackages;

    SavedQuickSettingsModel *m_enabledQSModel;
    SavedQuickSettingsModel *m_disabledQSModel;

    QTimer *m_updateTimer;
    QTimer *m_saveTimer;
};
