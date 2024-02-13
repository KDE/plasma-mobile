// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "mobiletaskswitchereffect.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusReply>
#include <QKeyEvent>
#include <QMetaObject>
#include <QQuickItem>

namespace KWin
{

MobileTaskSwitcherEffect::MobileTaskSwitcherEffect()
    : m_taskSwitcherState{new EffectTogglableState(this)}
    , m_border{new EffectTogglableTouchBorder{m_taskSwitcherState}}
    , m_shutdownTimer{new QTimer{this}}
{
    auto gesture = new EffectTogglableGesture{m_taskSwitcherState};
    gesture->addTouchscreenSwipeGesture(SwipeDirection::Up, 3);

    connect(m_taskSwitcherState, &EffectTogglableState::inProgressChanged, this, &MobileTaskSwitcherEffect::gestureInProgressChanged);
    connect(m_taskSwitcherState, &EffectTogglableState::partialActivationFactorChanged, this, &MobileTaskSwitcherEffect::partialActivationFactorChanged);
    connect(m_taskSwitcherState, &EffectTogglableState::statusChanged, this, [this](EffectTogglableState::Status status) {
        if (status == EffectTogglableState::Status::Activating || status == EffectTogglableState::Status::Active) {
            setRunning(true);
            setDBusState(true);
        }
        if (status == EffectTogglableState::Status::Inactive) {
            deactivate(true);
        }
    });

    // configure close timer
    m_shutdownTimer->setSingleShot(true);
    connect(m_shutdownTimer, &QTimer::timeout, this, &MobileTaskSwitcherEffect::realDeactivate);

    // toggle action
    const QKeySequence defaultToggleShortcut = Qt::META | Qt::Key_C;

    auto toggleAction = m_taskSwitcherState->toggleAction();
    toggleAction->setObjectName(QStringLiteral("Mobile Task Switcher"));
    toggleAction->setText(i18n("Toggle Mobile Task Switcher"));
    KGlobalAccel::self()->setDefaultShortcut(toggleAction, {defaultToggleShortcut});
    KGlobalAccel::self()->setShortcut(toggleAction, {defaultToggleShortcut});

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

    m_borderActivate.clear();

    const QList<int> activateBorders = {ElectricBorder::ElectricBottom};
    for (const int &border : activateBorders) {
        ElectricBorder electricBorder = ElectricBorder(border);
        m_borderActivate.append(electricBorder);
        effects->reserveElectricBorder(electricBorder, this);
    }

    m_border->setBorders(activateBorders);
}

int MobileTaskSwitcherEffect::requestedEffectChainPosition() const
{
    return 70;
}

bool MobileTaskSwitcherEffect::borderActivated(ElectricBorder border)
{
    return m_borderActivate.contains(border);
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

    m_taskSwitcherState->activate();
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
}

void MobileTaskSwitcherEffect::realDeactivate()
{
    m_taskSwitcherState->deactivate();
    if (m_taskSwitcherState->status() == EffectTogglableState::Status::Inactive) {
        setRunning(false);
        setDBusState(false);
    }
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
    return m_taskSwitcherState->inProgress();
}

qreal MobileTaskSwitcherEffect::partialActivationFactor() const
{
    return m_taskSwitcherState->partialActivationFactor();
}

void MobileTaskSwitcherEffect::setDBusState(bool active)
{
    QDBusMessage request = QDBusMessage::createMethodCall(QStringLiteral("org.kde.plasmashell"),
                                                          QStringLiteral("/Mobile"),
                                                          QStringLiteral("org.kde.plasmashell"),
                                                          QStringLiteral("setIsTaskSwitcherVisible"));
    request.setArguments({active});

    // this does not block, so it won't necessarily be called before the method returns
    QDBusConnection::sessionBus().send(request);
}
}
