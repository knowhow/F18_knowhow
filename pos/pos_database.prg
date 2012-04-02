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

// --------------------
// otvori baze potrebne za 
// pregled racuna
// --------------------
function o_pregled()

SELECT F_ODJ
if !used()
	O_ODJ
endif

SELECT F_OSOB
if !used()
	O_OSOB
endif

SELECT F_VRSTEP
if !used()
	O_VRSTEP
endif

SELECT F_POS
if !used()
	O_POS
endif

SELECT F_POS_DOKS
if !used()
	O_POS_DOKS
endif

SELECT F_DOKSPF
if !used()
	O_DOKSPF
endif

SELECT F_ROBA
if !used()
	O_ROBA
endif

SELECT F_TARIFA
if !used()
	O_TARIFA
endif

SELECT F_SIFK
if !used()
	O_SIFK
endif

SELECT F_SIFV
if !used()
	O_SIFV
endif

select pos_doks

return


// -----------------------------------------------
// otvori tabele potrebne za unos stavki u racun
// ------------------------------------------------
function o_edit_rn()

select F__POS
if !used()
    O__POS
endif

select F__PRIPR
if !used()
    O__POS_PRIPR
endif

select k2c
if !used()
    O_K2C
endif

select mjtrur
if !used()
    O_MJTRUR 
endif

select uredj
if !used()
    O_UREDJ 
endif

o_pregled()

return


 
function PostojiPromet()

O_POS_DOKS

select pos_doks

if reccount2()==0
	use
   	return .f.
else
   	use
   	return .t.
endif

return


/*! \fn PostojiDokument(cTipDok, dDate)
 *  \brief Provjerava da li postoje dokumenti cTipDok na datum dDate
 *  \param cTipDok - tip dokumenta, npr "42" - racun, "19" - nivelacija
 *  \param dDate - datum dokumenta
 *  \return .t. ako postoji, .f. ako ne postoji
 */
function PostojiDokument(cTipDok, dDate)
*{
O_POS_DOKS
select pos_doks
set order to tag "2"
seek cTipDok + DTOS(dDate)

if Found()
	return .t.
else
	return .f.
endif

return
*}


/*! \fn StanjeRoba(_IdPos,_IdRoba)
 *  \brief
 *  \param _IdPos
 *  \param _IdRoba
 *  \return nStanje
 */
 
function StanjeRoba(_IdPos, _IdRoba)
*{

local nStanje

select pos
//"5", "IdPos+idroba+DTOS(Datum)", KUMPATH+"POS")
set order to tag "5"  
seek _IdPos+_idroba

nStanje:=0

do while !eof() .and. pos->(IdPos+IdRoba)==(_IdPos+_IdRoba)
	if POS->idvd $ "16#00"
        	nStanje += POS->Kolicina
        elseif Pos->idvd $ "IN"
          	nStanje += POS->Kol2 - POS->Kolicina
        elseif POS->idvd $ "42#01#96"
          	nStanje -= POS->Kolicina
        endif
        SKIP
enddo
select pos
set order to tag "1"
return nStanje


 
function OpenPos()

close all

O_PARTN
O_VRSTEP
O_DIO
O_ODJ
O_KASE
O_OSOB
set order to tag "NAZ"

O_TARIFA 
O_VALUTE
O_SIFK
O_SIFV
O_ROBA
O__POS
O_POS_DOKS
O_POS
return


function o_pos_sifre()
close all
O_KASE
O_UREDJ
O_ODJ
O_ROBA
O_TARIFA
O_VRSTEP
O_VALUTE
O_PARTN
O_OSOB
O_STRAD
O_SIFK
O_SIFV
return


 
function O_InvNiv()
close all

O_UREDJ
O_MJTRUR
O_ODJ
O_DIO

O_SIFK
O_SIFV

O_SAST
O_ROBA

O_POS_DOKS
O_POS
O__POS
O_PRIPRZ
return



 
function OpenZad()
close all

O_UREDJ
O_MJTRUR
O_ODJ  
O_DIO
O_TARIFA
O_POS_DOKS
O_POS
O__POS
O_PRIPRZ
O_SIFK
O_SIFV
O_ROBA 
return


 
function ODbRpt()

close all

O_OSOB
O_SIFK
O_SIFV
O_VRSTEP 
O_ROBA
O_ODJ 
O_DIO
O_KASE
O_POS
O_POS_DOKS

return


 
function o_pos_narudzba()

close all

if gPratiStanje $ "D!"
	O_POS
endif

O_MJTRUR 
O_UREDJ 
O_ODJ 
O_K2C
O_ROBA
O_SIFK
O_SIFV
O__POS_PRIPR 
O__POS

return



function O_StAzur()
close all
O__POS
O_ODJ
O_VRSTEP
O_PARTN
O_OSOB
O_VALUTE
O_TARIFA
O_POS_DOKS
O_POS
O_ROBA
return


function RacIznos(cIdPos,cIdVD,dDatum,cBrDok)

if cIdPos==nil
	cIdPos:=pos_doks->IdPos
  	cIdVD:=pos_doks->IdVD
  	dDatum:=pos_doks->Datum
  	cBrDok:=pos_doks->BrDok
endif

nIznos:=0
SELECT POS
Seek2(cIdPos+cIdVd+dtos(dDatum)+cBrDok)
do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+cIdVd+dtos(dDatum)+cBrDok)
	nIznos+=POS->(Kolicina * Cijena)
  	SKIP
end
select pos_doks
return (nIznos)



function DokIznos(lUI)
local cRet:=SPACE(13)
local l_u_i
local nIznos:=0
local cIdPos, cIdVd, cBrDok
local dDatum

select pos_doks

cIdPos:=pos_doks->idPos
cIdVd:=pos_doks->idVd
cBrDok:=pos_doks->brDok
dDatum:=pos_doks->datum

