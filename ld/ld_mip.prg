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

#include "fmk.ch"

STATIC __mj
STATIC __god
STATIC __xml := 0
STATIC __ispl_s := 0



FUNCTION mip_sort( cRj, cGod, cMj, cRadnik, cObr )

   LOCAL cFilter := ""

   PRIVATE cObracun := cObr

   IF !Empty( cObr )
      cFilter += "obr == " + cm2str( cObr )
   ENDIF

   IF !Empty( cRj )

      IF !Empty( cFilter )
         cFilter += " .and. "
      ENDIF

      cFilter += Parsiraj( cRj, "IDRJ" )
   ENDIF

   IF !Empty( cFilter )
      SET FILTER to &cFilter
      GO TOP
   ENDIF

   IF Empty( cRadnik )
      INDEX ON Str( godina ) + Str( mjesec ) + SortPrez( idradn ) + idrj TAG "MIP1" TO ( my_home() + "ld_tmp" )
      GO TOP
      SEEK Str( cGod, 4 ) + Str( cMj, 2 ) + cRadnik
   ELSE
      SET ORDER TO tag ( TagVO( "2" ) )
      GO TOP
      SEEK Str( cGod, 4 ) + Str( cMj, 2 ) + cObracun + cRadnik
   ENDIF

   RETURN .T.


STATIC FUNCTION _ins_tbl( cRadnik, cIdRj, nGodina, nMjesec, ;
      cTipRada, cVrIspl, cR_ime, cR_jmb, cR_opc, dDatIsplate, ;
      nSati, nSatiB, nSatiT, nStUv, nBruto, nO_prih, nU_opor, ;
      nU_d_pio, nU_d_zdr, nU_d_pms, nU_d_nez, nU_d_iz, ;
      nU_dn_pio, nU_dn_zdr, nU_dn_nez, nU_dn_dz, ;
      nUm_prih, nKLO, nLODB, nOsn_por, nIzn_por, ;
      cR_rmj, lBolPreko )

   LOCAL nTArea := Select()

   O_R_EXP
   SELECT r_export
   APPEND BLANK

   REPLACE idradn WITH cRadnik
   REPLACE idrj WITH cIdRj
   REPLACE godina WITH nGodina
   REPLACE mjesec WITH nMjesec
   REPLACE tiprada WITH cTipRada
   REPLACE vr_ispl WITH cVrIspl
   REPLACE r_ime WITH cR_ime
   REPLACE r_jmb WITH cR_jmb
   REPLACE r_opc WITH cR_opc
   REPLACE d_isp WITH dDatIsplate
   REPLACE r_sati WITH nSati
   REPLACE r_satib WITH nSatiB
   REPLACE r_satit WITH nSatiT
   REPLACE r_stuv WITH nSTUv
   REPLACE bruto WITH nBruto
   REPLACE o_prih WITH nO_prih
   REPLACE u_opor WITH nU_opor
   REPLACE u_d_pio WITH nU_d_pio
   REPLACE u_d_zdr WITH nU_d_zdr
   REPLACE u_d_pms WITH nU_d_pms
   REPLACE u_d_nez WITH nU_d_nez
   REPLACE u_dn_pio WITH nU_dn_pio
   REPLACE u_dn_zdr WITH nU_dn_zdr
   REPLACE u_dn_dz WITH nU_dn_dz
   REPLACE u_dn_nez WITH nU_dn_nez
   REPLACE u_d_iz WITH nU_d_iz
   REPLACE um_prih WITH nUm_prih
   REPLACE r_klo WITH nKLO
   REPLACE l_odb WITH nLODB
   REPLACE osn_por WITH nOsn_por
   REPLACE izn_por WITH nIzn_por
   REPLACE r_rmj WITH cR_rmj

   IF lBolPreko = .T.
      REPLACE bol_preko WITH "1"
   ELSE
      REPLACE bol_preko WITH "0"
   ENDIF

   SELECT ( nTArea )

   RETURN



FUNCTION mip_tmp_tbl()

   LOCAL aDbf := {}

   AAdd( aDbf, { "IDRADN", "C", 6, 0 } )
   AAdd( aDbf, { "IDRJ", "C", 2, 0 } )
   AAdd( aDbf, { "GODINA", "N", 4, 0 } )
   AAdd( aDbf, { "MJESEC", "N", 2, 0 } )
   AAdd( aDbf, { "VR_ISPL", "C", 50, 0 } )
   AAdd( aDbf, { "R_IME", "C", 30, 0 } )
   AAdd( aDbf, { "R_JMB", "C", 13, 0 } )
   AAdd( aDbf, { "R_OPC", "C", 20, 0 } )
   AAdd( aDbf, { "TIPRADA", "C", 1, 0 } )
   AAdd( aDbf, { "D_ISP", "D", 8, 0 } )
   AAdd( aDbf, { "R_SATI", "N", 12, 2 } )
   AAdd( aDbf, { "R_SATIB", "N", 12, 2 } )
   AAdd( aDbf, { "R_SATIT", "N", 12, 2 } )
   AAdd( aDbf, { "R_STUV", "N", 12, 2 } )
   AAdd( aDbf, { "BRUTO", "N", 12, 2 } )
   AAdd( aDbf, { "O_PRIH", "N", 12, 2 } )
   AAdd( aDbf, { "U_OPOR", "N", 12, 2 } )
   AAdd( aDbf, { "U_D_PIO", "N", 12, 2 } )
   AAdd( aDbf, { "U_D_ZDR", "N", 12, 2 } )
   AAdd( aDbf, { "U_D_NEZ", "N", 12, 2 } )
   AAdd( aDbf, { "U_DN_PIO", "N", 12, 2 } )
   AAdd( aDbf, { "U_DN_ZDR", "N", 12, 2 } )
   AAdd( aDbf, { "U_DN_DZ", "N", 12, 2 } )
   AAdd( aDbf, { "U_DN_NEZ", "N", 12, 2 } )
   AAdd( aDbf, { "U_D_IZ", "N", 12, 2 } )
   AAdd( aDbf, { "UM_PRIH", "N", 12, 2 } )
   AAdd( aDbf, { "R_KLO", "N", 5, 2 } )
   AAdd( aDbf, { "L_ODB", "N", 12, 2 } )
   AAdd( aDbf, { "OSN_POR", "N", 12, 2 } )
   AAdd( aDbf, { "IZN_POR", "N", 12, 2 } )
   AAdd( aDbf, { "R_RMJ", "C", 20, 0 } )
   AAdd( aDbf, { "U_D_PMS", "N", 12, 2 } )
   AAdd( aDbf, { "BOL_PREKO", "C", 1, 0 } )
   AAdd( aDbf, { "PRINT", "C", 1, 0 } )

   t_exp_create( aDbf )

   O_R_EXP
   INDEX ON idradn + Str( godina, 4 ) + Str( mjesec, 2 ) + vr_ispl TAG "1"

   RETURN


