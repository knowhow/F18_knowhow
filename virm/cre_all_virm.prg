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

#include "f18.ch"
#include "cre_all.ch"


// -------------------------------
// -------------------------------
function cre_all_virm_sif(ver)
local aDbf
local _alias, _table_name
local _created


// -------------------
// VRPRIM
// -------------------

aDbf:={}
AADD(aDBf,{ 'ID'         , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NAZ'        , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'POM_TXT'    , 'C' ,  65 ,   0 })
AADD(aDBf,{ 'IDKONTO'    , 'C' ,   7 ,   0 })
AADD(aDBf,{ 'IDPartner'  , 'C' ,   6 ,   0 })
AADD(aDBf,{ 'NACIN_PL'   , 'C' ,   1 ,   0 })
AADD(aDBf,{ 'RACUN'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'DOBAV'      , 'C' ,   1 ,   0 })

_alias := "VRPRIM"
_table_name := "vrprim"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("ID","id", _alias )
CREATE_INDEX("NAZ","naz", _alias )
CREATE_INDEX("IDKONTO","idkonto+idpartner", _alias )


// -------------------
// VRPRIM2
// -------------------

_table_name := "vrprim2"
_alias := "VRPRIM2"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("ID","id", _alias )
CREATE_INDEX("NAZ","naz", _alias )
CREATE_INDEX("IDKONTO","idkonto+idpartner", _alias )

// -------------------
// LDVIRM
// -------------------

aDbf:={}
AADD(aDBf,{ 'ID'         , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NAZ'        , 'C' ,  50 ,   0 })
AADD(aDBf,{ 'FORMULA'    , 'C' ,  70 ,   0 })
	
_table_name := "ldvirm"
_alias := "LDVIRM"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("ID","id", _alias)


// -------------------
// KALVIR
// -------------------

aDbf:={}
AADD(aDBf,{ 'ID'         , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NAZ'        , 'C' ,  20 ,   0 })
AADD(aDBf,{ 'FORMULA'    , 'C' ,  70 ,   0 })
AADD(aDBf,{ 'PNABR'      , 'C' ,  10 ,   0 })
	
_table_name := "kalvir"
_alias := "KALVIR"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("ID","id", _alias )


// -------------------
// JPRIH
// -------------------

aDbf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IdN0'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'IdKan'               , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IdOps'               , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'Naz'                 , 'C' ,  40 ,  0 })
AADD(aDBf,{ 'Racun'               , 'C' ,  16 ,  0 })
AADD(aDBf,{ 'BudzOrg'             , 'C' ,  7 ,  0 })
	
_table_name := "jprih"
_alias := "JPRIH"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("Id","id+IdOps+IdKan+IdN0+Racun", _alias )
CREATE_INDEX("Naz","Naz+IdOps", _alias )

return .t.


// -------------------------------
// -------------------------------
function cre_all_virm(ver)
local aDbf
local _alias, _table_name
local _created

aDbf:={}
AADD(aDBf,{ 'RBR'        , 'N' ,   3 ,   0 })
AADD(aDBf,{ 'MJESTO'     , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'DAT_UPL'    , 'D' ,   8 ,   0 })
AADD(aDBf,{ 'SVRHA_PL'   , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NA_TERET'   , 'C' ,   6 ,   0 }) // ko  placa - sifra
AADD(aDBf,{ 'U_KORIST'   , 'C' ,   6 ,   0 }) // kome se placa - sifra
AADD(aDBf,{ 'KO_TXT'     , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KO_ZR'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KOME_TXT'   , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KOME_ZR'    , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KO_SJ'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KOME_SJ'    , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'SVRHA_DOZ'  , 'C' ,  92 ,   0 })
AADD(aDBf,{ 'PNABR'      , 'C' ,  10 ,   0 })
AADD(aDBf,{ 'Hitno'      , 'C' ,   1 ,   0 })
AADD(aDBf,{ 'Vupl'       , 'C' ,   1 ,   0 })
AADD(aDBF,{ 'IdOps'      , 'C' ,   3 ,   0 })
AADD(aDBF,{ 'POd'        , 'D' ,   8 ,   0 })
AADD(aDBF,{ 'PDo'        , 'D' ,   8 ,   0 })
AADD(aDBF,{ 'BPO'        , 'C' ,  13 ,   0 })
AADD(aDBF,{ 'BudzOrg'    , 'C' ,   7 ,   0 })
AADD(aDBF,{ 'IdJPrih'    , 'C' ,   6 ,   0 })
AADD(aDBf,{ 'IZNOS'      , 'N' ,  20 ,   2 })
AADD(aDBf,{ 'IZNOSSTR'   , 'C' ,  20 ,   0 })
AADD(aDBf,{ '_ST_'   ,     'C' ,   1 ,   0 })

_alias := "VIRM_PRIPR"
_table_name := "virm_pripr"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("1","STR(rbr,3)", _alias)
CREATE_INDEX("2","DTOS(dat_upl)+STR(rbr,3)", _alias)


aDbf:={}
AADD(aDBf,{ 'RBR'        , 'N' ,   3 ,   0 })
AADD(aDBf,{ 'MJESTO'     , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'DAT_UPL'    , 'C' ,  15 ,   0 })
AADD(aDBf,{ 'SVRHA_PL'   , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NA_TERET'   , 'C' ,   6 ,   0 }) // ko  placa - sifra
AADD(aDBf,{ 'U_KORIST'   , 'C' ,   6 ,   0 }) // kome se placa - sifra
AADD(aDBf,{ 'KO_TXT'     , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KO_ZR'      , 'C' ,  31 ,   0 })
AADD(aDBf,{ 'KOME_TXT'   , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KOME_ZR'    , 'C' ,  31 ,   0 })
AADD(aDBf,{ 'KO_SJ'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KOME_SJ'    , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'SVRHA_DOZ'  , 'C' ,  92 ,   0 })
AADD(aDBf,{ 'PNABR'      , 'C' ,  19 ,   0 })
AADD(aDBf,{ 'Hitno'      , 'C' ,   1 ,   0 })
AADD(aDBf,{ 'Vupl'       , 'C' ,   1 ,   0 })
AADD(aDBF,{ 'IdOps'      , 'C' ,   5 ,   0 })
AADD(aDBF,{ 'POd'        , 'C' ,  15 ,   0 })
AADD(aDBF,{ 'PDo'        , 'C' ,  15 ,   0 })
AADD(aDBF,{ 'BPO'        , 'C' ,  25 ,   0 })
AADD(aDBF,{ 'BudzOrg'    , 'C' ,  13 ,   0 })
AADD(aDBF,{ 'IdJPrih'    , 'C' ,  11 ,   0 })
AADD(aDBf,{ 'IZNOS'      , 'N' ,  20 ,   2 })
AADD(aDBf,{ 'IZNOSSTR'   , 'C' ,  20 ,   0 })
AADD(aDBf,{ '_ST_'   ,     'C' ,   1 ,   0 })

_alias := "IZLAZ"
_table_name := "izlaz"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("1","STR(rbr,3)", _alias )


return





