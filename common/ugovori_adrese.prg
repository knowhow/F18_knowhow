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

Box(,11,77)

    do while .t.

        @ m_x+0, m_y+5 SAY "POSTAVLJENJE USLOVA ZA PRAVLJENJE LABELA"
        @ m_x+2, m_y+2 SAY "Artikal  :" GET _id_roba VALID P_Roba( @_id_roba ) PICT "@!"
        @ m_x+3, m_y+2 SAY "Partner  :" GET _partner PICT "@S50!"
        @ m_x+4, m_y+2 SAY "Mjesto   :" GET _mjesto PICT "@S50!"
        @ m_x+5, m_y+2 SAY "PTT      :" GET _ptt PICT "@S50!"
        @ m_x+6, m_y+2 SAY "Gledati tekuci datum (D/N):" GET _g_dat ;
            VALID _g_dat $ "DN" PICT "@!"
        @ m_x+7, m_y+2 SAY "Nacin sortiranja (1-kolicina+mjesto+naziv ,"
        @ m_x+8, m_y+2 SAY "                  2-mjesto+naziv+kolicina ,"
        @ m_x+9, m_y+2 SAY "                  3-PTT+mjesto+naziv+kolicina),"
        @ m_x+10, m_y+2 SAY "                  4-kolicina+PTT+mjesto+naziv)," 
        @ m_x+11, m_y+2 SAY "                  5-idpartner)," ;
            GET _n_sort VALID _n_sort $ "12345" PICT "9"
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
        _rec["ptt"] := dest->ptt
        _rec["mjesto"] := dest->mjesto
        _rec["telefon"] := dest->telefon
        _rec["fax"] := dest->fax
        _rec["adresa"] := dest->adresa
        
    else  
        
        // nije naznacena destinacija
        // parametre uzimam iz tabele PARTN

        _rec["destin"] := ""
        _rec["naz"] := partn->naz
        _rec["naz2"] := partn->naz2
        _rec["ptt"] := partn->ptt
        _rec["mjesto"] := partn->mjesto
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

MsgBeep( "Ukupno generisano " + ALLTRIM( STR( _count ) ) + ;
        " naljepnica, kolicina: " + ALLTRIM( STR( _total_kolicina, 12, 0 ) ) )

// stampaj pregled naljepnica...
stampa_pregleda_naljepnica( _n_sort )

// stampaj labelu...
// pozovi funkciju stampanja rtm fajla kroz labeliranje.exe
f18_rtm_print( "labelu", "labelu", _n_sort, NIL, "labeliranje" )

// otvori ponovo tabele ugovora
_open_tables()

PopWA()

return


// -----------------------------------------------------------------------
// stampa pregleda naljepnica
// -----------------------------------------------------------------------
static function stampa_pregleda_naljepnica( index_sort )

select labelu
set order to tag index_sort
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
AADD( aKol, { "Naziv"        , {|| Naz          }, .f., "C", 60, 0, 1, 5} )
AADD( aKol, { "Naziv2"       , {|| Naz2         }, .f., "C", 60, 0, 1, 6} )
AADD( aKol, { "PTT"          , {|| PTT          }, .f., "C",  5, 0, 1, 7} )
AADD( aKol, { "Mjesto"       , {|| MJESTO       }, .f., "C", 16, 0, 1, 8} )
AADD( aKol, { "Adresa"       , {|| ADRESA       }, .f., "C", 40, 0, 1, 9} )
AADD( aKol, { "Telefon"      , {|| TELEFON      }, .f., "C", 12, 0, 1,10} )
AADD( aKol, { "Fax"          , {|| FAX          }, .f., "C", 12, 0, 1,11} )

StartPrint()

StampaTabele( aKol, {|| BlokSLU() }, , gTabela, , , "PREGLED BAZE PRIPREMLJENIH LABELA", , , , , )

close all

EndPrint()

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
local _table := "labelu"

AADD ( _dbf, {"IDROBA", "C",  10, 0 })
AADD ( _dbf, {"IdPartner", "C",  6, 0 })
AADD ( _dbf, {"Destin"  , "C", 6, 0 })
AADD ( _dbf, {"Kolicina", "N",  12, 0 })
AADD ( _dbf, {"Naz" , "C", 60, 0 })
AADD ( _dbf, {"Naz2", "C", 60, 0 })
AADD ( _dbf, {"PTT" , 'C' ,   5 ,  0 })
AADD ( _dbf, {"MJESTO" , 'C' ,  16 ,  0 })
AADD ( _dbf, {"ADRESA" , 'C' ,  40 ,  0 })
AADD ( _dbf, {"TELEFON", 'C' ,  12 ,  0 })
AADD ( _dbf, {"FAX"    , 'C' ,  12 ,  0 })

Dbcreate( my_home() + _table + ".dbf", _dbf )

select (F_LABELU)
use

my_use_temp( "labelu", my_home() + _table + ".dbf", .f., .f. )

index on ( STR( kolicina, 12, 0 ) + mjesto + naz ) tag "1"
index on ( mjesto + naz + STR( kolicina, 12, 0 ) ) tag "2"
index on ( ptt + mjesto + naz + STR( kolicina, 12, 0 ) ) tag "3"
index on ( STR( kolicina, 12, 0 ) + ptt + mjesto + naz ) tag "4"
index on ( idpartner ) tag "5"

return


static function BlokSLU()
return



