/* Copyright (C) 2012 basysKom GmbH <info@basyskom.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */

#ifndef LOCALESETTINGS_H
#define LOCALESETTINGS_H

#include <QObject>

class LocaleSettingsPrivate;

/**
 * @class A class to manage time and date related settings. This class serves two functions:
 * - Provide a plugin implementation
 * - Provide a settings module
 * This is done from one class in order to simplify the code. You can export any QObject-based
 * class through qmlRegisterType(), however.
 */
class LocaleSettings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QObject* languagesModel READ languagesModel WRITE setLanguagesModel NOTIFY languagesModelChanged)

    public:
        /**
         * @name Settings Module Constructor
         *
         * @arg parent The parent object
         * @arg list Arguments, currently unused
         */
        LocaleSettings();
        virtual ~LocaleSettings();

        QString language();
        QObject* languagesModel();

    public Q_SLOTS:
        void setLanguage(const QString &language);
        void setLanguagesModel(QObject* languages);

    Q_SIGNALS:
        void languageChanged();
        void languagesModelChanged();

    private:
        LocaleSettingsPrivate* d;
};

#endif // LOCALESETTINGS_H
