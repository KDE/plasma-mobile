/***************************************************************************
 *   Copyright (C) 2015 Marco Martin <mart@kde.org>                        *
 *   Copyright (C) 2018 Bhushan Shah <bshah@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "phonepanel.h"

#include <qplatformdefs.h>
#include <fcntl.h>
#include <unistd.h>

#include <QDateTime>
#include <QDBusPendingReply>
#include <QFile>
#include <QDebug>
#include <QStandardPaths>
#include <QProcess>
#include <QtConcurrent/QtConcurrent>
#include <QScreen>
#include <unistd.h>

constexpr int SCREENSHOT_DELAY = 200;

/* -- Static Helpers --------------------------------------------------------------------------- */

static int readData(int theFile, QByteArray &theDataOut)
{
    // implementation based on QtWayland file qwaylanddataoffer.cpp
    char    lBuffer[4096];
    int     lRetryCount = 0;
    ssize_t lBytesRead = 0;
    while (true) {
        lBytesRead = QT_READ(theFile, lBuffer, sizeof lBuffer);
        // give user 30 sec to click a window, afterwards considered as error
        if (lBytesRead == -1 && (errno == EAGAIN) && ++lRetryCount < 30000) {
            usleep(1000);
        } else {
            break;
        }
    }

    if (lBytesRead > 0) {
        theDataOut.append(lBuffer, lBytesRead);
        lBytesRead = readData(theFile, theDataOut);
    }
    return lBytesRead;
}

static QImage readImage(int thePipeFd)
{
    QByteArray lContent;
    if (readData(thePipeFd, lContent) != 0) {
        close(thePipeFd);
        return QImage();
    }
    close(thePipeFd);

    QDataStream lDataStream(lContent);
    QImage lImage;
    lDataStream >> lImage;
    return lImage;
}

PhonePanel::PhonePanel(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
{
    //setHasConfigurationInterface(true);
    m_kscreenInterface = new org::kde::KScreen(QStringLiteral("org.kde.kded5"), QStringLiteral("/modules/kscreen"), QDBusConnection::sessionBus(), this);
    m_screenshotInterface = new org::kde::kwin::Screenshot(QStringLiteral("org.kde.KWin"), QStringLiteral("/Screenshot"), QDBusConnection::sessionBus(), this);
}

PhonePanel::~PhonePanel() = default;

void PhonePanel::executeCommand(const QString &command)
{
    qWarning() << "Executing" << command;
    const QStringList commandAndArguments = QProcess::splitCommand(command);
    QProcess::startDetached(commandAndArguments.front(), commandAndArguments.mid(1));
}

void PhonePanel::toggleTorch()
{
    static auto FLASH_SYSFS_PATH = "/sys/devices/platform/led-controller/leds/white:flash/brightness";
    int fd = open(FLASH_SYSFS_PATH, O_WRONLY);

    if (fd < 0) {
        qWarning() << "Unable to open file %s" << FLASH_SYSFS_PATH;
        return;
    }

    write(fd, m_running ? "0" : "1", 1);
    close(fd);
    m_running = !m_running;
}

bool PhonePanel::autoRotate()
{
    QDBusPendingReply<bool> reply = m_kscreenInterface->getAutoRotate();
    reply.waitForFinished();
    if (reply.isError()) {
        qWarning() << "Getting auto rotate failed:" << reply.error().name() << reply.error().message();
        return false;
    } else {
        return reply.value();
    }
}

void PhonePanel::setAutoRotate(bool value)
{
    QDBusPendingReply<> reply = m_kscreenInterface->setAutoRotate(value);
    reply.waitForFinished();
    if (reply.isError()) {
        qWarning() << "Setting auto rotate failed:" << reply.error().name() << reply.error().message();
    } else {
        emit autoRotateChanged(value);
    }
}

void PhonePanel::takeScreenshot()
{
    QString filePath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    if (filePath.isEmpty()) {
        qWarning() << "Couldn't find a writable location for the screenshot!";
        return;
    }
    QDir picturesDir(filePath);
    if (!picturesDir.mkpath(QStringLiteral("Screenshots"))) {
        qWarning() << "Couldn't create folder at"
                << picturesDir.path() + QStringLiteral("/Screenshots")
                << "to take screenshot.";
        return;
    }
    filePath += QStringLiteral("/Screenshots/Screenshot_%1.png").arg(QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_hhmmss")));

    // wait ~200 ms to wait for rest of animations
    QTimer::singleShot(SCREENSHOT_DELAY, [=]() {
        int lPipeFds[2];
        if (pipe2(lPipeFds, O_CLOEXEC|O_NONBLOCK) != 0) {
            qWarning() << "Could not take screenshot";
            return;
        }
        // Take fullscreen screenshot, and no pointer
        QDBusPendingCall pcall = m_screenshotInterface->screenshotFullscreen(QDBusUnixFileDescriptor(lPipeFds[1]), false, true);
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pcall, this);
        QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [](QDBusPendingCallWatcher* watcher) {
            if (watcher->isError()) {
                const auto error = watcher->error();
                qWarning() << "Error calling KWin DBus interface:" << error.name() << error.message();
            }
            watcher->deleteLater();
        });
        const auto lWatcher = new QFutureWatcher<QImage>(this);
            QObject::connect(lWatcher, &QFutureWatcher<QImage>::finished, this,
            [lWatcher, filePath] () {
                lWatcher->deleteLater();
                const QImage lImage = lWatcher->result();
                qDebug() << lImage;
                if(!lImage.save(filePath, "PNG")) {
                    qWarning() << "Failed to save screenshot to" << filePath;
                }
            }
        );
        lWatcher->setFuture(QtConcurrent::run(readImage, lPipeFds[0]));
        close(lPipeFds[1]);
    });
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(quicksettings, PhonePanel, "metadata.json")

#include "phonepanel.moc"
