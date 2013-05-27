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


#include "kadev.ch"
#include "hbclass.ch"

// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbKadev INHERIT TDB 
	method New
	method setgaDBFs	
	method install	
	method kreiraj	
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::super:new()
 ::cName := "KADEV"
 ::lAdmin := .f.

 ::kreiraj()

return self



// -----------------------------------------------
// -----------------------------------------------
method setgaDBFs()
// prebaceno u f18_utils.prg
return



// -----------------------------------------------
// -----------------------------------------------
method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	install_start(goModul,.f.)
return



// -------------------------------------------------
// -------------------------------------------------
method kreiraj( nArea )
local _table_name
local _alias

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

if (nArea==nil)
	nArea:=-1
endif

if (nArea<>-1)
	CreSystemDb(nArea)
endif

return

