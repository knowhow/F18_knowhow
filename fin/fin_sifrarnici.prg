/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"



/* P_KontoFin(cId,dx,dy,lBlag)
 *     Otvara sifrarnik konta spec. za FIN
 *   param: cId
 *   param: dx
 *   param: dy
 *   param: lBlag
 */
FUNCTION P_KontoFin( cId, dx, dy, lBlag )

   LOCAL i
   LOCAL _t_area := Select()
   PRIVATE ImeKol := {}
   PRIVATE Kol := {}

   O_KONTO

   ImeKol := { { PadR( "ID", 7 ),  {|| id },     "id", {|| .T. }, {|| vpsifra( wid ) } }, ;
      { "Naziv",       {|| naz },     "naz"      };
      }

   IF KONTO->( FieldPos( "POZBILS" ) ) <> 0
      AAdd ( ImeKol, { PadR( "Poz.u bil.st.", 20 ), {|| pozbils }, "pozbils" } )
   ENDIF
   IF KONTO->( FieldPos( "POZBILU" ) ) <> 0
      AAdd ( ImeKol, { PadR( "Poz.u bil.usp.", 20 ), {|| pozbilu }, "pozbilu" } )
   ENDIF
   IF KONTO->( FieldPos( "OZNAKA" ) ) <> 0
      AAdd ( ImeKol, { PadR( "Oznaka", 20 ), {|| oznaka }, "oznaka" } )
   ENDIF

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   IF lBlag == NIL
      lBlag := .F.
   ENDIF

   SELECT konto
   sifk_fill_ImeKol( "KONTO", @ImeKol, @Kol )

   IF lBlag .AND. !Left( cId, 1 ) $ "0123456789"
      SELECT KONTO
      // ukini zaostali filter
      SET FILTER TO
      // postavi filter za zadanu vrijednost karakteristike BLOP
      cFilter := "DaUSifV('KONTO','BLOP',ID," + dbf_quote( Trim( cId ) ) + ")"
      SET FILTER TO &cFilter
      GO TOP
      cId := Space( Len( cId ) )
   ENDIF

   SELECT KONTO
   SET ORDER TO TAG "ID"

   PostojiSifra( F_KONTO, 1, MAXROWS() - 17, MAXCOLS() - 10, "LKTF Lista: Konta ", @cId, dx, dy, {| Ch| KontoBlok( Ch ) },,,,, { "ID" } )

   SELECT ( _t_area )

   RETURN .T.




/* KontoBlok(Ch)
 *     Obradjuje funkcije nad sifrarnikom konta
 *   param: Ch  - pritisnuti taster
 */

