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

#include "fakt.ch"
#include "hbclass.ch"
#include "common.ch"

CLASS KalkCounter  INHERIT  DocCounter
     METHOD New
     METHOD set_sql_get 
     METHOD set_konto(konto)
     DATA   brojac_po_kontima  INIT .f.

  protected:
     DATA   p_konto
ENDCLASS

METHOD KalkCounter:New(idfirma, idvd, datdok, new_number, konto)	
local _param := fakt_params()

::super:New(0, 12,  gLenBrKalk, "", "<G2>", "0", {"kalk", idfirma, idvd},  datdok)


if new_number == NIL
     new_number := .f.
endif

if new_number
   ::new_document_number()
endif

if glBrojacPoKontima
     ::brojac_po_kontima := .t.
else
     ::brojac_po_kontima := .f.
endif


if konto <> NIL
    ::set_konto(konto)
endif

return SELF

//-----------------------------------------
//-----------------------------------------
METHOD KalkCounter:set_konto(konto)

// ::a_s_param := { "kalk", "10", "14" }
::p_konto := konto

if ::brojac_po_kontima
   //  000100/15/13 - suffix0 ='/15', suffix='/13'
  ::suffix0 := SufBrKalk(konto)

	if EMPTY(::suffix0)
	   _msg := "ERR:  Kalk brojac po kontima podesen ali za konto " + konto + " suffix nije podesen"
	   log_write(_msg, 2)
	   MsgBeep(_msg)
	   QUIT_1
	endif
endif

IF LEN(::a_s_param) == 4
  // vec postoji konto parametar
  // a_s_param := { "kalk", "10", "14", "1321" }
  ::p_konto := konto
  ::a_s_param[4] := TRIM(konto)
else
  AADD(::a_s_param, TRIM(konto))
endif

::set_c_server_param()

return self

// ---------------------------------------------
// odredjuje sufiks broja dokumenta
// ---------------------------------------------
function SufBrKalk( cIdKonto )
local nArr := SELECT()
local cSufiks := SPACE(3)

select koncij
seek cIdKonto

if FOUND() 
    if FIELDPOS( "sufiks" ) <> 0
        cSufiks := field->sufiks
    endif
endif
select (nArr)

return cSufiks



// ------------------------------------------------
// ------------------------------------------------
METHOD KalkCounter:set_sql_get()

::c_sql_get := "select brdok from fmk.kalk_doks where idfirma=" + _sql_quote(::a_s_param[2]) + ;
   " AND idvd=" + _sql_quote(::a_s_param[3]) + ;
   " AND EXTRACT(YEAR FROM datdok)=" + ALLTRIM(STR(::year)) + ;
   " ORDER BY (datdok, brdok) DESC LIMIT 1"

return .t.


// --------------------------------------------------------
// brdok nula
// --------------------------------------------------------
function kalk_brdok_0(idfirma, idvd, datdok, konto)

local _counter := KalkCounter():New(idfirma, idvd, datdok, .f., konto)

return _counter:to_str()

// --------------------------------------------------------
// brdok nula hash params
// --------------------------------------------------------
function kalk_brdok_0h(dok, konto)

local _counter := KalkCounter():New(dok["idfirma"], dok["idvd"], dok["datdok"], .f., konto)

return _counter:to_str()


// --------------------------------------------------------
// generisi nov broj naloga uzevsi serverski brojac
// --------------------------------------------------------
function kalk_novi_broj_dokumenta(h_dok, konto)
local _counter := KalkCounter():New(h_dok["idfirma"], h_dok["idvd"], h_dok["datdok"], .t., konto)

return _counter:to_str()

// --------------------------------------------------------
// brdok nula
// --------------------------------------------------------
function kalk_rewind(idfirma, idvd, datdok, brdok, konto)
local _counter := KalkCounter():New(idfirma, idvd, datdok, .f., konto)

_counter:rewind(brdok)
return .t.


// ------------------------------------------------------------
// setuj broj dokumenta
// ------------------------------------------------------------
function kalk_set_broj_dokumenta(h_dokument, konto)
local _broj_dokumenta
local _t_rec
local _firma, _td, _datdok, _cnt, _null_brdok

PushWa()

if h_dokument == NIL
   select kalk_pripr
   go top
   h_dokument := hb_hash()
   h_dokument["idfirma"] := field->idfirma
   h_dokument["idvd"] := field->idvd
   h_dokument["datdok"] := field->datdok
   h_dokument["brdok"] := field->brdok
