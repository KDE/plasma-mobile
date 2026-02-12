// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "pagemodel.h"
#include "foliosettings.h"
#include "homescreenstate.h"
#include "widgetsmanager.h"

PageModel::PageModel(QList<FolioPageDelegate::Ptr> delegates, QObject *parent, HomeScreen *homeScreen)
    : QAbstractListModel{parent}
    , m_homeScreen{homeScreen}
    , m_delegates{delegates}
{
    // Listen to widget removal events and delete delegates
    connect(homeScreen->widgetsManager(), &WidgetsManager::widgetRemoved, this, [this](Plasma::Applet *applet) {
        if (!applet) {
            return;
        }

        // delete any instance of this widget
        for (int i = 0; i < m_delegates.size(); i++) {
            FolioPageDelegate::Ptr delegate = m_delegates[i];

            if (delegate->type() == FolioDelegate::Widget && delegate->widget()->applet() == applet) {
                removeDelegate(i);
                break;
            }
        }
    });

    // Listen to application removal events and delete delegates
    connect(homeScreen->applicationListModel(), &ApplicationListModel::applicationRemoved, this, [this](const QString &storageId) {
        for (int i = 0; i < m_delegates.size(); i++) {
            FolioPageDelegate::Ptr delegate = m_delegates[i];

            if (delegate->type() == FolioDelegate::Application && delegate->application()->storageId() == storageId) {
                removeDelegate(i);
            }
        }
    });
}

PageModel::~PageModel() = default;

PageModel *PageModel::fromJson(QJsonArray &arr, QObject *parent, HomeScreen *homeScreen)
{
    QList<FolioPageDelegate::Ptr> delegates;

    for (QJsonValueRef r : arr) {
        QJsonObject obj = r.toObject();

        FolioPageDelegate::Ptr delegate = FolioPageDelegate::fromJson(obj, homeScreen);
        if (delegate) {
            delegates.append(delegate);
        }
    }

    PageModel *model = new PageModel{delegates, parent, homeScreen};

    // ensure delegates can request saves
    for (FolioPageDelegate::Ptr delegate : delegates) {
        model->connectSaveRequests(delegate);
    }

    return model;
}

QJsonArray PageModel::toJson() const
{
    QJsonArray arr;

    for (FolioPageDelegate::Ptr delegate : m_delegates) {
        if (!delegate) {
            continue;
        }

        arr.append(delegate->toJson());
    }

    return arr;
}

int PageModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_delegates.size();
}

QVariant PageModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case DelegateRole:
        return QVariant::fromValue(m_delegates.at(index.row()).get());
    }

    return QVariant();
}

QHash<int, QByteArray> PageModel::roleNames() const
{
    return {{DelegateRole, "delegate"}};
}

void PageModel::removeDelegate(int row, int col)
{
    for (int i = 0; i < m_delegates.size(); ++i) {
        if (m_delegates[i]->row() == row && m_delegates[i]->column() == col) {
            removeDelegate(i);
            break;
        }
    }
}

void PageModel::removeDelegate(int index)
{
    if (index < 0 || index >= m_delegates.size()) {
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);
    // HACK: do not deleteLater(), because the delegate might still be used somewhere else
    m_delegates.removeAt(index);
    endRemoveRows();

    save();
}

