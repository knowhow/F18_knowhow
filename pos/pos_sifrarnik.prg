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


FUNCTION pos_roba_block( ch )

   DO CASE

   CASE Upper( Chr( ch ) ) == "P"
      IF gen_all_plu()
         RETURN DE_REFRESH
      ENDIF

   ENDCASE

   RETURN DE_CONT




FUNCTION pos_get_mpc()

   LOCAL nCijena := 0
   LOCAL cField
   LOCAL oData, cQry

   IF !pos_get_mpc_valid()
      MsgBeep( "Set cijena nije podesen ispravno !" )
      RETURN 0
   ENDIF

   cField := pos_get_mpc_field()

   cQry := "SELECT " + cField + " FROM " + F18_PSQL_SCHEMA_DOT + "roba "
   cQry += "WHERE id = " + sql_quote( roba->id )

   oData := run_sql_query( cQry )

   IF !is_var_objekat_tpqquery( oData )
      MsgBeep( "Problem sa SQL upitom !" )
   ELSE
      IF oData:LastRec() > 0 .AND. VALTYPE( oData:FieldGet(1) ) == "N"
         nCijena := oData:FieldGet(1)
      ENDIF
   ENDIF

   RETURN nCijena



STATIC FUNCTION pos_get_mpc_field()

   LOCAL cField := "mpc"
   LOCAL cSet := AllTrim( gSetMPCijena )

   IF cSet <> "1"
       cField := cField + cSet
   ENDIF

   RETURN cField



STATIC FUNCTION pos_get_mpc_valid()

   LOCAL lOk := .T.
   LOCAL cSet := AllTrim( gSetMPCijena )

   IF EMPTY( cSet ) .OR. cSet == "0"
      lOk := .F.
   ENDIF

   RETURN lOk



FUNCTION P_Kase( cId, dx, dy )

   PRIVATE ImeKol
   PRIVATE Kol

   SELECT ( F_KASE )
   IF !Used()
      O_KASE
   ENDIF

   ImeKol := {}
   AAdd( ImeKol, { "Sifra/ID kase", {|| id }, "id" } )
   AAdd( ImeKol, { "Naziv kase", {|| Naz }, "Naz" } )
   AAdd( ImeKol, { "Lokacija kumulativa", {|| pPath }, "pPath" } )
   Kol := { 1, 2, 3 }

   RETURN PostojiSifra( F_KASE, 1, 10, 77, "Sifarnik kasa/prodajnih mjesta", @cId, dx, dy )



FUNCTION Id2Naz()

   LOCAL nSel := Select()

   PushWA()
   SELECT roba
   HSEEK sast->id2
   popwa()

   RETURN Left( roba->naz, 25 )


FUNCTION LMarg()
   RETURN "   "



FUNCTION P_Odj( cId, dx, dy )

   PRIVATE ImeKol
   PRIVATE Kol := {}

   ImeKol := { { "ID ", {|| id }, "id", {|| .T. }, {|| vpsifra( wId ) } }, { PadC( "Naziv", 25 ), {|| naz }, "naz" }, { "Konto u KALK", {|| IdKonto }, "IdKonto" } }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN PostojiSifra( F_ODJ, 1, 10, 40, "Sifarnik odjeljenja", @cId, dx, dy )



FUNCTION P_Dio( cId, dx, dy )

   PRIVATE ImeKol
   PRIVATE Kol := {}

   ImeKol := { { "ID ", {|| id }, "id", {|| .T. }, {|| vpsifra( wId ) } }, { PadC( "Naziv", 25 ), {|| naz }, "naz" } }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN PostojiSifra( F_DIO, 1, 10, 55, "Sifrarnik dijelova objekta", @cid, dx, dy )



FUNCTION P_StRad( cId, dx, dy )

   PRIVATE ImeKol
   PRIVATE Kol := {}

   ImeKol := { { "ID ",  {|| id },       "id", {|| .T. }, {|| vpsifra( wId ) }      }, ;
      { PadC( "Naziv", 15 ), {|| naz },       "naz"       }, ;
      { "Prioritet", {|| PadC( prioritet, 9 ) }, "prioritet", {|| .T. }, {|| ( "0" <= wPrioritet ) .AND. ( wPrioritet <= "3" ) } } ;
      }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN PostojiSifra( F_STRAD, 1, 10, 55, "Sifrarnik statusa radnika", @cid, dx, dy )



