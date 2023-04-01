// SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>
// SPDX-FileCopyrightText: 2014 Martin Klapetek <mklapetek@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QTimeZone>

class TimeZoneFilterProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterString WRITE setFilterString MEMBER m_filterString NOTIFY filterStringChanged)

public:
    explicit TimeZoneFilterProxy(QObject *parent = nullptr);
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

    void setFilterString(const QString &filterString);

Q_SIGNALS:
    void filterStringChanged();

private:
    QString m_filterString;
    QStringMatcher m_stringMatcher;
};

class TimeZoneModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit TimeZoneModel(QObject *parent = nullptr);
    ~TimeZoneModel() override;

    enum Roles { TimeZoneIdRole = Qt::UserRole + 1 };

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    void update();

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<QString> m_data;
};
