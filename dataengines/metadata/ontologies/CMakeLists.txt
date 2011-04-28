# Build the nie static lib here so the tests can use it too.
nepomuk_add_ontology_classes (telepathynie_SRCS
                                FAST
                              ONTOLOGIES
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nie.trig
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nco.trig
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nmo.trig
                                CLASSES
                                "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark"
                                "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#BookmarkFolder"

)

kde4_add_library (ontologies
                  STATIC
                  ${telepathynie_SRCS}
)

set_property(TARGET ontologies PROPERTY COMPILE_FLAGS -fPIC)

#target_link_libraries(niefast_apps ${QT_QTCORE_LIBRARY} ${SOPRANO_LIBRARIES} ${NEPOMUK_LIBRARIES})
