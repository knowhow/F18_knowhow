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

STATIC __mj
STATIC __god
STATIC s_lExportXml := .T.
STATIC __ispl_s := 0



FUNCTION ld_mip_obrazac()

   LOCAL nC1 := 20
   LOCAL i
   LOCAL cTPNaz
   LOCAL nKrug := 1
   LOCAL cRj := Space( 60 )
   LOCAL cRJDef := Space( 2 )
   LOCAL cRadnik := fetch_metric( "ld_izvj_radnik", my_user(), Space( LEN_IDRADNIK ) )
   LOCAL cTipPrimIsplateUslugeIliDobra := Space( 100 )
   LOCAL cIdRj
   LOCAL cDopr10 := "10"
   LOCAL cDopr11 := "11"
   LOCAL cDopr12 := "12"
   LOCAL cDopr1X := "1X"
   LOCAL cDopr20 := "20"
   LOCAL cDopr21 := "21"
   LOCAL cDopr22 := "22"
   LOCAL cDopr2D := Space( 100 )
   LOCAL cDoprDod := Space( 100 )
   LOCAL cTipoviPrimanjaNeUlazeBeneficirani := Space( 100 )
   LOCAL cTipoviPrimanjaBolovanje := PadR( "18;", 100 )
   LOCAL cTipoviPrimanjaBolovanjePreko := PadR( "18;24;", 100 )
   LOCAL cObracun := gObracun
   LOCAL cStampaExport := "E"
   LOCAL nOper := 1
   LOCAL cIsplSaberi := "D"
   LOCAL cNule := "N"
   LOCAL cMipView := "N"
   LOCAL _pojed := .F.
   LOCAL cErr := ""
   LOCAL nX
   LOCAL cMj :=  fetch_metric( "ld_izv_mjesec_od", my_user(), gMjesec )
   LOCAL cGod := fetch_metric( "ld_izv_godina", my_user(), gGodina )

   IF !mip_tmp_tbl()
      RETURN .F.
   ENDIF

   cIdRj := gLDRadnaJedinica

   cPredNaz := PadR( fetch_metric( "obracun_plata_preduzece_naziv", NIL, "" ), 100 )
   cPredJMB := PadR( fetch_metric( "obracun_plata_preduzece_id_broj", NIL, "" ), 13 )
   cPredSDJ := PadR( fetch_metric( "obracun_plata_sifra_djelatnosti", NIL, "" ), 20 )
   cTipoviPrimanjaBolovanje := PadR( fetch_metric( "obracun_plata_mip_tip_pr_bolovanje", NIL, cTipoviPrimanjaBolovanje ), 100 )
   cTipoviPrimanjaNeUlazeBeneficirani := PadR( fetch_metric( "obracun_plata_mip_tip_pr_ne_benef", NIL, cTipoviPrimanjaNeUlazeBeneficirani ), 100 )

   cTipoviPrimanjaBolovanjePreko := PadR( fetch_metric( "obracun_plata_mip_tip_pr_bolovanje_42_dana", NIL, cTipoviPrimanjaBolovanjePreko ), 100 )
   cDoprDod := PadR( fetch_metric( "obracun_plata_mip_dodatni_dopr_ut", NIL, cDoprDod ), 100 )
   cRjDef := PadR( fetch_metric( "obracun_plata_mip_def_rj_isplata", NIL, cRjDef ), 2 )
   dDatPodn := Date()

   nPorGodina := 2011
   nBrZahtjeva := 1


   ol_o_tbl()

   Box( "#MIP OBRAZAC ZA RADNIKE", 22, 75 )

   @ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
   @ m_x + 2, m_y + 2 SAY "Za period:" GET cMj PICT "99"
   @ m_x + 2, Col() + 1 SAY "/" GET cGod PICT "9999"

   @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )

   @ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik VALID Empty( cRadnik ) .OR. P_RADN( @cRadnik )

   @ m_x + 6, m_y + 2 SAY " TIPOVI PRIMANJA:"
   @ m_x + 7, m_y + 2 SAY " .. isplate u usl. ili dobrima:" GET cTipPrimIsplateUslugeIliDobra PICT "@S30"
   @ m_x + 8, m_y + 2 SAY " .. ne ulaze u beneficirani:"  GET cTipoviPrimanjaNeUlazeBeneficirani PICT "@S30"
   @ m_x + 9, m_y + 2 SAY " .. bolovanje:" GET cTipoviPrimanjaBolovanje PICT "@S30"
   @ m_x + 10, m_y + 2 SAY8 " .. bolovanje preko 42 dana, trudničko:" GET cTipoviPrimanjaBolovanjePreko PICT "@S30"


   nX := 12
   @ m_x + nX, m_y + 2 SAY "   Doprinos iz pio: " GET cDopr10
   @ m_x + nX++, Col() + 2 SAY "na pio: " GET cDopr20

   @ m_x + nX, m_y + 2 SAY "   Doprinos iz zdr: " GET cDopr11
   @ m_x + nX, Col() + 2 SAY "na zdr: " GET cDopr21
   @ m_x + nX++, Col() + 2 SAY "dod.dopr.na zdr: " GET cDopr2D PICT "@S10"

   @ m_x + nX, m_y + 2 SAY "   Doprinos iz nez: " GET cDopr12
   @ m_x + nX++, Col() + 2 SAY "na nez: " GET cDopr22

   @ m_x + nX++, m_y + 2 SAY "Doprinos iz ukupni: " GET cDopr1X
   @ m_x + nX++, m_y + 2 SAY " dod.dopr. benef.: " GET cDoprDod PICT "@S30"

   @ m_x + nX, m_y + 2 SAY "Naziv preduzeca: " GET cPredNaz PICT "@S30"
   @ m_x + nX++, Col() + 1 SAY "JID: " GET cPredJMB

   @ m_x + nX++, m_y + 2 SAY "Sifra djelatnosti: " GET cPredSDJ PICT "@S20"
   @ m_x + nX, m_y + 2 SAY "Def.RJ" GET cRJDef
   @ m_x + nX, Col() + 2 SAY "Sabrati isplate za isti mj ?" GET cIsplSaberi VALID cIsplSaberi $ "DN" PICT "@!"
   @ m_x + nX, Col() + 2 SAY "obracun 0 ?" GET cNule VALID cNule $ "DN" PICT "@!"
   @ m_x + nX++, Col() + 2 SAY "pregled ?" GET cMipView VALID cMipView $ "DN" PICT "@!"

   @ m_x + nX++, m_y + 2 SAY "Stampa/Export ?" GET cStampaExport PICT "@!"  VALID cStampaExport $ "ES"

   READ

   IF cStampaExport == "E"
      @ m_x + nX++, m_y + 2 SAY "Datum podnosenja:" GET dDatPodn
      READ

   ENDIF

   dD_start := Date()
   dD_end := Date()

   mip_fix_datum_period( cMj, cGod, @dD_start, @dD_end )

   dPer := Date()

   mip_get_period( cMj, cGod, @dPer )

   clvbox()

   ESC_BCR

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   IF ld_provjeri_dat_isplate_za_mjesec( cGod, cMj, iif( !Empty( cRjDef ), cRjDef, NIL ) ) > 0

      IF !Empty( cRjDef )
         cErr := "Nije definisan datum isplate za radnu jedinicu '" + cRjDef +  "'."
      ELSE
         cErr := "Za pojedine radne jedinice nije definisan datum isplate.#Podesiti u <Obračun/Administracija obračuna>"
      ENDIF

      IF cStampaExport == "S"
         cErr += "#Obrazac će biti prikazan bez datuma isplate."
         MsgBeep( cErr )
      ELSE
         cErr += "#Molimo ispravite pa ponovo pokrenite ovu opciju."
         MsgBeep( cErr )
         RETURN .F.
      ENDIF

   ENDIF

   __mj := cMj
   __god := cGod

   IF cStampaExport == "S"
      s_lExportXml := .F.
   ELSE
      s_lExportXml := .T.
   ENDIF

   IF cIsplSaberi == "D"
      __ispl_s := 1
   ENDIF

   set_metric( "obracun_plata_preduzece_naziv", NIL, AllTrim( cPredNaz ) )
   set_metric( "obracun_plata_preduzece_id_broj", NIL, cPredJMB )
   set_metric( "obracun_plata_sifra_djelatnosti", NIL, cPredSDJ )
   set_metric( "obracun_plata_mip_tip_pr_bolovanje", NIL, AllTrim( cTipoviPrimanjaBolovanje ) )
   set_metric( "obracun_plata_mip_tip_pr_ne_benef", NIL, AllTrim( cTipoviPrimanjaNeUlazeBeneficirani ) )
   set_metric( "obracun_plata_mip_tip_pr_bolovanje_42_dana", NIL, AllTrim( cTipoviPrimanjaBolovanjePreko ) )
   set_metric( "obracun_plata_mip_dodatni_dopr_ut", NIL, AllTrim( cDoprDod ) )
   set_metric( "obracun_plata_mip_def_rj_isplata", NIL, cRjDef )

   IF !Empty( cRadnik )
      _pojed := .T.
      s_lExportXml := .F.
      MsgBeep( "Za jednog radnika se ne vrši export, samo štampa!" )
   ENDIF

   SELECT ld

   mip_sort( cRj, cGod, cMj, cRadnik, cObracun )

   mip_fill_data( cRj, cRjDef, cGod, cMj, cRadnik, ;
      cTipPrimIsplateUslugeIliDobra, cTipoviPrimanjaNeUlazeBeneficirani, cTipoviPrimanjaBolovanje, cTipoviPrimanjaBolovanjePreko, cDopr10, cDopr11, cDopr12, ;
      cDopr1X, cDopr20, cDopr21, cDopr22, cDoprDod, cDopr2D, cObracun, ;
      cNule )

   IF cMipView == "D"
      mip_view()
   ENDIF

   IF s_lExportXml
      nBrZahtjeva := g_br_zaht()
      mip_xml_export( cMj, cGod )
      MsgBeep( "Obradjeno " + AllTrim( Str( nBrZahtjeva ) ) + " radnika." )
   ELSE
      mip_print_odt( _pojed )
   ENDIF

   RETURN .T.



