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

STATIC dDatOd
STATIC dDatDo
STATIC cFaktPath
STATIC cSifPath
STATIC cTDSrc
STATIC nZaok
STATIC nZaok2
STATIC cIdTar
STATIC cIdPart
STATIC cOpis

// kategorija partnera
// 1-pdv obv
// 2-ne pdv obvz
STATIC cKatP

// kategorija partnera 2
// 1-fed
// 2-rs
// 3-bd
STATIC cKatP2
STATIC cRazbDan
STATIC cSBrDok

FUNCTION fakt_kif( dD1, dD2, cSezona )

   LOCAL nCount
   LOCAL cIdfirma

   IF cSezona == nil
      cSezona := ""
   ENDIF

   dDatOd := dD1
   dDatDo := dD2

   epdv_otvori_kif_tabele( .T. )

   SELECT F_SG_KIF
   IF !Used()
      O_SG_KIF
   ENDIF

   SELECT F_ROBA
   IF !Used()
      O_ROBA
   ENDIF

   SELECT sg_kif
   GO TOP

   nCount := 0

   DO WHILE !Eof()

      nCount ++

      IF Upper( aktivan ) == "N"
         SKIP
         LOOP
      ENDIF

      @ m_x + 1, m_y + 2 SAY "SG_KIF : " + Str( nCount )

      IF g_src_modul( src ) == "FAKT"

         cTdSrc := td_src

         // set id tarifu u kif dokumentu
         cIdTar := s_id_tar
         cIdPart := s_id_part

         cKatP := kat_p
         cKatP2 := kat_p_2

         cOpis := naz
         cRazbDan := razb_dan
         cSBrDok := s_br_dok

         PRIVATE cFormBPdv := form_b_pdv
         PRIVATE cFormPdv := form_pdv


         PRIVATE cTarFormula := ""
         PRIVATE cTarFilter := ""


         IF ";" $ id_tar
            // cDokTar je varijabla koja se dole setuje
            // za tarifu dokumenta
            cTarFilter := Parsiraj( id_tar, "cDokTar" )

            cTarFormula := ""
         ELSEIF ( "(" $ id_tar ) .AND. ( ")" $ id_tar )
            // zadaje se formula
            cTarFormula := id_tar
            cTarFilter := ""
         ELSE
            cTarFilter := ""
            cTarFormula := ""
         ENDIF

         nZaok := zaok
         nZaok2 := zaok2

         // za jednu shema gen stavku formiraj kif
         gen_fakt_kif_item( cSezona )

      ENDIF

      SELECT sg_kif
      SKIP

   ENDDO



FUNCTION close_open_fakt_epdv_tables()

   O_FAKT
   close_open_kuf_kif_sif()

   RETURN



