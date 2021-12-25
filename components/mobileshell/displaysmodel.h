/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QAbstractListModel>
#include <QRect>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/output.h>
#include <KWayland/Client/plasmashell.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

class DisplaysModel : public QAbstractListModel
{
public:
    enum Roles {
        Model = Qt::DisplayRole,
        Geometry = Qt::UserRole,
        Position,
        Output,
    };

    DisplaysModel(QObject *parent = nullptr);

    void createOutput(wl_output *output);

    Q_INVOKABLE void sendWindowToOutput(const QString &uuid, KWayland::Client::Output *output);

    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

private:
    KWayland::Client::PlasmaWindowManagement *m_windowManagement = nullptr;

    QVector<KWayland::Client::Output *> m_outputs;
};
