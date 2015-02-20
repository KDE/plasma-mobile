
include(ECMAddTests)

find_package(Qt5 ${REQUIRED_QT_VERSION} CONFIG REQUIRED Test)

include_directories(../src)

ecm_add_test(urlmodeltest.cpp ../src/urlmodel.cpp
             TEST_NAME urlmodeltest
             LINK_LIBRARIES Qt5::Test )
