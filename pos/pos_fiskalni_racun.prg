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

/*
-- Table: fmk.pos_pos

-- DROP TABLE fmk.pos_pos;

CREATE TABLE fmk.pos_pos
(
  idpos character varying(2),
  idvd character varying(2),
  brdok character varying(6),
  datum date,
  idcijena character varying(1),
  iddio character varying(2),
  idodj character(2),
  idradnik character varying(4),
  idroba character(10),
  idtarifa character(6),
  m1 character varying(1),
  mu_i character varying(1),
  prebacen character varying(1),
  smjena character varying(1),
  c_1 character varying(6),
  c_2 character varying(10),
  c_3 character varying(50),
  kolicina numeric(18,3),
  kol2 numeric(18,3),
  cijena numeric(10,3),
  ncijena numeric(10,3),
  rbr character varying(5)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fmk.pos_pos
  OWNER TO hernad;

-- Index: fmk.pos_pos_id1

-- DROP INDEX fmk.pos_pos_id1;

CREATE INDEX pos_pos_id1
  ON fmk.pos_pos
  USING btree
  (idpos COLLATE pg_catalog."default", idvd COLLATE pg_catalog."default", datum, brdok COLLATE pg_catalog."default", idroba COLLATE pg_catalog."default", idcijena COLLATE pg_catalog."default");

-- Index: fmk.pos_pos_id2

-- DROP INDEX fmk.pos_pos_id2;

CREATE INDEX pos_pos_id2
  ON fmk.pos_pos
  USING btree
  (idodj COLLATE pg_catalog."default", idroba COLLATE pg_catalog."default", datum);

-- Index: fmk.pos_pos_id3

-- DROP INDEX fmk.pos_pos_id3;

CREATE INDEX pos_pos_id3
  ON fmk.pos_pos
  USING btree
  (prebacen COLLATE pg_catalog."default");

-- Index: fmk.pos_pos_id4

-- DROP INDEX fmk.pos_pos_id4;

CREATE INDEX pos_pos_id4
  ON fmk.pos_pos
  USING btree
  (datum);

-- Index: fmk.pos_pos_id5

-- DROP INDEX fmk.pos_pos_id5;

CREATE INDEX pos_pos_id5
  ON fmk.pos_pos
  USING btree
  (idpos COLLATE pg_catalog."default", idroba COLLATE pg_catalog."default", datum);

-- Index: fmk.pos_pos_id6

-- DROP INDEX fmk.pos_pos_id6;

CREATE INDEX pos_pos_id6
  ON fmk.pos_pos
  USING btree
  (idroba COLLATE pg_catalog."default");
*/

STATIC __device_id := 0
STATIC s_hFiskalniUredjajParams
STATIC __DRV_TREMOL := "TREMOL"
STATIC __DRV_FPRINT := "FPRINT"
STATIC __DRV_FLINK := "FLINK"
STATIC __DRV_HCP := "HCP"
STATIC __DRV_TRING := "TRING"
STATIC s_cFiskalniDrajverNaziv


