/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"

static __tbl_suban := "fin_suban"
static __tbl_nalog := "fin_nalog"
static __tbl_anal := "fin_anal"
static __tbl_sint := "fin_sint"


// ---------------------------------------------------
// ---------------------------------------------------
function fin_azur( automatic )
local oServer := pg_server()
local _nalozi, _i
local _id_firma, _id_vn, _br_nal 
local _vise_naloga := .f.
local _ok := .f.

if ( automatic == NIL )
    automatic := .f.
endif

// otvori potrebne tabele
o_fin_za_azuriranje()

if fin_pripr->( RECCOUNT() == 0 ) .or. ( !automatic .and. Pitanje("pAz", "Izvrsiti azuriranje fin naloga ? (D/N)?", "N") == "N" )
    return _ok
endif

<<<<<<< HEAD
o_fin_za_azuriranje()
fin_set_broj_naloga()
=======
// daj mi sve naloge iz pripreme u matricu...
// za azuriranje vise naloga od jednom...
_nalozi := get_fin_nalozi()
>>>>>>> master

// ima li vise razlicitih naloga u pripremi ?
if LEN( _nalozi ) > 1
	_vise_naloga := .t.
endif

// napuni mi pomocne tabele
// ako je u pripremi vise naloga...
if _vise_naloga
	// napuni mi pomocne tabele
	StNal( .t. )
	// otvori ponovo tabele
	o_fin_za_azuriranje()
endif

// napravi sve provjere prije azuriranja naloga...
// ako nesto nije ok, prekinut ces operaciju...
if !fin_azur_check( automatic, _nalozi )
	return _ok
endif

// AZURIRANJE
// ======================================================

// lokuj mi tabele prije svega....
if !f18_lock_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog } )
    MsgBeep( "Problem sa lock-om tabela za azuriranje !!!#Prekidam operaciju..." )
    return _ok
endif

sql_table_update( nil, "BEGIN" )

MsgO( "Azuriranje naloga u toku ...." )

for _i := 1 to LEN( _nalozi )

	// tekuci nalog...
	_id_firma := _nalozi[_i, 1]
	_id_vn := _nalozi[_i, 2]
	_br_nal := _nalozi[_i, 3]

	// postoji li nalog na serveru ?
	if fin_doc_exist( _id_firma, _id_vn, _br_nal )

    	MsgBeep( "Nalog " + _id_firma + "-" + _id_vn + "-" + _br_nal + " vec postoji azuriran !!!" )

		if !_vise_naloga

			// zavrsi ti ovu transakciju
			f18_free_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog } )
			sql_table_update( nil, "ROLLBACK" )
	
			MsgC()

    		return _ok

		else
			// preskoci do narednog broja naloga
			loop
		endif

	endif

	// azuriraj SQL podatke
	if !fin_azur_sql( oServer, _id_firma, _id_vn, _br_nal )

		f18_free_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog } )
		sql_table_update( nil, "ROLLBACK" )
		
		MsgC()
		MsgBeep( "Problem sa azuriranjem naloga na SQL server !!!" )

		return _ok

	endif

	// azuriraj DBF podatke
    if !fin_azur_dbf( automatic, _id_firma, _id_vn, _br_nal )

		f18_free_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog } )
		sql_table_update( nil, "ROLLBACK" )
	
        MsgC()
        MsgBeep( "Problem sa azuriranjem naloga u DBF tabele !!!" )

        return _ok

   	endif

next

MsgC()

// sve proteklo ok... otkljucaj i zavrsi transakciju		
f18_free_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog } )
sql_table_update( nil, "END" )
	
// pakuj pripremu...
select fin_pripr
__dbpack()

// pobrisi pomocne tabele
fin_brisi_p_tabele( .t. )

_ok := .t.

return _ok



// ------------------------------------------------
// popunjava sve u matricu iz pripreme
// ubacuje naloge razlicitih vrsta ili jedan
// ------------------------------------------------
static function get_fin_nalozi()
local _data := {}
local _scan

select fin_pripr
set order to tag "1"
go top

do while !EOF()
    
    _scan := ASCAN( _data, { |var| var[1] == field->idfirma .and. ;
									var[2] == field->idvn .and. ;
									var[3] == field->brnal  })
    
    if _scan == 0
        AADD( _data, { field->idfirma, field->idvn, field->brnal } )
    endif

    skip