if ((lUI==NIL) .or. lUI)
	// ovo su ulazi ...
    	if pos_doks->IdVd $ VD_ZAD+"#"+VD_PCS+"#"+VD_REK
      		SELECT pos
			set order to tag "1"
			go top
      		SEEK cIdPos+cIdVd+DTOS(dDatum)+cBrDok
      		do while !eof().and.pos->(IdPos+IdVd+DTOS(datum)+BrDok)==cIdPos+cIdVd+DTOS(dDatum)+cBrDok
        		nIznos+=pos->kolicina*pos->cijena
        		SKIP
      		enddo
		if pos_doks->idvd==VD_REK
			nIznos:=-nIznos
		endif
    	endif
	
endif

if ((lUI==NIL) .or. !lUI)
	// ovo su, pak, izlazi ...
    	if pos_doks->IdVd $ VD_RN+"#"+VD_OTP+"#"+VD_RZS+"#"+VD_PRR+"#"+"IN"+"#"+"IN"

      		SELECT pos
			set order to tag "1"
			go top
      		SEEK cIdPos+cIdVd+DTOS(dDatum)+cBrDok
      		do while !eof() .and. pos->(IdPos+IdVd+DTOS(datum)+BrDok)==cIdPos+cIdVd+DTOS(dDatum)+cBrDok
        		do case
          			case pos_doks->IdVd=="IN"
            				nIznos+=(pos->kol2-pos->kolicina)*pos->cijena
          			case pos_doks->IdVd==VD_NIV
            				nIznos+=pos->kolicina*(pos->nCijena-POS->Cijena)
          			otherwise
            				nIznos+=pos->kolicina*pos->cijena
        		endcase
        		SKIP
      		enddo
    	endif
endif

select pos_doks
cRet:=STR(nIznos,13,2)

return (cRet)




function _Pripr2_POS(cIdVrsteP)
local cBrdok
local nTrec := 0
local nPopust

// prebacit ce u _POS sadrzaj _PRIPR

if cIdVrsteP == nil
	cIdVrsteP := ""
endif

nPopust := 0

select _pos_pripr
go top

cBrdok:=brdok

do while !eof()
	
	Scatter()
	
	select _pos
  	append blank
  	
	if (gRadniRac=="N")
   		// u _PRIPR mora biti samo jedan dokument!!!
		_brdok:=cBrDok   
  	endif

	_IdVrsteP := cIdVrsteP
  	
	if ( IsPlanika() .and. nPopust > 0 ;
		.and. gPopust == 0 .and. gPopIznP == 0 ;
		.and. !gClanPopust )
		
		_ncijena := ROUND( _cijena * nPopust / 100, gPopDec )
	endif
	
	gather()
  	
	select _pos_pripr
  	skip
enddo

select _pos_pripr
Zapp () 
__dbPack()
return


  

function BrisiDok(cIdPos,cIdVD, dDatum, cBrojR)
local cDatum
local _rec

select pos
cDatum := DTOS( dDatum )

set order to tag "1"

seek cIdPos+cIDVD+cDatum+cBrojR

do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+cIdVD+cDatum+cBrojR)
	skip
	nTTR:=recno()
	skip -1
    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( ALIAS(), _rec )
    go nTTR
enddo

select pos_doks
_rec := dbf_get_rec()
delete_rec_server_and_dbf( ALIAS(), _rec )

return


/*! \fn IspraviDV(cLast, dOrigD, dDatum, cVrijeme, cBroj)
 *  \brief Ispravi datum i vrijeme racuna
 *  \param cLast
 *  \param dOrigD
 *  \param dDatum
 *  \param cVrijeme
 *  \param cNBrDok - novi broj, ako je nil ne mjenjaj broj
 */
 
function IspraviDV(cLast, dOrigD, dDatum, cVrijeme, cNBrDok)
*{
local cBrDok
local fSvi

fSvi:=.f.
if (cNBrDok==nil) .and. Pitanje(,"Zelite li ispravku datuma SVIH RACUNA datuma " + dtoc(dOrigD) + " ?", "N")=="D"
	fSvi:=.t.
endif
cIdPos:=field->idPos 
cIdVd:=field->idVd
cBrDok:=field->brDok


select pos_doks
// prodji kroz sve racune ..."

do while (!EOF() .and. field->datum==dOrigD .and. field->idPos==cIdPos .and. field->idVd==cIdVd)
	
	cIdPos:=field->idPos 
	cIdVd:=field->idVd
	cBrDok:=field->brDok

	SKIP
        nTDRec:=recno()
        SKIP -1
        SELECT POS

	if (cNBrDok==nil) .and. IsDocExists(cIdPos, cIdVd, dDatum, cBrDok)
		// kada mjenjam broj dokumenta interesuje cBrDok
		MsgBeep("Vec postoji racun pod istim brojem "+cIdPos+"-"+cIdVd+"-"+cBrDok+"/"+DTOC(dDatum))
		go nTDRec
		loop
	endif
	

	if (cNBrDok<>nil) .and. IsDocExists(cIdPos, cIdVd, dDatum, cNBrDok)
		// kada mjenjam broj dokumenta trazi cNBrDok
		MsgBeep("Vec postoji racun pod brojem "+cIdPos+"-"+cIdVd+"-"+cNBrDok+"/"+DTOC(dDatum))
		go nTDRec
		loop
	endif


	// POS
        SELECT pos
	seek cIdPos+cIdVd+DTOS(dOrigD)+cBrDok
        do while (!EOF() .and. cIdPos+cIdVd+DTOS(dOrigD)+cBrDok==IdPos+IdVd+DTOS(datum)+BrDok)
	        skip
		nTTTrec:=recno()
		skip -1
                if cLast $ "DV"
                	REPLACE Datum with dDatum
			REPLSQL Datum WITH dDatum
                endif
		
                if ((cNBrDok<>nil) .and. (cBrDok<>cNBrDok))
			REPLACE brDok WITH cNBrDok
			REPLSQL brDok WITH cNBrDok
		endif
		
		go nTTTRec
        enddo

	// DOKS
        select pos_doks
	seek cIdPos+cIdVd+DTOS(dOrigD)+cBrDok
        if cLast $ "SV"
        	REPLACE Vrijeme with cVrijeme
        	REPLSQL Vrijeme with cVrijeme
        endif
        if cLast $ "DV"
        	REPLACE Datum with dDatum
        	REPLSQL Datum with dDatum
        endif
        if ((cNBrDok<>nil) .and. (cBrDok<>cNBrDok))
		REPLACE brDok WITH cNBrDok
		REPLSQL brDok WITH cNBrDok
	endif
	
        UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"0000", 'WRITE')
        if !fSvi
		exit
	endif
        go nTDRec
