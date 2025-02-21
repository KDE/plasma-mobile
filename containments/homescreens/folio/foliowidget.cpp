// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "foliowidget.h"
#include "homescreenstate.h"
#include "widgetsmanager.h"

FolioWidget::FolioWidget(HomeScreen *parent, int id, int realGridWidth, int realGridHeight)
    : QObject{parent}
    , m_homeScreen{parent}
    , m_id{id}
    , m_realGridWidth{realGridWidth}
    , m_realGridHeight{realGridHeight}
    , m_applet{nullptr}
    , m_quickApplet{nullptr}
{
    auto *applet = m_homeScreen->widgetsManager()->getWidget(id);
    if (applet) {
        setApplet(applet);
    }
    init();
}

FolioWidget::FolioWidget(HomeScreen *parent, Plasma::Applet *applet, int realGridWidth, int realGridHeight)
    : QObject{parent}
    , m_homeScreen{parent}
    , m_id{applet ? static_cast<int>(applet->id()) : -1}
    , m_realGridWidth{realGridWidth}
    , m_realGridHeight{realGridHeight}
{
    setApplet(applet);
    init();
}

void FolioWidget::init()
{
    connect(m_homeScreen->homeScreenState(), &HomeScreenState::pageOrientationChanged, this, [this]() {
        Q_EMIT gridWidthChanged();
        Q_EMIT gridHeightChanged();
    });

    connect(m_homeScreen->widgetsManager(), &WidgetsManager::widgetAdded, this, [this](Plasma::Applet *applet) {
        if (applet && static_cast<int>(applet->id()) == m_id) {
            setApplet(applet);
        }
    });
    connect(m_homeScreen->widgetsManager(), &WidgetsManager::widgetRemoved, this, [this](Plasma::Applet *applet) {
        if (applet && static_cast<int>(applet->id()) == m_id) {
            setApplet(nullptr);
        }
    });
}

FolioWidget::Ptr FolioWidget::fromJson(QJsonObject &obj, HomeScreen *parent)
{
    int id = obj[QStringLiteral("id")].toInt();
    int gridWidth = obj[QStringLiteral("gridWidth")].toInt();
    int gridHeight = obj[QStringLiteral("gridHeight")].toInt();
    return std::make_shared<FolioWidget>(parent, id, gridWidth, gridHeight);
}

QJsonObject FolioWidget::toJson() const
{
    QJsonObject obj;
    obj[QStringLiteral("type")] = "widget";
    obj[QStringLiteral("id")] = m_id;
    obj[QStringLiteral("gridWidth")] = m_realGridWidth;
    obj[QStringLiteral("gridHeight")] = m_realGridHeight;
    return obj;
}

int FolioWidget::id() const
{
    return m_id;
}

int FolioWidget::gridWidth() const
{
    switch (m_homeScreen->homeScreenState()->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        return m_realGridWidth;
    case HomeScreenState::RotateClockwise:
        return m_realGridHeight;
    case HomeScreenState::RotateCounterClockwise:
        return m_realGridHeight;
    case HomeScreenState::RotateUpsideDown:
        return m_realGridWidth;
    }
    return m_realGridWidth;
}

void FolioWidget::setGridWidth(int gridWidth)
{
    switch (m_homeScreen->homeScreenState()->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        setRealGridWidth(gridWidth);
        break;
    case HomeScreenState::RotateClockwise: {
        int oldGridHeight = m_realGridHeight;
        setRealGridHeight(gridWidth);
        Q_EMIT realTopLeftPositionChanged(oldGridHeight - gridWidth, 0);
        break;
    }
    case HomeScreenState::RotateCounterClockwise:
        setRealGridHeight(gridWidth);
        break;
    case HomeScreenState::RotateUpsideDown: {
        int oldGridWidth = m_realGridWidth;
        setRealGridWidth(gridWidth);
        Q_EMIT realTopLeftPositionChanged(0, oldGridWidth - gridWidth);
        break;
    }
    }
}

int FolioWidget::gridHeight() const
{
    switch (m_homeScreen->homeScreenState()->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        return m_realGridHeight;
    case HomeScreenState::RotateClockwise:
        return m_realGridWidth;
    case HomeScreenState::RotateCounterClockwise:
        return m_realGridWidth;
    case HomeScreenState::RotateUpsideDown:
        return m_realGridHeight;
    }
    return m_realGridHeight;
}

