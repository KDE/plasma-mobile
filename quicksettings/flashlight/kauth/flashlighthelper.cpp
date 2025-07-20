/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "flashlighthelper_debug.h"

#include <KAuth/ActionReply>
#include <KAuth/HelperSupport>

#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QLoggingCategory>
#include <QObject>

#include <libudev.h>

using namespace Qt::StringLiterals;

class Flashlighthelper : public QObject
{
    Q_OBJECT
public Q_SLOTS:
    KAuth::ActionReply setbrightness(const QVariantMap &args);
};

KAuth::ActionReply Flashlighthelper::setbrightness(const QVariantMap &args)
{
    const char *sysPath = args.value("sysPath"_L1).toString().toUtf8().constData();
    const char *brightness = args.value("brightness"_L1).toString().toUtf8().constData();

    struct udev *udev = udev_new();
    struct udev_device *device = udev_device_new_from_syspath(udev, sysPath);

    int ret = udev_device_set_sysattr_value(device, "brightness", const_cast<char *>(brightness));

    udev_device_unref(device);
    udev_unref(udev);

    if (ret >= 0) {
        return KAuth::ActionReply::SuccessReply();
    } else {
        qCWarning(FLASHLIGHTHELPER) << "Failed to set udev system attribute";
        return KAuth::ActionReply::HelperErrorReply();
    }
}

KAUTH_HELPER_MAIN("org.kde.plasma.mobileshell.flashlighthelper", Flashlighthelper)

#include "flashlighthelper.moc"