enddo

return 1


/*! \fn AzurRacuna(cIdPos,cStalRac,cRadRac,cVrijeme,cNacPlac,cIdGost)
 *  \brief Azuriranje racuna ( _POS->POS, _POS->DOKS )
 *  \param cIdPos
 *  \param cStalRac    - prilikom azuriranja daje se broj cStalRac
 *  \param cRadRac     - racun iz _POS.DBF sa brojem cRadRac se prenosi u POS, DOKS
 *  \param cVrijeme
 *  \param cNacPlac
 *  \param cIdGost
 */
 
function AzurRacuna(cIdPos, cStalRac, cRadRac, cVrijeme, cNacPlac, cIdGost)
local cDatum
local nStavki
local _rec, _append
local _cnt := 0

lNaX:=.f.

o_stazur()

if IzFmkIni("TOPS","PitanjePrijeAzuriranja","N",EXEPATH)=="D"
	lNaX:=(Pitanje(,"Azurirati racun? (D/N)","D")=="N")
endif

if (cNacPlac==nil)
	cNacPlac:=gGotPlac
endif
if (cIdGost==nil)
	cIdGost:=""
endif

SELECT _POS
set order to tag "1"
SEEK cIdPos + "42" + dtos(gDatum) + cRadRac

set_global_memvars_from_dbf()

select pos_doks

_BrDok := cStalRac
_Vrijeme := cVrijeme
_IdVrsteP := cNacPlac
_IdGost := cIdGost
_IdOdj := SPACE( LEN( _IdOdj ))
_M1 := OBR_NIJE

//Append Blank  radi mreza ne idemo na ovu varijantu!
set order to tag "1"
seek cIdPos + "42" + dtos(gdatum) + cStalRac

if ( alltrim(field->idRadnik) != "////" )
	MsgBeep("Nesto nije u redu zovite servis - radnik bi morao biti //// !!!")
endif

// ubaci zapis u tabelu
_append := get_dbf_global_memvars()

// transakcija...
sql_table_update( nil, "BEGIN")

update_rec_server_and_dbf( ALIAS(), _append, 1, "CONT" )

SELECT _POS

// uzmi gDatum za azuriranje
cDatum := DTOS(gDatum)  
private nIznRn := 0

do while !eof() .and. _POS->(IdPos+IdVd+dtos(Datum)+BrDok)==(cIdPos+"42"+cDatum+cRadRac)

    set_global_memvars_from_dbf()

  	_Kolicina := 0

  	do while !eof() .and. _POS->(IdPos+IdVd+dtos(Datum)+BrDok)==(cIdPos+"42"+cDatum+cRadRac) .and._POS->(IdRoba+IdCijena)==(_IdRoba+_IdCijena) .and._POS->Cijena==_Cijena

    	// saberi ukupnu kolicinu za jedan artikal
    	if gRadniRac = "D" .and. gVodiTreb == "D" .and. GT = OBR_NIJE
      		// vodi se po trebovanjima, a za ovu stavku trebovanje nije izgenerisano
      		replace kolicina with 0 
            // nuliraj kolicinu
    	endif
		
		_Kolicina += _POS->Kolicina

    	replace m1 with "Z"

    	if lNaX
      		SKIP 1
		    nTRec:=RECNO()
      		SKIP -1
      		replace idpos with "X "
      		GO (nTRec)
    	else
      		SKIP 1
    	endif

	enddo

  	_Prebacen := OBR_NIJE

  	SELECT ODJ
  	HSEEK _IdOdj

  	if odj->Zaduzuje=="S"
    	_M1 := OBR_NIJE
  	else
    	// za robe (ako odjeljenje zaduzuje robe) ne pravim razduzenje
    	// sirovina
    	_M1 := OBR_JEST
  	endif

  	if ROUND( _kolicina, 4) <> 0

		SELECT POS

		_BrDok := cStalRac
		_Vrijeme := cVrijeme
		_IdVrsteP := cNacPlac
		_IdGost := cIdGost
        _rbr := PADL( ALLTRIM( STR( ++ _cnt ) ), 5 )

		//append blank
        //_rec := dbf_get_rec()

		if lNaX
            _idpos := "X "
		endif

        _rec := get_dbf_global_memvars()
        
        update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )

		nIznRn += ( pos->kolicina * pos->cijena )

  	endif

  	select _pos

enddo

sql_table_update( nil, "END" )

return



// ---------------------------------------------------------
// azuriranje zaduzenja...
// ---------------------------------------------------------
function AzurPriprZ(cBrDok, cIdVd)
local _rec, _app
local _cnt := 0

SELECT PRIPRZ
GO TOP

set_global_memvars_from_dbf()

select pos_doks
append blank

_BrDok := cBrDok 

// zakljucene stavke
if gBrojSto == "D"
	if cIdVd <> VD_RN
		_zakljucen := "Z"
	endif
endif

if cIdVd == "PD"
	_IdVd := "16"
else
	_IdVd := cIdVd
