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

#include "fmk.ch"
#include "hbclass.ch"
#include "common.ch"

CLASS CsvReader

   DATA STRUCT
   DATA csvname
   DATA memname
   DATA DELIMITER
   DATA wa

   METHOD new()
   METHOD READ()
   METHOD CLOSE()

   PROTECTED:

   METHOD create_mem_dbf()
   METHOD open_csv_as_local_dbf()

ENDCLASS


// -----------------------------------------------------
// -----------------------------------------------------
METHOD CsvReader:New()

   ::memname := "csvimp"
   ::wa := 360

   RETURN self


// -----------------------------------------------------
// -----------------------------------------------------
METHOD CsvReader:close()

   SELECT ( ::wa )
   USE

   RETURN SELF


// ------------------------------------------------------
// ------------------------------------------------------
METHOD CsvReader:read()

   LOCAL _ok := .F.

   if ::struct == NIL
      MsgBeep( "Struktura zaboravljena !" )
      RETURN _ok
   ENDIF

   if ::csvname == NIL
      MsgBeep( "A koji fajl da importujem ???" )
      RETURN _ok
   ENDIF

   if ::delimiter == NIL
      ::delimiter := ";"
   ENDIF

   // kreiraj i otvori lokalni dbf
   ::create_mem_dbf()

   // otvori csv u dbf
   ::open_csv_as_local_dbf()

   RETURN _ok


// ------------------------------------------------------
// ------------------------------------------------------
METHOD CsvReader:create_mem_dbf()

   dbCreate( ::memname, ::struct, "ARRAYRDD" )

   RETURN


// ------------------------------------------------------
// ------------------------------------------------------
METHOD CsvReader:open_csv_as_local_dbf()

   SELECT ( ::wa )
   USE ( ::memname ) VIA "ARRAYRDD"

   APPEND FROM ( ::csvname ) DELIMITED
   GO TOP
   SKIP 1

   RETURN
