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

STATIC __fakt_params := NIL

// -----------------------------------------
// Fakt parametri
// -----------------------------------------
FUNCTION mnu_fakt_params()

   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   PRIVATE Izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   O_ROBA
   O_PARAMS

   SELECT params
   USE


   AAdd( opc, "1. postaviti osnovne podatke o firmi           " )
   AAdd( opcexe, {|| org_params() } )

   AAdd( opc, "2. postaviti varijante obrade dokumenata       " )
   AAdd( opcexe, {|| fakt_par_varijante_prikaza() } )

   AAdd( opc, "3. izgled dokumenata      " )
   AAdd( opcexe, {|| par_fakt_izgled_dokumenta() } )

   IF IsPDV()
      AAdd( opc, "4. izgled dokumenata - zaglavlje " )
      AAdd( opcexe, {|| fakt_zagl_params() } )
   ENDIF

   AAdd( opc, "5. nazivi dokumenata i teksta na kraju (potpis)" )
   AAdd( opcexe, {|| fakt_par_nazivi_dokumenata() } )

   AAdd( opc, "6. prikaza cijena, iznos " )
   AAdd( opcexe, {|| fakt_par_cijene() } )

   AAdd( opc, "F. fiskalni parametri  " )
   AAdd( opcexe, {|| fiskalni_parametri_za_korisnika() } )

   AAdd( opc, "P. parametri labeliranja, barkod stampe  " )
   AAdd( opcexe, {|| label_params() } )

   AAdd( opc, "R. postaviti parametre - razno                 " )
   AAdd( opcexe, {|| fakt_par_razno() } )

   Menu_SC( "parf" )


   fakt_params( .T. )

   RETURN NIL


// -------------------------------------------------------------
// postavi parametre unosa fakt_dokumenta
// -------------------------------------------------------------
PROCEDURE fakt_params( read )

   IF read == NIL
      read = .F.
   ENDIF

   IF READ .OR. __fakt_params == NIL

      __fakt_params := hb_Hash()

      // TODO: prebaciti na get_set sistem
      __fakt_params[ "def_rj" ] := fetch_metric( "fakt_default_radna_jedinica", my_user(), Space( 2 ) )

      __fakt_params[ "barkod" ] := fetch_metric( "fakt_prikaz_barkod", my_user(), "0" )

      // TODO: ugasiti ovaj globalni parametar
      IF destinacije() == "D"
         __fakt_params[ "destinacije" ] := .T.
      ELSE
         __fakt_params[ "destinacije" ] := .F.
      ENDIF

      __fakt_params[ "fakt_dok_veze" ] := iif( fakt_dok_veze() == "D", .T., .F. )
      __fakt_params[ "fakt_opis_stavke" ] := iif( fakt_opis_stavke() == "D", .T., .F. )
      __fakt_params[ "fakt_prodajna_mjesta" ] := iif( fakt_prodajna_mjesta() == "D", .T., .F. )
      __fakt_params[ "ref_lot" ] := iif( ref_lot() == "D", .T., .F. )
      __fakt_params[ "fakt_vrste_placanja" ] := iif( fakt_vrste_placanja() == "D", .T., .F. )
      __fakt_params[ "fakt_objekti" ] := iif( fakt_objekti() == "D", .T., .F. )
      __fakt_params[ "fakt_otpr_22_brojac" ] := iif( fakt_otpr_22_brojac() == "D", .T., .F. )
      __fakt_params[ "fakt_otpr_gen" ] := iif( fakt_otpr_gen() == "D", .T., .F. )
      __fakt_params[ "kontrola_brojaca" ] := iif( fakt_kontrola_brojaca_par() == "D", .T., .F. )

   ENDIF

   RETURN __fakt_params



// ------------------------------------------
// setuju parametre pri pokretanju modula
// napuni sifrarnike
// ------------------------------------------
FUNCTION fakt_set_params()

   // PTXT 01.50 compatibility switch
   PUBLIC gPtxtC50 := .T.

   fill_part()

   RETURN


/*! \fn fakt_par_razno()
 *  \brief Podesenja parametri-razno
 */
