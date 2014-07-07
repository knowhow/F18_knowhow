/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "epdv.ch"
#include "cre_all.ch"


// --------------------------------------------------------
// kreiranje epdv tabela
// --------------------------------------------------------
function cre_all_epdv(ver)
local aDbf
local _alias, _table_name
local _created


// KUF, KIF, PDV
// ----------------------------------

// daj mi polja za kuf
aDbf := get_kuf_fields()

_alias := "KUF"
_table_name := "epdv_kuf"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("datum","dtos(datum)+src_br_2", _alias)
CREATE_INDEX("l_datum","lock+dtos(datum)+src_br_2", _alias)
CREATE_INDEX("g_r_br","STR(g_r_br,6,0)+dtos(datum)", _alias)
CREATE_INDEX("BR_DOK","STR(BR_DOK,6,0)+STR(r_br,6,0)", _alias)
CREATE_INDEX("BR_DOK2","STR(BR_DOK,6,0)+dtos(datum)", _alias)
	

// daj mi polja za kif
aDbf := get_kif_fields()

_alias := "KIF"
_table_name := "epdv_kif"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("datum","dtos(datum)+src_br_2", _alias)
CREATE_INDEX("l_datum","lock+dtos(datum)+src_br_2", _alias)
CREATE_INDEX("g_r_br","STR(g_r_br,6,0)+dtos(datum)", _alias)
CREATE_INDEX("BR_DOK","STR(BR_DOK,6,0)+STR(r_br,6,0)", _alias)
CREATE_INDEX("BR_DOK2","STR(BR_DOK,6,0)+dtos(datum)", _alias)
	

// daj mi polja za pdv
aDbf := get_pdv_fields()

_alias := "PDV"
_table_name := "epdv_pdv"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("period","DTOS(per_od)+DTOS(per_do)", _alias )


// P_KIF, P_KUF
// ------------------------------
// daj mi polja za p_kuf
aDbf := get_kuf_fields()

_alias := "P_KUF"
_table_name := "epdv_p_kuf"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("datum","dtos(datum)+src_br_2", _alias)
CREATE_INDEX("l_datum","lock+dtos(datum)+src_br_2", _alias)
CREATE_INDEX("br_dok", "STR(br_dok,6,0)+STR(r_br,6,0)", _alias)
	

// daj mi polja za p_kif
aDbf := get_kif_fields()

_alias := "P_KIF"
_table_name := "epdv_p_kif"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("datum","dtos(datum)+src_br_2", _alias)
CREATE_INDEX("l_datum","lock+dtos(datum)+src_br_2", _alias)
CREATE_INDEX("br_dok", "STR(br_dok,6,0)+STR(r_br,6,0)", _alias)
	

// SG_KIF, SG_KUF
// --------------------------------------

// daj mi polja za sg_kuf
aDbf := get_sg_fields()

_alias := "SG_KUF"
_table_name := "epdv_sg_kuf"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("id","id", _alias)
CREATE_INDEX("naz","id", _alias)

// daj mi polja za sg_kif
aDbf := get_sg_fields()

_alias := "SG_KIF"
_table_name := "epdv_sg_kif"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("id","id", _alias)
CREATE_INDEX("naz","id", _alias)

return .t.


// ----------------------------------------------
// pdv fields
// ----------------------------------------------
function get_pdv_fields()
local aDbf

aDbf:={}
// datum kreiranja
AADD(aDBf,{ "datum_1"    , "D" ,   8 ,  0 })

// datum posljednje ispravke
AADD(aDBf,{ "datum_2"      , "D" ,   8 ,  0 })

// datum zakljucavanja
AADD(aDBf,{ "datum_3"      , "D" ,   8 ,  0 })

// identifikacijski broj
AADD(aDBf,{ "id_br"      , "C" ,   12 ,  0 })

// period od
AADD(aDBf,{ "per_od"      , "D" ,   8 ,  0 })
// do
AADD(aDBf,{ "per_do"      , "D" ,   8 ,  0 })

