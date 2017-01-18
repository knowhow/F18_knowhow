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

STATIC PicDEM := "9999999.99"
STATIC PicBHD := "999999999.99"
STATIC PicKol := "999999.999"
STATIC PicUN := "999999999.99"
STATIC __unos_x
STATIC __unos_y

// -----------------------------------------------------
// knjizenje naloga
// -----------------------------------------------------
FUNCTION mat_knjizenje_naloga()

   PUBLIC gPotpis := "N"
   PRIVATE fK1 := fk2 := fk3 := fk4 := "N"

   fK1 := fetch_metric( "mat_rpt_k1", my_user(), fK1 )
   fK2 := fetch_metric( "mat_rpt_k2", my_user(), fK2 )
   fK3 := fetch_metric( "mat_rpt_k3", my_user(), fK3 )
   fK4 := fetch_metric( "mat_rpt_k4", my_user(), fK4 )
   gPotpis := fetch_metric( "mat_rpt_potpis", my_user(), gPotpis )

   // unos naloga
   mat_unos_naloga()

   my_close_all_dbf()

   RETURN



// -----------------------------------------
// unos naloga
// -----------------------------------------
FUNCTION mat_unos_naloga()

   __unos_x := MAXROWS() - 5
   __unos_y := MAXCOLS() - 5

   mat_o_edit()

   ImeKol := { ;
      { "F.",         {|| IdFirma }, "idfirma" }, ;
      { "VN",         {|| IdVN    }, "idvn" }, ;
      { "Br.",        {|| BrNal   }, "brnal" }, ;
      { "R.br",       {|| RBr     } }, ;
      { IF( gSeks == "D", "Predmet", "Konto" ),      {|| IdKonto }, "idkonto" }, ;
      { "Partner",    {|| idpartner }, "idpartner" }, ;
      { "Artikal",    {|| IdRoba }, "idroba" }, ;
      { "U/I",        {|| U_I     }, "U_I" }, ;
      { "Kolicina",      {|| Transform( Kolicina, "999999.99" ) } } ;
      }

   IF gNW == "R"
      AAdd( ImeKol, { "Datum",               {|| DatDok                       }, "datdok" } )
   ELSE
      AAdd( ImeKol, { "Cijena ",             {|| Transform( Cijena, "99999.999" ) }           } )
      AAdd( ImeKol, { "Iznos " + ValDomaca(), {|| Transform( Iznos, "9999999.9" ) }           } )
      AAdd( ImeKol, { "Iznos " + ValPomocna(),  {|| Transform( Iznos2, "9999999.9" ) }           } )
      AAdd( ImeKol, { "Datum",               {|| DatDok                       }, "datdok" } )
   ENDIF

   Kol := {}
   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   Box(, __unos_x, __unos_y )

   @ m_x + __unos_x - 2, m_y + 2 SAY " <c-N>  Nove Stavke       � <ENT> Ispravi stavku   � <c-T> Brisi Stavku "
   @ m_x + __unos_x - 1, m_y + 2 SAY " <c-A>  Ispravka naloga   � <c-P> Stampa naloga    � <a-A> Azuriranje   "
   @ m_x + __unos_x, m_y + 2 SAY " <c-F9> Brisi pripremu    � <F5>  Kontrola zbira   �                    "

   my_db_edit( "PNal", __unos_x, __unos_y, {|| mat_pripr_key_handler() }, "", "Priprema..", , , , , 3 )

   BoxC()

   my_close_all_dbf()

   RETURN


FUNCTION mat_o_edit()

   O_MAT_PSUBAN
   O_MAT_PANAL
   O_MAT_PSINT
   O_MAT_PNALOG
   O_MAT_SUBAN
   O_KARKON
   O_MAT_PRIPR
   O_KONTO
   O_PARTN
   o_tnal()
   o_tdok()
   O_ROBA
   o_sifk()
   O_SIFV
   O_VALUTE
   O_MAT_NALOG
   O_TARIFA

   SELECT mat_pripr
   SET ORDER TO TAG "1"
   GO TOP

   RETURN



