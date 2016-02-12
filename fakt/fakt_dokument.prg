/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"



CLASS FaktDokument

    ACCESS     idfirma         METHOD get_idfirma()
    ASSIGN     idfirma         METHOD set_idfirma()
    ACCESS     idtipdok        INLINE ::p_idtipdok
    ASSIGN     idtipdok        METHOD set_idtipdok()
    ACCESS     brdok           INLINE ::p_brdok
    ASSIGN     brdok           METHOD set_brdok()

    ACCESS     broj            INLINE ::p_idfirma + "/" + ::p_idtipdok + "/" + ::p_brdok

    ACCESS     error_message   INLINE ::err_msg

    // info vraca hash matricu:
    //  neto_vrijednost, broj_stavki, distinct_roba, datdok, idpartner
    ACCESS     info            METHOD get_info()
    METHOD     refresh_info()

    METHOD     change_idtipdok(new_idtipdok)
    METHOD     refresh_dbfs()

    METHOD     New()
    METHOD     exists()

    // markiran
    ACCESS     mark     INLINE  ::p_marked
    ASSIGN     mark     METHOD   set_mark()

  PROTECTED:

    // access assign metodi dodaju "_" prefix
    DATA       p_idfirma
    DATA       p_idtipdok
    DATA       p_brdok
    DATA       p_h_info

    DATA       p_marked      INIT  .f.

    DATA       err_msg        INIT ""
    DATA       p_server
    DATA       p_sql_where
    METHOD     set_sql_where()

ENDCLASS


METHOD FaktDokument:New(idfirma, idtipdok, brdok, server)

   ::p_idfirma := idfirma
   ::p_idtipdok := idtipdok
   ::p_brdok := brdok

/*
   if server == NIL
      ::_server := my_server()
   else
      ::_server := server
   endif
*/


   ::set_sql_where()
return SELF

METHOD FaktDokument:get_idfirma()
return ::p_idfirma

METHOD FaktDokument:set_idfirma(val)
::p_idfirma := val
::set_sql_where()
return .t.

METHOD FaktDokument:set_idtipdok(val)
::p_idtipdok := val
::set_sql_where()
return .t.

METHOD FaktDokument:set_brdok(val)
::p_brdok := val
::set_sql_where()
return .t.

METHOD FaktDokument:set_sql_where()

::p_sql_where := "idfirma=" + sql_quote(::p_idfirma)
::p_sql_where += " AND idtipdok=" + sql_quote(::p_idtipdok)
::p_sql_where += " AND brdok=" + sql_quote(::p_brdok)

return .t.

METHOD FaktDokument:exists()
local _ret
local _qry := "SELECT count(*)  FROM fmk.fakt_doks WHERE " + ::p_sql_where


_ret := _qry:FieldGet(1)

if _ret > 1
    ::err_msg := "Dokument dupliran !?  cnt=" + to_str(_ret)
    log_write( ::err_msg, 2)
    MsgBeep(::err_msg)
    return .f.
endif

_ret := _qry:FieldGet(1)

return _ret


METHOD FaktDokument:refresh_info()

::p_h_info := NIL
return ::info

METHOD FaktDokument:get_info()
local _ret := hb_hash()
local _qry
local _qry_str

if ::p_h_info != NIL
    return ::p_h_info
endif

_qry_str:= "SELECT sum(kolicina * cijena * (1-Rabat/100)) from fmk.fakt_fakt WHERE " + ::p_sql_where
_qry := run_sql_query(_qry_str)
_ret["neto_vrijednost"] := _qry:FieldGet(1)

_qry_str := "SELECT count(*) from fmk.fakt_fakt WHERE " + ::p_sql_where
_qry := run_sql_query(_qry_str)
_ret["broj_stavki"] := _qry:FieldGet(1)

_qry_str := "SELECT DISTINCT(idroba) from fmk.fakt_fakt WHERE " + ::p_sql_where
_qry := run_sql_query(_qry_str)

_ret["distinct_idroba"] := {}
DO WHILE !_qry:EOF()
    AADD(_ret["distinct_idroba"], _qry:FieldGet(1))
   _qry:skip()
ENDDO

_qry_str := "SELECT datdok, idpartner from fmk.fakt_doks WHERE " + ::p_sql_where
_qry := run_sql_query(_qry_str)
_ret["datdok"] := _qry:FieldGet(1)
_ret["idpartner"] := _qry:FieldGet(2)

::p_h_info := _ret

return _ret


METHOD FaktDokument:set_mark(val)
::p_marked := val
return .t.

METHOD FaktDokument:refresh_dbfs()
local _ids_fakt:= {}, _ids_doks:={}
local _tmp_id

_tmp_id := ::p_idfirma + ::p_idtipdok + ::p_brdok
AADD( _ids_fakt, "#2" + _tmp_id )
AADD( _ids_doks,  _tmp_id )

// i na moj semafor stavi ovaj id da bih
// pokupio stanje sa servera
push_ids_to_semaphore( "fakt_fakt",  _ids_fakt, .t.)
push_ids_to_semaphore( "fakt_doks",  _ids_doks, .t.)
push_ids_to_semaphore( "fakt_doks2", _ids_doks, .t.)


METHOD FaktDokument:change_idtipdok(new_idtipdok)
local _srv := my_server()
local _sql, _qry
local _tmp_tbl := f18_user() + "_tmp_fakt_atributi"

// prvo sve u temp tabeli uraditi
_sql := "DROP TABLE IF EXISTS " + _tmp_tbl
_sql += ";"
_sql += "CREATE TEMP TABLE " + _tmp_tbl + " AS "
_sql += "SELECT * FROM fmk.fakt_fakt_atributi WHERE " + ::p_sql_where
_sql += ";"
_sql += "UPDATE " + _tmp_tbl + " SET idtipdok=" + sql_quote(new_idtipdok)
_sql += ";"
_sql += "DELETE FROM fmk.fakt_fakt_atributi "
_sql += " WHERE " + ::p_sql_where
_sql += ";"


_sql += "UPDATE fmk.fakt_fakt set idtipdok=" + sql_quote(new_idtipdok)
_sql += " WHERE " + ::p_sql_where
_sql += ";"

_sql += "UPDATE fmk.fakt_doks set idtipdok=" + sql_quote(new_idtipdok)
_sql += " WHERE " + ::p_sql_where
_sql += ";"

_sql += "UPDATE fmk.fakt_doks2 set idtipdok=" + sql_quote(new_idtipdok)
_sql += " WHERE " + ::p_sql_where
_sql += ";"

_sql += "INSERT INTO fmk.fakt_fakt_atributi (SELECT * from " + _tmp_tbl + ")"

_qry := _sql_query(_srv, _sql)

if VALTYPE(_qry) == "O"
  ::refresh_dbfs()
  ::p_idtipdok := new_idtipdok
  ::refresh_dbfs()
  return .t.
else
  return .f.
endif
