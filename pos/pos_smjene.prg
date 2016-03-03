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

FUNCTION OdrediSmjenu( lOdredi )

   LOCAL cOK := " "
   PRIVATE dDatum := gDatum
   PRIVATE cSmjena := Str( Val( gSmjena ) + 1, Len( gSmjena ) )
   PRIVATE d_Pos := d_Doks := CToD( "" )
   PRIVATE s_Pos := s_Doks := " "

   IF gVSmjene == "N"
      cSmjena := "1"
      gSmjena := cSmjena
      gDatum := dDatum
      pos_status_traka()
      CLOSERET
   ENDIF

   IF lOdredi == nil
      lOdredi := .T.
   ENDIF

   O__POS
   O_POS_DOKS
   SET ORDER TO TAG "2"  // IdVd+DTOS (Datum)+Smjena
   SEEK VD_RN + Chr ( 254 )
   IF Eof() .OR. pos_doks->IdVd <> VD_RN
      SKIP -1
   ENDIF
   // ako je slucajno mijenjan IdPos
   DO WHILE !Bof() .AND. pos_doks->IdVd == VD_RN .AND. pos_doks->IdPos <> gIdPos
      SKIP -1
   ENDDO
   IF pos_doks->IdVd == VD_RN
      d_Doks := pos_doks->Datum     // posljednji datum i smjena u kojoj
      s_Doks := pos_doks->Smjena    // je kasa radila, prema DOKS
   ENDIF

   SELECT _POS
   SET ORDER TO TAG "2"
   SEEK "42"
   IF Found()
      // d_Pos := _POS->Datum
      DO WHILE !Eof() .AND. _POS->IdVd == VD_RN
         IF _POS->m1 <> "Z"
            // racun nije zakljucen, a samo mi je to interesantno
            d_Pos := _POS->Datum
            IF _POS->Smjena > s_Pos
               s_Pos := _POS->Smjena
            ENDIF
         ENDIF
         SKIP
      ENDDO
   ENDIF

   IF d_Pos > d_Doks
      // postoji promet u _POS i to nezakljucen
      dDatum := d_Pos
      cSmjena := s_Pos
   ENDIF


   Box(, 8, 50 )
   @ m_x, m_y + 1 SAY " DEFINISANJE DATUMA" + iif ( gVsmjene == "D", " I SMJENE ", " " ) COLOR F18_COLOR_INVERT

   DO WHILE !( cOK $ "Dd" )
      BoxCLS()
      @ m_x + 2, m_y + 5 SAY " DATUM:" GET dDatum VALID DatumOK ()
      @ m_x + 4, m_y + 5 SAY "SMJENA:" GET cSmjena VALID cSmjena $ "123"
      SET CURSOR ON
      @ m_x + 6, m_y + 5 SAY "Unos u redu (D/N)" GET cOK VALID cOK $ "DN" PICT "@!"
      READ
      IF LastKey() == K_ESC
         LOOP
      ENDIF
      IF ProvKonzBaze( dDatum, cSmjena )
         EXIT
      ENDIF
      cOK := " "
   ENDDO
   BoxC()

   gSmjena := cSmjena
   gDatum := dDatum

   pos_status_traka()
   CLOSE ALL

   RETURN



/*! \fn DatumOK()
 *  \brief
 */

STATIC FUNCTION DatumOK()

   // {

   IF dDatum > Date()
      MsgBeep( "Morate unijeti datum jedna ili manji od danasnjeg!" )
      RETURN ( .F. )
   ENDIF

   RETURN ( .T. )



