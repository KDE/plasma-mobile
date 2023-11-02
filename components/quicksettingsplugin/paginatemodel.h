/*
 *   SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QAbstractListModel>
#include <qqmlregistration.h>

/**
 * @class PaginateModel
 *
 * This class can be used to create representations of only a chunk of a model.
 *
 * With this component it will be possible to create views that only show a page
 * of a model, instead of drawing all the elements in the model.
 */
class PaginateModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    /** Holds the number of elements that will fit in a page */
    Q_PROPERTY(int pageSize READ pageSize WRITE setPageSize NOTIFY pageSizeChanged)

    /** Tells what is the first row shown in the model */
    Q_PROPERTY(int firstItem READ firstItem WRITE setFirstItem NOTIFY firstItemChanged)

    /** The model we will be proxying */
    Q_PROPERTY(QAbstractItemModel *sourceModel READ sourceModel WRITE setSourceModel NOTIFY sourceModelChanged)

    /** Among the totality of elements, indicates the one we're currently offering */
    Q_PROPERTY(int currentPage READ currentPage NOTIFY firstItemChanged)

    /** Provides the number of pages available, given the sourceModel size */
    Q_PROPERTY(int pageCount READ pageCount NOTIFY pageCountChanged)

    /** If enabled, ensures that pageCount and pageSize are the same. */
    Q_PROPERTY(bool staticRowCount READ hasStaticRowCount WRITE setStaticRowCount NOTIFY staticRowCountChanged)

public:
    explicit PaginateModel(QObject *object = nullptr);
    ~PaginateModel() override;

    int pageSize() const;
    void setPageSize(int count);

    int firstItem() const;
    void setFirstItem(int row);

    /**
     * @returns Last visible item.
     *
     * Convenience function
     */
    int lastItem() const;

    QAbstractItemModel *sourceModel() const;
    void setSourceModel(QAbstractItemModel *model);

    QModelIndex mapToSource(const QModelIndex &idx) const;
    QModelIndex mapFromSource(const QModelIndex &idx) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    int currentPage() const;
    int pageCount() const;
    QHash<int, QByteArray> roleNames() const override;

    void setStaticRowCount(bool src);
    bool hasStaticRowCount() const;

    /** Display the first rows of the model */
    Q_SCRIPTABLE void firstPage();

    /** Display the rows right after the ones that are currently being served */
    Q_SCRIPTABLE void nextPage();

    /** Display the rows right before the ones that are currently being served */
    Q_SCRIPTABLE void previousPage();

    /** Display the last set of rows of the source model */
    Q_SCRIPTABLE void lastPage();

private Q_SLOTS:
    void _k_sourceRowsAboutToBeInserted(const QModelIndex &parent, int start, int end);
    void _k_sourceRowsInserted(const QModelIndex &parent, int start, int end);
    void _k_sourceRowsAboutToBeRemoved(const QModelIndex &parent, int start, int end);
    void _k_sourceRowsRemoved(const QModelIndex &parent, int start, int end);
    void _k_sourceRowsAboutToBeMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destParent, int dest);
    void _k_sourceRowsMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destParent, int dest);

    void _k_sourceColumnsAboutToBeInserted(const QModelIndex &parent, int start, int end);
    void _k_sourceColumnsInserted(const QModelIndex &parent, int start, int end);
    void _k_sourceColumnsAboutToBeRemoved(const QModelIndex &parent, int start, int end);
    void _k_sourceColumnsRemoved(const QModelIndex &parent, int start, int end);
    void _k_sourceColumnsAboutToBeMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destParent, int dest);
    void _k_sourceColumnsMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destParent, int dest);

    void _k_sourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles);
    void _k_sourceHeaderDataChanged(Qt::Orientation orientation, int first, int last);

    void _k_sourceModelAboutToBeReset();
    void _k_sourceModelReset();

Q_SIGNALS:
    void pageSizeChanged();
    void firstItemChanged();
    void sourceModelChanged();
    void pageCountChanged();
    void staticRowCountChanged();

private:
    bool canSizeChange() const;
    bool isIntervalValid(const QModelIndex &parent, int start, int end) const;
    int rowsByPageSize(int size) const;

    class PaginateModelPrivate;
    QScopedPointer<PaginateModelPrivate> d;
};
