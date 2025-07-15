// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "homescreen.h"

#include <QObject>

#include <Plasma/Applet>
#include <PlasmaQuick/AppletQuickItem>

class HomeScreen;

struct GridPosition {
    Q_GADGET
public:
    int row;
    int column;
};

/**
 * @short Object that represents a widget on the homescreen.
 */
class FolioWidget : public QObject, public std::enable_shared_from_this<FolioWidget>
{
    Q_OBJECT
    Q_PROPERTY(int id READ id NOTIFY idChanged)
    Q_PROPERTY(int gridWidth READ gridWidth NOTIFY gridWidthChanged)
    Q_PROPERTY(int gridHeight READ gridHeight NOTIFY gridHeightChanged)
    Q_PROPERTY(Plasma::Applet *applet READ applet NOTIFY appletChanged)
    Q_PROPERTY(PlasmaQuick::AppletQuickItem *visualApplet READ visualApplet NOTIFY visualAppletChanged)

public:
    typedef std::shared_ptr<FolioWidget> Ptr;

    FolioWidget(HomeScreen *homeScreen = nullptr, int id = -1, int gridWidth = 0, int gridHeight = 0, QObject *parent = nullptr);
    FolioWidget(HomeScreen *homeScreen, Plasma::Applet *applet, int gridWidth, int gridHeight, QObject *parent = nullptr);

    static std::shared_ptr<FolioWidget> fromJson(QJsonObject &obj, HomeScreen *homeScreen);
    QJsonObject toJson() const;

    int id() const;

    int gridWidth() const;
    void setGridWidth(int gridWidth);

    int gridHeight() const;
    void setGridHeight(int gridHeight);

    int realGridWidth() const;
    void setRealGridWidth(int gridWidth);

    int realGridHeight() const;
    void setRealGridHeight(int gridHeight);

    // takes in the stored position of the widget (top left when in portrait orientation)
    // returns the position of the widget corners on a page grid, factoring in the current page orientation
    GridPosition topLeftCorner(int row, int column);

    // query whether (row, column) is inside this widget, if it was at position (widgetRow, widgetColumn)
    bool isInBounds(int widgetRow, int widgetColumn, int row, int column);

    bool overlapsWidget(int widgetRow, int widgetColumn, std::shared_ptr<FolioWidget> otherWidget, int otherWidgetRow, int otherWidgetColumn);

    Plasma::Applet *applet() const;
    void setApplet(Plasma::Applet *applet);

    PlasmaQuick::AppletQuickItem *visualApplet() const;

    Q_INVOKABLE void destroyApplet();

Q_SIGNALS:
    void idChanged();
    void appletChanged();
    void visualAppletChanged();
    void gridWidthChanged();
    void gridHeightChanged();
    void saveRequested();

    // when we resize while the screen is rotated, the stored top left position
    // changes, so we need to notify the model
    void realTopLeftPositionChanged(int offsetRows, int offsetColumns);

private:
    void init();
    void setVisualApplet(PlasmaQuick::AppletQuickItem *quickApplet);

    HomeScreen *m_homeScreen{nullptr};

    int m_id{-1};
    int m_realGridWidth{1};
    int m_realGridHeight{1};

    Plasma::Applet *m_applet{nullptr};
    PlasmaQuick::AppletQuickItem *m_quickApplet{nullptr};
};
