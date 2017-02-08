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



FUNCTION gSjeciStr()

   IF gPrinter == "R"
      Beep( 1 )
      FF
   ELSE
      QQOut( gSjeciStr )
   ENDIF

   RETURN .T.



FUNCTION gOtvorStr()


   IF gPrinter <> "R"
      QQOut( gOtvorStr )
   ENDIF

   RETURN .T.



FUNCTION PaperFeed()

   IF gVrstaRS <> "S"
      FOR i := 1 TO nFeedLines
         ?
      NEXT
      IF gPrinter == "R"
         Beep( 1 )
         FF
      ELSE
         gSjeciStr()
      ENDIF
   ENDIF

   RETURN





FUNCTION IncID( cId, cPadCh )

   IF cPadCh == nil
      cPadCh := " "
   ELSE
      cPadCh := cPadCh
   ENDIF

   RETURN ( PadL( Val( AllTrim( cID ) ) + 1, Len( cID ), cPadCh ) )


FUNCTION DecID( cId, cPadCh )

   IF cPadCh == nil
      cPadCh := " "
   ELSE
      cPadCh := cPadCh
   ENDIF

   RETURN ( PadL( Val( AllTrim( cID ) ) -1, Len( cID ), cPadCh ) )



FUNCTION SetNazDVal()

   LOCAL lOpened

   SELECT F_VALUTE

   PushWA()

   lOpened := .T.

   IF !Used()
      o_valute()
      lOpened := .F.
   ENDIF

   SET ORDER TO TAG "NAZ"
   GO TOP

   Seek2( "D" )

   gDomValuta := AllTrim( naz2 )

   GO TOP

   Seek2( "P" )

   gStrValuta := AllTrim( naz2 )

   IF !lOpened
      USE
   ENDIF

   PopWA()

   RETURN



FUNCTION ispisi_donji_dio_forme_unosa( txt, row )

   IF row == nil
      row := 1
   ENDIF

   @ m_x + ( MAXROWS() - 12 ) + row, 2 SAY PadR( txt, MAXCOLS() / 2 )

   RETURN


