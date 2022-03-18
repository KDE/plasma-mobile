// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include "qqml.h"

#include <QAbstractListModel>
#include <QQmlListProperty>

#include <KPackage/Package>
#include <KPackage/PackageLoader>

#include "mobileshell_export.h"

namespace MobileShell
{

class MOBILESHELL_EXPORT HomeScreenModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString selectedHomeScreen READ selectedHomeScreen WRITE setSelectedHomeScreen NOTIFY selectedHomeScreenChanged)

public:
    HomeScreenModel(QObject *parent = nullptr);

    enum {
        IdRole,
        NameRole,
        DescriptionRole,
    };

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString selectedHomeScreen() const;
    void setSelectedHomeScreen(QString pluginId);

Q_SIGNALS:
    void selectedHomeScreenChanged();

private:
    QList<KPackage::Package> m_packages;
    QString m_selectedHomeScreen;
};

} // namespace MobileShell
