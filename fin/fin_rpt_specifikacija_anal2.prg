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


// --------------------------------------------
// kreiranje pomocne tabele
// --------------------------------------------
static function cre_tmp( cPath )
local aDbf := {}

AADD( aDbf, { "idfirma", "C", 2, 0  } )
AADD( aDbf, { "idkonto", "C", 7, 0  } )
AADD( aDbf, { "kto_opis", "C", 100, 0  } )
AADD( aDbf, { "opis", "C", 100, 0  } )
AADD( aDbf, { "dug", "N", 15, 5  } )
AADD( aDbf, { "pot", "N", 15, 5  } )
AADD( aDbf, { "saldo", "N", 15, 5  } )

t_exp_create( aDbf )

o_tmp( cPath )

return


// -----------------------------------------------
// otvori i indeksiraj pomocnu tabelu
// -----------------------------------------------
static function o_tmp( cPath )

select (248)
use ( cPath + "r_export" ) alias "r_export"
index on idfirma + idkonto tag "1"

return


// -----------------------------------------------------
// specifikacija po analitickim kontima
// -----------------------------------------------------
function spec_an()
local cSK := "N"
local nYearFrom
local nYearTo
local i
local lSilent
local lWriteKParam
local cP_path := PRIVPATH
local cT_sez := goModul:oDataBase:cSezona

private nC := 66

// formiraj pomocnu tabelu
cre_tmp( cP_path )

cIdFirma := gFirma
picBHD := FormPicL("9 " + gPicBHD, 20)

O_PARTN

__par_len := LEN(partn->id)
dDatOd := dDatDo := CTOD("")

qqKonto := space(100)

cTip:="1"

Box("",10,65)
	set cursor on
	cNula := "N"
	do while .t.
 	  @ m_x+1,m_y+6 SAY "SPECIFIKACIJA ANALITICKIH KONTA"
 	  if gNW=="D"
   		@ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 	  else
  		@ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 	  endif
 	  @ m_x+4,m_y+2 SAY "Konto " GET qqKonto  pict "@!S50"
 	  @ m_x+5,m_y+2 SAY "Datum od" GET dDatOd
 	  @ m_x+5,col()+2 SAY "do" GET dDatDo
 	  if gVar1=="0"
  	  	@ m_x+6,m_y+2 SAY "Obracun za "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+" (1/2):" GET cTip valid ctip $ "12"
 	  endif
 	  @ m_x+7,m_y+2 SAY "Prikaz sintetickih konta (D/N):" GET cSK pict "@!" valid cSK $ "DN"
 	  @ m_x+9,m_y+2 SAY "Prikaz stavki sa saldom 0 D/N" GET cNula pict "@!" valid cNula  $ "DN"
 	  cIdRJ := ""
 	  if gRJ=="D" .and. gSAKrIz=="D"
   		cIdRJ:="999999"
   		@ m_x+10,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
 	  endif
 	  
	  read
	  
	  ESC_BCR
 	  
	  aUsl1 := Parsiraj(qqKonto,"IdKonto")
 	  
	  if aUsl1 <> NIL
	  	exit
	  endif
	enddo
BoxC()

// godina od - do
nYearFrom := YEAR( dDatOd )
nYearTo := YEAR( dDatDo )
lInSez := .f.

if ( nYearTo - nYearFrom ) <> 0 .and. nYearTo = YEAR( DATE() )
	// ima vise godina, prosetaj sezone
	lInSez := .t.
endif

if cIdRj == "999999"
	cIdRj := ""
endif

if gRJ == "D" .and. gSAKrIz == "D" .and. "." $ cidrj
	cIdRj := trim(strtran(cidrj,".",""))
  	// odsjeci ako je tacka. 
	// prakticno "01. " -> sve koje pocinju sa  "01"
endif

cIdFirma := LEFT( cIdFirma, 2 )

// prodji sada kroz godine i napravi selekciju podataka ...

lSilent := .t.
lWriteKParam := .t.

