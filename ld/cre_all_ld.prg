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

function cre_all_ld( ver )
local aDbf
local _alias, _table_name
local _created

aDBf:={}
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

if !file(f18_ime_dbf("TIPPR"))
    DBCREATE2( 'TIPPR', aDbf)
    reset_semaphore_version("tippr")
    my_use("TIPPR")
endif

CREATE_INDEX("ID", "id", "TIPPR")

if !file(f18_ime_dbf("TIPPR2"))
    DBCREATE2( 'TIPPR2', aDbf )
    reset_semaphore_version("tippr2")
    my_use("TIPPR2")
endif

CREATE_INDEX("ID","id", "TIPPR2")

// modul LD koristi sopstveni sifrarnik radnih jedinica
if !file(f18_ime_dbf("ld_rj"))
    aDBf:={}
    AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
    add_f_mcode(@aDbf)
    AADD(aDBf,{ 'NAZ'                 , 'C' ,  35 ,  0 })
    AADD(aDBf,{ 'TIPRADA'             , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'OPOR'                , 'C' ,   1 ,  0 })
    DBCREATE2( "LD_RJ", aDbf )
    reset_semaphore_version("ld_rj")
    my_use("ld_rj")
endif
CREATE_INDEX("ID","id",KUMPATH+"LD_RJ")

// KRED
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
if !file(f18_ime_dbf("KRED"))
    DBCREATE2( 'KRED', aDbf )
    reset_semaphore_version("kred")
    my_use("KRED")
endif

if !file(f18_ime_dbf("_KRED"))
   DBCREATE2( '_KRED',aDbf)
endif

CREATE_INDEX("ID","id",SIFPATH+"KRED")
CREATE_INDEX("NAZ","naz",SIFPATH+"KRED")


// POR
if !file(f18_ime_dbf("POR"))

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
   
    DBCREATE2( 'POR', aDbf )
    reset_semaphore_version("por")
    my_use("POR")

endif

CREATE_INDEX("ID","id",SIFPATH+"POR")


// DOPR
if !file(f18_ime_dbf("DOPR"))
   
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
    
    DBCREATE2( 'DOPR', aDbf )
    reset_semaphore_version("dopr")
    my_use("dopr")

endif

CREATE_INDEX("ID","id",SIFPATH+"DOPR")

if !file(f18_ime_dbf("STRSPR"))
    aDbf:={ {"id","C",3,0} ,;
            {"naz","C",20,0} ,;
            {"naz2","C",6,0} ;
                }
    DBCREATE2( "STRSPR", aDbf )
    reset_semaphore_version( "strspr" )
    my_use("STRSPR")

endif


CREATE_INDEX("ID","id", "strspr")

if !file(f18_ime_dbf("KBENEF"))
   aDbf:={ {"id","C",1,0} ,;
           {"naz","C",8,0} ,;
           {"iznos","N",5,2} ;
         }
    DBCREATE2( "KBENEF", aDbf )
    reset_semaphore_version( "kbenef" )
    my_use("KBENEF")
    
endif

CREATE_INDEX("ID","id",SIFPATH+"KBENEF")


if !file(f18_ime_dbf("VPOSLA"))  // vrste posla
   aDbf:={  {"id","C",2,0}   ,;
            {"naz","C",20,0} ,;
            {"idkbenef","C",1,0} ;
         }
    DBCREATE2( "VPOSLA", aDbf )
    reset_semaphore_version( "vposla" )
    my_use( "VPOSLA" )

endif

CREATE_INDEX("ID","id",SIFPATH+"VPOSLA")


// -----------------------
// RADN.DBF
// -----------------------

aDbf:={}
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

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    reset_semaphore_version(_table_name)
    my_use(_alias)
    close all
endif

CREATE_INDEX("1", "id", _alias)
CREATE_INDEX("2", "naz", _alias)

// -------------------------------------
// -------------------------------------
_alias := "_RADN"
_table_name := "_ld_radn"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    close all
endif
    
// RADKR.DBF
aDbf:={}
AADD(aDBf,{ 'IDRadn'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'Mjesec'              , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'Godina'              , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'IdKred'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'Iznos'               , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'Placeno'             , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'NaOsnovu'            , 'C' ,  20 ,  0 })

_alias := "RADKR"
_table_name := "ld_radkr"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    reset_semaphore_version(_table_name)
    my_use(_alias)
    close all
endif

CREATE_INDEX("1","str(godina)+str(mjesec)+idradn+idkred+naosnovu", _alias)
CREATE_INDEX("2","idradn+idkred+naosnovu+str(godina)+str(mjesec)", _alias)
CREATE_INDEX("3","idkred+naosnovu+idradn+str(godina)+str(mjesec)", _alias)
CREATE_INDEX("4","str(godina)+str(mjesec)+idradn+naosnovu", _alias)

_alias := "_RADKR"
_table_name := "_ld_radkr"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
endif


