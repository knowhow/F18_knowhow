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


FUNCTION fin_stampa_liste_naloga()

   LOCAL nDug := 0.00
   LOCAL nPot := 0.00
   LOCAL nPos := 15

   cInteg := "N"
   nSort := 1

   cIdVN := "  "

   Box(, 7, 60 )
   @ m_x + 1, m_Y + 2 SAY "Provjeriti integritet podataka"
   @ m_x + 2, m_Y + 2 SAY "u odnosu na datoteku naloga D/N ?"  GET cInteg  PICT "@!" VALID cinteg $ "DN"
   @ m_x + 4, m_Y + 2 SAY "Sortiranje dokumenata po:  1-(firma,vn,brnal) "
   @ m_x + 5, m_Y + 2 SAY "2-(firma,brnal,vn),    3-(datnal,firma,vn,brnal) " GET nSort PICT "9"
   @ m_x + 7, m_Y + 2 SAY "Vrsta naloga (prazno-svi) " GET cIDVN PICT "@!"
   READ
   ESC_BCR
   BoxC()

   O_NALOG
   IF cinteg == "D"
      O_SUBAN
      SET ORDER TO TAG "4"

      O_ANAL
      SET ORDER TO TAG "2"

      O_SINT
      SET ORDER TO TAG "2"

   ENDIF

   SELECT NALOG
   SET ORDER TO nSort
   GO TOP

   nBrNalLen := Len( field->brnal )

   EOF CRET

   START PRINT CRET

   m := "---- --- --- " + Replicate( "-", nBrNalLen + 1 ) + " -------- ---------------- ----------------"

   IF gVar1 == "0"
      m += " ------------ ------------"
   ENDIF

   IF FieldPos( "SIFRA" ) <> 0
      m += " ------"
   ENDIF

   IF cInteg == "D"
      m := m + " ---  --- ----"
   ENDIF

   nRBr := 0

   nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0

   picBHD := "@Z " + FormPicL( gPicBHD, 16 )
   picDEM := "@Z " + FormPicL( gPicDEM, 12 )

   DO WHILE !Eof()

      IF PRow() == 0
         ?
         IF gVar1 == "0"
            P_COND
         ELSE
            F10CPI
         ENDIF

         ?? "LISTA FIN. DOKUMENATA (NALOGA) NA DAN:", Date()
         ? m
         ? "*RED*FIR* V *" + PadR( " BR", nBrNalLen + 1 ) + "* DAT    *   DUGUJE       *   POTRAZUJE    *" + IF( gVar1 == "0", "   DUGUJE   * POTRAZUJE *", "" )

         IF FieldPos( "SIFRA" ) <> 0
            ?? "  OP. *"
         ENDIF

         IF cInteg == "D"
            ?? "  1  * 2 * 3 *"
         ENDIF

         ? "*BRD*MA * N *" + PadR( " NAL", nBrNalLen + 1 ) + "* NAL    *    " + ValDomaca() + "        *      " + ValDomaca() + "      *"

         IF gVar1 == "0"
            ?? "    " + ValPomocna() + "    *    " + ValPomocna() + "   *"
         ENDIF

         IF FieldPos( "SIFRA" ) <> 0
            ?? "      *"
         ENDIF

         IF cInteg == "D"
            ?? "     *   *   *"
         ENDIF

         IF FieldPos( "SIFRA" ) <> 0
         ENDIF
         ? m
      ENDIF

      IF !Empty( cIdVN ) .AND. idvn <> cIDVN
         SKIP
         LOOP
      ENDIF

      NovaStrana()

      @ PRow() + 1, 0 SAY ++nRBr PICTURE "9999"
      @ PRow(), PCol() + 2 SAY IdFirma
      @ PRow(), PCol() + 2 SAY IdVN
      @ PRow(), PCol() + 2 SAY BrNal
      @ PRow(), PCol() + 1 SAY DatNal
      @ PRow(), nPos := PCol() + 1 SAY DugBHD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY PotBHD PICTURE picBHD
      IF gVar1 == "0"
         @ PRow(), PCol() + 1 SAY DugDEM PICTURE picDEM
         @ PRow(), PCol() + 1 SAY PotDEM PICTURE picDEM
      ENDIF
      IF FieldPos( "SIFRA" ) <> 0
         @ PRow(), PCol() + 1 SAY iif( Empty( sifra ), Space( 2 ), Left( Crypt( sifra ), 2 ) )
      ENDIF
      IF cInteg == "D"

         SELECT SUBAN; SEEK NALOG->( IDFirma + Idvn + Brnal )
         nDug := 0.00; nPot := 0.00
         DO WHILE ( IDFirma + Idvn + Brnal ) == NALOG->( IDFirma + Idvn + Brnal )  .AND. !Eof()
            IF d_p = "1"
               nDug += iznosbhd
            ELSE
               nPot += iznosbhd
            ENDIF
            SKIP
         ENDDO
         SELECT NALOG
         IF Str( nDug, 20, 2 ) == Str( DugBHd, 20, 2 ) .AND. Str( nPot, 20, 2 ) == Str( PotBHD, 20, 2 )
            ?? "     "
         ELSE
            ?? " ERR "
         ENDIF
         SELECT ANAL
         SEEK NALOG->( IDFirma + Idvn + Brnal )
         nDug := 0.00; nPot := 0.00
         DO WHILE ( IDFirma + Idvn + Brnal ) == NALOG->( IDFirma + Idvn + Brnal ) .AND. !Eof()
            nDug += dugbhd
            nPot += potbhd
            SKIP
         ENDDO
         SELECT NALOG
         IF Str( nDug, 20, 2 ) == Str( DugBHd, 20, 2 ) .AND. Str( nPot, 20, 2 ) == Str( PotBHD, 20, 2 )
            ?? "     "
         ELSE
            ?? " ERR "
         ENDIF
         SELECT SINT
         SEEK NALOG->( IDFirma + Idvn + Brnal )
         nDug := 0.00; nPot := 0.00
         DO WHILE ( IDFirma + Idvn + Brnal ) == NALOG->( IDFirma + Idvn + Brnal ) .AND. !Eof()
            nDug += dugbhd
            nPot += potbhd
            SKIP
         ENDDO
         SELECT NALOG
         IF Str( nDug, 20, 2 ) == Str( DugBHd, 20, 2 ) .AND. Str( nPot, 20, 2 ) == Str( PotBHD, 20, 2 )
            ?? "     "
         ELSE
            ?? " ERR "
         ENDIF

      ENDIF

      nDugBHD += DugBHD
      nPotBHD += PotBHD
      nDugDEM += DugDEM
      nPotDEM += PotDEM
      SKIP
   ENDDO
   NovaStrana()

   ? m
   ? "UKUPNO:"

   @ PRow(), nPos SAY nDugBHD PICTURE picBHD
   @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD

   IF gVar1 == "0"
      @ PRow(), PCol() + 1 SAY nDugDEM PICTURE picDEM
      @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picDEM
   ENDIF

   ? m

   FF
   ENDPRINT

   RETURN