for i := nYearFrom to nYearTo

	if lInSez = .t.
		// str(i) je sezona koju ganjamo...
		goModul:oDataBase:logAgain( ALLTRIM( STR( i ) ), ;
			lSilent, lWriteKParam )
		
		// otvori pomocnu tabelu opet
		o_tmp( cP_path ) 

	endif

	O_KONTO

	if gRJ == "D" .and. gSAKrIz == "D" .and. LEN( cIdRJ ) <> 0
  		SintFilt( .f., "IDRJ='" + cIdRJ + "'" )
	else
  		O_ANAL
	endif

	select anal
	set order to 1

	cFilt1 := "IdFirma==" + cm2str(cIdFirma)

	if !(empty(dDatOd) .and. empty(dDatDo))
		cFilt1 += ( ".and.DatNal>="+cm2str(dDatOd) +".and.DatNal<="+cm2str(dDatDo) )
	endif

	if aUsl1 <> ".t."
		cFilt1 += ( ".and." + aUsl1 )
	endif

	set filter to &cFilt1
	go top

	do whileSC !EOF()
 		
		cIdKonto := field->idkonto
     		
		nd := 0
		np := 0

		do whileSC !eof() .and. cIdKonto == field->idkonto
       			
			if lInSez = .t.
				
				// ako saltas po sezonama 
				// preskoci pocetna stanja...

				if field->idvn == "00"
					skip
					loop
				endif
			endif

			if cTip == "1"
         			nd += dugbhd
				np += potbhd
       			else
         			nd += dugdem
				np += potdem
       			endif
       			
			skip
     		enddo
   			
		select konto
		hseek cIdKonto
		
		select anal
   			
		if cNula == "D" .or. ROUND( nd - np, 3 ) <> 0
    			
			select r_export
			go top
			seek cIdFirma + cIdKonto

			if !FOUND()

				append blank
				
				replace field->idfirma with cIdFirma
				replace field->idkonto with cIdKonto
				replace field->kto_opis with ALLTRIM( konto->naz )
			endif

			replace field->dug with field->dug + nd
			replace field->pot with field->pot + np
			replace field->saldo with field->saldo + (nd - np)
 	
			select anal

		endif
	enddo
next

// uvijek na kraju budi u trenutnom radnom podrucju
if lInSez = .t.
	goModul:oDataBase:logAgain( cT_sez, lSilent, lWriteKParam )
	// otvori pomocnu tabelu opet...
	o_tmp( cP_path )
endif

Pic := PicBhd

START PRINT CRET

m := "------ --------------------------------------------------------- --------------------- -------------------- --------------------"
nStr:=0

nud := 0 
nup := 0

select r_export
set order to tag "1"
go top

do whileSC !eof()
	
	cSin := left( field->idkonto, 3 )

 	nkd := 0
	nkp := 0
 	
	do whileSC !eof() .and. cSin == left( field->idkonto, 3 )
     		
		cIdKonto := field->idkonto

     		if prow() == 0
			header()
		endif
     	
   		if prow() > 63 + gPStranica
			FF
			header()
		
		endif
   		
		if cNula == "D" .or. field->saldo <> 0

    			? field->idkonto, PADR( field->kto_opis, 57 )
    			
			nC := pcol() + 1
    			
			@ prow(), pcol()+1 SAY field->dug pict pic
    			@ prow(), pcol()+1 SAY field->pot pict pic
    			@ prow(), pcol()+1 SAY ( field->dug - field->pot ) ;
				pict pic
    			
			nkd += field->dug
			nkp += field->pot

   		endif 
		
		skip

 	enddo 
 	
	if prow() > 61 + gPStranica
		FF
		header()
	endif
 	
	if cSK == "D" .and. ( nkd != 0 .or. nkp != 0 )
  		
		O_KONTO
		select konto
		hseek cSin
		select r_export

		? m
  		?  "SINT.K.", cSin, ":", PADR( konto->naz, 50 )
  		@ prow(),nC       SAY nkd pict pic
  		@ prow(),pcol()+1 SAY nkp pict pic
  		@ prow(),pcol()+1 SAY nkd-nkp pict pic
  		? m

 	endif

 	nud += nkd
	nup += nkp   

enddo

if prow() > 61 + gPStranica
	FF
	header()
endif

? m
? " UKUPNO:"
@ prow(),nC       SAY nud pict pic
@ prow(),pcol()+1 SAY nup pict pic
@ prow(),pcol()+1 SAY nud-nup pict pic
? m

FF
END PRINT

closeret

return


// ------------------------------
// zaglavlje izvjestaja
// ------------------------------
static function header()
?
P_COND
?? "FIN.P:SPECIFIKACIJA ANALITI¬KIH KONTA  ZA",ALLTRIM(iif(cTip=="1",ValDomaca(),ValPomocna()))
if !(empty(dDatOd) .and. empty(dDatDo))
  ?? "  ZA NALOGE U PERIODU ",dDatOd,"-",dDatDo
endif
?? " NA DAN: "; ?? DATE()

@ prow(),125 SAY "Str:"+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,PADR(partn->naz,25),partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

select r_export
? m
? "KONTO      N A Z I V                                                           duguje            potra§uje                saldo"
? m
return


