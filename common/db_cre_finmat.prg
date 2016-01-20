/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"
#include "cre_all.ch"


// --------------------------------------------------------
// kreiranje tabele fin_mat
// --------------------------------------------------------
function cre_fin_mat(ver)
local aDbf
local _table_name
local _alias 
local _created

aDbf:={}
AADD(aDBf,{ "IDFIRMA"          , "C" ,   2 ,  0 })
AADD(aDBf,{ "IDKONTO"          , "C" ,   7 ,  0 })
AADD(aDBf,{ "IDKONTO2"         , "C" ,   7 ,  0 })
AADD(aDBf,{ "IDTARIFA"         , "C" ,   6 ,  0 })
AADD(aDBf,{ "IDPARTNER"        , "C" ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ'          , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ2'         , 'C' ,   6 ,  0 })
AADD(aDBf,{ "IDVD"             , "C" ,   2 ,  0 })
AADD(aDBf,{ "BRDOK"            , "C" ,   8 ,  0 })
AADD(aDBf,{ "DATDOK"           , "D" ,   8 ,  0 })
AADD(aDBf,{ "BRFAKTP"          , "C" ,  10 ,  0 })
AADD(aDBf,{ "DATFAKTP"         , "D" ,   8 ,  0 })
AADD(aDBf,{ "DATKURS"          , "D" ,   8 ,  0 })
AADD(aDBf,{ 'RABAT'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PREVOZ'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'CARDAZ'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'BANKTR'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'SPEDTR'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'ZAVTR'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'VPVSAP'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PRUCMP'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PORPOT'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ "FV"               , "N" ,  20 ,  8 })
AADD(aDBf,{ "GKV"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "GKV2"             , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR1"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR2"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR3"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR4"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR5"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR6"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "NV"               , "N" ,  20 ,  8 })
AADD(aDBf,{ "RABATV"           , "N" ,  20 ,  8 })
AADD(aDBf,{ "POREZV"           , "N" ,  20 ,  8 })
AADD(aDBf,{ "MARZA"            , "N" ,  20 ,  8 })
AADD(aDBf,{ "VPV"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "MPV"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "MARZA2"           , "N" ,  20 ,  8 })
AADD(aDBf,{ "POREZ"            , "N" ,  20 ,  8 })
AADD(aDBf,{ "POREZ2"           , "N" ,  20 ,  8 })
AADD(aDBf,{ "POREZ3"           , "N" ,  20 ,  8 })
AADD(aDBf,{ "MPVSAPP"          , "N" ,  20 ,  8 })
AADD(aDBf,{ "IDROBA"           , "C" ,  10 ,  0 })
AADD(aDBf,{ "KOLICINA"         , "N" ,  19 ,  7 })
AADD(aDBf,{ "GKol"             , "N" ,  19 ,  7 })
AADD(aDBf,{ "GKol2"            , "N" ,  19 ,  7 })
AADD(aDBf,{ "PORVT"            , "N" ,  20 ,  8 })
AADD(aDBf,{ "UPOREZV"          , "N" ,  20 ,  8 })
AADD(aDBf,{ "K1"               , "C" ,   1 ,  0 })
AADD(aDBf,{ "K2"               , "C" ,   1 ,  0 })

_alias := "FINMAT"
_table_name := "finmat"

IF_NOT_FILE_DBF_CREATE
	
// 0.9.1
if ver["current"] > 0 .and. ver["current"] < 0901
    modstru({"*" + _table_name, "A K1 C 1 0", "A K2 C 1 0" })
endif

CREATE_INDEX( "1", "idFirma+IdVD+BRDok", _alias )

return



