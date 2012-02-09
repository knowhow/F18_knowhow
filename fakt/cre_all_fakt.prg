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

function cre_all_fakt( ver )
local aDbf
local _alias, _table_name
local _created

aDbf:={}
AADD(aDBf,{ 'IDFIRMA'   , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IdTIPDok'  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'     , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'    , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'IDPARTNER' , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'DINDEM'    , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'zaokr'     , 'N' ,   1 ,  0 })
AADD(aDBf,{ 'Rbr'       , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'PodBr'     , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'    , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDROBA_J'  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'SerBr'     , 'C' ,  15 ,  0 })
AADD(aDBf,{ 'KOLICINA'  , 'N' ,  14 ,  5 })
AADD(aDBf,{ 'Cijena'    , 'N' ,  14 ,  5 })
AADD(aDBf,{ 'Rabat'     , 'N' ,   8 ,  5 })
AADD(aDBf,{ 'Porez'     , 'N' ,   9 ,  5 })
AADD(aDBf,{ 'K1'        , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K2'        , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'M1'        , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TXT'       , 'M' ,  10 ,  0 })
AADD(aDBf,{ 'IDVRSTEP'  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDPM'      , 'C' ,  15 ,  0 })
AADD(aDBf,{ 'DOK_VEZA'  , 'C' , 150 ,  0 })
AADD(aDBf,{ 'FISC_RN'   , 'N' ,  10 ,  0 })
AADD(aDBf,{ 'C1'        , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'C2'        , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'C3'        , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'N1'        , 'N' ,  10 ,  3 })
AADD(aDBf,{ 'N2'        , 'N' ,  10 ,  3 })
AADD(aDBf,{ 'OPIS'      , 'C' , 120 ,  0 })

_created := .f.
_alias := "FAKT"
_table_name := "fakt_fakt"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif
 
CREATE_INDEX("1", "IdFirma+idtipdok+brdok+rbr+podbr", _alias)
CREATE_INDEX("2", "IdFirma+dtos(datDok)+idtipdok+brdok+rbr", _alias)
CREATE_INDEX("3","idroba+dtos(datDok)", _alias)
CREATE_INDEX("6", "idfirma+idpartner+idroba+idtipdok+dtos(datdok)", _alias)
CREATE_INDEX("7", "idfirma+idpartner+idroba+dtos(datdok)", _alias)
CREATE_INDEX("8", "datdok", _alias)
CREATE_INDEX("IDPARTN","idpartner", _alias)

// ----------------------------------------------------------------------------
// fakt_pripr
// ----------------------------------------------------------------------------

_alias := "FAKT_PRIPR"
_table_name := "fakt_pripr"
if !FILE(f18_ime_dbf(_alias))
    DBcreate2(_alias, aDbf)
endif
    
CREATE_INDEX("1", "IdFirma+idtipdok+brdok+rbr+podbr", _alias)
CREATE_INDEX("2", "IdFirma+dtos(datdok)", _alias)
CREATE_INDEX("3", "IdFirma+idroba+rbr", _alias)

// ----------------------------------------------------------------------------
// fakt_pripr9
// opcija smece
// ----------------------------------------------------------------------------
_alias := "FAKT_PRIPR9"
_table_name := "fakt_pripr9"
if !FILE(f18_ime_dbf(_alias))
    DBcreate2(_alias, aDbf)
endif
 
CREATE_INDEX("1","IdFirma+idtipdok+brdok+rbr+podbr", _alias)
CREATE_INDEX("2","IdFirma+dtos(datdok)", _alias)
CREATE_INDEX("3","IdFirma+idroba+rbr", _alias)

// ----------------------------------------------------------------------------
// _fakt
// ----------------------------------------------------------------------------
_alias := "_FAKT"
_table_name := "fakt__fakt"
if !FILE(f18_ime_dbf(_alias))
    DBcreate2(_alias, aDbf)
endif
CREATE_INDEX("1", "IdFirma+idtipdok+brdok+rbr+podbr", _alias)


// ----------------------------------------------------------------------------
// fakt_doks
// ----------------------------------------------------------------------------
    

aDbf:={}
AADD(aDBf, { 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf, { 'IdTIPDok'            , 'C' ,   2 ,  0 })
AADD(aDBf, { 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf, { 'PARTNER'             , 'C' ,  30 ,  0 })
AADD(aDBf, { 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf, { 'DINDEM'              , 'C' ,   3 ,  0 })
AADD(aDBf, { 'Iznos'               , 'N' ,  12 ,  3 })
AADD(aDBf, { 'Rabat'               , 'N' ,  12 ,  3 })
AADD(aDBf, { 'Rezerv'              , 'C' ,   1 ,  0 })
AADD(aDBf, { 'M1'                  , 'C' ,   1 ,  0 })
AADD(aDBf, { 'IDPARTNER'           , 'C' ,   6 ,  0 })
AADD(aDBf, { 'IDVRSTEP'            , 'C' ,   2 ,  0 })
AADD(aDBf, { 'DATPL'               , 'D' ,   8 ,  0 })
AADD(aDBf, { 'IDPM'                , 'C' ,  15 ,  0 })
AADD(aDBf, { 'DOK_VEZA'            , 'C' , 150 ,  0 })
AADD(aDBf, { 'OPER_ID'             , 'N' ,   3 ,  0 })
AADD(aDBf, { 'FISC_RN'             , 'N' ,  10 ,  0 })
AADD(aDBf, { 'DAT_ISP'             , 'D' ,   8 ,  0 })
AADD(aDBf, { 'DAT_VAL'             , 'D' ,   8 ,  0 })
AADD(aDBf, { 'DAT_OTPR'            , 'D' ,   8 ,  0 })

_created := .f.
_alias := "FAKT_DOKS"
_table_name := "fakt_doks"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

// 0.4.3
if ver["current"] < 0403
    modstru({"*" + _table_name, "A FISC_ST N 10 0"})
endif

if _created 
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

CREATE_INDEX("1", "IdFirma+idtipdok+brdok", _alias)
CREATE_INDEX("2", "IdFirma+idtipdok+partner", _alias)
CREATE_INDEX("3", "partner", _alias)
CREATE_INDEX("4", "idtipdok", _alias)
CREATE_INDEX("5", "datdok", _alias)
CREATE_INDEX("6", "IdFirma+idpartner+idtipdok", _alias)

return .t.
