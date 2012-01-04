/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
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

#ifndef KDECLARATIVEVIEW_H
#define KDECLARATIVEVIEW_H

#include <QDeclarativeView>


namespace Plasma
{
    class Package;
}

class KDeclarativeViewPrivate;

class KDeclarativeView : public QDeclarativeView
{
    Q_OBJECT

public:
    KDeclarativeView(QWidget *parent = 0);
    ~KDeclarativeView();

    void setUseGL(const bool on);
    bool useGL() const;

    void setPackageName(const QString &packageName);
    QString packageName() const;

    void setPackage(Plasma::Package *package);
    Plasma::Package *package() const;

private:
    KDeclarativeViewPrivate *const d;
};

#endif //KDECLARATIVEVIEW_H
