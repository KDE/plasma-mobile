/*
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

#include "categorizedproxymodel.h"

#include <QTimer>

#include <KDebug>

CategorizedProxyModel::CategorizedProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent),
      m_categoryRoleInt(Qt::UserRole)
{
    m_fillCategoriesTimer = new QTimer(this);
    m_fillCategoriesTimer->setSingleShot(true);
    connect(m_fillCategoriesTimer, SIGNAL(timeout()), this, SLOT(fillCategories()));
}

CategorizedProxyModel::~CategorizedProxyModel()
{
}

void CategorizedProxyModel::setCategoryRole(const QString &role)
{
    if (role == m_categoryRoleString) {
        return;
    }

    m_categoryRoleString = role;
    m_fillCategoriesTimer->start(0);
}

QString CategorizedProxyModel::categoryRole() const
{
    return m_categoryRoleString;
}

void CategorizedProxyModel::setCurrentCategory(const QString &category)
{
    if (m_currentCategory == category) {
        return;
    }

    m_currentCategory = category;
    emit modelReset();
}

QString CategorizedProxyModel::currentCategory() const
{
    return m_currentCategory;
}

QStringList CategorizedProxyModel::categories() const
{
    return m_categories;
}

void CategorizedProxyModel::setModel(QObject *source)
{
    QAbstractItemModel *model = qobject_cast<QAbstractItemModel *>(source);
    if (!model) {
        return;
    }

    m_fillCategoriesTimer->start(0);

    // TODO disconnect old model
    connect(model, SIGNAL(rowsInserted(QModelIndex, int, int)),
            SLOT(slotInsertRows(QModelIndex, int, int)), Qt::QueuedConnection);
    connect(model, SIGNAL(rowsAboutToBeRemoved(QModelIndex, int, int)),
            SLOT(slotRemoveRows(QModelIndex, int, int)));
    connect(model, SIGNAL(modelReset()), this, SLOT(fillCategories()), Qt::QueuedConnection);

    setRoleNames(model->roleNames());
    setSourceModel(model);
}

QObject *CategorizedProxyModel::model() const
{
    return sourceModel();
}


int CategorizedProxyModel::rowCount(const QModelIndex &parent) const
{
    //if it's a root it's a category
    if (parent.parent() != QModelIndex()) {
        return 0;
    }

    return m_categoryHash.value(m_currentCategory);
}

QVariant CategorizedProxyModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0) {
        return QVariant();
    }

    int offset = 0;
    foreach (QString cat, m_categories) {
        if (cat == m_currentCategory) {
            break;
        }
        offset += m_categoryHash.value(cat);
    }

    return QSortFilterProxyModel::data(CategorizedProxyModel::index(index.row()+offset, index.column()), role);
}



void CategorizedProxyModel::fillCategories()
{
    QAbstractItemModel *model = QSortFilterProxyModel::sourceModel();
    if (!model) {
        return;
    }
    setRoleNames(model->roleNames());

    QHash<int, QByteArray> names = model->roleNames();
    QHash<int, QByteArray>::const_iterator i;
    for (i = names.constBegin(); i != names.constEnd(); ++i) {
        if (i.value() == m_categoryRoleString) {
            m_categoryRoleInt = i.key();
        }
    }

    setSortRole(m_categoryRoleInt);
    sort(0);
    QHash <QString, int> categoryHash;
    QStringList categories;

    for (int i = 0; i <= model->rowCount(); i++) {
        QString category = model->data(model->index(i, 0), m_categoryRoleInt).toString();

        if (category.isEmpty()) {
            continue;
        }

        if (categoryHash.contains(category)) {
            ++categoryHash[category];
        } else {
            categoryHash[category] = 1;
            categories.append(category);
            qSort(categories.begin(), categories.end());
        }
    }

    if (categoryHash != m_categoryHash) {
        m_categoryHash = categoryHash;
        m_categories = categories;
        emit modelReset();
        emit categoriesChanged();
    }

}


void CategorizedProxyModel::slotInsertRows(const QModelIndex& sourceIndex, int begin, int end)
{
    QAbstractItemModel *model = QSortFilterProxyModel::sourceModel();
    if (!model) {
        return;
    }
    setRoleNames(model->roleNames());
    sort(0);

    bool changed = false;
    for (int i = begin; i <= end; i++) {
        QString category = model->data(model->index(i, 0), m_categoryRoleInt).toString();

        if (category.isEmpty()) {
            continue;
        }

        if (m_categoryHash.contains(category)) {
            ++m_categoryHash[category];
        } else {
            m_categoryHash[category] = 1;
            m_categories.append(category);
            qSort(m_categories.begin(), m_categories.end());
            changed = true;
        }
    }
    if (changed) {
        emit categoriesChanged();
    }
}


void CategorizedProxyModel::slotRemoveRows(const QModelIndex& sourceIndex, int begin, int end)
{
    QAbstractItemModel *model = QSortFilterProxyModel::sourceModel();
    if (!model) {
        return;
    }

    bool changed = false;
    for (int i = begin; i <= end; i++) {
        QString category = model->data(model->index(i, 0), m_categoryRoleInt).toString();

        if (m_categoryHash.contains(category)) {
            if (m_categoryHash.value(category) <= 1) {
                m_categoryHash.remove(category);
                m_categories.removeAll(category);
                changed = true;
            } else {
                --m_categoryHash[category];
            }
        }
    }
    if (changed) {
        emit categoriesChanged();
    }
}



#include "categorizedproxymodel.moc"