STATIC FUNCTION mat_edit_priprema( fNovi )

   PRIVATE nKurs := 0

   IF fnovi .AND. nRbr == 1
      _idfirma := self_organizacija_id()
   ENDIF

   IF gNW $ "DR"
      @  m_x + 1, m_y + 2 SAY "Firma: "
      ?? self_organizacija_id(), "-", self_organizacija_naziv()
   ELSE
      @  m_x + 1, m_y + 2 SAY "Firma:" GET _IdFirma VALID {|| p_partner( @_IdFirma, 1, 20 ), _idfirma := Left( _idfirma, 2 ), .T. }
   ENDIF

   @ m_x + 3, m_y + 2 SAY "NALOG:   Vrsta:"  GET _IdVN    VALID P_VN( @_IdVN, 3, 23 )
   READ
   ESC_RETURN 0

   IF fnovi .AND. ( _idfirma <> idfirma .OR. _idvn <> idvn )
      SELECT mat_nalog
      SEEK _idfirma + _idvn + "X"
      SKIP -1
      IF idvn <> _idvn
         _brnal := "0000"
      ELSE
         _brnal := brnal
      ENDIF
      _brnal := NovaSifra( _brnal )
      SELECT  mat_pripr
   ENDIF


   @  m_x + 3, m_y + 52  SAY "Broj:"   GET _BrNal   VALID mat_dupli_nalog( _BrNal, _IdVN, _IdFirma ) .AND. !Empty( _BrNal )
   @  m_x + 5, m_y + 2  SAY "Redni broj stavke naloga:" GET nRbr PICTURE "9999"

   IF gKupZad == "D"
      @ m_x + 7, m_y + 2    SAY "Dobavljac/Kupac" GET _IdPartner VALID Empty( _IdPartner ) .OR. p_partner( @_IdPartner, 24 )
      @ m_x + 7, m_y + 40   SAY "Zaduzuje " GET _IdZaduz PICT "@!" VALID Empty( _IdZaduz ) .OR. p_partner( @_IdZaduz, 24 )
   ENDIF

   @  m_x + 9, m_y + 2  SAY "DOKUMENT:"

   IF gNW == "N"
      @ m_x + 9, m_y + 12 SAY "Tip :" GET _IdTipDok VALID P_TipDok( @_IdTipDok )
      @ m_x + 9, m_y + 24 SAY "Broj:"   GET _BrDok
   ELSE
      @ m_x + 9, m_y + 13 SAY "Broj:"   GET _BrDok
   ENDIF

   IF fk1 == "D"; @  m_x + 9, Col() + 2 SAY "K1" GET _k1 PICT "@!" ; ENDIF
   IF fk2 == "D"; @  m_x + 9, Col() + 2 SAY "K2" GET _k2 PICT "@!" ; ENDIF
   IF fk3 == "D"; @  m_x + 9, Col() + 2 SAY "K3" GET _k3 PICT "@!" ; ENDIF
   IF fk4 == "D"; @  m_x + 9, Col() + 2 SAY "K4" GET _k4 PICT "@!" ; ENDIF

   @  m_x + 11, m_y + 2  SAY "Datum dok.:"   GET  _DatDok valid {|| _datkurs := _DatDok, .T. }
   IF gNW == "N"
      @  m_x + 11, m_y + 24 SAY "Datum kursa:" GET _DatKurs ;
         VALID {|| nKurs := Kurs( _DatKurs ), QQOut( " " + ValDomaca() + "/" + ValPomocna(), Transform( nKurs, PicUn ) ), .T. }
   ENDIF

   IF gkonto <> "D"
      @  m_x + 13, m_y + 2  SAY IF( gSeks == "D", "Predmet ", "Konto   " ) GET _IdKonto ;
         VALID {|| nKurs := Kurs( _DatKurs ), P_Konto( @_IdKonto ), SetPos( m_x + 13, m_y + 25 ), QQOut( Left( konto->naz, 45 ) ), .T. }
   ENDIF

   @  m_x + 14, m_y + 2  SAY "Artikal " GET _IdRoba PICT "@!" ;
      VALID  V_Roba( fnovi )

   @  m_x + 16, m_y + 2  SAY "Ulaz/print_lista(1/2):" GET _U_I VALID  V_UI()

   @ m_x + 16, m_y + 32 GET _Kolicina PICTURE PicKol VALID V_Kol( fnovi )

   IF gNW != "R"
      @ m_x + 16, m_y + 50 SAY "CIJENA   :" GET _Cijena PICTURE PicUn + "9" ;
         when {|| IF( _cijena <> 0, .T., Cijena() ) } ;
         valid {|| _Iznos := iif( _Cijena <> 0, Round( _Cijena * _Kolicina, 2 ), _Iznos ), .T. }
      @ m_x + 17, m_y + 50 SAY "IZNOS " + ValDomaca() + ":" GET _Iznos PICTURE PicUn ;
         when {|| iif( gkonto == "D", .F., .T. ) }  valid  {|| _Iznos2 := _Iznos / nKurs, .T. }
      @ m_x + 18, m_y + 50 SAY "IZNOS " + ValPomocna() + ":" GET _Iznos2 PICTURE PicUn ;
         when {|| _iznos2 := iif( gkonto == "D", _iznos, _iznos2 ), .T. }

   ENDIF

   READ

   ESC_RETURN 0

   OsvCijSif()

   _Rbr := Str( nRbr, 4 )

   RETURN 1



