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


FUNCTION pos_narudzba()

   LOCAL _ret

   SetKXLat( "'", "-" )

   o_pos_tables()

   SELECT _pos_pripr

   IF reccount2() <> 0 .AND. !Empty( field->brdok )
      _ret := dodaj_na_racun( _pos_pripr->brdok )
   ELSE
      _ret := novi_racun()
   ENDIF

   SET KEY "'" to

   my_close_all_dbf()

   RETURN _ret



STATIC FUNCTION dodaj_na_racun( cBrojRn )

   SET CURSOR ON

   IF cBrojRn == nil
      cBrojRn := Space( 6 )
   ELSE
      cBrojRn := cBrojRn
   ENDIF

   pos_unos_racuna( cBrojRn, _pos->sto )

   RETURN


STATIC FUNCTION novi_racun()

   LOCAL cBrojRn
   LOCAL cBr2
   LOCAL cSto := Space( 3 )
   LOCAL dx := 3

   SELECT _pos
   SET CURSOR ON

   cBrojRn := "PRIPRE"

   IF gStolovi == "D"

      SET CURSOR ON

      Box(, 6, 40 )
      cStZak := "N"
      @ m_x + 2, m_y + 10 SAY "Unesi broj stola:" GET cSto VALID ( !Empty( cSto ) .AND. Val( cSto ) > 0 ) PICT "999"
      READ
      IF LastKey() == K_ESC
         MsgBeep( "Unos stola obavezan !" )
         RETURN
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
         RETURN
      ENDIF

      IF cStZak == "D"
         zak_sto( Val( cSto ) )
      ENDIF

   ENDIF

   pos_unos_racuna( cBrojRn, cSto )

   RETURN





FUNCTION PreglRadni( cBrDok )

   LOCAL nPrev := Select()

   SELECT _POS
   SET ORDER TO TAG "1"
   cFilt1 := "IdPos+IdVd+dtos(datum)+BrDok+IdRadnik==" + cm2str( gIdPos + VD_RN + DToS( gDatum ) + cBrDok + gIdRadnik )
   SET FILTER To &cFilt1
   ImeKol := { { "Roba",         {|| IdRoba + "-" + Left ( RobaNaz, 30 ) }, }, ;
      { "Kolicina",     {|| Str ( Kolicina, 8, 2 ) }, }, ;
      { "Cijena",       {|| Str ( Cijena, 8, 2 ) }, }, ;
      { "Iznos stavke", {|| Str ( Kolicina * Cijena, 12, 2 ) }, };
      }
   Kol := { 1, 2, 3, 4 }
   GO TOP
   ObjDBedit ( "rn2", MAXROWS() - 4, MAXCOLS() - 3,, " Radni racun " + AllTrim ( cBrDok ), "", nil )
   SET FILTER TO

   SELECT _pos_pripr

   RETURN




FUNCTION ZakljuciRacun()

   LOCAL lRet
   LOCAL lOtvoriUnos := fetch_metric( "pos_konstantni_unos_racuna", my_user(), "N" ) == "D"

   lRet := zakljuci_pos_racun()

   IF !lRet
      MsgBeep( "Postoji problem sa ažuriranjem računa !" )
   ENDIF

   IF lOtvoriUnos .AND. lRet
      pos_narudzba()
      zakljuciracun()
   ENDIF

   RETURN lRet



FUNCTION zakljuci_pos_racun()

   LOCAL lRet := .F.
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
      lRet := pos_zakljuci_racun_sve_na_jedan( _param )
   ENDIF

   my_close_all_dbf()

   RETURN lRet



STATIC FUNCTION pos_zakljuci_racun_sve_na_jedan( params )

   LOCAL _br_dok := params[ "brdok" ]
   LOCAL _id_pos := params[ "idpos" ]
   LOCAL _id_vrsta_p := params[ "idvrstap" ]
   LOCAL _id_partner := params[ "idpartner" ]
   LOCAL _uplaceno := params[ "uplaceno" ]
   LOCAL lOk := .T.

   o_pos_tables()

   IF ( Len( aRabat ) > 0 )
      ReCalcRabat( _id_vrsta_p )
   ENDIF

   pos_prebaci_pripr_u_pos( _id_vrsta_p )

   lOk := azuriraj_racun_iz_pripreme( _id_pos, _br_dok, _id_vrsta_p, _id_partner, _uplaceno )

   my_close_all_dbf()

   RETURN lOk



