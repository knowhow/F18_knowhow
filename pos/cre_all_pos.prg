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

#include "fmk.ch"
#include "cre_all.ch"


function cre_all_pos( ver )
local aDbf
local _alias, _table_name
local _created

aDbf := {}

AADD ( aDbf, { "DATUM",     "D",  8, 0} )
AADD ( aDbf, { "IDPOS",     "C",  2, 0} )
AADD ( aDbf, { "IDVD",      "C",  2, 0} )
AADD ( aDbf, { "BRDOK",     "C",  6, 0} )

AADD ( aDbf, { "IDGOST",    "C",  8, 0} )
AADD ( aDbf, { "IDRADNIK",  "C",  4, 0} )
AADD ( aDbf, { "IDVRSTEP",  "C",  2, 0} )
AADD ( aDbf, { "M1",        "C",  1, 0} )
AADD ( aDbf, { "PLACEN",    "C",  1, 0} )
AADD ( aDbf, { "PREBACEN",  "C",  1, 0} )
AADD ( aDbf, { "SMJENA",    "C",  1, 0} )
AADD ( aDbf, { "STO",       "C",  3, 0} )
AADD ( aDbf, { "VRIJEME",   "C",  5, 0} )

AADD ( aDbf, { "C_1",       "C",  6, 0} )
AADD ( aDbf, { "C_2",       "C", 10, 0} )
AADD ( aDbf, { "C_3",       "C", 50, 0} )

AADD ( aDbf, { "FISC_RN",   "N", 10, 0} )
AADD ( aDbf, { "ZAK_BR",    "N",  6, 0} )
AADD ( aDbf, { "STO_BR",    "N",  3, 0} )

_alias := "POS_DOKS"
_table_name := "pos_doks"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX ("1", "IdPos+IdVd+dtos(datum)+BrDok", _alias )
CREATE_INDEX ("2", "IdVd+DTOS(Datum)+Smjena", _alias )
CREATE_INDEX ("3", "IdGost+Placen+DTOS(Datum)", _alias )
CREATE_INDEX ("4", "IdVd+M1", _alias )
CREATE_INDEX ("5", "Prebacen", _alias )
CREATE_INDEX ("6", "dtos(datum)", _alias )
CREATE_INDEX ("7", "IdPos+IdVD+BrDok", _alias )
CREATE_INDEX ("TK", "IdPos+DTOS(Datum)+IdVd", _alias )
CREATE_INDEX ("GOSTDAT", "IdPos+IdGost+DTOS(Datum)+IdVd+Brdok", _alias )
CREATE_INDEX ("STO", "IdPos+idvd+STR(STO_BR)+STR(ZAK_BR)+DTOS(datum)+brdok", _alias )
CREATE_INDEX ("ZAK", "IdPos+idvd+STR(ZAK_BR)+STR(STO_BR)+DTOS(datum)+brdok", _alias )
CREATE_INDEX ("FISC", "STR(fisc_rn,10)+idpos+idvd", _alias )

// ------- pos dokspf ------
aDbf := {}
AADD(aDbf, {"DATUM", "D", 8, 0})
AADD(aDbf, {"IDPOS", "C", 2, 0})
AADD(aDbf, {"IDVD",  "C", 2, 0})
AADD(aDbf, {"BRDOK", "C", 6, 0})

AADD(aDbf, {"KNAZ",  "C", 35, 0})
AADD(aDbf, {"KADR",  "C", 35, 0})
AADD(aDbf, {"KIDBR", "C", 13, 0})
AADD(aDbf, {"DATISP", "D", 8, 0})

_alias := "DOKSPF"
_table_name := "pos_dokspf"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "1", "idpos+idvd+DToS(datum)+brdok", _alias )
CREATE_INDEX( "2", "knaz", _alias )



// ----------------- pos items ---------------

aDbf := {}

AADD ( aDbf, { "DATUM",     "D",  8, 0} )
AADD ( aDbf, { "IDPOS",     "C",  2, 0} )
AADD ( aDbf, { "IDVD",      "C",  2, 0} )
AADD ( aDbf, { "BRDOK",     "C",  6, 0} )
AADD ( aDbf, { "RBR",       "C",  5, 0} )
AADD ( aDbf, { "IDCIJENA",  "C",  1, 0} )
AADD ( aDbf, { "CIJENA",    "N", 10, 3} )
AADD ( aDbf, { "IDDIO",     "C",  2, 0} )
AADD ( aDbf, { "IDODJ",     "C",  2, 0} )
AADD ( aDbf, { "IDRADNIK",  "C",  4, 0} )
AADD ( aDbf, { "IDROBA",    "C", 10, 0} )
AADD ( aDbf, { "IDTARIFA",  "C",  6, 0} )
AADD ( aDbf, { "KOL2",      "N", 18, 3} )
AADD ( aDbf, { "KOLICINA",  "N", 18, 3} )
AADD ( aDbf, { "M1",        "C",  1, 0} )
AADD ( aDbf, { "MU_I",      "C",  1, 0} )
AADD ( aDbf, { "NCIJENA",   "N", 10, 3} )
AADD ( aDbf, { "PREBACEN",  "C",  1, 0} )
AADD ( aDbf, { "SMJENA",    "C",  1, 0} )
AADD ( aDbf, { "C_1",        "C",  6, 0})
AADD ( aDbf, { "C_2",        "C", 10, 0})
AADD ( aDbf, { "C_3",        "C", 50, 0})

