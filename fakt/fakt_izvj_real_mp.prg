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

STATIC PIC_IZN := "999999999.99"
STATIC _NUM := 12
STATIC _DEC := 2
STATIC _ZAOK := 2
STATIC _FNUM := 15
STATIC _FDEC := 4


FUNCTION fakt_real_maloprodaje()

   LOCAL nOperater
   LOCAL cFirma
   LOCAL dD_from
   LOCAL dD_to
   LOCAL cDocType
   LOCAL nVar
   LOCAL nT_uk := 0
   LOCAL nT_pdv := 0
   LOCAL nT_osn := 0
   LOCAL _params

   IF ! fakt_mp_uzmi_parametre_izvjestaja( @_params )
      RETURN .F.
   ENDIF

   _cre_tbl()
   fakt_gen_rekapitulacija_mp( _params )

   SELECT r_export
   IF reccount2() == 0
      MsgBeep( "Nema podataka za prikaz !" )
      my_close_all_dbf()
      RETURN
   ENDIF

   START PRINT CRET

   ?
   ? "REALIZACIJA PRODAJE na dan: " + DToC( Date() )
   ? "-----------------------------------------------"
   ? "Period od:" + DToC( _params[ "datum_od" ] ) + " do:" + DToC( _params[ "datum_do" ] )
   ?

   P_COND

   fakt_mp_set_totali( @nT_osn, @nT_pdv, @nT_uk )

   fakt_mp_po_operaterima()
   fakt_mp_po_vrstama_placanja()
   
   IF _params[ "tip_partnera" ] == "D" 
      ?
      fakt_mp_po_tipu_partnera()
   ENDIF

   ?
   IF _params[ "varijanta" ] = 1
      fakt_mp_po_robama()
   ELSEIF _params[ "varijanta" ] = 2
      fakt_mp_po_dokumentima()
   ENDIF

   ?

   P_10CPI

   ? "REKAPITULACIJA:"
   ? "---------------------------"
   ? "1) ukupno bez pdv-a:"
   @ PRow(), PCol() + 1 SAY Str( nT_osn, _NUM, _DEC ) PICT PIC_IZN
   ? "2) vrijednost pdv-a:"
   @ PRow(), PCol() + 1 SAY Str( nT_pdv, _NUM, _DEC ) PICT PIC_IZN
   ? "3)    ukupno sa pdv:"
   @ PRow(), PCol() + 1 SAY Str( nT_uk, _NUM, _DEC ) PICT PIC_IZN

   FF
   ENDPRINT

   RETURN


