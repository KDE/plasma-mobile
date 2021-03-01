/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef PHONEPANEL_H
#define PHONEPANEL_H


#include <Plasma/Containment>

#include "kscreeninterface.h"
#include "screenshotinterface.h"

class PhonePanel : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(bool autoRotateEnabled READ autoRotate WRITE setAutoRotate NOTIFY autoRotateChanged);
    Q_PROPERTY(bool torchEnabled READ torchEnabled NOTIFY torchChanged);
public:
    PhonePanel( QObject *parent, const QVariantList &args );
    ~PhonePanel() override;

public Q_SLOTS:
    void executeCommand(const QString &command);
    void toggleTorch();
    void takeScreenshot();

    bool autoRotate();
    void setAutoRotate(bool value);
    
    bool torchEnabled() const;

signals:
    void autoRotateChanged(bool value);
    void torchChanged(bool value);

private:
    bool m_running = false;

    org::kde::KScreen *m_kscreenInterface;
    org::kde::kwin::Screenshot *m_screenshotInterface;
};

#endif
