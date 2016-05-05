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


STATIC __mj_od
STATIC __mj_do
STATIC __god_od
STATIC __god_do
STATIC __xml := 0

// ---------------------------------------
// otvara potrebne tabele
// ---------------------------------------
FUNCTION ol_o_tbl()

   O_OBRACUNI
   O_PAROBR
   O_PARAMS
   O_LD_RJ
   O_RADN
   O_KBENEF
   O_VPOSLA
   O_TIPPR
   O_KRED
   O_DOPR
   O_POR
   O_LD

   RETURN .T.

// ---------------------------------------------------------
// sortiranje tabele LD
// ---------------------------------------------------------
FUNCTION ol_sort( cRj, cGod_od, cGod_do, cMj_od, cMj_do, ;
      cRadnik, cTipRpt, cObr )

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
      SET FILTER to &cFilter
      GO TOP
   ENDIF

   IF Empty( cRadnik )
      IF cTipRpt $ "1#2"
         INDEX ON SortPrez( idradn ) + Str( godina ) + Str( mjesec ) + idrj TO "tmpld"
         GO TOP
      ELSE
         INDEX ON Str( godina ) + Str( mjesec ) + SortPrez( idradn ) + idrj TO "tmpld"
         GO TOP
         SEEK Str( cGod_od, 4 ) + Str( cMj_od, 2 ) + cRadnik
      ENDIF
   ELSE
      SET ORDER TO tag ( TagVO( "2" ) )
      GO TOP
      SEEK Str( cGod_od, 4 ) + Str( cMj_od, 2 ) + cObracun + cRadnik
   ENDIF

   RETURN


// ---------------------------------------------
// upisivanje podatka u pomocnu tabelu za rpt
// ---------------------------------------------
STATIC FUNCTION _ins_tbl( cRadnik, cIdRj, cTipRada, cNazIspl, dDatIsplate, ;
      nMjesec, nMjisp, cIsplZa, cVrsta, ;
      nGodina, nPrihod, ;
      nPrihOst, nBruto, nMBruto, nTrosk, nDop_u_st, nDopPio, ;
      nDopZdr, nDopNez, nDop_uk, nNeto, nKLO, ;
      nLOdb, nOsn_por, nIzn_por, nUk, nUSati, nIzn1, nIzn2, ;
      nIzn3, nIzn4, nIzn5 )

   LOCAL nTArea := Select()

   O_R_EXP
   SELECT r_export
   APPEND BLANK

   REPLACE tiprada WITH cTipRada
   REPLACE idrj WITH cIdRj
   REPLACE idradn WITH cRadnik
   REPLACE naziv WITH cNazIspl
   REPLACE mjesec WITH nMjesec
   REPLACE mj_opis WITH ld_naziv_mjeseca( nMjIspl, nGodina, .F., .T. )
   REPLACE mj_naz WITH ld_naziv_mjeseca( nMjIspl, nGodina, .F., .F. )
   REPLACE mj_ispl WITH nMjIspl
   REPLACE ispl_za WITH cIsplZa
   REPLACE vr_ispl WITH cVrsta
   REPLACE godina WITH nGodina
   REPLACE datispl WITH dDatIsplate
   REPLACE prihod WITH nPrihod
   REPLACE prihost WITH nPrihOst
   REPLACE bruto WITH nBruto
   REPLACE mbruto WITH nMBruto
   REPLACE trosk WITH nTrosk
   REPLACE dop_u_st WITH nDop_u_st
   REPLACE dop_pio WITH nDopPio
   REPLACE dop_zdr WITH nDopZdr
   REPLACE dop_nez WITH nDopNez
   REPLACE dop_uk WITH nDop_uk
   REPLACE neto WITH nNeto
   REPLACE klo WITH nKlo
   REPLACE l_odb WITH nLOdb
   REPLACE osn_por WITH nOsn_Por
   REPLACE izn_por WITH nIzn_Por
   REPLACE ukupno WITH nUk
   REPLACE sati WITH nUSati

   IF nIzn1 <> nil
      REPLACE tp_1 WITH nIzn1
   ENDIF
   IF nIzn2 <> nil
      REPLACE tp_2 WITH nIzn2
   ENDIF
   IF nIzn3 <> nil
      REPLACE tp_3 WITH nIzn3
   ENDIF
   IF nIzn4 <> nil
      REPLACE tp_4 WITH nIzn4
   ENDIF
   IF nIzn5 <> nil
      REPLACE tp_5 WITH nIzn5
   ENDIF


   SELECT ( nTArea )

   RETURN