STATIC FUNCTION fakt_mp_uzmi_parametre_izvjestaja( params )

   LOCAL _x := 1
   LOCAL _tip_partnera, _id_firma, _d_from, _d_to, _dok_tip, _operater, _varijanta
   LOCAL _partner, _vrsta_p

   _id_firma := PadR( fetch_metric( "fakt_real_mp_firma", my_user(), "" ), 100 )
   _d_from := fetch_metric( "fakt_real_mp_datum_od", my_user(), Date() )
   _d_to := fetch_metric( "fakt_real_mp_datum_do", my_user(), Date() )
   _dok_tip := PadR( fetch_metric( "fakt_real_mp_tip_dok", my_user(), "11;" ), 100 )
   _operater := fetch_metric( "fakt_real_mp_operater", my_user(), 0 )
   _vrsta_p := fetch_metric( "fakt_real_mp_vrsta_p", my_user(), Space( 2 ) )
   _varijanta := fetch_metric( "fakt_real_mp_varijanta", my_user(), 1 )
   _tip_partnera := fetch_metric( "fakt_real_mp_tip_partnera", my_user(), "D" )
   _partner := PadR( fetch_metric( "fakt_real_mp_partner", my_user(), "" ), 200 )

   Box( , 14, 66 )

   @ m_x + _x, m_y + 2 SAY "**** REALIZACIJA PRODAJE ****"
   _x += 2
   @ m_x + _x, m_y + 2 SAY "Firma (prazno-sve):" GET _id_firma PICT "@S20"
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Obuhvatiti period od:" GET _d_from
   @ m_x + _x, Col() + 1 SAY "do:" GET _d_to
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Vrste dokumenata:" GET _dok_tip PICT "@S30"
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Partner (prazno-svi):" GET _partner PICT "@S40"
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Vrsta plaćanja (prazno-svi):" GET _vrsta_p VALID Empty( _vrsta_p ) .OR. P_VRSTEP( @_vrsta_p )
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Operater (0-svi):" GET _operater PICT "9999999999" ;
      VALID {|| _operater == 0, iif( _operater == -99, choose_f18_user_from_list( @_operater ), .T. ) }
   _x += 2
   @ m_x + _x, m_y + 2 SAY8 "Razvrstati po tipu partnera (D/N)?" GET _tip_partnera VALID _tip_partnera $ "DN" PICT "@!"
   _x += 2
   @ m_x + _x, m_y + 2 SAY8 "Varijanta prikaza 1-po robi 2-po dokumentima"
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "                  3-samo total" GET _varijanta PICT "9"

   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   set_metric( "fakt_real_mp_firma", my_user(), AllTrim( _id_firma ) )
   set_metric( "fakt_real_mp_datum_od", my_user(), _d_from )
   set_metric( "fakt_real_mp_datum_do", my_user(), _d_to )
   set_metric( "fakt_real_mp_tip_dok", my_user(), AllTrim( _dok_tip ) )
   set_metric( "fakt_real_mp_operater", my_user(), _operater )
   set_metric( "fakt_real_mp_vrsta_p", my_user(), _vrsta_p )
   set_metric( "fakt_real_mp_varijanta", my_user(), _varijanta )
   set_metric( "fakt_real_mp_tip_partnera", my_user(), _tip_partnera )
   set_metric( "fakt_real_mp_partner", my_user(), AllTrim( _partner ) )

   // snimi parametre i matricu
   params := hb_Hash()
   params[ "datum_od" ] := _d_from
   params[ "datum_do" ] := _d_to
   params[ "varijanta" ] := _varijanta
   params[ "tip_dok" ] := AllTrim( _dok_tip )
   params[ "operater" ] := _operater
   params[ "firma" ] := AllTrim( _id_firma )
   params[ "tip_partnera" ] := _tip_partnera
   params[ "partner" ] := _partner
   params[ "vrstap" ] := _vrsta_p


   RETURN .T.


