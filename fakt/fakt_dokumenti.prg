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

#include "fmk.ch"

#include "hbclass.ch"
#include "common.ch"

// ------------------------------------------------
// ------------------------------------------------
CLASS FaktDokument

    ACCESS     idfirma         INLINE ::_idfirma
    ACCESS     idtipdok        INLINE ::_idtipdok
    ACCESS     brdok           INLINE ::_brdok

    ASSIGN     idfirma         METHOD set_idfirma()
    ASSIGN     idtipdok        METHOD set_idtipdok()
    ASSIGN     brdok           METHOD set_brdok()

    ACCESS     error_message   INLINE ::err_msg 

    // info vraca hash matricu: 
    //  neto_vrijednost, broj_stavki, distinct_roba, datdok, idpartner
    ACCESS     info            METHOD get_info()
    METHOD     refresh_info() 

    METHOD     New()
    METHOD     exists()

  PROTECTED:

    DATA       _idfirma
    DATA       _idtipdok
    DATA       _brdok
    DATA       _h_info
 
    DATA       err_msg        INIT ""
    DATA       _sql_where
    METHOD     set_sql_where()

ENDCLASS

// ------------------------------------------------
// ------------------------------------------------
CLASS FaktDokumenti

    DATA    items
    DATA    count
    
    METHOD  New()
    METHOD  za_partnera(idfirma, idtipdok, idpartner)
    METHOD  pretvori_otpremnice_u_racun()

    PROTECTED:
       DATA  _sql_where
       DATA  _idfirma
       DATA  _idtidpok
       DATA  _idpartner
ENDCLASS


// ---------------------------------
// ---------------------------------
METHOD FaktDokumenti:New()
::items := {}
::count := 0

return self

//------------------------------------------------------------
//------------------------------------------------------------
METHOD FaktDokumenti:za_partnera(idfirma, idtipdok, idpartner)
local _qry_str
local _idfirma, _idtipdok, _brdok 
local _cnt

_qry_str := "SELECT idfirma, idtipdok, brdok FROM fmk.fakt_fakt " 
_qry_str += "LEFT JOIN fmk.fakt_doks "
_qry_str += "ON fakt_fakt.idfirma=fakt_doks.idfirma AND fakt_fakt.idtipdok=fakt_doks.idtipdok AND fakt_fakt.brdok=fakt_doks.brdok "
_qry_str += "WHERE "

::_sql_where := "idfirma=" + _sql_quote(::_idfirma) +  " idtipdok=" + _sql_quote(::_idtipdok) + " fakt_doks.idpartner=" + _sql_quote(::_idpartner)

_qry_str += ::_sql_where

_qry := run_sql_query(_qry_str)

_cnt := 0
do while !_qry:eof()
   _idfirma := qry:FieldGet(1)
   _idtipdok := qry:FieldGet(2)
   _brdok := qry:FieldGet(3)

   // napunicemo items matricom FaktDokument objekata
   _item := FaktDokument():New(_idfirma, _idtipdok, _brdok)
   _item:refresh_info()
   _cnt ++
   _qry:skip()
enddo

::count := _cnt
return _cnt



METHOD FaktDokument:New(idfirma, idtipdok, brdok, server)
	   
   ::_idfirma := idfirma
   ::_idtipdok := idtipdok
   ::_brdok := brdok
     
   if server == NIL
      ::server := my_server()
   endif

   ::set_sql_where()
return SELF


METHOD FaktDokument:set_idfirma(val)
::_idfirma := val
::set_sql_where()

METHOD FaktDokument:set_idtipdok(val)
::_idtipdok := val
::set_sql_where()


METHOD FaktDokument:set_brdok(val)
::_brdok := val
::set_sql_where()


METHOD FaktDokument:set_sql_where()
::_sql_where := "idfirma=" + _sql_quote(::_idfirma) +  " idtipdok=" + _sql_quote(::_idtipdok) + " brdok=" + _sql_quote(::_brdok)

