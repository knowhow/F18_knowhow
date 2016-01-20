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
function cre_all_kadev( ver )
local aDbf
local _alias, _table_name
local _created

// --------------------------------------------------
// KADEV_0
// --------------------------------------------------

aDbf:={} 
AADD(aDbf, {"id", "C", 13, 0} )
AADD(aDbf, {"id2","C",11,0} )
AADD(aDbf, {"Prezime","C",30,0} )
AADD(aDbf, {"ImeRod","C",20,0} )
AADD(aDbf, {"Ime",    "C",20,0} )
AADD(aDbf, {"Pol",    "C",1,0} )
AADD(aDbf, {"IdNac",  "C",2,0} )
AADD(aDbf, {"DatRodj","D",8,0} )
AADD(aDbf, {"MjRodj","C",30,0} )
AADD(aDbf, {"IdStrSpr","C",3,0} )
AADD(aDbf, {"IdZanim","C",4,0} )
AADD(aDbf, {"IdRJ","C",6,0} )
AADD(aDbf, {"IdRMJ","C",4,0} )
AADD(aDbf, {"DatURMJ","D",8,0} )
AADD(aDbf, {"DatUF","D",8,0} )
AADD(aDbf, {"DatVRMJ","D",8,0} )
AADD(aDbf, {"RadStE","N",11,2} )
AADD(aDbf, {"RadStB","N",11,2} )
AADD(aDbf, {"BrLK","C",12,0} )
AADD(aDbf, {"MjSt","C",30,0} )
AADD(aDbf, {"Ulst","C",30,0} )
AADD(aDbf, {"IdMZSt","C",4,0} )
AADD(aDbf, {"BrTel1","C",15,0} )
AADD(aDbf, {"BrTel2","C",15,0} )
AADD(aDbf, {"BrTel3","C",15,0} )
AADD(aDbf, {"Status","C",1,0} )
AADD(aDbf, {"BracSt","C",1,0} )
AADD(aDbf, {"BrDjece","N",2,0} )
AADD(aDbf, {"Krv","C",3,0} )
AADD(aDbf, {"Stan","C",1,0} )
AADD(aDbf, {"IdK1","C",2,0} )
AADD(aDbf, {"IdK2","C",4,0} )
AADD(aDbf, {"KOp1","C",30,0} )
AADD(aDbf, {"KOp2","C",30,0} )
AADD(aDbf, {"IdRRasp","C",4,0} )
AADD(aDbf, {"SlVr","C",1,0} )
// sluzio vojni rok - D/N
AADD(aDbf, {"VrSlVr","N",11,2} )
// vrijeme sluzenja vojnog roka
AADD(aDbf, {"SposVSl","C",1,0} )
// sposoban za vojnu sluzbu D,N,O
AADD(aDbf, {"IDVes","C",7,0} )
// ID VES-a
AADD(aDbf, {"IDCin","C",2,0} )
// ID Cin-a
AADD(aDbf, {"NazSekr", "C",100,0} )
AADD(aDbf, {"Operater","C",50,0} )
AADD(aDbf, {"k_date","D",8,0}  )
AADD(aDbf, {"k_time","C",8,0} )

_alias := "KADEV_0"
_table_name := "kadev_0"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "1" , "id"               , _alias )
CREATE_INDEX( "2" , "btoe(prezime+ime)", _alias )
CREATE_INDEX( "3" , "id2"              , _alias )
CREATE_INDEX( "4" , "idrj+idrmj"       , _alias )


// --------------------------------------------------
// KADEV_1
// --------------------------------------------------

aDbf := {}

