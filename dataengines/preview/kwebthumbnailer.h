/*
    Copyright 2011 Sebastian Kügler <sebas@kde.org>
    Copyright 2010 Richard Moore <rich@kde.org>

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

#ifndef KWEBTHUMBNAILER_H
#define KWEBTHUMBNAILER_H

#include <QtCore/QObject>
#include <QtGui/QImage>

class QUrl;
class QSize;

class KWebThumbnailer : public QObject
{
    Q_OBJECT

public:
    KWebThumbnailer( QObject *parent = 0 );
    KWebThumbnailer( const QUrl &url, const QSize &size, QObject *parent = 0 );
    ~KWebThumbnailer();

    void setUrl( const QUrl &url );
    void setSize( const QSize &size );


    void start();

    QUrl url();
    QSize size();
    QImage thumbnail() const;
    QString fileName();
    QString status();

    bool isValid() const;

signals:
    void done( bool success );

private slots:
    void completed( bool success );

private:
    class KWebThumbnailerPrivate *d;
};

#endif // KWEBTHUMBNAILER_H

