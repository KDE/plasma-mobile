#include "kdeclarativedirmodel.h"

KDeclarativeDirModel::KDeclarativeDirModel()
    : KDirModel(0)
{
    QHash<int, QByteArray> roles;
    roles[KDirModel::Name] = "name";
    roles[KDirModel::Size] = "size";
    roles[Qt::DecorationRole] = "decoration";
    setRoleNames(roles);
}
