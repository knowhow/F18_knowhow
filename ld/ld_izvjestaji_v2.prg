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


#include "ld.ch"



FUNCTION TekRec()

   @ m_x + 1, m_y + 2 SAY RecNo()

   RETURN NIL


FUNCTION ObrM4()
   CLOSERET
   RETURN


FUNCTION ld_pregled_primanja_za_period()

   LOCAL nC1 := 20

   cIdRadn := Space( 6 )
   cIdRj := gRj
   cGodina := gGodina
   cObracun := gObracun

   O_LD_RJ
   O_RADN
   O_LD

   PRIVATE cTip := "  "
   cDod := "N"
   cKolona := Space( 20 )
   Box(, 6, 75 )
   cMjesecOd := cMjesecDo := gMjesec
   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec od: "  GET  cmjesecOd  PICT "99"
   @ m_x + 2, Col() + 2 SAY "do" GET cMjesecDO  PICT "99"
   IF lViseObr
      @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY "Tip primanja: "  GET  cTip
   @ m_x + 5, m_y + 2 SAY "Prikaz dodatnu kolonu: "  GET  cDod PICT "@!" VALID cdod $ "DN"
   read; clvbox(); ESC_BCR
   IF cDod == "D"
      @ m_x + 6, m_y + 2 SAY "Naziv kolone:" GET cKolona
      READ
   ENDIF
   fRacunaj := .F.
   IF Left( cKolona, 1 ) = "="
      fRacunaj := .T.
      ckolona := StrTran( cKolona, "=", "" )
   ELSE
      ckolona := "radn->" + ckolona
   ENDIF
   BoxC()

   tipprn_use()

   SELECT tippr
   hseek ctip
   EOF CRET

   SELECT ld

   IF lViseObr .AND. !Empty( cObracun )
      SET FILTER TO obr == cObracun
   ENDIF

   SET ORDER TO tag ( TagVO( "4" ) )
   hseek Str( cGodina, 4 )

   EOF CRET

   nStrana := 0
   m := "----- ------ ---------------------------------- " + "-" + REPL( "-", Len( gPicS ) ) + " ----------- -----------"
   IF cdod == "D"
      IF Type( ckolona ) $ "UUIUE"
         Msg( "Nepostojeca kolona" )
         closeret
      ENDIF
   ENDIF
   bZagl := {|| ZPregPrimPer() }

   SELECT ld_rj; hseek ld->idrj; SELECT ld

   START PRINT CRET
   P_10CPI

   Eval( bZagl )

   nRbr := 0
   nT1 := nT2 := nT3 := nT4 := 0
   nC1 := 10

   DO WHILE !Eof() .AND.  cgodina == godina
      IF PRow() > RPT_PAGE_LEN; FF; Eval( bZagl ); ENDIF


      cIdRadn := idradn
      SELECT radn; hseek cidradn; SELECT ld

      wi&cTip := 0
      ws&cTip := 0

      IF fracunaj
         nKolona := 0
      ENDIF
      DO WHILE  !Eof() .AND. cgodina == godina .AND. idradn == cidradn
         Scatter()
         IF !Empty( cidrj ) .AND. _idrj <> cidrj
            skip; LOOP
         ENDIF
         IF cmjesecod > _mjesec .OR. cmjesecdo < _mjesec
            skip; LOOP
         ENDIF
         wi&cTip += _i&cTip
         IF ! ( lViseObr .AND. Empty( cObracun ) .AND. _obr <> "1" )
            ws&cTip += _s&cTip
         ENDIF
         IF fRacunaj
            nKolona += &cKolona
         ENDIF
         SKIP
      ENDDO

      IF wi&cTip <> 0 .OR. ws&cTip <> 0
         ? Str( ++nRbr, 4 ) + ".", cidradn, RADNIK
         nC1 := PCol() + 1
         IF tippr->fiksan == "P"
            @ PRow(), PCol() + 1 SAY ws&cTip  PICT "999.99"
         ELSE
            @ PRow(), PCol() + 1 SAY ws&cTip  PICT gpics
         ENDIF
         @ PRow(), PCol() + 1 SAY wi&cTip  PICT gpici
         nT1 += ws&cTip; nT2 += wi&cTip
         IF cdod == "D"
            IF fracunaj
               @ PRow(), PCol() + 1 SAY nKolona PICT gpici
            ELSE
               @ PRow(), PCol() + 1 SAY &ckolona
            ENDIF
         ENDIF

      ENDIF

      SELECT ld
   ENDDO

   IF PRow() > 60; FF; Eval( bZagl ); ENDIF
   ? m
   ? " UKUPNO:"
   @ PRow(), nC1 SAY  nT1 PICT gpics
   @ PRow(), PCol() + 1 SAY  nT2 PICT gpici
   ? m
   ?
   ? p_potpis()

   FF
   END PRINT
   my_close_all_dbf()
   RETURN



