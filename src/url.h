#ifndef URL_H
#define URL_H

#include <QImage>
#include <QUrl>
#include <QDateTime>

namespace AngelFish {

class Url
{
public:
    QUrl url;
    QString title;
    QImage icon;
    QImage preview;
    QDateTime lastVisited;
    bool bookmarked;
};

//typedef QHash<QString, Url> UrlData;
typedef QList<Url> UrlData;

} // namespace

#endif // URL_H
