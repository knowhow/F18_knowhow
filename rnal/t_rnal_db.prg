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

CLASS TDbRnal INHERIT TDB

   METHOD NEW
   METHOD install
   METHOD kreiraj

ENDCLASS


METHOD New()

   ::super:new()
   ::cName := "RNAL"
   ::lAdmin := .F.

   ::kreiraj()

   RETURN self



// ----------------------------------------
// ----------------------------------------
METHOD install()

   install_start( goModul, .F. )

   RETURN


// ----------------------------------------
// ----------------------------------------
METHOD kreiraj( nArea )

   cDirRad := my_home()
   cDirSif := my_home()
   cDirPriv := my_home()

   IF ( nArea == nil )
      nArea := -1
   ENDIF

   Beep( 1 )

   IF ( nArea <> -1 )
      CreSystemDb( nArea )
   ENDIF

   RETURN
