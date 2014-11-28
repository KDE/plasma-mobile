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

#include <QStandardPaths>

#include <QDebug>
#include <Plasma/Package>
#include <Plasma/PackageStructure>
#include <Plasma/PluginLoader>
#include <KLocalizedString>

Package::Package(QObject *parent)
    : QObject(parent)
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

    m_package = Plasma::PluginLoader::self()->loadPackage(QStringLiteral("Plasma/Generic"));
    m_package.setPath(name);
    QString domain = QStringLiteral("plasma_package_") + name;
    KLocalizedString::setApplicationDomain(domain.toLocal8Bit().data());

    emit nameChanged(name);
    emit visibleNameChanged();
}

QString Package::visibleName() const
{
    if (!m_package.isValid()) {
        return QString();
    }

    return m_package.metadata().name();
}

QString Package::filePath(const QString &fileType, const QString &fileName) const
{
    if (!m_package.isValid()) {
        return QString();
    }

    if (fileName.isEmpty()) {
        return m_package.filePath(fileType.toLatin1());
    } else {
        return m_package.filePath(fileType.toLatin1(), fileName);
    }
}

QString Package::filePath(const QString &fileType) const
{
    if (!m_package.isValid()) {
        return QString();
    }

    return m_package.filePath(fileType.toLatin1());
}

#include "package.moc"

