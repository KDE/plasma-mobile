/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <libudev.h>

#include <qqmlregistration.h>

class FlashlightUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool torchEnabled READ torchEnabled NOTIFY torchChanged);
    Q_PROPERTY(bool available READ isAvailable CONSTANT);

public:
    FlashlightUtil(QObject *parent = nullptr);
    ~FlashlightUtil();

    Q_INVOKABLE void toggleTorch();
    bool torchEnabled() const;
    bool isAvailable() const;

Q_SIGNALS:
    void torchChanged(bool value);

private:
    struct udev_device *m_device{nullptr};
    const char *m_maxBrightness{nullptr};
    bool m_isAvailable{false};
    bool m_torchEnabled{false};

    void findTorchDevice();
};
