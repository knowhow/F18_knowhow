/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2018 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"



// --------------------------------------------
// browse dokumenata - tabelarni pregled
// --------------------------------------------
FUNCTION browse_kalk_dokumenti()

   LOCAL cFirma := self_organizacija_id()
   LOCAL cIdVd := PadR( "", 30 )
   LOCAL dDatOd := Date() - 7
   LOCAL dDatDo := Date()
   LOCAL cProdKto := PadR( "", 50 )
   LOCAL cMagKto := PadR( "", 50 )
   LOCAL cPartner := PadR( "", 6 )
   LOCAL cFooter := ""
   LOCAL cHeader := "Pregled dokumenata - tabelarni pregled"
   PRIVATE ImeKol
   PRIVATE Kol

   IF usl_browse_kalk_dokumenti( @cFirma, @cIdVd, @dDatOd, @dDatDo, @cMagKto, @cProdKto, @cPartner ) == 0
      RETURN .F.
   ENDIF

  // o_roba()
   o_koncij()

   o_konto()
   find_kalk_doks_by_tip_datum( cFirma, NIL, dDatOd, dDatDo )
   set_filter_kalk_doks( cFirma, cIdVd, dDatOd, dDatDo, cMagKto, cProdKto, cPartner )
   GO TOP

   Box(, 20, 77 )

   @ box_x_koord() + 18, box_y_koord() + 2 SAY ""
   @ box_x_koord() + 19, box_y_koord() + 2 SAY ""
   @ box_x_koord() + 20, box_y_koord() + 2 SAY ""

   set_a_kol( @ImeKol, @Kol )

   my_browse( "pregl", 20, 77, {|| brow_keyhandler( Ch ) }, cFooter, cHeader,,,,, 3 )

   BoxC()

   closeret

   RETURN .T.


// --------------------------------------------------------
// setovanje filtera na tabeli..
// --------------------------------------------------------
STATIC FUNCTION set_filter_kalk_doks( cFirma, cIdVd, dDatOd, dDatDo, cMagKto, cProdKto, cPartner )

   LOCAL cFilter := ".t."

   IF !Empty( cFirma )
      cFilter += " .and. idfirma == " + dbf_quote( cFirma )
   ENDIF

   IF !Empty( cIdVd )
      cFilter += " .and. " + cIdVd
   ENDIF

   IF !Empty( DToS( dDatOd ) )
      cFilter += " .and. DTOS(datdok) >= " + dbf_quote( DToS( dDatOd ) )
   ENDIF

   IF !Empty( DToS( dDatDo ) )
      cFilter += " .and. DTOS(datdok) <= " + dbf_quote( DToS( dDatDo ) )
   ENDIF

   IF !Empty( cMagKto )
      cFilter += " .and. " + cMagKto
   ENDIF

   IF !Empty( cProdKto )
      cFilter += " .and. " + cProdKto
   ENDIF

   IF !Empty( cPartner )
      cFilter += " .and. idpartner == " + dbf_quote( cPartner )
   ENDIF

   MsgO( "pripremam pregled ... sacekajte trenutak !" )
   SELECT kalk_doks
   SET FILTER to &cFilter
   GO TOP
   MsgC()

   RETURN .T.



