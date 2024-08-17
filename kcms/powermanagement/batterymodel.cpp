/*
 *   SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *   SPD
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "batterymodel.h"

#include <Solid/DeviceNotifier>

#include <QQmlEngine>

BatteryModel::BatteryModel(QObject *parent)
    : QAbstractListModel(parent)
{
    qmlRegisterUncreatableType<Solid::Battery>("org.kde.kinfocenter.energy.private", 1, 0, "Battery", QStringLiteral("Use Solid::Battery"));

    m_batteries = Solid::Device::listFromType(Solid::DeviceInterface::Battery);

    connect(Solid::DeviceNotifier::instance(), &Solid::DeviceNotifier::deviceAdded, this, [this](const QString &udi) {
        auto it = std::find_if(m_batteries.constBegin(), m_batteries.constEnd(), [&udi](const Solid::Device &dev) {
            return dev.udi() == udi;
        });
        if (it != m_batteries.constEnd()) {
            return;
        }

        const Solid::Device device(udi);
        if (device.isValid() && device.is<Solid::Battery>()) {
            beginInsertRows(QModelIndex(), m_batteries.count(), m_batteries.count());
            m_batteries.append(device);
            endInsertRows();

            Q_EMIT countChanged();
        }
    });
    connect(Solid::DeviceNotifier::instance(), &Solid::DeviceNotifier::deviceRemoved, this, [this](const QString &udi) {
        auto it = std::find_if(m_batteries.constBegin(), m_batteries.constEnd(), [&udi](const Solid::Device &dev) {
            return dev.udi() == udi;
        });
        if (it == m_batteries.constEnd()) {
            return;
        }

        int index = std::distance(m_batteries.constBegin(), it);

        beginRemoveRows(QModelIndex(), index, index);
        m_batteries.removeAt(index);
        endRemoveRows();

        Q_EMIT countChanged();
    });
}

QVariant BatteryModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_batteries.count()) {
        return QVariant();
    }

    if (role == BatteryRole) {
        // .as returns a pointer to a casted DeviceInterface. This pointer must
        // not, under any circumstances, be deleted outside Solid!
        // https://bugs.kde.org/show_bug.cgi?id=413003
        const auto battery = m_batteries.value(index.row()).as<Solid::Battery>();
        QQmlEngine::setObjectOwnership(battery, QQmlEngine::CppOwnership);
        return QVariant::fromValue(battery);
    } else if (role == ProductRole) {
        const Solid::Device device = m_batteries.value(index.row());
        return device.product();
    } else if (role == VendorRole) {
        const Solid::Device device = m_batteries.value(index.row());
        return device.vendor();
    } else if (role == UdiRole) {
        return m_batteries.at(index.row()).udi();
    }

    return QVariant();
}

int BatteryModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_batteries.count();
}

QHash<int, QByteArray> BatteryModel::roleNames() const
{
    return {{BatteryRole, "battery"}, {VendorRole, "vendor"}, {ProductRole, "product"}, {UdiRole, "udi"}};
}
