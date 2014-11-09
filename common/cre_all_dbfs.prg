/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"
#include "cre_all.ch"



function cre_all_dbfs(ver)
local _first_start := fetch_metric( "f18_first_start", my_user(), 0 )
local _local_files, _local_files_count

// first_start, ako je 0 onda je to prvi ulazak u bazu...
if _first_start = 0

    // napravi dodatnu provjeru radi postojecih instalacija...
    _local_files := DIRECTORY( my_home() + "*.dbf" )    
    _local_files_count := LEN( _local_files )

    // ovdje mozemo poduzeti neka pitanja...
    if _local_files_count = 0
        // recimo mozemo birati module za glavni meni itd...
        f18_set_active_modules()
    endif

endif

#ifdef TEST
   if _TEST_NO_DATABASE
       // bez kreiranja F18 tabela
       return .t.
   endif
#endif

log_write("START cre_all_dbfs", 5)

cre_sifk_sifv(ver)
cre_sifrarnici_1(ver)
cre_roba(ver)
cre_partn(ver)
_kreiraj_adrese(ver)
cre_all_ld_sif(ver)
cre_all_virm_sif(ver)
proizvoljni_izvjestaji_db_cre(ver)
cre_fin_mat(ver)

if f18_use_module( "fin" )
    // glavni fin tabele
    cre_all_fin(ver)
    _db := TDbFin():new()
    _db:kreiraj()
endif

if f18_use_module( "kalk" )
    cre_all_kalk(ver)
    _db := TDbKalk():new()
    _db:kreiraj()
endif

if f18_use_module( "fakt" ) 
    cre_all_fakt(ver)
    _db := TDbFakt():new()
    _db:kreiraj()
endif

if f18_use_module( "ld" )
    cre_all_ld(ver)
    _db := TDbLd():new()
    _db:kreiraj()
endif


if f18_use_module( "os" )
    cre_all_os(ver)
    _db := TDbOs():new()
    _db:kreiraj()
endif


if f18_use_module( "virm" )
   cre_all_virm(ver)
   _db := TDbVirm():new()
   _db:kreiraj()
endif


if f18_use_module( "epdv" )
   cre_all_epdv(ver)
endif

if f18_use_module( "pos" )
   cre_all_pos(ver)
   _db := TDbPos():new()
   _db:kreiraj()
endif


if _first_start = 0
    // setuj da je modul vec aktiviran...
    set_metric( "f18_first_start", my_user(), 1 )
endif

log_write("END crea_all_dbfs", 5)

return




function CreSystemDb( ver )
_kreiraj_params_tabele(ver)
_kreiraj_adrese(ver)
return




function _kreiraj_params_tabele()
local _table_name, _alias, aDBF

close all

aDbf := {}
AADD(aDbf, {"FH","C",1,0} )  // istorija
AADD(aDbf, {"FSec","C",1,0} )
AADD(aDbf, {"FVar","C",2,0} )
AADD(aDbf, {"Rbr","C",1,0} )
AADD(aDbf, {"Tip","C",1,0} ) // tip varijable
AADD(aDbf, {"Fv","C",15,0}  ) // sadrzaj

_alias := "PARAMS"
_table_name := "params"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("ID","fsec+fh+fvar+rbr", _alias, .t. )
    
_alias := "GPARAMS"
_table_name := "gparams"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("ID","fsec+fh+fvar+rbr", _alias, .t. )

_alias := "KPARAMS"
_table_name := "kparams"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("ID", "fsec+fh+fvar+rbr", _alias, .t. )

return nil




function _kreiraj_adrese( ver )
local _table_name, _alias, _created

_alias := "ADRES"
_table_name := "adres"

aDBF:={}
AADD(aDBf,{ 'ID'    , 'C' ,  50 ,   0 })
AADD(aDBf,{ 'RJ'    , 'C' ,  30 ,   0 })
AADD(aDBf,{ 'KONTAKT'    , 'C' ,  30 ,   0 })
AADD(aDBf,{ 'NAZ'        , 'C' ,  15 ,   0 })
AADD(aDBf,{ 'TEL2'       , 'C' ,  15 ,   0 })
AADD(aDBf,{ 'TEL3'       , 'C' ,  15 ,   0 })
AADD(aDBf,{ 'MJESTO'     , 'C' ,  15 ,   0 })
AADD(aDBf,{ 'PTT'        , 'C' ,  6 ,   0 })
AADD(aDBf,{ 'ADRESA'     , 'C' ,  50 ,   0 })
AADD(aDBf,{ 'DRZAVA'     , 'C' ,  22 ,   0 })
AADD(aDBf,{ 'ziror'     , 'C' ,  30 ,   0 })
AADD(aDBf,{ 'zirod'     , 'C' ,  30 ,   0 })
AADD(aDBf,{ 'K7'     , 'C' ,  1 ,   0 })
AADD(aDBf,{ 'K8'     , 'C' ,  2 ,   0 })
AADD(aDBf,{ 'K9'     , 'C' ,  3 ,   0 })

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("ID","id+naz", _alias )

return




function CreGparam(nArea)
local aDbf

if (nArea==nil)
    nArea:=-1
endif

close all

if gReadonly
    return
endif

aDbf:={}
AADD(aDbf, {"FH","C",1,0} )  // istorija
AADD(aDbf, {"FSec","C",1,0} )
AADD(aDbf, {"FVar","C",2,0} )
AADD(aDbf, {"Rbr","C",1,0} )
AADD(aDbf, {"Tip","C",1,0} ) // tip varijable
AADD(aDbf, {"Fv","C",15,0}  ) // sadrzaj

if (nArea==-1 .or. nArea==F_GPARAMS)

    cImeDBf:= f18_ime_dbf("gparams")

    if !file(cImeDbf)
        DBCREATE2(cImeDbf, aDbf)
    endif

    CREATE_INDEX("ID", "fsec+fh+fvar+rbr", cImeDBF )
endif

return
*}


function KonvParams(cImeDBF)
*{
cImeDBF:=f18_ime_dbf(cImeDBF)
close  all
if file(cImeDBF) // ako postoji
use (cImeDbf)
if fieldpos("VAR")<>0  // stara varijanta parametara
       save screen to cScr
       cls
       Modstru(cImeDbf,"C H C 1 0  FH  C 1 0",.t.)
       Modstru(cImeDbf,"C SEC C 1 0  FSEC C 1 0",.t.)
       Modstru(cImeDbf,"C VAR C 2 0 FVAR C 2 0",.t.)
       Modstru(cImeDbf,"C  V C 15 0  FV C 15 0",.t.)
       Modstru(cImeDbf,"A BRISANO C 1 0",.t.)  // dodaj polje "BRISANO"
       inkey(2)
       restore screen from cScr
endif
endif
close all
return
*}


// -------------------------------
// -------------------------------
function dbf_ext_na_kraju(cIme)

cIme:=ToUnix(cIme)
if right(cIme,4)<>"." + DBFEXT
   cIme:=cIme+"." + DBFEXT
endif


// ------------------------------------------
// ------------------------------------------
function DBCREATE2(ime_dbf, struct_dbf, driver)

local _pos
local _ime_cdx

ime_dbf := f18_ime_dbf(ime_dbf)

_ime_cdx:= ImeDbfCdx(ime_dbf)

if right(_ime_cdx, 4) == "." + INDEXEXT
  ferase(_ime_cdx)
endif

DBCREATE(ime_dbf, struct_dbf, driver)
return .t.