FUNCTION ispisi_iznos_veliki_brojevi( iznos, row, col )

   LOCAL _iznos
   LOCAL _cnt, _char, _next_y

   IF col == nil
      col := 76
   ENDIF

   _iznos := AllTrim( Transform( iznos, "9999999.99" ) )
   _next_y := m_y + col

   @ m_x + row + 0, MAXCOLS() / 2 SAY PadR( "", MAXCOLS() / 2 )
   @ m_x + row + 1, MAXCOLS() / 2 SAY PadR( "", MAXCOLS() / 2 )
   @ m_x + row + 2, MAXCOLS() / 2 SAY PadR( "", MAXCOLS() / 2 )
   @ m_x + row + 3, MAXCOLS() / 2 SAY PadR( "", MAXCOLS() / 2 )
   @ m_x + row + 4, MAXCOLS() / 2 SAY PadR( "", MAXCOLS() / 2 )

   FOR _cnt := Len( _iznos ) TO 1 STEP -1

      _char := SubStr( _iznos, _cnt, 1 )

      DO CASE
         // https://en.wikipedia.org/wiki/Block_Elements

      CASE _char = "1"

         _next_y -= 5

         @ m_x + row + 0, _Next_Y SAY8 " ██"
         @ m_x + row + 1, _Next_Y SAY8 "  █"
         @ m_x + row + 2, _Next_Y SAY8 "  █"
         @ m_x + row + 3, _Next_Y SAY8 "  █"
         @ m_x + row + 4, _Next_Y SAY8 " ██"

      CASE _char = "2"

         _next_y -= 5

         @ m_x + row + 0, _Next_Y SAY8 "████"
         @ m_x + row + 1, _Next_Y SAY8 "   █"
         @ m_x + row + 2, _Next_Y SAY8 "████"
         @ m_x + row + 3, _Next_Y SAY8 "█"
         @ m_x + row + 4, _Next_Y SAY8 "████"

      CASE _char = "3"

         _next_y -= 5

         @ m_x + row + 0, _Next_Y SAY8 "████"
         @ m_x + row + 1, _Next_Y SAY8 "   █"
         @ m_x + row + 2, _Next_Y SAY8 " ███"
         @ m_x + row + 3, _Next_Y SAY8 "   █"
         @ m_x + row + 4, _Next_Y SAY8 "████"

      CASE _char = "4"

         _next_y -= 5

         @ m_x + row + 0, _Next_Y SAY8 "█"
         @ m_x + row + 1, _Next_Y SAY8 "█  █"
         @ m_x + row + 2, _Next_Y SAY8 "████"
         @ m_x + row + 3, _Next_Y SAY8 "   █"
         @ m_x + row + 4, _Next_Y SAY8 "   █"

      CASE _char = "5"

         _next_y -= 5

         @ m_x + row + 0, _Next_Y SAY8 "████"
         @ m_x + row + 1, _Next_Y SAY8 "█"
         @ m_x + row + 2, _Next_Y SAY8 "████"
         @ m_x + row + 3, _Next_Y SAY8 "   █"
         @ m_x + row + 4, _Next_Y SAY8 "████"

      CASE _char = "6"

         _next_y -= 5

         @ m_x + row + 0, _Next_Y SAY8 "████"
         @ m_x + row + 1, _Next_Y SAY8 "█"
         @ m_x + row + 2, _Next_Y SAY8 "████"
         @ m_x + row + 3, _Next_Y SAY8 "█  █"
         @ m_x + row + 4, _Next_Y SAY8 "████"

      CASE _char = "7"

         _next_y -= 5

         @ m_x + row + 0, _Next_Y SAY8 "████"
         @ m_x + row + 1, _Next_Y SAY8 "   █"
         @ m_x + row + 2, _Next_Y SAY8 "  █"
         @ m_x + row + 3, _Next_Y SAY8 " █"
         @ m_x + row + 4, _Next_Y SAY8 "█"

      CASE _char = "8"

         _next_y -= 5

         @ m_x + row + 0, _Next_Y SAY8 "████"
         @ m_x + row + 1, _Next_Y SAY8 "█  █"
         @ m_x + row + 2, _Next_Y SAY8 " ██ "
         @ m_x + row + 3, _Next_Y SAY8 "█  █"
         @ m_x + row + 4, _Next_Y SAY8 "████"

      CASE _char = "9"

         _next_y -= 5

         @ m_x + row + 0, _Next_Y SAY8 "████"
         @ m_x + row + 1, _Next_Y SAY8 "█  █"
         @ m_x + row + 2, _Next_Y SAY8 "████"
         @ m_x + row + 3, _Next_Y SAY8 "   █"
         @ m_x + row + 4, _Next_Y SAY8 "████"

      CASE _char = "0"

         _next_y -= 5

         @ m_x + row + 0, _Next_Y SAY8 "████"
         @ m_x + row + 1, _Next_Y SAY8 "█  █"
         @ m_x + row + 2, _Next_Y SAY8 "█  █"
         @ m_x + row + 3, _Next_Y SAY8 "█  █"
         @ m_x + row + 4, _Next_Y SAY8 "████"

      CASE _char = "."

         _next_y -= 2

         @ m_x + row + 4, _Next_Y SAY8 "█"

      CASE _char = "-"

         _next_y -= 4

         @ m_x + row + 2, _Next_Y SAY8 "███"

      ENDCASE
   NEXT

   RETURN .T.



