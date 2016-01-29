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

#include "f18.ch"

STATIC OID_ASK := "0"
STATIC nSlogova := 0

FUNCTION create_index( cImeInd, xKljuc, alias, silent )

   LOCAL _force_erase := .F.
   LOCAL bErr
   LOCAL cFulDbf
   LOCAL nH
   LOCAL cImeCDXIz
   LOCAL cImeCDX
   LOCAL nOrder
   LOCAL nPos
   LOCAL cImeDbf
   LOCAL _a_dbf_rec
   LOCAL _wa
   LOCAL _dbf
   LOCAL _tag
   LOCAL cKljuc
   LOCAL _unique := .F.

   PRIVATE cTag
   PRIVATE cKljuciz
   PRIVATE cFilter

   IF silent == nil
      silent := .F.
   ENDIF

   IF ValType( xKljuc ) == "C"
      cKljuc := xKljuc
      cFilter := NIL
   ELSE
      cKljuc := xKljuc[ 1 ]
      cFilter := xKljuc[ 2 ]
      IF Len( xKljuc ) == 3
         _unique := xKljuc[ 3 ]
      ENDIF
   ENDIF

   CLOSE ALL

   alias := FILEBASE( alias )

   _a_dbf_rec := get_a_dbf_rec( alias, .T. )
   _wa := _a_dbf_rec[ "wa" ]


   FOR EACH _tag in { cTag, "DEL" }

      cImeDbf := f18_ime_dbf( alias )
      cImeCdx := ImeDbfCdx( cImeDbf )

      nPom := RAt( SLASH, cImeInd )
      cTag := ""

      cKljucIz := cKljuc

      IF nPom <> 0
         cTag := SubStr( cImeInd, nPom + 1 )
      ELSE
         cTag := cImeInd
      ENDIF


      IF _tag == "DEL"
         cTag    := "DEL"
         cKljuc  := "deleted()"
         cImeInd := cTag
      ENDIF


      fPostoji := .T.

      SELECT ( _wa )

      _dbf := f18_ime_dbf( alias )

      BEGIN SEQUENCE WITH { | err | Break( err ) }

         dbUseArea( .F., DBFENGINE, _dbf, NIL, .T., .F. )

      recover using _err

         _msg := "ERR-CI: " + _err:description + ": tbl:" + alias + " se ne moze otvoriti ?!"
         log_write( _msg, 2 )
         Alert( _msg )

         // _err:GenCode = 23
         IF _err:description == "Read error"
            _force_erase := .T.
         ENDIF

         // kada imamo pokusaj duplog otvaranja onda je
         // _err:GenCode = 21
         // _err:description = "Open error"

         ferase_dbf( alias, _force_erase )

         repair_dbfs()
         QUIT_1

      END SEQUENCE


      // open index
      BEGIN SEQUENCE WITH { | err | Break( err ) }
         IF File( ImeDbfCdx( _dbf ) )
            dbSetIndex( ImeDbfCdx( _dbf ) )
         ENDIF
      recover using _err
         // ostecen index brisi ga
         FErase( ImeDbfCdx( _dbf ) )
      END SEQUENCE

      IF  File( ImeDbfCdx( _dbf, OLD_INDEXEXT ) )
         FErase( ImeDbfCdx( _dbf, OLD_INDEXEXT ) )
      ENDIF


      IF Used()
         nOrder := index_tag_num( cTag )
         cOrdKey := ordKey( cTag )
         SELECT ( _wa )
         USE
      ELSE
         log_write( "create_index: Ne mogu otvoriti " + cImeDbf, 3 )
         fPostoji := .F.
      ENDIF

      IF !fPostoji
         RETURN
      ENDIF

      IF !File( cImeCdx ) .OR. nOrder == 0 .OR. AllTrim( Upper( cOrdKey ) ) <> AllTrim( Upper( cKljuc ) )

         SELECT( _wa )
         my_use_temp( alias, f18_ime_dbf( alias) , .F. , .T. )

         IF !silent
            MsgO( "Baza:" + cImeDbf + ", Kreiram index-tag :" + cImeInd + "#" + ExFileName( cImeCdx ) )
         ENDIF

         log_write( "Kreiram indeks za tabelu " + cImeDbf + ", " + cImeInd, 7 )

         nPom := RAt( SLASH, cImeInd )

         PRIVATE cTag := ""
         PRIVATE cKljuciz := cKljuc

         IF nPom <> 0
            cTag := SubStr( cImeInd, nPom )
         ELSE
            cTag := cImeInd
         ENDIF

         // provjeri indeksiranje na nepostojecim poljima ID_J, _M1_
         IF  !( Left( cTag, 4 ) == "ID_J" .AND. FieldPos( "ID_J" ) == 0 ) .AND. !( cTag == "_M1_" .AND. FieldPos( "_M1_" ) == 0 )

            cImeCdx := StrTran( cImeCdx, "." + INDEXEXT, "" )

            log_write( "index on " + cKljucIz + " / " + cTag + " / " + cImeCdx + " FILTER: " + iif( cFilter != NIL, cFilter, "-" ) + " / alias=" + alias + " / used() = " + hb_ValToStr( Used() ), 5 )
            IF _tag == "DEL"
               INDEX ON Deleted() TAG "DEL" TO ( cImeCdx ) FOR deleted()
            ELSE
               IF cFilter != NIL
                  IF _unique
                     INDEX ON &cKljucIz  TAG ( cTag )  TO ( cImeCdx ) FOR &cFilter UNIQUE
                  ELSE
                     INDEX ON &cKljucIz  TAG ( cTag )  TO ( cImeCdx ) FOR &cFilter
                  ENDIF
               ELSE
                  INDEX ON &cKljucIz  TAG ( cTag )  TO ( cImeCdx )
               ENDIF
            ENDIF
            USE


         ENDIF

         IF !silent
            MsgC()
         ENDIF
         USE

      ENDIF

   NEXT

   CLOSE ALL

   RETURN


