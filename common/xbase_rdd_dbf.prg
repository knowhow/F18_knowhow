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

#include "f18.ch"

FUNCTION f18_ime_dbf( xTableRec )

   LOCAL _pos
   LOCAL _a_dbf_rec
   LOCAL _ret

   SWITCH ValType( xTableRec )

   CASE "H"
      _a_dbf_rec := xTableRec
      EXIT
   CASE "C"
      _a_dbf_rec := get_a_dbf_rec( FILEBASE( xTableRec, .T. ), .T. )
      EXIT
   OTHERWISE
      ?E  "f18_ime_dbf arg ?! " + hb_ValToStr( xTableRec )
   ENDSWITCH

   IF _a_dbf_rec[ "table" ] == "x"
      Alert( "f18_ime_dbf alias :" + ToStr( xTableRec ) )
   ENDIF

   IF ValType( _a_dbf_rec[ "table" ] ) != "C" .OR. ValType( my_home() ) != "C"
      _ret := "xyz"
      ?E "ERROR_f18_ime_dbf", my_home(), _a_dbf_rec[ "table" ]
   ELSE
      _ret := my_home() + _a_dbf_rec[ "table" ] + "." + DBFEXT
   ENDIF

   RETURN _ret



/*
   uzima sva polja iz tekuceg dbf zapisa
*/
FUNCTION dbf_get_rec()

   LOCAL _ime_polja, _i, _struct
   LOCAL _ret := hb_Hash()

   _struct := dbStruct()
   FOR _i := 1 TO Len( _struct )

      _ime_polja := _struct[ _i, 1 ]

      IF !( "#" + _ime_polja + "#" $ "#BRISANO#_OID_#_COMMIT_#" )
         _ret[ Lower( _ime_polja ) ] := Eval( FieldBlock( _ime_polja ) )
      ENDIF

   NEXT

   RETURN _ret


/*
     is_dbf_struktura_polja_identicna( "racun", "BRDOK", 8, 0)

    => .T. ako je racun, brdok C(8, 0)

    => .F.  ako je racun.brdok npr. C(6,0)
    => .F.  ako je racun.brdok polje ne postoji
*/
FUNCTION is_dbf_struktura_polja_identicna( cTable, cPolje, nLen, nWidth )

   my_use( cTable )

   IF FieldPos( cPolje ) == 0
      USE
      RETURN .F.
   ENDIF

   SWITCH ValType( cPolje )

   CASE "C"
      IF Len( Eval( FieldBlock( cPolje ) ) ) != nLen
         USE
         RETURN .F.
      ENDIF
      EXIT
   OTHERWISE
      USE
      RaiseError( "implementirano samo za C polja" )

   ENDSWITCH

   USE

   RETURN .T.


FUNCTION my_reccount()

   RETURN RecCount2()


FUNCTION RecCount2()

   LOCAL nCnt, nDel

   PushWa()
   count_deleted( @nCnt, @nDel )
   SET DELETED ON
   PopWa()

   RETURN nCnt - nDel

FUNCTION my_delete()

   RETURN delete_with_rlock()



FUNCTION my_delete_with_pack()

   my_delete()

   RETURN my_dbf_pack()


FUNCTION delete_with_rlock()

   IF my_rlock()
      DELETE
      my_unlock()
      RETURN .T.
   ENDIF

   RETURN .F.



/*
   ferase_dbf( "konto", .T. ) => izbriši tabelu "konto.dbf"
                                 (kao i pripadajuće indekse)

   - lSilent (default .T.)
     .F. => pitaj korisnika da li želi izbrisati tabelu
     .T. => briši bez pitanja
*/

FUNCTION f18_delete_dbf( tbl_name )

   RETURN ferase_dbf( tbl_name, .T. )


