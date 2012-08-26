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

function cre_all_kalk(ver)
local aDbf
local _alias, _table_name
local _created
local _tbl

// -----------------------------------------------
// kalk_doks
// -----------------------------------------------
	
aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })

AADD(aDBf,{ 'BRFAKTP'             , 'C' ,  10 ,  0 })

AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IdZADUZ'             , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IdZADUZ2'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'PKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'MKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'NV'                  , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'VPV'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'RABAT'               , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'MPV'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'PODBR'               , 'C' ,   2 ,  0 })

_created := .f.
_alias := "KALK_DOKS"
_table_name := "kalk_doks"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

// 0.4.0
if ver["current"] < 0400
   modstru({"*" + _table_name, "A SIFRA C 6 0"})
endif

if _created
  reset_semaphore_version(_table_name)
  my_usex(_alias)
  USE
endif

CREATE_INDEX("1"      , "IdFirma+idvd+brdok", _alias)
CREATE_INDEX("2"      , "IdFirma+MKONTO+idzaduz2+idvd+brdok", _alias)
CREATE_INDEX("3"      , "IdFirma+dtos(datdok)+podbr+idvd+brdok", _alias)
CREATE_INDEX("DAT"    ,"datdok", _alias)
CREATE_INDEX("1S"     , "IdFirma+idvd+SUBSTR(brdok,6)+LEFT(brdok,5)", _alias)
CREATE_INDEX("V_BRF"  , "brfaktp+idvd", _alias)
CREATE_INDEX("V_BRF2" , "idvd+brfaktp", _alias)


aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDKONTO2'            , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDZADUZ'             , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ2'            , 'C' ,   6 ,  0 })
// ova su polja prakticno tu samo radi kompat
// istina, ona su ponegdje iskoristena za neke sasvim druge stvari
// pa zato treba biti pazljiv sa njihovim diranjem
AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })

AADD(aDBf,{ 'BRFAKTP'             , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'DATFAKTP'            , 'D' ,   8 ,  0 })

AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })

// ovaj datkurs je sada skroz eliminisan iz upotrebe
// vidjeti za njegovo uklanjanje  (paziti na modul FIN) jer se ovo i tamo
// koristi
AADD(aDBf,{ 'RBR'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'PODBR'               , 'C' ,   2 ,  0 })

AADD(aDBf,{ 'TPREVOZ'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TPREVOZ2'            , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TBANKTR'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TSPEDTR'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TCARDAZ'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TZAVTR'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TRABAT'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TMARZA'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TMARZA2'             , 'C' ,   1 ,  0 })

