/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include "qqml.h"
#include "quicksetting.h"
#include "savedquicksettings.h"
#include "savedquicksettingsmodel.h"

#include <KPluginMetaData>
#include <QAbstractListModel>
#include <QQmlComponent>
#include <QQmlListProperty>
#include <qqmlregistration.h>

class QuickSettingsModel : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    QML_ELEMENT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    QuickSettingsModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;

    void classBegin() override;
    void componentComplete() override;

Q_SIGNALS:
    void countChanged();

private:
    void loadQuickSettings();
    void availabilityChanged(KPluginMetaData metaData, QuickSetting *quickSetting);

    void loadQuickSetting(KPluginMetaData metaData, bool emitInsertSignal);
    void removeQuickSetting(int index);

    void insertQuickSettingToModel(KPluginMetaData metaData, QuickSetting *quickSetting, bool emitInsertSignal);
    QuickSetting *loadQuickSettingComponent(KPluginMetaData metaData);

    bool m_loaded{false};

    // m_quickSettings and m_quickSettingsMetaData indices match to same quick setting
    QList<QuickSetting *> m_quickSettings;
    QList<KPluginMetaData> m_quickSettingsMetaData;

    SavedQuickSettings *m_savedQuickSettings{nullptr};
};
