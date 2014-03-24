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

   LOCAL lPoNarudzbi := .F.
   LOCAL glBrojacPoKontima := .F.
   LOCAL gVodiSamoTarife := "N"

   cDirRad := my_home()
   cDirSif := my_home()
   cDirPriv := my_home()

   IF ( nArea == nil )
      nArea := -1
   ENDIF

   IF ( nArea <> -1 )
      CreSystemDb( nArea )
   ENDIF

   IF IsPlanika()

      aDbf := {}
      AAdd( aDBf, { 'PKONTO', 'C',   7,  0 } )
      AAdd( aDBf, { 'IDROBA', 'C',  10,  0 } )
      AAdd( aDBf, { 'IDTARIFA', 'C',   6,  0 } )
      AAdd( aDBf, { 'IDVD', 'C',   2,  0 } )
      AAdd( aDBf, { 'BRDOK', 'C',   8,  0 } )
      AAdd( aDBf, { 'DATDOK', 'D',   8,  0 } )
      AAdd( aDBf, { 'NC', 'N',  20,  8 } )
      // kolicina kod posljednje nabavke
      AAdd( aDBf, { 'KOLICINA', 'N',  12,  2 } )
      IF !File( f18_ime_dbf( "prodnc" ) )
         DBcreate2( 'PRODNC.DBF', aDbf )
      ENDIF
      CREATE_INDEX( "PRODROBA", "PKONTO+IDROBA", "PRODNC" )

      // RVrsta.Dbf
      aDbf := {}
      AAdd( aDBf, { 'ID', 'C',  1,  0 } )
      AAdd( aDBf, { 'NAZ', 'C', 30,  0 } )
      IF !File( f18_ime_dbf( "rvrsta" ) )
         DBcreate2( 'RVRSTA.DBF', aDbf )
      ENDIF
      CREATE_INDEX( "ID", "ID", "RVRSTA" )
      CREATE_INDEX( "NAZ", "NAZ", "RVRSTA" )

   ENDIF

   RETURN
