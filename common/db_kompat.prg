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

/* \fn DBT2FPT(cImeDBF)
 * \brief Konvertuje memo polja iz DBT u FTP format (Clipper NTX -> FOX CDX)
 *
 * \note Obavezno proslijediti c:\sigma\ROBA - BEZ EXTENZIJE
 *
 */

FUNCTION DBT2FPT( cImeDBF )

   cImeDbf := StrTran( cImeDBF, "." + DBFEXT, "" )
   my_close_all_dbf()

   IF File( cimedbf + ".DBT" ) .AND. Pitanje(, "Izvrsiti konverziju " + cImeDBF, " " ) == "D"
      IF File( cimedbf + ".FPT" )
         MsgBeep( "Ne smije postojati" + cImeDBF + ".FPT ????#Prekidam operaciju !" )
         RETURN
      ENDIF
      MY_use ( cImeDBF, nil, .T., "DBFNTX" )
      MsgO( "Konvertujem " + cImeDBF + " iz DBT u FPT" )
      Beep( 1 )
      COPY STRUCTURE EXTENDED TO STRUCT
      my_USEX( "STRUCT", nil, .T. )
      dbAppend()
      REPLACE field_name WITH "BRISANO", field_type WITH "C", ;
         field_len WITH 1, field_dec WITH 0
      USE

      my_close_all_dbf()
      COPY File ( cImeDBF + ".DBF" ) TO ( PRIVPATH + "TEMP.DBF" )
      COPY File ( cImeDBF + ".DBT" ) TO ( PRIVPATH + "TEMP.DBT" )
      FErase( cImeDBF + ".DBT" )
      FErase( cImeDBF + ".DBF" )
      FErase( cImeDBF + ".CDX" )
      FErase( cImeDBF + ".FPT" )
      CREATE ( cImeDBF ) FROM STRUCT  VIA RDDENGINE
      my_close_all_dbf()
      MY_USE ( PRIVPATH + "TEMP", nil, .T., "DBFNTX" )
      SET ORDER TO 0
      MY_USE ( cImeDBF, "novi", .T., RDDENGINE )
      SET ORDER TO 0
      SELECT temp
      GO TOP
      DO WHILE !Eof()
         scatter()
         SELECT novi
         APPEND BLANK
         gather()
         SELECT temp
         SKIP
      ENDDO

      MsgC()
   ENDIF

   my_close_all_dbf()

   RETURN
