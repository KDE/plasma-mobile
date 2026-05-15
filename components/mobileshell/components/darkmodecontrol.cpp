/*
 *  SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2026 Florian Richer <florian.richer@protonmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "darkmodecontrol.h"

#include <QProcess>

using namespace Qt::StringLiterals;

#define GROUP_NAME u"General"_s
#define GROUP_ENTRY u"ColorScheme"_s

DarkModeControl::DarkModeControl(QObject *parent)
    : QObject(parent)
    , m_colorsSettings(ColorsSettings::self())
{
    m_globalConfigWatcher = KConfigWatcher::create(m_colorsSettings->sharedConfig());

    // set property initially
    m_darkMode = m_colorsSettings->colorScheme() == "BreezeDark";

    connect(m_globalConfigWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &) {
        if (group.name() == GROUP_NAME) {
            m_darkMode = group.readEntry(GROUP_ENTRY) == "BreezeDark";
            Q_EMIT darkModeChanged();
        }
    });
}

bool DarkModeControl::darkMode() const
{
    return m_darkMode;
}

void DarkModeControl::setDarkMode(const bool darkMode)
{
    // use plasma-apply-colorscheme since it has logic for notifying the shell of changes
    if (darkMode) {
        QProcess::execute("plasma-apply-colorscheme", {u"BreezeDark"_s});
    } else {
        QProcess::execute("plasma-apply-colorscheme", {u"BreezeLight"_s});
    }

    m_darkMode = darkMode;
    Q_EMIT darkModeChanged();
}
