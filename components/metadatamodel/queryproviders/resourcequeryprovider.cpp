/*
    Copyright (C) 2012  Marco Martin <mart@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/


#include "resourcequeryprovider.h"

#include <QTimer>

#include <KDebug>
#include <KIO/PreviewJob>
#include <KIcon>
#include <KImageCache>
#include <KService>


#include <soprano/vocabulary.h>

#include <Nepomuk2/File>
#include <Nepomuk2/Tag>
#include <Nepomuk2/Variant>

#include <Nepomuk2/Query/AndTerm>
#include <Nepomuk2/Query/OrTerm>
#include <Nepomuk2/Query/NegationTerm>
#include <Nepomuk2/Query/ResourceTerm>
#include <Nepomuk2/Query/ComparisonTerm>
#include <Nepomuk2/Query/LiteralTerm>
#include <Nepomuk2/Query/QueryParser>
#include <Nepomuk2/Query/ResourceTypeTerm>
#include <Nepomuk2/Query/StandardQuery>

#include <Nepomuk2/Vocabulary/NIE>

using namespace Nepomuk2::Vocabulary;
using namespace Soprano::Vocabulary;



class ResourceQueryProviderPrivate
{
public:
    ResourceQueryProviderPrivate(ResourceQueryProvider *provider)
        : q(provider),
          thumbnailSize(180, 120),
          thumbnailerPlugins(new QStringList(KIO::PreviewJob::availablePlugins()))
    {
        previewTimer = new QTimer(q);
        previewTimer->setSingleShot(true);
        QObject::connect(previewTimer, SIGNAL(timeout()),
                q, SLOT(delayedPreview()));

        //using the same cache of the engine, they index both by url
        imageCache = new KImageCache("plasma_engine_preview", 41943040);
    }

    QString resourceIcon(const Nepomuk2::Resource &resource) const;

    //slots
    void showPreview(const KFileItem &item, const QPixmap &preview);
    void previewFailed(const KFileItem &item);
    void delayedPreview();


    ResourceQueryProvider *q;
    QString queryString;
    QStringList sortBy;
    Qt::SortOrder sortOrder;

    //previews
    QTimer *previewTimer;
    QHash<KUrl, QPersistentModelIndex> filesToPreview;
    QSize thumbnailSize;
    QHash<KUrl, QPersistentModelIndex> previewJobs;
    KImageCache* imageCache;
    QStringList* thumbnailerPlugins;
};


ResourceQueryProvider::ResourceQueryProvider(QObject* parent)
    : BasicQueryProvider(parent),
      d(new ResourceQueryProviderPrivate(this))
{
    QHash<int, QByteArray> roleNames;
    roleNames[Qt::DisplayRole] = "display";
    roleNames[Qt::DecorationRole] = "decoration";
    roleNames[Label] = "label";
    roleNames[Description] = "description";
    roleNames[Types] = "types";
    roleNames[ClassName] = "className";
    roleNames[GenericClassName] = "genericClassName";
    roleNames[HasSymbol] = "hasSymbol";
    roleNames[Icon] = "icon";
    roleNames[Thumbnail] = "thumbnail";
    roleNames[IsFile] = "isFile";
    roleNames[Exists] = "exists";
    roleNames[Rating] = "rating";
    roleNames[NumericRating] = "numericRating";
    roleNames[ResourceUri] = "resourceUri";
    roleNames[ResourceType] = "resourceType";
    roleNames[MimeType] = "mimeType";
    roleNames[Url] = "url";
    roleNames[Tags] = "tags";
    roleNames[TagsNames] = "tagsNames";
    setRoleNames(roleNames);
}

ResourceQueryProvider::~ResourceQueryProvider()
{
    delete d->imageCache;
}

void ResourceQueryProvider::setQueryString(const QString &query)
{
    if (query == d->queryString || query == "nepomuk") {
        return;
    }

    d->queryString = query;
    requestRefresh();
    emit queryStringChanged();
}

QString ResourceQueryProvider::queryString() const
{
    return d->queryString;
}

void ResourceQueryProvider::setSortBy(const QVariantList &sortBy)
{
    QStringList stringList = variantToStringList(sortBy);

    if (d->sortBy == stringList) {
        return;
    }

    d->sortBy = stringList;
    requestRefresh();
    emit sortByChanged();
}

QVariantList ResourceQueryProvider::sortBy() const
{
    return stringToVariantList(d->sortBy);
}

void ResourceQueryProvider::setSortOrder(Qt::SortOrder sortOrder)
{
    if (d->sortOrder == sortOrder) {
        return;
    }

    d->sortOrder = sortOrder;
    requestRefresh();
    emit sortOrderChanged();
}

Qt::SortOrder ResourceQueryProvider::sortOrder() const
{
    return d->sortOrder;
}

void ResourceQueryProvider::setThumbnailSize(const QSize& size)
{
    d->thumbnailSize = size;
    emit thumbnailSizeChanged();
}

QSize ResourceQueryProvider::thumbnailSize() const
{
    return d->thumbnailSize;
}

void ResourceQueryProvider::doQuery()
{
    QDeclarativePropertyMap *parameters = qobject_cast<QDeclarativePropertyMap *>(extraParameters());

    //check if really all properties to build the query are null
    if (d->queryString.isEmpty() && resourceType().isEmpty() &&
        mimeTypeStrings().isEmpty() && activityId().isEmpty() &&
        tagStrings().size() == 0 && !startDate().isValid() &&
        !endDate().isValid() && minimumRating() <= 0 &&
        maximumRating() <= 0 && parameters->size() == 0) {
        return;
    }
    Nepomuk2::Query::Query query = Nepomuk2::Query::Query();
    query.setQueryFlags(Nepomuk2::Query::Query::NoResultRestrictions);
    Nepomuk2::Query::AndTerm rootTerm;

    if (!d->queryString.isEmpty()) {
        rootTerm.addSubTerm(Nepomuk2::Query::QueryParser::parseQuery(d->queryString).term());
    }

    if (!resourceType().isEmpty()) {
        QString type = resourceType();

        if (type.startsWith('!')) {
            // negation
            type = type.remove(0, 1);
            rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(Nepomuk2::Query::ResourceTypeTerm(propertyUrl(type))));
        } else {
            rootTerm.addSubTerm(Nepomuk2::Query::ResourceTypeTerm(propertyUrl(type)));
            /*if (type != "nfo:Bookmark") {
                //FIXME: remove bookmarks if not explicitly asked for
                rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(Nepomuk2::Query::ResourceTypeTerm(propertyUrl("nfo:Bookmark"))));
            }*/
        }

        if (type == "nfo:Archive") {
            Nepomuk2::Query::ComparisonTerm term(Nepomuk2::Vocabulary::NIE::mimeType(), Nepomuk2::Query::LiteralTerm("application/epub+zip"));
            rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(term));
        }
    }

    if (!mimeTypeStrings().isEmpty()) {
        Nepomuk2::Query::OrTerm mimeTerm;
        foreach (QString type, mimeTypeStrings()) {
            if (type.isEmpty()) {
                continue;
            }
            bool negation = false;
            if (type.startsWith('!')) {
                type = type.remove(0, 1);
                negation = true;
            }

            Nepomuk2::Query::ComparisonTerm term(Nepomuk2::Vocabulary::NIE::mimeType(), Nepomuk2::Query::LiteralTerm(type), Nepomuk2::Query::ComparisonTerm::Equal);

            if (negation) {
                mimeTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(term));
            } else {
                mimeTerm.addSubTerm(term);
            }
        }
        rootTerm.addSubTerm(mimeTerm);
    }


    if (parameters && parameters->size() > 0) {
        foreach (const QString &key, parameters->keys()) {
            QString parameter = parameters->value(key).toString();
            if (parameter.isEmpty()) {
                continue;
            }
            bool negation = false;
            if (parameter.startsWith('!')) {
                parameter = parameter.remove(0, 1);
                negation = true;
            }

            //FIXME: Contains should work, but doesn't match for file names
            // we must prepend and append "*" to the file name for the default Nepomuk match type (Contains) really work.
            Nepomuk2::Query::ComparisonTerm term(propertyUrl(key), Nepomuk2::Query::LiteralTerm(parameter));

            if (negation) {
                rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(term));
            } else {
                rootTerm.addSubTerm(term);
            }
        }
    }


    if (!activityId().isEmpty()) {
        QString activity = activityId();
        bool negation = false;
        if (activity.startsWith('!')) {
            activity = activity.remove(0, 1);
            negation = true;
        }
        kDebug() << "Asking for resources of activity" << activityId();
        Nepomuk2::Resource acRes(activity, Nepomuk2::Vocabulary::KAO::Activity());
        Nepomuk2::Query::ComparisonTerm term(Soprano::Vocabulary::NAO::isRelated(), Nepomuk2::Query::ResourceTerm(acRes));
        term.setInverted(true);
        if (negation) {
            rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(term));
        } else {
            rootTerm.addSubTerm(term);
        }
    }

    foreach (const QString &tag, tagStrings()) {
        QString individualTag = tag;
        bool negation = false;
        if (individualTag.startsWith('!')) {
            individualTag = individualTag.remove(0, 1);
            negation = true;
        }
        Nepomuk2::Query::ComparisonTerm term( Soprano::Vocabulary::NAO::hasTag(),
                                    Nepomuk2::Query::ResourceTerm(Nepomuk2::Tag(individualTag)));
        if (negation) {
            rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(term));
        } else {
            rootTerm.addSubTerm(term);
        }
    }

    if (startDate().isValid() || endDate().isValid()) {
        rootTerm.addSubTerm(Nepomuk2::Query::dateRangeQuery(startDate(), endDate()).term());
    }

    if (minimumRating() > 0) {
        const Nepomuk2::Query::LiteralTerm ratingTerm(minimumRating());
        Nepomuk2::Query::ComparisonTerm term = Nepomuk2::Types::Property(propertyUrl("nao:numericRating")) > ratingTerm;
        rootTerm.addSubTerm(term);
    }

    if (maximumRating() > 0) {
        const Nepomuk2::Query::LiteralTerm ratingTerm(maximumRating());
        Nepomuk2::Query::ComparisonTerm term = Nepomuk2::Types::Property(propertyUrl("nao:numericRating")) < ratingTerm;
        rootTerm.addSubTerm(term);
    }

    //bind directly some properties, to avoid calling hyper inefficient resource::property
    /*{
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(NIE::url()));
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(NAO::hasSymbol()));
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(NIE::mimeType()));
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(NAO::description()));
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(Xesam::description()));
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(RDFS::comment()));
    }*/

    int weight = d->sortBy.length() + 1;
    foreach (const QString &sortProperty, d->sortBy) {
        if (sortProperty.isEmpty()) {
            continue;
        }
        Nepomuk2::Query::ComparisonTerm sortTerm(propertyUrl(sortProperty), Nepomuk2::Query::Term());
        sortTerm.setSortWeight(weight, d->sortOrder);
        rootTerm.addSubTerm(sortTerm);
        --weight;
    }

    query.setTerm(rootTerm);
    setQuery(query);
}

