// SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>
// SPDX-FileCopyrightText: 2022-2025 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "recordutil.h"

#include <QDir>
#include <QFile>
#include <QStandardPaths>

#include <KFileUtils>
#include <KLocalizedString>
#include <KNotification>

using namespace Qt::StringLiterals;

RecordUtil::RecordUtil(QObject *parent)
    : QObject{parent}
{
    updateQuickSettingText();
    updateQuickSettingStatus();
}

bool RecordUtil::startRecording(int nodeId)
{
    if (!m_pipeWireRecord) {
        createPipeWireRecord();
    }

    if (m_pipeWireRecord->isActive()) {
        return false;
    }

    // Set an encoder from what's available
    m_pipeWireRecord->setEncoder(m_pipeWireRecord->suggestedEncoders().value(0, PipeWireRecord::NoEncoder));

    switch (m_pipeWireRecord->encoder()) {
    case PipeWireRecord::H264Main:
    case PipeWireRecord::H264Baseline:
        m_pipeWireRecord->setOutput(videoLocation("screen-recording.mp4"));
        break;
    case PipeWireRecord::VP8:
    case PipeWireRecord::VP9:
        m_pipeWireRecord->setOutput(videoLocation("screen-recording.webm"));
        break;
    case PipeWireRecord::WebP:
        m_pipeWireRecord->setOutput(videoLocation("screen-recording.webp"));
        break;
    case PipeWireRecord::Gif:
        m_pipeWireRecord->setOutput(videoLocation("screen-recording.gif"));
        break;
    case PipeWireRecord::NoEncoder:
    default:
        m_quickSettingStatus = i18n("No encoders available for recording");
        Q_EMIT quickSettingStatusChanged();
        qWarning() << "No video encoders available for screen recording!";
        return false;
    }

    m_pipeWireRecord->setNodeId(nodeId);
    m_pipeWireRecord->start();

    qDebug() << "Started recording screen with nodeId" << nodeId << "to file" << m_pipeWireRecord->output() << videoLocation("screen-recording.webm");
    return true;
}

void RecordUtil::stopRecording()
{
    if (!m_pipeWireRecord) {
        return;
    }
    if (!m_pipeWireRecord->isActive()) {
        return;
    }

    m_pipeWireRecord->stop();
    showNotification(i18n("New Screen Recording"), i18n("New Screen Recording saved in %1", m_pipeWireRecord->output()), m_pipeWireRecord->output());
}

QString RecordUtil::quickSettingText() const
{
    return m_quickSettingText;
}

QString RecordUtil::quickSettingStatus() const
{
    return m_quickSettingStatus;
}

bool RecordUtil::isRecording() const
{
    if (!m_pipeWireRecord) {
        return false;
    }

    return m_pipeWireRecord->isActive();
}

QString RecordUtil::videoLocation(const QString &name)
{
    const QString path = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
    if (!QDir(path).mkpath(u"."_s)) {
        qWarning() << "Unable to create directory" << path;
    }
    QString newPath(path + '/' + name);
    if (QFile::exists(newPath)) {
        newPath = path + '/' + KFileUtils::suggestName(QUrl::fromLocalFile(newPath), name);
    }
    return newPath;
}

void RecordUtil::showNotification(const QString &title, const QString &text, const QString &filePath)
{
    KNotification *notif = new KNotification("captured");
    notif->setComponentName(QStringLiteral("plasma_mobile_quicksetting_record"));
    notif->setTitle(title);
    notif->setUrls({QUrl::fromLocalFile(filePath)});
    notif->setText(text);
    notif->sendEvent();
}

void RecordUtil::updateQuickSettingText()
{
    QString defaultText = i18nc("@action:button", "Record Screen");
    if (!m_pipeWireRecord) {
        m_quickSettingText = defaultText;
        Q_EMIT quickSettingTextChanged();
        return;
    }

    switch (m_pipeWireRecord->state()) {
    case PipeWireRecord::Recording:
        m_quickSettingText = i18nc("@info:status", "Recording…");
        break;
    case PipeWireRecord::Rendering:
        m_quickSettingText = i18nc("@info:status", "Writing…");
        break;
    case PipeWireRecord::Idle:
    default:
        m_quickSettingText = defaultText;
        break;
    }

    Q_EMIT quickSettingTextChanged();
}

void RecordUtil::updateQuickSettingStatus()
{
    QString defaultText = i18n("Tap to start recording");

    if (!m_pipeWireRecord) {
        m_quickSettingStatus = defaultText;
        Q_EMIT quickSettingStatusChanged();
        return;
    }

    switch (m_pipeWireRecord->state()) {
    case PipeWireRecord::Recording:
        m_quickSettingStatus = i18n("Screen is being captured…");
        break;
    case PipeWireRecord::Rendering:
        m_quickSettingStatus = i18n("Please wait…");
        break;
    case PipeWireRecord::Idle:
    default:
        m_quickSettingStatus = defaultText;
        break;
    }

    Q_EMIT quickSettingStatusChanged();
}

void RecordUtil::createPipeWireRecord()
{
    m_pipeWireRecord = new PipeWireRecord{this};

    connect(m_pipeWireRecord, &PipeWireRecord::stateChanged, this, &RecordUtil::updateQuickSettingText);
    connect(m_pipeWireRecord, &PipeWireRecord::stateChanged, this, &RecordUtil::updateQuickSettingStatus);
    connect(m_pipeWireRecord, &PipeWireRecord::activeChanged, this, &RecordUtil::isRecordingChanged);
}
