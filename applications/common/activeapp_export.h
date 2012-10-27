/*  This file is part of the KDE project
    Copyright 2007 Aaron Seigo <aseigo@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#ifndef ACTIVEAPP_EXPORT_H
#define ACTIVEAPP_EXPORT_H

/* needed for KDE_EXPORT and KDE_IMPORT macros */
#include <kdemacros.h>

#ifndef ACTIVEAPP_EXPORT
# if defined(KDELIBS_STATIC_LIBS)
   /* No export/import for static libraries */
#  define ACTIVEAPP_EXPORT
# elif defined(MAKE_ACTIVEAPP_LIB)
   /* We are building this library */
#  define ACTIVEAPP_EXPORT KDE_EXPORT
# else
   /* We are using this library */
#  define ACTIVEAPP_EXPORT KDE_IMPORT
# endif
#endif

# ifndef ACTIVEAPP_EXPORT_DEPRECATED
#  define ACTIVEAPP_EXPORT_DEPRECATED KDE_DEPRECATED ACTIVEAPP_EXPORT
# endif

#endif
