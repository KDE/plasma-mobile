// SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>
// SPDX-FileCopyrightText: 2014 Martin Klapetek <mklapetek@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "timezonemodel.h"

#include <KLocalizedString>

#include <QDebug>
#include <QStringMatcher>
#include <QTimeZone>

TimeZoneFilterProxy::TimeZoneFilterProxy(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    m_stringMatcher.setCaseSensitivity(Qt::CaseInsensitive);
}

bool TimeZoneFilterProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (!sourceModel() || m_filterString.isEmpty()) {
        return true;
    }
    const QString id = sourceModel()->index(source_row, 0, source_parent).data(TimeZoneModel::TimeZoneIdRole).toString();
    return m_stringMatcher.indexIn(id) != -1;
}

void TimeZoneFilterProxy::setFilterString(const QString &filterString)
{
    m_filterString = filterString;
    m_stringMatcher.setPattern(filterString);
    Q_EMIT filterStringChanged();
    invalidateFilter();
}

TimeZoneModel::TimeZoneModel(QObject *parent)
    : QAbstractListModel(parent)
{
    update();
}

TimeZoneModel::~TimeZoneModel()
{
}

int TimeZoneModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_data.count();
}

QVariant TimeZoneModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {
        switch (role) {
        case TimeZoneIdRole:
            return m_data[index.row()];
        }
    }

    return QVariant();
}

void TimeZoneModel::update()
{
    beginResetModel();
    m_data.clear();

    QTimeZone localZone = QTimeZone(QTimeZone::systemTimeZoneId());
    m_data.append(localZone.id());

    QStringList cities;
    QHash<QString, QTimeZone> zonesByCity;

    const QList<QByteArray> systemTimeZones = QTimeZone::availableTimeZoneIds();

    for (QByteArray arr : systemTimeZones) {
        m_data.append(arr);
    }

    endResetModel();
}

QHash<int, QByteArray> TimeZoneModel::roleNames() const
{
    return {{TimeZoneIdRole, "timeZoneId"}};
}
