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



STATIC FUNCTION _o_virm_edit()

   O_SIFK
   O_SIFV
   O_JPRIH
   O_BANKE
   O_VRPRIM
   O_PARTN
   O_VIRM_PRIPR

   RETURN .T.



FUNCTION unos_virmana()

   _o_virm_edit()

   ImeKol := {}
   Kol := {}

   AAdd( ImeKol, { "R.br.", {|| _st_ + Str( rbr, 3 ) } } )
   AAdd( ImeKol, { _u( "Pošaljioc" ), {|| ko_zr },   "ko_zr" } )
   AAdd( ImeKol, { "Primalac", {|| kome_zr }, "kome_zr" } )
   AAdd( ImeKol, { "Primalac", {|| Left( kome_txt, 30 ) } } )
   AAdd( ImeKol, { "Iznos", {|| Iznos }, "Iznos" } )
   AAdd( ImeKol, { "Dat.Upl", {|| dat_upl }, "dat_upl" } )
   AAdd( ImeKol, { "POd", {|| POd }, "POd" } )
   AAdd( ImeKol, { "PDo", {|| PDo }, "PDo" } )
   AAdd( ImeKol, { "PNABR", {|| PNABR }, "PNABR" } )
   AAdd( ImeKol, { "Hitno", {|| Hitno }, "Hitno" } )
   AAdd( ImeKol, { "IdJPrih", {|| IdJprih }, "IdJPrih" } )
   AAdd( ImeKol, { "VUPl", {|| VUPl }, "VUPl" } )
   AAdd( ImeKol, { "IdOps", {|| IdOps }, "IdOps" } )
   AAdd( ImeKol, { PadR( "Pos.opis", 30 ), {|| ko_txt }, "ko_txt" } )
   AAdd( ImeKol, { PadR( "Prim.opis", 30 ), {|| kome_txt }, "kome_txt" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   @ 12, 0 SAY ""

   my_db_edit( "PripVir", MAXROWS() - 10, MAXCOLS() - 12, {|| _k_handler() }, "", "Priprema virmana", ;
      .F., { "<c-N>   Nova uplatnica", "<c-T>   Brisi ", ;
      "<Enter> Ispravi uplatnicu", "<c-F9>  Brisi sve", ;
      "<c-P>   Stampanje", ;
      "<a-P>   Rekapitulacija" }, 2,,, )

   my_close_all_dbf()

   RETURN


STATIC FUNCTION _k_handler()

   LOCAL nRec := RecNo()

   IF ( Ch == K_CTRL_T .OR. Ch == K_ENTER ) .AND. reccount2() == 0
      RETURN DE_CONT
   ENDIF

   SELECT virm_pripr

   DO CASE

   CASE Ch == K_ALT_P
      // rekapitulacija uplata
      _rekapitulacija_uplata()
      GO ( nRec )
      RETURN DE_CONT

   CASE Ch == K_ALT_M
      cDN := " "
      Box(, 2, 70 )
      @ m_x + 1, m_y + 2 SAY "Zelite sve stavke oznaciti odstampane/neodstampane ( /*) ?" ;
         GET  cDN VALID cdn $ " *" PICT "@!"
      READ
      BoxC()
      SELECT virm_pripr
      GO TOP
      DO WHILE !Eof()
         REPLACE _ST_ WITH cDN
         SKIP
      ENDDO
      GO TOP
      RETURN DE_REFRESH

   CASE Chr( Ch ) $ "eE"

      virm_export_banke()

      RETURN DE_CONT

   CASE Ch == Asc( " " )
      // ako je _ST_ = " " onda stavku treba odstampati
      // _ST_ = "*" onda stavku ne treba stampati
      my_rlock()
      IF field->_ST_ =  "*"
         REPLACE _st_ WITH  " "
      ELSE
         REPLACE _st_ WITH "*"
      ENDIF
      my_unlock()
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_T
      RETURN browse_brisi_stavku()

   CASE Ch == K_CTRL_P
      stampa_virmana_drb()
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_A
      PushWA()
      SELECT virm_pripr
      // go top
      Box( "c_A", 20, 75, .F., "Ispravka stavki" )
      nDug := 0; nPot := 0
      DO WHILE !Eof()
         skip; nTR2 := RecNo(); SKIP - 1
         Scatter()
         @ m_x + 1, m_y + 1 CLEAR TO m_x + 19, m_y + 74
         IF _virm_edit_pripr( .F. ) == 0
            EXIT
         ELSE
            // BrisiPBaze()
         ENDIF
         SELECT virm_pripr
         my_rlock()
         Gather()
         my_unlock()
         GO nTR2
      ENDDO
      PopWA()
      BoxC()
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_N

      // nove stavke

      nDug := 0
      nPot := 0
      nPrvi := 0

      GO BOTTOM

      Box( "c-N", MAXROWS() - 11, MAXCOLS() - 5, .F., "Unos novih stavki" )

      DO WHILE .T.

         Scatter()
         _rbr := _rbr + 1
         @ m_x + 1, m_y + 1 CLEAR TO m_x + ( MAXROWS() - 12 ), m_y + ( MAXCOLS() - 5 )
         IF _virm_edit_pripr( .T. ) == 0
            EXIT
         ENDIF
         Inkey( 10 )
         SELECT virm_pripr
         APPEND BLANK
         my_rlock()
         Gather()
         my_unlock()
      ENDDO

      BoxC()
      RETURN DE_REFRESH

   CASE Ch == K_ENTER

      Box( "ent", MAXROWS() - 11, MAXCOLS() - 5, .F. )
      Scatter()
      IF _virm_edit_pripr( .F. ) == 0
         BoxC()
         RETURN DE_CONT
      ELSE
         my_rlock()
         Gather()
         my_unlock()
         BoxC()
         RETURN DE_REFRESH
      ENDIF

   CASE Ch = K_CTRL_F9
      RETURN browse_brisi_pripremu()

   ENDCASE

   RETURN DE_CONT



STATIC FUNCTION _virm_edit_pripr( fNovi )

   LOCAL _firma := PadR( fetch_metric( "virm_org_id", nil, "" ), 6 )

   SET CURSOR ON

   @ m_x + 1, m_y + 2 SAY "Svrha placanja :" GET _svrha_pl PICT "@!" VALID P_Vrprim( @_svrha_pl )

   READ

   ESC_RETURN 0

   IF fNovi
      IF Empty( gDatum )
         IF gIDU == "D"
            _dat_upl := Date()  // gdatum
         ELSE
            _dat_upl := gdatum
         ENDIF
      ELSE
         _dat_upl := gdatum
      ENDIF
      _mjesto := gmjesto
      _svrha_doz := PadR( vrprim->pom_txt, Len( _svrha_doz ) )
   ENDIF

   @ m_x + 2, m_y + Col() + 2 SAY "R.br:" GET _Rbr PICT "999"

   _IdBanka := Left( _ko_zr, 3 )
   @ m_x + 3, m_y + 2 SAY "Posiljaoc (sifra banke):       " GET _IdBanka VALID OdBanku( _firma, @_IdBanka )
   READ
   ESC_RETURN 0
   _ko_zr := _IdBanka

   _IdBanka2 := Left( _kome_zr, 3 )

   SELECT partn
   SEEK _firma

   SELECT virm_pripr
   _ko_txt := Trim( partn->naz ) + ", " + Trim( partn->mjesto ) + ", " + Trim( partn->adresa ) + ", " + Trim( partn->telefon )

   IF vrprim->IdPartner == PadR( "JP", Len( vrprim->idpartner ) )
      _bpo := gOrgJed // ova varijabla je iskoristena za broj poreskog obv.
   ELSE
      IF vrprim->dobav == "D"
         // ako su javni prihodi ovo se zna !
         @ m_x + 5, m_y + 2 SAY "Primaoc (partner/banka):" GET _u_korist VALID P_Firma( @_u_korist )  PICT "@!"
         @ m_x + 5, Col() + 2 GET _IdBanka2 valid {|| OdBanku( _u_korist, @_IdBanka2 ), SetPrimaoc() }
      ELSE
         _kome_txt := vrprim->naz
         _kome_zr := vrprim->racun
         @ m_x + 5, m_y + 2 SAY "Primaoc (partner/banka):" + Trim( _kome_txt )
      ENDIF

   ENDIF


   // na osnovu _IdBanka , _IdBanka2 odrediti racune !!

   @ m_x + 8, m_y + 2 SAY "Svrha doznake:" GET _svrha_doz  PICT "@S30"

   @ m_x + 10, m_y + 2 SAY "Mjesto" GET _mjesto  PICT "@S20"
   @ m_x + 10, Col() + 2 SAY "Datum uplate :" GET _dat_upl


   @ m_x + 8, m_y + 50 SAY "Iznos" GET _iznos PICT "99999999.99"
   @ m_x + 8, m_y + Col() + 1 SAY "Hitno" GET _hitno PICT "@!" VALID _hitno $ " X"

   READ

   ESC_RETURN 0

   _IznosSTR := ""
   _IznosSTR := "=" + IF( _iznos == 0 .AND. gINulu == "N", Space( 6 ), AllTrim( StrTran( Str( _iznos ), ".", "," ) ) )


   IF vrprim->Idpartner = "JP"

      // javni prihod

      _vupl := "0"

      // setovanje varijabli: _kome_zr , _kome_txt, _budzorg
      // pretpostavke: kursor VRPRIM-> podesen na tekuce primanje
      SetJPVar()

      _kome_txt := vrprim->naz

      @ m_x + 5, m_y + 2 SAY "Primaoc (partner/banka):" + Trim( _kome_txt )

      IF fnovi

         IF Len( _IdJPrih ) < 6
            MsgBeep( "Sifra prihoda mora biti 6 cifara ?" )
            _IdJPrih := PadR( _IdJPrih, 6 )
         ENDIF
      ENDIF

      @ m_x + 13, m_y + 20 SAY Replicate( "-", 56 )

      @ m_x + 14, m_y + 20 SAY "Broj por.obveznika" GET _bpo
      @ m_x + 14, Col() + 2 SAY "V.uplate " GET _VUpl

      @ m_x + 15, m_y + 20 SAY "Vrsta prihoda     " GET _IdJPrih
      @ m_x + 17, m_y + 20 SAY "      Opcina      " GET _IdOps
      @ m_x + 15, m_y + 60 SAY "Od:" GET _POd
      @ m_x + 16, m_y + 60 SAY "Do:" GET _PDo
      @ m_x + 17, m_y + 55 SAY "Budz.org" GET _BudzOrg
      @ m_x + 18, m_y + 20 SAY "Poziv na broj:    " GET _PNaBr

      READ

      ESC_RETURN 0

   ELSE

      @ m_x + 13,  m_y + 20 SAY Replicate( "", 56 )

      _BPO := Space( Len( _BPO ) )
      _IdOps := Space( Len( _IdOps ) )
      _IdJPrih := Space( Len( _IdJPrih ) )
      _BudzOrg := Space( Len( _BudzOrg ) )
      _PNabr := Space( Len( _PNaBr ) )
      _IdOps := Space( Len( _IdOps ) )
      _POd := CToD( "" )
      _PDo := CToD( "" )
      _VUPL = ""

   ENDIF

   RETURN 1



FUNCTION SetPrimaoc()

   _kome_zr := _idbanka2

   SELECT partn
   SEEK _u_korist

   // --- Uslov za ispis adrese u polju primaoca (MUP ZE-DO)
   IF my_get_from_ini( "Primaoc", "UnosAdrese", "N", KUMPATH ) == "D"
      _kome_txt := AllTrim( naz ) + ", " + AllTrim( mjesto ) + ", " + AllTrim( adresa )
   ELSE
      _kome_txt := AllTrim( naz ) + ", " + AllTrim( mjesto )
   ENDIF

   SELECT virm_pripr

   RETURN .T.



FUNCTION UplDob()

   // {
   LOCAL lVrati := .F.
   SELECT VRPRIM
   GO TOP
   HSEEK _svrha_pl
   IF dobav == "D"; lVrati := .T. ; ENDIF
   SELECT virm_pripr

   RETURN lVrati
// }



FUNCTION IniProm()        // autom.popunjavanje nekih podataka

   // {
   SELECT VRPRIM
   IF dobav == "D"
      IF Empty( _nacpl ) .AND. Empty( _iznos ) .AND. Empty( _svrha_doz )
         _svrha_doz := PadR( pom_txt, Len( _svrha_doz ) )
         _nacpl := nacin_pl
      ENDIF
      SELECT PARTN
      HSEEK _u_korist

      _kome_txt := Trim( naz ) + mjesto
      // _kome_zr := ODBanku(_u_korist,_kome_zr)

   ELSE
      _u_korist := Space( Len( _u_korist ) )
      IF Empty( _nacpl ) .AND. Empty( _iznos ) .AND. Empty( _svrha_doz )

         _svrha_doz := PadR( pom_txt, Len( _svrha_doz ) )
         _kome_txt := naz
         // _nacpl:=nacin_pl
         // _kome_sj:=SPACE(LEN(_kome_sj))

      ENDIF
   ENDIF
   SELECT virm_pripr

   RETURN .T.
// }


FUNCTION ValPl()

   // {
   LOCAL lVrati := .F.

   IF _nacpl $ "12"
      lVrati := .T.
      IF Empty( _u_korist )
         _kome_zr := VRPRIM->racun
      ELSE
         _kome_zr := IF( _nacpl == "1", PARTN->ziror, PARTN->dziror )
      ENDIF
   ENDIF

   RETURN lVrati



// ------------------------------------------
// stampa virmana delphirb
// ------------------------------------------
FUNCTION stampa_virmana_drb()

   LOCAL _br_virmana := 999
   LOCAL _marker := "N"
   LOCAL _i
   LOCAL _konverzija := fetch_metric( "virm_konverzija_delphirb", nil, "5" )

   BEGIN SEQUENCE
      O_IZLAZ
      my_dbf_zap()

   RECOVER
      MsgBeep( "Vec je aktiviran delphirb ?" )
      RETURN
   END SEQUENCE


   Box(, 2, 70 )
   @ m_x + 1, m_y + 2 SAY "Broj virmana od sljedece pozicije:" GET _br_virmana PICT "999"
   @ m_x + 2, m_y + 2 SAY "Uzeti u obzir markere            :" GET _marker PICT "@!" VALID _marker $ "DN"
   READ
   BoxC()

   _i := 1

   SELECT virm_pripr
   SET ORDER TO TAG "1"

   IF _marker = "D"
      GO TOP
   ENDIF

   my_flock()

   DO WHILE !Eof()

      Scatter()

      IF _marker = "D" .AND. _st_ = "*"
         SKIP
         LOOP
      ELSE
         REPLACE _st_ WITH "*"
      ENDIF

      SELECT izlaz
      APPEND BLANK

      KonvZnWin( @_ko_txt, _konverzija )
      KonvZnWin( @_kome_txt, _konverzija )
      KonvZnWin( @_svrha_doz, _konverzija )
      KonvZnWin( @_mjesto, _konverzija )

      _ko_zr    = Razrijedi( _ko_zr )       // z.racun posiljaoca
      _kome_zr  = Razrijedi( _kome_zr )     // z.racun primaoca
      _bpo      = Razrijedi( _bpo )         // broj poreznog obveznika
      _idjprih  = Razrijedi( _idjprih )     // javni prihod
      _idops    = Razrijedi( _idops )       // opstina
      _pnabr    = Razrijedi( _pnabr )       // poziv na broj
      _budzorg  = Razrijedi( _budzorg )     // budzetska organizacija
      _pod      = Razrijedi( DToC( _pod ) )         // porezni period od
      _pdo      = Razrijedi( DToC( _pdo ) )         // porezni period do
      _dat_upl  = Razrijedi( DToC( _dat_upl ) )     // datum uplate

      Gather()

      SELECT virm_pripr
      SKIP

      IF _i >= _br_virmana
         EXIT
      ENDIF
      _i ++

   ENDDO

   IF Eof()
      SKIP -1
   ENDIF

   my_unlock()

   // pokreni stampu delphi rb-a
   _stampaj_virman()

   RETURN .T.


// ----------------------------------------------------
// stampaj virman
// ----------------------------------------------------
STATIC FUNCTION _stampaj_virman()

   LOCAL _t_rec
   LOCAL _rtm_file := "nalplac"

   SELECT virm_pripr
   _t_rec := RecNo()

   USE

   SELECT izlaz
   USE

   my_close_all_dbf()

   // ovdje treba kod za filovanje datoteke IZLAZ.DBF
   IF LastKey() != K_ESC
      f18_rtm_print( _rtm_file, "izlaz", "1" )
   ENDIF

   _o_virm_edit()
   SELECT virm_pripr
   GO ( _t_rec )

   RETURN



FUNCTION OdBanku( cIdPartn, cDefault, fsilent )

   // Odaberi banku
   LOCAL nX, nY
   LOCAL Izbor, nTIzbor
   PRIVATE aBanke
   PRIVATE GetList := {}

   IF fsilent = NIL
      fsilent := .T.
   ENDIF

   nX := m_x
   nY := m_y

   IF cDefault = NIL
      cDefault := "??FFFX"
   ENDIF

   aBanke := array_from_sifv( "PARTN", "BANK", cIdPartn )

   PushWA()

   SELECT banke

   nTIzbor := 1

   FOR i := 1 TO Len( aBanke )

      IF Left( aBanke[ i ], Len( cDefault ) ) = cDefault
         nTIzbor := i
         IF fSilent
            cDefault := Left( aBanke[ nTIzbor ], 16 )
            PopWA()
            RETURN .T.
         ENDIF
      ENDIF

      SEEK ( Left( aBanke[ i ], 3 ) )

      aBanke[ i ] := PadR( Trim( aBanke[ i ] ) + ":" + PadR( naz, 20 ), 50 )

   NEXT

   PopWa()

   SELECT virm_pripr

   izbor := nTIzbor

   IF Len( aBanke ) > 1
      // ako ima vise banaka...
      IF !fSilent
         MsgBeep( "Partner " + cIdPartn + " ima racune kod vise banaka, odaberite banku." )
      ENDIF

      PRIVATE h[ Len( aBanke ) ]

      AFill( h, "" )

      DO WHILE .T.

         izbor := meni_0( "ab-1", aBanke, izbor, .F., "1" )

         IF izbor = 0
            EXIT
         ELSE
            nTIzbor := izbor
            izbor := 0
         ENDIF

      ENDDO

      izbor := nTIzbor

      m_x := nX
      m_y := nY

   ELSEIF Len( aBanke ) == 1

      // ako je jedna banka...

      cDefault := Left( aBanke[ izbor ], 16 )
      RETURN .T.

   ELSE

      // potrazi ga u partn->ziror

      cDefault := ""
      SELECT partn
      HSEEK cIdpartn

      cDefault := partn->ziror

      IF !Empty( cDefault )
         RETURN .T.
      ELSE
         MsgBeep( "Nema unesena nitijedna banka za partnera " + cIdPartn )
         cDefault := ""
         RETURN .T.
      ENDIF

   ENDIF

   cDefault := Left( aBanke[ izbor ], 16 )

   RETURN .T.




// ----------------------------------------------------
// po izlasku iz ove funkcije kursor
// jprih.dbf-a treba biti pozicioniran
// na trazeni javni prihod
// ----------------------------------------------------
FUNCTION JPrih( cIdJPrih, cIdOps, cIdKan, cIdEnt )

   LOCAL fOk := .F.

   IF cIdOps == NIL
      cIdOps := ""
   ENDIF

   IF cIdKan == NIL
      cIdkan := ""
   ENDIF

   IF cIdEnt == NIL
      cIdEnt := ""
   ENDIF

   PushWA()

   // 1 - racun 2 - naziv 3 - budzorg
   aRez := { "", "", "" }

   SELECT jprih
   cPom := cIdJPrih

   FOR i := Len( cIdJPrih ) TO 1 STEP -1

      cPom := Left( cIdJPrih, i )
      SEEK cPom

      IF Found() .AND. Len( cPom ) == Len( cIdJPrih )
         // analiticki prihod
         aRez[ 2 ] := naz
      ENDIF

      IF Found()

         DO WHILE !Eof() .AND. Id == PadR( cPom, Len( cIdJPrih ) )

            fOk := .T.

            IF Empty( racun )
               // nema racuna trazi dalje
               fOk := .F.
               SKIP
               LOOP
            ENDIF

            IF !Empty( cIdOps ) .AND. cIdOps != idops
               IF !Empty( idops )
                  fOk := .F.
               ENDIF
            ENDIF

            IF !Empty( cIdKan ) .AND. cIdKan != idkan
               IF !Empty( idkan )
                  fOk := .F.
               ENDIF
            ENDIF

            IF !Empty( cIdEnt ) .AND. cIdEnt != idn0
               IF !Empty( idn0 )
                  fOk := .F.
               ENDIF
            ENDIF

            IF fOk
               IF Empty( aRez[ 2 ] )
                  // nisam jos nasao naziv
                  aRez[ 2 ] := racun
               ENDIF
               aRez[ 1 ] := racun
               aRez[ 3 ] := budzorg
               EXIT
            ENDIF

            SKIP

         ENDDO

         IF fOk
            EXIT
         ENDIF

      ENDIF

   NEXT

   PopWa()

   RETURN aRez



// setovanje varijabli: _kome_zr , _kome_txt, _budzorg
// pretpostavke: kursor VRPRIM-> podesen na tekuce primanje
//
// formula moze biti:
// ------------------------------
// 712221-103
// 712221-1-103

FUNCTION SetJPVar()

   LOCAL _tmp_1 := ""
   LOCAL _tmp_2 := ""
   LOCAL aJPrih

   _idjprih := TOKEN( vrprim->racun, "-", 1 )

   _tmp_1 := TOKEN( vrprim->racun, "-", 2 )
   // <- moze biti opcina, kanton ili entitet ili nista

   _tmp_2 := TOKEN( vrprim->racun, "-", 3 )
   // <- moze se iskoristiti za opcinu

   _tmp_1 := AllTrim( _tmp_1 )
   _tmp_2 := AllTrim( _tmp_2 )

   IF Len( _tmp_1 ) == 3

      _idops := _tmp_1
      aJPrih := JPrih( _idjprih, _idops, "", "" )

      _kome_zr := aJPrih[ 1 ]
      _budzorg :=  aJPrih[ 3 ]

   ELSEIF Len( _tmp_1 ) == 2

      // nivo kantona
      _idops := IF( Len( _tmp_2 ) == 3, _tmp_2, OpcRada() )
      aJPrih := JPrih( _idjprih, "", _tmp_1, "" )
      _kome_zr := aJPrih[ 1 ]
      _budzorg := aJPrih[ 3 ]

   ELSEIF Len( _tmp_1 ) == 1

      // nivo entiteta
      _idops := IF( Len( _tmp_2 ) == 3, _tmp_2, OpcRada() )
      aJPrih := JPrih( _idjprih, "", "", _tmp_1 )
      _kome_zr := aJPrih[ 1 ]
      _budzorg := aJPrih[ 3 ]

   ELSEIF Len( _tmp_1 ) == 0

      // jedinstveni uplatni racun
      _idops := Space( 3 )
      _idjprih := PadR( _idjprih, 6 )
      // duzina sifre javnog prihoda
      aJPrih := JPrih( _idjprih, "", "", _tmp_1 )
      _kome_zr := aJPrih[ 1 ]
      _budzorg :=  aJPrih[ 3 ]

   ENDIF

   RETURN



FUNCTION popuni_javne_prihode()

   // drugi krug; popuni polja vezana za javne prihode ....
   SELECT vrprim
   SET ORDER TO TAG "ID"

   SELECT virm_pripr
   GO TOP

   DO WHILE !Eof()

      SELECT vrprim
      SEEK virm_pripr->svrha_pl

      SELECT virm_pripr
      Scatter()

      IF vrprim->idpartner = "JP"
         // javni prihod
         SetJPVar()
      ENDIF

      _iznosstr := ""
      _iznosstr := "=" + IF( _iznos == 0 .AND. gINulu == "N", Space( 6 ), AllTrim( StrTran( Str( _iznos ), ".", "," ) ) )

      my_rlock()
      Gather()
      my_unlock()

      SKIP

   ENDDO

   RETURN



FUNCTION OpcRada()

   LOCAL cVrati := "   "
   LOCAL cOR := ""
   LOCAL nArr := Select()

   cOR := my_get_from_ini( "VIRM", "OpcRada", "XXXX", KUMPATH )

   IF Empty( cOR )
      RETURN ""
   ENDIF

   SELECT ( F_OPS )

   IF !Used()
      O_OPS
      SEEK cOR
      IF Found()
         cVrati := IDJ
      ENDIF
      USE
   ELSE
      PushWA()
      SET ORDER TO TAG "ID"
      SEEK cOR
      IF Found()
         cVrati := IDJ
      ENDIF
      PopWA()
   ENDIF

   SELECT ( nArr )

   RETURN cVrati



// ----------------------------------------
// rekapitulacija uplata
// ----------------------------------------
STATIC FUNCTION _rekapitulacija_uplata()

   LOCAL _arr := {}

   SELECT virm_pripr

   PushWA()

   START PRINT RET
   ?
   P_COND

   _arr := { ;
      { "PRIMALAC", {|| kome_txt }, .F., "C", 55, 0, 1, 1 }, ;
      { "ŽIRO RACUN", {|| kome_zr }, .F., "C", 16, 0, 1, 2 }, ;
      { "IZNOS      ", {|| iznos }, .T., "N", 15, 2, 1, 3 } ;
      }
   GO TOP

   print_lista_2( _arr, , 2, gTabela, {|| .T. }, "4", "REKAPITULACIJA UPLATA", {|| .T. } )

   ENDPRINT

   O_VIRM_PRIPR

   PopWA()

   RETURN


STATIC FUNCTION FormNum1( nIznos )

   LOCAL cVrati

   cVrati := Transform( nIznos, gpici )
   cVrati := StrTran( cVrati, ".", ":" )
   cVrati := StrTran( cVrati, ",", "." )
   cVrati := StrTran( cVrati, ":", "," )

   RETURN cVrati
