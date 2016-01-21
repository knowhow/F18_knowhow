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

#include "f18.ch"

/*! \fn OiNIsplate()
 *  \brief Odobrenje i nalog isplate
 */
function OiNIsplate()

LOCAL nRec:=0
 PRIVATE cBrojOiN:="T"     // T,S,O
  select fin_pripr
  nRec:=RECNO()

  IF !VarEdit({ {"Koliko obrazaca stampati? (T-samo tekuci, S-sve, O-od tekuceg do kraja)","cBrojOiN","cBrojOiN$'TSO'","@!",} }, 10,0,14,79,;
              'STAMPANJE OBRASCA "ODOBRENJE I NALOG ZA ISPLATU"',;
              "B1")
    RETURN (NIL)
  ENDIF
  IF cBrojOiN=="S"; GO TOP; ENDIF
  START PRINT CRET

  DO WHILE !EOF()
    ?
    gpCOND()
    ? SPACE(gnLMONI)
    gpB_ON(); gp12cpi()
    ?? "ORGAN UPRAVE-SLU"+IF(gKodnaS=="8","�","@")+"BA"
    gpB_OFF(); gpCOND()
    ?? SPACE(50)+"Ispla"+IF(gKodnaS=="8","�","}")+"eno putem"
    gpB_ON()
    ?? " ZPP-BLAGAJNE"
    gpB_OFF()

    ? SPACE(gnLMONI)+SPACE(77)+"sa "+IF(gKodnaS=="8","�","`")+"iro ra"+IF(gKodnaS=="8","�","~")+"una"
//    ? SPACE(gnLMONI); gPI_ON()
//    ?? Ocitaj(F_KONTO,idkonto,"naz")
//    gPI_OFF()
    ?
//    ? SPACE(gnLMONI)+REPL("-",60)
//    ? SPACE(gnLMONI)+SPACE(77); gpI_ON()
    ? SPACE(gnLMONI); gPI_ON()
    ?? PADC(ALLTRIM(Ocitaj(F_KONTO,idkonto,"naz")),60); gPI_OFF()
    ?? SPACE(17); gpI_ON()
    ?? PADC(ALLTRIM(idkonto),28); gPI_OFF()
    ? SPACE(gnLMONI)+REPL("-",60)+SPACE(17)+REPL("-",28)
    ?
    ? SPACE(gnLMONI)+"Broj: "; gPI_ON()
    ?? PADC(ALLTRIM(idpartner),54); gPI_OFF()
    ?? SPACE(17)+"Dana"+SPACE(14)+"      god."
    ? SPACE(gnLMONI)+"      "+REPL("-",54)+SPACE(21)+REPL("-",14)+"   "+"--"
    ? SPACE(gnLMONI)+"Zenica, "; gPI_ON()
    ?? PADC(SrediDat(datdok),52); gPI_OFF()
    ? SPACE(gnLMONI)+"        "+REPL("-",52)
    ?; ?; ?; ?; ?
    ? SPACE(gnLMONI)+SPACE(30); gPB_ON(); gP10cpi()
    ?? "ODOBRENJE I NALOG ZA ISPLATU"; gPB_OFF(); gPCOND()
    ?; ?; ?; ?; ?
    ? SPACE(gnLMONI)+"Kojim se odre"+IF(gKodnaS=="8","�","|")+"uje da se izvr"+IF(gKodnaS=="8","�","{")+"i isplata u korist "; gpI_ON()
    ?? PADC(ALLTRIM(Ocitaj(F_PARTN,idpartner,"TRIM(naz)+', '+mjesto")),57); gpI_OFF()
    ? SPACE(gnLMONI)+"                                                "+REPL("-",57)
    ?
    ? SPACE(gnLMONI)+REPL("-",105)
    ? SPACE(gnLMONI)+"na ime ra"+IF(gKodnaS=="8","�","~")+"una broj "; gpI_ON()
    ?? PADC(ALLTRIM(brdok),24); gpI_OFF()
    ?? " od "; gPI_ON()
    ?? PADC(DTOC(datval),23); gPI_OFF()
    ?? " za kupljenu robu - izvr"+IF(gKodnaS=="8","�","{")+"ene usluge"; gPI_ON()
    ? SPACE(gnLMONI)+"                   "+REPL("-",24)+"    "+REPL("-",23)
    ?
    ? SPACE(gnLMONI)+REPL("-",105)
    ? SPACE(gnLMONI)+PADC(ALLTRIM(opis),105); gPI_OFF()
    ? SPACE(gnLMONI)+REPL("-",105)
    ?
    ? SPACE(gnLMONI)+REPL("-",105)
    ? SPACE(gnLMONI)+"na teret ovog organa - slu"+IF(gKodnaS=="8","�","`")+"be i to:        "+ValDomaca()+" "; gPI_ON()
    ?? transform(iznosbhd,gPicBHD); gPI_OFF()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(43)+ValDomaca()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(43)+ValDomaca()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(43)+ValDomaca()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(43)+ValDomaca()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(32)+"UKUPNO     "+ValDomaca()+" "; gPI_ON()
    ?? transform(iznosbhd,gPicBHD); gPI_OFF()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(32)+REPL("-",33)
    ? SPACE(gnLMONI)+SPACE(32)+"ZA ISPLATU "+ValDomaca()+" "; gPI_ON()
    ?? transform(iznosbhd,gPicBHD); gPI_OFF()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(32)+REPL("-",33)
    ?; ?; ?; ?
    ? SPACE(gnLMONI)+SPACE(15)+"Ra"+IF(gKodnaS=="8","�","~")+"unopolaga"+IF(gKodnaS=="8","�","~")+SPACE(50)+"Naredbodavac"
    ?; ?
    ? SPACE(gnLMONI)+REPL("-",43)+SPACE(20)+REPL("-",42)
    ?
    FF
    IF cBrojOiN=="T"
      EXIT
    ELSE
      SKIP 1
    ENDIF
  ENDDO
  END PRINT
  GO (nRec)
RETURN (NIL)




function SrediRbrFin(lSilent)
local nArr
local nTREC
local i
local _rec

if (lSilent == nil)
	lSilent := .f.
endif

if !lSilent
	if Pitanje(,"Srediti redne brojeve?","D")=="N"
		return
	endif
endif

nArr := SELECT()
nRec := RecNo()

select fin_pripr
set order to tag "0"
go top

i := 1

Box(, 1, 50)

do while !EOF() 
	
	skip 1
	nTREC := RECNO()
	skip -1
	
    _rec := dbf_get_rec()

	_rec["rbr"] := PADL( ALLTRIM(STR(i)) , 4 )
	dbf_update_rec(_rec)
	
	@ m_x + 1, m_y + 2 SAY "redni broj: " + field->rbr
	
	++ i
	
	go (nTREC)
	
enddo

set order to tag "1"

BoxC()

go top

select (nArr)
go nRec

return



/*! \fn ChkKtoMark(cIdKonto)
 *  \brief provjeri da li postoji marker na kontu
 *  \brief Uslov za ovu opciju: SIFK podesenje: ID=KONTO, OZNAKA=MARK, TIP=C, DUZ=1
 *  \param cIdKonto - id konto
 */
function ChkKtoMark(cIdKonto)

bRet:=.t.
cMark:=IzSifKKonto( "MARK", cIdKonto, NIL)
do case
	// ne postoji definicija...
	case cMark==nil
		bRet:=.t.
	// postoji marker
	case cMark=="*"
		bRet:=.t.
	// ne postoji marker
	case cMark==" "
		bRet:=.f.
endcase

return bRet



