/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef QUICKSETTINGSMODEL_H
#define QUICKSETTINGSMODEL_H

#include "qqml.h"
#include <QAbstractListModel>
#include <QQmlListProperty>

class QuickSetting : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText REQUIRED NOTIFY textChanged)
    Q_PROPERTY(QString icon READ iconName WRITE setIconName REQUIRED NOTIFY iconNameChanged)
    Q_PROPERTY(QString settingsCommand READ settingsCommand WRITE setSettingsCommand NOTIFY settingsCommandChanged)
    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QQmlListProperty<QObject> children READ children CONSTANT)
    Q_CLASSINFO("DefaultProperty", "children")
    QML_NAMED_ELEMENT("QuickSetting")
public:
    QuickSetting(QObject *parent = nullptr);

    QString text() const
    {
        return m_text;
    }
    QString iconName() const
    {
        return m_iconName;
    }
    QString settingsCommand() const
    {
        return m_settingsCommand;
    }
    bool isEnabled() const
    {
        return m_enabled;
    }

    void setText(const QString &text);
    void setIconName(const QString &iconName);
    void setSettingsCommand(const QString &settingsCommand);
    void setEnabled(bool enabled);
    QQmlListProperty<QObject> children();

Q_SIGNALS:
    void enabledChanged(bool enabled);
    void textChanged(const QString &text);
    void iconNameChanged(const QString &icon);
    void settingsCommandChanged(const QString &settingsCommand);

private:
    bool m_enabled = true;
    QString m_text;
    QString m_iconName;
    QString m_settingsCommand;
    QList<QObject *> m_children;
};

class QuickSettingsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<QuickSetting> children READ children NOTIFY childrenChanged)
    Q_CLASSINFO("DefaultProperty", "children")
    QML_ELEMENT

public:
    QuickSettingsModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const override;
    QHash<int, QByteArray> roleNames() const override;

    QQmlListProperty<QuickSetting> children();

    Q_SCRIPTABLE void include(QuickSetting *item);

Q_SIGNALS:
    void childrenChanged();

private:
    QList<QuickSetting *> m_children;
};

#endif // QUICKSETTINGSMODEL_H
