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


FUNCTION pos_unos_ispravka_racuna()

   LOCAL lRet
   LOCAL lNoviRacun := .T.

   SetKXLat( "'", "-" )

   o_pos_tables()

   SELECT _pos_pripr

   IF reccount2() <> 0 .AND. ALLTRIM( field->brdok ) == "PRIPRE"
      lNoviRacun := .F.
   ENDIF

   unos_stavki_racuna( lNoviRacun )

   SET KEY "'" to

   my_close_all_dbf()

   RETURN lRet



STATIC FUNCTION unos_stavki_racuna( lNovi )

   LOCAL cSto := SPACE(3)

   SELECT _pos_pripr
   GO TOP

   IF lNovi
      cBrojRacuna := "PRIPRE"
   ELSE
      cBrojRacuna := _pos_pripr->brdok
      cSto := _pos_pripr->sto
   ENDIF

   IF lNovi .AND. gStolovi == "D"
      IF !definisanje_stolova( @cSto )
         RETURN
      ENDIF
   ENDIF

   pos_unos_racuna( cBrojRacuna, cSto )

   RETURN



STATIC FUNCTION definisanje_stolova( cSto )

   LOCAL cStZak
   LOCAL nStStanje
   LOCAL lRet := .F.

   SET CURSOR ON

   Box(, 6, 40 )
      
   cStZak := "N"
      
   @ m_x + 2, m_y + 10 SAY "Unesi broj stola:" GET cSto VALID ( !Empty( cSto ) .AND. Val( cSto ) > 0 ) PICT "999"
      
   READ
      
   IF LastKey() == K_ESC
      MsgBeep( "Unos stola obavezan !" )
      RETURN lRet
   ENDIF
      
   nStStanje := g_stanje_stola( Val( cSto ) )
      
   @ m_x + 4, m_y + 2 SAY "Prethodno stanje stola:   " + AllTrim( Str( nStStanje ) ) + " KM"
      
   IF nStStanje > 0
      @ m_x + 6, m_y + 2 SAY8 "Zaključiti prethodno stanje (D/N)?" GET cStZak VALID cStZak $ "DN" PICT "@!"
   ENDIF
      
   READ
      
   BoxC()

   IF LastKey() == K_ESC
      MsgBeep( "Unos novih stavki prekinut !" )
      RETURN lRet
   ENDIF

   lRet := .T.

   IF cStZak == "D"
      zak_sto( Val( cSto ) )
   ENDIF

   RETURN lRet



FUNCTION zakljuci_pos_racun()

   LOCAL lRet := .F.
   LOCAL lOtvoriUnos := fetch_metric( "pos_konstantni_unos_racuna", my_user(), "N" ) == "D"
   LOCAL _param := hb_Hash()

   O__POS_PRIPR
   my_dbf_pack()

   IF _pos_pripr->( RecCount2() ) == 0
      my_close_all_dbf()
      RETURN lRet
   ENDIF

   GO TOP

   _param[ "idpos" ] := _pos_pripr->idpos
   _param[ "idvd" ] := _pos_pripr->idvd
   _param[ "datum" ] := _pos_pripr->datum
   _param[ "brdok" ] := _pos_pripr->brdok
   _param[ "idpartner" ] := Space( 6 )
   _param[ "idvrstap" ] := "01"
   _param[ "zakljuci" ] := "D"
   _param[ "uplaceno" ] := 0

   form_zakljuci_racun( @_param )

   IF _param[ "zakljuci" ] == "D"
      lRet := azuriraj_stavke_racuna_i_napravi_fiskalni_racun( _param )
   ENDIF

   my_close_all_dbf()

   IF lOtvoriUnos .AND. lRet
      pos_unos_ispravka_racuna()
      lRet := zakljuci_pos_racun()
   ENDIF

   RETURN lRet