FUNCTION fakt_par_razno()

   LOCAL _def_rj := fetch_metric( "fakt_default_radna_jedinica", my_user(), Space( 2 ) )
   LOCAL _prik_bk := fetch_metric( "fakt_prikaz_barkod", my_user(), "0" )
   LOCAL _ext_pdf := fetch_metric( "fakt_dokument_pdf_lokacija", my_user(), PadR( "", 300 ) )
   LOCAL _unos_barkod := fetch_metric( "fakt_unos_artikala_po_barkodu", my_user(), "N" )
   LOCAL _pm := fakt_prodajna_mjesta()
   LOCAL _rabat := fetch_metric( "pregled_rabata_kod_izlaza", my_user(), "N" )
   LOCAL _racun_na_email := PadR( fetch_metric( "fakt_dokument_na_email", my_user(), "" ), 300 )
   LOCAL _def_vp_template := PadR( fetch_metric( "fakt_default_odt_template", my_user(), "" ), 20 )
   LOCAL _def_mp_template := PadR( fetch_metric( "fakt_default_odt_mp_template", my_user(), "" ), 20 )
   LOCAL _def_kol_template := PadR( fetch_metric( "fakt_default_odt_kol_template", my_user(), "" ), 20 )
   LOCAL _x := 1
   LOCAL _unos_ref_lot := ref_lot()
   LOCAL _unos_opisa := fakt_opis_stavke()
   LOCAL _unos_objekta := fakt_objekti()
   LOCAL _vr_pl := fakt_vrste_placanja()
   LOCAL _unos_dest := destinacije()
   LOCAL _unos_br_veza := fakt_dok_veze()
   LOCAL _otpr_brojac_22 := fakt_otpr_22_brojac()
   LOCAL _otpr_gen := fakt_otpr_gen()
   LOCAL _kontrola_brojaca := fakt_kontrola_brojaca_par()
   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   PRIVATE GetList := {}

   O_PARAMS

   gKomLin := PadR( gKomLin, 70 )

   Box(, MAXROWS() - 5, MAXCOLS() - 15, .F., "OSTALI PARAMETRI (RAZNO)" )

   _x := 2
   @ m_x + _x, m_y + 2 SAY "Inicijalna meni-opcija (1-9)" GET gIMenu VALID gIMenu $ "123456789" PICT "@!"
   _x += 2
   @ m_x + _x, m_y + 2 SAY8 "Tekuća radna jedinica kod unosa dokumenta:" GET _def_rj
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Unos dokumenata pomoću barkod-a (D/N) ?" GET _unos_barkod VALID _unos_barkod $ "DN" PICT "@!"
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Pregled zadnjih izlaza kod unosa dokumenta (D/N) ?" GET _rabat VALID _rabat $ "DN" PICT "@!"
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Dužina sifre artikla sintetički " GET gnDS VALID gnDS > 0 PICT "9"
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Voditi samo količine " GET gSamoKol PICT "@!" VALID gSamoKol $ "DN"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Tekuća vrijednost za rok placanja  " GET gRokPl PICT "999"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Uvijek resetuj artikal pri unosu dokumenata (D/N)" GET gResetRoba PICT "@!" VALID gResetRoba $ "DN"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Prikaz barkod-a na fakturi (0/1/2)" GET _prik_bk VALID _prik_bk $ "012"

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Račun na email:" GET _racun_na_email PICT "@S50"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "LibreOffice fakturu konvertuj u PDF na lokaciju:" GET _ext_pdf PICT "@S35"

   _x += 2
   @ m_x + _x, m_y + 2 SAY "   Uzorak fakture (VP):" GET _def_vp_template PICT "@S35"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "   Uzorak fakture (MP):" GET _def_mp_template PICT "@S35"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "     Uzorak otpremince:" GET _def_kol_template PICT "@S35"

   _x += 2
   read_dn_parametar( "Praćenje po destinacijama", m_x + _x, m_y + 2, @_unos_dest )
   ++ _x
   read_dn_parametar( "Unos brojeva veze", m_x + _x, m_y + 2, @_unos_br_veza )
   ++ _x
   read_dn_parametar( "Fakturisanje po prodajnim mjestima", m_x + _x, m_y + 2, @_pm )
   ++ _x
   read_dn_parametar( "Fakturisanje po objektima", m_x + _x, m_y + 2, @_unos_objekta )
   ++ _x
   read_dn_parametar( "Fakturisanje po vrstama placanja", m_x + _x, m_y + 2, @_vr_pl )
   ++ _x
   read_dn_parametar( "Fakt dodatni opis po stavkama", m_x + _x, m_y + 2, @_unos_opisa )
   ++ _x
   read_dn_parametar( "REF/LOT brojevi", m_x + _x, m_y + 2, @_unos_ref_lot )
   ++ _x
   read_dn_parametar( "Brojač otpremnica po dokumentu 22 (D/N)", m_x + _x, m_y + 2, @_otpr_brojac_22 )
   ++ _x

   read_dn_parametar( "Generacija otpremnica ver.2 (D/N)", m_x + _x, m_y + 2, @_otpr_gen )
   ++ _x

   read_dn_parametar( "Kontrola brojača dokumenta (D/N)", m_x + _x, m_y + 2, @_kontrola_brojaca )
   ++ _x

   @ m_x + _x, m_y + 2 SAY8 "Ispis računa MP na traku (D/N/X)" GET gMPPrint  PICT "@!"   VALID gMPPrint $ "DNXT"

   READ

   IF gMPPrint $ "DXT"

      ++ _x
      @ m_x + _x, m_y + 2 SAY "Oznaka lokalnog porta za stampu: LPT" GET gMPLocPort VALID gMPLocPort $ "1234567" PICT "@!"
      ++ _x
      @ m_x + _x, m_y + 2 SAY "Redukcija trake (0/1/2):" ;
         GET gMPRedTraka ;
         VALID gMPRedTraka $ "012"
      ++ _x
      @ m_x + _x, m_y + 2 SAY "Ispis id artikla na racunu (D/N):" ;
         GET gMPArtikal ;
         VALID gMPArtikal $ "DN" PICT "@!"
      ++ _x
      @ m_x + _x, m_y + 2 SAY "Ispis cjene sa pdv (2) ili bez (1):" ;
         GET gMPCjenPDV ;
         VALID gMPCjenPDV $ "12"


      READ

   ENDIF

   BoxC()

   gKomLin := Trim( gKomLin )

   IF LastKey() <> K_ESC

      set_metric( "fakt_voditi_samo_kolicine", nil, gSamoKol )
      set_metric( "fakt_rok_placanja_tekuca_vrijednost", my_user(), gRokPl )
      set_metric( "fakt_reset_artikla_na_unosu", my_user(), gResetRoba )
      set_metric( "fakt_incijalni_meni_odabri", my_user(), gIMenu )
      set_metric( "fakt_default_radna_jedinica", my_user(), _def_rj )
      set_metric( "fakt_prikaz_barkod", my_user(), _prik_bk )
      set_metric( "fakt_dokument_pdf_lokacija", my_user(), _ext_pdf )
      set_metric( "fakt_unos_artikala_po_barkodu", my_user(), _unos_barkod )
      set_metric( "pregled_rabata_kod_izlaza", my_user(), _rabat )
      set_metric( "fakt_dokument_na_email", my_user(), AllTrim( _racun_na_email ) )
      set_metric( "fakt_default_odt_template", my_user(), AllTrim( _def_vp_template ) )
      set_metric( "fakt_default_odt_mp_template", my_user(), AllTrim( _def_mp_template ) )
      set_metric( "fakt_default_odt_kol_template", my_user(), AllTrim( _def_kol_template ) )

      destinacije( _unos_dest )
      fakt_opis_stavke( _unos_opisa )
      fakt_objekti( _unos_objekta )
      ref_lot( _unos_ref_lot )
      fakt_prodajna_mjesta( _pm )
      fakt_vrste_placanja( _vr_pl )
      fakt_dok_veze( _unos_br_veza )
      fakt_otpr_22_brojac( _otpr_brojac_22 )
      fakt_otpr_gen( _otpr_gen )
      fakt_kontrola_brojaca_par( _kontrola_brojaca )

      // setuj mi default odt template ako treba
      __default_odt_template()

      Wpar( "NF", gFNar )
      Wpar( "UF", gFUgRab )
      Wpar( "ds", gnDS )
      WPar( "if", gImeF )
      WPar( "95", gKomLin )
      WPar( "Fi", @gIspPart )
      WPar( "mP", gMpPrint )
      WPar( "mL", gMpLocPort )
      WPar( "mT", gMpRedTraka )
      WPar( "mA", gMpArtikal )
      WPar( "mC", gMpCjenPDV )

   ENDIF

   RETURN


