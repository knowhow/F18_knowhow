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


#include "kalk.ch"

function kalk_sifrarnik()
local _opc:={}
local _opcexe:={}
local _izbor := 1

PRIVATE PicDem
PicDem:=gPICDem
close all

AADD(_opc,"1. opći šifarnici                  ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "OPCISIFOPEN"))
	AADD(_opcexe, {|| SifFmkSvi()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(_opc,"2. robno-materijalno poslovanje")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","ROBMATSIFOPEN"))
	AADD(_opcexe, {|| SifFmkRoba()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc,"3. magacinski i prodajni objekti")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","PRODOBJSIFOPEN"))
	AADD(_opcexe, {|| P_Objekti()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif


f18_menu("msif", .f., _izbor, _opc, _opcexe )

CLOSERET
return .f.



function kalk_serv_functions()
Msg("Nije u upotrebi")
closeret
return


function KalkRobaBlock(Ch)
LOCAL cSif:=ROBA->id, cSif2:=""

if Ch==K_CTRL_T .and. gSKSif=="D"

    // provjerimo da li je sifra dupla
    PushWA()
    SET ORDER TO TAG "ID"
    SEEK cSif
    SKIP 1
    cSif2:=ROBA->id
    PopWA()
    IF !(cSif==cSif2)
        // ako nije dupla provjerimo da li postoji u kumulativu
        if ima_u_kalk_kumulativ(cSif,"7")
            Beep(1)
            Msg("Stavka se ne moze brisati jer se vec nalazi u dokumentima!")
            return 7
        endif
    ENDIF

elseif Ch == K_ALT_M
    return MpcIzVpc()

elseif Ch==K_F2 .and. gSKSif=="D"

    if ima_u_kalk_kumulativ(cSif,"7")
        return 99
    endif

elseif Ch == K_F8  

    // cjenovnik
    PushWa()
    nRet:=CjenR()
    OSifBaze()
    SELECT ROBA
    PopWA()
    return nRet

elseif upper(Chr(Ch)) == "O"
    
    if roba->(fieldpos("strings")) == 0
 	    return 6
    endif
    TB:Stabilize()
    PushWa()
    m_strings(roba->strings, roba->id)
    select roba
    PopWa()
    return 7

elseif upper(Chr(Ch)) == "S"

    TB:Stabilize()  
    // problem sa "S" - exlusive, htc
    PushWa()
    KalkStanje( roba->id )
    PopWa()
    return 6  
    // DE_CONT2

elseif upper(Chr(Ch)) == "D"
    // pregled detalja artikla
    roba_opis_edit( .t. )
    return 6  
 
endif

return DE_CONT



function OSifBaze()
O_KONTO
O_KONCIJ
O_PARTN
O_TNAL
O_TDOK
O_TRFP
O_TRMP
O_VALUTE
O_TARIFA
O_ROBA
O_SAST
return

function P_Objekti()
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_OBJEKTI

AADD(ImeKol, { "ID", { || id }, "id" })
add_mcode(@ImeKol)
AADD(ImeKol, { "Naziv", { || PadR( ToStrU( naz ), 20 ) }, "naz" })
AADD(ImeKol, { "IdObj", { || idobj }, "idobj" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
p_sifra(F_OBJEKTI, 1, MAXROWS()-15, MAXCOLS()-20, "Objekti")
return 


