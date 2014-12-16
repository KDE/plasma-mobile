/*
 *  Copyright 2014 Alex Richardson <arichardson.kde@gmail.com>
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License version 2 as published by the Free Software Foundation;
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public License
 *  along with this library; see the file COPYING.LIB.  If not, write to
 *  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301, USA.
 */

#include <QtTest/QTest>

#include <QDebug>
#include <QJsonDocument>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonObject>
#include <QSignalSpy>

#include "urlmodel.h"


using namespace AngelFish;

class UrlModelTest : public QObject
{
    Q_OBJECT

    static void compare(const QJsonArray &data, QAbstractListModel *model)
    {
        QCOMPARE(data.count(), model->rowCount(QModelIndex()));
        QStringList roleNames;
        foreach (auto rn, model->roleNames()) {
            roleNames << rn;
        }
        for (int i = 0; i < data.count(); i++) {
            auto index = model->index(i);

            QVariantMap vm = data.at(i).toObject().toVariantMap();

            foreach (auto k, vm.keys()) {
                QVERIFY2(roleNames.contains(k), QString("Key \"" + k + "\" not found roleNames").toLocal8Bit());
            }


            foreach (int k, model->roleNames().keys()) {
                UrlModel *urlmodel = static_cast<UrlModel*>(model);
                const QString ks = urlmodel->key(k);

                QVariant ori = vm[ks];
                QVariant val = model->data(index, k);

//                 qDebug() << "Comparing " << ks << k;
//                 qDebug() << "          " << (ori == val) << ori << " == " << val;

                if (!vm.keys().contains(ks)) {
                    //QVERIFY(val == QVariant());
                    continue;
                }
                if (ks == "lastVisited") {
                    auto dt = QDateTime::fromString(model->data(index, k).toString(), Qt::ISODate);
                    QCOMPARE(vm[ks].toDateTime(), dt);
                } else {

                    QCOMPARE(vm[ks], model->data(index, k));
                }
            }

            QString u = model->data(index, UrlModel::url).toString();
            //QVERIFY(!u.isEmpty());
//             qDebug() << i << "URL: " << u;
        }
    };

    static QJsonArray readFile(const QString &fileName)
    {
        QFile jsonFile(fileName);
        jsonFile.open(QIODevice::ReadOnly);
        //QJsonDocument jdoc = QJsonDocument::fromBinaryData(jsonFile.readAll());
        QJsonDocument jdoc = QJsonDocument::fromJson(jsonFile.readAll());
        jsonFile.close();
        return jdoc.array();
    }


private Q_SLOTS:

    void init()
    {
        m_bookmarksModel = new UrlModel(QStringLiteral("urlmodeltest.json"), this);
    }

    void cleanup()
    {
        delete m_bookmarksModel;
    }