FUNCTION ld_mip_obrazac()

   LOCAL nC1 := 20
   LOCAL i
   LOCAL cTPNaz
   LOCAL nKrug := 1
   LOCAL cRj := Space( 60 )
   LOCAL cRJDef := Space( 2 )
   LOCAL cRadnik := Space( _LR_ )
   LOCAL cPrimDobra := Space( 100 )
   LOCAL cIdRj
   LOCAL cMj_od
   LOCAL cMj_do
   LOCAL cGod_od
   LOCAL cGod_do
   LOCAL cDopr10 := "10"
   LOCAL cDopr11 := "11"
   LOCAL cDopr12 := "12"
   LOCAL cDopr1X := "1X"
   LOCAL cDopr20 := "20"
   LOCAL cDopr21 := "21"
   LOCAL cDopr22 := "22"
   LOCAL cDopr2D := Space( 100 )
   LOCAL cDoprDod := Space( 100 )
   LOCAL cTP_off := Space( 100 )
   LOCAL cTP_bol := PadR( "18;", 100 )
   LOCAL cBolPreko := PadR( "18;24;", 100 )
   LOCAL cObracun := gObracun
   LOCAL cWinPrint := "E"
   LOCAL nOper := 1
   LOCAL cIsplSaberi := "D"
   LOCAL cNule := "N"
   LOCAL cMipView := "N"
   LOCAL _pojed := .F.
   LOCAL cErr := ""

   mip_tmp_tbl()

   cIdRj := gRj
   cMj := gMjesec
   cGod := gGodina

   cPredNaz := PadR( fetch_metric( "obracun_plata_preduzece_naziv", NIL, "" ), 100 )
   cPredJMB := PadR( fetch_metric( "obracun_plata_preduzece_id_broj", NIL, "" ), 13 )
   cPredSDJ := PadR( fetch_metric( "obracun_plata_sifra_djelatnosti", NIL, "" ), 20 )
   cTp_bol := PadR( fetch_metric( "obracun_plata_mip_tip_pr_bolovanje", NIL, cTp_bol ), 100 )
   cBolPreko := PadR( fetch_metric( "obracun_plata_mip_tip_pr_bolovanje_42_dana", NIL, cBolPreko ), 100 )
   cDoprDod := PadR( fetch_metric( "obracun_plata_mip_dodatni_dopr_ut", NIL, cDoprDod ), 100 )
   cRjDef := PadR( fetch_metric( "obracun_plata_mip_def_rj_isplata", NIL, cRjDef ), 2 )
   dDatPodn := Date()

   nPorGodina := 2011
   nBrZahtjeva := 1


altd()

   ol_o_tbl()

   Box( "#MIP OBRAZAC ZA RADNIKE", 20, 75 )

   @ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
   @ m_x + 2, m_y + 2 SAY "Za period:" GET cMj PICT "99"
   @ m_x + 2, Col() + 1 SAY "/" GET cGod PICT "9999"

   @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )

   @ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
      VALID Empty( cRadnik ) .OR. P_RADN( @cRadnik )
   @ m_x + 5, m_y + 2 SAY "    Isplate u usl. ili dobrima:" ;
      GET cPrimDobra PICT "@S30"
   @ m_x + 6, m_y + 2 SAY "Tipovi koji ne ulaze u obrazac:" ;
      GET cTP_off PICT "@S30"
   @ m_x + 7, m_y + 2 SAY "Izdvojena primanja (bolovanje):" ;
      GET cTP_bol PICT "@S30"
   @ m_x + 8, m_y + 2 SAY "Sifre bolovanja preko 42 dana:" ;
      GET cBolPreko PICT "@S30"

   @ m_x + 9, m_y + 2 SAY "   Doprinos iz pio: " GET cDopr10
   @ m_x + 9, Col() + 2 SAY "na pio: " GET cDopr20
   @ m_x + 10, m_y + 2 SAY "   Doprinos iz zdr: " GET cDopr11
   @ m_x + 10, Col() + 2 SAY "na zdr: " GET cDopr21
   @ m_x + 10, Col() + 2 SAY "dod.dopr.na zdr: " GET cDopr2D PICT "@S10"
   @ m_x + 11, m_y + 2 SAY "   Doprinos iz nez: " GET cDopr12
   @ m_x + 11, Col() + 2 SAY "na nez: " GET cDopr22
   @ m_x + 12, m_y + 2 SAY "Doprinos iz ukupni: " GET cDopr1X
   @ m_x + 13, m_y + 2 SAY " dod.dopr. benef.: " GET cDoprDod PICT "@S30"
   @ m_x + 15, m_y + 2 SAY "Naziv preduzeca: " GET cPredNaz PICT "@S30"
   @ m_x + 15, Col() + 1 SAY "JID: " GET cPredJMB
   @ m_x + 16, m_y + 2 SAY "Sifra djelatnosti: " GET cPredSDJ PICT "@S20"
   @ m_x + 17, m_y + 2 SAY "Def.RJ" GET cRJDef
   @ m_x + 17, Col() + 2 SAY "Sabrati isplate za isti mj ?" GET cIsplSaberi ;
      VALID cIsplSaberi $ "DN" PICT "@!"
   @ m_x + 17, Col() + 2 SAY "obracun 0 ?" GET cNule ;
      VALID cNule $ "DN" PICT "@!"
   @ m_x + 17, Col() + 2 SAY "pregled ?" GET cMipView ;
      VALID cMipView $ "DN" PICT "@!"
   @ m_x + 18, m_y + 2 SAY "Stampa/Export ?" GET cWinPrint PICT "@!" ;
      VALID cWinPrint $ "ES"
   READ

   IF cWinPrint == "E"
      @ m_x + 19, m_y + 2 SAY "Datum podnosenja:" GET dDatPodn
      READ

   ENDIF

   dD_start := Date()
   dD_end := Date()

   _fix_d_per( cMj, cGod, @dD_start, @dD_end )

   dPer := Date()

   g_per( cMj, cGod, @dPer )

   clvbox()

   ESC_BCR

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   IF ld_provjeri_dat_isplate_za_mjesec( cGod, cMj, IF( !Empty( cRjDef ), cRjDef, NIL ) ) > 0

      IF !EMPTY( cRjDef )
         cErr := "Nije definisan datum isplate za radnu jedinicu '" + cRjDef +  "'."
      ELSE
         cErr := "Za pojedine radne jedinice nije definisan datum isplate."
      ENDIF

      IF cWinPrint == "S"
         cErr += "#Obrazac će biti prikazan bez datuma isplate."
         MsgBeep( cErr )
      ELSE
         cErr += "#Molimo ispravite pa ponovo pokrenite ovu opciju."
         MsgBeep( cErr )
         RETURN
      ENDIF

   ENDIF

   __mj := cMj
   __god := cGod

   IF cWinPrint == "S"
      __xml := 1
   ELSE
      __xml := 0
   ENDIF

   IF cIsplSaberi == "D"
      __ispl_s := 1
   ENDIF

   set_metric( "obracun_plata_preduzece_naziv", NIL, AllTrim( cPredNaz ) )
   set_metric( "obracun_plata_preduzece_id_broj", NIL, cPredJMB )
   set_metric( "obracun_plata_sifra_djelatnosti", NIL, cPredSDJ )
   set_metric( "obracun_plata_mip_tip_pr_bolovanje", NIL, AllTrim( cTp_bol ) )
   set_metric( "obracun_plata_mip_tip_pr_bolovanje_42_dana", NIL, AllTrim( cBolPreko ) )
   set_metric( "obracun_plata_mip_dodatni_dopr_ut", NIL, AllTrim( cDoprDod ) )
   set_metric( "obracun_plata_mip_def_rj_isplata", NIL, cRjDef )

   IF !Empty( cRadnik )
      _pojed := .T.
      __xml := 1
   ENDIF

   SELECT ld

   mip_sort( cRj, cGod, cMj, cRadnik, cObracun )

   mip_fill_data( cRj, cRjDef, cGod, cMj, cRadnik, ;
      cPrimDobra, cTP_off, cTP_bol, cBolPreko, cDopr10, cDopr11, cDopr12, ;
      cDopr1X, cDopr20, cDopr21, cDopr22, cDoprDod, cDopr2D, cObracun, ;
      cNule )

   IF cMipView == "D"
      mip_view()
   ENDIF

   IF __xml == 1
      _xml_print( _pojed )
   ELSE
      nBrZahtjeva := g_br_zaht()
      _xml_export( cMj, cGod )
      msgbeep( "Obradjeno " + AllTrim( Str( nBrZahtjeva ) ) + " radnika." )
   ENDIF

   RETURN .T.


