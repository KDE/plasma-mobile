// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include "folioapplication.h"
#include "folioapplicationfolder.h"

class FolioApplication;
class FolioApplicationFolder;
class FolioDelegate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(FolioDelegate::Type type READ type CONSTANT)
    Q_PROPERTY(FolioApplication *application READ application CONSTANT)
    Q_PROPERTY(FolioApplicationFolder *folder READ folder CONSTANT)

public:
    enum Type {
        None,
        Application,
        Folder,
    };
    Q_ENUM(Type)

    FolioDelegate(QObject *parent = nullptr);
    FolioDelegate(FolioApplication *application, QObject *parent);
    FolioDelegate(FolioApplicationFolder *folder, QObject *parent);

    static FolioDelegate *fromJson(QJsonObject &obj, QObject *parent);

    virtual QJsonObject toJson() const;

    FolioDelegate::Type type();
    FolioApplication *application();
    FolioApplicationFolder *folder();

protected:
    FolioDelegate::Type m_type;
    FolioApplication *m_application{nullptr};
    FolioApplicationFolder *m_folder{nullptr};
};
