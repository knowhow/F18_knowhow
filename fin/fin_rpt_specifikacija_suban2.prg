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


#include "fin.ch"

static __par_len := 6
static __rj_len := 4


// ---------------------------------------------------
// kreira export tabelu
// ---------------------------------------------------
static function cre_tmp( cPath )
local aFields

aFields := {}

AADD(aFields, {"idfirma", "C", 2, 0})
AADD(aFields, {"idkonto", "C", 7, 0})
AADD(aFields, {"idpartner", "C", __par_len, 0})
AADD(aFields, {"kto_opis", "C", 50, 0})
AADD(aFields, {"par_opis", "C", 50, 0})
AADD(aFields, {"par_mjesto", "C", 50, 0})
AADD(aFields, {"idrj", "C", __rj_len, 0})
AADD(aFields, {"rj_opis", "C", 50, 0})
AADD(aFields, {"dug", "N", 15, 2})
AADD(aFields, {"pot", "N", 15, 2})
AADD(aFields, {"saldo", "N", 15, 2})
AADD(aFields, {"dug2", "N", 15, 2})
AADD(aFields, {"pot2", "N", 15, 2})
AADD(aFields, {"saldo2", "N", 15, 2})

t_exp_create( aFields )

o_tmp( cPath )

return



// -----------------------------------------------
// otvori i indeksiraj pomocnu tabelu
// -----------------------------------------------
static function o_tmp( cPath )

select (248)
use ( cPath + "r_export" ) alias "r_export"
index on idkonto + idpartner + idrj tag "1"

return


// ---------------------------------------------------
// Specifikacija subanalitickih konta v.2
// ---------------------------------------------------
function spec_sub()
local cSK:="N"
local cLDrugi:=""
local cPom:=""
local nCOpis:=0
local cLTreci:=""
local cIzr1
local cIzr2
local cExpRptDN:="N"
local cOpcine := SPACE(20)
local cVN := SPACE(20)
local cP_Path := PRIVPATH
local cT_sez := goModul:oDataBase:cSezona
local i
local nYearFrom
local nYearTo
local lSilent
local lWriteKParam
local lInSez
local cDok_izb := ""

private cSkVar := "N"
private fK1 := fk2 := fk3 := fk4 := "N"
private cRasclaniti := "N"

cN2Fin := IzFMkIni('FIN','PartnerNaziv2','N')

O_PARTN
__par_len := LEN( partn->id )
O_SUBAN
__rj_len := LEN( suban->idrj )

// kreiraj tabelu exporta
cre_tmp( cP_Path )

nC := 50
O_PARTN
O_PARAMS

private cSection:="1"
private cHistory:=" "
private aHistory:={}

RPar("k1",@fk1)
RPar("k2",@fk2)
RPar("k3",@fk3)
RPar("k4",@fk4)

select params
use

cIdFirma := gFirma
picBHD := FormPicL("9 "+gPicBHD,20)

qqKonto := SPACE(100)
qqPartner := SPACE(100)
dDatOd := CTOD("")
dDatDo := CTOD("")
cDok_izb := SPACE(150)

O_PARAMS

private cSection:="S"
private cHistory:=" "
private aHistory:={}

RPar("qK",@qqKonto)
RPar("qP",@qqPartner)
RPar("d1",@dDatoD)
RPar("d2",@dDatDo)

qqkonto := padr(qqKonto,100)
qqPartner := padr(qqPartner,100)
qqBrDok := SPACE(40)

select params
use

cTip := "1"

