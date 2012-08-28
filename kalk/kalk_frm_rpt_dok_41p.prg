/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "kalk.ch"



// ---------------------------------------------------------
// stampa kalkulacije tip-a 41, 42, PDV varijanta
// ---------------------------------------------------------
function StKalk41PDV()
local nCol0 := nCol1 := nCol2 := 0
local nPom := 0
local _line

private nMarza, nMarza2, nPRUC, aPorezi
nMarza := nMarza2 := nPRUC := 0
aPorezi := {}

nStr := 0
cIdPartner := IdPartner
cBrFaktP := BrFaktP
dDatFaktP := DatFaktP

cIdKonto := IdKonto
cIdKonto2 := IdKonto2

P_10CPI

Naslov4x()

select kalk_pripr

// daj mi liniju za izvjestaj
_line := _get_line( cIdVd )

? _line

// ispisi header izvjestaja
_print_report_header( cIdvd )

? _line

nTot1 := nTot1b := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := 0
nTot4a := 0
nTotMPP := 0

private cIdd := idpartner + brfaktp + idkonto + idkonto2

do while !eof() .and. cIdFirma == field->idfirma .and. cBrDok == field->brdok .and. cIdVD == field->idvd

    if field->idpartner + field->brfaktp + field->idkonto + field->idkonto2 <> cIdd
        set device to screen
        Beep(2)
        Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
        set device to printer
    endif

    // formiraj varijable _....
    Scatter() 

    RptSeekRT()

    // izracunaj nMarza2
    MarzaMPR()
    KTroskovi()
  
    Tarifa( pkonto, idRoba, @aPorezi, _idtarifa )
    
    // uracunaj i popust
    // racporezemp( matrica, mp_bez_pdv, mp_sa_pdv, nc )
    aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )

    nPor1 := aIPor[1]
    
    VTPorezi()

    DokNovaStrana( 125, @nStr, 2 )

    // nabavna vrijednost
    nTot3 += ( nU3 := IF( roba->tip = "U", 0, nc ) * field->kolicina )
    // marza
    nTot4 += ( nU4 := nMarza2 * field->kolicina )
    // maloprodajna vrijednost bez popusta
    nTot5 += ( nU5 := ( field->mpc + field->rabatv ) * field->kolicina )
    // porez
    nTot6 += ( nU6 := (nPor1) * field->kolicina )
    // maloprodajna vrijednost sa porezom
    nTot7 += ( nU7 := field->mpcsapp * field->kolicina )
    // maloprodajna vrijednost sa popustom bez poreza
    nTot8 += ( nU8 := ( field->mpc * field->kolicina ) )
    // popust
    nTot9 += ( nU9 := field->rabatv * field->kolicina )
    // mpv sa pdv - popust
    nTotMPP += ( nUMPP := ( field->mpc + nPor1 ) * field->kolicina )
    
    // ispis kalkulacije
    // ===========================================================

    // 1. red

    @ prow() + 1, 0 SAY field->rbr PICT "999"
    @ prow(), 4 SAY  ""

    ?? TRIM(LEFT(roba->naz, 40)), "(", roba->jmj, ")"

	if lKoristitiBK .and. !EMPTY( roba->barkod )
		?? ", BK: " + roba->barkod
	endif

    if lPoNarudzbi
        IspisPoNar( if(cIdVd == "41", .f., ))
    endif

    // 2. red

    @ prow() + 1, 4 SAY field->idroba
    @ prow(), pcol() + 1 SAY field->kolicina PICT pickol

    nCol0 := pcol()

    @ prow(), nCol0 SAY ""

    if field->idvd <> "47"

        // nabavna cijena
        if roba->tip = "U"
            @ prow(), pcol() + 1 SAY 0 PICT piccdem
        else
            @ prow(), pcol() + 1 SAY field->nc PICT piccdem
        endif

        // marza
        @ prow(), nMPos := pcol() + 1 SAY nMarza2 PICT piccdem

    endif

    // mpc ili prodajna cijena uvecana za rabat
    @ prow(), pcol() + 1 SAY ( field->mpc + field->rabatv ) PICT PicCDEM

    nCol1 := pcol() + 1

    // popusti...
    if field->idvd <> "47"
        
        // popust
        @ prow(), pcol() + 1 SAY field->rabatv PICT PicCDEM

        // mpc sa pdv umanjen za popust
        @ prow(), pcol() + 1 SAY field->mpc PICT PicCDEM
 
    endif

    // pdv
    @ prow(), pcol() + 1 SAY aPorezi[POR_PPP] PICT PicProc

    // mpc sa porezom
    @ prow(), pcol() + 1 SAY ( field->mpc + nPor1 ) PICT PicCDEM

    // mpc sa porezom
    @ prow(), pcol() + 1 SAY field->mpcsapp PICT PicCDEM


    // 3. red : totali stavke

    // tarifa
    @ prow() + 1, 4 SAY field->idtarifa
    @ prow(), nCol0 SAY ""
    
    if cIdVd <> "47"

        // ukupna nabavna vrijednost stavke
        if roba->tip = "U"
            @ prow(), pcol() + 1 SAY 0 PICT picdem
        else
            @ prow(), pcol() + 1 SAY ( field->nc * field->kolicina ) PICT picdem
        endif

        // ukupna marza stavke
        @ prow(), pcol() + 1 SAY ( nMarza2 * field->kolicina ) PICT picdem

    endif

    // ukupna mpv bez poreza ili ukupna prodajna vrijednost
    @ prow(), pcol() + 1 SAY ( ( field->mpc + field->rabatv) * field->kolicina ) PICT picdem

    // ukupne vrijednosti mpc sa porezom sa rabatom i sam rabat
    if cIdVd <> "47"
        @ prow(), pcol() + 1 SAY ( field->rabatv * field->kolicina ) PICT picdem
        @ prow(), pcol() + 1 SAY ( field->mpc * field->kolicina ) PICT picdem
    endif

    // ukupni PDV stavke
    @ prow(), pcol() + 1 SAY ( nPor1 * field->kolicina ) PICT piccdem
    
    // ukupni PDV stavke
    @ prow(), pcol() + 1 SAY ( ( nPor1 + field->mpc ) * field->kolicina ) PICT piccdem
        
    // ukupna maloprodajna vrijednost (sa PDV-om)
    @ prow(), pcol() + 1 SAY ( field->mpcsapp * field->kolicina ) PICT picdem

    // 4. red

    // marza iskazana u procentu
    if cIdVd <> "47"
        @ prow() + 1, nMPos SAY ( nMarza2 / field->nc ) * 100 PICT picproc
    endif
    
    skip 1

