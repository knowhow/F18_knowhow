#define F18_TEST_DEFINED

#define F18_LOG_FILE "F18_test.log"
#define F18_SERVER_INI_SECTION "F18_server_test"

#include "f18.ch"

#translate TEST_LINE( <x>, <result> ) => TEST_CALL( #<x>, {|| <x> }, <result> )

