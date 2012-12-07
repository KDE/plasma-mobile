/***************************************************************************
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public License     *
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
    Q_PROPERTY(QString visibleName READ visibleName NOTIFY visibleNameChanged)
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString rootPath READ rootPath WRITE setRootPath NOTIFY rootPathChanged)

public:
    Package(QObject *parent = 0);
    ~Package();

    QString name() const;
    void setName(const QString &name);

    QString type() const;
    void setType(const QString &type);

    QString rootPath() const;
    void setRootPath(const QString &type);

    Q_INVOKABLE QString filePath(const QString &fileType, const QString &filename) const;
    Q_INVOKABLE QString filePath(const QString &fileType) const;

    QString visibleName() const;

Q_SIGNALS:
    void nameChanged(const QString &);
    void visibleNameChanged();
    void typeChanged();
    void rootPathChanged();

private:
    void loadPackage();

    QString m_name;
    QString m_type;
    QString m_rootPath;
    Plasma::Package *m_package;
};

#endif
