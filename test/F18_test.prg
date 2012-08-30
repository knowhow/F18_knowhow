#include "f18.ch"

procedure Main(...)

public gDebug := 10

f18_test_init()

post_login()

TEST_BEGIN("")

MsgO("migrate")
test_migrate()
MsgC()

// test bug
// ? ajoj

//MsgO("fin_test")
//fin_test()
//MsgC()

MsgO("harbour base")
harbour_base()
MsgC()

/*
MsgO("dbf_test")
dbf_test()
MsgC()
*/

MsgO("modstru")
modstru_test()
MsgC()

/*
MsgO("sifk/sifv")
sifk_sifv_test()
MsgC()
*/

MsgO("fetch")
fetch_set_metric()
MsgC()

test_version()

//test_thread()


//test_semaphores()

i_dodaj_sifre()
i_fakt()

 

TEST_END()

? "kraj"


