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


// generisanje dokumenta tipa IM
function IM()
local cNule := "N"

lOsvjezi := .f.
O_KALK_PRIPR
GO TOP
IF idvd=="IM"
	IF Pitanje(,"U kalk_pripremi je dokument IM. Generisati samo knjizne podatke?","D")=="D"
    		lOsvjezi := .t.
  	ENDIF
ENDIF

O_KONTO
O_TARIFA
O_SIFK
O_SIFV
O_ROBA

cSrSort := "N"

IF lOsvjezi
 	
	cIdFirma:=gFirma
 	cIdKonto:=kalk_pripr->idKonto
 	dDatDok:=kalk_pripr->datDok

ELSE

	Box(,10,70)
 	cIdFirma:=gFirma
 	cIdKonto:=padr("1310",gDuzKonto)
 	dDatDok:=date()
	cArtikli:=SPACE(30)
	cPosition:="2"
	cCijenaTIP:="1"
	cNule := "D"
 	@ m_x+1,m_Y+2 SAY "Magacin:" GET  cIdKonto valid P_Konto(@cIdKonto)
 	@ m_x+2,m_Y+2 SAY "Datum:  " GET  dDatDok
 	@ m_x+3,m_Y+2 SAY "Uslov po grupaciji robe" 
 	@ m_x+4,m_Y+2 SAY "(prazno-sve):" GET cArtikli 
 	@ m_x+5,m_Y+2 SAY "(Grupacija broj mjesta) :" GET cPosition
 	@ m_x+6,m_Y+2 SAY "Cijene (1-VPC, 2-NC) :" GET cCijenaTIP VALID cCijenaTIP$"12"
 	@ m_x+7,m_y+2 SAY "sortirati po sifri dobavljaca :" GET cSRSort ;
		VALID cSRSort $ "DN" PICT "@!"
	@ m_x+8,m_y+2 SAY "generisati stavke sa stanjem 0 (D/N)" GET cNule ;
		PICT "@!" VALID cNule $ "DN"
	read
 	ESC_BCR
 	BoxC()
ENDIF

O_KONCIJ
O_KALK

IF lOsvjezi
	private cBrDok:=kalk_pripr->brdok
ELSE
  	private cBrDok:=SljBroj(cIdFirma,"IM",8)
ENDIF

nRbr:=0
set order to tag "3"


MsgO("Generacija dokumenta IM - "+cBrdok)

select koncij
seek trim(cIdKonto)

SELECT kalk
hseek cIdFirma+cIdKonto

do while !EOF() .and. cIdFirma+cIdKonto==field->idfirma+field->mkonto
	
	cIdRoba:=field->idRoba
	
	if !EMPTY(cArtikli) .and. AT(SubSTR(cIdRoba, 1, VAL(cPosition)), ALLTRIM(cArtikli))==0
		skip 
		loop
	endif
	
	nUlaz:=0
	nIzlaz:=0
	nVPVU:=0
	nVPVI:=0
	nNVU:=0
	nNVI:=0
	nRabat:=0
	
	do while !EOF() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+mkonto+idroba
	  	
		if dDatdok<field->datdok
	      		skip
	      		loop
	  	endif
		
		RowVpvRabat(@nVpvU, @nVpvI, @nRabat)
		
		if cCijenaTIP=="2"
			RowNC(@nNVU, @nNVI)
		endif
		
		RowKolicina(@nUlaz, @nIzlaz)
	  	
		skip
	enddo

	if cNule == "D" .or. ;
		((ROUND(nUlaz-nIzlaz,4)<>0) .or. (ROUND(nVpvU-nVpvI,4)<>0))
		
		SELECT roba
		HSEEK cIdroba
		
		SELECT kalk_pripr

		if lOsvjezi
			// trazi unutar dokumenta
			AzurPostojece(cIdFirma, cIdKonto, cBrDok, dDatDok, @nRbr, cIdRoba, nUlaz, nIzlaz, nVpvU, nVpvI, nNvU, nNvI )
		else
			// dodaj, formira se novi dokument
			DodajImStavku(cIdFirma, cIdKonto, cBrDok, dDatDok, @nRbr, cIdRoba, nUlaz, nIzlaz, nVpvU, nVpvI, nNvU, nNvI )
			
		endif
		select kalk
	
	elseif lOsvjezi
		
		// prije je ova stavka bila <>0 , sada je 0 pa je treba izbrisati
		select kalk_pripr
		SET ORDER TO TAG "3"
		GO TOP
		SEEK cIdFirma+"IM"+cBrDok+cIdRoba
		
		if FOUND()
			DELETE
		endif
		
		SELECT KALK
	
	endif

enddo


