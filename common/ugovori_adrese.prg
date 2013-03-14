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


#include "fmk.ch"


// --------------------------------------------------
// labeliranje adresa iz ugovora
// --------------------------------------------------
function kreiraj_adrese_iz_ugovora()
local _id_roba, _partner, _ptt, _mjesto
local _n_sort, _dat_do, _g_dat
local _filter := ""
local _index_sort := ""
local _rec, _usl_partner, _usl_mjesto, _usl_ptt
local _ima_destinacija
local _count := 0
local _total_kolicina := 0

PushWA()

// otvori potrebne tabele
_open_tables()

// parametri izvjestaja - stampe
_id_roba := PADR( fetch_metric( "ugovori_naljepnice_idroba", my_user(), SPACE(10) ), 10 )
_partner := PADR( fetch_metric( "ugovori_naljepnice_partner", my_user(), SPACE(300) ), 300 )
_ptt := PADR( fetch_metric( "ugovori_naljepnice_ptt", my_user(), SPACE(300) ), 300 )
_mjesto := PADR( fetch_metric( "ugovori_naljepnice_mjesto", my_user(), SPACE(300) ), 300 )
_n_sort := fetch_metric( "ugovori_naljepnice_sort", my_user(), "4" )

_dat_do := DATE()
_g_dat := "N"

Box(, 15, 77 )

    do while .t.

        @ m_x + 0, m_y + 5 SAY "POSTAVLJENJE USLOVA ZA PRAVLJENJE LABELA"
        @ m_x + 2, m_y + 2 SAY "Artikal  :" GET _id_roba VALID P_Roba( @_id_roba ) PICT "@!"
        @ m_x + 3, m_y + 2 SAY "Partner  :" GET _partner PICT "@S50!"
        @ m_x + 4, m_y + 2 SAY "Mjesto   :" GET _mjesto PICT "@S50!"
        @ m_x + 5, m_y + 2 SAY "PTT      :" GET _ptt PICT "@S50!"
        @ m_x + 6, m_y + 2 SAY "Gledati tekuci datum (D/N):" GET _g_dat ;
            VALID _g_dat $ "DN" PICT "@!"
        @ m_x + 7, m_y + 2 SAY "**** Nacin sortiranja podataka u pregledu: "
        @ m_x + 8, m_y + 2 SAY " 1 - kolicina + mjesto + naziv"
        @ m_x + 9, m_y + 2 SAY " 2 - mjesto + naziv + kolicina"
        @ m_x + 10, m_y + 2 SAY " 3 - PTT + mjesto + naziv + kolicina"
        @ m_x + 11, m_y + 2 SAY " 4 - kolicina + PTT + mjesto + naziv" 
        @ m_x + 12, m_y + 2 SAY " 5 - idpartner" 
        @ m_x + 13, m_y + 2 SAY " 6 - kolicina"
        @ m_x + 14, m_y + 2 SAY "odabrana vrijednost:" GET _n_sort VALID _n_sort $ "1234567" PICT "9"
        READ

        IF LASTKEY()==K_ESC
            BoxC()
            RETURN
        ENDIF
 
        _usl_partner := Parsiraj( _partner, "IDPARTNER" )
        _usl_ptt  := Parsiraj( _ptt, "PTT"       )
        _usl_mjesto := Parsiraj( _mjesto, "MJESTO" )

        if _usl_partner <> NIL .and. _usl_mjesto <> NIL .and. _usl_ptt <> NIL
            EXIT
        endif

    ENDDO

BoxC()

// snimi parametre
set_metric( "ugovori_naljepnice_idroba", my_user(), _id_roba )
set_metric( "ugovori_naljepnice_partner", my_user(), ALLTRIM( _partner ) )
set_metric( "ugovori_naljepnice_ptt", my_user(), ALLTRIM( _ptt ) )
set_metric( "ugovori_naljepnice_mjesto", my_user(), ALLTRIM( _mjesto ) )
set_metric( "ugovori_naljepnice_sort", my_user(), _n_sort )

// sredi index
_index_sort := _index_sort + ALLTRIM( _n_sort )

// kreiraj "labelu.dbf"
_create_labelu_dbf()

// otvori potrebne tabele i postavi sortove...
if is_dest()
    select dest
    set filter to
endif

select ugov
set filter to

select rugov
set filter to

if !EMPTY( _id_roba )
    set filter to idroba == _id_roba
endif

go top

Box(, 3, 60 )

