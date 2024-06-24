// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "folioapplication.h"
#include "folioapplicationfolder.h"
#include "foliodelegate.h"
#include "homescreen.h"

#include <QAbstractListModel>
#include <QJsonArray>
#include <QList>

#include <Plasma/Applet>

class HomeScreen;
class FolioPageDelegate;

class PageModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        DelegateRole = Qt::UserRole + 1,
        XPositionRole,
        YPositionRole,
        ShownRole,
    };

    PageModel(QList<FolioPageDelegate *> delegates = QList<FolioPageDelegate *>{}, QObject *parent = nullptr, HomeScreen *m_homeScreen = nullptr);
    ~PageModel();

    static PageModel *fromJson(QJsonArray &arr, QObject *parent, HomeScreen *homeScreen);

    QJsonArray toJson() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void removeDelegate(int row, int col);
    Q_INVOKABLE void removeDelegate(int index);
    Q_INVOKABLE bool canAddDelegate(int row, int column, FolioDelegate *delegate);
    bool addDelegate(FolioPageDelegate *delegate);
    FolioPageDelegate *getDelegate(int row, int col);

    Q_INVOKABLE void moveAndResizeWidgetDelegate(FolioPageDelegate *delegate, int newRow, int newColumn, int newGridWidth, int newGridHeight);

    bool isPageEmpty();

public Q_SLOTS:
    void save();

Q_SIGNALS:
    void saveRequested();

private:
    void connectSaveRequests(FolioDelegate *delegate);

    HomeScreen *m_homeScreen{nullptr};
    QList<FolioPageDelegate *> m_delegates;
};
