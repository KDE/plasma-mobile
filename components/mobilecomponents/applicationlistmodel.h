/*
 *   Copyright (C) 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef APPLICATIONLISTMODEL_H
#define APPLICATIONLISTMODEL_H

// Qt
#include <QObject>
#include <QAbstractListModel>
#include <QList>

class QString;

struct ApplicationData {
    QString name;
    QString icon;
    QString storageId;
};

class ApplicationListModel : public QAbstractListModel {
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    ApplicationListModel(QObject *parent = 0);
    virtual ~ApplicationListModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const Q_DECL_OVERRIDE;

    int count() { return m_applicationList.count(); }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    enum Roles {
        ApplicationNameRole = Qt::UserRole + 1,
        ApplicationIconRole = Qt::UserRole + 2,
        ApplicationStorageIdRole = Qt::UserRole + 3
    };

    Q_INVOKABLE void runApplication(const QString &storageId);

Q_SIGNALS:
    void countChanged();

private:
    QList<ApplicationData> m_applicationList;
    void loadApplications();
};

#endif // APPLICATIONLISTMODEL_H
