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

#include <QAbstractListModel>
#include <QQmlListProperty>

#include "mobileshell_export.h"

namespace MobileShell
{

class MOBILESHELL_EXPORT QuickSettingsModel : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    QML_ELEMENT

public:
    QuickSettingsModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const override;
    QHash<int, QByteArray> roleNames() const override;

    void classBegin() override;
    void componentComplete() override;
private:
    void loadQuickSettings();

    bool m_loaded = false;
    QList<QuickSetting *> m_quickSettings;
    SavedQuickSettings *m_savedQuickSettings;
};

} // namespace MobileShell