STATIC FUNCTION gen_fakt_kif_item( cSezona )

   LOCAL cPomPath
   LOCAL cPomSPath
   LOCAL xDummy
   LOCAL nCount
   LOCAL cPom
   LOCAL cPartRejon
   LOCAL lPdvObveznik
   LOCAL lIno
   LOCAL lOslPoClanu
   LOCAL lSkip
   LOCAL lRet
   LOCAL nCijena
   LOCAL dDMin
   LOCAL dDMax
   LOCAL dDMinD
   LOCAL dDMaxD
   LOCAL nF_rabat := 0

   close_open_fakt_epdv_tables()

   SELECT FAKT
   PRIVATE cFilter := ""

   cFilter :=  dbf_quote( dDatOd ) + " <= datdok .and. " + dbf_quote( dDatDo ) + ">= datdok"

   // setuj tip dokumenta
   cFilter :=  cFilter + ".and. IdTipDok == " + dbf_quote( cTdSrc )


   // "1","IdFirma+idtipdok+brdok+rbr+podbr"
   SET ORDER TO TAG "1"
   SET FILTER TO &cFilter

   GO TOP

   // prosetajmo kroz fakt tabelu
   nCount := 0
   DO WHILE !Eof()

      SELECT p_kif

      Scatter()

      SELECT fakt

      dDMin := datdok
      dDMax := datdok

      // ove var moraju biti private da bi se mogle macro-om evaluirati
      PRIVATE _uk_b_pdv := 0
      PRIVATE _popust := 0

      DO WHILE !Eof() .AND.  ( datdok == dDMax )

         SELECT fakt

         cBrdok := fakt->brdok
         cIdTipDok := fakt->idtipdok
         cIdFirma := fakt->IdFirma

         // datum kif-a
         _datum := fakt->datdok
         _id_part := fakt->idpartner
         _opis := cOpis

         IF !Empty( cIdPart )
            _id_part := cIdPart
         ENDIF

         lOslPoClanu := IsOslClan( _id_part )
         lIno := IsIno( _id_part )
         lPdvObveznik := IsPdvObveznik( _id_part )

         lSkip := .F.
         DO CASE

         CASE cKatP == "1"

            // samo pdv obveznici
            IF lIno
               lSkip := .T.
            ENDIF

            IF !lPdvObveznik
               lSkip := .T.
            ENDIF

         CASE cKatP == "2"

            IF lPdvObveznik
               lSkip := .T.
            ENDIF

            // samo ne-pdv obveznici, ako je ino preskoci
            IF lIno
               lSkip := .T.
            ENDIF

         CASE cKatP == "3"
            // ino
            IF !lIno
               lSkip := .T.
            ENDIF

         ENDCASE

         cPartRejon := part_rejon( _id_part )

         DO CASE
         CASE cKatP2 == "1"
            // samo federacija
            IF !( ( cPartRejon == " " ) .OR. ( cPartRejon == "1" ) )
               lSkip := .T.
            ENDIF

         CASE cKatP2 == "2"
            // nije rs, preskoci
            IF !( cPartRejon == "2" )
               lSkip := .T.
            ENDIF

         CASE cKatP2 == "3"
            // nije bd, preskoci
            IF !( cPartRejon == "3" )
               lSkip := .T.
            ENDIF
         ENDCASE

         nCount ++

         cPom := "FAKT : " + cIdFirma + "-" + cIdTipDok + "-" + cBrDok
         @ m_x + 3, m_y + 2 SAY cPom

         cPom := "FAKT cnt : " + Str( nCount, 6 )
         @ m_x + 4, m_y + 2 SAY cPom

         cDokTar := ""

         SELECT FAKT

         dDMinD := datdok
         dDMaxD := datdok

         nF_rabat := 0

         DO WHILE !Eof() .AND. cBrDok == brdok .AND. cIdTipDok == IdTipDok .AND. cIdFirma == IdFirma

            IF lSkip
               SKIP
               LOOP
            ENDIF

            // na nivou dokumenta utvrdi min/max datum
            IF dDMinD > datdok
               dDMinD := datdok
            ENDIF

            IF dDMaxD < datdok
               dDMaxD := datdok
            ENDIF

            IF dDMin > datdok
               dDMin := datdok
            ENDIF

            IF dDMax < datdok
               dDMax := datdok
            ENDIF

            // pozicioniraj se na artikal u sifranriku robe
            SELECT ROBA
            SEEK fakt->idroba

            SELECT FAKT
            PUBLIC cDokTar := roba->idTarifa

            IF !Empty( cTarFilter )
               lRet := &( cTarFilter )

               IF !lRet
                  SKIP
                  LOOP
               ENDIF
            ENDIF

            // ako je oslobodjen po clanu... PDV0
            IF lOslPoClanu == .T.
               cDokTar := "PDV0  "
            ENDIF

            // ako je avansna faktura setuj na PDV7AV ili PDV0AV
            IF AllTrim( fakt->idvrstep ) == "AV"
               IF lIno .OR. lOslPoClanu
                  cDokTar := "PDV0AV"
               ELSE
                  cDokTar := "PDV7AV"
               ENDIF
            ENDIF

            _id_tar := cDokTar

            IF !Empty( cTarFormula )
               // moze sadrzavati varijablu _id_tar
               xDummy := &cTarFormula
            ENDIF

            IF cTDSrc == "11"
               nCijena := cijena / ( 1 + g_pdv_stopa( cDokTar ) / 100 )
            ELSE
               nCijena := cijena
            ENDIF

            // rabat
            nF_rabat := field->rabat

            // da li je roba zasticena cijena
            IF RobaZastCijena( roba->idtarifa ) .AND. !lPdvObveznik
               nF_rabat := 0
            ENDIF

            _uk_b_pdv += Round( kolicina * ( nCijena * ( 1 - nF_rabat / 100 ) ), nZaok )
            _popust +=  Round( kolicina * ( nCijena *  nF_rabat / 100 ), nZaok )

            SELECT FAKT
            SKIP
         ENDDO

         IF ( cRazbDan == "D" )

            // razbij po danima
            IF dDMinD <> dDMaxD
               MsgBeep( "U dokumentu " + cIdFirma + "-" + cIdTipDok + "-" + cBrDok + "  se nalaze datumi " + DToC( dDMaxD ) + "-" + DToC( dDMaxD ) + "##" + ;
                  "To nije uredu je se promet razbija po danima !!!" )
            ENDIF

         ENDIF

         IF cRazbDan <> "D"
            // nije po danima
            // za jedan dokument se uzima
            EXIT
            // ako pak jeste "D" onda se vrti u petlji
         ENDIF

         // datumski interval
      ENDDO

      // za datum uzmi ovaj veci
      _datum := dDMax

      IF lSkip
         // vrati se gore
         SELECT FAKT
         LOOP
      ENDIF

      IF !Empty( cSBrDok )
         // broj dokumenta
         _src_br := cSBrDok
         _src_br_2 := cSBrDok
      ELSE
         // broj dokumenta
         _src_br := cBrDok
         _src_br_2 := cBrDok
      ENDIF

      _uk_b_pdv := Round( _uk_b_pdv, nZaok2 )
      _uk_popust := Round( _popust, nZaok2 )

      IF !Empty( cIdTar ) .AND. cDokTar <> "PDV7AV" .AND. !lOslPoClanu
         // uzmi iz sg sifrarnika tarifu kojom treba setovati
         _id_tar := cIdTar
      ELSE
         // uzmi iz dokumenta
         _id_tar := cDokTar
      ENDIF

      PRIVATE _uk_pdv :=  _uk_b_pdv * (  g_pdv_stopa( _id_tar ) / 100 )

      IF !Empty( cFormBPDV )
         _i_b_pdv := &cFormBPdv
      ELSE
         // nema formule koristi ukupan iznos bez pdv-a
         _i_b_pdv := _uk_b_pdv
      ENDIF

      _i_b_pdv := Round( _i_b_pdv, nZaok )

      IF !Empty( cFormPDV )
         _i_pdv := &cFormPdv
      ELSE
         // nema formule koristi ukupan iznos bez pdv-a
         _i_pdv :=  _uk_pdv
      ENDIF

      _i_pdv := Round( _i_pdv, nZaok )

      // snimi gornje podatke
      SELECT P_KIF
      APPEND BLANK

      Gather()

      SELECT fakt

   ENDDO

   RETURN .T.
