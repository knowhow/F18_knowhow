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


FUNCTION ld_naziv_mjeseca( nMjesec, nGodina, lShort, lGodina )

   LOCAL aVrati := { "Januar", "Februar", "Mart", "April", "Maj", "Juni", "Juli", ;
      "Avgust", "Septembar", "Oktobar", "Novembar", "Decembar", "UKUPNO" }
   LOCAL cTmp

   IF lShort == nil
      lShort := .F.
   ENDIF
   IF lGodina == nil
      lGodina := .T.
   ENDIF

   IF nGodina == nil
      nGodina := 0
   ENDIF

   IF ( nMjesec > 0 .AND. nMjesec < 14 )

      cTmp := aVrati[ nMjesec ]

      IF lShort == .T.
         cTmp := PadR( cTmp, 3 )
      ENDIF

      IF nGodina > 0 .AND. lGodina == .T.
         cTmp := cTmp + " " + AllTrim( Str( nGodina ) )
      ENDIF

      RETURN cTmp

   ELSE
      RETURN ""
   ENDIF

   RETURN



STATIC FUNCTION TekRec2()
   nSlog++
   @ m_x + 1, m_y + 2 SAY PadC( AllTrim( Str( nSlog ) ) + "/" + AllTrim( Str( nUkupno ) ), 20 )
   @ m_x + 2, m_y + 2 SAY "Obuhvaceno: " + Str( 0 )

   RETURN ( NIL )


FUNCTION ImaUOps( cOStan, cORada )

   LOCAL lVrati := .F.

   IF ( Empty( cOStan ) .OR. Ocitaj( F_RADN, _FIELD->IDRADN, "IDOPSST" ) == cOStan ) .AND. ;
         ( Empty( cORada ) .OR. Ocitaj( F_RADN, _FIELD->IDRADN, "IDOPSRAD" ) == cORada )
      lVrati := .T.
   ENDIF

   RETURN lVrati




STATIC FUNCTION _create_mtemp()

   LOCAL nI, _struct
   LOCAL _table := "mtemp"
   LOCAL _ret := .T.

   // pobrisi tabelu
   IF File( my_home() + _table + ".dbf" )
      FErase( my_home() + _table + ".dbf" )
   ENDIF

   _struct := LD->( dbStruct() )

   // ovdje cemo sva numericka polja prosiriti za 4 mjesta
   // (izuzeci su polja GODINA i MJESEC)

   FOR nI := 1 TO Len( _struct )
      IF _struct[ nI, 2 ] == "N" .AND. !( Upper( AllTrim( _struct[ nI, 1 ] ) ) $ "GODINA#MJESEC" )
         _struct[ nI, 3 ] += 4
      ENDIF
   NEXT

   dbCreate( my_home() + _table + ".dbf", _struct )

   IF !File( my_home() + _table + ".dbf" )
      MsgBeep( "Ne postoji " + _table + ".dbf !!!" )
      _ret := .F.
   ENDIF

   RETURN _ret


