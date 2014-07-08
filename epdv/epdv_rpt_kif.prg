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


#include "epdv.ch"

STATIC aHeader := {}
STATIC aZaglLen := {}
STATIC aZagl := {}

STATIC lSvakaHeader := .T.

// tekuca linija reporta
STATIC nCurrLine := 0

STATIC cRptNaziv := "Izvještaj KIF na dan "

STATIC cTbl := "kif"

STATIC cTar := ""
STATIC cPart := ""

STATIC cRptBrDok := 0

// -------------------------------------------
// kif izvjestaj
// -------------------------------------------
FUNCTION rpt_kif( nBrDok, cIdTarifa )

   LOCAL cHeader
   LOCAL cPom
   LOCAL cPom11
   LOCAL cPom12
   LOCAL cPom21
   LOCAL cPom22
   LOCAL nLenIzn
   LOCAL _export := "N"

   // 1 - red.br / ili br.dok
   // 2 - br.dok / ili r.br
   // 3 - dat dok
   // 4 - tarifna kategorija
   // 5 - kupac (naziv + id)
   // 6 - brdok kupca
   // 7 - opis
   // 8 - izn bez pdv
   // 9 - izn  pdv
   // 10 - izn sa pdv


   nLenIzn := Len( PIC_IZN() )
   aZaglLen := { 8, 8, 8, 8, 65, 12, 80,  nLenIzn, nLenIzn, nLenIzn }


   IF nBrDok == nil
      // izvjestaj se ne pravi za jedan dokument
      nBrDok := -999
	
   ENDIF
   nRptBrDok := nBrDok


   IF cIdTarifa == nil
      // sve tarife
      cTar := ""
   ELSE
      cTar := cIdTarifa
   ENDIF
   cPart := ""


   aDInt := rpt_d_interval ( Date() )

   dDate := Date()

   dDatOd := aDInt[ 1 ]
   dDatDo := aDInt[ 2 ]


   IF ( nBrDok == -999 )

      // treba zadati parametre izvjestaja

      cTar := PadR( cTar, 6 )
      cPart := PadR( cPart, 6 )

      nX := 1
      Box(, 11, 60 )

      // izvjestaj za period
      @ m_x + nX, m_y + 2 SAY "Period"
      nX++

      @ m_x + nX, m_y + 2 SAY "od " GET dDatOd
      @ m_x + nX, Col() + 2 SAY "do " GET dDatDo

      nX += 2

      @ m_x + nX, m_y + 2 SAY "Tarifa (prazno svi)  ? " GET cTar ;
         VALID {|| Empty( cTar ) .OR. P_Tarifa( @cTar ) } ;
         PICT "@!"
      nX += 1

      @ m_x + nX, m_y + 2 SAY "Partner (prazno svi) ? " GET cPart ;
         VALID {|| Empty( cPart ) .OR. P_Partneri( @cPart ) } ;
         PICT "@!"

      nX += 2

      @ m_x + nX, m_y + 2 SAY8 "Eksport izvještaja u DBF (D/N) ?" GET _export ;
         VALID _export $ "DN" PICT "@!"


      nX += 2

      @ m_x + nX, m_y + 2 SAY Replicate( "-", 30 )
      nX++

      READ
      BoxC()

      IF LastKey() == K_ESC
         my_close_all_dbf()
         RETURN
      ENDIF

   ENDIF

   aHeader := {}

   IF ( nBrDok == -999 )
      cHeader :=  cRptNaziv +  DToC( dDate ) + ", za period :" + DToC( dDatOd ) + "-" + DToC( dDatDo )

   ELSE
      IF nBrDok == 0
         cPom := "PRIPREMA"
      ELSE
         cPom := Str( nBrDok, 6, 0 )
      ENDIF
      cHeader :=  "Dokument KIF: " + cPom + ", na dan " + DToC( Date() )
   ENDIF

   AAdd( aHeader, "Preduzeće: " + my_firma() )


   AAdd( aHeader, cHeader )

   IF !Empty( cTar )
      cPom := "Prikaz kategorije : " + s_tarifa( cTar )
      AAdd( aHeader, cPom )
   ENDIF


   aZagl := {}

   cPom1 := ""
   cPom2 := ""

   IF ( nBrDok == -999 )
      // kif za period - globalni redni broj je prva stavka
      cPom11 := "Red."
      cPom12 := "br."

      cPom21 := "Broj"
      cPom22 := "dok"
   ELSE
      // prikaz jednog dokumenta
      // prvo brojdokumenta
      cPom11 := "Broj"
      cPom12 := "dok"
	
      // pa redni broj
      cPom21 := "Red"
      cPom22 := "br."

   ENDIF

   AAdd( aZagl, { cPom11,  cPom21, "Datum", "Tar.",  "Kupac", "Broj",  "Opis",  "iznos", "iznos",    "iznos" } )
   AAdd( aZagl, { cPom12,  cPom22,  "",     "kat.",      "(naziv, PDV / identifikacijski broj)",      "RN",     "",    "bez PDV", "PDV", "sa PDV" } )
   AAdd( aZagl, { "(1)",   "(2)",  "(3)",   "(4)",   "(5)",  "(6)",     "(7)", "(8)", "(9)", "(10) = (8+9)" } )


   fill_rpt( nBrDok )

   my_close_all_dbf()

   IF _export == "D"

      _file := my_home() + "epdv_r_kif.dbf"

