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
        : QStandardItemModel(parent),
          m_initialized(false)
{
    QHash<int, QByteArray> newRoleNames = roleNames();
    newRoleNames[CommonModel::Description] = "description";
    newRoleNames[CommonModel::Url] = "url";
    newRoleNames[CommonModel::Weight] = "weight";
    newRoleNames[CommonModel::ActionTypeRole] = "action";

    setRoleNames(newRoleNames);

    m_allCategoriesModel = new QStandardItemModel(this);
    //m_allCategoriesModel->setRoleNames(newRoleNames);

    setShownCategories(QStringList());
   // setSortRole(CommonModel::Weight);
}

AppModel::~AppModel()
{
}

//TODO: list of categories
void AppModel::setShownCategories(const QStringList &categories)
{
    if (m_initialized && m_shownCategories == categories) {
        return;
    }
    m_shownCategories = categories;
    m_initialized = true;

    QString query = "exist Exec";
    foreach (const QString &category, categories) {
        query += QString(" and (exist Categories and '%1' ~subin Categories)").arg(category);
    }
    KService::List services = KServiceTypeTrader::self()->query("Application", query);


    QHash<QString, int> categoryWeights;

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

        if (categories.isEmpty()) {
            foreach (const QString &category, service->categories()) {
                categoryWeights[category] = categoryWeights[category]+1;
            }
        }
    }

    if (categories.isEmpty()) {
        m_allCategoriesModel->clear();
        QHash<QString, int>::const_iterator i = categoryWeights.constBegin();
        while (i != categoryWeights.constEnd()) {
            QStandardItem *catItem = new QStandardItem;
            catItem->setText(i.key());
            catItem->setData(i.value(), CommonModel::Weight);
            m_allCategoriesModel->appendRow(catItem);
            ++i;
        }
    }
}

QStringList AppModel::shownCategories() const
{
    return m_shownCategories;
}

#include "appmodel.moc"