endif

sql_table_update( nil, "BEGIN")

_app := get_dbf_global_memvars()

update_rec_server_and_dbf( ALIAS(), _app, 1, "CONT" )

SELECT PRIPRZ

// dodaj u datoteku POS
do while !eof()   
	
	SELECT PRIPRZ

	AzurRoba()

	SELECT PRIPRZ 

    set_global_memvars_from_dbf()

    //SELECT POS
    //APPEND BLANK

    _BrDok := cBrDok

	if cIdVd=="PD"
		_IdVd:="16"
	else
		_IdVd:=cIdVd
	endif
	
	if cIdVD=="PD"
        // !prva stavka storno
		_IdVd:="16"
        _IdDio:=_IdVrsteP
        _kolicina:=-_Kolicina
    endif

    _rbr := PADL( ALLTRIM( STR( ++ _cnt ) ), 5 )

    _app := get_dbf_global_memvars()

    update_rec_server_and_dbf( ALIAS(), _app )

    if cIdVD == "PD"  
        
        // druga stavka
        //append blank
        
        // !druga stavka storno storna = "+"
        _rec := hb_hash()
        _rec["idvd"] := "16"
		_rec["idodj"] := _rec["idvrstep"]  
        _rec["iddio"] := ""
        _rec["idvrstep"] := ""
        _rec["kolicina"] := - _rec["kolicina"]
        _rec["rbr"] := PADL( ALLTRIM( STR( ++ _cnt ) ), 5 )

        update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )
	
    endif

    SELECT PRIPRZ
    Del_Skip()

enddo

SELECT PRIPRZ
__dbPack()

sql_table_update( nil, "END")

if gFc_use == "D"
	nTArea := SELECT()
	// generisi plu kodove za nove sifre
	gen_all_plu( .t. )
	select (nTArea)
endif

return


// -----------------------------------
// da li je roba na stanju...
// -----------------------------------
function roba_na_stanju(cIdPos, cIdVd, cBrDok, dDatDok)
local lRet := .t.
local nTArea := SELECT()
O_POS_DOKS
select pos_doks
set order to tag "1"
seek cIdPos + cIdVd + DTOS(dDatDok) + cBrDok

if FOUND()
	if ALLTRIM(field->sto) == "N"
		lRet := .f.
	endif
endif

select (nTArea)
return lRet



// ---------------------------------------------------
// funkcija koja poziva upit da li je roba na stanju
// ---------------------------------------------------
function g_roba_na_stanju(cIdVd)
local cRobaNaStanju := "N"

// ako je ovaj parametar aktivan... prekoci
if gBrojSto == "D"
	return
endif

// ako nije zaduzenje - prekoci
if cIdVD <> VD_ZAD
	return
endif

//box_roba_stanje(@cRobaNaStanju)

// setuj robu na stanju pri importu zaduzenja na N
_sto := cRobaNaStanju

return

// -------------------------------
// box roba na stanju
// -------------------------------
function box_roba_stanje(cRStanje)
private GetList:={}

if EMPTY(cRStanje)
	cRStanje := "D"
endif

Box(,3, 50)
	@ 2+m_x, 2+m_y SAY "Da li je roba zaprimljena u prodavnicu (D/N)?" GET cRStanje VALID cRStanje $ "DN" PICT "@!"
	read
BoxC()

if LastKey() == K_ESC
	cRStanje := cRStanje
	return 0
endif

return 1


/*! \fn VratiPripr(cIdVd,cIdRadnik,cIdOdj,cIdDio)
 *  \brief
 *  \param cIdVd
 *  \param cIdRadnik
 *  \param cIdOdj
 *  \param cIdDio
 */

