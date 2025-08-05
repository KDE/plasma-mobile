// SPDX-FileCopyrightText: 2025 Sebastian Kügler <sebas@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "kscreenosdutil.h"

#include <kscreen/configmonitor.h>
#include <kscreen/getconfigoperation.h>
#include <kscreen/output.h>

#include <QDebug>
#include <QDBusInterface>
#include <QDBusReply>

KScreenOSDUtil::KScreenOSDUtil(QObject *parent)
    : QObject{parent}
{
    connect(KScreen::ConfigMonitor::instance(), &KScreen::ConfigMonitor::configurationChanged, this, [this]() {
        setOutputs(m_config->outputs().size());
    });

    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this](auto *op) {
        m_config = qobject_cast<KScreen::GetConfigOperation *>(op)->config();
        KScreen::ConfigMonitor::instance()->addConfig(m_config);
        setOutputs(m_config->outputs().size());
    });
}

void KScreenOSDUtil::setOutputs(int _outputs)
{
    if (_outputs != m_outputs) {
        m_outputs = _outputs;
        Q_EMIT outputsChanged();
    }
}

int KScreenOSDUtil::outputs() const
{
    return m_outputs;
}

void KScreenOSDUtil::showKScreenOSD()
{
    // This is equivalent to this call from the command line:
    // busctl --user call org.kde.kscreen.osdService /org/kde/kscreen/osdService org.kde.kscreen.osdService showActionSelector
    QDBusMessage msg = QDBusMessage::createMethodCall(
        "org.kde.kscreen.osdService",      // service
        "/org/kde/kscreen/osdService",     // object path
        "org.kde.kscreen.osdService",      // interface
        "showActionSelector"               // method
    );

    auto pendingCall = QDBusConnection::sessionBus().asyncCall(msg);
}
