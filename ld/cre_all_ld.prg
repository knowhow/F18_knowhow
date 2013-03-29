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


static __LD_FIELDS_COUNT := 60



function cre_all_ld_sif(ver)
local _table_name, _alias, _created
local aDbf

// ---------------------------------------------------------
// KRED.DBF
// ---------------------------------------------------------

aDBf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
add_f_mcode(@aDbf)
AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'ZIRO'                , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'ZIROD'               , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'TELEFON'             , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'MJESTO'              , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'ADRESA'              , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'PTT'                 , 'C' ,   5 ,  0 })
AADD(aDBf,{ 'FIL'                 , 'C' ,  30 ,  0 })

_alias := "KRED"
_table_name := "kred"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID", "id", _alias )
CREATE_INDEX( "NAZ", "naz", _alias )

_alias := "_KRED"
_table_name := "_kred"

IF_NOT_FILE_DBF_CREATE

// ------------------------------------------------------------
// POR.DBF
// ------------------------------------------------------------

aDBf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
add_f_mcode(@aDbf)
AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'IZNOS'               , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'DLIMIT'              , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'POOPST'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'POR_TIP'             , 'C' ,   1 ,  0 })
// stepenasti porez
AADD(aDBf,{ 'ALGORITAM'           , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'S_STO_1'             , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'S_IZN_1'             , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S_STO_2'             , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'S_IZN_2'             , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S_STO_3'             , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'S_IZN_3'             , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S_STO_4'             , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'S_IZN_4'             , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S_STO_5'             , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'S_IZN_5'             , 'N' ,  12 ,  2 })

_alias := "POR"
_table_name := "por"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID", "id", _alias )

// -----------------------------------------------------------
// DOPR.DBF
// -----------------------------------------------------------

aDBf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
add_f_mcode(@aDbf)
AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'IZNOS'               , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'IdKBenef'            , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'DLIMIT'              , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'POOPST'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'DOP_TIP'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TIPRADA'             , 'C' ,   1 ,  0 })

_alias := "DOPR"
_table_name := "dopr"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID", "id", _alias )
CREATE_INDEX( "1", "id+naz+tiprada", _alias )



// -------------------------------------------------------
// STRSPR.DBF
// -------------------------------------------------------

aDbf := {}
AADD( aDBf,{ 'ID'              , 'C' ,   3 ,  0 })
AADD( aDBf,{ 'NAZ'             , 'C' ,  20 ,  0 })
AADD( aDBf,{ 'NAZ2'            , 'C' ,   6 ,  0 })

_alias := "STRSPR"
_table_name := "strspr"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID","id", _alias )


// --------------------------------------------------------
// KBENEF.DBF
// --------------------------------------------------------

aDbf := {}
AADD( aDBf,{ 'ID'              , 'C' ,   1 ,  0 })
AADD( aDBf,{ 'NAZ'             , 'C' ,   8 ,  0 })
AADD( aDBf,{ 'IZNOS'           , 'N' ,   5 ,  2 })

_alias := "KBENEF"
_table_name := "kbenef"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID", "id", _alias )



// --------------------------------------------------------
// VPOSLA.DBF
// --------------------------------------------------------

aDbf := {}
AADD( aDBf,{ 'ID'              , 'C' ,   2 ,  0 })
AADD( aDBf,{ 'NAZ'             , 'C' ,  20 ,  0 })
AADD( aDBf,{ 'IDKBENEF'        , 'C' ,   1 ,  0 })

_alias := "VPOSLA"
_table_name := "vposla"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID", "id", _alias )


// ---------------------------------------------------------
// TIPPR.DBF
// ---------------------------------------------------------

aDBf := {}
AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'Aktivan'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'Fiksan'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'UFS'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'UNeto'               , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'Koef1'               , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'Formula'             , 'C' , 200 ,  0 })
AADD(aDBf,{ 'OPIS'                , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'TPR_TIP'             , 'C' ,   1 ,  0 })

_alias := "TIPPR"
_table_name := "tippr"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID", "id", _alias )

_alias := "TIPPR2"
_table_name := "tippr2"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID", "id", _alias )