enddo

DokNovaStrana( 125, @nStr, 3 )

? _line

@ prow() + 1, 0 SAY "Ukupno:"
@ prow(), nCol0 SAY ""

if cIDVD <> "47"

    // nabavna vrijednost
    @ prow(), pcol() + 1 SAY nTot3 PICT PicDEM
    // marza
    @ prow(), pcol() + 1 SAY nTot4 PICT PicDEM

endif

// prodajna vrijednost
@ prow(), pcol() + 1 SAY nTot5 PICT PicDEM

if !IsPDV()
    @ prow(), pcol() + 1 SAY SPACE(LEN(picproc))
    @ prow(), pcol() + 1 SAY SPACE(LEN(picproc))
endif
    
// popust
@ prow(), pcol() + 1 SAY nTot9 PICT PicDEM

if cIdVd <> "47"
    
    // prodajna vrijednost - popust
    @ prow(), pcol() + 1 SAY nTot8 PICT PicDEM
    // porez
    @ prow(), pcol() + 1 SAY nTot6 PICT PicDEM

endif

// maloprodajna vrijednost sa porezom - popust
@ prow(), pcol() + 1 SAY nTotMPP PICT PicDEM

// maloprodajna vrijednost sa porezom
@ prow(), pcol() + 1 SAY nTot7 PICT PicDEM

? _line

DokNovaStrana( 125, @nStr, 10 )

nRec := RECNO()

// rekapitulacija tarifa PDV
PDVRekTar41( cIdFirma, cIdVd, cBrDok, @nStr )

set order to tag "1"
go nRec

return



// ------------------------------------------
// vraca liniju 
// ------------------------------------------
static function _get_line( id_vd )
local _line
_line := "--- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
if id_vd <> "47"
    _line += " ---------- ---------- ----------"
endif
return _line


// --------------------------------------------------
// stampa header-a izvjestaja
// --------------------------------------------------
static function _print_report_header( id_vd )

if id_vd = "47"
    ? "*R * ROBA     * Kolicina *    MPC   *   PDV %  *   MPC     *"
    ? "*BR*          *          *          *   PDV    *  SA PDV   *"
    ? "*  *          *          *     ä    *     ä    *     ä     *"
else
    ? "*R * ROBA     * Kolicina *  NAB.CJ  *  MARZA  *  Prod.C  *  Popust  * PC-pop.  *   PDV %  *   MPC    * MPC     *"
    ? "*BR*          *          *   U MP   *         *  Prod.V  *          * PV-pop.  *   PDV    *  SA PDV  * SA PDV  *"
    ? "*  *          *          *    ä     *         *     ä    *          *          *     ä    * - popust *   ä     *"
endif

return



// -----------------------------------------------------
// vraca liniju za rekapitulaciju po tarifama
// -----------------------------------------------------
static function _get_rekap_line()
local _line
local _i

_line := "------ " 
for _i := 1 to 7
    _line += REPLICATE( "-", 10 ) + " "
next

if glUgost
  _line += " ---------- ----------"
endif

return _line


// ---------------------------------------------------
// stampa header rekapitulacije po tarifama
// ---------------------------------------------------
static function _print_rekap_header()
if glUgost
    ?  "* Tar *  PDV%    *  P.P %   *   MPV    *    PDV   *   P.Potr *  Popust  * MPVSAPDV*"