// ---------------------------------------------
// ---------------------------------------------
FUNCTION fakt_zagl_params()

   LOCAL nSay := 17
   LOCAL sPict := "@S55"
   LOCAL nX := 1
   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   PRIVATE GetList := {}

   gFNaziv := PadR( gFNaziv, 250 )
   gFPNaziv := PadR( gFPNaziv, 250 )
   gFIdBroj := PadR( gFIdBroj, 13 )
   gFText1 := PadR( gFText1, 72 )
   gFText2 := PadR( gFText2, 72 )
   gFText3 := PadR( gFText3, 72 )
   gFTelefon := PadR( gFTelefon, 72 )
   gFEmailWeb := PadR( gFEmailWeb, 72 )

   Box( , 21, 77, .F., "Izgleda dokumenata - zaglavlje" )

   // opci podaci
   @ m_x + nX, m_y + 2 SAY PadL( "Puni naziv firme:", nSay ) GET gFNaziv ;
      PICT sPict
   nX++

   @ m_x + nX, m_y + 2 SAY PadL( "Dodatni opis:", nSay ) GET gFPNaziv ;
      PICT sPict
   nX++

   @ m_x + nX, m_y + 2 SAY PadL( "Adresa firme:", nSay ) GET gFAdresa ;
      PICT sPict
   nX++

   @ m_x + nX, m_y + 2 SAY PadL( "Ident.broj:", nSay ) GET gFIdBroj
   nX++

   @ m_x + nX, m_y + 2 SAY PadL( "Telefoni:", nSay ) GET gFTelefon ;
      PICT sPict
   nX++

   @ m_x + nX, m_y + 2 SAY PadL( "email/web:", nSay ) GET gFEmailWeb ;
      PICT sPict
   nX++

   // banke
   @ m_x + nX,  m_y + 2 SAY PadL( "Banka 1:", nSay ) GET gFBanka1 ;
      PICT sPict
   nX++

   @ m_x + nX,  m_y + 2 SAY PadL( "Banka 2:", nSay ) GET gFBanka2 ;
      PICT sPict
   nX++

   @ m_x + nX, m_y + 2 SAY PadL( "Banka 3:", nSay ) GET gFBanka3 ;
      PICT sPict
   nX++

   @ m_x + nX, m_y + 2 SAY PadL( "Banka 4:", nSay ) GET gFBanka4 ;
      PICT sPict
   nX++

   @ m_x + nX, m_y + 2 SAY PadL( "Banka 5:", nSay ) GET gFBanka5 ;
      PICT sPict
   nX += 2

   // dodatni redovi
   @ m_x + nX, m_y + 2 SAY "Proizvoljan sadrzaj na kraju"
   nX++

   @ m_x + nX, m_y + 2 SAY PadL( "Red 1:", nSay ) GET gFText1 ;
      PICT sPict
   nX++


   @ m_x + nX, m_y + 2 SAY PadL( "Red 2:", nSay ) GET gFText2 ;
      PICT sPict
   nX++

   @ m_x + nX, m_y + 2 SAY PadL( "Red 3:", nSay ) GET gFText3 ;
      PICT sPict
   nX += 2

   @ m_x + nX, m_y + 2 SAY "Koristiti tekstualno zaglavlje (D/N)?" GET gStZagl ;
      VALID gStZagl $ "DN" PICT "@!"

   nX += 2

   @ m_x + nX, m_y + 2 SAY PadL( "Slika na vrhu fakture (redova):", nSay + 15 ) GET gFPicHRow PICT "99"

   nX += 1

   @ m_x + nX, m_y + 2 SAY PadL( "Slika na dnu fakture (redova):", nSay + 15 ) GET gFPicFRow PICT "99"
   READ

   BoxC()

   IF ( LastKey() <> K_ESC )
      set_metric( "org_naziv", nil, gFNaziv )
      set_metric( "org_naziv_dodatno", nil, gFPNaziv )
      set_metric( "org_adresa", nil, gFAdresa )
      set_metric( "org_pdv_broj", nil, gFIdBroj )
      set_metric( "fakt_zagl_banka_1", nil, gFBanka1 )
      set_metric( "fakt_zagl_banka_2", nil, gFBanka2 )
      set_metric( "fakt_zagl_banka_3", nil, gFBanka3 )
      set_metric( "fakt_zagl_banka_4", nil, gFBanka4 )
      set_metric( "fakt_zagl_banka_5", nil, gFBanka5 )
      set_metric( "fakt_zagl_telefon", nil, gFTelefon )
      set_metric( "fakt_zagl_email", nil, gFEmailWeb )
      set_metric( "fakt_zagl_dtxt_1", nil, gFText1 )
      set_metric( "fakt_zagl_dtxt_2", nil, gFText2 )
      set_metric( "fakt_zagl_dtxt_3", nil, gFText3 )
      set_metric( "fakt_zagl_koristiti_txt", nil, gStZagl )
      set_metric( "fakt_zagl_pic_header", nil, gFPicHRow )
      set_metric( "fakt_zagl_pic_footer", nil, gFPicFRow )
   ENDIF

   RETURN



FUNCTION fakt_par_cijene()

   LOCAL nX
   PRIVATE  GetList := {}

   PicKol := StrTran( PicKol, "@Z ", "" )

   nX := 1
   Box(, 6, 60, .F., "PARAMETRI PRIKAZA" )

   @ m_x + nX, m_y + 2 SAY "Prikaz cijene   " GET PicCDem
   nX++

   @ m_x + nX, m_y + 2 SAY "Prikaz iznosa   " GET PicDem
   nX++

   @ m_x + nX, m_y + 2 SAY "Prikaz kolicine " GET PicKol
   nX++

   @ m_x + nX, m_y + 2 SAY "Na kraju fakture izvrsiti zaokruzenje" GET gFZaok PICT "99"
   nX++

   @ m_x + nX, m_y + 2 SAY "Zaokruzenje 5 pf (D/N)?" GET gZ_5pf PICT "@!" ;
      VALID gZ_5pf $ "DN"

   READ

   BoxC()

   IF ( LastKey() <> K_ESC )

      set_metric( "fakt_prikaz_cijene", NIL, PicCDem )
      set_metric( "fakt_prikaz_iznosa", NIL, PicDem )
      set_metric( "fakt_prikaz_kolicine", NIL, PicKol )
      set_metric( "fakt_zaokruzenje", NIL, gFZaok )
      set_metric( "fakt_zaokruzenje_5_pf", NIL, gZ_5pf )

   ENDIF

   RETURN