Box("",20,65)
	
	set cursor on
	
	private cK1 := "9"
	private cK2 := "9"
	private cK3 := "99"
	private cK4 := "99"
	
	if IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
  		cK3 := "999"
	endif

	if gDUFRJ=="D"
  		cIdRj := SPACE(60)
	else
  		cIdRj := "999999"
	endif
	
	cFunk := "99999"
	cFond := "9999"
	cNula := "N"
	
	do while .t.
 		
		@ m_x+1,m_y+6 SAY "SPECIFIKACIJA SUBANALITICKIH KONTA"
 		
		if gDUFRJ == "D"
    			cIdFirma := PADR(gFirma+";",30)
    			@ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma PICT "@!S20"
 		else
   			if gNW == "D"
     				@ m_x+3, m_y+2 SAY "Firma "
				?? gFirma, "-", gNFirma
   			else
    				@ m_x+3, m_y+2 SAY "Firma: " GET cIdFirma ;
					VALID {|| IF(!EMPTY(cIdFirma), ;
					P_Firma(@cIdFirma),),;
					cIdFirma := LEFT(cIdFirma,2), ;
					.t.}
   			endif
 		endif

 		@ m_x+4, m_y+2 SAY "Konto   " GET qqKonto  pict "@!S50"
 		@ m_x+5, m_y+2 SAY "Partner " GET qqPartner pict "@!S50"
 		@ m_x+6, m_y+2 SAY "Datum dokumenta od" GET dDatOd
 		@ m_x+6, col()+2 SAY "do" GET dDatDo
 		
		if gVar1 == "0"
  			@ m_x+7, m_y+2 SAY "Obracun za " + ;
				ALLTRIM(ValDomaca()) + "/" + ;
				ALLTRIM(ValPomocna()) + "/" + ;
				ALLTRIM(ValDomaca()) + "-" + ;
				ALLTRIM(ValPomocna()) + " (1/2/3):" ;
				GET cTip ;
				VALID cTip $ "123"
 		else
  			cTip := "1"
 		endif

 		@ m_x+ 8, m_y+2 SAY "Prikaz sintetickih konta (D/N) ?" ;
			GET cSK PICT "@!" VALID csk $ "DN"
 		@ m_x+ 9, m_y+2 SAY "Prikaz stavki sa saldom 0 D/N" ;
			GET cNula PICT "@!" VALID cNula  $ "DN"
 		@ m_x+10, m_y+2 SAY "Skracena varijanta (D/N) ?" ;
			GET cSkVar PICT "@!" VALID cSkVar $ "DN"
 		@ m_x+11, m_y+2 SAY "Uslov za broj veze (prazno-svi) " ;
			GET qqBrDok PICT "@!S20"
 		@ m_x+12, m_y+2 SAY "Uslov za vrstu naloga (prazno-svi) " ;
			GET cVN PICT "@!S20"
 		@ m_x+13, m_y+2 SAY "Izbaciti dokumente: " ;
			GET cDok_izb PICT "@!S30"
 	
		
		cRasclaniti := "N"
 		
		if gRJ == "D"
  			@ m_x+14, m_y+2 SAY "Rasclaniti po RJ (D/N) " ;
				GET cRasclaniti PICT "@!" ;
				VALID cRasclaniti $ "DN"
 		
		endif

		@ m_x + 16, m_y + 2 SAY "Opcina (prazno-sve):" GET cOpcine
		
		UpitK1k4( 15 )
 		
		@ m_x+20,m_y+2 SAY "Export izvjestaja u dbf (D/N) ?" ;
			GET cExpRptDN PICT "@!" ;
			VALID cExpRptDN $ "DN"
		
		read
		
		ESC_BCR
 		
		O_PARAMS
 		private cSection := "S"
		private cHistory := " "
		private aHistory := {}
 		
		WPar("qK",qqKonto)
 		WPar("qP",qqPartner)
 		WPar("d1",dDatoD)
 		WPar("d2",dDatDo)
 		
		select params
		use
 		
		aUsl1 := Parsiraj( qqKonto, "IdKonto" )
 		aUsl2 := Parsiraj( qqPartner, "IdPartner" )
 		
		if gDUFRJ == "D"
   			aUsl3 := Parsiraj(cIdFirma,"IdFirma")
   			aUsl4 := Parsiraj(cIdRJ,"IdRj")
 		endif

 		aBV := Parsiraj(qqBrDok,"UPPER(BRDOK)","C")
		aVN := Parsiraj(cVN,"IDVN","C")
 		
		if aBV<>NIL .and. aVN<>NIL .and. ;
			aUsl1<>NIL .and. aUsl2<>NIL .and. ;
			IF(gDUFRJ=="D",aUsl3<>NIL.and.aUsl4<>NIL,.t.)
			exit
		endif
	enddo
