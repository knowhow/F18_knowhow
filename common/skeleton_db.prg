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

#include "hbclass.ch"

function TDBNew(oDesktop, cDirPriv, cDirKum, cDirSif)

local oObj

CLASS TDB
	DATA oDesktop
	DATA oApp
	DATA cName
	
	DATA cSezona
	DATA cRadimUSezona
	
	DATA cSezonDir
	DATA cBase
	DATA cDirPriv
	DATA cDirKum
	DATA cDirSif
	DATA cUser
	DATA nPassword
	DATA nGroup1
	DATA nGroup2
	DATA nGroup3
	DATA lAdmin

	METHOD New() 
	method setDirPriv
	method setDirSif
	method setDirKum
	method setUser
	method setPassword
	method setGroup1
	method setGroup2
	method setGroup3
	
ENDCLASS


method New(oDesktop, cDirPriv, cDirKum, cDirSif)  CLASS TDB

::oDesktop:=oDesktop
::cDirPriv:=cDirPriv
::cDirKum:=cDirKum
::cDirSif:=cDirSif
::lAdmin:=.f.
::cSezona:= ALLTRIM(STR(YEAR(DATE())))
return self



METHOD setDirPriv(cDir) CLASS TDB
local cPom

// dosadasnja vrijednost varijable
cPom:=::cDirPriv

cDir:=ALLTRIM(cDir)

if (gKonvertPath=="D")
	KonvertPath(@cDir)
endif

::cDirPriv:=ToUnix(cDir)

// setuj i globalnu varijablu dok ne eliminisemo sve pozive na tu varijablu
cDirPriv:=::cDirPriv

return cPom



*string TDB::setDirSif(string cDir)

METHOD setDirSif(cDir) CLASS TDB
local cPom

// dosadasnja vrijednost varijable
cPom:=::cDirSif

cDir:=alltrim(cDir)
if (gKonvertPath=="D")
	KonvertPath(@cDir)
endif
::cDirSif:=ToUnix(cDir)

// setuj i globalnu varijablu dok ne eliminisemo sve pozive na tu varijablu
cDirSif:=::cDirSif

return cPom



*string TDB::setDirKum(string cDir)

METHOD setDirKum(cDir) CLASS TDB
local cPom

// dosadasnja vrijednost varijable
cPom:=::cDirKum
cDir:=alltrim(cDir)
if (gKonvertPath=="D")
	KonvertPath(@cDir)
endif
::cDirKum:=ToUnix(cDir)

// setuj i globalnu varijablu dok ne eliminisemo sve pozive na tu varijablu

cDirKum:=::cDirKum
cDirRad:=::cDirKum

SET(_SET_DEFAULT, trim(cDir))

return cPom





*string TDB::setUser(string cUser)

METHOD setUser(cUser) CLASS TDB
local cPom
// dosadasnja vrijednost varijable
cPom:=::cUser
::cUser:=cUser
return cPom



*string TDB::setPassword(integer nPassword)

METHOD setPassword(nPassword) CLASS TDB
local nPom
// dosadasnja vrijednost varijable
nPom:=::nPassword
::nPassword:=nPassword
return nPom



*string TDB::setGroup1(integer nGroup)

METHOD setGroup1(nGroup) CLASS TDB
local nPom
// dosadasnja vrijednost varijable
nPom:=::nGroup1
::nGroup1:=nGroup
return nPom



*string TDB::setGroup2(integer nGroup)

METHOD setGroup2(nGroup) CLASS TDB
local nPom
// dosadasnja vrijednost varijable
nPom:=::nGroup2
::nGroup2:=nGroup
return nPom



*string TDB::setGroup3(integer nGroup)

METHOD setGroup3(nGroup) CLASS TDB
local nPom
// dosadasnja vrijednost varijable
nPom:=::nGroup3
::nGroup3:=nGroup
return nPom






