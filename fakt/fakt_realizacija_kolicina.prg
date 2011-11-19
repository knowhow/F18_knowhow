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


#include "fakt.ch"


// ---------------------------------
// otvara potrebne tabele
// ---------------------------------
static function _o_tables()
O_FAKT
O_FAKT_DOKS
O_PARTN
O_VALUTE
O_RJ
O_SIFK
O_SIFV
O_ROBA
return


// --------------------------------------------------
// vraca matricu sa definicijom polja exp.tabele
// --------------------------------------------------
static function get_rpt_fields()
local aFields := {}

AADD(aFields, {"sifra", "C", 7, 0 })
AADD(aFields, {"naziv", "C", 40, 0 })
AADD(aFields, {"kolicina", "N", 15, 5 })
AADD(aFields, {"osnovica", "N", 15, 5 })
AADD(aFields, {"ukupno", "N", 15, 5 })

return aFields


// -------------------------------------------
// filuje export tabelu sa podacima
// -------------------------------------------
static function fill_exp_tbl( cIdSif, cNazSif, nKol, nOsn, nUk )
local nArr
nArr := SELECT()

O_R_EXP
append blank
replace field->sifra with cIdSif
replace field->naziv with cNazSif
replace field->kolicina with nKol
replace field->osnovica with nOsn
replace field->ukupno with nUk

select (nArr)

return



// ---------------------------------------
// specifikacija prodaje
// ---------------------------------------
function fakt_real_kolicina()
local nX := 1
local cExport := "N"
local lExpRpt := .f.
local lRelations := .f.
local cDDokOtpr := "D"
private cPrikaz
private cSection:="N"
private cHistory:=" "
private aHistory:={}
private cIdPartner
private nStrana:=0
private cLinija
private lGroup:=.f.
private cRelation := SPACE(4)
private cSvediJmj := "N"

// da li se koriste relacije
O_FAKT
select fakt

if fakt->(fieldpos("idrelac")) <> 0
	lRelations := .t.
endif

_o_tables()
O_OPS

// partneri po grupama
lGroup := p_group()

cIdfirma:=gFirma
dDatOd:=ctod("")
dDatDo:=date()
qqTipDok:=space(20)

