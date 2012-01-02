#include "f18.ch"

procedure Main(...)

public gDebug := 10

f18_test_init()

TEST_BEGIN("")

harbour_base()

dbf_test()

modstru_test()

sifk_sifv_test()

fetch_set_metric()

test_version()

//test_thread()

test_semaphores()

TEST_END()

? "kraj"
