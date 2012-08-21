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

select F_K2C
if !used()
    O_K2C
endif

select F_MJTRUR
if !used()
    O_MJTRUR 
endif

select F_UREDJ
if !used()
    O_UREDJ 
endif

o_pregled()

return


 
function OpenPos()

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



// -----------------------------------------------------------------------
// vraca iznos racuna
// -----------------------------------------------------------------------
function pos_iznos_racuna( cIdPos, cIdVD, dDatum, cBrDok )
local _iznos := 0
local _popust := 0
local _total := 0

if PCOUNT() == 0

	cIdPos := pos_doks->IdPos
	cIdVD := pos_doks->IdVD
	dDatum := pos_doks->Datum
	cBrDok := pos_doks->BrDok

endif

select pos
Seek2( cIdPos + cIdVd + DTOS(dDatum) + cBrDok )

do while !EOF() .and. POS->( IdPos + IdVd + DTOS( datum ) + BrDok ) == ( cIdPos + cIdVd + DTOS( dDatum ) + cBrDok )
	_iznos += POS->( kolicina * cijena )
	_popust += POS->( kolicina * ncijena )
	SKIP
enddo

_total := ( _iznos - _popust )

select pos_doks

return _total



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


// -------------------------------------------------------------
// prebacuje stavke iz tabele _pos_pripr u tabelu _pos
// -------------------------------------------------------------
function _pripr2_pos( cIdVrsteP )
local cBrdok
local nTrec := 0
local _rec

if cIdVrsteP == nil
	cIdVrsteP := ""
endif

select _pos_pripr
go top

cBrdok := field->brdok

do while !EOF()
	
	_rec := dbf_get_rec()

	select _pos
	append blank
	
	if ( gRadniRac == "N" )
		// u _pos_pripr mora biti samo jedan dokument!!!
		_rec["brdok"] := cBrDok   
	endif

	_rec["idvrstep"] := cIdVrsteP

    dbf_update_rec( _rec )
	
	select _pos_pripr
	skip

enddo

// pobrisi mi _pos_pripr
select _pos_pripr
Zapp() 
__dbPack()

return


  
// --------------------------------------------------------------
// brisanje pos dokumenta
// --------------------------------------------------------------
function pos_brisi_dokument( cIdPos, cIdVD, dDatum, cBrojR )
local cDatum
local _rec

my_use_semaphore_off()
sql_table_update( nil, "BEGIN" )

select pos
cDatum := DTOS( dDatum )

set order to tag "1"
seek cIdPos+cIDVD+cDatum+cBrojR

if FOUND()
	_rec := dbf_get_rec()
	delete_rec_server_and_dbf( "pos_pos", _rec, 2, "CONT" )
endif

select pos_doks
set order to tag "1"
go top
seek cIdPos + cIdVd + cDatum + cBrojR

if FOUND()
	_rec := dbf_get_rec()
	delete_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )
endif

sql_table_update( nil, "END" )
my_use_semaphore_on()

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
                endif
		
                if ((cNBrDok<>nil) .and. (cBrDok<>cNBrDok))
			REPLACE brDok WITH cNBrDok
		endif
		
		go nTTTRec
        enddo

	// DOKS
        select pos_doks
	seek cIdPos+cIdVd+DTOS(dOrigD)+cBrDok
        if cLast $ "SV"
			REPLACE Vrijeme with cVrijeme
        endif
        if cLast $ "DV"
			REPLACE Datum with dDatum
        endif
        if ((cNBrDok<>nil) .and. (cBrDok<>cNBrDok))
		REPLACE brDok WITH cNBrDok
	endif
	
        UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"0000", 'WRITE')
        if !fSvi
		exit
	endif
        go nTDRec
enddo

return 1


/*! \fn azur_pos_racun(cIdPos,cStalRac,cRadRac,cVrijeme,cNacPlac,cIdGost)
 *  \brief Azuriranje racuna ( _POS->POS, _POS->DOKS )
 *  \param cIdPos
 *  \param cStalRac    - prilikom azuriranja daje se broj cStalRac
 *  \param cRadRac     - racun iz _POS.DBF sa brojem cRadRac se prenosi u POS, DOKS
 *  \param cVrijeme
 *  \param cNacPlac
 *  \param cIdGost
 */
 