FUNCTION mip_sort( cRj, cGod, cMj, cRadnik, cObr )

   LOCAL cFilter := ""

   PRIVATE cObracun := cObr

   IF !Empty( cObr )
      cFilter += "obr == " + dbf_quote( cObr )
   ENDIF

   IF !Empty( cRj )

      IF !Empty( cFilter )
         cFilter += " .and. "
      ENDIF

      cFilter += Parsiraj( cRj, "IDRJ" )
   ENDIF

   IF !Empty( cFilter )
      SET FILTER TO &cFilter
      GO TOP
   ENDIF

   IF Empty( cRadnik )
      INDEX ON Str( field->godina ) + Str( field->mjesec ) + SortPrez( field->idradn ) + idrj TAG "MIP1" TO ( my_home() + "ld_tmp" )
      GO TOP
      SEEK Str( cGod, 4 ) + Str( cMj, 2 ) + cRadnik
   ELSE
      SET ORDER TO TAG ( TagVO( "2" ) )
      GO TOP
      SEEK Str( cGod, 4 ) + Str( cMj, 2 ) + cObracun + cRadnik
   ENDIF

   RETURN .T.



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

   IF !create_dbf_r_export( aDbf )
      RETURN .F.
   ENDIF

   O_R_EXP
   INDEX ON idradn + Str( godina, 4 ) + Str( mjesec, 2 ) + vr_ispl TAG "1"

   RETURN .T.