BoxC()

// godina od - do
nYearFrom := YEAR( dDatOd )
nYearTo := YEAR( dDatDo )
lInSez := .f.

if ( nYearTo - nYearFrom ) <> 0
	// ima vise godina, prodji kroz sezone
	lInSez := .t.
endif

// export izvjestaja u dbf
lExpRpt := (cExpRptDN == "D")

if gDUFRJ != "D"
	cIdFirma := left(cIdFirma,2)
endif

O_SUBAN
CistiK1k4()

// prodji po godinama i azuriraj u tbl_export

lSilent := .t.
lWriteKParam := .t.

for i := nYearFrom to nYearTo

	if lInSez == .t.
		// logiraj se u godinu
		goModul:oDataBase:logAgain( ALLTRIM(STR(i)), ;
			lSilent, lWriteKParam )
		// otvori export tabelu u tekucoj sezoni
		o_tmp( cP_Path )
	endif
	
	O_RJ
	O_PARTN
	O_KONTO
	O_SUBAN

	select suban

	if !EMPTY(cIdFirma) .and. gDUFRJ!="D"
		if cRasclaniti=="D"
   			index on idfirma+idkonto+idpartner+idrj+dtos(datdok) ;
				to SUBSUB
   			SET ORDER TO TAG "SUBSUB"
 		else
   			// IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr
   			SET ORDER TO 1
 		endif
	else
		if cRasclaniti=="D"
   			index on idkonto+idpartner+idrj+dtos(datdok) ;
				to SUBSUB
  			SET ORDER TO TAG "SUBSUB"
 		else
   			cIdFirma:=""
   			INDEX ON IdKonto+IdPartner+dtos(DatDok)+;
				BrNal+RBr TO SVESUB
   			SET ORDER TO TAG "SVESUB"
 		endif
	endif

	if gDUFRJ == "D"
		cFilter := aUsl3
	else
  		cFilter := "IdFirma="+cm2str(cidfirma)
	endif

	if !EMPTY(cVN)
		cFilter += ( ".and. " + aVN )
	endif

	if !EMPTY(qqBrDok)
  		cFilter += ( ".and." + aBV )
	endif

	if aUsl1 <> ".t."
 		cFilter += ( ".and."+aUsl1 )
	endif

	if aUsl2 <> ".t."
 		cFilter += ( ".and."+aUsl2 )
	endif

	if !empty(dDatOd) .or. !empty(dDatDo)
   		cFilter += ( ".and. DATDOK>="+;
			cm2str(dDatOd)+".and. DATDOK<="+cm2str(dDatDo) )
	endif

	if fk1=="D" .and. len(ck1)<>0
  		cFilter += ( ".and. k1='"+ck1+"'" )
	endif

	if fk2=="D" .and. len(ck2)<>0
  		cFilter += ( ".and. k2='"+ck2+"'" )
	endif

	if fk3=="D" .and. len(ck3)<>0
  		cFilter += ( ".and. k3='"+ck3+"'" )
	endif

	if fk4=="D" .and. len(ck4)<>0
  		cFilter += ( ".and. k4='"+ck4+"'" )
	endif

	if gRj=="D" .and. len(cIdrj)<>0
  		if gDUFRJ == "D"
    			cFilter += ( ".and."+aUsl4 )
  		else
    			cFilter += ( ".and. idrj='"+cidrj+"'" )
  		endif
	endif

	if gTroskovi == "D" .and. len(cFunk)<>0
  		cFilter += ( ".and. Funk='"+cFunk+"'" )
	endif

	if gTroskovi == "D" .and. len(cFond)<>0
  		cFilter += ( ".and. Fond='"+cFond+"'" )
	endif

	set filter to &cFilter
	go top

	// prodji kroz podatke
	
	do whileSC !EOF()
	
		cIdKonto := field->idkonto
   		cIdPartner := field->idpartner
		
		nTArea := SELECT()

		// uslov po opcinama
		if !EMPTY( cOpcine )
			
			select partn
			seek cIdPartner
			
			if ALLTRIM( field->idops ) $ cOpcine
				// to je taj partner...
			else
				// posto nije to taj preskoci...
				select (nTArea)
				skip
				loop
			endif

		endif

		cRasclan := ""

		if cRasclaniti == "D"
			cRasclan := field->idrj
		endif
		
		select (nTArea)

   		nD := 0
		nP := 0
   		nD2 := 0
		nP2 := 0

   		do whileSC !eof() .and. cIdKonto == field->idkonto ;
			.and. field->idpartner == cIdPartner ;
			.and. RasclanRJ()
		
			// ima li dokumenata za izbaciti ?
			if !EMPTY( cDok_izb )
				if field->idvn $ cDok_izb
					// preskoci na sljedeci zapis
					skip
					loop
				endif
			endif
			
			if lInSez == .t.
				// ako su sezone, 
				// preskaci pocetna stanja
				if field->idvn == "00"
					skip
					loop
				endif
			endif

			// racuna duguje/potrazuje
			if field->d_p == "1"
       				nD += field->iznosbhd
       				nD2 += field->iznosdem
			else
				nP += field->iznosbhd
       				nP2 += field->iznosdem
			endif
     			
			skip 1
		
		enddo

		// pronadji opis rj
		select rj
		go top
		seek cRasclan
		if !FOUND()
			cRj_naz := ""
		else
			cRj_naz := field->naz
		endif

		// pronadji opis konta
		select konto
		hseek cIdKonto

		// pronadji opis partnera
		select partn
		hseek cIdPartner

		select suban

		// ubaci u tbl_export
		if cNula == "D" .or. ROUND( nD - nP, 3 ) <> 0
			
			select r_export
			go top
			seek cIdKonto + cIdPartner + cRasclan

			if !FOUND()
				
				append blank
				replace field->idfirma with cIdFirma
				replace field->idkonto with cIdKonto
				replace field->idpartner with cIdPartner
				replace field->kto_opis with konto->naz
				replace field->par_opis with partn->naz
				replace field->par_mjesto with partn->mjesto
				replace field->idrj with cRasclan
				replace field->rj_opis with cRj_naz
			
			endif

			replace field->dug with field->dug + nD
			replace field->pot with field->pot + nP
			replace field->saldo with ;
				field->saldo + ( nD - nP )
			
			replace field->dug2 with field->dug2 + nD2
			replace field->pot2 with field->pot2 + nP2
			replace field->saldo2 with ;
				field->saldo2 + ( nD2 - nP2 )
		
			select suban

		endif
 	enddo  