enddo

go top

return _data


// -----------------------------
// -----------------------------
function o_fin_za_azuriranje()

close all

// kumulativne...
O_KONTO
O_PARTN
O_FIN_PRIPR
O_SUBAN
O_ANAL
O_SINT
O_NALOG

// pomocne
O_PSUBAN
O_PANAL
O_PSINT
O_PNALOG

return






// -----------------------------------------------------------------
// Azuriranje podataka na SQL server
// -----------------------------------------------------------------
function fin_azur_sql( oServer, id_firma, id_vn, br_nal )
local _ok := .t.
local _ids := {}
local _tmp_id, _count, _tmp_doc, _rec, _msg, _i
local _ids_doc := {}
local _ids_tmp := {}
local _ids_suban := {}
local _ids_sint := {}
local _ids_anal := {}
local _ids_nalog := {}
local _n := 1

Box(, 5, 60 )

	_tmp_id := "x"
  
	// azuriranje FIN_SUBAN
	// ======================================

	select psuban
	set order to tag "1"
	go top
	seek id_firma + id_vn + br_nal

	// upisi u log operaciju
	log_write( "FIN, azuriranje naloga: " + id_firma + "-" + id_vn + "-" + br_nal + " - START", 3 )
	
	_count := 0

	do while !EOF() .and. field->idfirma == id_firma .and. field->idvn == id_vn .and. field->brnal == br_nal

		_rec := dbf_get_rec()

		++ _count

		// dodaj za semafor na prvom zapisu subana...
		if _count == 1

			// ovo su IDS-ovi
			_tmp_id := _rec["idfirma"] + _rec["idvn"] + _rec["brnal"]
			
			// nivo dokumenta #2
			AADD( _ids_suban, "#2" + _tmp_id )
    		AADD( _ids_anal, "#2" + _tmp_id )
    		AADD( _ids_sint, "#2" + _tmp_id )
			
			// regularni IDS
    		AADD( _ids_nalog, _tmp_id )

			@ m_x + 1, m_y + 2 SAY "fin_suban -> server: " + _tmp_id 

		endif

		// pusti na server...
    	if !sql_table_update("fin_suban", "ins", _rec )
        	_ok := .f.
        	exit
    	endif

    	skip
	
	enddo

	
	// azuriranje FIN_ANAL
	// -----------------------------------

	if _ok

    	@ m_x + 2, m_y + 2 SAY "fin_anal -> server" 

    	select panal
		set order to tag "1"
    	go top
		seek id_firma + id_vn + br_nal

	    do while !EOF() .and. field->idfirma == id_firma .and. field->idvn == id_vn .and. field->brnal == br_nal

        	_rec := dbf_get_rec()
        	
			if !sql_table_update( "fin_anal", "ins", _rec )
            	_ok := .f.
           	 	exit
       		endif

        	skip

    	enddo

	endif

	
	// azuriranje FIN_SINT
	// -----------------------------------

	if _ok
  
    	@ m_x + 3, m_y + 2 SAY "fin_sint -> server" 

    	select psint
    	set order to tag "1"
		go top
		seek id_firma + id_vn + br_nal

    	do while !EOF() .and. field->idfirma == id_firma .and. field->idvn == id_vn .and. field->brnal == br_nal

        	_rec := dbf_get_rec()
        
			if !sql_table_update( "fin_sint", "ins", _rec )
            	_ok := .f.
            	exit
        	endif

        	skip

    	enddo

	endif


	// azuriranje FIN_NALOG
	// -----------------------------------

	if _ok
  
    	@ m_x + 4, m_y + 2 SAY "fin_nalog -> server" 

    	select pnalog
		set order to tag "1"
    	go top
		seek id_firma + id_vn + br_nal
 
    	do while !EOF() .and. field->idfirma == id_firma .and. field->idvn == id_vn .and. field->brnal == br_nal
        
			_rec := dbf_get_rec()
        
			if !sql_table_update("fin_nalog", "ins", _rec )
            	_ok := .f.
            	exit
        	endif

        	skip

    	enddo

	endif


	if !_ok
		// transakcija je neuspjesna...
    	_msg := "FIN azuriranje, trasakcija " + _tmp_id + " neuspjesna ?!"
    	log_write( _msg, 2 )
    	MsgBeep( _msg )
	else

		// pushiraj IDS-ove na semafore
    	push_ids_to_semaphore( __tbl_suban , _ids_suban )
   	 	push_ids_to_semaphore( __tbl_sint  , _ids_sint  )
    	push_ids_to_semaphore( __tbl_anal  , _ids_anal  )
    	push_ids_to_semaphore( __tbl_nalog , _ids_nalog )

    	log_write( "FIN, azuriranje naloga " + id_firma + "-" + id_vn + "-" + br_nal + " - END", 3 )

	endif