STATIC FUNCTION mip_fix_datum_period( nMj, nGod, dStart, dEnd )

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

   RETURN .T.


STATIC FUNCTION _xml_head()

   LOCAL cStr := '<?xml version="1.0" encoding="UTF-8"?><PaketniUvozObrazaca xmlns="urn:PaketniUvozObrazaca_V1_0.xsd">'

   xml_head( .T., cStr )

   RETURN .T.


STATIC FUNCTION mip_xml_export( nMjesec, nGodina )

   LOCAL _cre, cMsg, _id_br, _naziv, _adresa, _mjesto, cLokacijaExport
   LOCAL _a_files, _error
   LOCAL cOutputFile := ""

   IF !s_lExportXml
      RETURN .F.
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

   cLokacijaExport := my_home() + "export" + SLASH

   IF DirChange( cLokacijaExport ) != 0
      _cre := MakeDir ( cLokacijaExport )
      IF _cre != 0
         MsgBeep( "kreiranje " + cLokacijaExport + " neuspjesno ?!" )
         log_write( "dircreate err:" + cLokacijaExport, 6 )
         RETURN .F.
      ENDIF
   ENDIF

   DirChange( cLokacijaExport )


   mipmip_glavna_fill_xml( _id_br + ".xml" )

   cMsg := "Generacija obrasca završena.#"
   cMsg += "Fajl se nalazi na desktopu u folderu F18_dokumenti."

   MsgBeep( cMsg )

   DirChange( my_home() )

   my_close_all_dbf()


   cOutputFile := "mip_" + AllTrim( my_server_params()[ "database" ] ) + "_" + AllTrim( Str( nMjesec ) ) + "_" + AllTrim( Str( nGodina ) ) + ".xml"


   f18_copy_to_desktop( cLokacijaExport, _id_br + ".xml", cOutputFile ) // kopiraj fajl na desktop

   RETURN .T.