// naziv poreskog obveznika
AADD(aDBf,{ "po_naziv"      , "C" ,   60 ,  0 })

// adresa
AADD(aDBf,{ "po_adresa"      , "C" ,   60 ,  0 })

// ptt broj
AADD(aDBf,{ "po_ptt"      , "C" ,   10 ,  0 })
// mjesto
AADD(aDBf,{ "po_mjesto"      , "C" ,   40 ,  0 })

// 11 - oporezive isporuke
AADD(aDBf,{ "i_opor"      , "N" ,   18 ,  2 })
// 12 - isporuke izvoz
AADD(aDBf,{ "i_izvoz"      , "N" ,   18 ,  2 })
// 13 - ostale neoporezive isporuke
AADD(aDBf,{ "i_neop"    , "N" ,   18 ,  2 })

// 21 - sve nabavke osim uvoza i poljoprivrede
AADD(aDBf,{ "u_nab_21"    , "N" ,   18 ,  2 })

// 22  - uvoz
AADD(aDBf,{ "u_uvoz"    , "N" ,   18 ,  2 })

// 21 - nabavke od poljoprivrednika
AADD(aDBf,{ "u_nab_23"    , "N" ,   18 ,  2 })


// 31 - pdv za registrovane pdv obveznike
AADD(aDBf,{ "i_pdv_r" , "N" ,   18 ,  2 })

// 32 - pdv za neregistovane, federacija
AADD(aDBf,{ "i_pdv_nr1" , "N" ,   18 ,  2 })
// 33 - rs
AADD(aDBf,{ "i_pdv_nr2" , "N" ,   18 ,  2 })
// 34 - bdistrikt
AADD(aDBf,{ "i_pdv_nr3" , "N" ,   18 ,  2 })
// ne koristi se
AADD(aDBf,{ "i_pdv_nr4" , "N" ,   18 ,  2 })


// 41 - ulazni pdv, sve osim uvoza i poljoprivrednika
AADD(aDBf,{ "u_pdv_41" , "N" ,   18 ,  2 })

// 42 - uvoz
AADD(aDBf,{ "u_pdv_uv" , "N" ,   18 ,  2 })

// 43 -  pausalna naknada za poljoprivrednike, oporezivi dio pdv
AADD(aDBf,{ "u_pdv_43" , "N" ,   18 ,  2 })


// preneseno iz predhodnog perioda
AADD(aDBf,{ "u_pdv_pp" , "N" ,   18 ,  2 })

// 51 izlazni pdv ukupno
AADD(aDBf,{ "i_pdv_uk" , "N" ,   18 ,  2 })

// 61 = u_pdv_pp + u_pdv_41 + u_pdv_uv + u_pdv_43
AADD(aDBf,{ "u_pdv_uk" , "N" ,   18 ,  2 })


// 71 obaveza za uplatu, ako ima
// moze biti + (uplatiti) ili - (povrat)
AADD(aDBf,{ "pdv_uplati" , "N" ,   18 ,  2 })

// 80 zahtjev za povrat
//  D - da
//  N - ne
AADD(aDBf,{ "pdv_povrat" , "C" ,   1,  0 })


// potpis mjesto
AADD(aDBf,{ "pot_mjesto" , "C" ,   40,  0 })
// potpis datum 
AADD(aDBf,{ "pot_datum" ,  "D" ,   8,  0 })
// potpis obveznik pdv-a
AADD(aDBf,{ "pot_ob" ,  "C" ,   80,  0 })

// zakljucan obracun
AADD(aDBf,{ "lock" ,  "C" ,   1,  0 })

return aDbf


// ------------------------------------------------------
// kif struktura
// ------------------------------------------------------
function get_kif_fields()
local aDbf

aDbf:={}
AADD(aDBf,{ "datum" , "D" ,   8 ,  0 })

// ne koristi se
AADD(aDBf,{ "datum_2" , "D" ,   8 ,  0 })

// 1 - FIN
// 2 - KALK
// 3 - FAKT
// 4 - OS
// 5 - SII
AADD(aDBf,{ "src"  , "C" ,   1 ,  0 })

