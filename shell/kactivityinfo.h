/*
 * Copyright (c) 2010 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License version 2 as published by the Free Software Foundation.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#ifndef ACTIVITY_INFO_H
#define ACTIVITY_INFO_H

#include <QObject>
#include <QWidget>
#include <QString>
#include <QStringList>

#include <KUrl>
#include <kdemacros.h>

/**
 * This class provides info about an activity. Most methods in it
 * require a Nepomuk backend running.
 *
 * @see KActivityConsumer for info about activities
 *
 * @since 4.5
 */
class KDE_EXPORT KActivityInfo: public QObject
{
    Q_OBJECT

    Q_PROPERTY(KUrl uri READ uri)
    Q_PROPERTY(KUrl resourceUri READ resourceUri)
    Q_PROPERTY(QString id READ id)
    Q_PROPERTY(QString name READ name)

public:
    explicit KActivityInfo(const QString & activityId, QObject *parent=0);
    ~KActivityInfo();

    /**
     * @return true if the activity represented by this object exists and is valid
     */
    bool isValid() const;

    /**
     * Set of predefined resource types provided for convenience
     */
    enum ResourceType {
        UnspecifiedResource = 0,
        DocumentResource    = 1, ///< @see nfo:Document
        FolderResource      = 2, ///< @see nfo:Folder
        ApplicationResource = 3, ///< @see nfo:Application
        ContactResource     = 4, ///< @see nco:Contact
        LocationResource    = 5  ///< @see pimo:Location

    };

    /**
     * Specifies which parts of this class are functional
     */
    enum Availability {
        Nothing = 0,             ///< No activity info provided (isValid is false)
        BasicInfo = 1,           ///< Basic info is provided
        Everything = 2           ///< Everything is available
    };

    /**
     * State of the activity
     */
    enum State {
        Invalid  = 0,
        Running  = 2,
        Starting = 3,
        Stopped  = 4,
        Stopping = 5
    };

    /**
     * @returns what info is provided by this instance of KActivityInfo
     */
    Availability availability() const;

    /**
     * Associates the resource with the activity represented by this
     * KActivityInfo object.
     * @param resourceUrl url of the resource
     * @param resourceType type of the resource
     * @note Functional only when availability is Everything
     */
    void associateResource(const KUrl & resourceUrl, ResourceType resourceType = UnspecifiedResource);

    /**
     * Associates the resource with the activity represented by this
     * KActivityInfo object.
     * @param resourceUrl url of the resource
     * @param resourceType type of the resource
     * @note Functional only when availability is Everything
     */
    void associateResource(const KUrl & resourceUrl, const KUrl & resourceType);

    /**
     * Removes the association of this activity and the specified
     * resource.
     * @param resourceUrl url of the resource
     * @note Functional only when availability is Everything
     */
    void disassociateResource(const KUrl & resourceUrl);

    /**
     * @param resourceType type of the resource
     * @returns a list of resources of the specified type that are
     * associated with this activity. If the type is not specified,
     * all associated resources are returned,
     * @note Functional only when availability is Everything
     */
    QList < KUrl > associatedResources(ResourceType resourceType = UnspecifiedResource) const;

    /**
     * @param resourceType type of the resource
     * @returns a list of resources of the specified type that are
     * associated with this activity. If the type is not specified,
     * all associated resources are returned,
     * @note Functional only when availability is Everything
     */
    QList < KUrl > associatedResources(const KUrl & resourceType) const;

    /**
     * @returns the URI of this activity. The same URI is used by
     * activities KIO slave.
     * @note Functional only when availability is Everything
     */
    KUrl uri() const;

    /**
     * @returns the Nepomuk resource URI of this activity
     * @note Functional only when availability is Everything
     */
    KUrl resourceUri() const;

    /**
     * @returns the id of the activity
     */
    QString id() const;

    /**
     * @returns the name of the activity
     * @note Functional when availability is BasicInfo or Everything
     */
    QString name() const;

    /**
     * @returns the icon of the activity. Icon can be a
     * freedesktop.org name or a file path. Or empty if
     * no icon is set.
     * @note Functional only when availability is Everything
     */
    QString icon() const;

    /**
     * @returns the state of the activity
     */
    State state() const;

    /**
     * This function is provided for convenience.
     * @returns the name of the specified activity
     * @param id id of the activity
     */
    static QString name(const QString & id);

Q_SIGNALS:
    /**
     * Emitted when the activity's name, icon or description is changed
     */
    void infoChanged();

    /**
     * Emitted when the activity is added
     */
    void added();

    /**
     * Emitted when the activity is removed
     */
    void removed();

    /**
     * Emitted when the activity is started
     */
    void started();

    /**
     * Emitted when the activity is stopped
     */
    void stopped();

    /**
     * Emitted when the activity changes state
     * @param state new state of the activity
     */
    void stateChanged(KActivityInfo::State state);

private:
    class Private;
    Private * const d;

    Q_PRIVATE_SLOT(d, void activityStateChanged(const QString &, int))
    Q_PRIVATE_SLOT(d, void added(const QString &))
    Q_PRIVATE_SLOT(d, void removed(const QString &))
    Q_PRIVATE_SLOT(d, void started(const QString &))
    Q_PRIVATE_SLOT(d, void stopped(const QString &))
    Q_PRIVATE_SLOT(d, void infoChanged(const QString &))
};

#endif // ACTIVITY_INFO_H
