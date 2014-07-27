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


#include "pos.ch"



FUNCTION pos_pregled_racuna( admin )

   LOCAL _datum := NIL
   LOCAL _danas := "D"
   PRIVATE aVezani := {}

   IF admin == NIL
      admin := .F.
   ENDIF

   o_pos_tables()

   Box(, 1, 50 )
   @ m_x + 1, m_y + 2 SAY8 "Samo današnji ? (D/N)" GET _danas VALID _danas $ "DN" PICT "!@"
   READ
   BoxC()

   IF _danas == "D"
      _datum := Date()
   ENDIF

   pos_lista_racuna( _datum )

   my_close_all_dbf()

   RETURN



FUNCTION pos_lista_racuna( dDat, cBroj, fPrep, fScope, cPrefixFilter, qIdRoba )

   LOCAL i
   PRIVATE fMark := .F.
   PRIVATE cFilter
   PRIVATE ImeKol := {}
   PRIVATE Kol := {}

   IF cPrefixFilter == NIL
      cPrefixFilter := ""
   ENDIF

   cFilter := cPrefixFilter + " IdVd=='42'"

   IF fPrep == NIL
      fPrep := .F.
   ELSE
      fPrep := fPrep
   ENDIF

   IF cBroj == NIL
      cRacun := Space( Len( POS->BrDok ) )
   ELSE
      cRacun := AllTrim( cBroj )
   ENDIF

   cIdPos := Left( cRacun, At( "-", cRacun ) -1 )
   cIdPos := PadR( cIdPOS, Len( gIdPos ) )

   IF gVrstaRS <> "S" .AND. !Empty( cIdPos ) .AND. cIdPOS <> gIdPos
      MsgBeep( "Račun nije napravljen na ovoj kasi!#" + "Ne možete napraviti promjenu!", 20 )
      RETURN ( .F. )
   ENDIF

   cBroj := Right( cRacun, Len( cRacun ) -At( "-", cRacun ) )
   cBroj := PadL( cBroj, 6 )

   AAdd( ImeKol, { "Broj racuna", {|| PadR( Trim( IdPos ) + "-" + AllTrim( BrDok ), 9 ) } } )
   AAdd( ImeKol, { "Fisk.rn", {|| fisc_rn } } )
   AAdd( ImeKol, { "Iznos", {|| Str ( pos_iznos_racuna( field->idpos, field->idvd, field->datum, field->brdok ), 13, 2 ) } } )
   AAdd( ImeKol, { iif( gStolovi == "D", "Sto", "Smj" ), ;
      {|| iif( gStolovi == "D", sto_br, smjena ) } } )
   AAdd( ImeKol, { "Datum", {|| datum } } )
   AAdd( ImeKol, { "Vr.Pl", {|| idvrstep } } )
   AAdd( ImeKol, { "Partner", {|| idgost } } )
   AAdd( ImeKol, { "Vrijeme", {|| vrijeme } } )
   AAdd( ImeKol, { "Placen",     {|| iif ( Placen == PLAC_NIJE, "  NE", "  DA" ) } } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( kol, i )
   NEXT

   SELECT pos_doks

   IF fScope = nil
      fScope := .T.
   ENDIF

   IF fScope
      SET SCOPEBOTTOM TO "W"
   ENDIF

   IF gVrstaRS == "S" .OR. KLevel < L_UPRAVN
      AAdd( ImeKol, { "Radnik", {|| IdRadnik } } )
      AAdd( Kol, Len( ImeKol ) )
      cFilter += ".and. (Idpos=" + cm2str( gIdPos ) + " .or. IdPos='X ')"
   ELSE
      cFilter += ".and. IdRadnik=" + cm2str( gIdRadnik ) + ".and. Idpos=" + cm2str( gIdPos )
   ENDIF

   IF dDat <> NIL
      cFilter += '.and. Datum=' + cm2str( dDat )
   ENDIF

   IF qIdRoba <> NIL .AND. !Empty( qIdRoba )
      cFilter += ".and. pos_racun_sadrzi_artikal(IdPos, IdVd, datum, BrDok, " + cm2str( qIdRoba ) + ")"
   ENDIF

   SET FILTER TO &cFilter

   IF !Empty( cBroj )
      SEEK2( cIdPos + "42" + DToS( dDat ) + cBroj )
      IF Found()
         cBroj := AllTrim( pos_doks->IdPos ) + "-" + AllTrim( pos_doks->BrDok )
         dDat := pos_doks->datum
         RETURN( .T. )
      ENDIF
   ELSE
      GO BOTTOM
   ENDIF

   IF fPrep
      cFnc := "<Enter>-Odabir   <+>-Markiraj/Demarkiraj   <P>-Pregled"
      fMark := .T.
      bMarkF := {|| RacObilj () }
   ELSE
      cFnc := "<Enter>-Odabir          <P>-Pregled"
      bMarkF := NIL
   ENDIF

   ObjDBedit( "racun", MAXROWS() - 10, MAXCOLS() - 3, {|| lista_racuna_key_handler( fMark ) }, iif( gRadniRac == "D", "  STALNI ", "  " ) + "RACUNI  ", "", nil, cFnc,, bMarkF )

   SET FILTER TO

   cBroj := AllTrim( pos_doks->IdPos ) + "-" + AllTrim( pos_doks->BrDok )

   IF cBroj = '-'
      cBroj := Space( 9 )
   ENDIF

   dDat := pos_doks->datum

   IF LastKey() == K_ESC
      RETURN( .F. )
   ENDIF

   RETURN( .T. )



STATIC FUNCTION lista_racuna_key_handler()

   LOCAL cLevel
   LOCAL ii
   LOCAL nTrec
   LOCAL nTrec2
   LOCAL _rec

   IF M->Ch == 0
      RETURN ( DE_CONT )
   ENDIF

   IF ( LastKey() == K_ESC ) .OR. ( LastKey() == K_ENTER )
      RETURN ( DE_ABORT )
   ENDIF

   O_DIO
   O_ODJ
   O_STRAD

   SELECT strad
   hseek gStrad
   cLevel := prioritet
   USE
   SELECT pos_doks

   IF Upper( Chr( LastKey() ) ) == "P"
      pos_pregled_stavki_racuna( pos_doks->IdPos, pos_doks->datum, pos_doks->BrDok )
      RETURN DE_REFRESH
   ENDIF

   IF Upper( Chr( LastKey() ) ) == "F"
      aVezani := { { IdPos, BrDok, IdVd, datum } }
      StampaPrep( IdPos, DToS( datum ) + BrDok, aVezani, .T., nil, .T. )
      SELECT pos_doks
      f7_pf_traka( .T. )
      SELECT pos_doks

      RETURN DE_REFRESH
   ENDIF

   IF Upper( Chr( LastKey() ) ) == "S"

      pos_storno_rn( .T., pos_doks->brdok, pos_doks->datum, ;
         PadR( AllTrim( Str( pos_doks->fisc_rn ) ), 10 ) )

      msgbeep( "Storno račun se nalazi u pripremi !" )

      SELECT pos_doks
      RETURN DE_REFRESH

   ENDIF

   IF Upper( Chr( LastKey() ) ) == "Z"
      PushWa()
      print_zak_br( pos_doks->zak_br )
      o_pos_tables()
      PopWa()
      RETURN DE_REFRESH
   ENDIF

   IF ch == K_CTRL_V

      IF pos_doks->idvd <> "42"
         RETURN DE_CONT
      ENDIF

      nFisc_no := pos_doks->fisc_rn

      Box(, 1, 40 )
      @ m_x + 1, m_y + 2 SAY8 "Broj fiskalnog računa: " GET nFisc_no
      READ
      BoxC()

      IF LastKey() <> K_ESC

         _rec := dbf_get_rec()
         _rec[ "fisc_rn" ] := nFisc_no

         update_rec_server_and_dbf( "pos_doks", _rec, 1, "FULL" )

         RETURN DE_REFRESH

      ENDIF

   ENDIF

   RETURN ( DE_CONT )