// tip dokumenta 
// 
AADD(aDBf,{ "td_src" , "C" ,   2,  0 })

// podnivo src-a
// ako nam je to potrebno, ako nije empty
AADD(aDBf,{ "src_2"  , "C" ,   1,  0 })

AADD(aDBf,{ "id_tar" , "C" ,   6,  0 })
AADD(aDBf,{ "id_part" , "C" ,   6,  0 })

// id partner, id broj
AADD(aDBf,{ "part_idbr" , "C" ,   13,  0 })

// kategorija partnera
// 1-pdv obveznik
// 2-ne pdv obvezink
AADD(aDBf,{ "p_kat"  , "C" ,   1,  0 })

// za ne-pdv obveznike
//   1-federacija
//   2-rs
//   3-distrikt brcko
AADD(aDBf,{ "p_kat_2" , "C" ,   1,  0 })


// source dokument prodajno mjesto
AADD(aDBf,{ "src_pm" , "C" ,  6,  0 })

AADD(aDBf,{ "src_td" , "C" ,  12,  0 })

// source dokument broj
AADD(aDBf,{ "src_br" , "C" ,  12,  0 })

// source dokument broj - veza
//  ako slucaj avansne fakture:
//   05.01 - src_br = 00005,  i_b_pdv = 500 KM  opis=avans 50%
//  nakon toga desi se placanje
//   12.02 - src_br = 00033 (broj fakture),   src_veza_br = 00005
//           i_b_pdv = 500 KM (placeno po avansnoj fakturi)
//           i_v_b_pdv = 1000 KM (placeno po fakturi)
//  kako vidimo veza broj je broj avansne fakture 
AADD(aDBf,{ "src_veza_br"  , "C" ,  12,  0 })


// source dokument eksterni broj 
// (br dobavljaca ako je razlicit od brdokumenta)
AADD(aDBf,{ "src_br_2"  , "C" ,  12,  0 })


// redni broj stavke unutar dokumenta
AADD(aDBf,{ "r_br"      , "N" ,   6,  0 })

// broj kif dokumenta kod knjizenja
AADD(aDBf,{ "br_dok"      , "N" ,   6,  0 })

// globalni redni broj kif-a 
AADD(aDBf,{ "g_r_br"      , "N" ,   8,  0 })

// lock = D - zakljucano i ne moze se renumerisati i mjenjati 
// (osim stavki kao sto je opis itd)
AADD(aDBf,{ "lock"      , "C" ,   1,  0 })

// kategorija stavke
//  1  - dnevni bezgotovinski promet
//  2  - dnevni gotovinski promet
//  3  - gotovinski promet bez racuna iz clana 120 pravilnika ZPDV
//  4  - racun za isporuke bez naknade ili uz licni popust
//  5  - naknadne ispravke racuna
AADD(aDBf,{ "kat"      , "C" ,   1,  0 })

// kategorija 2 stavke
//  1  - izlazne fakture PDV obveznicima 
//  2  - izlazne fakture ne-PDV obveznicima 
//  3  - izlazne fakture izvoz, oslobodjen od pdv-a
//  4  - izlazne fakture oslobodjene od PDV-a po ostalim osnovama
//  5  - primljeni avansi - avansne fakture 
//  6  -  izvanposlovne svrhe
AADD(aDBf,{ "kat_2"    , "C" ,   1,  0 })

// opis stavke
AADD(aDBf,{ "opis"      , "C" ,   160,  0 })

// iznos bez pdv-a - osnovica
AADD(aDBf,{ "i_b_pdv"      , "N" ,   16,  2 })
// pdv
AADD(aDBf,{ "i_pdv"      , "N" ,   16,  2 })


// vezna stavka, iznos bez pdv-a - ako imamo veznu stavku
// (pogledati gore primjer avansne fakture)
AADD(aDBf,{ "i_v_b_pdv"      , "N" ,   16,  2 })
AADD(aDBf,{ "i_v_pdv"      , "N" ,   16,  2 })


