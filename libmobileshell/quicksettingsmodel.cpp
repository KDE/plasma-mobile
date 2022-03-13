/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "quicksettingsmodel.h"

#include <KPackage/PackageLoader>
#include <QFileInfo>
#include <QQmlComponent>
#include <QQmlEngine>

using namespace MobileShell;

QuickSettingsModel::QuickSettingsModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

QHash<int, QByteArray> QuickSettingsModel::roleNames() const
{
    return {{Qt::UserRole, "modelData"}};
}

QQmlListProperty<QuickSetting> QuickSettingsModel::children()
{
    return QQmlListProperty<QuickSetting>(this, &m_children);
}

int QuickSettingsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_children.count() + m_external.count();
}

QVariant QuickSettingsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= rowCount({}) || role != Qt::UserRole) {
        return {};
    }

    QObject *obj = nullptr;
    if (index.row() < m_children.count()) {
        obj = m_children[index.row()];
    } else {
        obj = m_external[index.row() - m_children.count()];
    }

    return QVariant::fromValue<QObject *>(obj);
}

void QuickSettingsModel::classBegin()
{
    QQmlEngine *engine = qmlEngine(this);

    const auto packages = KPackage::PackageLoader::self()->listPackages(QStringLiteral("KPackage/GenericQML"), "plasma/quicksettings");
    auto c = new QQmlComponent(engine, this);

    for (const auto &metaData : packages) {
        KPackage::Package package = KPackage::PackageLoader::self()->loadPackage("KPackage/GenericQML", QFileInfo(metaData.fileName()).path());
        if (!package.isValid()) {
            qWarning() << "Quick setting package invalid:" << metaData.fileName();
            continue;
        }

        c->loadUrl(package.fileUrl("mainscript"), QQmlComponent::PreferSynchronous);

        auto created = c->create(engine->rootContext());
        auto createdSetting = qobject_cast<QuickSetting *>(created);

        if (!createdSetting) {
            qWarning() << "Could not load" << metaData.fileName() << created;
            if (c->isError()) {
                for (const auto &error : c->errors()) {
                    qDebug() << error;
                }
            }
            delete created;
        } else {
            qDebug() << "Loaded quicksetting" << metaData.fileName();
            m_external += createdSetting;
        }
    }
    delete c;
}

void QuickSettingsModel::componentComplete()
{
}

void QuickSettingsModel::include(QuickSetting *item)
{
    const int c = m_children.count() + m_external.count();
    beginInsertRows({}, c, c);
    m_external.append(item);
    endInsertRows();
}
