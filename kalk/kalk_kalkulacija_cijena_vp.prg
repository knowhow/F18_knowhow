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


// ---------------------------------------------
// stampa dokumenta kalkulacija cijena vp (odt)
// ---------------------------------------------
function kalkulacija_cijena_vp( azurirana )
local _vars
local _template := F18_TEMPLATE_LOCATION + "kalk_vp.odt"

if azurirana == NIL
    azurirana := .t.
endif

// otvori sve potrebne tabele
o_tables( azurirana )

if azurirana .and. !get_vars( @_vars )
    return
endif

if !azurirana
    // podatke uzmi odmah iz pripreme
    _vars := hb_hash()
    _vars["id_firma"] := kalk_pripr->idfirma
    _vars["tip_dok"] := kalk_pripr->idvd
    _vars["br_dok"] := kalk_pripr->brdok
endif 

// provjeri da li dokument moze da se stampa
if ! (_vars["tip_dok"] $ "10" )
    return
endif

// generisi xml na osnovu dokumenta
if generisi_xml( _vars ) > 0
    // stampaj template fajl sa podacima
    st_kalkulacija_cijena_odt( _template )
endif

return


// ----------------------------------------------
// stampaj odt dokument
// ----------------------------------------------
function st_kalkulacija_cijena_odt( template_file )
local _jod_bin 
local _oo_bin
local _oo_writer_exe
local _oo_params := ""
local _java_start 
local _cmd
local _data_xml := my_home() + "kalkdata.xml"
local _out_file := my_home() + "out.odt"
local _sv_screen
local _template
local _office
local _template_file

_template := ALLTRIM( template_file )
_oo_bin := ALLTRIM( fetch_metric( "openoffice_bin", my_user(), "" ) )
_oo_writer_exe := ALLTRIM( fetch_metric( "openoffice_writer", my_user(), "" ) )
_java_start := ALLTRIM( fetch_metric( "java_start_cmd", my_user(), "" ) )
_jod_bin := ALLTRIM( fetch_metric( "jodreports_bin", my_user(), "" ) )
_office := _oo_bin + _oo_writer_exe

#IFDEF __PLATFORM__WINDOWS
    _data_xml := '"' + _data_xml + '"'
    _out_file := '"' + _out_file + '"'
    _template := '"' + _template + '"'
    _office := '"' + _office + '"'
    _jod_bin := '"' + _jod_bin + '"'
#ENDIF

_cmd := _java_start + " " + _jod_bin + " " 
_cmd += _template + " "
_cmd += _data_xml + " "
_cmd += _out_file

log_write( "jodreports line: " + _cmd )

SAVE SCREEN TO _sv_screen

if hb_run(_cmd) <> 0
    msgbeep( "problem sa generisanje jod reporta ..." )
endif

RESTORE SCREEN FROM _sv_screen

_cmd := "start " 
_cmd += _office + " " + _oo_params + " "
_cmd += _out_file

log_write("oo print: " + _cmd)

if hb_run( _cmd ) <> 0
    msgbeep( "problem sa pokretanjem office-a !!!" )
endif

return


// ----------------------------------------------
// otvara potrebne tabele za stampu
// ----------------------------------------------
static function o_tables( azurirana )

select F_KONCIJ
if !USED()
    O_KONCIJ
endif

select F_ROBA
if !USED()
    O_ROBA
endif

select F_TARIFA
if !USED()
    O_TARIFA
endif

select F_PARTN
if !USED()
    O_PARTN
endif

select F_KONTO
if !USED()
    O_KONTO
endif

select F_TDOK
if !USED()
    O_TDOK
endif

// azurirana otvara kalk, ali kao alijas kalk_pripr
if azurirana
    O_SKALK   
else
    O_KALK_PRIPR
endif

// pozicioniraj se odmah na prvi zapis
select kalk_pripr
set order to tag "1"
go top

return