FUNCTION fakt_par_varijante_prikaza()

   PRIVATE  GetList := {}

   O_PARAMS

   Box(, 23, 76, .F., "VARIJANTE OBRADE DOKUMENATA" )
   @ m_x + 1, m_y + 2 SAY "Unos Dat.pl, otpr., narudzbe D/N (1/2) ?" GET gDoDPar VALID gDodPar $ "12" PICT "@!"
   @ m_x + 1, m_y + 46 SAY "Dat.pl.u svim v.f.9 (D/N)?" GET gDatVal VALID gDatVal $ "DN" PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Generacija ulaza prilikom izlaza 13" GET gProtu13 VALID gProtu13 $ "DN" PICT "@!"
   @ m_x + 4, m_y + 2 SAY "Maloprod.cijena za 13-ku ( /1/2/3/4/5/6)   " GET g13dcij VALID g13dcij $ " 123456"
   @ m_x + 5, m_y + 2 SAY "Varijanta dokumenta 13 (1/2)   " GET gVar13 VALID gVar13 $ "12"
   @ m_x + 6, m_y + 2 SAY "Varijanta numeracije dokumenta 13 (1/2)   " GET gVarNum VALID gVarNum $ "12"
   @ m_x + 7, m_y + 2 SAY "Pratiti trenutnu kolicinu D/N ?" GET gPratiK PICT "@!" VALID gPratiK $ "DN"
   @ m_x + 7, Col() + 1 SAY "Pratiti cijene na unosu D/N ?" GET gPratiC PICT "@!" VALID gPratiC $ "DN"
   @ m_x + 8, m_y + 2 SAY  "Koristenje VP cijene:"
   @ m_x + 9, m_y + 2 SAY  "  ( ) samo VPC   (X) koristiti samo MPC    (1) VPC1/VPC2 "
   @ m_x + 10, m_y + 2 SAY "  (2) VPC1/VPC2 putem rabata u odnosu na VPC1   (3) NC "
   @ m_x + 11, m_y + 2 SAY "  (4) Uporedo vidi i MPC............" GET gVarC
   @ m_x + 12, m_y + 2 SAY "U fakturi maloprodaje koristiti:"
   @ m_x + 13, m_y + 2 SAY "  (1) MPC iz sifrarnika  (2) VPC + PPP + PPU   (3) MPC2 "
   @ m_x + 14, m_y + 2 SAY "  (4) MPC3  (5) MPC4  (6) MPC5  (7) MPC6 ....." GET gMP VALID gMP $ "1234567"
   @ m_x + 15, m_y + 2 SAY "Numericki dio broja dokumenta:" GET gNumDio PICT "99"
   @ m_x + 16, m_y + 2 SAY "Upozorenje na promjenu radne jedinice:" GET gDetPromRj PICT "@!" VALID gDetPromRj $ "DN"
   @ m_x + 17, m_y + 2 SAY "Var.otpr.-12 sa porezom :" GET gV12Por PICT "@!" VALID gV12Por $ "DN"
   @ m_x + 17, m_y + 35 SAY "Var.fakt.po ugovorima (1/2) :" GET gVFU PICT "9" VALID gVFU $ "12"
   @ m_x + 18, m_y + 2 SAY "Var.fakt.rok plac. samo vece od 0 :" GET gVFRP0 PICT "@!" VALID gVFRP0 $ "DN"
   @ m_x + 20, m_y + 2 SAY "Prikaz samo kolicina na dokumentima (0/D/N)" GET gPSamoKol PICT "@!" VALID gPSamoKol $ "0DN"
   @ m_x + 21, m_y + 2 SAY "Pretraga artikla po indexu:" GET gArtCdx PICT "@!"
   @ m_x + 22, m_y + 2 SAY "Koristiti rabat iz sif.robe (polje N1) ?" GET gRabIzRobe PICT "@!" VALID gRabIzRobe $ "DN"
   @ m_x + 23, m_y + 2 SAY "Brisi direktno u smece" GET gcF9usmece PICT "@!" VALID gcF9usmece $ "DN"
   @ m_x + 23, Col() + 2 SAY "Timeout kod azuriranja" GET gAzurTimeout PICT "9999"

   READ

   BoxC()

   IF ( LastKey() <> K_ESC )

      set_metric( "fakt_datum_placanja_otpremnica", nil, gDoDPar )
      set_metric( "fakt_datum_placanja_svi_dokumenti", nil, gDatVal )
      set_metric( "fakt_numericki_dio_dokumenta", nil, gNumDio )
      set_metric( "fakt_prikaz_samo_kolicine", nil, gPSamoKol )
      set_metric( "fakt_povrat_u_smece", nil, gcF9usmece )
      set_metric( "fakt_varijanta_dokumenta_13", nil, gVar13 )

      WPar( "pd", gProtu13 )
      WPar( "dc", g13dcij )
      WPar( "vn", gVarNum )
      WPar( "pk", gPratik )
      WPar( "pc", gPratiC )
      WPar( "50", gVarC )
      WPar( "mp", gMP )
      WPar( "PR", gDetPromRj )
      WPar( "vp", gV12Por )
      WPar( "vu", gVFU )
      WPar( "v0", gVFRP0 )
      WPar( "g1", gKarC1 )
      WPar( "g2", gKarC2 )
      WPar( "g3", gKarC3 )
      WPar( "g4", gKarN1 )
      WPar( "g5", gKarN2 )
      WPar( "gC", gArtCDX )
      WPar( "rR", gRabIzRobe )
      WPar( "Fz", gAzurTimeout )

   ENDIF

   RETURN