FUNCTION pos_fiskalni_racun( cIdPos, dDatDok, cBrojRacuna, hFiskalniParams, nUplaceniIznos )

   LOCAL nErrorLevel := 0
   LOCAL _dev_drv
   LOCAL _storno
   LOCAL aItems, _head, _cont

   IF nUplaceniIznos == NIL
      nUplaceniIznos := 0
   ENDIF

   IF hFiskalniParams == NIL
      RETURN nErrorLevel
   ENDIF

   __device_id := hFiskalniParams[ "id" ]
   s_hFiskalniUredjajParams := hFiskalniParams
   _dev_drv := s_hFiskalniUredjajParams[ "drv" ]
   s_cFiskalniDrajverNaziv := _dev_drv

   _storno := pos_dok_is_storno( cIdPos, "42", dDatDok, cBrojRacuna )
   aItems := pos_fiscal_stavke_racuna( cIdPos, "42", dDatDok, cBrojRacuna, _storno, nUplaceniIznos )

   IF aItems == NIL
      RETURN 1
   ENDIF

   DO CASE

   CASE _dev_drv == "TEST"
      nErrorLevel := 0

   CASE _dev_drv == __DRV_FPRINT
      nErrorLevel := pos_to_fprint( cIdPos, "42", dDatDok, cBrojRacuna, aItems, _storno )

   CASE _dev_drv == __DRV_FLINK
      nErrorLevel := pos_to_flink( cIdPos, "42", dDatDok, cBrojRacuna, aItems, _storno )

   CASE _dev_drv == __DRV_TRING
      nErrorLevel := pos_to_tring( cIdPos, "42", dDatDok, cBrojRacuna, aItems, _storno )

   CASE _dev_drv == __DRV_HCP
      nErrorLevel := pos_to_hcp( cIdPos, "42", dDatDok, cBrojRacuna, aItems, _storno, nUplaceniIznos )

   CASE _dev_drv == __DRV_TREMOL
      _cont := NIL
      nErrorLevel := pos_to_tremol( cIdPos, "42", dDatDok, cBrojRacuna, aItems, _storno, _cont )

   ENDCASE

   IF nErrorLevel > 0

      IF _dev_drv == __DRV_TREMOL

         _cont := "2"
         nErrorLevel := pos_to_tremol( cIdPos, "42", dDatDok, cBrojRacuna, aItems, _storno, _cont )

         IF nErrorLevel > 0
            MsgBeep( "Problem sa štampanjem na fiskalni uređaj !" )
         ENDIF
      ELSE
         MsgBeep( "Problem sa štampanjem na fiskalni uređaj !" )
      ENDIF
   ENDIF

   RETURN nErrorLevel



STATIC FUNCTION pos_dok_is_storno( cIdPos, cIdTipDok, dDatDok, cBrojRacuna )

   LOCAL _storno := .F.

   // SELECT pos
   // SET ORDER TO TAG "1"
   // GO TOP
   // SEEK cIdPos + cIdTipDok + DToS( dDatDok ) + cBrojRacuna
   seek_pos( cIdPos, cIdTipDok, dDatDok, cBrojRacuna )

   DO WHILE !Eof() .AND. pos->idpos == cIdPos  .AND. pos->idvd == cIdTipDok ;
         .AND. DToS( pos->Datum ) == DToS( dDatDok ) .AND. pos->brdok == cBrojRacuna

      IF !Empty( AllTrim( field->c_1 ) )
         _storno := .T.
         EXIT
      ENDIF
      SKIP

   ENDDO

   RETURN _storno