#ifdef __PLATFORM__WINDOWS
      _file := '"' + _file + '"'
#endif

      f18_open_document( _file )

   ELSE
      show_rpt(  .F.,  .F. )
   ENDIF

   RETURN




STATIC FUNCTION get_r_fields( aArr )

   AAdd( aArr, { "r_br",   "N",  8, 0 } )
   AAdd( aArr, { "br_dok",   "N",  6, 0 } )
   AAdd( aArr, { "datum",   "D",  8, 0 } )

   AAdd( aArr, { "id_tar",   "C",  6, 0 } )
   AAdd( aArr, { "id_part",   "C",  6, 0 } )

   AAdd( aArr, { "kup_rn",   "C",  12, 0 } )
   AAdd( aArr, { "kup_naz",   "C",  200, 0 } )
   AAdd( aArr, { "opis",   "C",  80, 0 } )

   AAdd( aArr, { "i_b_pdv",   "N",  18, 2 } )
   AAdd( aArr, { "i_pdv",   "N",  18, 2 } )
   AAdd( aArr, { "i_uk",   "N",  18, 2 } )

   RETURN

STATIC FUNCTION cre_r_tbl()

   LOCAL aArr := {}

   my_close_all_dbf()

   FErase ( my_home() + "epdv_r_" +  cTbl + ".cdx" )
   FErase ( my_home() + "epdv_r_" +  cTbl + ".dbf" )

   get_r_fields( @aArr )

   // kreiraj tabelu
   dbcreate2( my_home() + "epdv_r_" + cTbl + ".dbf", aArr )

   // kreiraj indexe
   CREATE_INDEX( "br_dok", "br_dok", "epdv_r_" +  cTbl, .T. )

   RETURN

STATIC FUNCTION fill_rpt( nBrDok )

   LOCAL nIzArea
   LOCAL nBPdv
   LOCAL nPdv
   LOCAL nRbr
   LOCAL dDatum
   LOCAL cKupRn
   LOCAL cKupNaz
   LOCAL cIdTar
   LOCAL cOpis
   LOCAL cIdPart

   cre_r_tbl()

   O_R_KIF

   IF ( nBrDok == 0 )
	
      nIzArea := F_P_KIF
	
      SELECT ( F_P_KIF )
      IF !Used()
         O_P_KIF
      ENDIF
      SET ORDER TO TAG "br_dok"

   ELSE

      nIzArea := F_KIF
	
      SELECT ( F_KIF )
      IF !Used()
         O_KIF
      ENDIF
      SET ORDER TO TAG "g_r_br"


   ENDIF

   SELECT ( nIzArea )

   PRIVATE cFilter := ""

   IF ( nBrdok == - 999 )
      cFilter := cm2str( dDatOd ) + " <= datum .and. " + cm2str( dDatDo ) + ">= datum"
   ENDIF

   IF !Empty( cTar )
      IF !Empty( cFilter )
         cFilter += " .and. "
      ENDIF
      cFilter += "id_tar == " + cm2str( cTar )
   ENDIF

   IF !Empty( cPart )
      IF !Empty( cFilter )
         cFilter += " .and. "
      ENDIF
      cFilter += "id_part == " + cm2str( cPart )
   ENDIF

   SET FILTER TO &cFilter

   GO TOP


   Box(, 3, 60 )

   nCount := 0


   DO WHILE !Eof()

      ++nCount


      @ m_x + 2, m_y + 2 SAY Str( nCount, 6, 0 )

      nBrDok := br_dok
      nBPdv := i_b_pdv
      nPdv := i_pdv

      IF ( nRptBrDok == -999 )
         // za vise dokumenata
         nRbr := g_r_br
      ELSE
         // za jedan dokument
         nRbr := r_br
      ENDIF

      dDatum := datum
      cKupRn := src_br_2
      cKupNaz := s_partner( id_part )
      cIdTar := id_tar
      cOpis := opis
      cIdPart := id_part

      SELECT r_kif
      APPEND BLANK


      REPLACE br_dok WITH nBrDok
      REPLACE r_br WITH nRbr
      REPLACE id_tar WITH cIdTar
      REPLACE id_part WITH cIdPart
      REPLACE datum WITH dDatum
      REPLACE kup_rn WITH cKupRn
      REPLACE kup_naz WITH cKupNaz
      REPLACE opis WITH cOpis

      REPLACE i_b_pdv WITH nBPdv
      REPLACE i_pdv WITH nPdv
      REPLACE i_uk WITH ( i_b_pdv + i_pdv )

      SELECT ( nIzArea )

      SKIP

   ENDDO

   BoxC()

   SELECT ( nIzArea )
   SET FILTER TO

   RETURN