FUNCTION ferase_dbf( tbl_name, lSilent )

   LOCAL _tmp, _odg

   IF lSilent == NIL
      lSilent := .T.
   ENDIF

   IF !lSilent

      _odg := Pitanje(, "Izbrisati dbf tabelu " + tbl_name + " (L-quit) ?!", "N" )

      IF _odg == "L"
         log_write( "ferase_dbf quit: " + tbl_name, 3 )
         QUIT_1
      ENDIF

      IF _odg == "N"
         RETURN .F.
      ENDIF

   ENDIF

   log_write( "ferase_dbf : " + tbl_name, 3 )
   tbl_name := f18_ime_dbf( tbl_name )

   IF File( tbl_name )
      IF FErase( tbl_name ) != 0
         log_write( "ferase_dbf : " + tbl_name + "neuspjesno !", 3 )
         RETURN .F.
      ENDIF
   ENDIF

   _tmp := StrTran( tbl_name, DBFEXT, INDEXEXT )
   IF File( _tmp )
      log_write( "ferase_dbf, brisem: " + _tmp, 3 )
      IF FErase( _tmp ) != 0
         log_write( "ferase_dbf : " + _tmp + "neuspjesno !", 3 )
         RETURN .F.
      ENDIF
   ENDIF

   _tmp := StrTran( tbl_name, DBFEXT, MEMOEXT )
   IF File( _tmp )
      log_write( "ferase, brisem: " + _tmp, 3 )
      IF FErase( _tmp ) != 0
         log_write( "ferase_dbf : " + _tmp + "neuspjesno !", 3 )
         RETURN .F.
      ENDIF
   ENDIF

   RETURN .T.



FUNCTION ferase_cdx( tbl_name )

   LOCAL _tmp

   tbl_name := f18_ime_dbf( tbl_name )

   _tmp := StrTran( tbl_name, DBFEXT, INDEXEXT )
   IF File( _tmp )
      log_write( "ferase_cdx, brisem: " + _tmp, 3 )
      IF FErase( _tmp ) != 0
         log_write( "ferase_cdx : " + _tmp + "neuspjesno !", 3 )
         RETURN .F.
      ENDIF
   ENDIF

   RETURN .T.


// ------------------------------------------------------
// open exclusive, lOpenIndex - otvoriti index
// ------------------------------------------------------
/*
// FUNCTION reopen_shared( dbf_table, lOpenIndex )

   RETURN reopen_dbf( .F., dbf_table, lOpenIndex )
*/


FUNCTION reopen_exclusive( xArg1, lOpenIndex )

   RETURN reopen_dbf( .T., xArg1, lOpenIndex )



FUNCTION reopen_dbf( lExclusive, xArg1, lOpenIndex )

   LOCAL _a_dbf_rec, _err
   LOCAL _dbf
   LOCAL lRet
   LOCAL cMsg

   IF lOpenIndex == NIL
      lOpenIndex := .T.
   ENDIF

   IF ValType( xArg1 ) == "H"
      _a_dbf_rec := xArg1
   ELSE
      _a_dbf_rec  := get_a_dbf_rec( xArg1, .T. )
   ENDIF

   IF _a_dbf_rec[ "sql" ]
      RETURN .F.
   ENDIF


   SELECT ( _a_dbf_rec[ "wa" ] )
   USE

   _dbf := my_home() + _a_dbf_rec[ "table" ]

   BEGIN SEQUENCE WITH {| err| Break( err ) }

      dbUseArea( .F., DBFENGINE, _dbf, _a_dbf_rec[ "alias" ], iif( lExclusive, .F., .T. ), .F. )
      IF lOpenIndex
         IF File( ImeDbfCdx( _dbf ) )
            dbSetIndex( ImeDbfCDX( _dbf ) )
         ENDIF
         lRet := .T.
      ENDIF

   RECOVER USING _err

      cMsg := "tbl:" + _a_dbf_rec[ "table" ] + " : " + _err:description +  " excl:" + ToStr( lExclusive )
      info_bar( "reop_dbf:" + _a_dbf_rec[ "table" ], cMsg )
      ?E "ERR-reopen_dbf " + cMsg
      lRet := .F.

   END SEQUENCE

   RETURN lRet