function VratiPripr(cIdVd,cIdRadnik,cIdOdj,cIdDio)
*{

local cSta
local cBrDok

do case
	case cIdVd == VD_ZAD
    		cSta:="zaduzenja"
  	case cIdVd == VD_OTP
    		cSta:="otpisa"
  	case cIdVd == VD_INV
    		cSta:="inventure"
  	case cIdVd == VD_NIV
    		cSta:="nivelacije"
	otherwise 
		cSta:="ostalo"
endcase

SELECT _POS
set order to 2         
// IdVd+IdOdj+IdRadnik

Seek cIdVd+cIdOdj+cIdDio

if FOUND()      
// .and. (Empty (cIdDio) .or. _POS->IdDio==cIdDio)
	if _POS->IdRadnik <> cIdRadnik
    		// ne mogu dopustiti da vise radnika radi paralelno inventuru, nivelaciju
    		// ili zaduzenje
    		MsgBeep ("Drugi radnik je poceo raditi pripremu "+cSta+"#"+"AKO NASTAVITE, PRIPREMA SE BRISE!!!", 30)
    		if Pitanje(,"Zelite li nastaviti?", " ")=="N"
      			return .f.
    		endif
    		// xIdRadnik := _POS->IdRadnik
    		do while !eof() .and. _POS->(IdVd+IdOdj+IdDio)==(cIdVd+cIdOdj+cIdDio)     
			// IdRadnik, xIdRadnik
      			Del_Skip()
    		end do
    		MsgBeep("Izbrisana je priprema "+cSta)
  	else
    		Beep (3)
    		if Pitanje(,"Poceli ste pripremu! Zelite li nastaviti? (D/N)"," ") == "N"
      			// brisanje prethodne pripreme
      			do while !eof() .and. _POS->(IdVd+IdOdj+IdDio)==(cIdVd+cIdOdj+cIdDio)
        			Del_Skip()
      			enddo
      			MsgBeep ("Priprema je izbrisana ... ")
    		else
      			// vrati ono sto je poceo raditi
      			SELECT _POS
      			do while !eof() .and. _POS->(IdVd+IdOdj+IdDio)==(cIdVd+cIdOdj+cIdDio)
        			Scatter()
        			SELECT PRIPRZ
        			Append Blank
        			Gather()
        			SELECT _POS
        			Del_Skip()
      			enddo
      			SELECT PRIPRZ
      			GO TOP
    		endif
  	endif
endif
SELECT _POS
Set order to 1
return .t.



/*! \fn ReindPosPripr()
 *  \brief
 */
 
function ReindPosPripr()

MsgO("Sacekajte trenutak...") 
O__POS
reindex
use
O__POS_PRIPR
reindex
use
MsgC()

return



/*! \fn DBZakljuci()
 *  \brief _POS -> ZAKSM
 */
 
function DBZakljuci()
*{

close all
O_OSOB
set order to tag "NAZ"
O_POS 
O_POS_DOKS
set order to 2
O__POS
set order to 1

aDbf:={}
AADD(aDbf, {"IdRadnik", "C",  4, 0})
AADD(aDbf, {"NazRadn",  "C", 30, 0})
AADD(aDbf, {"Zaklj",    "N", 12, 2})
AADD(aDbf, {"Otv",      "N", 12, 2})

Dbcreate2(PRIVPATH+"ZAKSM", aDbf)

select (F_ZAKSM)

my_use ("zaksm", "ZAKSM", .t.)

INDEX ON IdRadnik TAG ("1")           
Set Order To tag "1"

// pokupi nezakljucene racune....................
SELECT _POS
Seek gIdPos+"42"
do while !eof() .and. _POS->(IdPos+IdVd)==(gIdPos+"42")
	if _POS->Datum==gDatum
    		if _POS->M1 <> "Z"
      			nOtv:=_POS->(Kolicina*Cijena)
      			nZaklj:=0
    		endif
    		SELECT ZAKSM
		Seek _POS->IdRadnik
    		if !FOUND()
      			Append Blank
      			REPLACE IdRadnik WITH _POS->IdRadnik
      			SELECT OSOB
			HSEEK _POS->IdRadnik
      			SELECT ZAKSM
      			REPLACE NazRadn WITH OSOB->Naz
    		endif
    		REPLACE Otv WITH Otv+nOtv
    		SELECT _POS
  	endif
  	SKIP
enddo
//
// Pokupi ono sto je zakljuceno (od racuna)
//

select pos_doks  
// "2", "IdVd+DTOS (Datum)+Smjena"
// prodji kroz DOKS (i POS) da napunis iznosima ZAKSM
SEEK "42"+DTOS(gDatum)+gSmjena
do while !EOF() .and. pos_doks->IdVd=="42" .and. pos_doks->Datum==gDatum .and. pos_doks->Smjena == gSmjena
	if pos_doks->IdPos <> gIdPos
    	SKIP
		LOOP
  	endif
  	SELECT ZAKSM
  	HSEEK pos_doks->IdRadnik
  	if FOUND()
    	SELECT POS
    	HSEEK pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
    	nIzn := 0
    	do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
      		nIzn += POS->(Kolicina*Cijena)
      		SKIP
    	enddo
    	// azuriraj iznos zakljucenih racuna
    	SELECT ZAKSM
    	REPLACE Zaklj WITH Zaklj+nIzn
	endif
  	select pos_doks
	SKIP
enddo

return



/*! \fn UkloniRadne(cIdRadnik)
 *  \brief Ukloni radne racune (koj se nalaze u _POS tabeli)
 *  \param cIdRadnik
 */
 
function UkloniRadne(cIdRadnik)
*{

SELECT _POS
Set order to 1
SEEK gIdPos+VD_RN
while !eof() .and. _POS->(IdPos+IdVd)==(gIdPos+VD_RN)
	if _POS->IdRadnik==cIdRadnik .and. _POS->M1 == "Z"
    		Del_Skip ()
  	else
    		SKIP
  	endif
end
SELECT ZAKSM
return
*}

/*! \fn pos_naredni_dokument(cIdPos,cIdVd,cPadCh,dDat)
 *  \brief Naredni broj dokumenta
 *  \param cIdPos
 *  \param cIdVd
 *  \param cPadCh
 *  \param dDat
 *  \return cBrDok
 */
 
function pos_naredni_dokument(cIdPos,cIdVd,cPadCH,dDat)
*{

local cBrDok
local cFilter
local nRecs:=RecCount2()
local cBrDok1
local nObr:=0

if dDat==nil
	dDat:=gDatum
endif

set order to tag "1"
seek cIdPos+cIdVd+chr(254)

if ( IdPos+IdVd )<>( cIdPos+cIdVd )
	skip -1
endif

if (IdPos+IdVd)<>(cIdPos+cIdVd) .or. (year(dDat)>year(datum)) .or. (gSezonaTip=="M" .and. month(dDat)>month(datum) ) // m-tip i mjesec razlicit
	cBrDok:=SPACE(LEN(BrDok))
else
	cBrDok:=BrDok
endif

cBrdok:=(IncID(cBrDok,cPadCh))
cBrDok1:=cBrDok
nObr:=0

do while .t.
	if nObr>nRecs
   		// reindeksiraj pa trazi ispocetka
   		Reind_PB()
   		cBrDok:=cBrDok1
   		nObr:=0
 	endif
 	SEEK cidpos+cidvd+dtos(dDat)+cbrdok
 	if FOUND()
   		++nObr
   		cBrDok:=IncID (cBrDok, cPadCh)
 	else
   		EXIT
 	endif
enddo
return cBrDok




/*! \fn Reind_PB()
 *  \brief Reindeksiraj _POS i DOKS 
 */
 
function Reind_PB()

local cAlias:=ALIAS(SELECT())

MsgO("Indeksi nisu u redu?! Sacekajte trenutak da reindeksiram...")   

if UPPER(cAlias)="_POS"
	SELECT _POS
	USE
    O__POS
    reindex
	USE
    O__POS
elseif UPPER(cAlias)="POS_DOKS"
    select pos_doks
	USE
    O_POS_DOKS
    reindex
	USE
    O_POS_DOKS
endif
MsgC()

return



function Del_Skip()
local nNextRec
nNextRec:=0
SKIP
nNextRec:=RECNO()
Skip -1
delete
GO nNextRec
return



function GoTop2()
GO TOP
if DELETED()
	SKIP
endif
return


 
function pos_generisi_doks_iz_pos()
local _rec
local _app

if !SigmaSif("GENDOKS")
	return
endif

close all

O_POS_DOKS

Box(,1,60)
	cTipDok := SPACE(2)
	@ 1+m_x, 2+m_y SAY "Tip dokumenta (prazno-svi)" GET cTipDok
	read
BoxC()

if Empty(ALLTRIM(cTipDok)) .and. Pitanje(,"Izbrisati doks ??","N")=="D"
	ZAPP()
endif

O_POS
go top

do while !eof()
	
	if !Empty( ALLTRIM( cTipDok ) )
		if pos->idvd <> cTipDok
			skip
			loop
		endif
	endif
	
    _rec := dbf_get_rec()

  	do while !eof() .and. _rec["idpos"] == field->idpos .and. _rec["idvd"] == field->idvd .and. _rec["datum"] == field->datum .and. _rec["brdok"] == field->brdok
        skip
  	enddo

  	select pos_doks
	
	if !Empty(ALLTRIM(cTipDok))
		set order to tag "1"
		hseek _rec["idpos"] + _rec["idvd"] + DTOS(_rec["datum"])
		if Found()
			select pos
			skip
			loop
		endif
	endif
  	
	append blank

    _app := dbf_get_rec()
    _app["idpos"] := _rec["idpos"]
    _app["brdok"] := _rec["brdok"]
    _app["idvd"] := _rec["idvd"]
    _app["idradnik"] := _rec["idradnik"]
    _app["smjena"] := _rec["smjena"]
    _app["datum"] := _rec["datum"]
  	
    update_rec_server_and_dbf( ALIAS(), _app )
	
  	select pos

enddo

close all

return




/*! \fn SR_ImaRobu(cPom,cIdRoba)
 *  \brief Funkcija koja daje .t. ako se cIdRoba nalazi na posmatranom racunu
 *  \param cPom
 *  \param cIdRoba
 */
 
function SR_ImaRobu( cPom, cIdRoba )
local lVrati:=.f.
local nArr:=SELECT()

SELECT POS
Seek2(cPom+cIdRoba)

if POS->(IdPos+IdVd+dtos(datum)+BrDok+idroba)==cPom+cIdRoba
	lVrati:=.t.
endif

SELECT (nArr)
return (lVrati)




function Pos2_Pripr()
local _rec

select _pos_pripr

Zapp()

Scatter()

SELECT POS
seek pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

	_rec := dbf_get_rec()
    hb_hdel( _rec, "rbr" )
	
  	select roba
  	HSEEK _IdRoba
  	_rec["robanaz"] := roba->naz
  	_rec["jmj"] := roba->jmj

  	select _pos_pripr
  	Append Blank 

  	dbf_update_rec( _rec )

  	SELECT POS
  	SKIP

enddo
select _pos_pripr
return




/*! \fn NemaPrometa(cStariId, cNoviId)
 *  \brief Provjerava da li je bilo prometa
 *  \note ernad: Ugasio sam ovu funkciju .. administrator valjda zna sta treba da radi
 *  \todo promjenu Id-a prodajnog mjesta treba biti dostupna samo za L_ADMIN
 */
 
function NemaPrometa(cStariId, cNoviId)
return .t.




/*! \fn Priprz2Pos()
 *  \brief prebaci iz priprz -> pos,doks
 *  \note azuriranje dokumenata zaduzenja, nivelacija
 *
 */

function Priprz2Pos()
local lNivel
local _rec
local _cnt := 0

lNivel:=.f.

SELECT (cRsDbf)
SET ORDER TO TAG "ID"


SELECT PRIPRZ
GO TOP

_rec := dbf_get_rec()

select pos_doks
APPEND BLANK

update_rec_server_and_dbf( ALIAS(), _rec )

MsgO("prenos priprema->stanje")

// upis inventure/nivelacije
SELECT PRIPRZ  

do while !eof()

	_rec := dbf_get_rec()

	// dodaj stavku u pos
  	SELECT POS
	
	APPEND BLANK

    _rec["rbr"] := PADL( ALLTRIM(STR( ++ _cnt ) ) , 5 ) 
    update_rec_server_and_dbf( ALIAS(), _rec )
	
  	SELECT PRIPRZ

	// azur sifrarnik robe na osnovu priprz
	AzurRoba()

	SELECT PRIPRZ
  	SKIP

enddo

MsgC()

MsgO("brisem pripremu....")

// ostalo je jos da izbrisemo stavke iz pomocne baze
SELECT PRIPRZ

Zapp()
MsgC()

return




/*! \fn RealNaDan(dDatum)
 *  \brief Realizacija kase na dan = dDatum
 *
 */
function RealNaDan(dDatum)
*{
local nUkupno
local lOpened

SELECT(F_POS)
lOpened:=.t.
if !USED()
	O_POS
	lOpened:=.f.
endif


//"4", "dtos(datum)", KUMPATH+"POS"
SET ORDER TO TAG "4"
seek DTOS(dDatum)

nUkupno:=0
cPopust:=Pitanje(,"Uzeti u obzir popust","D")
do while !EOF() .and. dDatum==field->datum
	if field->idVd=="42"
		if cPopust=="D"
			nUkupno+=field->kolicina*(field->cijena-field->ncijena)
		else
			nUkupno+=field->kolicina*field->cijena
		endif
	endif
	SKIP
enddo

if !lOpened
	USE
endif
return nUkupno
*}


/*! \fn KasaIzvuci(cIdVd)
 *  \brief Punjenje podacima pomocne tabele za izvjestaj realizacije kase (tabela pos->pom)
 */

function KasaIzvuci(cIdVd, cDobId)
*{

// cIdVD - Id vrsta dokumenta
// Opis: priprema pomoce baze POM.DBF za realizaciju

if ( cDobId == nil )
	cDobId := ""
endif

if !gAppSrv
	MsgO("formiram pomocnu tabelu izvjestaja...")
endif

SEEK cIdVd+DTOS(dDat0)
do while !eof().and.pos_doks->IdVd==cIdVd.and.pos_doks->Datum<=dDat1

	if (kLevel>"0".and.pos_doks->IdPos="X").or.(!EMPTY(cIdPos).and.pos_doks->IdPos<>cIdPos).or.(!EMPTY(cSmjena).and.pos_doks->Smjena<>cSmjena)
    		SKIP
		loop
  	endif
  	
	SELECT pos 
	SEEK pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
  
  	do while !eof().and.pos->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
    		if (!EMPTY(cIdOdj).and.pos->IdOdj<>cIdOdj).or.(!EMPTY(cIdDio).and.pos->IdDio<>cIdDio)
      			SKIP 
			loop
    		endif
    		
		select roba 
		HSEEK pos->IdRoba

		if roba->(fieldpos("sifdob"))<>0
			if !Empty(cDobId)
				if roba->sifdob <> cDobId
					select pos
					skip
					loop
				endif
			endif
		endif
		
        if roba->( FIELDPOS("idodj") ) <> 0
    	    SELECT odj 
		    HSEEK roba->IdOdj
        endif
		
		nNeplaca:=0
    		
		if RIGHT(odj->naz,5)=="#1#0#"  // proba!!!
     			nNeplaca:=pos->(Kolicina*Cijena)
    		elseif RIGHT(odj->naz,6)=="#1#50#"
     			nNeplaca:=pos->(Kolicina*Cijena)/2
    		endif
    		
		if gPopVar="P" 
			nNeplaca+=pos->(kolicina*nCijena) 
		endif

    	SELECT pom
		HSEEK pos_doks->(IdPos+IdRadnik+IdVrsteP)+pos->(IdOdj+IdRoba+IdCijena)
		if !found()
      		APPEND BLANK
      		REPLACE IdPos WITH pos_doks->IdPos,IdRadnik WITH pos_doks->IdRadnik,IdVrsteP WITH pos_doks->IdVrsteP,IdOdj WITH pos->IdOdj,IdRoba WITH pos->IdRoba,IdCijena WITH pos->IdCijena,Kolicina WITH pos->Kolicina,Iznos WITH pos->Kolicina*POS->Cijena,Iznos3 WITH nNeplaca
      			
			if gPopVar=="A"
         		REPLACE Iznos2 WITH pos->nCijena
      		endif

      		if roba->(fieldpos("K1")) <> 0
             	REPLACE K2 WITH roba->K2,K1 WITH roba->K1
      		endif
    	else
      		REPLACE Kolicina WITH Kolicina+POS->Kolicina,Iznos WITH Iznos+POS->Kolicina*POS->Cijena,Iznos3 WITH Iznos3+nNeplaca
      		if gPopVar=="A"
         		REPLACE Iznos2 WITH Iznos2+pos->nCijena
      		endif
    	endif
    		
		SELECT pos
    	skip
  	enddo
  	
	select pos_doks  
	skip

enddo

if !gAppSrv
	MsgC()
endif

return


static function IsDocExists(cIdPos, cIdVd, dDatum, cBrDok)
local lFound

lFound:=.f.

SELECT POS	
PushWa()
SET ORDER TO TAG "1"
SEEK cIdPos+cIdVd+DTOS(dDatum)+cBrDok
if FOUND()
	lFound:=.t.
endif
PopWa()

select pos_doks
PushWa()
SET ORDER TO TAG "1"
SEEK cIdPos+cIdVd+DTOS(dDatum)+cBrDok

if FOUND()
	lFound:=.t.
endif
PopWa()

return lFound
*}


/*! \fn CreateTmpTblForDocReview()
 *  \brief Pravi pomocnu tabelu POM za stampu dokumenta iz pregleda dokumenata
 */
function CreateTmpTblForDocReView()

aDbf := {}
AADD(aDbf, {"IdRoba",   "C", 10, 0})
AADD(aDbf, {"IdCijena", "C",  1, 0})
AADD(aDbf, {"Cijena",   "N", 10, 3})
AADD(aDbf, {"NCijena",   "N", 10, 3})
AADD(aDbf, {"Kolicina", "N", 10, 3})
AADD(aDbf, {"Datum", "D", 8, 0})

NaprPom (aDbf)

O_POM

INDEX ON IdRoba+IdCijena+Str(Cijena, 10, 3) TAG ("1") TO (my_home()+"POM")
set order to tag "1"

return


// ------------------------------------------
// azuriraj sifrarnik robe
// priprz -> roba
// ------------------------------------------
static function AzurRoba()
local _rec

// u jednom dbf-u moze biti vise IdPos
// ROBA ili SIROV
select ( cRSDbf )
set order to tag "ID"

// pozicioniran sam na robi
hseek priprz->idroba  

lNovi:=.f.
if ( !FOUND() )

	// novi artikal
	// roba (ili sirov)
	append blank

    _rec := dbf_get_rec()
    _rec["id"] := priprz->idroba
    _rec["idodj"] := priprz->idodj

else

    _rec := dbf_get_rec()

endif

_rec["naz"] := priprz->robanaz
_rec["jmj"] := priprz->jmj

if !IsPDV() 
	// u ne-pdv rezimu je bilo bitno da preknjizenje na pdv ne pokvari
	// star cijene
	if katops->idtarifa <> "PDV17"
        _rec["cijena1"] := ROUND( priprz->cijena, 3 )        
	endif
else

	if cIdVd == "NI"
	  // nivelacija - u sifrarnik stavi novu cijenu
	  _rec["cijena1"] := ROUND(priprz->ncijena, 3)
	else
	  _rec["cijena1"] := ROUND(priprz->cijena, 3)
	endif
	
endif

_rec["idtarifa"] := priprz->idtarifa

if roba->(FIELDPOS("K1"))<>0  .and. priprz->(FIELDPOS("K2"))<>0
	_rec["k1"] := priprz->k1
	_rec["k2"] := priprz->k2
endif

if roba->(fieldpos("K7"))<>0  .and. priprz->(FIELDPOS("K9"))<>0
	_rec["k7"] := priprz->k7
	_rec["k8"] := priprz->k8
	_rec["k9"] := priprz->k9
endif

if roba->(FIELDPOS("N1"))<>0  .and. priprz->(FIELDPOS("N2"))<>0
	_rec["n1"] := priprz->n1
	_rec["n2"] := priprz->n2
endif

if (roba->(FIELDPOS("BARKOD"))<>0 .and. priprz->(FIELDPOS("BARKOD"))<>0)
	_rec["barkod"] := priprz->barkod
endif

update_rec_server_and_dbf( ALIAS(), _rec )

return


// -------------------------------------
// storniranje racuna
// -------------------------------------
function storno_rn( lSilent, cSt_rn, dSt_date, cSt_fisc )
local nTArea := SELECT()
local _rec
private GetList := {}

if lSilent == nil
	lSilent := .f.
endif
if cSt_rn == nil
	cSt_rn := SPACE(6)
endif
if dSt_date == nil
	dSt_date := DATE()
endif
if cSt_fisc == nil
	cSt_fisc := SPACE(10)
endif

Box(,3,55)
	
	@ m_x + 1, m_y + 2 SAY "stornirati pos racun broj:" GET cSt_rn 
	@ m_x + 2, m_y + 2 SAY "od datuma:" GET dSt_date
	
	read
	
	cSt_rn := PADL( ALLTRIM(cSt_rn), 6 )

	if EMPTY( cSt_fisc )
		select pos_doks
		seek gIdPos + "42" + DTOS(dSt_date) + cSt_rn
		cSt_fisc := PADR( ALLTRIM( STR( pos_doks->fisc_rn )), 10 )
	endif

	@ m_x + 3, m_y + 2 SAY "broj fiskalnog isjecka:" GET cSt_fisc
	
	read

BoxC()

if LastKey() == K_ESC

	select ( nTArea )
	return

endif

if EMPTY( cSt_rn )
	select ( nTArea )
	return
endif

//cSt_rn := PADL( ALLTRIM(cSt_rn), 6 )

// napuni pripremu sa stavkama racuna za storno
select pos
seek gIdPos + "42" + DTOS(dSt_date) + cSt_rn

do while !EOF() .and. field->idpos == gIdPos ;
	.and. field->brdok == cSt_rn ;
	.and. field->idvd == "42"

	cT_roba := field->idroba
	select roba
	seek cT_roba
	
	select pos

	_rec := dbf_get_rec()
	hb_hdel( _rec, "rbr" ) 
	
    select _pos_pripr
	append blank
	
	_rec["brdok"] := PADL( ALLTRIM( _rec["brdok"] ) + "S", 6 )
	_rec["kolicina"] := ( _rec["kolicina"] * -1 )
	_rec["robanaz"] := roba->naz
	_rec["datum"] := gDatum

	dbf_update_rec( _rec )

	if _pos_pripr->(FIELDPOS("C_1")) <> 0
		if EMPTY( cSt_fisc )
			replace field->c_1 with cSt_rn
		else
			replace field->c_1 with cSt_fisc
		endif
	endif

	select pos
	
	skip

enddo

select ( nTArea )

if lSilent == .f.

	// ovo refreshira pripremu
	oBrowse:goBottom()
	oBrowse:refreshAll()
	oBrowse:dehilite()

	do while !oBrowse:Stabilize().and.((Ch:=INKEY())==0)
	enddo

endif

return


// -------------------------------------
// povrat racuna u pripremu
// -------------------------------------
function povrat_rn( cSt_rn, dSt_date )
local nTArea := SELECT()
local _rec
private GetList := {}

if EMPTY( cSt_rn )
	select ( nTArea )
	return
endif

cSt_rn := PADL( ALLTRIM(cSt_rn), 6 )

// napuni pripremu sa stavkama racuna za storno
select pos
seek gIdPos + "42" + DTOS(dSt_date) + cSt_rn

do while !EOF() .and. field->idpos == gIdPos ;
	.and. field->brdok == cSt_rn ;
	.and. field->idvd == "42"

	cT_roba := field->idroba
	select roba
	seek cT_roba
	
	select pos

	_rec := dbf_get_rec()
	hb_hdel( _rec, "rbr" ) 
	
    select _pos_pripr
	append blank
	
	_rec["robanaz"] := roba->naz

	dbf_update_rec( _rec )

	select pos

	skip

enddo


// pobrisi racun iz POS i DOKS
select pos
go top

seek gIdPos + "42" + DTOS(dSt_date) + cSt_rn

do while !EOF() .and. field->idpos == gIdPos ;
	.and. field->brdok == cSt_rn ;
	.and. field->idvd == "42"

    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( ALIAS(), _rec )

	skip

enddo

select pos_doks
go top
seek gIdPos + "42" + DTOS(dSt_date) + cSt_rn

do while !EOF() .and. field->idpos == gIdPos ;
	.and. field->brdok == cSt_rn ;
	.and. field->idvd == "42"

    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( ALIAS(), _rec )

	skip

enddo

select ( nTArea )
	
return

