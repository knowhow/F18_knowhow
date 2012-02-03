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


#include "os.ch"


function os_pregled_po_rj()
local lPartner

O_RJ
o_os_sii()

lPartner := os_fld_partn_exist()

cIdrj:=space(4)
cON:="N"
cKolP:="N"
cPocinju:="N"

cBrojSobe:=space(6)
lBrojSobe:=.f.
cFiltK1:=SPACE(40)
cFiltDob:=SPACE(40)
cOpis:="N"

Box(,7+IF(lPartner,1,0),77)
    DO WHILE .t.
        @ m_x+1,m_y+2 SAY "Radna jedinica:" get cidrj valid p_rj(@cIdrj)
        @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
        @ m_x+2,m_y+2 SAY "Prikaz svih neotpisanih (N) / otpisanih(O) /"
        @ m_x+3,m_y+2 SAY "samo novonabavljenih (B)    / iz proteklih godina (G)"   get cON pict "@!" valid con $ "ONBG"
        @ m_x+4,m_y+2 SAY "Prikazati kolicine na popisnoj listi D/N" GET cKolP valid cKolP $ "DN" pict "@!"
        @ m_x+5,m_y+2 SAY "Prikazati kolonu 'opis' ? (D/N)" GET cOpis valid cOpis $ "DN" pict "@!"

        if os_postoji_polje("brsoba")
            lBrojSobe:=.t.
            @ m_x+6,m_y+2 SAY "Broj sobe (prazno sve) " GET cBrojSobe  pict "@!"
        endif

        @ m_x+7,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"

        if lPartner
            @ m_x+8,m_y+2 SAY "Filter po dobavljacima:" GET cFiltDob pict "@!S20"
        endif

        read
        ESC_BCR
        aUsl1:=Parsiraj(cFiltK1,"K1")
        aUsl2:=Parsiraj(cFiltDob,"idPartner")
        if aUsl1<>nil .and. aUsl2<>nil
            exit
        endif
    ENDDO
BoxC()

if lBrojSobe .and. EMPTY(cBrojSobe)
    lBrojSobe := ( Pitanje(,"Zelite li da bude prikazan broj sobe? (D/N)","N") == "D" )
endif

lPoKontima := .f.
lPoAmortStopama := (IzFmkIni("OsRptPrj","PoAmortStopama","N",PRIVPATH)=="D")

if cpocinju=="D"
    cIdRj:=trim(cIdrj)
endif

start print cret

m:="----- ---------- ----------------------------"+IF(cOpis=="D"," "+REPL("-",LEN(field->opis)),"")+"  ---- ------- -------------"

if lPoAmortStopama
	select_os_sii()
	if cIdRj==""
		set order to tag "5" 
        // idam+idrj+id
	else
		INDEX ON idrj+idam+id TO "TMPOS"
	endif
elseif lBrojSobe .and. EMPTY(cBrojSobe)
	m:="----- ------ ---------- ----------------------------"+IF(cOpis=="D"," "+REPL("-",LEN(field->opis)),"")+"  ---- ------- -------------"
	select_os_sii()
	set order to tag "2" 
    //idrj+id+dtos(datum)
	INDEX ON idrj+brsoba+id+dtos(datum) TO "TMPOS"
elseif lPoKontima
	select_os_sii()
	INDEX ON idkonto+id TO "TMPOS"
elseif cIdRj==""
	select_os_sii()
	set order to tag "1" 
    // id+idam+dtos(datum)
else
	select_os_sii()
	set order to tag "2" 
    //idrj+id+dtos(datum)
endif

if !EMPTY(cFiltK1) .or. !EMPTY(cFiltDob)
  cFilter:=aUsl1+".and."+aUsl2
  select_os_sii()
  set filter to &cFilter
endif

ZglPrj()

if !lPoKontima
    seek cIdrj
endif

private nRbr:=0
cLastKonto:=""

