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
#include "f18_separator.ch"



// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
function fakt_lista_dokumenata_tabelarni_pregled(lVrsteP, lOpcine, cFilter)
local i
local _w1 := 30
local _x, _y
local _params := fakt_params()

ImeKol:={}

AADD(ImeKol,{ " ", {|| g_fiscal_info( fisc_rn, fisc_st )} })
AADD(ImeKol,{ "RJ",          {|| idfirma}  })
AADD(ImeKol,{ "VD",          {|| idtipdok} })
AADD(ImeKol,{ "Brdok",       {|| brdok+rezerv} })
AADD(ImeKol,{ "VP",          {|| idvrstep } })
AADD(ImeKol,{ "Datum",       {|| Datdok } })
AADD(ImeKol,{ "Partner",     {|| PADR(partner, 45) } })
AADD(ImeKol,{ "Ukupno-Rab ", {|| iznos} })
AADD(ImeKol,{ "Rabat",       {|| rabat} })
AADD(ImeKol,{ "Ukupno",      {|| iznos+rabat} })

if lVrsteP
    AADD(ImeKol,{ "Nacin placanja", {|| idvrstep} })
endif

// datum otpremnice datum valute
AADD(ImeKol,{ "Datum placanja", {|| datpl} })
AADD(ImeKol,{ "Dat.otpr", {|| dat_otpr} })
AADD(ImeKol,{ "Dat.val.", {|| dat_val} })

AADD(ImeKol,{ "Fisk.rn", {|| PADR( sh_fiscal_rn( fisc_rn, fisc_st ), 20 ) } })

// prikaz operatera
AADD(ImeKol,{ "Operater", {|| GetUserName( oper_id ) } })

// veza sa dokumentima
if _params["fakt_dok_veze"]
    AADD(ImeKol,{ "Vezni dokumenti", {|| PADR( get_fakt_vezni_dokumenti( idfirma, idtipdok, brdok ), 50 ) } })
endif

Kol:={}
for i:=1 to len(ImeKol)
    AADD( Kol, i )
next

_x := MAXROWS() - 4
_y := MAXCOLS() - 3

Box( , _x, _y)

@ m_x + _x - 4, m_y + 2 SAY PADR(" <ENTER> Stampa TXT", _w1 ) + ;
                            BROWSE_COL_SEP + PADR( " < P > Povrat dokumenta", _w1 ) + ;
                            BROWSE_COL_SEP + PADR( " < I > Informacije", _w1 )
@ m_x + _x - 3, m_y + 2 SAY PADR(" < a+P > Stampa ODT", _w1 ) + ;
                            BROWSE_COL_SEP + PADR( " < S > Storno dokument", _w1) + ;
                            BROWSE_COL_SEP + PADR( " < c+V > Setuj vezu fisk.", _w1 )
@ m_x + _x - 2, m_y + 2 SAY PADR(" < R > Stampa fisk.racuna", _w1) + ;
                            BROWSE_COL_SEP + PADR( " < F > otpr.->racun",_w1 ) + ;
                            BROWSE_COL_SEP + PADR( " < F5 > Refresh ", _w1 )
@ m_x + _x - 1, m_y + 2 SAY PADR(" < W > Dupliciraj", _w1) + ;
                            BROWSE_COL_SEP + PADR( " < K > Ispravka podataka", _w1 ) + ;
                            BROWSE_COL_SEP + PADR( " -", _w1 )

fUPripremu:=.f.

adImeKol:={}

private  bGoreRed:=NIL
private  bDoleRed:=NIL
private  bDodajRed:=NIL
private  fTBNoviRed:=.f. // trenutno smo u novom redu ?
private  TBCanClose:=.t. // da li se moze zavrsiti unos podataka ?
private  TBAppend:="N"  // mogu dodavati slogove
private  bZaglavlje:=NIL
        // zaglavlje se edituje kada je kursor u prvoj koloni
        // prvog reda
private  TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                        // ovo se mo§e setovati u when/valid fjama

private  TBScatter:="N"  // uzmi samo tekuce polje

for i:=1 TO LEN(ImeKol)
        AADD( adImeKol, ImeKol[i] )
next

ASIZE( adImeKol, LEN( adImeKol ) + 1 )
AINS( adImeKol, 6 )
adImeKol[6] := { "ID PARTNER" , {|| idpartner}, "idpartner", {|| .t.}, {|| P_Firma(@widpartner)}, "V" }

adKol:={}
for i := 1 to len(adImeKol)
    AADD(adKol,i)
next

ObjDbedit("", _x-3, _y, {|| fakt_tabela_komande (lOpcine, cFilter) }, "", "", , , , , 2 )
BoxC()

if fUpripremu
    close all
    fakt_unos_dokumenta()
endif

close all
return


// ------------------------------------------
// vraca info o fiskalnom racunu
// ------------------------------------------
static function g_fiscal_info( _f_rn, _s_rn )
local cInfo := " "

if _f_rn == 0 .and. _s_rn == 0
	cInfo := " "
else
    cInfo := "F"
endif

return cInfo



// prikaz fiskalnog racuna i reklamnog racuna
static function sh_fiscal_rn( _f_rn, _s_rn )
local _txt := ""

_txt += ALLTRIM( STR( _f_rn ) ) 

if _s_rn > 0
    _txt += " / "
    _txt += ALLTRIM( STR( _s_rn ) )
endif

return _txt

