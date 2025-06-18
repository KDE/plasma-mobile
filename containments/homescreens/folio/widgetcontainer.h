// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QMouseEvent>
#include <QQuickItem>
#include <QTimer>

class WidgetContainer : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(bool editMode READ editMode WRITE setEditMode NOTIFY editModeChanged)

    QML_NAMED_ELEMENT(WidgetContainer)

public:
    WidgetContainer(QQuickItem *parent = nullptr);

    bool editMode() const;
    void setEditMode(bool editMode);

Q_SIGNALS:
    void editModeChanged();
    void pressReleased();
    void startEditMode(QPointF pressPoint);

protected:
    bool childMouseEventFilter(QQuickItem *item, QEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseUngrabEvent() override;

private Q_SLOTS:
    void startPressAndHold();
    void onActiveFocusChanged(bool activeFocus);

private:
    bool validMouseEvent(QMouseEvent *event);

    bool m_pressed{false};
    bool m_editMode{false};
    QTimer *m_pressAndHoldTimer{nullptr};
    QPointF m_mouseDownPosition{};
};

QML_DECLARE_TYPE(WidgetContainer)
