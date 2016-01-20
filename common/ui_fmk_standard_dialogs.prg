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

STATIC cLDirekt := "0"

/*! \fn Pitanje(cId,cPitanje,cOdgDefault,cMogOdg)
 *  \brief Otvara box sa zadatim pitanjem na koje treba odgovoriti sa D,N,..
 *  \param cId
 *  \param cPitanje       - Pitanje
 *  \param cOdgDefault    - Odgovor koji ce biti ponudjen na boxu
 *  \cMogOdg              - Moguci odgovori
 */

FUNCTION Pitanje( cId, cPitanje, cOdgDefault, cMogOdg )

   LOCAL cPom
   LOCAL cOdgovor

   IF cMogOdg == NIL
      cMogOdg := "YDNL"
   ENDIF

   PRIVATE GetList := {}


   IF gAppSrv
      RETURN cOdgDefault
   ENDIF

   cPom := Set( _SET_DEVICE )
   SET DEVICE TO SCREEN

   IF cOdgDefault == NIL .OR. !( cOdgDefault $ cMogOdg )
      cOdgovor := " "
   ELSE
      cOdgovor := cOdgDefault
   ENDIF

   SET ESCAPE OFF
#ifdef TEST
   push_test_tag( cId )
#else
   SET CONFIRM OFF
#endif

   Box( , 3, Len( cPitanje ) + 6, .F. )

   SET CURSOR ON
   @ m_x + 2, m_y + 3 SAY8 cPitanje GET cOdgovor PICTURE "@!" ;
      VALID ValidSamo( cOdgovor, cMogOdg )

   READ

   BoxC()

   SET ESCAPE ON
#ifdef TEST
   pop_test_tag()
#else
   SET CONFIRM ON
#endif

   SET( _SET_DEVICE, cPom )

   RETURN cOdgovor


// ------------------------------------------------
// ------------------------------------------------
STATIC FUNCTION ValidSamo( cOdg, cMogOdg )

   IF cOdg $ cMogOdg
      RETURN .T.
   ELSE

#ifndef TEST
      MsgBeep( "Unešeno: " + cOdg + "#Morate unijeti nešto od :" + cMogOdg )
#endif

      RETURN .F.
   ENDIF

   RETURN .F.



/*! \fn Pitanje2(cId,cPitanje,cOdgDefault)
 *  \brief
 *  \param cId
 *  \param cPitanje       - Pitanje
 *  \cOdgDefault          - Ponudjeni odgovor
 */

FUNCTION Pitanje2( cId, cPitanje, cOdgDefault )

   LOCAL cOdg
   LOCAL nDuz := Len( cPitanje ) + 4
   LOCAL cPom := Set( _SET_DEVICE )
   PRIVATE GetList := {}

   IF gAppSrv
      RETURN cOdgDefault
   ENDIF

   SET DEVICE TO SCREEN
   IF nDuz < 54; nDuz := 54; ENDIF

   IF cOdgDefault == NIL .OR. !( cOdgDefault $ 'DNAO' )
      cOdg := ' '
   ELSE
      cOdg := cOdgDefault
   ENDIF

#ifndef TEST
   SET ESCAPE OFF
   SET CONFIRM OFF
#endif

   Box( "", 5, nDuz + 4, .F. )
   SET CURSOR ON
   @ m_x + 2, m_y + 3 SAY PadR( cPitanje, nDuz ) GET cOdg PICTURE "@!" VALID cOdg $ 'DNAO'
   @ m_x + 4, m_y + 3 SAY8 PadC( "Mogući odgovori:  D - DA  ,  A - DA sve do kraja", nDuz )
   @ m_x + 5, m_y + 3 SAY8 PadC( "                  N - NE  ,  O - NE sve do kraja", nDuz )
   READ
   BoxC()

#ifndef TEST
   SET ESCAPE ON
   SET CONFIRM ON
#endif

   SET( _SET_DEVICE, cPom )

   RETURN cOdg




FUNCTION print_dialog_box( cDirekt )

   IF gAppSrv
      RETURN cDirekt
   ENDIF

   SET CONFIRM OFF
   SET CURSOR ON

   IF !gAppSrv
      cDirekt := select_print_mode( @cDirekt )
   ENDIF

   SET CONFIRM ON

   RETURN cDirekt