// ---------------------------------------------
// uslovi za dokument
// ---------------------------------------------
static function get_vars( vars )
local _firma := gFirma
local _tip := "10"
local _broj := SPACE(8)
local _ret := .f.

Box(,1,40)
    @ m_x + 1, m_y + 2 SAY "Broj dokumenta:" 
    @ m_x + 1, col() + 1 GET _firma 
    @ m_x + 1, col() + 1 SAY "-" GET _tip VALID !EMPTY( _tip )
    @ m_x + 1, col() + 1 SAY "-" GET _broj VALID !EMPTY( _broj )
    read
BoxC()

if LastKey() == K_ESC
    return _ret
endif

vars := hb_hash()
vars["id_firma"] := _firma
vars["tip_dok"] := _tip
vars["br_dok"] := _broj

return .t.



// ---------------------------------------------
// generisanje xml fajla
// ---------------------------------------------
static function generisi_xml( vars )
local _firma := vars["id_firma"]
local _tip_dok := vars["tip_dok"]
local _br_dok := vars["br_dok"]
local _generated := 0
local _xml_file := my_home() + "kalkdata.xml"
local _t_rec
local _redni_broj := 0
local _porezna_stopa, _porez
local _s_kolicina, _tmp

private nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

select kalk_pripr
set order to tag "1"
go top

seek _firma + _tip_dok + _br_dok

if !FOUND()
    MsgBeep( "Trazeni dokument " + _firma + "-" + _tip_dok + "-" + ALLTRIM(_br_dok) + " ne postoji !" )
    return _generated
endif

// seek-uj i ostale bitne tabele
select konto
hseek kalk_pripr->mkonto

select partn
hseek kalk_pripr->idpartner

select tdok
hseek kalk_pripr->idvd

select kalk_pripr

// zapamti prvi zapis
_t_rec := RECNO()

// napuni mi xml fajl...
open_xml( _xml_file )
// upisi standardni xml header
xml_head()

// <kalkulacija>
xml_subnode("kalk", .f. )

// osnovni podaci organizacije
xml_node( "org_id", ALLTRIM( gFirma ) )
xml_node( "org_naziv", to_xml_encoding( ALLTRIM( gNFirma ) ) )

// podaci dokumenta
xml_node( "dok_naziv", "KALKULACIJA CIJENA br." )
xml_node( "dok_broj", to_xml_encoding( ALLTRIM( _br_dok ) ) )
xml_node( "dok_datum", xml_date( field->datdok ) )

// podaci o magacinu
xml_node( "magacin", to_xml_encoding( ALLTRIM( konto->naz ) ) )

// podaci o dobavljacu i veznom racunu
xml_node( "dob_naziv", to_xml_encoding( ALLTRIM( partn->naz ) ) )
xml_node( "rn_broj", to_xml_encoding( ALLTRIM( field->brfaktp ) ) )
xml_node( "rn_datum", xml_date( field->datfaktp ) )

_u_fv := _t_fv := 0
_u_fv_r := _t_fv_r := 0
_u_tr_prevoz := _u_tr_bank := _u_tr_carina := _u_tr_zavisni := _u_tr_sped := _u_tr_svi := 0
_t_tr_prevoz := _t_tr_bank := _t_tr_carina := _t_tr_zavisni := _t_tr_sped := _t_tr_svi := 0
_u_nv := _t_nv := _u_marza := _t_marza := 0
_u_porez := _t_porez := 0
_u_pv := _t_pv := _u_pv_porez := _t_pv_porez := 0

