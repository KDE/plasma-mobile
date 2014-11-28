/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef SETTINGSMODULE_H
#define SETTINGSMODULE_H

#include <QObject>
#include <QVariant>

class SettingsModulePrivate;
/**
 * @class SettingsModule A class to manage settings from declarative UIs.
 * This class serves two functions:
 * - Provide a plugin implementation
 * - Provide a settings module
 * This is done from one class in order to simplify the code. You can export
 * any QObject-based class through qmlRegisterType(), however.
 */
class SettingsModule : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString module READ module WRITE setModule NOTIFY moduleChanged)
    Q_PROPERTY(QString iconName READ iconName WRITE setIconName NOTIFY iconNameChanged)
    Q_PROPERTY(QString category READ category WRITE setCategory NOTIFY categoryChanged)

    public:
        explicit SettingsModule(QObject *parent = 0, const QVariantList &v = QVariantList());
        virtual ~SettingsModule();

        QString name() const;
        QString description() const;
        QString iconName() const;
        QString module() const;
        QString category() const;

    public Q_SLOTS:
        void setName(const QString &name);
        void setDescription(const QString &description);
        void setModule(const QString &module);
        void setIconName(const QString &iconName);
        void setCategory(const QString &category);

    Q_SIGNALS:
        void nameChanged();
        void descriptionChanged();
        void moduleChanged();
        void iconNameChanged();
        void categoryChanged();

    private:
        SettingsModulePrivate *d;
};

#endif