AADD( aDbf, { "ID","C",13,0 } )
AADD( aDbf, {"DatumOd","D",8,0} )
AADD( aDbf, {"DatumDo","D",8,0} )
AADD( aDbf, {"IdPromj","C",2,0} )
AADD( aDbf, {"IdK","C",4,0}  )
AADD( aDbf, {"Dokument","C",15,0} )
AADD( aDbf, {"Opis","C",50,0} )
AADD( aDbf, {"Nadlezan","C",50,0} )
AADD( aDbf, {"IdRJ","C",6,0} )
AADD( aDbf, {"IdRMJ","C",4,0} )
AADD( aDbf, {"nAtr1","N",11,2} )
AADD( aDbf, {"nAtr2","N",11,2} )
AADD( aDbf, {"nAtr3","N", 2,0} )
AADD( aDbf, {"nAtr4","N", 2,0} )
AADD( aDbf, {"nAtr5","N", 2,0} )
AADD( aDbf, {"nAtr6","N", 2,0} )
AADD( aDbf, {"nAtr7","N", 2,0} )
AADD( aDbf, {"nAtr8","N", 2,0} )
AADD( aDbf, {"nAtr9","N", 2,0} )
AADD( aDbf, {"cAtr1","C",10,0} )
AADD( aDbf, {"cAtr2","C",10,0} )

_alias := "KADEV_1"
_table_name := "kadev_1"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("1" , "id+dtos(datumOd)+idpromj+opis" , _alias )
CREATE_INDEX("2" , "dtos(datumOd)"    , _alias )
CREATE_INDEX("3" , "id+idpromj"       , _alias )


// ------------------------------------------------------
// KADEV_PROMJ
// ------------------------------------------------------

aDbf := {}	
AADD( aDbf, { "ID", "C", 2,0 } )
AADD( aDbf, {"Naz","C",50,0} )
AADD( aDbf, {"Naz2","C",50,0} )
AADD( aDbf, {"Tip","C",1,0} )
AADD( aDbf, {"Status","C",1,0} )
AADD( aDbf, {"URadst","C",1,0} ) 
AADD( aDbf, {"SRMJ","C",1,0} )
AADD( aDbf, {"URRasp","C",1,0} )
AADD( aDbf, {"UStrSpr","C",1,0} ) 

_alias := "KADEV_PROMJ"
_table_name := "kadev_promj"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )


// ----------------------------------------------------
// KDV_MZ (mjesne zajednice)
// ----------------------------------------------------

	
aDbf := {}
AADD( aDbf, { "ID", "C", 4, 0 } ) 
AADD( aDbf, { "Naz", "C", 50, 0 } )
AADD( aDbf, { "Naz2", "C", 50, 0 } )
 
_alias := "KDV_MZ"
_table_name := "kadev_mz"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )

// -------------------------------------------------------
// KDV_NERDAN
// -------------------------------------------------------

aDbf := {}
AADD( aDbf, { "ID", "C", 4, 0 } ) 
AADD( aDbf, { "Naz", "C", 20, 0 } )
AADD( aDbf, { "Datum", "D", 8, 0 } )
 
_alias := "KDV_NERDAN"
_table_name := "kadev_nerdan"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )
CREATE_INDEX( "dat", "datum", _alias )


// ------------------------------------------------
// KDV_RMJ ( radna mjesta )
// ------------------------------------------------

aDbf := {}
AADD( aDbf, { "ID", "C", 4, 0 }  )
AADD( aDbf, { "Naz", "C", 50, 0 } )
AADD( aDbf, { "Naz2", "C", 50, 0 } )

_alias := "KDV_RMJ"
_table_name := "kadev_rmj"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )


// ------------------------------------------------
// KDV_RJ ( radna jedinica )
// ------------------------------------------------

aDbf := {}
AADD( aDbf, { "ID", "C", 6, 0 }  )
AADD( aDbf, { "Naz", "C", 50, 0 } )
AADD( aDbf, { "Naz2", "C", 50, 0 } )

_alias := "KDV_RJ"
_table_name := "kadev_rj"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )



// ---------------------------------------------------------------------
// KDV_RJRMJ
// ---------------------------------------------------------------------
	