if cSRSort == "D"

	msgo("sortiram po SIFRADOB ...")
	
	select kalk_pripr

	SET RELATION TO idroba INTO ROBA
	
	index on idFirma + idvd + brdok + roba->sifradob to "SDOB"
	go top

	nRbr := 0

	do while !EOF()
		scatter()
		_rbr := RedniBroj( ++nRbr )
        my_rlock()
		gather()
        my_unlock()
		skip
	enddo
	
	msgc()

	set relation to

endif

MsgC()

my_close_all_dbf()

return



// generisanje dokumenta tipa IM razlike na osnovu postojece inventure
function gen_im_razlika()

O_KONTO

Box(,8,70)
	cIdFirma:=gFirma
 	cIdKonto:=padr("1310",gDuzKonto)
 	dDatDok:=date()
	cArtikli:=SPACE(30)
	cPosition:="2"
	cCijenaTIP:="1"
	cOldBrDok:=SPACE(8)
 	@ m_x+1,m_Y+2 SAY "Magacin:" GET  cIdKonto valid P_Konto(@cIdKonto)
 	@ m_x+2,m_Y+2 SAY "Datum:  " GET  dDatDok
 	@ m_x+3,m_Y+2 SAY "Uslov po grupaciji robe" 
 	@ m_x+4,m_Y+2 SAY "(prazno-sve):" GET cArtikli 
 	@ m_x+5,m_Y+2 SAY "(Grupacija broj mjesta) :" GET cPosition
 	@ m_x+6,m_Y+2 SAY "Cijene (1-VPC, 2-NC) :" GET cCijenaTIP VALID cCijenaTIP$"12"
 	@ m_x+8,m_Y+2 SAY "Na osnovu dokumenta " + cIdFirma + "-IM" GET cOldBrDok
	read
 	ESC_BCR
BoxC()

if Pitanje(,"Generisati inventuru magacina (D/N)","D") == "N"
	return
endif

cIdVd := "IM"

// kopiraj postojecu IM u pript
if cp_dok_pript(cIdFirma, cIdVd, cOldBrDok) == 0
	return
endif

O_TARIFA
O_SIFK
O_SIFV
O_ROBA
O_KALK_PRIPR
O_PRIPT
O_KONCIJ
O_KALK_DOKS
O_KALK

private cBrDok:=SljBroj(cIdFirma, "IM", 8)

select kalk
set order to tag "3"

nRbr:=0

MsgO("Generacija dokumenta IM - "+cBrdok)


select koncij
seek trim(cIdKonto)

SELECT kalk
hseek cIdFirma+cIdKonto

do while !EOF() .and. cIdFirma+cIdKonto==field->idfirma+field->mkonto
	
	cIdRoba:=field->idRoba
	
	select pript
	set order to tag "2"
	hseek cIdFirma+cIdVd+cOldBrDok+cIdRoba
	
	// ako sam nasao prekoci ovaj zapis
	if Found()
		select kalk
		skip
		loop
	endif
	
	select kalk	
	
	if !EMPTY(cArtikli) .and. AT(SubSTR(cIdRoba, 1, VAL(cPosition)), ALLTRIM(cArtikli))==0
		skip 
		loop
	endif
	
	nUlaz:=0
	nIzlaz:=0
	nVPVU:=0
	nVPVI:=0
	nNVU:=0
	nNVI:=0
	nRabat:=0
	do while !EOF() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+mkonto+idroba
	  	if dDatdok<field->datdok
	      		skip
	      		loop
	  	endif
		RowVpvRabat(@nVpvU, @nVpvI, @nRabat)
		if cCijenaTIP=="2"
			RowNC(@nNVU, @nNVI)
		endif
		RowKolicina(@nUlaz, @nIzlaz)
	  	skip
	enddo

	if (ROUND(nUlaz-nIzlaz,4)<>0) .or. (ROUND(nVpvU-nVpvI,4)<>0)
		SELECT roba
		HSEEK cIdroba
		SELECT kalk_pripr
		DodajImStavku(cIdFirma, cIdKonto, cBrDok, dDatDok, @nRbr, cIdRoba, nUlaz, nIzlaz, nVpvU, nVpvI, nNvU, nNvI, .t.)
			
		select kalk
	endif
enddo

MsgC()

my_close_all_dbf()

return



function AzurPostojece(cIdFirma, cIdKonto, cBrDok, dDatDok, nRbr, cIdRoba, nUlaz, nIzlaz, nVpvU, nVpvI, nNvU, nNvI, cSrSort )

if cSrSort == nil
	cSrSort := "N"
endif

if cSrSort == "D"
	set order to "SDOB"
else
	SET ORDER TO TAG "3"
endif

