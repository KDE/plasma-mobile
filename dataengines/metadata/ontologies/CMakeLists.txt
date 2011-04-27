# Build the nie static lib here so the tests can use it too.
nepomuk_add_ontology_classes (telepathynie_SRCS
                              ONTOLOGIES
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nie.trig
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nco.trig
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nmo.trig
)

# Add the ontologies we want to build the vocabulary for.
soprano_add_ontology (pimo_ontology_SRCS
                      ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/pimo/pimo.trig
                      "PIMO"
                      "Nepomuk::Vocabulary"
                      "trig"
)

soprano_add_ontology (nco_ontology_SRCS
                      ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nco.trig
                      "NCO"
                      "Nepomuk::Vocabulary"
                      "trig"
)

soprano_add_ontology (nco_ontology_SRCS
                      ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
                      "NFO"
                      "Nepomuk::Vocabulary"
                      "trig"
)

soprano_add_ontology (nao_ontology_SRCS
                      ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nepomuk/nao.trig
                      "NAO"
                      "Nepomuk::Vocabulary"
                      "trig"
)

kde4_add_library (ontologies
                  STATIC
                  ${pimo_ontology_SRCS}
                  ${nco_ontology_SRCS}
                  ${nao_ontology_SRCS}
)

set_property(TARGET ontologies PROPERTY COMPILE_FLAGS -fPIC)