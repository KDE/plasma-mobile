/*
    SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include <QDebug>
#include <QDirIterator>
#include <QPluginLoader>

#include "gsettingsitem.h"
#include "languagemodel.h"

LanguageModel::LanguageModel(QObject *parent, GSettingsItem *settings)
    : QAbstractListModel(parent)
    , m_gsettings(settings)
{
    beginResetModel();
    loadPlugins();
    endResetModel();
}

void LanguageModel::loadPlugins()
{
    const QStringList enabledLangs = m_gsettings->value("enabled-languages").toStringList();

    QStringList langPaths;
    QDirIterator it(QStringLiteral(MALIIT_KEYBOARD_LANGUAGES_DIR), {"*plugin.so"}, QDir::NoFilter, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        langPaths << it.next();
    }
    m_languages.clear();
    for (const auto &langPath : qAsConst(langPaths)) {
        QPluginLoader langPlugin(langPath);
        const auto &metadata = langPlugin.metaData().value("MetaData").toObject();
        Data lang;
        lang.langName = metadata.value("Language").toString();
        lang.langCode = metadata.value("LanguageId").toString();
        lang.enabled = enabledLangs.contains(lang.langCode);
        m_languages.append(lang);
    }
}

QVariant LanguageModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    if (index.row() >= m_languages.size()) {
        return QVariant();
    }

    const Data data = m_languages.at(index.row());
    switch (role) {
    case EnabledRole:
        return data.enabled;
    case NameRole:
        return data.langName;
    case LanguageIdRole:
        return data.langCode;
    }

    return QVariant();
}

bool LanguageModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid()) {
        return QAbstractListModel::setData(index, value, role);
    }

    if (role == EnabledRole) {
        Data &data = m_languages[index.row()];
        if (data.enabled != value.toBool()) {
            data.enabled = value.toBool();
        }
        Q_EMIT dataChanged(this->index(index.row(), 0), this->index(index.row(), 0));
    }

    QStringList enabledLangs;
    for (const auto &data : qAsConst(m_languages)) {
        if (data.enabled) {
            enabledLangs << data.langCode;
        }
    }
    m_gsettings->set("enabled-languages", enabledLangs);
    return QAbstractListModel::setData(index, value, role);
}

int LanguageModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_languages.size();
}

QHash<int, QByteArray> LanguageModel::roleNames() const
{
    return {
        {NameRole, "name"},
        {EnabledRole, "enabled"},
        {LanguageIdRole, "langId"},
    };
}