FUNCTION ispisi_iznos_racuna_box( iznos )

   LOCAL cIzn
   LOCAL nCnt, Char, NextY
   LOCAL nPrevRow := Row()
   LOCAL nPrevCol := Col()

   SetPos ( 0, 0 )

   Box (, 9, 77 )

   cIzn := AllTrim ( Transform ( iznos, "9999999.99" ) )

   @ m_x, m_y + 28 SAY8 "  IZNOS RAČUNA JE  " COLOR f18_color_invert()

   NextY := m_y + 76

   FOR nCnt := Len ( cIzn ) TO 1 STEP -1
      Char := SubStr ( cIzn, nCnt, 1 )
      DO CASE
      CASE Char = "1"
         NextY -= 6
         @ m_x + 2, NextY SAY8 " ██"
         @ m_x + 3, NextY SAY8 "  █"
         @ m_x + 4, NextY SAY8 "  █"
         @ m_x + 5, NextY SAY8 "  █"
         @ m_x + 6, NextY SAY8 "  █"
         @ m_x + 7, NextY SAY8 "  █"
         @ m_x + 8, NextY SAY8 "  █"
         @ m_x + 9, NextY SAY8 "█████"
      CASE Char = "2"
         NextY -= 8
         @ m_x + 2, NextY SAY8 "███████"
         @ m_x + 3, NextY SAY8 "      █"
         @ m_x + 4, NextY SAY8 "      █"
         @ m_x + 5, NextY SAY8 "███████"
         @ m_x + 6, NextY SAY8 "█"
         @ m_x + 7, NextY SAY8 "█"
         @ m_x + 8, NextY SAY8 "█     █"
         @ m_x + 9, NextY SAY8 "███████"
      CASE Char = "3"
         NextY -= 8
         @ m_x + 2, NextY SAY8 " ██████"
         @ m_x + 3, NextY SAY8 "      █"
         @ m_x + 4, NextY SAY8 "      █"
         @ m_x + 5, NextY SAY8 "  ████"
         @ m_x + 6, NextY SAY8 "      █"
         @ m_x + 7, NextY SAY8 "      █"
         @ m_x + 8, NextY SAY8 "      █"
         @ m_x + 9, NextY SAY8 "███████"
      CASE Char = "4"
         NextY -= 8
         @ m_x + 2, NextY SAY8 "█"
         @ m_x + 3, NextY SAY8 "█"
         @ m_x + 4, NextY SAY8 "█     █"
         @ m_x + 5, NextY SAY8 "█     █"
         @ m_x + 6, NextY SAY8 "███████"
         @ m_x + 7, NextY SAY8 "      █"
         @ m_x + 8, NextY SAY8 "      █"
         @ m_x + 9, NextY SAY8 "      █"
      CASE Char = "5"
         NextY -= 8
         @ m_x + 2, NextY SAY8 "███████"
         @ m_x + 3, NextY SAY8 "█"
         @ m_x + 4, NextY SAY8 "█"
         @ m_x + 5, NextY SAY8 "███████"
         @ m_x + 6, NextY SAY8 "      █"
         @ m_x + 7, NextY SAY8 "      █"
         @ m_x + 8, NextY SAY8 "█     █"
         @ m_x + 9, NextY SAY8 "███████"
      CASE Char = "6"
         NextY -= 8
         @ m_x + 2, NextY SAY8 "███████"
         @ m_x + 3, NextY SAY8 "█"
         @ m_x + 4, NextY SAY8 "█"
         @ m_x + 5, NextY SAY8 "███████"
         @ m_x + 6, NextY SAY8 "█     █"
         @ m_x + 7, NextY SAY8 "█     █"
         @ m_x + 8, NextY SAY8 "█     █"
         @ m_x + 9, NextY SAY8 "███████"
      CASE Char = "7"
         NextY -= 8
         @ m_x + 2, NextY SAY8 "███████"
         @ m_x + 3, NextY SAY8 "      █"
         @ m_x + 4, NextY SAY8 "     █"
         @ m_x + 5, NextY SAY8 "    █"
         @ m_x + 6, NextY SAY8 "   █"
         @ m_x + 7, NextY SAY8 "  █"
         @ m_x + 8, NextY SAY8 " █"
         @ m_x + 9, NextY SAY8 "█"
      CASE Char = "8"
         NextY -= 8
         @ m_x + 2, NextY SAY8 "███████"
         @ m_x + 3, NextY SAY8 "█     █"
         @ m_x + 4, NextY SAY8 "█     █"
         @ m_x + 5, NextY SAY8 " █████ "
         @ m_x + 6, NextY SAY8 "█     █"
         @ m_x + 7, NextY SAY8 "█     █"
         @ m_x + 8, NextY SAY8 "█     █"
         @ m_x + 9, NextY SAY8 "███████"
      CASE Char = "9"
         NextY -= 8
         @ m_x + 2, NextY SAY8 "███████"
         @ m_x + 3, NextY SAY8 "█     █"
         @ m_x + 4, NextY SAY8 "█     █"
         @ m_x + 5, NextY SAY8 "███████"
         @ m_x + 6, NextY SAY8 "      █"
         @ m_x + 7, NextY SAY8 "      █"
         @ m_x + 8, NextY SAY8 "█     █"
         @ m_x + 9, NextY SAY8 "███████"
      CASE Char = "0"
         NextY -= 8
         @ m_x + 2, NextY SAY8 " █████ "
         @ m_x + 3, NextY SAY8 "█     █"
         @ m_x + 4, NextY SAY8 "█     █"
         @ m_x + 5, NextY SAY8 "█     █"
         @ m_x + 6, NextY SAY8 "█     █"
         @ m_x + 7, NextY SAY8 "█     █"
         @ m_x + 8, NextY SAY8 "█     █"
         @ m_x + 9, NextY SAY8 " █████"
      CASE Char = "."
         NextY -= 4
         @ m_x + 9, NextY SAY8 "███"
      CASE Char = "-"
         NextY -= 6
         @ m_x + 5, NextY SAY8 "█████"
      ENDCASE
   NEXT

   SetPos ( nPrevRow, nPrevCol )

   RETURN .T.



FUNCTION SkloniIznRac()

   BoxC()

   RETURN



