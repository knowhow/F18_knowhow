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

// -------------------------------------
// Izvjestaj: kartica artikla
// --------------------------------------
function pos_kartica_artikla()
local nStanje
local nSign:=1
local cSt
local nVrijednost
local nCijena:=0
local cRSdbf
local cLM:=""
local nSir:=40
local cSiroki := "D"
local cPPar
private cIdDio:=SPACE(2)
private cIdOdj:=SPACE(2)
private cDat0:=gDatum
private cDat1:=gDatum
private cPocSt:="D"

nMDBrDok := 6

O_KASE
O_ODJ
O_DIO
O_SIFK
O_SIFV
O_ROBA
O_POS

cRoba := SPACE(10)
cIdPos := gIdPos

cDat0 := fetch_metric("pos_kartica_datum_od", my_user(), cDat0 )
cDat1 := fetch_metric("pos_kartica_datum_do", my_user(), cDat1 )
cRoba := fetch_metric("pos_kartica_artikal", my_user(), cRoba )
cPPar := fetch_metric("pos_kartica_prikaz_partnera", my_user(), "N" )

set cursor on

Box(,11,60)

aNiz:={}

if gVrstaRS <> "K"
	@ m_x+1,m_y+2 SAY "Prod.mjesto (prazno-svi) "  GET  cIdPos  valid empty(cIdPos).or.P_Kase(cIdPos) pict "@!"
endif

if gModul=="HOPS"

	if gVodiOdj<>"D"
		cIdOdj:="10"
	endif
	
	@ m_x+2,m_y+2 SAY  "Odjeljenje               " GET cidodj valid P_Odj(@cIdOdj) picture "@!"
	
	if gPostDO=="D"
		@ m_X+3,m_y+2 SAY  "Dio objekta              " GET  cIdDio valid Empty(cIdDio).or.P_Dio(@cIdDio) pict "@!"
	endif

else 

	if gVodiOdj=="D"
		@ m_x+2,m_y+2 SAY  "Odjeljenje               " GET cidodj valid P_Odj(@cIdOdj) picture "@!"
	endif
	
endif  

read

@ m_x + 5, m_y + 6 SAY "Sifra artikla (prazno-svi)" GET cRoba valid EMPTY(cRoba) .or. P_Roba(@cRoba) PICT "@!"
@ m_x + 7, m_y + 2 SAY "za period " GET cDat0
@ m_x + 7, col() + 2 SAY "do " GET cDat1
@ m_x+9,m_y+2 SAY "sa pocetnim stanjem D/N ?" GET cPocSt valid cpocst $ "DN" pict "@!"
@ m_x+10,m_y+2 SAY "Prikaz partnera D/N ?" GET cPPar valid cPPar $ "DN" pict "@!"
@ m_x+11,m_y+2 SAY "Siroki papir    D/N ?" GET cSiroki valid cSiroki $ "DN" pict "@!"

read

ESC_BCR

set_metric("pos_kartica_datum_od", my_user(), cDat0 )
set_metric("pos_kartica_datum_do", my_user(), cDat1 )
set_metric("pos_kartica_artikal", my_user(), cRoba )
set_metric("pos_kartica_prikaz_partnera", my_user(), "N" )

BoxC()

SELECT ODJ
HSEEK cIdOdj

cZaduzuje := "R"
cU := R_U
cI := R_I
cRSdbf := "ROBA"

if gVrstaRS == "S"
  cLM := SPACE(5)
  nSir := 80
endif


if cPPar=="D"  
	O_POS_DOKS
	SELECT (F_POS_DOKS)
	// "IdPos+IdVd+dtos(datum)+BrDok"
	SET ORDER TO TAG "1"
endif

SELECT POS
set order to tag "2"      
// "2", "IdOdj+idroba+DTOS(Datum)", ;

if EMPTY( cRoba )
	Seek2( cIdOdj )
else
	Seek2( cIdOdj + cRoba )
	// da li postoji stanje ovog artikla
	if pos->idroba <> cRoba
		MsgBeep("Ne postoje trazeni podaci!")
		return
	endif
endif

EOF CRET

START PRINT CRET

// ovo je S - server
if gVrstaRS=="S"
   P_INI
   P_10CPI
endif

ZagFirma()

? PADC("KARTICE ARTIKALA NA DAN "+FormDat1(gDatum),nSir)
? PADC("-----------------------------------",nSir)

if gVrstaRS<>"K"
	if empty(cIdPos)
		? cLM+"PROD.MJESTO: "+cidpos+"-"+"SVE"
	else
		? cLM+"PROD.MJESTO: "+cidpos+"-"+Ocitaj(F_KASE,cIdPos,"Naz")
	endif
endif

if gVodiOdj=="D"
	? cLM+"Odjeljenje : "+cIdOdj+"-"+RTRIM(Ocitaj(F_ODJ,cIdOdj,"naz"))
endif
  
