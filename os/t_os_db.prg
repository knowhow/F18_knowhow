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
CLASS TDbOs INHERIT TDB 
	method New
	method install	
	method kreiraj	
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::super:new()
 ::cName:="OS"
 ::lAdmin:=.f.

 ::kreiraj()

return self


// -----------------------------------------------
// -----------------------------------------------
method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	install_start(goModul,.f.)
return



// -----------------------------------------------
// -----------------------------------------------
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

if (nArea==-1 .or. nArea==(F_INVENT))
	if !file(f18_ime_dbf("invent"))
	        aDbf:={}
	        AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
	        AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
	        AADD(aDBf,{ 'KOLICINA'            , 'N' ,   6 ,  1 })
	        AADD(aDBf,{ 'IZNOS'               , 'N' ,  14 ,  2 })
	        DBCREATE2(PRIVPATH+'INVENT.DBF',aDbf)
			
	endif
	CREATE_INDEX("ID","Id",PRIVPATH+"INVENT") // Inventura
endif

return




