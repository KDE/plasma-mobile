/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>

#include <KConfigWatcher>
#include <KSharedConfig>

#include "kscreeninterface.h"
#include "screenshot2interface.h"

#include "mobileshell_export.h"

namespace MobileShell
{

class MOBILESHELL_EXPORT ShellUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool autoRotateEnabled READ autoRotate WRITE setAutoRotate NOTIFY autoRotateChanged);
    Q_PROPERTY(bool torchEnabled READ torchEnabled NOTIFY torchChanged);
    Q_PROPERTY(bool isSystem24HourFormat READ isSystem24HourFormat NOTIFY isSystem24HourFormatChanged);

public:
    ShellUtil(QObject *parent = nullptr);
    ~ShellUtil() override;
    static ShellUtil *instance();

public Q_SLOTS:
    void executeCommand(const QString &command);
    void launchApp(const QString &app);
    void toggleTorch();
    void takeScreenshot();

    bool autoRotate();
    void setAutoRotate(bool value);

    bool torchEnabled() const;

    bool isSystem24HourFormat();

Q_SIGNALS:
    void autoRotateChanged(bool value);
    void torchChanged(bool value);
    void isSystem24HourFormatChanged();

private:
    void handleMetaDataReceived(const QVariantMap &metadata, int fd);
    bool m_running = false;

    KConfigWatcher::Ptr m_localeConfigWatcher;
    KSharedConfig::Ptr m_localeConfig;

    org::kde::KScreen *m_kscreenInterface;
    OrgKdeKWinScreenShot2Interface *m_screenshotInterface;
};

} // namespace MobileShell
