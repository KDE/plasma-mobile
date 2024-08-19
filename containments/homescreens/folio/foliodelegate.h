// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include "folioapplication.h"
#include "folioapplicationfolder.h"
#include "foliowidget.h"
#include "homescreen.h"

class HomeScreen;
class FolioApplication;
class FolioApplicationFolder;
class FolioWidget;

class FolioDelegate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(FolioDelegate::Type type READ type CONSTANT)
    Q_PROPERTY(FolioApplication *application READ application CONSTANT)
    Q_PROPERTY(FolioApplicationFolder *folder READ folder CONSTANT)
    Q_PROPERTY(FolioWidget *widget READ widget CONSTANT)

public:
    enum Type {
        None,
        Application,
        Folder,
        Widget,
    };
    Q_ENUM(Type)

    FolioDelegate(HomeScreen *parent = nullptr);
    FolioDelegate(FolioApplication *application, HomeScreen *parent);
    FolioDelegate(FolioApplicationFolder *folder, HomeScreen *parent);
    FolioDelegate(FolioWidget *widget, HomeScreen *parent);

    static FolioDelegate *fromJson(QJsonObject &obj, HomeScreen *parent);

    virtual QJsonObject toJson() const;

    FolioDelegate::Type type();
    FolioApplication *application();
    FolioApplicationFolder *folder();
    FolioWidget *widget();

protected:
    FolioDelegate::Type m_type;
    FolioApplication *m_application{nullptr};
    FolioApplicationFolder *m_folder{nullptr};
    FolioWidget *m_widget{nullptr};
};

class FolioPageDelegate : public FolioDelegate
{
    Q_OBJECT
    Q_PROPERTY(int row READ row NOTIFY rowChanged)
    Q_PROPERTY(int column READ column NOTIFY columnChanged)
    QML_UNCREATABLE("")

public:
    FolioPageDelegate(int row = 0, int column = 0, HomeScreen *parent = nullptr);
    FolioPageDelegate(int row, int column, FolioApplication *application, HomeScreen *parent);
    FolioPageDelegate(int row, int column, FolioApplicationFolder *folder, HomeScreen *parent);
    FolioPageDelegate(int row, int column, FolioWidget *widget, HomeScreen *parent);
    FolioPageDelegate(int row, int column, FolioDelegate *delegate, HomeScreen *parent);

    static FolioPageDelegate *fromJson(QJsonObject &obj, HomeScreen *parent);
    static int getTranslatedTopLeftRow(HomeScreen *homeScreen, int realRow, int realColumn, FolioDelegate *fd);
    static int getTranslatedTopLeftColumn(HomeScreen *homeScreen, int realRow, int realColumn, FolioDelegate *fd);
    static int getTranslatedRow(HomeScreen *homeScreen, int realRow, int realColumn);
    static int getTranslatedColumn(HomeScreen *homeScreen, int realRow, int realColumn);

    QJsonObject toJson() const override;

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

    HomeScreen *m_homeScreen{nullptr};

    int m_realRow;
    int m_realColumn;
    int m_row;
    int m_column;
};