STATIC FUNCTION azuriraj_racun_iz_pripreme( cIdPos, cRadRac, cIdVrsteP, cIdGost, nUplaceno )

   LOCAL cTime
   LOCAL nFis_err := 0
   LOCAL cBrojRacuna 
   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL _rec, _dev_id, _dev_params
   PRIVATE cPartner

   SELECT pos_doks

   cBrojRacuna := pos_novi_broj_dokumenta( cIdPos, VD_RN )

   cTime := PADR( TIME(), 5 )
   gDatum := Date()
   cPartner := cIdGost

   lOk := pos_azuriraj_racun( cIdPos, cBrojRacuna, cRadRac, cTime, cIdVrsteP, cIdGost )

   IF !lOk
      RETURN lRet
   ENDIF

   IF gRnInfo == "D"
      _sh_rn_info( cStalRac )
   ENDIF

   IF fiscal_opt_active()
      stampaj_fiskalni_racun( cIdPos, gDatum, cBrojRacuna, nUplaceno )
   ENDIF

   lRet := .T.

   RETURN lRet




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
STATIC FUNCTION _calc_racun( param )

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


// ---------------------------------------------------------
// ispisuje iznos racuna i kusur
// ---------------------------------------------------------
STATIC FUNCTION _ispisi( uplaceno, iznos_rn, pos_x, pos_y )

   LOCAL _vratiti := uplaceno - iznos_rn

   IF uplaceno <> 0
      @ pos_x, pos_y + 23 SAY "Iznos RN: " + AllTrim( Str( iznos_rn, 12, 2 ) ) + ;
         " vratiti: " + AllTrim( Str( _vratiti, 12, 2 ) ) ;
         COLOR "BR+/B"
   ENDIF

   RETURN .T.



// -------------------------------------------------------
// forma prije zakljucenja racuna
// -------------------------------------------------------
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
      // ako je rijec o clanovima pusti da izaberem vrstu placanja
      _id_vrsta_p := Space( 2 )
   ELSE
      _id_vrsta_p := gGotPlac
   ENDIF

   // select _pos
   // seek _id_pos + _id_vd + DTOS( _dat_dok ) + _br_dok

   Box(, 8, 67 )

   SET CURSOR ON

   // 01 - gotovina
   // KT - kartica
   // VR - virman
   // CK - cek
   // ...

   @ m_x + 1, m_y + 2 SAY "FORMA ZAKLJUCENJA RACUNA" COLOR "BG+/B"

   @ m_x + 3, m_y + 2 SAY "Nacni placanja (01/KT/VR...):" GET _id_vrsta_p PICT "@!" VALID p_vrstep( @_id_vrsta_p )

   READ

   // ako nije rijec o gotovini ponudi partnera
   IF _id_vrsta_p <> gGotPlac
      _def_partner := .T.
   ENDIF

   IF _def_partner
      @ m_x + 4, m_y + 2 SAY "Kupac:" GET _id_partner PICT "@!" VALID P_Firma( @_id_partner )
   ELSE
      _id_partner := Space( 6 )
   ENDIF

   @ _x_pos := m_x + 5, _y_pos := m_y + 2 SAY "Uplaceno:" GET _uplaceno PICT "9999999.99" ;
      VALID {|| if ( _uplaceno <> 0, _ispisi( _uplaceno, _calc_racun( params ), _x_pos, _y_pos ), .T. ), .T. }


   // pitanje za kraj ?
   @ m_x + 8, m_y + 2 SAY "Zakljuciti racun (D/N) ?" GET _ok PICT "@!" VALID _ok $ "DN"

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





FUNCTION ZakljuciDio()

   LOCAL cRacBroj := Space( 6 )

   // Zakljucuje dio racuna (ostatak ostaje aktivan)
   O__POS

   SET CURSOR ON
   Box (, 1, 50 )
   // unesi broj racuna
   @ m_x + 1, m_y + 3 SAY "Zakljuci dio radnog racuna broj:" GET cRacBroj VALID P_RadniRac ( @cRacBroj )
   READ
   ESC_BCR
   BoxC()

   o_pos_tables()

   O_RAZDR

   RazdRac( cRacBroj, .F., 2, "N", "ZAKLJUCENJE DIJELA RACUNA" )

   my_close_all_dbf()

   RETURN




