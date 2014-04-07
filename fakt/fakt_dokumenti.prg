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

    METHOD  count_markirani    
    METHOD  New()
    METHOD  za_partnera(idfirma, idtipdok, idpartner)
    METHOD  pretvori_otpremnice_u_racun()
    METHOD  change_idtipdok_markirani(new_idtipdok)

    ASSIGN  locked   INLINE ::p_locked
    METHOD  lock()
    METHOD  unlock()

    PROTECTED:
       METHOD generisi_fakt_pripr_vars()
       METHOD  generisi_fakt_pripr()
       DATA  _sql_where
       DATA  p_idfirma
       DATA  p_idtipdok
       DATA  p_idpartner
       DATA  p_locked  INIT .f.
       DATA  p_lock_tables INIT {"fakt_fakt", "fakt_doks", "fakt_doks2"}
ENDCLASS

// ---------------------------------
// ---------------------------------
METHOD FaktDokumenti:New()

::items := {}
::count := 0

return self


// -------------------------------------------
// lokuj - zabrani promjene drugih
//         logika semafora ovo zahtjeva
// -------------------------------------------
METHOD FaktDokumenti:lock()

if f18_lock_tables(::p_lock_tables)
   ::p_locked := .t.
else   
   ::p_locked := .f.
endif
return ::p_locked

// ----------------------------------------------------------
// unlock - oslobodi tabele za update od strane drugih
// ----------------------------------------------------------
METHOD FaktDokumenti:unlock()
f18_free_tables(::p_lock_tables)
return .t.


//------------------------------------------------------------
//------------------------------------------------------------
METHOD FaktDokumenti:za_partnera(idfirma, idtipdok, idpartner)
local _qry_str
local _cnt
local _brdok

::p_idfirma := idfirma
::p_idtipdok := idtipdok
::p_idpartner := idpartner

_qry_str := "SELECT fakt_doks.idfirma, fakt_doks.idtipdok, fakt_doks.brdok FROM fmk.fakt_doks " 
//_qry_str += "LEFT JOIN fmk.fakt_fakt "
//_qry_str += "ON fakt_fakt.idfirma=fakt_doks.idfirma AND fakt_fakt.idtipdok=fakt_doks.idtipdok AND fakt_fakt.brdok=fakt_doks.brdok "
_qry_str += "WHERE "

::_sql_where := "fakt_doks.idfirma=" + _sql_quote(::p_idfirma) +  " AND fakt_doks.idtipdok=" + _sql_quote(::p_idtipdok) + " AND fakt_doks.idpartner=" + _sql_quote(::p_idpartner)

_qry_str += ::_sql_where
_qry := run_sql_query(_qry_str)

_cnt := 0
do while !_qry:eof()
   _brdok := _qry:FieldGet(3)
   // napunicemo items matricom FaktDokument objekata
   _item := FaktDokument():New(::p_idfirma, ::p_idtipdok, _brdok)
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
         VALID {|| P_Firma( @_idpartner ),  ispisi_partn( _idpartner, m_x + MAXROWS()-12, m_y + 18 ) }
        
    read

    @ m_x + MAXROWS()-12, m_y + 2 SAY "Partner:" 
    @ m_x + MAXROWS()-10, m_y + 2 SAY "Komande: <SPACE> markiraj otpremnicu"


    ::za_partnera(_idfirma, _idtipdok, _idpartner)

    _fakt_browse := BrowseFaktDokumenti():New(m_x + 5, m_y +1, m_x + MAXROWS() - 13, MAXCOLS()-11, self) 
    _fakt_browse:set_kolone_markiraj_otpremnice()
    _fakt_browse:browse()


BoxC()

if ::count_markirani > 0
  if ::change_idtipdok_markirani("22")
     ::generisi_fakt_pripr()
  endif
else
  MsgBeep("Nije odabrana nijedna odtpremnica ! caos ...")
endif

return .t.


METHOD FaktDokumenti:generisi_fakt_pripr_vars(params)
local _ok := .t.
local _sumiraj := "N"
local _tip_rn := 1
local _valuta := PADR( ValDomaca(), 3 )

params := hb_hash()

Box(, 6, 65 )

    @ m_x + 1, m_y + 2 SAY "Sumirati stavke otpremnica (D/N) ?" GET _sumiraj ;
                    VALID _sumiraj $ "DN" ;
                    PICT "@!"

    @ m_x + 3, m_y + 2 SAY "Formirati tip racuna: 1 (veleprodaja)" 
    @ m_x + 4, m_y + 2 SAY "                      2 (maloprodaja)" GET _tip_rn ;
                    VALID ( _tip_rn > 0 .and. _tip_rn < 3 ) ;
                    PICT "9"

    @ m_x + 6, m_y + 2 SAY "Valuta (KM/EUR):" GET _valuta VALID !EMPTY( _valuta ) PICT "@!"
    
    read

BoxC()

if LastKey() == K_ESC
    _ok := .f.
    return _ok
endif

// snimi mi u matricu parametre
params["tip_racuna"] := _tip_rn
params["sumiraj"] := _sumiraj
params["valuta"] := UPPER( _valuta )

return _ok

