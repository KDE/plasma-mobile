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

//Plasma
#include <Plasma/Containment>
#include <Plasma/DeclarativeWidget>

MobileWidgetsExplorer::MobileWidgetsExplorer(QGraphicsItem *parent)
    : QGraphicsWidget(parent),
      m_containment(0),
      m_mainWidget(0)
{
    setContentsMargins(0, 0, 0, 0);

    m_declarativeWidget = new Plasma::DeclarativeWidget(this);
    QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(this);
    lay->setContentsMargins(0, 0, 0, 0);
    lay->addItem(m_declarativeWidget);

    m_appletsModel = new PlasmaAppletItemModel(this);
    m_appletsModel->setApplication(QString());

    m_declarativeWidget->setQmlPath(KStandardDirs::locate("data", "plasma-active/mobilewidgetsexplorer/view.qml"));

    if (m_declarativeWidget->engine()) {
        QDeclarativeContext *ctxt = m_declarativeWidget->engine()->rootContext();
        if (ctxt) {
            ctxt->setContextProperty("myModel", m_appletsModel);
        }
        m_mainWidget = qobject_cast<QDeclarativeItem *>(m_declarativeWidget->rootObject());

        if (m_mainWidget) {
            connect(m_mainWidget, SIGNAL(addAppletRequested(const QString &)), this, SLOT(addApplet(const QString &)));
            connect(m_mainWidget, SIGNAL(closeRequested()), this, SLOT(deleteLater()));
        }
    }
}

MobileWidgetsExplorer::~MobileWidgetsExplorer()
{
}

void MobileWidgetsExplorer::setContainment(Plasma::Containment *cont)
{
    m_containment = cont;
}

Plasma::Containment *MobileWidgetsExplorer::containment() const
{
    return m_containment;
}

void MobileWidgetsExplorer::addApplet(const QString &plugin)
{
    if (m_mainWidget) {
        kWarning() << "Applet added" << plugin;

        if (m_containment) {
            m_containment->addApplet(plugin);
        }
    }
}

#include "mobilewidgetsexplorer.moc"
