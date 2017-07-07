/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"

// ------------------------------
// parametri generacije ugovora
// ------------------------------
STATIC FUNCTION g_ug_params( dDatObr, dDatGen, dDatVal, dDatLUpl, cKtoDug, cKtoPot, cOpis, cIdArt, nGenCh, cDestin, cDatLFakt, dLFakt, cAutoAzur )

   LOCAL dPom
   LOCAL nX := 2
   LOCAL nBoxLen := 20

   dDatGen := Date()

   // datum posljednjeg fakturisanja
   dLFakt := g_lst_fakt()
   // datum posljenje uplate u fin
   dDatLUpl := CToD( "" )
   // konto kupac
   cKtoDug := fetch_metric( "ugovori_konto_duguje", NIL, PadR( "2110", 7 ) )
   // konto dobavljac
   cKtoPot := fetch_metric( "ugovori_konto_potrazuje", NIL, PadR( "5410", 7 ) )
   // opis
   cOpis := PadR( "", 100 )
   // artikal
   cIdArt := PadR( "", 10 )
   // destinacije
   cDestin := "N"
   // datum posljednjeg fakturisanja partnera
   cDatLFakt := "N"
   cAutoAzur := "D"

   // choice
   nGenCh := 0

   IF dDatObr == nil
      dDatObr := Date()
   ENDIF
   IF dDatVal == nil
      dDatVal := Date()
   ENDIF

   dPom := dDatObr

   // mjesec na koji se odnosi fakturisanje
   nMjesec := Month( dPom )
   // godina na koju se odnosi fakturisanje
   nGodina := Year( dPom )

   Box( "#PARAMETRI ZA GENERACIJU FAKTURA PO UGOVORIMA v2", 22, 70 )

   @ m_x + nX, m_y + 2 SAY PadL( "Gen. ?/fakt/ponuda (0/1/2)", nBoxLen + 6 ) GET nGenCh ;
      PICT "9"

   nX += 1

   @ m_x + nX, m_y + 2 SAY PadL( "Datum fakturisanja", nBoxLen ) GET dDatGen

   nX += 2

   @ m_x + nX, m_y + 2 SAY PadL( "Datum valute", nBoxLen ) GET dDatVal

   nX += 2

   @ m_x + nX, m_y + 2 SAY PadL( "Fakt.za mjesec", nBoxLen ) GET nMjesec PICT "99" VALID nMjesec >= 1 .OR. nMjesec <= 12
   @ m_x + nX, Col() + 2 SAY "godinu" GET nGodina PICT "9999"

   nX += 2
   @ m_x + nX, m_y + 2 SAY PadL( "Konto duguje", nBoxLen ) GET cKtoDug VALID P_Konto( @cKtoDug )

   ++nX
   @ m_x + nX, m_y + 2 SAY PadL( "Konto potrazuje", nBoxLen ) GET cKtoPot VALID P_Konto( @cKtoPot )

   nX += 2
   @ m_x + nX, m_y + 2 SAY PadL( "Dat.zadnje upl.fin", nBoxLen ) GET dDatLUpl ;
      WHEN {|| dDatLUpl := dDatGen - 1, .T. }

   nX += 2

   @ m_x + nX, m_y + 2 SAY PadL( "Fakturisati artikal (prazno-svi)", nBoxLen + 10 ) GET cIdArt VALID Empty( cIdArt ) .OR. p_roba( @cIdArt )

   nX += 2

   @ m_x + nX, m_y + 2 SAY PadL( "Opis", nBoxLen ) GET cOpis ;
      WHEN  {|| cOpis := iif( Empty( cOpis ), PadR( "Obracun " + fakt_do( dDatObr ), 100 ), cOpis ), .T. } ;
      PICT "@S40"

   //IF is_dest()

      nX += 2
      @ m_x + nX, m_y + 2 SAY PadL( "Uzeti u obzir destinacije ?", nBoxLen + 10 ) GET cDestin VALID cDestin $ "DN" PICT "@!"

      nX += 1
      @ m_x + nX, m_y + 2 SAY PadL( "Gledati datum zadnjeg fakturisanja ?", nBoxLen + 16 ) GET cDatLFakt VALID cDatLFakt $ "DN" PICT "@!"

      nX += 1
      @ m_x + nX, m_y + 2 SAY PadL( "Datum zadnjeg fakturisanja ?", nBoxLen + 16 ) GET dLFakt

   //ELSE
  //    cDestin := nil
  // ENDIF

   nX += 1
   @ m_x + nX, m_y + 2 SAY PadL( "Automatski azuriraj fakture (D/N) ?", nBoxLen + 16 ) GET cAutoAzur ;
      VALID cAutoAzur $ "DN" PICT "@!"

   READ

   BoxC()

   ESC_RETURN 0

   dDatObr := mo_ye( nMjesec, nGodina )

   // snimi parametre
   set_metric( "ugovori_konto_duguje", NIL, cKtoDug )
   set_metric( "ugovori_konto_potrazuje", NIL, cKtoPot )

   RETURN 1


