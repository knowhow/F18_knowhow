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


#include "f18.ch"


static cKontrolnaTabela:=""
static lCekaj:=.t.


// ---------------------------------------------
// Stanje prodajnog mjesta
// ---------------------------------------------
function pos_stanje_artikala_pm( cD, cS )
local nStanje
local nSign:=1
local cSt
local nVrijednost
local nCijena:=0
local cRSdbf
local cVrstaRs
local fZaklj
// ovo su ulazni parametri
private cDat := cD
private cSmjena := cS
private cIdDio:=SPACE(2)
private cIdOdj:=SPACE(2)
private cRoba:=SPACE(60)
private cLM:=""
private nSir:=40
private nRob:=29
private cNule:="N"
private cKontrolisi

cKontrolisi:="N"
cK9:=SPACE(3)
cVrstaRs:=gVrstaRs

if ( PCOUNT() == 0 )
	fZaklj := .f.
else
	fZaklj := .t.
endif

if !fZaklj
	private cDat:=gDatum
	private cSmjena:=" "
endif

O_KASE
O_ODJ
O_DIO
O_SIFK
O_SIFV
O_ROBA
O_POS

cIdPos:=gIdPos

private cUkupno:="N"
private cMink:="N"

if fZaklj
	// kod zakljucenja smjene
	aUsl1:={}
else

	cIdodj:="R "
	cIdPos:=gIdPos
	aNiz:={}
	
	if cVrstaRs<>"K"
		AADD (aNiz, {"Prodajno mjesto (prazno-svi)","cIdPos","cidpos='X'.or.empty(cIdPos).or. P_Kase(@cIdPos)","@!",})
	endif
	if gVodiOdj=="D"
		AADD(aNiz,{"Roba/Sirovine","cIdOdj", "cidodj $ 'R S '","@!",})
	endif
	if gModul=="HOPS"
		if gPostDO=="D"
			AADD (aNiz, {"Dio objekta","cIdDio", "Empty (cIdDio).or.P_Dio(@cIdDio)","@!",})
		endif
	endif 
	AADD (aNiz, {"Artikli  (prazno-svi)","cRoba",,"@!S30",})
	AADD (aNiz, {"Izvjestaj se pravi za datum","cDat",,,})
	if gVSmjene=="D"
		AADD (aNiz, {"Smjena","cSmjena",,,})
	endif
	AADD (aNiz, {"Stampati artikle sa stanjem 0", "cNule","cNule$'DN'","@!",})
	AADD (aNiz, {"Prikaz kolone ukupno D/N ", "cUkupno","cUkupno$'DN'","@!",})
	AADD (aNiz, {"Prikaz samo kriticnih zaliha (D/N/O) ?", "cMinK","cMinK$'DNO'","@!",})
	AADD (aNiz, {"Analiza - kontrolna tabela ?", "cKontrolisi","cKontrolisi$'DN'","@!",})
	AADD (aNiz, {"Uslov po K9", "cK9",,,})
	do while .t.
		if !VarEdit( aNiz, 10,5,13+LEN(aNiz),74,'USLOVI ZA IZVJESTAJ "STANJE ODJELJENJA"',"B1")
			CLOSERET
		endif
		aUsl1:=Parsiraj(cRoba,"IdRoba","C")
		if aUsl1<>NIL
			exit
		else
			Msg("Kriterij za artikal nije korektno postavljen!")
		endif
	enddo
endif

if cMink=="O"
	cNule:="D"
endif

cU:=R_U
cI:=R_I
cRSdbf:="ROBA"

private cZaduzuje:="R"

if cIdOdj="S "
	cZaduzuje:="S"
	cU:=S_U
	cI:=S_I
	cRSdbf:="SIROV"
endif

if cVrstaRs=="S"
	cLM:=SPACE(5)
	nSir:=80
	nRob:=40
endif


SELECT POS
if index_tag_num("5") == 0
	use
	CREATE_INDEX("5","IdPos+idroba+DTOS(Datum)", KUMPATH+"POS")
	select (F_POS)
	use
	O_POS
endif

cFilt:=""

if EMPTY(cIdPos)
	if gModul=="HOPS"
		SET ORDER TO TAG "5"
	else 
		
		//"2": "IdOdj+idroba+DTOS(Datum)"
		SET ORDER TO TAG "2"  
		// 1 artikal, 1 stavka u izvjestaju (samo TOPS)
	endif 
else
	SET ORDER TO TAG "5"
	cFilt:="IDPOS=='"+cIdPos+"'"
endif

if LEN(aUsl1)>0
	if EMPTY(cFilt)
		cFilt:=aUsl1
	else
		cFilt+=".and."+aUsl1
	endif
endif


if !EMPTY(cFilt)
	SET FILTER TO &cFilt
endif

go top

nH:=0

if !fZaklj
	
	START PRINT CRET
	
	Zagl(cIdOdj,cDat, cVrstaRs)

endif

