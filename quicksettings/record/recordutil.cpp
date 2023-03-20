/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "recordutil.h"

#include <QFile>
#include <QStandardPaths>

#include <KFileUtils>
#include <KNotification>

RecordUtil::RecordUtil(QObject *parent)
    : QObject{parent}
{
}

QString RecordUtil::videoLocation(const QString &name)
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
    QString newPath(path + '/' + name);
    if (QFile::exists(newPath)) {
        newPath = path + '/' + KFileUtils::suggestName(QUrl::fromLocalFile(newPath), name);
    }
    return newPath;
}

void RecordUtil::showNotification(const QString &title, const QString &text, const QString &filePath)
{
    KNotification *notif = new KNotification("captured");
    notif->setComponentName(QStringLiteral("plasma_mobile_quicksetting_record"));
    notif->setTitle(title);
    notif->setUrls({QUrl::fromLocalFile(filePath)});
    notif->setText(text);
    notif->sendEvent();
}