function azur_pos_racun( cIdPos, cStalRac, cRadRac, cVrijeme, cNacPlac, cIdGost )
local cDatum
local nStavki
local _rec, _append
local _cnt := 0
local _kolicina := 0
local _idroba, _idcijena, _cijena
local _tbl_pos := "pos_pos"
local _tbl_doks := "pos_doks"
local _tbl_dokspf := "pos_dokspf"
local _ok
private nIznRn := 0

_ok := .t.

// iskljuci mi semafore
my_use_semaphore_off()

o_stazur()

// ------------------------------------------------------
// lock semaphore
sql_table_update(nil, "BEGIN")
_ok := lock_semaphore( _tbl_pos, "lock" )
_ok := _ok .and. lock_semaphore( _tbl_doks,  "lock" )
_ok := _ok .and. lock_semaphore( _tbl_dokspf,  "lock" )

if _ok
    sql_table_update(nil, "END")
else
    sql_table_update(nil, "ROLLBACK")
    my_use_semaphore_on()
    MsgBeep("lock tabela neuspjesan, azuriranje prekinuto")
    return 
endif
    
msgo("pos azuriranje sleep")
sleep(10)
msgc()
 
// ---end lock ---------------------------------------------


if ( cNacPlac == NIL )
	cNacPlac := gGotPlac
endif

if ( cIdGost == NIL )
	cIdGost := ""
endif

select _pos
set order to tag "1"
seek cIdPos + "42" + DTOS( gDatum ) + cRadRac

if !FOUND()
    MsgBeep( "Problem sa podacima tabele _POS, nema stavi !!!#Azuriranje nije moguce !" )
    my_use_semaphore_on()
    return
endif

// azuriraj racun u POS_DOKS
select pos_doks
append blank
_rec := dbf_get_rec()
_rec["idpos"] := cIdPos
_rec["idvd"] := VD_RN
_rec["datum"] := gDatum
_rec["brdok"] := cStalRac
_rec["vrijeme"] := cVrijeme
_rec["idvrstep"] := cNacPlac
_rec["idgost"] := cIdGost
_rec["idradnik"] := _pos->idradnik
_rec["m1"] := OBR_NIJE
_rec["prebacen"] := OBR_JEST
_rec["smjena"] := _pos->smjena

sql_table_update( nil, "BEGIN" )
update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT", .f. )

// azuriranje stavki u POS

select _pos
cDatum := DTOS( gDatum )  

do while !EOF() .and. _POS->( IdPos + IdVd + DTOS( Datum ) + BrDok ) == ( cIdPos + "42" + cDatum + cRadRac )

    nIznRn += ( _pos->kolicina * _pos->cijena )
	
    select pos
	append blank

    _rec := dbf_get_rec()

    _rec["idpos"] := cIdPos
    _rec["idvd"] := VD_RN
    _rec["datum"] := gDatum
    _rec["brdok"] := cStalRac
    _rec["rbr"] := PADL( ALLTRIM( STR( ++ _cnt ) ), 5 )
    _rec["m1"] := OBR_JEST
	_rec["prebacen"] := OBR_NIJE
    _rec["iddio"] := _pos->iddio 
    _rec["idodj"] := _pos->idodj
    _rec["idcijena"] := _pos->idcijena
    _rec["idradnik"] := _pos->idradnik
    _rec["idroba"] := _pos->idroba
    _rec["idtarifa"] := _pos->idtarifa
    _rec["kolicina"] := _pos->kolicina
    _rec["mu_i"] := _pos->mu_i
    _rec["ncijena"] := _pos->ncijena
    _rec["cijena"] := _pos->cijena
    _rec["smjena"] := _pos->smjena
    _rec["c_1"] := _pos->c_1
    _rec["c_2"] := _pos->c_2
    _rec["c_3"] := _pos->c_3

    update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT", .f. )

	select _pos
    skip

enddo

sql_table_update( nil, "END" )

// --- unlock -----------------------------------------
lock_semaphore( _tbl_pos,  "free" )
lock_semaphore( _tbl_doks,  "free" )
lock_semaphore( _tbl_dokspf, "free" )
// -----------------------------------------------------

my_use_semaphore_on()

// pobrisi _pos
select _pos
zap
__dbPack()

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

my_use_semaphore_off()
sql_table_update( nil, "BEGIN")

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

_app := get_dbf_global_memvars()
update_rec_server_and_dbf( "pos_doks", _app, 1, "CONT" )