FUNCTION RazdijeliRacun()

   LOCAL cOK := " "
   LOCAL cAuto := "D"
   LOCAL cRacBroj := Space( 6 )
   LOCAL nKoliko := 0

   O__POS

   SET CURSOR ON
   Box(, 8, 55 )
   WHILE cOK <> "D"
      @ m_x + 1, m_y + 3 SAY "          Razdijeli radni racun broj:" GET cRacBroj VALID P_RadniRac ( @cRacBroj )
      @ m_x + 3, m_y + 3 SAY "        Ukupno je potrebno napraviti:" GET nKoliko PICT "99" VALID nKoliko > 1 .AND. nKoliko <= 10
      @ m_x + 4, m_y + 3 SAY "  (ukljucujuci i ovaj prvi)"
      @ m_x + 6, m_y + 3 SAY "Automatski razdijeli kolicine? (D/N):" GET cAuto PICT "@!" VALID cAuto $ "DN"
      @ m_x + 8, m_y + 3 SAY "                  Unos u redu? (D/N):" GET cOK PICT "@!" VALID cOK $ "DN"
      READ
      ESC_BCR
   END
   BoxC()

   o_pos_tables()

   O_RAZDR
   RazdRac( cRacBroj, .T., nKoliko, cAuto, "RAZDIOBA RACUNA" )
   my_close_all_dbf()

   RETURN



FUNCTION RobaNaziv( cSifra )

   LOCAL nARRR := Select()

   SELECT roba
   hseek cSifra
   SELECT( nArrr )

   RETURN roba->naz



FUNCTION PromNacPlac()

   LOCAL cRacun := Space( 9 )
   LOCAL cIdVrsPla := gGotPlac
   LOCAL cPartner := Space( 8 )
   LOCAL cDN := " "
   LOCAL cIdPOS
   LOCAL _rec
   PRIVATE aVezani := {}

   O_PARTN
   O_VRSTEP
   O_ROBA
   O__POS_PRIPR
   O__POS
   O_POS
   O_POS_DOKS

   Box (, 7, 70 )
   // prebaci se na posljednji racun da ti je lakse
   IF gVrstaRS <> "S"
      SELECT pos_doks
      SEEK ( gIdPos + VD_RN + Chr ( 250 ) )
      IF pos_doks->IdVd <> VD_RN
         SKIP -1
      ENDIF
      DO WHILE !Bof() .AND. pos_doks->( IdPos + IdVd ) == ( gIdPos + VD_RN ) .AND. pos_doks->IdRadnik <> gIdRadnik
         SKIP -1
      ENDDO
      IF !Bof() .AND. pos_doks->( IdPos + IdVd ) == ( gIdPos + VD_RN ) .AND. pos_doks->IdRadnik == gIdRadnik
         cRacun := PadR ( AllTrim ( gIdPos ) + "-" + AllTrim ( pos_doks->BrDok ), Len( cRacun ) )
      ENDIF
   ENDIF

   dDat := gDatum

   SET CURSOR ON
   @ m_x + 1, m_y + 4 SAY "Datum:" GET dDat
   @ m_x + 2, m_y + 4 SAY "Racun:" GET cRacun VALID PRacuni ( @dDat, @cRacun ) ;
      .AND. Pisi_NPG();
      .AND. RacNijeZaklj ( cRacun );
      .AND. RacNijePlac ( @cIdVrspla, @cPartner )
   @ m_x + 3, m_y + 7 SAY "Nacin placanja:" GET cIdVrsPla ;
      VALID P_VrsteP ( @cIdVrsPla, 3, 26 ) PICT "@!"
   READ
   ESC_BCR

   IF ( cIdVrsPla <> gGotPlac )
      @ m_x + 5, m_y + 9 SAY "Partner:" GET cPartner PICT "@!" ;
         VALID P_Firma( @cPartner, 5, 26 )
      READ
      ESC_BCR
   ELSE
      cPartner := ""
   ENDIF

   // vec je DOKS nastiman u BrowseSRn
   SELECT pos_doks

   _rec := dbf_get_rec()
   _rec[ "idvrstep" ] := cIdVrsPla
   _rec[ "idgost" ] := cPartner

   update_rec_server_and_dbf( "pos_doks", _rec, 1, "FULL" )

   BoxC()

   CLOSE ALL

   RETURN


