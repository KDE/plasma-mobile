// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include "folioapplication.h"
#include "folioapplicationfolder.h"
#include "foliowidget.h"

class FolioApplication;
class FolioApplicationFolder;
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

    FolioDelegate(QObject *parent = nullptr);
    FolioDelegate(FolioApplication *application, QObject *parent);
    FolioDelegate(FolioApplicationFolder *folder, QObject *parent);
    FolioDelegate(FolioWidget *widget, QObject *parent);

    static FolioDelegate *fromJson(QJsonObject &obj, QObject *parent);

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
