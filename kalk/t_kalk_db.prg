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
CLASS TDbKalk INHERIT TDB

   METHOD NEW
   METHOD install
   METHOD kreiraj

ENDCLASS


// --------------------------------------------
// --------------------------------------------
METHOD New()

   ::super:new()
   ::cName := "KALK"
   ::lAdmin := .F.

   ::kreiraj()

   RETURN self


// -------------------------------------------------------
// -------------------------------------------------------
METHOD install( cKorisn, cSifra, p3, p4, p5, p6, p7 )

   install_start( goModul, .F. )

   RETURN


// -------------------------------------------------------
// -------------------------------------------------------
METHOD kreiraj( nArea )

   LOCAL glBrojacPoKontima := .F.

   cDirRad := my_home()
   cDirSif := my_home()
   cDirPriv := my_home()

   IF ( nArea == nil )
      nArea := -1
   ENDIF

   IF ( nArea <> -1 )
      CreSystemDb( nArea )
   ENDIF

   RETURN