STATIC FUNCTION SmjenaOK()

   // {
   IF Empty( s_Pos )
      // nema prometa u _POS (nezakljucenog)
      IF d_Doks == dDatum .AND. cSmjena < s_Doks
         MsgBeep ( "Postoje zakljuceni racuni iz smjene " + cSmjena + "!" )
         IF Pitanje(, "Zelite li nastaviti?", "N" ) == "N"
            RETURN ( .F. )
         ENDIF
      ENDIF
      RETURN ( .T. )
   ENDIF

   IF cSmjena > s_Pos
      MsgBeep ( "Postoje NEZAKLJUCENI racuni iz smjene " + cSmjena + "!" )
      IF Pitanje(, "Zelite li nastaviti?", "N" ) == "N"
         RETURN ( .F. )
      ENDIF
   ENDIF

   IF cSmjena < s_Pos
      MsgBeep ( "Postoje NEZAKLJUCENI racuni iz starije smjene " + cSmjena + "!" )
      RETURN ( .F. )
   ENDIF

   RETURN ( .T. )
// }



/*! \fn ProvKonzBaze(dDatum,cSmjena)
 *  \brief Provjerava konzistentnost podataka.
 *  \brief Ako su svi racuni zakljuceni ova funkcija ZAPPuje POS.
 *  \param dDatum
 *  \param cSmjena
 */

FUNCTION ProvKonzBaze( dDatum, cSmjena )

   // {
   LOCAL dPrevDat
   LOCAL cPrevSmj
   LOCAL aRadnici := {}
   LOCAL nA

   IF Empty( d_POS )
      // nema nezakljucenog prometa u _POS
      ? dDatum, d_Doks, cSmjena, s_Doks
      IF ( dDatum < d_DOKS ) .OR. ( dDatum == d_DOKS ) .AND. ( cSmjena < s_DOKS )
         MsgBeep ( "Postoji zakljucen promet na#datum " + FormDat1 ( d_DOKS ) + " u smjeni " + s_DOKS )
         IF Klevel > L_SYSTEM
            MsgBeep ( "Vracate se na unos!!!" )
            RETURN ( .F. )
         ELSE
            MsgBeep ( "Rad nastavlja SISTEM ADMINISTRATOR!!!" )
         ENDIF
      ENDIF
      IF !( d_DOKS == dDatum .AND. s_DOKS == cSmjena )
         SELECT _POS
         my_dbf_zap()
      ENDIF
      RETURN .T.
   ENDIF

   IF d_POS == dDatum
      // ima nezakljucenog prometa
      IF cSmjena < s_Pos
         MsgBeep ( "Postoje NEZAKLJUCENI racuni iz starije smjene " + cSmjena + "!#" + "Vracate se na unos!!!" )
         CLOSE ALL
         RETURN ( .F. )
      ENDIF
      IF gVsmjene == "D"
         MsgBeep ( "POTREBNO JE UNIJETI RACUNE KOJE STE IZDAVALI#" + "BEZ UNOSA U KASU", 20 )
      ENDIF
      CLOSE ALL
      RETURN ( .T. )
   ENDIF

   IF gVsmjene == "N"
      SELECT _POS
      my_dbf_zap()
      RETURN .T.
   ENDIF

   IF Pitanje(, "Izvrsiti vanredno zakljucenje kase?", "N" ) == "N"
      MsgBeep ( "Vracate se na definisanje datuma i smjene...", 30 )
      RETURN .F.
   ENDIF

   // uzmi datum i smjenu iz _POS
   dPrevDat := d_POS
   cPrevSmj := s_POS

   // azuriraj nezakljucene
   o_pos_tables()

   cVrijeme  := Left ( Time (), 5 )
   cIdVrsteP := gGotPlac

   SELECT _POS
   SET ORDER TO TAG "1"
   SEEK gIdPos
   DO WHILE !Eof() .AND. _POS->( IdPos + IdVd ) == ( gIdPos + VD_RN )
      cRadRac := _POS->BrDok
      Scatter ()
      SELECT pos_doks
      cBrDok := _BrDok := pos_novi_broj_dokumenta( gIdPos, VD_RN )
      _Vrijeme  := cVrijeme
      _IdVrsteP := cIdVrsteP
      _IdOdj    := Space ( Len ( _IdOdj ) )
      _M1       := OBR_NIJE
      APPEND BLANK
      Gather()
      SELECT _POS
      WHILE !Eof() .AND. _POS->( IdPos + IdVd + BrDok ) == ( gIdPos + VD_RN + cRadRac )
         IF _POS->m1 == "Z"
            SKIP
            LOOP
         ENDIF
         nRec := RecNo()
         Scatter ()
         _Kolicina := 0
         DO WHILE !Eof() .AND. _POS->( IdPos + IdVd + BrDok ) == ( gIdPos + VD_RN + cRadRac ) .AND. _POS->( IdRoba + IdCijena ) == ( _IdRoba + _IdCijena ) .AND. ;
               _POS->Cijena == _Cijena
            IF _POS->m1 == "Z"
               SKIP
               LOOP
            ENDIF
            _Kolicina += _POS->Kolicina
            SKIP
         ENDDO
         _Prebacen := OBR_NIJE
         SELECT POS
         _BrDok    := cBrDok
         _Vrijeme  := cVrijeme
         _IdVrsteP := cIdVrsteP
         APPEND BLANK
         Gather()
         SELECT _POS
         GO nRec
         DO WHILE ! Eof() .AND. _POS->( IdPos + IdVd + BrDok ) == ( gIdPos + VD_RN + cRadRac ) .AND. _POS->( IdRoba + IdCijena ) == ( _IdRoba + _IdCijena ) .AND. ;
               _POS->Cijena == _Cijena
            IF _POS->m1 == "Z"
               SKIP
               LOOP
            ENDIF
            REPLACE m1 WITH "Z"
            SKIP
         ENDDO
      ENDDO
   ENDDO

   SELECT _POS
   SEEK gIdPos + VD_RN
   DO WHILE !Eof() .AND. _POS->( IdPos + IdVd ) == ( gIdPos + VD_RN )
      Del_Skip()
   ENDDO

   // prvo izvadim sve radnike koji su radili u predmetnoj smjeni
   SELECT pos_doks
   SET ORDER TO TAG "2"
   SEEK VD_RN + DToS ( dPrevDat )
   DO WHILE !Eof() .AND. pos_doks->IdVd == "42" .AND. pos_doks->Datum == dPrevDat
      nA := AScan ( aRadnici, pos_doks->IdRadnik )
      IF nA == 0
         AAdd ( aRadnici, pos_doks->IdRadnik )
      ENDIF
      SKIP
   ENDDO

   // podesim datum i smjenu
   SavegDatum := gDatum
   SavegSmjena := gSmjena
   gDatum := dPrevDat
   gSmjena := cPrevSmj
   SavegIdRadnik := gIdRadnik

   // realizacija radnika, pojedinacno, i kase (finansijski)
   FOR n := 1 TO Len( aRadnici )
      gIdRadnik := aRadnici[ n ]
      realizacija_radnik( .T., "P", .T. )
   NEXT
   gIdRadnik := SavegIdRadnik
   realizacija_kase( .T. )

   // vrati datum i smjenu
   gDatum  := SavegDatum
   gSmjena := SavegSmjena

   my_close_all_dbf()

   RETURN .T.