SELECT PRIPRZ

// dodaj u datoteku POS
do while !eof()   
	
	SELECT PRIPRZ

	AzurRoba()

	SELECT PRIPRZ 

    set_global_memvars_from_dbf()

    SELECT POS
    APPEND BLANK

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

    update_rec_server_and_dbf( "pos_pos", _app, 1, "CONT" )

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

        update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )
	
    endif

    SELECT PRIPRZ

    Del_Skip()

enddo

// zavrsi transakciju
sql_table_update( nil, "END")
my_use_semaphore_on()


SELECT PRIPRZ
__dbPack()

// ova opcija ce setovati plu kodove u sifrarniku ako nisu vec setovani
if gFc_use == "D" .and. gFc_acd == "P" 

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




function pos_vrati_dokument_iz_pripr(cIdVd,cIdRadnik,cIdOdj,cIdDio)
local cSta
local cBrDok

do case
	case cIdVd == VD_ZAD
        cSta := "zaduzenja"
	case cIdVd == VD_OTP
		cSta := "otpisa"
	case cIdVd == VD_INV
		cSta := "inventure"
	case cIdVd == VD_NIV
		cSta := "nivelacije"
	otherwise 
		cSta := "ostalo"
endcase

select _pos
set order to tag "2"         
// IdVd+IdOdj+IdRadnik

seek cIdVd+cIdOdj+cIdDio

if FOUND()      
    // .and. (Empty (cIdDio) .or. _POS->IdDio==cIdDio)
	if _pos->idradnik <> cIdRadnik
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
		enddo
		MsgBeep("Izbrisana je priprema "+cSta)
	else

		Beep (3)

		if Pitanje(, "Poceli ste pripremu! Zelite li nastaviti? (D/N)", "D" ) == "N"
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
Set order to tag "1"

return .t.




/*! \fn UkloniRadne(cIdRadnik)
 *  \brief Ukloni radne racune (koj se nalaze u _POS tabeli)
 *  \param cIdRadnik
 */
 
function UkloniRadne(cIdRadnik)
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


// ------------------------------------------------------------------
// pos, uzimanje novog broja za tops dokument
// ------------------------------------------------------------------
function pos_novi_broj_dokumenta( id_pos, tip_dokumenta, dat_dok )
local _broj := 0
local _broj_doks := 0
local _param
local _tmp, _rest
local _ret := ""
local _t_area := SELECT()

if dat_dok == NIL
    dat_dok := gDatum
endif

// param: pos/10/10
_param := "pos" + "/" + id_pos + "/" + tip_dokumenta 
_broj := fetch_metric( _param, nil, _broj )

// konsultuj i doks uporedo
O_POS_DOKS
set order to tag "1"
go top
seek id_pos + tip_dokumenta + DTOS( dat_dok ) + "Ž"
skip -1

if field->idpos == id_pos .and. field->idvd == tip_dokumenta .and. DTOS( field->datum ) == DTOS( dat_dok )
    _broj_doks := VAL( field->brdok )
else
    _broj_doks := 0
endif

// uzmi sta je vece, doks broj ili globalni brojac
_broj := MAX( _broj, _broj_doks )

// uvecaj broj
++ _broj

// ovo ce napraviti string prave duzine...
_ret := PADL( ALLTRIM( STR( _broj ) ), 6  )

// upisi ga u globalni parametar
set_metric( _param, nil, _broj )

select ( _t_area )
return _ret


// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
function pos_set_param_broj_dokumenta()
local _param
local _broj := 0
local _broj_old
local _id_pos := gIdPos
local _tip_dok := "42"

Box(, 2, 60 )

    @ m_x + 1, m_y + 2 SAY "Dokument:" GET _id_pos
    @ m_x + 1, col() + 1 SAY "-" GET _tip_dok

    read

    if LastKey() == K_ESC
        BoxC()
        return
    endif

    // param: pos/10/10
    _param := "pos" + "/" + _id_pos + "/" + _tip_dok
    _broj := fetch_metric( _param, nil, _broj )
    _broj_old := _broj

    @ m_x + 2, m_y + 2 SAY "Zadnji broj dokumenta:" GET _broj PICT "999999"

    read

BoxC()

if LastKey() != K_ESC
    // snimi broj u globalni brojac
    if _broj <> _broj_old
        set_metric( _param, nil, _broj )
    endif
