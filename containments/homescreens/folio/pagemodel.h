// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "folioapplication.h"
#include "folioapplicationfolder.h"
#include "foliodelegate.h"

#include <QAbstractListModel>
#include <QJsonArray>
#include <QList>

#include <Plasma/Applet>

class FolioPageDelegate : public FolioDelegate
{
    Q_OBJECT
    Q_PROPERTY(int row READ row NOTIFY rowChanged)
    Q_PROPERTY(int column READ column NOTIFY columnChanged)

public:
    FolioPageDelegate(int row = 0, int column = 0, QObject *parent = nullptr);
    FolioPageDelegate(int row, int column, FolioApplication *application, QObject *parent);
    FolioPageDelegate(int row, int column, FolioApplicationFolder *folder, QObject *parent);
    FolioPageDelegate(int row, int column, FolioWidget *widget, QObject *parent);
    FolioPageDelegate(int row, int column, FolioDelegate *delegate, QObject *parent);

    static FolioPageDelegate *fromJson(QJsonObject &obj, QObject *parent);
    static int getTranslatedTopLeftRow(int realRow, int realColumn, FolioDelegate *fd);
    static int getTranslatedTopLeftColumn(int realRow, int realColumn, FolioDelegate *fd);
    static int getTranslatedRow(int realRow, int realColumn);
    static int getTranslatedColumn(int realRow, int realColumn);

    virtual QJsonObject toJson() const override;

    int row();
    void setRow(int row);

    int column();
    void setColumn(int column);

Q_SIGNALS:
    void rowChanged();
    void columnChanged();

private:
    void setRowOnly(int row);
    void setColumnOnly(int column);
    void init();

    int m_realRow;
    int m_realColumn;
    int m_row;
    int m_column;
};

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

    PageModel(QList<FolioPageDelegate *> delegates = QList<FolioPageDelegate *>{}, QObject *parent = nullptr);
    ~PageModel();

    static PageModel *fromJson(QJsonArray &arr, QObject *parent);

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
    QList<FolioPageDelegate *> m_delegates;
};
