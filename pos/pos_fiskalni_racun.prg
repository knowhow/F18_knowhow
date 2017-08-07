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


STATIC __device_id := 0
STATIC __device_params
STATIC __DRV_TREMOL := "TREMOL"
STATIC __DRV_FPRINT := "FPRINT"
STATIC __DRV_FLINK := "FLINK"
STATIC __DRV_HCP := "HCP"
STATIC __DRV_TRING := "TRING"
STATIC __DRV_CURRENT


FUNCTION pos_fiskalni_racun( cIdPos, dDatDok, cBrojRacuna, hFiskalniParams, nUplaceniIznos )

   LOCAL _err_level := 0
   LOCAL _dev_drv
   LOCAL _storno
   LOCAL _items, _head, _cont

   IF nUplaceniIznos == NIL
      nUplaceniIznos := 0
   ENDIF

   IF hFiskalniParams == NIL
      RETURN _err_level
   ENDIF

   __device_id := hFiskalniParams[ "id" ]
   __device_params := hFiskalniParams
   _dev_drv := __device_params[ "drv" ]
   __DRV_CURRENT := _dev_drv

   _storno := pos_dok_is_storno( cIdPos, "42", dDatDok, cBrojRacuna )
   _items := pos_fiscal_stavke_racuna( cIdPos, "42", dDatDok, cBrojRacuna, _storno, nUplaceniIznos )

   IF _items == NIL
      RETURN 1
   ENDIF

   DO CASE

   CASE _dev_drv == "TEST"
      _err_level := 0

   CASE _dev_drv == __DRV_FPRINT
      _err_level := pos_to_fprint( cIdPos, "42", dDatDok, cBrojRacuna, _items, _storno )

   CASE _dev_drv == __DRV_FLINK
      _err_level := pos_to_flink( cIdPos, "42", dDatDok, cBrojRacuna, _items, _storno )

   CASE _dev_drv == __DRV_TRING
      _err_level := pos_to_tring( cIdPos, "42", dDatDok, cBrojRacuna, _items, _storno )

   CASE _dev_drv == __DRV_HCP
      _err_level := pos_to_hcp( cIdPos, "42", dDatDok, cBrojRacuna, _items, _storno, nUplaceniIznos )

   CASE _dev_drv == __DRV_TREMOL
      _cont := NIL
      _err_level := pos_to_tremol( cIdPos, "42", dDatDok, cBrojRacuna, _items, _storno, _cont )

   ENDCASE

   IF _err_level > 0

      IF _dev_drv == __DRV_TREMOL

         _cont := "2"
         _err_level := pos_to_tremol( cIdPos, "42", dDatDok, cBrojRacuna, _items, _storno, _cont )

         IF _err_level > 0
            MsgBeep( "Problem sa štampanjem na fiskalni uređaj !" )
         ENDIF
      ELSE
         MsgBeep( "Problem sa štampanjem na fiskalni uređaj !" )
      ENDIF
   ENDIF

   RETURN _err_level



STATIC FUNCTION pos_dok_is_storno( cIdPos, cIdTipDok, dDatDok, cBrojRacuna )

   LOCAL _storno := .F.

   SELECT pos
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cIdPos + cIdTipDok + DToS( dDatDok ) + cBrojRacuna

   DO WHILE !Eof() .AND. field->idpos == cIdPos  .AND. field->idvd == cIdTipDok ;
         .AND. DToS( field->DatDok ) == DToS( dDatDok ) .AND. field->brdok == cBrojRacuna

      IF !Empty( AllTrim( field->c_1 ) )
         _storno := .T.
         EXIT
      ENDIF

      SKIP

   ENDDO

   RETURN _storno



