// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "mobiletaskswitchereffect.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusReply>
#include <QKeyEvent>
#include <QMetaObject>
#include <QQuickItem>
#include <window.h>

using namespace std::chrono_literals;

const QString SHELL_CONFIG_FILE = QStringLiteral("plasmamobilerc");
const QString SHELL_CONFIG_GROUP = QStringLiteral("General");
const QString NAVIGATION_PANEL_SHOWN_CONFIG_KEY = QStringLiteral("navigationPanelEnabled");

namespace KWin
{

MobileTaskSwitcherState::MobileTaskSwitcherState(EffectTouchBorderState *effectState)
    : m_effectState{effectState}
    , m_doubleClickTimer{new QElapsedTimer{}}
{
    connect(m_effectState, &EffectTouchBorderState::inProgressChanged, this, &MobileTaskSwitcherState::gestureInProgressChanged);
}

bool MobileTaskSwitcherState::gestureInProgress() const
{
    return m_effectState->inProgress();
}

void MobileTaskSwitcherState::setGestureInProgress(bool gestureInProgress)
{
    if (m_status == Status::Stopped) {
        return;
    }
    m_effectState->setInProgress(gestureInProgress);
}

bool MobileTaskSwitcherState::wasInActiveTask() const
{
    return m_wasInActiveTask;
}

void MobileTaskSwitcherState::setWasInActiveTask(bool wasInActiveTask)
{
    if (m_wasInActiveTask != wasInActiveTask) {
        m_wasInActiveTask = wasInActiveTask;
        Q_EMIT wasInActiveTaskChanged();
    }
}

void MobileTaskSwitcherState::updateWasInActiveTask(KWin::Window *window)
{
    bool newWasInActiveTask = false;
    if (window) {
        newWasInActiveTask = !window->isDesktop();
    }
    setWasInActiveTask(newWasInActiveTask);
}

qreal MobileTaskSwitcherState::touchXPosition() const
{
    return m_touchXPosition;
}

qreal MobileTaskSwitcherState::touchYPosition() const
{
    return m_touchYPosition;
}

qreal MobileTaskSwitcherState::xVelocity() const
{
    return m_xVelocity;
}

qreal MobileTaskSwitcherState::yVelocity() const
{
    return m_yVelocity;
}

qreal MobileTaskSwitcherState::totalSquaredVelocity() const
{
    return m_totalSquaredVelocity;
}

qreal MobileTaskSwitcherState::flickVelocityThreshold() const
{
    return m_flickVelocityThreshold;
}

void MobileTaskSwitcherState::setFlickVelocityThreshold(qreal flickVelocityThreshold)
{
    if (m_flickVelocityThreshold != flickVelocityThreshold) {
        m_flickVelocityThreshold = flickVelocityThreshold;
        Q_EMIT flickVelocityThresholdChanged();
    }
}

qreal MobileTaskSwitcherState::xPosition() const
{
    return m_xPosition;
}

void MobileTaskSwitcherState::setXPosition(qreal xPosition)
{
    if (m_xPosition != xPosition) {
        m_xPosition = xPosition;
        Q_EMIT xPositionChanged();
    }
}

qreal MobileTaskSwitcherState::yPosition() const
{
    return m_yPosition;
}

void MobileTaskSwitcherState::setYPosition(qreal yPosition)
{
    if (m_yPosition != yPosition) {
        m_yPosition = yPosition;
        Q_EMIT yPositionChanged();
    }
}

void MobileTaskSwitcherState::setStatus(Status status)
{
    if (m_status != status) {
        if (status == Status::Inactive) {
            setYPosition(0);
        }
        m_status = status;
        Q_EMIT statusChanged();
    }
}

void MobileTaskSwitcherState::setCurrentTaskIndex(int newTaskIndex)
{
    if (m_currentTaskIndex != newTaskIndex) {
        m_currentTaskIndex = newTaskIndex;
        Q_EMIT currentTaskIndexChanged();
    }
}

void MobileTaskSwitcherState::setInitialTaskIndex(int newTaskIndex)
{
    if (m_initialTaskIndex != newTaskIndex) {
        m_initialTaskIndex = newTaskIndex;
        Q_EMIT initialTaskIndexChanged();
    }
}

void MobileTaskSwitcherState::restartDoubleClickTimer()
{
    m_doubleClickTimer->restart();
}

void MobileTaskSwitcherState::calculateFilteredVelocity(qreal primaryDelta, qreal orthogonalDelta)
{
    static qreal prevPrimaryDelta = 0;
    static qreal prevOrthogonalDelta = 0;

    qint64 frameTime = 0;
    if (!m_frameTimer.isValid()) {
        prevPrimaryDelta = 0;
        prevOrthogonalDelta = 0;
        m_frameTimer.start();
        return;
    }
    frameTime = m_frameTimer.restart();
    if (frameTime == 0) {
        // Skip because otherwise we get NaN later on. Not sure why this triggers as often as it does
        return;
    }

    qreal framePrimaryDelta = primaryDelta - prevPrimaryDelta;
    qreal frameOrthogonalDelta = orthogonalDelta - prevOrthogonalDelta;
    prevPrimaryDelta = primaryDelta;
    prevOrthogonalDelta = orthogonalDelta;

    // Implements an exponentially weighted moving average (EWMA) filter (= exponential smoothing)
    // Smoothing factor is approximated each event to achieve a chosen filter time constant
    qreal smoothingFactor = std::min(frameTime / (1000 * m_filterTimeConstant), 0.8);
    m_yVelocity = m_yVelocity + smoothingFactor * (framePrimaryDelta / frameTime - m_yVelocity);
    m_xVelocity = m_xVelocity + smoothingFactor * (frameOrthogonalDelta / frameTime - m_xVelocity);
    m_totalSquaredVelocity = m_yVelocity * m_yVelocity + m_xVelocity * m_xVelocity;
    Q_EMIT velocityChanged();
}

void MobileTaskSwitcherState::processTouchPositionChanged(qreal primaryDelta, qreal orthogonalDelta)
{
    calculateFilteredVelocity(primaryDelta, orthogonalDelta);
    m_touchXPosition = orthogonalDelta;
    m_touchYPosition = primaryDelta;
    Q_EMIT touchPositionChanged();
}

qint64 MobileTaskSwitcherState::getElapsedTimeSinceStart()
{
    if (m_doubleClickTimer->isValid())
    {
        return m_doubleClickTimer->elapsed();
    }
    return -1;
}

MobileTaskSwitcherEffect::MobileTaskSwitcherEffect()
    : m_effectState{new EffectTouchBorderState(this)}
    , m_taskSwitcherState{new MobileTaskSwitcherState(m_effectState)}
    , m_taskModel{new TaskModel{this}}
    , m_border{new EffectTouchBorder{m_effectState}}
    , m_toggleAction{std::make_unique<QAction>()}
    , m_shutdownTimer{new QTimer{this}}
    , m_mobileShellConfig{KSharedConfig::openConfig(SHELL_CONFIG_FILE, KConfig::SimpleConfig)}
{
    // Watch shell config for gesture mode changes
    m_mobileShellConfigWatcher = KConfigWatcher::create(m_mobileShellConfig);
    connect(m_mobileShellConfigWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) -> void {
        if (group.name() == SHELL_CONFIG_GROUP && names.contains(NAVIGATION_PANEL_SHOWN_CONFIG_KEY)) {
            reconfigure(ReconfigureFlag::ReconfigureAll);
        }
    });