endif

_firma := h_dokument["idfirma"]
_td    := h_dokument["idvd"]
_brdok := h_dokument["brdok"]
_datdok := h_dokument["datdok"]

_cnt := KalkCounter():New(_firma, _td, _datdok, .f., konto)
_cnt:decode(_brdok)

if _cnt:counter > 0
    _cnt:update_server_counter_if_counter_greater()
    PopWa()
    return .f.
endif

_null_brdok := _cnt:to_str()

// daj mi novi broj dokumenta
_broj_dokumenta := kalk_novi_broj_dokumenta( h_dokument, konto)

select kalk_pripr
set order to tag "1"
go top

do while !EOF()
    skip 1
    _t_rec := RECNO()
    skip -1
    if (field->idfirma == _firma) .and. (field->idvd == _td) .and. (field->brdok == _null_brdok)
        replace field->brdok with _broj_dokumenta
    endif
    go (_t_rec)
enddo

PopWa()
 
return .t.

// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
function kalk_set_param_broj_dokumenta()
local _param
local _broj := 0
local _broj_old
local _firma := gFirma
local _tip_dok := "10"
local _god := year_2str(YEAR(DATE()))

Box(, 2, 60 )

    @ m_x + 1, m_y + 2 SAY "Firma:" GET _firma
    @ m_x + 1, col() + 1 SAY "Tip" GET _tip_dok
    @ m_x + 1, col() + 1 SAY "Godina" GET _godina
    read

    if LastKey() == K_ESC
        BoxC()
        return
    endif

    // param: fin/10/10
    _param := "kalk" + "/" + _firma + "/" + _tip_dok + "/" + _godina
    _broj := fetch_metric( _param, nil, _broj )
    _broj_old := _broj

    @ m_x + 2, m_y + 2 SAY "Zadnji broj dokumenta:" GET _broj PICT "99999999"

    read

BoxC()

if LastKey() != K_ESC
    // snimi broj u globalni brojac
    if _broj <> _broj_old
        set_metric( _param, nil, _broj )
    endif
endif

return

// ------------------------------------------------------------------
// kalk, uzimanje novog broja za kalk dokument
// ------------------------------------------------------------------
function kalk_novi_broj_dokumenta_old( firma, tip_dokumenta, konto )
local _broj := 0
local _broj_dok := 0
local _len_broj := 5
local _len_brdok, _len_sufix
local _param
local _tmp, _rest
local _ret := ""
local _t_area := SELECT()
local _sufix := ""

// ova funkcija se brine i za sufiks
if konto == NIL
	konto := ""
endif

// moramo pronaci sufiks
if glBrojacPoKontima
	_sufix := SufBrKalk( konto )
endif

// param: kalk/10/10
_param := "kalk" + "/" + firma + "/" + tip_dokumenta + IIF( !EMPTY( _sufix ), "_" + _sufix, "" )
_broj := fetch_metric( _param, nil, _broj )

// konsultuj i doks uporedo
O_KALK_DOKS

if glBrojacPoKontima
	set order to tag "1S"
else
	set order to tag "1"
endif

go top

seek firma + tip_dokumenta + _sufix + "X"
skip -1

if field->idfirma == firma .and. field->idvd == tip_dokumenta .and. ;
	IIF( glBrojacPoKontima, RIGHT( ALLTRIM( field->brdok ), LEN( _sufix ) ) == _sufix, .t. )

	if glBrojacPoKontima .and. ( _sufix $ field->brdok )
		_len_brdok := LEN( ALLTRIM( field->brdok ) )
		_len_sufix := LEN( _sufix )
		// odrezi mi sufiks ako postoji
		_broj_dok := VAL( LEFT( ALLTRIM( field->brdok ), _len_brdok - _len_sufix ) )
	else
   		_broj_dok := VAL( field->brdok )
	endif

else
    _broj_dok := 0
endif

// uzmi sta je vece, dokument broj ili globalni brojac
_broj := MAX( _broj, _broj_dok )

// uvecaj broj
++ _broj

// ovo ce napraviti string prave duzine...
// dodaj i sufiks na kraju ako treba
_ret := PADL( ALLTRIM( STR( _broj ) ), _len_broj, "0" ) + _sufix

// upisi ga u globalni parametar
set_metric( _param, nil, _broj )

select ( _t_area )
return _ret





