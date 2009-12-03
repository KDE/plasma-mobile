/*
 *   Copyright (C) 2009 by Ana Cecília Martins <anaceciliamb@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library/Lesser General Public License
 *   version 2, or (at your option) any later version, as published by the
 *   Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library/Lesser General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef APPLETSFILTERING_H
#define APPLETSFILTERING_H

#include <QtCore>
#include <QtGui>

#include "kcategorizeditemsviewmodels_p.h"
#include "plasmaappletitemmodel_p.h"
#include "widgetexplorer.h"
#include <plasma/widgets/tabbar.h>

class KMenu;
namespace Plasma {
    class LineEdit;
    class ToolButton;
    class TreeView;
    class WidgetExplorer;
}

class FilteringTreeView : public QGraphicsWidget
{
    Q_OBJECT

public:
    explicit FilteringTreeView(QGraphicsItem * parent = 0, Qt::WindowFlags wFlags = 0);
    virtual ~FilteringTreeView();

    void setModel(QStandardItemModel *model);

Q_SIGNALS:
    void filterChanged(int index);

private slots:
    void filterChanged(const QModelIndex &index);

private:
    void init();

    QStandardItemModel *m_model;
    Plasma::TreeView *m_treeView;
};

class FilteringTabs : public Plasma::TabBar
{
    Q_OBJECT

public:
    explicit FilteringTabs(QGraphicsWidget *parent = 0);
    virtual ~FilteringTabs();

    void setModel(QStandardItemModel *model);

Q_SIGNALS:
    void filterChanged(int index);

private:
    //uses model to populate the tabs
    void populateList();

    QStandardItem *getItemByProxyIndex(const QModelIndex &index) const;
    QStandardItemModel *m_model;
};

class FilteringWidget : public QGraphicsWidget
{
    Q_OBJECT

public:
    explicit FilteringWidget(QGraphicsItem * parent = 0, Qt::WindowFlags wFlags = 0);
    explicit FilteringWidget(Qt::Orientation orientation = Qt::Horizontal,
                             Plasma::WidgetExplorer* widgetExplorer = 0,
                             QGraphicsItem * parent = 0,
                             Qt::WindowFlags wFlags = 0);
    virtual ~FilteringWidget();

    void setModel(QStandardItemModel *model);
    void setListOrientation(Qt::Orientation orientation);
    Plasma::LineEdit *textSearch();

Q_SIGNALS:
    void filterChanged(int index);

protected Q_SLOTS:
    void setMenuPos();
    void populateWidgetsMenu();

    /**
     * Launches a download dialog to retrieve new applets from the Internet
     *
     * @arg type the type of widget to download; an empty string means the default
     *           Plasma widgets will be accessed, any other value should map to a
     *           PackageStructure PluginInfo-Name entry that provides a widget browser.
     */
    void downloadWidgets(const QString &type = QString());

    /**
     * Opens a file dialog to open a widget from a local file
     */
    void openWidgetFile();

protected:
    void resizeEvent(QGraphicsSceneResizeEvent *event);

private:
    void init();

    QStandardItemModel *m_model;
    QGraphicsLinearLayout *m_linearLayout;
    FilteringTreeView *m_categoriesTreeView;
    FilteringTabs *m_categoriesTabs;
    Plasma::LineEdit *m_textSearch;
    Qt::Orientation m_orientation;
    Plasma::ToolButton *m_newWidgetsButton;
    KMenu *m_newWidgetsMenu;
    Plasma::WidgetExplorer *m_widgetExplorer;
};

#endif // APPLETSFILTERING_H