STATIC FUNCTION azuriraj_stavke_racuna_i_napravi_fiskalni_racun( params )

   LOCAL _br_dok := params[ "brdok" ]
   LOCAL _id_pos := params[ "idpos" ]
   LOCAL _id_vrsta_p := params[ "idvrstap" ]
   LOCAL _id_partner := params[ "idpartner" ]
   LOCAL _uplaceno := params[ "uplaceno" ]
   LOCAL lOk := .T.
   LOCAL lRet := .F.
   LOCAL cVrijemeRacuna
   LOCAL cBrojRacuna 
 
   o_pos_tables()

   IF ( Len( aRabat ) > 0 )
      ReCalcRabat( _id_vrsta_p )
   ENDIF

   SELECT pos_doks

   cBrojRacuna := pos_novi_broj_dokumenta( _id_pos, VD_RN )

   cVrijemeRacuna := PADR( TIME(), 5 )
   gDatum := Date()

   lOk := pos_azuriraj_racun( _id_pos, cBrojRacuna, cVrijemeRacuna, _id_vrsta_p, _id_partner )

   IF !lOk
      MsgBeep( "Greška sa ažuriranjem računa u kumulativ !" )
      RETURN lRet
   ENDIF

   IF gRnInfo == "D"
      _sh_rn_info( cBrojRacuna )
   ENDIF

   IF fiscal_opt_active()
      stampaj_fiskalni_racun( _id_pos, gDatum, cBrojRacuna, _uplaceno )
   ENDIF

   my_close_all_dbf()

   RETURN lOk




STATIC FUNCTION stampaj_fiskalni_racun( cIdPos, dDatum, cBrRn, nUplaceno )

   LOCAL nDeviceId
   LOCAL hDeviceParams
   LOCAL lRet := .F.
   LOCAL nError := 0

   nDeviceId := odaberi_fiskalni_uredjaj( NIL, .T., .F. )
   IF nDeviceId > 0
      hDeviceParams := get_fiscal_device_params( nDeviceId, my_user() )
      IF hDeviceParams == NIL
         RETURN lRet
      ENDIF
   ELSE
      RETURN lRet
   ENDIF

   nError := pos_fiskalni_racun( cIdPos, dDatum, cBrRn, hDeviceParams, nUplaceno )

   IF nError = -20
      IF Pitanje(, "Da li je nestalo trake u fiskalnom uređaju (D/N)?", "N" ) == "N"
         nError := 20
      ENDIF
   ENDIF

   IF nError > 0
      pos_povrat_rn( cBrRn, dDatum )
   ENDIF
   
   lRet := .T.
 
   RETURN lRet




// ------------------------------------------------------
// ova funkcija treba da izracuna kusur
// ------------------------------------------------------
STATIC FUNCTION koliko_treba_povrata_kupcu( param )

   LOCAL _t_area := Select()
   LOCAL _t_rec := RecNo()
   LOCAL _id_pos := PARAM[ "idpos" ]
   LOCAL _id_vd := PARAM[ "idvd" ]
   LOCAL _br_dok := PARAM[ "brdok" ]
   LOCAL _dat_dok := PARAM[ "datum" ]
   LOCAL _total := 0
   LOCAL _iznos := 0
   LOCAL _popust := 0

   SELECT _pos_pripr
   GO TOP

   DO WHILE !Eof() .AND. AllTrim( field->brdok ) == "PRIPRE"
      _iznos += field->kolicina * field->cijena
      _popust += field->kolicina * field->ncijena
      SKIP
   ENDDO

   _total := ( _iznos - _popust )

   SELECT ( _t_area )
   GO ( _t_rec )

   RETURN _total


STATIC FUNCTION ispisi_iznos_i_kusur_za_kupca( uplaceno, iznos_rn, pos_x, pos_y )

   LOCAL _vratiti := uplaceno - iznos_rn

   IF uplaceno <> 0
      @ pos_x, pos_y + 23 SAY "Iznos RN: " + AllTrim( Str( iznos_rn, 12, 2 ) ) + ;
         " vratiti: " + AllTrim( Str( _vratiti, 12, 2 ) ) ;
         COLOR "BR+/B"
   ENDIF

   RETURN .T.