return .t.



// -------------------------------
// -------------------------------
function cre_all_ld(ver)
local aDbf
local _alias, _table_name
local _created
local _i, _field_sati, _field_iznos
local _tmp

// -----------------------
// RADN.DBF
// -----------------------

aDbf := {}
AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
add_f_mcode(@aDbf)
AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'IMEROD'              , 'C' ,  15 ,  0 })
AADD(aDBf,{ 'IME'                 , 'C' ,  15 ,  0 })
AADD(aDBf,{ 'BRBOD'               , 'N' ,  11 ,  2 })
AADD(aDBf,{ 'KMINRAD'             , 'N' ,   7 ,  2 })
AADD(aDBf,{ 'KLO'                 , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'SP_KOEF'             , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'TIPRADA'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'IDVPOSLA'            , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'OSNBOL'              , 'N' ,  11 ,  4 })
AADD(aDBf,{ 'IDSTRSPR'            , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IDOPSST'             , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'IDOPSRAD'            , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'POL'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MATBR'               , 'C' ,  13 ,  0 })
AADD(aDBf,{ 'DATOD'               , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'brknjiz'             , 'C' ,  12,   0 })
AADD(aDBf,{ 'brtekr'              , 'C' ,  40,   0 })
AADD(aDBf,{ 'Isplata'             , 'C' ,   2,   0 })
AADD(aDBf,{ 'IdBanka'             , 'C' ,   6,   0 })
AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K3'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K4'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'RMJESTO'             , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'POROL'               , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'IDRJ'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'STREETNAME'          , 'C' ,  40 ,  0 })
AADD(aDBf,{ 'STREETNUM'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'HIREDFROM'           , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'HIREDTO'             , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'BEN_SRMJ'            , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'AKTIVAN'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'N1'                  , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'N2'                  , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'N3'                  , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S1'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'S2'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'S3'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'S4'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'S5'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'S6'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'S7'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'S8'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'S9'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'OPOR'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TROSK'               , 'C' ,   1 ,  0 })

_alias := "RADN"
_table_name := "ld_radn"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "1", "id" , _alias )
CREATE_INDEX( "2", "naz", _alias )


// -------------------------------------
// _RADN
// -------------------------------------
_alias := "_RADN"
_table_name := "_ld_radn"

IF_NOT_FILE_DBF_CREATE


// ----------------------------------------------
// LD_RJ
// ----------------------------------------------

aDBf := {}
AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
add_f_mcode(@aDbf)
AADD(aDBf,{ 'NAZ'                 , 'C' ,  35 ,  0 })
AADD(aDBf,{ 'TIPRADA'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'OPOR'                , 'C' ,   1 ,  0 })

_alias := "LD_RJ"
_table_name := "ld_rj"
    
IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID","id", _alias )


// -----------------------------------------------
// RADKR.DBF
// -----------------------------------------------
aDbf := {}
AADD(aDBf,{ 'IDRadn'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'Mjesec'              , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'Godina'              , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'IdKred'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'Iznos'               , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'Placeno'             , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'NaOsnovu'            , 'C' ,  20 ,  0 })

_alias := "RADKR"
_table_name := "ld_radkr"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("1","str(godina)+str(mjesec)+idradn+idkred+naosnovu", _alias)
CREATE_INDEX("2","idradn+idkred+naosnovu+str(godina)+str(mjesec)", _alias)
CREATE_INDEX("3","idkred+naosnovu+idradn+str(godina)+str(mjesec)", _alias)
CREATE_INDEX("4","str(godina)+str(mjesec)+idradn+naosnovu", _alias)

// --------------------------------------------------
// _RADKR.DBF
// --------------------------------------------------
_alias := "_RADKR"
_table_name := "_ld_radkr"

IF_NOT_FILE_DBF_CREATE


// ---------------------------------------------------
// LD
// ---------------------------------------------------

