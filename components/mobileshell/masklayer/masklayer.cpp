// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "masklayer.h"

#include <QSGFlatColorMaterial>

// helper function for creating rounded rectangles
static void createRoundedRectGeometry(QSGGeometry *geometry, const QRectF &rect, qreal radius)
{
    geometry->setDrawingMode(QSGGeometry::DrawTriangles);
    radius = qMin(radius, qMin(rect.width(), rect.height()) / 2.0); // clamp radius

    // if the radius is too small, draw a simple rectangle instead
    if (radius < 0.1) {
        // 4 vertices, 6 indices (2 triangles * 3 indices)
        geometry->allocate(4, 6);

        // fill vertex data
        QSGGeometry::Point2D *vertices = geometry->vertexDataAsPoint2D();
        vertices[0].set(rect.left(),  rect.top());
        vertices[1].set(rect.right(), rect.top());
        vertices[2].set(rect.left(),  rect.bottom());
        vertices[3].set(rect.right(), rect.bottom());

        // fill index data
        quint16 *indices = geometry->indexDataAsUShort();
        indices[0] = 0; indices[1] = 2; indices[2] = 1; // first triangle (TL, BL, TR)
        indices[3] = 1; indices[4] = 2; indices[5] = 3; // second triangle (TR, BL, BR)

        geometry->markVertexDataDirty();
        geometry->markIndexDataDirty();
        return;
    }

    const int segments_per_corner = 16;
    const int perimeter_verts = segments_per_corner * 4;
    const int vertex_count = 1 + perimeter_verts;
    const int index_count = perimeter_verts * 3;

    geometry->allocate(vertex_count, index_count);

    QSGGeometry::Point2D *vertices = geometry->vertexDataAsPoint2D();
    quint16 *indices = geometry->indexDataAsUShort();

    int vertIndex = 0;
    int indexPos = 0;

    // define the center vertex
    const quint16 center_vert_index = vertIndex;
    vertices[vertIndex++].set(rect.center().x(), rect.center().y());

    // define the center of the corners
    const QPointF tl_c = {rect.left() + radius, rect.top() + radius};
    const QPointF tr_c = {rect.right() - radius, rect.top() + radius};
    const QPointF br_c = {rect.right() - radius, rect.bottom() - radius};
    const QPointF bl_c = {rect.left() + radius, rect.bottom() - radius};

    // create all perimeter vertices
    // top-right
    for (int i = 0; i < segments_per_corner; ++i) {
        const qreal angle = M_PI * 1.5 + (M_PI_2 * i / segments_per_corner);
        vertices[vertIndex++].set(tr_c.x() + radius * cos(angle), tr_c.y() + radius * sin(angle));
    }
    // bottom-right
    for (int i = 0; i < segments_per_corner; ++i) {
        const qreal angle = (M_PI_2 * i / segments_per_corner);
        vertices[vertIndex++].set(br_c.x() + radius * cos(angle), br_c.y() + radius * sin(angle));
    }
    // bottom-left
    for (int i = 0; i < segments_per_corner; ++i) {
        const qreal angle = M_PI_2 + (M_PI_2 * i / segments_per_corner);
        vertices[vertIndex++].set(bl_c.x() + radius * cos(angle), bl_c.y() + radius * sin(angle));
    }
    // top-left
    for (int i = 0; i < segments_per_corner; ++i) {
        const qreal angle = M_PI + (M_PI_2 * i / segments_per_corner);
        vertices[vertIndex++].set(tl_c.x() + radius * cos(angle), tl_c.y() + radius * sin(angle));
    }

    // create the triangles using indices
    // loop through all perimeter vertices and connect them to the center and the next vertex
    for (quint16 i = 0; i < perimeter_verts; ++i) {
        indices[indexPos++] = center_vert_index; // center vertex
        indices[indexPos++] = center_vert_index + 1 + i; // current perimeter vertex
        // the next perimeter vertex / wrapping around to the start at the end
        indices[indexPos++] = center_vert_index + 1 + ((i + 1) % perimeter_verts);
    }

    // tell renderer to mark all the data as dirty
    geometry->markVertexDataDirty();
    geometry->markIndexDataDirty();
}

MaskLayer::MaskLayer(QQuickItem *parent) : QQuickItem(parent)
{
    setFlag(ItemHasContents, true);
}

MaskLayer::~MaskLayer() = default;

