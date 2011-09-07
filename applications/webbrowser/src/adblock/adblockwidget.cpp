/* ============================================================
*
* This file is a part of the rekonq project
*
* Copyright (C) 2010-2011 by Andrea Diamantini <adjam7 at gmail dot com>
*
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation; either version 2 of
* the License or (at your option) version 3 or any later version
* accepted by the membership of KDE e.V. (or its successor approved
* by the membership of KDE e.V.), which shall act as a proxy
* defined in Section 14 of version 3 of the license.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
* ============================================================ */


// Self Includes
#include "adblockwidget.h"
#include "adblockwidget.moc"

// Auto Includes
//#include "rekonq.h"

// KDE Includes
#include <KSharedConfig>
#include <KIcon>
#include <KDebug>

// Qt Includes
#include <QString>
#include <QWhatsThis>
#include <QListWidgetItem>


AdBlockWidget::AdBlockWidget(QWidget *parent)
    : QWidget(parent)
    , _changed(false)
{
    setupUi(this);

    hintLabel->setText(i18n("<qt>Filter expression (e.g. <tt>http://www.example.com/ad/*</tt>, <a href=\"filterhelp\">more information</a>):"));
    connect(hintLabel, SIGNAL(linkActivated(const QString &)), this, SLOT(slotInfoLinkActivated(const QString &)));

    listWidget->setSortingEnabled(true);
    listWidget->setSelectionMode(QAbstractItemView::SingleSelection);

    searchLine->setListWidget(listWidget);

    insertButton->setIcon(KIcon("list-add"));
    connect(insertButton, SIGNAL(clicked()), this, SLOT(insertRule()));

    removeButton->setIcon(KIcon("list-remove"));
    connect(removeButton, SIGNAL(clicked()), this, SLOT(removeRule()));

    load();

    spinBox->setSuffix(ki18np(" day", " days"));

    // emit changed signal
    connect(insertButton,       SIGNAL(clicked()),           this, SLOT(hasChanged()));
    connect(removeButton,       SIGNAL(clicked()),           this, SLOT(hasChanged()));
    connect(checkEnableAdblock, SIGNAL(stateChanged(int)),   this, SLOT(hasChanged()));
    connect(checkHideAds,       SIGNAL(stateChanged(int)),   this, SLOT(hasChanged()));
    connect(spinBox,            SIGNAL(valueChanged(int)),   this, SLOT(hasChanged()));
}


void AdBlockWidget::slotInfoLinkActivated(const QString &url)
{
    Q_UNUSED(url)

    QString hintHelpString = i18n("<qt><p>Enter an expression to filter. Filters can be defined as either:"
                                  "<ul><li>a shell-style wildcard, e.g. <tt>http://www.example.com/ads*</tt>, the wildcards <tt>*?[]</tt> may be used</li>"
                                  "<li>a full regular expression by surrounding the string with '<tt>/</tt>', e.g. <tt>/\\/(ad|banner)\\./</tt></li></ul>"
                                  "<p>Any filter string can be preceded by '<tt>@@</tt>' to whitelist (allow) any matching URL, "
                                  "which takes priority over any blacklist (blocking) filter.");

    QWhatsThis::showText(QCursor::pos(), hintHelpString);
}


void AdBlockWidget::insertRule()
{
    QString rule = addFilterLineEdit->text();
    if (rule.isEmpty())
        return;

    listWidget->addItem(rule);
    addFilterLineEdit->clear();
}


void AdBlockWidget::removeRule()
{
    listWidget->takeItem(listWidget->currentRow());
}


void AdBlockWidget::load()
{
    //const bool isAdBlockEnabled = ReKonfig::adBlockEnabled();
    const bool isAdBlockEnabled = true; // FIXME
    checkEnableAdblock->setChecked(isAdBlockEnabled);
    // update enabled status
    checkHideAds->setEnabled(checkEnableAdblock->isChecked());
    tabWidget->setEnabled(checkEnableAdblock->isChecked());

    //const bool areImageFiltered = ReKonfig::hideAdsEnabled();
    const bool areImageFiltered = true; // FIXME
    checkHideAds->setChecked(areImageFiltered);

    //const int days = ReKonfig::updateInterval();
    const int days = 7; // FIXME
    spinBox->setValue(days);

    //const QStringList subscriptions = ReKonfig::subscriptionTitles();
    const QStringList subscriptions; // FIXME

    // load automatic rules
    foreach(const QString & sub, subscriptions)
    {
        QTreeWidgetItem *subItem = new QTreeWidgetItem(treeWidget);
        subItem->setText(0, sub);
        loadRules(subItem);
    }

    // load local rules
    KSharedConfig::Ptr config = KSharedConfig::openConfig("adblock", KConfig::SimpleConfig, "appdata");
    KConfigGroup localGroup(config, "rules");
    const QStringList rules = localGroup.readEntry("local-rules" , QStringList());
    foreach(const QString & rule, rules)
    {
        listWidget->addItem(rule);
    }
}


void AdBlockWidget::loadRules(QTreeWidgetItem *item)
{
    KSharedConfig::Ptr config = KSharedConfig::openConfig("adblock", KConfig::SimpleConfig, "appdata");
    KConfigGroup localGroup(config, "rules");

    QString str = item->text(0) + "-rules";
    QStringList rules = localGroup.readEntry(str , QStringList());

    foreach(const QString & rule, rules)
    {
        QTreeWidgetItem *subItem = new QTreeWidgetItem(item);
        subItem->setText(0, rule);
    }
}


void AdBlockWidget::save()
{
    if (!_changed)
        return;

    // local rules
    KSharedConfig::Ptr config = KSharedConfig::openConfig("adblock", KConfig::SimpleConfig, "appdata");
    KConfigGroup localGroup(config , "rules");

    QStringList localRules;

    const int n = listWidget->count();
    for (int i = 0; i < n; ++i)
    {
        QListWidgetItem *item = listWidget->item(i);
        localRules << item->text();
    }
    localGroup.writeEntry("local-rules" , localRules);

    /* FIXME
    ReKonfig::setAdBlockEnabled(checkEnableAdblock->isChecked());
    ReKonfig::setHideAdsEnabled(checkHideAds->isChecked());
    ReKonfig::setUpdateInterval(spinBox->value());
    */
    _changed = false;
    emit changed(false);
}


void AdBlockWidget::hasChanged()
{
    // update enabled status
    checkHideAds->setEnabled(checkEnableAdblock->isChecked());
    tabWidget->setEnabled(checkEnableAdblock->isChecked());
    _changed = true;
    emit changed(true);
}


bool AdBlockWidget::changed()
{
    return _changed;
}
