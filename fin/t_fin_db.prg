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

#include "fin.ch"

#include "hbclass.ch"
CLASS TDbFin INHERIT TDB 
    method New
    method install  
    method kreiraj  
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::super:new()

 ::cName:="FIN"
 ::lAdmin:=.f.

 ::kreiraj()

return self



method install()
install_start(goModul, .f.)
return



method kreiraj(nArea)
local cImeDbf

if (nArea==nil)
    nArea:=-1
endif

Beep(1)

if (nArea<>-1)
    CreSystemDb(nArea)
endif

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()


return