endif

return



// ------------------------------------------------------------
// resetuje brojač dokumenta ako smo pobrisali dokument
// ------------------------------------------------------------
function pos_reset_broj_dokumenta( id_pos, tip_dok, broj_dok )
local _param
local _broj := 0

// param: fakt/10/10
_param := "pos" + "/" + id_pos + "/" + tip_dok
_broj := fetch_metric( _param, nil, _broj )

if VAL( ALLTRIM( broj_dok ) ) == _broj
    -- _broj
    // smanji globalni brojac za 1
    set_metric( _param, nil, _broj )
endif

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

//if !SigmaSif("GENDOKS")
// ovo je opasno !!!!
	return
//endif

close all

O_POS_DOKS

Box(,1,60)
	cTipDok := SPACE(2)
	@ 1+m_x, 2+m_y SAY "Tip dokumenta (prazno-svi)" GET cTipDok
	read
BoxC()

if Empty(ALLTRIM(cTipDok)) .and. Pitanje(,"Izbrisati doks ??","N")=="D"
	//ZAPP()
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



// -------------------------------------------
// pos -> priprz
// -------------------------------------------
function pos_2_priprz()
local _rec
local _t_area := SELECT()

O_PRIPRZ
select priprz

Zapp()
__dbPack()

select pos
seek pos_doks->( IdPos + IdVd + DTOS(datum) + BrDok )

do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

	_rec := dbf_get_rec()

    hb_hdel( _rec, "rbr" )
	
	select roba
	HSEEK _rec["idroba"]

	_rec["robanaz"] := roba->naz
	_rec["jmj"] := roba->jmj
    _rec["barkod"] := roba->barkod

	select priprz
	append blank 

	dbf_update_rec( _rec )

	select pos
	skip

enddo

select ( _t_area )
return







function pos2_pripr()
local _rec

select _pos_pripr

Zapp()
__dbPack()

go top
scatter()

select pos
seek pos_doks->( IdPos+IdVd+dtos(datum)+BrDok )

do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

	_rec := dbf_get_rec()
    hb_hdel( _rec, "rbr" )
	
	select roba
	HSEEK _IdRoba
	_rec["robanaz"] := roba->naz
	_rec["jmj"] := roba->jmj

	select _pos_pripr
	append blank 

	dbf_update_rec( _rec )

	select pos
	skip

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

MsgO( "Azuriranje priprema -> kumulativ u toku... sacekajte..." )

my_use_semaphore_off()
sql_table_update( nil, "BEGIN" )

SELECT PRIPRZ
GO TOP

select pos_doks
APPEND BLANK

_rec := dbf_get_rec()
_rec["idpos"] := priprz->idpos
_rec["idvd"] := priprz->idvd
_rec["datum"] := priprz->datum
_rec["brdok"] := priprz->brdok
_rec["vrijeme"] := priprz->vrijeme
_rec["idvrstep"] := priprz->idvrstep 
_rec["idgost"] := priprz->idgost
_rec["idradnik"] := priprz->idradnik
_rec["m1"] := priprz->m1
_rec["prebacen"] := priprz->prebacen
_rec["smjena"] := priprz->smjena

update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )

// upis inventure/nivelacije
SELECT PRIPRZ  

do while !eof()

	// dodaj stavku u pos
	SELECT POS	
	APPEND BLANK

	_rec := dbf_get_rec()
    _rec["idpos"] := priprz->idpos
    _rec["idvd"] := priprz->idvd
    _rec["datum"] := priprz->datum
    _rec["brdok"] := priprz->brdok
    _rec["m1"] := priprz->m1
	_rec["prebacen"] := priprz->prebacen
    _rec["iddio"] := priprz->iddio 
    _rec["idodj"] := priprz->idodj
    _rec["idcijena"] := priprz->idcijena
    _rec["idradnik"] := priprz->idradnik
    _rec["idroba"] := priprz->idroba
    _rec["idtarifa"] := priprz->idtarifa
    _rec["kolicina"] := priprz->kolicina
    _rec["kol2"] := priprz->kol2
    _rec["mu_i"] := priprz->mu_i
    _rec["ncijena"] := priprz->ncijena
    _rec["cijena"] := priprz->cijena
    _rec["smjena"] := priprz->smjena
    _rec["c_1"] := priprz->c_1
    _rec["c_2"] := priprz->c_2
    _rec["c_3"] := priprz->c_3
    _rec["rbr"] := PADL( ALLTRIM(STR( ++ _cnt ) ) , 5 ) 

    update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )
	
	SELECT PRIPRZ

	// azur sifrarnik robe na osnovu priprz
	AzurRoba()

	SELECT PRIPRZ
	SKIP