aDbf := {} 
AADD( aDbf, { "IdRJ", "C", 6, 0 } )
AADD( aDbf, {"IdRMJ","C",4,0} )
AADD( aDbf, {"BrIzvrs","N",2,0} )
AADD( aDbf, {"IdStrSprOd","C",3,0} )
AADD( aDbf, {"IdStrSprDo","C",3,0} )
AADD( aDbf, {"IdZanim1","C",4,0} )
AADD( aDbf, {"IdZanim2","C",4,0} )
AADD( aDbf, {"IdZanim3","C",4,0} )
AADD( aDbf, {"IdZanim4","C",4,0} )
AADD( aDbf, {"Bodova","N",10,2} )
AADD( aDbf, {"SBenefRSt","C",1,0} )
AADD( aDbf, {"IdK1","C",1,0} )
AADD( aDbf, {"IdK2","C",1,0} ) 
AADD( aDbf, {"IdK3","C",1,0} ) 
AADD( aDbf, {"IdK4","C",1,0} )
AADD( aDbf, {"Opis","C",30,0} )
                
_alias := "KDV_RJRMJ"
_table_name := "kadev_rjrmj"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "idrj + idrmj + idzanim1 + idstrsprod + idstrsprdo", _alias )


// ------------------------------------------------
// KDV_K1 ( karakteristike 1 )
// ------------------------------------------------

aDbf := {}
AADD( aDbf, { "ID", "C", 2, 0 } )
AADD( aDbf, { "Naz", "C", 50, 0 } )
AADD( aDbf, { "Naz2", "C", 50, 0 } )

_alias := "KDV_K1"
_table_name := "kadev_k1"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )


// ------------------------------------------------
// KDV_K2 ( karakteristike 2 )
// ------------------------------------------------

aDbf := {}
AADD( aDbf, { "ID", "C", 2, 0 } )
AADD( aDbf, { "Naz", "C", 50, 0 } )
AADD( aDbf, { "Naz2", "C", 50, 0 } )

_alias := "KDV_K2"
_table_name := "kadev_k2"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )


// ------------------------------------------------
// KDV_ZANIM ( zanimanja )
// ------------------------------------------------

aDbf := {}
AADD( aDbf, { "ID", "C", 4, 0 } )
AADD( aDbf, { "Naz", "C", 50, 0 } )
AADD( aDbf, { "Naz2", "C", 50, 0 } )

_alias := "KDV_ZANIM"
_table_name := "kadev_zanim"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )


// ------------------------------------------------
// KDV_RRASP ( ?!???? )
// ------------------------------------------------

aDbf := {}
AADD( aDbf, { "ID", "C", 4, 0 } )
AADD( aDbf, { "Naz", "C", 50, 0 } )
AADD( aDbf, { "Naz2", "C", 50, 0 } )
AADD( aDbf, { "catr", "C", 1, 0 } )

_alias := "KDV_RRASP"
_table_name := "kadev_rrasp"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )


// ------------------------------------------------
// KDV_VES ( ves, vosjka )
// ------------------------------------------------

aDbf := {}
AADD( aDbf, { "ID", "C", 7, 0 } )
AADD( aDbf, { "Naz", "C", 50, 0 } )
AADD( aDbf, { "Naz2", "C", 50, 0 } )

_alias := "KDV_VES"
_table_name := "kadev_ves"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )


// ------------------------------------------------
// KDV_CIN ( cin, vosjka )
// ------------------------------------------------

aDbf := {}
AADD( aDbf, { "ID", "C", 2, 0 } )
AADD( aDbf, { "Naz", "C", 50, 0 } )
AADD( aDbf, { "Naz2", "C", 50, 0 } )

_alias := "KDV_CIN"
_table_name := "kadev_cin"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )


// ------------------------------------------------
// KDV_NAC ( nac, vosjka )
// ------------------------------------------------

aDbf := {}
AADD( aDbf, { "ID", "C", 2, 0 } )
AADD( aDbf, { "Naz", "C", 50, 0 } )
AADD( aDbf, { "Naz2", "C", 50, 0 } )

