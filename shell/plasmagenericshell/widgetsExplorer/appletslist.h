/*
 *   Copyright (C) 2009 by Ana Cecília Martins <anaceciliamb@gmail.com>
 *   Copyright (C) 2009 by Ivan Cukic <ivan.cukic+kde@gmail.com>
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

#ifndef APPLETSLIST_H
#define APPLETSLIST_H

#include <QBasicTimer>
#include <QTimeLine>
#include <QtCore>
#include <QtGui>

#include <Plasma/Svg>
#include <plasma/widgets/toolbutton.h>

#include "kcategorizeditemsviewmodels_p.h"
#include "plasmaappletitemmodel_p.h"
#include "appleticon.h"
#include "applettooltip.h"

namespace Plasma
{
    class ItemBackground;
    class Animation;
} // namespace Plasma

class AppletsListWidget : public QGraphicsWidget
{

    Q_OBJECT

public:
    AppletsListWidget(Qt::Orientation orientation = Qt::Horizontal, QGraphicsItem *parent = 0);
    ~AppletsListWidget();

    //not used yet
    QList <KCategorizedItemsViewModels::AbstractItem *> selectedItems() const;

    void setItemModel(PlasmaAppletItemModel *model);
    void setFilterModel(QStandardItemModel *model);
    void setOrientation(Qt::Orientation orientation);

    // default size of the icons
    void setIconSize(int size);
    int iconSize() const;

    enum ScrollPolicy {
        DownRight = 0,
        UpLeft = 1,
        Wheel = 4,
        Button = 5
    };

private:
    void init();

    KCategorizedItemsViewModels::AbstractItem *getItemByProxyIndex(const QModelIndex &index) const;

    void populateAllAppletsHash();

    //Creates a new applet icon and puts it into the hash
    AppletIconWidget *createAppletIcon(PlasmaAppletItem *appletItem);

    //Adds the icon to the list layout
    void insertAppletIcon(AppletIconWidget *appletIconWidget);

    //see how many icons is visible at once, approximately
    int maximumAproxVisibleIconsOnList();

    //removes all the icons from the widget
    void eraseList();
    void setToolTipPosition();

    //returns the what's the visible rect of the list widget
    QRectF visibleListRect();
    //returns window's start position
    qreal visibleStartPosition();
    //returns window's end position
    qreal visibleEndPosition();
    //returns list size
    qreal listSize();
    //returns windows size relative to list
    qreal windowSize();
    //returns item position
    qreal itemPosition(int i);
    
    void scroll(ScrollPolicy side, ScrollPolicy how);

    //scrolls down or right according to orientation
    void scrollDownRight(int step);

    //scrolls up or left according to orientation
    void scrollUpLeft(int step);

    void wheelEvent(QGraphicsSceneWheelEvent *event);

    void setContentsPropertiesAccordingToOrientation();

private slots:
    void searchTermChanged(const QString &text);
    void filterChanged(int index);
    void updateList();

    void onRightArrowPress();
    void onLeftArrowPress();

    //checks if arrows should be enabled or not
    void manageArrows();

    //moves list to position 0,0
    void resetScroll();

    void itemSelected(AppletIconWidget *applet);
    void appletIconDoubleClicked(AppletIconWidget *applet);
    void appletIconHoverLeave(AppletIconWidget *appletIcon);
    void appletIconHoverEnter(AppletIconWidget *appletIcon);
    void onToolTipEnter();
    void onToolTipLeave();

    void animateToolTipMove();
    void toolTipMoveTimeLineFrameChanged(int frame);
    void rowsAboutToBeRemoved(const QModelIndex& parent, int row, int column);

protected:
    bool eventFilter(QObject *obj, QEvent *event);
    void timerEvent(QTimerEvent *event);
    QVariant itemChange(GraphicsItemChange change, const QVariant & value);

Q_SIGNALS:
    void appletDoubleClicked(PlasmaAppletItem *appletItem);

private:

    //Hash containing all widgets that represents the applets
    QHash<QString, AppletIconWidget *> m_allAppletsHash;

    //list containing the applet icons of the filter proxy model
    QList<AppletIconWidget *> m_currentAppearingAppletsOnList;

    QGraphicsLinearLayout *m_appletListLinearLayout;
    QGraphicsWidget *m_appletsListWidget;
    QGraphicsWidget *m_appletsListWindowWidget;
    QGraphicsLinearLayout *m_arrowsLayout;

    Plasma::ToolButton *m_downRightArrow;
    Plasma::ToolButton *m_upLeftArrow;
    Plasma::Svg *m_arrowsSvg;
    Plasma::FrameSvg *m_appletIconBgSvg;

    Qt::Orientation m_orientation;

    //One single tootip to show applets info
    AppletToolTipWidget *m_toolTip;
    Plasma::ItemBackground *m_selectionIndicator;
    Plasma::ItemBackground *m_hoverIndicator;

    QStandardItemModel *m_modelItems;

    //categories models
    QStandardItemModel *m_modelFilters;

    //model that filters the item models
    KCategorizedItemsViewModels::DefaultItemFilterProxyModel *m_modelFilterItems;

    //index of current first item
    int m_firstItemIndex;
    
    AppletIconWidget *m_selectedItem;

    QVariant m_dataFilterAboutToApply;
    QBasicTimer m_filterApplianceTimer;
    QBasicTimer m_toolTipAppearTimer;
    QBasicTimer m_toolTipDisappearTimer;
    QBasicTimer m_toolTipAppearWhenAlreadyVisibleTimer;
    QBasicTimer m_searchDelayTimer;
    QString m_searchString;

    int arrowClickStep;
    int wheelStep;
    int m_iconSize;

    Plasma::Animation *m_slide;

    QTimeLine toolTipMoveTimeLine;
    QPoint toolTipMoveFrom;
    QPoint toolTipMoveTo;
};

#endif //APPLETSLIST_H