aDBf := {}
AADD(aDBf,{ 'Godina'              , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'IDRJ'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDRADN'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'Mjesec'              , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'BRBOD'               , 'N' ,  11 ,  2 })
AADD(aDBf,{ 'IdStrSpr'            , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IdVPosla'            , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'KMinRad'             , 'N' ,   7 ,  2 })

// generisanje kolona iznos/sati
for _i := 1 to __LD_FIELDS_COUNT
    
    _field_sati := "S" + PADL( ALLTRIM( STR( _i ) ), 2, "0" )
    _field_iznos := "I" + PADL( ALLTRIM( STR( _i ) ), 2, "0" )

    AADD( aDBf, { _field_sati, 'N' ,   6 ,  2 })
    AADD( aDBf, { _field_iznos, 'N' ,  12 ,  2 })

next

AADD(aDBf,{ 'USATI'               , 'N' ,   8 ,  1 })
AADD(aDBf,{ 'UNETO'               , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'UODBICI'             , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'UIZNOS'              , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'UNETO2'              , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'UBRUTO'              , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'UPOREZ'              , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'UPOR_ST'             , 'N' ,  10 ,  2 })
AADD(aDBf,{ 'UDOPR'               , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'UDOP_ST'             , 'N' ,  10 ,  2 })
AADD(aDBf,{ 'NAKN_OPOR'           , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'NAKN_NEOP'           , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'ULICODB'             , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'TIPRADA'             , 'C' ,   1 ,  2 })
AADD(aDBf,{ 'OPOR'                , 'C' ,   1 ,  2 })
AADD(aDBf,{ 'TROSK'               , 'C' ,   1 ,  2 })
AADD(aDBf,{ 'VAROBR'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'V_ISPL'              , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'OBR'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'RADSAT'              , 'N' ,  10 ,  0 })

_alias := "LD"
_table_name := "ld_ld"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("1","str(godina)+idrj+str(mjesec)+obr+idradn", _alias)
CREATE_INDEX("2","str(godina)+str(mjesec)+obr+idradn+idrj", _alias)
CREATE_INDEX("3","str(godina)+idrj+idradn", _alias)
CREATE_INDEX("4","str(godina)+idradn+str(mjesec)+obr", _alias)
CREATE_INDEX("1U","str(godina)+idrj+str(mjesec)+idradn", _alias)
CREATE_INDEX("2U","str(godina)+str(mjesec)+idradn+idrj", _alias)
CREATE_INDEX("RADN","idradn", _alias)


// --------------------------------------
// LD_LDSM
// --------------------------------------
_alias := "LDSM"
_table_name := "ld_ldsm"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("1","Obr+str(godina)+str(mjesec)+idradn+idrj", _alias)
CREATE_INDEX("RADN", "idradn", _alias)


// --------------------------------------
// LD__LD
// --------------------------------------
_alias := "_LD"
_table_name := "_ld_ld"

IF_NOT_FILE_DBF_CREATE


// --------------------------------------------
// PAROBR.DBF
// --------------------------------------------
aDBf := {}
AADD(aDBf, { 'ID'                  , 'C' ,   2 ,  0 })  
AADD(aDBf, { 'GODINA'              , 'C' ,   4 ,  0 })  
AADD(aDBf, { 'NAZ'                 , 'C' ,  10 ,  0 })
AADD(aDBf, { 'IDRJ'                , 'C' ,   2 ,  0 })
AADD(aDBf, { 'VrBod'               , 'N' ,  15 ,  5 })
AADD(aDBf, { 'K1'                  , 'N' ,  11 ,  6 })
AADD(aDBf, { 'K2'                  , 'N' ,  11 ,  6 })
AADD(aDBf, { 'K3'                  , 'N' ,   9 ,  5 })
AADD(aDBf, { 'K4'                  , 'N' ,   6 ,  3 })
AADD(aDBf, { 'K5'                  , 'N' ,  12 ,  6 })
AADD(aDBf, { 'K6'                  , 'N' ,  12 ,  6 })
AADD(aDBf, { 'K7'                  , 'N' ,  11 ,  6 })
AADD(aDBf, { 'K8'                  , 'N' ,  11 ,  6 })
AADD(aDBf, { 'OBR'                 , 'C' ,   1 ,  0 })
AADD(aDBf, { 'PROSLD'              , 'N' ,  12 ,  2 })
AADD(aDBf, { 'M_BR_SAT'            , 'N' ,  12 ,  2 })
AADD(aDBf, { 'M_NET_SAT'           , 'N' ,  12 ,  2 })
        
_alias := "PAROBR"
_table_name := "ld_parobr"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID", "id + godina + obr", _alias )


// ---------------------------------------
// OBRACUNI.DBF
// ---------------------------------------
        
aDbf := {}
        
AADD(aDBf,{'RJ','C',2,0})
AADD(aDBf,{'GODINA','N',4,0})
AADD(aDBf,{'MJESEC','N',2,0})
AADD(aDBf,{'STATUS','C',1,0})
AADD(aDBf,{'OBR','C',1,0})
AADD(aDBf,{'K1','C',4,0})
AADD(aDBf,{'K2','C',10,0})
AADD(aDBf,{'MJ_ISPL','N',2,0})
AADD(aDBf,{'DAT_ISPL','D',8,0})
AADD(aDBf,{'ISPL_ZA','C',50,0})
AADD(aDBf,{'VR_ISPL','C',50,0})

_alias := "OBRACUNI"
_table_name := "ld_obracuni"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("RJ", "rj+STR(godina)+STR(mjesec)+status+obr", _alias)


// -----------------------------------------------------------
// PK_RADN
// -----------------------------------------------------------

aDbf := {}
AADD(aDBf,{ 'idradn'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'zahtjev'             , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'datum'               , 'D' ,   8 ,  0 })

// 1. podaci o radniku
// -----------------------------------------------------
// prezime
AADD(aDBf,{ 'r_prez'              , 'C' ,   20 ,  0 })
// ime
AADD(aDBf,{ 'r_ime'               , 'C' ,   20 ,  0 })
// ime oca
AADD(aDBf,{ 'r_imeoca'            , 'C' ,   20 ,  0 })
// jmb
AADD(aDBf,{ 'r_jmb'               , 'C' ,   13 ,  0 })
// adresa prebivalista
AADD(aDBf,{ 'r_adr'               , 'C' ,   30 ,  0 })
// opcina prebivalista
AADD(aDBf,{ 'r_opc'               , 'C' ,   30 ,  0 })
// opcina prebivalista "kod"
AADD(aDBf,{ 'r_opckod'            , 'C' ,   10 ,  0 })
// datum rodjenja
AADD(aDBf,{ 'r_drodj'             , 'D' ,    8 ,  0 })
// telefon
AADD(aDBf,{ 'r_tel'               , 'N' ,   12 ,  0 })

// 2. podaci o poslodavcu
// -----------------------------------------------------
// naziv poslodavca
AADD(aDBf,{ 'p_naziv'             , 'C' ,  100 ,  0 })
// jib poslodavca
AADD(aDBf,{ 'p_jib'               , 'C' ,   13 ,  0 })
// zaposlen TRUE/FALSE
AADD(aDBf,{ 'p_zap'               , 'C' ,    1 ,  0 })

// 3. podaci o licnim odbicima
// -----------------------------------------------------
// osnovni licni odbitak
AADD(aDBf,{ 'lo_osn'            , 'N' ,  10 ,  3 })
// licni odbitak za bracnog druga
AADD(aDBf,{ 'lo_brdr'           , 'N' ,  10 ,  3 })
// licni odbitak za izdrzavanu djecu
AADD(aDBf,{ 'lo_izdj'           , 'N' ,  10 ,  3 })
// licni odbitak za clanove porodice
AADD(aDBf,{ 'lo_clp'            , 'N' ,  10 ,  3 })
// licni odbitak za clanove porodice sa invaliditeom
AADD(aDBf,{ 'lo_clpi'           , 'N' ,  10 ,  3 })
// ukupni faktor licnog odbitka
AADD(aDBf,{ 'lo_ufakt'          , 'N' ,  10 ,  3 })

_alias := "PK_RADN"
_table_name := "ld_pk_radn"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "1", "idradn", _alias )
CREATE_INDEX( "2", "STR(zahtjev)", _alias )


// ---------------------------------------------------
// PK_DATA
// ---------------------------------------------------

aDbf := {}

// id radnik
AADD(aDBf,{ 'idradn'              , 'C' ,   6 ,  0 })
// identifikator podatka (1) bracni drug
//                       (2) djeca
//                       (3) clanovi porodice ....
AADD(aDBf,{ 'ident'               , 'C' ,   1 ,  0 })
// redni broj
AADD(aDBf,{ 'rbr'                 , 'N' ,   2 ,  0 })
// ime i prezime
AADD(aDBf,{ 'ime_pr'              , 'C' ,   50 ,  0 })
// jmb
AADD(aDBf,{ 'jmb'                 , 'C' ,   13 ,  0 })
// srodstvo naziv
AADD(aDBf,{ 'sr_naz'              , 'C' ,   30 ,  0 })
// kod srodstva
AADD(aDBf,{ 'sr_kod'              , 'N' ,   2 ,  0 })
// prihod vlastiti
AADD(aDBf,{ 'prihod'              , 'N' ,    10 ,  2 })
// udio u izdrzavanju
AADD(aDBf,{ 'udio'                , 'N' ,    3 ,  0 })
// koeficijent odbitka
AADD(aDBf,{ 'koef'                , 'N' ,    10 ,  3 })

_alias := "PK_DATA"
_table_name := "ld_pk_data"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "1", "idradn+ident+STR(rbr)", _alias )



// -------------------------------------
// RADSAT.DBF
// -------------------------------------

_alias := "RADSAT"
_table_name := "ld_radsat"

aDbf:={}
AADD(aDBf, {'IDRADN' , 'C',  6,  0})
AADD(aDBf, {'SATI'   , 'N', 10, 0})
AADD(aDBf, {'STATUS' , 'C',  2, 0})

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("IDRADN", "idradn", _alias)


// ------------------------------------------
// RADSIHT
// ------------------------------------------
aDbf := {}
AADD(aDBf,{ 'Godina'              , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'Mjesec'              , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'Dan'                 , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'DanDio'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'IDRJ'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDRADN'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'OPIS'                , 'C' ,  50 ,  0 })
AADD(aDBf,{ 'IDTipPR'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRBOD'               , 'N' ,  11 ,  2 })
AADD(aDBf,{ 'IdNorSiht'           , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'Izvrseno'            , 'N' ,  14 ,  3 })
AADD(aDBf,{ 'Bodova'              , 'N' ,  14 ,  2 })

_alias := "RADSIHT"
_table_name := "ld_radsiht"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("1","str(godina)+str(mjesec)+idradn+idrj+str(dan)+dandio+idtippr", _alias  )
CREATE_INDEX("2","idkonto+str(godina)+str(mjesec)+idradn", _alias )
CREATE_INDEX("3","idnorsiht+str(godina)+str(mjesec)+idradn", _alias )
CREATE_INDEX("4","idradn+str(godina)+str(mjesec)+idkonto", _alias )
CREATE_INDEX("2i","idkonto+SORTIME(idradn)+str(godina)+str(mjesec)", _alias )


// ------------------------------------------------------------
// NORSIHT - norme u sihtarici 
//         - koristi se vjerovatno samo kod rada u normi
// ------------------------------------------------------------
aDbf := {}
AADD(aDBf,{ 'ID'                , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'NAZ'               , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'JMJ'               , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'Iznos'             , 'N' ,   8 ,  2 })
AADD(aDBf,{ 'N1'                , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'K1'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'                , 'C' ,   2 ,  0 })

_alias := "NORSIHT"
_table_name := "ld_norsiht"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID", "id", _alias )
CREATE_INDEX( "NAZ", "NAZ", _alias )

// ---------------------------------------------------------------
// TPRSIHT   - tipovi primanja koji odradjuju sihtaricu
// ---------------------------------------------------------------
aDbf := {}
AADD(aDBf,{ 'ID'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'NAZ'               , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'K1'                , 'C' ,   1 ,  0 })
// K1="F" - po formuli
//    " " - direktno se unose bodovi
AADD(aDBf,{ 'K2'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K3'                , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'FF'                , 'C' ,  30 ,  0 })

_alias := "TPRSIHT"
_table_name := "ld_tprsiht"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID","id", _alias )
CREATE_INDEX( "NAZ","NAZ", _alias )

return .t.



