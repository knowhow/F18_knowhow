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

_created := .f.
_alias := "POS_DOKS"
_table_name := "pos_doks"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

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

_created := .f.
_alias := "DOKSPF"
_table_name := "pos_dokspf"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

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

_created := .f.
_alias := "POS"
_table_name := "pos_pos"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

// 0.4.5
if ver["current"] < 00405
   modstru({"*" + _table_name, "A RBR C 5 0" })
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif


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

_created := .f.
_alias := "PROMVP"
_table_name := "pos_promvp"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

CREATE_INDEX ("1", "DATUM", _alias )


// --------------- strad - statusi radnika -----------
aDbf := {}
AADD( aDbf, { "ID",        "C",  2, 0} )
AADD( aDbf, { "NAZ",       "C", 15, 0} )
AADD( aDbf, { "PRIORITET", "C",  1, 0} )

_created := .f.
_alias := "STRAD"
_table_name := "pos_strad"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

CREATE_INDEX("ID", "ID",  _alias )
CREATE_INDEX("NAZ", "NAZ", _alias )

// ------------ osob - osoblje ------------------------
aDbf := {}
AADD( aDbf, { "ID",        "C",  4, 0} )
AADD( aDbf, { "KORSIF",    "C",  6, 0} )
AADD( aDbf, { "NAZ",       "C", 40, 0} )
AADD( aDbf, { "STATUS",    "C",  2, 0} )

_created := .f.
_alias := "OSOB"
_table_name := "pos_osob"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

CREATE_INDEX("ID", "KorSif", _alias )
CREATE_INDEX("NAZ", "ID", _alias )


// --------- kase ------------------------

aDbf := {}
AADD( aDbf, {"ID" ,     "C",  2, 0} )
AADD( aDbf, {"NAZ",     "C", 15, 0} )
AADD( aDbf, {"PPATH",   "C", 50, 0} )

_created := .f.
_alias := "KASE"
_table_name := "pos_kase"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

CREATE_INDEX("ID", "ID", _alias )

aDbf := {}
AADD( aDbf, {"ID" ,      "C",  2, 0} )
AADD( aDbf, {"NAZ",      "C", 25, 0} )
AADD( aDbf, {"ZADUZUJE", "C",  1, 0} )
AADD( aDbf, {"IDKONTO",  "C",  7, 0} )

_created := .f.
_alias := "ODJ"
_table_name := "pos_odj"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

CREATE_INDEX("ID", "ID", _alias )

return