// status stavke
//  " " - nepoznato
//  1 - nije placeno
//  2 - placeno
AADD(aDBf,{ "status"      , "C" ,   1,  0 })

AADD(aDBf,{ "part_kat"      , "C" ,   1,  0 })

// kategorija partnera
// shema se primjenjuje samo za odredjenu kategoriju partnera
AADD(aDBf,{ "kat_p"        , "C" ,   1,  0 })
AADD(aDBf,{ "kat_p_2"      , "C" ,   1,  0 })


return aDbf


// ------------------------------------------------------
// kuf struktura
// ------------------------------------------------------
function get_kuf_fields()
local aDbf

aDbf:={}
AADD(aDBf,{ "datum"      , "D" ,   8 ,  0 })

// ne koristi se
AADD(aDBf,{ "datum_2"      , "D" ,   8 ,  0 })

// 1 - FIN
// 4 - OS
// 5 - SII
AADD(aDBf,{ "src"      , "C" ,   1 ,  0 })

// tip dokumenta 
// 
AADD(aDBf,{ "td_src"      , "C" ,   2,  0 })

// podnivo source-a
// ako nam je to potrebno, ako nije empty
AADD(aDBf,{ "src_2"      , "C" ,   1,  0 })

AADD(aDBf,{ "id_tar"    , "C" ,   6,  0 })
AADD(aDBf,{ "id_part"   , "C" ,   6,  0 })

// id partner, id broj
AADD(aDBf,{ "part_idbr"      , "C" ,   13,  0 })

// kategorija partnera
// 1-pdv obveznik
// 2-ne pdv obvezink
AADD(aDBf,{ "p_kat"      , "C" ,   1,  0 })

// ne koristi se trenutno
AADD(aDBf,{ "p_kat_2"      , "C" ,   1,  0 })


AADD(aDBf,{ "src_td"      , "C" ,  12,  0 })

// source dokument broj
AADD(aDBf,{ "src_br"      , "C" ,  12,  0 })

// source dokument broj - veza
//  ako slucaj avansne fakture:
//   05.01 - src_br = 00005,  i_b_pdv = 500 KM  opis=avans 50%
//  nakon toga desi se placanje
//   12.02 - src_br = 00033 (broj fakture),   src_veza_br = 00005
//           i_b_pdv = 500 KM (placeno po avansnoj fakturi)
//           i_v_b_pdv = 1000 KM (placeno po fakturi)
//  kako vidimo veza broj je broj avansne fakture 
AADD(aDBf,{ "src_veza_br"      , "C" ,  12,  0 })


// source dokument eksterni broj 
// (br dobavljaca ako je razlicit od brdokumenta)
AADD(aDBf,{ "src_br_2"      , "C" ,  12,  0 })


// redni broj stavke
AADD(aDBf,{ "r_br"      , "N" ,   6,  0 })

// broj kuf dokumenta kod knjizenja
AADD(aDBf,{ "br_dok"      , "N" ,   6,  0 })


// globalni redni broj kuf-a 
AADD(aDBf,{ "g_r_br"      , "N" ,   8,  0 })

// lock = D - zakljucano i ne moze se renumerisati i mjenjati 
// (osim stavki kao sto je opis itd)
AADD(aDBf,{ "lock"      , "C" ,   1,  0 })

// kategorija stavke
//  1  - ima pravo na odbitak pdv-a
//  2  - nema pravo na odbitak
AADD(aDBf,{ "kat"      , "C" ,   1,  0 })

// kategorija 2 stavke
// trenutno se ne koristi
AADD(aDBf,{ "kat_2"    , "C" ,   1,  0 })

// opis stavke
AADD(aDBf,{ "opis"      , "C" ,   160,  0 })

// iznos bez pdv-a - osnovica
AADD(aDBf,{ "i_b_pdv"      , "N" ,   16,  2 })
// pdv
AADD(aDBf,{ "i_pdv"      , "N" ,   16,  2 })