STATIC FUNCTION pos_fiscal_stavke_racuna( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, lStorno, nUplaceniIznos )

   LOCAL _items := {}
   LOCAL _plu
   LOCAL cReklamiraniRacun
   LOCAL _rabat, _cijena
   LOCAL _art_barkod, _art_id, _art_naz, _art_jmj
   LOCAL _rbr := 0
   LOCAL _rn_total := 0
   LOCAL _vr_plac
   LOCAL _level

   IF nUplaceniIznos == NIL
      nUplaceniIznos := 0
   ENDIF

   SELECT pos_doks
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cIdPos + cIdTipDok + DToS( dDatDok ) + cBrojRacuna

   IF !Found()
      RETURN NIL
   ENDIF

   _vr_plac := pos_get_vr_plac( field->idvrstep )

   IF _vr_plac <> "0"
      _rn_total := pos_iznos_racuna( cIdPos, cIdTipDok, dDatDok, cBrojRacuna )
   ELSE
      _rn_total := 0
   ENDIF

   IF nUplaceniIznos > 0
      _rn_total := nUplaceniIznos
   ENDIF

   SELECT pos
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cIdPos + cIdTipDok + DToS( dDatDok ) + cBrojRacuna

   IF !Found()
      RETURN NIL
   ENDIF

   DO WHILE !Eof() .AND. field->idpos == cIdPos .AND. field->idvd == cIdTipDok  ;
      .AND. DToS( field->DatDok ) == DToS( dDatDok ) .AND. field->brdok == cBrojRacuna

      cReklamiraniRacun := ""
      _rabat := 0
      _plu := 0
      _cijena := 0
      _art_barkod := ""

      cReklamiraniRacun := field->c_1

      _art_id := field->idroba

      select_o_roba( _art_id )

      _plu := roba->fisc_plu

      IF __device_params[ "plu_type" ] == "D"
         _plu := auto_plu( nil, nil, __device_params )
      ENDIF

      IF __DRV_CURRENT == "FPRINT" .AND. _plu == 0
         MsgBeep( "PLU artikla = 0, to nije moguće !" )
         RETURN NIL
      ENDIF

      _cijena := pos_get_mpc()
      _art_barkod := roba->barkod
      _art_jmj := roba->jmj

      SELECT pos

      IF field->ncijena > 0
         _rabat := ( field->ncijena / field->cijena ) * 100
      ENDIF

      _art_naz := fiscal_art_naz_fix( roba->naz, __device_params[ "drv" ] )

      AAdd( _items, { cBrojRacuna, ;
         AllTrim( Str( ++_rbr ) ), ;
         _art_id, ;
         _art_naz, ;
         field->cijena, ;
         Abs( field->kolicina ), ;
         field->idtarifa, ;
         cReklamiraniRacun, ;
         _plu, ;
         field->cijena, ;
         _rabat, ;
         _art_barkod, ;
         _vr_plac, ;
         _rn_total, ;
         dDatDok, ;
         _art_jmj } )

      SKIP

   ENDDO

   IF Len( _items ) == 0
      MsgBeep( "Nema stavki za štampu na fiskalni uređaj !" )
      RETURN NIL
   ENDIF

   _level := 1

   IF provjeri_kolicine_i_cijene_fiskalnog_racuna( @_items, lStorno, _level, __device_params[ "drv" ] ) < 0
      RETURN NIL
   ENDIF

   RETURN _items



STATIC FUNCTION pos_to_fprint( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, items, lStorno )

   LOCAL _err_level := 0
   LOCAL _fiscal_no := 0

   fprint_delete_answer( __device_params )

   fiskalni_fprint_racun( __device_params, items, NIL, lStorno )

   _err_level := fprint_read_error( __device_params, @_fiscal_no )

   IF _err_level = -9
      IF Pitanje(, "Da li je nestalo trake ?", "N" ) == "D"
         IF Pitanje(, "Zamjenite traku i pritisnite 'D'", "D" ) == "D"
            _err_level := fprint_read_error( __device_params, @_fiscal_no )
         ENDIF
      ENDIF
   ENDIF

   IF _fiscal_no <= 0
      _err_level := 1
   ENDIF

   IF _err_level <> 0

      IF pos_da_li_je_racun_fiskalizovan( @_fiscal_no )
         _err_level := 0
      ELSE
         fprint_delete_out( __device_params )
         MsgBeep( "Greška kod štampanja fiskalnog računa !" )
      ENDIF

   ENDIF

   IF ( _fiscal_no > 0 .AND. _err_level == 0 )
      pos_doks_update_fisc_rn( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, _fiscal_no )
      MsgO( "Kreiran fiskalni račun broj: " + AllTrim( Str( _fiscal_no ) ) )
      Sleep( 2 )
      MsgC()
   ENDIF

   RETURN _err_level




STATIC FUNCTION pos_to_flink( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, items, lStorno )

   LOCAL _err_level := 0

   // idemo sada na upis rn u fiskalni fajl
   _err_level := fc_pos_rn( __device_params, items, lStorno )

   RETURN _err_level





STATIC FUNCTION pos_to_tremol( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, items, lStorno, cont )

   LOCAL _err_level := 0
   LOCAL _f_name
   LOCAL _fiscal_no := 0

   IF cont == NIL
      cont := "0"
   ENDIF

   // idemo sada na upis rn u fiskalni fajl
   _err_level := tremol_rn( __device_params, items, NIL, lStorno, cont )

   IF cont <> "2"

      // naziv fajla
      _f_name := fiscal_out_filename( __device_params[ "out_file" ], cBrojRacuna )

      IF tremol_read_out( __device_params, _f_name )

         // procitaj poruku greske
         _err_level := tremol_read_error( __device_params, _f_name, @_fiscal_no )

         IF _err_level = 0 .AND. !lStorno .AND. _fiscal_no > 0

            pos_doks_update_fisc_rn( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, _fiscal_no )

            MsgBeep( "Kreiran fiskalni racun: " + AllTrim( Str( _fiscal_no ) ) )

         ENDIF

      ENDIF

      // obrisi fajl
      // da ne bi ostao kada server proradi ako je greska
      FErase( __device_params[ "out_dir" ] + _f_name )

   ENDIF

   RETURN _err_level




