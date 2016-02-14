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

STATIC nSlogova := 0

FUNCTION create_index( cImeInd, xKljuc, cAlias, lSilent )

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
   LOCAL lPostoji
   LOCAL _err, _msg

   PRIVATE cTag
   PRIVATE cKljuciz
   PRIVATE cFilter

   IF lSilent == nil
      lSilent := .F.
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

   cAlias := FILEBASE( cAlias )

   _a_dbf_rec := get_a_dbf_rec( cAlias, .T. )
   _wa := _a_dbf_rec[ "wa" ]


   FOR EACH _tag in { cTag, "DEL" }

      cImeDbf := f18_ime_dbf( cAlias )
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

      lPostoji := .T.
      SELECT ( _wa )
      _dbf := f18_ime_dbf( cAlias )

      BEGIN SEQUENCE WITH { |err| Break( err ) }

         dbUseArea( .F., DBFENGINE, _dbf, NIL, .T., .F. )

      RECOVER USING _err

         _msg := "create_index ERR-CI: " + _err:description + ": tbl:" + cAlias + " se ne moze otvoriti ?!"
         log_write( _msg, 2 )
         ?E _msg

         // _err:GenCode = 23
         IF _err:description == "Read error"
            _force_erase := .T.
         ENDIF

         // kada imamo pokusaj duplog otvaranja onda je
         // _err:GenCode = 21
         // _err:description = "Open error"
         ferase_dbf( cAlias, _force_erase )

         QUIT_1

      END SEQUENCE


      BEGIN SEQUENCE WITH { | err | Break( err ) }
         IF File( ImeDbfCdx( _dbf ) ) // open index
            dbSetIndex( ImeDbfCdx( _dbf ) )
         ENDIF
      RECOVER USING _err

         FErase( ImeDbfCdx( _dbf ) ) // ostecen index brisati
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
         lPostoji := .F.
      ENDIF

      IF !lPostoji
         RETURN .F.
      ENDIF

      IF !File( cImeCdx ) .OR. nOrder == 0 .OR. AllTrim( Upper( cOrdKey ) ) <> AllTrim( Upper( cKljuc ) )

         SELECT( _wa )
         my_use_temp( cAlias, f18_ime_dbf( cAlias) , .F. , .T. ) // my_use_temp( cAlias, table, new_area, excl )

         IF !lSilent
            info_tab( "DBF: " + cImeDbf + ", Kreiram index-tag :" + cImeInd + "#" + ExFileName( cImeCdx ) )
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

         // provjeriti indeksiranje na nepostojecim poljima ID_J, _M1_
         IF  !( Left( cTag, 4 ) == "ID_J" .AND. FieldPos( "ID_J" ) == 0 ) .AND. !( cTag == "_M1_" .AND. FieldPos( "_M1_" ) == 0 )

            cImeCdx := StrTran( cImeCdx, "." + INDEXEXT, "" )

            log_write( "index on " + cKljucIz + " / " + cTag + " / " + cImeCdx + " FILTER: " + iif( cFilter != NIL, cFilter, "-" ) + " / alias=" + cAlias + " / used() = " + hb_ValToStr( Used() ), 5 )
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

         USE

      ENDIF

   NEXT

   CLOSE ALL

   RETURN .T.