enddo

MsgC()

sql_table_update( nil, "END" )
my_use_semaphore_on()

MsgO("brisem pripremu....")

// ostalo je jos da izbrisemo stavke iz pomocne baze
SELECT PRIPRZ

Zapp()
__dbPack()

MsgC()

return




/*! \fn RealNaDan(dDatum)
 *  \brief Realizacija kase na dan = dDatum
 *
 */
function RealNaDan(dDatum)
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





function KasaIzvuci(cIdVd, cDobId)
// cIdVD - Id vrsta dokumenta
// Opis: priprema pomoce baze POM.DBF za realizaciju

if ( cDobId == nil )
	cDobId := ""
endif

if !gAppSrv
	MsgO("formiram pomocnu tabelu izvjestaja...")
endif

SEEK cIdVd + DTOS(dDat0)

do while !eof().and.pos_doks->IdVd==cIdVd.and.pos_doks->Datum<=dDat1

	if ( !EMPTY(cIdPos) .and. pos_doks->IdPos <> cIdPos ) .or. ( !EMPTY(cSmjena) .and. pos_doks->Smjena <> cSmjena )
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
		
		nNeplaca := 0
			
		if RIGHT(odj->naz,5)=="#1#0#"  // proba!!!
			nNeplaca:=pos->(Kolicina*Cijena)
		elseif RIGHT(odj->naz,6)=="#1#50#"
			nNeplaca:=pos->(Kolicina*Cijena)/2
		endif
			
		if gPopVar="P" 
			nNeplaca+=pos->(kolicina*nCijena) 
		endif

		SELECT pom  
        GO TOP
		seek pos_doks->IdPos + pos_doks->IdRadnik + pos_doks->IdVrsteP + pos->IdOdj + pos->IdRoba + pos->IdCijena
		
		if !found()

			APPEND BLANK
			replace IdPos WITH pos_doks->IdPos
			replace IdRadnik WITH pos_doks->IdRadnik
			replace IdVrsteP WITH pos_doks->IdVrsteP
			replace IdOdj WITH pos->IdOdj
			replace IdRoba WITH pos->IdRoba
			replace IdCijena WITH pos->IdCijena
			replace Kolicina WITH pos->Kolicina
			replace Iznos WITH pos->Kolicina * POS->Cijena
			replace Iznos3 WITH nNeplaca
				
			if gPopVar=="A"
				REPLACE Iznos2 WITH pos->nCijena
			endif

			if roba->(fieldpos("K1")) <> 0
				REPLACE K2 WITH roba->K2,K1 WITH roba->K1
			endif

		else

			replace Kolicina WITH Kolicina + POS->Kolicina
			replace Iznos WITH Iznos + POS->Kolicina * POS->Cijena
			replace Iznos3 WITH Iznos3 + nNeplaca

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

else

    _rec := dbf_get_rec()

endif

_rec["naz"] := priprz->robanaz
_rec["jmj"] := priprz->jmj

if !IsPDV() 
	// u ne-pdv rezimu je bilo bitno da preknjizenje na pdv ne pokvari
	// star cijene
	if katops->idtarifa <> "PDV17"
        _rec["mpc"] := ROUND( priprz->cijena, 3 )        
	endif
else

	if cIdVd == "NI"
	  // nivelacija - u sifrarnik stavi novu cijenu
	  _rec["mpc"] := ROUND(priprz->ncijena, 3)
	else
	  _rec["mpc"] := ROUND(priprz->cijena, 3)
	endif
	
endif

_rec["idtarifa"] := priprz->idtarifa
_rec["k1"] := priprz->k1
_rec["k2"] := priprz->k2
_rec["k7"] := priprz->k7
_rec["k8"] := priprz->k8
_rec["k9"] := priprz->k9
_rec["n1"] := priprz->n1
_rec["n2"] := priprz->n2
_rec["barkod"] := priprz->barkod

update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )

return


