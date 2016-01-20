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
#include "cre_all.ch"


// -----------------------------------------------------------
// kreiranje tabela za proizvoljne izvjestaje
// -----------------------------------------------------------
function proizvoljni_izvjestaji_db_cre()
local aDbf
local _alias, _table_name
local _created

aDBf := {}
AADD( aDBf, { 'ID'      , 'C' ,   2 ,  0 } )
AADD( aDBf, { 'NAZ'     , 'C' ,  50 ,  0 } )
AADD( aDBf, { 'USLOV'   , 'C' ,  80 ,  0 } )
AADD( aDBf, { 'KPOLJE'  , 'C' ,  50 ,  0 } )
AADD( aDBf, { 'IMEKP'   , 'C' ,  10 ,  0 } )
AADD( aDBf, { 'KSIF'    , 'C' ,  50 ,  0 } )
AADD( aDBf, { 'KBAZA'   , 'C' ,  50 ,  0 } )
AADD( aDBf, { 'KINDEKS' , 'C' ,  80 ,  0 } )
AADD( aDBf, { 'TIPTAB'  , 'C' ,   1 ,  0 } )
 
_alias := "IZVJE"
_table_name := "fin_izvje"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE
 
CREATE_INDEX( "ID", "id", _alias )


// KOLIZ.DBF (fin_koliz.dbf)

aDBf := {}
AADD(aDBf,{ 'ID'      , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'NAZ'     , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'RBR'     , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'FORMULA' , 'C' , 150 ,  0 })
AADD(aDBf,{ 'TIP'     , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'SIRINA'  , 'N' ,   3 ,  0 })
AADD(aDBf,{ 'DECIMALE', 'N' ,   1 ,  0 })
AADD(aDBf,{ 'SUMIRATI', 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K1'      , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'      , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'N1'      , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'N2'      , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'KUSLOV'  , 'C' , 100 ,  0 })
AADD(aDBf,{ 'SIZRAZ'  , 'C' , 100 ,  0 })
 
_alias := "KOLIZ"
_table_name := "fin_koliz"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE
 
CREATE_INDEX("ID","id"         , _alias )
CREATE_INDEX("1" ,"STR(rbr,2)" , _alias )



// ZAGLI.DBF (fin_zagli.dbf)

aDbf := {}
AADD(aDBf,{ 'ID'      , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'x1'      , 'N' ,   3 ,  0 })
AADD(aDBf,{ 'y1'      , 'N' ,   3 ,  0 })
AADD(aDBf,{ 'IZRAZ'   , 'C' , 100 ,  0 })

_alias := "ZAGLI"
_table_name := "fin_zagli"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE
 
CREATE_INDEX( "ID", "id"                  , _alias ) 
CREATE_INDEX( "1" , "STR(x1,3)+STR(y1,3)" , _alias )


// KONIZ.DBF ( fin_koniz.dbf )

aDBf:={}
AADD(aDBf,{ 'IZV'     , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'ID'      , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'ID2'     , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'OPIS'    , 'C' ,  57 ,  0 })
AADD(aDBf,{ 'RI'      , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'FI'      , 'C' ,  80 ,  0 })
AADD(aDBf,{ 'FI2'     , 'C' ,  80 ,  0 })
AADD(aDBf,{ 'K'       , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K2'      , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'PREDZN'  , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'PREDZN2' , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'PODVUCI' , 'C' ,   1 ,  0 })
AADD(aDbf,{ "K1"      , "C" ,   1 ,  0 })          
AADD(aDbf,{ "U1"      , "C" ,   3 ,  0 })          
 
_alias := "KONIZ"
_table_name := "fin_koniz"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "ID", "id", _alias )
CREATE_INDEX( "1", "izv+STR(ri,4)", _alias )

return