METHOD FaktDokumenti:count_markirani()
local _item, _cnt
_cnt := 0
FOR EACH _item IN ::items
    if _item:mark
       _cnt ++
    endif
NEXT
return _cnt


METHOD FaktDokumenti:change_idtipdok_markirani(new_idtipdok)
local _srv := my_server(), _err, _item, _broj, _ok := .t.

if !::lock
    MsgBeep("Zakljucavanje neuspjesno operacija " + ::p_idtipdok + "=>" + new_idtipdok + " otkazana !")
    return .f.
endif

begin sequence with { |err| err:cargo := { ProcName(1), ProcName(2), ProcLine(1), ProcLine(2) }, Break(err) }
	_sql_query(_srv, "BEGIN; SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")
	FOR EACH _item IN ::items
	    if _item:mark
               _broj := _item:broj
	       if !_item:change_idtipdok(new_idtipdok)
		     _sql_query(_srv, "ROLLBACK")
                     ::unlock()
		     _ok := .f.
                     BREAK
	       endif
	    endif
	NEXT
	_sql_query(_srv, "COMMIT")
        ::unlock()
        _ok := .t.
recover
    MsgBeep("neuspjesna konverzija " + _broj + " idtpdok => " + new_idtipdok + " !")
    _ok := .f.
end sequence

// forsiraj refresh dbf-ova
my_close_all_dbf()
o_fakt_edit()

::p_idtipdok := new_idtipdok

return _ok


METHOD FaktDokumenti:generisi_fakt_pripr()
local _sumirati := .f.
local _vp_mp := 1
local _n_tip_dok, _dat_max, _t_rec, _t_fakt_rec
local _veza_otpremnice, _broj_dokumenta
local _id_partner, _rec
local _ok := .t.
local _item, _msg
local _gen_params, _valuta
local _first
local _qry
local _datum_max

// parametri generisanja...
if !::generisi_fakt_pripr_vars( @_gen_params )
    return .f.
endif
         
// uzmi parametre matrice...
_sumirati := _gen_params["sumiraj"] == "D"
_vp_mp := _gen_params["tip_racuna"]
_valuta := _gen_params["valuta"]

if _vp_mp == 1
    _n_tip_dok := "10"
else
    _n_tip_dok := "11"
endif

_sql := "SELECT idroba, cijena, COALESCE(substring(txt from '\x10(.*?)\x11\x10.*?\x11' ), '') AS opis_usluga, "
if _sumirati
  _sql += "sum(kolicina), max(datdok), max(txt)"
else
   _sql += "kolicina, datdok, txt"
endif
_sql += " FROM fmk.fakt_fakt " 
_sql += " LEFT JOIN fmk.roba "
_sql += " ON fakt_fakt.idroba=roba.id "
_sql += " WHERE "
_sql += "idfirma=" + _sql_quote(::p_idfirma) + " AND  idtipdok="+ _sql_quote(::p_idtipdok)
_sql += " AND brdok IN (" 

_veza_otpremnice := ""
_first := .t.
FOR EACH _item IN ::items
    if _item:mark
       if _first
           _first := .f.
       else
           _sql += ","
           _veza_otpremnice += ","
       endif
       _sql += _sql_quote(_item:brdok)
       _veza_otpremnice += TRIM(_item:brdok)
    endif
NEXT

_sql += ")"

if _sumirati
  _sql += " group by idroba,cijena,opis_usluga order by idroba,cijena,opis_usluga"
else
  _sql += " order by idroba,cijena,opis_usluga"
endif

_qry := run_sql_query(_sql)

SELECT fakt_pripr
_fakt_rec := dbf_get_rec()

_fakt_rec["idfirma"]   := ::p_idfirma
_fakt_rec["idpartner"] := ::p_idpartner
_fakt_rec["brdok"]     := fakt_prazan_broj_dokumenta()
_fakt_rec["datdok"]    := DATE()
_fakt_rec["idtipdok"]  := _n_tip_dok
_fakt_rec["dindem"]    := LEFT( _valuta, 3)
_datum_max := DATE()

do while !_qry:eof()

    _fakt_rec["idroba"]   :=  _to_str(_qry:FieldGet(1))
    _fakt_rec["cijena"]   := _qry:FieldGet(2)
    // ovo polje ipak ne trebamo 
    // _opis_usluga := _qry:FieldGet(3)
    _fakt_rec["kolicina"] := _qry:FieldGet(4)
    _fakt_rec["datdok"]   := _qry:FieldGet(5)
    _fakt_rec["txt"]      := _to_str(_qry:FieldGet(6))
    
    if _fakt_rec["datdok"] > _datum_max
        _datum_max := _fakt_rec["datdok"]
    endif

    if _vp_mp == 2
         // radi se o mp racunu, izracunaj cijenu sa pdv
        _fakt_rec["cijena"] := ROUND( _uk_sa_pdv( ::p_idtipdok, ::p_idpartner, _fakt_rec["cijena"]), 2 )
    endif

    APPEND BLANK
    dbf_update_rec(_fakt_rec)

    _qry:skip()

enddo
 
_veza_otpremnice := "Racun formiran na osnovu otpremnica: " + _veza_otpremnice
  
renumeracija_fakt_pripr( _veza_otpremnice, _datum_max )

return _ok