// }


/*! \fn ZakljRadnik()
 *  \brief Zakljucenje radnika
 */

FUNCTION ZakljRadnik( Ch )

   // {
   LOCAL cIdSave

   // M->Ch je iz OBJDB
   IF Ch <> NIL .AND. M->Ch == 0
      RETURN ( DE_CONT )
   ENDIF
   IF LastKey() == K_ESC
      RETURN ( DE_ABORT )
   ENDIF
   IF Upper( Chr( LastKey() ) ) == "Z"
      IF Round ( ZAKSM->Otv, 4 ) <> 0
         MsgBeep ( "#Zakljucenje radnika nije moguce!#" + "Postoje nezakljuceni racuni!!!#" )
         RETURN ( DE_CONT )
      ENDIF
      Beep ( 3 )
      IF !Pitanje(, "Zelite li zakljuciti radnika (D/N)?", " " ) == "D"
         MsgBeep ( "Radnik nije zakljucen!" )
         RETURN ( DE_CONT )
      ENDIF
      cIdSave := gIdRadnik
      gIdRadnik := ZAKSM->IdRadnik
      IF !realizacija_radnik( .T., "P", .T. )
         // nije uspio stampati pazar radnika, pa ga sad ne mogu ni zakljuciti
         MsgBeep( "Nije uspjelo stampanje pazara!#Radnik nije zakljucen!" )
         gIdRadnik := cIdSave
         SELECT ZAKSM
         RETURN ( DE_CONT )
      ENDIF
      UkloniRadne( ZAKSM->IdRadnik )
      gIdRadnik := cIdSave
      SELECT ZAKSM
      my_delete_with_pack()
      RETURN ( DE_REFRESH )
   ENDIF

   RETURN ( DE_CONT )



