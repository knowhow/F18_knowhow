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


#include "kalk.ch"
#include "hbclass.ch"


// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbKalk INHERIT TDB 
	method New
	method install	
	method kreiraj	
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::super:new()
 ::cName:="KALK"
 ::lAdmin:=.f.

 ::kreiraj()

return self


// -------------------------------------------------------
// -------------------------------------------------------
method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	install_start(goModul,.f.)
return


// -------------------------------------------------------
// -------------------------------------------------------
method kreiraj(nArea)
local lPoNarudzbi := .f.
local glBrojacPoKontima := .f.
local gVodiSamoTarife := "N"

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

if (nArea==nil)
	nArea:=-1
endif

if (nArea<>-1)
	CreSystemDb(nArea)
endif

if IsPlanika() 

    aDbf:={}
    AADD(aDBf,{ 'PKONTO'             , 'C' ,   7 ,  0 })
    AADD(aDBf,{ 'IDROBA'             , 'C' ,  10 ,  0 })
    AADD(aDBf,{ 'IDTARIFA'           , 'C' ,   6 ,  0 })
    AADD(aDBf,{ 'IDVD'               , 'C' ,   2 ,  0 })
    AADD(aDBf,{ 'BRDOK'              , 'C' ,   8 ,  0 })
    AADD(aDBf,{ 'DATDOK'             , 'D' ,   8 ,  0 })
    AADD(aDBf,{ 'NC'                 , 'N' ,  20 ,  8 })
    // kolicina kod posljednje nabavke
    AADD(aDBf,{ 'KOLICINA'           , 'N' ,  12 ,  2 })
	if !FILE(f18_ime_dbf("prodnc"))
    		DBcreate2('PRODNC.DBF',aDbf)
	endif
	CREATE_INDEX("PRODROBA","PKONTO+IDROBA","PRODNC")

    //RVrsta.Dbf
    aDbf:={}
    AADD(aDBf,{ 'ID'              , 'C' ,  1 ,  0 })
    AADD(aDBf,{ 'NAZ'             , 'C' , 30 ,  0 })
	if !FILE(f18_ime_dbf("rvrsta"))
    		DBcreate2('RVRSTA.DBF',aDbf)
	endif
	CREATE_INDEX("ID","ID","RVRSTA")
	CREATE_INDEX("NAZ", "NAZ", "RVRSTA")

endif

return