FUNCTION Cijena()

   LOCAL nArr := Select()
   LOCAL cPom1 := " "
   LOCAL cPom2 := " "

   // da vidimo osobine unesenog konta, ako postoje
   SELECT KARKON
   SEEK _idkonto
   IF Found()
      cPom1 := tip_nc
      cPom2 := tip_pc
   ENDIF
   SELECT ( nArr )

   // ako se radi o ulazu
   IF _u_i == "1"
      // ako nije po kontu definisan tip cijene, gledamo u parametre
      IF cPom1 == " "
         IF gCijena == "1"
            _Cijena := roba->nc
         ELSEIF gCijena == "2"
            _Cijena := roba->vpc
         ELSEIF gCijena == "3"
            _cijena := roba->mpc
         ELSEIF gCijena == "P"
            _cijena := SredCij()
         ENDIF
      ELSE // u suprotnom gledamo u karakteristiku konta "tip_nc" <=> cPom1
         IF cPom1 == "1"
            _Cijena := roba->nc
         ELSEIF cPom1 == "2"
            _Cijena := roba->vpc
         ELSEIF cPom1 == "3"
            _cijena := roba->mpc
         ELSEIF cPom1 == "P"
            _cijena := SredCij()
         ENDIF
      ENDIF
   ELSE   // tj. ako se radi o izlazu
      // ako nije po kontu definisan tip cijene, gledamo u parametre
      IF cPom2 == " "
         IF gCijena == "1"
            _Cijena := roba->nc
         ELSEIF gCijena == "2"
            _Cijena := roba->vpc
         ELSEIF gCijena == "3"
            _cijena := roba->mpc
         ELSEIF gCijena == "P"
            _cijena := SredCij()
         ENDIF
      ELSE // u suprotnom gledamo u karakteristiku konta "tip_pc" <=> cPom2
         IF cPom2 == "1"
            _Cijena := roba->nc
         ELSEIF cPom2 == "2"
            _Cijena := roba->vpc
         ELSEIF cPom2 == "3"
            _cijena := roba->mpc
         ELSEIF cPom2 == "P"
            _cijena := SredCij()
         ENDIF
      ENDIF
   ENDIF

   RETURN .T.


FUNCTION SredCij()

   LOCAL nArr := Select(), nFin := 0, nMat := 0

   SELECT mat_suban
   SET ORDER TO TAG "3"
   SEEK _idfirma + _idkonto + _idroba
   DO WHILE !Eof() .AND. ( _idfirma + _idkonto + _idroba == idfirma + idkonto + idroba ) .AND. DToS( datdok ) <= DToS( _datdok )
      IF u_i == "1"  // ulaz
         nFin += iznos
         nMat += kolicina
      ELSE  // izlaz
         nFin -= iznos
         nMat -= kolicina
      ENDIF
      SKIP 1
   ENDDO

   Select( nArr )

   RETURN ( nFin / nMat )



STATIC FUNCTION V_Roba( fnovi )

   P_Roba( @_IdRoba, 14, 25 )

   IF fnovi .AND. _idvn $ gNalPr
      // predlozi izlaz iz prod
      _u_i := "2"
   ENDIF

   IF gKonto == "D"
      _Idkonto := roba->idkonto
      nKurs := Kurs( _DatKurs )
      @  m_x + 13, m_y + 2  SAY "Konto:   "
      ?? _IdKonto
   ENDIF

   @  m_x + 15, m_y + 25  SAY "Jed.mjere:"
   @  m_x + 15, m_y + 36  SAY ROBA->jmj COLOR f18_color_invert()

   RETURN .T.


FUNCTION V_UI()

   IF !( _U_I $ "12" )
      RETURN .F.
   ENDIF

   _D_P := _U_I

   IF _U_I == "1"
      @ m_x + 16, m_y + 25 SAY "ULAZ   "
   ELSE
      @ m_x + 16, m_y + 25 SAY "IZLAZ  "
   ENDIF

   RETURN .T.



FUNCTION V_Kol( fnovi )

   IF fNovi
      _Cijena := 0
   ENDIF
   IF fnovi .AND. _idvn $ gNalPr .AND. _u_i == "2"
      _cijena := roba->mpc
   ENDIF

   RETURN .T.


