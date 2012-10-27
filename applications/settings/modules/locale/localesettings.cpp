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

#include "localesettings.h"
#include "languagesmodel.h"

#include <KDebug>
#include <KConfigGroup>
#include <KGlobal>
#include <KGlobalSettings>
#include <KLocale>

class LocaleSettingsPrivate {
public:
    LocaleSettings *q;
    QString language;
    QObject *languagesModel;
    QString languageFilter;

    KSharedConfigPtr globalConfig;
    KConfigGroup localeConfigGroup;

    void initLanguages();
};

LocaleSettings::LocaleSettings()
{
    d = new LocaleSettingsPrivate;
    d->q = this;
    d->languagesModel = 0;

    d->initLanguages();

    kDebug() << "LocaleSettings module loaded.";
}

LocaleSettings::~LocaleSettings()
{
    kDebug() << "========================== LocaleSettings destroyed";
    delete d;
}

void LocaleSettingsPrivate::initLanguages()
{
    globalConfig = KSharedConfig::openConfig("kdeglobals", KConfig::SimpleConfig);
    localeConfigGroup = KConfigGroup(globalConfig, "Locale");

    QStandardItemModel * _languagesModel = new LanguagesModel(q);

    //kDebug() << "Language list" << KGlobal::locale()->languageList();

    //foreach (const QString &langCode, KGlobal::locale()->allLanguagesList()) {
    foreach (const QString &langCode, KGlobal::locale()->installedLanguages()) {
        QStandardItem *item = new QStandardItem(KGlobal::locale()->languageCodeToName(langCode));
        item->setData(langCode, Qt::UserRole+1);
        _languagesModel->appendRow(item);
    }
    languagesModel = _languagesModel;
    language = localeConfigGroup.readEntry("Language", QString()).split(':').first();
    language = KGlobal::locale()->languageCodeToName(language);
}

QString LocaleSettings::language()
{
    return d->language;
}

void LocaleSettings::setLanguage(const QString &language)
{
    // save new setting to $KDEHOME/.kde/share/config/kdeglobals.
    d->localeConfigGroup.writeEntry("Language", language);
    d->globalConfig->sync();

    // set language for this program.
    KGlobal::locale()->setLanguage(QStringList() << language);
    //KGlobal::locale()->reparseConfiguration();

    // cache the new language setting.
    //d->language = d->localeConfigGroup.readEntry("Language", QString()).split(':').first();
    //d->language = KGlobal::locale()->languageCodeToName(d->language);
    d->language = KGlobal::locale()->languageCodeToName(language);
    //kDebug() << "new language" << d->language;

    // signal other KDE programs that locale settings has changed.
    KGlobalSettings::self()->emitChange(KGlobalSettings::SettingsChanged, KGlobalSettings::SETTINGS_LOCALE);

    // signal the QML part of active-settings that the language has changed.
    emit languageChanged();
}

QObject* LocaleSettings::languagesModel()
{
    return d->languagesModel;
}

void LocaleSettings::setLanguagesModel(QObject* languagesModel)
{
    if ( d->languagesModel != languagesModel) {
        d->languagesModel = languagesModel;
        emit languagesModelChanged();
    }
}

#include "localesettings.moc"