_alias := "POS"
_table_name := "pos_pos"

IF_NOT_FILE_DBF_CREATE

// 0.4.5
if ver["current"] > 0 .and. ver["current"] < 00405
   modstru({"*" + _table_name, "A RBR C 5 0" })
endif

IF_C_RESET_SEMAPHORE

CREATE_INDEX ("1", "IdPos+IdVd+dtos(datum)+BrDok+IdRoba+IdCijena", _alias )
CREATE_INDEX ("2", "IdOdj+idroba+DTOS(Datum)", _alias )
CREATE_INDEX ("3", "Prebacen", _alias )
CREATE_INDEX ("4", "dtos(datum)", _alias )
CREATE_INDEX ("5", "IdPos+idroba+DTOS(Datum)", _alias )
CREATE_INDEX ("6", "IdRoba", _alias )
CREATE_INDEX ("7", "IdPos+IdVd+BrDok+DTOS(Datum)+IdDio+IdOdj", _alias )
CREATE_INDEX ("IDS_SEM", "IdPos+IdVd+dtos(datum)+BrDok+rbr", _alias )

//--- promvp - promet po vrstama placanja --

aDbf := {}
AADD ( aDbf, { "DATUM",     "D",  8, 0} )
AADD ( aDbf, { "POLOG01",   "N", 10, 2} )
AADD ( aDbf, { "POLOG02",   "N", 10, 2} )
AADD ( aDbf, { "POLOG03",   "N", 10, 2} )
AADD ( aDbf, { "POLOG04",   "N", 10, 2} )
AADD ( aDbf, { "POLOG05",   "N", 10, 2} )
AADD ( aDbf, { "POLOG06",   "N", 10, 2} )
AADD ( aDbf, { "POLOG07",   "N", 10, 2} )
AADD ( aDbf, { "POLOG08",   "N", 10, 2} )
AADD ( aDbf, { "POLOG09",   "N", 10, 2} )
AADD ( aDbf, { "POLOG10",   "N", 10, 2} )
AADD ( aDbf, { "POLOG11",   "N", 10, 2} )
AADD ( aDbf, { "POLOG12",   "N", 10, 2} )
AADD ( aDbf, { "UKUPNO",    "N", 10, 3} )

_alias := "PROMVP"
_table_name := "pos_promvp"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX ("1", "DATUM", _alias )


// --------------- strad - statusi radnika -----------
aDbf := {}
AADD( aDbf, { "ID",        "C",  2, 0} )
AADD( aDbf, { "NAZ",       "C", 15, 0} )
AADD( aDbf, { "PRIORITET", "C",  1, 0} )

_alias := "STRAD"
_table_name := "pos_strad"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("ID", "ID",  _alias )
CREATE_INDEX("NAZ", "NAZ", _alias )


// ------------ osob - osoblje ------------------------
aDbf := {}
AADD( aDbf, { "ID",        "C",  4, 0} )
AADD( aDbf, { "KORSIF",    "C",  6, 0} )
AADD( aDbf, { "NAZ",       "C", 40, 0} )
AADD( aDbf, { "STATUS",    "C",  2, 0} )

_alias := "OSOB"
_table_name := "pos_osob"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("ID", "KorSif", _alias )
CREATE_INDEX("NAZ", "ID", _alias )


// --------- kase ------------------------

aDbf := {}
AADD( aDbf, {"ID" ,     "C",  2, 0} )
AADD( aDbf, {"NAZ",     "C", 15, 0} )
AADD( aDbf, {"PPATH",   "C", 50, 0} )

_alias := "KASE"
_table_name := "pos_kase"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("ID", "ID", _alias )



aDbf := {}
AADD( aDbf, {"ID" ,      "C",  2, 0} )
AADD( aDbf, {"NAZ",      "C", 25, 0} )
AADD( aDbf, {"ZADUZUJE", "C",  1, 0} )
AADD( aDbf, {"IDKONTO",  "C",  7, 0} )