METHOD FaktDokument:exists()
local _ret
local _qry := "SELECT count(*)  FROM fmk.fakt_doks WHERE " + ::_sql_where


_ret := _qry:FieldGet(1)

if _ret > 1
    ::err_msg := "Dokument dupliran !?  cnt=" + to_str(_ret)
    log_write( ::err_msg, 2)
endif

_ret := _qry:FieldGet(1) 


METHOD FaktDokument:refresh_info()

::_h_info := NIL
return ::info

METHOD FaktDokument:get_info()
local _ret := hb_hash()
local _qry
local _qry_str 

if ::_hinfo != NIL
    return ::_h_info
endif

_qry_str:= "SELECT sum(kolicina * cijena * (1-Rabat/100)) from fmk.fakt_fakt WHERE " + ::_sql_where
_qry := run_sql_query(_qry_str)
_ret["neto_vrijednost"] := _qry:FieldGet(1)

_qry_str := "SELECT count(*) from fmk.fakt_fakt WHERE " + ::_sql_where
_qry := run_sql_query(_qry_str)
_ret["broj_stavki"] := _qry:FieldGet(1)

_qry_str := "SELECT DISTINCT(idroba) from fmk.fakt_fakt WHERE " + ::_sql_where
_qry := run_sql_query(_qry_str)

_ret["distinct_idroba"] := {}
DO WHILE !_qry_obj:EOF()
    AADD(_ret["distinct_idroba"], _qry:FieldGet(1))
   _qry:skip() 
ENDDO

_qry_str := "SELECT datdok, idpartner from fmk.fakt_doks WHERE" + ::_sql_where
_qry := run_sql_query(_qry_str)
_ret["datdok"] := _qry:FieldGet(1)
_ret["idpartner"] := _qry:FieldGet(2)
 
::_h_info := _ret

return _ret


// ----------------------------------------------
// ----------------------------------------------
METHOD FaktDokumenti:pretvori_otpremnice_u_racun()
local _idpartner
local _suma := 0
local _veza_otpr := ""
local _datum_max := DATE()
local _ok
local _lock_user := ""
local _fakt_browse

O_FAKT_PRIPR
go top

// ako je priprema prazna
if RecCount2() <> 0
    select fakt_pripr
    return .f.
endif

_otpr_tip := "12"
_firma    := gFirma
_suma      := 0
_idpartner := SPACE(6)
   
Box(, 20, 75 )

    @ m_x + 1, m_y + 2 SAY "PREGLED OTPREMNICA:"
    @ m_x + 3, m_y + 2 SAY "Radna jedinica" GET  _firma pict "@!"
    @ m_x + 3, col() + 2 SAY "Partner:" GET _idpartner pict "@!"

    read

    ::za_partnera(_firma, _otpr_tip, _idpartner)

    _fakt_browse := BrowseFaktDokumenti():New(m_x + 5, m_y +1, m_x + 19, m_y + 73, self) 
    _fakt_browse:browse()
    //BrowseKey( m_x + 5, m_y + 1, m_x + 19, m_y+ 73, ImeKol, ;
    //            {|ch| EdOtpr( ch, @_suma) }, "idfirma+idtipdok = _firma + _otpr_tip",;
    //            _firma + _otpr_tip, 2, , , {|| partner = _partn_naz } )

BoxC()

/*
if __generisati .and. Pitanje(, "Formirati fakturu na osnovu gornjih otpremnica ?", "N" ) == "D"
     
    _ok := _formiraj_racun( _firma, _otpr_tip, _partn_naz, @_veza_otpr, @_datum_max )
 
    if _ok
        // ovdje ce se setovati jos i parametri dokumenta...
        // datum otpremnice, datum valute... destinacija itd...
        select fakt_pripr
        renumeracija_fakt_pripr( _veza_otpr, _datum_max )
    endif

    select fakt_doks
    set order to tag "1"

endif 
*/

return .t.
