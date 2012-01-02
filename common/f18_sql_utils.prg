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


// ------------------------------
// fields := { "id, "naz" }
// => "id, naz"
//
function sql_fields(fields)
local  _i, _sql_fields := ""	

for _i:=1 to LEN(fields)
   _sql_fields += fields[_i]
   if _i < LEN(fields)
      _sql_fields +=  ","
   endif
next

return _sql_fields

 

//----------------------------------------------
// ----------------------------------------------
function sql_table_update(table, op, record, where )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()
local _key
local _dbstruct
local __pos
local __dec
local __len

_tbl := "fmk." + LOWER(table)

DO CASE
   CASE op == "BEGIN"
    _qry := "BEGIN;"

   CASE op == "END"
    _qry := "COMMIT;" 

   CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"

   CASE op == "del"
    if (where == NIL) .and. (record == NIL .or. (record["id"] == NIL))
      // brisi kompletnu tabelu
      _where := "true"
      MsgBeep(PROCNAME(1) + "/" + ALLTRIM(STR(PROCLINE(1))) + " nedozvoljeno stanje, postavit eksplicitno where na 'true' !!")
      QUIT
    else
      if where == NIL
         _where := "ID = " + _sql_quote(record["id"])
      else
         // moze biti "id = nesto and id_2 = nesto_drugo"
         _where := where
      endif
    endif
    _qry := "DELETE FROM " + _tbl + ;
            " WHERE " + _where  

   CASE op == "ins"
	
	_dbstruct := {}
	_dbstruct := DBSTRUCT()

    _qry := "INSERT INTO " + _tbl + "(" 
    for each  _key in record:Keys
       _qry +=  _key + ","
    next 
    // otkini zadnji zarez
    _qry := SUBSTR( _qry, 1, LEN(_qry) - 1) + ")"

    _qry += " VALUES(" 
     
    for each _key in record:Keys
        // ako je polje numericko
		if VALTYPE( record[_key] ) == "N"
			
			__pos := ASCAN( _dbstruct, {|_var| LOWER(_var[1]) == LOWER(_key)} )
			__len := _dbstruct[ __pos, 3 ]
			__dec := _dbstruct[ __pos, 4 ]
  
			_qry += STR( record[_key], __len, __dec ) + ","
        else
			_qry += _sql_quote( record[_key]) + ","
    	endif 	
	next 
    _qry := SUBSTR( _qry, 1, LEN(_qry) - 1) + ")"

END CASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif


// ----------------------------------------
// ----------------------------------------
function run_sql_query(qry, retry) 
local _i, _qry_obj
local _server := my_server()

// sslv3 alert handshake failure dobijam ?!

if retry == NIL
  retry := 1
endif

for _i:=1 to retry

   ? qry
   begin sequence with {|err| Break(err)}
       _qry_obj := _server:Query(qry)
   recove
      log_write("ajoj ajoj: qry rokno !?!")
      my_server_logout()
      hb_IdleSleep(0.5)
      if my_server_login()
         _server := my_server()
      endif
   end sequence

   if _qry_obj:NetErr()
       log_write("ajoj :" + _qry_obj:ErrorMsg())
       log_write("error na:" + qry)
       my_server_logout()
       hb_IdleSleep(0.5)
       if my_server_login()
            _server := my_server()
       endif

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
// -----------------------------------
function set_sql_search_path()
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
            cOut := "'" + substr(cOut, 1, 4) + "-" + substr(cOut, 5, 2) + "-" + substr(cOut, 7, 2) + "'"
    endif
else
    cOut := "NULL"
endif

return cOut

// ---------------------------------------
// ---------------------------------------
function sql_where_block(table_name, x)
local _ret, _pos, _fields, _item, _key

_pos := ASCAN(gaDBFS, {|x| x[3] == table_name })

if _pos == 0
   MsgBeep(PROCLINE(1) + "sql_where_block tbl ne postoji" + table_name)
   QUIT
endif

// npr. _fields := {{"godina", 4}, "idrj", {"mjesec", 2}, "obr", "idradn" }
_fields := gaDBFS[_pos, 6]

_ret := ""
for each _item in _fields

   if !EMPTY(_ret)
       _ret += " AND "
   endif

   if VALTYPE(_item) == "A"
      // numeric
      _key := LOWER(_item[1])
      _ret += _item[1] + "=" + STR(x[_key], _item[2])

   elseif VALTYPE(_item) == "C"
      _key := LOWER(_item)
      _ret += _item + "=" + _sql_quote(x[_key])
 
   else
       MsgBeep(PROCNAME(1) + "valtype _item ?!")
       QUIT
   endif

next

return _ret


// ---------------------------------------
// ---------------------------------------
function sql_concat_ids(table_name)
local _ret, _pos, _fields, _item

_pos := ASCAN(gaDBFS, {|x| x[3] == table_name })

if _pos == 0
   MsgBeep(PROCLINE(1) + "sql tbl ne postoji in gaDBFs " + table_name)
   QUIT
endif

// npr. _fields := {{"godina", 4}, "idrj", {"mjesec", 2}, "obr", "idradn" }
_fields := gaDBFS[_pos, 6]

_ret := ""

for each _item in _fields

   if !EMPTY(_ret)
       _ret += " || "
   endif

   if VALTYPE(_item) == "A"
      // numeric
      // to_char(godina, '9999') 
      _ret += "to_char(" + _item[1] + ",'" + REPLICATE("9", _item[2]) + "')"

   elseif VALTYPE(_item) == "C"
      _ret += _item
 
   else
       MsgBeep(PROCNAME(1) + "valtype _item ?!")
       QUIT
   endif

next

return _ret


