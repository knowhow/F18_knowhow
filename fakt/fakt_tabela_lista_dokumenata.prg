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

function fakt_lista_dokumenata_tabelarni_pregled(lVrsteP, lOpcine)
local i

ImeKol:={}

if FIELDPOS("FISC_RN")>0
    AADD(ImeKol,{ " ", {|| g_fiscal_info(fisc_rn)} })
endif

AADD(ImeKol,{ "RJ",          {|| idfirma}  })
AADD(ImeKol,{ "VD",          {|| idtipdok} })
AADD(ImeKol,{ "Brdok",       {|| brdok+rezerv} })
AADD(ImeKol,{ "VP",          {|| idvrstep } })
AADD(ImeKol,{ "Datum",       {|| Datdok } })
AADD(ImeKol,{ "Partner",     {|| PADR( iif( m1 = "Z", "<<dok u pripremi>>", partner ), 45) } })
AADD(ImeKol,{ "Ukupno-Rab ", {|| iznos} })
AADD(ImeKol,{ "Rabat",       {|| rabat} })
AADD(ImeKol,{ "Ukupno",      {|| iznos+rabat} })

IF lVrsteP
    AADD(ImeKol,{ "Nacin placanja", {|| idvrstep} })
ENDIF

IF FIELDPOS("DATPL")>0
    AADD(ImeKol,{ "Datum placanja", {|| datpl} })
ENDIF


if FIELDPOS("DOK_VEZA") <> 0
    AADD(ImeKol,{ "Vezni dokumenti", ;
    {|| PADR( ALLTRIM( g_d_veza(idfirma,idtipdok,brdok,dok_veza)) , 60) + "..." }})
endif

// datum otpremnice, datum isporuke
if FIELDPOS("DAT_OTPR") <> 0
    AADD(ImeKol,{ "Dat.otpr", {|| dat_otpr} })
    AADD(ImeKol,{ "Dat.val.", {|| dat_val} })
endif

// prikaz operatera
IF FIELDPOS("oper_id")>0
    AADD(ImeKol,{ "Operater", {|| oper_id} })
ENDIF

Kol:={}
for i:=1 to len(ImeKol)
    AADD( Kol, i )
next

Box(, MAXROW() - 4, MAXCOL() - 3 )

@ m_x + MAXROW() - 4 - 3, m_y + 2 SAY " <ENTER> Stampa dokumenta        " + BROWSE_COL_SEP + " <P> Povrat dokumenta u pripremu    ³"
@ m_x + MAXROW() - 4 - 2, m_y + 2 SAY " <N>     Stampa narudzbenice     " + BROWSE_COL_SEP + " <B> Stampa radnog naloga           ³ "
@ m_x + MAXROW() - 4 - 1, m_y + 2 SAY " <S>     Storno dokument         " + BROWSE_COL_SEP + " <R> Rezervacija/Realizacija        ³"
@ m_x + MAXROW() - 4,     m_y + 2 SAY " <R>  Stampa fiskalnog racuna    " + BROWSE_COL_SEP + " <F> otpremnica -> faktura          ³"

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

ObjDbedit("", MAXROW() - 4, MAXCOL() - 3, {|| EdDatn (lOpcine) }, "", "", , , , , 2 )
BoxC()

if fupripremu
    close all
    fakt_unos_dokumenta()
endif

close all
return


// ------------------------------------------
// vraca info o fiskalnom racunu
// ------------------------------------------
static function g_fiscal_info( _f_rn )
local cInfo := " "
if _f_rn > 0
    cInfo := "F"
endif
return cInfo

