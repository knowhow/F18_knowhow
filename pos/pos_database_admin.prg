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



FUNCTION NaprPom( aDbf, cPom )

   IF cPom == nil
      cPom := "POM"
   ENDIF

   cPomDBF := my_home() + "pom.dbf"
   cPomCDX := my_home() + "pom.cdx"

   IF File( cPomDBF )
      FErase( cPomDBF )
   ENDIF

   IF File( cPomCDX )
      FErase( cPomCDX )
   ENDIF

   IF File( Upper( cPomDBF ) )
      FErase( Upper( cPomDBF ) )
   ENDIF

   IF File ( Upper( cPomCDX ) )
      FErase( Upper( cPomCDX ) )
   ENDIF

   // kreiraj tabelu pom.dbf
   dbCreate( my_home() + "pom.dbf", aDbf )

   RETURN



FUNCTION ChkTblPromVp()

   LOCAL cTbl

   RETURN



FUNCTION CrePosISifData()

   LOCAL _rec

   O_STRAD

   IF ( RECCOUNT2() == 0 )

      MsgO( "Kreiram ini STRAD" )

      f18_lock_tables( { "pos_strad" } )
      sql_table_update( nil, "BEGIN" )

      SELECT strad
      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "id" ] := PadR( "0", Len( _rec[ "id" ] ) )
      _rec[ "prioritet" ] := PadR( "0", Len( _rec[ "prioritet" ] ) )
      _rec[ "naz" ] := PadR( "Nivo adm.", Len( _rec[ "naz" ] ) )

      update_rec_server_and_dbf( "pos_strad", _rec, 1, "CONT" )

      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "id" ] := PadR( "1", Len( _rec[ "id" ] ) )
      _rec[ "prioritet" ] := PadR( "1", Len( _rec[ "prioritet" ] ) )
      _rec[ "naz" ] := PadR( "Nivo upr.", Len( _rec[ "naz" ] ) )

      update_rec_server_and_dbf( "pos_strad", _rec, 1, "CONT" )

      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "id" ] := PadR( "3", Len( _rec[ "id" ] ) )
      _rec[ "prioritet" ] := PadR( "3", Len( _rec[ "prioritet" ] ) )
      _rec[ "naz" ] := PadR( "Nivo prod.", Len( _rec[ "naz" ] ) )

      update_rec_server_and_dbf( "pos_strad", _rec, 1, "CONT" )

      f18_free_tables( { "pos_strad" } )
      sql_table_update( nil, "END" )

      MsgC()

   ENDIF

   O_OSOB

   IF ( RECCOUNT2() == 0 )

      MsgO( "Kreiram ini OSOB" )

      SELECT osob

      f18_lock_tables( { "pos_osob" } )
      sql_table_update( nil, "BEGIN" )

      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "id" ] := PadR( "0001", Len( _rec[ "id" ] ) )
      _rec[ "korsif" ] := PadR( CryptSc( PadR( "PARSON", 6 ) ), 6 )
      _rec[ "naz" ] := PadR( "Admin", Len( _rec[ "naz" ] ) )
      _rec[ "status" ] := PadR( "0", Len( _rec[ "status" ] ) )

      update_rec_server_and_dbf( "pos_osob", _rec, 1, "CONT" )

      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "id" ] := PadR( "0010", Len( _rec[ "id" ] ) )
      _rec[ "korsif" ] := PadR( CryptSc( PadR( "P1", 6 ) ), 6 )
      _rec[ "naz" ] := PadR( "Prodavac 1", Len( _rec[ "naz" ] ) )
      _rec[ "status" ] := PadR( "3", Len( _rec[ "status" ] ) )

      update_rec_server_and_dbf( "pos_osob", _rec, 1, "CONT" )

      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "id" ] := PadR( "0011", Len( _rec[ "id" ] ) )
      _rec[ "korsif" ] := PadR( CryptSc( PadR( "P2", 6 ) ), 6 )
      _rec[ "naz" ] := PadR( "Prodavac 2", Len( _rec[ "naz" ] ) )
      _rec[ "status" ] := PadR( "3", Len( _rec[ "status" ] ) )

      update_rec_server_and_dbf( "pos_osob", _rec, 1, "CONT" )

      f18_free_tables( { "pos_osob" } )
      sql_table_update( nil, "END" )

      MsgC()

   ENDIF

   CLOSE ALL

   RETURN