// -------------------------------------------
// generacija ugovora - varijanta 2
// -------------------------------------------
FUNCTION gen_ug_2()

   LOCAL dDatObr
   LOCAL dDatVal
   LOCAL dDatLUpl
   LOCAL cKtoDug
   LOCAL cKtoPot
   LOCAL cOpis
   LOCAL cFilter
   LOCAL lSetParams := .F.
   LOCAL cUId
   LOCAL cUPartner
   LOCAL nSaldo
   LOCAL nSaldoPDV
   LOCAL cNBrDok
   LOCAL nFaktBr
   LOCAL nMjesec
   LOCAL nGodina
   LOCAL dDatGen := Date()
   LOCAL cFaktOd
   LOCAL cFaktDo
   LOCAL cIdArt
   LOCAL cIdFirma
   LOCAL nTArea
   LOCAL cDestin
   LOCAL nGenCh
   LOCAL cGenTipDok := ""
   LOCAL cDatLFakt
   LOCAL dLFakt
   LOCAL __where, _rec
   LOCAL _count := 0
   LOCAL _auto_azur
   LOCAL _doks_generated := {}


   o_ugov_tabele()

   // otvori parametre generacije
   lSetParams := .T.

   IF lSetParams .AND. g_ug_params( @dDatObr, @dDatGen, @dDatVal, @dDatLUpl, @cKtoDug, @cKtoPot, @cOpis, @cIdArt, @nGenCh, @cDestin, @cDatLFakt, @dLFakt, @_auto_azur ) == 0
      RETURN
   ENDIF

   // otvori i fakt
   o_fakt()
   o_fakt_pripr()

   IF RecCount2() <> 0
      MsgBeep( "U pripremi postoje dokumenti#Prekidam generaciju!" )
      my_close_all_dbf()
      RETURN
   ENDIF

   // ako postoji vec generisano za datum sta izadji ili nastavi
   IF lSetParams .AND. postoji_generacija( dDatObr, cIdArt ) == 0
      RETURN
   ENDIF

   // dodaj u gen_ug novu generaciju
   IF lSetParams

      SELECT gen_ug
      SET ORDER TO TAG "dat_obr"
      SEEK DToS( dDatObr )

      IF !Found()
         APPEND BLANK
      ENDIF

      _rec := dbf_get_rec()

      _rec[ "dat_obr" ] := dDatObr
      _rec[ "dat_gen" ] := dDatGen
      _rec[ "dat_u_fin" ] := dDatLUpl
      _rec[ "kto_kup" ] := cKtoDug
      _rec[ "kto_dob" ] := cKtoPot
      _rec[ "opis" ] := cOpis

      update_rec_server_and_dbf( "fakt_gen_ug", _rec, 1, "FULL" )

   ENDIF

   // filter na samo aktivne ugovore
   cFilter := "aktivan == 'D'"

   SELECT ugov
   SET ORDER TO TAG "ID"
   SET FILTER TO &cFilter
   GO TOP

   nSaldo := 0
   nSaldoPDV := 0
   nNBrDok := ""

   // ukupni broj faktura
   nFaktBr := 0

   IF nGenCh == 1
      cGenTipDok := "10"
   ENDIF

   IF nGenCh == 2
      cGenTipDok := "20"
   ENDIF

   Box(, 3, 60 )

   @ m_x + 1, m_y + 2 SAY "Generacija ugovora u toku..."

   cFaktOd := ""
   cFaktDo := ""

   // precesljaj ugovore u UGOV
   DO WHILE !Eof()

      // da li ima stavki za fakturisanje ???
      IF !ima_u_rugov( ugov->id, cIdArt )
         SKIP
         LOOP
      ENDIF

      SELECT ugov

      // provjeri da li treba fakturisati ???
      IF !treba_generisati( ugov->id, dDatObr, cDatLFakt, dLFakt )
         SKIP
         LOOP
      ENDIF

      IF !Empty( cIdArt )
         // uzmi firmu na osnovu artikla
         cIdFirma := g_idfirma( cIdArt )
      ELSE
         cIdFirma := self_organizacija_id()
      ENDIF

      ++_count

      IF Empty( cGenTipDok )
         cGenTipDok := ugov->idtipdok
      ENDIF

      cNBrDok := fakt_novi_broj_dokumenta( cIdFirma, cGenTipDok )

      IF _count == 1
         cFaktOd := cNBrDok
      ENDIF

      cUId := ugov->id
      cUPartner := ugov->idpartner

      // destinacije ...
      IF cDestin <> NIL .AND. cDestin == "D"
         cDefDest := ugov->def_dest
      ELSE
         cDefDest := nil
      ENDIF

      @ m_x + 2, m_y + 2 SAY "Ug / Partner -> " + cUId + " / " + cUPartner

      // generisi ugovor za partnera
      g_ug_f_partner( cUId, cUPartner, dDatObr, dDatVal, @nSaldo, @nSaldoPDV, @nFaktBr, @cNBrDok, cIdArt, cIdFirma, cDefDest, cGenTipDok, @_doks_generated )

      SELECT ugov
      SKIP

   ENDDO

   cFaktDo := cNBrDok


   // upisi u gen_ug salda
   SELECT gen_ug
   SET ORDER TO TAG "dat_obr"
   GO TOP
   SEEK DToS( dDatObr ) + cIdArt

   IF Found()

      _rec := dbf_get_rec()
      _rec[ "fakt_br" ] := nFaktBr
      _rec[ "saldo" ] := nSaldo
      _rec[ "saldo_pdv" ] := nSaldoPDV
      _rec[ "dat_gen" ] := dDatGen
      _rec[ "dat_val" ] := dDatVal
      _rec[ "brdok_od" ] := cFaktOd
      _rec[ "brdok_do" ] := cFaktDo

      update_rec_server_and_dbf( "fakt_gen_ug", _rec, 1, "FULL" )

   ENDIF

   BoxC()

   // prikazi info generacije
   s_gen_info( dDatObr )

   // ako je opcija automatike ukljucena
   IF _auto_azur == "D"
      // funkcija azuriranja modula FAKT
      fakt_azuriraj_dokumente_u_pripremi( .T. )
   ENDIF

   // prikazi info o generisanim dokumentima
   info_generated_data( _doks_generated )

   RETURN


