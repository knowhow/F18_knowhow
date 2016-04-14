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

STATIC cIdPos


STATIC FUNCTION GetPm()

   LOCAL cPm
   LOCAL cPitanje

   cPm := cIdPos

   cPitanje := my_get_from_ini( "POS", "PrenosGetPm", "0" )
   IF ( ( gVrstaRs <> "S" ) .AND. ( cPitanje == "0" ) )
      RETURN ""
   ENDIF


   IF ( gVrstaRs == "S" ) .OR. ( ( cPitanje == "D" ) .OR. Pitanje(, "Postaviti oznaku prodajnog mjesta? (D/N)", "N" ) == "D" )
      Box(, 1, 30 )
      SET CURSOR ON
      @ m_x + 1, m_Y + 2 SAY "Oznaka prodajnog mjesta:" GET cPm
      READ
      BoxC()
   ENDIF

   RETURN cPm




/* Real2Fakt()
 *     Prenos realizacije u FAKT
 */

FUNCTION Real2Fakt()

   // {

   O_ROBA
   O_SIFK
   O_SIFV
   O_PARTN
   O_KASE
   o_pos_pos()
   o_pos_doks()

   cIdPos := gIdPos
   dDatOd := Date()
   dDatDo := Date()
   cIdPartnG := Space( Len( partn->id ) )
   cBezCijena := "D"

   SET CURSOR ON

   Box( "#PRENOS REALIZACIJE POS->FAKT", 6, 70 )
   @ m_x + 2, m_y + 2 SAY "Prodajno mjesto " GET cIdPos PICT "@!" VALID !Empty( cIdPos ) .OR. P_Kase( @cIdPos, 2, 25 )
   @ m_x + 3, m_y + 2 SAY "Partner gotovinski " GET cIdPartnG PICT "@!" VALID Empty( cIdPartnG ) .OR. P_Firma( @cIdPartnG, 3, 28 )
   @ m_x + 4, m_y + 2 SAY "Prenos bez cijene i rabata? (D/N)" GET cBezCijena VALID cBezCijena $ "DN" PICT "@!"
   @ m_x + 5, m_y + 2 SAY "Prenos za period" GET dDatOd
   @ m_x + 5, Col() + 2 SAY "-" GET dDatDo
   READ
   ESC_BCR
   BoxC()

   IF gVrstaRS <> "S"
      cIdPos := gIdPos
   ELSE
      // ako je server
      gIdPos := cIdPos
   ENDIF

   SELECT pos_doks
   SET ORDER TO TAG "2"  // IdVd+DTOS (Datum)+Smjena
   SEEK VD_RN + DToS( dDatOd )

   IF Eof()
      MsgBeep( "Nema nista za prenos!" )
      CLOSERET
   ELSE
      IF !Empty( cIdPartnG )
         SELECT partn
         HSEEK cIdPartnG
         cIdPartnG := partn->idfmk
      ELSE
         cIdPartnG := Space( Len( partn->idfmk ) )
      ENDIF
   ENDIF

   PripTOPSFAKT( cIdPartnG )

   SELECT pos_doks
   nRbr := 0

   DO WHILE !Eof() .AND. pos_doks->IdVd == VD_RN .AND. pos_doks->Datum <= dDatDo

      IF !Empty( cIdPos ) .AND. pos_doks->IdPos <> cIdPos
         SKIP
         LOOP
      ENDIF

      SELECT pos
      SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

      DO WHILE !Eof() .AND. pos->( IdPos + IdVd + DToS( datum ) + BrDok ) == pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )
         Scatter()
         SELECT topsfakt
         cIdRoba := pos->idRoba
         nKolicina := pos->kolicina
         nPCijena := pos->cijena
         nPopustCij := pos->nCijena

         IF cBezCijena == "D"
            nPCijena := nPopustCij := 0
         ENDIF
         cIdRoba := PadR( cIdRoba, Len( topsfakt->idRoba ) )
         IF pos_doks->placen <> "Z" // sve sto nije "Z" gotovina je
            cIdPartner := cIdPartnG
            cIdVd := "12"
         ELSE
            cIdPartner := Ocitaj( F_RNGOST, pos_doks->idGost, "idfmk" )
            cIdVd := "10"
         ENDIF


         HSEEK POS->idPos + cIdVd + cIdPartner + cIdRoba + Str( nPCijena, 13, 4 ) + Str( nPopustCij, 13, 4 )
         // seekuj i cijenu i popust (koji je pohranjen u ncijena)
         IF !Found() // .or.idTarifa<>POS->idTarifa
            APPEND BLANK
            REPLACE idPos WITH POS->idPos
            REPLACE idRoba WITH cIdRoba
            REPLACE kolicina WITH nKolicina
            REPLACE idTarifa WITH POS->idTarifa
            REPLACE mpc WITH nPCijena
            REPLACE datum WITH dDatDo
            REPLACE idVd WITH cIdVd
            REPLACE idPartner WITH cIdPartner
            REPLACE stMPC WITH nPopustCij
            ++nRbr
         ELSE
            REPLACE kolicina WITH Kolicina + nKolicina
         ENDIF
         SELECT pos
         SKIP 1
      ENDDO
      SELECT pos_doks
      SKIP 1
   ENDDO

   CLOSE ALL

   cLokacija := PadR( "A:" + SLASH, 40 )
   Box( "#DEFINISANJE LOKACIJE ZA PRENOS DATOTEKE TOPSFAKT", 5, 70 )
   @ m_x + 2, m_y + 2 SAY "Datoteka TOPSFAKT je izgenerisana. Broj stavki:" + Str( nRbr, 4 )
   @ m_x + 4, m_y + 2 SAY "Lokacija za prenos je:" GET cLokacija
   READ
   IF LastKey() <> K_ESC
      SAVE SCREEN TO cS
      cPom := "copy " + PRIVPATH + "TOPSFAKT.DBF " + Trim( cLokacija ) + "TOPSFAKT.DBF"
      f18_run( cPom )
      cPom := "copy " + PRIVPATH + "TOPSFAKT.CDX " + Trim( cLokacija ) + "TOPSFAKT.CDX"
      f18_run( cPom )
      RESTORE SCREEN FROM cS
   ENDIF
   BoxC()

   CLOSERET

   RETURN