STATIC FUNCTION fakt_gen_rekapitulacija_mp( params )

   LOCAL _filter
   LOCAL cF_firma
   LOCAL cF_tipdok
   LOCAL cF_brdok
   LOCAL nUkupno
   LOCAL _tip_partnera := "1"
   LOCAL _pdv_broj := ""
   LOCAL _pdv_clan
   LOCAL _d_do, _d_od, _varijanta, _tip_dok, _operater, _id_firma, _rasclaniti
   LOCAL _vrsta_p

   O_FAKT_DOKS
   O_FAKT
   O_ROBA
   O_SIFK
   O_SIFV
   O_VRSTEP
   O_TARIFA
   O_PARTN

   // parametri
   _d_od := params[ "datum_od" ]
   _d_do := params[ "datum_do" ]
   _varijanta := params[ "varijanta" ]
   _tip_dok := params[ "tip_dok" ]
   _operater := params[ "operater" ]
   _id_firma := params[ "firma" ]
   _rasclaniti := params[ "tip_partnera" ] == "D"
   _partner := params[ "partner" ]
   _vrsta_p := params[ "vrstap" ]

   _filter := ""

   IF !Empty( _id_firma )
      _filter += Parsiraj( AllTrim( _id_firma ), "idfirma" )
   ENDIF

   // vrsta placanja...
   IF !Empty( _vrsta_p )
      IF !Empty( _filter )
         _filter += ".and."
      ENDIF
      _filter += "idvrstep = " + _filter_quote( _vrsta_p )
   ENDIF

   // operater
   IF _operater <> 0
      IF !Empty( _filter )
         _filter += ".and."
      ENDIF
      _filter += "oper_id = " + _filter_quote( _operater )
   ENDIF

   // tipovi dokumenata
   IF !Empty( _tip_dok )
      IF !Empty( _filter )
         _filter += ".and."
      ENDIF
      _filter += Parsiraj( AllTrim( _tip_dok ), "idtipdok" )
   ENDIF

   // partner
   IF !Empty( _partner )
      IF !Empty( _filter )
         _filter += ".and."
      ENDIF
      _filter += Parsiraj( AllTrim( _partner ), "idpartner" )
   ENDIF

   // datumi od-do
   IF !Empty( DToS( _d_od ) )
      IF !Empty( _filter )
         _filter += ".and."
      ENDIF
      _filter += "datdok >=" + _filter_quote( _d_od )
   ENDIF

   IF !Empty( DToS( _d_do ) )
      IF !Empty( _filter )
         _filter += ".and."
      ENDIF
      _filter += "datdok <=" + _filter_quote( _d_do )
   ENDIF

   msgo( "generisem podatke ..." )

   SELECT fakt_doks
   SET FILTER to &_filter
   GO TOP

   DO WHILE !Eof()

      cF_firma := field->idfirma
      cF_tipdok := field->idtipdok
      cF_brdok := field->brdok
      nUkupno := field->iznos

      _oper_id := field->oper_id

      SELECT fakt
      GO TOP
      SEEK cF_firma + cF_tipdok + cF_brdok

      DO WHILE !Eof() .AND. field->idfirma == cF_firma ;
            .AND. field->idtipdok == cF_tipdok ;
            .AND. field->brdok == cF_brdok
		
         cRoba_id := field->idroba
         cPart_id := field->idpartner
	
         // fizicka lica
         _tip_partnera := "1"

         IF _rasclaniti

            _pdv_broj := firma_pdv_broj( cPart_id )
            _pdv_clan := IsOslClan( cPart_id )

            IF !Empty( _pdv_broj )
               _tip_partnera := "2"
            ENDIF

         ENDIF

         SELECT roba
         SEEK cRoba_id

         SELECT tarifa
         SEEK roba->idtarifa

         SELECT partn
         SEEK cPart_id

         SELECT fakt

         nCjPDV := 0
         nCj2PDV := 0
         nCjBPDV := 0
         nCj2BPDV := 0
         nVPopust := 0
	
         // procenat pdv-a
         nPPDV := tarifa->opp

         // kolicina
         nKol := field->kolicina
         nRCijen := field->cijena

	
         IF Left( field->dindem, 3 ) <> Left( ValBazna(), 3 )
            // preracunaj u EUR
            // omjer EUR / KM
            nRCijen := nRCijen / OmjerVal( ValBazna(), ;
               field->dindem, field->datdok )
            nRCijen := Round( nRCijen, DEC_CIJENA() )
         ENDIF

         // rabat - popust
         nPopust := field->rabat
	
         // ako je 13-ka ili 27-ca
         // cijena bez pdv se utvrdjuje unazad
         IF ( field->idtipdok == "13" .AND. glCij13Mpc ) .OR. ;
               ( field->idtipdok $ "11#27" .AND. gMP $ "1234567" )
            // cjena bez pdv-a
            nCjPDV := nRCijen
            nCjBPDV := ( nRCijen / ( 1 + nPPDV / 100 ) )
         ELSE
            // cjena bez pdv-a
            nCjBPDV := nRCijen
            nCjPDV := ( nRCijen * ( 1 + nPPDV / 100 ) )
         ENDIF
	
         // izracunaj vrijednost popusta
         IF Round( nPopust, 4 ) <> 0
            // vrijednost popusta
            nVPopust := ( nCjBPDV * ( nPopust / 100 ) )
         ENDIF
	
         // cijena sa popustom bez pdv-a
         nCj2BPDV := ( nCjBPDV - nVPopust )
		
         // izracuna PDV na cijenu sa popustom
         nCj2PDV := ( nCj2BPDV * ( 1 + nPPDV / 100 ) )
		
         // preracunaj VPDV sa popustom
         nVPDV := ( nCj2BPDV * ( nPPDV / 100 ) )

         SELECT r_export
         APPEND BLANK

         REPLACE field->tip WITH _tip_partnera
         REPLACE field->idfirma WITH fakt->idfirma
         REPLACE field->idtipdok WITH fakt->idtipdok
         REPLACE field->brdok WITH fakt->brdok
         REPLACE field->datdok WITH fakt->datdok
         REPLACE field->operater WITH _oper_id
         REPLACE field->vrstap WITH  get_naziv_vrsta_placanja( fakt->idtipdok, fakt->idvrstep )
         REPLACE field->part_id WITH fakt->idpartner
         REPLACE field->part_naz WITH AllTrim( partn->naz )
         REPLACE field->roba_id WITH fakt->idroba
         REPLACE field->roba_naz WITH AllTrim( roba->naz )
         REPLACE field->kolicina WITH nKol
         REPLACE field->s_pdv WITH nPPDV
         REPLACE field->popust WITH nVPopust
         REPLACE field->c_bpdv WITH nCj2BPdv
         REPLACE field->pdv WITH nVPDV
         REPLACE field->c_pdv WITH nCj2PDV
         REPLACE field->uk_fakt WITH nUkupno

         SELECT fakt
         SKIP

      ENDDO

      SELECT fakt_doks
      SKIP

   ENDDO

   msgc()

   RETURN