FUNCTION RacNijeZaklj()

   IF ( gVrstaRS == "S" .AND. kLevel < L_UPRAVN )
      RETURN .T.
   ENDIF
   IF ( pos_doks->Datum == gDatum )
      RETURN .T.
   ENDIF
   MsgBeep ( "Promjena nacina placanja nije moguca!" )

   RETURN .F.


FUNCTION RacNijePlac( cIdVrsPla, cPartner )

   // Provjerava da li je racun pribiljezen kao placen
   // Ako jest, tad promjena nacina placanja nema smisla

   IF pos_doks->Placen == "D"
      MsgBeep ( "Racun je vec placen!#Promjena nacina placanja nije dopustena!" )
      RETURN ( .F. )
   ELSE
      cIdVrsPla := pos_doks->idvrstep
      cPartner := pos_doks->idgost
   ENDIF

   RETURN ( .T. )




FUNCTION Pisi_NPG()

   PushWA()
   SELECT VRSTEP
   Seek2 ( pos_doks->IdVrsteP )
   IF Found ()
      @ m_x + 3, m_y + 26 SAY Naz
   ENDIF
   SELECT partn
   Seek2 ( pos_doks->IdGost )
   IF Found ()
      @ m_x + 5, m_y + 31 SAY Left ( Naz, 30 )
   ENDIF
   PopWA ()

   RETURN ( .T. )



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

   IF Pitanje(, "Pregledati nezakljucene racune (D/N) ?", "D" ) == "D"
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

   IF Pitanje(, "Odstampati zbirni racun (D/N) ?", "D" ) == "D"
      StampaRekap( gIdRadnik, cBrojStola, dDatOd, dDatDo, .T. )
   ENDIF

   RETURN



// ---------------------------------------------
// prepis racuna
// ---------------------------------------------
FUNCTION PrepisRacuna()

   LOCAL cPolRacun := Space( 9 )
   LOCAL cIdPos := Space( Len( gIdPos ) )
   LOCAL nPoz
   PRIVATE aVezani := {}
   PRIVATE dDatum
   PRIVATE cVrijeme

   o_pos_tables()

   Box (, 3, 60 )

   dDat := gDatum

   IF ( klevel <> L_PRODAVAC )
      @ m_x + 1, m_y + 4 SAY "Datum:" GET dDat
   ENDIF

   SET CURSOR ON

   @ m_x + 2, m_y + 4 SAY "Racun:" GET cPolRacun VALID PRacuni( @dDat, @cPolRacun, .T. )

   READ
   ESC_BCR

   BoxC()

   IF Len( aVezani ) > 0
      ASort ( aVezani,,, {| x, y| x[ 1 ] + DToS( x[ 4 ] ) + x[ 2 ] < y[ 1 ] + DToS( y[ 4 ] ) + y[ 2 ] } )
      cIdPos := aVezani[1 ][ 1 ]
      cPolRacun := DToS( aVezani[ 1, 4 ] ) + aVezani[1 ][ 2 ]
   ELSE
      nPoz := At ( "-", cPolRacun )
      IF npoz <> 0
         cIdPos := PadR ( AllTrim ( Left ( cPolRacun, nPoz - 1 ) ), Len ( gIdPos ) )
      ELSE
         cIdPos := gIdPos
      ENDIF
      cPolRacun := PadL ( AllTrim ( SubStr ( cPolRacun, nPoz + 1 ) ), 6 )
      aVezani := { { cIdPos, cPolRacun, "", dDat } }
      cPolRacun := DToS( dDat ) + cPolRacun
      // stampaprep sadrzi 2-param kao dtos(datum)+brdok
   ENDIF

   StampaPrep( cIdPos, cPolRacun, aVezani )

   my_close_all_dbf()

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
