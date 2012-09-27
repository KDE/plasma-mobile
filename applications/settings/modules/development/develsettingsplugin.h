/*
 *  Copyright 2012 Aaron Seigo <aseigo@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef DEVELSETTINGSPLUGIN_H
#define DEVELSETTINGSPLUGIN_H

#include <QtCore/QObject>
#include <QtCore/QVariantList>

class DevelSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool sshEnabled READ sshEnabled WRITE enableSsh NOTIFY enableSshChanged)
    Q_PROPERTY(bool showTerminal READ terminalShown WRITE setShowTerminal NOTIFY showTerminalChanged)
    Q_PROPERTY(bool visibleCursor READ isCursorVisible WRITE setCursorVisible NOTIFY cursorVisibleChanged)

public:
    DevelSettings(QObject *parent = 0);

    bool sshEnabled() const;
    void enableSsh(bool enable);

    bool terminalShown() const;
    void setShowTerminal(bool show);

    bool isCursorVisible() const;
    void setCursorVisible(bool visible);

Q_SIGNALS:
    void enableSshChanged(bool enabled);
    void showTerminalChanged(bool shown);
    void cursorVisibleChanged(bool visible);

private:
    // platform specific
    void applyCursorTheme(const QByteArray &themeName);
    QString cursorTheme() const;

    bool m_sshEnabled;
    bool m_terminalShown;
    bool m_cursorVisible;
    QString m_terminalApp;
};

class DevelSettingsPlugin : public QObject
{
    Q_OBJECT

public:
    explicit DevelSettingsPlugin(QObject *parent, const QVariantList &list = QVariantList());
    ~DevelSettingsPlugin();
};

#endif // DEVELSETTINGSPLUGIN_H
