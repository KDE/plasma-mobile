// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include <QAbstractListModel>
#include <QList>
#include <QObject>
#include <QQuickItem>
#include <QSet>

#include <Plasma/Applet>

#include "foliodelegate.h"
#include "homescreen.h"

class HomeScreen;
class FolioDelegate;

struct FavouritesDelegate {
    std::shared_ptr<FolioDelegate> delegate;
    qreal xPosition;
};

class FavouritesModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        DelegateRole = Qt::UserRole + 1,
    };

    FavouritesModel(HomeScreen *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void removeEntry(int row);
    void moveEntry(int fromRow, int toRow);
    bool canAddEntry(int row, std::shared_ptr<FolioDelegate> delegate);
    bool addEntry(int row, std::shared_ptr<FolioDelegate> delegate);
    std::shared_ptr<FolioDelegate> getEntryAt(int row);

    // whether the dock is full, we can't add any more items
    bool isFull() const;

    // for use with drag and drop, as the delegate is dragged around
    // ghost - fake delegate exists at an index, so a gap is created
    // invisible - existing delegate looks like it doesn't exist
    int getGhostEntryPosition();
    void setGhostEntry(int row);
    void replaceGhostEntry(std::shared_ptr<FolioDelegate> delegate);
    void deleteGhostEntry();

    // whether the position given is in between 2 delegates, or at the edge.
    // this would return false if dropping should place the delegate into a folder/create a folder.
    bool dropPositionIsEdge(qreal x, qreal y) const;

    // the index that dropping at the position given would place the delegate at.
    int dropInsertPosition(qreal x, qreal y) const;

    QPointF getDelegateScreenPosition(int position) const;

    QJsonArray exportToJson();
    void save();
    Q_INVOKABLE void load();
    void loadFromJson(QJsonArray arr);

private:
    void connectSaveRequests(std::shared_ptr<FolioDelegate> delegate);

    // get the x (or y) position where delegates start being placed
    qreal getDelegateRowStartPos() const;

    // adjusts the index in relation to the page orientation
    // this is so that we only have to calculate positions assuming one orientation
    int adjustIndex(int index) const;

    HomeScreen *m_homeScreen{nullptr};

    QList<FavouritesDelegate> m_delegates;
};
