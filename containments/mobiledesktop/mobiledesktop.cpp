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
#include "mobiledesktop.h"

//Qt
#include <QtDeclarative/QDeclarativeComponent>
#include <QtDeclarative/QDeclarativeItem>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtGui/QGraphicsLinearLayout>

//KDE
#include <KDebug>
#include <KStandardDirs>
#include <Plasma/Corona>

using namespace Plasma;

MobileDesktop::MobileDesktop(QObject *parent, const QVariantList &args)
    : Containment(parent, args),
      m_engine(0),
      m_component(0),
      m_root(0)
{
    setHasConfigurationInterface(false);
    kDebug() << "!!! loading mobile desktop";
    // At some point it has to be a custom constainment
    //setContainmentType(Containment::CustomContainment);
}

MobileDesktop::~MobileDesktop()
{
}

void MobileDesktop::init()
{
    Containment::init();

    setAcceptsHoverEvents(false);
    setFlag(QGraphicsItem::ItemSendsGeometryChanges, false);
    setFlag(QGraphicsItem::ItemUsesExtendedStyleOption, false);
    execute(KStandardDirs::locate("data", "plasma-mobile/containments/mobile-desktop/Main.qml"));
}

void MobileDesktop::errorPrint()
{
    loaded=false;
    QString errorStr = "Error loading QML file.\n";
    if(m_component->isError()){
        QList<QDeclarativeError> errors = m_component->errors();
        foreach (const QDeclarativeError &error, errors) {
            errorStr += (error.line()>0?QString::number(error.line()) + ": ":"")
                + error.description() + '\n';
        }
    }
    kWarning() << errorStr;
}

void MobileDesktop::execute(const QString &fileName)
{
    if (fileName.isEmpty()) {
      return;
    } if (m_engine) {
      delete m_engine;
    } if (m_component) {
      delete m_component;
    }

    m_engine = new QDeclarativeEngine(this);
    m_component = new QDeclarativeComponent(m_engine, fileName, this);

    if(m_component->isReady() || m_component->isError()) {
        finishExecute();
    } else {
        QObject::connect(m_component, SIGNAL(statusChanged(QDeclarativeComponent::Status)), this, SLOT(finishExecute()));
    }
}

void MobileDesktop::constraintsEvent(Plasma::Constraints constraints)
{
    if (m_root && (constraints & Plasma::SizeConstraint)) {
        m_root->setProperty("width", size().width());
        m_root->setProperty("height", size().height());
    }
}

void MobileDesktop::finishExecute()
{
    if(m_component->isError()) {
        errorPrint();
    }
    m_root = m_component->create();
    if (!m_root) {
        errorPrint();
    }

    QGraphicsWidget *widget = dynamic_cast<QGraphicsWidget*>(m_root);
    if (widget) {
        QGraphicsLinearLayout* layout = new QGraphicsLinearLayout(this);
        layout->setContentsMargins(0, 0, 0, 0);
        layout->setSpacing(0);
        layout->addItem(this);
        widget->setLayout(layout);
        QGraphicsObject *object = dynamic_cast<QGraphicsObject *>(m_root);
        corona()->addItem(object);
        setParentItem(object);
        setParent(object);
    } else {
        QDeclarativeItem *object = dynamic_cast<QDeclarativeItem *>(m_root);
        corona()->addItem(object);
        setParentItem(object);
        setParent(object);
        object->setProperty("containment", qVariantFromValue((QGraphicsObject*)this));
        setPos(0, 0);
        resize(object->width(), object->height());
        if (id() == 1) {
            object->setProperty("flipable", false);
        }
    }
}

K_EXPORT_PLASMA_APPLET(mobiledesktop, MobileDesktop)

#include "mobiledesktop.moc"