FUNCTION select_print_mode( cDirekt )

   LOCAL nWidth

   nWidth := 35

   Tone( 400, 2 )

   m_x := 8
   m_y := 38 - Round( nWidth / 2, 0 )

   @ m_x, m_y SAY ""

   IF gcDirekt <> "B"

      Box(, 7, nWidth )

      @ m_x + 1, m_y + 2 SAY "   Izlaz direktno na printer:" GET cDirekt ;
         PICT "@!" VALID cDirekt $ "DEFGRVP"

      @ m_x + 2, m_y + 2 SAY "----------------------------------"
      @ m_x + 3, m_y + 2 SAY8 "E - direktna štampa na LPT1 (F,G)"
      @ m_x + 4, m_y + 2 SAY8 "V - prikaz izvještaja u editoru"
      @ m_x + 5, m_y + 2 SAY8 "P - pošalji na email podrške"
      @ m_x + 6, m_y + 2 SAY8 "R - ptxt štampa"
      @ m_x + 7, m_y + 2 SAY "---------- O P C I J E -----------"

      READ

      BoxC()

      IF LastKey() == K_ESC
         RETURN ""
      ELSE
         RETURN cDirekt
      ENDIF

   ELSE

      Box (, 3, 60 )
      @ m_x + 1, m_y + 2 SAY8 "Batch printer režim ..."
      Sleep( 14 )
      BoxC()
      RETURN "D"

   ENDIF

   RETURN


FUNCTION GetLozinka( nSiflen )

   LOCAL cKorsif

   cKorsif := ""
   Box(, 2, 30 )
   @ m_x + 2, m_y + 2 SAY "Lozinka..... "

   DO WHILE .T.

      nChar := WaitScrSav()

      IF nChar == K_ESC
         cKorsif := ""

      ELSEIF ( nChar == 0 ) .OR. ( nChar > 128 )
         LOOP

      ELSEIF ( nChar == K_ENTER )
         EXIT

      ELSEIF ( nChar == K_BS )
         cKorSif := Left( ckorsif, Len( cKorsif ) -1 )

      ELSE


         IF Len( cKorsif ) >= nSifLen // max 15 znakova
            Beep( 1 )
         ENDIF

         IF ( nChar > 1 )
            cKorsif := cKorSif + Chr( nChar )
         ENDIF

      ENDIF

      @ m_x + 2, m_y + 15 SAY PadR( Replicate( "*", Len( cKorSif ) ), nSifLen )
      IF ( nChar == K_ESC )
         LOOP
      ENDIF

   ENDDO

   BoxC()

   SET CURSOR ON

   RETURN PadR( cKorSif, nSifLen )



/*! \fn PozdravMsg(cNaslov,cVer,nk)
 *  \brief Ispisuje ekran sa pozdravnom porukom
 *  \param cNaslov
 *  \param cVer
 *  \param nk
 */

FUNCTION PozdravMsg( cNaslov, cVer, lGreska )

   LOCAL lInvert

   IF gAppSrv
      RETURN
   ENDIF

   lInvert := .F.

   Box( "por", 11, 60, lInvert )
   SET CURSOR OFF

   @ m_x + 2, m_y + 2 SAY PadC( cNaslov, 60 )
   @ m_x + 3, m_y + 2 SAY PadC( "Ver. " + cVer, 60 )
   @ m_x + 5, m_y + 2 SAY PadC( "bring.out d.o.o. Sarajevo", 60 )
   @ m_x + 7, m_y + 2 SAY PadC( "Juraja Najtharta 3, Sarajevo, BiH", 60 )
   @ m_x + 8, m_y + 2 SAY PadC( "tel: 033/269-291, fax: 033/269-292", 60 )
   @ m_x + 9, m_y + 2 SAY PadC( "web: http://bring.out.ba", 60 )
   @ m_x + 10, m_y + 2 SAY PadC( "email: podrska@bring.out.ba", 60 )
   IF lGreska
      @ m_x + 11, m_y + 4 SAY8 "Prošli put program nije regularno završen"
      Beep( 2 )
   ENDIF

   Inkey( 5 )

   BoxC()

   RETURN