FUNCTION ld_specifikacija_po_mjesecima()

   gnLMarg := 0
   gTabela := 1
   gOstr := "N"
   cIdRj := gLDRadnaJedinica
   cGodina := gGodina
   cIdRadn := Space( 6 )
   cSvaPrim := "S"
   qqOstPrim := ""
   cSamoAktivna := "D"

   O_LD

   IF !_create_mtemp()
      RETURN
   ENDIF

   my_close_all_dbf()

   o_ld_rj()
   O_STRSPR
   O_OPS
   O_RADN
   O_LD

   cIdRadn := fetch_metric( "ld_spec_po_rasponu_id_radnik", my_user(), cIdRadn )
   cSvaPrim := fetch_metric( "ld_spec_po_rasponu_sva_primanja", my_user(), cSvaPrim )
   qqOstPrim := fetch_metric( "ld_spec_po_rasponu_ostala_primanja", my_user(), qqOstPrim )
   cSamoAktivna := fetch_metric( "ld_spec_po_rasponu_samo_aktivna", my_user(), cSamoAktivna )

   qqOstPrim := PadR( qqOstPrim, 100 )

   cPrikKolUk := "D"

   Box(, 7, 77 )

   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno sve): "  GET cIdRJ VALID Empty( cIdRj ) .OR. P_LD_RJ( @cIdRj )
   @ m_x + 2, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 3, m_y + 2 SAY "Radnik (prazno-svi radnici): "  GET  cIdRadn  VALID Empty( cIdRadn ) .OR. P_Radn( @cIdRadn )
   @ m_x + 4, m_y + 2 SAY "Prikazati primanja (N-neto,V-van neta,S-sva primanja,0-nista)" GET cSvaPrim PICT "@!" VALID cSvaPrim $ "NVS0"
   @ m_x + 5, m_y + 2 SAY "Ostala primanja za prikaz (navesti sifre npr. 25;26;27;):" GET qqOstPrim PICT "@S15"
   @ m_x + 6, m_y + 2 SAY "Prikazati samo aktivna primanja ? (D/N)" GET cSamoAktivna PICT "@!" VALID cSamoAktivna $ "DN"
   @ m_x + 7, m_y + 2 SAY "Prikazati kolonu 'ukupno' ? (D/N)" GET cPrikKolUk PICT "@!" VALID cPrikKolUk $ "DN"

   READ
   ESC_BCR

   BoxC()

   qqOstPrim := Trim( qqOstPrim )

   set_metric( "ld_spec_po_rasponu_id_radnik", my_user(), cIdRadn )
   set_metric( "ld_spec_po_rasponu_sva_primanja", my_user(), cSvaPrim )
   set_metric( "ld_spec_po_rasponu_ostala_primanja", my_user(), qqOstPrim )
   set_metric( "ld_spec_po_rasponu_samo_aktivna", my_user(), cSamoAktivna )

   SELECT ( F_TMP_1 )
   my_use_temp( "MTEMP", my_home() + "mtemp" )

   o_tippr()

   SELECT LD

   PRIVATE cFilt1 := "GODINA==" + dbf_quote( cGodina ) + ;
      IF( Empty( cIdRJ ), "", ".and.IDRJ==" + dbf_quote( cIdRJ ) ) + ;
      IF( Empty( cIdRadn ), "", ".and.IDRADN==" + dbf_quote( cIdRadn ) )

   SET FILTER TO &cFilt1
   SET ORDER TO TAG "2"
   GO TOP

   DO WHILE !Eof()
      cMjesec := mjesec
      DO WHILE !Eof() .AND. cMjesec == mjesec
         SELECT MTEMP
         IF MTEMP->mjesec != cMjesec
            APPEND BLANK
            REPLACE mjesec WITH cMjesec
         ENDIF
         FOR i := 1 TO cLDPolja
            cSTP := PadL( AllTrim( Str( i ) ), 2, "0" )
            IF cSvaPrim != "S" .AND. !( cSTP $ qqOstPrim )
               SELECT TIPPR; HSEEK cSTP; SELECT MTEMP
               IF cSvaPrim == "N" .AND. TIPPR->uneto == "N" .OR. ;
                     cSvaPrim == "V" .AND. TIPPR->uneto == "D" .OR. ;
                     cSvaPrim == "0"
                  LOOP
               ENDIF
            ENDIF
            cNPPI := "I" + cSTP
            cNPPS := "S" + cSTP
            nFPosI := FieldPos( cNPPI )
            nFPosS := FieldPos( cNPPS )
            IF nFPosI > 0
               FieldPut( nFPosI, FieldGet( nFPosI ) + LD->( FieldGet( nFPosI ) ) )
               IF ! ( lViseObr .AND. LD->obr <> "1" ) // samo sati iz 1.obracuna
                  FieldPut( nFPosS, FieldGet( nFPosS ) + LD->( FieldGet( nFPosS ) ) )
               ENDIF
            ELSE
               EXIT
            ENDIF
         NEXT
         SELECT LD
         SKIP 1
      ENDDO
   ENDDO

   nSum := {}
   aKol := {}

   nKol := 1
   nRed := 0
   nKorekcija := 0

   nPicISUk := IF( cPrikKolUk == "D", 9, 10 )  // ako nema kolone ukupno mo�e i 10
   nPicSDec := Decimala( gPicS )
   nPicIDec := Decimala( gPicI )

   NUK := IF( cPrikKolUk == "D", 13, 12 )   // ukupno kolona za iznose

   FOR i := 1 TO cLDPolja

      cSTP := PadL( AllTrim( Str( i ) ), 2, "0" )

      cNPPI := "I" + cSTP
      cNPPS := "S" + cSTP

      SELECT TIPPR; HSEEK cSTP; cAktivno := aktivan
      SELECT LD

      IF FieldPos( cNPPI ) > 0

         IF ( cSamoAktivna == "N" .OR. Upper( cAktivno ) == "D" ) .AND. ;
               ( cSvaPrim == "S" .OR. cSTP $ qqOstPrim .OR. ;
               cSvaPrim == "N" .AND. TIPPR->uneto == "D" .OR. ;
               cSvaPrim == "V" .AND. TIPPR->uneto == "N" )

            cNPrim := "{|| '" + cSTP + "-" + ;
               TIPPR->naz + "'}"

            AAdd( aKol, { IF( ( i - nKorekcija ) == 1, "TIP PRIMANJA", "" ), &cNPrim., .F., "C", 25, 0, 2 * ( i - nKorekcija ) -1, 1 } )

            FOR j := 1 TO NUK

               cPomMI := "nSum[" + AllTrim( Str( i - nKorekcija ) ) + "," + AllTrim( Str( j ) ) + ",1]"
               cPomMS := "nSum[" + AllTrim( Str( i - nKorekcija ) ) + "," + AllTrim( Str( j ) ) + ",2]"

               AAdd( aKol, { IF( i - nKorekcija == 1, ld_naziv_mjeseca( j ), "" ), {|| &cPomMI. }, .F., "N", nPicISUk + IF( j > 12, 1, 0 ), nPicIDec, 2 * ( i - nKorekcija ) -1, j + 1 } )
               AAdd( aKol, { IF( i - nKorekcija == 1, "IZNOS/SATI", "" ), {|| &cPomMS. }, .F., "N", nPicISUk + IF( j > 12, 1, 0 ), nPicSDec, 2 * ( i - nKorekcija ), j + 1 } )

            NEXT

         ELSE

            nKorekcija += 1

         ENDIF

      ELSE
         EXIT
      ENDIF

   NEXT

   AAdd( aKol, { "", {|| REPL( "=", 25 ) }, .F., "C", 25, 0, 2 * ( i - nKorekcija ) -1, 1 } )
   AAdd( aKol, { "", {|| "U K U P N O"    }, .F., "C", 25, 0, 2 * ( i - nKorekcija ), 1 } )
   FOR j := 1 TO NUK
      cPomMI := "nSum[" + AllTrim( Str( i - nKorekcija ) ) + "," + AllTrim( Str( j ) ) + ",1]"
      cPomMS := "nSum[" + AllTrim( Str( i - nKorekcija ) ) + "," + AllTrim( Str( j ) ) + ",2]"

      AAdd( aKol, { "", {|| &cPomMI. }, .F., "N", nPicISUk + IF( j > 12, 1, 0 ), nPicIDec, 2 * ( i - nKorekcija ), j + 1 } )
      AAdd( aKol, { "", {|| &cPomMS. }, .F., "N", nPicISUk + IF( j > 12, 1, 0 ), nPicSDec, 2 * ( i - nKorekcija ) + 1, j + 1 } )
   NEXT

   nSumLen := i - 1 -nKorekcija + 1
   nSum := Array( nSumLen, NUK, 2 )
   FOR k := 1 TO nSumLen
      FOR j := 1 TO NUK
         FOR l := 1 TO 2
            nSum[ k, j, l ] := 0
         NEXT
      NEXT
   NEXT

   SELECT MTEMP
   GO TOP

   START PRINT CRET

   P_12CPI

   ?? Space( gnLMarg ); ?? _l( "LD: Izvjestaj na dan" ), Date()
   ? Space( gnLMarg ); IspisFirme( "" )
   ? Space( gnLMarg ); ?? _l( "RJ:" ) + Space( 1 ); B_ON; ?? IF( Empty( cIdRJ ), "SVE", cIdRJ ); B_OFF
   ?? Space( 2 ) + _l( "GODINA: " ); B_ON; ?? cGodina; B_OFF
   ? _l( "RADNIK: " )
   IF Empty( cIdRadn )
      ?? "SVI"
   ELSE
      SELECT ( F_RADN ); HSEEK cIdRadn
      SELECT ( F_STRSPR ); HSEEK RADN->idstrspr
      SELECT ( F_OPS ); HSEEK RADN->idopsst; cOStan := naz
      HSEEK RADN->idopsrad
      SELECT ( F_RADN )
      B_ON; ?? cIdRadn + "-" + Trim( naz ) + ' (' + Trim( imerod ) + ') ' + ime; B_OFF
      ? _l( "Br.knjiz: " ); B_ON; ?? brknjiz; B_OFF
      ?? _l( "  Mat.br: " ); B_ON; ?? matbr; B_OFF
      ?? _l( "  R.mjesto: " ); B_ON; ?? rmjesto; B_OFF

      ? _l( "Min.rad: " ); B_ON; ?? kminrad; B_OFF
      ?? _l( "  Str.spr: " ); B_ON; ?? STRSPR->naz; B_OFF
      ?? _l( "  Opst.stan: " ); B_ON; ?? cOStan; B_OFF

      ? _l( "Opst.rada: " ); B_ON; ??U OPS->naz; B_OFF
      ?? _l( "  Dat.zasn.rad.odnosa: " ); B_ON; ?? datod; B_OFF
      ?? _l( "  Pol: " ); B_ON; ?? pol; B_OFF
      SELECT MTEMP
   ENDIF

   print_lista_2( aKol, {|| FSvaki3() },, gTabela,, ;
      , _l( "Specifikacija primanja po mjesecima" ), ;
      {|| FFor3() }, IF( gOstr == "D",, -1 ),,,,,, .F. )

   SELECT ld

   my_close_all_dbf()

   FF
   ENDPRINT

   RETURN