FUNCTION par_fakt_izgled_dokumenta()

   LOCAL nX
   LOCAL nDx1 := 0
   LOCAL nDx2 := 0
   LOCAL nDx3 := 0
   LOCAL nSw1 := 72
   LOCAL nSw2 := 1
   LOCAL nSw3 := 72
   LOCAL nSw4 := 31
   LOCAL nSw5 := 1
   LOCAL nSw6 := 1
   LOCAL nSw7 := 0
   LOCAL _params := fakt_params()
   LOCAL _auto_odt := fetch_metric( "fakt_odt_template_auto", NIL, "D" )
   PRIVATE GetList := {}
   PRIVATE cIzvj := "1"

   O_PARAMS

   IF ValType( gTabela ) <> "N"
      gTabela := 1
   ENDIF

   RPar( "c1", @cIzvj )

   cSection := "F"
   RPar( "x1", @nDx1 )
   RPar( "x2", @nDx2 )
   RPar( "x3", @nDx3 )
   RPar( "x4", @nSw1 )
   RPar( "x5", @nSw2 )
   RPar( "x6", @nSw3 )
   RPar( "x7", @nSw4 )
   RPar( "x8", @nSw5 )
   RPar( "x9", @nSw6 )
   RPar( "y1", @nSw7 )

   cSection := "1"

   nX := 2
   Box( , 22, 76, .F., "Izgled dokumenata" )

   IF !IsPdv()

      @ m_x + nX, m_y + 2 SAY "Prikaz cijena podstavki/cijena u glavnoj stavci (1/2)" GET cIzvj
      nX++
      @ m_x + nX, m_y + 2 SAY "Izgled fakture 1/2/3" GET gTipF VALID gTipF $ "123"
      nX++
      @ m_x + nX, m_y + 2 SAY "Varijanta 1/2/3/4/9/A/B" GET gVarF VALID gVarF $ "12349AB"
      nX++
   ENDIF

   @ m_x + nX, m_y + 2 SAY "Dodat.redovi po listu " GET gERedova ;
      PICT "999"
   nX++
   @ m_x + nX, m_y + 2 SAY "Lijeva margina pri stampanju " GET gnLMarg PICT "99"
   nX++

   // legacy
   IF !IsPdv()
      @ m_x + nX, m_y + 35 SAY "L.marg.za v.2/9/A5 " GET gnLMargA5 PICT "99"
      nX++
   ENDIF

   @ m_x + nX, m_y + 2 SAY "Gornja margina " GET gnTMarg PICT "99"
   nX++

   // legacy
   IF !IsPdv()
      @ m_x + nX, m_y + 2 SAY "Koristiti A5 obrazac u varijanti 9 D/N/0" GET gFormatA5 PICT "@!" VALID gFormatA5 $ "DN0"
      nX++

      @ m_x + nX, m_y + 58 SAY "A4   A5"
      nX++
      @ m_x + nX, m_y + 2 SAY "Horizont.pomjeranje zaglavlja u varijanti 9 (br.kolona)" GET gFPzag PICT "99"
      @ m_x + nX, m_y + 63 GET gFPzagA5 PICT "99"
      nX++
      @ m_x + nX, m_y + 2 SAY "Vertikalno pomjeranje stavki u fakturi var.9(br.redova)" GET gnTmarg2 PICT "99"
      @ m_x + nX, m_y + 63 GET gnTmarg2A5 PICT "99"
      nX++
      @ m_x + nX, m_y + 2 SAY "Vertikalno pomjeranje totala u fakturi var.9(br.redova)" GET gnTmarg3 PICT "99"
      @ m_x + nX, m_y + 63 GET gnTmarg3A5 PICT "99"
      nX++
      @ m_x + nX, m_y + 2 SAY "Vertikalno pomj.donjeg dijela fakture  var.9(br.redova)" GET gnTmarg4 PICT "99"
      @ m_x + nX, m_y + 63 GET gnTmarg4A5 PICT "99"
      nX++
      @ m_x + nX, m_y + 2 SAY "Vertik.pomj.znakova krizanja i br.dok.var.9(br.red.>=0)" GET gKriz PICT "99"
      @ m_x + nX, m_y + 63 GET gKrizA5 PICT "99"
      nX++
      @ m_x + nX, m_y + 2 SAY "Znak kojim se precrtava dio teksta na papiru" GET gZnPrec
      nX++
      @ m_x + nX, m_y + 2 SAY "Broj linija za odvajanje tabele od broja dokumenta" GET gOdvT2 VALID gOdvT2 >= 0 PICT "9"
      nX++
      @ m_x + nX, m_y + 2 SAY "Nacin crtanja tabele (0/1/2) ?" GET gTabela VALID gTabela < 3 .AND. gTabela >= 0 PICT "9"
      nX++
      @ m_x + nX, m_y + 2 SAY "Zaglavlje na svakoj stranici D/N  (1/2) ? " GET gZagl VALID gZagl $ "12" PICT "@!"
      nX++
      @ m_x + nX, m_y + 2 SAY "Crni-masni prikaz fakture D/N  (1/2) ? " GET gBold VALID gBold $ "12" PICT "@!"
      nX++
      @ m_x + nX, m_y + 2 SAY "Var.RTF-fakt.,izgled tipa 2 (' '-standardno, 1-MINEX, 2-LIKOM, 3-ZENELA)" GET gVarRF VALID gVarRF $ " 123"
      nX++
      @ m_x + nX, m_y + 2 SAY "Prikaz rekapitulacije po tarifama na 13-ci:" GET gRekTar VALID gRekTar $ "DN" PICT "@!"
      nX++
      @ m_x + nX, m_y + 2 SAY "Prikaz horizot. linija:" GET gHLinija VALID gHLinija $ "DN" PICT "@!"
      nX++
      @ m_x + nX, m_y + 2 SAY "Prikaz rabata u %(procentu)? (D/N):" GET gRabProc VALID gRabProc $ "DN" PICT "@!"
      nX++
   ENDIF

   IF IsPdv()

      @ m_x + nX, m_y + 2 SAY "Koristi ODT template automatski (D/N) ?" GET _auto_odt VALID _auto_odt $ "DN" PICT "!@"

      nX ++

      @ m_x + nX, m_y + 2 SAY "PDV Delphi RB prikaz (D/N)" GET gPDVDrb PICT "@!" VALID gPDVDrb $ "DN"
      nX ++

      @ m_x + nX, m_y + 2 SAY "PDV TXT dokument varijanta " GET gPDVDokVar PICT "@!" VALID gPDVDokVar $ "123"
      nX ++

      nX += 2
      @ m_x + nX, m_y + 2 SAY "Koordinate iznad kupac/ispod kupac/nar_otp-tabela"

      nX ++
      @ m_x + nX, m_y + 2 SAY "DX-1 :" GET nDx1 ;
         PICT "99"
      @ m_x + nX, Col() + 2 SAY "DX-2 :" GET nDx2 ;
         PICT "99"
      @ m_x + nX, Col() + 2 SAY "DX-3 :" GET nDx3 ;
         PICT "99"
      nX += 2
      @ m_x + nX, m_y + 2 SAY "SW-1 :" GET nSw1 ;
         PICT "99"
      @ m_x + nX, Col() + 2 SAY "SW-2 :" GET nSw2 ;
         PICT "99"
      @ m_x + nX, Col() + 2 SAY "SW-3 :" GET nSw3 ;
         PICT "99"
      @ m_x + nX, Col() + 2 SAY "SW-4 :" GET nSw4 ;
         PICT "99"
      @ m_x + nX, Col() + 2 SAY "SW-5 :" GET nSw5 ;
         PICT "99"
      nX += 2
      @ m_x + nX, m_y + 2 SAY "SW-6 :" GET nSw6 ;
         PICT "9"
      @ m_x + nX, Col() + 2 SAY "SW-7 :" GET nSw7 ;
         PICT "9"
      nX += 2

      // parametri fin.stanje na dod.txt...
      @ m_x + nX, m_y + 2 SAY "Ispis grupacije robe poslije naziva (D/N)" GET glRGrPrn PICT "@!" VALID glRGrPrn $ "DN"

      nX += 2

      // parametri fin.stanje na dod.txt...
      @ m_x + nX, m_y + 2 SAY "Prikaz fin.salda kupca/dobavljaca na dodatnom tekstu (D/N)" GET gShSld PICT "@!" VALID gShSld $ "DN"

      nX += 1

      @ m_x + nX, m_y + 2 SAY PadL( "Konto duguje:", 20 ) GET gFinKtoDug VALID !Empty( gFinKtoDug ) .AND. P_Konto( @gFinKtoDug ) WHEN gShSld == "D"

      nX += 1

      @ m_x + nX, m_y + 2 SAY PadL( "Konto potrazuje:", 20 ) GET gFinKtoPot VALID !Empty( gFinKtoPot ) .AND. P_Konto( @gFinKtoPot ) WHEN gShSld == "D"

      nX += 1

      @ m_x + nX, m_y + 2 SAY "Varijanta prikaza podataka (1/2)" GET gShSldVar PICT "9" VALID gShSldVar > 0 .AND. gShSldVar < 3 WHEN gShSld == "D"

   ENDIF

   READ

   BoxC()

   IF ( LastKey() <> K_ESC )

      WPar( "c1", cIzvj )
      WPar( "tf", @gTipF )
      WPar( "vf", @gVarF )
      WPar( "kr", @gKriz )
      WPar( "55", @gKrizA5 )
      WPar( "vr", @gVarRF )
      WPar( "56", gnLMargA5 )
      WPar( "a5", gFormatA5 )
      WPar( "fp", gFPzag )
      WPar( "51", gFPzagA5 )
      WPar( "52", gnTMarg2A5 )
      WPar( "53", gnTMarg3A5 )
      WPar( "54", gnTMarg4A5 )
      WPar( "d1", gnTMarg2 )
      WPar( "d2", gnTMarg3 )
      WPar( "d3", gnTMarg4 )
      WPar( "cr", gZnPrec )
      WPar( "ot", gOdvT2 )
      WPar( "tb", gTabela )
      WPar( "za", gZagl )
      WPar( "zb", gbold )
      WPar( "RT", gRekTar )
      WPar( "HL", gHLinija )
      WPar( "rp", gRabProc )

      cSection := "F"
      WPar( "x1", nDx1 )
      WPar( "x2", nDx2 )
      WPar( "x3", nDx3 )
      WPar( "x4", nSw1 )
      WPar( "x5", nSw2 )
      WPar( "x6", nSw3 )
      WPar( "x7", nSw4 )
      WPar( "x8", nSw5 )
      WPar( "x9", nSw6 )
      WPar( "y1", nSw7 )

      cSection := "1"

      set_metric( "fakt_odt_template_auto", NIL, _auto_odt )

      set_metric( "fakt_ispis_grupacije_na_dokumentu", nil, glRGrPrn )
      set_metric( "fakt_ispis_salda_kupca_dobavljaca", nil, gShSld )
      set_metric( "fakt_ispis_salda_kupca_dobavljaca_varijanta", nil, gShSldVar )
      set_metric( "konto_duguje", nil, gFinKtoDug )
      set_metric( "konto_potrazuje", nil, gFinKtoPot )

      set_metric( "fakt_dokument_dodati_redovi_po_listu", nil, gERedova )
      set_metric( "fakt_dokument_lijeva_margina", nil, gnLMarg )
      set_metric( "fakt_dokument_top_margina", nil, gnTMarg )
      set_metric( "fakt_dokument_delphirb_prikaz", nil, gPDVDrb )
      set_metric( "fakt_dokument_txt_prikaz_varijanta", nil, gPDVDokVar )

   ENDIF

   RETURN




