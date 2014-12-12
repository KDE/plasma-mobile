
include(ECMAddTests)

find_package(Qt5 ${REQUIRED_QT_VERSION} CONFIG REQUIRED Test)

macro(angelfish_unit_tests)
  foreach(_testname ${ARGN})
    ecm_add_test(${_testname}.cpp TEST_NAME ${_testname}
    LINK_LIBRARIES Qt5::Test )
  endforeach()
endmacro(angelfish_unit_tests)

angelfish_unit_tests(
 urlmodeltest
)