FUNCTION mat_pripr_key_handler()

   LOCAL nTr2

   IF ( Ch == K_CTRL_T .OR. Ch == K_ENTER )  .AND. Empty( BrNal )
      RETURN DE_CONT
   ENDIF

   SELECT mat_pripr

   DO CASE

   CASE Ch == K_CTRL_T
      RETURN browse_brisi_stavku()

   CASE Ch == K_F5

      // kontrola zbira za jedan mat_nalog
      PushWA()

      Box( "kzb", 8, 60, .F., "Kontrola zbira naloga" )

      SET CURSOR ON

      cFirma := IdFirma
      cIdVN := IdVN
      cBrNal := BrNal

      @ m_x + 1, m_y + 1 SAY "       Firma:" GET cFirma
      // VALID p_partner(@cFirma,1,20) .and. len(trim(cFirma))<=2
      @ m_x + 2, m_y + 1 SAY "Vrsta mat_naloga:" GET cIdVn VALID P_VN( @cIdVN, 2, 20 )
      @ m_x + 3, m_y + 1 SAY " Broj mat_naloga:" GET cBrNal

      READ

      IF LastKey() == K_ESC
         BoxC()
         PopWA()
         RETURN DE_CONT
      ENDIF

      cFirma := Left( cFirma, 2 )

      SET ORDER TO TAG "2"
      SEEK cFirma + cIdVn + cBrNal

      dug := 0
      pot := 0

      IF !( IdFirma + IdVn + BrNal == cFirma + cIdVn + cBrNal )
         Msg( "Ovaj nalog nije unesen ...", 10 )
         BoxC()
         PopWa()
         RETURN DE_CONT
      ENDIF

      zbir_mat_naloga( @dug, @pot, cFirma, cIdVn, cBrNal )

      @ m_x + 5, m_y + 2 SAY "Zbir naloga:"
      @ m_x + 6, m_y + 2 SAY "     Duguje:"
      @ m_x + 6, Col() + 2 SAY Dug PICTURE gPicDEM()
      @ m_x + 7, m_y + 2 SAY "  Potrazuje:"
      @ m_x + 7, Col() + 2 SAY Pot  PICTURE gPicDEM()
      @ m_x + 8, m_y + 2 SAY "      Saldo:"
      @ m_x + 8, Col() + 2 SAY Dug - Pot  PICTURE gPicDEM()

      Inkey( 0 )
      BoxC()
      PopWA()

      RETURN DE_CONT

   CASE Ch == K_ENTER

      Box( "ist", __unos_x - 5, __unos_y - 5, .F. )

      Scatter()
      nRbr := Val( _Rbr )
      IF mat_edit_priprema( .F. ) == 0
         BoxC()
         RETURN DE_CONT
      ELSE
         my_rlock()
         Gather()
         my_unlock()
         mat_brisi_pbaze()
         BoxC()
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == K_CTRL_A

      PushWA()
      SELECT mat_pripr
      GO TOP

      Box( "anal", __unos_x - 5, __unos_y - 5, .F., "Ispravka naloga" )

      nDug := 0
      nPot := 0

      DO WHILE !Eof()

         SKIP
         nTR2 := RecNo()
         SKIP - 1

         Scatter()

         nRbr := Val( _Rbr )

         @ m_x + 1, m_y + 1 CLEAR TO m_x + ( __unos_x - 7 ), m_y + ( __unos_y - 4 )

         IF mat_edit_priprema( .F. ) == 0
            EXIT
         ELSE
            mat_brisi_pbaze()
         ENDIF

         IF d_p = '1'
            nDug += _Iznos
         ELSE
            nPot += _Iznos
         ENDIF

         @ m_x + __unos_x - 5, m_y + 1 SAY "ZBIR NALOGA:"
         @ m_x + __unos_x - 5, m_y + 14 SAY nDug PICTURE PicDEM
         @ m_x + __unos_x - 5, m_y + 35 SAY nPot PICTURE PicDEM
         @ m_x + __unos_x - 5, m_y + 56 SAY nDug - nPot PICTURE PicDEM

         SELECT mat_pripr
         my_rlock()
         Gather()
         my_unlock()
         GO nTR2

      ENDDO

      PopWA()
      BoxC()

      RETURN DE_REFRESH

   CASE Ch == K_CTRL_N  // nove stavke

      nDug := 0
      nPot := 0
      nPrvi := 0

      zbir_mat_naloga( @nDug, @nPot )

      GO BOTTOM

      Box( "knjn", __unos_x - 5, __unos_y - 5, .F., "Knjizenje naloga - nove stavke" )

      DO WHILE .T.

         Scatter()

         nRbr := Val( _Rbr ) + 1

         @ m_x + 1, m_y + 1 CLEAR TO m_x + ( __unos_x - 7 ), m_y + ( __unos_y - 4 )

         IF mat_edit_priprema( .T. ) == 0
            EXIT
         ELSE
            mat_brisi_pbaze()
         ENDIF

         IF field->d_p = '1'
            nDug += _Iznos
         ELSE
            nPot += _Iznos
         ENDIF

         @ m_x + __unos_x - 5, m_y + 1 SAY "ZBIR NALOGA:"
         @ m_x + __unos_x - 5, m_y + 14 SAY nDug PICTURE PicDEM
         @ m_x + __unos_x - 5, m_y + 35 SAY nPot PICTURE PicDEM
         @ m_x + __unos_x - 5, m_y + 56 SAY nDug - nPot PICTURE PicDEM

         SELECT mat_pripr
         APPEND BLANK

         my_rlock()
         Gather()
         my_unlock()

      ENDDO

      BoxC()
      RETURN DE_REFRESH

   CASE Ch == k_ctrl_f9()

      IF Pitanje(, D_ZELITE_LI_IZBRISATI_PRIPREMU, "N" ) == "D"
         my_dbf_zap()
         mat_brisi_pbaze()
      ENDIF

      RETURN DE_REFRESH

   CASE Ch == K_CTRL_P

      my_close_all_dbf()
      mat_st_nalog()
      mat_o_edit()
      RETURN DE_REFRESH

   CASE Ch == K_ALT_A
      my_close_all_dbf()
      azur_mat()
      mat_o_edit()
      RETURN DE_REFRESH

   ENDCASE



   // kalkulise zbir mat naloga dug/pot

FUNCTION zbir_mat_naloga( duguje, potrazuje, firma, vn, broj )

   DO WHILE !Eof() .AND. if( firma <> NIL, field->idfirma + field->idvn + field->brnal == firma + vn + broj, .T. )
      IF field->d_p = "1"
         duguje += field->iznos
         potrazuje += 0
      ELSE
         duguje += 0
         potrazuje += field->iznos
      ENDIF
      SKIP
   ENDDO

   RETURN




FUNCTION mat_dupli_nalog( cBrNal, cVN, cIdFirma )

   PushWA()
   SELECT mat_nalog
   SEEK cIdFirma + cVN + cBrNal
   IF Found()
      MsgO( " Dupli nalog ! " )
      Beep( 3 )
      MsgC()
      PopWa()
      RETURN .F.
   ENDIF
   PopWa()

   RETURN .T.


