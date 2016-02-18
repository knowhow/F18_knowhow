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


FUNCTION tekuci_modul()
   RETURN gModul

FUNCTION tekuca_sezona()
   RETURN my_server_params()[ "database" ]


FUNCTION start_f18_program_module( oApp, lSezone )

   LOCAL cImeDbf
   LOCAL _i


   gModul   := oApp:cName
   goModul  := oApp
   gVerzija := oApp:cVerzija

   set_naslovni_ekran( oApp )

   set_global_vars_1()

   IF oApp:lTerminate
      RETURN .T.
   ENDIF

   set_global_vars_2()

   info_bar( oApp:cName, oApp:cName + " : start_program_module set global vars - start " )
   oApp:set_module_gvars()
   info_bar( oApp:cName, oApp:cName + " : start_program_module set global vars - end" )

   RETURN .T.



FUNCTION set_naslovni_ekran( oApp )

   gNaslov := oApp:cName + " F18, " + oApp:cPeriod


   AFill( h, "" )

   nOldCursor := iif( ReadInsert(), 2, 1 )

   standardboje()

   SET KEY K_INS TO ToggleINS()

#ifdef __PLATFORM__DARWIN
   SET KEY K_F12 TO ToggleIns()
#endif


   NaslEkran( .T. )
   ToggleIns()
   ToggleIns()

   @ 10, 35 SAY ""
   // prijava

   IF !oApp:lStarted
      IF ( oApp:cKorisn <> NIL .AND. oApp:cSifra <> nil )
         IF oApp:cP3 <> nil
            Prijava( oApp, .F. )  // bez prijavnog Box-a
         ELSE
            Prijava( oApp )
         ENDIF
      ELSE
         Prijava( oApp )
      ENDIF
   ENDIF


   RETURN NIL



FUNCTION mpar37( x, oApp )

   // proslijedjeni su parametri
   lp3 := oApp:cP3
   lp4 := oApp:cP4
   lp5 := oApp:cP5
   lp6 := oApp:cP6
   lp7 := oApp:cP7

   RETURN ( ( lp3 <> NIL .AND. Upper( lp3 ) == x ) .OR. ( lp4 <> NIL .AND. Upper( lp4 ) == x ) .OR. ;
      ( lp5 <> NIL .AND. Upper( lp5 ) == x ) .OR. ( lp6 <> NIL .AND. Upper( lp6 ) == x ) .OR. ;
      ( lp7 <> NIL .AND. Upper( lp7 ) == x ) )



FUNCTION mpar37cnt( oApp )

   LOCAL nCnt := 0

   IF oApp:cP3 <> nil
      ++nCnt
   ENDIF
   IF oApp:cP4 <> nil
      ++nCnt
   ENDIF
   IF oApp:cP5 <> nil
      ++nCnt
   ENDIF
   IF oApp:cP6 <> nil
      ++nCnt
   ENDIF
   IF oApp:cP7 <> nil
      ++nCnt
   ENDIF

   RETURN nCnt


FUNCTION mparstring( oApp )

   LOCAL cPars

   cPars := ""

   IF oApp:cP3 <> NIL
      cPars += "'" + oApp:cP3 + "'"
   ENDIF
   IF oApp:cP4 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP4 + "'"
   ENDIF
   IF oApp:cP5 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP5 + "'"
   ENDIF
   IF oApp:cP6 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP6 + "'"
   ENDIF
   IF oApp:cP7 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP7 + "'"
   ENDIF

   RETURN cPars





/*! \fn Prijava(oApp,lScreen)
 *  \brief Prijava korisnika pri ulasku u aplikaciju
 *  \todo Prijava je primjer klasicne kobasica funkcije ! Razbiti je.
 *  \todo prijavu na osnovu scshell.ini izdvojiti kao posebnu funkciju
 */

FUNCTION Prijava( oApp, lScreen )

   LOCAL i
   LOCAL nRec
   LOCAL cKontrDbf
   LOCAL cCD

   LOCAL cPom
   LOCAL cPom2
   LOCAL lRegularnoZavrsen

   IF lScreen == nil
      lScreen := .T.
   ENDIF

   @ 3, 4 SAY ""
   IF ( gfKolor == "D" .AND. IsColor() )
      Normal := "GR+/B,R/N+,,,N/W"
   ELSE
      Normal := "W/N,N/W,,,N/W"
   ENDIF

   IF !oApp:lStarted
      IF lScreen
         // korisn->nk napustiti
         // PozdravMsg(gNaslov, gVerzija, korisn->nk)
         // lGreska:=.f.
         PozdravMsg( gNaslov, gVerzija, .F. )
      ENDIF
   ENDIF

   IF ( gfKolor == "D" .AND. IsColor() )
      Normal := "W/B,R/N+,,,N/W"
   ELSE
      Normal := "W/N,N/W,,,N/W"
   ENDIF

   CLOSERET

   RETURN NIL

STATIC FUNCTION PrijRunInstall( m_sif, cKom )

   IF m_sif == "I"
      cKom := cKom := "I" + gModul + " " + ImeKorisn + " " + CryptSC( sifrakorisn )
   ENDIF
   IF m_sif == "IM"
      cKom += "  /M"
   ENDIF
   IF m_sif == "II"
      cKom += "  /I"
   ENDIF
   IF m_sif == "IR"
      cKom += "  /R"
   ENDIF
   IF m_sif == "IP"
      cKom += "  /P"
   ENDIF
   IF m_sif == "IB"
      cKom += "  /B"
   ENDIF
   RunInstall( cKom )

   RETURN .T.


FUNCTION RunInstall( cKom )

   LOCAL lIB

   lIB := .F.

   IF ( cKom == nil )
      cKom := ""
   ENDIF

   // MsgBeep("cKom="+cKom)
   IF ( " /B" $ cKom )
      goModul:cP7 := "/B"
      lIb := .T.
   ENDIF

   IF ( lIB )
      goModul:cP7 := ""
      lIB := .F.
   ENDIF

   RETURN .T.
