/*
 * SPDX-FileCopyrightText: 2026 Florian RICHER <florian.richer@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "grayscaleutil.h"

#include <QDBusConnection>
#include <QDBusInterface>

#define KWIN_CONFIG_FILE u"kwinrc"_s
#define KWIN_PLUGINS_GROUP u"Plugins"_s
#define KWIN_PLUGINS_ENTRY u"colorblindnesscorrectionEnabled"_s
#define KWIN_EFFECT_NAME u"colorblindnesscorrection"_s
#define KWIN_EFFECT_GROUP u"Effect-colorblindnesscorrection"_s
#define KWIN_EFFECT_MODE_ENTRY u"Mode"_s
#define KWIN_EFFECT_INTENSITY_ENTRY u"Intensity"_s

using namespace Qt::StringLiterals;

GrayscaleUtil::GrayscaleUtil(QObject *parent)
    : QObject(parent)
    , m_config(KSharedConfig::openConfig(KWIN_CONFIG_FILE))
{
    m_configWatcher = KConfigWatcher::create(m_config);
    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &) {
        if (group.name() == KWIN_PLUGINS_GROUP || group.name() == KWIN_EFFECT_GROUP) {
            loadConfig();
        }
    });

    loadConfig();
}

GrayscaleUtil::~GrayscaleUtil()
{
}

void GrayscaleUtil::grayscaleToggle()
{
    KConfigGroup effectGroup = m_config->group(KWIN_EFFECT_GROUP);

    if (!m_enabled) {
        effectGroup.writeEntry(KWIN_EFFECT_MODE_ENTRY, "3"); // Can be defined to another value so override to 3 (Grayscale effect)
        effectGroup.writeEntry(KWIN_EFFECT_INTENSITY_ENTRY, "1.0"); // Can be defined to another value so override to 1.0
    }
    m_config->sync();

    QDBusMessage msg;
    if (m_enabled) {
        msg = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Effects"_s, u"org.kde.kwin.Effects"_s, u"unloadEffect"_s);
    } else {
        msg = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Effects"_s, u"org.kde.kwin.Effects"_s, u"loadEffect"_s);
    }

    QVariantList args;
    args << KWIN_EFFECT_NAME;
    msg.setArguments(args);

    QDBusConnection::sessionBus().send(msg);

    m_enabled = !m_enabled;
    Q_EMIT grayscaleChanged();
}

bool GrayscaleUtil::grayscaleEnabled() const
{
    return m_enabled;
}

void GrayscaleUtil::loadConfig()
{
    KConfigGroup pluginsGroup = m_config->group(KWIN_PLUGINS_GROUP);
    QString pluginsValue = pluginsGroup.readEntry(KWIN_PLUGINS_ENTRY);
    if (pluginsValue != "true") {
        m_enabled = false;
        Q_EMIT grayscaleChanged();
        return;
    }

    KConfigGroup effectGroup = m_config->group(KWIN_EFFECT_GROUP);
    QString modeValue = effectGroup.readEntry(KWIN_EFFECT_MODE_ENTRY);

    if (modeValue != "3") {
        m_enabled = false;
        Q_EMIT grayscaleChanged();
    }

    m_enabled = true;
    Q_EMIT grayscaleChanged();
}