QVariant ResourceQueryProvider::formatData(const Nepomuk2::Query::Result &row, const QPersistentModelIndex &index, int role) const
{
    const Nepomuk2::Resource &resource = row.resource();

    if (!resource.isValid()) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
    case Label:
        return resource.genericLabel();
    case Description:
        return resource.description();
    case Qt::DecorationRole: 
        return KIcon(d->resourceIcon(resource));
    case HasSymbol:
    case Icon:
        return d->resourceIcon(resource);
    case Thumbnail: {
        KUrl url(resource.property(propertyUrl("nie:url")).toString());
        if (resource.isFile() && url.isLocalFile()) {
            QImage preview = QImage(d->thumbnailSize, QImage::Format_ARGB32_Premultiplied);

            if (d->imageCache->findImage(url.prettyUrl(), &preview)) {
                return preview;
            } else if (!d->filesToPreview.contains(url)) {
                d->previewTimer->start(500);
                //HACK
                const_cast<ResourceQueryProvider *>(this)->d->filesToPreview[url] = QPersistentModelIndex(index);
            }
        }
        return QVariant();
    }
    case Url:
        return resource.property(propertyUrl("nie:url")).toString();
    case ClassName:
        return resource.type().toString().section( QRegExp( "[#:]" ), -1 );
    //FIXME: The most complicated of all, this should really be simplified
    case GenericClassName: {
        //FIXME: a more elegant way is needed
        //if a Bookmark is a Document too, Bookmark wins
        if (resource.types().contains(NFO::Bookmark())) {
            return "Bookmark";

        } else {
            Nepomuk2::Types::Class resClass(resource.type());
            foreach (const Nepomuk2::Types::Class &parentClass, resClass.parentClasses()) {
                const QString label = parentClass.label();
                if (label == "Document" ||
                    label == "Audio" ||
                    label == "Video" ||
                    label == "Image" ||
                    label == "Contact") {
                    return label;
                    break;
                //two cases where the class is 2 levels behind the level of generalization we want
                } else if (parentClass.label() == "RasterImage") {
                    return "Image";
                } else if (parentClass.label() == "TextDocument") {
                    return "Document";
                }
            }
        }
        //this should never happen
        return QVariant();
    }
    case ResourceType:
        return resource.type();
    case MimeType:
        return resource.property(propertyUrl("nie:mimeType")).toString();
    case IsFile:
        return resource.isFile();
    case Exists:
        return resource.exists();
    case Rating:
        return resource.rating();
    case NumericRating:
        return resource.property(NAO::numericRating()).toString();
    case ResourceUri:
        return resource.uri();
    case Types: {
        QStringList types;
        foreach (const QUrl &u, resource.types()) {
            types << u.toString();
        }
        return types;
    }
    case Tags: {
        QStringList tags;
        foreach (const Nepomuk2::Tag &tag, resource.tags()) {
            tags << tag.uri().toString();
        }
        return tags;
    }
    case TagsNames: {
        QStringList tagNames;
        foreach (const Nepomuk2::Tag &tag, resource.tags()) {
            tagNames << tag.genericLabel();
        }
        return tagNames;
    }
    default:
        return QVariant();
    }
}