STATIC FUNCTION get_naziv_vrsta_placanja( tip_dok, vrsta_p )

   LOCAL _ret := "MP GOTOVINA"

   DO CASE

   CASE tip_dok == "11"

      IF !Empty( vrsta_p )
         IF vrsta_p == "KT"
            _ret := "MP KARTICA"
         ELSEIF vrsta_p == "AV"
            _ret := "MP AVANSNA FAKTURA"
         ELSEIF vrsta_p == "VR"
            _ret := "MP VIRMANSKO PLACANJE"
         ENDIF
      ENDIF

   CASE tip_dok == "10"
      _ret := "VP VIRMANSKO PLACANJE"
      IF !Empty( vrsta_p )
         IF vrsta_p == "G "
            _ret := "VP GOTOVINA"
         ELSEIF vrsta_p == "KT"
            _ret := "VP KARTICA"
         ELSEIF vrsta_p == "AV"
            _ret := "VP AVANSNA FAKTURA"
         ENDIF
      ENDIF

   ENDCASE

   RETURN _ret


STATIC FUNCTION _cre_tbl()

   LOCAL aDbf := {}

   AAdd( aDbf, { "tip", "C", 1, 0 } )
   AAdd( aDbf, { "idfirma", "C", 2, 0 } )
   AAdd( aDbf, { "idtipdok", "C", 2, 0 } )
   AAdd( aDbf, { "brdok", "C", 10, 0 } )
   AAdd( aDbf, { "datdok", "D", 8, 0 } )
   AAdd( aDbf, { "operater", "N", 10, 0 } )
   AAdd( aDbf, { "vrstap", "C", 40, 0 } )
   AAdd( aDbf, { "part_id", "C", 6, 0 } )
   AAdd( aDbf, { "part_naz", "C", 100, 0 } )
   AAdd( aDbf, { "roba_id", "C", 10, 0 } )
   AAdd( aDbf, { "roba_naz", "C", 100, 0 } )
   AAdd( aDbf, { "kolicina", "N", 15, 5 } )
   AAdd( aDbf, { "popust", "N", 15, 5 } )
   AAdd( aDbf, { "s_pdv", "N", 12, 2 } )
   AAdd( aDbf, { "c_bpdv", "N", _FNUM, _FDEC } )
   AAdd( aDbf, { "pdv", "N", _FNUM, _FDEC } )
   AAdd( aDbf, { "c_pdv", "N", _FNUM, _FDEC } )
   AAdd( aDbf, { "uk_fakt", "N", _FNUM, _FDEC } )

   t_exp_create( aDbf )
   O_R_EXP

   INDEX ON idfirma + idtipdok + brdok TAG "1"
   INDEX ON roba_id TAG "2"
   INDEX ON Str( operater, 10 ) + idfirma + idtipdok + brdok TAG "3"
   INDEX ON tip TAG "4"
   INDEX ON vrstap TAG "5"

   RETURN


STATIC FUNCTION fakt_mp_set_totali( nT_os, nT_pdv, nT_uk )

   RETURN fakt_mp_po_dokumentima( @nT_os, @nT_pdv, @nT_uk, .T. )