FUNCTION KontoBlok( Ch )

   LOCAL nRec := RecNo(), cId := ""
   LOCAL cSif := KONTO->id, cSif2 := ""

   // @ m_x+11,45 SAY "<a-P> - stampa k.plana"

   IF Ch == K_CTRL_T .AND. gSKSif == "D"

      // provjerimo da li je sifra dupla
      PushWA()
      SET ORDER TO TAG "ID"
      SEEK cSif
      SKIP 1
      cSif2 := KONTO->id
      PopWA()
      IF !( cSif == cSif2 )
         IF is_konto_ima_u_prometu( KONTO->id )
            Beep( 1 )
            Msg( "Stavka konta se ne moze brisati jer se vec nalazi u knjizenjima!" )
            RETURN 7
         ENDIF
      ENDIF
   ELSEIF Ch == K_F2 .AND. gSKSif == "D"
      IF is_konto_ima_u_prometu( KONTO->id )
         RETURN 99
      ENDIF
   ENDIF

   IF Ch <> K_ALT_P
      RETURN DE_CONT
   ENDIF

   PRIVATE cKonto := Space( 60 )
   PRIVATE cSirIs := "0", cOdvKlas := "N", cOstran := "D"

   DO WHILE .T.
      IF !VarEdit( { { "Konto (prazno-sva)", "cKonto",, "@!S30", }, ;
            { "Sirina ispisa (0 - 10CPI, 1 - 12CPI, 2 - 17CPI, 3 - 20CPI)", "cSirIs", "cSirIs$'0123'",, }, ;
            { "Odvajati klase novom stranicom (D - da, N - ne) ?", "cOdvKlas", "cOdvKlas$'DN'", "@!", }, ;
            { "Ukljuceno ostranicavanje ? (D - da, N - ne) ?", "cOstran", "cOstran$'DN'", "@!", } }, ;
            10, 3, 17, 76, ;
            'POSTAVLJANJE USLOVA ZA PRIKAZ KONTA', ;
            "B1" )
         RETURN DE_CONT
      ENDIF
      aUsl1 := Parsiraj( cKonto, "id" )
      IF aUsl1 <> NIL
         EXIT
      ELSE
         MsgBeep ( "Kriterij za konto nije korektno postavljen!" )
      ENDIF
   ENDDO


   SET FILTER TO &aUsl1


   IF !start_print()
      RETURN .F.
   ENDIF

   ?
   B_ON
   ? "K O N T N I    P L A N"
   ? "----------------------"
   B_OFF
   ?

   IF cSirIs == "1"
      F12CPI
   ELSEIF cSirIs == "2"
      P_COND
   ELSEIF cSirIs == "3"
      P_COND2
   ENDIF

   GO TOP
   DO WHILE ! Eof()
      cId := RTrim( id )

      ? Space( IF( Len( cId ) > 3, 6, IF( Len( cId ) == 3, 3, Len( cId ) -1 ) ) )
      ?? PadR( cId, 15 -PCol(), "." )
      ?? naz
      SKIP 1
      IF cOdvKlas == "D" .AND. Left( cId, 1 ) != Left( id, 1 ) .OR. cOstran == "D" .AND. PRow() > 60 + dodatni_redovi_po_stranici()
         FF
         LOOP
      ENDIF
      IF Len( cId ) > 3 .AND. Len( RTrim( id ) ) < 4 .OR. Len( cId ) == Len( RTrim( id ) ) .AND. Len( cId ) < 4 .OR. Left( cId, 3 ) != Left( id, 3 )
         ?
      ENDIF
   ENDDO

   FF
   end_print()

   SET FILTER TO

   GO nRec

   RETURN DE_CONT




/* P_PKonto(cId,dx,dy)
 *     Otvara sifrarnik prenosa konta u novu godinu
 *   param: cId
 *   param: dx
 *   param: dy
 */

FUNCTION P_PKonto( CId, dx, dy )

   PRIVATE ImeKol, Kol

   ImeKol := { { "ID  ",  {|| id },   "id", {|| .T. }, {|| vpsifra( wid ) }    }, ;
      { PadC( "Tip prenosa", 25 ), {|| PadC( TipPkonto( tip ), 25 ) },     "tip", {|| .T. }, {|| wtip $ "123456" }     };
      }
   Kol := { 1, 2 }

   RETURN p_sifra( F_PKONTO, 1, 10, 60, "MatPod: Način prenosa konta u novu godinu", @cId, dx, dy )



/* TipPKonto(cTip)
 *     Tip prenosa konta u novu godinu
 *   param: cTip
 */

FUNCTION TipPKonto( cTip )

   IF cTip = "2"
      RETURN "po saldu partnera"
   ELSEIF cTip = "1"
      RETURN "po otvorenim stavkama"
   ELSEIF cTip = "3"
      RETURN "otv.st. bez sabiranja"
   ELSEIF cTip = "4"
      RETURN "po rj,funk,fond"
   ELSEIF cTip = "5"
      RETURN "po rj,fond"
   ELSEIF cTip = "6"
      RETURN "po rj"
   ELSE
      RETURN "??????????????"
   ENDIF


/* P_Funk(cId,dx,dy)
 *     Otvara sifranik funkcionalnih klasifikacija
 *   param: cId
 *   param: dx
 *   param: dy
 */

FUNCTION P_Funk( cId, dx, dy )

   PRIVATE imekol, kol

   ImeKol := { { PadR( "Id", 5 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } }, ;
      { PadR( "Naziv", 50 ), {||  naz }, "naz" } ;
      }
   Kol := { 1, 2 }

   RETURN PostojiSifra( F_FUNK, 1, 10, 70, "Lista funkcionalne klasifikacije", @cId, dx, dy )