// ------------------------------------------------------
// zap, then open shared, lOpenIndex - otvori index
// ------------------------------------------------------
FUNCTION reopen_exclusive_and_zap( cDbfTable, lOpenIndex )

   LOCAL _err

   IF lOpenIndex == NIL
      lOpenIndex := .T.
   ENDIF


   BEGIN SEQUENCE WITH {| err | Break( err ) }

      reopen_dbf( .T., cDbfTable, lOpenIndex )
      ZAP
      reopen_dbf( .F., cDbfTable, lOpenIndex )

   RECOVER USING _err

      ?E "ERROR-REXCL-ZAP ", _err:Description
      // info_bar( "reop_dbf_zap:" + cDbfTable, cDbfTable + " / " + _err:Description )
      reopen_dbf( .F., cDbfTable, lOpenIndex )
      zapp()

   END SEQUENCE

   RETURN .T.


FUNCTION open_exclusive_zap_close( xArg1, lOpenIndex )

   LOCAL cDbfTable
   LOCAL _err
   LOCAL nRecCount := 999
   LOCAL nCounter := 0

   IF ValType( xArg1 ) == "H"
      cDbfTable := xArg1[ "table" ]
   ELSE
      cDbfTable := xArg1
   ENDIF


   IF lOpenIndex == NIL
      lOpenIndex := .T.
   ENDIF

   DO WHILE nRecCount != 0

      BEGIN SEQUENCE WITH {| err | Break( err ) }
         IF ValType( xArg1 ) == "H"
            reopen_dbf( .T., xArg1, lOpenIndex )
         ELSE
            reopen_dbf( .T., cDbfTable, lOpenIndex )
         ENDIF

         ZAP
         nRecCount := RecCount2()

         USE

      RECOVER USING _err

         ?E "ERR-OXCL-ZAP ", cDbfTable, _err:Description, nCounter
         // info_bar( "op_zap_clo:" + cDbfTable, cDbfTable + " / " + _err:Description )
         IF ValType( xArg1 ) == "H"
            reopen_dbf( .F., xArg1, lOpenIndex )
         ELSE
            reopen_dbf( .F., cDbfTable, lOpenIndex )
         ENDIF
         zapp()

         IF Used()
            nRecCount := RecCount2()
         ENDIF

         USE

      END SEQUENCE

      nCounter++

      IF nCounter > 10
         RETURN .F.
      ELSE
         hb_idleSleep( 1 )
      ENDIF
   ENDDO

   RETURN .T.

FUNCTION my_dbf_zap( cTabelaOrAlias )

   LOCAL cAlias
   LOCAL lRet

   IF cTabelaOrAlias  != NIL
      cAlias := get_a_dbf_rec( cTabelaOrAlias )[ "alias" ]
   ELSE
      cAlias := Alias()
   ENDIF

   PushWA()
   lRet := reopen_exclusive_and_zap( cAlias, .T. )
   PopWa()

   RETURN lRet


FUNCTION my_dbf_pack( lOpenUSharedRezimu )

   LOCAL lRet
   LOCAL cAlias
   LOCAL cMsg

   cAlias := Alias()

   IF lOpenUSharedRezimu == NIL
      lOpenUSharedRezimu := .T.
   ENDIF

   PushWA()
   lRet :=  reopen_dbf( .T., cAlias, .T. )

   IF lRet
      __dbPack()
   ENDIF

   IF !lRet .OR. lOpenUSharedRezimu
      lRet := reopen_dbf( .F., cAlias, .T. ) // ako je neuspjesan bio reopen u ekskluzivnom režimu obavezno otvoriti ponovo
   ENDIF

   IF Alias() <> cAlias
      PopWa()
      cMsg := "my_dbf_pack :" + Alias() + " <> " + cAlias
      RaiseError( cMsg )
   ENDIF
   PopWa()

   RETURN lRet



