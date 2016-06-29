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


#include "f18.ch"

/*

// prenos tops->kalk 96 po normativima
FUNCTION tops_nor_96( cIdFirma, cIdTipDok, cIdZaduz2, cIdKonto2, cIdKonto, ;
      dDatKalk, dD_from, dD_to, cArtfilter, cTopsKonto, cSezSif, cSirovina )

   LOCAL lTest := .F.
   LOCAL cTSifPath
   LOCAL cTKumPath
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )

   IF PCount() == 0
      cIdFirma := gFirma
      cIdTipDok := PadR( "42;", 20 )
      cIdZaduz2 := Space( 6 )
      cIdkonto2 := PadR( "1310", 7 )
      cIdKonto := PadR( "", 7 )
      dDatKalk := Date()
      cSirovina := ""
   ELSE
      lTest := .T.
   ENDIF

   o_kalk_pripr()
   o_koncij()
   -- o_kalk()
   O_KONTO
   O_PARTN
   O_TARIFA


   IF lTest == .T.

      my_close_all_dbf()

      cSifPath := PadR( SIFPATH, 14 )
      // "c:\sigma\sif1\"

      IF !Empty( cSezSif ) .AND. cSezSif <> "RADP"
         cSifPath += cSezSif + SLASH
      ENDIF

      SELECT ( F_ROBA )
      USE
      SELECT ( F_ROBA )
      USE ( cSifPath + "ROBA" ) ALIAS "ROBA"
      SET ORDER TO TAG "ID"

      SELECT ( F_SAST )
      USE
      SELECT ( F_SAST )
      USE ( cSifPath + "SAST" ) ALIAS "SAST"
      SET ORDER TO TAG "ID"

   ELSE
      O_ROBA
      O_SAST
   ENDIF

   o_kalk_pripr()
   o_koncij()
   o_kalk()
   O_KONTO
   O_PARTN
   O_TARIFA

   IF lTest == .F. .AND. gBrojacKalkulacija == "D"
      SELECT kalk
      SET ORDER TO TAG "1"
      SEEK cIdFirma + "96X"
      SKIP -1
      IF idvd <> "96"
         cBrKalk := Space( 8 )
      ELSE
         cBrKalk := brdok
      ENDIF
   ENDIF

   IF lTest == .T.
      cBrKalk := "99999"
   ENDIF

   IF lTest == .F.

      Box(, 10, 60 )
      IF gBrojacKalkulacija == "D"
         cBrKalk := UBrojDok( Val( Left( cBrKalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
      ENDIF

      @ m_x + 1, m_y + 2 SAY "Broj kalkulacije 96 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 3, m_y + 2 SAY "Konto razduzuje :" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      @ m_x + 4, m_y + 2 SAY "Konto zaduzuje  :" GET cIdKonto PICT "@!" VALID P_Konto( @cIdKonto )

      cArtFilter := PadR( "2;3;", 20 )
      cTopsKonto := PadR( "1320", 7 )
      dDatPOd := Date()
      dDatPDo := Date()

      @ m_x + 6, m_y + 2 SAY "Prodavnicki konto: " GET cTopsKonto PICT "@!" VALID P_Konto( @cTopsKonto )
      @ m_x + 7, m_y + 2 SAY "period od" GET dDatPOd
      @ m_x + 7, Col() + 2 SAY "do" GET dDatPDo

      @ m_x + 9, m_Y + 2  SAY "Vrsta dokumenta kase     :" GET cIdTipDok
      @ m_x + 10, m_Y + 2 SAY "Sifre artikala pocinju sa:" GET cArtFilter
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN
      ENDIF

   ENDIF

   // uzmi iz koncija sve potrebne varijable
   SELECT koncij
   SET ORDER TO TAG "ID"
   HSEEK cTopsKonto

   IF !Found()
      MsgBeep( "Ne postoji definisan prod.konto u KONCIJ-u" )
      RETURN
   ENDIF

   cTKumPath := Trim( field->kumtops )
   cIdPos := field->idprodmjes

   IF lTest
      dDatPOd := dD_from
      dDatPDo := dD_to
   ENDIF

   nRBr := 0


   // provjeri prodajno mjesto, mora biti popunjeno
   IF Empty( cIdPos )
      MsgBeep( "Ne postoji popunjeno prodajno mjesto !" )
      RETURN
   ENDIF

   // provjeri putanju
   IF Empty( cTKumPath )
      MsgBeep( "Nisu popunjeni parametri za prodavnicu" )
      RETURN
   ENDIF

   AddBs( @cTKumPath )

   // provjeri da li postoje fajloci na destinaciji
   IF ( !File( cTKumPath + "POS.DBF" ) .OR. !File( cTKumPath + "POS.CDX" ) )
      MsgBeep( "Na zadatim lokacijama ne postoje tabele!" )
      RETURN
   ENDIF

   // otvori pos
   Select( 249 )
   USE ( cTKumPath + "POS" ) ALIAS xpos
   SET ORDER TO TAG "1"

   SELECT xpos
   GO TOP
   SEEK cIdPos

   nCnt := 0

   // box prenosa
   Box(, 3, 60 )
   @ 1 + m_x, 2 + m_y SAY "Razbijam po normativima...."

   DO WHILE !Eof() .AND. xpos->idpos == cIdPos
      IF xpos->idvd $ AllTrim( cIdTipDok ) .AND. xpos->datum >= dDatPOd .AND. xpos->datum <= dDatPDo
         SELECT ROBA
         HSEEK xpos->idroba

         IF !Found()
            SELECT xpos
            SKIP
            LOOP
         ENDIF

         IF ( !Empty( cArtFilter ) .AND. At( Left( roba->id, 1 ), cArtFilter ) == 0 )
            SELECT xpos
            SKIP
            LOOP
         ENDIF

         IF roba->tip = "P"  // proizvod je!
            SELECT sast
            HSEEK  xpos->idroba
            DO WHILE !Eof() .AND. id == xpos->idroba
               SELECT roba
               HSEEK sast->id2
               SELECT kalk_pripr
               LOCATE FOR idroba == sast->id2
               IF Found()
                  RREPLACE kolicina WITH kolicina + xpos->kolicina * sast->kolicina
               ELSE
                  SELECT kalk_pripr
                  APPEND BLANK
                  REPLACE idfirma WITH gFirma
                  REPLACE rbr WITH Str( ++nRbr, 3 )
                  REPLACE idvd WITH "96"
                  REPLACE brdok WITH cBrKalk
                  REPLACE datdok WITH dDatKalk
                  REPLACE idtarifa WITH ROBA->idtarifa
                  REPLACE brfaktp WITH ""
                  REPLACE datfaktp WITH dDatKalk
                  REPLACE idkonto WITH cIdkonto
                  REPLACE idkonto2 WITH cIdkonto2
                  REPLACE idzaduz2 WITH cIdzaduz2
                  REPLACE kolicina WITH xpos->kolicina * sast->kolicina
                  REPLACE idroba WITH sast->id2
                  REPLACE nc WITH ROBA->nc
                  REPLACE vpc WITH xpos->cijena
                  // replace rabatv with xpos->ncijena
                  // replace mpc with xpos->cijena
               ENDIF

               @ 2 + m_x, 2 + m_y SAY "Obradio: " + AllTrim( Str( ++nCnt ) )
               SELECT sast
               SKIP
            ENDDO
         ENDIF
      ENDIF
      SELECT xpos
      SKIP
   ENDDO

   BoxC()

   IF nCnt > 0 .AND. lTest == .F.
      MsgBeep( "Razmjena podatka izvrsena, dokument izgenerisan u pripremi!#Obradite ga!" )
   ENDIF

   IF lTest == .F.
      closeret
   ENDIF

   RETURN

*/
