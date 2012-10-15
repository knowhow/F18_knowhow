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


#include "pos.ch"


function StampZaduz(cIdVd,cBrDok)

local nPrevRec
local cKoje
local nFinZad
local fPred:=.f.
local aTarife := {}
local nPPP
local nPPU
local nOsn
local nPP
nPPP:=0
nPPU:=0
nOsn:=0
nPP:=0

SELECT PRIPRZ   

IF RecCount2() > 0 

    nPrevRec := RECNO()

    GO TOP
   
    START PRINT CRET 
    ?

    cPom:=""

    NaslovDok(cIdVd)

    if cIdVD=="16"
        if !empty(IdDio)
            cPom+="PREDISPOZICIJA "
            fPred:=.t.
        else
            cPom+="ZADUZENJE "
        endif
    endif

    if cIdvd=="PD"
        cPom+="PREDISPOZICIJA "
        fpred:=.t.
    endif

    if cIdVd=="98"
  	    cPom+="REKLAMACIJA "
    endif

    if gVrstaRS<>"S"
        cPom+= ALLTRIM(PRIPRZ->IdPos)+"-"+ALLTRIM (cBrDok)
    endif

    if fpred
        ? PADC("PRENOS IZ ODJ: "+idodj+"  U ODJ:"+idvrstep,38)
    endif

    ? PADC(cPom,40)
    ? PADL (FormDat1 (PRIPRZ->Datum), 39)
    ?

    if gZadCij=="D"
        ? " Sifra      Naziv            JMJ Kolicina"
        ? "---------- ----------------- --- --------"
        ? "           Nabav.vr.*   PPP   *    MPC   "
        ? "           --------- --------- ----------"
        ? "           MPV-porez*   PPU   *    MPV   "
        ? "-----------------------------------------"
    else
        ? " Sifra      Naziv            JMJ Kolicina"
        ? "---------- ----------------- --- --------"
    endif

    nFinZad := 0
    SELECT PRIPRZ
    GoTop2()
    DO WHILE ! EOF()

        nIzn:=cijena*kolicina
        if !IsPDV()
    	    if priprz->idtarifa = "PDV17"
		        WhilePTarife(IdRoba, IdTarifa, nIzn, @aTarife, @nPPP, @nPPU, @nOsn, @nPP)
	        else
		        WhileaTarife(IdRoba, nIzn, @aTarife, @nPPP, @nPPU, @nOsn, @nPP)
	        endif
        else
    	    WhileaTarife(IdRoba, nIzn, @aTarife, @nPPP, @nPPU, @nOsn, @nPP)
        endif
        if fpred .and. !empty(IdDio)
            // ne stampaj nista
        else
            ? idroba, PADR (RobaNaz, 17), JMJ, ;
                TRANSFORM (Kolicina, "99999.99")
            IF gZadCij=="D"
                ? SPACE(10), TRANSFORM(ncijena*kolicina,"999999.99"), TRANSFORM (nPPP,"999999.99"), TRANSFORM (cijena,"9999999.99")
                ? SPACE(10), TRANSFORM(nOsn,"999999.99"),             TRANSFORM (nPPU,"999999.99"), TRANSFORM (cijena*kolicina,"9999999.99")
                ? "-----------------------------------------"
            ENDIF
        endif
        nFinZad += PRIPRZ->(Kolicina * Cijena)

        SKIP 1

    ENDDO

    ? "-------- ----------------- --- --------"
    ? PADL ("UKUPNO ZADUZENJE (" + TRIM ( gDomValuta ) + ")", 29), ;
        TRANS (nFinZad, "999,999.99")
    ? "-------- ----------------- --- --------"

    if IsPDV()
  	    PDVpos_rekap_tarifa(aTarife)
    else
    	pos_rekap_tarifa(aTarife)
    endif

    ? " Primio " + PADL ("Predao", 31)
    ?
    ? PADL (ALLTRIM (gKorIme), 39)
  
    //PaperFeed()

    END PRINT

    O_PRIPRZ
    GO nPrevRec

ELSE
    MsgBeep ("Zaduzenje nema nijedne stavke!", 20)
ENDIF

return



// -------------------------------------------------------------
// stampa dokumenta zaduzenja
// -------------------------------------------------------------
function PrepisZad(cNazDok)
local fPred:=.f.
local nSir := 80
local nRobaSir := 40
local cLm := SPACE (5)
local cPicKol := "999999.999"
local aTarife:={}
local cRobaNaStanju := "N"
local cLine
local cLine2
local _t_area := SELECT()

START PRINT CRET

if gVrstaRS == "S"
	P_INI
  	P_10CPI