BoxC()

return _ok



// ----------------------------
// provjeri prije azuriranja
// pokrece se serija testova...
// ----------------------------
function fin_azur_check( auto, lista_naloga )
local _t_area, _i, _t_rec
local _id_firma, _id_vn, _br_nal
local _vise_naloga := .f.
local _ok := .f.

_t_area := SELECT()

// ima li vise naloga
if LEN( lista_naloga ) > 1
	_vise_naloga := .t.
endif

// da li je nalog ogroman, treba li ga provjeravati uopste ?
if !_vise_naloga .and. fin_p_nalog_bez_provjere( auto )
	_ok := .t.
	return _ok
endif

// 1) provjera pomocnih tabela
if !fin_p_tabele_provjera( lista_naloga )
	
	// u slucaju da je samo jedan nalog u pitanju
	// to je moguci uzrok !

	if !_vise_naloga
		MsgBeep( "Potrebno izvrsiti stampu naloga prije azuriranja !!!" )
	endif

	return _ok

endif

// prodji seriju testova
for _i := 1 to LEN( lista_naloga )

	_id_firma := lista_naloga[ _i, 1 ]
	_id_vn := lista_naloga[ _i, 2 ]
	_br_nal := lista_naloga[ _i, 3 ]

	// pronadji mi nalog prvo !!!
	select fin_pripr
	set order to tag "1"
	go top
	seek _id_firma + _id_vn + _br_nal

	_t_rec := RECNO()
	
	// 2) provjeri da li je broj naloga zadovoljen
	// ovo ce raditi jos u tekucoj 1.4.x verziji a poslije treba izbaciti !!!

	if LEN( ALLTRIM( field->brnal ) ) < 8
    	// mora biti LEN = 8
   	 	MsgBeep( "Broj naloga mora biti sa vodecim nulama !?!" )
   	 	select ( _t_area )
    	return _ok
	endif

	// 3) provjera rednih brojeva u nalogu
	if !fin_p_provjeri_redni_broj( _id_firma, _id_vn, _br_nal ) 
    	select ( _t_area )
    	return _ok
	endif

	// 4) fin saldo provjera
	if !fin_p_saldo_provjera( _id_firma, _id_vn, _br_nal )
		select ( _t_area )
		return _ok
	endif

next

// sve je ok
_ok := .t.

return _ok

<<<<<<< HEAD
    // prodji kroz PSUBAN i vidi da li je nalog zatvoren
    // samo u tom slucaju proknjizi nalog u odgovarajuce datoteke
    cNal := IDFirma+IdVn+BrNal
    nSaldo := 0
    do while !eof() .and. cNal == IdFirma + IdVn + BrNal
=======
>>>>>>> master



// ------------------------------------------------
// provjera rednog broja u tabeli
// ------------------------------------------------
static function fin_p_provjeri_redni_broj( id_firma, id_vn, br_nal )
local _ok := .t.
local _tmp

select psuban
set order to tag "1"
go top
seek id_firma + id_vn + br_nal

do while !EOF() .and. field->idfirma == id_firma .and. field->idvn == id_vn .and. field->brnal == br_nal

    _tmp := field->rbr
    
    skip 1

    if _tmp == field->rbr
        _ok := .f.
		MsgBeep( "Nalog " + id_firma + "-" + id_vn + "-" + br_nal + " nema ispravne redne brojeve !" )
        return _ok        
    endif

enddo

return _ok