STATIC FUNCTION mipmip_glavna_fill_xml( cFile )

   LOCAL nTArea := Select()
   LOCAL nU_dn_pio
   LOCAL nU_dn_zdr
   LOCAL nU_dn_nez
   LOCAL nU_dn_dz
   LOCAL nU_prih
   LOCAL nU_dopr
   LOCAL nU_lodb
   LOCAL nU_porez
   LOCAL lImaBolovanjePreko42 := .F.
   LOCAL _id_br, _naziv, _adresa, _mjesto
   LOCAL cPredSDJ

   // otvori xml za upis
   create_xml( cFile )

   _xml_head()

   // ovo ne treba zato sto je u headeru sadrzan ovaj prvi sub-node !!!
   // <paketniuvozobrazaca>
   // xml_subnode("PaketniUvozObrazaca", .f.)

   _id_br  := fetch_metric( "org_id_broj", NIL, PadR( "<POPUNI>", 13 ) )
   _naziv  := fetch_metric( "org_naziv", NIL, PadR( "<POPUNI naziv>", 100 ) )
   _adresa := fetch_metric( "org_adresa", NIL, PadR( "<POPUNI adresu>", 100 ) )
   _mjesto   := fetch_metric( "org_mjesto", NIL, PadR( "<POPUNI mjesto>", 100 ) )
   cPredSDJ := fetch_metric( "obracun_plata_sifra_djelatnosti", NIL, Space( 20 ) )


   xml_subnode( "PodaciOPoslodavcu", .F. ) // <podacioposlodavcu>

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

   xml_subnode( "Dio1", .F. )  // dio1

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

      IF field->PRINT == "X"
         SKIP
         LOOP
      ENDIF


      cIdRadnikTekuci := field->idradn // po radniku


      SELECT radn
      SEEK cIdRadnikTekuci

      SELECT r_export

      nCnt := 0

      nR_sati := 0
      nR_satib := 0
      nRadnihSatiUvecanoTrajanje := 0
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

      lImaBolovanjePreko42 := .F.

      DO WHILE !Eof() .AND. field->idradn == cIdRadnikTekuci

         IF field->PRINT == "X"
            SKIP
            LOOP
         ENDIF

         cVr_ispl := field->vr_ispl
         cR_jmb := field->r_jmb
         cR_ime := field->r_ime
         dD_ispl := field->d_isp

         IF !lImaBolovanjePreko42
            nR_sati += field->r_sati
            nR_satib += field->r_satib
            nRadnihSatiUvecanoTrajanje += field->r_satit
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
         cSifraRadnogMjestaUvecanoTrajanje := field->r_rmj
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

            lImaBolovanjePreko42 := .T.

            nR_sati := field->r_sati
            nR_satib := field->r_satib

/* hernad ne razumijem?!
          --  IF nRadnihSatiUvecanoTrajanje <> 0 .AND. is_beneficirani_staz_redovan_rad()
               nRadnihSatiUvecanoTrajanje := field->r_sati
            ENDIF
*/

         ENDIF

         SKIP
      ENDDO

      xml_subnode( "PodaciOPrihodima", .F. )

      xml_node( "VrstaIsplate", to_xml_encoding( AllTrim( cVr_ispl ) ) )
      xml_node( "Jmb", AllTrim( cR_jmb ) )
      xml_node( "ImePrezime", to_xml_encoding( AllTrim( cR_ime ) ) )
      xml_node( "DatumIsplate", xml_date( dD_ispl ) )
      xml_node( "RadniSati", Str( nR_sati, 12, 2 ) )
      xml_node( "RadniSatiBolovanje", Str( nR_satib, 12, 2 ) )
      xml_node( "BrutoPlaca", Str( nBruto, 12, 2 ) )
      xml_node( "KoristiIDrugiOporeziviPrihodi", Str( nO_prih, 12, 2 ) )
      xml_node( "UkupanPrihod", Str( nU_opor, 12, 2 ) )
      xml_node( "IznosPIO", Str( nU_d_pio, 12, 2 ) )
      xml_node( "IznosZO", Str( nU_d_zdr, 12, 2 ) )
      xml_node( "IznosNezaposlenost", Str( nU_d_nez, 12, 2 ) )
      xml_node( "Doprinosi", Str( nU_d_iz, 12, 2 ) )
      xml_node( "PrihodUmanjenZaDoprinose", Str( nUm_prih, 12, 2 ) )
      xml_node( "FaktorLicnogOdbitka", Str( nR_klo, 12, 2 ) )
      xml_node( "IznosLicnogOdbitka", Str( nL_odb, 12, 2 ) )
      xml_node( "OsnovicaPoreza", Str( nOsnpor, 12, 2 ) )
      xml_node( "IznosPoreza", Str( nIznpor, 12, 2 ) )

      cTmp := "false"

      IF nRadnihSatiUvecanoTrajanje > 0 // beneficirani radni staz
         cTmp := "true"
         xml_node( "RadniSatiUT", Str( nRadnihSatiUvecanoTrajanje, 12, 2 ) )
         xml_node( "StepenUvecanja", Str( nR_stuv, 12, 0 ) )
         xml_node( "SifraRadnogMjestaUT", AllTrim( cSifraRadnogMjestaUvecanoTrajanje )  )
         xml_node( "DoprinosiPIOMIOzaUT", Str( nU_d_pms, 12, 2 )  )
         xml_node( "BeneficiraniStaz", AllTrim( cTmp ) ) // true or false

      ENDIF

      xml_node( "OpcinaPrebivalista", AllTrim( cR_opc ) )

      xml_subnode( "PodaciOPrihodima", .T. )

   ENDDO

   xml_subnode( "Dio2", .T. ) // kraj dio2


   xml_subnode( "Dio3", .F. ) // dio3
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


   xml_subnode( "Dio4IzjavaPoslodavca", .F. ) // dio4
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

   xml_subnode( "PaketniUvozObrazaca", .T. ) // zatvori <PaketniUvoz...>

   SELECT ( nTArea )

   close_xml()

   RETURN .T.