    const char *uri = "org.kde.private.mobileshell.taskswitcher";
    qmlRegisterType<TaskFilterModel>(uri, 1, 0, "TaskFilterModel");
    qmlRegisterSingletonType<TaskModel>(uri, 1, 0, "TaskModel", [this](QQmlEngine *, QJSEngine *) -> QObject * {
        return m_taskModel;
    });
    qmlRegisterSingletonType<MobileTaskSwitcherState>(uri, 1, 0, "TaskSwitcherState", [this](QQmlEngine *, QJSEngine *) -> QObject * {
        return m_taskSwitcherState;
    });

    connect(m_border, &EffectTouchBorder::touchPositionChanged, m_taskSwitcherState, &MobileTaskSwitcherState::processTouchPositionChanged);

    connect(m_taskSwitcherState, &MobileTaskSwitcherState::gestureInProgressChanged, this, [this]() {
        if (m_taskSwitcherState->gestureInProgress()) {
            invokeEffect();
        }
    });

    // configure close timer
    m_shutdownTimer->setSingleShot(true);
    connect(m_shutdownTimer, &QTimer::timeout, this, &MobileTaskSwitcherEffect::realDeactivate);

    // toggle action
    const QKeySequence defaultToggleShortcut = Qt::META | Qt::Key_C;

    m_toggleAction.get()->setObjectName(QStringLiteral("Mobile Task Switcher"));
    m_toggleAction.get()->setText(i18n("Toggle Mobile Task Switcher"));
    KGlobalAccel::self()->setDefaultShortcut(m_toggleAction.get(), {defaultToggleShortcut});
    KGlobalAccel::self()->setShortcut(m_toggleAction.get(), {defaultToggleShortcut});
    connect(m_toggleAction.get(), &QAction::triggered, this, &MobileTaskSwitcherEffect::toggle);

    connect(effects, &EffectsHandler::screenAboutToLock, this, &MobileTaskSwitcherEffect::realDeactivate);

    setSource(QUrl::fromLocalFile(
        QStandardPaths::locate(QStandardPaths::GenericDataLocation, QStringLiteral("kwin/effects/mobiletaskswitcher/qml/TaskSwitcher.qml"))));
    reconfigure(ReconfigureFlag::ReconfigureAll);
}

MobileTaskSwitcherEffect::~MobileTaskSwitcherEffect()
{
}

void MobileTaskSwitcherEffect::reconfigure(ReconfigureFlags)
{
    setAnimationDuration(animationTime(300ms));

    auto group = KConfigGroup{m_mobileShellConfig, SHELL_CONFIG_GROUP};

    // Only enable edge borders when navigation panel is not shown
    if (group.readEntry(NAVIGATION_PANEL_SHOWN_CONFIG_KEY, true)) {
        m_border->setBorders({});
    } else {
        m_border->setBorders(m_borderActivate);
    }
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
        m_taskSwitcherState->restartDoubleClickTimer();
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

    m_effectState->setInProgress(false);
    invokeEffect();
}

void MobileTaskSwitcherEffect::deactivate(bool deactivateInstantly)
{
    const auto screens = effects->screens();
    for (const auto screen : screens) {
        if (QuickSceneView *view = viewForScreen(screen)) {
            QMetaObject::invokeMethod(view->rootItem(), "hideAnimation");
        }
    }
    m_shutdownTimer->start(animationTime(deactivateInstantly ? 0ms : 200ms));
}

void MobileTaskSwitcherEffect::realDeactivate()
{
    m_effectState->setInProgress(false);
    m_taskSwitcherState->setStatus(MobileTaskSwitcherState::Status::Inactive);
    setRunning(false);
    setDBusState(false);
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

void MobileTaskSwitcherEffect::invokeEffect()
{
    m_taskSwitcherState->setInitialTaskIndex(
        m_taskSwitcherState->currentTaskIndex()); // TODO! this is only until the crashing bug is fixed and recency sorting is in
    setRunning(true);
    setDBusState(true);
}
}
