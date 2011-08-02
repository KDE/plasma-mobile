/***************************************************************************
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
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
#ifndef PACKAGE_H
#define PACKAGE_H

#include <QDeclarativeItem>
#include <QUrl>

namespace Plasma {
    class Package;
}


class QTimer;
class QGraphicsView;

class Package : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

public:
    Package(QObject *parent = 0);
    ~Package();

    QString name() const;
    void setName(const QString &name);

    Q_INVOKABLE QString filePath(const QString &fileType, const QString &filename) const;
    Q_INVOKABLE QString filePath(const QString &fileType) const;

Q_SIGNALS:
    void nameChanged(const QString &);

private:
    QString m_name;
    Plasma::Package *m_package;
};

#endif
