/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>

#include <KConfigWatcher>
#include <KSharedConfig>

#include "mobileshell_export.h"

namespace MobileShell
{

class MOBILESHELL_EXPORT ShellUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isSystem24HourFormat READ isSystem24HourFormat NOTIFY isSystem24HourFormatChanged);

public:
    ShellUtil(QObject *parent = nullptr);
    ~ShellUtil() override;
    static ShellUtil *instance();

public Q_SLOTS:
    void executeCommand(const QString &command);
    void launchApp(const QString &app);

    bool isSystem24HourFormat();

Q_SIGNALS:
    void isSystem24HourFormatChanged();

private:
    KConfigWatcher::Ptr m_localeConfigWatcher;
    KSharedConfig::Ptr m_localeConfig;
};

} // namespace MobileShell
