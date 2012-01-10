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

    /**
     * Sets wether the application uses opengl
     * @arg bool on if true the declarative view will use opengl for its viewport()
     */
    void setUseGL(const bool on);
    /**
     * @returns true if the declarative view uses opengl
     */
    bool useGL() const;

    /**
     * Sets the package from where load the application QML UI
     * The package must be of the type "Generic package"
     * it must provide a qml file as "mainscript"
     * @arg QString packageName the plugin name of the package
     */
    void setPackageName(const QString &packageName);
    /**
     * @returns the plugin name of the package
     */
    QString packageName() const;

    /**
     * Sets the package used for the application QML UI.
     * You usually don't need to use this, rather use setPackageName
     * @see setPackageName
     */
    //FIXME: remove this function?
    void setPackage(Plasma::Package *package);
    /**
     * @returns the plugin name of the package that holds the application QML UI
     */
    Plasma::Package *package() const;

private:
    KDeclarativeViewPrivate *const d;
};

#endif //KDECLARATIVEVIEW_H
