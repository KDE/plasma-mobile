/*
    Copyright 2011 Marco Martin <mart@kde.org>
    Copyright 2011 Sebastian Kügler <sebas@kde.org>

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Library General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
    License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
    02110-1301, USA.
*/

#include "resourcecontainer.h"
#include "resourcewatcher.h"

#include <QDBusServiceWatcher>
#include <QDBusConnection>

#include <KMimeType>

#include <Nepomuk2/Tag>
#include <Nepomuk2/Variant>
#include <Nepomuk2/File>


ResourceContainer::ResourceContainer(QObject *parent)
    : Plasma::DataContainer(parent)
{
    m_watcher = new Nepomuk2::ResourceWatcher(this);

    m_watcher->addProperty(QUrl("http://www.semanticdesktop.org/ontologies/2007/08/15/nao#numericRating"));
    connect(m_watcher, SIGNAL(propertyAdded(Nepomuk2::Resource,Nepomuk2::Types::Property,QVariant)),
            this, SLOT(propertyChanged(Nepomuk2::Resource,Nepomuk2::Types::Property,QVariant)));
}

ResourceContainer::~ResourceContainer()
{
}


void ResourceContainer::propertyChanged(Nepomuk2::Resource res, Nepomuk2::Types::Property prop, QVariant val)
{
    if (res != m_resource) {
        return;
    }

    setData(prop.name(), val);
    checkForUpdate();
}

void ResourceContainer::setResource(Nepomuk2::Resource resource)
{
    if (m_resource == resource) {
        return;
    }
    m_resource = resource;

    //update the resource watcher
    {
        m_watcher->stop();
        QList<Nepomuk2::Resource> resources;
        resources << resource;
        m_watcher->setResources(resources);
        m_watcher->start();
    }



    const QString className = resource.type().toString().section( QRegExp( "[#:]" ), -1 );
    QString desc = resource.genericDescription();
    if (desc.isEmpty()) {
        desc = className;
    }
    QString label = resource.genericLabel();
    if (label.isEmpty()) {
        label = "Empty label.";
    }

    setData("label", label);
    setData("description", desc);

    // Types
    QStringList _types;
    foreach (const QUrl &u, resource.types()) {
        _types << u.toString();
    }

    setData("types", _types);

    Nepomuk2::Types::Class resClass(resource.type());

    //FIXME: a more elegant way is needed
    setData("genericClassName", className);
    foreach (const Nepomuk2::Types::Class &parentClass, resClass.parentClasses()) {
        if (parentClass.label() == "Document" ||
            parentClass.label() == "Audio" ||
            parentClass.label() == "Video" ||
            parentClass.label() == "Image" ||
            parentClass.label() == "Contact") {
            setData("genericClassName", parentClass.label());
            break;
        //two cases where the class is 2 levels behind the level of generalization we want
        } else if (parentClass.label() == "RasterImage") {
            setData("genericClassName", "Image");
        } else if (parentClass.label() == "TextDocument") {
            setData("genericClassName", "Document");
        }
    }

    QString _icon = resource.genericIcon();
    if (_icon.isEmpty() && resource.isFile()) {
        KUrl url = resource.toFile().url();
        if (!url.isEmpty()) {
            _icon = KMimeType::iconNameForUrl(url);
        }
    }
    if (_icon.isEmpty()) {
        // use resource types to find a suitable icon.
        //TODO
        _icon = icon(QStringList(className));
        //kDebug() << "symbol" << _icon;
    }
    if (_icon.split(',').count() > 1) {
        kDebug() << "More than one icon!" << _icon;
        _icon = _icon.split(',').last();
    }

    setData("icon", _icon);
    setData("hasSymbol", _icon);
    setData("isFile", resource.isFile());
    setData("exists", resource.exists());
    setData("rating", resource.rating());

    setData("className", className);
    setData("resourceUri", resource.uri());
    setData("resourceType", resource.type());
    setData("query", objectName());

    if (resource.isFile() && resource.toFile().url().isLocalFile()) {
        setData("url", resource.toFile().url().prettyUrl());
    }

    // Tags
    QStringList _tags, _tagNames;
    foreach (const Nepomuk2::Tag &tag, resource.tags()) {
        _tags << tag.uri().toString();
        _tagNames << tag.genericLabel();
    }
    setData("tags", _tags);
    setData("tagNames", _tagNames);

    // Related
    QStringList _relateds;
    foreach (const Nepomuk2::Resource &res, resource.isRelateds()) {
        _relateds << res.uri().toString();
    }
    setData("relateds", _relateds);

    // Dynamic properties
    QStringList _properties;
    QHash<QUrl, Nepomuk2::Variant> props = resource.properties();
    foreach(const QUrl &propertyUrl, props.keys()) {

        QStringList _l = propertyUrl.toString().split('#');
        if (_l.count() > 1) {
            QString key = _l[1];
            _properties << key;
            //QString from = dynamic_cast<QList<QUrl>();
            if (resource.property(propertyUrl).variant().canConvert(QVariant::List)) {
                QVariantList tl = resource.property(propertyUrl).variant().toList();
                foreach (const QVariant &vu, tl) {
                    //kDebug() << vu.toString().startsWith("nepomuk:") << vu.toString().startsWith("akonadi:") << vu.toString();
                    if (vu.canConvert(QVariant::Url) &&
                        (vu.toString().startsWith(QLatin1String("nepomuk:")) || vu.toString().startsWith(QLatin1String("akonadi:")))) {
                        kDebug() <<  "HHH This is a list.!!!" << key << vu.toString();
                    }
                }
            }
            //kDebug() << " ... " << key << propertyUrl << resource.property(propertyUrl).variant();
            if (key != "plainTextMessageContent" && !data().contains(key)) {
                setData(key, resource.property(propertyUrl).variant());
            }
            // More properties


        } else {
            kWarning() << "Could not parse ontology URL, missing '#':" << propertyUrl.toString();
        }
    }
    setData("properties", _properties);

    checkForUpdate();
}

QString ResourceContainer::icon(const QStringList &types)
{
    if (!m_icons.size()) {
        // Add fallback icons here from generic to specific
        // The list of types is also sorted in this way, so
        // we're returning the most specific icon, even with
        // the hardcoded mapping.

        // Files
        //m_icons["FileDataObject"] = QString("audio-x-generic");

        // Audio
        m_icons["Audio"] = QString("audio-x-generic");
        m_icons["MusicPiece"] = QString("audio-x-generic");

        // Images
        m_icons["Image"] = QString("image-x-generic");
        m_icons["RasterImage"] = QString("image-x-generic");

        m_icons["Email"] = QString("internet-mail");
        m_icons["Document"] = QString("kword");
        m_icons["PersonContact"] = QString("x-office-contact");

        // Filesystem
        m_icons["Website"] = QString("text-html");

        // ... add some more
        // Filesystem
        m_icons["Bookmark"] = QString("bookmarks");
        m_icons["BookmarksFolder"] = QString("bookmarks-organize");

        m_icons["FileDataObject"] = QString("unknown");
        m_icons["TextDocument"] = QString("text-enriched");
    }

    // keep searching until the most specific icon is found
    QString _icon = "nepomuk";
    foreach(const QString &t, types) {
        QString shortType = t.split('#').last();
        if (shortType.isEmpty()) {
            shortType = t;
        }
        if (m_icons.keys().contains(shortType)) {
            _icon = m_icons[shortType];
            //kDebug() << "found icon for type" << shortType << _icon;
        }
    }
    return _icon;
}

#include "resourcecontainer.moc"

