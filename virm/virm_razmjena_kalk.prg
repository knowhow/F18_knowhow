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


FUNCTION virm_prenos_kalk()

   LOCAL _firma := PadR( fetch_metric( "virm_org_id", nil, "" ), 6 )

   gUVarPP := my_get_from_ini( "POREZI", "PPUgostKaoPPU", "T", KUMPATH )
   cPNaBr := my_get_from_ini( "KALKVIRM", "PozivNaBr", " ", KUMPATH )
   cPnabr := PadR( cPnabr, 10 )
   cVUPL := my_get_from_ini( "KALKVIRM", "VrstaUplate", " ", KUMPATH )
   cVUPL := PadR( cVUPL, 1 )
   qqIDVD := "42;"
   dDatOd := Date()
   dDatDo := Date()
   dDatVir := Date()
   O_PARTN
   O_SIFK
   O_SIFV
   O_BANKE
   O_PARAMS
   o_kalk()
   O_TARIFA
   O_JPRIH
   O_KALVIR
   O_VRPRIM
   O_VIRM_PRIPR

   SELECT params
   PRIVATE cSection := "2"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   Rpar( "01", @qqIDVD )
   Rpar( "02", @dDatOd )
   Rpar( "03", @dDatDo )
   Rpar( "04", @dDatVir )
   SET CURSOR ON
   qqIDVD := PadR( qqIDVD, 80 )

   SELECT partn

   DO WHILE .T.
      Box(, 7, 70 )
      @ m_x + 0, m_y + 2 SAY "P R E N O S   I Z   K A L K"
      cKo_zr := Space( 3 )
      cIdBanka := PadR( cko_zr, 3 )
      @ m_x + 2, m_y + 2 SAY "Posiljaoc (sifra banke):       " GET cIdBanka VALID  OdBanku( _firma, @cIdBanka )
      READ
      cKo_zr := cIdBanka
      SELECT partn
      SEEK gVirmFirma
      cKo_txt := Trim( partn->naz ) + ", " + Trim( partn->mjesto ) + ", " + Trim( partn->adresa ) + ", " + Trim( partn->telefon )
      @ m_x + 3, m_y + 2 SAY "Poziv na broj " GET cPNABR
      @ m_x + 3, Col() + 4 SAY "Vrsta uplate " GET cVUPL
      @ m_x + 4, m_y + 2 SAY "Uslov za vrstu dok." GET qqIDVD PICT "@!S20"
      @ m_x + 5, m_y + 2 SAY "Dokum. za period od" GET dDatOd
      @ m_x + 5, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 6, m_y + 2 SAY "Datum virmana      " GET dDatVir
      READ
      ESC_BCR
      IF LastKey() == K_ESC
         RETURN
      ENDIF
      BoxC()
      aUsl1 := Parsiraj( qqIDVD, "IDVD" )
      IF aUsl1 <> nil
         EXIT
      ENDIF
   ENDDO

   UzmiIzIni( KUMPATH + "fmk.ini", "KALKVIRM", "PozivNaBr", cPNaBr, "WRITE" )
   UzmiIzIni( KUMPATH + "fmk.ini", "KALKVIRM", "VrstaUplate", cVUPL, "WRITE" )

   qqIDVD := Trim( qqIDVD )

   SELECT params

   IF LastKey() <> K_ESC
      Wpar( "01", qqIDVD )
      Wpar( "02", dDatOd )
      Wpar( "03", dDatDo )
      Wpar( "04", dDatVir )
      SELECT params; USE
   ENDIF
   USE


   cFilter := aUsl1

   cFilter += ".and. DatDok>=" + dbf_quote( dDatOd ) + ".and. DatDok<=" + dbf_quote( dDatDo )

   // postavljamo filter na vrstu i datum dokumenata u KALK.DBF
   // ---------------------------------------------------------
   SELECT KALK
   SET FILTER TO &cFilter

   // napravimo praznu POM.DBF
   // ------------------------
   CrePom()

   // ubacimo u POM.DBF stavke iz KALVIR.DBF
   // --------------------------------------
   PRIVATE c77, qqRoba, qqKonto, qqIzraz, lSamoPripremi := .T.
   SELECT KALVIR
   GO TOP
   DO WHILE !Eof()
      qqRoba := ".f."; qqKonto := ".f."; qqIzraz := "0"
      SELECT POM
      APPEND BLANK
      c77 := Trim( KALVIR->formula )
      c77 := &c77    // samo da se izvr�i f-ja IzKalk() ako je ima
      REPLACE IDVRPRIM WITH KALVIR->id,;
         ROBA     WITH qqRoba,;
         KONTO    WITH qqKonto,;
         IZRAZ    WITH qqIzraz,;
         PNABR    WITH IF( KALVIR->( FieldPos( "pnabr" ) ) <> 0, KALVIR->pnabr, "" )
      SELECT KALVIR
      SKIP 1
   ENDDO

   lSamoPripremi := .F.

   PRIVATE cRoba, cKonto, cIzraz

   // popunimo POM.DBF iz KALK.DBF
   // ----------------------------
   SELECT KALK
   GO TOP
   DO WHILE !Eof()     // idi po KALK-u
      SELECT TARIFA
      HSEEK KALK->idtarifa
      SELECT POM
      GO TOP
      DO WHILE !Eof()     // idi po POM-u
         cRoba  := ROBA
         cKonto := KONTO
         cIzraz := IZRAZ
         IF KALK->( &cRoba .AND. &cKonto )
            PRIVATE nPRUC := 0
            KALK->( Proracun() )
            REPLACE iznos WITH iznos + KALK->( &cIzraz )
         ENDIF
         SKIP 1
      ENDDO
      SELECT KALK
      SKIP 1
   ENDDO

   // cDOpis   := "OD "+DTOC(dDatOd)+" DO "+DTOC(dDatDo)
   cDOpis := ""

   // sad pravimo PRIPR.DBF od POM.DBF
   // --------------------------------
   SELECT POM
   GO TOP
   DO WHILE !Eof()

      cSvrha_pl := idvrprim
      nFormula  := Round( iznos, 2 )
      SELECT VRPRIM; HSEEK cSvrha_pl
      SELECT PARTN ; HSEEK gVirmFirma

      SELECT virm_pripr
      GO BOTTOM
      nRbr := rbr

      IF nFormula > 0

         APPEND BLANK
         REPLACE rbr with ++nrbr, ;
            mjesto WITH gmjesto, ;
            svrha_pl WITH csvrha_pl, ;
            iznos WITH nFormula,;
            POD WITH dDatOd,;
            PDO WITH dDatDo

         // orgjed with gorgjed,;

         REPLACE na_teret  WITH gVirmFirma, ;
            Ko_Txt WITH cko_txt, ;
            Ko_ZR WITH cKo_zr,;
            kome_txt WITH VRPRIM->naz

         // nacpl with VRPRIM->nacin_pl, ;


         cPomOpis := Trim( VRPRIM->pom_txt ) + IF( !Empty( cDOpis ), " " + cDOpis, "" )

         IF vrprim->idpartner = "JP  " // javni prihodi
            cBPO    := gOrgJed  // iskoristena za broj poreskog obveznika
            IF Empty( POM->pnabr )
               ckPNABR := cPNABR
            ELSE
               ckPNABR := POM->pnabr
            ENDIF
            ckVUPL  := cVUPL
         ELSE
            cBPO    := ""
            ckPNABR := ""
            ckVUPL  := ""
         ENDIF

         REPLACE kome_zr WITH VRPRIM->racun, ;
            dat_upl WITH dDatVir, ;
            svrha_doz WITH cPomOpis, ;
            BPO WITH cBPO, ;
            PnaBR WITH ckPNABR, ;
            VUPL WITH ckVUPL

         // sifra with VRPRIM->sifra
         // dat_dpo with dDatVir,;

         // if nacpl=="2"
         // replace ko_zr with partn->dziror
         // endif

      ENDIF

      SELECT POM
      SKIP 1
   ENDDO


   popuni_javne_prihode()


   CLOSERET


   // --------------------------------------
   // cRoba : uslov za obuhvatanje artikala
   // cKonto: uslov za obuhvatanje konta
   // cIzraz: izraz za utvr�ivanje iznosa
   // cMP   : "M"-magacin ili "P"-prodavnica
   // cRT   : prvi parametar je uslov za "R"-roba , "T" tarifa
   // ----------------------------------------------------------

