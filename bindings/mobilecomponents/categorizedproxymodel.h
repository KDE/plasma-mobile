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

#ifndef CATEGORIZEDPROXYMODEL_H
#define CATEGORIZEDPROXYMODEL_H

#include <QProxyModel>
#include <QStringList>

class QTimer;

class CategorizedProxyModel : public QProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QObject *sourceModel READ sourceModel WRITE setSourceModel)
    

public:
    CategorizedProxyModel(QObject *parent = 0);
    ~CategorizedProxyModel();

    void setSourceModel(QObject *source);
    QObject *sourceModel() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    void setCategoryRole(const QString &role);
    QString categoryRole() const;

Q_SIGNALS:
    void modelReset();

private Q_SLOTS:
    void fillCategories();
    void slotInsertRows(const QModelIndex& sourceIndex, int begin, int end);
    void slotRemoveRows(const QModelIndex& sourceIndex, int begin, int end);

private:
    QString m_categoryRoleString;
    int m_categoryRoleInt;
    //FIXME: QVector?
    QStringList m_categories;
    QHash<QString, int> m_categoryHash;
    QTimer *m_fillCategoriesTimer;
};

#endif
