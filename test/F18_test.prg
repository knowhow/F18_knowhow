#include "f18.ch"

procedure Main(...)

public gDebug := 10

f18_test_init()

TEST_BEGIN("")

harbour_base()

modstru_test()

sifk_sifv_test()

TEST_END()

? "kraj"