// ---------------------------------------------
// kreiranje pomocne tabele
// ---------------------------------------------
FUNCTION ol_tmp_tbl()

   LOCAL aDbf := {}

   AAdd( aDbf, { "IDRADN", "C", 6, 0 } )
   AAdd( aDbf, { "IDRJ", "C", 2, 0 } )
   AAdd( aDbf, { "TIPRADA", "C", 1, 0 } )
   AAdd( aDbf, { "NAZIV", "C", 15, 0 } )
   AAdd( aDbf, { "DATISPL", "D", 8, 0 } )
   AAdd( aDbf, { "MJESEC", "N", 2, 0 } )
   AAdd( aDbf, { "MJ_NAZ", "C", 15, 0 } )
   AAdd( aDbf, { "MJ_OPIS", "C", 15, 0 } )
   AAdd( aDbf, { "MJ_ISPL", "N", 2, 0 } )
   AAdd( aDbf, { "ISPL_ZA", "C", 50, 0 } )
   AAdd( aDbf, { "VR_ISPL", "C", 50, 0 } )
   AAdd( aDbf, { "GODINA", "N", 4, 0 } )
   AAdd( aDbf, { "PRIHOD", "N", 12, 2 } )
   AAdd( aDbf, { "PRIHOST", "N", 12, 2 } )
   AAdd( aDbf, { "BRUTO", "N", 12, 2 } )
   AAdd( aDbf, { "MBRUTO", "N", 12, 2 } )
   AAdd( aDbf, { "TROSK", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_U_ST", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_PIO", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_ZDR", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_NEZ", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_UK", "N", 12, 4 } )
   AAdd( aDbf, { "NETO", "N", 12, 2 } )
   AAdd( aDbf, { "KLO", "N", 5, 2 } )
   AAdd( aDbf, { "L_ODB", "N", 12, 2 } )
   AAdd( aDbf, { "OSN_POR", "N", 12, 2 } )
   AAdd( aDbf, { "IZN_POR", "N", 12, 2 } )
   AAdd( aDbf, { "UKUPNO", "N", 12, 2 } )
   AAdd( aDbf, { "SATI", "N", 12, 2 } )
   AAdd( aDbf, { "TP_1", "N", 12, 2 } )
   AAdd( aDbf, { "TP_2", "N", 12, 2 } )
   AAdd( aDbf, { "TP_3", "N", 12, 2 } )
   AAdd( aDbf, { "TP_4", "N", 12, 2 } )
   AAdd( aDbf, { "TP_5", "N", 12, 2 } )

   t_exp_create( aDbf )

   O_R_EXP
   // index on ......
   INDEX ON idradn + Str( godina, 4 ) + Str( mjesec, 2 ) TAG "1"

   RETURN


FUNCTION ld_olp_gip_obrazac()

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
   LOCAL cTipRpt := "1"
   LOCAL cTP_off := Space( 100 )
   LOCAL cObracun := gObracun
   LOCAL cWinPrint := "E"
   LOCAL nOper := 1

   // kreiraj pomocnu tabelu
   ol_tmp_tbl()

   cIdRj := gRj
   cMj_od := gMjesec
   cMj_do := gMjesec
   cGod_od := gGodina
   cGod_do := gGodina

   cPredNaz := Space( 50 )
   cPredAdr := Space( 50 )
   cPredJMB := Space( 13 )

   nPorGodina := 2009
   cOperacija := "Novi"
   dDatUnosa := Date()
   dDatPodnosenja := Date()
   nBrZahtjeva := 1

   // otvori tabele
   ol_o_tbl()

   // upisi parametre...
   cPredNaz := PadR( fetch_metric( "obracun_plata_preduzece_naziv", NIL, cPredNaz ), 100 )
   cPredAdr := PadR( fetch_metric( "obracun_plata_preduzece_adresa", NIL, cPredAdr ), 100 )
   cPredJMB := PadR( fetch_metric( "obracun_plata_preduzece_id_broj", NIL, cPredJMB ), 13 )

   Box( "#OBRACUNSKI LISTOVI RADNIKA", 17, 75 )

   @ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
   @ m_x + 2, m_y + 2 SAY "Period od:" GET cMj_od PICT "99"
   @ m_x + 2, Col() + 1 SAY "/" GET cGod_od PICT "9999"
   @ m_x + 2, Col() + 1 SAY "do:" GET cMj_do PICT "99"
   @ m_x + 2, Col() + 1 SAY "/" GET cGod_do PICT "9999"

   IF lViseObr
      @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF

   @ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
      VALID Empty( cRadnik ) .OR. P_RADN( @cRadnik )
   @ m_x + 5, m_y + 2 SAY "    Isplate u usl. ili dobrima:" ;
      GET cPrimDobra PICT "@S30"
   @ m_x + 6, m_y + 2 SAY "Tipovi koji ne ulaze u obrazac:" ;
      GET cTP_off PICT "@S30"
   @ m_x + 7, m_y + 2 SAY "   Doprinos iz pio: " GET cDopr10
   @ m_x + 8, m_y + 2 SAY "   Doprinos iz zdr: " GET cDopr11
   @ m_x + 9, m_y + 2 SAY "   Doprinos iz nez: " GET cDopr12
   @ m_x + 10, m_y + 2 SAY "Doprinos iz ukupni: " GET cDopr1X

   @ m_x + 12, m_y + 2 SAY "Naziv preduzeca: " GET cPredNaz PICT "@S30"
   @ m_x + 12, Col() + 1 SAY "JID: " GET cPredJMB
   @ m_x + 13, m_y + 2 SAY "Adresa: " GET cPredAdr PICT "@S30"

   @ m_x + 15, m_y + 2 SAY "(1) OLP-1021 / (2) GIP-1022 / (3,4) AOP:" GET cTipRpt ;
      VALID cTipRpt $ "1234"

   @ m_x + 15, Col() + 2 SAY "def.rj" GET cRJDef

   @ m_x + 15, Col() + 2 SAY "st./exp.(S/E)?" GET cWinPrint ;
      VALID cWinPrint $ "SE" PICT "@!"

   READ

   dPerOd := Date()
   dPerDo := Date()

   // daj period od - do
   g_per_oddo( cMj_od, cGod_od, cMj_do, cGod_do, @dPerOd, @dPerDo )

   IF cWinPrint == "E"

      nPorGodina := cGod_do

      @ m_x + 16, m_y + 2 SAY "P.godina" GET nPorGodina ;
         PICT "9999"
      @ m_x + 16, Col() + 2 SAY "Dat.podnos." GET dDatPodnosenja
      @ m_x + 16, Col() + 2 SAY "Dat.unosa" GET dDatUnosa

      @ m_x + 17, m_y + 2 SAY "operacija: 1 (novi) 2 (izmjena) 3 (brisanje)" ;
         GET nOper PICT "9"

      READ
   ENDIF

   cOperacija := g_operacija( nOper )

   clvbox()

   ESC_BCR

   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   // staticke
   __mj_od := cMj_od
   __mj_do := cMj_do
   __god_od := cGod_od
   __god_do := cGod_do

   IF cWinPrint == "S"
      __xml := 1
   ELSE
      __xml := 0
   ENDIF

   // upisi parametre...
   set_metric( "obracun_plata_preduzece_naziv", NIL, AllTrim( cPredNaz ) )
   set_metric( "obracun_plata_preduzece_adresa", NIL, AllTrim( cPredAdr ) )
   set_metric( "obracun_plata_preduzece_id_broj", NIL, cPredJMB )

   SELECT ld

   // sortiraj tabelu i postavi filter
   ol_sort( cRj, cGod_od, cGod_do, cMj_od, cMj_do, cRadnik, cTipRpt, cObracun )

   // nafiluj podatke obracuna
   ol_fill_data( cRj, cRjDef, cGod_od, cGod_do, cMj_od, cMj_do, cRadnik, ;
      cPrimDobra, cTP_off, cDopr10, cDopr11, cDopr12, cDopr1X, cTipRpt, ;
      cObracun )

   // stampa izvjestaja xml/oo3

   IF __xml == 1
      _xml_print( cTipRpt )
   ELSE
      nBrZahtjeva := g_br_zaht()
      _xml_export( cTipRpt, cMj_od, cGod_od )
      MsgBeep( "Obradjeno " + AllTrim( Str( nBrZahtjeva ) ) + " zahtjeva." )
   ENDIF

   RETURN


// --------------------------------------
// vraca period od-do
// --------------------------------------
STATIC FUNCTION g_per_oddo( cMj_od, cGod_od, cMj_do, cGod_do, ;
      dPerOd, dPerDo )

   LOCAL cTmp := ""

   cTmp += "01" + "."
   cTmp += PadL( AllTrim( Str( cMj_od ) ), 2, "0" ) + "."
   cTmp += AllTrim( Str( cGod_od ) )

   dPerOd := CToD( cTmp )

   cTmp := g_day( cMj_do ) + "."
   cTmp += PadL( AllTrim( Str( cMj_do ) ), 2, "0" ) + "."
   cTmp += AllTrim( Str( cGod_do ) )

   dPerDo := CToD( cTmp )

   RETURN

// ------------------------------------------
// vraca koliko dana ima u mjesecu
// ------------------------------------------
FUNCTION g_day( nMonth )

   LOCAL cDay := "31"

   DO CASE
   CASE nMonth = 1
      cDay := "31"
   CASE nMonth = 2
      cDay := "28"
   CASE nMonth = 3
      cDay := "31"
   CASE nMonth = 4
      cDay := "30"
   CASE nMonth = 5
      cDay := "31"
   CASE nMonth = 6
      cDay := "30"
   CASE nMonth = 7
      cDay := "31"
   CASE nMonth = 8
      cDay := "31"
   CASE nMonth = 9
      cDay := "30"
   CASE nMonth = 10
      cDay := "31"
   CASE nMonth = 11
      cDay := "30"
   CASE nMonth = 12
      cDay := "31"

   ENDCASE

   RETURN cDay



// -------------------------------------
// vraca vrstu isplate
// -------------------------------------
FUNCTION g_v_ispl( cId )

   LOCAL cIspl := "Plata"

   IF cId == "1"
      cIspl := "Plata"
   ELSEIF cId == "2"
      cIspl := "Plata + ostalo"
   ENDIF

   RETURN cIspl



STATIC FUNCTION g_operacija( nOper )

   LOCAL cOperacija := ""

   IF nOper = 1
      cOperacija := "Novi"
   ELSEIF nOper = 2
      cOperacija := "Izmjena"
   ELSEIF nOper = 3
      cOperacija := "Brisanje"
   ELSE
      cOperacija := "Novi"
   ENDIF

   RETURN cOperacija


// -----------------------------------------------
// vraca broj zahtjeva
// -----------------------------------------------
FUNCTION g_br_zaht()

   LOCAL nTArea := Select()
   LOCAL cT_radnik
   LOCAL nCnt
   LOCAL nRet := 0

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      cT_radnik := field->idradn
      nCnt := 0

      DO WHILE !Eof() .AND. field->idradn == cT_radnik
         nCnt := 1
         SKIP
      ENDDO

      nRet += nCnt

   ENDDO

   SELECT ( nTArea )

   RETURN nRet



// ----------------------------------------
// export xml-a
// ----------------------------------------
STATIC FUNCTION _xml_export( cTip, mjesec, godina )

   LOCAL cMsg
   LOCAL _id_br, _naziv, _adresa, _mjesto
   LOCAL _lokacija, _cre, _error, _a_files
   LOCAL _output_file := ""

   IF __xml == 1
      RETURN
   ENDIF

   IF cTip == "1"
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
   cMsg += "Fajl se nalazi na desktopu u folderu F18_dokumenti"

   MsgBeep( cMsg )

   DirChange( my_home() )

   my_close_all_dbf()

   _output_file := "gip_" + AllTrim( my_server_params()[ "database" ] ) + "_" + ;
      AllTrim( Str( mjesec ) ) + "_" + AllTrim( Str( godina ) ) + ".xml"

   // kopiraj fajl na desktop
   f18_copy_to_desktop( _lokacija, _id_br + ".xml", _output_file )

   RETURN


// ----------------------------------------
// stampa xml-a
// ----------------------------------------
STATIC FUNCTION _xml_print( tip )

   LOCAL _template
   LOCAL _xml_file := my_home() + "data.xml"

   IF __xml == 0
      RETURN
   ENDIF

   _fill_xml( tip, _xml_file )

   DO CASE
   CASE tip == "1"
      _template := "ld_olp.odt"
   CASE tip == "2"
      _template := "ld_gip.odt"
   CASE tip == "3"
      _template := "ld_aop.odt"
   CASE tip == "4"
      _template := "ld_aop2.odt"
   ENDCASE

   IF generisi_odt_iz_xml( _template, _xml_file )
      prikazi_odt()
   ENDIF

   RETURN


// ------------------------------------
// header za export
// ------------------------------------
STATIC FUNCTION _xml_head()

   LOCAL cStr := '<?xml version="1.0" encoding="UTF-8"?><PaketniUvozObrazaca xmlns="urn:PaketniUvozObrazaca_V1_0.xsd">'

   xml_head( .T., cStr )

   RETURN



// --------------------------------------------
// filuje xml fajl sa podacima za export
// --------------------------------------------
STATIC FUNCTION _fill_e_xml( file_name )

   LOCAL nTArea := Select()
   LOCAL nT_prih := 0
   LOCAL nT_pros := 0
   LOCAL nT_bruto := 0
   LOCAL nT_neto := 0
   LOCAL nT_poro := 0
   LOCAL nT_pori := 0
   LOCAL nT_dop_s := 0
   LOCAL nT_dop_u := 0
   LOCAL nT_d_zdr := 0
   LOCAL nT_d_pio := 0
   LOCAL nT_d_nez := 0
   LOCAL nT_bbd := 0
   LOCAL nT_klo := 0
   LOCAL nT_lodb := 0

   // otvori xml za upis
   create_xml( file_name )

   // upisi header
   _xml_head()

   // ovo ne treba zato sto je u headeru sadrzan ovaj prvi sub-node !!!
   // <paketniuvozobrazaca>
   // xml_subnode("PaketniUvozObrazaca", .f.)

   // <podacioposlodavcu>
   xml_subnode( "PodaciOPoslodavcu", .F. )

   // naziv firme
   xml_node( "JIBPoslodavca", AllTrim( cPredJmb ) )
   xml_node( "NazivPoslodavca", to_xml_encoding( AllTrim( cPredNaz ) ) )
   xml_node( "BrojZahtjeva", Str( nBrZahtjeva ) )
   xml_node( "DatumPodnosenja", xml_date( dDatPodnosenja ) )

   xml_subnode( "PodaciOPoslodavcu", .T. )

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      // po radniku
      cT_radnik := field->idradn

      // pronadji radnika u sifrarniku
      SELECT radn
      SEEK cT_radnik

      SELECT r_export

      xml_subnode( "Obrazac1022", .F. )

      xml_subnode( "Dio1PodaciOPoslodavcuIPoreznomObvezniku", .F. )

      xml_node( "JIBJMBPoslodavca", AllTrim( cPredJmb ) )
      xml_node( "Naziv", to_xml_encoding( AllTrim( cPredNaz ) ) )
      xml_node( "AdresaSjedista", to_xml_encoding( AllTrim( cPredAdr ) ) )
      xml_node( "JMBZaposlenika", AllTrim( radn->matbr ) )
      xml_node( "ImeIPrezime", to_xml_encoding( AllTrim( radn->ime ) + " " + ;
         AllTrim( radn->naz ) ) )
      xml_node( "AdresaPrebivalista", to_xml_encoding( AllTrim( radn->streetname ) + ;
         " " + AllTrim( radn->streetnum ) ) )
      xml_node( "PoreznaGodina", Str( nPorGodina ) )

      xml_node( "PeriodOd", xml_date( dPerOd ) )
      xml_node( "PeriodDo", xml_date( dPerDo ) )

      xml_subnode( "Dio1PodaciOPoslodavcuIPoreznomObvezniku", .T. )

      xml_subnode( "Dio2PodaciOPrihodimaDoprinosimaIPorezu", .F. )

      nT_prih := 0
      nT_pros := 0
      nT_bruto := 0
      nT_neto := 0
      nT_poro := 0
      nT_pori := 0
      nT_dop_s := 0
      nT_dop_u := 0
      nT_d_zdr := 0
      nT_d_pio := 0
      nT_d_nez := 0
      nT_bbd := 0
      nT_klo := 0
      nT_lodb := 0

      nCnt := 0

      DO WHILE !Eof() .AND. field->idradn == cT_radnik

         // ukupni doprinosi
         REPLACE field->dop_uk WITH field->dop_pio + ;
            field->dop_nez + field->dop_zdr

         REPLACE field->osn_por with ( field->bruto - field->dop_uk ) - ;
            field->l_odb

         // ako je neoporeziv radnik, nema poreza
         IF !radn_oporeziv( field->idradn, field->idrj ) .OR. ;
               field->osn_por < 0
            REPLACE field->osn_por WITH 0
         ENDIF

         IF field->osn_por > 0
            REPLACE field->izn_por WITH field->osn_por * 0.10
         ELSE
            REPLACE field->izn_por WITH 0
         ENDIF

         REPLACE field->neto with ( field->bruto - field->dop_uk ) - ;
            field->izn_por

         IF field->tiprada $ " #I#N#"
            REPLACE field->neto with ;
               min_neto( field->neto, field->sati )
         ENDIF


         xml_subnode( "PodaciOPrihodimaDoprinosimaIPorezu", .F. )

         xml_node( "Mjesec", Str( field->mj_ispl ) )
         xml_node( "IsplataZaMjesecIGodinu", ;
            to_xml_encoding( AllTrim( field->ispl_za ) ) )
         xml_node( "VrstaIsplate", ;
            to_xml_encoding( AllTrim( field->vr_ispl ) ) )
         xml_node( "IznosPrihodaUNovcu", ;
            Str( field->prihod, 12, 2 ) )
         xml_node( "IznosPrihodaUStvarimaUslugama", ;
            Str( field->prihost, 12, 2 ) )
         xml_node( "BrutoPlaca", Str( field->bruto, 12, 2 ) )
         xml_node( "IznosZaPenzijskoInvalidskoOsiguranje", ;
            Str( field->dop_pio, 12, 2 ) )
         xml_node( "IznosZaZdravstvenoOsiguranje", ;
            Str( field->dop_zdr, 12, 2 ) )
         xml_node( "IznosZaOsiguranjeOdNezaposlenosti", ;
            Str( field->dop_nez, 12, 2 ) )
         xml_node( "UkupniDoprinosi", Str( field->dop_uk, 12, 2 ) )
         xml_node( "PlacaBezDoprinosa", ;
            Str( field->bruto - field->dop_uk, 12, 2 ) )

         xml_node( "FaktorLicnihOdbitakaPremaPoreznojKartici", ;
            Str( field->klo, 12, 2 ) )

         xml_node( "IznosLicnogOdbitka", Str( field->l_odb, 12, 2 ) )

         xml_node( "OsnovicaPoreza", Str( field->osn_por, 12, 2 ) )
         xml_node( "IznosUplacenogPoreza", Str( field->izn_por, 12, 2 ) )

         xml_node( "NetoPlaca", Str( field->neto, 12, 2 ) )
         xml_node( "DatumUplate", xml_date( field->datispl ) )

         // xml_node("opis", to_xml_encoding( ALLTRIM( field->naziv ) ) )
         // xml_node("uk", STR( field->ukupno, 12, 2 ) )

         xml_subnode( "PodaciOPrihodimaDoprinosimaIPorezu", .T. )

         nT_prih += field->prihod
         nT_pros += field->prihost
         nT_bruto += field->bruto
         nT_neto += field->neto
         nT_poro += field->osn_por
         nT_pori += field->izn_por
         nT_dop_s += field->dop_u_st
         nT_dop_u += field->dop_uk
         nT_d_zdr += field->dop_zdr
         nT_d_pio += field->dop_pio
         nT_d_nez += field->dop_nez
         nT_bbd += ( field->bruto - field->dop_uk )
         nT_klo += field->klo
         nT_lodb += field->l_odb

         SKIP
      ENDDO

      xml_subnode( "Ukupno", .F. )

      xml_node( "IznosPrihodaUNovcu", Str( nT_prih, 12, 2 ) )
      xml_node( "IznosPrihodaUStvarimaUslugama", ;
         Str( nT_pros, 12, 2 ) )

      xml_node( "BrutoPlaca", Str( nT_bruto, 12, 2 ) )
      xml_node( "IznosZaPenzijskoInvalidskoOsiguranje", ;
         Str( nT_d_pio, 12, 2 ) )

      xml_node( "IznosZaZdravstvenoOsiguranje", ;
         Str( nT_d_zdr, 12, 2 ) )

      xml_node( "IznosZaOsiguranjeOdNezaposlenosti", ;
         Str( nT_d_nez, 12, 2 ) )

      xml_node( "UkupniDoprinosi", Str( nT_dop_u, 12, 2 ) )
      xml_node( "PlacaBezDoprinosa", Str( nT_bbd, 12, 2 ) )
      xml_node( "IznosLicnogOdbitka", Str( nT_lodb, 12, 2 ) )
      xml_node( "OsnovicaPoreza", Str( nT_poro, 12, 2 ) )
      xml_node( "IznosUplacenogPoreza", Str( nT_pori, 12, 2 ) )
      xml_node( "NetoPlaca", Str( nT_neto, 12, 2 ) )

      xml_subnode( "Ukupno", .T. )

      xml_subnode( "Dio2PodaciOPrihodimaDoprinosimaIPorezu", .T. )

      xml_subnode( "Dio3IzjavaPoslodavcaIsplatioca", .F. )
      xml_node( "JIBJMBPoslodavca", AllTrim( cPredJmb ) )
      xml_node( "DatumUnosa", xml_date( dDatUnosa ) )
      xml_node( "NazivPoslodavca", to_xml_encoding( AllTrim( cPredNaz ) ) )
      xml_subnode( "Dio3IzjavaPoslodavcaIsplatioca", .T. )

      xml_subnode( "Dokument", .F. )
      xml_node( "Operacija", cOperacija )
      xml_subnode( "Dokument", .T. )


      xml_subnode( "Obrazac1022", .T. )

   ENDDO

   // zatvori <PaketniUvoz...>
   xml_subnode( "PaketniUvozObrazaca", .T. )

   // zatvori xml fajl
   close_xml()

   SELECT ( nTArea )

   RETURN



// --------------------------------------------
// filuje xml fajl sa podacima izvjestaja
// --------------------------------------------
STATIC FUNCTION _fill_xml( cTip, xml_file )

   LOCAL nTArea := Select()
   LOCAL nT_prih := 0
   LOCAL nT_pros := 0
   LOCAL nT_bruto := 0
   LOCAL nT_mbruto := 0
   LOCAL nT_trosk := 0
   LOCAL nT_bbtr := 0
   LOCAL nT_bbd := 0
   LOCAL nT_neto := 0
   LOCAL nT_poro := 0
   LOCAL nT_pori := 0
   LOCAL nT_dop_s := 0
   LOCAL nT_dop_u := 0
   LOCAL nT_d_zdr := 0
   LOCAL nT_d_pio := 0
   LOCAL nT_d_nez := 0
   LOCAL nT_klo := 0
   LOCAL nT_lodb := 0

   // otvori xml za upis
   create_xml( xml_file )
   // upisi header
   xml_head()

   xml_subnode( "rpt", .F. )

   // naziv firme
   xml_node( "p_naz", to_xml_encoding( AllTrim( cPredNaz ) ) )
   xml_node( "p_adr", to_xml_encoding( AllTrim( cPredAdr ) ) )
   xml_node( "p_jmb", AllTrim( cPredJmb ) )
   xml_node( "p_per", g_por_per() )

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      // po radniku
      cT_radnik := field->idradn

      // pronadji radnika u sifrarniku
      SELECT radn
      SEEK cT_radnik

      SELECT r_export

      xml_subnode( "radnik", .F. )

      xml_node( "ime", to_xml_encoding( AllTrim( radn->ime ) + ;
         " (" + AllTrim( radn->imerod ) + ;
         ") " + AllTrim( radn->naz ) ) )

      xml_node( "mb", AllTrim( radn->matbr ) )

      xml_node( "adr", to_xml_encoding( AllTrim( radn->streetname ) + ;
         " " + AllTrim( radn->streetnum ) ) )

      nT_prih := 0
      nT_pros := 0
      nT_bruto := 0
      nT_mbruto := 0
      nT_trosk := 0
      nT_bbtr := 0
      nT_bbd := 0
      nT_neto := 0
      nT_poro := 0
      nT_pori := 0
      nT_dop_s := 0
      nT_dop_u := 0
      nT_d_zdr := 0
      nT_d_pio := 0
      nT_d_nez := 0
      nT_klo := 0
      nT_lodb := 0

      nCnt := 0

      DO WHILE !Eof() .AND. field->idradn == cT_radnik

         // ukupni doprinosi
         REPLACE field->dop_uk WITH field->dop_pio + ;
            field->dop_nez + field->dop_zdr

         IF cTip $ "3#4"
            REPLACE field->osn_por with ;
               ( field->mbruto - field->dop_zdr )
         ELSE
            REPLACE field->osn_por with ;
               ( field->bruto - field->dop_uk ) - ;
               field->l_odb
         ENDIF

         // ako je neoporeziv radnik, nema poreza
         IF !radn_oporeziv( field->idradn, field->idrj ) .OR. ;
               field->osn_por < 0
            REPLACE field->osn_por WITH 0
         ENDIF

         IF field->osn_por > 0
            REPLACE field->izn_por WITH field->osn_por * 0.10
         ELSE
            REPLACE field->izn_por WITH 0
         ENDIF

         IF cTip $ "3#4"
            REPLACE field->neto with ;
               ( ( field->mbruto - field->dop_zdr ) - ;
               field->izn_por ) + field->trosk
         ELSE
            REPLACE field->neto with ;
               ( field->bruto - field->dop_uk ) - ;
               field->izn_por
         ENDIF

         IF ( cTip <> "3" .OR. cTip <> "4" ) .AND. ;
               field->tiprada $ " #I#N#"
            REPLACE field->neto with ;
               min_neto( field->neto, field->sati )
         ENDIF

         xml_subnode( "obracun", .F. )

         xml_node( "rbr", Str( ++nCnt ) )
         xml_node( "pl_opis", to_xml_encoding( AllTrim( field->mj_opis ) ) )
         xml_node( "mjesec", Str( field->mj_ispl ) )
         xml_node( "godina", Str( field->godina ) )
         xml_node( "isp_m", to_xml_encoding( AllTrim( field->mj_naz ) ) )
         xml_node( "isp_z", to_xml_encoding( AllTrim( field->ispl_za ) ) )
         xml_node( "isp_v", to_xml_encoding( g_v_ispl( AllTrim( field->vr_ispl ) ) ) )
         xml_node( "prihod", Str( field->prihod, 12, 2 ) )
         xml_node( "prih_o", Str( field->prihost, 12, 2 ) )
         xml_node( "bruto", Str( field->bruto, 12, 2 ) )
         xml_node( "trosk", Str( field->trosk, 12, 2 ) )
         xml_node( "bbtr", Str( field->bruto - field->trosk, 12, 2 ) )
         xml_node( "do_us", Str( field->dop_u_st, 12, 2 ) )
         xml_node( "do_uk", Str( field->dop_uk, 12, 2 ) )
         xml_node( "do_pio", Str( field->dop_pio, 12, 2 ) )
         xml_node( "do_zdr", Str( field->dop_zdr, 12, 2 ) )
         xml_node( "do_nez", Str( field->dop_nez, 12, 2 ) )
         xml_node( "bbd", Str( field->bruto - field->dop_uk, 12, 2 ) )
         xml_node( "neto", Str( field->neto, 12, 2 ) )
         xml_node( "klo", Str( field->klo, 12, 2 ) )
         xml_node( "l_odb", Str( field->l_odb, 12, 2 ) )
         xml_node( "p_osn", Str( field->osn_por, 12, 2 ) )
         xml_node( "p_izn", Str( field->izn_por, 12, 2 ) )
         xml_node( "uk", Str( field->ukupno, 12, 2 ) )
         xml_node( "d_isp", DToC( field->datispl ) )
         xml_node( "opis", to_xml_encoding( AllTrim( field->naziv ) ) )

         xml_subnode( "obracun", .T. )

         nT_prih += field->prihod
         nT_pros += field->prihost
         nT_bruto += field->bruto
         nT_trosk += field->trosk
         nT_bbtr += ( field->bruto - field->trosk )
         nT_bbd += ( field->bruto - field->dop_uk )
         nT_neto += field->neto
         nT_poro += field->osn_por
         nT_pori += field->izn_por
         nT_dop_s += field->dop_u_st
         nT_dop_u += field->dop_uk
         nT_d_zdr += field->dop_zdr
         nT_d_pio += field->dop_pio
         nT_d_nez += field->dop_nez
         nT_klo += field->klo
         nT_lodb += field->l_odb

         SKIP
      ENDDO

      // upisi totale za radnika
      xml_subnode( "total", .F. )

      xml_node( "prihod", Str( nT_prih, 12, 2 ) )
      xml_node( "prih_o", Str( nT_pros, 12, 2 ) )
      xml_node( "bruto", Str( nT_bruto, 12, 2 ) )
      xml_node( "trosk", Str( nT_trosk, 12, 2 ) )
      xml_node( "bbtr", Str( nT_bbtr, 12, 2 ) )
      xml_node( "bbd", Str( nT_bbd, 12, 2 ) )
      xml_node( "neto", Str( nT_neto, 12, 2 ) )
      xml_node( "p_izn", Str( nT_pori, 12, 2 ) )
      xml_node( "p_osn", Str( nT_poro, 12, 2 ) )
      xml_node( "do_st", Str( nT_dop_s, 12, 2 ) )
      xml_node( "do_uk", Str( nT_dop_u, 12, 2 ) )
      xml_node( "do_pio", Str( nT_d_pio, 12, 2 ) )
      xml_node( "do_zdr", Str( nT_d_zdr, 12, 2 ) )
      xml_node( "do_nez", Str( nT_d_nez, 12, 2 ) )
      xml_node( "klo", Str( nT_klo, 12, 2 ) )
      xml_node( "l_odb", Str( nT_lodb, 12, 2 ) )

      xml_subnode( "total", .T. )

      // zatvori radnika
      xml_subnode( "radnik", .T. )

   ENDDO

   // zatvori <rpt>
   xml_subnode( "rpt", .T. )

   SELECT ( nTArea )

   // zatvori xml fajl za upis
   close_xml()

   RETURN


// ----------------------------------------------------------
// vraca string poreznog perioda
// ----------------------------------------------------------
STATIC FUNCTION g_por_per()

   LOCAL cRet := ""

   cRet += AllTrim( Str( __mj_od ) ) + "/" + AllTrim( Str( __god_od ) )
   cRet += " - "
   cRet += AllTrim( Str( __mj_do ) ) + "/" + AllTrim( Str( __god_do ) )
   cRet += " godine"

   RETURN cRet



// -------------------------------------------
// vraca string sa datumom uslovskim
// -------------------------------------------
FUNCTION ld_date( nGod, nMj )

   LOCAL cRet

   cRet := PadR( AllTrim( Str( nGod ) ), 4 ) + ;
      PadL( AllTrim( Str( nMj ) ), 2, "0" )

   RETURN cRet



// ---------------------------------------------------------
// napuni podatke u pomocnu tabelu za izvjestaj
// ---------------------------------------------------------
FUNCTION ol_fill_data( cRj, cRjDef, cGod_od, cGod_do, cMj_od, cMj_do, ;
      cRadnik, cPrimDobra, cTP_off, cDopr10, cDopr11, cDopr12, cDopr1X, ;
      cRptTip, cObracun, cTp1, cTp2, cTp3, cTp4, cTp5 )

   LOCAL i
   LOCAL cPom
   LOCAL nPrDobra
   LOCAL nTP_off
   LOCAL nTp1 := 0
   LOCAL nTp2 := 0
   LOCAL nTp3 := 0
   LOCAL nTp4 := 0
   LOCAL nTp5 := 0
   LOCAL nTrosk := 0
   LOCAL nIDopr10 := 0000.00000
   LOCAL nIDopr11 := 0000.00000
   LOCAL nIDopr12 := 0000.00000
   LOCAL nIDopr1X := 0000.00000
   LOCAL lInRS := .F.

   // dodatni tipovi primanja
   IF cTp1 == nil
      cTp1 := ""
   ENDIF
   IF cTp2 == nil
      cTp2 := ""
   ENDIF
   IF cTp3 == nil
      cTp3 := ""
   ENDIF
   IF cTp4 == nil
      cTp4 := ""
   ENDIF
   IF cTp5 == nil
      cTp5 := ""
   ENDIF

   lDatIspl := .F.
   IF obracuni->( FieldPos( "DAT_ISPL" ) ) <> 0
      lDatIspl := .T.
   ENDIF

   SELECT ld

   DO WHILE !Eof()

      IF ld_date( field->godina, field->mjesec ) < ;
            ld_date( cGod_od, cMj_od )
         SKIP
         LOOP
      ENDIF

      IF ld_date( field->godina, field->mjesec ) > ;
            ld_date( cGod_do, cMj_do )
         SKIP
         LOOP
      ENDIF

      cT_radnik := field->idradn

      IF !Empty( cRadnik )
         IF cT_radnik <> cRadnik
            SKIP
            LOOP
         ENDIF
      ENDIF

      cTipRada := g_tip_rada( ld->idradn, ld->idrj )
      lInRS := radnik_iz_rs( radn->idopsst, radn->idopsrad )

      // samo pozicionira bazu PAROBR na odgovarajuci zapis
      ParObr( ld->mjesec, ld->godina, IF( lViseObr, ld->obr, ), ld->idrj )

      SELECT radn
      SEEK cT_radnik

      IF cRptTip $ "3#4"
         IF ( cTipRada $ " #I#N" )
            SELECT ld
            SKIP
            LOOP
         ENDIF
      ELSE
         IF !( cTipRada $ " #I#N" )
            SELECT ld
            SKIP
            LOOP
         ENDIF
      ENDIF

      SELECT ld

      nBruto := 0
      nTrosk := 0
      nBrDobra := 0
      nDoprStU := 0
      nDopPio := 0
      nDopZdr := 0
      nDopNez := 0
      nDopUk := 0
      nNeto := 0
      nPrDobra := 0
      nTP_off := 0
      nTp1 := 0
      nTp2 := 0
      nTp3 := 0
      nTp4 := 0
      nTp5 := 0

      DO WHILE !Eof() .AND. field->idradn == cT_radnik

         IF ld_date( field->godina, field->mjesec ) < ;
               ld_date( cGod_od, cMj_od )
            SKIP
            LOOP
         ENDIF

         IF ld_date( field->godina, field->mjesec ) > ;
               ld_date( cGod_do, cMj_do )
            SKIP
            LOOP
         ENDIF

         // radna jedinica
         cRadJed := ld->idrj

         // uvijek provjeri tip rada, ako ima vise obracuna
         cTipRada := g_tip_rada( ld->idradn, ld->idrj )
         cTrosk := radn->trosk
         lInRS := radnik_iz_rs( radn->idopsst, radn->idopsrad )

         IF cRptTip $ "3#4"
            IF ( cTipRada $ " #I#N" )
               SKIP
               LOOP
            ENDIF
         ELSE
            IF !( cTipRada $ " #I#N" )
               SKIP
               LOOP
            ENDIF
         ENDIF

         ParObr( ld->mjesec, ld->godina, IF( lViseObr, ld->obr, ), ;
            ld->idrj )

         nPrDobra := 0
         nTP_off := 0

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

         // ostali tipovi primanja
         IF !Empty( cTp1 )
            nTp1 := LD->&( "I" + cTp1 )
         ENDIF
         IF !Empty( cTp2 )
            nTp2 := LD->&( "I" + cTp2 )
         ENDIF
         IF !Empty( cTp3 )
            nTp3 := LD->&( "I" + cTp3 )
         ENDIF
         IF !Empty( cTp4 )
            nTp4 := LD->&( "I" + cTp4 )
         ENDIF
         IF !Empty( cTp5 )
            nTp5 := LD->&( "I" + cTp5 )
         ENDIF


         nNeto := field->uneto
         nKLO := g_klo( field->ulicodb )
         nL_odb := field->ulicodb

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

         // ugovori o djelu
         IF cTipRada == "U" .AND. cTrosk <> "N"

            nTrosk := ROUND2( nMBruto * ( gUgTrosk / 100 ), gZaok2 )

            IF lInRs == .T.
               nTrosk := 0
            ENDIF

         ENDIF

         // autorski honorar
         IF cTipRada == "A" .AND. cTrosk <> "N"

            nTrosk := ROUND2( nMBruto * ( gAhTrosk / 100 ), gZaok2 )

            IF lInRs == .T.
               nTrosk := 0
            ENDIF

         ENDIF

         IF cRptTip $ "3#4"
            // ovo je bruto iznos
            nMBruto := ( nBruto - nTrosk )
         ENDIF

         // ovo preskoci, nema ovdje GIP-a
         IF nMBruto <= 0
            SELECT ld
            SKIP
            LOOP
         ENDIF

         // bruto primanja u uslugama ili dobrima
         // za njih posebno izracunaj bruto osnovicu
         IF nPrDobra > 0
            nBrDobra := bruto_osn( nPrDobra, cTipRada, nL_odb )
         ENDIF

         // ocitaj doprinose, njihove iznose
         nDopr10 := get_dopr( cDopr10, cTipRada )
         nDopr11 := get_dopr( cDopr11, cTipRada )
         nDopr12 := get_dopr( cDopr12, cTipRada )
         nDopr1X := get_dopr( cDopr1X, cTipRada )

         // izracunaj doprinose
         nIDopr10 := Round( nMBruto * nDopr10 / 100, 4 )
         nIDopr11 := Round( nMBruto * nDopr11 / 100, 4 )
         nIDopr12 := Round( nMBruto * nDopr12 / 100, 4 )

         // zbirni je zbir ova tri doprinosa
         nIDopr1X := Round( nIDopr10 + nIDopr11 + nIDopr12, 4 )

         // ukupno dopr iz 31%
         // nDoprIz := u_dopr_iz( nMBruto, cTipRada )

         // osnovica za porez
         IF cRptTip $ "3#4"
            nPorOsn := ( nMBruto - nIDopr1X ) - nL_odb
         ELSE
            nPorOsn := ( nBruto - nIDopr1X ) - nL_odb
         ENDIF

         // ako je neoporeziv radnik, nema poreza
         IF !radn_oporeziv( radn->id, ld->idrj ) .OR. ;
               ( nBruto - nIDopr1X ) < nL_odb
            nPorOsn := 0
         ENDIF

         // porez je ?
         nPorez := izr_porez( nPorOsn, "B" )

         SELECT ld

         // na ruke je
         IF cRptTip $ "3#4"
            nNaRuke := Round( ( nMBruto - nIDopr1X - nPorez ) ;
               + nTrosk, 2 )
         ELSE
            nNaRuke := Round( nBruto - nIDopr1X - nPorez, 2 )
         ENDIF

         nIsplata := nNaRuke

         // da li se radi o minimalcu ?
         IF cTipRada $ " #I#N#"
            nIsplata := min_neto( nIsplata, field->usati )
         ENDIF

         nMjIspl := 0
         cIsplZa := ""
         cVrstaIspl := ""
         dDatIspl := Date()
         cObr := " "

         IF lViseObr
            cObr := field->obr
         ENDIF

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


         // ubaci u tabelu podatke
         _ins_tbl( cT_radnik, ;
            cRadJed, ;
            cTipRada, ;
            "placa", ;
            dDatIspl, ;
            ld->mjesec, ;
            nMjIspl, ;
            cIsplZa, ;
            cVrstaIspl, ;
            ld->godina, ;
            nBruto - nBrDobra, ;
            nBrDobra, ;
            nBruto, ;
            nMBruto, ;
            nTrosk, ;
            nDopr1X, ;
            nIDopr10, ;
            nIDopr11, ;
            nIDopr12, ;
            nIDopr1X, ;
            nNaRuke, ;
            nKLO, ;
            nL_Odb, ;
            nPorOsn, ;
            nPorez, ;
            nIsplata, ;
            ld->usati, ;
            nTp1, ;
            nTp2, ;
            nTp3, ;
            nTp4, ;
            nTp5 )

         SELECT ld
         SKIP

      ENDDO

   ENDDO

   RETURN
