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


FUNCTION os_sifarnici()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _opis

   _opis := "osnovna sredstva"

   IF gOsSii == "S"
      _opis := "sitan inventar"
   ENDIF

   AAdd( _opc, PadR( "1. " + _opis, 40 ) )
   AAdd( _opcexe, {|| p_os() } )

   AAdd( _opc, "2. koeficijenti amortizacije"  )
   AAdd( _opcexe, {|| p_amort() } )
   AAdd( _opc, "3. koeficijenti revalorizacije" )
   AAdd( _opcexe, {|| p_reval() } )
   AAdd( _opc, "4. radne jedinice" )
   AAdd( _opcexe, {|| p_rj() } )
   AAdd( _opc, "---------------------------" )
   AAdd( _opcexe, {|| nil } )
   AAdd( _opc, "6. konta" )
   AAdd( _opcexe, {|| p_konto() } )
   AAdd( _opc, "7. grupacije K1" )
   AAdd( _opcexe, {|| p_k1() } )
   AAdd( _opc, "8. partneri" )
   AAdd( _opcexe, {|| p_partner() } )
   AAdd( _opc, "9. valute" )
   AAdd( _opcexe, {|| p_valuta() } )

   _o_sif_tables()

   f18_menu( "sifre", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN



FUNCTION P_OS( cId, dx, dy )

   LOCAL lNovi := .T.
   LOCAL _n_area := F_OS
   PRIVATE ImeKol
   PRIVATE Kol

   IF gOsSii == "S"
      _n_area := F_SII
   ENDIF

   ImeKol := { { PadR( "Inv.Broj", 15 ), {|| id },     "id", {|| .T. }, {|| validacija_postoji_sifra( wId ) .AND. os_promjena_id_zabrana( lNovi ) } }, ;
      { PadR( "Naziv", 30 ), {|| naz },     "naz"      }, ;
      { PadR( "Kolicina", 8 ), {|| kolicina },    "kolicina"     }, ;
      { PadR( "jmj", 3 ), {|| jmj },    "jmj"     }, ;
      { PadR( "Datum", 8 ), {|| Datum },    "datum"     }, ;
      { PadR( "RJ", 2 ),    {|| idRj },    "idRj", {|| .T. }, {|| P_Rj( @wIdRj ) }   }, ;
      { PadR( "Konto", 7 ), {|| idkonto },    "idkonto", {|| .T. }, {|| P_Konto( @wIdKonto ) }     }, ;
      { PadR( "StAm", 8 ),  {|| IdAm },  "IdAm", {|| .T. }, {|| P_Amort( @wIdAm ) } }, ;
      { PadR( "StRev", 5 ), {|| IdRev + " " },  "IdRev", {|| .T. }, {|| P_Reval( @wIdRev ) }   }, ;
      { PadR( "NabVr", 15 ), {|| nabvr },  "nabvr", {|| .T. }, {|| os_validate_vrijednost( wnabvr, wotpvr ) } }, ;
      { PadR( "OtpVr", 15 ), {|| otpvr },  "otpvr", {|| .T. },  {|| os_validate_vrijednost( wnabvr, wotpvr ) }  };
      }

   IF os_postoji_polje( "K1" )
      AAdd ( ImeKol, { PadC( "K1", 4 ), {|| k1 }, "k1", {|| .T. }, {|| P_K1( @wK1 ) } } )
      AAdd ( ImeKol, { PadC( "K2", 2 ), {|| k2 }, "k2"   } )
      AAdd ( ImeKol, { PadC( "K3", 2 ), {|| k3 }, "k3"   } )
      AAdd ( ImeKol, { PadC( "Opis", 2 ), {|| opis }, "opis"   } )
   ENDIF

   IF os_fld_partn_exist()
      AAdd ( ImeKol, { "Dobavljac", {|| idPartner }, "idPartner", {|| .T. }, {|| p_partner( @wIdPartner ) }   } )
   ENDIF

   IF os_postoji_polje( "brsoba" )
      AAdd ( ImeKol, { PadC( "BrSoba", 6 ), {|| brsoba }, "brsoba"   } )
   ENDIF

   PRIVATE Kol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN PostojiSifra( _n_area, 1, MAXROWS() -15, MAXCOLS() -15, "Lista stalnih sredstava", @cId, dx, dy, {| Ch| os_sif_key_handler( Ch, @lNovi ) } )




FUNCTION os_validate_vrijednost( wNabVr, wOtpVr )

   @ m_x + 11, m_y + 50 say ( wNabvr - wOtpvr )

   RETURN .T.



FUNCTION os_sif_key_handler( Ch, lNovi )

   LOCAL _n_area := F_PROMJ
   LOCAL _rec
   LOCAL _sr_id

   lNovi := .T.

   IF gOsSii == "S"
      _n_area := F_SII_PROMJ
   ENDIF

   _sr_id := field->id

   DO CASE

   CASE ( Ch == K_CTRL_T )

      SELECT ( _n_area )
      lUsedPromj := .T.

      IF !Used()
         lUsedPromj := .F.
         o_os_sii_promj()
      ENDIF

      select_promj()

      SEEK _sr_id

      IF Found()
         Beep( 1 )
         Msg( "Sredstvo se ne moze brisati - prvo izbrisi promjene !" )
      ELSE
         select_os_sii()
         IF Pitanje(, "Sigurno zelite izbrisati ovo sredstvo ?", "N" ) == "D"
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( get_os_table_name( Alias() ), _rec, 1, "FULL" )
         ENDIF
      ENDIF
      IF !lUsedPromj
         select_promj()
         USE
      ENDIF
      select_os_sii()

      RETURN 7
      // kao de_refresh, ali se zavrsava izvrsenje f-ja iz ELIB-a

   CASE ( Ch == K_F2 )
      // ispravka stavke
      lNovi := .F.

   ENDCASE

   RETURN DE_CONT



FUNCTION os_promjena_id_zabrana( lNovi )

   IF !lNovi .AND. wId <> field->id
      Beep( 1 )
      Msg( "Promjenu inventurnog broja ne vrsiti ovdje !" )
      RETURN .F.
   ENDIF

   RETURN .T.


FUNCTION P_AMORT( cId, dx, dy )

   PRIVATE ImeKol, Kol

   ImeKol := { { PadR( "Id", 8 ), {|| id },     "id", {|| .T. }, {|| validacija_postoji_sifra( wid ) }    }, ;
      { PadR( "Naziv", 25 ), {|| naz },     "naz"      }, ;
      { PadR( "Iznos", 7 ), {|| iznos },    "iznos"     };
      }
   Kol := { 1, 2, 3 }

   RETURN PostojiSifra( F_AMORT, 1, MAXROWS() -15, MAXCOLS() -15, "Lista koeficijenata amortizacije", @cId, dx, dy )



FUNCTION P_REVAL( cId, dx, dy )

   PRIVATE ImeKol, Kol

   ImeKol := { { PadR( "Id", 4 ), {|| id },     "id", {|| .T. }, {|| validacija_postoji_sifra( wid ) }    }, ;
      { PadR( "Naziv", 10 ), {|| naz },     "naz"      }, ;
      { PadR( "I1", 7 ), {|| i1 },    "i1"     }, ;
      { PadR( "I2", 7 ), {|| i2 },    "i2"     }, ;
      { PadR( "I3", 7 ), {|| i3 },    "i3"     }, ;
      { PadR( "I4", 7 ), {|| i4 },    "i4"     }, ;
      { PadR( "I5", 7 ), {|| i5 },    "i5"     }, ;
      { PadR( "I6", 7 ), {|| i6 },    "i6"     }, ;
      { PadR( "I7", 7 ), {|| i7 },    "i7"     }, ;
      { PadR( "I8", 7 ), {|| i8 },    "i8"     }, ;
      { PadR( "I9", 7 ), {|| i9 },    "i9"     }, ;
      { PadR( "I10", 7 ), {|| i10 },    "i10"     }, ;
      { PadR( "I11", 7 ), {|| i11 },    "i11"     }, ;
      { PadR( "I12", 7 ), {|| i12 },    "i12"     };
      }
   Kol := { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }

   RETURN PostojiSifra( F_REVAL, 1, MAXROWS() -15, MAXCOLS() -15, "Lista koeficijenata revalorizacije", @cId, dx, dy )



STATIC FUNCTION validacija_postoji_sifra( wid )

   LOCAL _t_rec := RecNo()
   LOCAL _ret

   SEEK wId

   IF Found() .AND. Ch == K_CTRL_N
      Beep( 3 )
      _ret := .F.
   ELSE
      _ret := .T.
   ENDIF
   GO _t_rec

   RETURN _ret



// --------------------------------------------------------------
// provjerava postojanje polja idpartner u os/sii tabelama
// --------------------------------------------------------------
FUNCTION os_fld_partn_exist()
   RETURN os_postoji_polje( "idpartner" )



STATIC FUNCTION _o_sif_tables()

   o_valute()
   o_konto()

   o_os_sii()

   O_AMORT
   O_REVAL
   o_rj()
   O_K1
   o_partner()
   o_sifk()
   o_sifv()

   RETURN .T.