STATIC FUNCTION _fix_d_per( nMj, nGod, dStart, dEnd )

   LOCAL cTmp := ""

   cTmp := "01"
   cTmp += "."
   cTmp += PadL( AllTrim( Str( nMj ) ), 2, "0" )
   cTmp += "."
   cTmp += AllTrim( Str( nGod ) )

   dStart := CToD( cTmp )

   cTmp := g_day( nMj )
   cTmp += "."
   cTmp += PadL( AllTrim( Str( nMj ) ), 2, "0" )
   cTmp += "."
   cTmp += AllTrim( Str( nGod ) )

   dEnd := CToD( cTmp )

   RETURN


STATIC FUNCTION _xml_head()

   LOCAL cStr := '<?xml version="1.0" encoding="UTF-8"?><PaketniUvozObrazaca xmlns="urn:PaketniUvozObrazaca_V1_0.xsd">'

   xml_head( .T., cStr )

   RETURN


STATIC FUNCTION _xml_export( mjesec, godina )

   LOCAL _cre, cMsg, _id_br, _naziv, _adresa, _mjesto, _lokacija
   LOCAL _a_files, _error
   LOCAL _output_file := ""

   IF __xml == 1
      RETURN
   ENDIF

   _id_br  := fetch_metric( "org_id_broj", NIL, PadR( "<POPUNI>", 13 ) )
   _naziv  := fetch_metric( "org_naziv", NIL, PadR( "<POPUNI naziv>", 100 ) )
   _adresa := fetch_metric( "org_adresa", NIL, PadR( "<POPUNI adresu>", 100 ) )
   _mjesto   := fetch_metric( "org_mjesto", NIL, PadR( "<POPUNI mjesto>", 100 ) )

   Box(, 6, 70 )
   @ m_x + 1, m_y + 2 SAY " - Firma/Organizacija - "
   @ m_x + 3, m_y + 2 SAY " Id broj: " GET _id_br
   @ m_x + 4, m_y + 2 SAY "   Naziv: " GET _naziv PICT "@S50"
   @ m_x + 5, m_y + 2 SAY "  Adresa: " GET _adresa PICT "@S50"
   @ m_x + 6, m_y + 2 SAY "  Mjesto: " GET _mjesto PICT "@S50"
   READ
   BoxC()

   set_metric( "org_id_broj", NIL, _id_br )
   set_metric( "org_naziv", NIL, _naziv )
   set_metric( "org_adresa", NIL, _adresa )
   set_metric( "org_mjesto", NIL, _mjesto )


   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   _id_br := AllTrim( _id_br )

   _lokacija := _path_quote( my_home() + "export" + SLASH )

   IF DirChange( _lokacija ) != 0
      _cre := MakeDir ( _lokacija )
      IF _cre != 0
         MsgBeep( "kreiranje " + _lokacija + " neuspjesno ?!" )
         log_write( "dircreate err:" + _lokacija, 6 )
         RETURN .F.
      ENDIF
   ENDIF

   DirChange( _lokacija )

   // napuni xml fajl
   _fill_e_xml( _id_br + ".xml" )

   cMsg := "Generacija obrasca završena.#"
   cMsg += "Fajl se nalazi na desktopu u folderu F18_dokumenti."

   MsgBeep( cMsg )

   DirChange( my_home() )

   my_close_all_dbf()

   _output_file := "mip_" + AllTrim( my_server_params()[ "database" ] ) + "_" + AllTrim( mjesec ) + "_" + AllTrim( godina ) + ".xml"

   // kopiraj fajl na desktop
   f18_copy_to_desktop( _lokacija, _id_br + ".xml", _output_file )

   RETURN