Podvuci(cVrstaRs)

nVrijednost:=0
_n_rbr := 0
_total_pst := 0
_total_ulaz := 0
_total_izlaz := 0
_total_stanje := 0

do while !eof()

	nStanje:=0
	nPstanje:=0
	nUlaz:=nIzlaz:=0
	cIdRoba:=POS->IdRoba

	//
	//pocetno stanje - stanje do
	//

	nSlogova:=0

	do while !eof() .and. POS->IdRoba==cIdRoba .and. (POS->Datum<cDat .or. (!Empty(cSmjena) .and. POS->Datum==cDat .and. POS->Smjena<cSmjena))
		
		SELECT (cRSdbf)
		HSEEK cIdRoba
		if (FIELDPOS("K9"))<>0 .and. !Empty(cK9)
			if (field->k9 <> cK9)
				select pos
				skip
				loop
			endif
		endif
		SELECT POS
		
		if !Empty (cIdDio) .and. POS->IdDio <> cIdDio
			skip
			loop
		endif
		if (Klevel>"0".and.pos->idpos="X").or.(!empty(cIdPos).and.pos->IdPos<>cIdPos)
			// (POS->IdPos="X".and.AllTrim(cIdPos)<>"X").or.;// ?MS
			skip
			loop
		endif
		//
		if cZaduzuje=="S".and.pos->idvd$"42#01"
			skip
			loop  // racuni za sirovine - zdravo
		endif

		if cZaduzuje=="R".and.pos->idvd=="96"
			skip
			loop   // otpremnice za robu - zdravo
		endif
		
		++nSlogova
		
		if POS->idvd$"16#00"
			nPstanje+=POS->Kolicina
		elseif POS->idvd $ "IN#NI#"+DOK_IZLAZA
			do case
				case POS->IdVd == "IN"
                    nPstanje -= ( pos->kolicina - pos->kol2 )
				case POS->IdVd=="NI"
				
				otherwise // 42#01
					nPstanje-=POS->Kolicina
			endcase
		endif
		skip
	enddo

	//
	//realizacija specificiranog datuma/smjene
	//
	do while !eof() .and. POS->IdRoba==cIdRoba .and. (POS->Datum==cDat .or. (!Empty(cSmjena) .and. POS->Datum==cDat .and. POS->Smjena<cSmjena))
		
		SELECT (cRSdbf)
		HSEEK cIdRoba
		if (FIELDPOS("K9"))<>0 .and. !Empty(cK9)
			if (field->k9 <> cK9)
				select pos
				skip
				loop
			endif
		endif
		SELECT POS
		
		if !Empty(cIdDio) .and. POS->IdDio<>cIdDio
			skip
			loop
		endif
		if cZaduzuje=="S" .and. pos->idvd$"42#01"
			skip
			loop  
			// racuni za sirovine - zdravo
		endif
		if cZaduzuje=="R" .and. pos->idvd=="96"
			skip
			loop   
			// otpremnice za robu - zdravo
		endif
		if (Klevel>"0" .and. pos->idpos="X") .or. (!empty(cIdPos) .and. pos->IdPos<>cIdPos)
			// (POS->IdPos="X".and.AllTrim(cIdPos)<>"X").or.;//?MS
			skip
			loop
		endif
		//
		++nSlogova
		if POS->idvd $ DOK_ULAZA
			nUlaz+=POS->Kolicina
		elseif POS->idvd $ "IN#NI#"+DOK_IZLAZA
			do case
				case POS->IdVd=="IN"
			        nIzlaz += ( pos->kolicina - pos->kol2 )
				case POS->IdVd=="NI"
					nIzlaz += 0
				otherwise  
					nIzlaz += POS->Kolicina
			endcase
		endif
		skip
	enddo

	//
	//stampaj
	//

	nStanje := nPstanje + ( nUlaz - nIzlaz )

	IF Round(nStanje,4)<>0 .or. cNule=="D" .and. !(nPstanje==0.and.nUlaz==0.and.nIzlaz==0)
		SELECT (cRSdbf)
		HSEEK cIdRoba
		if (FIELDPOS("K9"))<>0 .and. !Empty(cK9)
			if (field->k9 <> cK9)
				select pos
				skip
				loop
			endif
		endif
		
		if (FIELDPOS("MINK"))<>0
			nMink:=roba->mink
		else
			nMink:=0
		endif
		
			
		if ((cMink<>"D" .and. (cNule=="D".or.round(nStanje,4)<>0)) .or. (cMink=="D" .and. nMink<>0 .and. (nStanje-nMink)<0)) .and. !(cMink=="O" .and. nMink==0 .and. round(nStanje,4)==0)

			nCijena1 := pos_get_mpc()

            ? cLM + PADL( ALLTRIM( STR( ++ _n_rbr, 5 ) ), 5 ) + "."
			?? " " + cIdRoba, PADR( Naz, nRob ) + " "

			//
			// VRIJEDNOST = CIJENA U SIFRARNIKU * STANJE KOMADA
			nVrijednost += nStanje * nCijena1

			SELECT POS
		
			? cLM + SPACE(6)
		
        	?? STR(nPstanje,9,3)
		
        	if round(nUlaz,4)<>0
				?? " "+STR(nUlaz,9,3)
			else
				?? SPACE(10)
			endif
		
        	if Round(nIzlaz,4)<>0
				?? " "+STR(nIzlaz,9,3)
			else
				?? SPACE(10)
			endif
		
        	?? " " + STR( nStanje, 10, 3 )
	
            ?? " " + STR( nCijena1, 10, 3 )
	
            ?? " " + STR( nStanje * nCijena1, 10, 3 )

        	if cMink<>"N".and.nMink>0
				? PADR(IF(cMink=="O".and.nMink<>0.and.(nStanje-nMink)<0,"*KRITICNO STANJE !*",""),19)
				?? "  min.kolic:"+STR(nMink,9,3)
			endif

            _total_pst += nPStanje
            _total_ulaz += nUlaz
            _total_izlaz += nIzlaz
            _total_stanje += nStanje

		endif
	endif

	SELECT POS
	// preko zadanog datuma
	do while !eof() .and. POS->IdRoba == cIdRoba
		skip
	enddo

