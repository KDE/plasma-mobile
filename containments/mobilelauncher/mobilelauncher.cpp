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
#include "mobilelauncher.h"
#include "../../common/qmlwidget.h"
#include "models/krunnermodel.h"
#include "resultwidget.h"


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
#include <Plasma/Corona>
#include <Plasma/RunnerManager>



QML_DECLARE_TYPE(ResultWidget)


MobileLauncher::MobileLauncher(QObject *parent, const QVariantList &args)
    : Containment(parent, args)
{
    setHasConfigurationInterface(false);
    kDebug() << "!!! loading mobile launcher";

    qmlRegisterType<ResultWidget>("MobileLauncher", 1, 0, "ResultWidget");
    // At some point it has to be a custom constainment
    setContainmentType(Containment::CustomContainment);
}

MobileLauncher::~MobileLauncher()
{
}

void MobileLauncher::init()
{
    Containment::init();

    m_runnerModel = new KRunnerModel(this);
    m_runnerModel->setQuery("Network");

    setContentsMargins(0, 16, 0, 32);

    m_qmlWidget = new Plasma::QmlWidget(this);
    QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(this);
    lay->addItem(m_qmlWidget);

    m_qmlWidget->setQmlPath(KStandardDirs::locate("data", "plasma-mobile/containments/mobilelauncher/view.qml"));

    if (m_qmlWidget->engine()) {
        QDeclarativeContext *ctxt = m_qmlWidget->engine()->rootContext();
        if (ctxt) {
            ctxt->setContextProperty("myModel", m_runnerModel);
        }
        QDeclarativeItem *item = qobject_cast<QDeclarativeItem *>(m_qmlWidget->rootObject());
        if (item) {
            connect(item, SIGNAL(clicked()), this, SLOT(itemActivated()));
        }
    }
    Plasma::Corona *c = corona();
    if (c) {
        connect(c, SIGNAL(screenOwnerChanged(int, int, Plasma::Containment *)), this, SLOT(updateActivity(int, int, Plasma::Containment *)));
    }
}

void MobileLauncher::updateActivity(int wasScreen, int isScreen, Plasma::Containment *containment)
{
    Q_UNUSED(wasScreen)
    Q_UNUSED(wasScreen)

    m_runnerModel->setQuery(containment->activity());
}

void MobileLauncher::itemActivated()
{
    QDeclarativeItem *item = qobject_cast<QDeclarativeItem *>(m_qmlWidget->rootObject());
    if (item) {
        item = item->property("currentItem").value<QDeclarativeItem *>();
        if (item) {
            QString url = item->property("urlText").toString();
            kWarning() << "URL clicked" << url;

            KRunnerItemHandler::openUrl(url);
        }
    }
}

K_EXPORT_PLASMA_APPLET(mobilelauncher, MobileLauncher)

#include "mobilelauncher.moc"
