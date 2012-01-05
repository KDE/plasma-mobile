/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/


#ifndef KDECLARATIVEMAINWINDOW_H
#define KDECLARATIVEMAINWINDOW_H

#include <KMainWindow>


class KDeclarativeView;

class KDeclarativeMainWindowPrivate;

class KDeclarativeMainWindow : public KMainWindow
{
    Q_OBJECT
    Q_PROPERTY(QStringList startupArguments READ startupArguments CONSTANT)
    Q_PROPERTY(QString caption READ caption WRITE setCaption NOTIFY captionChanged)

public:
    KDeclarativeMainWindow();
    ~KDeclarativeMainWindow();

    QString name();
    QIcon icon();
    KConfigGroup config(const QString &group = "Default");

    KDeclarativeView *declarativeView() const;

    void setUseGL(const bool on);
    bool useGL() const;

    //propertyies & methods for QML
    QStringList startupArguments() const;

    QString caption() const;

    Q_INVOKABLE QString startupOption(const QString &option) const;

public Q_SLOTS:
    void setCaption(const QString &caption);
    //FIXME: this exists only to not hide the superclass method
    void setCaption(const QString &caption, bool modified);

Q_SIGNALS:
    void captionChanged();

private:
    KDeclarativeMainWindowPrivate * const d;
    Q_PRIVATE_SLOT(d, void statusChanged(QDeclarativeView::Status))
};

#endif // KDECLARATIVEMAINWINDOW_H
