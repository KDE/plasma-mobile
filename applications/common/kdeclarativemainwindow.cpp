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

#include "kdeclarativemainwindow.h"
#include "kdeclarativeview.h"

#include <QApplication>
#include <QDeclarativeContext>

#include <KAction>
#include <KActionCollection>
#include <KCmdLineArgs>
#include <KStandardAction>

#include <Plasma/Theme>



class KDeclarativeMainWindowPrivate
{
public:
    KDeclarativeMainWindowPrivate(KDeclarativeMainWindow *window)
        : q(window)
    {
        actions = new KActionCollection(q);
        actions->setConfigGroup("Shortcuts");
        actions->addAssociatedWidget(q);
    }

    void statusChanged(QDeclarativeView::Status status);

    KDeclarativeMainWindow *q;
    KDeclarativeView *view;
    KCmdLineArgs *args;
    QStringList arguments;
    QString caption;
    QVariant icon;
    KActionCollection *actions;
};

void KDeclarativeMainWindowPrivate::statusChanged(QDeclarativeView::Status status)
{
    if (status == QDeclarativeView::Ready) {
        view->rootContext()->setContextProperty("application", q);
    }
}



KDeclarativeMainWindow::KDeclarativeMainWindow()
    : KMainWindow(),
      d(new KDeclarativeMainWindowPrivate(this))
{
    setAcceptDrops(true);
    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);
    KMainWindow::addAction(KStandardAction::close(this, SLOT(close()), this));
    KMainWindow::addAction(KStandardAction::quit(this, SLOT(close()), this));

    KAction *backAction = d->actions->addAction("back");
    backAction->setAutoRepeat(false);
    backAction->setShortcut(KShortcut(QKeySequence(Qt::Key_Back)));

    d->view = new KDeclarativeView(this);
    connect(d->view, SIGNAL(statusChanged(QDeclarativeView::Status)), this, SLOT(statusChanged(QDeclarativeView::Status)));

    setCentralWidget(d->view);
    restoreWindowSize(config("Window"));

    setWindowIcon(KIcon(KCmdLineArgs::aboutData()->programIconName()));

    d->args = KCmdLineArgs::parsedArgs();
    for (int i = 0; i < d->args->count(); i++) {
        d->arguments << d->args->arg(i);
    }

    cg = KConfigGroup(KSharedConfig::openConfig("plasmarc"), "General");
    bool useGL = cg.readEntry("UseOpenGl", true);

    d->view->setUseGL(useGL);

    connect(d->view, SIGNAL(titleChanged(QString)), SLOT(setCaption(QString)));
}

KDeclarativeMainWindow::~KDeclarativeMainWindow()
{
    saveWindowSize(config("Window"));
}


KDeclarativeView *KDeclarativeMainWindow::declarativeView() const
{
    return d->view;
}

KConfigGroup KDeclarativeMainWindow::config(const QString &group)
{
    return KConfigGroup(KSharedConfig::openConfig(qApp->applicationName() + "rc"), group);
}

QStringList KDeclarativeMainWindow::startupArguments() const
{
    return d->arguments;
}

QString KDeclarativeMainWindow::caption() const
{
    return d->caption;
}

void KDeclarativeMainWindow::setCaption(const QString &caption)
{
    if (d->caption == caption) {
        return;
    }

    d->caption = caption;
    emit captionChanged();
    KMainWindow::setCaption(caption);
}

void KDeclarativeMainWindow::setCaption(const QString &caption, bool modified)
{
    Q_UNUSED(modified)

    if (d->caption == caption) {
        return;
    }

    d->caption = caption;
    emit captionChanged();
    KMainWindow::setCaption(caption, true);
}


QVariant KDeclarativeMainWindow::icon() const
{
    return d->icon;
}

void KDeclarativeMainWindow::setIcon(const QVariant &icon)
{
    if (d->icon == icon || (icon.canConvert<QString>() && icon.canConvert<QIcon>())) {
        return;
    }

    d->icon = icon;
    if (icon.canConvert<QString>()) {
        setWindowIcon(KIcon(icon.toString()));
    } else {
        setWindowIcon(icon.value<QIcon>());
    }

    emit iconChanged();
}

QAction *KDeclarativeMainWindow::action(const QString &name)
{
    return d->actions->action(name);
}

void KDeclarativeMainWindow::addAction(const QString &name, const QString &string)
{
    KAction *action = d->actions->addAction(name);
    action->setAutoRepeat(false);
    action->setText(string);
}

#include "kdeclarativemainwindow.moc"