void MaskLayer::addItem(QQuickItem* item)
{
    if (!item || m_sourceItems.contains(item)) {
        return;
    }

    m_sourceItems.append(item);

    // we connect these signals so that any changes that affects the item's visual representation triggers an update
    // we then store connections to be able to disconnect them later
    auto& conns = m_connections[item];
    conns.append(QObject::connect(item, &QQuickItem::xChanged, this, &MaskLayer::scheduleUpdate));
    conns.append(QObject::connect(item, &QQuickItem::yChanged, this, &MaskLayer::scheduleUpdate));
    conns.append(QObject::connect(item, &QQuickItem::visibleChanged, this, &MaskLayer::scheduleUpdate));
    conns.append(QObject::connect(item, &QQuickItem::opacityChanged, this, &MaskLayer::scheduleUpdate));
    conns.append(QObject::connect(item, &QObject::destroyed, this, [this, item]() {
        removeItem(item);
    }));

    const QMetaObject* metaObject = item->metaObject();

    // due to not being about to tell when the item's transform value changes
    // we check for 'scaleAmountChanged()' to use as a sort of work around
    int scaleAmountIndex = metaObject->indexOfProperty("scaleAmount");
    if (scaleAmountIndex != -1 && metaObject->property(scaleAmountIndex).hasNotifySignal()) {
        conns.append(QObject::connect(item, SIGNAL(scaleAmountChanged()), this, SLOT(scheduleUpdate())));
    }

    // connect the parents signal changes, as this affects the final visible outcome
    QQuickItem* currentParent = item->parentItem();
    while (currentParent) {
        conns.append(QObject::connect(currentParent, &QQuickItem::xChanged, this, &MaskLayer::scheduleUpdate));
        conns.append(QObject::connect(currentParent, &QQuickItem::yChanged, this, &MaskLayer::scheduleUpdate));
        conns.append(QObject::connect(currentParent, &QQuickItem::opacityChanged, this, &MaskLayer::scheduleUpdate));

        const QMetaObject* metaObject = currentParent->metaObject();

        // check for 'scaleAmountChanged()'
        int scaleAmountIndex = metaObject->indexOfProperty("scaleAmount");
        if (scaleAmountIndex != -1 && metaObject->property(scaleAmountIndex).hasNotifySignal()) {
            conns.append(QObject::connect(currentParent, SIGNAL(scaleAmountChanged()), this, SLOT(scheduleUpdate())));
        }

        currentParent = currentParent->parentItem();
    }

    scheduleUpdate();
}

void MaskLayer::removeItem(QQuickItem* item)
{
    if (!item) return;

    disconnectItemSignals(item);
    m_connections.remove(item);
    m_sourceItems.removeAll(item);
    scheduleUpdate();
}

void MaskLayer::disconnectItemSignals(QQuickItem* item)
{
    if (m_connections.contains(item)) {
        for (const auto &conn : m_connections.value(item)) {
            QObject::disconnect(conn);
        }
    }
}

void MaskLayer::scheduleUpdate()
{
    // marks this item for an update.
    // the renderer will call updatePaintNode before the next frame
    update();
}

QSGNode *MaskLayer::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
    // if oldNode is null, we need to create a new root node for our content
    // otherwise, we can reuse it and manage its children
    QSGNode *rootNode = oldNode;
    if (!rootNode) {
        rootNode = new QSGNode();
    }

    int currentChildIndex = 0;

    for (const QPointer<QQuickItem>& itemPtr : m_sourceItems) {
        QQuickItem* item = itemPtr.data();
        // item was deleted
        if (!item) {
            continue;
        }

        // calculate opacity and visibility
        qreal accumulatedOpacity = item->opacity();
        bool isVisible = item->isVisible();
        QQuickItem* currentParent = item->parentItem();
        while (currentParent) {
            if (!currentParent->isVisible()) {
                isVisible = false;
                break;
            }
            accumulatedOpacity *= currentParent->opacity();
            if (currentParent == this) break;
            currentParent = currentParent->parentItem();
        }

        // skip this item if it is invisible or fully transparent
        if (!isVisible || qFuzzyCompare(accumulatedOpacity, 0)) {
            continue;
        }

        // calculate position and size
        bool transformOk = false;
        const QTransform transform = item->itemTransform(this, &transformOk);
        if (!transformOk) continue;

        qreal radius = item->property("radius").toReal();

        QSGTransformNode *transformNode = nullptr;
        QSGGeometryNode *geometryNode = nullptr;

        if (currentChildIndex < rootNode->childCount()) {
            transformNode = static_cast<QSGTransformNode*>(rootNode->childAtIndex(currentChildIndex));
            geometryNode = static_cast<QSGGeometryNode*>(transformNode->firstChild());
        } else {
            transformNode = new QSGTransformNode();
            geometryNode = new QSGGeometryNode();

            QSGGeometry *geometry = new QSGGeometry(QSGGeometry::defaultAttributes_Point2D(), 0);

            geometryNode->setGeometry(geometry);

            QSGFlatColorMaterial *material = new QSGFlatColorMaterial();
            geometryNode->setMaterial(material);
            geometryNode->setFlags(QSGNode::OwnsMaterial);

            transformNode->appendChildNode(geometryNode);
            rootNode->appendChildNode(transformNode);
        }

        transformNode->setMatrix(QMatrix4x4(transform));

        QSGFlatColorMaterial *material = static_cast<QSGFlatColorMaterial*>(geometryNode->material());
        QColor color = Qt::white;
        color.setAlphaF(accumulatedOpacity);
        if (material->color() != color) material->setColor(color);

        QRectF rect(0, 0, item->width(), item->height());
        createRoundedRectGeometry(geometryNode->geometry(), rect, radius);
        geometryNode->markDirty(QSGNode::DirtyGeometry);


        currentChildIndex++;
    }

    // if we have more nodes than items this frame, remove the extras
    if (currentChildIndex < rootNode->childCount()) {
        for (int i = rootNode->childCount() - 1; i >= currentChildIndex; --i) {
            QSGNode *nodeToRemove = rootNode->childAtIndex(i);
            rootNode->removeChildNode(nodeToRemove);
            delete nodeToRemove;
        }
    }

    return rootNode;
}
