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


function cre_all_fin( ver )
local aDbf
local _alias, _table_name
local _created

// -----------------------------------------------------------
// FIN_SUBAN
// -----------------------------------------------------------

aDbf := {}
AADD(aDBf,{ "IDFIRMA"             , "C" ,   2 ,  0 })
AADD(aDBf,{ "IDKONTO"             , "C" ,   7 ,  0 })
AADD(aDBf,{ "IDPARTNER"           , "C" ,   6 ,  0 })
AADD(aDBf,{ "IDVN"                , "C" ,   2 ,  0 })
AADD(aDBf,{ "BRNAL"               , "C" ,   8 ,  0 })
AADD(aDBf,{ "RBR"                 , "C" ,   4 ,  0 })
AADD(aDBf,{ "IDTIPDOK"            , "C" ,   2 ,  0 })
AADD(aDBf,{ "BRDOK"               , "C" ,   10 ,  0 })
AADD(aDBf,{ "DATDOK"              , "D" ,   8 ,  0 })
AADD(aDBf,{ "DatVal"              , "D" ,   8 ,  0 })
AADD(aDBf,{ "OTVST"               , "C" ,   1 ,  0 })
AADD(aDBf,{ "D_P"                 , "C" ,   1 ,  0 })
AADD(aDBf,{ "IZNOSBHD"            , "N" ,  21 ,  6 })
AADD(aDBf,{ "IZNOSDEM"            , "N" ,  19 ,  6 })
AADD(aDBf,{ "OPIS"                , "C" ,  80 ,  0 })
AADD(aDBf,{ "K1"                  , "C" ,   1 ,  0 })
AADD(aDBf,{ "K2"                  , "C" ,   1 ,  0 })
AADD(aDBf,{ "K3"                  , "C" ,   2 ,  0 })
AADD(aDBf,{ "K4"                  , "C" ,   2 ,  0 })
AADD(aDBf,{ "M1"                  , "C" ,   1 ,  0 })
AADD(aDBf,{ "M2"                  , "C" ,   1 ,  0 })
AADD(aDBf,{ "IDRJ"                , "C" ,   6 ,  0 })
AADD(aDBf,{ "FUNK"                , "C" ,   5 ,  0 })
AADD(aDBf,{ "FOND"                , "C" ,   4 ,  0 })

_alias := "SUBAN"
_table_name := "fin_suban"

IF_NOT_FILE_DBF_CREATE

// 0.3.0
if ver["current"] > 0 .and. ver["current"] < 00300
    modstru({"*" + _table_name, "A IDRJ C 6 0", "A FUNK C 5 0", "A FOND C 4 0" })
endif

IF_C_RESET_SEMAPHORE

CREATE_INDEX( "1", "IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr", _alias) 
CREATE_INDEX( "2", "IdFirma+IdPartner+IdKonto", _alias)
CREATE_INDEX( "3", "IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)", _alias)
CREATE_INDEX( "4", "idFirma+IdVN+BrNal+Rbr", _alias)
CREATE_INDEX( "5", "idFirma+IdKonto+dtos(DatDok)+idpartner", _alias)
CREATE_INDEX( "6", "IdKonto", _alias)
CREATE_INDEX( "7", "Idpartner", _alias)
CREATE_INDEX( "8", "Datdok", _alias)
CREATE_INDEX( "9", "idfirma+idkonto+idrj+idpartner+DTOS(datdok)+brnal+rbr", _alias)
CREATE_INDEX("10", "idFirma+IdVN+BrNal+idkonto+DTOS(datdok)", _alias)



// ----------------------------------------------------------------------------
// PSUBAN
// ----------------------------------------------------------------------------

_alias := "PSUBAN"
_table_name := "fin_psuban"

IF_NOT_FILE_DBF_CREATE

// 0.4.1
if ver["current"] > 0 .and. ver["current"] < 00401
    modstru({"*" + _table_name, "A IDRJ C 6 0", "A FUNK C 5 0", "A FOND C 4 0" })
endif

CREATE_INDEX("1", "IdFirma+IdVn+BrNal", _alias)
CREATE_INDEX("2", "idFirma+IdVN+BrNal+IdKonto", _alias)


// ----------------------------------------------------------------------------
// FIN_PRIPR
// ----------------------------------------------------------------------------
_alias := "FIN_PRIPR"
_table_name := "fin_pripr"

