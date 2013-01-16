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

#include "hbclass.ch"
#include "common.ch"
#include "fmk.ch"

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
       DATA  _idtipdok
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

::_idfirma := idfirma
::_idtipdok := idtipdok
::_idpartner := idpartner

_qry_str := "SELECT fakt_doks.idfirma, fakt_doks.idtipdok, fakt_doks.brdok FROM fmk.fakt_fakt " 
_qry_str += "LEFT JOIN fmk.fakt_doks "
_qry_str += "ON fakt_fakt.idfirma=fakt_doks.idfirma AND fakt_fakt.idtipdok=fakt_doks.idtipdok AND fakt_fakt.brdok=fakt_doks.brdok "
_qry_str += "WHERE "

::_sql_where := "fakt_doks.idfirma=" + _sql_quote(::_idfirma) +  " AND fakt_doks.idtipdok=" + _sql_quote(::_idtipdok) + " AND fakt_doks.idpartner=" + _sql_quote(::_idpartner)

_qry_str += ::_sql_where
_qry := run_sql_query(_qry_str)

_cnt := 0
do while !_qry:eof()
   //_idfirma := _qry:FieldGet(1)
   //_idtipdok := _qry:FieldGet(2)
   _brdok := _qry:FieldGet(3)

   // napunicemo items matricom FaktDokument objekata
   _item := FaktDokument():New(::_idfirma, ::_idtipdok, _brdok)
   _item:refresh_info()
   AADD(::items, _item)
   _cnt ++
   _qry:skip()
enddo

::count := _cnt
return _cnt



// ----------------------------------------------
// ----------------------------------------------
METHOD FaktDokumenti:pretvori_otpremnice_u_racun()
local _idfirma, _idtipdok, _idpartner
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
    MsgBeep("FAKT priprema nije prazna")
    return .f.
endif

_idfirma   := gFirma
_idtipdok  := "12"
_idpartner := SPACE(6)
_suma      := 0
  
SET CURSOR ON 
Box(, MAXROWS()-10, MAXCOLS()-10 )

    @ m_x + 1, m_y + 2 SAY "PREGLED OTPREMNICA:"
    @ m_x + 3, m_y + 2 SAY "Radna jedinica" GET  _idfirma pict "@!"
    @ m_x + 3, col() + 1 SAY " - " + _idtipdok + " / " pict "@!"
    @ m_x + 3, col() + 1 SAY "Partner ID:" GET _idpartner pict "@!" ;
         VALID {|| P_Firma( @_idpartner ),  ispisi_partn( _idpartner, MAXROWS()-12, m_y + 18 ) }
        
    read

    ::za_partnera(_idfirma, _idtipdok, _idpartner)

    _fakt_browse := BrowseFaktDokumenti():New(m_x + 5, m_y +1, m_x + MAXROWS() - 13, MAXCOLS()-11, self) 
    _fakt_browse:browse()

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