FUNCTION pakuj_dbf( a_dbf_rec, lSilent )

   LOCAL _err

   log_write( "PACK table " + a_dbf_rec[ "alias" ], 2 )

   BEGIN SEQUENCE WITH {| err| Break( err ) }

      SELECT ( a_dbf_rec[ "wa" ] )
      my_use_temp( a_dbf_rec[ "alias" ], my_home() + a_dbf_rec[ "table" ], .F., .T. )

      ?E "PACK-TABELA", a_dbf_rec[ "table" ]

      PACK

      DO WHILE .T.
         USE
         IF Used()
            hb_idleSleep( 2 )
         ELSE
            EXIT
         ENDIF
      ENDDO


   RECOVER using _err
      log_write( "NOTIFY: PACK neuspjesan dbf: " + a_dbf_rec[ "table" ] + "  " + _err:Description, 3 )

   END SEQUENCE

   RETURN .T.




STATIC FUNCTION zatvori_dbf( value )

   Select( value[ 'wa' ] )

   IF Used()
      // ostalo je još otvorenih DBF-ova
      USE
      RETURN .F.
   ENDIF

   RETURN .T.




FUNCTION dbf_open_temp_and_count( aDbfRec, nCntSql, nCnt, nDel )

   LOCAL cAliasTemp := "TEMP__" + aDbfRec[ "alias" ]
   LOCAL cFullDbf := f18_ime_dbf( aDbfRec )
   LOCAL cFullIdx
   LOCAL bKeyBlock, cEmptyRec, nDel0, nCnt2
   LOCAL oError
   LOCAL nI, cMsg, cLogMsg := ""

   cFullIdx := ImeDbfCdx( cFullDbf )

   BEGIN SEQUENCE WITH {| err| Break( err ) }
      SELECT ( aDbfRec[ "wa" ] + 2000 )
      USE  ( cFullDbf ) Alias ( cAliasTemp )  SHARED
      IF File( cFullIdx )
         dbSetIndex( ImeDbfCdx( cFullDbf ) )
      ENDIF
   RECOVER USING  oError
      LOG_CALL_STACK cLogMsg
      ?E "dbf_open_temp_and_count use dbf:", cFullDbf, "alias:", cAliasTemp, oError:Description
      error_bar( "dbf_open_tmp_cnt", cAliasTemp + " / " + oError:Description )
      QUIT_1
   END SEQUENCE

   count_deleted( @nCnt, @nDel )

   IF Abs( nCntSql - nCnt + nDel ) > 0

      bKeyBlock := aDbfRec[ "algoritam" ][ 1 ][ "dbf_key_block" ]
      IF hb_HHasKey( aDbfRec[ "algoritam" ][ 1 ], "dbf_key_empty_rec" )

         nDel0 := nDel
         SET ORDER TO
         SET DELETED ON
         cEmptyRec := aDbfRec[ "algoritam" ][ 1 ][ "dbf_key_empty_rec" ]

         nCnt2 := 0
         dbEval( {|| delete_empty_records( bKeyBlock, cEmptyRec, @nCnt2 ) } )
         count_deleted( @nCnt, @nDel )
         log_write( "DELETING (nDel0:" + ;
            AllTrim( Str( nDel0 ) ) + ") empty records for dbf: " + ;
            aDbfRec[ "table" ] + " nDel:" + AllTrim( Str( nDel ) ) + ;
            " nCnt2= " + AllTrim( Str ( nCnt2 ) ), 1 )
      ELSE
         ?E "WARNING-dbf_open_temp_and_count_NOT_defined_dbf_key_empty_rec: " + aDbfRec[ "table" ]
      ENDIF

   ENDIF

   USE
   SET DELETED ON

   RETURN .T.


FUNCTION count_deleted( nCnt, nDel )

   LOCAL oError

   SET DELETED OFF
   SET ORDER TO TAG "DEL"
   IF Empty( ordKey() )
      SET DELETED ON
      COUNT TO nCnt
      nDel := 0
   ELSE
      COUNT TO nDel
      nCnt := RecCount()
   ENDIF

   RETURN .T.


STATIC FUNCTION delete_empty_records( bKeyBlock, cEmptyRec, nCnt2 )

   IF Eval( bKeyBlock ) == cEmptyRec
      RLock()
      dbDelete()
      dbUnlock()
      nCnt2++
      RETURN .T.
   ENDIF

   RETURN .F.