if gModul=="HOPS".and.gPostDO=="D"
	if empty(cIdDio)
		? cLM+"Dio objekta: "+"SVI"
	else
		? cLM+"Dio objekta: "+cIdDio+"-"+RTRIM(Ocitaj(F_DIO, cIdDio,"naz"))
	endif
endif

? cLM+"ARTIKAL    : "+IF(EMPTY(cRoba),"SVI",RTRIM(cRoba))
? cLM+"PERIOD     : "+FormDat1(cDat0)+" - "+FormDat1(cDat1)
?

/*****
Artikal
Dokum.     Ulaz       Izlaz     Stanje    Vrijednost
------- ---------- ---------- ---------- ------------
xx-xxxx 999999.999 999999.999 999999.999 99999999.999
*****/

if gVrstaRS=="S"
	cLM:=SPACE(5)
	? cLM
else
	cLM:=""
	?
endif

?? "Artikal"

if cSiroki=="D"
	? cLM+" Datum   Dokum."+SPACE(nMDBrDok-4)+"     Ulaz       Izlaz     Stanje"
else
	? cLM+"Dokum."+SPACE(nMDBrDok-4)+"     Ulaz       Izlaz     Stanje"
endif

if gVrstaRS=="S"
	?? "    Vrijednost"
endif

if cPPar=="D"
	?? "   Partner"
endif

if gVrstaRS=="S"
	m:=cLM
	if cSiroki=="D"
		m:=m+replicate("-",8)+" "  // datum
	endif
	m:=m+"---"+REPL("-",nMDBrDok)+" ---------- ---------- ---------- ------------"
else
	m:=""
	if cSiroki=="D"
		m:=m+replicate("-",8)+" "  // datum
	endif
	m:=m+"---"+REPL("-",nMDBrDok)+" ---------- ---------- ----------"
endif

if cPPar=="D"
	m+=" --------"
endif


