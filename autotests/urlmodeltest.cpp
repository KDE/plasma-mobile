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

#include "urlmodel.h"


using namespace AngelFish;

class UrlModelTest : public QObject
{
    Q_OBJECT

    static void compare(const QJsonArray &data, QAbstractListModel *model)
    {
        QCOMPARE(data.count(), model->rowCount(QModelIndex()));
        for (int i = 0; i < data.count(); i++) {
            auto index = model->index(i);

            foreach (int k, model->roleNames().keys()) {
                UrlModel *urlmodel = static_cast<UrlModel*>(model);
                const QString ks = urlmodel->key(k);
                QVariantMap vm = data.at(i).toObject().toVariantMap();

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
        qDebug() << "TEST::readFile: jsonfile: " << fileName << jsonFile.fileName() << jsonFile.exists();

        jsonFile.open(QIODevice::ReadOnly);
        //QJsonDocument jdoc = QJsonDocument::fromBinaryData(jsonFile.readAll());
        QJsonDocument jdoc = QJsonDocument::fromJson(jsonFile.readAll());
        jsonFile.close();

        qDebug() << "Done";
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
        qDebug() << "File1: " << file1;

        auto model = new UrlModel(file1, this);
        QVERIFY(model->load());

        QVERIFY(model->rowCount(QModelIndex()));

        compare(readFile(file1), model);
    };

    void testAdd() {
        m_bookmarksModel->setSourceData(m_data);
        // Adding bookmarks
    };

    void testRemove() {
        m_bookmarksModel->setSourceData(m_data);
        // Remove a bookmark
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