// ------------------------------------------------------------
// setuj broj dokumenta u pripremi ako treba !
// ------------------------------------------------------------
function kalk_set_broj_dokumenta_old()
local _broj_dokumenta
local _t_rec, _rec
local _firma, _td, _null_brdok
local _konto := ""

PushWa()

select kalk_pripr
go top

//_null_brdok := kalk_prazan_broj_dokumenta()
        
if field->brdok <> _null_brdok 
    // nemam sta raditi, broj je vec setovan
    PopWa()
    return .f.
endif

_firma := field->idfirma
_td := field->idvd
_konto := field->idkonto

// daj mi novi broj dokumenta
_broj_dokumenta := kalk_novi_broj_dokumenta( _firma, _td, _konto )

select kalk_pripr
set order to tag "1"
go top

do while !EOF()

    skip 1
    _t_rec := RECNO()
    skip -1

    if field->idfirma == _firma .and. field->idvd == _td .and. field->brdok == _null_brdok
        _rec := dbf_get_rec()
        _rec["brdok"] := _broj_dokumenta
        dbf_update_rec( _rec )
    endif

    go (_t_rec)

enddo

PopWa()
 
return .t.



// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
function kalk_set_param_broj_dokumenta_old()
local _param
local _broj := 0
local _broj_old
local _firma := gFirma
local _tip_dok := "10"
local _sufix := ""
local _konto := PADR( "1330", 7 )

Box(, 2, 60 )

    @ m_x + 1, m_y + 2 SAY "Dokument:" GET _firma
    @ m_x + 1, col() + 1 SAY "-" GET _tip_dok

	if glBrojacPoKontima
    	@ m_x + 1, col() + 1 SAY " konto:" GET _konto
	endif

    read

    if LastKey() == K_ESC
        BoxC()
        return
    endif

	if glBrojacPoKontima
		_sufix := SufBrKalk( _konto )
	endif

    // param: kalk/10/10
	_param := "kalk" + "/" + firma + "/" + tip_dokumenta + IIF( !EMPTY( _sufix ), "_" + _sufix, "" )
    _broj := fetch_metric( _param, nil, _broj )
    _broj_old := _broj

    @ m_x + 2, m_y + 2 SAY "Zadnji broj dokumenta:" GET _broj PICT "99999999"

    read

BoxC()

if LastKey() != K_ESC
    // snimi broj u globalni brojac
    if _broj <> _broj_old
        set_metric( _param, nil, _broj )
    endif
endif

return


// ------------------------------------------------
// ------------------------------------------------
function SljBrKalk_old(cTipKalk, cIdFirma, cSufiks)

local cBrKalk:=space(8)
if cSufiks==nil
    cSufiks:=SPACE(3)
endif
if gBrojac=="D"
    if glBrojacPoKontima
        select kalk_doks
        set order to tag "1S"
        seek cIdFirma+cTipKalk+cSufiks+"X"
    else
        select kalk
        set order to tag "1"
        seek cIdFirma+cTipKalk+"X"
    endif
    skip -1
    
    if cTipKalk<>field->idVD .or. glBrojacPoKontima .and. right(field->brDok,3)<>cSufiks
        cBrKalk:=SPACE(gLenBrKalk)+cSufiks
    else
        cBrKalk:=field->brDok
    endif
    
    if cTipKalk=="16" .and. glEvidOtpis
        cBrKalk:=STRTRAN(cBrKalk,"-X","  ")
    endif
/*  
    if ALLTRIM( cBrKalk ) >= "99999"
        cBrKalk := PADR( novasifra( ALLTRIM(cBrKalk) ), 5 ) + ;
            right( cBrKalk, 3 )
    else
        cBrKalk:=UBrojDok(val(left(cBrKalk,5)) + 1, ;
            5, right(cBrKalk,3) )
    endif
*/
endif
return cBrKalk


// ---------------------------------------
// ---------------------------------------
function kalk_fix_brdok(brdok)
local _cnt
_cnt := KalkCounter():New("99", "99", DATE())
_cnt:fix(@brdok)

return .t.



/*! 
 * UBrojDok(nBroj,nNumDio,cOstatak)
 * Pretvara Broj podbroj u string format "Broj dokumenta"
 * 
 * UBrojDok ( 123,  5, "/99" )   =>   00123/99
 * \encode
 */
 
function UBrojDok_old(nBroj, nNumdio, cOstatak)
return padl( alltrim(str(nBroj)), nNumDio, "0")+cOstatak


/*! \fn SljBroj(cidfirma,cIdvD,nMjesta)
 *  \brief Sljedeci slobodan broj dokumenta za zadanu firmu i vrstu dokumenta
 */