// --------------------------------------------
// filuje xml fajl sa podacima za export
// --------------------------------------------
STATIC FUNCTION _fill_e_xml( file )

   LOCAL nTArea := Select()
   LOCAL nU_dn_pio
   LOCAL nU_dn_zdr
   LOCAL nU_dn_nez
   LOCAL nU_dn_dz
   LOCAL nU_prih
   LOCAL nU_dopr
   LOCAL nU_lodb
   LOCAL nU_porez
   LOCAL _ima_bol_preko := .F.
   LOCAL _id_br, _naziv, _adresa, _mjesto
   LOCAL cPredSDJ

   // otvori xml za upis
   open_xml( file )

   // upisi header
   _xml_head()

   // ovo ne treba zato sto je u headeru sadrzan ovaj prvi sub-node !!!
   // <paketniuvozobrazaca>
   // xml_subnode("PaketniUvozObrazaca", .f.)

   _id_br  := fetch_metric( "org_id_broj", NIL, PadR( "<POPUNI>", 13 ) )
   _naziv  := fetch_metric( "org_naziv", NIL, PadR( "<POPUNI naziv>", 100 ) )
   _adresa := fetch_metric( "org_adresa", NIL, PadR( "<POPUNI adresu>", 100 ) )
   _mjesto   := fetch_metric( "org_mjesto", NIL, PadR( "<POPUNI mjesto>", 100 ) )
   cPredSDJ := fetch_metric( "obracun_plata_sifra_djelatnosti", NIL, Space( 20 ) )

   // <podacioposlodavcu>
   xml_subnode( "PodaciOPoslodavcu", .F. )

   // naziv firme
   xml_node( "JIBPoslodavca", AllTrim( _id_br ) )
   xml_node( "NazivPoslodavca", to_xml_encoding( AllTrim( _naziv ) ) )
   xml_node( "BrojZahtjeva", Str( 1 ) )
   xml_node( "DatumPodnosenja", xml_date( dDatPodn ) )

   xml_subnode( "PodaciOPoslodavcu", .T. )

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   nU_dn_pio := 0
   nU_dn_zdr := 0
   nU_dn_nez := 0
   nU_dn_dz := 0
   nU_prih := 0
   nU_dopr := 0
   nU_lodb := 0
   nU_porez := 0


   xml_subnode( "Obrazac1023", .F. )

   // dio1
   xml_subnode( "Dio1", .F. )

   xml_node( "JibJmb", AllTrim( _id_br ) )
   xml_node( "Naziv", to_xml_encoding( AllTrim( _naziv ) ) )
   xml_node( "DatumUpisa", xml_date( dDatPodn ) )
   xml_node( "BrojUposlenih", Str( nBrZahtjeva ) )
   xml_node( "PeriodOd", xml_date( dD_start ) )
   xml_node( "PeriodDo", xml_date( dD_end ) )
   xml_node( "SifraDjelatnosti", to_xml_encoding( AllTrim( cPredSDJ ) ) )

   xml_subnode( "Dio1", .T. )
   // dio1

   // dio2
   xml_subnode( "Dio2", .F. )

   DO WHILE !Eof()

      IF field->print == "X"
         SKIP
         LOOP
      ENDIF

      // po radniku
      cT_radnik := field->idradn

      // pronadji radnika u sifrarniku
      SELECT radn
      SEEK cT_radnik

      SELECT r_export

      nCnt := 0

      nR_sati := 0
      nR_satib := 0
      nR_satit := 0
      nO_prih := 0
      nBruto := 0
      nU_opor := 0
      nU_d_zdr := 0
      nU_d_pio := 0
      nU_d_nez := 0
      nU_d_iz := 0
      nU_d_pms := 0
      nUm_prih := 0
      nR_klo := 0
      nL_odb := 0
      nOsnPor := 0
      nIznPor := 0

      _ima_bol_preko := .F.

      DO WHILE !Eof() .AND. field->idradn == cT_radnik

         IF field->print == "X"
            SKIP
            LOOP
         ENDIF

         cVr_ispl := field->vr_ispl
         cR_jmb := field->r_jmb
         cR_ime := field->r_ime
         dD_ispl := field->d_isp

         IF !_ima_bol_preko
            nR_sati += field->r_sati
            nR_satib += field->r_satib
            nR_satit += field->r_satit
         ENDIF

         nBruto += field->bruto
         nO_prih += field->o_prih
         nU_opor += field->u_opor
         nU_d_zdr += field->u_d_zdr
         nU_d_pio += field->u_d_pio
         nU_d_nez += field->u_d_nez
         nU_d_iz += field->u_d_iz
         nU_d_pms += field->u_d_pms
         nUm_prih += field->um_prih
         nR_klo += field->r_klo
         nL_odb += field->l_odb
         nOsnPor += field->osn_por
         nIznPor += field->izn_por
         nR_stuv := field->r_stuv
         cR_rmj := field->r_rmj
         cR_opc := field->r_opc

         nU_dn_pio += field->u_dn_pio
         nU_dn_zdr += field->u_dn_zdr
         nU_dn_nez += field->u_dn_nez
         nU_dn_dz += field->u_dn_dz
         nU_prih += field->u_opor
         nU_dopr += field->u_d_iz
         nU_lodb += field->l_odb
         nU_porez += field->izn_por

         // ako je isti radnik kao i ranije
         // i bolovanje preko 42 dana
         // uzmi puni fond sati sa stavke bolovanja
         // bol_preko = "1"
         IF field->bol_preko == "1"

            _ima_bol_preko := .T.

            nR_sati := field->r_sati
            nR_satib := field->r_satib

            IF nR_satiT <> 0 .AND. gBenefSati == 1
               nR_satiT := field->r_sati
            ENDIF

         ENDIF

         SKIP
      ENDDO

      xml_subnode( "PodaciOPrihodima", .F. )

      xml_node( "VrstaIsplate", ;
         to_xml_encoding( AllTrim( cVr_ispl ) ) )
      xml_node( "Jmb", AllTrim( cR_jmb ) )
      xml_node( "ImePrezime", ;
         to_xml_encoding( AllTrim( cR_ime ) ) )
      xml_node( "DatumIsplate", xml_date( dD_ispl ) )
      xml_node( "RadniSati", ;
         Str( nR_sati, 12, 2 ) )
      xml_node( "RadniSatiBolovanje", ;
         Str( nR_satib, 12, 2 ) )
      xml_node( "BrutoPlaca", Str( nBruto, 12, 2 ) )
      xml_node( "KoristiIDrugiOporeziviPrihodi", ;
         Str( nO_prih, 12, 2 ) )
      xml_node( "UkupanPrihod", ;
         Str( nU_opor, 12, 2 ) )
      xml_node( "IznosPIO", ;
         Str( nU_d_pio, 12, 2 ) )
      xml_node( "IznosZO", ;
         Str( nU_d_zdr, 12, 2 ) )
      xml_node( "IznosNezaposlenost", ;
         Str( nU_d_nez, 12, 2 ) )
      xml_node( "Doprinosi", Str( nU_d_iz, 12, 2 ) )
      xml_node( "PrihodUmanjenZaDoprinose", ;
         Str( nUm_prih, 12, 2 ) )
      xml_node( "FaktorLicnogOdbitka", ;
         Str( nR_klo, 12, 2 ) )
      xml_node( "IznosLicnogOdbitka", Str( nL_odb, 12, 2 ) )
      xml_node( "OsnovicaPoreza", Str( nOsnpor, 12, 2 ) )
      xml_node( "IznosPoreza", Str( nIznpor, 12, 2 ) )

      cTmp := "false"

      IF nR_satit > 0
         cTmp := "true"

         xml_node( "RadniSatiUT", Str( nR_satit, 12, 2 ) )
         xml_node( "StepenUvecanja", Str( nR_stuv, 12, 0 ) )
         xml_node( "SifraRadnogMjestaUT", AllTrim( cR_rmj )  )
         xml_node( "DoprinosiPIOMIOzaUT", ;
            Str( nU_d_pms, 12, 2 )  )

         // true or false
         xml_node( "BeneficiraniStaz", AllTrim( cTmp ) )

      ENDIF

      xml_node( "OpcinaPrebivalista", AllTrim( cR_opc ) )

      xml_subnode( "PodaciOPrihodima", .T. )

   ENDDO

   xml_subnode( "Dio2", .T. )
   // kraj dio2

   // dio3
   xml_subnode( "Dio3", .F. )
   xml_node( "PIO", Str( nU_dn_pio, 12, 2 ) )
   xml_node( "ZO", Str( nU_dn_zdr, 12, 2 ) )
   xml_node( "OsiguranjeOdNezaposlenosti", Str( nU_dn_nez, 12, 2 ) )
   xml_node( "DodatniDoprinosiZO", Str( nU_dn_dz, 12, 2 ) )
   xml_node( "Prihod", Str( nU_prih, 12, 2 ) )
   xml_node( "Doprinosi", Str( nU_dopr, 12, 2 ) )
   xml_node( "LicniOdbici", Str( nU_lodb, 12, 2 ) )
   xml_node( "Porez", Str( nU_porez, 12, 2 ) )
   xml_subnode( "Dio3", .T. )
   // dio3

   // dio4
   xml_subnode( "Dio4IzjavaPoslodavca", .F. )
   xml_node( "JibJmbPoslodavca", AllTrim( cPredJmb ) )
   xml_node( "DatumUnosa", xml_date( dDatPodn ) )
   xml_node( "NazivPoslodavca", to_xml_encoding( AllTrim( cPredNaz ) ) )
   xml_subnode( "Dio4IzjavaPoslodavca", .T. )
   // dio4

   cOperacija := "Prijava_od_strane_poreznog_obveznika"
   xml_subnode( "Dokument", .F. )
   xml_node( "Operacija",  cOperacija )
   xml_subnode( "Dokument", .T. )


   xml_subnode( "Obrazac1023", .T. )

   // zatvori <PaketniUvoz...>
   xml_subnode( "PaketniUvozObrazaca", .T. )

   SELECT ( nTArea )

   close_xml()

   RETURN


