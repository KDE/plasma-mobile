/*
    Copyright 2009 Ivan Cukic <ivan.cukic+kde@gmail.com>
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

// Own
#include "appmodel.h"
#include "models/commonmodel.h"

// Qt
#include <QList>
#include <QMimeData>
#include <QString>

// KDE
#include <KService>
#include <KServiceTypeTrader>
#include <KDebug>
#include <KIcon>



AppModel::AppModel(QObject *parent)
        : QStandardItemModel(parent)
{
    QHash<int, QByteArray> newRoleNames = roleNames();
    newRoleNames[CommonModel::Description] = "description";
    newRoleNames[CommonModel::Url] = "url";
    newRoleNames[CommonModel::Weight] = "weight";
    newRoleNames[CommonModel::ActionTypeRole] = "action";

    setRoleNames(newRoleNames);

   // setSortRole(CommonModel::Weight);
}

AppModel::~AppModel()
{
}

//TODO: list of categories
void AppModel::setCategory(const QString &category)
{
    m_category = category;

    QString query;
    if (category.isEmpty()) {
        query = "exist Exec";
    } else {
        query = QString("exist Exec and (exist Categories and '%1' ~subin Categories)").arg(category);
    }
    KService::List services = KServiceTypeTrader::self()->query("Application", query);

    foreach (const KService::Ptr &service, services) {
        if (service->noDisplay()) {
            continue;
        }

        QString description;
        if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
            description = service->genericName();
        } else if (!service->comment().isEmpty()) {
            description = service->comment();
        }

        appendRow(
        StandardItemFactory::createItem(
            KIcon(service->icon()),
            service->name(),
            description,
            service->storageId(),
            1,
            CommonModel::AddAction
            )
        );
    }
}

QString AppModel::category() const
{
    return m_category;
}

#include "appmodel.moc"
