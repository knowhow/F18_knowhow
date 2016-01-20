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
#include "hbclass.ch"

// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbLd INHERIT TDB 
	method New
	method install	
	method kreiraj	
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::super:new()
 ::cName:="LD"
 ::lAdmin:=.f.

 ::kreiraj()

return self


// -------------------------------------------------
// -------------------------------------------------
method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	install_start(goModul,.f.)
return


// -------------------------------------------------
// -------------------------------------------------
method kreiraj(nArea)

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

if (nArea==nil)
    nArea:=-1
endif

if (nArea<>-1)
	CreSystemDb(nArea)
endif

// REKLD
aDbf:={}
AADD( aDbf, {"GODINA"     ,  "C" ,  4, 0})
AADD( aDbf, {"MJESEC"     ,  "C" ,  2, 0})
AADD( aDbf, {"ID"         ,  "C" , 40, 0})
AADD( aDbf, {"OPIS"       ,  "C" , 40, 0})
AADD( aDbf, {"IZNOS1"     ,  "N" , 18, 4})
AADD( aDbf, {"IZNOS2"     ,  "N" , 18, 4})
AADD( aDbf, {"IDPARTNER"  ,  "C" ,  6, 0})

if !FILE( f18_ime_dbf( "REKLD" ) )
    DBCreate2( "REKLD", aDbf )
endif

CREATE_INDEX("1","godina+mjesec+id", "REKLD" )
CREATE_INDEX("2","godina+mjesec+id+idpartner", "REKLD" )

AADD( aDbf, {"IDRNAL"  ,  "C" , 10, 0})

if !FILE(f18_ime_dbf( "REKLDP" ))
    DBCreate2( "REKLDP", aDbf )
endif

CREATE_INDEX("1","godina+mjesec+id+idRNal", "REKLDP" )


aDbf := {} 
AADD( aDbf, {"ID"     ,  "C" ,  1, 0})
AADD( aDbf, {"IDOPS"  ,  "C" ,  4, 0})
AADD( aDbf, {"IZNOS"  ,  "N" , 18, 4})
AADD( aDbf, {"IZNOS2" ,  "N" , 18, 4})
AADD( aDbf, {"LJUDI"  ,  "N" ,  4, 0})

if !FILE( f18_ime_dbf("OPSLD") )
    DBCreate2( "OPSLD", aDbf )
endif

CREATE_INDEX("1","id+idops", "OPSLD" )

return



