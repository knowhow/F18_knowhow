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


#include "pos.ch"


// ----------------------------------
// fill init db podatke
// ----------------------------------
FUNCTION pos_init_dbfs()

   CLOSE ALL

   // kreiram inicijalne podatke u sifrarnicima ako nema nista
   CrePosISifData()

   // kreiraj priprz tabelu
   cre_priprz()

   RETURN


// -----------------------------------------------
// kreiraj priprz ako joj ne valja struktura
// -----------------------------------------------
STATIC FUNCTION cre_priprz()

   LOCAL cFileName := PRIVPATH + "PRIPRZ"
   LOCAL lCreate := .F.

   IF !File( f18_ime_dbf( "priprz" ) )
      lCreate := .T.
   ELSE
      // postoji provjeri je li struktura nova
      CLOSE ALL
      O_PRIPRZ
      // ako nije priprema prazna ne brisi
      IF reccount2() > 0
         RETURN .F.
      ENDIF

      IF FieldPos( "k7" ) == 0
         // stara struktura
         lCreate := .T.
      ENDIF
   ENDIF

   CLOSE ALL
   IF lCreate
      aDbf := g_pos_pripr_fields()
      DBcreate2 ( cFileName, aDbf )
      CREATE_INDEX ( "1", "IdRoba", cFileName )
   ENDIF

   RETURN
