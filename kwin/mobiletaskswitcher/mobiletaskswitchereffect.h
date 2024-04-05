// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <effect/effecthandler.h>
#include <effect/quickeffect.h>
#include <effect/effect.h>
#include <effect/effecttogglablestate.h>

#include <span>

#include <QAction>
#include <QKeySequence>
#include <QTimer>

#include <KGlobalAccel>
#include <KLocalizedString>

namespace KWin
{

class MobileTaskSwitcherEffect : public QuickSceneEffect
{
    Q_OBJECT
    Q_PROPERTY(qreal partialActivationFactor READ partialActivationFactor NOTIFY partialActivationFactorChanged)
    Q_PROPERTY(bool gestureInProgress READ gestureInProgress NOTIFY gestureInProgressChanged)

public:
    enum class Status { Inactive, Activating, Deactivating, Active };
    MobileTaskSwitcherEffect();
    ~MobileTaskSwitcherEffect() override;

    int animationDuration() const;
    void setAnimationDuration(int duration);

    bool gestureInProgress() const;

    qreal partialActivationFactor() const;

    int requestedEffectChainPosition() const override;
    bool borderActivated(ElectricBorder border) override;
    void reconfigure(ReconfigureFlags flags) override;
    void grabbedKeyboardEvent(QKeyEvent *keyEvent) override;

    void setDBusState(bool active);

public Q_SLOTS:
    void activate();
    void realDeactivate();
    void deactivate(bool deactivateInstantly);
    void quickDeactivate();
    void toggle();

Q_SIGNALS:
    void animationDurationChanged();
    void gestureInProgressChanged();
    void partialActivationFactorChanged();

private:
    EffectTogglableState *const m_taskSwitcherState;
    EffectTogglableTouchBorder *const m_border;
    QList<int> m_borderActivate = {ElectricBorder::ElectricBottom};

    QAction *m_realtimeToggleAction = nullptr;
    QAction *m_toggleAction = nullptr;
    QList<QKeySequence> m_toggleShortcut;

    QTimer *m_shutdownTimer;

    int m_animationDuration = 400;
};

} // namespace KWin