// --------------------------------------------------
// izvjestaj "Dnevnik naloga"
// --------------------------------------------------
FUNCTION DnevnikNaloga()

   LOCAL cMjGod := ""
   LOCAL _filter := ""
   PRIVATE fK1 := fetch_metric( "dnevnik_naloga_fk1", my_user(), "N" )
   PRIVATE fK2 := fetch_metric( "dnevnik_naloga_fk2", my_user(), "N" )
   PRIVATE fK3 := fetch_metric( "dnevnik_naloga_fk3", my_user(), "N" )
   PRIVATE fK4 := fetch_metric( "dnevnik_naloga_fk4", my_user(), "N" )
   PRIVATE gnLOst := fetch_metric( "dnevnik_naloga_otv_stavke", my_user(), 0 )
   PRIVATE gPotpis := fetch_metric( "dnevnik_naloga_potpis", my_user(), "N" )
   PRIVATE nColIzn := 20

   dOd := CToD( "01.01." + Str( Year( Date() ), 4 ) )
   dDo := Date()

   SET KEY K_F5 TO VidiNaloge()

   Box(, 3, 77 )
   @ m_x + 4, m_y + 30   SAY "<F5> - sredjivanje datuma naloga"
   @ m_x + 2, m_y + 2    SAY "Obuhvatiti naloge u periodu od" GET dOd
   @ m_x + 2, Col() + 2 SAY "do" GET dDo VALID dDo >= dOd
   READ
   ESC_BCR
   BoxC()

   SET KEY K_F5 TO

   O_VRSTEP
   O_TNAL
   O_TDOK
   O_PARTN
   O_KONTO
   O_NALOG
   O_SUBAN


   SELECT SUBAN
   SET ORDER TO TAG "4"
   SELECT NALOG
   SET ORDER TO TAG "3"

   IF !Empty( dOd ) .OR. !Empty( dDo )

      _filter := "datnal >= " + _filter_quote( dOd )
      _filter += " .and. "
      _filter += "datnal <= " + _filter_quote( dDo )

      SET FILTER TO &_filter

   ENDIF

   GO TOP

   START PRINT CRET

   nUkDugBHD := nUkPotBHD := nUkDugDEM := nUkPotDEM := 0  // sve strane ukupno

   nStr := 0
   nRbrDN := 0
   cIdFirma := IDFIRMA; cIdVN := IDVN; cBrNal := BRNAL; dDatNal := DATNAL

   PicBHD := "@Z " + FormPicL( gPicBHD, 15 )
   PicDEM := "@Z " + FormPicL( gPicDEM, 10 )

   lJerry := .F.

   IF gNW == "N"
      M := "------ -------------- --- " + "---- ------- " + REPL( "-", FIELD_PARTNER_ID_LENGTH ) + " ----------------------------" + IF( gVar1 == "1" .AND. lJerry, "-- " + REPL( "-", 20 ), "" ) + " -- ------------- ----------- -------- -------- --------------- ---------------" + IF( gVar1 == "1", "-", " ---------- ----------" )
   ELSE
      M := "------ -------------- --- " + "---- ------- " + REPL( "-", FIELD_PARTNER_ID_LENGTH ) + " ----------------------------" + IF( gVar1 == "1" .AND. lJerry, "-- " + REPL( "-", 20 ), "" ) + " ----------- -------- -------- --------------- ---------------" + IF( gVar1 == "1", "-", " ---------- ----------" )
   ENDIF

   cMjGod := Str( Month( dDatNal ), 2 ) + Str( Year( dDatNal ), 4 )

   fin_nalog_zaglavlje( dDatNal )

   nTSDugBHD := nTSPotBHD := nTSDugDEM := nTSPotDEM := 0   // tekuca strana

   DO WHILE !Eof()

      IF PRow() < 6  // nije odstampano zaglavlje
            fin_nalog_zaglavlje( dDatNal )
      ENDIF

      cIdFirma := IDFIRMA
      cIdVN    := IDVN
      cBrNal   := BRNAL
      dDatNal  := DATNAL

      IF cMjGod != Str( Month( dDatNal ), 2 ) + Str( Year( dDatNal ), 4 )
         // završi stranu
         PrenosDNal()
         // stampaj zaglavlje (nova stranica)
         fin_nalog_zaglavlje( dDatNal )
      ENDIF

      cMjGod := Str( Month( dDatNal ), 2 ) + Str( Year( dDatNal ), 4 )

      SELECT SUBAN
      HSEEK cIdFirma + cIdVN + cBrNal

      fin_nalog_stampa( "3", NIL, dDatNal )

      SELECT NALOG

      SKIP 1
   ENDDO

   IF PRow() > 5  // znaci da je pocela nova stranica tj.odstampano je zaglavlje
      PrenosDNal()
   ENDIF

   ENDPRINT

   my_close_all_dbf()

   RETURN



