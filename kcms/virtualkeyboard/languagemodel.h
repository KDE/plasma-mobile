/*
    SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#ifndef LANGUAGEMODEL_H
#define LANGUAGEMODEL_H

#include "gsettingsitem.h"
#include <QAbstractListModel>

struct Data {
    QString langCode;
    QString langName;
    bool enabled;
};

class LanguageModel : public QAbstractListModel
{
    enum ModelRoles {
        NameRole = Qt::DisplayRole,
        EnabledRole = Qt::UserRole + 1,
        LanguageIdRole,
    };

    Q_OBJECT
public:
    LanguageModel(QObject *parent, GSettingsItem *gsettingsItem);

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    QHash<int, QByteArray> roleNames() const override;

private:
    QVector<Data> m_languages;
    void loadPlugins();
    GSettingsItem *m_gsettings;
};

#endif
