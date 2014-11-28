#add_subdirectory(metadatamodel)
#TODO Here exists a big part of the nepomuk support, which needs to be
#ported to Baloo
add_subdirectory(mobilecomponents)
add_subdirectory(settings)

#FIXME can we remove that now?
# dirmodel can be removed once plasma-mobile hard-requires KDE libs/runtime 4.11
# as long as 4.10 is the requirement, however, we need to keep a copy of it here
#macro_ensure_version("4.10.80" ${KDE_VERSION} HAS_DIRMODEL_IN_RUNTIME)
#if (!${HAS_DIRMODEL_IN_RUNTIME})
#    add_subdirectory(dirmodel)
#endif (!${HAS_DIRMODEL_IN_RUNTIME})