bool PageModel::canAddDelegate(int row, int column, FolioDelegate *delegate)
{
    HomeScreenState *homeScreenState = m_homeScreen->homeScreenState();

    if (row < 0 || row >= homeScreenState->pageRows() || column < 0 || column >= homeScreenState->pageColumns()) {
        return false;
    }

    if (delegate->type() == FolioDelegate::Widget) {
        // inserting a widget...

        // bounds of widget
        int maxRow = row + delegate->widget()->gridHeight() - 1;
        int maxColumn = column + delegate->widget()->gridWidth() - 1;

        // check bounds
        if ((row < 0 || row >= homeScreenState->pageRows()) || (maxRow < 0 || maxRow >= homeScreenState->pageRows())
            || (column < 0 || column >= homeScreenState->pageColumns()) || (maxColumn < 0 || maxColumn >= homeScreenState->pageColumns())) {
            return false;
        }

        // check if any delegate exists at any of the spots where the widget is being added
        for (FolioPageDelegate::Ptr d : m_delegates) {
            if (delegate->widget()->isInBounds(row, column, d->row(), d->column())) {
                return false;
            } else if (d->type() == FolioDelegate::Widget) {
                // 2 widgets overlapping scenario
                if (d->widget()->overlapsWidget(d->row(), d->column(), delegate->widget(), row, column)) {
                    return false;
                }
            }
        }

    } else {
        // inserting app or folder...

        // check if there already exists a delegate in this space
        for (FolioPageDelegate::Ptr d : m_delegates) {
            if (d->row() == row && d->column() == column) {
                return false;
            } else if (d->type() == FolioDelegate::Widget && d->widget()->isInBounds(d->row(), d->column(), row, column)) {
                return false;
            }
        }
    }

    return true;
}

bool PageModel::addDelegate(FolioPageDelegate::Ptr delegate)
{
    if (!canAddDelegate(delegate->row(), delegate->column(), delegate.get())) {
        return false;
    }

    beginInsertRows(QModelIndex(), m_delegates.size(), m_delegates.size());
    m_delegates.append(delegate);
    endInsertRows();

    // ensure the delegate requests saves
    connectSaveRequests(delegate);
    save();

    return true;
}

FolioPageDelegate::Ptr PageModel::getDelegate(int row, int col)
{
    for (FolioPageDelegate::Ptr d : m_delegates) {
        if (d->row() == row && d->column() == col) {
            return d;
        }

        // check if this is in a widget's space
        if (d->type() == FolioDelegate::Widget) {
            if (d->widget()->isInBounds(d->row(), d->column(), row, col)) {
                return d;
            }
        }
    }
    return nullptr;
}

void PageModel::moveAndResizeWidgetDelegate(FolioPageDelegate *delegate, int newRow, int newColumn, int newGridWidth, int newGridHeight)
{
    if (delegate->type() != FolioDelegate::Widget) {
        return;
    }

    if (newGridWidth < 1 || newGridHeight < 1) {
        return;
    }

    // Test if we can add the delegate with new size and position
    FolioWidget::Ptr testWidget = std::make_shared<FolioWidget>(m_homeScreen, 0, 0, 0);
    // We have to use setGridWidth and setGridHeight since it takes into account the page orientation
    testWidget->setGridWidth(newGridWidth);
    testWidget->setGridHeight(newGridHeight);
    FolioDelegate::Ptr testDelegate = std::make_shared<FolioDelegate>(testWidget, m_homeScreen);

    // testWidget and testDelegate will get cleaned up automatically since are smart pointers

    // NOT THREAD SAFE!
    // which is fine, because the GUI isn't multithreaded
    int index = m_delegates.indexOf(delegate->sharedPageDelegate());
    m_delegates.remove(index); // remove the delegate temporarily, since we don't want it to check overlapping of itself
    bool canAdd = canAddDelegate(newRow, newColumn, testDelegate.get());
    m_delegates.insert(index, delegate->sharedPageDelegate()); // add it back

    if (!canAdd) {
        return;
    }

    delegate->setRow(newRow);
    delegate->setColumn(newColumn);
    delegate->widget()->setGridWidth(newGridWidth);
    delegate->widget()->setGridHeight(newGridHeight);
}

bool PageModel::isPageEmpty()
{
    return m_delegates.size() == 0;
}

void PageModel::connectSaveRequests(FolioDelegate::Ptr delegate)
{
    if (delegate->type() == FolioDelegate::Folder && delegate->folder()) {
        connect(delegate->folder().get(), &FolioApplicationFolder::saveRequested, this, &PageModel::save);
    } else if (delegate->type() == FolioDelegate::Widget && delegate->widget()) {
        connect(delegate->widget().get(), &FolioWidget::saveRequested, this, &PageModel::save);
    }
}

void PageModel::save()
{
    Q_EMIT saveRequested();
}