// -------------------------------------------
// setovanje kolona za browse
// -------------------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   aImeKol := {}
   aKol := {}

   AAdd( aImeKol, { "F.",    {|| idfirma } } )
   AAdd( aImeKol, { "Tip", {|| idvd } } )
   AAdd( aImeKol, { "Broj",     {|| brdok } } )
   AAdd( aImeKol, { "Datum",    {|| datdok } } )
   AAdd( aImeKol, { "M.Konto",  {|| mkonto } } )
   AAdd( aImeKol, { "P.Konto",  {|| pkonto } } )
   AAdd( aImeKol, { "Partner",  {|| idpartner } } )
   AAdd( aImeKol, { "NV",       {|| Transform( field->nv, kalk_pic_iznos_bilo_gpicdem() ) } } )
   AAdd( aImeKol, { "VPV",      {|| Transform( vpv, kalk_pic_iznos_bilo_gpicdem() ) } } )
   AAdd( aImeKol, { "MPV",      {|| Transform( mpv, kalk_pic_iznos_bilo_gpicdem() ) } } )
   AAdd( aImeKol, { "Dokument",   {|| Brfaktp }                           } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN .T.

// -------------------------------------------------------------
// prikazi status dokumenata
// -------------------------------------------------------------
FUNCTION st_dok_status( cFirma, cIdVd, cBrDok )

   LOCAL nTArea := Select()
   LOCAL cStatus := "na stanju"

   IF cIdVd == "80" .AND. dok_u_procesu( cFirma, cIdVd, cBrDok )
      cStatus := "u procesu"
   ENDIF

   cStatus := PadR( cStatus, 10 )

   SELECT ( nTArea )

   RETURN cStatus

// ----------------------------------------
// key handler za browse_dok
// ----------------------------------------
STATIC FUNCTION brow_keyhandler( Ch )

   LOCAL hRec
   LOCAL _br_fakt

   DO CASE

   CASE Ch == K_F2

      hRec := dbf_get_rec()
      _br_fakt := hRec[ "brfaktp" ]

      Box(, 3, 60 )
      @ box_x_koord() + 1, box_y_koord() + 2 SAY "Ispravka podataka dokumenta ***"
      @ box_x_koord() + 3, box_y_koord() + 2 SAY "Broj fakture:" GET _br_fakt
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN DE_CONT
      ENDIF

      hRec[ "brfaktp" ] := _br_fakt
      update_rec_server_and_dbf( "kalk_doks", hRec, 1, "FULL" )
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_P
      // stampa dokumenta
      RETURN DE_CONT

   CASE Upper( Chr( Ch ) ) ==  "P"
      // povrat dokumenta u pripremu
      RETURN DE_CONT
   ENDCASE

   RETURN DE_CONT


// ----------------------------------------
// uslovi browse-a dokumenata
// ----------------------------------------
STATIC FUNCTION usl_browse_kalk_dokumenti( cFirma, cIdVd, dDatOd, dDatDo, ;
      cMagKto, cProdKto, cPartner )

   LOCAL nX := 1
   PRIVATE GetList := {}

   Box(, 10, 65 )

   SET CURSOR ON

   @ nX + box_x_koord(), 2 + box_y_koord() SAY "Firma" GET cFirma

   ++ nX
   @ nX + box_x_koord(), 2 + box_y_koord() SAY "Datumski period od" GET dDatOd
   @ nX + box_x_koord(), Col() + 1 SAY "do" GET dDatDo

   nX := nX + 2
   @ nX + box_x_koord(), 2 + box_y_koord() SAY "Vrsta dokumenta (prazno-svi)" GET cIdVd PICT "@S30"

   ++ nX
   @ nX + box_x_koord(), 2 + box_y_koord() SAY "Magacinski konto (prazno-svi)" GET cMagKto PICT "@S30"

   ++ nX
   @ nX + box_x_koord(), 2 + box_y_koord() SAY "Prodavnicki konto (prazno-svi)" GET cProdKto PICT "@S30"

   nX := nX + 2
   @ nX + box_x_koord(), 2 + box_y_koord() SAY "Partner:" GET cPartner VALID Empty( cPartner ) .OR. p_partner( @cPartner )

   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   cIdVd := Parsiraj( cIdVd, "idvd" )
   cMagKto := Parsiraj( cMagKto, "mkonto" )
   cProdKto := Parsiraj( cProdKto, "pkonto" )

   RETURN 1

/*

FUNCTION kalk_pregled_dokumenata_hronoloski()

  // o_roba()
   o_koncij()
   -- o_kalk()
   o_konto()

   cIdFirma := self_organizacija_id()
   cIdFirma := Left( cIdFirma, 2 )

   o_kalk_doks()
   SELECT kalk
   SELECT kalk_doks
   SET ORDER TO TAG "3" // kalk_doks

   Box(, 19, 77 )

   ImeKol := {}
   AAdd( ImeKol, { "Dat.Dok.",   {|| DatDok }                          } )
   AAdd( ImeKol, { "Podbr",      {|| IIF( Len( podbr ) > 1, Str( asc256( podbr ), 5 ), Str( Asc( podbr ), 3 ) ) }                          } )
   AAdd( ImeKol, { "VD  ",       {|| IdVD }                           } )
   AAdd( ImeKol, { "Broj  ",     {|| BrDok }                           } )
   AAdd( ImeKol, { "M.Konto",    {|| mkonto }                    } )
   AAdd( ImeKol, { "P.Konto",    {|| pkonto }                    } )
   AAdd( ImeKol, { "Nab.Vr",     {|| Transform( nv, kalk_pic_iznos_bilo_gpicdem() ) }                          } )
   AAdd( ImeKol, { "VPV",        {|| Transform( vpv, kalk_pic_iznos_bilo_gpicdem() ) }                          } )
   AAdd( ImeKol, { "MPV",        {|| Transform( mpv, kalk_pic_iznos_bilo_gpicdem() ) }                          } )
   AAdd( ImeKol, { "Dokument",   {|| Brfaktp }                           } )
   Kol := {}
   FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT

   SET CURSOR ON
   @ box_x_koord() + 2, box_y_koord() + 1 SAY "<SPACE> pomjeri dokument nagore"
   BrowseKey( box_x_koord() + 4, box_y_koord() + 1, box_x_koord() + 19, box_y_koord() + 77, ImeKol, {| Ch| pregled_dokumenata_hron_keyhandler( Ch ) }, "idFirma=cidFirma", cidFirma, 2,,, {|| .F. } )

   BoxC()

   my_close_all_dbf()

   RETURN .T.


STATIC FUNCTION pregled_dokumenata_hron_keyhandler( Ch )

   LOCAL cDn := "N", nTrecDok := 0, nRet := DE_CONT

   DO CASE
   CASE Ch == K_CTRL_PGUP
      Tb:GoTop()
      nRet := DE_REFRESH

   CASE Ch == K_CTRL_PGDN
      Tb:GoBottom()
      nRet := DE_REFRESH

   CASE Ch == K_ESC
      nRet := DE_ABORT

   CASE Ch == Asc( " " )

      SELECT kalk_doks
      cPodbr := podbr
      cIdvd := idvd
      cBrdok := brdok
      nTrecDok := RecNo()
      dDatdok := datdok
      SKIP -1
      IF Bof() .OR. datdok <> dDatDok
         Msgbeep( "Dokument je prvi unutar zadatog datuma" )
         GO nTrecDok; RETURN DE_CONT
      ENDIF
      cGPodbr := PodBr
      cGIdvd := idvd
      cGBrdok := brdok

      IF cGPodbr == cPodbr
         IF Len( podbr ) > 1
            IF ( Asc( cPodbr ) -1 ) > 5
               cPodbr  := chr256( asc256( cPodbr ) -1 )
            ELSE
               cGPodbr := chr256( asc256( cPodbr ) + 1 )
            ENDIF
         ELSE
            IF ( Asc( cPodbr ) -1 ) > 5
               cPodbr := Chr( Asc( cPodbr ) -1 )
            ELSE
               cGPodbr := Chr( Asc( cPodbr ) + 1 )
            ENDIF
         ENDIF
      ENDIF

      GO nTrecDok

      SELECT kalk_doks
      SET ORDER TO TAG "1"
      SEEK cidfirma + cidvd + cbrdok
      REPLACE podbr WITH cGPodbr

      SEEK cidfirma + cgidvd + cgbrdok
      REPLACE podbr WITH cPodbr

      SELECT kalk; SET ORDER TO TAG "1"
      SEEK cidfirma + cidvd + cbrdok
      DO WHILE !Eof() .AND. cIdFirma + cidvd + cbrdok = idfirma + idvd + brdok
         REPLACE podbr WITH cGPodbr
         SKIP
      ENDDO
      SEEK cidfirma + cgidvd + cgbrdok
      DO WHILE !Eof() .AND. cIdFirma + cgidvd + cgbrdok = idfirma + idvd + brdok
         REPLACE podbr WITH cPodbr
         SKIP
      ENDDO

      SELECT kalk_doks
      SET ORDER TO TAG "3"
      GO nTrecDok

      nRet := DE_REFRESH

   CASE Ch == K_ENTER
      kalk_pregled_dokumenta()
      SELECT kalk_doks
      nRet := DE_CONT

   CASE Ch == K_CTRL_P
      PushWA()
      cSeek := idfirma + idvd + brdok
      my_close_all_dbf()
      --kalk_stampa_dokumenta( .T., cSeek )
      -- o_kalk()
      -- o_kalk_doks()
      PopWA()
      nRet := DE_REFRESH
   ENDCASE

   RETURN nRet



STATIC FUNCTION kalk_pregled_dokumenta()

   SELECT kalk
   SET ORDER TO TAG "1"

   Box(, 15, 77, .T., "Pregled dokumenta" )

   ImeKol := {}
   AAdd( ImeKol, { "Rbr",       {|| Rbr }                         } )
   AAdd( ImeKol, { "M.Konto",    {|| mkonto }                     } )
   AAdd( ImeKol, { "P.Konto",    {|| pkonto }                     } )
   AAdd( ImeKol, { "Roba",       {|| IdRoba }                     } )
   AAdd( ImeKol, { "Kolicina",   {|| Transform( Kolicina, kalk_pic_kolicina_bilo_gpickol() ) } } )
   AAdd( ImeKol, { "Nc",         {|| Transform( nc, kalk_pic_iznos_bilo_gpicdem() ) }  } )
   AAdd( ImeKol, { "VPC",        {|| Transform( vpc, kalk_pic_iznos_bilo_gpicdem() ) }  } )
   AAdd( ImeKol, { "MPCSAPP",    {|| Transform( mpcsapp, kalk_pic_iznos_bilo_gpicdem() ) } } )

   Kol := {}
   FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT

   SET CURSOR ON
   @ box_x_koord() + 2, box_y_koord() + 1 SAY "Pregled dokumenta: "
   ?? kalk_doks->idfirma, "-", kalk_doks->idvd, "-", kalk_doks->brdok, " od", kalk_doks->datdok
   BrowseKey( box_x_koord() + 4, box_y_koord() + 1, box_x_koord() + 15, box_y_koord() + 77, ImeKol, {| Ch| kalk_pregled_dokumenta_key_handler( Ch ) }, "idFirma+idvd+brdok=kalk_doks->(idFirma+idvd+brdok)", kalk_doks->( idFirma + idvd + brdok ), 2,,, {|| .F. } )

   BoxC()

   RETURN .T.



STATIC FUNCTION kalk_pregled_dokumenta_key_handler( Ch )

   LOCAL cDn := "N", nTrecDok := 0, nRet := DE_CONT
   DO CASE
   CASE Ch == K_ENTER
      pregled_kartice()
      nRet := DE_CONT

   CASE Ch == K_CTRL_P
      nRet := DE_REFRESH
   ENDCASE

   RETURN nRet




STATIC FUNCTION pregled_kartice()

   nTreckalk := RecNo()

   cId := idfirma + idvd + brdok + rbr

   cIDFirma := idfirma
   cIdRoba := idroba
   cMkonto := mkonto
   cPkonto := pkonto

   IF !Empty( cPKonto )
      IF !Empty( cMkonto ) .AND. Pitanje(, "Pregled magacina - D, prodavnica - N" ) == "D"
         cPKonto := ""
      ELSE
         cMkonto := ""
      ENDIF
   ENDIF

   IF Empty( cPkonto )
      SET ORDER TO TAG "3"
   ELSE
      SET ORDER TO TAG "4"
   ENDIF

   Box(, 15, 77, .T., "Pregled  kartice " + iif( Empty( cPkonto ), cMKonto, cPKonto ) )

   o_kalk_kartica()
   my_dbf_zap()
   SET ORDER TO TAG "ID"

   IF !Empty( cMkonto )

      SELECT kalk
    --  SEEK cidfirma + cmkonto + cidroba

      nStanje := nNV := nVPV := 0

      DO WHILE !Eof() .AND. idfirma + mkonto + idroba == cidfirma + cmkonto + cidroba
         cId := idfirma + idvd + brdok + rbr
         IF mu_i == "1"
            nStanje += ( kolicina - gkolicina - gkolicin2 )
            nVPV += vpc * ( kolicina - gkolicina - gkolicin2 )
            nNV += nc * ( kolicina - gkolicina - gkolicin2 )
         ELSEIF mu_i == "3"
            nVPV += vpc * kolicina
         ELSEIF mu_i == "5"
            nStanje -= kolicina
            nVPV -= vpc * kolicina
            nNV -= nc * kolicina
         ENDIF
         SELECT kalk_kartica
         APPEND BLANK
         REPLACE id WITH cid, stanje WITH nStanje, VPV WITH nVPV, NV WITH nNV
         IF nStanje <> 0
            REPLACE VPC WITH nVPV / nStanje
         ENDIF
         SELECT kalk
         SKIP
      ENDDO
   ELSE
      SELECT kalk
    --  SEEK cidfirma + cpkonto + cidroba
      nStanje := nNV := nMPV := 0
      DO WHILE !Eof() .AND. idfirma + pkonto + idroba == cidfirma + cpkonto + cidroba
         cId := idfirma + idvd + brdok + rbr
         IF pu_i == "1"
            nStanje += ( kolicina - gkolicina - gkolicin2 )
            nMPV += mpcsapp * ( kolicina - gkolicina - gkolicin2 )
            nNV += nc * ( kolicina - gkolicina - gkolicin2 )
         ELSEIF pu_i == "3"
            nMPV += mpcsapp * kolicina
         ELSEIF pu_i == "5"
            nStanje -= kolicina
            nMPV -= Mpcsapp * kolicina
            nNV -= nc * kolicina
         ELSEIF pu_i == "I"
            nStanje -= gkolicin2
            nMPV -= Mpcsapp * gkolicin2
            nNV -= nc * gkolicin2
         ENDIF
         SELECT kalk_kartica
         APPEND BLANK
         REPLACE id WITH cid, stanje WITH nStanje, MPV WITH nMPV, NV WITH nNV
         IF nStanje <> 0
            REPLACE MPC WITH nMPV / nStanje
         ENDIF
         SELECT kalk
         SKIP
      ENDDO

   ENDIF

   SET RELATION TO idfirma + idvd + brdok + rbr into kalk_kartica

   ImeKol := {}
   AAdd( ImeKol, { "VD",       {|| idvd }                         } )
   AAdd( ImeKol, { "Brdok",    {|| brdok }                         } )
   AAdd( ImeKol, { "Rbr",      {|| Rbr }                         } )
   AAdd( ImeKol, { "Kolicina", {|| Transform( Kolicina, kalk_pic_kolicina_bilo_gpickol() ) } } )
   AAdd( ImeKol, { "Nc",       {|| Transform( nc, kalk_pic_iznos_bilo_gpicdem() ) }  } )
   AAdd( ImeKol, { "VPC",      {|| Transform( vpc, kalk_pic_iznos_bilo_gpicdem() ) }  } )
   IF !Empty( cPKonto )
      AAdd( ImeKol, { "MPV",    {|| Transform( mpcsapp * kolicina, kalk_pic_iznos_bilo_gpicdem() ) } } )
      AAdd( ImeKol, { "NV po kartici", {|| kalk_kartica->nv } } )
      AAdd( ImeKol, { "Stanje", {|| kalk_kartica->stanje } } )
      AAdd( ImeKol, { "MPC po Kartici", {|| kalk_kartica->mpc } } )
      AAdd( ImeKol, { "MPV po kartici", {|| kalk_kartica->mpv } } )
   ELSE
      AAdd( ImeKol, { "VPV",    {|| Transform( vpc * kolicina, kalk_pic_iznos_bilo_gpicdem() ) } } )
      AAdd( ImeKol, { "NV po kartici", {|| kalk_kartica->nv } } )
      AAdd( ImeKol, { "Stanje", {|| kalk_kartica->stanje } } )
      AAdd( ImeKol, { "VPC po Kartici", {|| kalk_kartica->vpc } } )
      AAdd( ImeKol, { "VPV po kartici", {|| kalk_kartica->vpv } } )
   ENDIF

   Kol := {}
   FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT

   SET CURSOR ON

  -- SELECT roba; HSEEK cidroba; SELECT kalk
   IF Empty( cPkonto )
--      SELECT koncij; SEEK Trim( cmkonto ); SELECT kalk
      @ box_x_koord() + 2, box_y_koord() + 1 SAY "Pregled kartice magacin: "; ?? cMkonto, "-", cidroba,"-", Left( roba->naz, 40 )
      BrowseKey( box_x_koord() + 4, box_y_koord() + 1, box_x_koord() + 15, box_y_koord() + 77, ImeKol, {| Ch| EdKart( Ch ) }, ;
         "idFirma+mkonto+idroba=cidFirma+cmkonto+cidroba", ;
         cidFirma + cmkonto + cidroba, 2,,, {|| OznaciMag( .T. ) } )
   ELSE
--      SELECT koncij; SEEK Trim( cpkonto ) ; SELECT kalk
      @ box_x_koord() + 2, box_y_koord() + 1 SAY "Pregled kartice prodavnica: "; ?? cPkonto, "-", cidroba, "-", Left( roba->naz, 40 )
      BrowseKey( box_x_koord() + 4, box_y_koord() + 1, box_x_koord() + 15, box_y_koord() + 77, ImeKol, {| Ch| EdKart( Ch ) }, ;
         "idFirma+pkonto+idroba=cidFirma+cpkonto+cidroba", ;
         cidFirma + cpkonto + cidroba, 2,,, {|| OznaciPro( .T. ) } )
   ENDIF

   SELECT kalk_kartica
   USE
   SELECT kalk
   SET ORDER TO TAG "1"
   GO nTreckalk

   BoxC()

   RETURN .T.




STATIC FUNCTION OznaciMag( fsilent )

   IF Round( kalk_kartica->stanje, 4 ) <> 0

      IF idvd <> "18"
         IF koncij->naz <> "N1" .AND. Round( VPC - kalk_kartica->vpc, 2 ) <> 0
            IF !fsilent
               MsgBeep( "vpc stavke <> vpc kumulativno po kartici !" )
            ENDIF
            RETURN .T.
         ENDIF
      ELSE
         IF Round( mpcsapp + vpc - kalk_kartica->vpc, 4 ) <> 0
            IF !fsilent
               MsgBeep( "vpc stavke <> vpc kumulativno po kartici !" )
            ENDIF
            RETURN .T.
         ENDIF

         IF mpcsapp <> 0  .AND. Abs( vpc + MPCSAPP ) / mpcsapp * 100 > 80
            IF !fsilent
               MSgBeep( "Promjena cijene za " + Str( Abs( vpc + MPCSAPP ) / mpcsapp * 100, 5, 0 ) + "!" )
            ENDIF
         ENDIF

      ENDIF

   ELSE
      IF Round( kalk_kartica->vpv, 4 ) <> 0
         IF !fsilent
            MsgBeep( "količina 0 , vpv <> 0 !" )
         ENDIF
         RETURN .T.
      ENDIF
      IF Round( kalk_kartica->nv, 4 ) <> 0
         IF !fsilent
            MsgBeep( "količina 0 , NV <> 0 !" )
         ENDIF
         RETURN .T.
      ENDIF
   ENDIF

   IF kalk_kartica->nv < 0
      IF !fsilent
         MsgBeep( "Nabavna cijena < 0 !" )
      ENDIF
      RETURN .T.
   ENDIF

   IF kalk_kartica->vpv <> 0 .AND. kalk_kartica->( nv / vpv ) * 100 > 150
      IF !fsilent
         MsgBeep( "VPV za " + Str( kalk_kartica->( nv / vpv ) * 100, 4, 0 ) + " veća od nabavne !" )
      ENDIF
   ENDIF

   IF kalk_kartica->stanje < 0
      IF !fsilent
         MsgBeep( "Stanje negativno !" )
      ENDIF
      RETURN .T.
   ENDIF

   RETURN .F.




STATIC FUNCTION OznaciPro( fsilent )

   IF Round( kalk_kartica->stanje, 4 ) <> 0

      IF idvd <> "19"
         IF koncij->naz <> "N1" .AND. Round( MPCSAPP - kalk_kartica->mpc, 2 ) <> 0  // po kartici i po stavci razlika
            IF !fsilent
               MsgBeep( "vpc stavke <> vpc kumulativno po kartici ?" )
            ENDIF
            RETURN .T.
         ENDIF
      ELSE
         IF Round( fcj + mpcsapp - kalk_kartica->mpc, 4 ) <> 0  // vpc iz nivelacije
            IF !fsilent
               MsgBeep( "mpc stavke <> mpc kumulativno po kartici ?" )
            ENDIF
            RETURN .T.
         ENDIF

         IF fcj <> 0  .AND. Abs( mpcsapp + fcj ) / fcj * 100 > 80
            IF !fsilent
               MSgBeep( "Promjena cijene za " + Str( Abs( mpcsapp + fcj ) / fcj * 100, 5, 0 ) + "?" )
            ENDIF
         ENDIF

      ENDIF

   ELSE
      IF Round( kalk_kartica->mpv, 4 ) <> 0
         IF !fsilent
            MsgBeep( "količina 0, mpv <> 0 !" )
         ENDIF
         RETURN .T.
      ENDIF
      IF Round( kalk_kartica->nv, 4 ) <> 0
         IF !fsilent
            MsgBeep( "količina 0, NV <> 0 !" )
         ENDIF
         RETURN .T.
      ENDIF
   ENDIF

   IF kalk_kartica->nv < 0
      IF !fsilent
         MsgBeep( "Nabavna cijena < 0 !" )
      ENDIF
      RETURN .T.
   ENDIF


   IF kalk_kartica->stanje < 0
      IF !fsilent
         MsgBeep( "Stanje negativno !" )
      ENDIF
      RETURN .T.
   ENDIF

   RETURN .F.




STATIC FUNCTION EdKart( Ch )

   LOCAL cDn := "N", nTrecDok := 0, nRet := DE_CONT
   DO CASE
   CASE Ch == K_ENTER
      IF !Empty( cPkonto )
         OznaciPro( .F. )
      ELSE
         OznaciMag( .F. )
      ENDIF

      nRet := DE_REFRESH

   CASE Ch == K_CTRL_P
      nRet := DE_REFRESH
   ENDCASE

   RETURN nRet

*/