FUNCTION fakt_par_nazivi_dokumenata()

   PRIVATE  GetList := {}

   O_PARAMS

   g10Str := PadR( g10Str, 20 )
   g16Str := PadR( g16Str, 20 )
   g06Str := PadR( g06Str, 20 )
   g11Str := PadR( g11Str, 20 )
   g12Str := PadR( g12Str, 20 )
   g13Str := PadR( g13Str, 20 )
   g15Str := PadR( g15Str, 20 )
   g20Str := PadR( g20Str, 20 )
   g21Str := PadR( g21Str, 20 )
   g22Str := PadR( g22Str, 20 )
   g23Str := PadR( g23Str, 20 )
   g25Str := PadR( g25Str, 20 )
   g26Str := PadR( g26Str, 24 )
   g27Str := PadR( g27Str, 20 )

   g10ftxt := PadR( g10ftxt, 100 )
   g11ftxt := PadR( g11ftxt, 100 )
   g12ftxt := PadR( g12ftxt, 100 )
   g13ftxt := PadR( g13ftxt, 100 )
   g15ftxt := PadR( g15ftxt, 100 )
   g16ftxt := PadR( g16ftxt, 100 )
   g20ftxt := PadR( g20ftxt, 100 )
   g21ftxt := PadR( g21ftxt, 100 )
   g22ftxt := PadR( g22ftxt, 100 )
   g23ftxt := PadR( g23ftxt, 100 )
   g25ftxt := PadR( g25ftxt, 100 )
   g26ftxt := PadR( g26ftxt, 100 )
   g27ftxt := PadR( g27ftxt, 100 )

   g10Str2T := PadR( g10Str2T, 132 )
   g16Str2T := PadR( g16Str2T, 132 )
   g06Str2T := PadR( g06Str2T, 132 )
   g11Str2T := PadR( g11Str2T, 132 )
   g15Str2T := PadR( g15Str2T, 132 )
   g12Str2T := PadR( g12Str2T, 132 )
   g13Str2T := PadR( g13Str2T, 132 )
   g20Str2T := PadR( g20Str2T, 132 )
   g21Str2T := PadR( g21Str2T, 132 )
   g22Str2T := PadR( g22Str2T, 132 )
   g23Str2T := PadR( g23Str2T, 132 )
   g25Str2T := PadR( g25Str2T, 132 )
   g26Str2T := PadR( g26Str2T, 132 )
   g27Str2T := PadR( g27Str2T, 132 )
   gNazPotStr := PadR( gNazPotStr, 132 )

   Box(, 22, 76, .F., "Naziv dokumenata, potpis na kraju, str. 1" )
   @ m_x + 1, m_y + 2 SAY "06 - Tekst"      GET g06Str
   @ m_x + 2, m_y + 2 SAY "06 - Potpis TXT" GET g06Str2T PICT"@S50"
   @ m_x + 4, m_y + 2 SAY "10 - Tekst"      GET g10Str
   @ m_x + 4, Col() + 1 SAY "d.txt lista:" GET g10ftxt PICT "@S25"
   @ m_x + 5, m_y + 2 SAY "10 - Potpis TXT" GET g10Str2T PICT"@S50"
   @ m_x + 7, m_Y + 2 SAY "11 - Tekst"      GET g11Str
   @ m_x + 7, Col() + 1 SAY "d.txt lista:" GET g11ftxt PICT "@S25"
   @ m_x + 8, m_y + 2 SAY "11 - Potpis TXT" GET g11Str2T PICT "@S50"
   @ m_x + 10, m_y + 2 SAY "12 - Tekst"      GET g12Str
   @ m_x + 10, Col() + 1 SAY "d.txt lista:" GET g12ftxt PICT "@S25"
   @ m_x + 11, m_y + 2 SAY "12 - Potpis TXT" GET g12Str2T PICT "@S50"
   @ m_x + 13, m_y + 2 SAY "13 - Tekst"      GET g13Str
   @ m_x + 13, Col() + 1 SAY "d.txt lista:" GET g13ftxt PICT "@S25"
   @ m_x + 14, m_y + 2 SAY "13 - Potpis TXT" GET g13Str2T PICT "@S50"
   @ m_x + 16, m_y + 2 SAY "15 - Tekst"      GET g15Str
   @ m_x + 16, Col() + 1 SAY "d.txt lista:" GET g15ftxt PICT "@S25"
   @ m_x + 17, m_y + 2 SAY "15 - Potpis TXT" GET g15Str2T PICT "@S50"
   @ m_x + 19, m_y + 2 SAY "16 - Tekst"      GET g16Str
   @ m_x + 19, Col() + 1 SAY "d.txt lista:" GET g16ftxt PICT "@S25"
   @ m_x + 20, m_y + 2 SAY "16 - Potpis TXT" GET g16Str2T PICT"@S50"
   READ
   BoxC()

   Box(, 22, 76, .F., "Naziv dokumenata, potpis na kraju, str. 2" )
   @ m_x + 1, m_y + 2 SAY "20 - Tekst"      GET g20Str
   @ m_x + 1, Col() + 1 SAY "d.txt lista:" GET g20ftxt PICT "@S25"
   @ m_x + 2, m_y + 2 SAY "20 - Potpis TXT" GET g20Str2T PICT "@S50"
   @ m_x + 4, m_y + 2 SAY "21 - Tekst"      GET g21Str
   @ m_x + 4, Col() + 1 SAY "d.txt lista:" GET g21ftxt PICT "@S25"
   @ m_x + 5, m_y + 2 SAY "21 - Potpis TXT" GET g21Str2T PICT "@S50"
   @ m_x + 7, m_y + 2 SAY "22 - Tekst"      GET g22Str
   @ m_x + 7, Col() + 1 SAY "d.txt lista:" GET g22ftxt PICT "@S25"
   @ m_x + 8, m_y + 2 SAY "22 - Potpis TXT" GET g22Str2T PICT"@S50"

   @ m_x + 10, m_y + 2 SAY "23 - Tekst"      GET g23Str
   @ m_x + 10, Col() + 1 SAY "d.txt lista:" GET g23ftxt PICT "@S25"
   @ m_x + 11, m_y + 2 SAY "23 - Potpis TXT" GET g23Str2T PICT"@S50"

   @ m_x + 13, m_y + 2 SAY "25 - Tekst"      GET g25Str
   @ m_x + 13, Col() + 1 SAY "d.txt lista:" GET g25ftxt PICT "@S25"
   @ m_x + 14, m_y + 2 SAY "25 - Potpis TXT" GET g25Str2T PICT"@S50"
   @ m_x + 16, m_y + 2 SAY "26 - Tekst"      GET g26Str
   @ m_x + 16, Col() + 1 SAY "d.txt lista:" GET g26ftxt PICT "@S25"
   @ m_x + 17, m_y + 2 SAY "26 - Potpis TXT" GET g26Str2T PICT"@S50"
   @ m_x + 19, m_y + 2 SAY "27 - Tekst"      GET g27Str
   @ m_x + 19, Col() + 1 SAY "d.txt lista:" GET g27ftxt PICT "@S25"
   @ m_x + 20, m_y + 2 SAY "27 - Potpis TXT" GET g27Str2T PICT"@S50"
   @ m_x + 22, m_y + 2 SAY "Dodatni red    " GET gNazPotStr PICT"@S50"

   READ
   BoxC()

   IF ( LastKey() <> K_ESC )

      set_metric( "fakt_dokument_dok_10_naziv", nil, g10Str )
      set_metric( "fakt_dokument_dok_10_potpis", nil, g10Str2T )
      set_metric( "fakt_dokument_dok_10_txt_lista", nil, g10ftxt )
      set_metric( "fakt_dokument_dok_11_naziv", nil, g11Str )
      set_metric( "fakt_dokument_dok_11_potpis", nil, g11Str2T )
      set_metric( "fakt_dokument_dok_11_txt_lista", nil, g11ftxt )
      set_metric( "fakt_dokument_dok_12_naziv", nil, g12Str )
      set_metric( "fakt_dokument_dok_12_potpis", nil, g12Str2T )
      set_metric( "fakt_dokument_dok_12_txt_lista", nil, g12ftxt )
      set_metric( "fakt_dokument_dok_13_naziv", nil, g13Str )
      set_metric( "fakt_dokument_dok_13_potpis", nil, g13Str2T )
      set_metric( "fakt_dokument_dok_13_txt_lista", nil, g13ftxt )
      set_metric( "fakt_dokument_dok_16_naziv", nil, g16Str )
      set_metric( "fakt_dokument_dok_16_potpis", nil, g16Str2T )
      set_metric( "fakt_dokument_dok_16_txt_lista", nil, g16ftxt )
      set_metric( "fakt_dokument_dok_20_naziv", nil, g20Str )
      set_metric( "fakt_dokument_dok_20_potpis", nil, g20Str2T )
      set_metric( "fakt_dokument_dok_20_txt_lista", nil, g20ftxt )
      set_metric( "fakt_dokument_dok_22_naziv", nil, g22Str )
      set_metric( "fakt_dokument_dok_22_potpis", nil, g22Str2T )
      set_metric( "fakt_dokument_dok_22_txt_lista", nil, g22ftxt )


      WPar( "r3", g06Str )
      WPar( "xl", @g15Str )
      WPar( "x9", @g21Str )
      WPar( "xC", @g23Str )
      WPar( "xf", @g25Str )
      WPar( "xi", @g26Str )
      WPar( "xo", @g27Str )

      WPar( "r4", @g06Str2T )
      WPar( "xm", @g15Str2T )
      WPar( "xa", @g21Str2T )
      WPar( "xD", @g23Str2T )
      WPar( "xg", @g25Str2T )
      WPar( "xj", @g26Str2T )
      WPar( "xp", @g27Str2T )

      WPar( "uc", @gNazPotStr )

      // liste
      WPar( "ye", @g15ftxt )
      WPar( "yh", @g21ftxt )
      WPar( "yI", @g23ftxt )
      WPar( "yj", @g25ftxt )
      WPar( "yk", @g26ftxt )
      WPar( "yl", @g27ftxt )

   ENDIF

   RETURN



