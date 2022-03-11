/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef QUICKSETTINGSMODEL_H
#define QUICKSETTINGSMODEL_H

#include "qqml.h"
#include "quicksetting.h"

#include <QAbstractListModel>
#include <QQmlListProperty>

class QuickSettingsModel : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QQmlListProperty<QuickSetting> children READ children NOTIFY childrenChanged)
    Q_CLASSINFO("DefaultProperty", "children")
    QML_ELEMENT

public:
    QuickSettingsModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const override;
    QHash<int, QByteArray> roleNames() const override;

    QQmlListProperty<QuickSetting> children();

    void classBegin() override;
    void componentComplete() override;
    Q_SCRIPTABLE void include(QuickSetting *item);

Q_SIGNALS:
    void childrenChanged();

private:
    QList<QuickSetting *> m_children;
    QList<QuickSetting *> m_external;
};

#endif // QUICKSETTINGSMODEL_H
