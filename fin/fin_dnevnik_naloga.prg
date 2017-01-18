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

MEMVAR M
MEMVAR nUkDugBHD, nUkPotBHD, nUkDugDEM, nUkPotDEM


FUNCTION DnevnikNaloga()

   LOCAL cMjGod := ""
   LOCAL _filter := ""
   LOCAL dOd, dDo

   PRIVATE nUkDugBHD, nUkPotBHD, nUkDugDEM, nUkPotDEM

   PRIVATE fK1 := fetch_metric( "dnevnik_naloga_fk1", my_user(), "N" )
   PRIVATE fK2 := fetch_metric( "dnevnik_naloga_fk2", my_user(), "N" )
   PRIVATE fK3 := fetch_metric( "dnevnik_naloga_fk3", my_user(), "N" )
   PRIVATE fK4 := fetch_metric( "dnevnik_naloga_fk4", my_user(), "N" )
   PRIVATE gnLOst := fetch_metric( "dnevnik_naloga_otv_stavke", my_user(), 0 )
   PRIVATE gPotpis := fetch_metric( "dnevnik_naloga_potpis", my_user(), "N" )


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
   o_tnal()
   o_tdok()
   O_PARTN
   O_KONTO
   o_nalog()
   o_suban()


   SELECT SUBAN
   SET ORDER TO TAG "4"

   SELECT NALOG
   SET ORDER TO TAG "3" //nalog

   IF !Empty( dOd ) .OR. !Empty( dDo )

      _filter := "datnal >= " + _filter_quote( dOd )
      _filter += " .and. "
      _filter += "datnal <= " + _filter_quote( dDo )

      SET FILTER TO &_filter

   ENDIF

   GO TOP

   IF !start_print()
      RETURN .F.
   ENDIF

   nUkDugBHD := nUkPotBHD := nUkDugDEM := nUkPotDEM := 0  // sve strane ukupno

   nStr := 0
   nRbrDN := 0
   cIdFirma := IDFIRMA; cIdVN := IDVN; cBrNal := BRNAL; dDatNal := DATNAL

   PicBHD := "@Z " + FormPicL( gPicBHD, 15 )
   PicDEM := "@Z " + FormPicL( gPicDEM, 10 )

   lJerry := .F.

   IF gNW == "N"
      M := "------ -------------- --- " + "---- ------- " + REPL( "-", FIELD_PARTNER_ID_LENGTH ) + " ----------------------------" + IF( fin_jednovalutno() .AND. lJerry, "-- " + REPL( "-", 20 ), "" ) + " -- ------------- ----------- -------- -------- --------------- ---------------" + IF( fin_jednovalutno(), "-", " ---------- ----------" )
   ELSE
      M := "------ -------------- --- " + "---- ------- " + REPL( "-", FIELD_PARTNER_ID_LENGTH ) + " ----------------------------" + IF( fin_jednovalutno() .AND. lJerry, "-- " + REPL( "-", 20 ), "" ) + " ----------- -------- -------- --------------- ---------------" + IF( fin_jednovalutno(), "-", " ---------- ----------" )
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

         PrenosDNal() // završi stranu

         fin_nalog_zaglavlje( dDatNal ) // stampaj zaglavlje (nova stranica)
      ENDIF

      cMjGod := Str( Month( dDatNal ), 2 ) + Str( Year( dDatNal ), 4 )

      SELECT SUBAN
      HSEEK cIdFirma + cIdVN + cBrNal

      fin_nalog_stampa_fill_psuban( "3", NIL, dDatNal )

      SELECT NALOG

      SKIP 1
   ENDDO

   IF PRow() > 5  // znaci da je pocela nova stranica tj.odstampano je zaglavlje
      PrenosDNal()
   ENDIF

   end_print()

   my_close_all_dbf()

   RETURN .T.



/* NazMjeseca(nMjesec)
 *   Vraca naziv mjeseca za zadati nMjesec (np. 1 => Januar)
 *   param: nMjesec - oznaka mjeseca - integer
 */

FUNCTION NazMjeseca( nMjesec )

   LOCAL aVrati := { "Januar", "Februar", "Mart", "April", "Maj", "Juni", "Juli", ;
      "Avgust", "Septembar", "Oktobar", "Novembar", "Decembar" }

   RETURN IIF( nMjesec > 0 .AND. nMjesec < 13, aVrati[ nMjesec ], "" )



/* VidiNaloge
 *  Pregled naloga
 */

FUNCTION VidiNaloge()

   LOCAL i

   o_nalog()
   SET ORDER TO TAG "3" //nalog
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

   RETURN .T.


/*
 * Ispravka datuma na nalogu
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