FUNCTION VirmIzKalk( cRoba, cKonto, cIzraz, cMP, cRT )

   IF cKonto == NIL; cKonto := ".f."; ENDIF
   IF cRoba == NIL; cRoba := ".f."; ENDIF
   IF cMP == NIL; cMP := "P"; ENDIF
   IF cRT == NIL; cRT := "R"; ENDIF
   IF cIzraz == NIL; cIzraz := "MPCSAPP*KOLICINA"; ENDIF
   IF lSamoPripremi
      IF cRoba <> ".f."
         IF cRT == "R"
            qqRoba  := Parsiraj( cRoba, "IDROBA" )
         ELSE
            qqRoba  := Parsiraj( cRoba, "IDTarifa" )
         ENDIF
      ENDIF
      IF cKonto <> ".f."
         qqKonto := Parsiraj( cKonto, cMP + "KONTO" )
      ENDIF
      qqIzraz := cIzraz
   ENDIF

   RETURN 0


STATIC FUNCTION CrePom()

   SELECT ( F_POM )
   USE

   // kreiranje pomocne baze POM.DBF
   // ------------------------------
   cPom := PRIVPATH + "POM"
   IF FErase( PRIVPATH + "POM.DBF" ) == -1
      MsgBeep( "Ne mogu izbrisati POM.DBF!" )

   ENDIF
   IF FErase( PRIVPATH + "POM.CDX" ) == -1
      MsgBeep( "Ne mogu izbrisati POM.CDX!" )

   ENDIF
   // ferase(cPom+".CDX")
   aDbf := {}
   AAdd( aDBf, { 'IDVRPRIM', 'C', Len( VRPRIM->id ),  0 } )
   AAdd( aDBf, { 'ROBA', 'C',150,  0 } )
   AAdd( aDBf, { 'KONTO', 'C',150,  0 } )
   AAdd( aDBf, { 'IZRAZ', 'C',150,  0 } )
   AAdd( aDBf, { 'IZNOS', 'N', 22,  9 } )
   AAdd( aDBf, { 'PNABR', 'C', 10,  0 } )
   DBCREATE2 ( cPom, aDbf )
   my_usex( cPom )
   INDEX ON IDVRPRIM TAG "1"
   SET ORDER TO TAG "1" ; GO TOP

   RETURN .T.