do while !eof() .and. POS->IdOdj==cIdOdj
    nStanje:=0
    nVrijednost:=0
    fSt:=.t.
    cIdRoba:=POS->IdRoba
    nUlaz:=nIzlaz:=0
    SELECT POS

    do while !eof() .and. POS->(IdOdj+IdRoba)==(cIdOdj+cIdRoba)
        if (cZaduzuje=="R" .and. pos->idvd=="96") .or. (cZaduzuje=="S".and.pos->idvd$"42#01")
    	    skip
	        loop
        endif

        if cPocSt=="N"
	        SELECT (cRSdbf)
	        HSEEK cIdRoba
	        nCijena1:=pos_get_mpc()
	        SELECT POS
    	    nStanje:=0
    	    nVrijednost:=0
        	seek cIdOdj+cIdRoba+DTOS(cDat0)
        else
            // stanje do
            do while !eof() .and. POS->(IdOdj+IdRoba)==(cIdOdj+cIdRoba) .and. POS->Datum<cDat0
      	   	    if !empty(cIdDio) .and. POS->IdDio<>cIdDio
		            skip
		            loop
      	        endif
      	    if (Klevel>"0" .and. pos->idpos="X") .or. (!empty(cIdPos) .and. IdPos<>cIdPos)
        	    skip
		        loop
      	    endif
	
        	if (cZaduzuje=="R" .and. pos->idvd=="96") .or. (cZaduzuje=="S".and.pos->idvd$"42#01")
        	    skip
		        loop
        	endif
	
      	    if pos->idvd $ DOK_ULAZA
        	    nStanje += POS->Kolicina
		
      	    elseif pos->idvd $ "IN"

        	    //nStanje -= ( POS->Kolicina - POS->Kol2 )
        	    //nVrijednost += (POS->Kol2-POS->Kolicina) * POS->Cijena
                
                // ima setovano i knjizna kolicina
                //if pos->kolicina <> 0
            	    nStanje -= ( POS->Kolicina - POS->Kol2 )
            	    nVrijednost += (POS->Kol2-POS->Kolicina) * POS->Cijena
                //else
                  //  nStanje := pos->kol2
		          //  nVrijednost := pos->kol2 * pos->cijena
                //endif

      	    elseif pos->idvd $ DOK_IZLAZA
        	    nStanje -= POS->Kolicina
		
      	    elseif pos->IdVd == "NI"
        	    // ne mijenja kolicinu
      	    endif
	
      	    skip
        enddo
      
        SELECT (cRSdbf)
        HSEEK cIdRoba
        nCijena1:=pos_get_mpc()
      
        if fSt
            if gVrstaRS=="S" .and. Prow()>63-gPstranica-3
		        FF
            endif
            ? m
            ? cLM
            if cSiroki=="D"
		        ?? space(8)+" "
            endif
            ?? cIdRoba, PADR (AllTrim (Naz)+" ("+AllTrim (Jmj)+")", 32)
            ? m
            nVrijednost:=nStanje * nCijena1
            if gVrstaRS=="S"
		        ? cLM
	        else
		        ?
	        endif
            ?? PADL ("Stanje do "+FormDat1 (cDat0), 29), ""
            ?? STR (nStanje, 10, 3)
            if gVrstaRS == "S"
		        ?? " " + STR (nCijena1*nStanje, 12, 3)
            endif
            fSt := .F.
        endif
        SELECT POS
    endif // cPocSt

    do while !eof().and.POS->(IdOdj+IdRoba)==(cIdOdj+cIdRoba).and.POS->Datum<=cDat1
      
        if !empty(cIdDio).and.POS->IdDio<>cIdDio
      	    skip
	        loop
        endif
      
        if (Klevel>"0".and.pos->idpos="X").or.(!empty(cIdPos).and.IdPos<>cIdPos)
	        //    (POS->IdPos="X" .and. AllTrim (cIdPos)<>"X") .or. ;  // ?MS
            skip
	        loop
        endif
      
        if (cZaduzuje=="R".and.pos->idvd=="96") .or. (cZaduzuje=="S".and.pos->idvd$"42#01")
      	    skip
      	    loop
        endif

        if fSt
            SELECT (cRSdbf)
	        HSEEK cIdRoba
            if gVrstaRS=="S".and.prow()>63-gPstranica-3
        	    FF
            endif
            ? m
            ? cLM+cIdRoba,PADR(ALLTRIM(Naz)+" ("+ALLTRIM(Jmj)+")",32)
            ? m
            SELECT POS
            fSt:=.F.
        endif
        //
      
        if POS->idvd $ DOK_ULAZA
      
            ? cLM
	
            if cSiroki=="D"
                ?? dtoc(pos->datum)+" "
            endif
	
            ?? POS->IdVd+"-"+PADR(AllTrim(POS->BrDok),nMDBrDok),""
	
            ?? STR (POS->Kolicina, 10, 3), SPACE (10), ""
            nUlaz += POS->Kolicina
	
            nStanje += POS->Kolicina
            ?? STR (nStanje, 10, 3)
	
            if gVrstaRS == "S"
                ?? "", STR (nCijena1*nStanje, 12, 3)
            endif
	
        elseif POS->IdVd == "NI"
      
          //nVrijednost := POS->Kolicina * POS->Ncijena
          ? cLM
	  
          if cSiroki=="D"
            ?? dtoc(pos->datum)+" "
          endif
	  
          ?? POS->IdVd+"-"+PADR (AllTrim(POS->BrDok), nMDBrDok), ""
          ?? "S:", STR (POS->Cijena, 7, 2), "N:", Str (POS->Ncijena, 7, 2),;
             STR (nStanje, 10, 3)
	     
          if gVrstaRS == "S"
            ?? "", Str (nCijena1*nStanje, 12, 3)
          endif
	  
          skip
	      loop  
	  
      elseif POS->idvd $ "IN"+DOK_IZLAZA
      
        if pos->idvd $ DOK_IZLAZA
            nKol := POS->Kolicina
        elseif POS->IdVd == "IN"
            nKol := ( POS->Kolicina - POS->Kol2 )
        endif
	
        if pos->idvd == "IN" .and. pos->kolicina == 0
            nIzlaz += nStanje - nKol
            nStanje -= nStanje - ABS( nKol )
        else
            nIzlaz += nKol
	        nStanje -= nKol
        endif

        if gVrstaRS == "S" .and. Prow() > 63-gPstranica-3
            FF
        endif
	
        ? cLM
	
        if cSiroki=="D"
            ?? dtoc(pos->datum)+" "
        endif
	
        ?? POS->IdVd + "-" + PADR(AllTrim(POS->BrDok), nMDBrDok), ""
        ?? SPACE (10), STR (nKol, 10, 3), STR (nStanje, 10, 3)
	
        if gVrstaRS == "S"
          ?? "", STR (nCijena1*nStanje, 12, 3)
        endif
	
      endif // izlaz, in

      // prikaz partnera
      if cPPar=="D"
        ?? " "
        ?? Ocitaj(F_POS_DOKS,POS->(IdPos+IdVd+dtos(datum)+BrDok),"idgost")
      endif
      

      skip
    enddo
    //
    
    ? m
    ? cLM
    
    if cSiroki=="D"
       ?? space(8)+" "
    endif
    
    ?? " UKUPNO", STR(nUlaz,10,3), STR(nIzlaz,10,3), STR(nStanje,10,3)
      
    if gVrstaRS == "S"
	?? "", STR (nCijena1*nStanje, 12, 3)
    else
    	if cSiroki=="D"
		?  space(9)+"  Cij:",str(nCijena1,8,2),"Ukupno:",STR (nCijena1*nStanje, 12, 3)
	else
		?  "  Cij:",str(nCijena1,8,2),"Ukupno:",STR (nCijena1*nStanje, 12, 3)
	endif
    endif
    
    ? m
    ?
    
    // odvrti viska slogove
    do while !eof().and.POS->(IdOdj+IdRoba)==(cIdOdj+cIdRoba).and.POS->Datum>cDat1
      skip
    enddo
    
  enddo
  
  // izleti ako je zadata konkretna roba
  if !empty(cRoba)  
    exit
  endif
 
// cidodj
enddo 

PaperFeed()
END PRINT

close all
return