// ---------------------------------------------------------------
// koriguje broj racuna
// ---------------------------------------------------------------
static function _fix_rn_no( racun )
local _a_rn := {}

if !EMPTY( racun ) .and. ( "-" $ racun )

	_a_rn := TokToNiz( racun, "-" )

	if !EMPTY( _a_rn[2] )
		racun := PADR( ALLTRIM(_a_rn[2]), 6 )
	endif 

endif

return .t.



// ---------------------------------------------------------------
// storniranje racuna po fiskalnom isjecku
// ---------------------------------------------------------------
function pos_storno_fisc_no()
local nTArea := SELECT()
local _rec
local _datum, _broj_rn
local _fisc_broj := 0
private GetList := {}
private aVezani:={}

Box(, 1, 55 )
	@ m_x + 1, m_y + 2 SAY "broj fiskalnog isjecka:" GET _fisc_broj PICT "9999999999"
	read
BoxC()

if LastKey() == K_ESC
	select ( nTArea )
	return
endif

if _fisc_broj <= 0
	select ( nTArea )
	return
endif

select ( nTArea )

select pos_doks
set order to tag "FISC"
go top
seek STR( _fisc_broj, 10 )

if !FOUND()
    MsgBeep( "Ne postoji racun sa zeljenom vezom fiskalnog racuna !!!" )
    select (nTArea )
    return
endif

_datum := pos_doks->datum
_broj_rn := pos_doks->brdok

select pos_doks
set order to tag "1"

// filuj stavke storno racuna
__fill_storno( _datum, _broj_rn, STR( _fisc_broj, 10 ) )

select (nTArea)

// ovo refreshira pripremu
oBrowse:goBottom()
oBrowse:refreshAll()
oBrowse:dehilite()

do while !oBrowse:Stabilize() .and. ( ( Ch := INKEY() ) == 0 )
enddo

return







// -------------------------------------
// storniranje racuna
// -------------------------------------
function pos_storno_rn( lSilent, cSt_rn, dSt_date, cSt_fisc )
local nTArea := SELECT()
local _rec
local _datum := gDatum
local _danasnji := "D"
private GetList := {}
private aVezani:={}

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

Box(, 4, 55 )
	
	@ m_x + 1, m_y + 2 SAY "Racun je danasnji ?" GET _danasnji VALID _danasnji $ "DN" PICT "@!"
	
	read

	if _danasnji == "N"
		_datum := NIL
	endif

	@ m_x + 2, m_y + 2 SAY "stornirati pos racun broj:" GET cSt_rn VALID {|| PRacuni( @_datum, @cSt_rn, .t. ), _fix_rn_no( @cSt_rn ), dSt_date := _datum,  .t. }
	@ m_x + 3, m_y + 2 SAY "od datuma:" GET dSt_date
	
	read
	
	cSt_rn := PADL( ALLTRIM(cSt_rn), 6 )

	if EMPTY( cSt_fisc )
		select pos_doks
		seek gIdPos + "42" + DTOS( dSt_date ) + cSt_rn
		cSt_fisc := PADR( ALLTRIM( STR( pos_doks->fisc_rn )), 10 )
	endif

	@ m_x + 4, m_y + 2 SAY "broj fiskalnog isjecka:" GET cSt_fisc
	
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

select ( nTArea )

// filuj stavke storno racuna
__fill_storno( dSt_date, cSt_rn, cSt_fisc )

if lSilent == .f.

	// ovo refreshira pripremu
	oBrowse:goBottom()
	oBrowse:refreshAll()
	oBrowse:dehilite()

	do while !oBrowse:Stabilize() .and. ( ( Ch := INKEY() ) == 0 )
	enddo

endif

return


// --------------------------------------------------
// filuje pripremu sa storno stavkama
// --------------------------------------------------
static function __fill_storno( rn_datum, storno_rn, broj_fiscal )
local _t_area := SELECT()
local _t_roba, _rec

// napuni pripremu sa stavkama racuna za storno
select pos
seek gIdPos + "42" + DTOS( rn_datum ) + storno_rn