FUNCTION ZPregPrimPer()

   P_12CPI
   ? Upper( Trim( gTS ) ) + ":", gnFirma
   ?
   ? "Pregled primanja za period od", cMjesecOd, "do", cMjesecDo, "mjesec " + IspisObr()
   ?? cGodina
   ?
   IF Empty( cIdRj )
      ? "Pregled za sve RJ ukupno:"
   ELSE
      ? "RJ:", cIdRj, ld_rj->naz
   ENDIF
   ?? Space( 4 ), "Str.", Str( ++nStrana, 3 )
   ?
   ? "Pregled za tip primanja:", ctip, tippr->naz

   ? m
   ? " Rbr  Sifra           Naziv radnika               " + iif( tippr->fiksan == "P", " %  ", "Sati" ) + "      Iznos"
   ? m





FUNCTION ZSRO()

   P_COND
   ? Upper( gTS ) + ":", gnFirma
   ?
   IF Empty( cidrj )
      ? "Pregled za sve RJ ukupno:"
   ELSE
      ? "RJ:", cidrj, ld_rj->naz
   ENDIF
   ?? "  Mjesec:", Str( cmjesec, 2 ) + IspisObr()
   ?? "    Godina:", Str( cGodina, 5 )
   DevPos( PRow(), 74 )
   ?? "Str.", Str( ++nStrana, 3 )
   IF !Empty( cvposla )
      ? "Vrsta posla:", cvposla, "-", vposla->naz
   ENDIF
   IF !Empty( cKBenef )
      ? "Stopa beneficiranog r.st:", ckbenef, "-", kbenef->naz, ":", kbenef->iznos
   ENDIF
   ? m
   ? " Rbr * Sifra*         Naziv radnika            *  Sati *   Neto    *  Odbici   * ZA ISPLATU*"
   ? "     *      *                                  *       *           *           *           *"
   ? m

   RETURN



FUNCTION SortOpSt( cId )

   LOCAL cVrati := "", nArr := Select()

   SELECT RADN
   HSEEK cId
   cVrati := IdOpsSt
   SELECT ( nArr )

   RETURN cVrati



