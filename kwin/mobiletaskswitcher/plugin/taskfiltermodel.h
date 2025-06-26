// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "taskmodel.h"

#include <window.h>

#include <QAbstractListModel>
#include <QHash>
#include <QQmlEngine>
#include <QSortFilterProxyModel>
#include <QVariant>

namespace KWin
{

class TaskFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(KWin::TaskModel *windowModel READ windowModel WRITE setWindowModel NOTIFY windowModelChanged)
    Q_PROPERTY(QString screenName READ screenName WRITE setScreenName NOTIFY screenNameChanged)
    QML_ELEMENT

public:
    explicit TaskFilterModel(QObject *parent = nullptr);

    TaskModel *windowModel() const;
    void setWindowModel(KWin::TaskModel *taskModel);

    QString screenName() const;
    void setScreenName(const QString &screenName);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

Q_SIGNALS:
    void screenNameChanged();
    void windowModelChanged();

private:
    TaskModel *m_taskModel = nullptr;
    QPointer<Output> m_output;
};

} // namespace KWin
