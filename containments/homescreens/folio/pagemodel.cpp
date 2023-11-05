// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "pagemodel.h"
#include "foliosettings.h"
#include "homescreenstate.h"
#include "widgetsmanager.h"

FolioPageDelegate::FolioPageDelegate(int row, int column, QObject *parent)
    : FolioDelegate{parent}
    , m_row{row}
    , m_column{column}
{
    init();
}

FolioPageDelegate::FolioPageDelegate(int row, int column, FolioApplication *application, QObject *parent)
    : FolioDelegate{application, parent}
    , m_row{row}
    , m_column{column}
{
    init();
}

FolioPageDelegate::FolioPageDelegate(int row, int column, FolioApplicationFolder *folder, QObject *parent)
    : FolioDelegate{folder, parent}
    , m_row{row}
    , m_column{column}
{
    init();
}

FolioPageDelegate::FolioPageDelegate(int row, int column, FolioWidget *widget, QObject *parent)
    : FolioDelegate{widget, parent}
    , m_row{row}
    , m_column{column}
{
    init();
}

FolioPageDelegate::FolioPageDelegate(int row, int column, FolioDelegate *delegate, QObject *parent)
    : FolioDelegate{parent}
    , m_row{row}
    , m_column{column}
{
    m_type = delegate->type();
    m_application = delegate->application();
    m_folder = delegate->folder();
    m_widget = delegate->widget();

    init();
}

void FolioPageDelegate::init()
{
    // we have to use the "real" rows and columns, so fetch them from FolioSettings instead of HomeScreenState
    switch (HomeScreenState::self()->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        m_realRow = m_row;
        m_realColumn = m_column;
        break;
    case HomeScreenState::RotateClockwise:
        m_realRow = HomeScreenState::self()->pageColumns() - m_column - 1;
        m_realColumn = m_row;

        if (m_widget) {
            // since top-left in cw is bottom-left in portrait
            m_realRow -= m_widget->realGridHeight() - 1;
        }

        break;
    case HomeScreenState::RotateCounterClockwise:
        m_realRow = m_column;
        m_realColumn = HomeScreenState::self()->pageRows() - m_row - 1;

        if (m_widget) {
            // since top-left in ccw is top-right in portrait
            m_realColumn -= m_widget->realGridWidth() - 1;
        }

        break;
    case HomeScreenState::RotateUpsideDown:
        m_realRow = HomeScreenState::self()->pageRows() - m_row - 1;
        m_realColumn = HomeScreenState::self()->pageColumns() - m_column - 1;

        if (m_widget) {
            // since top-left in upside-down is bottom-right in portrait
            m_realRow -= m_widget->realGridHeight() - 1;
            m_realColumn -= m_widget->realGridWidth() - 1;
        }

        break;
    }

    if (m_widget) {
        connect(m_widget, &FolioWidget::realTopLeftPositionChanged, this, [this](int rowOffset, int columnOffset) {
            m_realRow += rowOffset;
            m_realColumn += columnOffset;
        });
    }

    connect(HomeScreenState::self(), &HomeScreenState::pageOrientationChanged, this, [this]() {
        setRowOnly(getTranslatedTopLeftRow(m_realRow, m_realColumn, this));
        setColumnOnly(getTranslatedTopLeftColumn(m_realRow, m_realColumn, this));
    });
}

FolioPageDelegate *FolioPageDelegate::fromJson(QJsonObject &obj, QObject *parent)
{
    FolioDelegate *fd = FolioDelegate::fromJson(obj, parent);

    if (!fd) {
        return nullptr;
    }

    int realRow = obj[QStringLiteral("row")].toInt();
    int realColumn = obj[QStringLiteral("column")].toInt();

    int row = getTranslatedTopLeftRow(realRow, realColumn, fd);
    int column = getTranslatedTopLeftColumn(realRow, realColumn, fd);

    FolioPageDelegate *delegate = new FolioPageDelegate{row, column, fd, parent};
    fd->deleteLater();

    return delegate;
}