FUNCTION IzracDopr( cDopr, nKLO, cTipRada, nSpr_koef )

   LOCAL nArr := Select(), nDopr := 0, nPom := 0, nPom2 := 0, nPom0 := 0, nBO := 0, nBFOsn := 0
   LOCAL _a_benef := {}

   IF nKLO == nil
      nKLO := 0
   ENDIF

   IF cTipRada == nil
      cTipRada := ""
   ENDIF

   IF nSPr_koef == nil
      nSPr_koef := 0
   ENDIF

   ParObr( mjesec, godina, IF( lViseObr, cObracun, ), cIdRj )

   IF gVarObracun == "2"

      nBo := bruto_osn( Max( _UNeto, PAROBR->prosld * gPDLimit / 100 ), cTipRada, nKlo, nSPr_koef )

      IF UBenefOsnovu()

         IF !Empty( gBFForm )
            gBFForm := StrTran( gBFForm, "_", "" )
         ENDIF

         nBFOsn := bruto_osn( _UNeto - IF( !Empty( gBFForm ), &gBFForm, 0 ), cTipRada, nKlo, nSPr_koef )

         _benef_st := BenefStepen()
         add_to_a_benef( @_a_benef, AllTrim( radn->k3 ), _benef_st, nBFOsn )

      ENDIF

      IF cTipRada $ " #I#N"
         // minimalni bruto osnov
         IF calc_mbruto()
            nBo := min_bruto( nBo, ld->usati )
         ENDIF
      ENDIF

   ELSE
      nBo := round2( parobr->k3 / 100 * Max( _UNeto, PAROBR->prosld * gPDLimit / 100 ), gZaok2 )
   ENDIF

   SELECT DOPR
   GO TOP

   DO WHILE !Eof()

      IF gVarObracun == "2"
         IF cTipRada $ "I#N" .AND. Empty( dopr->tiprada )
            // ovo je uredu !
         ELSEIF dopr->tiprada <> cTipRada
            SKIP 1
            LOOP
         ENDIF
      ENDIF

      IF !( id $ cDopr )
         SKIP 1
         LOOP
      ENDIF

      PozicOps( DOPR->poopst )   // ? mozda ovo rusi koncepciju zbog sorta na LD-u

      IF !ImaUOp( "DOPR", DOPR->id )
         SKIP 1
         LOOP
      ENDIF

      IF !Empty( dopr->idkbenef )
         // beneficirani
         nPom := Max( dlimit, Round( iznos / 100 * get_benef_osnovica( _a_benef, dopr->idkbenef ), gZaok2 ) )
      ELSE
         nPom := Max( dlimit, Round( iznos / 100 * nBO, gZaok2 ) )
      ENDIF

      IF Round( iznos, 4 ) = 0 .AND. dlimit > 0
         // fuell boss
         // kartica plate
         nPom := 1 * dlimit
      ENDIF

      nDopr += nPom

      // resetuj matricu a_benef, posto nam treba za radnika
      _a_benef := {}

      SKIP 1

   ENDDO

   SELECT ( nArr )

   RETURN ( nDopr )


FUNCTION SortPre2()
   RETURN ( RADN->( naz + ime + imerod ) + idradn )



STATIC FUNCTION _specpr_o_tbl()

   O_TIPPR
   O_KRED
   O_RADKR
   SET ORDER TO TAG "1"
   O_LD_RJ
   O_RADN
   O_LD

   RETURN