STATIC FUNCTION fakt_mp_po_dokumentima( nT_osnovica, nT_pdv, nT_ukupno, lCalc )

   LOCAL nOsnovica
   LOCAL nPDV
   LOCAL nUkupno
   LOCAL nRbr := 0
   LOCAL nRow := 35
   LOCAL cLine := ""
   LOCAL nOperater
   LOCAL cOper_Naz := ""

   IF lCalc == nil
      lCalc := .F.
   ENDIF

   nT_osnovica := 0
   nT_pdv := 0
   nT_ukupno := 0

   IF lCalc == .F.
      // vraca liniju
      g_l_mpdok( @cLine )

      // zaglavlje pregled po robi
      s_z_mpdok( cLine )
   ENDIF

   SELECT r_export
   // po dokumentima
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      cIdFirma := field->idfirma
      cIdTipDok := field->idtipdok
      cBrDok := field->brdok
      cPart_id := field->part_id
      cPart_naz := field->part_naz
      nOperater := field->operater
      cOper_naz := GetFullUserName( nOperater )
	
      nOsnovica := 0
      nPDV := 0
      nUkupno := 0
      nS_pdv := 0
      nUk_fakt := 0

      DO WHILE !Eof() .AND. field->idfirma + field->idtipdok + field->brdok == cIdFirma + cIdTipDok + cBrDok
		
         nOsnovica += field->kolicina * field->c_bpdv
         nPDV += field->kolicina * field->pdv
         nS_pdv := field->s_pdv
         nUk_fakt := field->uk_fakt

         SKIP
      ENDDO

      // zaokruzi
      nOsnovica := Round( ( nUk_fakt / ( 1 + ( nS_pdv / 100 ) ) ), ;
         ZAO_VRIJEDNOST() )
      nPDV := Round( ( nUk_fakt / ( 1 + ( nS_pdv / 100 ) ) * ;
         ( nS_pdv / 100 ) ), ZAO_VRIJEDNOST() )
      nUkupno := Round( nUk_fakt, ZAO_VRIJEDNOST() )

      IF lCalc == .F.
         // pa ispisi tu stavku

         ? PadL( AllTrim( Str( ++nRbr ) ), 4 ) + "."

         // dokument
         @ PRow(), PCol() + 1 SAY PadR( AllTrim( cIdFirma + "-" + cIdTipDok + "-" + cBrDok ), 16 )

         // partner
         @ PRow(), PCol() + 1 SAY PadR( AllTrim( cPart_id ) + "-" +  AllTrim( cPart_naz ), 40 )
	
         // osnovica
         @ PRow(), nRow := PCol() + 1 SAY Str( nOsnovica, _NUM, _DEC )  PICT PIC_IZN

         // pdv
         @ PRow(), PCol() + 1 SAY Str( nPDV, _NUM, _DEC ) PICT PIC_IZN

         // ukupno
         @ PRow(), PCol() + 1 SAY Str( nUkupno, _NUM, _DEC ) PICT PIC_IZN
		
         // operater
         @ PRow(), PCol() + 1 SAY PadR( AllTrim( cOper_naz ), 20 )

      ENDIF

      nT_ukupno += nUkupno
      nT_osnovica += nOsnovica
      nT_pdv += nPDV

   ENDDO

   IF lCalc == .F.
	
      // ispisi sada total
      ? cLine

      ? "UKUPNO:"
      @ PRow(), nRow SAY Str( nT_osnovica, _NUM, _DEC ) PICT PIC_IZN
      @ PRow(), PCol() + 1 SAY Str( nT_pdv, _NUM, _DEC ) PICT PIC_IZN
      @ PRow(), PCol() + 1 SAY Str( nT_ukupno, _NUM, _DEC ) PICT PIC_IZN

      ? cLine
   ENDIF

   RETURN