    void initTestCase()
    {
        init();
        {
            QJsonObject u;
            u.insert(m_bookmarksModel->key(UrlModel::url), QStringLiteral("http://m.nos.nl"));
            u.insert(m_bookmarksModel->key(UrlModel::title), QStringLiteral("Nieuws"));
            u.insert(m_bookmarksModel->key(UrlModel::icon), QStringLiteral("text-html"));
            u.insert(m_bookmarksModel->key(UrlModel::bookmarked), true);
            u.insert(m_bookmarksModel->key(UrlModel::lastVisited), QDateTime::currentDateTime().toString(Qt::ISODate));
            m_data << u;
        }
        {
            QJsonObject u;
            u.insert(m_bookmarksModel->key(UrlModel::url), QStringLiteral("http://vizZzion.org"));
            u.insert(m_bookmarksModel->key(UrlModel::title), QStringLiteral("sebas' blog"));
            u.insert(m_bookmarksModel->key(UrlModel::icon), QStringLiteral("/home/sebas/Pictures/avatar-small.jpg"));
            u.insert(m_bookmarksModel->key(UrlModel::preview), QStringLiteral("/home/sebas/Pictures/avatar-small.jpg"));
            u.insert(m_bookmarksModel->key(UrlModel::bookmarked), true);
            u.insert(m_bookmarksModel->key(UrlModel::lastVisited), QDateTime::currentDateTime().toString(Qt::ISODate));
            m_data << u;
        }
        {
            QJsonObject u;
            u.insert(m_bookmarksModel->key(UrlModel::url), QStringLiteral("http://lwn.net"));
            u.insert(m_bookmarksModel->key(UrlModel::title), QStringLiteral("Linux Weekly News"));
            u.insert(m_bookmarksModel->key(UrlModel::icon), QStringLiteral("text-html"));
            u.insert(m_bookmarksModel->key(UrlModel::bookmarked), true);
            u.insert(m_bookmarksModel->key(UrlModel::lastVisited), QDateTime::currentDateTime().toString(Qt::ISODate));
            m_data << u;
        }
        {
            QJsonObject u;
            u.insert(m_bookmarksModel->key(UrlModel::url), QStringLiteral("http://tweakers.net"));
            u.insert(m_bookmarksModel->key(UrlModel::title), QStringLiteral("Tweakers.net"));
            u.insert(m_bookmarksModel->key(UrlModel::icon), QStringLiteral("text-html"));
            u.insert(m_bookmarksModel->key(UrlModel::bookmarked), true);
            u.insert(m_bookmarksModel->key(UrlModel::lastVisited), QDateTime::currentDateTime().toString(Qt::ISODate));
            m_data << u;
        }
        {
            QJsonObject u;
            u.insert(m_bookmarksModel->key(UrlModel::url), QStringLiteral("http://en.wikipedia.org"));
            u.insert(m_bookmarksModel->key(UrlModel::title), QStringLiteral("Wikipedia"));
            u.insert(m_bookmarksModel->key(UrlModel::icon), QStringLiteral("text-html"));
            //u.insert(m_bookmarksModel->key(UrlModel::preview), QStringLiteral("/home/sebas/Pictures/avatar-small.jpg"));
            u.insert(m_bookmarksModel->key(UrlModel::bookmarked), false);
            u.insert(m_bookmarksModel->key(UrlModel::lastVisited), QDateTime::currentDateTime().toString(Qt::ISODate));
            m_data << u;
        }
        {
            QJsonObject u;
            u.insert(m_bookmarksModel->key(UrlModel::url), QStringLiteral("http://plasma-mobile.org"));
            u.insert(m_bookmarksModel->key(UrlModel::title), QStringLiteral("Plasma Mobile"));
            u.insert(m_bookmarksModel->key(UrlModel::icon), QStringLiteral("plasma"));
            u.insert(m_bookmarksModel->key(UrlModel::bookmarked), true);
            u.insert(m_bookmarksModel->key(UrlModel::lastVisited), QDateTime::currentDateTime().toString(Qt::ISODate));
            m_data << u;
        }
        cleanup();
    };

    void testEmpty()
    {
        QVERIFY(m_data.count() > 0);
        QVERIFY(m_bookmarksModel->rowCount(QModelIndex()) == 0);
    };

    void testSetSourceData() {

        m_bookmarksModel->setSourceData(m_data);

        // TODO wait for update!
        // ...

        QVERIFY(m_bookmarksModel->rowCount(QModelIndex()) > 0);
        QCOMPARE(m_bookmarksModel->rowCount(QModelIndex()), m_data.count());

        QCOMPARE(m_data, m_bookmarksModel->sourceData());

    }

    void testSave()
    {
        const QString fileName("savetest.json");
        // save, reset, load...
        auto saveModel = new UrlModel(fileName);
        saveModel->setSourceData(m_data);
        QVERIFY(saveModel->save());

        const QString fpath = saveModel->filePath();

        delete saveModel;

        auto loadModel = new UrlModel(fileName);
        QVERIFY(loadModel->load());


        QJsonArray written = readFile(fpath);
//         return;

        compare(written, loadModel);
        delete loadModel;
    };

    void compareData()
    {
        m_bookmarksModel->setSourceData(m_data);
        compare(m_data, m_bookmarksModel);
    }

    void testLoad()
    {
        const QString file1 = QFINDTESTDATA("data/simplebookmarks.json");

        auto model = new UrlModel(file1, this);
        QVERIFY(model->load());

        QVERIFY(model->rowCount(QModelIndex()));

        compare(readFile(file1), model);
    };

