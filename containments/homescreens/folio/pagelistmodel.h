// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "homescreen.h"
#include "pagemodel.h"

#include <QAbstractListModel>
#include <QList>

#include <Plasma/Containment>

class HomeScreen;
class PageModel;

class PageListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

    Q_PROPERTY(int length READ length NOTIFY lengthChanged)

public:
    enum Roles { PageRole = Qt::UserRole + 1 };

    PageListModel(HomeScreen *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int length();

    PageModel *getPage(int index);
    void removePage(int index);

    Q_INVOKABLE void addPageAtEnd();
    Q_INVOKABLE void deleteEmptyPagesAtEnd();
    bool isLastPageEmpty();

    QJsonArray exportToJson();
    void save();
    Q_INVOKABLE void load();
    void loadFromJson(QJsonArray arr);

Q_SIGNALS:
    void lengthChanged();

private:
    HomeScreen *m_homeScreen{nullptr};

    QList<PageModel *> m_pages;
};