// vrtim se kroz rugov
do while !EOF()

    // pronadji ugovor
    select ugov
    set order to tag "ID"
    go top
    seek rugov->id

    @ m_x + 1, m_y + 2 SAY "Ugovor ID: " + PADR( rugov->id, 10 )
    @ m_x + 2, m_y + 2 SAY PADR( "", 60 )
    @ m_x + 3, m_y + 2 SAY PADR( "", 60 )

    // nema tog ugovora ... preskoci !!!
    if !FOUND()
        MsgBeep( "Ugovor " + rugov->id + " ne postoji !!! Preskacem..." )
        select rugov
        skip
        loop
    endif
    
    // dodatni uslovi za preskakanje...

    // ugovor aktivan ?
    if field->aktivan == "N"
        select rugov
        skip
        loop
    endif

    // printati labelu ??
    if field->lab_prn == "N"
        select rugov
        skip
        loop
    endif

    // pogledaj i datum ugovora, ako je istekao 
    // ne stampaj labelu
    if _g_dat == "D" .and. ( _dat_do > ugov->datdo )
        select rugov
        skip 
        loop
    endif

    // partner ?
    if !EMPTY( _partner )
        if !(&_usl_partner)
            select rugov
            skip
            loop
        endif
    endif

    // predji na partnere
    select partn
    seek ugov->idpartner
 
    if !FOUND()
        Msgbeep( "Partner " + ugov->idpartner + " ne postoji, preskacem !!!" )
        select rugov
        skip
        loop
    endif

    // ptt ?
    if !EMPTY( _ptt )
        if !(&_usl_ptt)
            select rugov
            skip
            loop
        endif
    endif

    // mjesto ?
    if !EMPTY( _mjesto )
        if !(&_usl_mjesto)
            select rugov
            skip
            loop
        endif
    endif

    select labelu
    append blank

    _rec := dbf_get_rec()

    _rec["idpartner"] := ugov->idpartner
    _rec["kolicina"] := rugov->kolicina
    _rec["idroba"] := rugov->idroba
    _rec["kol_c"] := PADL( ALLTRIM( STR( rugov->kolicina, 12, 0 ) ), 5, "0" )

    _total_kolicina += rugov->kolicina

    @ m_x + 2, m_y + 2 SAY "Partner: " + ugov->idpartner
        
    _ima_destinacija := .f.

    // vidi ima li ovaj ugovor destinacije ?
    if is_dest() .and. !EMPTY( rugov->dest )
            
        select dest
        set order to tag "ID"
        go top
        seek ( ugov->idpartner + rugov->dest )

        if FOUND()
            _ima_destinacija := .t.
        endif

    endif

    select labelu
    
    // ako je destinacija, uzmi info iz tabele DEST
    if _ima_destinacija

        _rec["destin"] := dest->id
        _rec["naz"] := dest->naziv
        _rec["naz2"] := dest->naziv2
        _rec["ptt"] := UPPER( dest->ptt )
        _rec["mjesto"] := UPPER( dest->mjesto )
        _rec["telefon"] := dest->telefon
        _rec["fax"] := dest->fax
        _rec["adresa"] := dest->adresa
        
    else  
        
        // nije naznacena destinacija
        // parametre uzimam iz tabele PARTN

        _rec["destin"] := ""
        _rec["naz"] := partn->naz
        _rec["naz2"] := partn->naz2
        _rec["ptt"] := UPPER( partn->ptt )
        _rec["mjesto"] := UPPER( partn->mjesto )
        _rec["telefon"] := partn->telefon
        _rec["fax"] := partn->fax
        _rec["adresa"] := partn->adresa
        
    endif
    
    dbf_update_rec( _rec )

    @ m_x + 3, m_y + 2 SAY "Ukupno prebaceno: " + ALLTRIM( STR( ++_count ) )

    select rugov
    skip

enddo

BoxC()

// nije nista generisano !!! mogu izaci
if _count == 0
    MsgBeep( "Nema generisanih adresa !!!" ) 
    select ugov
    return
endif

// prebaci naljenpnice za tabelu lab2
label_to_lab2( _index_sort )


MsgBeep( "Ukupno generisano " + ALLTRIM( STR( _count ) ) + ;
        " naljepnica, kolicina: " + ALLTRIM( STR( _total_kolicina, 12, 0 ) ) )

// stampaj pregled naljepnica...
stampa_pregleda_naljepnica( _index_sort )

// stampaj labelu...
// pozovi funkciju stampanja rtm fajla kroz labeliranje.exe
f18_rtm_print( "labelu", "lab2", "1", NIL, "labeliranje" )

// otvori ponovo tabele ugovora
_open_tables()

PopWA()

return


// -------------------------------------------------------------
// prebacuje sve iz labelu u lab2 
// ali tu ima index samo po polju IDX (numerickom)
// -------------------------------------------------------------
static function label_to_lab2( index_sort )
local _rec
local _count := 0

select labelu
set order to tag &index_sort
go top

do while !EOF()
    
    _rec := dbf_get_rec()
    
    select lab2
    append blank

    _rec["idx"] := ++_count

    dbf_update_rec( _rec )

    select labelu
    skip

enddo

select lab2
use

return .t.



// -----------------------------------------------------------------------
// stampa pregleda naljepnica
// -----------------------------------------------------------------------
static function stampa_pregleda_naljepnica( index_sort )
local _table_type := 1
private _index := index_sort

