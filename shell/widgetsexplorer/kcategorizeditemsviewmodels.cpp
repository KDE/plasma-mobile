/*
 *   Copyright (C) 2007 Ivan Cukic <ivan.cukic+kde@gmail.com>
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

#include "kcategorizeditemsviewmodels_p.h"
#include <klocale.h>

#define COLUMN_COUNT 4

namespace KCategorizedItemsViewModels {

// AbstractItem

QString AbstractItem::name() const
{
    return text();
}

QString AbstractItem::id() const
{
    QString plugin = data().toMap()["pluginName"].toString();

    if (plugin.isEmpty()) {
        return name();
    }

    return plugin;
}

QString AbstractItem::description() const
{
    return "";
}

bool AbstractItem::isFavorite() const
{
    return passesFiltering(Filter("favorite", true));
}

int AbstractItem::running() const
{
    return 0;
}

bool AbstractItem::matches(const QString &pattern) const
{
    return
        name().contains(pattern, Qt::CaseInsensitive) ||
        description().contains(pattern, Qt::CaseInsensitive);
}

// DefaultFilterModel

DefaultFilterModel::DefaultFilterModel(QObject *parent) :
    QStandardItemModel(0, 1, parent)
{
    setHeaderData(1, Qt::Horizontal, i18n("Filters"));
}

void DefaultFilterModel::addFilter(const QString &caption, const Filter &filter, const KIcon &icon)
{
    QList<QStandardItem *> newRow;
    QStandardItem *item = new QStandardItem(caption);
    item->setData(qVariantFromValue<Filter>(filter));
    if (!icon.isNull()) {
        item->setIcon(icon);
    }

    newRow << item;
    appendRow(newRow);
}

void DefaultFilterModel::addSeparator(const QString &caption)
{
    QList<QStandardItem *> newRow;
    QStandardItem *item = new QStandardItem(caption);
    item->setEnabled(false);

    newRow << item;
    appendRow(newRow);
}

// DefaultItemFilterProxyModel

DefaultItemFilterProxyModel::DefaultItemFilterProxyModel(QObject *parent) :
    QSortFilterProxyModel(parent), m_innerModel(parent)
{
}

void DefaultItemFilterProxyModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    QStandardItemModel *model = qobject_cast<QStandardItemModel*>(sourceModel);

    if (!model) {
        kWarning() << "Expecting a QStandardItemModel!";
        return;
    }

    m_innerModel.setSourceModel(model);
    QSortFilterProxyModel::setSourceModel(&m_innerModel);
}

QStandardItemModel *DefaultItemFilterProxyModel::sourceModel() const
{
    return m_innerModel.sourceModel();
}

int DefaultItemFilterProxyModel::columnCount(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return COLUMN_COUNT;
}

QVariant DefaultItemFilterProxyModel::data(const QModelIndex &index, int role) const
{
    return m_innerModel.data(index, (index.column() == 1), role);
}

bool DefaultItemFilterProxyModel::filterAcceptsRow(int sourceRow,
        const QModelIndex &sourceParent) const
{
    QStandardItemModel *model = (QStandardItemModel *) sourceModel();

    QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);

    AbstractItem *item = (AbstractItem *) model->itemFromIndex(index);
    //kDebug() << "ITEM " << (item ? "IS NOT " : "IS") << " NULL\n";

    return item &&
        (m_filter.first.isEmpty() || item->passesFiltering(m_filter)) &&
        (m_searchPattern.isEmpty() || item->matches(m_searchPattern));
}

bool DefaultItemFilterProxyModel::lessThan(const QModelIndex &left,
        const QModelIndex &right) const
{
    return
        sourceModel()->data(left).toString().localeAwareCompare(
            sourceModel()->data(right).toString()) < 0;
}

void DefaultItemFilterProxyModel::setSearch(const QString &pattern)
{
    m_searchPattern = pattern;
    invalidateFilter();
    emit searchTermChanged(pattern);
}

void DefaultItemFilterProxyModel::setFilter(const Filter &filter)
{
    m_filter = filter;
    invalidateFilter();
    emit filterChanged();
}

// DefaultItemFilterProxyModel::InnerProxyModel

DefaultItemFilterProxyModel::InnerProxyModel::InnerProxyModel(QObject *parent) :
    QAbstractItemModel(parent), m_sourceModel(NULL)
{
}

Qt::ItemFlags DefaultItemFilterProxyModel::InnerProxyModel::flags(const QModelIndex &index) const
{
    if (!m_sourceModel) {
        return 0;
    }
    return m_sourceModel->flags(index);
}

QVariant DefaultItemFilterProxyModel::InnerProxyModel::data(
    const QModelIndex &index, bool favoriteColumn, int role) const
{
    Q_UNUSED(favoriteColumn);
    return data(index, role);
}

QVariant DefaultItemFilterProxyModel::InnerProxyModel::data(
        const QModelIndex &index, int role) const
{
    if (!m_sourceModel) {
        return QVariant();
    }
    return m_sourceModel->data(index, role);
}

QVariant DefaultItemFilterProxyModel::InnerProxyModel::headerData(
    int section, Qt::Orientation orientation, int role) const
{
    Q_UNUSED(orientation);
    Q_UNUSED(role);
    return QVariant(section);
}

int DefaultItemFilterProxyModel::InnerProxyModel::rowCount(const QModelIndex &parent) const
{
    if (!m_sourceModel) {
        return 0;
    }
    return m_sourceModel->rowCount(parent);
}

bool DefaultItemFilterProxyModel::InnerProxyModel::setData(
    const QModelIndex &index, const QVariant &value, int role)
{
    if (!m_sourceModel) {
        return false;
    }
    return m_sourceModel->setData(index, value, role);
}

bool DefaultItemFilterProxyModel::InnerProxyModel::setHeaderData(
    int section, Qt::Orientation orientation, const QVariant &value, int role)
{
    Q_UNUSED(section);
    Q_UNUSED(value);
    Q_UNUSED(orientation);
    Q_UNUSED(role);
    return false;
}

QModelIndex DefaultItemFilterProxyModel::InnerProxyModel::index(
    int row, int column, const QModelIndex &parent) const
{
    Q_UNUSED(column);
    if (!m_sourceModel) {
        return QModelIndex();
    }
    return m_sourceModel->index(row, 0, parent);
}

QModelIndex DefaultItemFilterProxyModel::InnerProxyModel::parent(const QModelIndex &index) const
{
    if (!m_sourceModel) {
        return QModelIndex();
    }
    return m_sourceModel->parent(index);
}

QMimeData *DefaultItemFilterProxyModel::InnerProxyModel::mimeData(
    const QModelIndexList &indexes) const
{
    if (!m_sourceModel) {
        return NULL;
    }
    return m_sourceModel->mimeData(indexes);
}

int DefaultItemFilterProxyModel::InnerProxyModel::columnCount(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return COLUMN_COUNT;
}

void DefaultItemFilterProxyModel::InnerProxyModel::setSourceModel(QStandardItemModel *sourceModel)
{
    m_sourceModel = sourceModel;
}

QStandardItemModel *DefaultItemFilterProxyModel::InnerProxyModel::sourceModel() const
{
    return m_sourceModel;
}

}
