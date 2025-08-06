/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include "qqml.h"
#include <QAbstractListModel>
#include <QQmlListProperty>

class QuickSetting : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    /**
     * @property QString text
     * @brief The main text of a quicksetting item.
     *
     * The (upper) text / title of a quicksetting item.
     *
     * - Getter: text()
     * - Setter: setText(const QString &)
     */
    Q_PROPERTY(QString text READ text WRITE setText REQUIRED NOTIFY textChanged)

    /**
     * @property QString status
     * @brief The status (lower) text of a quicksetting item.
     *
     * The lower / status text of a quicksetting item. This string
     * often changes depending on state, e.g. the enabled property.
     *
     * If no status is explicitly set, On/Off is used by default.
     *
     * - Getter: status()
     * - Setter: setStatus(const QString &)
     */
    Q_PROPERTY(QString status READ status WRITE setStatus NOTIFY statusChanged)

    /**
     * @property QString icon
     * @brief The icon name of the quicksetting item.
     *
     * - Getter: iconName()
     * - Setter: setIconName(const QString &)
     */
    Q_PROPERTY(QString icon READ iconName WRITE setIconName REQUIRED NOTIFY iconNameChanged)

    /**
     * @property QString settingsCommand
     * @brief A command that opens the settings app when tapped.
     *
     * - Getter: settingsCommand()
     * - Setter: setSettingsCommand(const QString &)
     */
    Q_PROPERTY(QString settingsCommand READ settingsCommand WRITE setSettingsCommand NOTIFY settingsCommandChanged)

    /**
     * @property bool enabled
     * @brief Enables or disables a quicksetting.
     *
     * This property indicates whether this item is active, a setting that
     * is enabled usually carries a highlight item.
     *
     * This property defaults to true.
     *
     * - Getter: enabled()
     * - Setter: setEnabled(bool)
     */
    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)

    /**
     * @property bool available
     * @brief Show or remove a quicksetting in the drawer.
     *
     * The available property indicates whether this item is currently
     * listed in the quicksettings drawer view. Items that are not available (this property
     * is false) are removed temporarily from the list (but not deleted, i.e. they will
     * still execute signal handlers so they can add themselves back by setting this
     * property to true.
     *
     * This property defaults to true.
     *
     * - Getter: available()
     * - Setter: setAvailable(bool)
     */
    Q_PROPERTY(bool available READ isAvailable WRITE setAvailable NOTIFY availableChanged)

    Q_PROPERTY(QQmlListProperty<QObject> children READ children CONSTANT)
    Q_CLASSINFO("DefaultProperty", "children")

public:
    QuickSetting(QObject *parent = nullptr);

    /*!
     * \brief Returns the (upper) text / title of a quicksetting item.
     */
    QString text() const
    {
        return m_text;
    }

    /*!
     * \brief Returns the lower / status text of a quicksetting item.
     */
    QString status() const
    {
        return m_status;
    }

    /*!
     * \brief Returns the icon name of the quicksetting item.
     */
    QString iconName() const
    {
        return m_iconName;
    }

    /*!
     * \brief Returns a command that opens the settings app when tapped.
     */
    QString settingsCommand() const
    {
        return m_settingsCommand;
    }

    /*!
     * \brief Returns enabled property.
     */
    bool isEnabled() const
    {
        return m_enabled;
    }

    /*!
     * \brief Returns available property.
     */
    bool isAvailable() const
    {
        return m_available;
    }

    void setText(const QString &text);
    void setStatus(const QString &status);
    void setIconName(const QString &iconName);
    void setSettingsCommand(const QString &settingsCommand);
    void setEnabled(bool enabled);
    void setAvailable(bool available);
    QQmlListProperty<QObject> children();

Q_SIGNALS:
    void enabledChanged(bool enabled);
    void availableChanged(bool available);
    void textChanged(const QString &text);
    void statusChanged(const QString &text);
    void iconNameChanged(const QString &icon);
    void settingsCommandChanged(const QString &settingsCommand);

private:
    bool m_enabled = true;
    bool m_available = true;
    QString m_text;
    QString m_status;
    QString m_iconName;
    QString m_settingsCommand;
    QList<QObject *> m_children;
};
