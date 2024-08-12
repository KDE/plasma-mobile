// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@server23.cc>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "effecttouchborder.h"

namespace KWin
{

EffectTouchBorderState::EffectTouchBorderState(Effect *parent)
    : QObject(parent)
    , m_activateAction{std::make_unique<QAction>()}
{
    connect(m_activateAction.get(), &QAction::triggered, this, [this]() {
        if (m_inProgress) {
            setInProgress(false);
        }
    });
}

bool EffectTouchBorderState::inProgress() const
{
    return m_inProgress;
}

void EffectTouchBorderState::setInProgress(bool inProgress)
{
    if (!effects->hasActiveFullScreenEffect() || effects->activeFullScreenEffect() == parent()) {
        if (m_inProgress != inProgress) {
            m_inProgress = inProgress;
            Q_EMIT inProgressChanged();
        }
    }
}

EffectTouchBorder::EffectTouchBorder(EffectTouchBorderState *state)
    : QObject(state)
    , m_state(state)
{
}

EffectTouchBorder::~EffectTouchBorder()
{
    for (const ElectricBorder &border : std::as_const(m_touchBorderActivate)) {
        effects->unregisterTouchBorder(border, m_state->activateAction());
    }
}

void EffectTouchBorder::setBorders(const QList<int> &touchActivateBorders)
{
    for (const ElectricBorder &border : std::as_const(m_touchBorderActivate)) {
        effects->unregisterTouchBorder(border, m_state->activateAction());
    }
    m_touchBorderActivate.clear();

    for (const int &border : touchActivateBorders) {
        m_touchBorderActivate.append(ElectricBorder(border));
        effects->registerRealtimeTouchBorder(ElectricBorder(border),
                                             m_state->activateAction(),
                                             [this](ElectricBorder border, const QPointF &deltaProgress, const Output *screen) {
						 Q_UNUSED(screen)
                                                 m_state->setInProgress(true);

                                                 if (border == ElectricTop || border == ElectricBottom) {
                                                     Q_EMIT touchPositionChanged(deltaProgress.y(), deltaProgress.x());
                                                 } else {
                                                     Q_EMIT touchPositionChanged(deltaProgress.x(), deltaProgress.y());
                                                 }
                                             });
    }
}

} // namespace KWin