STATIC FUNCTION fakt_mp_po_tipu_partnera( nT_osnovica, nT_pdv, nT_ukupno )

   LOCAL nOsnovica
   LOCAL nPDV
   LOCAL nUkupno
   LOCAL nRbr := 0
   LOCAL nRow := 35
   LOCAL cLine := ""
   LOCAL cF_tipdok
   LOCAL cF_firma
   LOCAL cF_brdok
   LOCAL _tip_partnera, _opis
   LOCAL __osn, __pdv, __total

   // 1 - nepdv
   // 2 - pdv
   // 3 - ino

   nT_osnovica := 0
   nT_pdv := 0
   nT_ukupno := 0

   g_l_mptip( @cLine )

   s_z_mptip( cLine )

   SELECT r_export
   // po operaterima
   SET ORDER TO TAG "4"
   GO TOP

   DO WHILE !Eof()

      _tip_partnera := field->tip

      // iznosi...
      __osn := 0
      __pdv := 0
      __total := 0

      DO WHILE !Eof() .AND. field->tip == _tip_partnera

         _tip_partnera := field->tip

         _id_firma := field->idfirma
         _tip_dok := field->idtipdok
         _br_dok := field->brdok

         nOsnovica := 0
         nPDV := 0
         nUkupno := 0
         nS_pdv := 0
         nUk_fakt := 0

         DO WHILE !Eof() .AND. _tip_partnera == field->tip .AND. field->idfirma + field->idtipdok + field->brdok == _id_firma + _tip_dok + _br_dok
		
            nS_pdv := field->s_pdv
            nUk_fakt := field->uk_fakt

            SKIP

         ENDDO

         // zaokruzi
         nOsnovica := Round( ( nUk_fakt / ( 1 + ( nS_pdv / 100 ) ) ), ;
            ZAO_VRIJEDNOST() )
         nPDV := Round( ( nUk_fakt / ( 1 + ( nS_pdv / 100 ) ) * ;
            ( nS_pdv / 100 ) ), ZAO_VRIJEDNOST() )
         nUkupno := Round( nUk_fakt, ZAO_VRIJEDNOST() )

         __osn += nOsnovica
         __pdv += nPDV
         __total += nUkupno

      ENDDO

      ? PadL( AllTrim( Str( ++nRbr ) ), 4 ) + "."

      _opis := "Fizicka lica"

      IF _tip_partnera == "2"
         _opis := "Pravna lica"
      ENDIF

      // tip partnera
      @ PRow(), PCol() + 1 SAY PadR( _opis, 40 )
	
      // total
      @ PRow(), nRow := PCol() + 1 SAY Str( __osn, _NUM, _DEC ) ;
         PICT PIC_IZN

      // pdv
      @ PRow(), PCol() + 1 SAY Str( __pdv, _NUM, _DEC ) PICT PIC_IZN

      // osnovica
      @ PRow(), PCol() + 1 SAY Str( __total, _NUM, _DEC ) PICT PIC_IZN

      // dodaj na total

      nT_ukupno += __total
      nT_osnovica += __osn
      nT_pdv += __pdv

   ENDDO

   // ispisi sada total
   ? cLine

   ? "UKUPNO:"

   @ PRow(), nRow SAY Str( nT_osnovica, _NUM, _DEC ) PICT PIC_IZN
   @ PRow(), PCol() + 1 SAY Str( nT_pdv, _NUM, _DEC ) PICT PIC_IZN
   @ PRow(), PCol() + 1 SAY Str( nT_ukupno, _NUM, _DEC ) PICT PIC_IZN

   ? cLine

   RETURN



STATIC FUNCTION fakt_mp_po_vrstama_placanja( nT_osnovica, nT_pdv, nT_ukupno )

   LOCAL nOsnovica
   LOCAL nPDV
   LOCAL nUkupno
   LOCAL nRbr := 0
   LOCAL nRow := 35
   LOCAL cLine := ""
   LOCAL cF_tipdok
   LOCAL cF_firma
   LOCAL cF_brdok
   LOCAL _vrsta_p, _vrsta_p_naz

   nT_osnovica := 0
   nT_pdv := 0
   nT_ukupno := 0

   // vraca liniju
   g_l_mpop( @cLine )

   // zaglavlje pregled po robi
   s_z_mpvrstap( cLine )

   SELECT r_export
   // po operaterima
   SET ORDER TO TAG "5"
   GO TOP

   DO WHILE !Eof()

      _vrsta_p := field->vrstap

      nOsnovica := 0
      nPDV := 0
      nUkupno := 0
      nS_pdv := 0
      nU_fakt := 0
      nUU_fakt := 0

      DO WHILE !Eof() .AND. field->vrstap == _vrsta_p
	
         cF_brdok := field->brdok
         cF_tipdok := field->idtipdok
         cF_firma := field->idfirma

         DO WHILE !Eof() .AND. field->vrstap == _vrsta_p .AND. cF_firma + cF_tipdok + cF_brdok == field->idfirma +  field->idtipdok + field->brdok
		
            nU_fakt := field->uk_fakt
            nS_pdv := field->s_pdv
            nOsnovica += field->kolicina * field->c_bpdv
            nPDV += field->kolicina * field->pdv

            SKIP
         ENDDO

         nUU_fakt += nU_fakt

      ENDDO

      // zaokruzi
      nOsnovica := Round( ( nUU_fakt / ( 1 + ( nS_pdv / 100 ) ) ), ;
         ZAO_VRIJEDNOST() )
      nPDV := Round( ( nUU_fakt / ( 1 + ( nS_pdv / 100 ) ) * ;
         ( nS_pdv / 100 ) ), ZAO_VRIJEDNOST() )
      nUkupno := Round( nUU_fakt, ZAO_VRIJEDNOST() )


      // pa ispisi tu stavku

      // rbr
      ? PadL( AllTrim( Str( ++nRbr ) ), 4 ) + "."

      // operater
      @ PRow(), PCol() + 1 SAY PadR( AllTrim( _vrsta_p ), 40 )
	
      // total
      @ PRow(), nRow := PCol() + 1 SAY Str( nUkupno, _NUM, _DEC ) ;
         PICT PIC_IZN

      // dodaj na total
      nT_ukupno += nUkupno
      nT_osnovica += nOsnovica
      nT_pdv += nPDV

   ENDDO

   ? cLine
   ? "UKUPNO:"
   @ PRow(), nRow SAY Str( nT_Ukupno, _NUM, _DEC ) PICT PIC_IZN
   ? cLine

   RETURN




