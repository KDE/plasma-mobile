/*
    SPDX-FileCopyrightText: 2018 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: LGPL-2.1-only

*/

#include <QDebug>
#include <QString>

#include "gsettingsitem.h"

QVariant GSettingsItem::value(const QString &key) const
{
    if (!m_settings) {
        return QVariant();
    }

    GVariant *gvalue = g_settings_get_value(m_settings, key.toLatin1().data());

    QVariant toReturn;

    switch (g_variant_classify(gvalue)) {
    case G_VARIANT_CLASS_BOOLEAN:
        toReturn = QVariant(static_cast<bool>(g_variant_get_boolean(gvalue)));
        break;
    case G_VARIANT_CLASS_STRING:
        toReturn = QVariant(QString::fromUtf8(g_variant_get_string(gvalue, nullptr)));
        break;
    case G_VARIANT_CLASS_ARRAY:
        if (g_variant_is_of_type(gvalue, G_VARIANT_TYPE_STRING_ARRAY)) {
            GVariantIter iter;
            QStringList list;
            const gchar *str;
            g_variant_iter_init(&iter, gvalue);
            while (g_variant_iter_next(&iter, "&s", &str)) {
                list.append(str);
            }
            return QVariant(list);
        }
        break;
    default:
        qWarning() << "Unhandled variant type in value()";
    }

    g_variant_unref(gvalue);

    return toReturn;
}

void GSettingsItem::set(const QString &key, const QVariant &val)
{
    if (!m_settings) {
        return;
    }

    // It might be hard to detect the right GVariant type from
    // complex QVariant types such as string lists or more detailed
    // types such as integers (GVariant has different sizes),
    // therefore we get the current value for the key and convert
    // to QVariant using the GVariant type
    GVariant *oldValue = g_settings_get_value(m_settings, key.toLatin1().data());
    GVariant *newValue = nullptr;

    switch (g_variant_type_peek_string(g_variant_get_type(oldValue))[0]) {
    case G_VARIANT_CLASS_BOOLEAN:
        newValue = g_variant_new_boolean(val.toBool());
        break;
    case G_VARIANT_CLASS_STRING:
        newValue = g_variant_new_string(val.toString().toUtf8().constData());
        break;
    case G_VARIANT_CLASS_ARRAY:
        if (g_variant_is_of_type(oldValue, G_VARIANT_TYPE_STRING_ARRAY)) {
            const QStringList list = val.toStringList();
            GVariantBuilder builder;
            g_variant_builder_init(&builder, G_VARIANT_TYPE_STRING_ARRAY);
            for (const QString &string : list) {
                g_variant_builder_add(&builder, "s", string.toUtf8().constData());
            }

            newValue = g_variant_builder_end(&builder);
            break;
        }
        qWarning() << "Unhandled variant array type in set()";
        break;
    default:
        qWarning() << "Unhandled variant type in set()";
    }

    if (newValue) {
        g_settings_set_value(m_settings, key.toLatin1().data(), newValue);
    }

    g_variant_unref(oldValue);
}

bool GSettingsItem::isValid() const
{
    return m_settings;
}

GSettingsItem::GSettingsItem(const QString &key, QObject *parent)
    : QObject(parent)
{
    const char schemaId[] = "org.maliit.keyboard.maliit";

    // g_settings_new_with_path asserts if the schema doesn't exist, check this manually to avoid an abort.
    auto *defaultSource = g_settings_schema_source_get_default();
    if (!defaultSource) {
        qWarning() << "No GSettings schemas are installed on the system";
        return;
    }

    auto *schema = g_settings_schema_source_lookup(defaultSource, schemaId, true /*recursive*/);
    if (!schema) {
        qWarning() << "Settings schema" << schemaId << "is not installed";
        return;
    }

    m_settings = g_settings_new_with_path(schemaId, key.toLatin1().data());
    g_settings_schema_unref(schema);

    g_signal_connect(m_settings, "changed", G_CALLBACK(GSettingsItem::settingChanged), this);
}

GSettingsItem::~GSettingsItem()
{
    g_settings_sync();
    if (m_settings)
        g_object_unref(m_settings);
}