// -----------------------------------------------------------------------------------
// provjerava da li se radi o velikom nalogu i treba li ga uopste provjeravati ?
// -----------------------------------------------------------------------------------
static function fin_p_nalog_bez_provjere( auto )
local _ok := .f.

select psuban
set order to TAG "1"
go top

if RecCount2() > 9999 .and. !auto
    if Pitanje(, "Staviti na stanje bez provjere ?", "N" ) == "D"
        _ok := .t.
    endif
endif

return _ok



// --------------------------------------------------------------------------------------
// provjera salda naloga
// --------------------------------------------------------------------------------------
static function fin_p_saldo_provjera( id_firma, id_vn, br_nal )
local _ok := .f.
local _tmp, _saldo

// ako nije neophodna ravnoteza naloga, bye bye
if gRavnot == "N"
	_ok := .t.
	return _ok
endif

select psuban
set order to tag "1"
go top
seek id_firma + id_vn + br_nal

_saldo := 0

do while !EOF() .and. field->idfirma == id_firma .and. field->idvn == id_vn .and. field->brnal == br_nal
	
	// ima li partnera ?
	if !psuban_partner_check()
        return _ok
    endif

	// ima li konto ??
    if !psuban_konto_check()
        return _ok
  	endif

    select psuban
        
	if field->d_p == "1"
    	_saldo += field->iznosbhd
    else
        _saldo -= field->iznosbhd
    endif
    
	skip

enddo

// saldo nije dobar !!!
if ROUND( _saldo, 4 ) <> 0
	Beep(3)
    Msg( "Neophodna ravnoteza naloga " + id_firma + "-" + id_vn + "-" + ALLTRIM( br_nal ) + "##, azuriranje nece biti izvrseno!")
    return _ok
endif

// sve ok
_ok := .t.

return _ok




// -------------------------------------------------------
// provjera pomocnih tabela, prije stampe
// -------------------------------------------------------
static function fin_p_tabele_provjera( lista_naloga )
local _ok := .f.
local _i
local _id_firma, _id_vn, _br_nal

select psuban
if RecCount2() == 0
	return _ok
endif

select panal
if RecCount2() == 0
 	return _ok
endif

select psint
if RecCount2() == 0
  	return _ok
endif

// treba provjeriti ima li naloga u psuban ???? takodjer
// na osnovu liste
for _i := 1 to LEN( lista_naloga )

	_id_firma := lista_naloga[ _i, 1 ]
	_id_vn := lista_naloga[ _i, 2 ]
	_br_nal := lista_naloga[ _i, 3 ]

	select psuban
	set order to tag "1"
	go top
	seek _id_firma + _id_vn + _br_nal

	if !FOUND()
		MsgBeep( "Nalog " + _id_firma + "-" + _id_vn + "-" + ALLTRIM( _br_nal ) + " ne postoji u PSUBAN !!!" )
		return _ok
	endif	

next

_ok := .t.

return _ok




// ------------------------
// azuriraj dbf-ove
// -----------------------
function fin_azur_dbf( auto, id_firma, id_vn, br_nal )
local _n_c
local _t_area := SELECT()
local _saldo
local _ctrl 
local _ok := .t.

Box( "ad", 10, MAXCOLS() - 10 )

	log_write( "FIN, azuriranje DBF tabela " + id_firma + "-" + id_vn + "-" + br_nal + " - START", 7 )

	select psuban
	set order to tag "1"
	go top
	seek id_firma + id_vn + br_nal

	_saldo := 0

	do while !EOF() .and. field->idfirma == id_firma .and. field->idvn == id_vn .and. field->brnal == br_nal

    	_ctrl := field->idfirma + field->idvn + field->brnal

    	@ m_x + 1, m_y + 2 SAY "DBF: azuriram nalog: " + field->idfirma + "-" + field->idvn + "-" + ALLTRIM(field->brnal)

        if field->d_p == "1"
            _saldo += field->iznosbhd
        else
            _saldo -= field->iznosbhd
        endif

        skip

    enddo

    log_write( "azuriram fin nalog: " + _ctrl + " saldo " + STR( _saldo, 17, 2), 5 )

	// prebaci iz p tabele u tekucu
    pnalog_nalog( _ctrl )
    panal_anal( _ctrl )
    psint_sint( _ctrl )
    psuban_suban( _ctrl )

	// brisi iz pripreme stavke ovog naloga
	fin_pripr_delete( _ctrl )
    
	select psuban