////////// ResourceQueryProviderPrivate


QString ResourceQueryProviderPrivate::resourceIcon(const Nepomuk2::Resource &resource) const
{
    //FIXME: symbols seems broken on Mer
    //indagate after PA3
    if (0&&!resource.symbols().isEmpty()) {
        return resource.symbols().first();
    } else {
        //if it's an application, fetch the icon from the desktop file
        Nepomuk2::Types::Class resClass(resource.type());
        if (resClass.label() == "Application") {
            KService::Ptr serv = KService::serviceByDesktopPath(resource.property(NIE::url()).toUrl().path());
            if (serv) {
                return serv->icon();
            } else {
                return KMimeType::iconNameForUrl(resource.property(NIE::url()).toString());
            }
        } else {
            return KMimeType::iconNameForUrl(resource.property(NIE::url()).toString());
        }
    }
}

void ResourceQueryProviderPrivate::delayedPreview()
{
    QHash<KUrl, QPersistentModelIndex>::const_iterator i = filesToPreview.constBegin();

    KFileItemList list;

    while (i != filesToPreview.constEnd()) {
        KUrl file = i.key();
        QPersistentModelIndex index = i.value();


        if (!previewJobs.contains(file) && file.isValid()) {
            list.append(KFileItem(file, QString(), 0));
            previewJobs.insert(file, QPersistentModelIndex(index));
        }

        ++i;
    }

    filesToPreview.clear();

    if (list.size() > 0) {
        KIO::PreviewJob* job = KIO::filePreview(list, thumbnailSize, thumbnailerPlugins);
        //job->setIgnoreMaximumSize(true);
        kDebug() << "Created job" << job << "for" << list.size() << "files";
        QObject::connect(job, SIGNAL(gotPreview(KFileItem,QPixmap)),
                q, SLOT(showPreview(KFileItem,QPixmap)));
        QObject::connect(job, SIGNAL(failed(KFileItem)),
                q, SLOT(previewFailed(KFileItem)));
    }
}

void ResourceQueryProviderPrivate::showPreview(const KFileItem &item, const QPixmap &preview)
{
    QPersistentModelIndex index = previewJobs.value(item.url());
    previewJobs.remove(item.url());

    if (!index.isValid()) {
        return;
    }

    imageCache->insertImage(item.url().prettyUrl(), preview.toImage());
    //kDebug() << "preview size:" << preview.size();
    emit q->dataFormatChanged(index);
}

void ResourceQueryProviderPrivate::previewFailed(const KFileItem &item)
{
    previewJobs.remove(item.url());
}

#include "resourcequeryprovider.moc"
