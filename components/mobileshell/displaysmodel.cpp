/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "displaysmodel.h"

#include <QGuiApplication>

DisplaysModel::DisplaysModel(QObject *parent)
    : QAbstractListModel(parent)
{
    if (!QGuiApplication::platformName().startsWith(QLatin1String("wayland"), Qt::CaseInsensitive)) {
        return;
    }

    using namespace KWayland::Client;
    ConnectionThread *connection = ConnectionThread::fromApplication(this);

    if (!connection) {
        return;
    }

    auto *registry = new Registry(this);
    registry->create(connection);

    connect(registry, &Registry::outputAnnounced, this, [this, registry](quint32 name, quint32 version) {
        createOutput(registry->bindOutput(name, version));
    });
    connect(registry, &Registry::plasmaWindowManagementAnnounced, this, [this, registry](quint32 name, quint32 version) {
        m_windowManagement = registry->createPlasmaWindowManagement(name, version, this);
    });

    registry->setup();
    connection->roundtrip();
}

QHash<int, QByteArray> DisplaysModel::roleNames() const
{
    return {
        {Model, "modelName"},
        {Geometry, "geometry"},
        {Position, "position"},
        {Output, "output"},
    };
}

void DisplaysModel::createOutput(wl_output *output)
{
    auto newOutput = new KWayland::Client::Output(this);
    connect(newOutput, &KWayland::Client::Output::removed, this, [this, newOutput] {
        auto i = m_outputs.indexOf(newOutput);
        Q_ASSERT(i >= 0);
        beginRemoveRows({}, i, i);
        m_outputs.removeAt(i);
        endRemoveRows();
    });
    newOutput->setup(output);
    beginInsertRows({}, m_outputs.count(), m_outputs.count());
    m_outputs.append(newOutput);
    endInsertRows();
}

void DisplaysModel::sendWindowToOutput(const QString &uuid, KWayland::Client::Output *output)
{
    const auto windows = m_windowManagement->windows();
    for (auto w : windows) {
        if (w->uuid() == uuid) {
            w->sendToOutput(output);
        }
    }
}

int DisplaysModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_outputs.count();
}

QVariant DisplaysModel::data(const QModelIndex &index, int role) const
{
    if (index.row() >= m_outputs.count()) {
        return {};
    }

    auto o = m_outputs[index.row()];
    switch (role) {
    case Model:
        return o->model();
    case Geometry:
        return o->geometry();
    case Position:
        return o->globalPosition();
    case Output:
        return QVariant::fromValue<QObject *>(o);
    }
    return {};
}
