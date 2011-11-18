/*
 *   Copyright 2010 by Marco Martin <mart@kde.org>
 *   Copyright 2011 by Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef CONFIGMODEL_H
#define CONFIGMODEL_H

#include <QAbstractItemModel>
#include <QVector>


namespace Plasma
{

class ConfigModelPrivate;


class ConfigModel : public QAbstractItemModel
{
    Q_OBJECT
    Q_PROPERTY(QString file READ file WRITE setFile NOTIFY fileChanged)
    Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)
    //Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    ConfigModel(QObject* parent=0);
    ~ConfigModel();

    int roleNameToId(const QString &name);

    //Reimplemented
    QVariant data(const QModelIndex &index, int role) const;
    //QVariant headerData(int section, Qt::Orientation orientation,
    //                    int role = Qt::DisplayRole) const;
    QModelIndex index(int row, int column,
                      const QModelIndex &parent = QModelIndex()) const;
    QModelIndex parent(const QModelIndex &child) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;

    QString file() const;
    void setFile(const QString &filename);
    QString group() const;
    void setGroup(const QString &groupname);

    Q_INVOKABLE QVariant readEntry(const QString &key);
    Q_INVOKABLE bool writeEntry(const QString &key, const QVariant &value);

Q_SIGNALS:
    void fileChanged();
    void groupChanged();

private:
    ConfigModelPrivate* d;

    bool readConfigFile();

private Q_SLOTS:
    void sync();
};

}

#endif
