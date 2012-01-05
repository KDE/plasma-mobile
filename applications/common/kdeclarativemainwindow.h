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
    /**
     * the list of all startup arguments, such as urls to open
     */
    Q_PROPERTY(QStringList startupArguments READ startupArguments CONSTANT)
    /**
     * The caption of the main window. Do not include the application name in this string. It will be added automatically according to the KDE standard.
     */
    Q_PROPERTY(QString caption READ caption WRITE setCaption NOTIFY captionChanged)

public:
    KDeclarativeMainWindow();
    ~KDeclarativeMainWindow();

    /**
     * The main kconfiggroup to be used for this application
     * The configuration file name is derived from the application name
     *
     * @arg QString group the kconfigugroup name
     */
    KConfigGroup config(const QString &group = "Default");

    /**
     * @returns the declarative view that will contain the application UI
     * It loads a Plasma::Package rather than an absolute path
     * @see KDeclarativeView
     * @see Plasma::Package
     */
    KDeclarativeView *declarativeView() const;

    //propertyies & methods for QML
    QStringList startupArguments() const;

    QString caption() const;

    /**
     * Read out a string option.
     * The option must have a corresponding KCmdLineOptions entry of the form:
        <code>
         options.add("option <argument>", ki18n("Description"), "default");
        </code>
     * You cannot test for the presence of an alias - you must always test for the full option.
     * @arg QString option  The name of the option without '-'.
     * @returns The value of the option. If the option was not present on the command line the default is returned. If the option was present more than once, the value of the last occurrence is used.
     */
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