GO TOP
SEEK cIdFirma+"IM"+cBrDok+cIdRoba

if found()
	Scatter()
	_gkolicina:=nUlaz-nIzlaz
	_ERROR:=""
	// knjizno stannje
	_fcj:=nVpvu-nVpvi
    my_rlock() 
	Gather()
    my_unlock()
else
	GO BOTTOM
	nRbr:=VAL(ALLTRIM(field->rbr))
	Scatter()
	APPEND NCNL
	_idfirma:=cIdFirma
	_idkonto:=cIdKonto
	_mkonto:=cIdKonto
	_mu_i:="I"
	_idroba:=cIdroba
	_idtarifa:=roba->idTarifa
	_idvd:="IM"
	_brdok:=cBrdok
	_rbr:=RedniBroj(++nRbr)
	_kolicina:=nUlaz-nIzlaz
	_gkolicina:=nUlaz-nIzlaz
	_DatDok:=dDatDok
	_DatFaktP:=dDatdok
	_ERROR:=""
	_fcj:=nVpvU-nVpvI 
	if ROUND(nUlaz-nIzlaz,4)<>0
		_vpc:=ROUND((nVPVU-nVPVI)/(nUlaz-nIzlaz),3)
	else
		_vpc:=0
	endif
	if ROUND(nUlaz-nIzlaz,4)<>0
		_nc:=ROUND((nNvU-nNvI)/(nUlaz-nIzlaz),3)
	else
		_nc:=0
	endif

	Gather2()
endif
return



static function DodajImStavku(cIdFirma, cIdKonto, cBrDok, dDatDok, nRbr, cIdRoba, nUlaz, nIzlaz, nVpvU, nVpvI, nNcU, nNcI, lKolNula, cSrSort )

if cSrSort == nil
	cSrSort := "N"
endif

if lKolNula == nil
	lKolNula := .f.
endif

Scatter()
APPEND NCNL
_IdFirma:=cIdFirma
_IdKonto:=cIdKonto
_mKonto:=cIdKonto
_mU_I:="I"
_IdRoba:=cIdroba
_IdTarifa:=roba->idtarifa
_IdVd:="IM"
_Brdok:=cBrdok
_RBr:=RedniBroj(++nRbr)
_kolicina:=_gkolicina:=nUlaz-nIzlaz

if lKolNula // ako je lKolNula setuj na 0 popisanu kolicinu
	_kolicina := 0
endif

_datdok:=dDatDok
_DatFaktP:=dDatdok
_ERROR:=""
_fcj:=nVpvu-nVpvi 

if round(nUlaz-nIzlaz,4)<>0
	_vpc:=round((nVPVU-nVPVI)/(nUlaz-nIzlaz),3)
else
    _fcj := 0
	_vpc := 0
endif

if round(nUlaz-nIzlaz,4)<>0 .and. nNcI<>nil .and. nNcU<>nil
	_nc:=round((nNcU-nNcI)/(nUlaz-nIzlaz),3)
else
	_nc := 0
endif

Gather2()

return



function RowKolicina(nUlaz, nIzlaz)
  
if field->mu_i=="1" .and. !(field->idVd $ "12#22#94")
	nUlaz+=field->kolicina-field->gkolicina-field->gkolicin2
elseif field->mu_i=="1" .and. (field->idVd $ "12#22#94")
	nIzlaz-=field->kolicina
elseif field->mu_i=="5"
	nIzlaz+=field->kolicina
elseif mu_i=="3"    
	// nivelacija
endif

return


function RowVpvRabat(nVpvU, nVpvI, nRabat)

if mu_i=="1" .and. !(idvd $ "12#22#94")
	nVPVU+=vpc*(kolicina-gkolicina-gkolicin2)
elseif mu_i=="5"
	nVPVI+=vpc*kolicina
	nRabat+=vpc*rabatv/100*kolicina
elseif mu_i=="1" .and. (idvd $ "12#22#94")    
	// povrat
	nVPVI-=vpc*kolicina
	nRabat-=vpc*rabatv/100*kolicina
elseif mu_i=="3"    
	nVPVU+=vpc*kolicina
endif
return



/*! \fn RowNC(nNcU, nNcI)
 *  \brief Popunjava polja NC
 */
 
function RowNC(nNcU, nNcI)

if mu_i=="1" .and. !(idvd $ "12#22#94")
	nNcU+=nc*(kolicina-gkolicina-gkolicin2)
elseif mu_i=="5"
	nNcI+=nc*kolicina
elseif mu_i=="1" .and. (idvd $ "12#22#94")    
	// povrat
	nNcI-=nc*kolicina
elseif mu_i=="3"    
	nNcU+=nc*kolicina
endif

return