// --------------------------------------
// vraca period
// --------------------------------------
STATIC FUNCTION g_per( cMj, cGod, dPer )

   LOCAL cTmp := ""

   cTmp += PadL( AllTrim( Str( cMj ) ), 2, "0" ) + "."
   cTmp += AllTrim( Str( cGod ) )

   dPer := CToD( cTmp )

   RETURN


STATIC FUNCTION _xml_print( lPojedinacni )

   LOCAL _template := "ld_mip.odt"
   LOCAL _xml_file := my_home() + "data.xml"

   IF __xml == 0
      RETURN
   ENDIF

   IF lPojedinacni == .T.
      _template := "ld_pmip.odt"
   ENDIF

   _fill_xml( _xml_file )

   IF generisi_odt_iz_xml( _template, _xml_file )
      prikazi_odt()
   ENDIF

   RETURN


STATIC FUNCTION _fill_xml( xml_file )

   LOCAL nTArea := Select()
   LOCAL _ima_bol_preko := .F.

   // otvori xml za upis
   open_xml( xml_file )
   // upisi header
   xml_head()

   xml_subnode( "mip", .F. )

   // naziv firme
   xml_node( "p_naz", to_xml_encoding( AllTrim( cPredNaz ) ) )
   xml_node( "p_jmb", AllTrim( cPredJmb ) )
   xml_node( "p_sdj", AllTrim( cPredSDJ ) )
   xml_node( "p_per", g_por_per() )

   nU_prih := 0
   nU_dopr := 0
   nU_lodb := 0
   nU_porez := 0
   nU_pd_pio := 0
   nU_pd_nez := 0
   nU_pd_zdr := 0
   nU_pd_dodz := 0
   nZaposl := 0

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   // saberi totale...
   DO WHILE !Eof()

      IF field->print == "X"
         SKIP
         LOOP
      ENDIF

      ++ nZaposl

      nU_prih += field->u_opor
      nU_dopr += field->u_d_iz
      nU_lodb += field->l_odb
      nU_porez += field->izn_por
      nU_pd_pio += field->u_dn_pio
      nU_pd_nez += field->u_dn_nez
      nU_pd_zdr += field->u_dn_zdr
      nU_pd_dodz += field->u_dn_dz

      SKIP
   ENDDO

   // totali
   xml_node( "p_zaposl", Str( nZaposl ) )
   xml_node( "u_prih", Str( nU_prih, 12, 2 ) )
   xml_node( "u_dopr", Str( nU_dopr, 12, 2 ) )
   xml_node( "u_lodb", Str( nU_lodb, 12, 2 ) )
   xml_node( "u_porez", Str( nU_porez, 12, 2 ) )
   xml_node( "u_pd_pio", Str( nU_pd_pio, 12, 2 ) )
   xml_node( "u_pd_zdr", Str( nU_pd_zdr, 12, 2 ) )
   xml_node( "u_pd_nez", Str( nU_pd_nez, 12, 2 ) )
   xml_node( "u_pd_dodz", Str( nU_pd_dodz, 12, 2 ) )

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   nCnt := 0

   DO WHILE !Eof()

      IF field->print == "X"
         SKIP
         LOOP
      ENDIF

      // po radniku
      cT_radnik := field->idradn

      xml_subnode( "radnik", .F. )

      xml_node( "rbr", Str( ++nCnt ) )
      xml_node( "visp", AllTrim( field->vr_ispl ) )
      xml_node( "r_ime", to_xml_encoding( AllTrim( field->r_ime ) ) )
      xml_node( "r_jmb", AllTrim( field->r_jmb ) )
      xml_node( "r_opc", to_xml_encoding( AllTrim( field->r_opc ) ) )

      nR_sati := 0
      nR_satib := 0
      nR_satit := 0
      cStuv := ""
      nR_StUv := 0
      cR_rmj := ""
      nBruto := 0
      nO_prih := 0
      nU_opor := 0
      nU_d_pio := 0
      nU_d_zdr := 0
      nU_d_pms := 0
      nU_d_nez := 0
      nU_d_iz := 0
      nUm_prih := 0
      nL_odb := 0
      nR_klo := 0
      nOsn_por := 0
      nIzn_por := 0

      _ima_bol_preko := .F.

      // provrti obracune
      DO WHILE !Eof() .AND. field->idradn == cT_radnik

         IF field->print == "X"
            SKIP
            LOOP
         ENDIF

         // za obrazac i treba zadnja isplata
         dD_isp := field->d_isp

         IF !_ima_bol_preko
            nR_sati += field->r_sati
            nR_satib += field->r_satib
            nR_satit += field->r_satit
         ENDIF

         nR_stuv := field->r_stuv
         cR_rmj := field->r_rmj
         nBruto += field->bruto
         nO_prih += field->o_prih
         nU_opor += field->u_opor
         nU_d_pio += field->u_d_pio
         nU_d_zdr += field->u_d_zdr
         nU_d_nez += field->u_d_nez
         nU_d_iz += field->u_d_iz
         nUm_prih += field->um_prih
         nL_odb += field->l_odb
         nR_klo += field->r_klo
         nOsn_por += field->osn_por
         nIzn_por += field->izn_por
         nU_d_pms += field->u_d_pms

         // ako je isti radnik kao i ranije
         // i bolovanje preko 42 dana
         // uzmi puni fond sati sa stavke bolovanja
         // bol_preko = "1"
         IF field->bol_preko == "1"

            _ima_bol_preko := .T.

            nR_sati := field->r_sati
            nR_satib := field->r_satib

            IF nR_satiT <> 0 .AND. gBenefSati == 1
               nR_satiT := field->r_sati
            ENDIF

         ENDIF

         SKIP

      ENDDO

      cStUv := AllTrim( Str( nR_Stuv, 12, 0 ) ) + "/12"

      xml_node( "d_isp", DToC( dD_isp ) )
      xml_node( "r_sati", Str( nR_sati, 12, 2 ) )
      xml_node( "r_satib", Str( nR_satiB, 12, 2 ) )
      xml_node( "r_satit", Str( nR_satiT, 12, 2 ) )
      xml_node( "r_stuv", cStUv )
      xml_node( "bruto", Str( nBruto, 12, 2 ) )
      xml_node( "o_prih", Str( nO_prih, 12, 2 ) )
      xml_node( "u_opor", Str( nU_opor, 12, 2 ) )
      xml_node( "u_d_pio", Str( nU_d_pio, 12, 2 ) )
      xml_node( "u_d_nez", Str( nU_d_nez, 12, 2 ) )
      xml_node( "u_d_zdr", Str( nU_d_zdr, 12, 2 ) )
      xml_node( "u_d_pms", Str( nU_d_pms, 12, 2 ) )
      xml_node( "u_d_iz", Str( nU_d_iz, 12, 2 ) )
      xml_node( "um_prih", Str( nUm_prih, 12, 2 ) )
      xml_node( "r_klo", Str( nR_klo, 5, 2 ) )
      xml_node( "l_odb", Str( nL_odb, 12, 2 ) )
      xml_node( "osn_por", Str( nOsn_por, 12, 2 ) )
      xml_node( "izn_por", Str( nIzn_por, 12, 2 ) )
      xml_node( "r_rmj", cR_rmj )

      xml_subnode( "radnik", .T. )

   ENDDO

   // zatvori <mip>
   xml_subnode( "mip", .T. )

   SELECT ( nTArea )

   // zatvori xml fajl
   close_xml()

   RETURN


