/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef PHONEPANEL_H
#define PHONEPANEL_H

#include <Plasma/Containment>

#include <KConfigWatcher>
#include <KSharedConfig>

#include "kscreeninterface.h"
#include "screenshotinterface.h"

class PhonePanel : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(bool autoRotateEnabled READ autoRotate WRITE setAutoRotate NOTIFY autoRotateChanged);
    Q_PROPERTY(bool torchEnabled READ torchEnabled NOTIFY torchChanged);
    Q_PROPERTY(bool isSystem24HourFormat READ isSystem24HourFormat NOTIFY isSystem24HourFormatChanged);

public:
    PhonePanel(QObject *parent, const QVariantList &args);
    ~PhonePanel() override;

public Q_SLOTS:
    void executeCommand(const QString &command);
    void toggleTorch();
    void takeScreenshot();

    bool autoRotate();
    void setAutoRotate(bool value);

    bool torchEnabled() const;

    bool isSystem24HourFormat();

signals:
    void autoRotateChanged(bool value);
    void torchChanged(bool value);
    void isSystem24HourFormatChanged();

private:
    bool m_running = false;

    KConfigWatcher::Ptr m_localeConfigWatcher;
    KSharedConfig::Ptr m_localeConfig;

    org::kde::KScreen *m_kscreenInterface;
    org::kde::kwin::Screenshot *m_screenshotInterface;
};

#endif
