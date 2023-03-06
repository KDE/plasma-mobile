// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "mobiletaskswitchereffect.h"

#include <QKeyEvent>
#include <QMetaObject>
#include <QQuickItem>

namespace KWin
{

MobileTaskSwitcherEffect::MobileTaskSwitcherEffect()
    : m_shutdownTimer(new QTimer(this))
{
    m_shutdownTimer->setSingleShot(true);
    connect(m_shutdownTimer, &QTimer::timeout, this, &MobileTaskSwitcherEffect::realDeactivate);

    const QKeySequence defaultToggleShortcut = Qt::META | Qt::Key_C;

    m_toggleAction = new QAction(this);
    m_toggleAction->setObjectName(QStringLiteral("Mobile Task Switcher"));
    m_toggleAction->setText(i18n("Toggle Mobile Task Switcher"));

    connect(m_toggleAction, &QAction::triggered, this, &MobileTaskSwitcherEffect::toggle);

    KGlobalAccel::self()->setDefaultShortcut(m_toggleAction, {defaultToggleShortcut});
    KGlobalAccel::self()->setShortcut(m_toggleAction, {defaultToggleShortcut});

    m_realtimeToggleAction = new QAction(this);
    connect(m_realtimeToggleAction, &QAction::triggered, this, [this]() {
        if (m_status == Status::Deactivating) {
            if (m_partialActivationFactor < 0.5) {
                deactivate(false);
            } else {
                cancelPartialDeactivate();
            }
        } else if (m_status == Status::Activating) {
            if (m_partialActivationFactor > 0.5) {
                activate();
            } else {
                cancelPartialActivate();
            }
        }
    });

    auto progressCallback = [this](qreal progress) {
        if (!effects->hasActiveFullScreenEffect() || effects->activeFullScreenEffect() == this) {
            switch (m_status) {
            case Status::Inactive:
            case Status::Activating:
                partialActivate(progress);
                break;
            case Status::Active:
            case Status::Deactivating:
                partialDeactivate(progress);
                break;
            }
        }
    };

    effects->registerTouchpadPinchShortcut(PinchDirection::Contracting, 4, m_realtimeToggleAction, progressCallback);
    effects->registerTouchscreenSwipeShortcut(SwipeDirection::Up, 3, m_realtimeToggleAction, progressCallback);

    connect(effects, &EffectsHandler::screenAboutToLock, this, &MobileTaskSwitcherEffect::realDeactivate);

    setSource(QUrl::fromLocalFile(
        QStandardPaths::locate(QStandardPaths::GenericDataLocation, QStringLiteral("kwin/effects/mobiletaskswitcher/qml/TaskSwitcher.qml"))));
}

MobileTaskSwitcherEffect::~MobileTaskSwitcherEffect()
{
}

void MobileTaskSwitcherEffect::reconfigure(ReconfigureFlags)
{
    setAnimationDuration(animationTime(300));

    for (const ElectricBorder &border : std::as_const(m_borderActivate)) {
        effects->unreserveElectricBorder(border, this);
    }

    for (const ElectricBorder &border : std::as_const(m_touchBorderActivate)) {
        effects->unregisterTouchBorder(border, m_toggleAction);
    }

    m_borderActivate.clear();
    m_touchBorderActivate.clear();

    const QList<int> activateBorders = {ElectricBorder::ElectricBottom};
    for (const int &border : activateBorders) {
        m_borderActivate.append(ElectricBorder(border));
        effects->reserveElectricBorder(ElectricBorder(border), this);
    }

    const QList<int> touchActivateBorders = {ElectricBorder::ElectricBottom};
    for (const int &border : touchActivateBorders) {
        m_touchBorderActivate.append(ElectricBorder(border));
        effects->registerRealtimeTouchBorder(ElectricBorder(border),
                                             m_realtimeToggleAction,
                                             [this](ElectricBorder border, const QPointF &deltaProgress, const EffectScreen *screen) {
                                                 if (m_status == Status::Active) {
                                                     return;
                                                 }
                                                 const int maxDelta = 500; // Arbitrary logical pixels value seems to behave better than scaledScreenSize
                                                 if (border == ElectricTop || border == ElectricBottom) {
                                                     partialActivate(std::min(1.0, std::abs(deltaProgress.y()) / maxDelta));
                                                 } else {
                                                     partialActivate(std::min(1.0, std::abs(deltaProgress.x()) / maxDelta));
                                                 }
                                             });
    }
}

int MobileTaskSwitcherEffect::requestedEffectChainPosition() const
{
    return 70;
}

bool MobileTaskSwitcherEffect::borderActivated(ElectricBorder border)
{
    return false;
}

void MobileTaskSwitcherEffect::grabbedKeyboardEvent(QKeyEvent *keyEvent)
{
    if (m_toggleShortcut.contains(keyEvent->key() | keyEvent->modifiers())) {
        if (keyEvent->type() == QEvent::KeyPress) {
            toggle();
        }
        return;
    }
    QuickSceneEffect::grabbedKeyboardEvent(keyEvent);
}

void MobileTaskSwitcherEffect::toggle()
{
    if (!isRunning()) {
        activate();
    } else {
        deactivate(false);
    }
}

void MobileTaskSwitcherEffect::activate()
{
    if (effects->isScreenLocked()) {
        return;
    }

    m_status = Status::Active;
    setRunning(true);
}

void MobileTaskSwitcherEffect::deactivate(bool deactivateInstantly)
{
    const auto screens = effects->screens();
    for (const auto screen : screens) {
        if (QuickSceneView *view = viewForScreen(screen)) {
            QMetaObject::invokeMethod(view->rootItem(), "hideAnimation");
        }
    }
    m_shutdownTimer->start(animationTime(deactivateInstantly ? 0 : 200));

    setGestureInProgress(false);
    setPartialActivationFactor(0.0);
}

void MobileTaskSwitcherEffect::partialActivate(qreal factor)
{
    if (effects->isScreenLocked()) {
        return;
    }

    m_status = Status::Activating;

    setPartialActivationFactor(factor);
    setGestureInProgress(true);

    setRunning(true);
}

void MobileTaskSwitcherEffect::partialDeactivate(qreal factor)
{
    m_status = Status::Deactivating;

    setPartialActivationFactor(1.0 - factor);
    setGestureInProgress(true);
}

void MobileTaskSwitcherEffect::cancelPartialDeactivate()
{
    activate();
}

void MobileTaskSwitcherEffect::cancelPartialActivate()
{
    deactivate(false);
}

void MobileTaskSwitcherEffect::realDeactivate()
{
    setRunning(false);
    m_status = Status::Inactive;
}

void MobileTaskSwitcherEffect::quickDeactivate()
{
    m_shutdownTimer->start(0);
}

int MobileTaskSwitcherEffect::animationDuration() const
{
    return m_animationDuration;
}

void MobileTaskSwitcherEffect::setAnimationDuration(int duration)
{
    if (m_animationDuration != duration) {
        m_animationDuration = duration;
        Q_EMIT animationDurationChanged();
    }
}

bool MobileTaskSwitcherEffect::gestureInProgress() const
{
    return m_gestureInProgress;
}

void MobileTaskSwitcherEffect::setGestureInProgress(bool gesture)
{
    if (m_gestureInProgress != gesture) {
        m_gestureInProgress = gesture;
        Q_EMIT gestureInProgressChanged();
    }
}

qreal MobileTaskSwitcherEffect::partialActivationFactor() const
{
    return m_partialActivationFactor;
}

void MobileTaskSwitcherEffect::setPartialActivationFactor(qreal factor)
{
    if (m_partialActivationFactor != factor) {
        qDebug() << factor;
        m_partialActivationFactor = factor;
        Q_EMIT partialActivationFactorChanged();
    }
}
}