Box("#SPECIFIKACIJA PRODAJE PO ARTIKLIMA",13,77)
	O_PARAMS
	RPar("c1", @cIdFirma)
	RPar("d1", @dDatOd)
	RPar("d2", @dDatDo)
	RPar("d3", @cDDokOtpr)
	qqIdRoba := SPACE(20)
	cPrikaz := "2"
	if IsPlanika()
		cK2X := "N"
		cJmjPar := "D"
		RPar("pK", @cK2X)
		RPar("pJ", @cJmjPar)
	endif
	cIdRoba := SPACE(20)
	cImeKup := SPACE(20)
	cOpcina := SPACE(20)
	qqPartn := SPACE(20)
	RPar("sk", @qqPartn)
	RPar("td", @qqTipDok)
	qqPartn := PADR(qqPartn, LEN(partn->id))
	qqIdRoba := PADR(qqIdRoba, 20)
	qqTipDok := PADR(qqTipDok, 40)

	nX := 2

	do while .t.
 		
		cIdFirma:=PADR(cIdFirma,2)
 		
		@ m_x + nX, m_y+2 SAY "RJ            " GET cIdFirma valid {|| empty(cIdFirma) .or. cIdFirma==gFirma .or. P_RJ(@cIdFirma) }
 		
		++nX
		
		@ m_x + nX, m_y+2 SAY "Tip dokumenta " GET qqTipDok pict "@!S20"
 		
		++nX
		
		@ m_x + nX, m_y+2 SAY "Od datuma "  get dDatOd
 		
		@ m_x + nX, col()+1 SAY "do"  get dDatDo
		
		++ nX

		@ m_x + nX, m_y + 2 SAY "gledati dat. (D)dok. (O)otpr. (V)valute:" GET cDDokOtpr VALID cDDokOtpr $ "DOV" PICT "@!"

		nX := nX + 3
		
		@ m_x + nX, m_y+2 SAY "Uslov po sifri partnera (prazno svi) "  get qqPartn pict "@!" valid {|| empty(qqPartn).or.P_Firma(@qqPartn)}
 		
		++nX
		
		@ m_x + nX, m_y+2 SAY "Uslov po artiklu (prazno svi) "  get qqIdRoba pict "@!"
   			
		++nX
			
		@ m_x + nX, m_y + 2 SAY "Uslov po opcini (prazno sve) "  get cOpcina pict "@!"
 		
 		
		if lRelations == .t.
			
			++ nX 
			@ m_x + nX, m_y + 2 SAY "Relacija (prazno sve):" GET cRelation
		endif
		
		if IsPlanika()
			
			++nX
			
			@ m_x + nX, m_y+2 SAY "Ne prikazuj robu K2=X "  get cK2X pict "@!" VALID cK2X$"DN"
			
			++nX
			
			@ m_x + nX, m_y+2 SAY "Filter po ROBA->JMJ=PAR "  get cJmjPar pict "@!" VALID cJmjPar$"DN"
 		
		endif
		
		if lGroup
   			
			private cPGroup := SPACE(3)
			
			++nX
			
			@ m_x + nX, m_y+2 SAY "Grupa partnera (prazno sve):" GET cPGroup VALID EMPTY(cPGroup) .or. cPGroup $ "VP #AMB#SIS#OST"
		
		endif
		
		++nX

		@ m_x + nX, m_y + 2 SAY "Svedi na jedinicu mjere ?" GET cSvediJmj VALID cSvediJmj $ "DN" PICT "@!"

		nX := nX + 2
		
		@ m_x + nX, m_y+2 SAY "Export izvjestaja u DBF?" GET cExport VALID cExport $ "DN" PICT "@!"
		
		
		read
 		
		ESC_BCR

 		aUslRB:=Parsiraj(qqIdRoba,"IDROBA","C")

		aUslOpc:=Parsiraj(cOpcina,"IDOPS","C")

 		aUslTD:=Parsiraj(qqTipdok,"IdTipdok","C")
 		
		if (aUslTD<>NIL)
			exit
		endif
		
		
	enddo

	qqTipDok:=TRIM(qqTipDok)
	qqPartn:=TRIM(qqPartn)
	qqIdRoba:=TRIM(qqIdRoba)
	qqTipDok:=TRIM(qqTipDok)
	Params2()
	WPar("c1", cIdFirma)
	WPar("d1", dDatOd)
	WPar("d2", dDatDo)
	WPar("d3", cDDokOtpr)
	WPar("vi", cPrikaz)
	WPar("td", qqTipDok)
	
	if IsPlanika()
		RPar("pK", cK2X)
		RPar("pJ", cJmjPar)
	endif
	
	select params
	use
BoxC()

// ako je export izabran
if cExport == "D"		
	lExpRpt := .t.
endif

// export dokumenta
if lExpRpt == .t.
	aExpFields := get_rpt_fields()
	t_exp_create(aExpFields)
	cLaunch := exp_report()
endif

_o_tables()

if fakt_doks->(FIELDPOS("dat_isp")) = 0
	// ako nema ovog polja, samo gledaj po dokumentima
	cDDokOtpr := "D"
endif

select fakt

private cFilter:=".t."

if (!empty(dDatOd) .or. !empty(dDatDo))

	if cDDokOtpr == "D"
		cFilter+=".and.  datdok>=" + Cm2Str(dDatOd) + " .and. datdok<="+Cm2Str(dDatDo)
	endif
endif

if (!empty(cIdFirma))
	cFilter+=" .and. IdFirma=" + Cm2Str(cIdFirma)
endif

if (!empty(qqPartn))
	cFilter+=" .and. IdPartner=" + Cm2Str(qqPartn)
endif

if (!empty(qqIdRoba))
	cFilter+=" .and. " + aUslRB
endif