int FolioPageDelegate::getTranslatedTopLeftRow(int realRow, int realColumn, FolioDelegate *fd)
{
    int row = getTranslatedRow(realRow, realColumn);
    int column = getTranslatedColumn(realRow, realColumn);

    // special logic to return "top left" for widgets, since they take more than one tile
    if (fd->type() == FolioDelegate::Widget) {
        return fd->widget()->topLeftCorner(row, column).row;
    } else {
        return row;
    }
}

int FolioPageDelegate::getTranslatedTopLeftColumn(int realRow, int realColumn, FolioDelegate *fd)
{
    int row = getTranslatedRow(realRow, realColumn);
    int column = getTranslatedColumn(realRow, realColumn);

    // special logic to return "top left" for widgets, since they take more than one tile
    if (fd->type() == FolioDelegate::Widget) {
        return fd->widget()->topLeftCorner(row, column).column;
    } else {
        return column;
    }
}

int FolioPageDelegate::getTranslatedRow(int realRow, int realColumn)
{
    // we have to use the "real" rows and columns, so fetch them from FolioSettings instead of HomeScreenState
    switch (HomeScreenState::self()->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        return realRow;
    case HomeScreenState::RotateClockwise:
        return realColumn;
    case HomeScreenState::RotateCounterClockwise:
        return FolioSettings::self()->homeScreenColumns() - realColumn - 1;
    case HomeScreenState::RotateUpsideDown:
        return FolioSettings::self()->homeScreenRows() - realRow - 1;
    }
    return realRow;
}

int FolioPageDelegate::getTranslatedColumn(int realRow, int realColumn)
{
    // we have to use the "real" rows and columns, so fetch them from FolioSettings instead of HomeScreenState
    switch (HomeScreenState::self()->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        return realColumn;
    case HomeScreenState::RotateClockwise:
        return FolioSettings::self()->homeScreenRows() - realRow - 1;
    case HomeScreenState::RotateCounterClockwise:
        return realRow;
    case HomeScreenState::RotateUpsideDown:
        return FolioSettings::self()->homeScreenColumns() - realColumn - 1;
    }
    return realRow;
}

QJsonObject FolioPageDelegate::toJson() const
{
    QJsonObject o = FolioDelegate::toJson();
    o[QStringLiteral("row")] = m_realRow;
    o[QStringLiteral("column")] = m_realColumn;
    return o;
}

int FolioPageDelegate::row()
{
    return m_row;
}

void FolioPageDelegate::setRow(int row)
{
    if (m_row != row) {
        // adjust stored data too
        switch (HomeScreenState::self()->pageOrientation()) {
        case HomeScreenState::RegularPosition:
            m_realRow = row;
            break;
        case HomeScreenState::RotateClockwise:
            m_realColumn += row - m_row;
            break;
        case HomeScreenState::RotateCounterClockwise:
            m_realColumn += m_row - row;
            break;
        case HomeScreenState::RotateUpsideDown:
            m_realRow += m_row - row;
            break;
        }

        setRowOnly(row);
    }
}

void FolioPageDelegate::setRowOnly(int row)
{
    if (m_row != row) {
        m_row = row;
        Q_EMIT rowChanged();
    }
}

int FolioPageDelegate::column()
{
    return m_column;
}

void FolioPageDelegate::setColumn(int column)
{
    if (m_column != column) {
        // adjust stored data too
        switch (HomeScreenState::self()->pageOrientation()) {
        case HomeScreenState::RegularPosition:
            m_realColumn = column;
            break;
        case HomeScreenState::RotateClockwise:
            m_realRow += m_column - column;
            break;
        case HomeScreenState::RotateCounterClockwise:
            m_realRow += column - m_column;
            break;
        case HomeScreenState::RotateUpsideDown:
            m_realColumn += m_column - column;
            break;
        }

        setColumnOnly(column);
    }
}

void FolioPageDelegate::setColumnOnly(int column)
{
    if (m_column != column) {
        m_column = column;
        Q_EMIT columnChanged();
    }
}

