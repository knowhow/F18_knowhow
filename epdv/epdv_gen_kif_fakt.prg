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

MEMVAR _id_part, _datum, _opis


STATIC dDatOd
STATIC dDatDo
STATIC cFaktPath
STATIC cSifPath
STATIC cTDSrc
STATIC nZaok
STATIC nZaok2
STATIC cIdTar
STATIC cIdPart
STATIC s_cOpis

// kategorija partnera
// 1-pdv obv
// 2-ne pdv obvz
// 3-ino
// 0-svi za koje je pdv 0
// 9-svi za koje se pdv obracunava
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
      o_sg_kif()
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

         s_cOpis := sg_kif->naz
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


         gen_fakt_kif_item( cSezona )  // za jednu shema gen stavku formiraj kif

      ENDIF

      SELECT sg_kif
      SKIP

   ENDDO

FUNCTION close_open_fakt_epdv_tables()

   o_fakt()
   close_open_kuf_kif_sif()

   RETURN .T.



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
   LOCAL lProcesirano
   LOCAL nProcesiranoDokumenata := 0

   close_open_fakt_epdv_tables()

   SELECT FAKT
   PRIVATE cFilter := ""

   cFilter :=  dbf_quote( dDatOd ) + " <= datdok .and. " + dbf_quote( dDatDo ) + ">= datdok"

   // setuj tip dokumenta
   cFilter :=  cFilter + ".and. IdTipDok == " + dbf_quote( cTdSrc )



   SET ORDER TO TAG "1" // "1","IdFirma+idtipdok+brdok+rbr+podbr"
   SET FILTER TO &cFilter

   GO TOP


   nCount := 0
   DO WHILE !Eof()  // fakt_fakt

      SELECT p_kif

      Scatter()

      SELECT fakt

      dDMin := datdok
      dDMax := datdok

      // ove var moraju biti private da bi se mogle macro-om evaluirati
      PRIVATE _uk_b_pdv := 0
      PRIVATE _popust := 0

      lProcesirano := .F.
      nProcesiranoDokumenata := 0

      DO WHILE !Eof() .AND.  ( datdok == dDMax )

         SELECT fakt

         cBrdok := fakt->brdok
         cIdTipDok := fakt->idtipdok
         cIdFirma := fakt->IdFirma

         // datum kif-a
         _datum := fakt->datdok
         _id_part := fakt->idpartner
         _opis := s_cOpis

         // ispitati partnera koji stoji na fakt dokumentu
         lOslPoClanu := is_part_pdv_oslob_po_clanu( _id_part )
         lIno := partner_is_ino( _id_part )
         lPdvObveznik := partner_is_pdv_obveznik( _id_part )

         IF !Empty( cIdPart ) // ako se u shemi trazi da se stavi jedinstven partner sada ga staviti
            _id_part := cIdPart
         ENDIF

         lSkip := .F.
         DO CASE

         CASE cKatP == "1" // samo pdv obveznici

            IF lIno
               lSkip := .T.
            ENDIF

            IF !lPdvObveznik
               lSkip := .T.
            ENDIF

         CASE cKatP == "2"  // samo ne-pdv obveznici, ako je ino preskoci

            IF lPdvObveznik
               lSkip := .T.
            ENDIF

            IF lIno
               lSkip := .T.
            ENDIF

         CASE cKatP == "3"  // ino

            IF !lIno
               lSkip := .T.
            ENDIF

         CASE cKatP == "4"  // oslobodjen po clanu

            IF !lOslPoClanu
               lSkip := .T.
            ENDIF

         CASE cKatP == "0"  // pdv ili oslobodjen po clanu

            IF !( lOslPoClanu .OR. lIno )
               lSkip := .T.
            ENDIF

         CASE cKatP == "9"  // obracunati pdv

            IF ( lOslPoClanu .OR. lIno )
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

            select_o_roba( fakt->idroba )

            SELECT FAKT
            PUBLIC cDokTar := roba->idTarifa

            IF !Empty( cTarFilter )
               lRet := &( cTarFilter )

               IF !lRet
                  SKIP
                  LOOP
               ENDIF
            ENDIF


            IF lOslPoClanu == .T. // ako je oslobodjen po clanu... PDV0
               cDokTar := "PDV0  "
            ENDIF


            IF AllTrim( fakt->idvrstep ) == "AV" // ako je avansna faktura setuj na PDV7AV ili PDV0AV
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
            lProcesirano := .T.

            SELECT FAKT
            SKIP
         ENDDO

         IF !lSkip
            nProcesiranoDokumenata++
         ENDIF

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

      _datum := dDMax // za datum uzmi ovaj veci

      IF !lProcesirano
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
         _id_tar := cIdTar  // uzmi iz sg sifrarnika tarifu kojom treba setovati
      ELSE
         _id_tar := cDokTar // uzmi iz dokumenta
      ENDIF

      IF nProcesiranoDokumenata > 1 // ako sumiramo vise dokumenata moramo koristiti tarifu iz sifarnika
         _id_tar := cIdTar
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
         _i_pdv :=  _uk_pdv // nema formule koristi ukupan iznos bez pdv-a
      ENDIF

      _i_pdv := Round( _i_pdv, nZaok )


      SELECT P_KIF
      APPEND BLANK
      Gather()

      SELECT fakt

   ENDDO

   RETURN .T.