BoxC()

return _ok



// ------------------------------------------------------------
// brisanje pomocnih tabela
// ------------------------------------------------------------
static function fin_brisi_p_tabele( close_all )
        
if close_all == NIL
	close_all := .f.
endif

select PNALOG
zapp()

select PSUBAN
zapp()
            
select PANAL
zapp()
            
select PSINT
zapp()

if close_all           
	close all
endif
 
return



// -------------------------------------------------------------
// -------------------------------------------------------------
function psuban_partner_check()
local _ok := .t.

if EMPTY( psuban->idpartner )
	return _ok
endif
      
select partn
hseek psuban->idpartner

if !FOUND()
	MsgBeep( "Stavka br." + psuban->rbr + " : Nepostojeca sifra partnera!#Partner id: " + psuban->idpartner )
	fin_brisi_p_tabele( .t. )
    o_fin_za_azuriranje()
	_ok := .f.
endif

select psuban 

return _ok



// --------------------------------------------------------------
// --------------------------------------------------------------
function psuban_konto_check()
local _ok := .t.

if EMPTY( psuban->idkonto )
	return _ok
endif
    
select konto
hseek psuban->idkonto
    
if !FOUND()
	MsgBeep( "Stavka br." + psuban->rbr + " : Nepostojeca sifra konta!#Konto id: " + psuban->idkonto )
	fin_brisi_p_tabele( .t. )
    _ok := .f.      
endif

select psuban

return _ok 



// -------------------------------------------------------------
// -------------------------------------------------------------
function panal_anal( nalog_ctrl )
local _rec

@ m_x + 3, m_y+2 SAY "ANALITIKA       "

select panal
seek nalog_ctrl

do while !EOF() .and. nalog_ctrl == IdFirma + IdVn + BrNal
    
    _rec := dbf_get_rec()

    select ANAL

    APPEND BLANK

    dbf_update_rec(_rec, .f.)

    select PANAL
    skip

enddo

return




// -------------------
// -------------------
function psint_sint( nalog_ctrl )
local _rec
  
@ m_x + 3, m_y + 2 SAY "SINTETIKA       "
select PSINT
seek nalog_ctrl

do while !EOF() .and. nalog_ctrl == IdFirma + IdVn + BrNal

    _rec:= dbf_get_rec()

    select SINT

    APPEND BLANK
    dbf_update_rec(_rec, .f.)
    
    select PSINT
    skip

enddo

return




//-----------------------
//-----------------------
function pnalog_nalog( nalog_ctrl )
local _rec

select pnalog
seek nalog_ctrl

if FOUND()

    _rec := dbf_get_rec()

    select nalog
    APPEND BLANK

    dbf_update_rec(_rec, .f.)

else

    Beep(4)
    Msg( "Greska... ponovi stampu naloga ..." )

endif

return



//-----------------------
//-----------------------
function psuban_suban( nalog_ctrl )
local nSaldo := 0
local nC := 0
local _rec

@ m_x + 3, m_y + 2 SAY "SUBANALITIKA   "

SELECT SUBAN
SET ORDER TO TAG "3"

SELECT PSUBAN
SEEK nalog_ctrl
  
nC := 0

do while !EOF() .and. nalog_ctrl == IdFirma + IdVn + BrNal

    @ m_x + 3, m_y + 25 SAY ++nC  pict "99999999999"

    _rec:= dbf_get_rec()
    
    if _rec["d_p"] == "1" 
          nSaldo:= _rec["iznosbhd"]
    else
          nSaldo:= -_rec["iznosbhd"]
    endif

    SELECT SUBAN
    SEEK _rec["idfirma"] + _rec["idkonto"] + _rec["idpartner"] + _rec["brdok"]    

    nRec := recno()
    do while  !eof() .and. (_rec["idfirma"] + _rec["idkonto"] + _rec["idpartner"] + _rec["brdok"]) == (IdFirma + IdKonto + IdPartner + BrDok)
       if _rec["d_p"] == "1"
           nSaldo += field->IznosBHD
       else
           nSaldo -= field->IznosBHD
       endif
       skip
    enddo

    if ABS(round(nSaldo, 3)) <= gnLOSt
       
        GO nRec
        do while  !EOF() .and. (_rec["idfirma"] + _rec["idkonto"] + _rec["idpartner"] + _rec["brdok"]) == (IdFirma + IdKonto + IdPartner + BrDok)
            
            _rec_2 := dbf_get_rec()
            _rec_2["otvst"] := "9"
            update_rec_server_and_dbf("fin_suban", _rec_2, 1, "FULL")

            SKIP

        enddo
        _rec["otvSt"] := "9"

    endif

    SELECT SUBAN    
    APPEND BLANK

    dbf_update_rec(_rec, .t.)

    select PSUBAN
    SKIP