/*! \fn NovaSmjGas()
 *  \brief
 */

FUNCTION NovaSmjGas()

   // {
   LOCAL aOpcn[ 2 ]
   LOCAL nIzb
   LOCAL cOK := " "

   aOpcn[1 ] := "Otvori novu smjenu"
   aOpcn[2 ] := "Gasenje kase      "

   DO WHILE .T.
      nIzb := KudaDalje ( "ODABERITE NAREDNU AKCIJU", aOpcn )
      IF nIzb == 1
         IF gDatum == Date()
            gSmjena := Str ( Val ( gSmjena ) + 1, 1 )
         ELSE
            // radio je staru smjenu, pa nek unese smjenu danasnjeg dana
            gDatum := Date ()
            MsgBeep( "#Zavrsili ste neregularno okoncanu smjenu!#" + "Unesite smjenu koju radite na danasnji dan!#", 30 )
            Box(, 5, 30 )
            WHILE cOK <> "D"
               cOK := " "
               @ m_x + 1, m_y + 1 SAY " Datum" GET gDatum WHEN .F.
               @ m_x + 3, m_y + 1 SAY "Smjena" GET gSmjena VALID gSmjena $ "123"
               @ m_x + 5, m_y + 1 SAY "Unos u redu (D/N)" GET cOK PICT "@!" VALID cOK $ "DN"
               READ
            ENDDO
            BoxC()
         ENDIF
         EXIT
      ELSEIF nIzb == 2
         goModul:quit()
      ENDIF
   ENDDO
   pos_status_traka()

   RETURN



/*! \fn OtvoriSmjenu()
 *  \brief Otvaranje smjene
 */

FUNCTION OtvoriSmjenu()

   // {
   LOCAL fImaNezak := .F.

   IF gVSmjene == "N"
      MsgBeep( "Promet kase se ne vodi po smjenama!" )
      RETURN
   ENDIF

   // potrazi ima li nezakljucenih radnika i obavjesti

   O__POS
   SEEK gIdPos + VD_RN

   IF Found()
      fImaNezak := .T.
      MsgBeep ( "Postoje nezakljuceni radnici!!!" )
      IF Pitanje(, "Zelite li nastaviti s otvaranjem smjene!", " " ) == "N"
         my_close_all_dbf()
         RETURN
      ENDIF
   ENDIF

   IF fImaNezak
      MsgBeep( "Kada zakljucite nezakljucene radnike,#" + "Pazar smjene uradite u opciji#" + "IZVJESTAJI / REALIZACIJA / KASE#" + "zadajuci smjenu ciji pazar nije odstampan!" )
   ELSE
      // odstampam ubiljezeni pazar smjene
      CLOSE ALL
      IF !realizacija_kase( .T. )
         MsgBeep ( "#Stampanje pazara smjene nije uspjelo!#" )
         my_close_all_dbf()
         RETURN 0
      ENDIF
      IF gModul == "HOPS"
         // generisi utrosak sirovina za smjenu
         GenUtrSir( gDatum, gDatum, gSmjena )
      ENDIF
   ENDIF

   gSmjena := Str( Val( gSmjena ) + 1, Len( gSmjena ) )
   MsgBeep( "Otvorena je smjena " + gSmjena )
   my_close_all_dbf()

   RETURN