FUNCTION mat_st_nalog()

   LOCAL Izb

   PRIVATE PicDEM := "@Z 9999999.99"
   PRIVATE PicBHD := "@Z 999999999.99"
   PRIVATE PicKol := "@Z 999999.999"

   mat_st_anal_nalog()

   MsgO( "Formiranje analitickih i sintetickih stavki..." )

   mat_sint_stav()

   MsgC()

   IF ( gKonto == "D" .AND. Pitanje(, "Stampa analitike", "D" ) == "D" )  .OR. ;
         ( gKonto == "N" .AND. Pitanje(, "Stampa analitike", "N" ) == "D" )

      mat_st_sint_nalog( .T. )

   ENDIF

   RETURN



FUNCTION mat_st_anal_nalog( fnovi )

   LOCAL i

   IF PCount() == 0
      fnovi := .T.
   ENDIF

   o_tnal()
   O_ROBA

   IF fnovi

      O_MAT_PRIPR
      O_MAT_PSUBAN
      SELECT mat_psuban
      my_dbf_zap()
      SELECT mat_pripr
      SET ORDER TO TAG "2"
      GO TOP
      IF Empty( BrNal )
         Msg( "PRIPR je prazna!", 15 )
         RETURN
      ENDIF
   ELSE
      O_MAT_SUBAN2
   ENDIF

   IF gkonto == "N"  .AND. g2Valute == "D"
      M := "---- ------- ---------- ------------------ --- -------- ------- ---------- ----------" + IF( gNW == "R", "", " ---------- ---------- ------------ ------------" )
   ELSE
      M := "---- ------- ------ ---------- ---------------------------------------- -- --------" + IF( gNW == "R", "", " ----------" ) + " ---------- ----------" + IF( gNW == "R", "", " ------------ ------------" )
   ENDIF

   DO WHILE !Eof()

      cIdFirma := IdFirma
      cIdVN := IdVN
      cBrNal := BrNal

      Box( "", 1, 50 )
      // set cursor on
      // set confirm off
      @ m_x + 1, m_y + 2 SAY "Nalog broj:" GET cIdFirma
      @ m_x + 1, Col() + 1 SAY "-" GET cIdVn
      @ m_x + 1, Col() + 1 SAY "-" GET cBrNal
      READ
      ESC_BCR
      // set confirm on

      BoxC()

      HSEEK cIdFirma + cIdVN + cBrNal
      IF Eof()
         my_close_all_dbf()
         RETURN
      ENDIF

      START PRINT CRET
      ?
      nStr := 0
      nUkDug := nUkPot := 0
      nUkDug2 := nUkPot2 := 0
      b2 := {|| cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal }
      Zagl11()
      DO WHILE !Eof() .AND. Eval( b2 )   // mat_nalog
         nDug := nPot := 0
         nDug2 := nPot2 := 0
         cBrDok := BrDok
         DO WHILE !Eof() .AND. Eval( b2 ) .AND. BrDok == cBrDok  // brdok
            IF PRow() > 58; FF; Zagl11(); ENDIF
            @ PRow() + 1, 0 SAY Rbr
            @ PRow(), PCol() + 1 SAY IdKonto
            IF gkonto == "D" .OR. g2Valute == "N"
               @ PRow(), PCol() + 1 SAY IdPartner
            ENDIF
            nCP := PCol() + 1
            @ PRow(), PCol() + 1 SAY IdRoba
            nCR := PCol() + 1
            SELECT ROBA; HSEEK mat_pripr->idroba
            IF gkonto == "D" .OR. g2Valute == "N"
               aRez := SjeciStr( naz, 40 )
            ELSE
               aRez := SjeciStr( naz, 18 )
            ENDIF
            SELECT mat_pripr
            @ PRow(), PCol() + 1 SAY aRez[ 1 ]
            nCK14 := PCol() + 1
            @ PRow(), nCk14    SAY IdTipDok
            IF gkonto == "N" .AND. g2Valute == "D"
               @ PRow(), PCol() + 1 SAY BrDok
            ENDIF
            @ PRow(), PCol() + 1 SAY DatDok
            IF ( gkonto == "D" .OR. g2Valute == "N" ) .AND. gNW != "R"
               IF Round( kolicina, 4 ) <> 0
                  @ PRow(), PCol() + 1 SAY iznos / kolicina PICTURE Right( gpicdem + "9", Len( gPicDem ) )
               ELSE
                  @ PRow(), PCol() + 1  SAY 0 PICTURE Right( gpicdem + "9", Len( gPicDem ) )
               ENDIF
            ENDIF
            nCK := PCol() + 1
            IF U_I == "1"
               @ PRow(), PCol() + 1 SAY Kolicina PICTURE "@Z " + gPicKol
               @ PRow(), PCol() + 1 SAY 0        PICTURE "@Z " + gPicKol
            ELSE
               @ PRow(), PCol() + 1 SAY 0        PICTURE "@Z " + gPicKol
               @ PRow(), PCol() + 1 SAY Kolicina PICTURE "@Z " + gPicKol
            ENDIF

            nCI := PCol() + 1
            IF gNW != "R"
               IF D_P = "1"
                  @ PRow(), PCol() + 1 SAY Iznos PICTURE "@Z " + gPicDEM()
                  @ PRow(), PCol() + 1 SAY 0 PICTURE "@Z " + gPicDEM()
                  nDug += Iznos
               ELSE
                  @ PRow(), PCol() + 1 SAY 0 PICTURE "@Z " + gPicDEM()
                  @ PRow(), PCol() + 1 SAY Iznos PICTURE "@Z " + gPicDEM()
                  nPot += Iznos
               ENDIF
            ENDIF

            IF gkonto == "N" .AND. g2Valute == "D" .AND. gNW != "R"
               IF D_P = "1"
                  @ PRow(), PCol() + 1 SAY Iznos2  PICTURE "@Z " + gPicDIN
                  @ PRow(), PCol() + 1 SAY 0  PICTURE "@Z " + gPicDIN
                  nDug2 += Iznos2
               ELSE
                  @ PRow(), PCol() + 1 SAY 0     PICTURE "@Z " + gPicDIN
                  @ PRow(), PCol() + 1 SAY Iznos2 PICTURE "@Z " + gPicDIN
                  nPot2 += Iznos2
               ENDIF
            ENDIF

            IF gkonto == "N" .AND.  g2Valute == "D"
               FOR i := 2 TO Len( aRez )
                  @ PRow() + 1, nCR SAY aRez[ i ]
               NEXT
               @ PRow() + 1, nCP SAY IdPartner
               @ PRow(), nCR SAY IdZaduz
               @ PRow(), nCK14 SAY k1 + "-" + k2 + "-" + k3 + "-" + k4
               IF Kolicina <> 0 .AND. gNW != "R"
                  @ PRow(), nCK SAY "Cijena:"
                  @ PRow(), PCol() + 1 SAY  Iznos / Kolicina PICTURE "*****.***"
                  @ PRow(), PCol() + 1 SAY ValDomaca()
               ENDIF
            ENDIF

            IF fnovi
               SELECT mat_pripr; Scatter()

               SELECT mat_psuban
               APPEND BLANK
               Gather()  // stavi sve vrijednosti iz mat_pripr u mat_psuban
               SELECT mat_pripr
            ENDIF // fnovi

            SKIP
         ENDDO // brdok

         IF PRow() > 59; FF; Zagl11();  ENDIF
         ? M
         IF gNW != "R"
            ? "UKUPNO ZA DOKUMENT:"
            @ PRow(), PCol() + 1 SAY cBrDok
            @ PRow(), nCI - 1 SAY ""
            @ PRow(), PCol() + 1 SAY nDug PICTURE "@Z " + gPicDEM()
            @ PRow(), PCol() + 1 SAY nPot PICTURE "@Z " + gPicDEM()

            IF gkonto == "N" .AND. g2Valute == "D"
               @ PRow(), PCol() + 1 SAY nDug2 PICTURE "@Z " + gPicDIN
               @ PRow(), PCol() + 1 SAY nPot2 PICTURE "@Z " + gPicDIN
            ENDIF
            ? M
         ENDIF

         nUkDug += nDug; nUkPot += nPot
         nUkDug2 += nDug2; nUkPot2 += nPot2
         // ?
      ENDDO // mat_nalog

      IF PRow() > 59; FF; Zagl11();  ENDIF
      IF gNW != "R"
         ? M
         ? "ZBIR NALOGA:"
         @ PRow(), nCI - 1 SAY ""
         @ PRow(), PCol() + 1 SAY nUkDug PICTURE "@Z " + gPicDEM()
         @ PRow(), PCol() + 1 SAY nUkPot PICTURE "@Z " + gPicDEM()
         IF gkonto == "N" .AND. g2Valute == "D"
            @ PRow(), PCol() + 1 SAY nUkDug2 PICTURE "@Z " + gPicDIN
            @ PRow(), PCol() + 1 SAY nUkPot2 PICTURE "@Z " + gPicDIN
         ENDIF
         ? M
      ENDIF
      cIdFirma := IdFirma
      cIdVN := IdVN
      cBrNal := BrNal


      IF gPotpis == "D"
         IF PRow() > 58; FF; Zagl11();  ENDIF
         ?
         ?; P_12CPI
         @ PRow() + 1, 55 SAY "Obrada AOP "; ?? Replicate( "_", 20 )
         @ PRow() + 1, 55 SAY "Kontirao   "; ?? Replicate( "_", 20 )
      ENDIF

      FF
      ENDPRINT

   ENDDO  // eof()

   my_close_all_dbf()

   RETURN