next

// uvijek se vrati u radno podrucje
if lInSez == .t.
	goModul:oDataBase:logAgain( cT_sez, lSilent, lWriteKParam )
	o_tmp( cP_Path )
endif

// ako je export izvjestaja onda ne pozivaj stampu !
if lExpRpt

	// pokreni i pregled export dbf-a nakon izvjestaja
	cLaunch := exp_report()
	tbl_export(cLaunch)

	close all
	return

endif

// poziva se izvjestaj

Pic := PicBhd

START PRINT CRET

if cSkVar == "D"
  	nDOpis:=25
	if __par_len > 6
	  //nDOpis += 2
	endif
	nDIznos:=12
  	pic:=RIGHT(picbhd,nDIznos)
else
  	nDOpis:=50
	if __par_len > 6
	   //nDOpis += 2
	endif
	nDIznos:=20
endif

if cTip == "3"
   	m:= "------- " + REPLICATE("-", __par_len) + " "+REPL("-",nDOpis)+" "+REPL("-",nDIznos)+" "+REPL("-",nDIznos)
else
   	m := "------- " + REPLICATE("-", __par_len) + " "+REPL("-",nDOpis)+" "+REPL("-",nDIznos)+" "+REPL("-",nDIznos)+" "+REPL("-",nDIznos)
endif

nStr:=0

nud := 0
nup := 0      
nud2 := 0
nup2 := 0    