// --------------------------------------------
// vraca firmu na osnovu roba->k2
// --------------------------------------------
STATIC FUNCTION g_idfirma( cArt_id )

   LOCAL nTArea := Select()
   LOCAL cFirma := self_organizacija_id()

   SELECT roba
   GO TOP
   SEEK cArt_id

   IF Found()
      IF !Empty( field->k2 ) ;
            .AND. Len( AllTrim( field->k2 ) ) == 2

         cFirma := AllTrim( field->k2 )

      ENDIF
   ENDIF

   SELECT ( nTArea )

   RETURN cFirma


// ------------------------------------------
// da li partnera treba generisati
// ------------------------------------------
STATIC FUNCTION treba_generisati( cUgovId, dDatObr, cDatLFakt, dLFakt )

   LOCAL nPMonth
   LOCAL nPYear
   LOCAL i
   LOCAL lNasaoObracun

   // predhodni obracun
   LOCAL dPObr
   LOCAL cNFakt

   IF cDatLFakt == nil
      cDatLFakt := "N"
   ENDIF


   PushWA()

   dPom := dDatObr

   SELECT ugov
   SEEK cUgovId


   // pogledaj datum zadnjeg fakturisanja....
   IF cDatLFakt == "D"
      IF !Empty( ugov->dat_l_fakt ) .AND. ugov->dat_l_fakt < dLFakt
         PopWa()
         RETURN .F.
      ENDIF
   ENDIF

   // istekao je krajnji rok trajanja ugovora
   IF ugov->datdo < dDatObr
      PopWa()
      RETURN .F.
   ENDIF

   // nivo fakturisanja
   cFNivo := ugov->f_nivo

   SELECT gen_ug_p
   SET ORDER TO TAG "DAT_OBR"

   // GODISNJI NIVO...
   IF ugov->f_nivo == "G"

      dPObr := ugov->dat_l_fakt

      PopWa()

      IF dDatObr - 365 >= dPObr
         RETURN .T.
      ELSE
         RETURN .F.
      ENDIF

   ELSE

      lNasaoObracun := .F.
      // gledamo obracune u predhodnih 6 mjeseci
      FOR i := 1 TO 6

         // predhodni mjesec (datum) u odnosu na dPom
         dPObr := pr_mjesec( dPom )

         // ima li ovaj obracun pohranjen
         SELECT gen_ug_p
         SEEK DToS( dPObr ) + cUgovId + ugov->IdPartner

         IF Found()
            lNasaoObracun := .T.
            EXIT
         ELSE
            // nisam nasao ovaj obracun,
            // pokusaj ponovo mjesec ispred ...
            dPom := dPObr
         ENDIF
      NEXT

      IF !lNasaoObracun
         // nisam nasao obracun, ovo je prva generacija
         // pa je u ugov upisan datum posljednjeg obracuna
         dPObr := ugov->dat_l_fakt
      ELSE
         // ako su rucno pravljene fakture (unaprijed)
         // u ugov se upisuje do kada je to pravljeno
         IF ugov->dat_l_fakt >= dDatObr
            dPObr := ugov->dat_l_fakt
         ENDIF
      ENDIF

      PopWa()

      IF dDatObr > dPObr
         RETURN .T.
      ELSE
         RETURN .F.
      ENDIF
   ENDIF

   RETURN

