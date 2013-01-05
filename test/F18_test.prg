#include "f18.ch"

procedure Main(...)
local _param
public gDebug := 10


public _TEST_NO_DATABASE := .f.

FOR EACH _param IN hb_AParams()
    if _param == "--no-database"
       _TEST_NO_DATABASE := .t.
    endif
NEXT

f18_test_init()

post_login()

TEST_BEGIN("")

t_doc_counters()


/* na windowsima vrti beskonacno
MsgO("migrate")
test_migrate()
MsgC()
*/

//MsgO("fin_test")
//fin_test()
//MsgC()

MsgO("harbour base")
harbour_base()
MsgC()

MsgO("dbf_test")
dbf_test()
MsgC()

TEST_END()
return


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
return