// ----------------------------------------------------------
// vraca string poreznog perioda
// ----------------------------------------------------------
STATIC FUNCTION g_por_per()

   LOCAL cRet := ""

   cRet += AllTrim( Str( __mj ) ) + "/" + AllTrim( Str( __god ) )
   cRet += " godine"

   RETURN cRet



// ---------------------------------------------------------
// napuni podatke u pomocnu tabelu za izvjestaj
// ---------------------------------------------------------
FUNCTION mip_fill_data( cRj, cRjDef, cGod, cMj, ;
      cRadnik, cPrimDobra, cTP_off, cTP_bol, cBolPreko, cDopr10, ;
      cDopr11, cDopr12, ;
      cDopr1X, cDopr20, cDopr21, cDopr22, cDoprDod, cDopr2D, cObracun, cNule )

   LOCAL i
   LOCAL b
   LOCAL c
   LOCAL t
   LOCAL o
   LOCAL cPom
   LOCAL nPrDobra
   LOCAL nTP_off
   LOCAL nTP_bol
   LOCAL nTrosk := 0
   LOCAL lInRS := .F.

   lDatIspl := .F.
   IF obracuni->( FieldPos( "DAT_ISPL" ) ) <> 0
      lDatIspl := .T.
   ENDIF

   SELECT ld

   DO WHILE !Eof()

      IF ld_date( field->godina, field->mjesec ) < ;
            ld_date( cGod, cMj )
         SKIP
         LOOP
      ENDIF

      IF ld_date( field->godina, field->mjesec ) > ;
            ld_date( cGod, cMj )
         SKIP
         LOOP
      ENDIF

      cT_radnik := field->idradn
      nGodina := field->godina
      nMjesec := field->mjesec

      IF !Empty( cRadnik )
         IF cT_radnik <> cRadnik
            SKIP
            LOOP
         ENDIF
      ENDIF

      cTipRada := g_tip_rada( ld->idradn, ld->idrj )
      lInRS := radnik_iz_rs( radn->idopsst, radn->idopsrad )

      // samo pozicionira bazu PAROBR na odgovarajuci zapis
      ParObr( ld->mjesec, ld->godina, ld->obr, ld->idrj )

      SELECT radn
      SEEK cT_radnik

      IF !( cTipRada $ " #I#N" )
         SELECT ld
         SKIP
         LOOP
      ENDIF

      SELECT ld

      nSati := 0
      nSatiB := 0
      nSatiT := 0
      nStUv := 0
      nBruto := 0
      nO_prih := 0
      nU_opor := 0
      nU_d_pio := 0
      nU_d_zdr := 0
      nU_dn_dz := 0
      nU_d_nez := 0
      nU_dn_pio := 0
      nU_dn_zdr := 0
      nU_dn_nez := 0
      nU_d_iz := 0
      nUm_prih := 0
      nOsn_por := 0
      nIzn_por := 0
      nU_d_pms := 0

      nTrosk := 0
      nBrDobra := 0
      nNeto := 0
      nPrDobra := 0
      nTP_off := 0
      nTP_bol := 0

      cR_ime := ""
      cR_jmb := ""
      cR_opc := ""
      cR_rmj := ""

      DO WHILE !Eof() .AND. field->idradn == cT_radnik

         IF ld_date( field->godina, field->mjesec ) < ;
               ld_date( cGod, cMj )
            SKIP
            LOOP
         ENDIF

         IF ld_date( field->godina, field->mjesec ) > ;
               ld_date( cGod, cMj )
            SKIP
            LOOP
         ENDIF

         // radna jedinica
         cRadJed := ld->idrj

         SELECT radn

         cR_ime := AllTrim( radn->ime ) + " " + AllTrim( radn->naz )
         cR_jmb := AllTrim( radn->matbr )
         cR_opc := g_ops_code( radn->idopsst )
         cR_rmj := ""

         SELECT ld

         // uvijek provjeri tip rada, ako ima vise obracuna
         cTipRada := g_tip_rada( ld->idradn, ld->idrj )
         cTrosk := radn->trosk
         lInRS := radnik_iz_rs( radn->idopsst, radn->idopsrad )

         IF !( cTipRada $ " #I#N" )
            SKIP
            LOOP
         ENDIF

         ParObr( ld->mjesec, ld->godina, ld->obr, ld->idrj )

         // puni fond sati za ovaj mjesec
         nFondSati := parobr->k1

         nPrDobra := 0
         nTP_off := 0
         nTP_bol := 0

         IF !Empty( cPrimDobra )
            FOR t := 1 TO 60
               cPom := IF( t > 9, Str( t, 2 ), "0" + Str( t, 1 ) )
               IF ld->( FieldPos( "I" + cPom ) ) <= 0
                  EXIT
               ENDIF
               nPrDobra += IF( cPom $ cPrimDobra, LD->&( "I" + cPom ), 0 )
            NEXT
         ENDIF

         IF !Empty( cTP_off )
            FOR o := 1 TO 60
               cPom := IF( o > 9, Str( o, 2 ), "0" + Str( o, 1 ) )
               IF ld->( FieldPos( "I" + cPom ) ) <= 0
                  EXIT
               ENDIF
               nTP_off += IF( cPom $ cTP_off, LD->&( "I" + cPom ), 0 )
            NEXT
         ENDIF

         IF !Empty( cTP_bol )
            FOR b := 1 TO 60
               cPom := IF( b > 9, Str( b, 2 ), "0" + Str( b, 1 ) )
               IF ld->( FieldPos( "S" + cPom ) ) <= 0
                  EXIT
               ENDIF
               nTP_bol += IF( cPom $ cTP_bol, LD->&( "S" + cPom ), 0 )
            NEXT
         ENDIF

         // provjeri da li ima bolovanja preko 42 dana
         // ili trudnickog bolovanja

         lImaBPreko := .F.

         IF !Empty( cBolPreko )

            FOR c := 1 TO 60
               cPom := IF( c > 9, Str( c, 2 ), "0" + Str( c, 1 ) )
               IF ld->( FieldPos( "S" + cPom ) ) <= 0
                  EXIT
               ENDIF

               IF cPom $ cBolPreko .AND. ;
                     LD->&( "S" + cPom ) <> 0

                  lImaBPreko := .T.
                  EXIT
               ENDIF

            NEXT

         ENDIF

         nNeto := field->uneto
         nKLO := g_klo( field->ulicodb )
         nL_odb := field->ulicodb
         nSati := field->usati
         nSatiB := nTP_bol

         IF lImaBPreko
            // uzmi puni fond sati
            nSati := nFondSati
            nSatiB := nFondSati
         ENDIF

         nSatiT := 0

         // tipovi primanja koji ne ulaze u bruto osnovicu
         IF ( nTP_off > 0 )
            nNeto := ( nNeto - nTP_off )
         ENDIF

         nBruto := bruto_osn( nNeto, cTipRada, nL_odb )

         nMBruto := nBruto

         // prvo provjeri hoces li racunati mbruto
         IF calc_mbruto()
            // minimalni bruto
            nMBruto := min_bruto( nBruto, field->usati )
         ENDIF

         // ovo preskoci, nema ovdje GIP-a
         IF nMBruto <= 0 .AND. cNule == "N"
            SELECT ld
            SKIP
            LOOP
         ENDIF

         // bruto primanja u uslugama ili dobrima
         // za njih posebno izracunaj bruto osnovicu
         IF nPrDobra > 0
            nBrDobra := bruto_osn( nPrDobra, cTipRada, nL_odb )
         ENDIF

         nBr_benef := 0
         nU_d_pms := 0
         cBen_stopa := ""

         // beneficirani staz
         _a_benef := {}

         // beneficirani radnici
         IF UBenefOsnovu()

            // sati beneficiranog su sati redovnog rada
            IF gBenefSati == 1
               nSatiT := nSati
            ELSE
               nSatiT := field->usati
            ENDIF

            // benef.stepen
            nStUv := benefstepen()
            cBen_stopa := AllTrim( radn->k3 )

            IF radn->( FieldPos( "BEN_SRMJ" ) ) <> 0
               cR_rmj := AllTrim( radn->ben_srmj )
            ENDIF

            // promjeni parametre za benef. primanja
            cFFTmp := gBFForm
            gBFForm := StrTran( gBFForm, "_", "" )

            nBr_Benef := bruto_osn( nNeto - ;
               IF( !Empty( gBFForm ), &gBFForm, 0 ), ;
               cTipRada, nL_odb )

            add_to_a_benef( @_a_benef, cBen_stopa, nStUv, nBr_Benef )

            // vrati parametre
            gBFForm := cFFtmp

         ENDIF

         // ocitaj doprinose, njihove iznose
         nDopr10 := get_dopr( cDopr10, cTipRada )
         nDopr11 := get_dopr( cDopr11, cTipRada )
         nDopr12 := get_dopr( cDopr12, cTipRada )
         nDopr1X := get_dopr( cDopr1X, cTipRada )
         nDopr20 := get_dopr( cDopr20, cTipRada )
         nDopr21 := get_dopr( cDopr21, cTipRada )
         nDopr22 := get_dopr( cDopr22, cTipRada )

         // izracunaj doprinose
         nU_d_pio := Round( nMBruto * nDopr10 / 100, 4 )
         nU_d_zdr := Round( nMBruto * nDopr11 / 100, 4 )
         nU_d_nez := Round( nMBruto * nDopr12 / 100, 4 )

         nU_dn_pio := Round( nMBruto * nDopr20 / 100, 4 )
         nU_dn_zdr := Round( nMBruto * nDopr21 / 100, 4 )
         nU_dn_nez := Round( nMBruto * nDopr22 / 100, 4 )

         // zbirni je zbir ova tri doprinosa
         nU_d_iz := Round( nU_d_pio + nU_d_zdr + nU_d_nez, 4 )

         // dodatni doprinosi iz beneficije
         IF !Empty( cDoprDod )

            aD_Dopr := TokToNiz( cDoprDod, ";" )

            FOR m := 1 TO Len( aD_dopr )

               nDoprTmp := get_dopr( aD_dopr[ m ], cTipRada )

               IF !Empty( dopr->idkbenef ) .AND. cBen_stopa == dopr->idkbenef
                  nU_d_pms += Round( get_benef_osnovica( _a_benef, dopr->idkbenef ) * nDoprTmp / 100, 4 )
               ENDIF

            NEXT
         ENDIF

         // dodatni doprinosi na
         IF !Empty( cDopr2D )

            aD2_Dopr := TokToNiz( cDopr2D, ";" )

            FOR c := 1 TO Len( aD2_dopr )
               nDoprTmp := get_dopr( aD2_dopr[ c ], cTipRada )
               IF !Empty( dopr->idkbenef ) .AND. cBen_stopa == dopr->idkbenef
                  nU_dn_dz += ;
                     Round( nBr_benef * nDoprTmp / 100, 4 )
               ELSE
                  nU_dn_dz += ;
                     Round( nMBruto * nDoprTmp / 100, 4 )
               ENDIF
            NEXT
         ENDIF

         nUM_prih := ( nBruto - nU_d_iz )
         nPorOsn := ( nBruto - nU_d_iz ) - nL_odb

         // ako je neoporeziv radnik, nema poreza
         IF !radn_oporeziv( radn->id, ld->idrj ) .OR. ;
               ( nBruto - nU_d_iz ) < nL_odb
            nPorOsn := 0
         ENDIF

         // porez je ?
         nPorez := izr_porez( nPorOsn, "B" )

         SELECT ld

         // na ruke je
         nNaRuke := Round( nBruto - nU_d_iz - nPorez + nTrosk, 2 )

         nIsplata := nNaRuke

         // da li se radi o minimalcu ?
         IF cTipRada $ " #I#N#"
            nIsplata := min_neto( nIsplata, field->usati )
         ENDIF

         nO_prih := nBrDobra
         nU_opor := ( nBruto - nBrDobra )

         cVrstaIspl := ""
         dDatIspl := Date()
         cObr := " "
         nMjIspl := 0
         cIsplZa := ""
         cVrstaIspl := "1"

         cObr := field->obr

         IF lDatIspl

            // radna jedinica
            cTmpRj := field->idrj
            IF !Empty( cRJDef )
               cTmpRj := cRJDef
            ENDIF

            dDatIspl := g_isp_date( cTmpRJ, ;
               field->godina, ;
               field->mjesec, ;
               cObr, @nMjIspl, ;
               @cIsplZa, @cVrstaIspl )
         ENDIF

         // vrstu isplate cu uzeti iz LD->V_ISPL
         IF Empty( field->v_ispl )
            cVrstaIspl := "1"
         ELSE
            cVrstaIspl := AllTrim( field->v_ispl )
         ENDIF

         _ins_tbl( cT_radnik, ;
            cRadJed, ;
            nGodina, ;
            nMjesec, ;
            cTipRada, ;
            cVrstaIspl, ;
            cR_ime, ;
            cR_jmb, ;
            cR_opc, ;
            dDatIspl, ;
            nSati, ;
            nSatiB, ;
            nSatiT, ;
            nStUv, ;
            nBruto, ;
            nO_prih, ;
            nU_opor, ;
            nU_d_pio, ;
            nU_d_zdr, ;
            nU_d_pms, ;
            nU_d_nez, ;
            nU_d_iz, ;
            nU_dn_pio, ;
            nU_dn_zdr, ;
            nU_dn_nez, ;
            nU_dn_dz, ;
            nUm_prih, ;
            nKLO, ;
            nL_odb, ;
            nPorOsn, ;
            nPorez, ;
            cR_rmj, ;
            lImaBPreko )

         SELECT ld
         SKIP

      ENDDO

   ENDDO

   RETURN