// -----------------------------------
// predhodni mjesec
// -----------------------------------
STATIC FUNCTION pr_mjesec( dPom )

   LOCAL nPMonth
   LOCAL nPYear

   nPMonth := Month( dPom ) - 1
   nPYear := Year( dPom )

   IF nPMonth == 0
      // dPom je bio 01/YYYY
      nPMonth := 12
      nPYear--
   ENDIF

   RETURN  dPObr := mo_ye( nPMonth, nPYear )


// -----------------------------------------
// da li ima stavki u rugovu za ugovor
// -----------------------------------------
STATIC FUNCTION ima_u_rugov( cIdUgovor, cArt_id )

   LOCAL nTArr
   LOCAL lRet := .F.

   nTArr := Select()
   SELECT rugov

   IF cArt_id == nil
      cArt_id := ""
   ENDIF

   IF Empty( cArt_id )
      SEEK cIdUgovor
   ELSE
      SEEK cIdUgovor + cArt_id
   ENDIF

   IF Found()
      lRet := .T.
   ENDIF

   SELECT ( nTArr )

   RETURN lRet


// --------------------------------
// prikazi info o generaciji
// --------------------------------
STATIC FUNCTION s_gen_info( dDat )

   LOCAL cPom

   SELECT gen_ug
   SET ORDER TO TAG "dat_obr"
   GO TOP
   SEEK DToS( dDat )

   IF Found()

      cPom := "Generisani ugovor za " + DToC( dDat )
      cPom += "##"
      cPom += "Broj faktura: " + AllTrim( Str( field->fakt_br ) )
      cPom += "#"
      cPom += "Saldo: " + AllTrim( Str( field->saldo, 12, 2 ) )
      cPom += "#"
      cPom += "PDV: " + AllTrim( Str( field->saldo_pdv, 12, 2 ) )
      cPom += "#"
      cPom += "Fakture od: " + AllTrim( gen_ug->brdok_od ) + " - " + AllTrim( gen_ug->brdok_do )

      MsgBeep( cPom )

   ENDIF

   RETURN .T.