FUNCTION P_Osob( cId, dx, dy )

   PRIVATE ImeKol
   PRIVATE Kol := {}

   ImeKol := { { "ID ",          {|| id },    "id", {|| .T. }, {|| vpsifra( wId ) } }, ;
      { PadC( "Naziv", 40 ), {|| naz },  "naz"    }, ;
      { "Korisn.sifra", {|| korsif }, "korsif" }, ;
      { "Status",       {|| status }, "status" };
      }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN PostojiSifra( F_OSOB, 2, 10, 55, "Sifrarnik osoblja", @cid, dx, dy, {|| EdOsob() } )

   RETURN .T.




FUNCTION P_Uredj( cId, dx, dy )

   PRIVATE ImeKol
   PRIVATE Kol := {}

   ImeKol := { { "ID ",  {|| id },       "id", {|| .T. }, {|| vpsifra( wId ) }      }, ;
      { PadC( "Naziv", 30 ), {|| naz },      "naz"       }, ;
      { "Port", {|| port },      "port"       };
      }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN PostojiSifra( F_UREDJ, 1, 10, 55, "Sifrarnik uredjaja", @cid, dx, dy )




FUNCTION P_MJTRUR( cId, dx, dy )

   PRIVATE ImeKol
   PRIVATE Kol := {}

   ImeKol := { { "Uredjaj",     {|| iduredjaj }, "IdUredjaj", {|| .T. }, {|| P_Uredj( wIdUredjaj ) } }, ;
      { "Odjeljenje",  {|| IdOdj },     "IdOdj", {|| .T. }, {|| P_Odj( wIdOdj ) } }, ;
      { "Dio objekta", {|| IdDio },     "IdDio", {|| .T. }, {|| P_Dio( wIdDio ) } } ;
      }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN PostojiSifra( F_MJTRUR, 1, 10, 55, "Sifrarnik parova uredjaj-odjeljenje", @cid, dx, dy )



FUNCTION EdOsob()

   LOCAL lSystemLevel := ( pos_admin() )
   LOCAL nVrati := DE_CONT
   LOCAL hRec

   DO CASE

   CASE Ch == K_CTRL_N

      IF gSamoProdaja == "D"
         MsgBeep( "SamoProdaja=D#Nemate ovlastenje za ovu opciju !" )
         nVrati := DE_CONT
      ELSE

         IF lSystemLevel

            // setuj varijable globalne
            set_global_memvars_from_dbf()

            _korsif := Space( 6 )

            IF GetOsob( .T. ) <> K_ESC

               // azuriranje OSOB.DBF
               _korsif := CryptSC( _korsif )

               APPEND BLANK

               // daj mi iz globalnih varijabli
               hRec := get_hash_record_from_global_vars()

               update_rec_server_and_dbf( Alias(), hRec, 1, "FULL" )

               nVrati := DE_REFRESH

            ENDIF
         ENDIF
      ENDIF

   CASE Ch == K_F2

      IF gSamoProdaja == "D"
         MsgBeep( "SamoProdaja=D#Nemate ovlastenje za ovu opciju !" )
         nVrati := DE_CONT
      ELSE

         IF lSystemLevel

            set_global_memvars_from_dbf()
            _korsif := CryptSC( _korsif )

            IF GetOsob( .F. ) <> K_ESC
               // azuriranje OSOB.DBF
               _korsif := CryptSC( _korsif )
               // daj mi iz globalnih varijabli
               hRec := get_hash_record_from_global_vars()

               update_rec_server_and_dbf( Alias(), hRec, 1, "FULL" )

               nVrati := DE_REFRESH

            ENDIF
         ENDIF
      ENDIF

   CASE Ch == K_CTRL_T

      IF gSamoProdaja == "D"
         MsgBeep( "Nemate ovlastenje za ovu opciju !" )
         nVrati := DE_CONT
      ELSE
         IF lSystemLevel
            IF Pitanje(, "Izbrisati korisnika " + Trim( naz ) + ":" + CryptSC( korsif ) + " D/N ?", "N" ) == "D"

               SELECT osob
               hRec := dbf_get_rec()
               delete_rec_server_and_dbf( Alias(), hRec, 1, "FULL" )
               nVrati := DE_REFRESH

            ENDIF
         ENDIF
      ENDIF
   CASE Ch == K_ESC .OR. Ch == K_ENTER
      nVrati := DE_ABORT
   ENDCASE

   IF ch == K_ALT_R .OR. ch == K_ALT_S .OR. ch == K_CTRL_N .OR. ch == K_F2 .OR. ch == K_F4 .OR. ch == K_CTRL_A .OR. ch == K_CTRL_T .OR. ch == K_ENTER
      ch := 0
   ENDIF

   RETURN nVrati




