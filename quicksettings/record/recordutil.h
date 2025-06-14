// SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>
// SPDX-FileCopyrightText: 2022-2025 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QVariantMap>
#include <qqmlregistration.h>

#include <PipeWireRecord>

class RecordUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString quickSettingText READ quickSettingText NOTIFY quickSettingTextChanged)
    Q_PROPERTY(QString quickSettingStatus READ quickSettingStatus NOTIFY quickSettingStatusChanged)
    Q_PROPERTY(bool isRecording READ isRecording NOTIFY isRecordingChanged)

public:
    RecordUtil(QObject *parent = nullptr);

    Q_INVOKABLE bool startRecording(int nodeId);
    Q_INVOKABLE void stopRecording();

    QString quickSettingText() const;
    QString quickSettingStatus() const;
    bool isRecording() const;

    /**
     * Allows us to get a filename in the standard videos directory (~/Videos by default)
     * with a name that starts with @p name
     *
     * @returns a non-existing path that can be written into
     *
     * @see QStandardPaths::writableLocation()
     * @see KFileUtil::suggestName()
     */
    QString videoLocation(const QString &name);

    void showNotification(const QString &title, const QString &text, const QString &filePath);

Q_SIGNALS:
    void quickSettingTextChanged();
    void quickSettingStatusChanged();
    void isRecordingChanged();

private:
    void updateQuickSettingText();
    void updateQuickSettingStatus();

    void createPipeWireRecord();

    QString m_quickSettingText;
    QString m_quickSettingStatus;

    // Only created when needed
    PipeWireRecord *m_pipeWireRecord{nullptr};
};
