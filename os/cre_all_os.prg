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

function cre_all_os(ver)
local aDbf
local _alias, _table_name
local _created

aDbf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'IDRJ'                , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'Datum'               , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DatOtp'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'OpisOtp'             , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'IdKonto'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'kolicina'            , 'N' ,   8 ,  1 })
AADD(aDBf,{ 'jmj'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IdAm'                , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'IdRev'               , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'NabVr'               , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'OtpVr'               , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'AmD'                 , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'AmP'                 , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'RevD'                , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'RevP'                , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'K1'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K2'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K3'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'Opis'                , 'C' ,  25 ,  0 })
AADD(aDBf,{ 'BrSoba'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IdPartner'           , 'C' ,   6 ,  0 })

// kreiraj tabelu OS

_alias := "os"
_table_name := "os_os"

IF !FILE( f18_ime_dbf( _alias ) )
    DBCREATE2( _alias, aDbf )
    reset_semaphore_version( _table_name )
    my_use( _alias )
ENDIF

CREATE_INDEX("1", "id+idam+dtos(datum)", _alias )
CREATE_INDEX("2", "idrj+id+dtos(datum)", _alias )
CREATE_INDEX("3", "idrj+idkonto+id",  _alias )
CREATE_INDEX("4", "idkonto+idrj+id", _alias )
CREATE_INDEX("5", "idam+idrj+id", _alias )


// kreiraj tabelu SII

_alias := "sii"
_table_name := "sii_sii"

IF !FILE( f18_ime_dbf( _alias ) )
    DBCREATE2( _alias, aDbf )
    reset_semaphore_version( _table_name )
    my_use( _alias )
ENDIF

CREATE_INDEX("1", "id+idam+dtos(datum)", _alias )
CREATE_INDEX("2", "idrj+id+dtos(datum)", _alias )
CREATE_INDEX("3", "idrj+idkonto+id",  _alias )
CREATE_INDEX("4", "idkonto+idrj+id", _alias )
CREATE_INDEX("5", "idam+idrj+id", _alias )


aDbf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'Opis'                , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'Datum'               , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'Tip'                 , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'NabVr'               , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'OtpVr'               , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'AmD'                , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'AmP'                , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'RevD'               , 'N' ,  18 ,  2 })
AADD(aDBf,{ 'RevP'               , 'N' ,  18 ,  2 })

// kreiraj os promjene
    
_alias := "promj"
_table_name := "os_promj"

IF !FILE( f18_ime_dbf( _alias ) )
    DBCREATE2( _alias, aDbf )
    reset_semaphore_version( _table_name )
    my_use( _alias )
ENDIF

CREATE_INDEX("1","id+tip+dtos(datum)+opis", _alias )


// kreiraj sii promjene

_alias := "sii_promj"
_table_name := "sii_promj"

IF !FILE( f18_ime_dbf( _alias ) )
    DBCREATE2( _alias, aDbf )
    reset_semaphore_version( _table_name )
    my_use( _alias )
ENDIF

CREATE_INDEX("1","id+tip+dtos(datum)+opis", _alias )


aDbf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
AADD(aDBf,{ 'IZNOS'               , 'N' ,   7 ,  3 })

_alias := "amort"
_table_name := "os_amort"
 
IF !FILE( f18_ime_dbf( _alias ) )
    DBCREATE2( _alias, aDbf )
    reset_semaphore_version( _table_name )
    my_use( _alias )
ENDIF

CREATE_INDEX( "ID", "id", _alias )

aDbf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'NAZ'                 , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'I1'                  , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I2'                  , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I3'                  , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I4'                  , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I5'                  , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I6'                  , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I7'                  , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I8'                  , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I9'                  , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I10'                 , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I11'                 , 'N' ,   7 ,  3 })
AADD(aDBf,{ 'I12'                 , 'N' ,   7 ,  3 })

_alias := "reval"
_table_name := "os_reval" 

IF !FILE( f18_ime_dbf( _alias ) )
    DBCREATE2( _alias, aDbf )
    reset_semaphore_version( _table_name )
    my_use( _alias )
ENDIF

CREATE_INDEX( "ID", "id", _alias )

aDBf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
 
_alias := "k1"
_table_name := "os_k1"

IF !FILE( f18_ime_dbf( _alias ) )
    DBCREATE2( _alias, aDbf )
    reset_semaphore_version( _table_name )
    my_use( _alias )
ENDIF

CREATE_INDEX( "ID", "id", _alias )
CREATE_INDEX( "NAZ", "NAZ", _alias )

return