/* PromIdCijena()
 *     Promjena seta cijena
 *  \todo Ovu funkciju treba ugasiti, zajedno sa konceptom vise setova cijena, to treba generalno revidirati jer prakticno niko i ne koristi, a knjigovodstveno je sporno
 */

FUNCTION PromIdCijena()

   LOCAL i := 0, j := Len( SC_Opisi )
   LOCAL cbsstara := ShemaBoja( "B1" )

   box_crno_na_zuto( 5, 1, 6 + j + 2, 78, "SETOVI CIJENA", cbnaslova,, cbokvira, cbteksta, 0 )
   FOR i := 1 TO j
      @ 6 + i, 2 SAY IF( Val( gIdCijena ) == i, "->", "  " ) + ;
         Str( i, 3 ) + ". " + PadR( SC_Opisi[ i ], 40 ) + ;
         IF( Val( gIdCijena ) == i, " <- tekuci set", "" )
   NEXT
   VarEdit( { { "Oznaka seta cijena", "gIdCijena", "VAL(gIdCijena)>0.and.VAL(gIdCijena)<=LEN(SC_Opisi)",, } }, ;
      6 + j + 3, 1, 6 + j + 7, 78, "IZBOR SETA CIJENA", "B1" )
   Prozor0()
   ShemaBoja( cBsstara )
   pos_status_traka()

   RETURN .T.


/* PortZaMT(cIdDio,cIdOdj)
 *
 *   param: cIdDio
 *   param: cIdOdj
 */

FUNCTION PortZaMT( cIdDio, cIdOdj )

   LOCAL nObl := Select(), cVrati := gLocPort    // default port je gLocPort

   SELECT F_UREDJ; PushWA()
   IF ! Used()
      O_UREDJ
   ENDIF
   SELECT F_MJTRUR; PushWA()
   IF ! Used()
      O_MJTRUR
   ENDIF
   GO TOP; HSEEK cIdDio + cIdOdj
   IF Found()
      SELECT F_UREDJ
      GO TOP; HSEEK MJTRUR->iduredjaj
      cVrati := AllTrim( port )
   ENDIF
   SELECT F_MJTRUR; PopWA()
   SELECT F_UREDJ; PopWA()
   SELECT ( nObl )

   RETURN cVrati




FUNCTION NazivRobe( cIdRoba )

   LOCAL nCurr := Select()

   select_o_roba( cIdRoba )
   SELECT nCurr

   RETURN ( roba->Naz )



FUNCTION Godina_2( dDatum )

   // 01.01.99 -> "99"
   // 01.01.00 -> "00"

   RETURN PadL( AllTrim( Str( Year( dDatum ) % 100, 2, 0 ) ), 2, "0" )



FUNCTION NenapPop()

   RETURN iif( gPopVar = "A", "NENAPLACENO:", "     POPUST:" )



FUNCTION pos_set_user( cKorSif, nSifLen, cLevel )

   O_STRAD
   O_OSOB

   cKorSif := CryptSC( PadR( Upper( Trim( cKorSif ) ), nSifLen ) )
   SELECT OSOB
   SEEK cKorSif

   IF Found()
      gIdRadnik := field->ID
      gKorIme   := field->Naz
      gSTRAD  := AllTrim ( field->Status )
      SELECT STRAD
      SEEK OSOB->Status
      IF Found ()
         cLevel := field->prioritet
      ELSE
         cLevel := L_PRODAVAC
         gSTRAD := "K"
      ENDIF
      SELECT OSOB
      RETURN 1
   ELSE
      MsgBeep ( "Unijeta je nepostojeća lozinka !" )
      SELECT OSOB
      RETURN 0
   ENDIF

   RETURN 0


FUNCTION pos_status_traka()

   LOCAL _x := MAXROWS() - 3
   LOCAL _y := 0

   @ 1, _y + 1 SAY8 "RADI:" + PadR( LTrim( gKorIme ), 31 ) + " SMJENA:" + gSmjena + " CIJENE:" + gIdCijena + " DATUM:" + DToC( gDatum ) + IF( gVrstaRS == "S", "   SERVER  ", " KASA-PM:" + gIdPos )

   IF gIdPos == "X "
      @ _x, _y + 1 SAY8 PadC( "$$$ --- PRODAJNO MJESTO X ! --- $$$", MAXCOLS() - 2, "█" )
   ELSE
      @ _x, _y + 1 SAY8 Replicate( "█", MAXCOLS() - 2 )
   ENDIF

   @ _x - 1, _y + 1 SAY PadC ( Razrijedi ( gKorIme ), MAXCOLS() - 2 ) COLOR f18_color_invert()

   RETURN .T.
