/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <QQuickItem>

#include <KConfigWatcher>
#include <KIO/ApplicationLauncherJob>
#include <KSharedConfig>

/**
 * Miscellaneous class to put utility functions used in the shell.
 *
 * @author Devin Lin <devin@kde.org>
 **/
class ShellUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isSystem24HourFormat READ isSystem24HourFormat NOTIFY isSystem24HourFormatChanged)

public:
    ShellUtil(QObject *parent = nullptr);
    static ShellUtil *instance();

    /**
     * Change the stacking order to have the first item behind the second item.
     *
     * @param item1 The item to move behind.
     * @param item2 The item to move in front.
     */
    Q_INVOKABLE void stackItemBefore(QQuickItem *item1, QQuickItem *item2);

    /**
     * Change the stacking order to have the first item in front of the second item.
     *
     * @param item1 The item to move in front.
     * @param item2 The item to move behind.
     */
    Q_INVOKABLE void stackItemAfter(QQuickItem *item1, QQuickItem *item2);

    /**
     * Execute the command given.
     *
     * @param command The command to execute.
     */
    Q_INVOKABLE void executeCommand(const QString &command);

    /**
     * Launch an application by name. Sets the internal "launched app" state.
     *
     * @param storageId The storage id of the application to launch.
     */
    Q_INVOKABLE void launchApp(const QString &storageId);

    /**
     * Whether the system is using 24 hour format.
     */
    Q_INVOKABLE bool isSystem24HourFormat();

Q_SIGNALS:
    void isSystem24HourFormatChanged();

private:
    KConfigWatcher::Ptr m_localeConfigWatcher;
    KSharedConfig::Ptr m_localeConfig;
};
