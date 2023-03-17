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
    void availabilityChanged();

    bool m_loaded = false;
    QList<QuickSetting *> m_quickSettings;
    SavedQuickSettings *m_savedQuickSettings;
};