STATIC FUNCTION mip_get_period( cMj, cGod, dPer )

   LOCAL cTmp := ""

   cTmp += PadL( AllTrim( Str( cMj ) ), 2, "0" ) + "."
   cTmp += AllTrim( Str( cGod ) )

   dPer := CToD( cTmp )

   RETURN .T.


STATIC FUNCTION mip_print_odt( lPojedinacni )

   LOCAL _template := "ld_mip.odt"
   LOCAL _xml_file := my_home() + "data.xml"

   IF s_lExportXml
      RETURN .F.
   ENDIF

   IF lPojedinacni == .T.
      _template := "ld_pmip.odt"
   ENDIF

   mip_glavna_fill_xml( _xml_file )

   IF generisi_odt_iz_xml( _template, _xml_file )
      prikazi_odt()
   ENDIF

   RETURN .T.


STATIC FUNCTION mip_glavna_fill_xml( xml_file )

   LOCAL nTArea := Select()
   LOCAL lImaBolovanjePreko42 := .F.
   LOCAL nRadnihSatiUvecanoTrajanje

   create_xml( xml_file )
   xml_head()

   xml_subnode( "mip", .F. )


   xml_node( "p_naz", to_xml_encoding( AllTrim( cPredNaz ) ) ) // naziv firme
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

   // saberi totale
   DO WHILE !Eof()

      IF field->PRINT == "X"
         SKIP
         LOOP
      ENDIF

      ++nZaposl

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

      IF field->PRINT == "X"
         SKIP
         LOOP
      ENDIF


      cIdRadnikTekuci := field->idradn // po radniku

      xml_subnode( "radnik", .F. )

      xml_node( "rbr", Str( ++nCnt ) )
      xml_node( "visp", AllTrim( field->vr_ispl ) )
      xml_node( "r_ime", to_xml_encoding( AllTrim( field->r_ime ) ) )
      xml_node( "r_jmb", AllTrim( field->r_jmb ) )
      xml_node( "r_opc", to_xml_encoding( AllTrim( field->r_opc ) ) )

      nR_sati := 0
      nR_satib := 0
      nRadnihSatiUvecanoTrajanje := 0
      cStuv := ""
      nR_StUv := 0
      cSifraRadnogMjestaUvecanoTrajanje := ""
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

      lImaBolovanjePreko42 := .F.


      DO WHILE !Eof() .AND. field->idradn == cIdRadnikTekuci // provrti obracune

         IF field->PRINT == "X"
            SKIP
            LOOP
         ENDIF

         // za obrazac i treba zadnja isplata
         dD_isp := field->d_isp

         IF !lImaBolovanjePreko42
            nR_sati += field->r_sati
            nR_satib += field->r_satib
            nRadnihSatiUvecanoTrajanje += field->r_satit
         ENDIF

         nR_stuv := field->r_stuv
         cSifraRadnogMjestaUvecanoTrajanje := field->r_rmj
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

         IF field->bol_preko == "1" // ako je isti radnik kao i ranije, i bolovanje preko 42 dana, uzmi puni fond sati sa stavke bolovanja bol_preko = "1"

            lImaBolovanjePreko42 := .T.

            nR_sati := field->r_sati
            nR_satib := field->r_satib

/* hernad ne razumijem !
          --  IF nRadnihSatiUvecanoTrajanje <> 0 .AND. is_beneficirani_staz_redovan_rad()
               nRadnihSatiUvecanoTrajanje := field->r_sati
            ENDIF
*/

         ENDIF

         SKIP

      ENDDO

      cStUv := AllTrim( Str( nR_Stuv, 12, 0 ) ) + "/12"

      xml_node( "d_isp", DToC( dD_isp ) )
      xml_node( "r_sati", Str( nR_sati, 12, 2 ) )
      xml_node( "r_satib", Str( nR_satiB, 12, 2 ) )
      xml_node( "r_satit", Str( nRadnihSatiUvecanoTrajanje, 12, 2 ) ) // 21) Broj radnih sati sa uvećanim trajanjem ${rad.r_satit}
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
      xml_node( "r_rmj", cSifraRadnogMjestaUvecanoTrajanje )

      xml_subnode( "radnik", .T. )

   ENDDO


   xml_subnode( "mip", .T. ) // zatvori <mip>

   SELECT ( nTArea )
   close_xml() // zatvori xml fajl

   RETURN .T.