// PPP
FUNC PMP1()
   RETURN ( KOLICINA * KALK->mpc * TARIFA->opp / 100 )

// PPU
FUNC PMP2()
   RETURN ( KOLICINA * KALK->mpc * ( 1 + TARIFA->opp / 100 ) * TARIFA->ppp / 100 )

// PP
FUNC PMP3()
   RETURN ( KOLICINA * KALK->mpc * ( 1 + TARIFA->opp / 100 ) * TARIFA->zpp / 100 )



STATIC FUNCTION PorRUCMP()

   // {
   LOCAL nV := 0
   nV := Round( nPRUC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )

   RETURN nV
// }


STATIC FUNCTION PorPP()

   // {
   LOCAL nV := 0
   IF gUVarPP $ "MT"
      nV := Round( mpcsapp * ( kolicina - gkolicina - gkolicin2 ) * _opp / ( 1 + _opp ), gZaokr )
   ELSE
      nV := Round( _OPP * MPC * ( kolicina - gkolicina - gkolicin2 ), gZaokr )
   ENDIF

   RETURN nV
// }


STATIC FUNCTION PorPU()

   // {
   LOCAL nV := 0
   nV := Round( _PPP * ( 1 + _OPP ) * MPC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )

   RETURN nV
// }


STATIC FUNCTION PorP()

   // {
   LOCAL nV := 0
   nV := Round( _zpp * ( mpcsapp - nPRUC ) * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )

   RETURN nV
// }



STATIC FUNCTION Proracun()

   // {
   LOCAL cIdVd, nPom
   LOCAL lKontPRUCMP

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2
   nFV := FCj * Kolicina
   SKol := Kolicina
   kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()
   set_pdv_public_vars()
   cIdVd := kalk->idvd
   lKontPRUCMP := ( gUVarPP $ "MJRT" )

   IF ( lKontPRUCMP .AND. cIdVd $ "41#42#81" .AND. _mpp <> 0 )
      IF ( gUVarPP $ "T" )
         nPRUC := Max( mpcsapp - nc - PPPMP(), mpcsapp * _dlruc ) * _mpp / ( 1 + _mpp )
      ELSEIF ( gUVarPP $ "R" )
         nPom    := nMarza2
         nPRUC   := Max( mpcsapp * _dlruc, nPom ) * _mpp / ( 1 + _mpp )
         nMarza2 := nPom - nPRUC
      ELSEIF ( gUVarPP $ "MJ" )
         nPRUC := PPUMP()
      ENDIF
   ELSE
      nPRUC := 0
   ENDIF

   RETURN