_alias := "KDV_NAC"
_table_name := "kadev_nac"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "id", "id", _alias )
CREATE_INDEX( "naz", "naz", _alias )


// ---------------------------------------------------------
// KDV_OBRAZDEF
// ---------------------------------------------------------
aDbf:={}
AADD(aDbf,{"Tip","C",1,0})
AADD(aDbf,{"Grupa","C",1,0})
AADD(aDbf,{"Red_Br","C",1,0})
AADD(aDbf,{"id_uslova","C",8,0})
AADD(aDbf,{"Komentar","C",50,0})
AADD(aDbf,{"Uslov","C",300,0})

_alias := "KDV_OBRAZDEF"
_table_name := "kadev_obrazdef"

IF_NOT_FILE_DBF_CREATE
//IF_C_RESET_SEMAPHORE

CREATE_INDEX( "1" , "tip+grupa+red_br", _alias )


// --------------------------------------------------------
// KDV_GLOBUSL
// --------------------------------------------------------
aDBF:={}
AADD(aDbf,{"KOMENTAR","C",50,0})
AADD(aDbf,{"USLOV","C",300,0})
AADD(aDbf,{"IME_BAZE","C",10,0})

_alias := "KDV_GLOBUSL"
_table_name := "kadev_globusl"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "1" , "Komentar", _alias )


// ------------------------------------------------------
// KDV_USLOVI
// ------------------------------------------------------
aDBF:={}
AADD(aDbf,{"ID"        , "C",   8, 0})
AADD(aDbf,{"NAZ"       , "C",  50, 0})
AADD(aDbf,{"USLOV"     , "C", 300, 0})

_alias := "KDV_USLOVI"
_table_name := "kadev_uslovi"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "1" , "id", _alias )
CREATE_INDEX( "2" , "naz", _alias )


// -----------------------------------------------------
// KDV_RJES
// -----------------------------------------------------

aDbf := {} 
AADD( aDbf, { "id"       , "C" ,  2 , 0 } )
AADD( aDbf, { "naz"      , "C" , 50 , 0 } )
AADD( aDbf, { "fajl"     , "C" , 20 , 0 } )
AADD( aDbf, { "zadbrdok" , "C" , 20 , 0 } )
AADD( aDbf, { "idpromj"  , "C" ,  2 , 0 } )

_alias := "KDV_RJES"
_table_name := "kadev_rjes"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("id" , "id" , _alias )
CREATE_INDEX("naz" , "naz" , _alias )


// ---------------------------------------------------------------
// KDV_DEFRJES
// ---------------------------------------------------------------

aDbf := {} 
AADD( aDbf, { "id"       , "C" ,   2 , 0 } )
AADD( aDbf, { "idrjes"   , "C" ,   2 , 0 } )
AADD( aDbf, { "izraz"    , "C" , 200 , 0 } )
AADD( aDbf, { "obrada"   , "C" ,   1 , 0 } )
AADD( aDbf, { "upit"     , "C" ,  20 , 0 } )
AADD( aDbf, { "uvalid"   , "C" , 100 , 0 } )
AADD( aDbf, { "upict"    , "C" ,  20 , 0 } )
AADD( aDbf, { "iizraz"   , "C" , 200 , 0 } )
AADD( aDbf, { "tipslova" , "C" ,   5 , 0 } )
AADD( aDbf, { "ppromj"   , "C" ,  10 , 0 } )
AADD( aDbf, { "ipromj"   , "C" ,   1 , 0 } )
AADD( aDbf, { "priun"    , "C" ,   1 , 0 } )

_alias := "KDV_DEFRJES"
_table_name := "kadev_defrjes"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("1"  , "idrjes+id"           , _alias )
CREATE_INDEX("2"  , "idrjes+ipromj+id"    , _alias )
CREATE_INDEX("3"  , "idrjes+priun+id"     , _alias )
CREATE_INDEX("4"  , "id"     , _alias )


return





