// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "foliodelegate.h"
#include "homescreenstate.h"

FolioDelegate::FolioDelegate(HomeScreen *parent)
    : QObject{parent}
    , m_type{FolioDelegate::None}
    , m_application{nullptr}
    , m_folder{nullptr}
    , m_widget{nullptr}
{
}

FolioDelegate::FolioDelegate(FolioApplication *application, HomeScreen *parent)
    : QObject{parent}
    , m_type{FolioDelegate::Application}
    , m_application{application}
    , m_folder{nullptr}
    , m_widget{nullptr}
{
}

FolioDelegate::FolioDelegate(FolioApplicationFolder *folder, HomeScreen *parent)
    : QObject{parent}
    , m_type{FolioDelegate::Folder}
    , m_application{nullptr}
    , m_folder{folder}
    , m_widget{nullptr}
{
}

FolioDelegate::FolioDelegate(FolioWidget *widget, HomeScreen *parent)
    : QObject{parent}
    , m_type{FolioDelegate::Widget}
    , m_application{nullptr}
    , m_folder{nullptr}
    , m_widget{widget}
{
}

FolioDelegate *FolioDelegate::fromJson(QJsonObject &obj, HomeScreen *parent)
{
    const QString type = obj[QStringLiteral("type")].toString();
    if (type == "application") {
        // read application
        FolioApplication *app = FolioApplication::fromJson(obj, parent);

        if (app) {
            return new FolioDelegate{app, parent};
        }

    } else if (type == "folder") {
        // read folder
        FolioApplicationFolder *folder = FolioApplicationFolder::fromJson(obj, parent);

        if (folder) {
            return new FolioDelegate{folder, parent};
        }

    } else if (type == "widget") {
        // read widget
        FolioWidget *widget = FolioWidget::fromJson(obj, parent);

        if (widget) {
            return new FolioDelegate{widget, parent};
        }
    } else if (type == "none") {
        return new FolioDelegate{parent};
    }

    return nullptr;
}

QJsonObject FolioDelegate::toJson() const
{
    switch (m_type) {
    case FolioDelegate::Application:
        return m_application->toJson();
    case FolioDelegate::Folder:
        return m_folder->toJson();
    case FolioDelegate::Widget:
        return m_widget->toJson();
    case FolioDelegate::None: {
        QJsonObject obj;
        obj[QStringLiteral("type")] = "none";
        return obj;
    }
    default:
        break;
    }
    return QJsonObject{};
}

FolioDelegate::Type FolioDelegate::type()
{
    return m_type;
}

FolioApplication *FolioDelegate::application()
{
    return m_application;
}

FolioApplicationFolder *FolioDelegate::folder()
{
    return m_folder;
}

FolioWidget *FolioDelegate::widget()
{
    return m_widget;
}

FolioPageDelegate::FolioPageDelegate(int row, int column, HomeScreen *parent)
    : FolioDelegate{parent}
    , m_homeScreen{parent}
    , m_row{row}
    , m_column{column}
{
    init();
}

FolioPageDelegate::FolioPageDelegate(int row, int column, FolioApplication *application, HomeScreen *parent)
    : FolioDelegate{application, parent}
    , m_homeScreen{parent}
    , m_row{row}
    , m_column{column}
{
    init();
}

FolioPageDelegate::FolioPageDelegate(int row, int column, FolioApplicationFolder *folder, HomeScreen *parent)
    : FolioDelegate{folder, parent}
    , m_homeScreen{parent}
    , m_row{row}
    , m_column{column}
{
    init();
}

FolioPageDelegate::FolioPageDelegate(int row, int column, FolioWidget *widget, HomeScreen *parent)
    : FolioDelegate{widget, parent}
    , m_homeScreen{parent}
    , m_row{row}
    , m_column{column}
{
    init();
}