PageModel::PageModel(QList<FolioPageDelegate *> delegates, QObject *parent)
    : QAbstractListModel{parent}
    , m_delegates{delegates}
{
    connect(WidgetsManager::self(), &WidgetsManager::widgetRemoved, this, [this](Plasma::Applet *applet) {
        if (applet) {
            // delete any instance of this widget
            for (int i = 0; i < m_delegates.size(); i++) {
                auto *delegate = m_delegates[i];
                if (delegate->type() == FolioDelegate::Widget && delegate->widget()->applet() == applet) {
                    removeDelegate(i);
                    break;
                }
            }
        }
    });
}

PageModel::~PageModel() = default;

PageModel *PageModel::fromJson(QJsonArray &arr, QObject *parent)
{
    QList<FolioPageDelegate *> delegates;

    for (QJsonValueRef r : arr) {
        QJsonObject obj = r.toObject();

        FolioPageDelegate *delegate = FolioPageDelegate::fromJson(obj, parent);
        if (delegate) {
            delegates.append(delegate);
        }
    }

    PageModel *model = new PageModel{delegates, parent};

    // ensure delegates can request saves
    for (auto *delegate : delegates) {
        model->connectSaveRequests(delegate);
    }

    return model;
}

QJsonArray PageModel::toJson() const
{
    QJsonArray arr;

    for (FolioPageDelegate *delegate : m_delegates) {
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
        return QVariant::fromValue(m_delegates.at(index.row()));
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
    if (row < 0 || row >= HomeScreenState::self()->pageRows() || column < 0 || column >= HomeScreenState::self()->pageColumns()) {
        return false;
    }

    if (delegate->type() == FolioDelegate::Widget) {
        // inserting a widget...

        // bounds of widget
        int maxRow = row + delegate->widget()->gridHeight() - 1;
        int maxColumn = column + delegate->widget()->gridWidth() - 1;

        // check bounds
        if ((row < 0 || row >= HomeScreenState::self()->pageRows()) || (maxRow < 0 || maxRow >= HomeScreenState::self()->pageRows())
            || (column < 0 || column >= HomeScreenState::self()->pageColumns()) || (maxColumn < 0 || maxColumn >= HomeScreenState::self()->pageColumns())) {
            return false;
        }

        // check if any delegate exists at any of the spots where the widget is being added
        for (FolioPageDelegate *d : m_delegates) {
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
        for (FolioPageDelegate *d : m_delegates) {
            if (d->row() == row && d->column() == column) {
                return false;
            } else if (d->type() == FolioDelegate::Widget && d->widget()->isInBounds(d->row(), d->column(), row, column)) {
                return false;
            }
        }
    }

    return true;
}

bool PageModel::addDelegate(FolioPageDelegate *delegate)
{
    if (!canAddDelegate(delegate->row(), delegate->column(), delegate)) {
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

FolioPageDelegate *PageModel::getDelegate(int row, int col)
{
    for (FolioPageDelegate *d : m_delegates) {
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

    // test if we can add the delegate with new size and position
    FolioWidget *testWidget = new FolioWidget(this, 0, 0, 0);
    // we have to use setGridWidth and setGridHeight since it takes into account the page orientation
    testWidget->setGridWidth(newGridWidth);
    testWidget->setGridHeight(newGridHeight);
    FolioDelegate *testDelegate = new FolioDelegate(testWidget, this);

    // NOT THREAD SAFE!
    // which is fine, because the GUI isn't multithreaded
    int index = m_delegates.indexOf(delegate);
    m_delegates.remove(index); // remove the delegate temporarily, since we don't want it to check overlapping of itself
    bool canAdd = canAddDelegate(newRow, newColumn, testDelegate);
    m_delegates.insert(index, delegate); // add it back

    // cleanup test delegate
    testDelegate->deleteLater();
    testWidget->deleteLater();

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

void PageModel::connectSaveRequests(FolioDelegate *delegate)
{
    if (delegate->type() == FolioDelegate::Folder && delegate->folder()) {
        connect(delegate->folder(), &FolioApplicationFolder::saveRequested, this, &PageModel::save);
    } else if (delegate->type() == FolioDelegate::Widget && delegate->widget()) {
        connect(delegate->widget(), &FolioWidget::saveRequested, this, &PageModel::save);
    }
}

void PageModel::save()
{
    Q_EMIT saveRequested();
}