// ----------------------------------------------------------
// vraca string poreznog perioda
// ----------------------------------------------------------
STATIC FUNCTION g_por_per()

   LOCAL cRet := ""

   cRet += AllTrim( Str( __mj ) ) + "/" + AllTrim( Str( __god ) )
   cRet += " godine"

   RETURN cRet



FUNCTION mip_fill_data( cRj, cRjDef, cGod, cMj, ;
      cRadnik, ;
      cTipPrimIsplateUslugeIliDobra,  cTipoviPrimanjaNeUlazeBeneficirani, cTipoviPrimanjaBolovanje, cTipoviPrimanjaBolovanjePreko, ;
      cDopr10, cDopr11, cDopr12, ;
      cDopr1X, cDopr20, cDopr21, cDopr22, cDoprDod, cDopr2D, cObracun, cNule )

   LOCAL i
   LOCAL b
   LOCAL c
   LOCAL t
   LOCAL o
   LOCAL cPom
   LOCAL nPrimanjaUslugeIliDobraIznos, nPrimanjaUslugeIliDobraSati
   LOCAL nPrimanjaNeUlazeUBeneficiraniIznos, nPrimanjaNeUlazeUBeneficiraniSati
   LOCAL nBolovanjaSati, nBolovanjaIznos
   LOCAL nTrosk := 0
   LOCAL lInRS := .F.
   LOCAL nRadnihSatiUvecanoTrajanje // polje 21) set
   LOCAL lImaBovanjaPreko42, nBolovanjaPreko42Iznos := 0, nBolovanjaPreko42Sati := 0
   LOCAL nBrojRadnihSati
   LOCAL cTipRada, lDatIspl
   LOCAL cIdRadnikTekuci
   LOCAL m
   LOCAL aBeneficiraniRadniStaz
   LOCAL nGodina, nMjesec
   LOCAL nFondSati


   lDatIspl := .F.
   IF obracuni->( FieldPos( "DAT_ISPL" ) ) <> 0
      lDatIspl := .T.
   ENDIF

   SELECT ld

   DO WHILE !Eof()

      IF ld_date( field->godina, field->mjesec ) < ld_date( cGod, cMj )
         SKIP
         LOOP
      ENDIF

      IF ld_date( field->godina, field->mjesec ) > ld_date( cGod, cMj )
         SKIP
         LOOP
      ENDIF

      cIdRadnikTekuci := field->idradn
      nGodina := field->godina
      nMjesec := field->mjesec

      IF !Empty( cRadnik )
         IF cIdRadnikTekuci <> cRadnik
            SKIP
            LOOP
         ENDIF
      ENDIF

      cTipRada := get_ld_rj_tip_rada( ld->idradn, ld->idrj )
      lInRS := radnik_iz_rs( radn->idopsst, radn->idopsrad )

      ParObr( ld->mjesec, ld->godina, ld->obr, ld->idrj ) // samo pozicionira bazu PAROBR na odgovarajuci zapis

      SELECT radn
      SEEK cIdRadnikTekuci

     //https://redmine.bring.out.ba/projects/klijenti/wiki/Modul_LD
      IF !( cTipRada $ " #I#N" ) // ako nije " " ili "I" ili "N" - neto-neto
         MsgBeep( "preskace se radnik " + ld->idradn + " jer tip rada nije 'I/N/ ' !")
         SELECT ld
         SKIP
         LOOP
      ENDIF

      SELECT ld

      nBrojRadnihSati := 0
      nSatiB := 0
      nRadnihSatiUvecanoTrajanje := 0
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
      nPrimanjaUslugeIliDobraIznos := 0
      nPrimanjaUslugeIliDobraSati := 0
      nPrimanjaNeUlazeUBeneficiraniIznos := 0
      nPrimanjaNeUlazeUBeneficiraniSati := 0
      nBolovanjaSati := 0
      nBolovanjaIznos := 0

      cR_ime := ""
      cR_jmb := ""
      cR_opc := ""
      cSifraRadnogMjestaUvecanoTrajanje := ""

      DO WHILE !Eof() .AND. field->idradn == cIdRadnikTekuci

         IF ld_date( field->godina, field->mjesec ) <  ld_date( cGod, cMj )
            SKIP
            LOOP
         ENDIF

         IF ld_date( field->godina, field->mjesec ) > ld_date( cGod, cMj )
            SKIP
            LOOP
         ENDIF

         cRadJed := ld->idrj // radna jedinica

         SELECT radn
         cR_ime := AllTrim( radn->ime ) + " " + AllTrim( radn->naz )
         cR_jmb := AllTrim( radn->matbr )
         cR_opc := g_ops_code( radn->idopsst )
         cSifraRadnogMjestaUvecanoTrajanje := ""

         SELECT ld
         cTipRada := get_ld_rj_tip_rada( ld->idradn, ld->idrj ) // uvijek provjeri tip rada, ako ima vise obracuna
         cTrosk := radn->trosk
         lInRS := radnik_iz_rs( radn->idopsst, radn->idopsrad )

         IF !( cTipRada $ " #I#N" )
            SKIP
            LOOP
         ENDIF

         ParObr( ld->mjesec, ld->godina, ld->obr, ld->idrj )
         nFondSati := parobr->k1 // puni fond sati za ovaj mjesec

         nPrimanjaUslugeIliDobraIznos := 0
         // nPrimanjaNeUlazeUBeneficiraniIznos := 0
         nBolovanjaSati := 0

         sum_primanja_za_tipove_primanja( cTipPrimIsplateUslugeIliDobra, @nPrimanjaUslugeIliDobraIznos, @nPrimanjaUslugeIliDobraSati )
         sum_primanja_za_tipove_primanja( cTipoviPrimanjaNeUlazeBeneficirani, @nPrimanjaNeUlazeUBeneficiraniIznos, @nPrimanjaNeUlazeUBeneficiraniSati )
         sum_primanja_za_tipove_primanja( cTipoviPrimanjaBolovanje, @nBolovanjaIznos, @nBolovanjaSati )

         lImaBovanjaPreko42 := .F. // provjeri da li ima bolovanja preko 42 dana ili trudnickog bolovanja
         sum_primanja_za_tipove_primanja( cTipoviPrimanjaBolovanjePreko, @nBolovanjaPreko42Iznos, @nBolovanjaPreko42Sati )
         IF Round( nBolovanjaPreko42Iznos, 2 ) != 0 .OR. Round( nBolovanjaPreko42Sati, 2 ) != 0
            lImaBovanjaPreko42 := .T.
         ENDIF

         nNeto := ld->uneto
         nKLO := g_klo( ld->ulicodb )
         nL_odb := ld->ulicodb
         nBrojRadnihSati := ld->usati
         nSatiB := nBolovanjaSati

         IF lImaBovanjaPreko42  // uzmi puni fond sati
            nBrojRadnihSati := nFondSati
            nSatiB := nFondSati
            // bolovanje preko42d nije unutar neto
            nNeto += 0.0000001
         ENDIF

         nRadnihSatiUvecanoTrajanje := 0

         IF ( nBolovanjaIznos != 0 ) .OR. ( nBolovanjaSati != 0 )

            // nNeto := ( nNeto - nPrimanjaNeUlazeUBeneficiraniIznos )  - ovo ne postoji
            // nBrojRadnihSati := ( nBrojRadnihSati - nPrimanjaNeUlazeUBeneficiraniSati ) // tipovi primanja koji ne ulaze u sate
            nBrojRadnihSati := nBrojRadnihSati - nBolovanjaSati
         ENDIF

         nBruto := bruto_osn( nNeto, cTipRada, nL_odb )
         nMBruto := nBruto


         IF calc_mbruto() // prvo provjeri hoces li racunati mbruto
            nMBruto := min_bruto( nBruto, field->usati ) // minimalni bruto
         ENDIF


         IF nMBruto <= 0 .AND. cNule == "N" // ovo preskoci, nema ovdje GIP-a
            SELECT ld
            SKIP
            LOOP
         ENDIF


         IF nPrimanjaUslugeIliDobraIznos > 0 // bruto primanja u uslugama ili dobrima, za njih posebno izracunaj bruto osnovicu
            nBrDobra := bruto_osn( nPrimanjaUslugeIliDobraIznos, cTipRada, nL_odb )
         ENDIF

         nBr_benef := 0
         nU_d_pms := 0
         cBen_stopa := ""

         aBeneficiraniRadniStaz := {}

         IF is_radn_k4_bf_ide_u_benef_osnovu()

            // altd()
            // IF is_beneficirani_staz_redovan_rad()
            nRadnihSatiUvecanoTrajanje := nBrojRadnihSati - nPrimanjaNeUlazeUBeneficiraniSati
            // ELSE
            // nRadnihSatiUvecanoTrajanje := field->usati
            // ENDIF

            nStUv := benefstepen() // benef.stepen
            cBen_stopa := AllTrim( radn->k3 )

            cSifraRadnogMjestaUvecanoTrajanje := AllTrim( radn->ben_srmj ) // set sifra stopa beneficiranog radnog staza
            cFFTmp := gBFForm
            gBFForm := StrTran( gBFForm, "_", "" )

            nBr_Benef := bruto_osn( nNeto - iif( !Empty( gBFForm ), &gBFForm, 0 ), cTipRada, nL_odb )
            add_to_a_benef( @aBeneficiraniRadniStaz, cBen_stopa, nStUv, nBr_Benef )

            gBFForm := cFFtmp // vrati parametre

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


         nU_d_iz := Round( nU_d_pio + nU_d_zdr + nU_d_nez, 4 ) // zbirni je zbir ova tri doprinosa


         IF !Empty( cDoprDod ) // dodatni doprinosi iz beneficije

            aDodatniDoprinosiIzBeneficije := TokToNiz( cDoprDod, ";" )

            FOR m := 1 TO Len( aDodatniDoprinosiIzBeneficije )
               nDoprTmp := get_dopr( aDodatniDoprinosiIzBeneficije[ m ], cTipRada )
               IF !Empty( dopr->idkbenef ) .AND. cBen_stopa == dopr->idkbenef
                  nU_d_pms += Round( get_benef_osnovica( aBeneficiraniRadniStaz, dopr->idkbenef ) * nDoprTmp / 100, 4 )
               ENDIF

            NEXT
         ENDIF


         IF !Empty( cDopr2D ) // dodatni doprinosi na

            aDodatniDoprinosiNaZaBeneficiju := TokToNiz( cDopr2D, ";" )
            FOR c := 1 TO Len( aDodatniDoprinosiNaZaBeneficiju )
               nDoprTmp := get_dopr( aDodatniDoprinosiNaZaBeneficiju[ c ], cTipRada )
               IF !Empty( dopr->idkbenef ) .AND. cBen_stopa == dopr->idkbenef
                  nU_dn_dz += Round( nBr_benef * nDoprTmp / 100, 4 )
               ELSE
                  nU_dn_dz += Round( nMBruto * nDoprTmp / 100, 4 )
               ENDIF
            NEXT
         ENDIF

         nUM_prih := ( nBruto - nU_d_iz )
         nPorOsn := ( nBruto - nU_d_iz ) - nL_odb


         IF !radn_oporeziv( radn->id, ld->idrj ) .OR. ( nBruto - nU_d_iz ) < nL_odb // ako je neoporeziv radnik, nema poreza
            nPorOsn := 0
         ENDIF


         nPorez := izr_porez( nPorOsn, "B" )  // porez je ?

         SELECT ld
         nNaRuke := Round( nBruto - nU_d_iz - nPorez + nTrosk, 2 ) // na ruke je

         nIsplata := nNaRuke

         IF cTipRada $ " #I#N#"  // da li se radi o minimalcu ?
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
            cTmpRj := field->idrj // radna jedinica
            IF !Empty( cRJDef )
               cTmpRj := cRJDef
            ENDIF

            dDatIspl := g_isp_date( cTmpRJ, field->godina, field->mjesec, cObr, @nMjIspl, @cIsplZa, @cVrstaIspl )
         ENDIF


         IF Empty( field->v_ispl )  // vrstu isplate cu uzeti iz LD->V_ISPL
            cVrstaIspl := "1"
         ELSE
            cVrstaIspl := AllTrim( field->v_ispl )
         ENDIF

         mip_insert_record_r_export( cIdRadnikTekuci, ;
            cRadJed, ;
            nGodina, ;
            nMjesec, ;
            cTipRada, ;
            cVrstaIspl, ;
            cR_ime, ;
            cR_jmb, ;
            cR_opc, ;
            dDatIspl, ;
            nBrojRadnihSati, ;
            nSatiB, ;
            nRadnihSatiUvecanoTrajanje, ;
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
            cSifraRadnogMjestaUvecanoTrajanje, ;
            lImaBovanjaPreko42 )

         SELECT ld
         SKIP

      ENDDO

   ENDDO

   RETURN .T.