if (!empty(qqTipDok))
	cFilter+=" .and. " + aUslTD
endif

if (!empty(cRelation))
	cFilter+=" .and. idrelac == " + Cm2Str(cRelation)
endif

if (cFilter=" .t. .and. ")
	cFilter:=SubStr(cFilter,9)
endif

if (cFilter==".t.")
	set filter to
else
	set filter to &cFilter 
endif

EOF CRET

START PRINT CRET

if cPrikaz=="1"
	cLinija:="---- ------ -------------------------- ------------"
else
	cLinija:="---- ----------- "+REPL("-",40)+" ------------" + ;
		" ------------ -------------"
endif

if cSvediJmj == "D"
	cLinija += " ------------"
endif

cIdPartner:=idPartner

zagl_sp_prod()

if cPrikaz=="1"
	
	set order to tag "1"
	seek cIdFirma
	nC:=0
  	nCol1:=10
	nTKolicina:=0
  	
	do while !eof() .and. IdFirma=cIdFirma
    		
		if cDDokOtpr == "O"
    			select fakt_doks
			seek fakt->idfirma + fakt->idtipdok + fakt->brdok
			if fakt_doks->dat_otpr < dDatOd .or. fakt_doks->dat_otpr > dDatDo
				select fakt
				skip
				loop
			endif
			select fakt
    		endif
    		
		if cDDokOtpr == "V"
    			select fakt_doks
			seek fakt->idfirma + fakt->idtipdok + fakt->brdok
			if fakt_doks->dat_val < dDatOd .or. fakt_doks->dat_val > dDatDo
				select fakt
				skip
				loop
			endif
			select fakt
    		endif
    
		nKolicina:=0
		cIdPartner:=IdPartner
    		
		do while !eof() .and. IdFirma=cIdFirma .and. idpartner==cIdpartner
        		
			if cDDokOtpr == "O"
    				select fakt_doks
				seek fakt->idfirma + fakt->idtipdok + ;
					fakt->brdok
				if fakt_doks->dat_otpr < dDatOd .or. ;
					fakt_doks->dat_otpr > dDatDo
					select fakt
					skip
					loop
				endif
				select fakt
    			endif
    		
			if cDDokOtpr == "V"
    				select fakt_doks
				seek fakt->idfirma + fakt->idtipdok + ;
					fakt->brdok
				if fakt_doks->dat_val < dDatOd .or. ;
					fakt_doks->dat_val > dDatDo
					select fakt
					skip
					loop
				endif
				select fakt
    			endif
			
			SELECT partn
			HSEEK fakt->idPartner
			SELECT fakt
        		if !(partn->(&aUslOpc))
           			skip 1
				loop
        		endif
      			
			nKolicina += kolicina
      			
			
			skip 1
			
		enddo

		if prow()>61	
			FF
			zagl_sp_prod()
		endif

    		select partn
		hseek cIdPartner
		select fakt
    		
		if ROUND(nKolicina,4)<>0
      			? SPACE(gnLMarg)
			?? STR(++nC,4)+".", cIdPartner, partn->naz
      			nCol1:=pcol()+1
      			@ prow(),pcol()+1 SAY STR(nKolicina,12,2)
      			nTKolicina+=nKolicina
    		endif

		if lExpRpt
			fill_exp_tbl( cIdPartner, partn->naz, nKolicina, 0 )
		endif
  	enddo