// }


FUNCTION PripTOPSFAKT( cIdPartnG )

   aDbf := {}
   AAdd( aDBF, { "IdPos", "C", 2, 0 } )
   AAdd( aDBF, { "IDROBA", "C", 10, 0 } )
   AAdd( aDBF, { "IDPARTNER", "C", Len( cIdPartnG ), 0 } )
   AAdd( aDBF, { "kolicina", "N", 13, 4 } )
   AAdd( aDBF, { "MPC", "N", 13, 4 } )
   AAdd( aDBF, { "STMPC", "N", 13, 4 } )
   // stmpc - kod dokumenta tipa 42 koristi se za iznos popusta !!
   AAdd( aDBF, { "IDTARIFA", "C", 6, 0 } )
   AAdd( aDBF, { "DATUM", "D", 8, 0 } )
   AAdd( aDBF, { "IdVd", "C", 2, 0 } )
   AAdd( aDBF, { "M1", "C", 1, 0 } )

   NaprPom( aDbf, "TOPSFAKT" )

   SELECT 7000
   USE
   my_use ( "topsfakt", "TOPSFAKT" )
   INDEX ON IdPos + idVd + idPartner + IdRoba + Str( mpc, 13, 4 ) + Str( stmpc, 13, 4 ) TAG ( "1" ) TO ( PRIVPATH + "TOPSFAKT" )
   INDEX ON brisano + "10" TAG "BRISAN"    // TO (PRIVPATH+"ZAKSM")
   SET ORDER TO TAG "1"

   RETURN .T.





/* Stanje2Fakt()
 *     Prenos stanja robe u FAKT
 */

