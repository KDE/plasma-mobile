// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QCoreApplication>
#include <QObject>
#include <QString>
#include <QTimer>

#include <KJob>

#pragma once

class NotificationTest : public QObject
{
    Q_OBJECT
public:
    explicit NotificationTest(QObject *parent = nullptr);
    virtual ~NotificationTest() = default;
    virtual QString name() const = 0;
    virtual void sendNotification(QCoreApplication &app) = 0;
};

class BasicNotificationTest : public NotificationTest
{
    Q_OBJECT
public:
    QString name() const override
    {
        return QStringLiteral("basic");
    }
    void sendNotification(QCoreApplication &app) override;
};

class UrlNotificationTest : public NotificationTest
{
    Q_OBJECT
public:
    QString name() const override
    {
        return QStringLiteral("url");
    }
    void sendNotification(QCoreApplication &app) override;
};

class ReplyNotificationTest : public NotificationTest
{
    Q_OBJECT
public:
    QString name() const override
    {
        return QStringLiteral("reply");
    }
    void sendNotification(QCoreApplication &app) override;
};

class LowUrgencyNotificationTest : public NotificationTest
{
    Q_OBJECT
public:
    QString name() const override
    {
        return QStringLiteral("lowUrgency");
    }
    void sendNotification(QCoreApplication &app) override;
};

class HighUrgencyNotificationTest : public NotificationTest
{
    Q_OBJECT
public:
    QString name() const override
    {
        return QStringLiteral("highUrgency");
    }
    void sendNotification(QCoreApplication &app) override;
};

class CriticalUrgencyNotificationTest : public NotificationTest
{
    Q_OBJECT
public:
    QString name() const override
    {
        return QStringLiteral("criticalUrgency");
    }
    void sendNotification(QCoreApplication &app) override;
};

class FakeJob : public KJob
{
    Q_OBJECT
public:
    explicit FakeJob(QObject *parent = nullptr);
    void start() override;

private Q_SLOTS:
    void timerFinished();

private:
    double m_progress{0};
    QTimer *m_timer{nullptr};
};

class JobNotificationTest : public NotificationTest
{
    Q_OBJECT

public:
    QString name() const override
    {
        return QStringLiteral("job");
    }
    void sendNotification(QCoreApplication &app) override;
};