IF_NOT_FILE_DBF_CREATE

// 0.4.1
if ver["current"] > 0 .and. ver["current"] < 00401
   modstru({"*" + _table_name, "A IDRJ C 6 0", "A FUNK C 5 0", "A FOND C 4 0" })
endif

CREATE_INDEX("1", "idFirma+IdVN+BrNal+Rbr", _alias)
CREATE_INDEX("2", "idFirma+IdVN+BrNal+IdKonto", _alias)

// -----------------------------------------------------------
// FIN_ANAL
// -----------------------------------------------------------

_alias := "ANAL"
_table_name := "fin_anal"

aDbf := {}
AADD(aDBf,{ "IDFIRMA"             , "C" ,   2 ,  0 })
AADD(aDBf,{ "IDKONTO"             , "C" ,   7 ,  0 })
AADD(aDBf,{ "IDVN"                , "C" ,   2 ,  0 })
AADD(aDBf,{ "BRNAL"               , "C" ,   8 ,  0 })
AADD(aDBf,{ "RBR"                 , "C" ,   3 ,  0 })
AADD(aDBf,{ "DATNAL"              , "D" ,   8 ,  0 })
AADD(aDBf,{ "DUGBHD"              , "N" ,  17 ,  2 })
AADD(aDBf,{ "POTBHD"              , "N" ,  17 ,  2 })
AADD(aDBf,{ "DUGDEM"              , "N" ,  15 ,  2 })
AADD(aDBf,{ "POTDEM"              , "N" ,  15 ,  2 })

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE           
 
CREATE_INDEX("1", "IdFirma+IdKonto+dtos(DatNal)", _alias)
CREATE_INDEX("2", "idFirma+IdVN+BrNal+Rbr", _alias)
CREATE_INDEX("3", "idFirma+dtos(DatNal)", _alias) 
CREATE_INDEX("4", "Idkonto", _alias)
CREATE_INDEX("5", "DatNal", _alias)
    

// ----------------------------------------------------------------------------
// PANAL
// ----------------------------------------------------------------------------

_alias := "PANAL"
_table_name := "fin_panal"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("1", "IdFirma+IdVn+BrNal+idkonto", _alias)


// ----------------------------------------------------------------------------
// FIN_SINT
// ----------------------------------------------------------------------------

aDbf := {}
AADD(aDBf,{ "IDFIRMA"             , "C" ,   2 ,  0 })
AADD(aDBf,{ "IDKONTO"             , "C" ,   3 ,  0 })
AADD(aDBf,{ "IDVN"                , "C" ,   2 ,  0 })
AADD(aDBf,{ "BRNAL"               , "C" ,   8 ,  0 })
AADD(aDBf,{ "RBR"                 , "C" ,   3 ,  0 })
AADD(aDBf,{ "DATNAL"              , "D" ,   8 ,  0 })
AADD(aDBf,{ "DUGBHD"              , "N" ,  17 ,  2 })
AADD(aDBf,{ "POTBHD"              , "N" ,  17 ,  2 })
AADD(aDBf,{ "DUGDEM"              , "N" ,  15 ,  2 })
AADD(aDBf,{ "POTDEM"              , "N" ,  15 ,  2 })

_alias := "SINT"
_table_name := "fin_sint"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE
 
CREATE_INDEX("1", "IdFirma+IdKonto+dtos(DatNal)", _alias)
CREATE_INDEX("2", "idFirma+IdVN+BrNal+Rbr", _alias)
CREATE_INDEX("3", "datnal", _alias)

// ----------------------------------------------------------------------------
// PSINT
// ----------------------------------------------------------------------------

_alias := "PSINT"
_table_name := "fin_psint"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("1", "IdFirma+IdVn+BrNal+idkonto", _alias)



// ----------------------------------------------------------------------------
// FIN_NALOG
// ----------------------------------------------------------------------------

