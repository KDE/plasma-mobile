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

#include "package.h"

#include <KDebug>
#include <KGlobalSettings>
#include <Plasma/Package>
#include <Plasma/PackageStructure>


#define DEFAULT_PACKAGE_TYPE "Plasma/Generic"

Package::Package(QObject *parent)
    : QObject(parent),
      m_type(DEFAULT_PACKAGE_TYPE),
      m_package(0)
{
}

Package::~Package()
{
}


QString Package::name() const
{
    return m_name;
}

void Package::setName(const QString &name)
{
    if (m_name == name) {
        return;
    }

    m_name = name;
    KGlobal::locale()->insertCatalog("plasma_package_" + m_name);
    loadPackage();
    emit nameChanged(name);
}

void Package::loadPackage()
{
    if (m_name.isEmpty()) {
        return;
    }

    delete m_package;
    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load(m_type);
    m_package = new Plasma::Package(m_rootPath, m_name, structure);
    emit visibleNameChanged();
}

QString Package::visibleName() const
{
    if (!m_package) {
        return QString();
    }

    return m_package->metadata().name();
}

QString Package::type() const
{
    return m_type;
}

void Package::setType(const QString &type)
{
    if (type == m_type) {
        return;
    }

    if (type.isEmpty()) {
        if (m_type == DEFAULT_PACKAGE_TYPE) {
            return;
        }

        m_type = DEFAULT_PACKAGE_TYPE;
    } else {
        m_type = type;
    }

    loadPackage();
    emit typeChanged();
}


QString Package::rootPath() const
{
    return m_rootPath;
}

void Package::setRootPath(const QString &rootPath)
{
    if (rootPath == m_rootPath) {
        return;
    }

    m_rootPath = rootPath;
    loadPackage();
    emit rootPathChanged();
}

QString Package::filePath(const QString &fileType, const QString &fileName) const
{
    if (!m_package) {
        return QString();
    }

    if (fileName.isEmpty()) {
        return m_package->filePath(fileType.toLatin1());
    } else {
        return m_package->filePath(fileType.toLatin1(), fileName);
    }
}

QString Package::filePath(const QString &fileType) const
{
    if (!m_package) {
        return QString();
    }

    return m_package->filePath(fileType.toLatin1());
}

#include "package.moc"

