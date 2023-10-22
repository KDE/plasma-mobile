// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "foliodelegate.h"
#include "homescreenstate.h"

FolioDelegate::FolioDelegate(QObject *parent)
    : QObject{parent}
    , m_type{FolioDelegate::None}
    , m_application{nullptr}
    , m_folder{nullptr}
{
}

FolioDelegate::FolioDelegate(FolioApplication *application, QObject *parent)
    : QObject{parent}
    , m_type{FolioDelegate::Application}
    , m_application{application}
    , m_folder{nullptr}
{
}

FolioDelegate::FolioDelegate(FolioApplicationFolder *folder, QObject *parent)
    : QObject{parent}
    , m_type{FolioDelegate::Folder}
    , m_application{nullptr}
    , m_folder{folder}
{
}

FolioDelegate *FolioDelegate::fromJson(QJsonObject &obj, QObject *parent)
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
