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

// -----------------------------------------------------------
// kreiranje tabela za proizvoljne izvjestaje
// -----------------------------------------------------------
FUNCTION proizvoljni_izvjestaji_db_cre()

   LOCAL aDbf
   LOCAL _alias, _table_name, _created

   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',   2,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  50,  0 } )
   AAdd( aDBf, { 'USLOV', 'C',  80,  0 } )
   AAdd( aDBf, { 'KPOLJE', 'C',  50,  0 } )
   AAdd( aDBf, { 'IMEKP', 'C',  10,  0 } )
   AAdd( aDBf, { 'KSIF', 'C',  50,  0 } )
   AAdd( aDBf, { 'KBAZA', 'C',  50,  0 } )
   AAdd( aDBf, { 'KINDEKS', 'C',  80,  0 } )
   AAdd( aDBf, { 'TIPTAB', 'C',   1,  0 } )

   _alias := "IZVJE"
   _table_name := "fin_izvje"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
   AFTER_CREATE_INDEX


   // KOLIZ.DBF (fin_koliz.dbf)

   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',   2,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  20,  0 } )
   AAdd( aDBf, { 'RBR', 'N',   2,  0 } )
   AAdd( aDBf, { 'FORMULA', 'C', 150,  0 } )
   AAdd( aDBf, { 'TIP', 'C',   2,  0 } )
   AAdd( aDBf, { 'SIRINA', 'N',   3,  0 } )
   AAdd( aDBf, { 'DECIMALE', 'N',   1,  0 } )
   AAdd( aDBf, { 'SUMIRATI', 'C',   1,  0 } )
   AAdd( aDBf, { 'K1', 'C',   1,  0 } )
   AAdd( aDBf, { 'K2', 'C',   2,  0 } )
   AAdd( aDBf, { 'N1', 'C',   1,  0 } )
   AAdd( aDBf, { 'N2', 'C',   2,  0 } )
   AAdd( aDBf, { 'KUSLOV', 'C', 100,  0 } )
   AAdd( aDBf, { 'SIZRAZ', 'C', 100,  0 } )

   _alias := "KOLIZ"
   _table_name := "fin_koliz"

   IF_NOT_FILE_DBF_CREATE
   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "1", "STR(rbr,2)", _alias )
   AFTER_CREATE_INDEX


   // ZAGLI.DBF (fin_zagli.dbf)

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   2,  0 } )
   AAdd( aDBf, { 'x1', 'N',   3,  0 } )
   AAdd( aDBf, { 'y1', 'N',   3,  0 } )
   AAdd( aDBf, { 'IZRAZ', 'C', 100,  0 } )

   _alias := "ZAGLI"
   _table_name := "fin_zagli"

   IF_NOT_FILE_DBF_CREATE


   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "1", "STR(x1,3)+STR(y1,3)", _alias )
   AFTER_CREATE_INDEX

   // KONIZ.DBF ( fin_koniz.dbf )

   aDBf := {}
   AAdd( aDBf, { 'IZV', 'C',   2,  0 } )
   AAdd( aDBf, { 'ID', 'C',  20,  0 } )
   AAdd( aDBf, { 'ID2', 'C',  20,  0 } )
   AAdd( aDBf, { 'OPIS', 'C',  57,  0 } )
   AAdd( aDBf, { 'RI', 'N',   4,  0 } )
   AAdd( aDBf, { 'FI', 'C',  80,  0 } )
   AAdd( aDBf, { 'FI2', 'C',  80,  0 } )
   AAdd( aDBf, { 'K', 'C',   2,  0 } )
   AAdd( aDBf, { 'K2', 'C',   2,  0 } )
   AAdd( aDBf, { 'PREDZN', 'N',   2,  0 } )
   AAdd( aDBf, { 'PREDZN2', 'N',   2,  0 } )
   AAdd( aDBf, { 'PODVUCI', 'C',   1,  0 } )
   AAdd( aDbf, { "K1", "C",   1,  0 } )
   AAdd( aDbf, { "U1", "C",   3,  0 } )

   _alias := "KONIZ"
   _table_name := "fin_koniz"

   IF_NOT_FILE_DBF_CREATE


   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "1", "izv+STR(ri,4)", _alias )
   AFTER_CREATE_INDEX

   RETURN .T.