STATIC FUNCTION pos_to_hcp( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, items, lStorno, nUplaceniIznos )

   LOCAL _err_level := 0
   LOCAL _fiscal_no := 0

   IF nUplaceniIznos == NIL
      nUplaceniIznos := 0
   ENDIF

   _err_level := hcp_rn( __device_params, items, NIL, lStorno, nUplaceniIznos )

   IF _err_level = 0

      // vrati broj racuna
      _fiscal_no := hcp_fisc_no( __device_params, lStorno )

      IF _fiscal_no > 0
         pos_doks_update_fisc_rn( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, _fiscal_no )
         MsgBeep( "Kreiran fiskalni racun: " + AllTrim( Str( _fiscal_no ) ) )
      ENDIF

   ENDIF

   RETURN _err_level


// ------------------------------------------------
// update broj fiskalnog racuna
// ------------------------------------------------
STATIC FUNCTION pos_doks_update_fisc_rn( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, fisc_no )

   LOCAL hRec

   SELECT pos_doks
   SET ORDER TO TAG "1"
   GO TOP

   SEEK cIdPos + cIdTipDok + DToS( dDatDok ) + cBrojRacuna

   IF !Found()
      RETURN .F.
   ENDIF

   hRec := dbf_get_rec()
   hRec[ "fisc_rn" ] := fisc_no

   update_rec_server_and_dbf( "pos_doks", hRec, 1, "FULL" )

   RETURN .T.



// --------------------------------------------
// vrati vrstu placanja
// --------------------------------------------
STATIC FUNCTION pos_get_vr_plac( id_vr_pl )

   LOCAL _ret := "0"
   LOCAL nDbfArea := Select()
   LOCAL _naz := ""

   IF Empty( id_vr_pl ) .OR. id_vr_pl == "01"
      RETURN _ret
   ENDIF

   o_vrstep()
   SELECT vrstep
   SET ORDER TO TAG "ID"
   SEEK id_vr_pl

   _naz := Upper( AllTrim( vrstep->naz ) )

   DO CASE
   CASE "KARTICA" $ _naz
      _ret := "1"
   CASE "CEK" $ _naz
      _ret := "2"
   CASE "VIRMAN" $ _naz
      _ret := "3"
   OTHERWISE
      _ret := "0"
   ENDCASE

   SELECT ( nDbfArea )

   RETURN _ret



// --------------------------------------------
// stampa fiskalnog racuna TRING (www.kase.ba)
// --------------------------------------------
STATIC FUNCTION pos_to_tring( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, items, lStorno )
   LOCAL _err_level := 0
   _err_level := tring_rn( __device_params, items, NIL, lStorno )
   RETURN _err_level




/* -------------------------------------------
 popravlja naziv artikla
*/

STATIC FUNCTION _fix_naz( cR_naz, cNaziv )

   cNaziv := PadR( cR_naz, 30 )

   DO CASE

   CASE AllTrim( flink_type() ) == "FLINK"
      cNaziv := Lower( cNaziv )
      cNaziv := StrTran( cNaziv, ",", "." )

   ENDCASE

   RETURN .T.


/*
   Opis: u slučaju greške sa fajlom odgovora, kada nema broja fiskalnog računa
         korisnika ispituje da li je račun fiskalizovan te nudi mogućnost ručnog unosa
         broja fiskalnog računa

   Parameters:
      fisc_no - broj fiskalnog računa, proslijeđuje se po referenci

   Return:
      .T. => trakica je izašla korektno
      .F. => račun primarno nije fiskalizovan na uređaj
      fisc_no - varijabla proslijeđena po refernci, sadrži broj fiskalnog računa
                broj koji je korisnik unjeo na formi

*/
FUNCTION pos_da_li_je_racun_fiskalizovan( fisc_no )

   LOCAL lRet := .F.
   LOCAL nX
   LOCAL cStampano := " "

   DO WHILE .T.

      nX := 1

      Box(, 5, 70 )

      @ m_x + nX, m_y + 2 SAY8 "Program ne može da dobije odgovor od fiskalnog uređaja !"
      ++ nX
      @ m_x + nX, m_y + 2 SAY8 "Da li je račun ispravno odštampan na fiskalni uređaj (D/N) ?" GET cStampano VALID cStampano $ "DN" PICT "@!"

      READ

      IF LastKey() == K_ESC
         BoxC()
         MsgBeep( "ESC operacija nije dozvoljena. Odgovortite na postavljena pitanja." )
         LOOP
      ENDIF

      IF cStampano == "N"
         fisc_no := 0
         BoxC()
         EXIT
      ENDIF

      ++ nX
      ++ nX

      @ m_x + nX, m_y + 2 SAY8 "Molimo unesite broj računa koji je fiskalni račun ispisao:" GET fisc_no VALID fisc_no > 0 PICT "9999999999"

      READ

      BoxC()

      IF LastKey() == K_ESC
         MsgBeep( "ESC operacija nije dozvoljena. Odgovortite na postavljena pitanja." )
         LOOP
      ENDIF

      lRet := .T.
      EXIT

   ENDDO

   RETURN lRet
