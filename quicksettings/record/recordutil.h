/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <QVariantMap>
#include <qqmlregistration.h>

class RecordUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    RecordUtil(QObject *parent = nullptr);

    /**
     * Allows us to get a filename in the standard videos directory (~/Videos by default)
     * with a name that starts with @p name
     *
     * @returns a non-existing path that can be written into
     *
     * @see QStandardPaths::writableLocation()
     * @see KFileUtil::suggestName()
     */
    Q_INVOKABLE QString videoLocation(const QString &name);

    Q_INVOKABLE void showNotification(const QString &title, const QString &text, const QString &filePath);
};
