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

STATIC __line
STATIC __txt1
STATIC __txt2
STATIC __txt3



FUNCTION lager_lista_magacin()

   PARAMETERS fPocStanje

   LOCAL fimagresaka := .F.
   LOCAL _curr_user := "<>"
   LOCAL lExpDbf := .F.
   LOCAL cExpDbf := "N"
   LOCAL cMoreInfo := "N"
   LOCAL _vpc_iz_sif := "D"
   LOCAL _print := "1"


   LOCAL nTUlazP  // ulaz, izlaz parovno
   LOCAL nTIzlazP
   LOCAL nKolicina
   LOCAL cPicDem
   LOCAL cPicCDem
   LOCAL cPicKol
   LOCAL cLine
   LOCAL cTxt1
   LOCAL cTxt2
   LOCAL cTxt3
   LOCAL cMIPart := ""
   LOCAL cMINumber := ""
   LOCAL dMIDate := CToD( "" )
   LOCAL cMI_type := ""
   LOCAL cSrKolNula := "0"
   LOCAL dL_ulaz := CToD( "" )
   LOCAL dL_izlaz := CToD( "" )
   LOCAL hParams

   // pPicDem := global_pic_iznos()
   // pPicCDem := global_pic_cijena()
   // pPicKol := global_pic_kolicina()

   cIdFirma := self_organizacija_id()
   cPrikazDob := "N"
   cIdKonto := PadR( "1310", gDuzKonto )

   PRIVATE nVPVU := 0
   PRIVATE nVPVI := 0

   PRIVATE nVPVRU := 0
   PRIVATE nVPVRI := 0

   PRIVATE nNVU := 0
   PRIVATE nNVI := 0

   // signalne zalihe
   PRIVATE lSignZal := .F.
   PRIVATE qqRGr := Space( 40 )
   PRIVATE qqRGr2 := Space( 40 )

   IF IsVindija()
      cOpcine := Space( 50 )
   ENDIF

   kalk_open_tables()

   IF fPocStanje == NIL
      fPocStanje := .F.
   ELSE
      fPocStanje := .T.
      o_kalk_pripr()
      cBrPSt := "00001   "
      Box(, 3, 60 )
      @ m_x + 1, m_y + 2 SAY8 "Generacija poč.stanja  - broj dokumenta 16 -" GET cBrPSt
      READ
      ESC_BCR
      BoxC()
   ENDIF

   PRIVATE dDatOd := Date()
   PRIVATE dDatDo := Date()

   qqRoba := Space( 60 )
   qqTarifa := Space( 60 )
   qqidvd := Space( 60 )
   qqIdPartner := Space( 60 )

   PRIVATE cPNab := "N"
   PRIVATE cDoNab := "N"
   PRIVATE cNulaDN := "N"
   PRIVATE cErr := "N"
   PRIVATE cNCSif := "N"
   PRIVATE cMink := "N"
   PRIVATE cSredCij := "N"
   PRIVATE cFaBrDok := Space( 40 )

   IF !Empty( cRNT1 )
      PRIVATE cRNalBroj := PadR( "", 40 )
   ENDIF

   IF !fPocStanje

      cIdKonto := fetch_metric( "kalk_lager_lista_id_konto", _curr_user, cIdKonto )
      cPNab := fetch_metric( "kalk_lager_lista_po_nabavnoj", _curr_user, cPNab )
      cNulaDN := fetch_metric( "kalk_lager_lista_prikaz_nula", _curr_user, cNulaDN )
      dDatOd := fetch_metric( "kalk_lager_lista_datum_od", _curr_user, dDatOd )
      dDatDo := fetch_metric( "kalk_lager_lista_datum_do", _curr_user, dDatDo )
      cDoNab := fetch_metric( "kalk_lager_Lista_prikaz_do_nabavne", _curr_user, cDoNab )
      _vpc_iz_sif := fetch_metric( "kalk_lager_Lista_vpc_iz_sif", _curr_user, _vpc_iz_sif )
      _print := fetch_metric( "kalk_lager_print_varijanta", _curr_user, _print )
   ENDIF

   cArtikalNaz := Space( 30 )

   Box(, 21, 80 )


   DO WHILE .T.

      @ m_x + 1, m_y + 2 SAY "Firma "
      ?? self_organizacija_id(), "-", self_organizacija_naziv()

      @ m_x + 2, m_y + 2 SAY "Konto   " GET cIdKonto VALID "." $ cidkonto .OR. P_Konto( @cIdKonto )
      @ m_x + 3, m_y + 2 SAY "Artikli " GET qqRoba PICT "@!S50"
      @ m_x + 4, m_y + 2 SAY "Tarife  " GET qqTarifa PICT "@!S50"
      @ m_x + 5, m_y + 2 SAY "Vrste dokumenata " GET qqIDVD PICT "@!S30"
      @ m_x + 6, m_y + 2 SAY "Partneri " GET qqIdPartner PICT "@!S20"
      @ m_x + 6, Col() + 1 SAY "Br.fakture " GET cFaBrDok  PICT "@!S15"
      @ m_x + 7, m_y + 2 SAY "Prikaz Nab.vrijednosti D/N" GET cPNab  VALID cpnab $ "DN" PICT "@!"

      @ m_x + 7, Col() + 1 SAY "Prikaz samo do nab.vr. D/N" GET cDoNab  VALID cDoNab $ "DN" PICT "@!"

      @ m_x + 8, m_y + 2 SAY8 "Pr.stavki kojima je NV 0 D/N" GET cNulaDN  VALID cNulaDN $ "DN" PICT "@!"
      @ m_x + 9, m_y + 2 SAY8 "Prikaz 'ERR' ako je NV/Kolicina<>NC " GET cErr PICT "@!" VALID cErr $ "DN"
      @ m_x + 9, Col() + 1 SAY8 "VPC iz sifrarnika robe (D/N)?" GET _vpc_iz_sif PICT "@!" VALID _vpc_iz_sif $ "DN"


      @ m_x + 10, m_y + 2 SAY8 "Datum od " GET dDatOd
      @ m_x + 10, Col() + 2 SAY8 "do" GET dDatDo

      @ m_x + 11, m_y + 2 SAY8 "Vrsta štampe TXT/ODT (1/2)" GET _print VALID _print $ "12" PICT "@!"

      @ m_x + 12, m_y + 2 SAY8 "Postaviti srednju NC u sifrarnik" GET cNCSif PICT "@!" VALID ( ( cpnab == "D" .AND. cncsif == "D" ) .OR. cNCSif == "N" )

      IF fPocStanje
         @ m_x + 13, m_y + 2 SAY8 "Sredi samo stavke kol=0, nv<>0 (0/1/2)"  GET cSrKolNula VALID cSrKolNula $ "012" PICT "@!"
      ENDIF

      @ m_x + 14, m_y + 2 SAY8 "Prikaz samo kritičnih zaliha (D/N/O) ?" GET cMinK PICT "@!" VALID cMink $ "DNO"

      IF IsVindija()
         cGr := Space( 10 )
         cPSPDN := "N"
         @ m_x + 15, m_y + 2 SAY "Grupa:" GET cGr
         @ m_x + 16, m_y + 2 SAY "Pregled samo prodaje (D/N)" GET cPSPDN VALID cPSPDN $ "DN" PICT "@!"
         @ m_x + 17, m_y + 2 SAY "Uslov po opcinama:" GET cOpcine PICT "@!S40"
      ENDIF

      // ako je roba - grupacija
      @ m_x + 17, m_y + 2 SAY "Grupa artikla:" GET qqRGr PICT "@S10"
      @ m_x + 17, m_y + 30 SAY "Podgrupa artikla:" GET qqRGr2 PICT "@S10"

      @ m_x + 18, m_y + 2 SAY "Naziv artikla sadrzi"  GET cArtikalNaz

      IF !Empty( cRNT1 )
         @ m_x + 19, m_y + 2 SAY "Broj radnog naloga:"  GET cRNalBroj PICT "@S20"
      ENDIF

      @ m_x + 20, m_y + 2 SAY8 "Export izvještaja u dbf?" GET cExpDbf VALID cExpDbf $ "DN" PICT "@!"

      @ m_x + 20, Col() + 1 SAY "Pr.dodatnih informacija ?" GET cMoreInfo VALID cMoreInfo $ "DN" PICT "@!"

      READ
      ESC_BCR

      PRIVATE aUsl1 := Parsiraj( qqRoba, "IdRoba" )
      PRIVATE aUsl2 := Parsiraj( qqTarifa, "IdTarifa" )
      PRIVATE aUsl3 := Parsiraj( qqIDVD, "idvd" )
      PRIVATE aUsl4 := Parsiraj( qqIDPartner, "idpartner" )
      PRIVATE aUsl5 := Parsiraj( cFaBrDok, "brfaktp" )

      qqRGr := AllTrim( qqRGr )
      qqRGr2 := AllTrim( qqRGr2 )

      IF !Empty( cRnT1 ) .AND. !Empty( cRNalBroj )
         PRIVATE aUslRn := Parsiraj( cRNalBroj, "idzaduz2" )
      ENDIF

      IF aUsl1 <> NIL .AND. aUsl2 <> NIL .AND. aUsl3 <> NIL .AND. aUsl4 <> NIL .AND. ( Empty( cRnT1 ) .OR. Empty( cRNalBroj ) .OR. aUslRn <> NIL ) .AND. aUsl5 <> nil
         EXIT
      ENDIF
   ENDDO
   BoxC()

   IF !fPocStanje

      set_metric( "kalk_lager_lista_id_konto", f18_user(), cIdKonto )
      set_metric( "kalk_lager_lista_po_nabavnoj", f18_user(), cPNab )
      set_metric( "kalk_lager_lista_prikaz_nula", f18_user(), cNulaDN )
      set_metric( "kalk_lager_lista_datum_od", f18_user(), dDatOd )
      set_metric( "kalk_lager_lista_datum_do", f18_user(), dDatDo )
      set_metric( "kalk_lager_lista_prikaz_do_nabavne", f18_user(), cDoNab )
      set_metric( "kalk_lager_Lista_vpc_iz_sif", _curr_user, _vpc_iz_sif )
      set_metric( "kalk_lager_print_varijanta", _curr_user, _print )

   ENDIF

   // export u dbf ?
   IF cExpDbf == "D"
      lExpDbf := .T.
   ENDIF

   lSvodi := .F.

   IF my_get_from_ini( "KALK_LLM", "SvodiNaJMJ", "N", KUMPATH ) == "D"
      lSvodi := ( Pitanje(, "Svesti kolicine na osnovne jedinice mjere? (D/N)", "N" ) == "D" )
   ENDIF

   // sinteticki konto
   fSint := .F.
   cSintK := cIdKonto

   IF "." $ cIdKonto
      cIdkonto := StrTran( cIdKonto, ".", "" )
      cIdkonto := Trim( cIdKonto )
      cSintK := cIdKonto
      fSint := .T.
      lSaberiStanjeZaSvaKonta := ( Pitanje(, "Racunati stanje robe kao zbir stanja na svim obuhvacenim kontima? (D/N)", "N" ) == "D" )
   ENDIF

   IF lExpDbf == .T.
      aExpFields := g_exp_fields()
      create_dbf_r_export( aExpFields )
   ENDIF

   kalk_open_tables()


   PRIVATE cFilt := ".t."

   IF aUsl1 <> ".t."
      cFilt += ".and." + aUsl1
   ENDIF

   IF aUsl2 <> ".t."
      cFilt += ".and." + aUsl2
   ENDIF
   IF aUsl3 <> ".t."
      cFilt += ".and." + aUsl3
   ENDIF
   IF aUsl4 <> ".t."
      cFilt += ".and." + aUsl4
   ENDIF
   IF !Empty( cFaBrDok ) .AND. aUsl5 <> ".t."
      cFilt += ".and." + aUsl5
   ENDIF

   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
      cFilt += ".and. DatDok>=" + dbf_quote( dDatOd ) + ".and. DatDok<=" + dbf_quote( dDatDo )
   ENDIF
   IF fSint .AND. lSaberiStanjeZaSvaKonta
      cFilt += ".and. MKonto=" + dbf_quote( cSintK )
      cSintK := ""
   ENDIF

   IF !Empty( cRNT1 ) .AND. !Empty( cRNalBroj )
      cFilt += ".and." + aUslRn
   ENDIF


   MsgO( "Preuzimanje podataka sa SQL servera ..." )
   IF fSint .AND. lSaberiStanjeZaSvaKonta
      // HSEEK cIdFirma
      find_kalk_by_mkonto_idroba( cIdFirma, NIL, NIL, "idFirma,IdTarifa,idroba" )
      // kalk index tag ( "6", "idFirma+IdTarifa+idroba" )
      // SET ORDER TO TAG "6"
      GO TOP
   ELSE
      // SET ORDER TO TAG "3"
      // HSEEK cIdFirma + cIdKonto
      find_kalk_by_mkonto_idroba( cIdFirma, cIdKonto )
   ENDIF
   MsgC()

   IF cFilt == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilt
   ENDIF
   GO TOP

   SELECT koncij
   SEEK Trim( cIdKonto )

   SELECT kalk
   ?E "trace-kalk-llm-11"

   IF _print == "2"
      // stampa dokumenta u odt formatu
      hParams := hb_Hash()
      hParams[ "idfirma" ] := self_organizacija_id()
      hParams[ "idkonto" ] := cIdKonto
      hParams[ "roba_naz" ] := cArtikalNaz
      hParams[ "group_1" ] := qqRGr
      hParams[ "group_2" ] := qqRGr2
      hParams[ "nule" ] := ( cNulaDN == "D" )
      hParams[ "svodi_jmj" ] := lSvodi
      hParams[ "vpc_sif" ] := ( _vpc_iz_sif == "D" )
      hParams[ "datum_od" ] := dDatOd
      hParams[ "datum_do" ] := dDatDo
      kalk_magacin_llm_odt( hParams )
      RETURN .F.
   ENDIF

   EOF CRET

   nLen := 1



   _set_zagl( @cLine, @cTxt1, @cTxt2, @cTxt3, cSredCij )

   __line := cLine
   __txt1 := cTxt1
   __txt2 := cTxt2
   __txt3 := cTxt3

   IF koncij->naz $ "P1#P2"
      cPNab := "D"
   ENDIF

   gaZagFix := { 7, 5 }


   IF !start_print()
      RETURN .F.
   ENDIF
   ?

   PRIVATE nTStrana := 0
   PRIVATE bZagl := {|| Zagllager_lista_magacin() }

   Eval( bZagl )

   nTUlaz := 0
   nTIzlaz := 0
   nTUlazP := 0
   nTIzlazP := 0
   nTVPVU := 0
   nTVPVI := 0
   nTVPVRU := 0
   nTVPVRI := 0
   nTNVU := 0
   nTNVI := 0
   nRazlika := 0
   nTNV := 0
   nNBUk := 0
   nNBCij := 0
   nTRabat := 0
   nCol1 := 50
   nCol0 := 50

   PRIVATE nRbr := 0

   DO WHILE !Eof() .AND. iif( fSint .AND. lSaberiStanjeZaSvaKonta, idfirma, idfirma + mkonto ) == cIdfirma + cSintK .AND. IspitajPrekid()

      cIdRoba := field->Idroba

      nUlaz := 0
      nIzlaz := 0

      nVPVU := 0
      nVPVI := 0

      nVPVRU := 0
      nVPVRI := 0

      nNVU := 0
      nNVI := 0

      nRabat := 0

      cMIFakt := ""
      cMINumber := ""
      dMIDate := CToD( "" )

      dL_ulaz := CToD( "" )
      dL_izlaz := CToD( "" )

      SELECT roba
      HSEEK cIdRoba

      // pretrazi artikle po nazivu
      IF ( !Empty( cArtikalNaz ) .AND. At( AllTrim( cArtikalNaz ), AllTrim( roba->naz ) ) == 0 )
         SELECT kalk
         SKIP
         LOOP
      ENDIF


      IF !Empty( qqRGr ) .OR. !Empty( qqRGr2 ) // uslov za roba - grupacija
         IF !IsInGroup( qqRGr, qqRGr2, roba->id )
            SELECT kalk
            SKIP
            LOOP
         ENDIF
      ENDIF

      // Vindija - uslov po opcinama
      IF ( IsVindija() .AND. !Empty( cOpcine ) )
         SELECT partn
         SET ORDER TO TAG "ID"
         HSEEK kalk->idpartner
         IF At( AllTrim( partn->idops ), cOpcine ) == 0
            SELECT kalk
            SKIP
            LOOP
         ENDIF
         SELECT roba
      ENDIF

      // po vindija GRUPA
      IF IsVindija()
         IF !Empty( cGr )
            IF AllTrim( cGr ) <> IzSifKRoba( "GR1", cIdRoba, .F. )
               SELECT kalk
               SKIP
               LOOP
            ELSE
               IF Empty( IzSifKRoba( "GR2", cIdRoba, .F. ) )
                  SELECT kalk
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         ENDIF
         IF ( cPSPDN == "D" )
            SELECT kalk
            IF ( kalk->mu_i <> "5" ) .AND. ( kalk->mkonto <> cIdKonto )
               SKIP
               LOOP
            ENDIF
            SELECT roba
         ENDIF
      ENDIF


      IF ( FieldPos( "MINK" ) ) <> 0
         nMink := roba->mink
      ELSE
         nMink := 0
      ENDIF

      SELECT kalk
      IF roba->tip $ "TUY"
         SKIP
         LOOP
      ENDIF

      cIdkonto := kalk->mkonto



      DO WHILE !Eof() .AND. iif( fSint .AND. lSaberiStanjeZaSvaKonta, cIdFirma + cIdRoba == idFirma + field->idroba, cIdFirma + cIdKonto + cIdRoba == idFirma + mkonto + field->idroba ) .AND. IspitajPrekid()

         IF roba->tip $ "TU"
            SKIP
            LOOP
         ENDIF

         IF mu_i == "1"
            IF !( idvd $ "12#22#94" )
               nKolicina := field->kolicina - field->gkolicina - field->gkolicin2
               nUlaz += nKolicina
               kalk_sumiraj_kolicinu( nKolicina, 0, @nTUlazP, @nTIzlazP )
               nCol1 := PCol() + 1
               IF koncij->naz == "P2"
                  nVPVU += Round( roba->plc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
                  nVPVRU += Round( roba->plc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
               ELSE
                  nVPVU += Round( roba->vpc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
                  nVPVRU += Round( field->vpc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
               ENDIF

               nNVU += Round( nc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
            ELSE
               nKolicina := -field->kolicina
               nIzlaz += nKolicina
               kalk_sumiraj_kolicinu( 0, nKolicina, @nTUlazP, @nTIzlazP )
               IF koncij->naz == "P2"
                  nVPVI -= Round( roba->plc * kolicina, gZaokr )
                  nVPVRI -= Round( roba->plc * kolicina, gZaokr )
               ELSE
                  nVPVI -= Round( roba->vpc * kolicina, gZaokr )
                  nVPVRI -= Round( field->vpc * kolicina, gZaokr )
               ENDIF
               nNVI -= Round( nc * kolicina, gZaokr )
            ENDIF

            // datum zadnjeg ulaza
            dL_ulaz := field->datdok

         ELSEIF mu_i == "5"
            nKolicina := field->kolicina
            nIzlaz += nKolicina
            kalk_sumiraj_kolicinu( 0, nKolicina, @nTUlazP, @nTIzlazP )
            IF koncij->naz == "P2"
               nVPVI += Round( roba->plc * kolicina, gZaokr )
               nVPVRI += Round( roba->plc * kolicina, gZaokr )
            ELSE
               nVPVI += Round( roba->vpc * kolicina, gZaokr )
               nVPVRI += Round( field->vpc * kolicina, gZaokr )
            ENDIF
            nRabat += Round(  rabatv / 100 * vpc * kolicina, gZaokr )
            nNVI += Round( nc * kolicina, gZaokr )

            // datum zadnjeg izlaza
            dL_izlaz := field->datdok

         ELSEIF mu_i == "8"
            nKolicina := -field->kolicina
            nIzlaz += nKolicina
            kalk_sumiraj_kolicinu( 0, nKolicina, @nTUlazP, @nTIzlazP )
            IF koncij->naz == "P2"
               nVPVI += Round( roba->plc * ( - kolicina ), gZaokr )
               nVPVRI += Round( roba->plc * ( - kolicina ), gZaokr )
            ELSE
               nVPVI += Round( roba->vpc * ( - kolicina ), gZaokr )
               nVPVRI += Round( field->vpc * ( - kolicina ), gZaokr )
            ENDIF
            nRabat += Round(  rabatv / 100 * vpc * ( - kolicina ), gZaokr )
            nNVI += Round( nc * ( - kolicina ), gZaokr )
            nKolicina := -field->kolicina
            nUlaz += nKolicina
            kalk_sumiraj_kolicinu( nKolicina, 0, @nTUlazP, @nTIzlazP )

            IF koncij->naz == "P2"
               nVPVU += Round( - roba->plc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
               nVPVRU += Round( - roba->plc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
            ELSE
               nVPVU += Round( - roba->vpc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
               nVPVRU += Round( - field->vpc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
            ENDIF

            nNVU += Round( - nc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
         ENDIF

         cMIPart := field->idpartner
         dMIDate := field->datfaktp
         cMINumber := field->brfaktp
         cMI_type := field->mu_i

         SKIP
      ENDDO

      IF cMinK == "D" .AND. ( nUlaz - nIzlaz - nMink ) > 0
         LOOP
      ENDIF

      IF cNulaDN == "D" .OR. Round( nNVU - nNVI, 4 ) <> 0

         aNaz := Sjecistr( roba->naz, 20 )
         NovaStrana( bZagl )

         // rbr, idroba, naziv

         ? Str( ++nRbr, 6 ) + ".", cIdRoba
         nCr := PCol() + 1

         @ PRow(), PCol() + 1 SAY aNaz[ 1 ]

         cJMJ := ROBA->JMJ
         nVPCIzSif := ROBA->VPC

         IF lSvodi
            nKJMJ  := svedi_na_jedinicu_mjere( 1, cIdRoba, @cJMJ )
            cJMJ := PadR( cJMJ, Len( ROBA->JMJ ) )
         ELSE
            nKJMJ  := 1
         ENDIF

         @ PRow(), PCol() + 1 SAY cJMJ

         nCol0 := PCol() + 1

         // ulaz, izlaz, stanje
         @ PRow(), PCol() + 1 SAY say_kolicina( nKJMJ * nUlaz          )
         @ PRow(), PCol() + 1 SAY say_kolicina( nKJMJ * nIzlaz         )
         @ PRow(), PCol() + 1 SAY say_kolicina( nKJMJ * ( nUlaz - nIzlaz ) )

         IF fPocStanje

            SELECT kalk_pripr
            IF Round( nUlaz - nIzlaz, 4 ) <> 0 .AND. cSrKolNula $ "01"

               APPEND BLANK

               REPLACE idfirma WITH cIdfirma, ;
                  idroba WITH cIdRoba, ;
                  idkonto WITH cIdKonto, ;
                  datdok WITH dDatDo + 1, ;
                  idtarifa WITH roba->idtarifa, ;
                  datfaktp WITH dDatDo + 1, ;
                  kolicina WITH nUlaz - nIzlaz, ;
                  idvd WITH "16", ;
                  brdok WITH cBRPST

               REPLACE nc WITH ( nNVU - nNVI ) / ( nUlaz - nIzlaz )
               REPLACE vpc WITH ( nVPVU - nVPVI ) / ( nUlaz - nIzlaz )

               REPLACE vpc WITH nc


            ELSEIF cSrKolNula $ "12" .AND. Round( nUlaz - nIzlaz, 4 ) = 0

               // kontrolna opcija
               // kolicina 0, nabavna cijena <> 0
               IF ( nNVU - nNVI ) <> 0

                  // 1 stavka (minus)
                  APPEND BLANK

                  REPLACE idfirma WITH cIdfirma
                  REPLACE idroba WITH cIdRoba
                  REPLACE idkonto WITH cIdKonto
                  REPLACE datdok WITH dDatDo + 1
                  REPLACE idtarifa WITH roba->idtarifa
                  REPLACE datfaktp WITH dDatDo + 1
                  REPLACE kolicina WITH -1
                  REPLACE idvd WITH "16"
                  REPLACE brdok WITH cBRPST
                  REPLACE brfaktp WITH "#KOREK"
                  REPLACE nc WITH 0
                  REPLACE vpc WITH 0

                  REPLACE vpc WITH nc


                  // 2 stavka (plus i nv)
                  APPEND BLANK

                  REPLACE idfirma WITH cIdfirma
                  REPLACE idroba WITH cIdRoba
                  REPLACE idkonto WITH cIdKonto
                  REPLACE datdok WITH dDatDo + 1
                  REPLACE idtarifa WITH roba->idtarifa
                  REPLACE datfaktp WITH dDatDo + 1
                  REPLACE kolicina WITH 1
                  REPLACE idvd WITH "16"
                  REPLACE brdok WITH cBRPST
                  REPLACE brfaktp WITH "#KOREK"
                  REPLACE nc WITH ( nNVU - nNVI )
                  REPLACE vpc WITH 0

                  REPLACE vpc WITH nc


               ENDIF

            ENDIF

            SELECT kalk

         ENDIF

         nCol1 := PCol() + 1




         // NV
         @ PRow(), PCol() + 1 SAY say_iznos( nNVU )
         @ PRow(), PCol() + 1 SAY say_iznos( nNVI  )
         @ PRow(), PCol() + 1 SAY say_iznos( nNVU - nNVI )

         IF cDoNab == "N"


            IF _vpc_iz_sif == "D"
               // sa vpc iz sifrarnika robe
               @ PRow(), PCol() + 1 SAY say_iznos( nVPVU )
               @ PRow(), PCol() + 1 SAY say_iznos( nRabat )
               @ PRow(), PCol() + 1 SAY say_iznos( nVPVI )
               @ PRow(), PCol() + 1 SAY say_iznos( nVPVU - nVPVI )
            ELSE
               // sa vpc iz tabele kalk
               @ PRow(), PCol() + 1 SAY say_iznos( nVPVRU )
               @ PRow(), PCol() + 1 SAY say_iznos( nRabat )
               @ PRow(), PCol() + 1 SAY say_iznos( nVPVRI )
               @ PRow(), PCol() + 1 SAY say_iznos( nVPVRU - nVPVRI )
            ENDIF

         ENDIF

         // provjeri greske sa NC
         IF !( koncij->naz = "P" )
            IF Round( nUlaz - nIzlaz, 4 ) <> 0
               IF cErr == "D" .AND. Round( ( nNVU - nNVI ) / ( nUlaz - nIzlaz ), 4 ) <> Round( roba->nc, 4 )
                  ?? " ERR"
                  fImaGreska := .T.
               ENDIF
            ELSE
               IF ( cErr == "D" .OR. fPocstanje ) .AND. ;
                     Round( ( nNVU - nNVI ), 4 ) <> 0
                  fImaGresaka := .T.
                  ?? " ERR"
               ENDIF
            ENDIF
         ENDIF


         IF cSredCij == "D"
            @ PRow(), PCol() + 1 SAY ( nNVU - nNVI + nVPVU - nVPVI ) / ( nUlaz - nIzlaz ) / 2 PICT "9999999.99"
         ENDIF

         // novi red
         @ PRow() + 1, 0 SAY ""
         IF Len( aNaz ) > 1
            @ PRow(), nCR  SAY aNaz[ 2 ]
         ENDIF



         IF cMink <> "N" .AND. nMink > 0
            @ PRow(), ncol0    SAY PadR( "min.kolic:", Len( global_pic_kolicina() ) )
            @ PRow(), PCol() + 1 SAY say_kolicina( nKJMJ * nMink  )
         ENDIF


         // ulaz - prazno
         @ PRow(), nCol0 SAY Space( Len( global_pic_kolicina() ) )
         // izlaz - prazno
         @ PRow(), PCol() + 1 SAY Space( Len( global_pic_kolicina() ) )
         // stanje - prazno
         @ PRow(), PCol() + 1 SAY Space( Len( global_pic_kolicina() ) )
         // nv.dug - prazno
         @ PRow(), PCol() + 1 SAY Space( Len( global_pic_iznos() ) )
         // nv.pot - prazno
         @ PRow(), PCol() + 1 SAY Space( Len( global_pic_iznos() ) )
         // prikazi NC
         IF Round( nUlaz - nIzlaz, 4 ) <> 0

            @ PRow(), PCol() + 1 SAY say_iznos( ( nNVU - nNVI ) / ( nUlaz - nIzlaz ) )

         ENDIF
         IF cDoNab == "N"
            // pv.dug - prazno
            @ PRow(), PCol() + 1 SAY Space( Len( global_pic_iznos() ) )
            // rabat - prazno
            @ PRow(), PCol() + 1 SAY Space( Len( global_pic_iznos() ) )
            // pv.pot - prazno
            @ PRow(), PCol() + 1 SAY Space( Len( global_pic_iznos() ) )
            // prikazi PC
            IF Round( nUlaz - nIzlaz, 4 ) <> 0
               @ PRow(), PCol() + 1 SAY say_cijena( nVPCIzSif )
            ENDIF
         ENDIF


         IF cMink == "O" .AND. nMink <> 0 .AND. ( nUlaz - nIzlaz - nMink ) < 0
            B_OFF
         ENDIF


         nTULaz += nKJMJ * nUlaz
         nTIzlaz += nKJMJ * nIzlaz
         nTVPVU += nVPVU
         nTVPVI += nVPVI
         nTVPVRU += nVPVRU
         nTVPVRI += nVPVRI
         nTNVU += nNVU
         nTNVI += nNVI
         nTNV += ( nNVU - nNVI )
         nTRabat += nRabat

         // prikaz dodatnih informacija na lager listi
         IF cMoreInfo == "D"
            ? Space( 6 ) + show_more_info( cMIPart, dMIDate, cMINumber, cMI_type )
         ENDIF

         IF lExpDbf == .T.
            IF ( cNulaDN == "N" .AND. Round( nUlaz - nIzlaz, 4 ) <> 0 ) ;
                  .OR. ( cNulaDN == "D" )

               cTmp := ""
               cTmp := roba->sifradob

               IF cNulaDN == "D" .AND. Round( nUlaz - nIzlaz, 4 ) = 0
                  fill_exp_tbl( 0, roba->id, cTmp, ;
                     roba->naz, roba->idtarifa, cJmj, ;
                     nUlaz, nIzlaz, ( nUlaz - nIzlaz ), ;
                     nNVU, nNVI, ( nNVU - nNVI ), 0, ;
                     nVPVU, nVPVI, ( nVPVU - nVPVI ), 0, ;
                     nVPVRU, nVPVRI, ;
                     dL_ulaz, dL_izlaz )

               ELSE
                  fill_exp_tbl( 0, roba->id, cTmp, ;
                     roba->naz, roba->idtarifa, cJmj, ;
                     nUlaz, nIzlaz, ( nUlaz - nIzlaz ), ;
                     nNVU, nNVI, ( nNVU - nNVI ), ;
                     ( nNVU - nNVI ) / ( nUlaz - nIzlaz ), ;
                     nVPVU, nVPVI, ( nVPVU - nVPVI ), ;
                     nVPCIzSif, ;
                     nVPVRU, nVPVRI, ;
                     dL_ulaz, dL_izlaz )
               ENDIF
            ENDIF
         ENDIF

      ENDIF

      IF roba_barkod_pri_unosu()
         ? Space( 6 ) + roba->barkod
      ENDIF

      IF lSignZal
         ?? Space( 6 ) + "p.kol: " + Str( IzSifKRoba( "PKOL", roba->id, .F. ) )
         ?? ", p.cij: " + Str( IzSifKRoba( "PCIJ", roba->id, .F. ) )
      ENDIF


   ENDDO

   ? __line
   ? "UKUPNO:"

   @ PRow(), nCol0 SAY say_kolicina( ntUlaz )
   @ PRow(), PCol() + 1 SAY say_kolicina( ntIzlaz )
   @ PRow(), PCol() + 1 SAY say_kolicina( ntUlaz - ntIzlaz )

   nCol1 := PCol() + 1


   // NV
   @ PRow(), PCol() + 1 SAY say_kolicina( ntNVU )
   @ PRow(), PCol() + 1 SAY say_kolicina( ntNVI )
   @ PRow(), PCol() + 1 SAY say_kolicina( ntNV )

   IF cDoNab == "N"
      IF _vpc_iz_sif == "D"
         // PV - samo u pdv rezimu
         @ PRow(), PCol() + 1 SAY say_kolicina( ntVPVU )
         @ PRow(), PCol() + 1 SAY say_kolicina( ntRabat )
         @ PRow(), PCol() + 1 SAY say_kolicina( ntVPVI )
         @ PRow(), PCol() + 1 SAY say_kolicina( ntVPVU - NtVPVI )
      ELSE
         // PV - samo u pdv rezimu
         @ PRow(), PCol() + 1 SAY say_kolicina( ntVPVRU )
         @ PRow(), PCol() + 1 SAY say_kolicina( ntRabat )
         @ PRow(), PCol() + 1 SAY say_kolicina( ntVPVRI )
         @ PRow(), PCol() + 1 SAY say_kolicina( ntVPVRU - NtVPVRI )
      ENDIF
   ENDIF


   ? __line

   FF
   end_print()

   kalk_open_tables()
   o_kalk_pripr()

   IF fimagresaka
      MsgBeep( "Pogledajte artikle za koje je u izvjestaju stavljena oznaka ERR - GRESKA" )
   ENDIF

   IF fPocStanje
      IF fimagresaka .AND. Pitanje(, "Nulirati pripremu (radi ponavljanja procedure) ?", "D" ) == "D"
         SELECT kalk_pripr
         my_dbf_zap()
      ELSE
         renumeracija_kalk_pripr( cBrPst, "16" )
      ENDIF
   ENDIF


   IF lExpDbf == .T.
      open_r_export_table() // lansiraj report
   ENDIF


   my_close_all_dbf()

   RETURN .T.





// --------------------------------------
// export rpt, tbl fields
// --------------------------------------
STATIC FUNCTION g_exp_fields()

   LOCAL aDbf := {}

   AAdd( aDbf, { "IDROBA", "C", 10, 0 } )
   AAdd( aDbf, { "SIFRADOB", "C", 10, 0 } )
   AAdd( aDbf, { "NAZIV", "C", 40, 0 } )
   AAdd( aDbf, { "TARIFA", "C", 6, 0 } )
   AAdd( aDbf, { "JMJ", "C", 3, 0 } )
   AAdd( aDbf, { "ULAZ", "N", 15, 5 } )
   AAdd( aDbf, { "IZLAZ", "N", 15, 5 } )
   AAdd( aDbf, { "STANJE", "N", 15, 5 } )
   AAdd( aDbf, { "NVDUG", "N", 20, 10 } )
   AAdd( aDbf, { "NVPOT", "N", 20, 10 } )
   AAdd( aDbf, { "NV", "N", 15, 5 } )
   AAdd( aDbf, { "NC", "N", 15, 5 } )
   AAdd( aDbf, { "PVDUG", "N", 20, 10 } )
   AAdd( aDbf, { "PVPOT", "N", 20, 10 } )
   AAdd( aDbf, { "PVRDUG", "N", 20, 10 } )
   AAdd( aDbf, { "PVRPOT", "N", 20, 10 } )
   AAdd( aDbf, { "PV", "N", 15, 5 } )
   AAdd( aDbf, { "PC", "N", 15, 5 } )
   AAdd( aDbf, { "D_ULAZ", "D", 8, 0 } )
   AAdd( aDbf, { "D_IZLAZ", "D", 8, 0 } )

   RETURN aDbf


// ------------------------------------------------------------
// filovanje tabele exporta
// ------------------------------------------------------------
STATIC FUNCTION fill_exp_tbl( nVar, cIdRoba, cSifDob, cNazRoba, cTarifa, ;
      cJmj, nUlaz, nIzlaz, nSaldo, nNVDug, nNVPot, nNV, nNC, ;
      nPVDug, nPVPot, nPV, nPC, nPVrdug, nPVrpot, dL_ulaz, dL_izlaz )

   PushWa()

   IF nVar == nil
      nVar := 0
   ENDIF

   O_R_EXP

   APPEND BLANK

   REPLACE field->idroba WITH cIdRoba
   REPLACE field->sifradob WITH cSifDob
   REPLACE field->naziv WITH cNazRoba
   REPLACE field->tarifa WITH cTarifa
   REPLACE field->jmj WITH cJmj
   REPLACE field->ulaz WITH nUlaz
   REPLACE field->izlaz WITH nIzlaz
   REPLACE field->stanje WITH nSaldo
   REPLACE field->nvdug WITH nNVDug
   REPLACE field->nvpot WITH nNVPot
   REPLACE field->nv WITH nNV
   REPLACE field->nc WITH nNC

   IF cDoNab == "D"  // resetuj varijable
      nPVDug := 0
      nPVPot := 0
      nPV := 0
      nPC := 0
   ENDIF

   REPLACE field->pvdug WITH nPVDug
   REPLACE field->pvpot WITH nPVPot

   REPLACE field->pvrdug WITH nPVrDug
   REPLACE field->pvrpot WITH nPVrPot

   REPLACE field->pv WITH nPV
   REPLACE field->pc WITH nPC

   REPLACE field->d_ulaz WITH dL_ulaz
   REPLACE field->d_izlaz WITH dL_izlaz

   IF nVar == 1
      //
   ENDIF

   PopWa()

   RETURN .T.


// -------------------------------------------------------------
// setovanje linije i teksta
// -------------------------------------------------------------
STATIC FUNCTION _set_zagl( cLine, cTxt1, cTxt2, cTxt3, cSredCij )

   LOCAL aLLM := {}
   LOCAL nPom

   // r.br
   nPom := 7
   AAdd( aLLM, { nPom, PadC( "R.", nPom ), PadC( "br.", nPom ), PadC( "", nPom ) } )

   // artikl
   nPom := 10
   AAdd( aLLM, { nPom, PadC( "Artikal", nPom ), PadC( "", nPom ), PadC( "1", nPom ) } )

   // naziv
   nPom := 20
   AAdd( aLLM, { nPom, PadC( "Naziv", nPom ), PadC( "", nPom ), PadC( "2", nPom ) } )

   // jmj
   nPom := 3
   AAdd( aLLM, { nPom, PadC( "jmj", nPom ), PadC( "", nPom ), PadC( "3", nPom ) } )

   nPom := Len( global_pic_kolicina() )
   // ulaz
   AAdd( aLLM, { nPom, PadC( "ulaz", nPom ), PadC( "", nPom ), PadC( "4", nPom ) } )
   // izlaz
   AAdd( aLLM, { nPom, PadC( "izlaz", nPom ), PadC( "", nPom ), PadC( "5", nPom ) } )
   // stanje
   AAdd( aLLM, { nPom, PadC( "STANJE", nPom ), PadC( "", nPom ), PadC( "4 - 5", nPom ) } )



   // NV podaci
   // -------------------------------
   nPom := Len( global_pic_cijena() )
   // nv dug.
   AAdd( aLLM, { nPom, PadC( "NV.Dug.", nPom ), PadC( "", nPom ), PadC( "6", nPom ) } )
   // nv pot.
   AAdd( aLLM, { nPom, PadC( "NV.Pot.", nPom ), PadC( "", nPom ), PadC( "7", nPom ) } )
   // NV
   AAdd( aLLM, { nPom, PadC( "NV", nPom ), PadC( "NC", nPom ), PadC( "6 - 7", nPom ) } )

   IF cDoNab == "N"

      nPom := Len( global_pic_cijena() )
      // pv.dug
      AAdd( aLLM, { nPom, PadC( "PV.Dug.", nPom ), PadC( "", nPom ), PadC( "8", nPom ) } )
      // rabat
      AAdd( aLLM, { nPom, PadC( "Rabat", nPom ), PadC( "", nPom ), PadC( "9", nPom ) } )
      // pv pot.
      AAdd( aLLM, { nPom, PadC( "PV.Pot.", nPom ), PadC( "", nPom ), PadC( "10", nPom ) } )
      // PV
      AAdd( aLLM, { nPom, PadC( "PV", nPom ), PadC( "PC", nPom ), PadC( "8 - 10", nPom ) } )


   ENDIF


   IF cSredCij == "D"

      nPom := Len( global_pic_cijena() )
      // sredi cijene
      AAdd( aLLM, { nPom, PadC( "Sred.cij", nPom ), PadC( "", nPom ), PadC( "", nPom ) } )

   ENDIF

   cLine := SetRptLineAndText( aLLM, 0 )
   cTxt1 := SetRptLineAndText( aLLM, 1, "*" )
   cTxt2 := SetRptLineAndText( aLLM, 2, "*" )
   cTxt3 := SetRptLineAndText( aLLM, 3, "*" )

   RETURN .T.




FUNCTION Zagllager_lista_magacin()

   LOCAL nTArea := Select()

   Preduzece()

   P_COND2

   SELECT konto
   HSEEK cIdKonto

   SET CENTURY ON

   ?? "KALK: LAGER LISTA ZA PERIOD", dDatOd, "-", dDatdo, "  na dan", Date(), Space( 12 ), "Str:", Str( ++nTStrana, 4 )

   SET CENTURY OFF

   ? "Magacin:", cIdkonto, "-", AllTrim( konto->naz )
   IF !Empty( cRNT1 ) .AND. !Empty( cRNalBroj )
      ?? ", uslov radni nalog: " + AllTrim( cRNalBroj )
   ENDIF

   ? __line
   ? __txt1
   ? __txt2
   ? __txt3
   ? __line

   SELECT ( nTArea )

   RETURN .T.



/* kalk_pocetno_stanje_magacin_legacy()
 *     Generacija pocetnog stanja magacina
 */

FUNCTION kalk_pocetno_stanje_magacin_legacy()

   lager_lista_magacin( .T. )

   RETURN .T.


/* IsInGroup(cGr, cPodGr, cIdRoba)
 *     Provjerava da li artikal pripada odredjenoj grupi i podgrupi
 *   param: cGr - grupa
 *   param: cPodGr - podgrupa
 *   param: cIdRoba - id roba
 */
FUNCTION IsInGroup( cGr, cPodGr, cIdRoba )

   bRet := .F.

   IF Empty( cGr )
      RETURN .T.
   ENDIF

   IF AllTrim( IzSifKRoba( "GR1", cIdRoba, .F. ) ) $ AllTrim( cGr )
      bRet := .T.
   ELSE
      bRet := .F.
   ENDIF

   IF bRet
      IF !Empty( cPodGr )
         IF AllTrim( IzSifKRoba( "GR2", cIdRoba, .F. ) ) $ AllTrim( cPodGr )
            bRet := .T.
         ELSE
            bRet := .F.
         ENDIF
      ELSE
         bRet := .T.
      ENDIF
   ENDIF

   RETURN bRet



STATIC FUNCTION kalk_magacin_llm_odt( hParams )

   IF !_gen_xml( hParams )
      MsgBeep( "Problem sa generisanjem podataka ili nema podataka !" )
      RETURN
   ENDIF

   IF generisi_odt_iz_xml( "kalk_llm.odt", my_home() + "data.xml" )
      prikazi_odt()
   ENDIF

   RETURN


STATIC FUNCTION _gen_xml( hParams )

   LOCAL _idfirma := hParams[ "idfirma" ]
   LOCAL _sintk := hParams[ "idkonto" ]
   LOCAL _art_naz := hParams[ "roba_naz" ]
   LOCAL _group_1 := hParams[ "group_1" ]
   LOCAL _group_2 := hParams[ "group_2" ]
     LOCAL lPrikazatiNulaNV := hParams[ "nule" ]
   LOCAL _svodi_jmj := hParams[ "svodi_jmj" ]
   LOCAL _vpc_iz_sif := hParams[ "vpc_sif" ]
   LOCAL _idroba, _idkonto, _vpc_sif, _jmj
   LOCAL _rbr := 0
   LOCAL _t_ulaz_p := _t_izlaz_p := 0
   LOCAL _ulaz, _izlaz, _vpv_u, _vpv_i, _vpv_ru, _vpv_ri, _nv_u, _nv_i
   LOCAL _t_ulaz, _t_izlaz, _t_vpv_u, _t_vpv_i, _t_vpv_ru, _t_vpv_ri, _t_nv_u, _t_nv_i, _t_nv, _t_rabat
   LOCAL _rabat
   LOCAL _ok := .F.

   _t_ulaz := _t_izlaz := _t_nv_u := _t_nv_i := _t_vpv_u := _t_vpv_i := 0
   _t_rabat := _t_vpv_ru := _t_vpv_ri := _t_nv := 0

   SELECT konto
   HSEEK hParams[ "idkonto" ]

   SELECT kalk

   create_xml( my_home() + "data.xml" )
   xml_head()

   xml_subnode( "ll", .F. )

   // header
   xml_node( "dat_od", DToC( hParams[ "datum_od" ] ) )
   xml_node( "dat_do", DToC( hParams[ "datum_do" ] ) )
   xml_node( "dat", DToC( Date() ) )
   xml_node( "kid", to_xml_encoding( hParams[ "idkonto" ] ) )
   xml_node( "knaz", to_xml_encoding( AllTrim( konto->naz ) ) )
   xml_node( "fid", to_xml_encoding( self_organizacija_id() ) )
   xml_node( "fnaz", to_xml_encoding( self_organizacija_naziv() ) )
   xml_node( "tip", "MAGACIN" )

   DO WHILE !Eof() .AND. field->idfirma + field->mkonto = _idfirma + _sintk .AND. IspitajPrekid()

      _idroba := field->idroba

      _ulaz := 0
      _izlaz := 0

      _vpv_u := 0
      _vpv_i := 0

      _vpv_ru := 0
      _vpv_ri := 0

      _nv_u := 0
      _nv_i := 0

      _rabat := 0

      SELECT roba
      HSEEK _idroba

      IF ( !Empty( _art_naz ) .AND. At( AllTrim( _art_naz ), AllTrim( roba->naz ) ) == 0 )
         SELECT kalk
         SKIP
         LOOP
      ENDIF

      IF !Empty( _group_1 ) .OR. !Empty( _group_2 )
         IF !IsInGroup( _group_1, _group_2, roba->id )
            SELECT kalk
            SKIP
            LOOP
         ENDIF
      ENDIF

      SELECT kalk

      IF roba->tip $ "TUY"
         SKIP
         LOOP
      ENDIF

      _idkonto := field->mkonto

      DO WHILE !Eof() .AND. _idfirma + _idkonto + _idroba == field->idfirma + field->mkonto + field->idroba .AND. IspitajPrekid()

         IF roba->tip $ "TU"
            SKIP
            LOOP
         ENDIF

         IF field->mu_i == "1"
            IF !( field->idvd $ "12#22#94" )
               _kolicina := field->kolicina - field->gkolicina - field->gkolicin2
               _ulaz += _kolicina
               kalk_sumiraj_kolicinu( _kolicina, 0, @_t_ulaz_p, @_t_izlaz_p )
               IF koncij->naz == "P2"
                  _vpv_u += Round( roba->plc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
                  _vpv_ru += Round( roba->plc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
               ELSE
                  _vpv_u += Round( roba->vpc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
                  _vpv_ru += Round( field->vpc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
               ENDIF

               _nv_u += Round( nc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
            ELSE
               _kolicina := -field->kolicina
               _izlaz += _kolicina
               kalk_sumiraj_kolicinu( 0, _kolicina, @_t_ulaz_p, @_t_izlaz_p )
               IF koncij->naz == "P2"
                  _vpv_i -= Round( roba->plc * kolicina, gZaokr )
                  _vpv_ri -= Round( roba->plc * kolicina, gZaokr )
               ELSE
                  _vpv_i -= Round( roba->vpc * kolicina, gZaokr )
                  _vpv_ri -= Round( field->vpc * kolicina, gZaokr )
               ENDIF
               _nv_i -= Round( nc * kolicina, gZaokr )
            ENDIF

         ELSEIF field->mu_i == "5"
            _kolicina := field->kolicina
            _izlaz += _kolicina
            kalk_sumiraj_kolicinu( 0, _kolicina, @_t_ulaz_p, @_t_izlaz_p )
            IF koncij->naz == "P2"
               _vpv_i += Round( roba->plc * kolicina, gZaokr )
               _vpv_ri += Round( roba->plc * kolicina, gZaokr )
            ELSE
               _vpv_i += Round( roba->vpc * kolicina, gZaokr )
               _vpv_ri += Round( field->vpc * kolicina, gZaokr )
            ENDIF
            _rabat += Round(  rabatv / 100 * vpc * kolicina, gZaokr )
            _nv_i += Round( nc * kolicina, gZaokr )

         ELSEIF field->mu_i == "8"
            _kolicina := -field->kolicina
            _izlaz += _kolicina
            kalk_sumiraj_kolicinu( 0, _kolicina, @_t_ulaz_p, @_t_izlaz_p )
            IF koncij->naz == "P2"
               _vpv_i += Round( roba->plc * ( - kolicina ), gZaokr )
               _vpv_ri += Round( roba->plc * ( - kolicina ), gZaokr )
            ELSE
               _vpv_i += Round( roba->vpc * ( - kolicina ), gZaokr )
               _vpv_ri += Round( field->vpc * ( - kolicina ), gZaokr )
            ENDIF
            _rabat += Round(  rabatv / 100 * vpc * ( - kolicina ), gZaokr )
            _nv_i += Round( nc * ( - kolicina ), gZaokr )
            _kolicina := -field->kolicina
            _ulaz += _kolicina
            kalk_sumiraj_kolicinu( _kolicina, 0, @_t_ulaz_p, @_t_izlaz_p )

            IF koncij->naz == "P2"
               _vpv_u += Round( - roba->plc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
               _vpv_ru += Round( - roba->plc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
            ELSE
               _vpv_u += Round( - roba->vpc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
               _vpv_ru += Round( - field->vpc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
            ENDIF

            _nv_u += Round( - nc * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
         ENDIF

         SKIP

      ENDDO

      IF lPrikazatiNulaNV .OR. ( Round( _ulaz - _izlaz, 4 ) <> 0 .OR. Round( _nv_u - _nv_i, 4 ) <> 0 )

         xml_subnode( "items", .F. )

         xml_node( "rbr", AllTrim( Str( ++_rbr ) ) )
         xml_node( "id", to_xml_encoding( _idroba ) )
         xml_node( "naz", to_xml_encoding( AllTrim( roba->naz ) ) )
         xml_node( "tar", to_xml_encoding( AllTrim( roba->idtarifa ) ) )
         xml_node( "barkod", to_xml_encoding( AllTrim( roba->barkod ) ) )

         _jmj := roba->jmj
         _vpc_sif := roba->vpc
         _nc_sif := roba->nc

         IF _svodi_jmj
            _k_jmj := svedi_na_jedinicu_mjere( 1, _idroba, @_jmj )
            _jmj := PadR( _jmj, Len( roba->jmj ) )
         ELSE
            _k_jmj := 1
         ENDIF

         xml_node( "jmj", to_xml_encoding( _jmj ) )
         xml_node( "vpc", Str( _vpc_sif, 12, 3 ) )

         xml_node( "ulaz", Str( _k_jmj * _ulaz, 12, 3 )  )
         xml_node( "izlaz", Str( _k_jmj * _izlaz, 12, 3 )  )
         xml_node( "stanje", Str( _k_jmj * ( _ulaz - _izlaz ), 12, 3 )  )

         xml_node( "nvu", Str( _nv_u, 12, 3 )  )
         xml_node( "nvi", Str( _nv_i, 12, 3 )  )
         xml_node( "nv", Str( _nv_u - _nv_i, 12, 3 )  )

         _stanje := _k_jmj * ( _ulaz - _izlaz )
         __nv := ( _nv_u - _nv_i )

         IF Round( _stanje, 4 ) == 0 .OR. Round( __nv, 4 ) == 0
            _nc := 0
         ELSE
            _nc := Round( __nv / _stanje, 3 )
         ENDIF

         xml_node( "nc", Str( _nc, 12, 3 ) )

         IF _vpc_iz_sif
            xml_node( "vpvu", Str( _vpv_u, 12, 3 )  )
            xml_node( "rabat", Str( _rabat, 12, 3 )  )
            xml_node( "vpvi", Str( _vpv_i, 12, 3 )  )
            xml_node( "vpv", Str( _vpv_u - _vpv_i, 12, 3 )  )
         ELSE
            xml_node( "vpvu", Str( _vpv_ru, 12, 3 )  )
            xml_node( "rabat", Str( _rabat, 12, 3 )  )
            xml_node( "vpvi", Str( _vpv_ri, 12, 3 )  )
            xml_node( "vpv", Str( _vpv_ru - _vpv_ri, 12, 3 )  )
         ENDIF

         // kontrola !
         IF _nc_sif <> _nc
            xml_node( "err", "ERR" )
         ELSE
            xml_node( "err", "" )
         ENDIF

         xml_subnode( "items", .T. )

      ENDIF

      _t_ulaz += _k_jmj * _ulaz
      _t_izlaz += _k_jmj * _izlaz
      _t_rabat += _rabat
      _t_nv_u += _nv_u
      _t_nv_i += _nv_i
      _t_nv += ( _nv_u - _nv_i )
      _t_vpv_u += _vpv_u
      _t_vpv_i += _vpv_i
      _t_vpv_ru += _vpv_ru
      _t_vpv_ri += _vpv_ri

   ENDDO

   xml_node( "ulaz", Str( _t_ulaz, 12, 3 ) )
   xml_node( "izlaz", Str( _t_izlaz, 12, 3 ) )
   xml_node( "stanje", Str( _t_ulaz - _t_izlaz, 12, 3 ) )
   xml_node( "nvu", Str( _t_nv_u, 12, 3 ) )
   xml_node( "nvi", Str( _t_nv_i, 12, 3 ) )
   xml_node( "nv", Str( _t_nv, 12, 3 ) )

   IF _vpc_iz_sif
      xml_node( "vpvu", Str( _t_vpv_u, 12, 3 )  )
      xml_node( "rabat", Str( _t_rabat, 12, 3 )  )
      xml_node( "vpvi", Str( _t_vpv_i, 12, 3 )  )
      xml_node( "vpv", Str( _t_vpv_u - _t_vpv_i, 12, 3 )  )
   ELSE
      xml_node( "vpvu", Str( _t_vpv_ru, 12, 3 )  )
      xml_node( "rabat", Str( _t_rabat, 12, 3 )  )
      xml_node( "vpvi", Str( _t_vpv_ri, 12, 3 )  )
      xml_node( "vpv", Str( _t_vpv_ru - _t_vpv_ri, 12, 3 )  )
   ENDIF

   xml_subnode( "ll", .T. )

   close_xml()

   my_close_all_dbf()

   IF _rbr > 0
      _ok := .T.
   ENDIF

   RETURN _ok


// ---------------------------------
// tabele potrebne za report
// ---------------------------------
STATIC FUNCTION kalk_open_tables()

   o_sifk()
   o_sifv()
   //o_roba()
   IF o_koncij()
      ?E "open koncij ok"
   ELSE
      ?E "open koncij ERROR?!"
   ENDIF
   IF o_konto()
      ?E "open konto"
   ELSE
      ?E "open konto ERROR"
   ENDIF
   IF o_partner()
      ?E "open partn ok"
   ELSE
      ?E "open partn error"
   ENDIF

   RETURN .T.