STATIC FUNCTION FFor3()

   LOCAL nArr := Select()

   DO WHILE !Eof()
      nKorekcija := 0
      FOR i := 1 TO cLDPolja
         cSTP := PadL( AllTrim( Str( i ) ), 2, "0" )
         cNPPI := "I" + cSTP
         cNPPS := "S" + cSTP
         SELECT TIPPR; HSEEK cSTP; cAktivno := aktivan
         SELECT ( nArr )
         nFPosI := FieldPos( cNPPI )
         nFPosS := FieldPos( cNPPS )
         IF nFPosI > 0
            IF ( cSamoAktivna == "N" .OR. Upper( cAktivno ) == "D" ) .AND. ;
                  ( cSvaPrim == "S" .OR. cSTP $ qqOstPrim .OR. ;
                  cSvaPrim == "N" .AND. TIPPR->uneto == "D" .OR. ;
                  cSvaPrim == "V" .AND. TIPPR->uneto == "N" )
               nSum[ i - nKorekcija, mjesec, 1 ] := FieldGet( nFPosI )
               nSum[ nSumLen, mjesec, 1 ] += FieldGet( nFPosI )
               nSum[ i - nKorekcija, mjesec, 2 ] := FieldGet( nFPosS )
               nSum[ nSumLen, mjesec, 2 ] += FieldGet( nFPosS )

               IF NUK > 12
                  // kolona 13.mjeseca tj."ukupno" iznos
                  nSum[ i - nKorekcija, NUK, 1 ] += FieldGet( nFPosI )
                  // red ukupno kolone 13.mjeseca tj."sveukupno" iznos
                  nSum[ nSumLen, NUK, 1 ] += FieldGet( nFPosI )
                  // kolona 13.mjeseca tj."ukupno" sati
                  nSum[ i - nKorekcija, NUK, 2 ] += FieldGet( nFPosS )
                  // red ukupno kolone 13.mjeseca tj."sveukupno" sati
                  nSum[ nSumLen, NUK, 2 ] += FieldGet( nFPosS )
               ENDIF
            ELSE
               nKorekcija += 1
            ENDIF
         ELSE
            EXIT
         ENDIF
      NEXT
      SKIP 1
   ENDDO

   RETURN .T.


