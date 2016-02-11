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



// -----------------------------------
// otvaranje potrebnih tabela
// -----------------------------------
static function _o_tbl()
O_KALK_DOKS
O_KALK
O_SIFK
O_SIFV
O_TDOK
O_ROBA
O_KONCIJ
O_KONTO
O_PARTN
return


// -----------------------------------------------
// pomocna tabela finansijskog stanja magacina
//
// uslovi koji se u hash matrici trebaju koristi
// su:
// - "vise_konta" (D/N)
// - "konto" (lista konta ili jedan konto)
// - "datum_od"
// - "datum_do"
// - "tarife"
// - "vrste_dok"
//
// -----------------------------------------------
function kalk_gen_fin_stanje_magacina( vars )
local _konto := ""
local _datum_od := DATE()
local _datum_do := DATE()
local _tarife := ""
local _vrste_dok := ""
local _id_firma := gFirma
local _vise_konta := .f.
local _t_area, _t_rec
local _ulaz, _izlaz, _rabat
local _nv_ulaz, _nv_izlaz, _vp_ulaz, _vp_izlaz
local _marza, _marza_2, _tr_prevoz, _tr_prevoz_2
local _tr_bank, _tr_zavisni, _tr_carina, _tr_sped
local _br_fakt, _tip_dok, _tip_dok_naz, _id_partner
local _partn_naziv, _partn_ptt, _partn_mjesto, _partn_adresa
local _broj_dok, _dat_dok
local _usl_konto := ""
local _usl_vrste_dok := ""
local _usl_tarife := ""
local _gledati_usluge := "N"
local _v_konta := "N"
local _cnt := 0

// uslovi generisanja se uzimaju iz hash matrice
// moguce vrijednosti su:
if HB_HHASKEY( vars, "vise_konta" )
    _v_konta := vars["vise_konta"]
endif

if HB_HHASKEY( vars, "konto" )
    _konto := vars["konto"]
endif

if HB_HHASKEY( vars, "datum_od" )
    _datum_od := vars["datum_od"]
endif

if HB_HHASKEY( vars, "datum_do" )
    _datum_do := vars["datum_do"]
endif

if HB_HHASKEY( vars, "tarife" )
    _tarife := vars["tarife"]
endif

if HB_HHASKEY( vars, "vrste_dok" )
    _vrste_dok := vars["vrste_dok"]
endif

if HB_HHASKEY( vars, "gledati_usluge" )
    _gledati_usluge := vars["gledati_usluge"]
endif


// napravi pomocnu tabelu
_cre_tmp_tbl()

// otvori ponovo tabele izvjestaja
_o_tbl()

if _v_konta == "D"
    _vise_konta := .t.
endif

// parsirani uslovi...
if _vise_konta .and. !EMPTY( _konto )
    _usl_konto := Parsiraj( _konto, "mkonto" )
endif

if !EMPTY( _tarife )
    _usl_tarife := Parsiraj( _tarife, "idtarifa" )
endif

if !EMPTY( _vrste_dok )
    _usl_vrste_dok := Parsiraj( _vrste_dok, "idvd" )
endif

// sinteticki konto
if !_vise_konta
    if LEN(TRIM( _konto )) <= 3 .or. "." $ _konto
        if "." $ _konto
            _konto := STRTRAN( _konto, ".", "" )
        endif
        _konto := TRIM( _konto )
    endif
endif

select kalk
set order to tag "5"
// "idFirma+dtos(datdok)+idvd+brdok+rbr"

HSEEK _id_firma

select koncij
seek TRIM( _konto )

select kalk

Box(, 2, 60 )

@ m_x + 1, m_y + 2 SAY PADR( "Generisanje pomocne tabele u toku...", 58 ) COLOR "I"

