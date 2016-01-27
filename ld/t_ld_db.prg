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


CLASS TDbLd INHERIT TDB

   METHOD NEW
   METHOD install
   METHOD kreiraj

ENDCLASS


METHOD New()

   ::super:new()
   ::cName := "LD"
   ::lAdmin := .F.

   ::kreiraj()

   RETURN self


// -------------------------------------------------
// -------------------------------------------------
METHOD install( cKorisn, cSifra, p3, p4, p5, p6, p7 )

   install_start( goModul, .F. )

   RETURN


// -------------------------------------------------
// -------------------------------------------------
METHOD kreiraj( nArea )

   cDirRad := my_home()
   cDirSif := my_home()
   cDirPriv := my_home()

   IF ( nArea == nil )
      nArea := -1
   ENDIF

   IF ( nArea <> -1 )
      CreSystemDb( nArea )
   ENDIF

   // REKLD
   aDbf := {}
   AAdd( aDbf, { "GODINA",  "C",  4, 0 } )
   AAdd( aDbf, { "MJESEC",  "C",  2, 0 } )
   AAdd( aDbf, { "ID",  "C", 40, 0 } )
   AAdd( aDbf, { "OPIS",  "C", 40, 0 } )
   AAdd( aDbf, { "IZNOS1",  "N", 18, 4 } )
   AAdd( aDbf, { "IZNOS2",  "N", 18, 4 } )
   AAdd( aDbf, { "IDPARTNER",  "C",  6, 0 } )

   IF !File( f18_ime_dbf( "REKLD" ) )
      DBCreate2( "REKLD", aDbf )
   ENDIF

   CREATE_INDEX( "1", "godina+mjesec+id", "REKLD" )
   CREATE_INDEX( "2", "godina+mjesec+id+idpartner", "REKLD" )

   AAdd( aDbf, { "IDRNAL",  "C", 10, 0 } )

   IF !File( f18_ime_dbf( "REKLDP" ) )
      DBCreate2( "REKLDP", aDbf )
   ENDIF

   CREATE_INDEX( "1", "godina+mjesec+id+idRNal", "REKLDP" )


   aDbf := {}
   AAdd( aDbf, { "ID",  "C",  1, 0 } )
   AAdd( aDbf, { "IDOPS",  "C",  4, 0 } )
   AAdd( aDbf, { "IZNOS",  "N", 18, 4 } )
   AAdd( aDbf, { "IZNOS2",  "N", 18, 4 } )
   AAdd( aDbf, { "LJUDI",  "N",  4, 0 } )

   IF !File( f18_ime_dbf( "OPSLD" ) )
      DBCreate2( "OPSLD", aDbf )
   ENDIF

   CREATE_INDEX( "1", "id+idops", "OPSLD" )

   RETURN
