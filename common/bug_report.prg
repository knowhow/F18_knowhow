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
#include "f18_ver.ch"
#include "error.ch"

// -----------------------------------------------
// -----------------------------------------------
function GlobalErrorHandler(err_obj)

local _i, _err_code
local _out_file

_err_code := err_obj:genCode

BEEP(5)
_out_file := my_home_root() + "error.txt"

PTxtSekvence()


/*
do case

   CASE objErr:genCode=EG_ARG
     MsgO(objErr:description+' Neispravan argument')
   CASE objErr:genCode=EG_BOUND
     MsgO(objErr:description+' Greska-EG_BOUND')
   CASE objErr:genCode=EG_STROVERFLOW
     MsgO(objErr:description+' Prevelik string')
   CASE objErr:genCode=EG_NUMOVERFLOW
     MsgO(objErr:description+' Prevelik broj')
   CASE objErr:genCode=36
     //Workarea not indexed
     lInstallDB:=.t.
     
   CASE objErr:genCode=EG_ZERODIV
     MsgO(objErr:description+' Dijeljenje sa nulom')
   CASE objErr:genCode=EG_NUMERR
     MsgO(objErr:description+' EG_NUMERR')
   CASE objErr:genCode=EG_SYNTAX
     MsgO(objErr:description+' Greska sa sintaksom')
   CASE objErr:genCode=EG_COMPLEXITY
     MsgO('Prevelika kompleksnost za makro operaciju')

   CASE objErr:genCode=EG_MEM
     MsgO(objErr:description+' Nepostojeca varijabla')


   CASE objErr:genCode=EG_NOFUNC
     MsgO(objErr:description+' Nepostojeca funkcija')
   CASE objErr:genCode=EG_NOMETHOD
     MsgO(objErr:description+' Nepostojeci metod')
   CASE objErr:genCode=EG_NOVAR
    MsgO(objErr:description+' Nepostojeca varijabla -?-')

   CASE objErr:genCode=EG_NOALIAS
     MsgO(objErr:description+' Nepostojeci alias')
   CASE objErr:genCode=EG_NOVARMETHOD
     MsgO(objErr:description+' Nepostojeci metod')

   CASE objErr:genCode=EG_CREATE
     MsgO(ObjErr:description+' Ne mogu kreirati fajl '+ObjErr:filename)
   CASE objErr:genCode=EG_OPEN
     MsgO(ObjErr:description+' Ne mogu otvoriti fajl '+ObjErr:filename)
     lInstallDB:=.t.
     
   CASE objErr:genCode=EG_CLOSE
     MsgO(objErr:description+':Ne mogu zatvoriti fajl '+ObjErr:filename)
   CASE objErr:genCode=EG_READ
     MsgO(objErr:description+':Ne mogu procitati fajl '+ObjErr:filename)
   CASE objErr:genCode=EG_WRITE
     MsgO(objErr:description+':Ne mogu zapisati u fajl '+ObjErr:filename)
   CASE objErr:genCode=EG_PRINT
     MsgO(objErr:description+':Greska sa stampacem !!!!')

   CASE objErr:genCode=EG_UNSUPPORTED
     MsgO(objErr:description+' Greska - nepodrzano')

   CASE objErr:genCode=EG_CORRUPTION
     MsgO(objErr:description+' Grska - ostecenje pomocnih CDX fajlova')
     lInstallDB:=.t.

   CASE objErr:genCode=EG_DATATYPE
     MsgO(objErr:description+' Greska - tip podataka neispravan')
   CASE objErr:genCode=EG_DATAWIDTH
     MsgO(objErr:description+' Greska EG_DATAWIDTH')
   CASE objErr:genCode=EG_NOTABLE
     MsgO(objErr:description+' Greska - EG_NOTABLE')
   CASE objErr:genCode=EG_NOORDER
     MsgO(objErr:description+' Greska - no order ')
   CASE objErr:genCode=EG_SHARED
     MsgO(objErr:description+' Greska - dijeljenje')
   CASE objErr:genCode=EG_UNLOCKED
     MsgO(objErr:description+' Greska - nije zakljucan zapis/fajl')
   CASE objErr:genCode=EG_READONLY
     MsgO(objErr:description+' Greska - samo za citanje')
   CASE objErr:genCode=EG_APPENDLOCK
     MsgO(objErr:description+' Greska - nije zakljucano pri apendovanju')
   OTHERWISE
     MsgO(objErr:description+' Greska !!!!')
 endcase

 INKEY(0)

 MsgC()

 if (lInstallDB .and. !(goModul:oDatabase:lAdmin) .and. Pitanje(,"Install DB procedura ?","D")=="D")
   goModul:oDatabase:install()
   return .t.
 endif

 cOdg:="N"
 if (objErr:genCode>=EG_ARG .and.  objErr:genCode<=EG_NOVARMETHOD) .or.;
    (objErr:genCode>=EG_UNSUPPORTED .and. objErr:genCode<=EG_APPENDLOCK)
   cOdg:="N"
 else

*/

set console off
    
set printer off
set device to printer

set printer to (_out_file)
set printer on


P_12CPI

? REPLICATE("=", 84) 
? "F18 bug report:", DATE(), TIME()
? REPLICATE("=", 84) 


? "Verzija programa:", F18_VER, F18_VER_DATE, FMK_LIB_VER
?

? "Podsistem  :", err_obj:SubSystem
? "GenKod     :", str(err_obj:GenCode, 3), "OpSistKod:", str(err_obj:OsCode,3)
? "Opis       :", err_obj:description
? "ImeFajla   :", err_obj:filename
? "Operacija  :", err_obj:operation
? "Argumenti  :", err_obj:args

? 
? "CALL STACK:"
? "---", REPLICATE("-", 80)
for _i := 1 to 30
   if !empty(PROCNAME(_i))
       ? STR(_i, 3), PROCNAME(_i) + " / " +   ALLTRIM(STR(ProcLine(_i), 6))
   endif
next
? "---", REPLICATE("-", 80)
?

server_info()

if used() 
   current_dbf_info()
else
   ? "USED() = false"
endif

? 
? "== END OF BUG REPORT =="


SET DEVICE TO SCREEN
set printer off
set printer to
set console on


close all

run (_cmd := "f18_editor " + _out_file)

RETURN

static function server_info()
local _key
local _server_vars := {"server_version", "TimeZone"}

?
? "/---------- BEGIN PostgreSQL vars --------/"
?
for each _key in _server_vars 
  ? PADR(_key, 25) + ":",  server_show(_key)
next
?
? "/----------  END PostgreSQL vars --------/"
?
?
return .t.

// ---------------------------------
// ---------------------------------
static function current_dbf_info()
local _struct, _i

? "Trenutno radno podrucje:", alias() ,", record:", RECNO(), "/", RECCOUNT()

_struct := DBSTRUCT()

? REPLICATE("-", 60)
? "Record content:"
? REPLICATE("-", 60)
for _i := 1 to LEN( _struct )
   ? STR(_i, 3), _struct[_i, 1], _struct[_i, 2], _struct[_i, 3], _struct[_i, 4], EVAL(FIELDBLOCK(_struct[_i, 1]))
next
? REPLICATE("-", 60)

return .t.

