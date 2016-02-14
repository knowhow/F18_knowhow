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

   _ret := my_home() + _a_dbf_rec[ "table" ] + "." + DBFEXT

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

   RETURN RecCount()



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

/* TODO: out
FUNCTION repair_dbfs()

   LOCAL _ver

   _ver := read_dbf_version_from_config()

   cre_all_dbfs( _ver )

   RETURN .T.
*/


// ------------------------------------------------------
// open exclusive, open_index - otvoriti index
// ------------------------------------------------------
/*
// FUNCTION reopen_shared( dbf_table, open_index )

   RETURN reopen_dbf( .F., dbf_table, open_index )
*/


FUNCTION reopen_exclusive( dbf_table, open_index )

   RETURN reopen_dbf( .T., dbf_table, open_index )



FUNCTION reopen_dbf( excl, dbf_table, open_index )

   LOCAL _a_dbf_rec
   LOCAL _dbf
   LOCAL lRet
   LOCAL cMsg

   IF open_index == NIL
      open_index := .T.
   ENDIF

   _a_dbf_rec  := get_a_dbf_rec( dbf_table, .T. )
   IF _a_dbf_rec[ "sql" ]
      RETURN .F.
   ENDIF

   SELECT ( _a_dbf_rec[ "wa" ] )
   USE

   _dbf := my_home() + _a_dbf_rec[ "table" ]

   BEGIN SEQUENCE WITH {| err| Break( err ) }

      dbUseArea( .F., DBFENGINE, _dbf, _a_dbf_rec[ "alias" ], iif( excl, .F., .T. ), .F. )

      IF open_index
         IF File( ImeDbfCdx( _dbf ) )
            dbSetIndex( ImeDbfCDX( _dbf ) )
         ENDIF
         lRet := .T.
      ENDIF

   RECOVER USING _err

      cMsg := "ERROR reopen_dbf: " + _err:description + ": tbl:" + _dbf + " excl:" + ToStr( excl )
      log_write( cMsg, 2 )
      lRet := .F.

   END SEQUENCE

   RETURN lRet


// ------------------------------------------------------
// zap, then open shared, open_index - otvori index
// ------------------------------------------------------
FUNCTION reopen_exclusive_and_zap( dbf_table, open_index )

   LOCAL _err

   IF open_index == NIL
      open_index := .T.
   ENDIF


   BEGIN SEQUENCE WITH {| err | Break( err ) }

      reopen_dbf( .T., dbf_table, open_index )
      ZAP
      reopen_dbf( .F., dbf_table, open_index )

   RECOVER USING _err

      log_write( "ERROR-REXCL-ZAP " + _err:Description, 3 )
      reopen_dbf( .F., dbf_table, open_index )
      zapp()

   END SEQUENCE

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
      // ako je neuspjesan bio reopetn u ekskluzivnom režimu obavezno otvoriti ponovo
      lRet := reopen_dbf( .F., cAlias, .T. )
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

      IF ! lSilent
         Box( "#Molimo sačekajte...", 7, 75 )
         @ m_x + 7, m_y + 2 SAY8 "Pakujem tabelu radi brzine, molim sačekajte ..."
      ENDIF

      PACK

      DO WHILE .T.
         USE
         IF Used()
            hb_idleSleep( 2 )
         ELSE
            EXIT
         ENDIF
      ENDDO

      IF ! lSilent
         BoxC()
      ENDIF

   RECOVER using _err
      log_write( "NOTIFY: PACK neuspjesan dbf: " + a_dbf_rec[ "table" ] + "  " + _err:Description, 3 )

   END SEQUENCE

   RETURN .T.




FUNCTION full_table_synchro()

   LOCAL _sifra := Space( 6 ), _full_table_name, _alias := PadR( "PAROBR", 30 )

   Box( , 3, 60 )
   @ m_x + 1, m_y + 2 SAY " Admin sifra :" GET  _sifra PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Table alias  :"  GET _alias PICTURE "@S20"
   READ
   BoxC()

   IF ( LastKey() == K_ESC ) .OR. ( Upper( AllTrim( _sifra ) ) != "F18AD" )
      MsgBeep( "nista od ovog posla !" )
      RETURN .F.
   ENDIF

   _alias := AllTrim( Upper( _alias ) )

   CLOSE ALL
   _full_table_name := f18_ime_dbf( _alias )

   IF File( _full_table_name )
      ferase_dbf( _alias )
   ELSE
      MsgBeep( "ove dbf tabele nema: " + _full_table_name )
   ENDIF

   post_login()

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
         log_write( "ERR-dbf_open_temp_and_count: " + aDbfRec[ "table" ] + " not defined dbf_key_empty_rec", 1 )
      ENDIF

   ENDIF

   USE
   SET DELETED ON

   RETURN .T.


STATIC FUNCTION count_deleted( nCnt, nDel )

   LOCAL oError

   BEGIN SEQUENCE WITH {| err| Break( err ) }
      SET DELETED OFF
      SET ORDER TO TAG "DEL"
      COUNT TO nDel
      nCnt := RecCount()
   RECOVER USING  oError
      ?E "dbf_open_temp_and_count set order to tag DEL ", oError:Description
      SET DELETED ON
      COUNT TO nCnt
      nDel := 0
   END SEQUENCE

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