STATIC FUNCTION FSvaki3()
   RETURN



FUNCTION Izrezi( cPoc, nIza, cOstObav )

   LOCAL cVrati := "", nPoz := 0

   DO WHILE ( nPoz := At( cPoc, cOstObav ) ) > 0
      cVrati := cVrati + SubStr( cOstObav, nPoz + Len( cPoc ), nIza ) + ";"
      cOstObav := Stuff( cOstObav, nPoz, Len( cPoc ) + nIza, "" )
      cOstObav := StrTran( cOstObav, ";;", ";" )
   ENDDO

   RETURN cVrati


STATIC FUNCTION FormNum1( nIznos, nDuz, pici )

   LOCAL cVrati

   cVrati := Transform( nIznos, pici )
   cVrati := StrTran( cVrati, ".", ":" )
   cVrati := StrTran( cVrati, ",", "." )
   cVrati := StrTran( cVrati, ":", "," )
   cVrati := AllTrim( cVrati )
   cVrati := IF( Len( cVrati ) > nDuz, REPL( "*", nDuz ), PadL( cVrati, nDuz ) )

   RETURN cVrati


FUNCTION FormNum2( nIznos, nDuz, pici )
   RETURN AllTrim( formnum1( nIznos, nDuz, pici ) )




FUNCTION OSpecif()

   o_dopr()
   o_por()
   O_PAROBR
   O_KBENEF
   O_VPOSLA
   o_ld_rj()
   O_RADN
   O_PARAMS
   O_LD
   O_OPS

   RETURN