    void testAdd() {
        m_bookmarksModel->setSourceData(m_data);
        // Adding bookmarks
        compare(m_data, m_bookmarksModel);


        {
            int i0 = m_bookmarksModel->rowCount(QModelIndex());
            QJsonObject u;
            u.insert(m_bookmarksModel->key(UrlModel::url), QStringLiteral("http://kde.org"));
            u.insert(m_bookmarksModel->key(UrlModel::title), QStringLiteral("KDE"));
            u.insert(m_bookmarksModel->key(UrlModel::icon), QStringLiteral("kde-start-here"));
            u.insert(m_bookmarksModel->key(UrlModel::bookmarked), true);
            u.insert(m_bookmarksModel->key(UrlModel::lastVisited), QDateTime::currentDateTime().toString(Qt::ISODate));
            //m_data << u;
            m_bookmarksModel->add(u);
            int i1 = m_bookmarksModel->rowCount(QModelIndex());
            QCOMPARE(i0 + 1, i1);

            QJsonArray copy = m_data;
            copy << u;
            compare(copy, m_bookmarksModel);
        }

        { // dupe, should not insert

            // reset
            m_bookmarksModel->setSourceData(m_data);
            int i0 = m_bookmarksModel->rowCount(QModelIndex());

            QJsonObject u;
            u.insert(m_bookmarksModel->key(UrlModel::url), QStringLiteral("http://plasma-mobile.org"));
            u.insert(m_bookmarksModel->key(UrlModel::title), QStringLiteral("Plasma Mobile"));
            u.insert(m_bookmarksModel->key(UrlModel::icon), QStringLiteral("plasma"));
            u.insert(m_bookmarksModel->key(UrlModel::bookmarked), true);
            u.insert(m_bookmarksModel->key(UrlModel::lastVisited), QDateTime::currentDateTime().toString(Qt::ISODate));

            m_bookmarksModel->add(u);
            int i2 = m_bookmarksModel->rowCount(QModelIndex());
            QCOMPARE(i0, i2);

            QJsonArray copy = m_data;
            copy << u;
            QCOMPARE(copy.count() - 1, m_bookmarksModel->rowCount(QModelIndex()));
            //QVERIFY(!compare(copy, m_bookmarksModel));
        }
    };

    void testDataChanged()
    {
        //QSignalSpy spy(m_bookmarksModel, SIGNAL(dataChanged(const QModelIndex &, const QModelIndex &, const QVector<int> &)));
        QSignalSpy spy(m_bookmarksModel, SIGNAL(modelReset()));
        {
            QJsonObject u;
            u.insert(m_bookmarksModel->key(UrlModel::url), QStringLiteral("http://kde.org"));
            u.insert(m_bookmarksModel->key(UrlModel::title), QStringLiteral("KDE"));
            u.insert(m_bookmarksModel->key(UrlModel::icon), QStringLiteral("kde-start-here"));
            u.insert(m_bookmarksModel->key(UrlModel::bookmarked), true);
            u.insert(m_bookmarksModel->key(UrlModel::lastVisited), QDateTime::currentDateTime().toString(Qt::ISODate));
            //m_data << u;
            m_bookmarksModel->add(u);
            m_bookmarksModel->add(u);
        }
        QCOMPARE(spy.count(), 1);

        QSignalSpy spy2(m_bookmarksModel, SIGNAL(modelReset()));
        m_bookmarksModel->remove("http://kde.org");

        QCOMPARE(spy2.count(), 1);

    }

    void testRemove() {
        m_bookmarksModel->setSourceData(m_data);

        // Remove a bookmark
        int c1 = m_bookmarksModel->rowCount(QModelIndex());

        const QString r = "http://lwn.net";
        m_bookmarksModel->remove(r);
        int c2 = m_bookmarksModel->rowCount(QModelIndex());
        QCOMPARE(c1, c2 + 1);

        QStringList urls;
        for (int i = 0; i < c2; i++) {
            auto index = m_bookmarksModel->index(i);
            const QString r = m_bookmarksModel->data(index, UrlModel::url).toString();
            urls << r;
        }
        int c3 = m_bookmarksModel->rowCount(QModelIndex());
        foreach (auto r, urls) {
            c3--;
            m_bookmarksModel->remove(r);
            QCOMPARE(m_bookmarksModel->rowCount(QModelIndex()), c3);
        }
        QCOMPARE(m_bookmarksModel->rowCount(QModelIndex()), 0);
    };

    void testNotify() {
        m_bookmarksModel->setSourceData(m_data);
        // save to file while waiting for model update...
    };

private: // disable from here for testing just the above


private:
    QJsonArray m_data;
    QJsonArray m_empty;

    UrlModel* m_bookmarksModel;

};

QTEST_MAIN(UrlModelTest)

#include "urlmodeltest.moc"
