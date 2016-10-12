/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

// ------------------------------------
// set_global_vars_from_dbf("w")
// geerise public vars wId, wNaz ..
// sa vrijednostima dbf polja Id, Naz
// -------------------------------------
FUNCTION set_global_memvars_from_dbf( cPrefixVarijabla )

   RETURN set_global_vars_from_dbf( cPrefixVarijabla )





FUNCTION get_hash_record_from_global_vars( cPrefixVarijabla, lReleaseVarFromMemory, lUtf )

   LOCAL _ime_polja, _i, _struct
   LOCAL _ret := hb_Hash()

   IF cPrefixVarijabla == nil
      cPrefixVarijabla := "_"
   ENDIF

   // da li da pobrisem odmah iz memorije...
   IF lReleaseVarFromMemory == NIL
      lReleaseVarFromMemory := .T.
   ENDIF

   IF lUtf == NIL
      lUtf := .F.
   ENDIF

   _struct := dbStruct()

   FOR _i := 1 TO Len( _struct )

      _ime_polja := _struct[ _i, 1 ]

      IF !( "#" + _ime_polja + "#" $ "#BRISANO#_OID_#_COMMIT_#" )

         // punimo hash matricu sa vrijednostima public varijabli
         // _ret["idfirma"] := wIdFirma, za cPrefixVarijabla = "w"
         _ret[ Lower( _ime_polja ) ] := Eval( MemVarBlock( cPrefixVarijabla + _ime_polja ) )

         IF ( ValType( _ret[ Lower( _ime_polja ) ] ) == "C" ) .AND.  lUtf
            _ret[ Lower( _ime_polja ) ] := hb_StrToUTF8 ( _ret[ Lower( _ime_polja ) ]  )
         ENDIF

         IF lReleaseVarFromMemory // oslobadja public ili private varijablu
            __mvXRelease( cPrefixVarijabla + _ime_polja )
         ENDIF

      ENDIF

   NEXT

   RETURN _ret



// -----------------------------------------
// vratice osnovu naziva tabele
// fakt_fakt -> fakt
// fakt_doks -> fakt
// -----------------------------------------
STATIC FUNCTION _table_base( a_dbf_rec )

   LOCAL _table := ""
   LOCAL _sep := "_"
   LOCAL _arr

   IF _sep $ a_dbf_rec[ "table" ]
      _arr := toktoniz( a_dbf_rec[ "table" ], _sep )
      IF Len( _arr ) > 1
         _table := _arr[ 1 ]
      ENDIF
   ENDIF

   RETURN _table


/* TODO: izbaciti ovo je koristeno u 1.4 kod ulaska u aplikaciju

FUNCTION iterate_through_active_tables( iterate_block )

   LOCAL _key
   LOCAL _f18_dbf
   LOCAL _temp_tbl
   LOCAL _sql_tbl := .F.

   get_dbf_params_from_ini_conf()
   _f18_dbfs := f18_dbfs()

   FOR EACH _key in _f18_dbfs:Keys

      _temp_tbl := _f18_dbfs[ _key ][ "temp" ]

      // sql tabela
      IF hb_HHasKey( _f18_dbfs[ _key ], "sql" )
         IF _f18_dbfs[ _key ][ "sql" ]
            _sql_tbl := .T.
         ENDIF
      ENDIF

      IF !_temp_tbl .AND. !_sql_tbl

         _tbl_base := _table_base( _f18_dbfs[ _key ] )

         // radi os/sii
         IF _tbl_base == "sii"
            _tbl_base := "os"
         ENDIF

         // EMPTY - sifarnici (roba, tarifa itd)
         IF  Empty( _tbl_base ) .OR. f18_use_module( _tbl_base )
            Eval( iterate_block, _f18_dbfs[ _key ] )
         ENDIF

      ENDIF

   NEXT

   RETURN .T.

// ---------------------------------------------------------------
// utvrdjuje da li se tabela koristi
//
// ako je use KALK = N, is_active_dbf_table("kalk_kalk") => .f.
//
// ---------------------------------------------------------------
FUNCTION is_active_dbf_table( table )

   LOCAL _key
   LOCAL _f18_dbf
   LOCAL _temp_tbl

   _f18_dbfs := f18_dbfs()

   // tabela sa ovakvim imenom uopste ne postoji
   IF  !hb_HHasKey( _f18_dbfs, table )
      RETURN .F.
   ENDIF


   _temp_tbl := _f18_dbfs[ table ][ "temp" ]


   IF !_temp_tbl

      _tbl_base := _table_base( _f18_dbfs[ table ] )

      // radi os/sii
      IF _tbl_base == "sii"
         _tbl_base := "os"
      ENDIF

      // EMPTY - sifarnici (roba, tarifa itd)
      IF  Empty( _tbl_base ) .OR. f18_use_module( _tbl_base )
         RETURN .T.
      ENDIF

   ENDIF

   RETURN .F.

*/