function SljBroj_old(cidfirma,cIdvD,nMjesta)
private cReturn:="0"
select kalk
seek cidfirma+cidvd+"ä"
skip -1
if idvd<>cidvd
     cReturn:=space(8)
else
     cReturn:=brdok
endif

/*
if ALLTRIM(cReturn) >= "99999"
    cReturn := PADR( novasifra( ALLTRIM(cReturn) ), 5 )
else
    cReturn := UBrojDok( VAL( LEFT(cReturn, 5) ) + 1, ;
        5, RIGHT(cReturn) )
endif
*/
return cReturn


// --------------------------------------------------------
// uvecava broj kalkulacije sa stepenom uvecanja nUvecaj
// --------------------------------------------------------
function GetNextKalkDoc_old(cIdFirma, cIdTipDok, nUvecaj)
local xx
local i
local lIdiDalje

if nUvecaj == nil
    nUvecaj := 1
endif

lIdiDalje := .f.

O_KALK_DOKS
select kalk_doks
set order to tag "1"

seek cIdFirma + cIdTipDok + "XXX"
// vrati se na zadnji zapis
skip -1

do while .t.
    for i := 2 to LEN(ALLTRIM(field->brDok)) 
        if !IsNumeric(SubStr(ALLTRIM(field->brDok),i,1))
            lIdiDalje := .f.
            skip -1
            loop
        else
            lIdiDalje := .t.
        endif
    next

    if lIdiDalje := .t.
        cResult := field->brDok
        exit
    endif
    
enddo

xx := 1

for xx := 1 to nUvecaj
    cResult := PADR( novasifra( ALLTRIM(cResult) ), 5 ) + ;
        RIGHT( cResult, 3 )
next

return cResult



// ------------------------------------------------------------
// resetuje brojac dokumenta ako smo pobrisali dokument
// ------------------------------------------------------------
function kalk_reset_broj_dokumenta( firma, tip_dokumenta, broj_dokumenta, konto )
local _param
local _broj := 0
local _sufix := ""

if konto == NIL
	konto := ""
endif

if glBrojacPoKontima 
	_sufix := SufBrKalk( konto )
endif

// param: kalk/10/10
_param := "kalk" + "/" + firma + "/" + tip_dokumenta + IIF( !EMPTY( _sufix ), "_" + _sufix, "" )
_broj := fetch_metric( _param, nil, _broj )

if VAL( broj_dokumenta ) == _broj
    -- _broj
    // smanji globalni brojac za 1
    set_metric( _param, nil, _broj )
endif

return


/*! \fn MMarza2()
 *  \brief Daje iznos maloprodajne marze
 */

function MMarza2()
  if TMarza2=="%".or.EMPTY(tmarza2)
     nMarza2:=kolicina*Marza2/100*VPC
  elseif TMarza2=="A"
     nMarza2:=Marza2*kolicina
  elseif TMarza2=="U"
     nMarza2:=Marza2
  endif
return nMarza2


/*! \fn MarkBrDok(fNovi)
 *  \brief Odredjuje sljedeci broj dokumenta uzimajuci u obzir marker definisan u polju koncij->m1
 */

function MarkBrDok_old(fNovi)
 LOCAL nArr:=SELECT()
  _brdok:=cNBrDok
  IF fNovi .and. KONCIJ->(FIELDPOS("M1"))<>0
    SELECT KONCIJ; HSEEK _idkonto2
    IF !EMPTY(m1)
      select kalk; set order to tag "1"; seek _idfirma+_idvd+"X"
      skip -1
      _brdok:=space(8)
      do while !bof() .and. idvd==_idvd
        if UPPER(right(brdok,3))==UPPER(KONCIJ->m1)
          _brdok:=brdok
          exit
        endif
        skip -1
      enddo
     // _Brdok:=UBrojDok(val(left(_brdok,5))+1,5,KONCIJ->m1)
    ENDIF
    SELECT (nArr)
  ENDIF
  @  m_x+2,m_y+46  SAY _BrDok COLOR INVERT
return .t.

function kalk_sljedeci_old(cIdFirma,cVrsta)
local cBrKalk
if gBrojac=="D"
 select kalk
 set order to tag "1"
 seek cIdFirma+cVrsta+"X"
 skip -1
 if idvd<>cVrsta
   cBrKalk:=space(8)
 else
   cBrKalk:=brdok
 endif
 //cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
endif
return cBrKalk


