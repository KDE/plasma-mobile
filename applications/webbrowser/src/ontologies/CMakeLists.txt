
# Add ontologies you need in the dataengine here,
# but only if they don't come with kdelibs
# Don't forget to link "ontologies" into your code

nepomuk_add_ontology_classes (ontologies_SRCS
                              ONTOLOGIES
                              NEPOMUK2
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nie.trig
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
                              CLASSES
                              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark"
                              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#BookmarkFolder"
)

kde4_add_library (ontologies
                  STATIC
                  ${ontologies_SRCS}
)

set_property(TARGET ontologies PROPERTY COMPILE_FLAGS -fPIC)