STATIC FUNCTION show_rpt()

   LOCAL nLenUk
   LOCAL nPom1
   LOCAL nPom2
   LOCAL aKupacNaziv

   nCurrLine := 0

   START PRINT CRET

   nPageLimit := 40
   ? "#%LANDS#"

   P_COND
   nRow := 0

   r_zagl()

   O_R_KIF
   SELECT r_kif
   SET ORDER TO TAG "1"
   GO TOP
   nRbr := 0

   nBPdv := 0
   nPdv :=  0
   DO WHILE !Eof()

      ++ nCurrLine

      IF nRptBrDok == -999
         nPom1 := r_br
         nPom2 := br_dok
      ELSE
         nPom1 := br_dok
         nPom2 := r_br
      ENDIF

      aKupacNaziv := SjeciStr( kup_naz, aZaglLen[5] )
 
      ?
      // 1. broj dokumenta
      ?? Transform( nPom1, Replicate( "9", aZaglLen[ 1 ] ) )
      ?? " "

      // 2. r.br
      ?? Transform( nPom2, Replicate( "9", aZaglLen[ 2 ] ) )
      ?? " "


      // 3. datum
      ?? PadR( datum, aZaglLen[ 3 ] )
      ?? " "

      // 4. tarifa
      ?? PadR( id_tar, aZaglLen[ 4 ] )
      ?? " "

      nPos := pcol()

      // 5. kupac naziv
      ?? PadR( aKupacNaziv[1], aZaglLen[ 5 ] )
      ?? " "

      // 6. dobavljac rn
      ?? PadR( kup_rn, aZaglLen[ 6 ] )
      ?? " "

      // 7. opis
      ?? PadR( opis, aZaglLen[ 7 ] )
      ?? " "

      // 8. bez pdv
      ?? Transform( i_b_pdv,  PIC_IZN() )
      ?? " "

      // 9. pdv
      ?? Transform( i_pdv,  PIC_IZN() )
      ?? " "

      // 10. sa pdv
      ?? Transform( i_b_pdv + i_pdv,  PIC_IZN() )
      ?? " "

      IF LEN( aKupacNaziv ) > 1
         nCurrLine := nCurrLine + 1
         epdv_rpt_kuf_kif_nova_stranica( @nCurrLine, nPageLimit, lSvakaHeader )
         ?
         @ prow(), nPos SAY aKupacNaziv[2]
      ENDIF

      nBPdv += i_b_pdv
      nPdv += i_pdv

      epdv_rpt_kuf_kif_nova_stranica( @nCurrLine, nPageLimit, lSvakaHeader )

      SKIP

   ENDDO

   nCurrLine := nCurrLine + 3

   epdv_rpt_kuf_kif_nova_stranica( @nCurrLine, nPageLimit, lSvakaHeader )

   r_linija()
   ?
   cPom := "   U K U P N O :  "

   nLenUk := 0
   FOR i := 1 TO 7
      nLenUk += aZaglLen[ i ] + 1
   NEXT
   nLenUk -= 1

   ?? PadR( cPom, nLenUk )
   ?? " "
   ?? Transform( nBPdv, PIC_IZN() )
   ?? " "

   ?? Transform( nPdv, PIC_IZN() )
   ?? " "

   ?? Transform( nBPdv + nPdv, PIC_IZN() )

   r_linija()


   FF
   END PRINT

   RETURN


STATIC FUNCTION r_zagl()

   P_COND
   B_ON
   FOR i := 1 TO Len( aHeader )
      ?U aHeader[ i ]
      ++nCurrLine
   NEXT
   B_OFF

   P_COND2

   r_linija()

   FOR i := 1 TO Len( aZagl )
      ++nCurrLine
      ?
      FOR nCol := 1 TO Len( aZaglLen )
         // mergirana kolona ovako izgleda
         // "#3 Zauzimam tri kolone"
         IF Left( aZagl[ i, nCol ], 1 ) = "#"
	
            nMergirano := Val( SubStr( aZagl[ i, nCol ], 2, 1 ) )
            cPom := SubStr( aZagl[ i, nCol ], 3, Len( aZagl[ i, nCol ] ) -2 )
            nMrgWidth := 0
            FOR nMrg := 1 TO nMergirano
               nMrgWidth += aZaglLen[ nCol + nMrg - 1 ]
               nMrgWidth ++
            NEXT
            ??U PadC( cPom, nMrgWidth )
            ?? " "
            nCol += ( nMergirano - 1 )
         ELSE
            ??U PadC( aZagl[ i, nCol ], aZaglLen[ nCol ] )
            ?? " "
         ENDIF
      NEXT
   NEXT
   r_linija()

   RETURN


STATIC FUNCTION r_linija()

   ++nCurrLine
   ?
   FOR i = 1 TO Len( aZaglLen )
      ?? PadR( "-", aZaglLen[ i ], "-" )
      ?? " "
   NEXT

   RETURN
