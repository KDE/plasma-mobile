// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <KJob>
#include <KNotification>
#include <KNotificationJobUiDelegate>
#include <KNotificationReplyAction>
#include <KUiServerV2JobTracker>

#include <stdlib.h>

#include "tests.h"

NotificationTest::NotificationTest(QObject *parent)
    : QObject{parent}
{
}

void BasicNotificationTest::sendNotification(QCoreApplication &app)
{
    KNotification *notification = new KNotification(QStringLiteral("notificationTest"));
    notification->setComponentName(QStringLiteral("plasma_mobile_notificationtest"));
    notification->setIconName(QStringLiteral("notification-active"));
    notification->setText("This is a test notification!");
    auto action = notification->addAction("Action!");
    Q_UNUSED(action)

    connect(notification, &KNotification::closed, &app, QCoreApplication::quit);
    notification->sendEvent();
}

void UrlNotificationTest::sendNotification(QCoreApplication &app)
{
    KNotification *notification = new KNotification(QStringLiteral("notificationTest"));
    notification->setComponentName(QStringLiteral("plasma_mobile_notificationtest"));
    notification->setTitle("Web link");
    notification->setText("I like links!");
    notification->setUrls({QUrl{"file:/usr/share/wallpapers/Next/contents/images/1920x1080.png"}});

    connect(notification, &KNotification::closed, &app, QCoreApplication::quit);
    notification->sendEvent();
}

void ReplyNotificationTest::sendNotification(QCoreApplication &app)
{
    KNotification *notification = new KNotification(QStringLiteral("notificationTest"));
    notification->setComponentName(QStringLiteral("plasma_mobile_notificationtest"));
    notification->setIconName(QStringLiteral("avatar-default-symbolic"));
    notification->setTitle("John");
    notification->setText("This is great news! Let's meet up tomorrow!");

    auto replyAction = std::make_unique<KNotificationReplyAction>("Reply");
    replyAction->setPlaceholderText("Reply to John...");
    QObject::connect(replyAction.get(), &KNotificationReplyAction::replied, [](const QString &text) {
        qDebug() << "you replied with" << text;
    });
    notification->setReplyAction(std::move(replyAction));

    connect(notification, &KNotification::closed, &app, QCoreApplication::quit);
    notification->sendEvent();
}

void LowUrgencyNotificationTest::sendNotification(QCoreApplication &app)
{
    KNotification *notification = new KNotification(QStringLiteral("notificationTest"));
    notification->setComponentName(QStringLiteral("plasma_mobile_notificationtest"));
    notification->setIconName(QStringLiteral("notification-inactive"));
    notification->setTitle("Low Urgency Notification");
    notification->setText("This is not very important...");
    notification->setUrgency(KNotification::CriticalUrgency);

    connect(notification, &KNotification::closed, &app, QCoreApplication::quit);
    notification->sendEvent();
}

void HighUrgencyNotificationTest::sendNotification(QCoreApplication &app)
{
    KNotification *notification = new KNotification(QStringLiteral("notificationTest"));
    notification->setComponentName(QStringLiteral("plasma_mobile_notificationtest"));
    notification->setIconName(QStringLiteral("notification-active"));
    notification->setTitle("Urgent Notification");
    notification->setText("This is very urgent! AAAAAA");
    notification->setUrgency(KNotification::CriticalUrgency);

    connect(notification, &KNotification::closed, &app, QCoreApplication::quit);
    notification->sendEvent();
}

void CriticalUrgencyNotificationTest::sendNotification(QCoreApplication &app)
{
    KNotification *notification = new KNotification(QStringLiteral("notificationTest"));
    notification->setComponentName(QStringLiteral("plasma_mobile_notificationtest"));
    notification->setIconName(QStringLiteral("notification-active"));
    notification->setTitle("Critically Urgent Notification");
    notification->setText("This is very urgent! AAAAAA");
    notification->setUrgency(KNotification::CriticalUrgency);
    auto action = notification->addAction("Action!");
    Q_UNUSED(action)

    connect(notification, &KNotification::closed, &app, QCoreApplication::quit);
    notification->sendEvent();
}

FakeJob::FakeJob(QObject *parent)
    : KJob{parent}
    , m_timer{new QTimer{this}}
{
    setTotalAmount(KJob::Bytes, 100);
    setProcessedAmount(KJob::Bytes, 0);
    connect(m_timer, &QTimer::timeout, this, &FakeJob::timerFinished);
}

void FakeJob::start()
{
    setProcessedAmount(KJob::Bytes, 0);
    m_timer->start(1000);

    QString s_title = "Processing";
    QString s_source = "Source";
    QString s_destination = "Destination";
    Q_EMIT description(this, s_title, {s_source, QStringLiteral("data:[...]")}, {s_destination, QStringLiteral("data:[...]")});
    setFinishedNotificationHidden();
}

void FakeJob::timerFinished()
{
    if (processedAmount(KJob::Bytes) + 10 < 100) {
        setProcessedAmount(KJob::Bytes, processedAmount(KJob::Bytes) + 10);
        emitSpeed(rand() % 100);
    } else {
        setProcessedAmount(KJob::Bytes, 100);
        emitResult();
    }
}

void JobNotificationTest::sendNotification(QCoreApplication &app)
{
    KUiServerV2JobTracker *jobTracker = new KUiServerV2JobTracker{};

    KJob *job = new FakeJob{this};
    job->setProperty("immediateProgressReporting", true);
    job->setProperty("desktopFileName", "org.kde.plasmashell");
    connect(job, &KJob::finished, &app, QCoreApplication::quit);

    jobTracker->registerJob(job);
    job->start();
}