aDBf:={}
AADD(aDBf,{ 'Godina'              , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'IDRJ'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDRADN'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'Mjesec'              , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'BRBOD'               , 'N' ,  11 ,  2 })
AADD(aDBf,{ 'IdStrSpr'            , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IdVPosla'            , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'KMinRad'             , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'S01'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I01'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S02'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I02'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S03'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I03'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S04'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I04'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S05'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I05'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S06'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I06'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S07'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I07'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S08'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I08'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S09'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I09'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S10'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I10'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S11'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I11'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S12'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I12'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S13'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I13'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S14'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I14'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S15'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I15'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S16'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I16'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S17'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I17'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S18'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I18'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S19'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I19'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S20'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I20'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S21'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I21'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S22'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I22'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S23'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I23'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S24'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I24'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S25'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I25'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S26'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I26'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S27'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I27'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S28'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I28'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S29'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I29'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S30'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I30'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S31'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I31'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S32'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I32'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S33'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I33'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S34'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I34'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S35'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I35'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S36'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I36'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S37'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I37'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S38'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I38'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S39'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I39'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S40'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I40'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S41'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I41'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S42'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I42'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S43'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I43'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S44'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I44'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S45'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I45'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S46'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I46'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S47'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I47'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S48'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I48'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S49'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I49'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S50'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I50'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S51'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I51'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S52'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I52'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S53'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I53'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S54'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I54'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S55'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I55'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S56'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I56'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S57'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I57'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S58'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I58'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S59'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I59'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S60'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I60'                 , 'N' ,  12 ,  2 })
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

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    reset_semaphore_version(_table_name)
    my_use(_alias)
    close all
endif

// polje OBR koristimo u indeksima
CREATE_INDEX("1","str(godina)+idrj+str(mjesec)+obr+idradn", _alias)
CREATE_INDEX("2","str(godina)+str(mjesec)+obr+idradn+idrj", _alias)
CREATE_INDEX("3","str(godina)+idrj+idradn", _alias)
CREATE_INDEX("4","str(godina)+idradn+str(mjesec)+obr", _alias)
CREATE_INDEX("1U","str(godina)+idrj+str(mjesec)+idradn", _alias)
CREATE_INDEX("2U","str(godina)+str(mjesec)+idradn+idrj", _alias)
CREATE_INDEX("RADN","idradn", _alias)

// --------------------------------------
// ld_ldsm
// --------------------------------------
_alias := "LDSM"
_table_name := "ld_ldsm"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    close all
endif

CREATE_INDEX("1","Obr+str(godina)+str(mjesec)+idradn+idrj", _alias)
CREATE_INDEX("RADN", "idradn", _alias)

// --------------------------------------
// ld__ld
// --------------------------------------
_alias := "_LD"
_table_name := "_ld_ld"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    close all
endif


// --------------------------------------------
// --------------------------------------------
aDBf:={}
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

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    reset_semaphore_version(_table_name)
    my_use(_alias)
    close all
endif

CREATE_INDEX("ID", "id+godina+obr", _alias)


// ---------------------------------------
// OBRACUNI.DBF
// ---------------------------------------
        
aDbf:={}
        
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

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    reset_semaphore_version(_table_name)
    my_use(_alias)
    close all
endif

CREATE_INDEX("RJ", "rj+STR(godina)+STR(mjesec)+status+obr", _alias)

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

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    reset_semaphore_version(_table_name)
    my_use(_alias)
    close all
endif

CREATE_INDEX( "1", "idradn", _alias)
CREATE_INDEX( "2", "STR(zahtjev)", _alias)

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

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    reset_semaphore_version(_table_name)
    my_use(_alias)
    close all
endif

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

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    reset_semaphore_version(_table_name)
    my_use(_alias)
    close all
endif

CREATE_INDEX("IDRADN", "idradn", _alias)

//RADSIHT
aDbf:={}
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

if !file(f18_ime_dbf("RADSIHT"))
    DBCREATE2( "RADSIHT", aDBF )
    reset_semaphore_version( "ld_radsiht" )
    my_use( "RADSIHT" )
    close all
endif

CREATE_INDEX("1","str(godina)+str(mjesec)+idradn+idrj+str(dan)+dandio+idtippr", "RADSIHT" )
CREATE_INDEX("2","idkonto+str(godina)+str(mjesec)+idradn", "RADSIHT" )
CREATE_INDEX("3","idnorsiht+str(godina)+str(mjesec)+idradn", "RADSIHT" )
CREATE_INDEX("4","idradn+str(godina)+str(mjesec)+idkonto", "RADSIHT" )
CREATE_INDEX("2i","idkonto+SORTIME(idradn)+str(godina)+str(mjesec)", "RADSIHT" )


//NORSIHT - norme u sihtarici - koristi se vjerovatno samo kod rada u normi
aDbf:={}
AADD(aDBf,{ 'ID'                , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'NAZ'               , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'JMJ'               , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'Iznos'             , 'N' ,   8 ,  2 })
AADD(aDBf,{ 'N1'                , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'K1'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'                , 'C' ,   2 ,  0 })

if !file(f18_ime_dbf("NORSIHT"))

    DBCREATE2( "NORSIHT", aDBF)
    reset_semaphore_version("ld_norsiht")
    my_use("NORSIHT")

endif

CREATE_INDEX("ID","id",KUMPATH+"NORSIHT")
CREATE_INDEX("NAZ","NAZ",KUMPATH+"NORSIHT")

//TPRSIHT   - tipovi primanja koji odradjuju sihtaricu
aDbf:={}
AADD(aDBf,{ 'ID'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'NAZ'               , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'K1'                , 'C' ,   1 ,  0 })
// K1="F" - po formuli
//    " " - direktno se unose bodovi
AADD(aDBf,{ 'K2'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K3'                , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'FF'                , 'C' ,  30 ,  0 })

if !file(f18_ime_dbf("TPRSIHT"))
    DBCREATE2( "TPRSIHT", aDBF )
    reset_semaphore_version("ld_tprsiht")
    my_use("TPRSIHT")
endif

CREATE_INDEX("ID","id",KUMPATH+"TPRSIHT")
CREATE_INDEX("NAZ","NAZ",KUMPATH+"TPRSIHT")



return .t.