// ovo zasad ne diram
AADD(aDBf,{ 'NC'                  , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC'                 , 'N' ,  18 ,  8 })

// currency tip
AADD(aDBf,{ 'VPC'                 , 'Y' ,  8 ,  4 })
AADD(aDBf,{ 'MPCSAPP'             , 'Y' ,  8 ,  4 })


AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'MKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'PKONTO'              , 'C' ,   7 ,  0 })


AADD(aDBf,{ 'MU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'ERROR'               , 'C' ,   1 ,  0 })

AADD(aDBf,{ 'KOLICINA'            , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'GKOLICINA'           , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'GKOLICIN2'           , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'FCJ'                 , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'FCJ2'                , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'FCJ3'                , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'RABAT'               , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'PREVOZ'              , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'BANKTR'              , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'SPEDTR'              , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'PREVOZ2'             , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'CARDAZ'              , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'ZAVTR'               , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'MARZA'               , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'MARZA2'              , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'RABATV'              , 'B' ,  8 ,  8 })
AADD(aDBf,{ 'VPCSAP'              , 'B' ,  8 ,  8 })


_created := .f.
_alias := "KALK"
_table_name := "kalk_kalk"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

// 0.8.3
if ver["current"] < 00803
  for each _tbl in { _table_name, "_kalk_kalk", "kalk_pripr", "kalk_pripr2", "kalk_pripr9" }
    modstru( {"*" + _tbl, ;
        "C KOLICINA N 12 3  KOLICINA B 8 8",;
        "C GKOLICINA N 12 3 GKOLICINA B 8 8",;
        "C GKOLICIN2 N 12 3 GKOLICIN2 B 8 8",;
        "C FCJ N 18 8 FCJ B 8 8",;
        "C FCJ2 N 18 8 FCJ2 B 8 8",;
        "C FCJ3 N 18 8 FCJ3 B 8 8",;
        "C RABAT N 18 8 RABAT B 8 8",;
        "C PREVOZ N 18 8 PREVOZ B 8 8",;
        "C PREVOZ2 N 18 8 PREVOZ2 B 8 8",;
        "C BANKTR N 18 8 BANKTR B 8 8",;
        "C SPEDTR N 18 8 SPEDTR B 8 8",;
        "C CARDAZ N 18 8 CARDAZ B 8 8",;
        "C ZAVTR N 18 8 ZAVTR B 8 8",  ;
        "C MARZA N 18 8 MARZA B 8 8", ;
        "C MARZA2 N 18 8 MARZA2 B 8 8", ;
        "C RABATV N 18 8 RABATV B 8 8", ;
        "C VPCSAP N 18 8 VPCSAP B 8 8", ;
        "C VPC N 18 8 VPC Y 8 4",;
        "C MPCSAPP N 18 8 MPCSAPP Y 8 4", ;
        "D ROKTR D 8 0", ;
        "D DATKURS D 8 0" ;
    })
 next
endif



if _created
  reset_semaphore_version(_table_name)
  my_usex(_alias)
  USE
endif

CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr", "KALK")
CREATE_INDEX("2","idFirma+idvd+brdok+IDTarifa","KALK")
CREATE_INDEX("3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD", "KALK")
CREATE_INDEX("4","idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD" ,"KALK")
CREATE_INDEX("5","idFirma+dtos(datdok)+podbr+idvd+brdok","KALK")
CREATE_INDEX("6","idFirma+IdTarifa+idroba","KALK")
CREATE_INDEX("7","idroba+idvd", "KALK")
CREATE_INDEX("8","mkonto", "KALK")
CREATE_INDEX("9","pkonto","KALK")
CREATE_INDEX("DAT","datdok", "KALK")
CREATE_INDEX("MU_I", "mu_i+mkonto+idfirma+idvd+brdok","KALK")
CREATE_INDEX("MU_I2","mu_i+idfirma+idvd+brdok","KALK")
CREATE_INDEX("PU_I", "pu_i+pkonto+idfirma+idvd+brdok","KALK")
CREATE_INDEX("PU_I2","pu_i+idfirma+idvd+brdok","KALK")
CREATE_INDEX("PMAG", "idfirma+mkonto+idpartner+idvd+dtos(datdok)","KALK")

// priprema itd...

// kalk_pripr
_alias := "KALK_PRIPR"
_table_name := "kalk_pripr"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
endif
CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr", _alias )
CREATE_INDEX("2","idFirma+idvd+brdok+IDTarifa", _alias )
CREATE_INDEX("3","idFirma+idvd+brdok+idroba+rbr", _alias )
CREATE_INDEX("4","idFirma+idvd+idroba", _alias )
CREATE_INDEX("5","idFirma+idvd+idroba+STR(mpcsapp,12,2)", _alias )

// kalk_pripr2
_alias := "KALK_PRIPR2"
_table_name := "kalk_pripr2"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
endif
CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr","kalk_pripr2")
CREATE_INDEX("2","idFirma+idvd+brdok+IDTarifa","kalk_pripr2")

// kalk_pripr9
_alias := "KALK_PRIPR9"
_table_name := "kalk_pripr9"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
endif
CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr","kalk_pripr9")
CREATE_INDEX("2","idFirma+idvd+brdok+IDTarifa","kalk_pripr9")
CREATE_INDEX("3","dtos(datdok)+mu_i+pu_i","kalk_pripr9")

// _kalk
_alias := "_KALK"
_table_name := "_kalk"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
endif
CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr","_KALK")


// kalk_doks2
aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDvd'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATVAL'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'Opis'                , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'K1'                , 'C' ,  1 ,  0 })
AADD(aDBf,{ 'K2'                , 'C' ,  2 ,  0 })
AADD(aDBf,{ 'K3'                , 'C' ,  3 ,  0 })
if !FILE(f18_ime_dbf( "kalk_doks2" ))
    DBcreate2( "kalk_doks2", aDbf )
    reset_semaphore_version( "kalk_doks2" )
	my_use( "kalk_doks2" )
    close all
endif
CREATE_INDEX( "1", "IdFirma+idvd+brdok", "kalk_doks2" )


// objekti
aDbf:={}
AADD(aDbf, {"id","C",2,0})
AADD(aDbf, {"naz","C",10,0}) 
AADD(aDbf, {"IdObj","C", 7,0})
if !FILE(f18_ime_dbf("objekti"))
	DBCREATE2("OBJEKTI", aDbf)
    reset_semaphore_version( "objekti" )
    my_use( "objekti" )
    close all
endif
CREATE_INDEX("ID", "ID", "OBJEKTI")
CREATE_INDEX("NAZ", "NAZ", "OBJEKTI")
CREATE_INDEX("IdObj", "IdObj", "OBJEKTI")


return .t.