enddo

if cVrstaRs<>"S"

	Podvuci(cVrstaRs)

	? "Ukupno stanje zaduzenja: "
    ? cLM + SPACE(5), ;
        STR( _total_pst, 10, 2 ), ;
        STR( _total_ulaz, 10, 2 ), ;
        STR( _total_izlaz, 10, 2 ), ;
        STR( _total_stanje, 10, 2 ), ;
        STR( 0, 10, 2 ), ;
        STR( nVrijednost, 10, 2 )

	Podvuci(cVrstaRs)
	
endif

FF
END PRINT

close all
return



/*! \fn Podvuci(cVrstaRs)
 *  \brief Podvlaci red u izvjestaju stanje odjeljenja/dijela objekta
 */
 
function Podvuci(cVrstaRs)
?
?? REPL("-", 6), REPL ("-",9), REPL ("-",9), REPL ("-",9), REPL ("-",10), REPL("-", 10), REPL("-", 10)
return


/*! \fn Zagl(cIdOdj,dDat, cVrstaRs)
 *  \brief Ispis zaglavlja izvjestaja stanje odjeljenja/dijela objekta
 */

static function Zagl(cIdOdj,dDat, cVrstaRs)

if dDat==NIL
  dDat:=gDatum
endif

?
ZagFirma()

P_10CPI
? PADC("STANJE ODJELJENJA NA DAN "+FormDat1(dDat),nSir)
? PADC("-----------------------------------",nSir)

IF cVrstaRs <> "K"
  ? cLM+"Prod. mjesto:"+IIF (Empty(cIdPos),"SVE",Ocitaj(F_KASE,cIdPos,"Naz"))
ENDIF
if gvodiodj=="D"
  ? cLM+"Odjeljenje : "+ cIdOdj+"-"+RTRIM(Ocitaj(F_ODJ, cIdOdj,"naz"))
endif
if gModul=="HOPS"
  IF gPostDO == "D"
    ? cLM+"Dio objekta: "+ IIF (Empty(cIdDio), "SVI", cIdDio+"-"+RTRIM(Ocitaj(F_DIO, cIdDio,"naz")))
  EndIF
endif 

? cLM + "Artikal    : "+IF(EMPTY(cRoba),"SVI",RTRIM(cRoba))
?
? cLM + SPACE(6) + PADR ("Sifra", 10), PADR ("Naziv artikla", nRob) + " "
? cLM
?? "R.broj", "P.stanje ", PADC ("Ulaz", 9), PADC ("Izlaz", 9), PADC ("Stanje", 10), PADC("Cijena", 10), PADC("Total", 10)
? cLM

return


// -------------------------------------------------------------------
// -------------------------------------------------------------------
static function AnalizirajKontrolnuTabelu(cIdRoba, nStanje, nMpv)
local nArea

SELECT (F_KONTROLA)

cKontrolnaTabela:="c:/sigma/kontrola.dbf"

if !USED()
	USE (cKontrolnaTabela)
	SET ORDER TO TAG "ID"
endif

nArea:=SELECT()
SEEK cIdRoba

if FOUND()
	if lCekaj
		if (nMpv<>kontrola->mpv) .or. (nStanje<>kontrola->kolicina)
			MsgBeep(cIdRoba+"#kontrola (stanje, mpv):"+STR(kontrola->kolicina,10,2)+"/"+STR(kontrola->mpv,10,2)+"#pos (stanje, mpv):"+STR(nStanje,10,2)+"/"+STR(nMpv,10,2))
			if (LASTKEY()==K_ESC)
				lCekaj:=.f.
			endif
		endif
	endif
endif

SELECT(nArea)
return
