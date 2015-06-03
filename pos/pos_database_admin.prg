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



function NaprPom( aDbf, cPom )

if cPom == nil
    cPom := "POM"
endif

cPomDBF := my_home() + "pom.dbf"
cPomCDX := my_home() + "pom.cdx"

if File(cPomDBF)
    FErase(cPomDBF)
endif

if File(cPomCDX)
    FErase(cPomCDX)
endif

if File(UPPER(cPomDBF))
    FErase(UPPER(cPomDBF))
endif

if File (UPPER(cPomCDX))
    FErase(UPPER(cPomCDX))
endif

// kreiraj tabelu pom.dbf
DBcreate( my_home() + "pom.dbf", aDbf )

return



function ChkTblPromVp()
local cTbl

cTbl:=DbfName(F_PROMVP,.t.)+'.'+DBFEXT

if (FILE(cTbl))
    O_PROMVP
    if (FIELDPOS("polog01")==0 .or. FIELDPOS("_SITE_")==0)
        USE
        goModul:oDatabase:kreiraj(F_PROMVP)
        USE
    endif
    USE
endif

return



function CrePosISifData()
local _rec

O_STRAD

if (RECCOUNT2() == 0)
    
    MsgO("Kreiram ini STRAD")

    f18_lock_tables({"pos_strad"})
    sql_table_update( nil, "BEGIN")

    select strad
    append blank
    _rec := dbf_get_rec()
    _rec["id"] := PADR( "0", LEN( _rec["id"] ) )
    _rec["prioritet"] := PADR( "0", LEN( _rec["prioritet"] ) )
    _rec["naz"] := PADR( "Nivo adm.", LEN( _rec["naz"] ) )

    update_rec_server_and_dbf( "pos_strad", _rec, 1, "CONT" )
    
    append blank
    _rec := dbf_get_rec()
    _rec["id"] := PADR( "1", LEN( _rec["id"] ) )
    _rec["prioritet"] := PADR( "1", LEN( _rec["prioritet"] ) )
    _rec["naz"] := PADR( "Nivo upr.", LEN( _rec["naz"] ) )

    update_rec_server_and_dbf( "pos_strad", _rec, 1, "CONT" )

    append blank
    _rec := dbf_get_rec()
    _rec["id"] := PADR( "3", LEN( _rec["id"] ) )
    _rec["prioritet"] := PADR( "3", LEN( _rec["prioritet"] ) )
    _rec["naz"] := PADR( "Nivo prod.", LEN( _rec["naz"] ) )

    update_rec_server_and_dbf( "pos_strad", _rec, 1, "CONT" )

    f18_free_tables({"pos_strad"})
    sql_table_update( nil, "END")

    MsgC()
    
endif

O_OSOB

if (RECCOUNT2() == 0)
    
    MsgO("Kreiram ini OSOB")
    
    select osob
  
    f18_lock_tables({"pos_osob"}) 
    sql_table_update( nil, "BEGIN")
    
    append blank
    _rec := dbf_get_rec()
    _rec["id"] := PADR( "0001", LEN( _rec["id"] ) )
    _rec["korsif"] := PADR( CryptSc( PADR( "PARSON", 6 ) ), 6 )
    _rec["naz"] := PADR( "Admin", LEN( _rec["naz"] ) )
    _rec["status"] := PADR( "0", LEN( _rec["status"] ) )

    update_rec_server_and_dbf( "pos_osob", _rec, 1, "CONT" )
    
    append blank
    _rec := dbf_get_rec()
    _rec["id"] := PADR( "0010", LEN( _rec["id"] ) )
    _rec["korsif"] := PADR( CryptSc( PADR( "P1", 6 ) ), 6 )
    _rec["naz"] := PADR( "Prodavac 1", LEN( _rec["naz"] ) )
    _rec["status"] := PADR( "3", LEN( _rec["status"] ) )

    update_rec_server_and_dbf( "pos_osob", _rec, 1, "CONT" )
    
    append blank
    _rec := dbf_get_rec() 
    _rec["id"] := PADR( "0011", LEN( _rec["id"] ) )
    _rec["korsif"] := PADR( CryptSc( PADR( "P2", 6 ) ), 6 )
    _rec["naz"] := PADR( "Prodavac 2", LEN( _rec["naz"] ) )
    _rec["status"] := PADR( "3", LEN( _rec["status"] ) )

    update_rec_server_and_dbf( "pos_osob", _rec, 1, "CONT" )
    
    f18_free_tables({"pos_osob"}) 
    sql_table_update( nil, "END")

    MsgC()

endif

CLOSE ALL

return