select labelu
// (ovako ce indeks profercerati kako treba ...)
set order to tag &_index
go top

aKol := {}

if lSpecifZips
    AADD( aKol, { "Sifra izdanja", {|| IDROBA       }, .f., "C", 13, 0, 1, 1} )
else
    AADD( aKol, { "Artikal"      , {|| IDROBA       }, .f., "C", 10, 0, 1, 1} )
endif

AADD( aKol, { "Partner"      , {|| IdPartner    }, .f., "C",  6, 0, 1, 2} )
AADD( aKol, { "Dest."        , {|| Destin       }, .f., "C",  6, 0, 1, 3} )
AADD( aKol, { "Kolicina"     , {|| Kolicina     }, .t., "N", 12, 0, 1, 4} )
AADD( aKol, { "PTT"          , {|| PTT          }, .f., "C",  5, 0, 1, 5} )
AADD( aKol, { "Mjesto"       , {|| MJESTO       }, .f., "C", 16, 0, 1, 6} )
AADD( aKol, { "Naziv"        , {|| PADR( ALLTRIM( naz ) + ", " + ALLTRIM( naz2 ), 60 ) }, .f., "C", 60, 0, 1, 7} )
AADD( aKol, { "Adresa"       , {|| ADRESA       }, .f., "C", 40, 0, 1, 8} )
AADD( aKol, { "Telefon"      , {|| TELEFON      }, .f., "C", 12, 0, 1, 9} )
AADD( aKol, { "Fax"          , {|| FAX          }, .f., "C", 12, 0, 1,10} )

StartPrint()

StampaTabele( aKol, NIL, NIL, _table_type, NIL, NIL, "PREGLED BAZE PRIPREMLJENIH NALJEPNICA", , , , , )

EndPrint()

close all

return


// otvori tabele bitne za ugovore
static function _open_tables()

select ( F_UGOV )
if !USED()
    O_UGOV
endif

select ( F_RUGOV )
if !USED()
    O_RUGOV
endif

select ( F_DEST )
if !USED()
    O_DEST
endif

select ( F_PARTN )
if !USED()
    O_PARTN
endif

select ( F_ROBA )
if !USED()
    O_ROBA
endif

select ( F_SIFK )
if !USED()
    O_SIFK
endif

select ( F_SIFV )
if !USED()
    O_SIFV
endif

select ugov

return



static function _create_labelu_dbf()
local _dbf := {}
local _table_label := "labelu"
local _table_label_2 := "lab2"

AADD ( _dbf, { "idroba",    "C",     10, 0 })
AADD ( _dbf, { "idpartner", "C",      6, 0 })
AADD ( _dbf, { "destin"  ,  "C",      6, 0 })
AADD ( _dbf, { "kol_c",     "C",      5, 0 })
AADD ( _dbf, { "naz" ,      "C",     40, 0 })
AADD ( _dbf, { "naz2",      "C",     40, 0 })
AADD ( _dbf, { "ptt" ,      "C" ,    10, 0 })
AADD ( _dbf, { "mjesto" ,   "C" ,    20, 0 })
AADD ( _dbf, { "adresa" ,   "C" ,    40, 0 })
AADD ( _dbf, { "telefon",   "C" ,    20, 0 })
AADD ( _dbf, { "fax"    ,   "C" ,    20, 0 })
AADD ( _dbf, { "kolicina",  "N",     12, 0 })
AADD ( _dbf, { "idx",       "N",     12, 0 })

select ( F_LABELU )
use

// brisi tabelu i indeks
// napravi ponovo
FERASE( my_home() + _table_label + ".dbf" )
FERASE( my_home() + _table_label + ".cdx" )

Dbcreate( my_home() + _table_label + ".dbf", _dbf )

select ( F_LABELU )
use
my_use_temp( "labelu", my_home() + _table_label + ".dbf", .f., .f. )

// indeksiraj tabelu
index on ( kol_c + PADR( mjesto, 20, " " ) + PADR( naz, 40, " " ) ) tag "1"
index on ( mjesto + naz + kol_c ) tag "2"
index on ( ptt + mjesto + naz + kol_c ) tag "3"
index on ( kol_c + ptt + mjesto + naz ) tag "4"
index on ( idpartner ) tag "5"
index on ( kol_c ) tag "6"

// sada mi kreiraj tabelu "lab2"

FERASE( my_home() + _table_label_2 + ".dbf" )
FERASE( my_home() + _table_label_2 + ".cdx" )

SELECT ( F_TMP_1 )
USE

Dbcreate( my_home() + _table_label_2 + ".dbf", _dbf )

select ( F_TMP_1 )
use
my_use_temp( "lab2", my_home() + _table_label_2 + ".dbf", .f., .f. )

// indeksiraj tabelu
index on ( STR( idx, 12, 0 ) ) tag "1"


return