STATIC FUNCTION Zagl11()

   LOCAL nArr

   P_10CPI
   ?? self_organizacija_naziv()
   IF gkonto == "N"
      P_COND
   ELSE
      P_COND2
   ENDIF
   ?
   ? "MAT.P: NALOG ZA KNJIZENJE BROJ :"
   @ PRow(), PCol() + 2 SAY cIdFirma + " - " + cIdVn + " - " + cBrNal
   nArr := Select()
   SELECT TNAL; HSEEK cIdVN; @ PRow(), PCol() + 4 SAY naz
   Select( nArr )
   @ PRow(), 120 SAY "Str " + Str( ++nStr, 3 )
   ? M
   IF gkonto == "N" .AND. g2Valute == "D"
      ? "*R. *" + KonSeks( "KONTO  " ) + "*  ROBA    *  NAZIV ROBE      *  D O K U M E N T   *      KOLICINA       *" + IF( gNW == "R", "", "  I Z N O S   " + ValDomaca() + "   *   I Z N O S   " + ValPomocna() + "     *" )
      ? "             ----------  ---------------  --------------------- --------------------- " + IF( gNW == "R", "", "--------------------- -------------------------" )
      ? "*BR.*       * PARTNER  *  ZADUZUJE        *TIP* BROJ  * DATUM  *  ULAZ    *  IZLAZ   *" + IF( gNW == "R", "", "   DUG    *   POT    *    DUG     *    POT    *" )
   ELSE
      ? "*R. *" + KonSeks( "KONTO  " ) + "*Partn.*  SIFRA   *            NAZIV                       * DOKUMENT   *" + IF( gNW == "R", "", "  Cijena *" ) + "      KOLICINA       *" + IF( gNW == "R", "", "   I Z N O S   " + ValDomaca() + "     *" )
      ? "            *      *                                                   --------------" + IF( gNW == "R", "", "         *" ) + "--------------------- " + IF( gNW == "R", "", "-------------------------" )
      ? "*BR.*       *      *          *                                        *TIP* DATUM  *" + IF( gNW == "R", "", "         *" ) + "  ULAZ    *  IZLAZ   *" + IF( gNW == "R", "", "    DUG     *    POT    *" )
   ENDIF
   ? M

   RETURN



