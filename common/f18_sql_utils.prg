/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"


// ----------------------------------------
// ----------------------------------------
function run_sql_query(qry, retry) 
local _i, _qry_obj
local _server := my_server()

// sslv3 alert handshake failure dobijam ?!

for _i:=1 to retry

   ? qry
   begin sequence with {|err| Break(err)}
       _qry_obj := _server:Query(qry)
   recove
      log_write("ajoj ajoj: qry rokno !?!")
      my_server_logout()
      hb_IdleSleep(0.5)
      _server := my_server_login()
   end sequence

   if _qry_obj:NetErr()
       log_write("ajoj :" + _qry_obj:ErrorMsg())
       log_write("error na:" + qry)
       my_server_logout()
       hb_IdleSleep(0.5)
       _server := my_server_login()
   
       if _i == retry
           MsgBeep("neuspjesno nakon " + to_str(retry) + "pokusaja !?")
           QUIT
       endif
     else
       _i := retry + 1
     endif
next

return _qry_obj



// pomoćna funkcija za sql query izvršavanje
function _sql_query( oServer, cQuery )
local oResult, cMsg

oResult := oServer:Query( cQuery )
IF oResult:NetErr()
      cMsg := oResult:ErrorMsg()
      if gDebug > 0 
         log_write(cQuery)
         log_write(cMsg)
      endif
      MsgBeep( cMsg )
      return .f.
ENDIF
RETURN oResult

// -------------------------------------
// setovanje sql schema path-a
function _set_sql_path( oServer)
local _server := my_server()
local _path := my_server_search_path()

local _qry := "SET search_path TO " + _path + ";"
local _result
local _msg

_result := _server:Query( _qry )
IF _result:NetErr()
      _msg := _result:ErrorMsg()
      if gDebug > 0 
         log_write(_qry)
         log_write(_msg)
      endif
      MsgBeep( _msg )
      return .f.
ENDIF

RETURN _result


/*

function SQLValue(xVar, nDec, cKonv)
local cPom, cChar, cChar2, nStat,ilok

if cKonv=NIL
  cKonv:="DBF"
endif

if valtype(xVAR)="C"
   if cKonv=="DBF"
     cPom:=""
     nStat:=0
     for ilok:=1 to len(xVar)
        cChar:=substr(xVar,ilok,1)
	cChar2:="CHAR("+alltrim(str(asc(cChar)))+")"
        if ASC(cChar)=39 .or. ASC(cChar)>127 // "'"
           if nStat=0
             cPom:=cChar2
           elseif nStat=1
             cPom:=cPom + "'+" + cChar2
           elseif nStat=2
             cPom:=cPom + "+" + cChar2
           endif
           nStat:=2
        else
	   // debug NULNULNUL
           if ASC(cChar) == 0
	   	cChar := " "
	   endif
	   
	   if nStat=0
             cPom := "'" + cChar
           elseif nStat=1
	     cPom:=cPom+cChar
           else
             cPom:=cPom + "+'" + cChar
           endif
           
	   nStat:=1
	   
        endif
     next
     if nStat=0
        cPom:="''"
     elseif nStat=1
        cPom := cPom + "'"
     elseif nStat=2
        // nista ... gotovo je
     endif
   endif
   return cPom

elseif valtype(xVAR)="N"

   if nDec<>NIL
     return alltrim(str(xVar,25,nDec))
   else
     return alltrim(str(xVar))
   endif

elseif valtype(xVar)="D"

   cPom:=dtos(xVar)
   if empty(cPom)
     cPom:=replicate('0',8)
   endif
   //1234-56-78
   cPom:="'"+substr(cPom,1,4)+"-"+substr(cPom,5,2)+"-"+substr(cPom,7,2)+"'"
   return cPom

else
   return "NULL"
endif



*/

// ------------------------
// ------------------------
function _sql_quote(xVar)
local cOut

if VALTYPE(xVar) == "C"
    cOut := STRTRAN(xVar, "'","''")
    cOut := "'" + hb_strtoutf8(cOut) + "'"
elseif VALTYPE(xVar) == "D"
    if xVar == CTOD("")
            cOut := "NULL"
    else
            cOut:=DTOS(xVar)
            if EMPTY(cOut)
                cPom:=replicate('0',8)
            endif
            //1234-56-78
            cOut := "'" + substr(cOut,1,4) + "-" + substr(cOut,5,2) + "-" + substr(cOut,7,2) + "'"
    endif
else
    cOut := "NULL"
endif

return cOut


