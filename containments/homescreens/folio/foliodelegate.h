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

class FolioDelegate : public QObject, public std::enable_shared_from_this<FolioDelegate>
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

    Q_PROPERTY(FolioDelegate::Type type READ type CONSTANT)
    Q_PROPERTY(FolioApplication *application READ applicationRaw CONSTANT)
    Q_PROPERTY(FolioApplicationFolder *folder READ folderRaw CONSTANT)
    Q_PROPERTY(FolioWidget *widget READ widgetRaw CONSTANT)

public:
    typedef std::shared_ptr<FolioDelegate> Ptr;

    enum Type {
        None,
        Application,
        Folder,
        Widget,
    };
    Q_ENUM(Type)

    FolioDelegate(QObject *parent = nullptr);
    FolioDelegate(std::shared_ptr<FolioApplication> application, QObject *parent = nullptr);
    FolioDelegate(std::shared_ptr<FolioApplicationFolder> folder, QObject *parent = nullptr);
    FolioDelegate(std::shared_ptr<FolioWidget> widget, QObject *parent = nullptr);

    static std::shared_ptr<FolioDelegate> fromJson(QJsonObject &obj, HomeScreen *homeScreen);

    virtual QJsonObject toJson() const;

    FolioDelegate::Type type() const;

    std::shared_ptr<FolioApplication> application();
    FolioApplication *applicationRaw();

    std::shared_ptr<FolioApplicationFolder> folder();
    FolioApplicationFolder *folderRaw();

    std::shared_ptr<FolioWidget> widget();
    FolioWidget *widgetRaw();

protected:
    FolioDelegate::Type m_type;
    std::shared_ptr<FolioApplication> m_application{nullptr};
    std::shared_ptr<FolioApplicationFolder> m_folder{nullptr};
    std::shared_ptr<FolioWidget> m_widget{nullptr};
};

class FolioPageDelegate : public FolioDelegate
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

    Q_PROPERTY(int row READ row NOTIFY rowChanged)
    Q_PROPERTY(int column READ column NOTIFY columnChanged)

public:
    typedef std::shared_ptr<FolioPageDelegate> Ptr;

    FolioPageDelegate(int row = 0, int column = 0, HomeScreen *homeScreen = nullptr, QObject *parent = nullptr);
    FolioPageDelegate(int row, int column, std::shared_ptr<FolioApplication> application, HomeScreen *homeScreen, QObject *parent = nullptr);
    FolioPageDelegate(int row, int column, std::shared_ptr<FolioApplicationFolder> folder, HomeScreen *homeScreen, QObject *parent = nullptr);
    FolioPageDelegate(int row, int column, std::shared_ptr<FolioWidget> widget, HomeScreen *homeScreen, QObject *parent = nullptr);
    FolioPageDelegate(int row, int column, std::shared_ptr<FolioDelegate> delegate, HomeScreen *homeScreen, QObject *parent = nullptr);

    static std::shared_ptr<FolioPageDelegate> fromJson(QJsonObject &obj, HomeScreen *homeScreen);
    static int getTranslatedTopLeftRow(HomeScreen *homeScreen, int realRow, int realColumn, std::shared_ptr<FolioDelegate> fd);
    static int getTranslatedTopLeftColumn(HomeScreen *homeScreen, int realRow, int realColumn, std::shared_ptr<FolioDelegate> fd);
    static int getTranslatedRow(HomeScreen *homeScreen, int realRow, int realColumn);
    static int getTranslatedColumn(HomeScreen *homeScreen, int realRow, int realColumn);

    QJsonObject toJson() const override;

    int row();
    void setRow(int row);

    int column();
    void setColumn(int column);

    std::shared_ptr<FolioPageDelegate> sharedPageDelegate();

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