FUNCTION ld_specifikacija_po_rj()

   LOCAL _alias, _table_name

   cGodina  := gGodina
   cMjesecOd := cMjesecDo := gMjesec
   cObracun := " "
   qqRj := ""
   qqPrimanja := ""

   _specpr_o_tbl()

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " ", aHistory := {}

   cMjesecOd := Str( cMjesecOd, 2 )
   cMjesecDo := Str( cMjesecDo, 2 )
   cGodina   := Str( cGodina,4 )

   RPar( "p1", @cMjesecOd )
   RPar( "p2", @cMjesecDo )
   RPar( "p3", @cGodina   )
   RPar( "p8", @qqRj      )
   RPar( "p9", @cObracun  )
   RPar( "pA", @qqPrimanja )

   cMjesecOd := Val( cMjesecOd )
   cMjesecDo := Val( cMjesecDo )
   cGodina   := Val( cGodina  )
   qqRj      := PadR( qqRj, 40 )
   qqPrimanja := PadR( qqPrimanja, 100 )

   DO WHILE .T.
      Box( "#Uslovi za specifikaciju primanja po radnim jedinicama", 8, 75 )
      @ m_x + 2, m_y + 2   SAY "Radne jedinice (prazno-sve): "   GET qqRj PICT "@S20"
      @ m_x + 3, m_y + 2   SAY "Mjesec od: "                     GET cMjesecOd PICT "99"
      @ m_x + 3, Col() + 2 SAY "do"                              GET cMjesecDo PICT "99"
      @ m_x + 4, m_y + 2   SAY "Godina: "                        GET cGodina   PICT "9999"
      IF lViseObr
         @ m_x + 4, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
      ENDIF
      @ m_x + 5, m_y + 2   SAY "Sifre primanja (prazno-sve):"   GET qqPrimanja PICT "@S30"
      READ
      ESC_BCR
      BoxC()
      aUslRJ   := Parsiraj( qqRj, "IDRJ" )
      aUslPrim := Parsiraj( qqPrimanja, "cIDPRIM" )
      IF aUslRJ <> NIL
         EXIT
      ENDIF
   ENDDO

   cMjesecOd := Str( cMjesecOd, 2 )
   cMjesecDo := Str( cMjesecDo, 2 )
   cGodina   := Str( cGodina,4 )
   qqRj      := Trim( qqRj )
   qqPrimanja := Trim( qqPrimanja )

   WPar( "p1", cMjesecOd )
   WPar( "p2", cMjesecDo )
   WPar( "p3", cGodina   )
   WPar( "p8", qqRj      )
   RPar( "p9", cObracun  )
   WPar( "pA", qqPrimanja )
   SELECT PARAMS
   USE

   cMjesecOd := Val( cMjesecOd )
   cMjesecDo := Val( cMjesecDo )
   cGodina   := Val( cGodina  )

   _alias := "LDT22"
   _table_name := "ldt22"

   aDbf := {    { "IDPRIM",  "C",  2, 0 },;
      { "IDKRED",  "C",  6, 0 },;
      { "IDRJ",  "C",  2, 0 },;
      { "IZNOS",  "N", 18, 4 } ;
      }

   DBCREATE2( f18_ime_dbf( _table_name ), aDbf )

   SELECT F_LDT22
   my_usex( _alias )

   CREATE_INDEX( "1", "idprim+idkred+idrj", _alias )
   USE

   _specpr_o_tbl()
   O_LDT22

   SET ORDER TO TAG "1"

   aPrim  := {}       // standardna primanja
   aPrimK := {}       // primanja kao npr. krediti

   O_TIPPR

   FOR i := 1 TO cLDPolja
      cIDPRIM := PadL( AllTrim( Str( i ) ), 2, "0" )
      IF &aUslPrim
         IF "SUMKREDITA" $ Ocitaj( F_TIPPR, cIdPrim, "formula" )
            AAdd( aPrimK, "I" + cIdPrim )
         ELSE
            AAdd( aPrim, "I" + cIdPrim )
         ENDIF
      ENDIF
   NEXT

   PRIVATE cFilt := ".t."
   IF !Empty( qqRJ )    ; cFilt += ( ".and." + aUslRJ )                ; ENDIF
   IF !Empty( cObracun ); cFilt += ( ".and. OBR==" + cm2str( cObracun ) ); ENDIF
   IF cMjesecOd != cMjesecDo
      cFilt := cFilt + ".and.mjesec>=" + cm2str( cMjesecOd ) + ;
         ".and.mjesec<=" + cm2str( cMjesecDo ) + ;
         ".and.godina=" + cm2str( cGodina )
   ELSE
      cFilt := cFilt + ".and.mjesec=" + cm2str( cMjesecOd ) + ;
         ".and.godina=" + cm2str( cGodina )
   ENDIF

   SELECT LD
   SET FILTER TO &cFilt
   GO TOP
   aRJ := {}
   DO WHILE !Eof()
      FOR i := 1 TO Len( aPrim )
         SELECT LD; nPom := &( aPrim[ i ] )
         SELECT LDT22; SEEK Right( aPrim[ i ], 2 ) + Space( 6 ) + LD->IDRJ
         IF Found()
            REPLACE iznos WITH iznos + nPom
         ELSE
            APPEND BLANK
            REPLACE idprim  WITH Right( aPrim[ i ], 2 ), ;
               idkred  WITH Space( 6 ),;
               idrj    WITH LD->IDRJ,;
               iznos   WITH iznos + nPom
            IF AScan( aRJ, {| x| x[ 1 ] == idrj } ) <= 0
               AAdd( aRJ, { idrj, 0 } )
            ENDIF
         ENDIF
         SELECT LD
      NEXT
      FOR i := 1 TO Len( aPrimK )
         SELECT LD; cKljuc := Str( godina, 4 ) + Str( mjesec, 2 ) + idradn
         SELECT RADKR; SEEK cKljuc
         IF Found()
            DO WHILE !Eof() .AND. Str( godina, 4 ) + Str( mjesec, 2 ) + idradn == cKljuc
               cIdKred := idkred
               nPom := 0
               DO WHILE !Eof() .AND. Str( godina, 4 ) + Str( mjesec, 2 ) + idradn + idkred == cKljuc + cIdKred
                  nPom += placeno
                  SKIP 1
               ENDDO
               nPom := -nPom      // kredit je odbitak
               SELECT LDT22; SEEK Right( aPrimK[ i ], 2 ) + cIdKred + LD->IDRJ
               IF Found()
                  REPLACE iznos WITH iznos + nPom
               ELSE
                  APPEND BLANK
                  REPLACE idprim  WITH Right( aPrimK[ i ], 2 ), ;
                     idkred  WITH cIdKred,;
                     idrj    WITH LD->IDRJ,;
                     iznos   WITH iznos + nPom
                  IF AScan( aRJ, {| x| x[ 1 ] == idrj } ) <= 0
                     AAdd( aRJ, { idrj, 0 } )
                  ENDIF
               ENDIF
               SELECT RADKR
            ENDDO
         ENDIF
      NEXT
      SELECT LD; SKIP 1
   ENDDO

   START PRINT CRET
   gOstr := "D"; gTabela := 1
   cPrimanje := ""; nUkupno := 0
   nKol := 0

   aKol := { { "PRIMANJE", {|| cPrimanje }, .F., "C", 40, 0, 1, ++nKol } }

   // radne jedinice
   ASort( aRJ,,, {| x, y| x[ 1 ] < y[ 1 ] } )
   FOR i := 1 TO Len( aRJ )
      cPom := AllTrim( Str( i ) )
      AAdd( aKol, { "RJ " + aRJ[ i, 1 ], {|| aRJ[ &cPom., 2 ] }, .T., "N", 15, 2, 1, ++nKol  } )
   NEXT

   // ukupno
   AAdd( aKol, { "UKUPNO", {|| nUkupno }, .T., "N", 15, 2, 1, ++nKol } )

   P_10CPI
   ?? gnFirma
   ?
   ? "Mjesec: od", Str( cMjesecOd, 2 ) + ".", "do", Str( cMjesecDo, 2 ) + "."
   ?? "    Godina:", Str( cGodina, 4 )
   ? "Obuhvacene radne jedinice  :", IF( !Empty( qqRJ ), "'" + qqRj + "'", "SVE" )
   ? "Obuhvacena primanja (sifre):", "'" + qqPrimanja + "'"
   ?

   SELECT LDT22; GO TOP

   StampaTabele( aKol,,, gTabela,, ;
      , "SPECIFIKACIJA PRIMANJA PO RADNIM JEDINICAMA", ;
      {|| FFor8() }, IF( gOstr == "D",, -1 ),,,,, )
   FF

   END PRINT
   my_close_all_dbf()
   RETURN


FUNCTION FFor8()

   LOCAL i, nPos, cIdPrim, cIdKred, cIdRj

   IF Empty( idkred )
      cPrimanje := idprim + "-" + Ocitaj( F_TIPPR, idprim, "naz" )
   ELSE
      cPrimanje := idprim + "-" + idkred + "-" + Ocitaj( F_KRED, idkred, "naz" )
   ENDIF
   cIdPrim := idprim
   cIdKred := idkred
   FOR i := 1 TO Len( aRJ ); aRJ[ i, 2 ] := 0; NEXT
   nUkupno := 0
   DO WHILE !Eof() .AND. cIdPrim + cIdKred == idprim + idkred
      cIdRJ := idrj
      nPos := AScan( aRJ, {| x| x[ 1 ] == cIdRj } )
      DO WHILE !Eof() .AND. cIdPrim + cIdKred + cIdRj == idprim + idkred + idrj
         aRJ[ nPos, 2 ] += iznos
         nUkupno     += iznos
         SKIP 1
      ENDDO
   ENDDO
   SKIP -1

   RETURN .T.