FUNCTION mat_sint_stav()

   O_MAT_PSUBAN
   O_MAT_PANAL
   O_MAT_PSINT
   O_MAT_PNALOG

   SELECT mat_panal
   my_dbf_zap()

   SELECT mat_psint
   my_dbf_zap()

   SELECT mat_pnalog
   my_dbf_zap()

   SELECT mat_psuban
   SET ORDER TO TAG "2"
   GO TOP

   IF Empty( BrNal )
      my_close_all_dbf()
      RETURN
   ENDIF

   DO WHILE !Eof()   // svi nalozi

      cIdFirma := IdFirma;cIDVn = IdVN;cBrNal := BrNal

      nDug11 := nPot11 := nDug22 := nPot22 := 0

      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal    // jedan mat_nalog

         cIdKonto := IdKonto
         nDug1 := 0;nPot1 := 0
         nDug2 := 0;nPot2 := 0

         IF D_P == "1" ; nDug1 := Iznos; ELSE; nPot1 := Iznos; ENDIF
         IF D_P == "1"; nDug2 := Iznos2; ELSE; nPot2 := Iznos2; ENDIF

         SELECT mat_panal     // mat_analitika
         SEEK cidfirma + cidvn + cbrnal + cidkonto
         fNasao := .F.
         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal ;
               .AND. IdKonto == cIdKonto
            IF Month( mat_psuban->datdok ) == Month( datnal )
               fNasao := .T.
               EXIT
            ENDIF
            SKIP
         ENDDO
         IF !fNasao
            APPEND BLANK
         ENDIF

         REPLACE IdFirma WITH cIdFirma, IdKonto WITH cIdKonto, IdVN WITH cIdVN, ;
            BrNal WITH cBrNal, ;
            DatNal WITH Max( mat_psuban->datdok, datnal ), ;
            Dug    WITH Dug + nDug1, Pot WITH Pot + nPot1, ;
            Dug2 WITH   Dug2 + nDug2, Pot2 WITH Pot2 + nPot2
         SELECT mat_psint
         SEEK cidfirma + cidvn + cbrnal + Left( cidkonto, 3 )
         fNasao := .F.
         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal ;
               .AND. Left( cidkonto, 3 ) == idkonto
            IF  Month( mat_psuban->datdok ) == Month( datnal )
               fNasao := .T.
               EXIT
            ENDIF
            SKIP
         ENDDO  // konto
         IF !fNasao
            APPEND BLANK
         ENDIF

         REPLACE IdFirma WITH cIdFirma, IdKonto WITH Left( cIdKonto, 3 ), IdVN WITH cIdVN, ;
            BrNal WITH cBrNal, ;
            DatNal WITH Max( DatNal, mat_psuban->datdok ), ;
            Dug  WITH   Dug + nDug1,  Pot   WITH Pot + nPot1, ;
            Dug2 WITH   Dug2 + nDug2, Pot2  WITH Pot2 + nPot2


         SELECT mat_psuban
         nDug11 += nDug1; nPot11 += nPot1
         nDug22 += nDug2; nPot22 += nPot2
         SKIP

      ENDDO  // mat_nalog

      SELECT mat_pnalog    // datoteka mat_naloga
      APPEND BLANK
      REPLACE IdFirma WITH cIdFirma, IdVN WITH cIdVN, BrNal WITH cBrNal, ;
         DatNal WITH Date(), ;
         Dug WITH nDug11, Pot WITH nPot11, ;
         Dug2 WITH nDug22, Pot2 WITH nPot22
      SELECT mat_psuban


   ENDDO // eof


   SELECT mat_panal
   GO TOP
   DO WHILE !Eof()
      nRbr := 0
      cIdFirma := IdFirma;cIDVn = IdVN;cBrNal := BrNal
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal     // jedan mat_nalog
         REPLACE rbr WITH Str( ++nRbr, 4 )
         SKIP
      ENDDO
   ENDDO

   SELECT mat_psint
   GO TOP
   DO WHILE !Eof()
      nRbr := 0
      cIdFirma := IdFirma;cIDVn = IdVN;cBrNal := BrNal
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal     // jedan mat_nalog
         REPLACE rbr WITH Str( ++nRbr, 4 )
         SKIP
      ENDDO
   ENDDO

   my_close_all_dbf()

   RETURN