// ------------------------------------
// nastimaj partnera u PARTN
// ------------------------------------
STATIC FUNCTION n_partner( cId )

   LOCAL nTArr

   nTArr := Select()
   select_o_partner( cId )
   SELECT ( nTArr )

   RETURN .T.


// ------------------------------------
// nastimaj roba u ROBI
// ------------------------------------
STATIC FUNCTION n_roba( cId )

   LOCAL nTArr

   nTArr := Select()
   SELECT roba
   SEEK cId
   SELECT ( nTArr )

   RETURN .T.


// ------------------------------------
// nastimaj destinaciju u DEST
// ------------------------------------
STATIC FUNCTION n_dest( cPartn, cDest )

   LOCAL nTArr
   LOCAL lRet := .F.

   nTArr := Select()
   SELECT dest
   SET ORDER TO TAG "ID"
   GO TOP
   SEEK cPartn + cDest

   IF Found()
      lRet := .T.
   ENDIF

   SELECT ( nTArr )

   RETURN lRet


// ----------------------------------------------------------
// generacija ugovora za jednog partnera
// aData - sadrzi matricu generisanih faktura sa opisima
// ----------------------------------------------------------
STATIC FUNCTION g_ug_f_partner( cUId, cUPartn, dDatObr, dDatVal, nGSaldo, nGSaldoPDV, nFaktBr, cBrDok, cArtikal, cFirma, cDestin, cFTipDok, aData )

   LOCAL dDatGen
   LOCAL cIdUgov
   LOCAL i
   LOCAL nRbr
   LOCAL nCijena
   LOCAL nFaktIzn := 0
   LOCAL nFaktPDV := 0
   LOCAL cTxt1
   LOCAL cTxt2
   LOCAL cTxt3
   LOCAL cTxt4
   LOCAL cTxt5
   LOCAL nSaldoKup := 0
   LOCAL nSaldoDob := 0
   LOCAL dPUplKup := CToD( "" )
   LOCAL dPPromKup := CToD( "" )
   LOCAL dPPRomDob := CToD( "" )
   LOCAL cPom
   LOCAL nCount
   LOCAL nPorez
   LOCAL cKtoPot
   LOCAL cKtoDug
   LOCAL dDatLFakt
   LOCAL nMjesec
   LOCAL nGodina
   LOCAL lFromDest
   LOCAL _rec
   LOCAL __destinacija

   SELECT gen_ug
   SET ORDER TO TAG "dat_obr"
   SEEK DToS( dDatObr )

   cKtoPot := gen_ug->kto_dob
   cKtoDug := gen_ug->kto_kup
   dDatLUpl := gen_ug->dat_u_fin
   dDatGen := gen_ug->dat_gen
   nMjesec := gen_ug->( Month( dat_obr ) )
   nGodina := gen_ug->( Year( dat_obr ) )

   // nastimaj PARTN na partnera
   n_partner( cUPartn )

   IF Empty( cFTipDok )
      cFTipdok := ugov->idtipdok
   ENDIF

   nRbr := 0
   cIdUgov := ugov->id

   SELECT rugov
   nCount := 0

   // prodji kroz rugov
   DO WHILE !Eof() .AND. ( id == cUId )

      lFromDest := .F.

      IF !Empty( cArtikal )

         // ako postoji zadata roba...
         // ako rugov->idroba nije predmet fakturisanja
         // preskoci tu stavku ...

         IF cArtikal <> rugov->idroba

            SELECT rugov
            SKIP
            LOOP

         ENDIF

      ENDIF

      nCijena := rugov->cijena
      nKolicina := rugov->kolicina
      nRabat := rugov->rabat

      // nastimaj destinaciju
      IF cDestin <> NIL .AND. !Empty( cDestin )

         // postoji def. destinacija za svu robu
         IF n_dest( cUPartn, cDestin )
            lFromDest := .T.
         ENDIF

      ELSEIF cDestin <> NIL .AND. Empty( cDestin )

         // za svaku robu treba posebna faktura
         IF n_dest( cUPartn, rugov->dest )
            lFromDest := .T.
         ENDIF

         // daj novi broj dokumenta....
         IF lFromDest == .T. .AND. nCount > 0

            // uvecaj uk.broj gen.faktura
            ++nFaktBr

            // resetuj brojac stavki na 0
            nRbr := 0

            // uvecaj broj dokumenta
            cBrDok := fakt_novi_broj_dokumenta( cFirma, cFTipDok )

         ENDIF

      ENDIF

      // nastimaj roba na rugov-idroba
      n_roba( rugov->idroba )

      select_o_tarifa( roba->idtarifa )
      nPorez := tarifa->opp

      SELECT fakt_pripr
      APPEND BLANK

      ++nCount

      Scatter()

      // ako je roba tip U
      IF roba->tip == "U"

         // aMemo[1]
         // pronadji djoker #ZA_MJ#
         cPom := str_za_mj( roba->naz, nMjesec, nGodina )

         // dodaj ovo u _txt
         a_to_txt( cPom )
      ELSE
         // aMemo[1]
         a_to_txt( "", .T. )
      ENDIF

      // samo na prvoj stavci generisi txt
      IF nRbr == 0

         // nadji tekstove
         cTxt1 := f_ftxt( ugov->idtxt )
         cTxt2 := f_ftxt( ugov->iddodtxt )
         cTxt3 := f_ftxt( ugov->txt2 )
         cTxt4 := f_ftxt( ugov->txt3 )
         cTxt5 := f_ftxt( ugov->txt4 )

         SELECT fakt_pripr

         // aMemo[2]
         cPom := cTxt1 + cTxt2 + cTxt3 + cTxt4 + cTxt5
         // dodaj u polje _txt
         a_to_txt( cPom )

         // dodaj podatke o partneru

         // aMemo[3]
         // naziv partnera
         cPom := AllTrim( partn->naz )
         a_to_txt( cPom )

         // adresa
         // aMemo[4]
         cPom := AllTrim( partn->adresa )
         a_to_txt( cPom )

         // ptt i mjesto
         // aMemo[5]
         cPom := AllTrim( partn->ptt )
         cPom += " "
         cPom += AllTrim( partn->mjesto )
         a_to_txt( cPom )

         // br.otpremnice i datum
         // aMemo[6,7]
         a_to_txt( "", .T. )
         a_to_txt( "", .T. )

         // br. ugov
         // aMemo[8]
         a_to_txt( ugov->id, .T. )

         cPom := DToC( dDatGen )

         // datum isporuke
         // aMemo[9]
         cPom := DToC( dDatVal )
         a_to_txt( cPom )

         // datum valute
         // aMemo[10]
         a_to_txt( cPom )

         __destinacija := ""

         IF lFromDest == .T.

            // dodaj prazne zapise
            cPom := " "
            FOR i := 11 TO 17
               a_to_txt( cPom, .T. )
            NEXT

            // uzmi iz destinacije
            cPom := ""
            cPom += AllTrim( dest->naziv )

            IF !Empty( dest->naziv2 )
               cPom += " "
               cPom += AllTrim( dest->naziv2 )
            ENDIF

            IF !Empty( dest->mjesto )
               cPom += ", "
               cPom += AllTrim( dest->mjesto )
            ENDIF

            IF !Empty( dest->adresa )
               cPom += ", "
               cPom += AllTrim( dest->adresa )
            ENDIF

            IF !Empty( dest->ptt )
               cPom += ", "
               cPom += AllTrim( dest->ptt )
            ENDIF

            IF !Empty( dest->telefon )
               cPom += ", tel: "
               cPom += AllTrim( dest->telefon )
            ENDIF

            IF !Empty( dest->fax )
               cPom += ", fax: "
               cPom += AllTrim( dest->fax )
            ENDIF

            __destinacija := cPom

            a_to_txt( cPom, .T. )

         ENDIF

      ENDIF

      SELECT fakt_pripr

      _idfirma := cFirma
      _idpartner := cUPartn
      _zaokr := ugov->zaokr
      _rbr := Str( ++nRbr, 3 )
      _idtipdok := cFTipDok
      _brdok := cBrDok
      _datdok := dDatGen
      _datpl := dDatGen
      _kolicina := nKolicina
      _idroba := rugov->idroba
      _cijena := nCijena

      // setuj iz sifrarnika
      IF _cijena == 0
         fakt_setuj_cijenu( "1" )
         nCijena := _cijena
      ENDIF

      _rabat := rugov->rabat

      // ne smije se setovati porez u tabeli pripreme,
      // napravit ce kurslus !!
      // _porez := rugov->porez

      _dindem := ugov->dindem

      nFaktIzn += nKolicina * nCijena
      nFaktPDV += nFaktIzn * ( nPorez / 100 )

      nGSaldo += nFaktIzn
      nGSaldoPDV += nFaktPDV

      // dodaj u kontrolnu matricu sta je generisano
      add_to_generated_data( @aData, _idfirma, _idtipdok, _brdok, _idpartner, __destinacija )

      my_rlock()
      Gather()
      my_unlock()

      // resetuj _txt
      _txt := ""

      SELECT rugov
      SKIP

   ENDDO

   // saldo kupca
   nSaldoKup := get_fin_partner_saldo( cUPartn, cKtoDug )
   // saldo dobavljaca
   nSaldoDob := get_fin_partner_saldo( cUPartn, cKtoPot )
   // datum zadnje uplate kupca
   dPUplKup := g_dpupl_part( cUPartn, cKtoDug )
   // datum zadnje promjene kupac
   dPPromKup := datum_posljednje_promjene_kupac_dobavljac( cUPartn, cKtoDug )
   // datum zadnje promjene dobavljac
   dPPromDob := datum_posljednje_promjene_kupac_dobavljac( cUPartn, cKtoPot )

   // dodaj stavku u gen_ug_p
   a_to_gen_p( dDatObr, cUId, cUPartn, nSaldoKup, nSaldoDob, dPUplKup, dPPromKup, dPPromDob, nFaktIzn, nFaktPdv )

   // uvecaj broj faktura
   ++nFaktBr

   SELECT gen_ug
   SET ORDER TO TAG "dat_obr"
   SEEK DToS( dDatGen )

   IF Found()

      _rec := dbf_get_rec()
      // broj prve fakture
      IF Empty( field->brdok_od )
         _rec[ "brdok_od" ] := cBrDok
      ENDIF
      _rec[ "brdok_do" ] := cBrDok
      update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
   ENDIF

   // vrati se na pripremu i pregledaj djokere na _TXT
   SELECT fakt_pripr
   nTRec := RecNo()

   // vrati se na prvu stavku ove fakture
   SKIP -( nCount - 1 )

   Scatter()

   // obradi djokere
   txt_djokeri( nSaldoKup, nSaldoDob, dPUplKup, dPPromKup, dPPromDob, dDatLUpl, cUPartn )

   my_rlock()
   Gather()
   my_unlock()

   GO ( nTRec )

   RETURN


