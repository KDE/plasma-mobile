// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "folioapplication.h"
#include "foliodelegate.h"
#include "homescreen.h"

#include <QAbstractListModel>
#include <QObject>
#include <QString>

#include <KService>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

class HomeScreen;
struct ApplicationDelegate;
class ApplicationFolderModel;
class FolioDelegate;
class FolioApplication;

/**
 * @short Object that represents an application folder.
 */

class FolioApplicationFolder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QList<FolioApplication *> appPreviews READ appPreviews NOTIFY applicationsChanged)
    Q_PROPERTY(ApplicationFolderModel *applications READ applications NOTIFY applicationsReset)

public:
    FolioApplicationFolder(HomeScreen *parent = nullptr, QString name = QString{});

    static FolioApplicationFolder *fromJson(QJsonObject &obj, HomeScreen *parent);
    QJsonObject toJson() const;

    QString name() const;
    void setName(QString &name);

    QList<FolioApplication *> appPreviews();

    ApplicationFolderModel *applications();
    void setApplications(QList<FolioApplication *> applications);

    void moveEntry(int fromRow, int toRow);
    bool addDelegate(FolioDelegate *delegate, int row);
    Q_INVOKABLE void removeDelegate(int row);

    int dropInsertPosition(int page, qreal x, qreal y);
    bool isDropPositionOutside(qreal x, qreal y);

Q_SIGNALS:
    void nameChanged();
    void saveRequested();
    void applicationsChanged();
    void applicationsReset();

private:
    HomeScreen *m_homeScreen{nullptr};

    QString m_name;
    QList<ApplicationDelegate> m_delegates;
    ApplicationFolderModel *m_applicationFolderModel{nullptr};

    friend class ApplicationFolderModel;
};

struct ApplicationDelegate {
    FolioDelegate *delegate;
    qreal xPosition;
    qreal yPosition;
};

class ApplicationFolderModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int numberOfPages READ numTotalPages NOTIFY numberOfPagesChanged)

public:
    enum Roles {
        DelegateRole = Qt::UserRole + 1,
        XPositionRole,
        YPositionRole,
    };
    ApplicationFolderModel(FolioApplicationFolder *folder);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    FolioDelegate *getDelegate(int index);
    void moveEntry(int fromRow, int toRow);
    bool canAddDelegate(FolioDelegate *delegate, int index);
    bool addDelegate(FolioDelegate *delegate, int index);
    void removeDelegate(int index);
    QPointF getDelegatePosition(int index);

    // for use with drag and drop, as the delegate is dragged around
    // ghost - fake delegate exists at an index, so a gap is created
    // invisible - existing delegate looks like it doesn't exist
    int getGhostEntryPosition();
    void setGhostEntry(int index);
    void replaceGhostEntry(FolioDelegate *delegate);
    void deleteGhostEntry();

    // the index that dropping at the position given would place the delegate at.
    int dropInsertPosition(int page, qreal x, qreal y);

    // whether this position is outside of the folder area
    bool isDropPositionOutside(qreal x, qreal y);

    // distance between page content to screen edge
    qreal leftMarginFromScreenEdge();
    qreal topMarginFromScreenEdge();

    int numTotalPages();

Q_SIGNALS:
    void numberOfPagesChanged();

private:
    void evaluateDelegatePositions(bool emitSignal = true);

    // get the position where delegates start being placed
    QPointF getDelegateStartPosition(int page);

    int numRowsOnPage();
    int numColumnsOnPage();

    // distance between folder edge and page content
    qreal horizontalPageMargin();
    qreal verticalPageMargin();

    FolioApplicationFolder *m_folder{nullptr};

    friend class FolioApplicationFolder;
};