// prodji kroz dokument...
do while !EOF() .and. _firma == field->idfirma .and. _tip_dok == field->idvd .and. _br_dok == field->brdok 
  
    ++ _generated 

    // seek-uje robu 
    RptSeekRT()

    // selektuje troskove
    KTroskovi()
    
    _porezna_stopa := tarifa->opp
    _porez := field->mpcsapp / ( 1 + ( _porezna_stopa / 100 ) ) * ( _porezna_stopa / 100 )

    _s_kolicina := field->kolicina - field->gkolicina - field->gkolicin2

    // fakturna cijena vrijednost
    _u_fv := ROUND( field->fcj * field->kolicina, gZaokr )
    _u_fv := ROUND( field->fcj2 * ( field->gkolicina + field->gkolicin2 ), gZaokr )
    _t_fv += _u_fv

    // rabati
    _u_fv_r := ROUND( -field->rabat / 100 * field->fcj * field->kolicina, gZaokr )
    _t_fv_r += _u_fv_r

    // troskovi
    _u_tr_prevoz := ROUND( nPrevoz * _s_kolicina, gZaokr )
    _u_tr_bank := ROUND( nBankTr * _s_kolicina, gZaokr )
    _u_tr_sped := ROUND( nSpedTr * _s_kolicina, gZaokr )
    _u_tr_carina := ROUND( nCarDaz * _s_kolicina, gZaokr )
    _u_tr_zavisni := ROUND( nZavTr* _s_kolicina, gZaokr )
    // svi troskovi zajedno
    _u_tr_svi := ( _u_tr_prevoz + _u_tr_bank + _u_tr_sped + _u_tr_carina + _u_tr_zavisni )

    _t_tr_prevoz += _u_tr_prevoz
    _t_tr_bank += _u_tr_bank
    _t_tr_sped += _u_tr_sped
    _t_tr_carina += _u_tr_carina
    _t_tr_zavisni += _u_tr_zavisni
    _t_tr_svi += _u_tr_svi

    // nabavna vrijednost
    _u_nv := ROUND( field->nc * _s_kolicina, gZaokr )
    _t_nv += _u_nv

    // marza
    _u_marza := ROUND( nMarza * _s_kolicina, gZaokr )
    _t_marza += _u_marza

    // prodajna cijena
    _u_pv := ROUND( field->vpc * _s_kolicina, gZaokr )
    _t_pv += _u_pv

    // total porez
    _u_porez := ( _porez * field->kolicina )
    _t_porez += _u_porez

    // prodajna vrijednost sa porezom
    _u_pv_porez := ( field->mpcsapp * field->kolicina )
    _t_pv_porez += _u_pv_porez

    xml_subnode("stavka", .f. )

    // podaci artikla
    xml_node( "art_id", to_xml_encoding( ALLTRIM( field->idroba ) ) )
    xml_node( "art_naz", to_xml_encoding( ALLTRIM( roba->naz ) ) )
    xml_node( "art_jmj", to_xml_encoding( ALLTRIM( roba->jmj ) ) )
    xml_node( "tarifa", to_xml_encoding( ALLTRIM( field->idtarifa ) ) )
    xml_node( "rbr", PADL( ALLTRIM( STR( ++_redni_broj ) ), 4 ) )

    // kolicine
    xml_node( "kol", STR( field->kolicina, 12, 2 ) )
    xml_node( "g_kol", STR( field->gkolicina, 12, 2 ) )
    xml_node( "g_kol2", STR( field->gkolicin2, 12, 2 ) )
    xml_node( "skol", STR( _s_kolicina, 12, 2 ) )
    
    // jedinicne cijene itd...
    
    xml_node( "fcj", STR( field->fcj, 12, 2 ) )
    xml_node( "kskonto", STR( -rabat, 12, 2 ) )
    xml_node( "nc", STR( field->nc, 12, 2 ) )
    xml_node( "marzap", STR( nMarza / field->nc * 100, 12, 2 ) )
    xml_node( "marza", STR( nMarza, 12, 2 ) )
    xml_node( "pc", STR( field->vpc, 12, 2 ) )
    xml_node( "por_st", STR( _porezna_stopa, 12, 2 ) )
    xml_node( "porez", STR( _porez, 12, 2 ) )
    xml_node( "pcsap", STR( field->mpcsapp, 12, 2 ) )

    // troskovi
    _pr_tr_prev := nPrevoz / field->fcj2 * 100
    _pr_tr_bank := nBankTr / field->fcj2 * 100
    _pr_tr_sped := nSpedTr / field->fcj2 * 100
    _pr_tr_car := nCarDaz / field->fcj2 * 100
    _pr_tr_zav := nZavTr / field->fcj2 * 100
    _pr_tr_svi := ( _pr_tr_prev + _pr_tr_bank + _pr_tr_sped + _pr_tr_car + _pr_tr_zav )
 
    // procenti troskova
    xml_node( "tr1p", STR( _pr_tr_prev, 12, 2 ) )
    xml_node( "tr2p", STR( _pr_tr_bank, 12, 2 ) )
    xml_node( "tr3p", STR( _pr_tr_sped, 12, 2 ) )
    xml_node( "tr4p", STR( _pr_tr_car, 12, 2 ) )
    xml_node( "tr5p", STR( _pr_tr_zav, 12, 2 ) )
    xml_node( "trsp", STR( _pr_tr_svi, 12, 2 ) )
    
    // iznosi troskova
    _tmp := nPrevoz + nBankTr + nSpedTr + nCarDaz + nZavTr
    xml_node( "tr1", STR( nPrevoz, 12, 2 ) )
    xml_node( "tr2", STR( nBankTr, 12, 2 ) )
    xml_node( "tr3", STR( nSpedTr, 12, 2 ) )
    xml_node( "tr4", STR( nCarDaz, 12, 2 ) )
    xml_node( "tr5", STR( nZavTr, 12, 2 ) )
    xml_node( "trs", STR( _tmp, 12, 2 ) )

    // ukupne vrijednosti po stavkama
    xml_node( "ufv", STR( _u_fv, 12, 2 ) )
    xml_node( "ufvr", STR( _u_fv_r, 12, 2 ) )
    
    xml_node( "utr1", STR( _u_tr_prevoz, 12, 2 ) )
    xml_node( "utr2", STR( _u_tr_bank, 12, 2 ) )
    xml_node( "utr3", STR( _u_tr_sped, 12, 2 ) )
    xml_node( "utr4", STR( _u_tr_carina, 12, 2 ) )
    xml_node( "utr5", STR( _u_tr_zavisni, 12, 2 ) )
    xml_node( "utrs", STR( _u_tr_svi, 12, 2 ) )

    xml_node( "unv", STR( _u_nv, 12, 2 ) )
    xml_node( "umarza", STR( _u_marza, 12, 2 ) )
    xml_node( "upv", STR( _u_pv, 12, 2 ) )
    xml_node( "upor", STR( _u_porez, 12, 2 ) )
    xml_node( "upvp", STR( _u_pv_porez, 12, 2 ) )

    xml_subnode("stavka", .t. )

    skip

enddo

// ukupne vrijednosti za dokument
xml_node( "tfv", STR( _t_fv, 12, 2 ) )
xml_node( "tfvr", STR( _t_fv_r, 12, 2 ) )
xml_node( "ttr1", STR( _t_tr_prevoz, 12, 2 ) )
xml_node( "ttr2", STR( _t_tr_bank, 12, 2 ) )
xml_node( "ttr3", STR( _t_tr_sped, 12, 2 ) )
xml_node( "ttr4", STR( _t_tr_carina, 12, 2 ) )
xml_node( "ttr5", STR( _t_tr_zavisni, 12, 2 ) )
xml_node( "ttrs", STR( _t_tr_svi, 12, 2 ) )
xml_node( "tnv", STR( _t_nv, 12, 2 ) )
xml_node( "tmarza", STR( _t_marza, 12, 2 ) )
xml_node( "tpv", STR( _t_pv, 12, 2 ) )
xml_node( "tpor", STR( _t_porez, 12, 2 ) )
xml_node( "tpvp", STR( _t_pv_porez, 12, 2 ) )

// zatvori subnode...
xml_subnode("kalk", .t. )

// zatvori xml fajl
close_xml()

return _generated