// ----------------------------------------------------------------------
// dodaj u kontrolnu matricu sta je generisano
// ----------------------------------------------------------------------
STATIC FUNCTION add_to_generated_data( DATA, ;
      id_firma, id_tip_dok, br_dok, ;
      id_partner, destinacija )

   _scan := AScan( DATA, {| srch | srch[ 1 ] == id_firma .AND.  srch[ 2 ] == id_tip_dok .AND.  srch[ 3 ] == br_dok } )

   IF _scan == 0
      AAdd( DATA, { id_firma, id_tip_dok, br_dok, id_partner, destinacija } )
   ENDIF

   RETURN

// ----------------------------------------------------------------------
// prikaz generisanih podataka
//
// data = [ idfirma, idtipdok, brdok, idpartner, destinacija ]
// ----------------------------------------------------------------------
STATIC FUNCTION info_generated_data( DATA )

   LOCAL nI
   LOCAL _cnt := 0

   START PRINT CRET

   o_partner()

   ?
   ? "Pregled generisanih dokumenata prema kupcima:"
   ? "----------------------------------------------"
   P_COND2
   ?
   ? PadR( "R.br", 5 ), PadR( "dokument", 15 ), PadR( "partner", 34 ), PadR( "destinacija", 100 )
   ? Replicate( "-", 150 )

   FOR nI := 1 TO Len( DATA )

      select_o_partner( DATA[ nI, 4 ] )

      ? PadL( AllTrim( Str( ++_cnt ) ), 4 ) + "."

      @ PRow(), PCol() + 1 SAY PadR( DATA[ nI, 1 ] + "-" + DATA[ nI, 2 ] + "-" + AllTrim( DATA[ nI, 3 ] ), 15 )
      @ PRow(), PCol() + 1 SAY PadR( DATA[ nI, 4 ], 6 ) + " - " + PadR( partn->naz, 25 )
      @ PRow(), PCol() + 1 SAY PadR( DATA[ nI, 5 ], 100 )

   NEXT

   FF
   ENDPRINT

   RETURN .T.