STATIC FUNCTION pos_fiscal_stavke_racuna( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, lStorno, nUplaceniIznos )

   LOCAL aItems := {}
   LOCAL _plu
   LOCAL cReklamiraniRacun
   LOCAL _rabat, _cijena
   LOCAL _art_barkod, _art_id, _art_naz, _art_jmj
   LOCAL _rbr := 0
   LOCAL _rn_total := 0
   LOCAL _vr_plac
   LOCAL nLevel

   IF nUplaceniIznos == NIL
      nUplaceniIznos := 0
   ENDIF

   // SELECT pos_doks
   // SET ORDER TO TAG "1"
   // GO TOP
   // SEEK cIdPos + cIdTipDok + DToS( dDatDok ) + cBrojRacuna
   IF seek_pos_doks( cIdPos, cIdTipDok, dDatDok, cBrojRacuna )
      // IF !Found()
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

   // SELECT pos
   // SET ORDER TO TAG "1"
   // GO TOP
   // SEEK cIdPos + cIdTipDok + DToS( dDatDok ) + cBrojRacuna
   IF seek_pos( cIdPos, cIdTipDok, dDatDok, cBrojRacuna )
      // IF !Found()
      RETURN NIL
   ENDIF

   DO WHILE !Eof() .AND. pos->idpos == cIdPos .AND. pos->idvd == cIdTipDok  ;
         .AND. DToS( pos->Datum ) == DToS( dDatDok ) .AND. pos->brdok == cBrojRacuna

      cReklamiraniRacun := ""
      _rabat := 0
      _plu := 0
      _cijena := 0
      _art_barkod := ""

      cReklamiraniRacun := field->c_1

      _art_id := field->idroba

      select_o_roba( _art_id )

      _plu := roba->fisc_plu

      IF s_hFiskalniUredjajParams[ "plu_type" ] == "D"
         _plu := auto_plu( NIL, NIL, s_hFiskalniUredjajParams )
      ENDIF

      IF s_cFiskalniDrajverNaziv == "FPRINT" .AND. _plu == 0
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

      _art_naz := fiscal_art_naz_fix( roba->naz, s_hFiskalniUredjajParams[ "drv" ] )

      AAdd( aItems, { cBrojRacuna, ;
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

   IF Len( aItems ) == 0
      MsgBeep( "Nema stavki za štampu na fiskalni uređaj !" )
      RETURN NIL
   ENDIF

   nLevel := 1

   IF provjeri_kolicine_i_cijene_fiskalnog_racuna( @aItems, lStorno, nLevel, s_hFiskalniUredjajParams[ "drv" ] ) < 0
      RETURN NIL
   ENDIF

   RETURN aItems



STATIC FUNCTION pos_to_fprint( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, aStavkeRacuna, lStorno )

   LOCAL nErrorLevel := 0
   LOCAL _fiscal_no := 0

   fprint_delete_answer( s_hFiskalniUredjajParams )
   fiskalni_fprint_racun( s_hFiskalniUredjajParams, aStavkeRacuna, NIL, lStorno )

   nErrorLevel := fprint_read_error( s_hFiskalniUredjajParams, @_fiscal_no )

   IF nErrorLevel = -9
      IF Pitanje(, "Da li je nestalo trake ?", "N" ) == "D"
         IF Pitanje(, "Zamjenite traku i pritisnite 'D'", "D" ) == "D"
            nErrorLevel := fprint_read_error( s_hFiskalniUredjajParams, @_fiscal_no )
         ENDIF
      ENDIF
   ENDIF

   IF _fiscal_no <= 0
      nErrorLevel := 1
   ENDIF

   IF nErrorLevel <> 0

      IF pos_da_li_je_racun_fiskalizovan( @_fiscal_no )
         nErrorLevel := 0
      ELSE
         fprint_delete_out( s_hFiskalniUredjajParams )
         MsgBeep( "Greška kod štampanja fiskalnog računa !" )
      ENDIF

   ENDIF

   IF ( _fiscal_no > 0 .AND. nErrorLevel == 0 )
      pos_doks_update_fisc_rn( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, _fiscal_no )
      MsgO( "Kreiran fiskalni račun broj: " + AllTrim( Str( _fiscal_no ) ) )
      Sleep( 2 )
      MsgC()
   ENDIF

   RETURN nErrorLevel




STATIC FUNCTION pos_to_flink( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, aStavkeRacuna, lStorno )

   LOCAL nErrorLevel := 0

   // idemo sada na upis rn u fiskalni fajl
   nErrorLevel := fc_pos_rn( s_hFiskalniUredjajParams, aStavkeRacuna, lStorno )

   RETURN nErrorLevel





STATIC FUNCTION pos_to_tremol( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, aStavkeRacuna, lStorno, cContinue )

   LOCAL nErrorLevel := 0
   LOCAL _f_name
   LOCAL _fiscal_no := 0

   IF cContinue == NIL
      cContinue := "0"
   ENDIF

   // idemo sada na upis rn u fiskalni fajl
   nErrorLevel := tremol_rn( s_hFiskalniUredjajParams, aStavkeRacuna, NIL, lStorno, cContinue )

   IF cContinue <> "2"

      // naziv fajla
      _f_name := fiscal_out_filename( s_hFiskalniUredjajParams[ "out_file" ], cBrojRacuna )

      IF tremol_read_out( s_hFiskalniUredjajParams, _f_name )

         // procitaj poruku greske
         nErrorLevel := tremol_read_error( s_hFiskalniUredjajParams, _f_name, @_fiscal_no )

         IF nErrorLevel = 0 .AND. !lStorno .AND. _fiscal_no > 0

            pos_doks_update_fisc_rn( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, _fiscal_no )

            MsgBeep( "Kreiran fiskalni račun: " + AllTrim( Str( _fiscal_no ) ) )

         ENDIF

      ENDIF

      // obrisi fajl
      // da ne bi ostao kada server proradi ako je greska
      FErase( s_hFiskalniUredjajParams[ "out_dir" ] + _f_name )

   ENDIF

   RETURN nErrorLevel




STATIC FUNCTION pos_to_hcp( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, aStavkeRacuna, lStorno, nUplaceniIznos )

   LOCAL nErrorLevel := 0
   LOCAL _fiscal_no := 0

   IF nUplaceniIznos == NIL
      nUplaceniIznos := 0
   ENDIF

   nErrorLevel := hcp_rn( s_hFiskalniUredjajParams, aStavkeRacuna, NIL, lStorno, nUplaceniIznos )

   IF nErrorLevel = 0

      // vrati broj racuna
      _fiscal_no := hcp_fisc_no( s_hFiskalniUredjajParams, lStorno )

      IF _fiscal_no > 0
         pos_doks_update_fisc_rn( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, _fiscal_no )
         MsgBeep( "Kreiran fiskalni racun: " + AllTrim( Str( _fiscal_no ) ) )
      ENDIF

   ENDIF

   RETURN nErrorLevel


// ------------------------------------------------
// update broj fiskalnog racuna
// ------------------------------------------------
STATIC FUNCTION pos_doks_update_fisc_rn( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, nFiskalniBroj )

   LOCAL hRec

   //SELECT pos_doks
   //SET ORDER TO TAG "1"
   //GO TOP

   //SEEK cIdPos + cIdTipDok + DToS( dDatDok ) + cBrojRacuna
   //IF !Found()
   IF !seek_pos_doks( cIdPos, cIdTipDok, dDatDok, cBrojRacuna )
      RETURN .F.
   ENDIF

   hRec := dbf_get_rec()
   hRec[ "fisc_rn" ] := nFiskalniBroj

   update_rec_server_and_dbf( "pos_doks", hRec, 1, "FULL" )

   RETURN .T.



// --------------------------------------------
// vrati vrstu placanja
// --------------------------------------------
STATIC FUNCTION pos_get_vr_plac( cIdVrstePlacanja )

   LOCAL cRet := "0"
   LOCAL nDbfArea := Select()
   LOCAL _naz := ""

   IF Empty( cIdVrstePlacanja ) .OR. cIdVrstePlacanja == "01"
      RETURN cRet
   ENDIF

   //o_vrstep()
   //SELECT vrstep
   //SET ORDER TO TAG "ID"

   select_o_vrstep( cIdVrstePlacanja )

   _naz := Upper( AllTrim( vrstep->naz ) )

   DO CASE
   CASE "KARTICA" $ _naz
      cRet := "1"
   CASE "CEK" $ _naz
      cRet := "2"
   CASE "VIRMAN" $ _naz
      cRet := "3"
   OTHERWISE
      cRet := "0"
   ENDCASE

   SELECT ( nDbfArea )

   RETURN cRet



// --------------------------------------------
// stampa fiskalnog racuna TRING (www.kase.ba)
// --------------------------------------------
STATIC FUNCTION pos_to_tring( cIdPos, cIdTipDok, dDatDok, cBrojRacuna, aStavkeRacuna, lStorno )

   LOCAL nErrorLevel := 0

   nErrorLevel := tring_rn( s_hFiskalniUredjajParams, aStavkeRacuna, NIL, lStorno )

   RETURN nErrorLevel




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
      nFiskalniBroj - broj fiskalnog računa, proslijeđuje se po referenci

   Return:
      .T. => trakica je izašla korektno
      .F. => račun primarno nije fiskalizovan na uređaj
      nFiskalniBroj - varijabla proslijeđena po refernci, sadrži broj fiskalnog računa
                broj koji je korisnik unjeo na formi

*/
FUNCTION pos_da_li_je_racun_fiskalizovan( nFiskalniBroj )

   LOCAL lRet := .F.
   LOCAL nX
   LOCAL cStampano := " "
   LOCAL GetList := {}

   DO WHILE .T.

      nX := 1

      Box(, 5, 70 )

      @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Program ne može da dobije odgovor od fiskalnog uređaja !"
      ++nX
      @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Da li je račun ispravno odštampan na fiskalni uređaj (D/N) ?" GET cStampano VALID cStampano $ "DN" PICT "@!"

      READ

      IF LastKey() == K_ESC
         BoxC()
         MsgBeep( "ESC operacija nije dozvoljena. Odgovortite na postavljena pitanja." )
         LOOP
      ENDIF

      IF cStampano == "N"
         nFiskalniBroj := 0
         BoxC()
         EXIT
      ENDIF

      ++nX
      ++nX
      @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Molimo unesite broj računa koji je fiskalni račun ispisao:" GET nFiskalniBroj VALID nFiskalniBroj > 0 PICT "9999999999"

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