FUNCTION GetOsob( fNovi )

   LOCAL cLevel

   Box( "", 4, 60, .F., "Unos novog korisnika,sifre" )

   SET CURSOR ON

   IF fNovi .OR. pos_admin()
      @ m_x + 1, m_y + 2 SAY "Sifra radnika (ID)." GET _id VALID vpsifra( _id )
   ELSE
      @ m_x + 1, m_y + 2 SAY "Sifra radnika (ID). " + _id
   ENDIF

   @ m_x + 2, m_y + 2 SAY "Ime radnika........" GET _naz

   READ

   SELECT strad
   HSEEK gStRad
   cLevel := strad->prioritet

   SELECT strad
   HSEEK _status
   SELECT osob

   // level tekuceg korisnika > level
   IF ( cLevel > strad->prioritet )
      MsgBeep( "Ne mozete mjenjati sifru" )
   ELSE
      @ m_x + 3, m_y + 2 SAY "Sifra.............." GET _korsif PICTURE "@!" VALID vpsifra2( _korsif, _id )
      @ m_x + 4, m_y + 2 SAY "Status............." GET _status VALID P_STRAD( @_status )
   ENDIF

   READ

   BoxC()

   RETURN LastKey()



STATIC FUNCTION VPSifra2( cSifra, cIme )

   LOCAL lRet := .T.
   LOCAL nObl := Select()

   IF Empty( cSifra )
      Beep ( 3 )
      RETURN ( .F. )
   ENDIF

   RETURN lRet




FUNCTION PomMenu1( aNiz )

   LOCAL xP := Row()
   LOCAL yP := Col()
   LOCAL xN
   LOCAL yN
   LOCAL dP := Len( aNiz ) + 1
   LOCAL sP := 0

   AEval( aNiz, {| x| IF( Len( x[ 1 ] + x[ 2 ] ) > sP, sP := Len( x[ 1 ] + x[ 2 ] ), ) } )
   sP += 3
   xN := IF( xP > 11, xP - dP, xP + 1 )
   yN := IF( yP > 39, yP - sP, yP + 1 )
   box_crno_na_zuto( xN, yN, xN + dP, yN + sP - 1, "POMOC" )

   FOR i := 1 TO dP - 1
      @ xN + i, yN + 1 SAY PadR( aNiz[ i, 1 ] + "-" + aNiz[ i, 2 ], sP - 2 )
   NEXT

   @ xP, yP SAY ""

   RETURN




FUNCTION P_Barkod( cBK )

   LOCAL fRet := .F.
   LOCAL nRec := RecNo()

   PushWA()
   SET ORDER TO TAG "BARKOD"
   SEEK cBK
   IF !Empty( cBK ) .AND. Found() .AND. nRec <> RecNo()
      MsgBeep( "Isti barkod pridruzen je sifri: " + id + " ??!" )
      PopWa()
      RETURN .F.
   ENDIF

   // trazi alternativne sifre
   IF !Empty( cBK )
      cID := ""
      ImaUSifV( "ROBA", "BARK", cBK, @cId )
      IF !Empty( cID )
         SELECT roba
         SET ORDER TO TAG "ID"
         SEEK cId  // nasao sam sifru !!
         MsgBeep( "Isti barkod pridruzen je sifri: " + id + " ??!" )
         PopWa()
         RETURN .F.
      ENDIF
   ENDIF

   PopWa()

   RETURN .T.