FUNCTION P_WinFakt()

   cIniName := EXEPATH + 'proizvj.ini'

   cFirma := PadR( UzmiIzIni( cIniName, 'Varijable', 'Firma', '--', 'READ' ), 30 )
   cAdresa := PadR( UzmiIzIni( cIniName, 'Varijable', 'Adres', '--', 'READ' ), 30 )
   cTelefoni := PadR( UzmiIzIni( cIniName, 'Varijable', 'Tel', '--', 'READ' ), 50 )
   cFax := PadR( UzmiIzIni( cIniName, 'Varijable', 'Fax', '--', 'READ' ), 30 )
   cRBroj := PadR( UzmiIzIni( cIniName, 'Varijable', 'RegBroj', '--', 'READ' ), 13 )
   cPBroj := PadR( UzmiIzIni( cIniName, 'Varijable', 'PorBroj', '--', 'READ' ), 13 )
   cBrSudRj := PadR( UzmiIzIni( cIniName, 'Varijable', 'BrSudRj', '--', 'READ' ), 45 )
   cBrUpisa := PadR( UzmiIzIni( cIniName, 'Varijable', 'BrUpisa', '--', 'READ' ), 45 )
   cZRac1 := PadR( UzmiIzIni( cIniName, 'Varijable', 'ZRacun1', '--', 'READ' ), 45 )
   cZRac2 := PadR( UzmiIzIni( cIniName, 'Varijable', 'ZRacun2', '--', 'READ' ), 45 )
   cZRac3 := PadR( UzmiIzIni( cIniName, 'Varijable', 'ZRacun3', '--', 'READ' ), 45 )
   cZRac4 := PadR( UzmiIzIni( cIniName, 'Varijable', 'ZRacun4', '--', 'READ' ), 45 )
   cZRac5 := PadR( UzmiIzIni( cIniName, 'Varijable', 'ZRacun5', '--', 'READ' ), 45 )
   cZRac6 := PadR( UzmiIzIni( cIniName, 'Varijable', 'ZRacun6', '--', 'READ' ), 45 )
   cNazivRtm := PadR( IzFmkIni( 'Fakt', 'NazRTM', '', EXEPATH ), 15 )
   cNazivFRtm := PadR( IzFmkIni( 'Fakt', 'NazRTMFax', '', EXEPATH ), 15 )
   cPictLoc := PadR( UzmiIzIni( cIniName, 'Varijable', 'LokSlika', '--', 'READ' ), 30 )
   cDN := "D"

   Box(, 22, 63 )
   @ m_x + 1, m_Y + 2 SAY "Podesavanje parametara Win stampe:"
   @ m_x + 3, m_Y + 2 SAY "Naziv firme: " GET cFirma
   @ m_x + 4, m_Y + 2 SAY "Adresa: " GET cAdresa
   @ m_x + 5, m_Y + 2 SAY "Telefon: " GET cTelefoni
   @ m_x + 6, m_Y + 2 SAY "Fax: " GET cFax
   @ m_x + 7, m_Y + 2 SAY "Ziro racun 1: " GET cZRac1
   @ m_x + 8, m_Y + 2 SAY "Ziro racun 2: " GET cZRac2
   @ m_x + 9, m_Y + 2 SAY "Ziro racun 3: " GET cZRac3
   @ m_x + 10, m_Y + 2 SAY "Ziro racun 4: " GET cZRac4
   @ m_x + 11, m_Y + 2 SAY "Ziro racun 5: " GET cZRac5
   @ m_x + 12, m_Y + 2 SAY "Ziro racun 6: " GET cZRac6
   @ m_x + 13, m_Y + 2 SAY "Identifikac.broj: " GET cRBroj
   @ m_x + 14, m_Y + 2 SAY "Porezni dj. broj: " GET cPBroj
   @ m_x + 15, m_Y + 2 SAY "Br.sud.rjesenja: " GET cBrSudRj
   @ m_x + 16, m_Y + 2 SAY "Reg.broj upisa: " GET cBrUpisa

   @ m_x + 17, m_Y + 2 SAY "--------------------------------------------"
   @ m_x + 18, m_Y + 2 SAY "Lokacija slike: " GET cPictLoc
   @ m_x + 19, m_Y + 2 SAY "Naziv RTM fajla za fakture: " GET cNazivRtm
   @ m_x + 20, m_Y + 2 SAY "Naziv RTM fajla za slanje dok.faksom: " GET cNazivFRtm
   @ m_x + 21, m_Y + 2 SAY "Snimi podatke D/N? " GET cDN VALID cDN $ "DN" PICT "@!"
   READ
   BoxC()

   IF LastKey() = K_ESC
      RETURN
   ENDIF

   IF cDN == "D"
      UzmiIzIni( cIniName, 'Varijable', 'Firma', cFirma, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'Adres', cAdresa, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'Tel', cTelefoni, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'Fax', cFax, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'RegBroj', cRBroj, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'PorBroj', cPBroj, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'BrSudRj', cBrSudRj, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'BrUpisa', cBrUpisa, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'ZRacun1', cZRac1, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'ZRacun2', cZRac2, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'ZRacun3', cZRac3, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'ZRacun4', cZRac4, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'ZRacun5', cZRac5, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'ZRacun6', cZRac6, 'WRITE' )
      UzmiIzIni( EXEPATH + "fmk.ini", 'Fakt', 'NazRTM', cNazivRtm, 'WRITE' )
      UzmiIzIni( EXEPATH + "fmk.ini", 'Fakt', 'NazRTMFax', cNazivFRtm, 'WRITE' )
      UzmiIzIni( cIniName, 'Varijable', 'LokSlika', cPictLoc, 'WRITE' )
      MsgBeep( "Podaci snimljeni!" )
   ELSE
      RETURN
   ENDIF

   RETURN