_alias := "ODJ"
_table_name := "pos_odj"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("ID", "ID", _alias )


// RNGPLA - izmirenje dugovanja po racunima gostiju
aDbf := { {"IDGOST",   "C",  8, 0}, ;
		     {"DATUM",    "D",  8, 0}, ;
		     {"IZNOS",    "N", 20, 3}, ;
		     {"IDVALUTA", "C",  4, 0}, ;
		     {"DAT_OD",   "D",  8, 0}, ;
		     {"DAT_DO",   "D",  8, 0}, ;
		     {"IDRADNIK", "C",  4, 0}  ;
		   }

_alias := "RNGPLA"
_table_name := "rngpla"

IF_NOT_FILE_DBF_CREATE	   
	
CREATE_INDEX ("1", "IdGost", _alias )


// ----------------------------------------------------------
// _POS, _PRIPR, PRIPRZ, PRIPRG, _POSP
// ----------------------------------------------------------

aDbf := g_pos_pripr_fields()

_alias := "_POS"
_table_name := "_pos"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX ("1", "IdPos+IdVd+dtos(datum)+BrDok+IdRoba+IdCijena+STR(Cijena,10,3)", _alias )
CREATE_INDEX ("2", "IdVd+IdOdj+IdDio", _alias )
CREATE_INDEX ("3", "IdVd+IdRadnik+GT+IdDio+IdOdj+IdRoba", _alias )

_alias := "_POSP"
_table_name := "_posp"

IF_NOT_FILE_DBF_CREATE

_alias := "_POS_PRIPR"
_table_name := "_pos_pripr"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX ("1", "IdRoba", _alias )

_alias := "PRIPRZ"
_table_name := "priprz"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX ("1", "IdRoba", _alias )

_alias := "PRIPRG"
_table_name := "priprg"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX ("1", "IdPos+IdOdj+IdDio+IdRoba+DTOS(Datum)+Smjena", _alias )
CREATE_INDEX ("2", "IdPos+DTOS (Datum)+Smjena", _alias )
CREATE_INDEX ("3", "IdVd+IdPos+IdVrsteP+IdGost+Placen+IdDio+IdOdj+IdRoba", _alias )
CREATE_INDEX ("4", "IdVd+IdPos+IdVrsteP+IdGost+DToS(datum)", _alias )


aDbf := {}
AADD ( aDbf, {"KEYCODE", "N",  4, 0} )
AADD ( aDbf, {"IDROBA",  "C", 10, 0} )

_alias := "K2C"
_table_name := "k2c"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX ("1", "STR (KeyCode, 4)", _alias )
CREATE_INDEX ("2", "IdRoba", _alias )


aDbf := {}
AADD ( aDbf, {"IDDIO",      "C",  2, 0} )
AADD ( aDbf, {"IDODJ",      "C",  2, 0} )
AADD ( aDbf, {"IDUREDJAJ" , "C",  2, 0} )

_alias := "MJTRUR"
_table_name := "mjtrur"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX ("1", "IdDio+IdOdj", _alias )


aDbf := {}
AADD ( aDbf, {"IDROBA",     "C", 10, 0} )
AADD ( aDbf, {"IDDIO",      "C",  2, 0} )

_alias := "ROBAIZ"
_table_name := "robaiz"

IF_NOT_FILE_DBF_CREATE
	  
CREATE_INDEX ("1", "IdRoba", _alias )


aDbf := {}
AADD ( aDbf, {"ID" ,      "C",  2, 0} )
AADD ( aDbf, {"NAZ",      "C", 25, 0} )

_alias := "DIO"
_table_name := "dio"

IF_NOT_FILE_DBF_CREATE
	  
CREATE_INDEX ("ID", "ID", _alias )


aDbf := {}
AADD ( aDbf, {"ID"        , "C",  2, 0} )
AADD ( aDbf, {"NAZ"       , "C", 30, 0} )
AADD ( aDbf, {"PORT"      , "C", 10, 0} )

_alias := "UREDJ"
_table_name := "uredj"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX ("ID", "ID", _alias )
CREATE_INDEX ("NAZ", "NAZ", _alias )


aDbf := {}
AADD ( aDbf, { "ID",        "C",  8, 0} )
AADD ( aDbf, { "ID2",       "C",  8, 0} )
AADD ( aDbf, { "KM",        "N",  6, 1} )

_alias := "MARS"
_table_name := "mars"
	   
IF_NOT_FILE_DBF_CREATE

CREATE_INDEX ("ID", "ID"     , _alias )
CREATE_INDEX ("2" , "ID+ID2" , _alias )


// kreiraj tabele dok_src : DOK_SRC
cre_doksrc( ver )


return .t.

