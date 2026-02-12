// SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "widgetcontainer.h"

#include <QCursor>
#include <QGuiApplication>
#include <QStyleHints>

WidgetContainer::WidgetContainer(QQuickItem *parent)
    : QQuickItem(parent)
    , m_pressAndHoldTimer{new QTimer{this}}
{
    m_pressAndHoldTimer->setInterval(QGuiApplication::styleHints()->mousePressAndHoldInterval());
    m_pressAndHoldTimer->setSingleShot(true);
    connect(m_pressAndHoldTimer, &QTimer::timeout, this, &WidgetContainer::startPressAndHold);

    setFiltersChildMouseEvents(true);
    setFlags(QQuickItem::ItemIsFocusScope);
    setActiveFocusOnTab(true);
    setAcceptedMouseButtons(Qt::LeftButton);

    connect(this, &WidgetContainer::activeFocusChanged, this, &WidgetContainer::onActiveFocusChanged);
}

bool WidgetContainer::editMode() const
{
    return m_editMode;
}

void WidgetContainer::setEditMode(bool editMode)
{
    if (m_editMode != editMode) {
        m_editMode = editMode;

        if (m_editMode) {
            setZ(1);

            if (m_pressed) {
                // sendUngrabRecursive(m_contentItem);
                QMouseEvent ev(QEvent::MouseButtonPress, mapFromScene(m_mouseDownPosition), m_mouseDownPosition, QPointF(), Qt::LeftButton, {}, {});
                ev.setExclusiveGrabber(ev.point(0), this);
                QCoreApplication::sendEvent(this, &ev);
            }

        } else {
            setZ(0);
        }

        Q_EMIT editModeChanged();
    }
}

bool WidgetContainer::childMouseEventFilter(QQuickItem *item, QEvent *event)
{
    switch (event->type()) {
    case QEvent::MouseButtonPress: {
        QMouseEvent *me = static_cast<QMouseEvent *>(event);

        if (!validMouseEvent(me)) {
            return true;
        }

        if (me->buttons() & Qt::LeftButton) {
            mousePressEvent(me);
        }
        break;
    }
    case QEvent::MouseMove: {
        QMouseEvent *me = static_cast<QMouseEvent *>(event);

        if (!validMouseEvent(me)) {
            return true;
        }

        mouseMoveEvent(me);
        break;
    }
    case QEvent::MouseButtonRelease: {
        QMouseEvent *me = static_cast<QMouseEvent *>(event);

        if (!validMouseEvent(me)) {
            return true;
        }

        mouseReleaseEvent(me);
        break;
    }
    case QEvent::UngrabMouse:
        mouseUngrabEvent();
        break;
    default:
        break;
    }

    return QQuickItem::childMouseEventFilter(item, event);
}

void WidgetContainer::mousePressEvent(QMouseEvent *event)
{
    forceActiveFocus(Qt::MouseFocusReason);

    m_pressed = true;
    m_pressAndHoldTimer->start();
    m_mouseDownPosition = event->scenePosition();
    event->accept();
}

void WidgetContainer::mouseMoveEvent(QMouseEvent *event)
{
    if (!m_editMode && QPointF(event->scenePosition() - m_mouseDownPosition).manhattanLength() >= QGuiApplication::styleHints()->startDragDistance()) {
        m_pressAndHoldTimer->stop();
    }

    QQuickItem::mouseMoveEvent(event);
}

void WidgetContainer::mouseReleaseEvent(QMouseEvent *event)
{
    Q_EMIT pressReleased();

    m_pressAndHoldTimer->stop();
    m_pressed = false;

    event->accept();
}

void WidgetContainer::mouseUngrabEvent()
{
    m_pressAndHoldTimer->stop();
    m_pressed = false;
}

void WidgetContainer::startPressAndHold()
{
    setEditMode(true);
    Q_EMIT startEditMode(m_mouseDownPosition);
}

void WidgetContainer::onActiveFocusChanged(bool activeFocus)
{
    if (!activeFocus) {
        setEditMode(false);
    }
}

bool WidgetContainer::validMouseEvent(QMouseEvent *event)
{
    bool synthesized = event->source() == Qt::MouseEventSynthesizedByQt || event->source() == Qt::MouseEventSynthesizedBySystem;

    // Don't need to block propagated events
    if (!synthesized || event->type() != QEvent::MouseButtonRelease) {
        return true;
    }

    // If edit mode is not enabled, let the event propagate
    if (!m_editMode) {
        return true;
    } else {
        // If edit mode is enabled, block the event propagation and handle it only on the WidgetContainer
        mouseReleaseEvent(event);
        return false;
    }
}