aDbf := {}
AADD(aDBf,{ "IDFIRMA"             , "C" ,   2 ,  0 })
AADD(aDBf,{ "IDVN"                , "C" ,   2 ,  0 })
AADD(aDBf,{ "BRNAL"               , "C" ,   8 ,  0 })
AADD(aDBf,{ "DATNAL"              , "D" ,   8 ,  0 })
AADD(aDBf,{ "DUGBHD"              , "N" ,  17 ,  2 })
AADD(aDBf,{ "POTBHD"              , "N" ,  17 ,  2 })
AADD(aDBf,{ "DUGDEM"              , "N" ,  15 ,  2 })
AADD(aDBf,{ "POTDEM"              , "N" ,  15 ,  2 })

_alias := "NALOG"
_table_name := "fin_nalog"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("1", "IdFirma+IdVn+BrNal", _alias) 
CREATE_INDEX("2", "IdFirma+str(val(BrNal),8)+idvn", _alias) 
CREATE_INDEX("3", "dtos(datnal)+IdFirma+idvn+brnal", _alias) 
CREATE_INDEX("4", "datnal", _alias) 



// -----------------------------------------------------------
// PNALOG
// -----------------------------------------------------------

_alias := "PNALOG"
_table_name := "fin_pnalog"

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("1","IdFirma+IdVn+BrNal", _alias)



// -----------------------------------------------------------
// FIN_FUNK
// -----------------------------------------------------------

aDbf := {}
AADD(aDBf,{ "ID"      , "C" ,   5 ,  0 })
AADD(aDBf,{ "NAZ"     , "C" ,  35 ,  0 })
 
_alias := "FUNK"
_table_name := "fin_funk"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE
    
CREATE_INDEX("ID","id", _alias )
CREATE_INDEX("NAZ","NAZ", _alias )


// -----------------------------------------------------------
// FIN_FOND
// -----------------------------------------------------------

aDbf := {}
AADD(aDBf,{ "ID"      , "C" ,   4 ,  0 })
AADD(aDBf,{ "NAZ"     , "C" ,  35 ,  0 })
 
_alias := "FOND"
_table_name := "fin_fond"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE
    
CREATE_INDEX("ID","id", _alias )
CREATE_INDEX("NAZ","NAZ", _alias )



// -----------------------------------------------------------
// FIN_BUDZET
// -----------------------------------------------------------

aDBf := {}
AADD(aDBf,{ "IDRJ"                , "C" ,   6 ,  0 })
AADD(aDBf,{ "IDKONTO"             , "C" ,   7 ,  0 })
AADD(aDBf,{ "IZNOS"               , "N" ,  20 ,  2 })
AADD(aDBf,{ "FOND"                , "C" ,   3 ,  0 })
AADD(aDBf,{ "FUNK"                , "C" ,   5 ,  0 })
AADD(aDBf,{ "REBIZNOS"            , "N" ,  20 ,  2 })
 
_alias := "BUDZET"
_table_name := "fin_budzet"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE
    
CREATE_INDEX( "1", "IdRj+Idkonto", _alias )
CREATE_INDEX( "2", "Idkonto",      _alias )



// -----------------------------------------------------------
// FIN_PAREK
// -----------------------------------------------------------

_alias := "PAREK"
_table_name := "fin_parek"

aDBf := {}
AADD(aDBf,{ "IDPARTIJA"           , "C" ,   6 ,  0 })
AADD(aDBf,{ "Idkonto"             , "C" ,   7 ,  0 })

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("1","IdPartija", _alias )



// -----------------------------------------------------------
// FIN_BUIZ
// -----------------------------------------------------------

_alias := "BUIZ"
_table_name := "fin_buiz"

aDBf := {}
AADD( aDBf, { "ID"        , "C" ,   7 ,  0 })
AADD( aDBf, { "NAZ"       , "C" ,  10 ,  0 })

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID"  , "ID"  , _alias )
CREATE_INDEX( "NAZ" , "NAZ" , _alias )


// -----------------------------------------------------------
// FIN_ULIMIT
// -----------------------------------------------------------

_alias := "ULIMIT"
_table_name := "fin_ulimit"

aDBf := {}
AADD(aDBf,{ "ID"        , "C" ,   3 ,  0 })
AADD(aDBf,{ "IDPARTNER" , "C" ,   6 ,  0 })
AADD(aDBf,{ "F_LIMIT"   , "N" ,  15 ,  2 })
 
IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE
   
CREATE_INDEX("ID","Id"          , _alias )
CREATE_INDEX("2" ,"Id+idpartner", _alias )



// -----------------------------------------------------------
// FIN_KONTO
// -----------------------------------------------------------