FolioPageDelegate::FolioPageDelegate(int row, int column, FolioDelegate *delegate, HomeScreen *parent)
    : FolioDelegate{parent}
    , m_homeScreen{parent}
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
    HomeScreenState *homeScreenState = m_homeScreen->homeScreenState();

    // we have to use the "real" rows and columns, so fetch them from FolioSettings instead of HomeScreenState
    switch (homeScreenState->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        m_realRow = m_row;
        m_realColumn = m_column;
        break;
    case HomeScreenState::RotateClockwise:
        m_realRow = homeScreenState->pageColumns() - m_column - 1;
        m_realColumn = m_row;

        if (m_widget) {
            // since top-left in cw is bottom-left in portrait
            m_realRow -= m_widget->realGridHeight() - 1;
        }

        break;
    case HomeScreenState::RotateCounterClockwise:
        m_realRow = m_column;
        m_realColumn = homeScreenState->pageRows() - m_row - 1;

        if (m_widget) {
            // since top-left in ccw is top-right in portrait
            m_realColumn -= m_widget->realGridWidth() - 1;
        }

        break;
    case HomeScreenState::RotateUpsideDown:
        m_realRow = homeScreenState->pageRows() - m_row - 1;
        m_realColumn = homeScreenState->pageColumns() - m_column - 1;

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

    connect(homeScreenState, &HomeScreenState::pageOrientationChanged, this, [this]() {
        setRowOnly(getTranslatedTopLeftRow(m_homeScreen, m_realRow, m_realColumn, this));
        setColumnOnly(getTranslatedTopLeftColumn(m_homeScreen, m_realRow, m_realColumn, this));
    });
}

FolioPageDelegate *FolioPageDelegate::fromJson(QJsonObject &obj, HomeScreen *parent)
{
    FolioDelegate *fd = FolioDelegate::fromJson(obj, parent);

    if (!fd) {
        return nullptr;
    }

    int realRow = obj[QStringLiteral("row")].toInt();
    int realColumn = obj[QStringLiteral("column")].toInt();

    int row = getTranslatedTopLeftRow(parent, realRow, realColumn, fd);
    int column = getTranslatedTopLeftColumn(parent, realRow, realColumn, fd);

    FolioPageDelegate *delegate = new FolioPageDelegate{row, column, fd, parent};
    fd->deleteLater();

    return delegate;
}

int FolioPageDelegate::getTranslatedTopLeftRow(HomeScreen *homeScreen, int realRow, int realColumn, FolioDelegate *fd)
{
    int row = getTranslatedRow(homeScreen, realRow, realColumn);
    int column = getTranslatedColumn(homeScreen, realRow, realColumn);

    // special logic to return "top left" for widgets, since they take more than one tile
    if (fd->type() == FolioDelegate::Widget) {
        return fd->widget()->topLeftCorner(row, column).row;
    } else {
        return row;
    }
}

int FolioPageDelegate::getTranslatedTopLeftColumn(HomeScreen *homeScreen, int realRow, int realColumn, FolioDelegate *fd)
{
    int row = getTranslatedRow(homeScreen, realRow, realColumn);
    int column = getTranslatedColumn(homeScreen, realRow, realColumn);

    // special logic to return "top left" for widgets, since they take more than one tile
    if (fd->type() == FolioDelegate::Widget) {
        return fd->widget()->topLeftCorner(row, column).column;
    } else {
        return column;
    }
}

int FolioPageDelegate::getTranslatedRow(HomeScreen *homeScreen, int realRow, int realColumn)
{
    HomeScreenState *homeScreenState = homeScreen->homeScreenState();
    FolioSettings *folioSettings = homeScreen->folioSettings();

    // we have to use the "real" rows and columns, so fetch them from FolioSettings instead of HomeScreenState
    switch (homeScreenState->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        return realRow;
    case HomeScreenState::RotateClockwise:
        return realColumn;
    case HomeScreenState::RotateCounterClockwise:
        return folioSettings->homeScreenColumns() - realColumn - 1;
    case HomeScreenState::RotateUpsideDown:
        return folioSettings->homeScreenRows() - realRow - 1;
    }
    return realRow;
}

int FolioPageDelegate::getTranslatedColumn(HomeScreen *homeScreen, int realRow, int realColumn)
{
    HomeScreenState *homeScreenState = homeScreen->homeScreenState();
    FolioSettings *folioSettings = homeScreen->folioSettings();

    // we have to use the "real" rows and columns, so fetch them from FolioSettings instead of HomeScreenState
    switch (homeScreenState->pageOrientation()) {
    case HomeScreenState::RegularPosition:
        return realColumn;
    case HomeScreenState::RotateClockwise:
        return folioSettings->homeScreenRows() - realRow - 1;
    case HomeScreenState::RotateCounterClockwise:
        return realRow;
    case HomeScreenState::RotateUpsideDown:
        return folioSettings->homeScreenColumns() - realColumn - 1;
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
    HomeScreenState *homeScreenState = m_homeScreen->homeScreenState();

    if (m_row != row) {
        // adjust stored data too
        switch (homeScreenState->pageOrientation()) {
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
    HomeScreenState *homeScreenState = m_homeScreen->homeScreenState();

    if (m_column != column) {
        // adjust stored data too
        switch (homeScreenState->pageOrientation()) {
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
