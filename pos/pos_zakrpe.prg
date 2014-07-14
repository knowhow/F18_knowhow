/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "pos.ch"



function pos_zakrpe_mnu()
local _Opc:={}
local _opcexe:={}
local _Izbor:=1

AADD(_opc,"1. doks ///                                          ")
AADD(_opcexe, {|| Zakrpa1()})
AADD(_opc,"2. postavi tarife u prometu kao u sifrarniku robe ")
AADD(_opcexe, {|| KorekTar()})

f18_menu( "zakr", .f., _izbor, _opc, _opcexe )

close all
return



function Zakrpa1()
local _rec

if !SigmaSif("BUG1DOKS")
  return
endif

if Pitanje(,"Izbrisati DOKS - radnika '////'","N")=="D"

    O_POS_DOKS
    set order to
    go top
    nCnt:=0
   
    f18_lock_tables({"pos_doks"}) 
    sql_table_update( nil, "BEGIN" )

    do while !eof()
        if field->idradnik == '////'
	        nCnt ++
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )
	    endif
	    skip
    enddo

    f18_free_tables({"pos_doks"}) 
    sql_table_update( nil, "END" )

    MsgBeep( "Izbrisano " + STR( nCnt ) + " slogova" )

endif
return nil