do while !EOF() .and. _id_firma == field->idfirma .and. IspitajPrekid()

    if !_vise_konta .and. field->mkonto <> _konto
        skip
        loop
    endif

    // ispitivanje konta u varijanti jednog konta i datuma
    if ( field->datdok < _datum_od .or. field->datdok > _datum_do )
        skip
        loop
    endif

    // ispitivanje konta u varijanti vise konta
    if _vise_konta .and. !EMPTY( _usl_konto )
        if !Tacno( _usl_konto )
            skip
            loop
        endif
    endif

    // vrste dokumenata
    if !EMPTY( _usl_vrste_dok )
        if !Tacno( _usl_vrste_dok )
            skip
            loop
        endif
    endif

    // tarife...
    if !EMPTY( _usl_tarife )
        if !Tacno( _usl_tarife )
            skip
            loop
        endif
    endif

    // resetuj varijable...
    _ulaz := 0
    _izlaz := 0
    _vp_ulaz := 0
    _vp_izlaz := 0
    _nv_ulaz := 0
    _nv_izlaz := 0
    _rabat := 0
    _marza := 0
    _marza_2 := 0
    _tr_bank := 0
    _tr_zavisni := 0
    _tr_carina := 0
    _tr_prevoz := 0
    _tr_prevoz_2 := 0
    _tr_sped := 0


    // pokupi mi varijable bitne za azuriranje u export tabelu...
    _id_d_firma := field->idfirma
    _d_br_dok := field->brdok
    _br_fakt := field->brfaktp
    _id_partner := field->idpartner
    _dat_dok := field->datdok
    _broj_dok := field->idvd + "-" + field->brdok
    _tip_dok := field->idvd

    _t_area := SELECT()

    select tdok
    HSEEK _tip_dok
    _tip_dok_naz := field->naz

    select partn
    HSEEK _id_partner

    _partn_naziv := field->naz
    _partn_ptt := field->ptt
    _partn_mjesto := field->mjesto
    _partn_adresa := field->adresa

    select ( _t_area )

    do while !EOF() .and. _id_firma + DTOS( _dat_dok ) + _broj_dok == field->idfirma + DTOS(field->datdok) + field->idvd + "-" + field->brdok .and. IspitajPrekid()

        // ispitivanje konta u varijanti jednog konta i datuma
        if !_vise_konta .and. ( field->datdok < _datum_od .or. field->datdok > _datum_do .or. field->mkonto <> _konto )
            skip
            loop
        endif

        // ispitivanje konta u varijanti vise konta
        if _vise_konta .and. !EMPTY( _usl_konto )
            if !Tacno( _usl_konto )
                skip
                loop
            endif
        endif

        // vrste dokumenata
        if !EMPTY( _usl_vrste_dok )
            if !Tacno( _usl_vrste_dok )
                skip
                loop
            endif
        endif

        // tarife...
        if !EMPTY( _usl_tarife )
            if !Tacno( _usl_tarife )
                skip
                loop
            endif
        endif

        select roba
        HSEEK kalk->idroba

        // treba li gledati usluge ??
        if _gledati_usluge == "N" .and. roba->tip $ "U"
            select kalk
            skip
            loop
        endif

        select kalk

        // saberi vrijednosti...
        if field->mu_i == "1" .and. !( field->idvd $ "12#22#94" )
            // ulazne kalkulacije
            _vp_ulaz += ROUND( field->vpc * ( field->kolicina - field->gkolicina - field->gkolicin2 ), gZaokr )
            _nv_ulaz += ROUND( field->nc *( field->kolicina - field->gkolicina - field->gkolicin2 ), gZaokr )
        elseif field->mu_i == "5"
            // izlazne kalkulacije
            _vp_izlaz += ROUND( field->vpc * field->kolicina, gZaokr )
            _rabat += ROUND( (field->rabatv / 100) * field->vpc * field->kolicina, gZaokr )
            _nv_izlaz += ROUND( field->nc * field->kolicina, gZaokr )
        elseif field->mu_i == "1" .and. ( field->idvd $ "12#22#94" )
            // povrati
            _vp_izlaz -= ROUND( field->vpc * field->kolicina, gZaokr )
            _rabat -= ROUND( ( field->rabatv / 100 ) * field->vpc * field->kolicina, gZaokr )
            _nv_izlaz -= ROUND( field->nc * field->kolicina, gZaokr )
        elseif field->mu_i == "3"
            // nivelacija
            _vp_ulaz += ROUND( field->vpc * field->kolicina, gZaokr )
        endif

        _marza += MMarza()
        _marza_2 += MMarza2()
        _tr_prevoz += field->prevoz
        _tr_prevoz_2 += field->prevoz2
        _tr_bank += field->banktr
        _tr_sped += field->spedtr
        _tr_carina += field->cardaz
        _tr_zavisni += field->zavtr

        skip 1

    enddo

    @ m_x + 2, m_y + 2 SAY "Dokument: " + _id_d_firma + "-" + _tip_dok + "-" + _d_br_dok

    _add_to_exp( _id_d_firma, _tip_dok, _d_br_dok, _dat_dok, _tip_dok_naz, _id_partner, ;
                _partn_naziv, _partn_mjesto, _partn_ptt, _partn_adresa, _br_fakt, ;
                _nv_ulaz, _nv_izlaz, _nv_ulaz - _nv_izlaz, ;
                _vp_ulaz, _vp_izlaz, _vp_ulaz - _vp_izlaz, ;
                _rabat, _marza, _marza_2, ;
                _tr_prevoz, _tr_prevoz_2, _tr_bank, _tr_sped, _tr_carina, _tr_zavisni )

    ++ _cnt

