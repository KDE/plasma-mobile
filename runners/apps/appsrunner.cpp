/*
 *   Copyright 2012 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "appsrunner.h"

#include <QMimeData>

#include <KIcon>
#include <KDebug>
#include <KLocale>
#include <KRun>
#include <KService>
#include <KServiceTypeTrader>
#include <KUrl>

ActiveAppsRunner::ActiveAppsRunner(QObject *parent, const QVariantList &args)
    : Plasma::AbstractRunner(parent, args)
{
    Q_UNUSED(args)

    setObjectName(QLatin1String("Active Apps" ));
    setPriority(AbstractRunner::HighestPriority);
    Plasma::RunnerSyntax syntax(QLatin1String("__activeappslist"), QString());
    setDefaultSyntax(syntax);

    // TODO: this could be moved into a prepare() method so that it is refreshed on each search
    // right now it requires a restart of the shell to update the blacklist; however, reading a
    // kconfig in could be a bit heavy
    KSharedConfigPtr ptr = KSharedConfig::openConfig("active-blacklistrc");
    KConfigGroup config = KConfigGroup(ptr, "blacklist");
    m_blackList = config.readEntry("apps", QStringList()).toSet();
}

ActiveAppsRunner::~ActiveAppsRunner()
{
}

void ActiveAppsRunner::match(Plasma::RunnerContext &context)
{
    if (context.query() != "__activeappslist") {
        serviceMatches(context);
        return;
    }

    // Search for applications which are executable and case-insensitively match the search term
    // See http://techbase.kde.org/Development/Tutorials/Services/Traders#The_KTrader_Query_Language
    // if the following is unclear to you.
    const QString query = QString("exist Exec");
    KService::List services = KServiceTypeTrader::self()->query("Application", query);
    //kDebug() << "******** populating with" << services.count();

    QList<Plasma::QueryMatch> matches;

    //kDebug() << service->name() << "is an exact match!" << service->storageId() << service->exec();
    foreach (const KService::Ptr &service, services) {
        if (!service->noDisplay() &&
            service->property("NotShowIn", QVariant::String) != "KDE" &&
            !m_blackList.contains(service->desktopEntryName())) {
            Plasma::QueryMatch match(this);
            match.setType(Plasma::QueryMatch::ExactMatch);
            setupMatch(service, match);
            match.setRelevance(1);
            matches << match;
        }
    }

    context.addMatches(context.query(), matches);
}

void ActiveAppsRunner::serviceMatches(Plasma::RunnerContext &context)
{
    const QString term = context.query();
    if (term.length() <  3) {
        return;
    }

    // Search for applications which are executable and case-insensitively match the search term
    // See http://techbase.kde.org/Development/Tutorials/Services/Traders#The_KTrader_Query_Language
    // if the following is unclear to you.
    QString query = QString("exist Exec and ('%1' =~ Name)").arg(term);
    KService::List services = KServiceTypeTrader::self()->query("Application", query);

    QList<Plasma::QueryMatch> matches;

    QSet<QString> seen;
    if (!services.isEmpty()) {
        //kDebug() << service->name() << "is an exact match!" << service->storageId() << service->exec();
        foreach (const KService::Ptr &service, services) {
            if (!service->noDisplay() && service->property("NotShowIn", QVariant::String) != "KDE") {
                Plasma::QueryMatch match(this);
                match.setType(Plasma::QueryMatch::ExactMatch);
                setupMatch(service, match);
                match.setRelevance(1);
                matches << match;
                seen.insert(service->storageId());
                seen.insert(service->exec());
            }
        }
    }

    if (!context.isValid()) {
        return;
    }

    // Search for applications which are executable and the term case-insensitive matches any of
    // * a substring of one of the keywords
    // * a substring of the GenericName field
    // * a substring of the Name field
    // Note that before asking for the content of e.g. Keywords and GenericName we need to ask if
    // they exist to prevent a tree evaluation error if they are not defined.
    query = QString("exist Exec and ( (exist Keywords and '%1' ~subin Keywords) or (exist GenericName and '%1' ~~ GenericName) or (exist Name and '%1' ~~ Name) or ('%1' ~~ Exec) )").arg(term);
    services = KServiceTypeTrader::self()->query("Application", query);
    services += KServiceTypeTrader::self()->query("KCModule", query);

    //kDebug() << "got " << services.count() << " services from " << query;
    foreach (const KService::Ptr &service, services) {
        if (!context.isValid()) {
            return;
        }

        if (service->noDisplay()) {
            continue;
        }

        const QString id = service->storageId();
        const QString exec = service->exec();
        if (seen.contains(id) || seen.contains(exec)) {
            //kDebug() << "already seen" << id << exec;
            continue;
        }

        //kDebug() << "haven't seen" << id << "so processing now";
        seen.insert(id);
        seen.insert(exec);

        Plasma::QueryMatch match(this);
        match.setType(Plasma::QueryMatch::PossibleMatch);
        setupMatch(service, match);
        qreal relevance(0.6);

        if (service->name().contains(term, Qt::CaseInsensitive)) {
            relevance = 0.8;

            if (service->name().startsWith(term, Qt::CaseInsensitive)) {
                relevance += 0.1;
            }
        } else if (service->genericName().contains(term, Qt::CaseInsensitive)) {
            relevance = 0.7;

            if (service->genericName().startsWith(term, Qt::CaseInsensitive)) {
                relevance += 0.1;
            }
        }

        if (service->categories().contains("KDE") || service->serviceTypes().contains("KCModule")) {
            //kDebug() << "found a kde thing" << id << match.subtext() << relevance;
            if (id.startsWith("kde-")) {
                //kDebug() << "old" << service->type();
                if (!service->isApplication()) {
                    // avoid showing old kcms and what not
                    continue;
                }

                // This is an older version, let's disambiguate it
                QString subtext("KDE3");

                if (!match.subtext().isEmpty()) {
                    subtext.append(", " + match.subtext());
                }

                match.setSubtext(subtext);
            } else {
                relevance += .1;
            }
        }

        //kDebug() << service->name() << "is this relevant:" << relevance;
        match.setRelevance(relevance);
        matches << match;
    }

    //search for applications whose categories contains the query
    query = QString("exist Exec and (exist Categories and '%1' ~subin Categories)").arg(term);
    services = KServiceTypeTrader::self()->query("Application", query);

    //kDebug() << service->name() << "is an exact match!" << service->storageId() << service->exec();
    foreach (const KService::Ptr &service, services) {
        if (!context.isValid()) {
            return;
        }

        if (!service->noDisplay()) {
            QString id = service->storageId();
            QString exec = service->exec();
            if (seen.contains(id) || seen.contains(exec)) {
                //kDebug() << "already seen" << id << exec;
                continue;
            }
            Plasma::QueryMatch match(this);
            match.setType(Plasma::QueryMatch::PossibleMatch);
            setupMatch(service, match);

            qreal relevance = 0.6;
            if (service->categories().contains("X-KDE-More") ||
                    !service->showInKDE()) {
                relevance = 0.5;
            }

            if (service->isApplication()) {
                relevance += .4;
            }

            match.setRelevance(relevance);
            matches << match;
        }
    }

    context.addMatches(term, matches);
}

void ActiveAppsRunner::run(const Plasma::RunnerContext &context, const Plasma::QueryMatch &match)
{
    Q_UNUSED(context);
    KService::Ptr service = KService::serviceByStorageId(match.data().toString());
    if (service) {
        KRun::run(*service, KUrl::List(), 0);
    }
}

void ActiveAppsRunner::setupMatch(const KService::Ptr &service, Plasma::QueryMatch &match)
{
    const QString name = service->name();

    match.setText(name);
    match.setData(service->storageId());

    if (!service->genericName().isEmpty() && service->genericName() != name) {
        match.setSubtext(service->genericName());
    } else if (!service->comment().isEmpty()) {
        match.setSubtext(service->comment());
    }

    if (!service->icon().isEmpty()) {
        match.setIcon(KIcon(service->icon()));
    }
}

QMimeData * ActiveAppsRunner::mimeDataForMatch(const Plasma::QueryMatch *match)
{
    KService::Ptr service = KService::serviceByStorageId(match->data().toString());
    if (service) {
        QMimeData * result = new QMimeData();
        QList<QUrl> urls;
        urls << KUrl(service->entryPath());
        //kDebug() << urls;
        result->setUrls(urls);
        return result;
    }

    return 0;
}

#include "appsrunner.moc"

