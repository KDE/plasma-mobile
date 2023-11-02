// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include "qqml.h"
#include "quicksetting.h"

#include <KPluginMetaData>

#include <QAbstractListModel>
#include <QQmlListProperty>

/**
 * @short A list model for serving quick settings metadata.
 *
 * @author Devin Lin <devin@kde.org>
 **/
class SavedQuickSettingsModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    SavedQuickSettingsModel(QObject *parent = nullptr);

    enum {
        NameRole, /**< The name of the quick setting. */
        IdRole, /**< The plugin id of the quick setting package. */
        IconRole, /**< The icon of the quick setting. */
    };

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void moveRow(int oldIndex, int newIndex);
    Q_INVOKABLE void insertRow(KPluginMetaData metaData, int index);
    Q_INVOKABLE KPluginMetaData takeRow(int index);
    Q_INVOKABLE void removeRow(int index);

    QList<KPluginMetaData> list() const;

public Q_SLOTS:
    void updateData(QList<KPluginMetaData> data);

Q_SIGNALS:
    void dataUpdated(QList<KPluginMetaData> data);

private:
    QList<KPluginMetaData> m_data;
};
