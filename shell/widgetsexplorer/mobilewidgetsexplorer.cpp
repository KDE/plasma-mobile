/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

//own
#include "mobilewidgetsexplorer.h"
#include "../../common/qmlwidget.h"
#include "plasmaappletitemmodel_p.h"

//Qt
#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeItem>
#include <QtGui/QGraphicsLinearLayout>
#include <QStandardItemModel>

//KDE
#include <KDebug>
#include <KStandardDirs>



MobileWidgetsExplorer::MobileWidgetsExplorer(QGraphicsItem *parent)
    : QGraphicsWidget(parent)
{
    setContentsMargins(0, 0, 0, 0);

    m_qmlWidget = new Plasma::QmlWidget(this);
    QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(this);
    lay->setContentsMargins(0, 0, 0, 0);
    lay->addItem(m_qmlWidget);

    m_qmlWidget->setQmlPath(KStandardDirs::locate("data", "plasma-mobile/mobilewidgetsexplorer/view.qml"));

    m_appletsModel = new PlasmaAppletItemModel(this);

    if (m_qmlWidget->engine()) {
        QDeclarativeContext *ctxt = m_qmlWidget->engine()->rootContext();
        if (ctxt) {
            ctxt->setContextProperty("myModel", m_appletsModel);
        }
        QDeclarativeItem *item = qobject_cast<QDeclarativeItem *>(m_qmlWidget->rootObject());
        if (item) {
            connect(item, SIGNAL(clicked()), this, SLOT(itemActivated()));
        }
    }
}

MobileWidgetsExplorer::~MobileWidgetsExplorer()
{
}



#include "mobilewidgetsexplorer.moc"