enddo

BoxC()

return _cnt


// ----------------------------------------------
// kreiranje pomocne tabele izvjestaja
// ----------------------------------------------
static function _cre_tmp_tbl()
local _dbf := {}

AADD( _dbf, { "idfirma"   , "C",  2, 0 } )
AADD( _dbf, { "idvd"      , "C",  2, 0 } )
AADD( _dbf, { "brdok"     , "C",  8, 0 } )
AADD( _dbf, { "datum"     , "D",  8, 0 } )
AADD( _dbf, { "vr_dok"    , "C", 30, 0 } )
AADD( _dbf, { "idpartner" , "C",  6, 0 } )
AADD( _dbf, { "part_naz"  , "C",100, 0 } )
AADD( _dbf, { "part_mj"   , "C", 50, 0 } )
AADD( _dbf, { "part_ptt"  , "C", 10, 0 } )
AADD( _dbf, { "part_adr"  , "C", 50, 0 } )
AADD( _dbf, { "br_fakt"   , "C", 20, 0 } )
AADD( _dbf, { "nv_dug"    , "N", 15, 2 } )
AADD( _dbf, { "nv_pot"    , "N", 15, 2 } )
AADD( _dbf, { "nv_saldo"  , "N", 15, 2 } )
AADD( _dbf, { "vp_dug"    , "N", 15, 2 } )
AADD( _dbf, { "vp_pot"    , "N", 15, 2 } )
AADD( _dbf, { "vp_saldo"  , "N", 15, 2 } )
AADD( _dbf, { "vp_rabat"  , "N", 15, 2 } )
AADD( _dbf, { "marza"     , "N", 15, 2 } )
AADD( _dbf, { "marza2"    , "N", 15, 2 } )
AADD( _dbf, { "t_prevoz"  , "N", 15, 2 } )
AADD( _dbf, { "t_prevoz2" , "N", 15, 2 } )
AADD( _dbf, { "t_bank"    , "N", 15, 2 } )
AADD( _dbf, { "t_sped"    , "N", 15, 2 } )
AADD( _dbf, { "t_cardaz"  , "N", 15, 2 } )
AADD( _dbf, { "t_zav"     , "N", 15, 2 } )

t_exp_create( _dbf )

return _dbf


// ---------------------------------------
// dodaj podatke u r_export tabelu
// ---------------------------------------
static function _add_to_exp( id_firma, id_tip_dok, broj_dok, datum_dok, vrsta_dok, id_partner, ;
                            part_naz, part_mjesto, part_ptt, part_adr, broj_fakture, ;
                            n_v_dug, n_v_pot, n_v_saldo, ;
                            v_p_dug, v_p_pot, v_p_saldo, ;
                            v_p_rabat, marza, marza_2, tr_prevoz, tr_prevoz_2, ;
                            tr_bank, tr_sped, tr_carina, tr_zavisni )

local _t_area := SELECT()
local _rec

O_R_EXP

APPEND BLANK

_rec := hb_hash()
_rec["idfirma"] := id_firma
_rec["idvd"] := id_tip_dok
_rec["brdok"] := broj_dok
_rec["datum"] := datum_dok
_rec["vr_dok"] := vrsta_dok
_rec["idpartner"] := id_partner
_rec["part_naz"] := part_naz
_rec["part_mj"] := part_mjesto
_rec["part_ptt"] := part_ptt
_rec["part_adr"] := part_adr
_rec["br_fakt"] := broj_fakture
_rec["nv_dug"] := n_v_dug
_rec["nv_pot"] := n_v_pot
_rec["nv_saldo"] := n_v_saldo
_rec["vp_dug"] := v_p_dug
_rec["vp_pot"] := v_p_pot
_rec["vp_saldo"] := v_p_saldo
_rec["vp_rabat"] := v_p_rabat
_rec["marza"] := marza
_rec["marza2"] := marza_2
_rec["t_prevoz"] := tr_prevoz
_rec["t_prevoz2"] := tr_prevoz_2
_rec["t_bank"] := tr_bank
_rec["t_sped"] := tr_sped
_rec["t_cardaz"] := tr_carina
_rec["t_zav"] := tr_zavisni

dbf_update_rec( _rec )

select (_t_area)
return
