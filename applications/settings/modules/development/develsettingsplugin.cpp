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

#include "develsettingsplugin.h"

#include <QtDeclarative/QDeclarativeItem>

#include <KAuth/Action>
#include <KDebug>
#include <KPluginFactory>

DevelSettings::DevelSettings(QObject *parent)
    : QObject(parent)
{
    // read settings
}

bool DevelSettings::sshEnabled() const
{
    return m_sshEnabled;
}

void DevelSettings::enableSsh(bool enable)
{
    if (m_sshEnabled != enable) {
        m_sshEnabled = enable;
        emit enableSshChanged(m_sshEnabled);

        //FIXME: this really should be non-blocking ...
        KAuth::Action action(m_sshEnabled ? "org.kde.active.sshdcontrol.start"
                                          : "org.kde.active.sshdcontrol.stop");
        action.setHelperID("org.kde.active.sshdcontrol");

        KAuth::ActionReply reply = action.execute();
        if (reply.failed()) {
            m_sshEnabled = !m_sshEnabled;
            emit enableSshChanged(m_sshEnabled);
            kWarning()<< "KAuth returned an error code:" << reply.errorCode();
        }
    }
}

bool DevelSettings::konsoleShown() const
{
    return m_konsoleShown;
}

void DevelSettings::setShowKonsole(bool show)
{
    if (m_konsoleShown != show) {
        m_konsoleShown = show;
        //TODO save setting
        emit showKonsoleChanged(m_konsoleShown);
    }
}

bool DevelSettings::isCursorVisible() const
{
    return m_cursorVisible;
}

void DevelSettings::setCursorVisible(bool visible)
{
    if (m_cursorVisible != visible) {
        m_cursorVisible = visible;
        //TODO save setting
        emit cursorVisibleChanged(m_cursorVisible);
    }
}

DevelSettingsPlugin::DevelSettingsPlugin(QObject *parent, const QVariantList &list)
    : QObject(parent)
{
    Q_UNUSED(list)
    qmlRegisterType<DevelSettings>("org.kde.active.settings", 0, 1, "DevelSettings");
}

DevelSettingsPlugin::~DevelSettingsPlugin()
{
}

K_PLUGIN_FACTORY(DevelSettingsFactory, registerPlugin<DevelSettingsPlugin>();)
K_EXPORT_PLUGIN(DevelSettingsFactory("active_settings_devel"))

#include "develsettingsplugin.moc"
