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

set_f18_params(...)

f18_test_init()

if !no_sql_mode()
   post_login()
endif

TEST_BEGIN("")

test_external_run()

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

/*
MsgO("dbf_test")
dbf_test()
MsgC()
*/

if !no_sql_mode()

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
endif
 

TEST_END()

? "kraj"