// --------------------------------------------
// provjerava da li postoji generacija u GEN_UG
// --------------------------------------------
STATIC FUNCTION postoji_generacija( dDatObr, cIdArt )

   IF !Empty( cIdArt )
      RETURN 1
   ENDIF

   SELECT gen_ug
   SET ORDER TO TAG "dat_obr"
   SEEK DToS( dDatObr )

   IF !Found()
      RETURN 1
   ENDIF

   IF Pitanje(, "Obracun " + fakt_do( dDatObr ) + " postoji, ponoviti (D/N)?", "D" ) == "D"
      vrati_nazad( dDatObr, cIdArt )

      my_close_all_dbf()
      o_ugov_tabele()
      o_fakt()
      o_fakt_pripr()
      SELECT gen_ug
      SET ORDER TO TAG "dat_obr"
      SEEK DToS( dDatObr )
      RETURN 1
   ENDIF

   RETURN 0


// ---------------------------------------------
// vrati obracun nazad
// ---------------------------------------------
STATIC FUNCTION vrati_nazad( dDatObr, cIdArt )

   LOCAL cBrDokOdDo
   LOCAL cFirma := self_organizacija_id()

   SELECT gen_ug
   SET ORDER TO TAG "dat_obr"
   GO TOP
   SEEK DToS( dDatObr )

   IF !Found()
      MsgBeep( "Obracun " + fakt_do( dDatObr ) + " ne postoji" )
      RETURN
   ENDIF

   IF !Empty( cIdArt )
      cFirma := g_idfirma( cIdArt )
   ENDIF

   IF fakt_dokument_postoji( cFirma, "10", gen_ug->brdok_od ) .AND. ;
         fakt_dokument_postoji( cFirma, "10", gen_ug->brdok_do )

      cBrDokOdDo := gen_ug->brdok_od + "--" +  gen_ug->brdok_do + ";"
      Povrat_fakt_po_kriteriju( cBrDokOdDo, NIL, NIL, cFirma )

   ENDIF

   // izbrisi pripremu
   o_fakt_pripr()

   fakt_brisanje_pripreme()

   RETURN



// ------------------------------------------------
// vraca datum zadnjeg fakturisanja
// ------------------------------------------------
STATIC FUNCTION g_lst_fakt()

   LOCAL nTArea := Select()
   LOCAL dGen

   SELECT gen_ug
   SET ORDER TO TAG "dat_obr"
   GO BOTTOM
   dGen := field->dat_gen
   SELECT ( nTArea )

   RETURN dGen