// vezna stavka, iznos bez pdv-a - ako imamo veznu stavku
// (pogledati gore primjer avansne fakture)
AADD(aDBf,{ "i_v_b_pdv"      , "N" ,   16,  2 })
AADD(aDBf,{ "i_v_pdv"      , "N" ,   16,  2 })


// status stavke
//  " " - nepoznato
//  1 - nije placeno
//  2 - placeno
AADD(aDBf,{ "status"      , "C" ,   1,  0 })

AADD(aDBf,{ "part_kat"      , "C" ,   1,  0 })

// kategorija partnera
// shema se primjenjuje samo za odredjenu kategoriju partnera
AADD(aDBf,{ "kat_p"        , "C" ,   1,  0 })
AADD(aDBf,{ "kat_p_2"      , "C" ,   1,  0 })


return aDbf

// -----------------------------
// gen shema kuf, kif fields
// -----------------------------
function get_sg_fields()
local aDbf

aDbf:={}

// 0001 - stavka 1, 0002 - stavka 2 itd ...
AADD(aDBf, { "id"      , "C" ,   4,  0 })

// npr: "got. promet prodavnica Tuzla 1"
AADD(aDBf, { "naz"      , "C" ,   60,  0 })


// src - pogledaj g_src_modul(cSrc)
AADD(aDBf,{ "src"      , "C" ,   1,  0 })

// tip dokumenta source-a 
AADD(aDBf,{ "td_src"      , "C" ,   2,  0 })

// source path kumulativ
AADD(aDBf,{ "s_path"      , "C" ,   60,  0 })
// ako je potreban i sifrarnik
AADD(aDBf,{ "s_path_s"      , "C" ,   60,  0 })

// formula za izracunavanje osnovice - iznos b. pdv
AADD(aDBf,{ "form_b_pdv"      , "C" ,   160,  0 })

// formula za izracunavanje PDV-a
AADD(aDBf,{ "form_pdv"      , "C" ,   160,  0 })

// tarifa dobra, moze se navesti vise tarifa sa ";"
AADD(aDBf,{ "id_tar"      , "C" ,   160,  0 })
// ako se podaci uzimaju iz fin-a, onda nam je konto najbitniji
// moze se uzeti vise konta iz fin-a
AADD(aDBf,{ "id_kto"      , "C" ,   160,  0 })

// "PKONTO", "MKONTO" , "IDKONTO"
AADD(aDBf,{ "id_kto_naz"      , "C" ,   10,  0 })

// svaki konto posebno
// razbij za svaku tarifu posebno, ako ih ima vise
// D - da
// N - ne
AADD(aDBf,{ "razb_tar"      , "C" ,   1,  0 })

// razbij za svaki konto posebno, ako ih vise ima
// D - da
// N - ne
AADD(aDBf,{ "razb_kto"      , "C" ,   1,  0 })

// razbij po danima
// D - da
// N - ne
AADD(aDBf,{ "razb_dan"      , "C" ,   1,  0 })

// kategorija partnera
// shema se primjenjuje samo za odredjenu kategoriju partnera
AADD(aDBf,{ "kat_p"        , "C" ,   1,  0 })
AADD(aDBf,{ "kat_p_2"      , "C" ,   1,  0 })

// set id tarifa kod kuf/kif stavke
AADD(aDBf,{ "s_id_tar"      , "C" ,   6,  0 })

// setuj id partnera
AADD(aDBf,{ "s_id_part"      , "C" ,   6,  0 })

// setuj broj dokuumenta
AADD(aDBf,{ "s_br_dok"      , "C" ,   12,  0 })

// zaokruzenja
AADD(aDBf,{ "zaok"      , "N" ,   1,  0 })
AADD(aDBf,{ "zaok2"      , "N" ,   1,  0 })

AADD(aDBf,{ "kat_part"        , "C" ,   1,  0 })

// aktivan 
// D - da
// N - ne
AADD(aDBf,{ "aktivan"      , "C" ,   1,  0 })

return aDbf