else
  	nSir := 40
  	nRobaSir := 18
  	cLM := ""
  	cPicKol := "9999.999"
endif

SELECT POS
HSEEK pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

if !empty(pos_doks->idvrstep)  
	// predispozicija
	fPred:=.t.
 	cNazDok := "PREDISPOZICIJA "
endif

cNazDok := cNazDok + " "

? PADC(cNazDok + IIF(Empty(pos_doks->IdPos), "", ALLTRIM(pos_doks->IdPos) + "-" ) + ;
        ALLTRIM(pos_doks->BrDok), nSir)

SELECT ODJ
HSEEK POS->IdOdj

IF !EMPTY(POS->IdDio)
	SELECT DIO
  	HSEEK POS->IdDio
EndIF

SELECT POS
if fpred
	? PADC("PRENOS IZ ODJ: "+pos->idodj+"  U ODJ:"+pos_doks->idvrstep,nSir)
else
 	? PADC (ALLTRIM (ODJ->Naz)+IIF (!Empty (POS->IdDio),"-"+AllTrim (DIO->Naz),"");
        , nSir)
endif

? PADC (FormDat1 (pos_doks->Datum), nSir)
?

// setuj linije...
// cLine = artikal, kolicina ....
// cLine2 = ------- --------- ...
_get_line(@cLine, @cLine2)

? cLM + cLine
? cLM + cLine2

nFinZad := 0
SELECT POS
DO While ! Eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
	IF gVrstaRS == "S" .and. Prow() > 63-gPstranica
    		FF
   	EndIF
   	if fPred  // predispozicija
     		if !empty(IdDio)
          		SKIP
	  		loop
      		endif
   	endif

   	? cLM
   	if len(trim(idroba)) > 8
     		?? IdRoba, ""
   	else
     		?? padr(IdRoba, 8), ""
   	endif
   
    SELECT ROBA
   	
	HSEEK POS->IdRoba
   	?? PADR (_field->Naz, nRobaSir), _field->Jmj, ""
   	SELECT POS
   	IF gVrstaRS == "S"
    		?? TRANS (POS->Cijena, "9999.99"), ""
   	EndIF
   	?? TRANS (POS->Kolicina, cPicKol)
   	nFinZad += POS->(Kolicina * Cijena)
   
  	if gModul="TOPS"
    		if !IsPDV() 
        		if pos->idtarifa = "PDV17"
    				WhilePTarife(pos->IdRoba,pos->idtarifa, POS->(Kolicina * Cijena) , @aTarife )
			else
    				WhileaTarife(pos->IdRoba, POS->(Kolicina * Cijena) , @aTarife )
			endif
    		else	
    			WhileaTarife(pos->IdRoba, POS->(Kolicina * Cijena) , @aTarife )
    		endif
   	endif
   	SKIP
ENDDO

IF gVrstaRS == "S" .and. Prow() > 63-gPstranica - 7
	FF
EndIF

? cLine2
? cLM


?? PADL("IZNOS DOKUMENTA ", ;
          IIF (gVrstaRS=="S", 13, 11) + nRobaSir), ;
          TRANS (nFinZad, IIF(gVrstaRS=="S", "999,999,999,999.99", ;
	  "9,999,999.99" ))
? cLine2
?

if gModul=="TOPS"
	if IsPDV()
   		PDVpos_rekap_tarifa(aTarife)
   	else
   		pos_rekap_tarifa(aTarife)
  	endif
endif


?? " Primio", PADL ("Predao", nSir-9)

SELECT OSOB
HSEEK pos_doks->IdRadnik

? PADL (ALLTRIM (OSOB->Naz), nSir-9)

IF gVrstaRS == "S"
	FF
Else
	PaperFeed()
EndIF

END PRINT

select ( _t_area )

return


// ----------------------------------------------
// setovanje linije za podvlacenje
// ----------------------------------------------
static function _get_line(cLine, cLine2)

cLine := PADR("Sifra", 10) + " "
cLine2 := REPLICATE("-", 10) + " "

if gVrstaRS == "S"
	cLine += PADR("Naziv", 40) + " "
	cLine2 += REPLICATE("-", 40) + " "
else
	cLine += PADR("Naziv", 18) + " "
	cLine2 += REPLICATE("-", 18) + " "
endif

cLine += PADR("JMJ", 3) + " "
cLine2 += REPLICATE("-", 3) + " "

if gVrstaRS == "S"
	cLine += PADR("Cijena", 7) + " "
	cLine2 += REPLICATE("-", 7) + " "
endif

cLine += PADR("Kolicina", 8) 
cLine2 += REPLICATE("-", 8)

return