// }


/* kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()
 *     Proracun iznosa troskova pri unosu u pripremi
 */

STATIC FUNCTION kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()

   // {
   LOCAL Skol := 0, nPPP := 0

   Skol := Kolicina

   nPPP := 1

   IF TPrevoz == "%"
      nPrevoz := Prevoz / 100 * FCj2
   ELSEIF TPrevoz == "A"
      nPrevoz := Prevoz
   ELSEIF TPrevoz == "U"
      IF skol <> 0
         nPrevoz := Prevoz / SKol
      ELSE
         nPrevoz := 0
      ENDIF
   ELSE
      nPrevoz := 0
   ENDIF

   IF TCarDaz == "%"
      nCarDaz := CarDaz / 100 * FCj2
   ELSEIF TCarDaz == "A"
      nCarDaz := CarDaz
   ELSEIF TCarDaz == "U"
      IF skol <> 0
         nCarDaz := CarDaz / SKol
      ELSE
         nCarDaz := 0
      ENDIF
   ELSE
      nCarDaz := 0
   ENDIF

   IF TZavTr == "%"
      nZavTr := ZavTr / 100 * FCj2
   ELSEIF TZavTr == "A"
      nZavTr := ZavTr
   ELSEIF TZavTr == "U"
      IF skol <> 0
         nZavTr := ZavTr / SKol
      ELSE
         nZavTr := 0
      ENDIF
   ELSE
      nZavTr := 0
   ENDIF

   IF TBankTr == "%"
      nBankTr := BankTr / 100 * FCj2
   ELSEIF TBankTr == "A"
      nBankTr := BankTr
   ELSEIF TBankTr == "U"
      IF skol <> 0
         nBankTr := BankTr / SKol
      ELSE
         nBankTr := 0
      ENDIF
   ELSE
      nBankTr := 0
   ENDIF

   IF TSpedTr == "%"
      nSpedTr := SpedTr / 100 * FCj2
   ELSEIF TSpedTr == "A"
      nSpedTr := SpedTr
   ELSEIF TSpedTr == "U"
      IF skol <> 0
         nSpedTr := SpedTr / SKol
      ELSE
         nSpedTr := 0
      ENDIF
   ELSE
      nSpedTr := 0
   ENDIF

   IF IdVD $ "14#94#15"   // izlaz po vp
      nMarza := VPC * nPPP * ( 1 -Rabatv / 100 ) -NC
   ELSEIF idvd == "24"  // usluge
      nMarza := marza
   ELSEIF idvd $ "11#12#13"
      nMarza := VPC * nPPP - FCJ
   ELSE
      nMarza := VPC * nPPP - NC
   ENDIF

   IF ( idvd $ "11#12#13" )
      nMarza2 := MPC - VPC - nPrevoz
   ELSEIF ( ( idvd $ "41#42#43#81" ) )
      nMarza2 := MPC - NC
   ELSE
      nMarza2 := MPC - VPC
   ENDIF

   RETURN
// }



/* PPUMP()
 *     Racuna i daje porez na promet usluga u maloprodaji
 */
STATIC FUNCTION PPUMP()

   // {
   LOCAL nVrati
   IF ( gUVarPP $ "JM" .AND. _mpp > 0 )
      nVrati := field->MPCSAPP * _DLRUC * _MPP / ( 1 + _MPP )
   ELSE
      nVrati := field->MPC * ( 1 + _OPP ) * _PPP
   ENDIF

   RETURN nVrati
// }



/* PPPMP()
 *     Racuna i daje porez na promet proizvoda u maloprodaji
 */
STATIC FUNCTION PPPMP()

   // {
   LOCAL nVrati
   IF ( gUVarPP $ "MT" )
      nVrati := field->MPCSAPP * _OPP / ( 1 + _OPP )
   ELSE
      nVrati := field->MPC * _OPP
   ENDIF

   RETURN nVrati
// }