do while !eof() .and. ( field->idrj = cIdrj .or. lPoKontima)

    if lPoKontima .and. !( field->idrj = cidrj)
        skip
        loop
    endif

    if (cON="B" .and. year(gdatobr)<>year(field->datum))  
        // nije novonabavljeno
        skip 
        loop                                  
        // prikazi samo novonabavlj.
    endif

    if (cON="G" .and. year(gdatobr)=year(field->datum))  
        // iz protekle godine
        skip
        loop                                   
        // prikazi samo novonabavlj.
    endif

    if (!empty(datotp) .and. year(datotp)<=year(gdatobr)) .and. cON $ "NB"
        // otpisano sredstvo , a zelim prikaz neotpisanih
        skip 
        loop
    endif
    
    if (empty(datotp) .and. year(datotp)<year(gdatobr)) .and. cON=="O"
        // neotpisano, a zelim prikaz otpisanih
        skip 
        loop
    endif

    if !empty(cBrojsobe)
        if cbrojsobe <> field->brsoba
            skip
            loop
        endif
    endif

    if lPoKontima .and. ( nrbr=0 .or. cLastKonto<>idkonto )  // prvo sredstvo,
                                                          // ispiçi zaglavlje
        if nrbr>0
            ? m
            ?
        endif

        if prow()>59
            FF
            ZglPrj()
        endif

        ?
        ? "KONTO:",idkonto
        ? REPL("-",14)
        nRbr:=0

    endif

    if prow()>62
        FF
        ZglPrj()
    endif
 
    if lBrojSobe .and. EMPTY(cBrojSobe)
        ? str(++nrbr,4)+".",brsoba,id,naz
    else
        ? str(++nrbr,4)+".",id,naz
    endif
 
    IF cOpis=="D"
        ?? "",opis
    ENDIF
    ?? "",jmj

    if cKolP=="D"
        @  prow(),pcol()+1 SAY kolicina pict "9999.99"
    else
        @  prow(),pcol()+1 SAY space(7)
    endif

    cLastKonto := idkonto

    @ prow(),pcol()+1 SAY " ____________"
    skip
enddo

? m

if prow()>56
    FF
    ZglPrj()
endif

?
? "     Zaduzeno lice:                                     Clanovi komisije:"
?
? "     _______________                                  1.___________________"
?
? "                                                      2.___________________"
?
? "                                                      3.___________________"
FF
end print

close all
return




function ZglPrj()
local _mod_name := "OS"
local nArr := SELECT()

if gOsSii == "S"
    _mod_name := "SII"
endif

P_10CPI
?? UPPER(gTS)+":",gNFirma
?
? _mod_name + ": Pregled stalnih "

if cON=="N"
   ?? "sredstava u upotrebi"
elseif cON=="B"
   ?? "novonabavljenih sredstava u toku godine"
else
   ?? "sredstava otpisanih u toku godine"
endif

select rj
seek cidrj

select (nArr)

?? "     Datum:", gDatObr

? "Radna jedinica:", cIdrj, rj->naz

if cpocinju=="D"
  ?? space(6),"(SVEUKUPNO)"
endif

if !EMPTY(cFiltK1)
  ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"
endif

if !EMPTY(cFiltDob)
  ? "Filter za dobavljace pravljen po uslovu: '"+TRIM(cFiltDob)+"'"
endif

if !empty(cBrojSobe)
  ?
  ? "Prikaz za sobu br:", cBrojSobe
  ?
endif

IF cOpis=="D"
  P_COND
ENDIF

? m
if lBrojSobe .and. EMPTY(cBrojSobe)
 ? " Rbr. Br.sobe Inv.broj        Sredstvo               "+IF(cOpis=="D",PADC("Opis",1+LEN(field->opis)),"")+" jmj  kol  "
else
 ? " Rbr.  Inv.broj        Sredstvo              "+IF(cOpis=="D",PADC("Opis",1+LEN(field->opis)),"")+"  jmj  kol  "
endif
? m

return


