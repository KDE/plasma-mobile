/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <Plasma/Containment>
#include <QOrientationSensor>

#include <kscreen/config.h>

class FakeInput;

class TaskPanel : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(bool showRotationButton READ showRotationButton NOTIFY showRotationButtonChanged)

public:
    TaskPanel(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    virtual ~TaskPanel();

    Q_INVOKABLE void triggerTaskSwitcher() const;

    bool showRotationButton() const;
    Q_INVOKABLE void rotateToSuggestedRotation();
    Q_INVOKABLE void sendBackButtonEvent();

Q_SIGNALS:
    void showRotationButtonChanged();

private Q_SLOTS:
    void updateShowRotationButton();

private:
    void initWayland();

    bool m_showRotationButton{false};
    KScreen::Output::Rotation m_rotateTo;

    std::unique_ptr<FakeInput> m_fakeInput;
    bool m_waylandFakeInputAuthRequested;

    KScreen::ConfigPtr m_config{nullptr};
    QOrientationSensor *m_sensor{nullptr};
};
