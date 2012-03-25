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


#include "mat.ch"


function cre_all_mat( ver )
local aDbf
local _alias, _table_name
local _created

aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRNAL'               , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'DATNAL'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DUG'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'DUG2'                , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT2'                , 'N' ,  15 ,  2 })

_created := .f.
_alias := "MAT_NALOG"
_table_name := "mat_nalog"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

if !file( f18_ime_dbf( "mat_pnalog" ))
        DBCREATE2( "mat_pnalog", aDbf )
endif

CREATE_INDEX("1","IdFirma+IdVn+BrNal", "mat_nalog")
CREATE_INDEX("2","datnal", "mat_nalog")
CREATE_INDEX("1","IdFirma", "mat_pnalog")



aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRNAL'               , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'IDTIPDOK'            , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'U_I'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  15 ,  3 })
AADD(aDBf,{ 'D_P'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'IZNOS'               , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'IDPartner'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZaduz'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IZNOS2'              , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'DatKurs'             , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K3'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K4'                  , 'C' ,   2 ,  0 })

_created := .f.
_alias := "MAT_SUBAN"
_table_name := "mat_suban"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

if !file( f18_ime_dbf( "mat_psuban" ))
        DBCREATE2( 'mat_psuban', aDbf )
endif

CREATE_INDEX("1","IdFirma+IdRoba+dtos(DatDok)"        , KUMPATH+"mat_suban")
CREATE_INDEX("2","IdFirma+IdPartner+IdRoba"           , KUMPATH+"mat_suban")
CREATE_INDEX("3","IdFirma+IdKonto+IdRoba+dtos(DatDok)", KUMPATH+"mat_suban")
CREATE_INDEX("4","idFirma+IdVN+BrNal+rbr"             , KUMPATH+"mat_suban")
CREATE_INDEX("5","IdFirma+IdKonto+IdPartner+IdRoba+dtos(DatDok)", KUMPATH+"mat_suban")
CREATE_INDEX("8","datdok"             , KUMPATH+"mat_suban")
CREATE_INDEX("9","DESCEND(DTOS(datdok))+idpartner", KUMPATH+"mat_suban")
CREATE_INDEX("IDROBA","idroba", KUMPATH+"mat_suban")
CREATE_INDEX("IDPARTN","idpartner", KUMPATH+"mat_suban")

CREATE_INDEX("1","idFirma+idvn+brnal"        , PRIVPATH+"mat_psuban")
CREATE_INDEX("2","idFirma+IdVN+Brnal+IdKonto", PRIVPATH+"mat_psuban")


aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRNAL'               , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'DATNAL'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'DUG'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'DUG2'                , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT2'                , 'N' ,  15 ,  2 })

_created := .f.
_alias := "MAT_ANAL"
_table_name := "mat_anal"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

// 0.4.4
if ver["current"] < 0404
    modstru({"*" + _table_name, "C RBR C 3 0 RBR C 4 0"})
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

// pomocna tabela
if !file( f18_ime_dbf( 'mat_panal' ))
        DBCREATE2( 'mat_panal', aDbf)
endif

if ver["current"] < 0404
    modstru({"*mat_panal", "C RBR C 3 0 RBR C 4 0"})
endif

CREATE_INDEX("1","IdFirma+IdKonto+dtos(DatNal)",KUMPATH+"mat_anal")  //mat_analiti
CREATE_INDEX("2","idFirma+IdVN+BrNal+IdKonto",KUMPATH+"mat_anal")
CREATE_INDEX("3","datnal",KUMPATH+"mat_anal")
CREATE_INDEX("1","IdFirma+idvn+brnal+idkonto",PRIVPATH+"mat_panal")


aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRNAL'               , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'DATNAL'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'DUG'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'DUG2'                , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT2'                , 'N' ,  15 ,  2 })

_created := .f.
_alias := "MAT_SINT"
_table_name := "mat_sint"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

if ver["current"] < 0404
    modstru({"*" + _table_name, "C RBR C 3 0 RBR C 4 0"})
endif

if _created
    reset_semaphore_version(_table_name)
    my_use(_alias)
    use
endif

if !file( f18_ime_dbf( 'mat_psint' ))
        DBCREATE2( 'mat_psint', aDbf )
endif

if ver["current"] < 0404
    modstru({"*mat_psint", "C RBR C 3 0 RBR C 4 0"})
endif

CREATE_INDEX("1","IdFirma+IdKonto+dtos(DatNal)",KUMPATH+"mat_sint")  // mat_sinteti
CREATE_INDEX("2","idFirma+IdVN+BrNal+IdKonto",KUMPATH+"mat_sint")
CREATE_INDEX("3","datnal",KUMPATH+"mat_sint")
CREATE_INDEX("1","IdFirma",PRIVPATH+"mat_psint")


aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRNAL'               , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'IDTIPDOK'            , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'U_I'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  15 ,  3 })
AADD(aDBf,{ 'D_P'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'IZNOS'               , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'CIJENA'              , 'N' ,  15 ,  3 })
AADD(aDBf,{ 'IDPartner'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZaduz'             , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IZNOS2'              , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'DATKURS'             , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K3'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K4'                  , 'C' ,   2 ,  0 })
 
_created := .f.
_alias := "MAT_PRIPR"
_table_name := "mat_pripr"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif


CREATE_INDEX("1","idFirma+IdVN+BrNal+rbr",PRIVPATH+"mat_pripr")
CREATE_INDEX("2","idFirma+IdVN+BrNal+BrDok+Rbr",PRIVPATH+"mat_pripr")
CREATE_INDEX("3","idFirma+IdVN+IdKonto",PRIVPATH+"mat_pripr")
CREATE_INDEX("4","idFirma+idkonto+idpartner+idroba",PRIVPATH+"mat_pripr")
        

aDbf:={}
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'BROJXX'              , 'N' ,   8 ,  2 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  10 ,  2 })
AADD(aDBf,{ 'CIJENA'              , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'IZNOS'               , 'N' ,  14 ,  2 })
AADD(aDBf,{ 'IZNOS2'              , 'N' ,  14 ,  2 })
AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })

_created := .f.
_alias := "MAT_INVENT"
_table_name := "mat_invent"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

CREATE_INDEX("1","IdRoba", "mat_invent") // Inventura

 
return


