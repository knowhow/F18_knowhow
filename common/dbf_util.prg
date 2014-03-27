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

#include "fmk.ch"

FUNCTION delete_with_rlock()

   IF my_rlock()
      DELETE
      my_unlock()
      RETURN .T.
   ELSE
      RETURN .F.
   ENDIF

   // --------------------------------------------
   // --------------------------------------------

FUNCTION ferase_dbf( tbl_name, _silent )

   LOCAL _tmp, _odg

   IF _silent == NIL
      _silent := .F.
   ENDIF

   IF !_silent

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


/*!
 @function    NoviID_A
 @abstract    Novi ID - automatski
 @discussion  Za one koji ne pocinju iz pocetak, ID-ovi su dosadasnje sifre
              Program (radi prometnih datoteka) ove sifre ne smije dirati)
              Zato ce se nove sifre davati po kljucu Chr(246)+Chr(246) + sekvencijalni dio
*/
FUNCTION NoviID_A()

   LOCAL cPom, xRet

   PushWA()

   nCount := 1
   DO WHILE .T.

      SET FILTER TO
      // pocisti filter
      SET ORDER TO TAG "ID"
      GO BOTTOM
      IF id > "99"
         SEEK Chr( 246 ) + Chr( 246 ) + Chr( 246 )
         // chr(246) pokusaj
         SKIP -1
         IF id < Chr( 246 ) + Chr( 246 ) + "9"
            cPom :=   Str( Val( SubStr( id, 4 ) ) + nCount, Len( id ) -2 )
            xRet := Chr( 246 ) + Chr( 246 ) + PadL(  cPom, Len( id ) -2,"0" )
         ENDIF
      ELSE
         cPom := Str( Val( id ) + nCount, Len( id ) )
         xRet := cPom
      ENDIF

      ++nCount
      SEEK xRet
      IF !Found()
         EXIT
      ENDIF

      IF nCount > 100
         MsgBeep( "Ne mogu da dodijelim sifru automatski ????" )
         xRet := ""
         EXIT
      ENDIF

   ENDDO

   PopWa()

   RETURN xRet

// -----------------------------
// -----------------------------
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


// ------------------------------------------------------
// open exclusive, open_index - otvoriti index
// ------------------------------------------------------
FUNCTION reopen_shared( dbf_table, open_index )
   RETURN reopen_dbf( .F., dbf_table, open_index )

FUNCTION reopen_exclusive( dbf_table, open_index )
   RETURN reopen_dbf( .T., dbf_table, open_index )

// ----------------------------------------------------
// ----------------------------------------------------
FUNCTION reopen_dbf( excl, dbf_table, open_index )

   LOCAL _a_dbf_rec
   LOCAL _dbf

   IF open_index == NIL
      open_index := .T.
   ENDIF

   _a_dbf_rec  := get_a_dbf_rec( dbf_table )

   SELECT ( _a_dbf_rec[ "wa" ] )
   USE

   _dbf := my_home() + _a_dbf_rec[ "table" ]

   // finalno otvaranje tabele
   SELECT ( _a_dbf_rec[ "wa" ] )
   USE
   dbUseArea( .F., DBFENGINE, _dbf, _a_dbf_rec[ "alias" ], iif( excl, .F., .T. ), .F. )

   IF open_index

      IF File( ImeDbfCdx( _dbf ) )
         dbSetIndex( ImeDbfCDX( _dbf ) )
         RETURN .T.
      ENDIF
   ENDIF

   RETURN .T.

// ------------------------------------------------------
// zap, then open shared, open_index - otvori index
// ------------------------------------------------------
FUNCTION reopen_exclusive_and_zap( dbf_table, open_index )

   LOCAL _a_dbf_rec
   LOCAL _dbf
   LOCAL _idx

   IF open_index == NIL
      open_index := .T.
   ENDIF

   _a_dbf_rec  := get_a_dbf_rec( dbf_table )

   SELECT ( _a_dbf_rec[ "wa" ] )
   USE

   _dbf := my_home() + _a_dbf_rec[ "table" ]
   _idx := ImeDbfCdx( _dbf )

   // otvori ekskluzivno - 5 parametar .t. kada zelimo shared otvaranje
   SET AUTOPEN OFF
   dbUseArea( .F., DBFENGINE, _dbf, _a_dbf_rec[ "alias" ], .F., .F. )
   // kod prvog otvaranja uvijek otvori index da i njega nuliram

   IF File( _idx )
      dbSetIndex( _idx )
   ENDIF

   __dbZap()

   RETURN .T.
