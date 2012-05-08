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

#include "localesettingsplugin.h"
#include "localesettings.h"

#include <QDeclarativeComponent>

#include <KDebug>
#include <KPluginFactory>

K_PLUGIN_FACTORY(LocaleSettingsFactory, registerPlugin<LocaleSettingsPlugin>();)
K_EXPORT_PLUGIN(LocaleSettingsFactory("active_settings_locale"))

LocaleSettingsPlugin::LocaleSettingsPlugin(QObject *parent, const QVariantList &list)
    : QObject(parent)
{
    Q_UNUSED(list)

    kDebug() << "LocaleSettingsPlugin created:)";
    qmlRegisterType<LocaleSettings>();
    qmlRegisterType<LocaleSettings>("org.kde.active.settings", 0, 1, "LocaleSettings");
}

LocaleSettingsPlugin::~LocaleSettingsPlugin()
{
}

#include "localesettingsplugin.moc"
