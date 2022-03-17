// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include "mobileshellsettings.h"
#include "qqml.h"
#include "quicksetting.h"

#include <KPluginMetaData>

#include <QAbstractListModel>
#include <QQmlListProperty>

#include "mobileshell_export.h"

namespace MobileShell
{

class MOBILESHELL_EXPORT SavedQuickSettingsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    SavedQuickSettingsModel(QObject *parent = nullptr);

    enum {
        NameRole,
        IdRole,
        IconRole,
    };

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void moveRow(int oldIndex, int newIndex);
    Q_INVOKABLE void insertRow(KPluginMetaData metaData, int index);
    Q_INVOKABLE void removeRow(int index);

    QList<KPluginMetaData> list() const;

public Q_SLOTS:
    void updateData(QList<KPluginMetaData> data);

Q_SIGNALS:
    void dataUpdated(QList<KPluginMetaData> data);

private:
    QList<KPluginMetaData> m_data;
};

} // namespace MobileShell