enddo

return



// ------------------------------
// ------------------------------
function fin_pripr_delete( nalog_ctrl )
local _t_rec

// nalog je uravnotezen, moze se izbrisati iz PRIPR
select fin_pripr
seek nalog_ctrl

@ m_x + 3, m_y + 2 SAY "BRISEM PRIPREMU "

do while !EOF() .and. nalog_ctrl == IdFirma + IdVn + BrNal

    skip

    _t_rec := RECNO()

    skip -1

    delete

    go ( _t_rec )

enddo

__dbPack()

return .t.




// ------------------------------------------------------------
// provjeri duple stavke u pripremi za vise dokumenata
// ------------------------------------------------------------
static function prov_duple_stavke() 
local cSeekNal
local lNalExist:=.f.

select fin_pripr
go top

// provjeri duple dokumente
do while !EOF()
    cSeekNal := fin_pripr->(idfirma + idvn + brnal)
    if dupli_nalog(cSeekNal)
        lNalExist := .t.
        exit
    endif
    
    select fin_pripr
    skip
enddo

// postoje dokumenti dupli
if lNalExist
    MsgBeep("U pripremi su se pojavili dupli nalozi !!!")
    if Pitanje(,"Pobrisati duple naloge (D/N)?", "D")=="N"
        MsgBeep("Dupli nalozi ostavljeni u tabeli pripreme!#Prekidam operaciju azuriranja!")
        return 1
    else
        Box(,1,60)
            cKumPripr := "P"
            @ m_x+1, m_y+2 SAY "Zelite brisati stavke iz kumulativa ili pripreme (K/P)" GET cKumPripr VALID !Empty(cKumPripr) .or. cKumPripr $ "KP" PICT "@!"
            read
        BoxC()
        
        if cKumPripr == "P"
            // brisi pripremu
            return prip_brisi_duple()
        else
            // brisi kumulativ
            return kum_brisi_duple()
        endif
    endif
endif

return 0

// ------------------------------------------------------------
// brisi stavke iz pripreme koje se vec nalaze u kumulativu
// ------------------------------------------------------------
static function prip_brisi_duple()
local cSeek
local _brisao := .f.

select fin_pripr
go top

do while !EOF()

    cSeek := fin_pripr->(idfirma + idvn + brnal)
    
    if dupli_nalog( cSeek )
        // pobrisi stavku
        select fin_pripr
        delete
        _brisao := .t.    
    endif
    
    select fin_pripr
    skip

enddo

if _brisao
    __dbPack()
endif

return 0


// -------------------------------------------------------------
// brisi stavke iz kumulativa koje se vec nalaze u pripremi
// -------------------------------------------------------------
static function kum_brisi_duple()
local cSeek
select fin_pripr
go top

cKontrola := "XXX"