select r_export
set order to tag "1"
go top

do whileSC !EOF()
	
	cSin := LEFT( field->idkonto, 3 )
 	
	nKd := 0
	nKp := 0
 	nKd2 := 0
	nKp2 := 0

 	do whileSC !EOF() .and.  cSin == LEFT( field->idkonto, 3 )
   		
		cIdKonto := field->idkonto
   		cIdPartner := field->idpartner

		if cRasclaniti == "D"
			cRasclan := field->idrj
		else
			cRasclan := ""
		endif

		// ispis headera
   		if prow() == 0
			header( cSkVar )
		endif
		
   		if prow() > 63 + gPStranica
			FF
			header( cSkVar )
		endif

   		if cNula == "D" .or. ( ROUND( field->saldo, 3) <> 0 ;
			.and. cTip $ "13" )
     			
			? cIdKonto, cIdPartner, ""
     			
			if cRasclaniti == "D"
       				
			  if !EMPTY( cRasclan )
         				
				cLTreci := "RJ:" + cRasclan + "-" + ;
					TRIM( field->rj_opis )
       			  endif
				
     			endif
     			
			nCOpis := PCOL()

			// ispis partnera
     			if !EMPTY( cIdPartner )
       			  if gVSubOp == "D"
				cPom := ALLTRIM( field->kto_opis ) + ;
					" (" + ;
					ALLTRIM( ALLTRIM(field->par_opis) + ;
					PN2()) + ;
					")"
         				
				?? PADR( cPom, nDOpis - DifIdP(cIdPartner) )
         				
				if LEN(cPom)>nDOpis-DifIdP(cidpartner)
           				cLDrugi := SUBSTR(cPom,nDOpis+1)
         			endif
       			  else
         			cPom:= ALLTRIM(field->par_opis) + PN2()
         			
				if !empty(field->par_mjesto)
            			  if right(trim(upper(field->par_opis)),;
				  	len(trim(field->par_mjesto))) != ;
					TRIM(UPPER(field->par_mjesto))
                			cPom:=trim(ALLTRIM(field->par_opis) + ;
						PN2()) + " " + ;
						trim(field->par_mjesto)

                			aTxt:=Sjecistr(cPom,nDOpis)
                			cPom:=aTxt[1]

                			if len(aTxt)>1
                  				cLDrugi:=aTxt[2]
                			endif

            			  endif
         			endif

         			?? padr(cPom,nDOpis)
       			  endif
     			
			else
       				?? padr( field->kto_opis, nDOpis )
     			endif

     			nC := pcol()+1
     			
			// ispis duguje/potrazuje/saldo
			if cTip=="1"
      				@ prow(),pcol()+1 SAY field->dug pict pic
      				@ prow(),pcol()+1 SAY field->pot pict pic
      				@ prow(),pcol()+1 SAY field->saldo pict pic
     			elseif cTip=="2"
      				@ prow(),pcol()+1 SAY field->dug2 pict pic
      				@ prow(),pcol()+1 SAY field->pot2 pict pic
      				@ prow(),pcol()+1 SAY field->saldo2 pict pic
     			else
      				@ prow(),pcol()+1 SAY field->saldo pict pic
      				@ prow(),pcol()+1 SAY field->saldo2 pict pic
     			endif
     			
			nKd += field->dug
			nKp += field->pot
     			nKd2 += field->dug2
			nKp2 += field->pot2
   		
		endif

   		if LEN(cLDrugi)>0
     			@ prow()+1, nCOpis SAY cLDrugi
     			cLDrugi:=""
   		endif
   		if LEN(cLTreci)>0
     			@ prow()+1, nCOpis SAY cLTreci
     			cLTreci:=""
   		endif
		
		skip

 	enddo  
	
 	if prow() > 61 + gPStranica
		FF
		header( cSkVar )
	endif

 	if cSK == "D"
   		
		select rj
		hseek cSin

		select r_export

		? m
   
		?  "SINT.K.",cSin, ": ", ALLTRIM( konto->naz )
   		
		if cTip == "1"
     			@ prow(),nC SAY nKd pict pic
     			@ prow(),pcol()+1 SAY nKp pict pic
     			@ prow(),pcol()+1 SAY nKd-nKp pict pic
   		elseif cTip == "2"
     			@ prow(),nC SAY nKd2 pict pic
     			@ prow(),pcol()+1 SAY nKp2 pict pic
     			@ prow(),pcol()+1 SAY nKd2-nKp2 pict pic
   		else
     			@ prow(),nC SAY nKd-nKP pict pic
     			@ prow(),pcol()+1 SAY nKd2-nKP2 pict pic
   		endif
   		
		? m
 	endif

 	nUd += nKd
	nUp += nKp  
 	nUd2 += nKd2
	nUp2 += nKp2   