STATIC FUNCTION fakt_mp_po_operaterima( nT_osnovica, nT_pdv, nT_ukupno )

   LOCAL nOperater
   LOCAL cOper_naz
   LOCAL nOsnovica
   LOCAL nPDV
   LOCAL nUkupno
   LOCAL nRbr := 0
   LOCAL nRow := 35
   LOCAL cLine := ""
   LOCAL cF_tipdok
   LOCAL cF_firma
   LOCAL cF_brdok

   nT_osnovica := 0
   nT_pdv := 0
   nT_ukupno := 0

   // vraca liniju
   g_l_mpop( @cLine )

   // zaglavlje pregled po robi
   s_z_mpop( cLine )

   SELECT r_export
   // po operaterima
   SET ORDER TO TAG "3"
   GO TOP

   DO WHILE !Eof()

      nOperater := field->operater
      cOper_naz := ""

      // ako postoji operater
      IF nOperater <> 0

         nTArea := Select()

         cOper_naz := GetFullUserName( nOperater )
         cOper_naz := "(" + AllTrim( Str( nOperater ) ) + ") " + cOper_naz

         SELECT ( nTArea )
      ENDIF

      nOsnovica := 0
      nPDV := 0
      nUkupno := 0
      nS_pdv := 0
      nU_fakt := 0
      nUU_fakt := 0

      DO WHILE !Eof() .AND. field->operater == nOperater
	
         cF_brdok := field->brdok
         cF_tipdok := field->idtipdok
         cF_firma := field->idfirma

         DO WHILE !Eof() .AND. field->operater == nOperater .AND. cF_firma + cF_tipdok + cF_brdok == field->idfirma + field->idtipdok + field->brdok
		
            nU_fakt := field->uk_fakt
            nS_pdv := field->s_pdv
            nOsnovica += field->kolicina * field->c_bpdv
            nPDV += field->kolicina * field->pdv

            SKIP
         ENDDO

         nUU_fakt += nU_fakt

      ENDDO

      // zaokruzi
      nOsnovica := Round( ( nUU_fakt / ( 1 + ( nS_pdv / 100 ) ) ), ;
         ZAO_VRIJEDNOST() )
      nPDV := Round( ( nUU_fakt / ( 1 + ( nS_pdv / 100 ) ) * ;
         ( nS_pdv / 100 ) ), ZAO_VRIJEDNOST() )
      nUkupno := Round( nUU_fakt, ZAO_VRIJEDNOST() )


      // pa ispisi tu stavku
      ? PadL( AllTrim( Str( ++nRbr ) ), 4 ) + "."

      // operater
      @ PRow(), PCol() + 1 SAY PadR( AllTrim( cOper_naz ), 40 )
	
      // total
      @ PRow(), nRow := PCol() + 1 SAY Str( nUkupno, _NUM, _DEC ) ;
         PICT PIC_IZN

      nT_ukupno += nUkupno
      nT_osnovica += nOsnovica
      nT_pdv += nPDV

   ENDDO

   ? cLine
   ? "UKUPNO:"
   @ PRow(), nRow SAY Str( nT_Ukupno, _NUM, _DEC ) PICT PIC_IZN
   ? cLine

   RETURN



