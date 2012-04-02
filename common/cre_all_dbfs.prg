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

function cre_all_dbfs(ver)

cre_sifk_sifv(ver)
cre_sifrarnici_1(ver)
cre_roba(ver)
cre_partn(ver)
cre_adres(ver)


Alert(RECI_GDJE_SAM + " fix: cre_all kalk, fakt, ld, mat, pos !")
// TODO: http://redmine.bring.out.ba/issues/25815
cre_all_fin(ver)

//cre_all_kalk(ver)

//cre_all_fakt(ver)

//cre_all_ld(ver)

//cre_all_os(ver)

//cre_all_mat(ver)

//cre_all_pos(ver)

_db := TDbFin():new()
_db:kreiraj()

//_db := TDbKalk():new()
//_db:kreiraj()


//_db := TDbFakt():new()
//_db:kreiraj()


//_db := TDbOs():new()
//_db:kreiraj()

//_db := TDbLd():new()
//_db:kreiraj()

//_db := TDbVirm():new()
//_db:kreiraj()

//_db := TDbEPdv():new()
//_db:kreiraj()

//_db := TDbPos():new()
//_db:kreiraj()

return


function CreSystemDb(nArea)
local lShowMsg

lShowMsg:=.f.

if (nArea==nil)
    nArea:=-1

    if goModul:oDatabase:lAdmin
        lShowMsg:=.t.
    endif

endif

if lShowMsg
    MsgO("Kreiram systemske tabele")
endif

CreGParam(nArea)

CreParams(nArea)

cre_adres()

if lShowMsg
    MsgC()
endif

return

function CreParams()
close all

if gReadOnly
    return
endif

aDbf:={}
AADD(aDbf, {"FH","C",1,0} )  // istorija
AADD(aDbf, {"FSec","C",1,0} )
AADD(aDbf, {"FVar","C",2,0} )
AADD(aDbf, {"Rbr","C",1,0} )
AADD(aDbf, {"Tip","C",1,0} ) // tip varijable
AADD(aDbf, {"Fv","C",15,0}  ) // sadrzaj


if !file(f18_ime_dbf("params"))
    DBCREATE2(PRIVPATH+"params.dbf",aDbf)
endif
CREATE_INDEX("ID","fsec+fh+fvar+rbr",PRIVPATH+"params.dbf",.t.)
    
if !file(f18_ime_dbf("gparams"))
    DBCREATE2(PRIVPATH+"gparams.dbf",aDbf)
endif
CREATE_INDEX("ID","fsec+fh+fvar+rbr", PRIVPATH + "gparams.dbf",.t.)

if !file(f18_ime_dbf("kparams"))
    DBCREATE2(KUMPATH+"KPARAMS.dbf",aDbf)
endif
CREATE_INDEX("ID", "fsec+fh+fvar+rbr", KUMPATH+"kparams.dbf", .t.)

aDbf:={}
AADD(aDbf, {"FH","C",1,0} )  // istorija
AADD(aDbf, {"FSec","C",1,0} )
AADD(aDbf, {"FVar","C",15,0} )
AADD(aDbf, {"Rbr","C",1,0} )
AADD(aDbf, {"Tip","C",1,0} ) // tip varijable
AADD(aDbf, {"Fv","C",15,0}  ) // sadrzaj

cImeDBf:=ToUnix(KUMPATH+"secur.dbf")
if !file(f18_ime_dbf(cImeDbF))
    DBCREATE2(cImeDBF,aDbf)
endif
CREATE_INDEX("ID","fsec+fh+fvar+rbr", cImeDBF, .t.)

return nil



function cre_adres( ver )
local _alias

_alias := "adres"

if !file(f18_ime_dbf( _alias ))
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
    DBCREATE2( _alias, aDBf )
    reset_semaphore_version( _alias )
    my_use( _alias )
 
endif

CREATE_INDEX("ID","id+naz", _alias )

return


* kreiraj gparams u glavnom modulu
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

_ime_cdx:= strtran(ime_dbf, "." + DBFEXT, "." + INDEXEXT)

if right(_ime_cdx, 4) == "." + INDEXEXT
  ferase(_ime_cdx)
endif

DBCREATE(ime_dbf, struct_dbf, driver)
return .t.


/*
function AddOidFields(aDbf)
*{

AADD(aDbf,{"_OID_", "N", 12, 0})
AADD(aDbf,{"_SITE_", "N", 2, 0})
AADD(aDbf,{"_DATAZ_", "D", 8, 0})
AADD(aDbf,{"_TIMEAZ_", "C", 8, 0})
AADD(aDbf,{"_COMMIT_", "C", 1, 0})
AADD(aDbf,{"_USER_", "N", 3, 0})

return
*}
*/