else  
	// ako je izabrano "2"
	set order to tag "3"
	go top
  	nC:=0
  	nCol1:=10
	nTKolicina:=0
	nTKolJmj := 0
	nTOsn:=0
	nTUkupno:=0
	nCounter:=0
	nMX:=0
	nMY:=0
	
	Box(,3,60)
	
	set device to screen
	@ 1+m_x, 2+m_y SAY "formiranje izvjestaja u toku..."
	nMX := 3+m_x
	nMY := 2+m_y
	set device to printer
	
	do while !eof()
	
    		nKolicina := 0
		nKolJmj := 0
		nOsn := 0
		nPojOsn := 0
		nUkupno := 0
		nPojUk := 0
   		cIdRoba := IdRoba
		
		if cDDokOtpr == "O"
    			select fakt_doks
			seek fakt->idfirma + fakt->idtipdok + fakt->brdok
			if fakt_doks->dat_otpr < dDatOd .or. fakt_doks->dat_otpr > dDatDo
				select fakt
				skip
				loop
			endif
			select fakt
    		endif
    		
		if cDDokOtpr == "V"
    			select fakt_doks
			seek fakt->idfirma + fakt->idtipdok + fakt->brdok
			if fakt_doks->dat_val < dDatOd .or. fakt_doks->dat_val > dDatDo
				select fakt
				skip
				loop
			endif
			select fakt
    		endif
    
		if IsPlanika()
			select roba
			set order to tag "ID"
			hseek cIdRoba
			select fakt
		endif
		
		// ako je planika i roba.k2=X preskoci
		if IsPlanika() .and. cK2X == "D"
			if LEFT(roba->k2, 1) == "X"
				skip
				loop
			endif
		endif
    		// ako je planika i roba.jmj<>PAR preskoci
		if IsPlanika() .and. cJmjPar == "D"
			if roba->jmj <> "PAR"
				skip
				loop
			endif
		endif
    		
		do while !eof() .and. idRoba==cIdRoba
        			
			if cDDokOtpr == "O"
    				select fakt_doks
				seek fakt->idfirma + fakt->idtipdok + ;
					fakt->brdok
				if fakt_doks->dat_otpr < dDatOd .or. ;
					fakt_doks->dat_otpr > dDatDo
					select fakt
					skip
					loop
				endif
				select fakt
    			endif
    		
			if cDDokOtpr == "V"
    				select fakt_doks
				seek fakt->idfirma + fakt->idtipdok + ;
					fakt->brdok
				if fakt_doks->dat_val < dDatOd .or. ;
					fakt_doks->dat_val > dDatDo
					select fakt
					skip
					loop
				endif
				select fakt
    			endif
			
			SELECT partn
			HSEEK fakt->idPartner
			SELECT fakt
        		if !(partn->(&aUslOpc))
           			skip 1
				loop
        		endif
			
			if lGroup .and. !EMPTY(cPGroup)
				cPartn := fakt->idpartner
				SELECT partn
				hseek cPartn
				SELECT fakt
				if !p_in_group(cPartn, cPGroup)
					skip
					loop
				endif
			endif
     			
			nKolicina += kolicina
			
			if cSvediJmj == "D"
				
				cJmj := ""
				nKolJmj += SJMJ(kolicina, idroba, @cJmj )
			
			endif
			
			// pojedinacna osnova
			nPojOsn := ROUND( kolicina * Cijena * (1-Rabat/100) * (1+Porez/100) ,ZAOKRUZENJE)
			
			// ukupni iznos sa PDV
			nPojUk := nPojOsn

			// ako je rijec o MP dokumentima
			// potrebno je izvuci osnovicu iz iznosa
			// jer se radi o cijeni sa PDV-om

			if field->idtipdok $ "11#13#23"
			
				nPojOsn := _osnovica( field->idtipdok, ;
					field->idpartner, nPojOsn )
			
			endif
			
			// ako je rijec o VP dokumentima, treba izracunati
			// ukupno sa PDV

			if field->idtipdok $ "10#12"
				nPojUk := _uk_sa_pdv( field->idtipdok, ;
					field->idpartner, nPojUk )
			endif

			// dodaj na total
			nOsn += nPojOsn
			nUkupno += nPojUk

			++ nCounter
			
			// ispisi progres u box-u
			if nCounter % 50 == 0
				set device to screen
				@ nMX, nMY SAY "obradjeno " + ALLTRIM(STR(nCounter)) + " zapisa"
				set device to printer
			endif
      			
			skip 1
    		enddo
		
    		if prow()>61
			FF
			zagl_sp_prod()
		endif
    		
		select roba
		hseek cIdRoba
		select fakt
    		
		if ROUND(nKolicina,4)<>0
      			? SPACE(gnLMarg)
			?? STR(++nC,4)+".", cIdRoba, LEFT(roba->naz,40)
      			nCol1:=PCol()+1
      			@ prow(),PCol()+1 SAY STR(nKolicina,12,2)
      			if cSvediJmj == "D"
      				@ prow(),PCol()+1 SAY STR(nKolJmj,12,2)
				nTKolJmj += nKolJmj
			endif
			
			@ prow(),PCol()+1 SAY STR(nOsn,12,2)
			@ prow(),PCol()+1 SAY STR(nUkupno,12,2)
      			
			nTKolicina += nKolicina
			nTOsn += nOsn
			nTUkupno += nUkupno
    		endif
		
		if lExpRpt
			fill_exp_tbl( cIdRoba, LEFT(roba->naz, 40), ;
					nKolicina, nOsn, nUkupno )
		endif
		
  	enddo

	BoxC()
	