do while !EOF() .and. field->idpos == gIdPos ;
	.and. field->brdok == storno_rn ;
	.and. field->idvd == "42"

	_t_roba := field->idroba

	select roba
	seek _t_roba
	
	select pos

	_rec := dbf_get_rec()
	hb_hdel( _rec, "rbr" ) 
	
    select _pos_pripr
	append blank
	
	_rec["brdok"] :=  "PRIPRE"
	_rec["kolicina"] := ( _rec["kolicina"] * -1 )
	_rec["robanaz"] := roba->naz
	_rec["datum"] := gDatum

	dbf_update_rec( _rec )

	if _pos_pripr->(FIELDPOS("C_1")) <> 0
		if EMPTY( broj_fiscal )
			replace field->c_1 with storno_rn
		else
			replace field->c_1 with broj_fiscal
		endif
	endif

	select pos
	
	skip

enddo

select ( _t_area )

return



// ----------------------------------------------------------------
// povrat dokumenta u pripremu POS
// ----------------------------------------------------------------
function pos_povrat_dokumenta( id_pos, id_vd, dat_dok, br_dok )
local _t_area := SELECT()
local _rec

select pos
set order to tag "1"
go top
seek id_pos + id_vd + DTOS( dat_dok ) + br_dok

if FOUND()

    _rec := dbf_get_rec()
    
    my_use_semaphore_off()
    sql_table_update( nil, "BEGIN" )

    delete_rec_server_and_dbf( "pos_pos", _rec, 2, "CONT" )

    select pos_doks
    seek id_pos + id_vd + DTOS( dat_dok ) + br_dok

    if FOUND()
        _rec := dbf_get_rec()
        delete_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )
    endif

    sql_table_update( nil, "END" )
    my_use_semaphore_on()

endif

select ( _t_area )
return




// -------------------------------------
// povrat racuna u pripremu
// -------------------------------------
function pos_povrat_rn( cSt_rn, dSt_date )
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

my_use_semaphore_off()
sql_table_update( nil, "BEGIN")

// pobrisi racun iz POS i DOKS
select pos
go top

seek gIdPos + "42" + DTOS(dSt_date) + cSt_rn

if FOUND()
    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( "pos_pos", _rec, 2, "CONT" )
endif

select pos_doks
go top
seek gIdPos + "42" + DTOS(dSt_date) + cSt_rn

if FOUND()
    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )
endif

sql_table_update( nil, "END")
my_use_semaphore_on()

select ( nTArea )
	
return


// ---------------------------------------------
// import sifrarnika iz fmk
// ---------------------------------------------
function pos_import_fmk_roba()
local _location := fetch_metric( "pos_import_fmk_roba_path", my_user(), PADR( "", 300 ) )
local _cnt := 0
local _rec

O_ROBA

_location := PADR( ALLTRIM( _location ), 300 ) 

Box(, 1, 60)
    @ m_x + 1, m_y + 2 SAY "lokacija:" GET _location PICT "@S50"
    read
BoxC()

if LastKey() == K_ESC
    return
endif

// snimi parametar
set_metric( "pos_import_fmk_roba_path", my_user(), _location )

select ( F_TMP_1 )
if used()
    use
endif

my_use_temp( "TOPS_ROBA", ALLTRIM( _location ), .f., .t. )
index on ("id") tag "ID" 

// ----------
// predji na tops_roba

select tops_roba
set order to tag "ID"
go top

my_use_semaphore_off()
sql_table_update( nil, "BEGIN" )

Box(,1,60)

do while !EOF() 

    _id_roba := field->id

    select roba
    go top
    seek _id_roba

    if !FOUND()
        append blank
    endif
    
    _rec := dbf_get_rec()

    _rec["id"] := tops_roba->id

    _rec["naz"] := tops_roba->naz
    _rec["jmj"] := tops_roba->jmj
    _rec["idtarifa"] := tops_roba->idtarifa
    _rec["barkod"] := tops_roba->barkod

    _rec["mpc"] := tops_roba->cijena1
    _rec["mpc2"] := tops_roba->cijena2

    ++ _cnt
    @ m_x + 1, m_y + 2 SAY "import roba: " + _rec["id"] + ":" + PADR( _rec["naz"], 20 ) + "..."
    update_rec_server_and_dbf( "roba", _rec, 1, "CONT" )

    select tops_roba
    skip

enddo

BoxC()

sql_table_update( nil, "END" )
my_use_semaphore_on()

select ( F_TMP_1 )
use

if _cnt > 0
    msgbeep( "Update " + ALLTRIM( STR( _cnt ) ) + " zapisa !" )
endif

close all
return