_alias := "_KONTO"
_table_name := "fin_konto"
    
aDbf := {}
AADD(aDBf,{ "ID"                  , "C" ,   7 ,  0 })
AADD(aDBf,{ "NAZ"                 , "C" ,  57 ,  0 })
AADD(aDBf,{ "POZBILU"             , "C" ,   3 ,  0 })
AADD(aDBf,{ "POZBILS"             , "C" ,   3 ,  0 })

IF_NOT_FILE_DBF_CREATE



// -----------------------------------------------------------
// FIN_BBKLAS
// -----------------------------------------------------------

_alias := "BBKLAS"
_table_name := "fin_bbklas"

aDbf := {}
AADD(aDBf,{ "IDKLASA"             , "C" ,   1 ,  0 })
AADD(aDBf,{ "POCDUG"              , "N" ,  17 ,  2 })
AADD(aDBf,{ "POCPOT"              , "N" ,  17 ,  2 })
AADD(aDBf,{ "TEKPDUG"             , "N" ,  17 ,  2 })
AADD(aDBf,{ "TEKPPOT"             , "N" ,  17 ,  2 })
AADD(aDBf,{ "KUMPDUG"             , "N" ,  17 ,  2 })
AADD(aDBf,{ "KUMPPOT"             , "N" ,  17 ,  2 })
AADD(aDBf,{ "SALPDUG"             , "N" ,  17 ,  2 })
AADD(aDBf,{ "SALPPOT"             , "N" ,  17 ,  2 })

IF_NOT_FILE_DBF_CREATE
    
CREATE_INDEX("1","IdKlasa", _alias )



// -----------------------------------------------------------
// FIN_IOS
// -----------------------------------------------------------

_alias := "IOS"
_table_name := "fin_ios"

aDbf := {}
AADD(aDBf,{ "IDFIRMA"             , "C" ,   2 ,  0 })
AADD(aDBf,{ "IDKONTO"             , "C" ,   7 ,  0 })
AADD(aDBf,{ "IDPARTNER"           , "C" ,   6 ,  0 })
AADD(aDBf,{ "IZNOSBHD"            , "N" ,  17 ,  2 })
AADD(aDBf,{ "IZNOSDEM"            , "N" ,  15 ,  2 })

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("1","IdFirma+IdKonto+IdPartner", _alias )




// -----------------------------------------------------------
// VKSG
// -----------------------------------------------------------

_alias := "VKSG"
_table_name := "vksg"

aDbf := {}
AADD(aDBf,{ "ID"                  , "C" ,   7 ,  0 })
AADD(aDBf,{ "GODINA"              , "C" ,   4 ,  0 })
AADD(aDBf,{ "IDS"                 , "C" ,   7 ,  0 })

IF_NOT_FILE_DBF_CREATE

CREATE_INDEX("1","id+DESCEND(godina)", _alias )



// -----------------------------------------------------------
// KAM_PRIPR
// -----------------------------------------------------------

_alias := "kam_pripr"
_table_name := "kam_pripr"

aDbf := {}
AADD(aDBf,{ "IDPARTNER"           , "C" ,   6 ,  0 })
AADD(aDBf,{ "IDKONTO"             , "C" ,   7 ,  0 })
AADD(aDBf,{ "BRDOK"               , "C" ,  10 ,  0 })
AADD(aDBf,{ "DATOD"               , "D" ,   8 ,  0 })
AADD(aDBf,{ "DATDO"               , "D" ,   8 ,  0 })
AADD(aDBf,{ "OSNOVICA"            , "N" ,  18 ,  2 })
AADD(aDBf,{ "OSNDUG"              , "N" ,  18 ,  2 })
AADD(aDBf,{ "M1"                  , "C" ,   1 ,  0 })

IF_NOT_FILE_DBF_CREATE
           
CREATE_INDEX("1", "idpartner+brdok+dtos(datod)", _alias)


// -----------------------------------------------------------
// KAM_KAMAT
// -----------------------------------------------------------

_alias := "kam_kamat"
_table_name := "kam_kamat"

IF_NOT_FILE_DBF_CREATE
           
CREATE_INDEX("1", "idpartner+brdok+dtos(datod)", _alias)



// kreiraj indexe tabele FMKRULES
cre_rule_cdx()

return