do while !EOF()
    
    cSeek := fin_pripr->(idfirma + idvn + brnal)
    
    if cSeek == cKontrola
        skip
        loop
    endif
    
    if dupli_nalog( cSeek )
        
        MsgO("Brisem stavke iz kumulativa ... sacekajte trenutak!")
        
        // brisi nalog
        select nalog
        
        if !flock()
            msg("Datoteka je zauzeta ",3)
            closeret
        endif
    
        set order to tag "1"
        go top
        seek cSeek
        
        if Found()
            
            do while !eof() .and. nalog->(idfirma+idvn+brnal) == cSeek
                skip 1
                nRec:=RecNo()
                skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
        
            // brisi iz suban
            select suban
            if !flock()
                msg("Datoteka je zauzeta ",3)
                closeret
            endif
            
            set order to tag "4"
            go top
            seek cSeek
            if Found()
                do while !EOF() .and. suban->(idfirma + idvn + brnal) == cSeek
                    
                    skip 1
                    nRec:=RecNo()
                    skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
        
            // brisi iz sint
            select sint
            if !flock()
                msg("Datoteka je zauzeta ",3)
                closeret
            endif
        
            set order to tag "2"
            go top
            seek cSeek
            if Found()
                do while !EOF() .and. sint->(idfirma + idvn + brnal) == cSeek
                    
                    skip 1
                    nRec:=RecNo()
                    skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
            
            // brisi iz anal
            select anal
            if !flock()
                msg("Datoteka je zauzeta ",3)
                closeret
            endif
            
            set order to tag "2"
            go top
            seek cSeek
            if Found()
                do while !EOF() .and. anal->(idfirma + idvn + brnal) == cSeek
                    skip 1
                    nRec:=RecNo()
                    skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
        
    
            MsgC()
       endif
    
       cKontrola := cSeek
    
       select fin_pripr
       skip

enddo

return 0




// ------------------------------------------
// provjerava da li je dokument dupli
// ------------------------------------------
static function dupli_nalog(cSeek)
select nalog
set order to tag "1"
go top
seek cSeek
if Found()
    return .t.
endif
return .f.



// ------------------------------------------------------------
// postoji fin nalog ?
// ------------------------------------------------------------
function fin_doc_exist( id_firma, id_vn, br_nal )
local _exist := .f.
local _tbl, _result

_tbl := "fmk.fin_nalog"
_result := table_count( _tbl, "idfirma=" + _sql_quote( id_firma ) + " AND idvn=" + _sql_quote( id_vn ) + " AND brnal=" + _sql_quote( br_nal ) ) 

if _result <> 0
    _exist := .t.
endif

return _exist



// --------------------------------
// validacija broja naloga
// --------------------------------
static function __val_nalog( cNalog )
local lRet := .t.
local cTmp
local cChar
local i

cTmp := RIGHT( cNalog, 4 )

// vidi jesu li sve brojevi
for i := 1 to LEN( cTmp )
    
    cChar := SUBSTR( cTmp, i, 1 )
    
    if cChar $ "0123456789"
        loop
    else
        lRet := .f.
        exit
    endif

next

return lRet




// ----------------------------------------------------------------
// specijalna funkcija regeneracije brojeva naloga u kum tabelama
// C(4) -> C(8) konverzija
// stari broj A001 -> 0000A001
// ----------------------------------------------------------------
function regen_tbl()

if !SigmaSIF("REGEN")
    MsgBeep("Ne diraj lava dok spava !")
    return
endif

// otvori sve potrebne tabele
O_SUBAN

if LEN( suban->brnal ) = 4
    msgbeep("potrebno odraditi modifikaciju FIN.CHS prvo !")
    return
endif

O_NALOG
O_ANAL
O_SINT

// pa idemo redom
select suban
_renum_convert()
select nalog
_renum_convert()
select anal
_renum_convert()
select sint
_renum_convert()

return


// --------------------------------------------------
// konvertuje polje BRNAL na zadatoj tabeli
// --------------------------------------------------
static function _renum_convert()
local xValue
local nCnt
local _rec

set order to tag "0"
go top

Box(,2,50)

@ m_x + 1, m_y + 2 SAY "Konvertovanje u toku... "

f18_lock_tables({LOWER(ALIAS())})

sql_table_update( nil, "BEGIN" )

nCnt := 0
do while !EOF()

    xValue := field->brnal

    if !EMPTY(xValue)
        
        _rec := dbf_get_rec()
        _rec["brnal"] := PADL( ALLTRIM( xValue ), 8, "0" )
        update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )
        ++ nCnt

    endif

    @ m_x + 2, m_y + 2 SAY PADR( "odradjeno " + ALLTRIM(STR(nCnt)), 45 )

    skip

enddo

f18_free_tables({LOWER(ALIAS())})
sql_table_update( nil, "END" )

BoxC()

return


