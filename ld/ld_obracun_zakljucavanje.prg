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


FUNCTION DlgZakljucenje()

   O_OBRACUNI
   O_LD_RJ

   SELECT obracuni

   cRadnaJedinica := "  "
   nMjObr := gMjesec
   nGodObr := gGodina
   cOdgovor := "N"
   cStatus := "U"

   Box(, 9, 40 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica:" GET cRadnaJedinica VALID P_LD_Rj( @cRadnaJedinica ) PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Mjesec        :" GET nMjObr PICT "99"
   @ m_x + 3, m_y + 2 SAY "Godina        :" GET nGodObr PICT "9999"
   @ m_x + 4, m_y + 2 SAY "--------------------------------------"
   @ m_x + 5, m_y + 2 SAY "Opcije: "
   @ m_x + 6, m_y + 2 SAY "  - otvori (U)"
   @ m_x + 7, m_y + 2 SAY "  - zakljuci (Z)" GET cStatus VALID cStatus $ "UZ" PICT "@!"
   @ m_x + 8, m_y + 2 SAY "--------------------------------------"
   @ m_x + 9, m_y + 2 SAY "Snimiti promjene (D/N)?" GET cOdgovor VALID cOdgovor $ "DN" PICT"@!"
   READ

   IF ( cOdgovor == "D" )
      IF ( cStatus == "Z" )
         ZakljuciObr( cRadnaJedinica, nGodObr, nMjObr, "Z" )
      ELSEIF ( cStatus == "U" )
         IF ( ProsliObrOtvoren( cRadnaJedinica, nGodObr, nMjObr ) )
            MsgBeep( "Morate prvo zakljuciti obracun za prethodni mjesec!" )
         ELSE
            OtvoriObr( cRadnaJedinica, nGodObr, nMjObr, "U" )
         ENDIF
      ENDIF
   ENDIF
   BoxC()

   RETURN




/*! \fn OtvoriObr(cRj,nGodina,nMjesec,cStatus)
 *  \brief Otvara obracun ili ga ponovo otvara zavisno od statusa
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status: "U" otvori novi, "P" ponovo otvori
 */

FUNCTION OtvoriObr( cRj, nGodina, nMjesec, cStatus )

   SELECT obracuni
   hseek cRj + AllTrim( Str( nGodina ) ) + FmtMjesec( nMjesec )

   IF !Found()
      AddStatusObr( cRj, nGodina, nMjesec, "U" )
      MsgBeep( "Obracun otvoren !!!" )
      IspisiStatusObracuna( cRj, nGodina, nMjesec )
      RETURN
   ENDIF

   IF JelZakljucen( cRj, nGodina, nMjesec )
      IF Pitanje(, "Obracun zakljucen, otvoriti ponovo", "N" ) == "D"
         hseek cRj + AllTrim( Str( nGodina ) ) + FmtMjesec( nMjesec )
         ChStatusObr( cRJ, nGodina, nMjesec, "P" )
         MsgBeep( "Obracun ponovo otvoren !!!" )
         IspisiStatusObracuna( cRJ, nGodina, nMjesec )
         RETURN
      ELSE
         MsgBeep( "Obracun nije otvoren !!!" )
         RETURN
      ENDIF
   ENDIF

   RETURN



/*! \fn ZakljuciObr(cRj,nGodina,nMjesec,cStatus)
 *  \brief Zakljucuje obracun ili ga ponovo zakljucuje zavisno od statusa
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status: "Z" zakljuci, "X" ponovo zakljuci
 */

FUNCTION ZakljuciObr( cRJ, nGodina, nMjesec, cStatus )

   SELECT obracuni
   hseek cRj + AllTrim( Str( nGodina ) ) + FmtMjesec( nMjesec )

   IF !Found()
      MsgBeep( "Potrebno prvo otvoriti obracun !!!" )
      RETURN
   ENDIF

   IF field->status == "U"
      ChStatusObr( cRj, nGodina, nMjesec, "Z" )
      MsgBeep( "Obracun zakljucen !!!" )
      IspisiStatusObracuna( cRj, nGodina, nMjesec )
      RETURN
   ENDIF

   IF JelOtvoren( cRj, nGodina, nMjesec )
      ChStatusObr( cRJ, nGodina, nMjesec, "X" )
      MsgBeep( "Obracun ponovo zakljucen !!!" )
      IspisiStatusObracuna( cRj, nGodina, nMjesec )
      RETURN
   ENDIF

   RETURN



/*! \fn JelZakljucen(cRJ,nGodina,nMjesec)
 *  \brief Provjerava da li je obracun vec zakljucen
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 */
FUNCTION JelZakljucen( cRJ, nGodina, nMjesec )

   SELECT obracuni
   hseek ( cRJ + AllTrim( Str( nGodina ) ) + FmtMjesec( nMjesec ) )
   IF ( Found() .AND. field->status == "X" .OR. Found() .AND. field->status == "Z" )
      RETURN .T.
   ELSE
      RETURN .F.
   ENDIF

   RETURN


/*! \fn JelOtvoren(cRJ,nGodina,nMjesec)
 *  \brief Provjerava da li je obracun vec otvoren
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 */
FUNCTION JelOtvoren( cRJ, nGodina, nMjesec )

   SELECT obracuni
   hseek cRJ + AllTrim( Str( nGodina ) ) + FmtMjesec( nMjesec )
   IF ( Found() .AND. field->status == "P" .OR. Found() .AND. field->status == "U" )
      RETURN .T.
   ELSE
      RETURN .F.
   ENDIF

   RETURN


/*! \fn AddStatusObr(cRJ,nGodina,nMjesec,cStatus)
 *  \brief Upisuje novi zapis u tabelu OBRACUNI ako ga nije nasao za cRJ+nGodina+nMjesec+cStatus
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status koji se provjerava
 */
FUNCTION AddStatusObr( cRJ, nGodina, nMjesec, cStatus )

   LOCAL _rec

   SELECT obracuni
   APPEND BLANK

   _rec := dbf_get_rec()
   _rec[ "rj" ] := cRJ
   _rec[ "godina" ] := nGodina
   _rec[ "mjesec" ] := nMjesec
   _rec[ "status" ] := cStatus

   update_rec_server_and_dbf( "ld_obracuni", _rec, 1, "FULL" )

   RETURN



/*! \fn ChStatusObr(cRJ,nGodina,nMjesec,cStatus)
 *  \brief Mjenja zapis u tabelu OBRACUNI za cRJ+nGodina+nMjesec+cStatus
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status koji se provjerava
 */
FUNCTION ChStatusObr( cRJ, nGodina, nMjesec, cStatus )

   LOCAL _rec

   SELECT obracuni
   _rec := dbf_get_rec()
   _rec[ "rj" ] := cRJ
   _rec[ "godina" ] := nGodina
   _rec[ "mjesec" ] := nMjesec
   _rec[ "status" ] := cStatus

   update_rec_server_and_dbf( "ld_obracuni", _rec, 1, "FULL" )

   RETURN


/*! \fn FmtMjesec(nMjesec)
 *  \brief Format prikaza mjeseca
 *  \param nMjesec - mjesec
 */
FUNCTION FmtMjesec( nMjesec )

   // {
   IF nMjesec < 10
      cMj := " " + AllTrim( Str( nMjesec ) )
   ELSE
      cMj := AllTrim( Str( nMjesec ) )
   ENDIF

   RETURN cMj


/*! \fn GetObrStatus(cRJ,nGodina,nMjesec)
 *  \brief Provjerava status obracuna, ako uopste ne postoji vraca "N" inace vraca pravi status
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 */
FUNCTION GetObrStatus( cRj, nGodina, nMjesec )

   LOCAL nArr

   nArr := Select()

   IF gZastitaObracuna <> "D"
      RETURN ""
   ENDIF

   O_OBRACUNI
   SELECT obracuni
   SET ORDER TO TAG "RJ"
   hseek cRj + AllTrim( Str( nGodina ) ) + FmtMjesec( nMjesec )

   IF !Found()
      cStatus := "N"
   ELSE
      cStatus := field->status
   ENDIF

   SELECT ( nArr )

   RETURN cStatus


/*! \fn ProsliObrOtvoren(cRj,nGodObr,nMjObr)
 *  \brief Provjerava da li je obracun za mjesec unazad otvoren
 *  \param cRJ - radna jedinica
 *  \param nGodObr - godina
 *  \param nMjObr - mjesec
 */
FUNCTION ProsliObrOtvoren( cRJ, nGodObr, nMjObr )

   LOCAL lOtvoren

   IF ( nMjObr == 1 )
      lOtvoren := JelOtvoren( cRJ, nGodObr - 1, 12 )
   ELSE
      lOtvoren := JelOtvoren( cRJ, nGodObr, nMjObr - 1 )
   ENDIF

   RETURN ( lOtvoren )