STATIC FUNCTION fakt_mp_po_robama()

   LOCAL cRoba_id
   LOCAL nOsnovica
   LOCAL nPDV
   LOCAL nUkupno
   LOCAL nKolicina
   LOCAL nT_kolicina := 0
   LOCAL nRbr := 0
   LOCAL nRow := 35
   LOCAL cLine := ""
   LOCAL nT_osnovica := 0
   LOCAL nT_pdv := 0
   LOCAL nT_ukupno := 0

   // vraca liniju
   g_l_mproba( @cLine )

   // zaglavlje pregled po robi
   s_z_mproba( cLine )

   SELECT r_export
   SET ORDER TO TAG "2"
   GO TOP

   DO WHILE !Eof()

      cRoba_id := field->roba_id
      cRoba_naz := field->roba_naz

      nOsnovica := 0
      nPDV := 0
      nS_pdv := 0
      nUkupno := 0
      nKolicina := 0

      DO WHILE !Eof() .AND. field->roba_id == cRoba_id
		
         nS_pdv := field->s_pdv
         nOsnovica += field->kolicina * field->c_bpdv
         nPDV += field->kolicina * field->pdv
         nKolicina += field->kolicina

         SKIP
      ENDDO

      // zaokruzi
      nOsnovica := Round( nOsnovica, ZAO_VRIJEDNOST() )
      nPDV := Round( ( nOsnovica * ( nS_pdv / 100 ) ), ZAO_VRIJEDNOST() + _ZAOK )
      nUkupno := Round( nOsnovica + nPDV, ZAO_VRIJEDNOST() )


      // pa ispisi tu stavku
      ? PadL( AllTrim( Str( ++nRbr ) ), 4 ) + "."
      @ PRow(), PCol() + 1 SAY PadR( AllTrim( cRoba_id ) + "-" + AllTrim( cRoba_naz ), 50 )
      @ PRow(), nRow := PCol() + 1 SAY Str( nKolicina, 12, 2 )

      nT_kolicina += nKolicina

   ENDDO

   // ispisi sada total
   ? cLine

   ? "UKUPNO:"
   @ PRow(), nRow SAY Str( nT_kolicina, 12, 2 )

   ? cLine

   RETURN


// -----------------------------------------
// vraca liniju za pregled po robi
// -----------------------------------------
STATIC FUNCTION g_l_mproba( cLine )

   cLine := ""

   cLine += Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 50 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )

   RETURN


// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
STATIC FUNCTION s_z_mproba( cLine )

   cTxt := ""

   cTxt += PadR( "r.br", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "roba (id/naziv)", 50 )
   cTxt += Space( 1 )
   cTxt += PadR( "kolicina", 12 )
   ? "Realizacija po robi:"
   ? cLine
   ? cTxt
   ? cLine

   RETURN

// -----------------------------------------
// vraca liniju za pregled po robi
// -----------------------------------------
STATIC FUNCTION g_l_mptip( cLine )

   cLine := ""

   cLine += Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 40 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )

   RETURN




// -----------------------------------------
// vraca liniju za pregled po robi
// -----------------------------------------
STATIC FUNCTION g_l_mpop( cLine )

   cLine := ""

   cLine += Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 40 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )

   RETURN


// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
STATIC FUNCTION s_z_mptip( cLine )

   cTxt := ""

   cTxt += PadR( "r.br", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "Tip partnera", 40 )
   cTxt += Space( 1 )
   cTxt += PadR( "osnovica", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "pdv", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "ukupno", 12 )

   ? "Realizacija po tipu partnera:"
   ? cLine
   ? cTxt
   ? cLine

   RETURN



// -----------------------------------------
// zaglavlje za pregled po vrsti placanja
// -----------------------------------------
STATIC FUNCTION s_z_mpvrstap( cLine )

   cTxt := ""

   cTxt += PadR( "r.br", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "vrsta plaćanja (id/naziv)", 40 )
   cTxt += Space( 1 )
   cTxt += PadR( "ukupno", 12 )

   ?
   ?U "Realizacija po vrstama plaćanja:"
   ?U cLine
   ?U cTxt
   ?U cLine

   RETURN




// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
STATIC FUNCTION s_z_mpop( cLine )

   cTxt := ""

   cTxt += PadR( "r.br", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "operater (id/naziv)", 40 )
   cTxt += Space( 1 )
   cTxt += PadR( "ukupno", 12 )

   ? "Realizacija po opearterima:"
   ? cLine
   ? cTxt
   ? cLine

   RETURN


// -----------------------------------------
// vraca liniju za pregled po dokumentima
// -----------------------------------------
STATIC FUNCTION g_l_mpdok( cLine )

   cLine := ""

   cLine += Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 16 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 40 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 20 )

   RETURN


// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
STATIC FUNCTION s_z_mpdok( cLine )

   cTxt := ""

   cTxt += PadR( "r.br", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "dokument", 16 )
   cTxt += Space( 1 )
   cTxt += PadR( "partner (id/naziv)", 40 )
   cTxt += Space( 1 )
   cTxt += PadR( "osnovica", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "pdv", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "ukupno", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "operater", 20 )

   ? "Realizacija po dokumentima:"
   ? cLine
   ? cTxt
   ? cLine

   RETURN