FUNCTION Stanje2Fakt()

   O_ROBA
   O_SIFK
   O_SIFV
   O_PARTN
   O_KASE
   o_pos_pos()
   o_pos_doks()

   cIdPos := gIdPos
   dDatOd := CToD( "" )
   dDatDo := Date()
   cIdPartnG := Space( Len( partn->id ) )

   SET CURSOR ON

   Box( "#PRENOS STANJA ROBE POS->FAKT", 5, 70 )
   @ m_x + 2, m_y + 2 SAY "Prodajno mjesto " GET cIdPos PICT "@!" VALID !Empty( cIdPos ) .OR. P_Kase( @cIdPos, 2, 25 )
   @ m_x + 3, m_y + 2 SAY "Partner/dost.vozilo " GET cIdPartnG PICT "@!" VALID Empty( cIdPartnG ) .OR. P_Firma( @cIdPartnG, 3, 28 )
   @ m_x + 4, m_y + 2 SAY "Stanje robe na dan" GET dDatDo
   READ
   ESC_BCR
   BoxC()

   IF gVrstaRS <> "S"
      cIdPos := gIdPos
   ELSE
      // ako je server
      gIdPos := cIdPos
   ENDIF

   IF !Empty( cIdPartnG )
      SELECT partn
      HSEEK cIdPartnG
      cIdPartnG := partn->idfmk
   ELSE
      cIdPartnG := Space( Len( partn->idfmk ) )
   ENDIF

   PripTOPSFAKT( cIdPartnG )


   // ------------------------------------------------------------------

   SELECT POS

   // ("2", "IdOdj+idroba+DTOS(Datum)", KUMPATH+"POS")
   SET ORDER TO TAG "2"

   GO TOP

   cIdOdj := Space( 2 )
   cZaduzuje := "R"
   nRBr := 0
   SEEK cIdOdj
   // do while !eof()
   // cIdOdj:=IdOdj
   DO WHILE !Eof() .AND. POS->IdOdj == cIdOdj
      nStanje := 0
      nVrijednost := 0
      nUlaz := nIzlaz := 0
      cIdRoba := POS->IdRoba
      nUlaz := nIzlaz := nVrijednost := 0
      SELECT pos
      DO WHILE !Eof() .AND. POS->IdOdj == cIdOdj .AND. POS->IdRoba == cIdRoba
         IF ( !pos_admin() .AND. pos->idpos = "X" ) .OR. ( !Empty( cIdPos ) .AND. IdPos <> cIdPos )
            SKIP
            LOOP
         ENDIF

         IF cZaduzuje == "S" .AND. pos->idvd $ "42#01"
            // racuni za sirovine - zdravo
            SKIP
            LOOP
         ENDIF
         IF cZaduzuje == "R" .AND. pos->idvd == "96"
            // otpremnice za robu - zdravo
            SKIP
            LOOP
         ENDIF

         IF POS->idvd $ "16#00"
            nUlaz += POS->Kolicina
            nVrijednost += POS->Kolicina * POS->Cijena
         ELSEIF POS->idvd $ "42#01#IN#NI#96"
            DO CASE
            CASE POS->IdVd == "IN"
               nIzlaz += ( POS->Kolicina - POS->Kol2 )
               nVrijednost -= ( POS->Kol2 - POS->Kolicina ) * POS->Cijena
            CASE POS->IdVd == VD_NIV
               // ne mijenja kolicinu
               nVrijednost := POS->Kolicina * POS->Cijena
            OTHERWISE
               // 42#01
               nIzlaz += POS->Kolicina
               nVrijednost -= POS->Kolicina * POS->Cijena
            ENDCASE
         ENDIF
         SKIP
      ENDDO


      SELECT roba
      SEEK cIdRoba
      SELECT topsfakt
      nKolicina := nUlaz - nIzlaz
      cIdRoba := PadR( cIdRoba, Len( topsfakt->idRoba ) )
      cIdPartner := cIdPartnG
      cIdVd := "12"
      IF Round( nKolicina, 4 ) <> 0
         APPEND BLANK
         REPLACE idPos WITH cIdPos
         REPLACE idRoba WITH cIdRoba
         REPLACE kolicina WITH nKolicina
         REPLACE idTarifa WITH roba->idTarifa
         REPLACE mpc WITH pos_get_mpc()
         REPLACE datum WITH dDatDo
         REPLACE idVd WITH cIdVd
         REPLACE idPartner WITH cIdPartner
         REPLACE stMpc WITH 0
         ++nRbr
      ENDIF
      SELECT pos

   ENDDO

   // ------------------------------------------------------------------

   CLOSE ALL

   cLokacija := PadR( "A:\", 40 )
   Box( "#DEFINISANJE LOKACIJE ZA PRENOS DATOTEKE TOPSFAKT", 5, 70 )
   @ m_x + 2, m_y + 2 SAY "Datoteka TOPSFAKT je izgenerisana. Broj stavki:" + Str( nRbr, 4 )
   @ m_x + 4, m_y + 2 SAY "Lokacija za prenos je:" GET cLokacija
   READ
   IF LastKey() <> K_ESC
      SAVE SCREEN TO cS
      cPom := "copy " + PRIVPATH + "TOPSFAKT.DBF " + Trim( cLokacija ) + "TOPSFAKT.DBF"
      f18_run( cPom )
      cPom := "copy " + PRIVPATH + "TOPSFAKT.CDX " + Trim( cLokacija ) + "TOPSFAKT.CDX"
      f18_run( cPom )
      RESTORE SCREEN FROM cS
   ENDIF
   BoxC()

   CLOSERET

   RETURN
// }
