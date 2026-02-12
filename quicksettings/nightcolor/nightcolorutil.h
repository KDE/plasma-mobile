/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <qqmlregistration.h>

#include "nightcolorsettings.h"
#include "nightlightinterface.h"

class NightColorUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    NightColorUtil(QObject *parent = nullptr);

    bool enabled();
    void setEnabled(bool enabled);

Q_SIGNALS:
    void enabledChanged();

public Q_SLOTS:
    void enabledUpdated(const QString &name, const QVariantMap &map, const QStringList &list);

private:
    bool m_enabled;
    OrgKdeKWinNightLightInterface *m_ccInterface;
    NightColorSettings *m_settings;
};