STATIC FUNCTION form_zakljuci_racun( params )

   LOCAL _def_partner := .F.
   LOCAL _id_vd := params[ "idvd" ]
   LOCAL _id_pos := params[ "idpos" ]
   LOCAL _br_dok := params[ "brdok" ]
   LOCAL _dat_dok := params[ "datum" ]
   LOCAL _ok := params[ "zakljuci" ]
   LOCAL _id_vrsta_p := params[ "idvrstap" ]
   LOCAL _id_partner := params[ "idpartner" ]
   LOCAL _uplaceno := params[ "uplaceno" ]

   IF gClanPopust
      _id_vrsta_p := Space( 2 )
   ELSE
      _id_vrsta_p := gGotPlac
   ENDIF

   Box(, 8, 67 )

   SET CURSOR ON

   // 01 - gotovina
   // KT - kartica
   // VR - virman
   // CK - cek

   @ m_x + 1, m_y + 2 SAY8 "FORMA ZAKLJUČENJA RAČUNA" COLOR "BG+/B"

   @ m_x + 3, m_y + 2 SAY8 "Način plaćanja (01/KT/VR...):" GET _id_vrsta_p PICT "@!" VALID p_vrstep( @_id_vrsta_p )

   READ

   IF _id_vrsta_p <> gGotPlac
      _def_partner := .T.
   ENDIF

   IF _def_partner
      @ m_x + 4, m_y + 2 SAY "Kupac:" GET _id_partner PICT "@!" VALID P_Firma( @_id_partner )
   ELSE
      _id_partner := Space( 6 )
   ENDIF

   @ _x_pos := m_x + 5, _y_pos := m_y + 2 SAY8 "Kupac uplatio:" GET _uplaceno PICT "9999999.99" ;
      VALID {|| if ( _uplaceno <> 0, ispisi_iznos_i_kusur_za_kupca( _uplaceno, koliko_treba_povrata_kupcu( params ), _x_pos, _y_pos ), .T. ), .T. }


   @ m_x + 8, m_y + 2 SAY8 "Ažurirati račun (D/N) ?" GET _ok PICT "@!" VALID _ok $ "DN"

   READ

   BoxC()

   IF LastKey() == K_ESC
      _ok := "D"
   ENDIF

   params[ "zakljuci" ] := _ok
   params[ "idpartner" ] := _id_partner
   params[ "idvrstap" ] := _id_vrsta_p
   params[ "uplaceno" ] := _uplaceno

   RETURN



FUNCTION RacObilj()

   IF AScan ( aVezani, {| x| x[ 1 ] + DToS( x[ 4 ] ) + x[ 2 ] == pos_doks->( IdPos + DToS( datum ) + BrDok ) } ) > 0
      RETURN .T.
   ENDIF

   RETURN .F.


FUNCTION PreglNezakljRN()

   o_pos_tables()

   dDatOd := Date()
   dDatDo := Date()

   Box (, 1, 60 )
   SET CURSOR ON
   @ m_x + 1, m_y + 2 SAY "Od datuma:" GET dDatOd
   @ m_x + 1, m_y + 22 SAY "Do datuma:" GET dDatDo
   READ
   ESC_BCR
   BoxC()

   IF Pitanje(, "Pregledati nezaključene račune (D/N) ?", "D" ) == "D"
      StampaNezakljRN( gIdRadnik, dDatOd, dDatDo )
   ENDIF

   RETURN



FUNCTION RekapViseRacuna()

   cBrojStola := Space( 3 )

   o_pos_tables()

   dDatOd := Date()
   dDatDo := Date()

   Box (, 2, 60 )
   SET CURSOR ON
   @ m_x + 1, m_y + 2 SAY "Od datuma:" GET dDatOd
   @ m_x + 1, m_y + 22 SAY "Do datuma:" GET dDatDo
   @ m_x + 2, m_y + 2 SAY "Broj stola:" GET cBrojStola VALID !Empty( cBrojStola )
   READ
   ESC_BCR
   BoxC()

   IF Pitanje(, "Štampati zbirni račun (D/N) ?", "D" ) == "D"
      StampaRekap( gIdRadnik, cBrojStola, dDatOd, dDatDo, .T. )
   ENDIF

   RETURN




FUNCTION StrValuta( cNaz2, dDat )

   LOCAL nTekSel

   nTekSel := Select()
   SELECT valute
   SET ORDER TO TAG "NAZ2"
   cNaz2 := PadR( cNaz2, 4 )
   SEEK PadR( cnaz2, 4 ) + DToS( dDat )
   IF valute->naz2 <> cnaz2
      SKIP -1
   ENDIF
   SELECT ( nTekSel )
   IF valute->naz2 <> cnaz2
      RETURN 0
   ELSE
      RETURN valute->kurs1
   ENDIF


