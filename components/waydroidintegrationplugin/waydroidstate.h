/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include "waydroidapplicationlistmodel.h"

#include <QObject>

#include <qqmlregistration.h>
#include <qtmetamacros.h>

class WaydroidApplicationListModel;

/**
 * This class provides an interface to interact with the Waydroid container,
 * including session management and property configuration.
 *
 * @author Florian RICHER <florian.richer@protonmail.com>
 */
class WaydroidState : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(SessionStatus sessionStatus READ sessionStatus NOTIFY sessionStatusChanged)
    Q_PROPERTY(SystemType systemType READ systemType NOTIFY systemTypeChanged)
    Q_PROPERTY(QString ipAddress READ ipAddress NOTIFY ipAddressChanged)
    Q_PROPERTY(QString androidId READ androidId NOTIFY androidIdChanged)
    Q_PROPERTY(QString errorTitle READ errorTitle NOTIFY errorTitleChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(bool multiWindows READ multiWindows WRITE setMultiWindows NOTIFY multiWindowsChanged)
    Q_PROPERTY(bool suspend READ suspend WRITE setSuspend NOTIFY suspendChanged)
    Q_PROPERTY(bool uevent READ uevent WRITE setUevent NOTIFY ueventChanged)
    Q_PROPERTY(WaydroidApplicationListModel *applicationListModel READ applicationListModel CONSTANT)

public:
    WaydroidState(QObject *parent = nullptr);

    /**
     * @enum Status
     * @brief Defines the possible installation statuses of the Waydroid service.
     */
    enum Status {
        NotSupported = 0,
        NotInitialized,
        Initializing,
        Initialized
    };
    Q_ENUM(Status)

    /**
     * @enum SessionStatus
     * @brief Defines the possible states of a Waydroid session.
     */
    enum SessionStatus {
        SessionStopped = 0,
        SessionStarting,
        SessionRunning
    };
    Q_ENUM(SessionStatus)

    /**
     * @enum SystemType
     * @brief Defines the types of Android systems supported by Waydroid.
     */
    enum SystemType {
        Vanilla = 0, ///< Vanilla Android system.
        Foss, ///< Free and Open Source Software variant.
        Gapps, ///< Variant with Google Apps included.
        UnknownSystemType
    };
    Q_ENUM(SystemType)

    /**
     * @enum RomType
     * @brief Defines the types of ROMs supported by Waydroid.
     *
     * @todo Add OTA ROM with custom system url and vendor url
     */
    enum RomType {
        Lineage = 0, ///< LineageOS ROM.
        Bliss ///< Bliss ROM.
    };
    Q_ENUM(RomType)

    Q_INVOKABLE void refreshSupportsInfo();
    Q_INVOKABLE void refreshInstallationInfo();
    Q_INVOKABLE void refreshSessionInfo();
    Q_INVOKABLE void refreshAndroidId();
    Q_INVOKABLE void refreshPropsInfo();
    Q_INVOKABLE void resetError();
    Q_INVOKABLE void initialize(const SystemType systemType, const RomType romType, const bool forced = false);
    Q_INVOKABLE void startSession();
    Q_INVOKABLE void stopSession();
    Q_INVOKABLE void copyToClipboard(const QString text);

    Status status() const;
    SessionStatus sessionStatus() const;
    SystemType systemType() const;
    QString ipAddress() const;
    QString androidId() const;
    QString errorTitle() const;
    QString errorMessage() const;
    WaydroidApplicationListModel *applicationListModel() const;

    bool multiWindows() const;
    void setMultiWindows(const bool multiWindows);
    bool suspend() const;
    void setSuspend(const bool suspend);
    bool uevent() const;
    void setUevent(const bool uevent);

Q_SIGNALS:
    void statusChanged();
    // download and total is in MB and speed in Kbps
    void downloadStatusChanged(float downloaded, float total, float speed);
    void sessionStatusChanged();
    void systemTypeChanged();
    void ipAddressChanged();
    void multiWindowsChanged();
    void suspendChanged();
    void ueventChanged();
    void errorTitleChanged();
    void errorMessageChanged();
    void androidIdChanged();

private:
    Status m_status{NotInitialized};
    SessionStatus m_sessionStatus{SessionStopped};
    SystemType m_systemType{SystemType::UnknownSystemType};
    QString m_ipAddress{""};
    QString m_errorTitle{""};
    QString m_errorMessage{""};
    QString m_androidId{""};
    WaydroidApplicationListModel *m_applicationListModel{nullptr};

    // Waydroid props. See https://docs.waydro.id/usage/waydroid-prop-options
    bool m_multiWindows{false};
    bool m_suspend{false};
    bool m_uevent{false};

    /**
     * @brief Executes the command to retrieve the current session status and related
     * information from Waydroid.
     *
     * @return A QString containing the output of the Waydroid session status command.
     */
    QString fetchSessionInfo();

    /**
     * @brief Executes the command to retrieve the value of a specified property from the Waydroid container.
     *
     * @param key The key of the property to fetch.
     * @param defaultValue The default value to return if the property is not found or empty.
     * @return A QString containing the property value, or the defaultValue if not found.
     */
    QString fetchPropValue(const QString key, const QString defaultValue);

    /**
     * @brief Executes the command to writes a value to a specified property in the Waydroid container.
     *
     * @param key The key of the property to set.
     * @param value The value to write to the property.
     * @return A boolean indicating whether the write operation was successful.
     */
    bool writePropValue(const QString key, const QString value);

    /**
     * @brief Extracts text from a string using a regular expression pattern.
     *
     * @param text The text to search within.
     * @param regExp The regular expression pattern to use for extraction.
     * @return A QString containing the extracted text if a match is found; otherwise, an empty string.
     */
    QString extractRegExp(const QString text, const QRegularExpression regExp) const;

    /**
     * @brief Checks every 500ms if the session has started.
     *
     * This function periodically checks whether a session has started. If the session starts,
     * it emits a "Running" signal. If the check count reaches the specified limit without
     * the session starting, it emits a "Stopped" signal and logs a warning message.
     *
     * @param limit The maximum number of attempts to check for session start before stopping.
     * @param tried The current number of attempts made to check for session start (defaults to 0).
     *
     * @todo Investigate using DBus for a cleaner implementation, potentially using the method:
     *       id.waydro.Container /ContainerManager id.waydro.ContainerManager.Start(a{ss} session).
     *       This would require duplicating the session start command logic from:
     *       https://github.com/waydroid/waydroid/blob/2c41162d8bfef5bf83333a6ce4834af0c3c2b535/tools/actions/session_manager.py#L31
     */
    void checkSessionStarting(const int limit, const int tried = 0);
};
