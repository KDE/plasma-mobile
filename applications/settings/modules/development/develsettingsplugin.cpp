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

#include <QDBusInterface>
#include <QFile>
#include <QProcess>
#include <QtDeclarative/QDeclarativeItem>
#include <QTimer>

#include <KAuth/Action>
#include <KConfig>
#include <KConfigGroup>
#include <KDebug>
#include <KDesktopFile>
#include <KGlobal>
#include <KPluginFactory>
#include <KService>
#include <KSycoca>

//FIXME: hardcoded strings! *groan*
const QByteArray visibleCursorTheme("Oxygen_White");
const QByteArray noCursorTheme("plasmamobilemouse");
const QString terminalApp("");
DevelSettings::DevelSettings(QObject *parent)
    : QObject(parent)
{
    m_cursorVisible = (cursorTheme() != noCursorTheme);

    // TODO: should probably not rely on systemctl, but be put into a platform specific backend?
    const int rv = QProcess::execute("systemctl is-enabled sshd.service");
    m_sshEnabled = rv == 0;

    m_terminalShown = false;
    KConfigGroup confGroup(KGlobal::config(), "General");
    m_terminalApp = confGroup.readPathEntry("TerminalApplication", QString::fromLatin1("konsole"));
    KService::Ptr service = KService::serviceByStorageId(m_terminalApp);
    kDebug() << "showing?" << service->noDisplay();
    m_terminalShown = service && !service->noDisplay();

    m_integrationEnabled = confGroup.readEntry("IntegrationEnabled", false);
}

bool DevelSettings::sshEnabled() const
{
    return m_sshEnabled;
}

void DevelSettings::enableSsh(bool enable)
{
    if (m_sshEnabled != enable) {
        const bool was = m_sshEnabled;
        m_sshEnabled = enable;

        //TODO: this really should be non-blocking ...
        KAuth::Action action(m_sshEnabled ? "org.kde.active.sshdcontrol.start"
                                          : "org.kde.active.sshdcontrol.stop");
        action.setHelperID("org.kde.active.sshdcontrol");

        kDebug() << "Action" << action.name() << action.details() << "valid:" << action.isValid();

        KAuth::ActionReply reply = action.execute();
        if (reply.failed()) {
            m_sshEnabled = !m_sshEnabled;
            kWarning()<< "KAuth returned an error code:" << reply.errorCode() << m_sshEnabled;
        }

        if (was != m_sshEnabled) {
            emit enableSshChanged(m_sshEnabled);
        }
    }
}

bool DevelSettings::terminalShown() const
{
    return m_terminalShown;
}

void DevelSettings::setShowTerminal(bool show)
{
    if (m_terminalShown != show) {
        m_terminalShown = show;
        KService::Ptr service = KService::serviceByStorageId(m_terminalApp);
        if (!service) {
            //TODO: if not installed, install it
            return;
        }

        if (show) {
            QFile::remove(service->locateLocal());
        } else {
            KDesktopFile file(service->locateLocal());
            KConfigGroup dg = file.desktopGroup();
            dg.writeEntry("Exec", m_terminalApp);
            dg.writeEntry("NoDisplay", !show);
        }

        if (KSycoca::isAvailable()) {
            QDBusInterface dbus("org.kde.kded", "/kbuildsycoca", "org.kde.kbuildsycoca");
            dbus.call(QDBus::NoBlock, "recreate");
        }

        emit showTerminalChanged(m_terminalShown);
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
        applyCursorTheme(m_cursorVisible ? visibleCursorTheme : noCursorTheme);
        emit cursorVisibleChanged(m_cursorVisible);
    }
}

void DevelSettings::setIntegrationEnabled(bool enable)
{
    if (m_integrationEnabled != enable) {
        const bool was = m_integrationEnabled;
        m_integrationEnabled = enable;

        //TODO: this really should be non-blocking ...
        KAuth::Action action(m_integrationEnabled ? "org.kde.active.integrationcontrol.enable"
                                          : "org.kde.active.integrationcontrol.disable");
        action.setHelperID("org.kde.active.integrationcontrol");

        kDebug() << "Action" << action.name() << action.details() << "valid:" << action.isValid();
        KAuth::ActionReply reply = action.execute();
        if (reply.failed()) {
            m_integrationEnabled = !m_integrationEnabled;
            kWarning()<< "KAuth returned an error code:" << reply.errorCode()  << reply.errorDescription() << "enabled" << m_integrationEnabled;
        }

        if (was != m_integrationEnabled) {
            KConfigGroup confGroup(KGlobal::config(), "General");
            confGroup.writeEntry("IntegrationEnabled", m_integrationEnabled);
            emit enableIntegrationChanged(m_integrationEnabled);
        }
    }
}

bool DevelSettings::isIntegrationEnabled()
{
    return m_integrationEnabled;
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
