// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QSortFilterProxyModel>
#include <QTimer>
#include <qqmlregistration.h>

#include <KWayland/Client/plasmawindowmanagement.h>

class StartupFeedback : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString iconName READ iconName CONSTANT)
    Q_PROPERTY(QString title READ title CONSTANT)
    Q_PROPERTY(QString storageId READ storageId CONSTANT)
    Q_PROPERTY(qreal iconStartX READ iconStartX CONSTANT)
    Q_PROPERTY(qreal iconStartY READ iconStartY CONSTANT)
    Q_PROPERTY(qreal iconSize READ iconSize CONSTANT)
    Q_PROPERTY(int screen READ screen CONSTANT)

public:
    explicit StartupFeedback(QObject *parent = nullptr,
                             QString iconName = "",
                             QString title = "",
                             QString storageId = "",
                             qreal iconStartX = 0.0,
                             qreal iconStartY = 0.0,
                             qreal iconSize = 0.0,
                             int screen = 0);

    explicit StartupFeedback();

    QString iconName() const;
    QString title() const;
    QString storageId() const;

    qreal iconStartX() const;
    qreal iconStartY() const;
    qreal iconSize() const;

    int screen() const;

    // Set by StartupFeedbackModel
    QString windowUuid() const;
    void setWindowUuid(QString uuid);

    void startTimeoutTimer();

Q_SIGNALS:
    void timeout();

private:
    const QString m_iconName;
    const QString m_title;
    const QString m_storageId;
    const qreal m_iconStartX;
    const qreal m_iconStartY;
    const qreal m_iconSize;
    const int m_screen;
    QString m_windowUuid;

    QTimer *m_timeoutTimer{nullptr};
};

class StartupFeedbackModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool activeWindowIsStartupFeedback READ activeWindowIsStartupFeedback NOTIFY activeWindowIsStartupFeedbackChanged)

public:
    enum Roles {
        DelegateRole = Qt::UserRole,
        ScreenRole,
    };

    explicit StartupFeedbackModel(QObject *parent = nullptr);

    void addApp(StartupFeedback *startupFeedback);

    bool activeWindowIsStartupFeedback() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
    void activeWindowIsStartupFeedbackChanged();

private Q_SLOTS:
    void onWindowOpened(KWayland::Client::PlasmaWindow *window);
    void onPlasmaWindowOpened(KWayland::Client::PlasmaWindow *window);
    void onActiveWindowChanged(KWayland::Client::PlasmaWindow *activeWindow);

private:
    void updateActiveWindowIsStartupFeedback();

    bool m_activeWindowIsStartupFeedback{false};
    QList<StartupFeedback *> m_list;
    KWayland::Client::PlasmaWindow *m_activeWindow{nullptr};
};

class StartupFeedbackFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(StartupFeedbackModel *startupFeedbackModel READ startupFeedbackModel WRITE setStartupFeedbackModel NOTIFY startupFeedbackModelChanged)

public:
    explicit StartupFeedbackFilterModel(QObject *parent = nullptr);

    StartupFeedbackModel *startupFeedbackModel() const;
    void setStartupFeedbackModel(StartupFeedbackModel *taskModel);

Q_SIGNALS:
    void startupFeedbackModelChanged();

private:
    StartupFeedbackModel *m_startupFeedbackModel{nullptr};
};