endif

if prow()>59
	FF
	zagl_sp_prod()
endif

? space(gnLMarg)
?? cLinija
? space(gnLMarg)
?? " Ukupno"
@ prow(),nCol1 SAY STR(nTKolicina,12,2)
if cSvediJmj == "D"
	@ prow(),pcol()+1 SAY STR(nTKolJmj,12,2)
endif
@ prow(),pcol()+1 SAY STR(nTOsn,12,2)
@ prow(),pcol()+1 SAY STR(nTUkupno,12,2)
? space(gnLMarg)
?? cLinija

// ukini filter
set filter to  

if lExpRpt
	fill_exp_tbl( "UKUPNO", "", nTKolicina, nTOsn, nTUkupno )
endif

FF
END PRINT

// lansiraj export....
if lExpRpt
	tbl_export( cLaunch )
endif

return


// ---------------------------------------------
// zaglavlje izvjestaja specifikacija prodaje 
// ---------------------------------------------
static function zagl_sp_prod()
?
P_12CPI

?? SPACE(gnLMarg)
IspisFirme(cIdFirma)

?

set century on

P_12CPI

if cPrikaz=="1"
	? SPACE(gnLMarg)
	?? "Specifikacija prodaje po partnerima na dan",date(),space(8),"Strana:",STR(++nStrana,3)
else
  	? SPACE(gnLMarg)
	?? "Specifikacija prodaje po artiklima na dan",date(),space(8),"Strana:",STR(++nStrana,3)
endif

? SPACE(gnLMarg)
?? "      za period:",dDatOd," - ",dDatDo

? SPACE(gnLMarg)
?? "Izvjestaj za tipove dokumenata : ",TRIM(qqTipDok)

if !EMPTY(cRelation)
	? SPACE(gnLMarg)
	?? "Relacija : " + cRelation
endif

if cPrikaz=="2" .and. !EMPTY(qqPartn)
	? SPACE(gnLMarg)
	?? "Partner: " + qqPartn + " - " + Ocitaj(F_PARTN, qqPartn, "naz")
endif

if !empty(cOpcina)
	? SPACE(gnLMarg)
	?? "Opcine: " + TRIM(cOpcina)
endif

if lGroup .and. !EMPTY(cPGroup)
	? SPACE(gnLMarg)
	?? "Grupa partnera: " + TRIM(cPGroup), " - " + gr_opis(cPGroup)
endif

set century off

P_COND

? SPACE(gnLMarg)
?? cLinija

if cPrikaz=="1"
	? SPACE(gnLMarg)
	?? " Rbr  Sifra     Partner                  Kolicina                           "
else
	? SPACE(gnLMarg)
	?? " Rbr  Sifra      " + ;
		PADC("Naziv", 40) + ;
		"   Kolicina   " + ;
		if(cSvediJmj == "D", "  Kol.po jmj ", "" )+ ;
		" Uk.bez PDV " + ;
		"  Uk.sa PDV "
endif

? SPACE(gnLMarg)
?? "                                                                            "
? SPACE(gnLMarg)
?? cLinija

return