// ----------------------------------------------------
// specificne funkcije za fakturisanje uglja
// ----------------------------------------------------
FUNCTION is_fakt_ugalj()
   RETURN .F.


// ----------------------------------------------------------------
// dodatni opis na stavke u fakt dokumentu
// ----------------------------------------------------------------
FUNCTION fakt_opis_stavke( value )
   RETURN get_set_global_param( "fakt_opis_stavke", value, "N" )



// ----------------------------------------------------------------
// unos objekata
// ----------------------------------------------------------------
FUNCTION fakt_objekti( value )
   RETURN get_set_global_param( "fakt_objekti", value, "N" )


// ----------------------------------------------------------------
// koriste se REF/LOT oznake
// ----------------------------------------------------------------
FUNCTION ref_lot( value )
   RETURN get_set_global_param( "ref_lot", value, "N" )


// ----------------------------------------------------------------
// prate se destinacije
// ----------------------------------------------------------------
FUNCTION destinacije( value )
   RETURN get_set_global_param( "destinacije", value, "N" )

// ----------------------------------------------------------------
// fakturise se po prodajnim mjestima
// ----------------------------------------------------------------
FUNCTION fakt_prodajna_mjesta( value )
   RETURN get_set_global_param( "fakt_prodajna_mjesta", value, "N" )


// ----------------------------------------------------------------
// fakturise se po prodajnim mjestima
// ----------------------------------------------------------------
FUNCTION fakt_dok_veze( value )
   RETURN get_set_global_param( "fakt_dok_veze", value, "N" )


// ----------------------------------------------------------------
// fakturise se po vrstama placanja
// ----------------------------------------------------------------
FUNCTION fakt_vrste_placanja( value )
   RETURN get_set_global_param( "fakt_unos_vrste_placanja", value, "N" )


// ----------------------------------------------------------------
// kada pravis otpremnicu pravi je po brojacu tip-a 22
// ----------------------------------------------------------------
FUNCTION fakt_otpr_22_brojac( value )
   RETURN get_set_global_param( "fakt_otpremnice_22_brojac", value, "N" )


// ----------------------------------------------------------------
// nova vrsta generisanja otpremnica...
// ----------------------------------------------------------------
FUNCTION fakt_otpr_gen( value )
   RETURN get_set_global_param( "fakt_otpremnice_gen_v2", value, "D" )

// ----------------------------------------------------------------
// kontrolisanje brojaca...
// ----------------------------------------------------------------
FUNCTION fakt_kontrola_brojaca_par( value )
   RETURN get_set_global_param( "fakt_kontrola_brojaca_dokumenta", value, "N" )