STATIC FUNCTION mip_insert_record_r_export( cRadnik, cIdRj, nGodina, nMjesec, ;
      cTipRada, cVrIspl, cR_ime, cR_jmb, cR_opc, dDatIsplate, ;
      nBrojRadnihSati, nSatiB, nRadnihSatiUvecanoTrajanje, nStUv, nBruto, nO_prih, nU_opor, ;
      nU_d_pio, nU_d_zdr, nU_d_pms, nU_d_nez, nU_d_iz, ;
      nU_dn_pio, nU_dn_zdr, nU_dn_nez, nU_dn_dz, ;
      nUm_prih, nKLO, nLODB, nOsn_por, nIzn_por, ;
      cSifraRadnogMjestaUvecanoTrajanje, lBolPreko42 )

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
   REPLACE r_sati WITH nBrojRadnihSati // 6)  broj radnih sati ${rad.r_sati}
   REPLACE r_satib WITH nSatiB
   REPLACE r_satit WITH nRadnihSatiUvecanoTrajanje
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
   REPLACE r_rmj WITH cSifraRadnogMjestaUvecanoTrajanje // 23) Šifra radnog mjesta sa uvećanim trajanjem ${rad.r_rmj}, radn->ben_srmj

   IF lBolPreko42
      REPLACE bol_preko WITH "1"
   ELSE
      REPLACE bol_preko WITH "0"
   ENDIF

   SELECT ( nTArea )

   RETURN .T.
