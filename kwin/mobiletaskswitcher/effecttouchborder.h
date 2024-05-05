// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@server23.cc>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QAction>
#include <effect/effect.h>
#include <effect/effecthandler.h>

namespace KWin
{

class EffectTouchBorderState : public QObject
{
    Q_OBJECT

public:
    EffectTouchBorderState(Effect *parent);

    bool inProgress() const;
    void setInProgress(bool inProgress);

    QAction *activateAction() const
    {
        return m_activateAction.get();
    }

Q_SIGNALS:
    void inProgressChanged();

private:
    bool m_inProgress = false;

    std::unique_ptr<QAction> m_activateAction;
};

class EffectTouchBorder : public QObject
{
    Q_OBJECT

public:
    EffectTouchBorder(EffectTouchBorderState *state);
    ~EffectTouchBorder();

    void setBorders(const QList<int> &borders);

Q_SIGNALS:
    void touchPositionChanged(qreal primaryPosition, qreal orthogonalPosition);

private:
    QList<ElectricBorder> m_touchBorderActivate;
    EffectTouchBorderState *m_state;
};

}