FUNCTION IsFreeForReading( cFulDBF, fSilent )

   LOCAL nH

   nH := FOpen( cFulDbf, 2 )  // za citanje i pisanje
   IF FError() <> 0
      Beep( 2 )
      IF !fSilent
         Msg( "Ne mogu otvoriti " + cFulDBF + " - vjerovatno ga neko koristi#" + ;
            "na mrezi. Ponovite operaciju kada ovo rijesite !" )
         RETURN .F.
      ELSE
         cls
         ? "Ne mogu otvoriti", cFulDbf
         Inkey()
      ENDIF
      FClose( nH )
      RETURN .T.
   ENDIF
   FClose( nH )

   RETURN .T.


FUNCTION AddFldBrisano( cImeDbf )

   USE
   SAVE SCREEN TO cScr
   CLS
   Modstru( cImeDbf, "C H C 1 0  FH  C 1 0", .T. )
   Modstru( cImeDbf, "C SEC C 1 0  FSEC C 1 0", .T. )
   Modstru( cImeDbf, "C VAR C 2 0 FVAR C 2 0", .T. )
   Modstru( cImeDbf, "C VAR C 15 0 FVAR C 15 0", .T. )
   Modstru( cImeDbf, "C  V C 15 0  FV C 15 0", .T. )
   Modstru( cImeDbf, "A BRISANO C 1 0", .T. )  // dodaj polje "BRISANO"
   Inkey( 3 )
   RESTORE SCREEN FROM cScr

   SELECT ( F_TMP )
   usex ( cImeDbf )

   RETURN


FUNCTION KZNbaza( aPriv, aKum, aSif, cIz, cU, cSamoId )

   // cSamoId  "1"- konvertuj samo polja koja pocinju sa id
   // "2"- konvertuj samo polja koja ne pocinju sa id
   // "3" ili nil - konvertuj sva polja
   // "B" - konvertuj samo IDRADN polja iz LD-a

   LOCAL i := 0, j := 0, k := 0, aPom := {}, xVar := "", anPolja := {}
   CLOSE ALL
   SET EXCLUSIVE ON
   IF aPriv == nil; aPriv := {}; ENDIF
   IF aKum == nil ; aKum := {} ; ENDIF
   IF aSif == nil ; aSif := {} ; ENDIF
   IF cSamoid == nil; cSamoid := "3"; ENDIF
   PRIVATE cPocStanjeSif
   PRIVATE cKrajnjeStanjeSif
   IF !gAppSrv
      Box( "xx", 1, 50, .F., "Vrsi se konverzija znakova u bazama podataka" )
      @ m_x + 1, m_y + 1 SAY "Konvertujem:"
   ELSE
      ? "Vrsi se konverzija znakova u tabelama"
   ENDIF
   FOR j := 1 TO 3
      DO CASE
      CASE j == 1
         aPom := aPriv
      CASE j == 2
         aPom := aKum
      CASE j == 3
         aPom := aSif
      ENDCASE
      FOR i := 1 TO Len( aPom )
         nDbf := aPom[ i ]
         goModul:oDatabase:obaza( nDbf )
         dbSelectArea ( nDbf )
         IF !gAppSrv
            @ m_x + 1, m_y + 25 SAY Space( 12 )
            @ m_x + 1, m_y + 25 SAY Alias( nDBF )
         ELSE
            ? "Konvertujem: " + Alias( nDBF )
         ENDIF
         IF Used()
            beep( 1 )
            ordSetFocus( 0 )
            GO TOP
            anPolja := {}
            FOR k := 1 TO FCount()
               IF ( cSamoId == "3" ) .OR. ( cSamoId == "1" .AND. Upper( FieldName( k ) ) = "ID" ) .OR. ( cSamoId == "2"  .AND. !( Upper( FieldName( k ) ) = "ID" ) ) .OR. ( cSamoId == "B" .AND. ( ( Upper( FieldName( k ) ) = "IDRADN" ) .OR. ( ( Upper( FieldName( k ) ) = "ID" ) .AND. Alias( nDbf ) == "RADN" ) ) )
                  xVar := FieldGet( k )
                  IF ValType( xVar ) $ "CM"
                     AAdd( anPolja, k )
                  ENDIF
               ENDIF  // csamoid
            NEXT
            DO WHILE !Eof()
               FOR k := 1 TO Len( anPolja )
                  xVar := FieldGet( anPolja[ k ] )
                  FieldPut( anPolja[ k ], StrKZN( xVar, cIz, cU ) )
                  // uzmi za radnika ime i prezime
                  IF ( cSamoId == "B" ) .AND. Upper( FieldName( 1 ) ) = "ID" .AND. Alias( nDbf ) == "RADN"
                     // AADD(aSifRev, {FIELDGET(4)+" "+FIELDGET(5), cPocStanjeSif, cKrajnjeStanjeSif})
                  ENDIF
               NEXT
               SKIP 1
            ENDDO
            USE
         ENDIF
      NEXT
   NEXT
   IF !gAppSrv
      BoxC()
   ENDIF
   SET EXCLUSIVE OFF

   RETURN


FUNCTION MyErrHt( o )

   BREAK o

   RETURN .T.




STATIC FUNCTION Every()
   RETURN