enddo

if prow() > 61 + gPStranica
	FF
	header( cSkVar )
endif

? m
? " UKUPNO:"
if cTip=="1"
	@ prow(),nC       SAY nUd pict pic
  	@ prow(),pcol()+1 SAY nUp pict pic
  	@ prow(),pcol()+1 SAY nUd-nUp pict pic
elseif cTip=="2"
  	@ prow(),nC       SAY nUd2 pict pic
  	@ prow(),pcol()+1 SAY nUp2 pict pic
  	@ prow(),pcol()+1 SAY nUd2-nUp2 pict pic
else
  	@ prow(),nC       SAY nUd-nUP pict pic
  	@ prow(),pcol()+1 SAY nUd2-nUP2 pict pic
endif

? m

FF
END PRINT

closeret
return


// -------------------------------------------------------------
// header izvjestaja specifikacija po suban kontima
// -------------------------------------------------------------
static function header( cSkVar )

?
B_ON
P_COND

?? "FIN: SPECIFIKACIJA SUBANALITICKIH KONTA  ZA "

if cTip=="1"
  ?? ValDomaca()
elseif cTip=="2"
  ?? ValPomocna()
else
  ?? ALLTRIM(ValDomaca())+"-"+ALLTRIM(ValPomocna())
endif
if !(empty(dDatOd) .and. empty(dDatDo))
  ?? "  ZA DOKUMENTE U PERIODU ",dDatOd,"-",dDatDo
endif
?? " NA DAN: "; ?? DATE()
IF !EMPTY(qqBrDok)
  ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '"+TRIM(qqBrDok)+"'"
ENDIF
@ prow(),125 SAY "Str:"+str(++nStr,3)
B_OFF

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 IF EMPTY(cIdFirma)
  ? "Firma:",gNFirma,"(SVE RJ)"
 ELSE
  SELECT PARTN; HSEEK cIdFirma
  ? "Firma:",cidfirma,PADR(partn->naz, 25),partn->naz2
 ENDIF
endif
?
PrikK1k4()

select r_export

IF cSkVar=="D"
  F12CPI
  ? m
ELSE
  P_COND
  ? m
ENDIF
if cTip $ "12"
  IF cSkVar!="D"
    ? "KONTO   " + PADC("PARTN.", __par_len) + " NAZIV KONTA / PARTNERA                                          duguje            potra§uje                saldo"
  ELSE
    ? "KONTO   " + PADC("PARTN", __par_len) + " " +  PADR("NAZIV KONTA / PARTNERA",nDOpis)+" "+PADC("duguje",nDIznos)+" "+PADC("potra§uje",nDIznos)+" "+PADC("saldo",nDIznos)
  ENDIF
else
  IF cSkVar!="D"
    ? "KONTO   " + PADC("PARTN.", __par_len) + " NAZIV KONTA / PARTNERA                                       saldo "+ValDomaca()+"           saldo "+ALLTRIM(ValPomocna())
  ELSE
    ? "KONTO   " + PADC("PARTN.", __par_len) + " "+PADR("NAZIV KONTA / PARTNERA",nDOpis)+" "+PADC("saldo "+ValDomaca(),nDIznos)+" "+PADC("saldo "+ALLTRIM(ValPomocna()),nDIznos)
  ENDIF
endif

? m

return