/*! \fn NazMjeseca(nMjesec)
 *  \brief Vraca naziv mjeseca za zadati nMjesec (np. 1 => Januar)
 *  \param nMjesec - oznaka mjeseca - integer
 */

FUNCTION NazMjeseca( nMjesec )

   LOCAL aVrati := { "Januar", "Februar", "Mart", "April", "Maj", "Juni", "Juli", ;
      "Avgust", "Septembar", "Oktobar", "Novembar", "Decembar" }

   RETURN IF( nMjesec > 0 .AND. nMjesec < 13, aVrati[ nMjesec ], "" )



/*! \fn VidiNaloge()
 *  \brief Pregled naloga
 */

FUNCTION VidiNaloge()

   LOCAL i

   O_NALOG
   SET ORDER TO TAG "3"
   GO TOP

   ImeKol := { ;
      { "Firma",         {|| IDFIRMA }, "IDFIRMA" },;
      { "Vrsta naloga",  {|| IDVN    }, "IDVN"    },;
      { "Broj naloga",   {|| BRNAL   }, "BRNAL"   },;
      { "Datum naloga",  {|| DATNAL  }, "DATNAL"  } ;
      }

   Kol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   Box(, 20, 45 )
   my_db_edit( "Nal", MAXROWS() -10, 50, {|| EdNal() }, "<Enter> - ispravka", "Nalozi...", , , , , )
   BoxC()

   CLOSERET

   RETURN


/*! \fn EdNal()
 *  \brief Ispravka datuma na nalogu
 */

FUNCTION EdNal()

   LOCAL nVrati := DE_CONT, dDatNal := NALOG->datnal, GetList := {}

   IF ( Ch == K_ENTER )

      Box(, 4, 77 )
      @ m_x + 2, m_y + 2 SAY "Stari datum naloga: " + DToC( dDatNal )
      @ m_x + 3, m_y + 2 SAY "Novi datum naloga :" GET dDatNal
      READ
      BoxC()

      IF LastKey() != K_ESC

         SELECT NALOG
         _rec := dbf_get_rec()
         _rec[ "datnal" ] := dDatNal
         dbf_update_rec( _rec )

         nVrati := DE_REFRESH
      ENDIF

   ENDIF

   RETURN nVrati