else
    ?  "* Tar *  PDV%    *  Prod.   *  Popust  * Prod.vr. *   PDV   * MPV-Pop. *  MPV    *"
    ?  "*     *          *   vr.    *          * - popust *   PDV   *  sa PDV  * sa PDV  *"
endif
return


// --------------------------------------------------
// rekapitulacija tarifa na dokumentu
// --------------------------------------------------
function PDVRekTar41( cIdFirma, cIdVd, cBrDok, nStr )
local nTot1
local nTot2
local nTot3
local nTot4
local nTot5
local nTotP
local aPorezi
local _line

select kalk_pripr
set order to tag "2"
seek cIdfirma + cIdvd + cBrdok

// daj mi liniju za izvjestaj
_line := _get_rekap_line()

? _line

// stampaj header
_print_rekap_header()

? _line

nTot1:=0
nTot2:=0
nTot2b:=0
nTot3:=0
nTot4:=0
nTot5:=0
nTot6:=0
nTot7:=0
nTot8:=0
// popust
nTotP:=0 

aPorezi:={}

do while !EOF() .and. cIdfirma + cIdvd + cBrDok == field->idfirma + field->idvd + field->brdok
    
    cIdTarifa := field->idtarifa
    nU1 := 0
    nU2 := 0
    nU2b := 0
    nU5 := 0
    nUp := 0

    select tarifa
    hseek cIdtarifa
    
    Tarifa( kalk_pripr->pkonto, kalk_pripr->idroba, @aPorezi, kalk_pripr->idtarifa )

    select kalk_pripr

    fVTV := .f.

    do while !EOF() .and. cIdfirma + cIdVd + cBrDok == field->idFirma + field->idVd + field->brDok .and. field->idTarifa == cIdTarifa
    
        select roba
        hseek kalk_pripr->idroba

        select kalk_pripr

        SetStPor_()
    
        Tarifa( kalk_pripr->pkonto, kalk_pripr->idRoba, @aPorezi, kalk_pripr->idtarifa )
    
        // mpc bez poreza sa uracunatim popustom
        nU1 += field->mpc * field->kolicina

        aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )

        // PDV

        nU2 += aIPor[1] * field->kolicina
        
        // ugostiteljstvo porez na potr
        if glUgost
            nU2b += aIPor[3] * field->kolicina
        endif

        nU5 += field->mpcsapp * field->kolicina

        nUP += field->rabatv * field->kolicina
    
        nTot6 += ( field->mpc - field->nc ) * field->kolicina
    
        skip
    enddo
  
    nTot1 += nU1
    nTot2 += nU2

    if glUgost
        nTot2b += nU2b
    endif

    nTot5 += nU5
    nTotP += nUP
  
    // ispisi rekapitulaciju
    // =========================================

    ? cIdtarifa

    @ prow(), pcol() + 1 SAY aPorezi[POR_PPP] pict picproc

    if glUgost
        @ prow(), pcol() + 1 SAY aPorezi[POR_PP] pict picproc
    endif
  
    nCol1 := pcol()

    // mpv bez pdv 
    @ prow(), nCol1 + 1 SAY nU1+nUP pict picdem

    // popust
    @ prow(), pcol() + 1 SAY nUp pict picdem

    // mpv - popust
    @ prow(), pcol() + 1 SAY nU1 pict picdem

    // PDV
    @ prow(), pcol() + 1 SAY nU2 pict picdem

    if glUgost
        @ prow(), pcol() + 1 SAY nU2b pict picdem
    endif

    // mpv
    @ prow(), pcol() + 1 SAY (nU1 + nU2) pict picdem

    // mpv sa originalnom cijemo
    @ prow(), pcol() + 1 SAY nU5 pict picdem


enddo

DokNovaStrana(125, @nStr, 4)

? _line

? "UKUPNO"

// prodajna vrijednost bez popusta
@ prow(), nCol1 + 1 SAY ( nTot1 + nTotP ) pict picdem

// popust
@ prow(), pcol() + 1 SAY nTotP pict picdem

if glUgost
    @ prow(), pcol() + 1 SAY nTot2b pict picdem
endif

// prodajna vrijednost - popust
@ prow(), pcol() + 1 SAY nTot1 pict picdem  

// pdv
@ prow(), pcol() + 1 SAY nTot2 pict picdem  

// mpv sa uracunatim popustom
@ prow(), pcol() + 1 SAY ( nTot1 + nTot2 ) pict picdem

// mpv 
@ prow(), pcol() + 1 SAY nTot5 pict picdem


? _line

if cIdVd <> "47" .and. !IsJerry()
    ? "        UKUPNA RUC:"
    @ prow(), pcol() + 1 SAY nTot6 pict picdem
    ? "UKUPNO POPUST U MP:"
    @ prow(), pcol() + 1 SAY nTot5 - ( nTot1 + nTot2 ) pict picdem
    ? _line
endif

return


