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

#include "settingscomponent.h"


#include <QDeclarativeEngine>
#include <KDebug>
#include <Plasma/Package>

class SettingsComponentPrivate {

public:
//     QList<QObject*> items;
    QString module;
    QDeclarativeEngine *engine;
    Plasma::Package* package;
};


SettingsComponent::SettingsComponent(QDeclarativeEngine *engine, QObject *parent)
    : QDeclarativeComponent(engine, parent)
{
    d = new SettingsComponentPrivate;
    d->package = 0;
    d->engine = new QDeclarativeEngine;
    kDebug() << "Creating settings component";
}

SettingsComponent::~SettingsComponent()
{
}


QString SettingsComponent::module() const
{
    return d->module;
}

void SettingsComponent::loadModule(const QString &name)
{

    delete d->package;
    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    //structure->setPath(path);
    d->package = new Plasma::Package(QString(), name, structure);
    KGlobal::locale()->insertCatalog("plasma_package_" + name);
    const QUrl qmlFile = QUrl::fromLocalFile(d->package->filePath("mainscript"));
    kDebug() << "QML FILE: " << qmlFile;
    loadUrl(qmlFile);

}

void SettingsComponent::setModule(const QString &module)
{
    kDebug() << "setmo" << module;
    if (d->module != module) {
        d->module = module;
        loadModule(module);
        emit moduleChanged();
    }
}



#include "settingscomponent.moc"