FUNCTION mat_brisi_pbaze()

   PushWA()

   SELECT ( F_MAT_PSUBAN )
   my_dbf_zap()

   SELECT ( F_MAT_PANAL )
   my_dbf_zap()

   SELECT ( F_MAT_PSINT )
   my_dbf_zap()

   SELECT ( F_MAT_PNALOG )
   my_dbf_zap()

   PopWA()

   RETURN NIL




STATIC FUNCTION OsvCijSif()

   LOCAL nArr := Select()
   LOCAL cPom1 := " "
   LOCAL cPom2 := " "
   LOCAL _vars

   SELECT ROBA
   SEEK _idroba
   IF !Found()
      SELECT ( nArr )
      MsgBeep( "Nema sifre artikla!" )
      RETURN
   ENDIF

   // da vidimo osobine unesenog konta, ako postoje
   SELECT KARKON
   SEEK _idkonto
   IF Found()
      cPom1 := tip_nc
      cPom2 := tip_pc
   ENDIF

   SELECT ROBA
   _vars := dbf_get_rec()

   // ako se radi o ulazu
   IF _u_i == "1"
      // ako nije po kontu definisan tip cijene, gledamo u parametre
      IF cPom1 == " "
         IF gCijena == "1"
            IF field->nc <> _cijena .AND. Pitanje( "", "Zelite li ovu nabavnu cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "nc" ] := _Cijena
            ENDIF
         ELSEIF gCijena == "2"
            IF field->vpc <> _cijena .AND. Pitanje( "", "Zelite li ovu (VP) cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "vpc" ] := _Cijena
            ENDIF
         ELSEIF gCijena == "3"
            IF field->mpc <> _cijena .AND. Pitanje( "", "Zelite li ovu (MP) cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "mpc" ] := _Cijena
            ENDIF
         ELSEIF gCijena == "P"
         ENDIF
      ELSE // u suprotnom gledamo u karakteristiku konta "tip_nc" <=> cPom1
         IF cPom1 == "1"
            IF field->nc <> _cijena .AND. Pitanje( "", "Zelite li ovu nabavnu cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "nc" ] := _Cijena
            ENDIF
         ELSEIF cPom1 == "2"
            IF field->vpc <> _cijena .AND. Pitanje( "", "Zelite li ovu (VP) cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "vpc" ] := _Cijena
            ENDIF
         ELSEIF cPom1 == "3"
            IF field->mpc <> _cijena .AND. Pitanje( "", "Zelite li ovu (MP) cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "mpc" ] := _Cijena
            ENDIF
         ELSEIF cPom1 == "P"
         ENDIF
      ENDIF
   ELSE   // tj. ako se radi o izlazu
      // ako nije po kontu definisan tip cijene, gledamo u parametre
      IF cPom2 == " "
         IF gCijena == "1"
            IF field->nc <> _cijena .AND. Pitanje( "", "Zelite li ovu nabavnu cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "nc" ] := _Cijena
            ENDIF
         ELSEIF gCijena == "2"
            IF field->vpc <> _cijena .AND. Pitanje( "", "Zelite li ovu (VP) cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "vpc" ] := _Cijena
            ENDIF
         ELSEIF gCijena == "3"
            IF field->mpc <> _cijena .AND. Pitanje( "", "Zelite li ovu (MP) cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "mpc" ] := _Cijena
            ENDIF
         ELSEIF gCijena == "P"
         ENDIF
      ELSE // u suprotnom gledamo u karakteristiku konta "tip_pc" <=> cPom2
         IF cPom2 == "1"
            IF field->nc <> _cijena .AND. Pitanje( "", "Zelite li ovu nabavnu cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "nc" ] := _Cijena
            ENDIF
         ELSEIF cPom2 == "2"
            IF field->vpc <> _cijena .AND. Pitanje( "", "Zelite li ovu (VP) cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "vpc" ] := _Cijena
            ENDIF
         ELSEIF cPom2 == "3"
            IF field->mpc <> _cijena .AND. Pitanje( "", "Zelite li ovu (MP) cijenu postaviti kao tekucu ? (D/N)", "D" ) == "D"
               _vars[ "mpc" ] := _Cijena
            ENDIF
         ELSEIF cPom2 == "P"
         ENDIF
      ENDIF
   ENDIF

   update_rec_server_and_dbf( "roba", _vars, 1, "FULL" )

   SELECT ( nArr )

   RETURN
