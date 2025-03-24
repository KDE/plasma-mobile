// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "enums.h"
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
class KeyboardNavigation;

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

    PageModel(QList<std::shared_ptr<FolioPageDelegate>> delegates = QList<std::shared_ptr<FolioPageDelegate>>{},
              QObject *parent = nullptr,
              HomeScreen *m_homeScreen = nullptr);
    ~PageModel();

    static PageModel *fromJson(QJsonArray &arr, QObject *parent, HomeScreen *homeScreen);

    QJsonArray toJson() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void removeDelegate(int row, int col);
    Q_INVOKABLE void removeDelegate(int index);
    Q_INVOKABLE bool canAddDelegate(int row, int column, FolioDelegate *delegate);
    bool addDelegate(std::shared_ptr<FolioPageDelegate> delegate);
    std::shared_ptr<FolioPageDelegate> getDelegate(int row, int col);
    std::shared_ptr<FolioPageDelegate> getDelegateFromFolder(std::shared_ptr<FolioApplicationFolder> folder) const;

    std::shared_ptr<FolioPageDelegate> getFirstDelegate() const;
    std::shared_ptr<FolioPageDelegate> getLastDelegate() const;

    std::shared_ptr<FolioDelegate> getNeighborDelegate(std::shared_ptr<FolioDelegate> delegate, Enums::Direction direction);

    Q_INVOKABLE void moveAndResizeWidgetDelegate(FolioPageDelegate *delegate, int newRow, int newColumn, int newGridWidth, int newGridHeight);

    bool isPageEmpty();

public Q_SLOTS:
    void save();

Q_SIGNALS:
    void saveRequested();

private:
    void connectSaveRequests(std::shared_ptr<FolioDelegate> delegate);

    HomeScreen *m_homeScreen{nullptr};
    QList<std::shared_ptr<FolioPageDelegate>> m_delegates;
};
