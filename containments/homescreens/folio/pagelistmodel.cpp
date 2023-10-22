// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "pagelistmodel.h"
#include "homescreenstate.h"

#include <QJsonArray>
#include <QJsonDocument>

PageListModel *PageListModel::self()
{
    static PageListModel *model = new PageListModel;
    return model;
}

PageListModel::PageListModel(QObject *parent)
    : QAbstractListModel{parent}
{
}

int PageListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_pages.size();
}

QVariant PageListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case PageRole:
        return QVariant::fromValue(m_pages.at(index.row()));
    }

    return QVariant();
}

QHash<int, QByteArray> PageListModel::roleNames() const
{
    return {{PageRole, "delegate"}};
}

int PageListModel::length()
{
    return m_pages.size();
}

PageModel *PageListModel::getPage(int index)
{
    if (index < 0 || index >= m_pages.size()) {
        return nullptr;
    }

    return m_pages[index];
}

void PageListModel::removePage(int index)
{
    if (index < 0 || index >= m_pages.size()) {
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);
    m_pages[index]->deleteLater();
    m_pages.removeAt(index);
    endRemoveRows();

    Q_EMIT lengthChanged();

    save();
}

Q_INVOKABLE void PageListModel::addPageAtEnd()
{
    beginInsertRows(QModelIndex(), m_pages.size(), m_pages.size());

    PageModel *page = new PageModel{{}, this};
    connect(page, &PageModel::saveRequested, this, &PageListModel::save);

    m_pages.append(page);

    endInsertRows();

    Q_EMIT lengthChanged();

    save();
}

bool PageListModel::isLastPageEmpty()
{
    return m_pages.size() == 0 ? true : m_pages[m_pages.size() - 1]->isPageEmpty();
}

void PageListModel::save()
{
    if (!m_applet) {
        return;
    }

    QJsonArray arr;
    for (auto &page : m_pages) {
        arr.push_back(page->toJson());
    }
    QByteArray data = QJsonDocument(arr).toJson(QJsonDocument::Compact);

    m_applet->config().writeEntry("Pages", QString::fromStdString(data.toStdString()));
    Q_EMIT m_applet->configNeedsSaving();
}

void PageListModel::load()
{
    if (!m_applet) {
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(m_applet->config().readEntry("Pages", "{}").toUtf8());

    beginResetModel();

    m_pages.clear();

    for (QJsonValueRef r : doc.array()) {
        QJsonArray obj = r.toArray();

        PageModel *page = PageModel::fromJson(obj, this);
        if (page) {
            connect(page, &PageModel::saveRequested, this, &PageListModel::save);
            m_pages.append(page);
        }
    }

    endResetModel();

    Q_EMIT lengthChanged();

    // add page if there are no pages
    if (m_pages.size() == 0) {
        addPageAtEnd();
    }
}

void PageListModel::setApplet(Plasma::Applet *applet)
{
    m_applet = applet;
}
