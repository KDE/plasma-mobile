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

#ifndef APPLETTOOLTIP_H
#define APPLETTOOLTIP_H

#include "plasmaappletitemmodel_p.h"
#include "appleticon.h"

#include <QtCore>
#include <QtGui>

#include <plasma/dialog.h>
#include <plasma/widgets/iconwidget.h>
#include <plasma/widgets/pushbutton.h>
#include <plasma/widgets/textbrowser.h>
#include <plasma/widgets/label.h>

class AppletInfoWidget : public QGraphicsWidget {

    Q_OBJECT

    public:
        AppletInfoWidget(QGraphicsItem *parent = 0, PlasmaAppletItem *appletItem = 0);
        ~AppletInfoWidget();

        void init();
        void setAppletItem(PlasmaAppletItem *appletItem);

    public Q_SLOTS:
        void updateInfo();

    protected Q_SLOTS:
        void uninstall();

    private:
        PlasmaAppletItem *m_appletItem;
        QGraphicsLinearLayout *m_mainLayout;
        QGraphicsLinearLayout *m_mainVerticalLayout;

        Plasma::IconWidget *m_iconWidget;
        Plasma::Label *m_nameLabel;
        Plasma::Label *m_versionLabel;
        Plasma::TextBrowser *m_aboutLabel;
        Plasma::PushButton *m_uninstallButton;
};

class AppletToolTipWidget : public Plasma::Dialog {

    Q_OBJECT

    public:
        explicit AppletToolTipWidget(QWidget *parent = 0, AppletIconWidget *applet = 0);
        virtual ~AppletToolTipWidget();

        void setAppletIconWidget(AppletIconWidget *applet);
        void updateContent();
        AppletIconWidget *appletIconWidget();
        void setScene(QGraphicsScene *scene);

    Q_SIGNALS:
        void enter();
        void leave();

    protected:
        void enterEvent(QEvent *event);
        void leaveEvent(QEvent *event);
        void dragEnterEvent(QDragEnterEvent *event);

    private:
        AppletIconWidget *m_applet;
        AppletInfoWidget *m_widget;
};

#endif //APPLETTOOLTIP_H