// -------------------------------------------
// kamatne stope
// -------------------------------------------
FUNCTION P_KS( cId, dx, dy )

   LOCAL _i
   PRIVATE imekol := {}
   PRIVATE kol := {}

   O_KS

   AAdd( imekol, { PadR( "ID", 3 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } } )
   AAdd( imekol, { PadR( "Tip", 3 ), {|| PadC( tip, 3 ) }, "tip" } )
   AAdd( imekol, { PadR( "DatOd", 8 ), {|| datod }, "datod" } )
   AAdd( imekol, { PadR( "DatDo", 8 ), {|| datdo }, "datdo" } )
   AAdd( imekol, { PadR( "Rev", 6 ), {|| strev }, "strev" } )
   AAdd( imekol, { PadR( "Kam", 6 ), {|| stkam }, "stkam" } )
   AAdd( imekol, { PadR( "DENOM", 15 ), {|| den }, "den" } )
   AAdd( imekol, { PadR( "Duz.", 4 ), {|| duz }, "duz" } )

   FOR _i := 1 TO Len( imekol )
      AAdd( kol, _i )
   NEXT

   RETURN p_sifra( F_KS, 1, MAXROWS() -10, MAXCOLS() -5, "Lista kamatni stopa", @cId, dx, dy )




/* P_Fond(cId,dx,dy)
 *     Otvara sifrarnik fondova
 *   param: cId
 *   param: dx
 *   param: dy
 */

FUNCTION P_Fond( cId, dx, dy )

   PRIVATE imekol, kol

   ImeKol := { { PadR( "Id", 3 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } }, ;
      { PadR( "Naziv", 50 ), {||  naz }, "naz" } ;
      }
   Kol := { 1, 2 }

   RETURN PostojiSifra( F_FOND, 1, 10, 70, "Lista: Fondovi", @cId, dx, dy )



/* P_BuIz(cId,dx,dy)
 *     Otvara sifrarnik konta-izuzetci
 *   param: cId
 *   param: dx
 *   param: dy
 */

FUNCTION P_BuIz( cId, dx, dy )

   PRIVATE imekol, kol

   ImeKol := { { PadR( "Konto", 10 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wid ) } }, ;
      { PadR( "pretvori u", 10 ), {||  naz }, "naz" } ;
      }
   Kol := { 1, 2 }

   RETURN PostojiSifra( F_BUIZ, 1, 10, 70, "Lista: konta-izuzeci u sortiranju", @cId, dx, dy )



/* P_Budzet(cId,dx,dy)
 *     Otvara sifrarnik plana budzeta
 *   param: cId
 *   param: dx
 *   param: dy
 */

FUNCTION P_Budzet( cId, dx, dy )

   PRIVATE imekol, kol

   ImeKol := { { "Glava",   {|| idrj }, "idrj",, {|| Empty( wIdRj ) .OR. P_RJ ( @wIdRj ) } }, ;
      { "Konto",   {|| Idkonto }, "Idkonto",, {|| gMeniSif := .F., P_KontoFin ( @wIdkonto ), gMeniSif := .T., .T. } }, ;
      { "Iznos",   {|| Iznos }, "iznos" }, ;
      { "Rebalans", {|| rebiznos }, "rebiznos" }, ;
      { "Fond",   {|| Fond }, "fond", {|| gMeniSif := .F., wfond $ "N1 #N2 #N3 " .OR. Empty( wFond ) .OR. P_FOND( @wFond ), gMeniSif := .T., .T. }  }, ;
      { "Funk",   {|| Funk }, "funk", {|| gMeniSif := .F., Empty( wFunk ) .OR. P_funk( @wFunk ), gMeniSif := .T., .T. } };
      }
   Kol := { 1, 2, 3, 4, 5, 6 }

   RETURN PostojiSifra( F_BUDZET, 1, 10, 55, "Plan budzeta za tekucu godinu", @cId, dx, dy )