void FolioWidget::setGridHeight(int gridHeight)
{
    switch (m_homeScreen->homeScreenState()->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        setRealGridHeight(gridHeight);
        break;
    case HomeScreenState::RotateClockwise:
        setRealGridWidth(gridHeight);
        break;
    case HomeScreenState::RotateCounterClockwise: {
        int oldGridWidth = m_realGridWidth;
        setRealGridWidth(gridHeight);
        Q_EMIT realTopLeftPositionChanged(0, oldGridWidth - gridHeight);
        break;
    }
    case HomeScreenState::RotateUpsideDown: {
        int oldGridHeight = m_realGridHeight;
        setRealGridHeight(gridHeight);
        Q_EMIT realTopLeftPositionChanged(oldGridHeight - gridHeight, 0);
        break;
    }
    }
}

int FolioWidget::realGridWidth() const
{
    return m_realGridWidth;
}

void FolioWidget::setRealGridWidth(int gridWidth)
{
    if (m_realGridWidth != gridWidth) {
        m_realGridWidth = gridWidth;

        // emit both because realGridWidth could be either gridWidth or gridHeight
        Q_EMIT gridWidthChanged();
        Q_EMIT gridHeightChanged();

        Q_EMIT saveRequested();
    }
}

int FolioWidget::realGridHeight() const
{
    return m_realGridHeight;
}

void FolioWidget::setRealGridHeight(int gridHeight)
{
    if (m_realGridHeight != gridHeight) {
        m_realGridHeight = gridHeight;

        // emit both because realGridHeight could be either gridWidth or gridHeight
        Q_EMIT gridWidthChanged();
        Q_EMIT gridHeightChanged();

        Q_EMIT saveRequested();
    }
}

GridPosition FolioWidget::topLeftCorner(int row, int column)
{
    switch (m_homeScreen->homeScreenState()->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        return {row, column};
    case HomeScreenState::RotateClockwise:
        return {row, column - gridWidth() + 1};
    case HomeScreenState::RotateCounterClockwise:
        return {row - gridHeight() + 1, column};
    case HomeScreenState::RotateUpsideDown:
        return {row - gridHeight() + 1, column - gridWidth() + 1};
    }
    return {row, column};
}

bool FolioWidget::isInBounds(int widgetRow, int widgetColumn, int row, int column)
{
    return (row >= widgetRow) && (row <= widgetRow + gridHeight() - 1) && (column >= widgetColumn) && (column <= widgetColumn + gridWidth() - 1);
}

bool FolioWidget::overlapsWidget(int widgetRow, int widgetColumn, FolioWidget::Ptr otherWidget, int otherWidgetRow, int otherWidgetColumn)
{
    if (!otherWidget) {
        return false;
    }

    // property: if they overlap, then at least one corner of one widget is in the other widget
    int widgetMaxRow = widgetRow + gridHeight() - 1;
    int widgetMaxColumn = widgetColumn + gridWidth() - 1;
    int otherWidgetMaxRow = otherWidgetRow + otherWidget->gridHeight() - 1;
    int otherWidgetMaxColumn = otherWidgetColumn + otherWidget->gridWidth() - 1;

    return isInBounds(widgetRow, widgetColumn, otherWidgetRow, otherWidgetColumn) || isInBounds(widgetRow, widgetColumn, otherWidgetMaxRow, otherWidgetColumn)
        || isInBounds(widgetRow, widgetColumn, otherWidgetRow, otherWidgetMaxColumn)
        || isInBounds(widgetRow, widgetColumn, otherWidgetMaxRow, otherWidgetMaxColumn)
        || otherWidget->isInBounds(otherWidgetRow, otherWidgetColumn, widgetRow, widgetColumn)
        || otherWidget->isInBounds(otherWidgetRow, otherWidgetColumn, widgetMaxRow, widgetColumn)
        || otherWidget->isInBounds(otherWidgetRow, otherWidgetColumn, widgetRow, widgetMaxColumn)
        || otherWidget->isInBounds(otherWidgetRow, otherWidgetColumn, widgetMaxRow, widgetMaxColumn);
}

Plasma::Applet *FolioWidget::applet() const
{
    return m_applet;
}

void FolioWidget::setApplet(Plasma::Applet *applet)
{
    m_applet = applet;
    Q_EMIT appletChanged();

    int id = applet ? applet->id() : -1;
    if (m_id != id) {
        m_id = id;
        Q_EMIT idChanged();

        // ensure the id is saved
        Q_EMIT saveRequested();
    }

    if (m_applet) {
        setVisualApplet(PlasmaQuick::AppletQuickItem::itemForApplet(m_applet));
    } else {
        setVisualApplet(nullptr);
    }
}

PlasmaQuick::AppletQuickItem *FolioWidget::visualApplet() const
{
    return m_quickApplet;
}

void FolioWidget::setVisualApplet(PlasmaQuick::AppletQuickItem *quickItem)
{
    m_quickApplet = quickItem;
    Q_EMIT visualAppletChanged();
}

void FolioWidget::destroyApplet()
{
    if (m_applet) {
        m_applet->destroy();
    }
}
