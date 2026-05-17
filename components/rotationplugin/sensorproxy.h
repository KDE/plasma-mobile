// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

class QDBusServiceWatcher;

class SensorProxy : public QObject
{
    Q_OBJECT

public:
    enum class Orientation {
        Undefined,
        TopUp,
        TopDown,
        LeftUp,
        RightUp,
    };
    Q_ENUM(Orientation)

    explicit SensorProxy(QObject *parent = nullptr);
    ~SensorProxy() override;

    bool available() const;
    Orientation orientation() const;

    void claimAccelerometer();
    void releaseAccelerometer();

Q_SIGNALS:
    void availableChanged();
    void orientationChanged();

private Q_SLOTS:
    void refreshProperties();
    void propertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidatedProperties);

private:
    void setAvailable(bool available);
    void setOrientation(Orientation orientation);

    bool m_available{false};
    bool m_claimed{false};
    Orientation m_orientation{Orientation::Undefined};
    QDBusServiceWatcher *m_serviceWatcher{nullptr};
};