/* P_ParEK(cId,dx,dy)
 *     Otvara sifrarnik ekonomskih kategorija
 *   param: cId
 *   param: dx
 *   param: dy
 */

FUNCTION P_ParEK( cId, dx, dy )

   PRIVATE imekol, kol

   ImeKol := { { "Partija", {|| IdPartija }, "idpartija",, {|| vpsifra ( wIdPartija ) } }, ;
      { "Konto", {|| IdKonto }, "Idkonto",, {|| gMeniSif := .F., P_KontoFin ( @wIdKonto ), gMeniSif := .T., .T. } };
      }
   Kol := { 1, 2 }

   RETURN PostojiSifra( F_PAREK, 1, 10, 55, "Partije->Konta", @cId, dx, dy )





/* 
 *     Otvara sifrarnik shema kontiranja obracuna LD
 *   param: cId
 *   param: dx
 *   param: dy
 */

FUNCTION P_TRFP3( cId, dx, dy )

   PRIVATE imekol, kol

   ImeKol := {  { PadC( "Shema", 5 ),    {|| PadC( shema, 5 ) },      "shema"     }, ;
      { PadC( "Formula/ID", 10 ),    {|| id },      "id"            }, ;
      { PadC( "Naziv", 20 ), {|| naz },     "naz"                   }, ;
      { "Konto  ", {|| idkonto },        "Idkonto", {|| .T. }, {|| ( "?" $ widkonto ) .OR. ( "A" $ widkonto ) .OR. ( "B" $ widkonto ) .OR. ( "IDKONT" $ widkonto ) .OR.  P_kontoFin( @wIdkonto ) }   }, ;
      { "D/P",   {|| PadC( D_P, 3 ) },      "D_P"                   }, ;
      { "Znak",    {|| PadC( Znak, 4 ) },        "ZNAK"                  }, ;
      { "IDVN",    {|| PadC( idvn, 4 ) },        "idvn"                  };
      }
   Kol := { 1, 2, 3, 4, 5, 6, 7 }

   PRIVATE cShema := " "

   IF Pitanje(, "Želite li postaviti filter za odredjenu shemu", "N" ) == "D"
      Box(, 1, 60 )
      @ m_x + 1, m_y + 2 SAY "Odabir sheme:" GET cShema  PICT "@!"
      READ
      Boxc()
      SELECT trfp3
      cFiltTRFP3 := "shema=" + dbf_quote( cShema )
      SET FILTER TO &cFiltTRFP3
      GO TOP
   ELSE
      SELECT trfp3
      SET FILTER TO
   ENDIF

   RETURN PostojiSifra( F_TRFP3, 1, 15, 76, "Sheme kontiranja obracuna LD", @cId, dx, dy )





FUNCTION is_konto_ima_u_prometu( cKonto )

   LOCAL cSql := "select count(*) as cnt from fmk.fin_anal where idkonto=" + sql_quote( cKonto )
   LOCAL lRet

   PushWa()

   SELECT 0
   use_sql( "DATASET", cSql )
   lRet := ( dataset->cnt > 0 )
   USE

   PopWA()

   RETURN  lRet


FUNCTION P_Roba_fin( CId, dx, dy )

   LOCAL cPrikazi

   RETURN .T.


/* P_ULimit(cId,dx,dy)
 *     Otvara sifrarnik limita po ugovorima
 *   param: cId
 *   param: dx
 *   param: dy
 */

FUNCTION P_ULIMIT( cId, dx, dy )

   PRIVATE ImeKol, Kol := {}

   ImeKol := { { "ID ", {|| id       }, "id", {|| .T. }, {|| vpsifra( wId ) },, "999" }, ;
      { "ID partnera", {|| idpartner }, "idpartner", {|| .T. }, {|| p_partner( @wIdPartner ) } }, ;
      { "Limit", {|| f_limit    }, "f_limit"      };
      }
   FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT

   RETURN PostojiSifra( F_ULIMIT, 1, 10, 55, "Sifrarnik limita po ugovorima", @cid, dx, dy )
