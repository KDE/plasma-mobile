/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <QQuickItem>
#include <QQuickWindow>
#include <qqmlregistration.h>

#include <KConfigWatcher>
#include <KIO/ApplicationLauncherJob>
#include <KSharedConfig>
#include <LayerShellQt/Window>

/**
 * Miscellaneous class to put utility functions used in the shell.
 *
 * @author Devin Lin <devin@kde.org>
 **/
class ShellUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool isSystem24HourFormat READ isSystem24HourFormat NOTIFY isSystem24HourFormatChanged)

public:
    ShellUtil(QObject *parent = nullptr);

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
     * Launch an application by name.
     *
     * @param storageId The storage id of the application to launch.
     */
    Q_INVOKABLE void launchApp(const QString &storageId);

    /**
     * Whether the system is using 24 hour format.
     */
    Q_INVOKABLE bool isSystem24HourFormat();

    /**
     * Set window input to be transparent.
     */
    Q_INVOKABLE void setInputTransparent(QQuickWindow *window, bool transparent);

    /**
     * Set the window layer
     */
    Q_INVOKABLE void setWindowLayer(QQuickWindow *window, LayerShellQt::Window::Layer layer);

    /**
     * Sets a region where inputs will get registered on a window.
     * Inputs outside the region will pass through to the surface below.
     * Set this to empty to fill the whole window again.
     */
    Q_INVOKABLE void setInputRegion(QWindow *window, const QRect &region);

    /**
     * Converts rich text to plain text.
     */
    Q_INVOKABLE QString toPlainText(QString htmlString);

Q_SIGNALS:
    void isSystem24HourFormatChanged();

private:
    KConfigWatcher::Ptr m_localeConfigWatcher;
    KSharedConfig::Ptr m_localeConfig;
};
