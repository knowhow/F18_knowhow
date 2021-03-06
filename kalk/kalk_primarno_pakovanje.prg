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

/*

FUNCTION NaPrimPak()

   LOCAL nStavki := 0, nKolicina := 0, nUlaz := 0, nIzlaz := 0, dDatKalk, cBrDok

   IF my_get_from_ini( "Svi", "Sifk" ) <> "D"
      MsgBeep( "Sifrarnik dodatnih karakteristika nedostupan! (Sifk<>'D')" )
      RETURN .F.
   ENDIF

   o_koncij()
  // o_roba()
   o_kalk_pripr()
   -- o_kalk_doks()
   -- o_kalk()
--   o_sifk()
--   o_sifv()

   dDatKalk := Date()
   qqProd := PadR( "132;", 80 )
   qqRoba := Space( 80 )

   Box( "#USLOVI ZA GENERISANJE DOKUMENTA SVODJENJA NA PRIMARNO PAKOVANJE", 5, 70 )
   DO WHILE .T.
      @ box_x_koord() + 2, box_y_koord() + 2 SAY "PRODAVNICE:" GET qqProd PICT "@S30"
      @ box_x_koord() + 3, box_y_koord() + 2 SAY "ROBA      :" GET qqRoba PICT "@S30"
      @ box_x_koord() + 4, box_y_koord() + 2 SAY "DATUM DOK.:" GET dDatKalk
      READ; ESC_BCR
      aUsl1 := Parsiraj( qqProd, "PKONTO" )
      // aUsl1 := Parsiraj(qqProd,"MKONTO")
      aUsl2 := Parsiraj( qqRoba, "IDROBA" )
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL; EXIT; ENDIF
   ENDDO
   BoxC()

   // utvrdimo broj nove kalkulacije
   // ------------------------------
   cIdVdI := "80"
   cIdFirma := self_organizacija_id()

   find_kalk_doks_by_broj_dokumenta( cIdFirma, cIdVdI )
   //SELECT kalk_doks; SEEK cIdFirma + cIdVdI + Chr( 255 ); SKIP -1
   GO BOTTOM
   IF cIdFirma + cIdVdI == IDFIRMA + IDVD
      cBrDok := brdok
   ELSE
      cBrDok := Space( 8 )
   ENDIF
   -- cBrDok := UBrojDok( Val( Left( cBrDok, 5 ) ) + 1, 5, Right( cBrDok, 3 ) )
   nRBr := 0

   // postavimo odgovarajuci indeks i filter na KALK
   // ----------------------------------------------
   cFilter := aUsl1 + ".and." + aUsl2 + ".and. !EMPTY(PKONTO)"
   // cFilter:=aUsl1+".and."+aUsl2+".and. !EMPTY(MKONTO)"

   SELECT KALK
   SET ORDER TO TAG "4"



   SET FILTER TO &cFilter

   GO TOP
   COUNT TO nStavki

   Postotak( 1, nStavki, "Generacija dokumenata" )
   nStavki := 0
   GO TOP
   DO WHILE !Eof()
      cIdKonto := PKONTO

  --    SELECT KONCIJ
      HSEEK cIdKonto

      SELECT KALK
      DO WHILE !Eof() .AND. PKONTO == cIdKonto
         cIdRoba := IDROBA
         nUlaz := nIzlaz := nMPV := nNV := 0
         // kartica artikla
         // ---------------
         DO WHILE !Eof() .AND. PKONTO == cIdKonto .AND. IDROBA == cIdRoba
            KaKaProd( @nUlaz, @nIzlaz, @nMPV, @nNV )
            Postotak( 2, ++nStavki )
            SKIP 1
         ENDDO
         SELECT sifv   // "ID","id+oznaka+IdSif+Naz"
         SET ORDER TO TAG "ID"
         SEEK PadR( "ROBA", 8 ) + "PAKO" + PadR( cIdRoba, 15 )
         aSastav := {}
         // napuni matricu aSastav parovima ("SIFRA",KOLICINA)
         // --------------------------------------------------
         DO WHILE !Eof() .AND. ( id + oznaka + idsif = PadR( "ROBA", 8 ) + "PAKO" + PadR( cIdRoba, 15 ) )
            cPom := Trim( naz )
            IF NumToken( cPom, "_" ) = 2
               AAdd ( aSastav, { Token( cPom, "_", 1 ), Val( Token( cPom, "_", 2 ) )  } )
            ENDIF
            SKIP
         ENDDO

         SELECT kalk_pripr
         // generisi stavke storna zaduzenja primarnih pakovanja ("sirovina")
         // -----------------------------------------------------------------
         nUkNV := 0
         FOR i := 1 TO Len( aSastav )
            cIdPrim := aSastav[ i, 1 ]
      --      SELECT ROBA; SEEK cIdPrim
            nKolicina := aSastav[ i, 2 ]
            nNC := NCuMP( cIdFirma, cIdPrim, cIdKonto, ;
               ( nUlaz - nIzlaz ) * nKolicina, dDatKalk )
            SELECT kalk_pripr
            IF ( ( nulaz - nizlaz ) * nkolicina  <> 0 )
               APPEND BLANK
               nRBr++
               REPLACE idfirma    WITH cIdFirma,;
                  rbr        WITH Str( nRbr, 3 ),;
                  idvd       WITH cIdVdI,;
                  brdok      WITH cBrDok,;
                  datdok     WITH dDatKalk,;
                  idtarifa   WITH ROBA->idtarifa,;
                  brfaktp    WITH "",;
                  datfaktp   WITH dDatKalk,;
                  idkonto    WITH cidkonto,;
                  idzaduz    WITH "",;
                  idkonto2   WITH "",;
                  idzaduz2   WITH "",;
                  nc         WITH nNC,;
                  mpc        WITH 0,;
                  tmarza2    WITH "A",;
                  tprevoz    WITH "A",;
                  mpcsapp    WITH kalk_get_mpc_by_koncij_pravilo(),;
                  idroba     WITH cidPrim,;
                  KOLICINA   with ( nUlaz - nIzlaz ) * nKolicina
               nUkNV += kolicina * nc
            ENDIF
         NEXT
         // generisi stavku zaduzenja sekundarnog pakovanja
         // -----------------------------------------------
         IF Len( aSastav ) != 0
        ==    SELECT ROBA
      --      HSEEK cidroba
            SELECT kalk_pripr        // kalk_priprema dokumenta
            IF ( ( nulaz - nizlaz )  <> 0 )
               nRBr++
               APPEND BLANK
               // zaduzi sekundarno pakovanje, uobicajeno je nulaz-nizlaz = -50 pak
               REPLACE idfirma    WITH cIdFirma,;
                  rbr        WITH Str( nRbr, 3 ),;
                  idvd       WITH cIdVdI,;
                  brdok      WITH cBrDok,;
                  datdok     WITH dDatKalk,;
                  idtarifa   WITH ROBA->idtarifa,;
                  brfaktp    WITH "",;
                  datfaktp   WITH dDatKalk,;
                  idkonto    WITH cidkonto,;
                  idzaduz    WITH "",;
                  idkonto2   WITH "",;
                  idzaduz2   WITH "",;
                  nc         WITH nUkNV / ( nUlaz - nIzlaz ),;
                  mpc        WITH 0,;
                  tmarza2    WITH "A",;
                  tprevoz    WITH "A",;
                  mpcsapp    WITH kalk_get_mpc_by_koncij_pravilo(),;
                  idroba     WITH cidroba,;
                  KOLICINA   WITH -( nUlaz - nIzlaz )
            ENDIF
         ENDIF
         SELECT KALK
      ENDDO
      cBrDok := UBrojDok( Val( Left( cBrDok, 5 ) ) + 1, 5, Right( cBrDok, 3 ) )
      nRBr := 0
   ENDDO
   Postotak( -1 )
   MsgBeep( "Obradite izgenerisane dokumente u kalk_pripremi!" )
   CLOSERET

   RETURN .T.



//     Svedi artikle na primarno pakovanje v.2

FUNCTION NaPrPak2()

   // {
   LOCAL nStavki := 0, nKolicina := 0, nUlaz := 0, nIzlaz := 0, dDatKalk, cBrDok
   IF my_get_from_ini( "Svi", "Sifk" ) <> "D"
      MsgBeep( "Sifrarnik dodatnih karakteristika nedostupan! (Sifk<>'D')" )
      RETURN
   ENDIF

   O__KALK
   o_koncij()
  // o_roba()
   o_kalk_pripr()
   -- o_kalk_doks()
   -- o_kalk()
--   o_sifk()
--   o_sifv()

   dDatKalk := kalk_pripr->datdok

   Box( "#USLOVI ZA GENERISANJE DOKUMENTA SVODJENJA NA PRIMARNO PAKOVANJE", 5, 70 )
   @ box_x_koord() + 2, box_y_koord() + 2 SAY "DATUM DOK.:" GET dDatKalk
   READ; ESC_BCR
   BoxC()

   // kalk_pripr -> _KALK
   // --------------
   SELECT _KALK
   my_dbf_zap()

   APPEND FROM kalk_pripr
   SELECT kalk_pripr
   my_dbf_zap()

   // utvrdimo broj nove kalkulacije
   // ------------------------------
   cIdVdI := "80"
   cIdFirma := self_organizacija_id()
   SELECT kalk_doks; SEEK cIdFirma + cIdVdI + Chr( 255 ); SKIP -1
   IF cIdFirma + cIdVdI == IDFIRMA + IDVD
      cBrDok := brdok
   ELSE
      cBrDok := Space( 8 )
   ENDIF
   cBrDok := UBrojDok( Val( Left( cBrDok, 5 ) ) + 1, 5, Right( cBrDok, 3 ) )
   nRBr := 0

   // postavimo odgovarajuci indeks i filter na KALK
   // ----------------------------------------------
   SELECT _KALK
   INDEX ON idFirma + idkonto + idroba + DToS( datdok ) + podbr + PU_I + IdVD TO "4"
   SET ORDER TO TAG "4"

   GO TOP
   COUNT TO nStavki

   Postotak( 1, nStavki, "Generacija dokumenata" )
   nStavki := 0
   GO TOP
   DO WHILE !Eof()
      IF idvd != "42"; SKIP 1; LOOP; ENDIF
      cIdKonto := IDKONTO
    --  SELECT KONCIJ; HSEEK cIdKonto
      SELECT _KALK
      DO WHILE !Eof() .AND. IDKONTO == cIdKonto
         cIdRoba := IDROBA
         nUlaz := nIzlaz := nMPV := nNV := 0
         // realizacija artikla
         // -------------------
         DO WHILE !Eof() .AND. IDKONTO == cIdKonto .AND. IDROBA == cIdRoba
            nIzlaz += kolicina
            Postotak( 2, ++nStavki )
            SKIP 1
         ENDDO
         SELECT sifv   // "ID","id+oznaka+IdSif+Naz"
         SET ORDER TO TAG "ID"
         SEEK PadR( "ROBA", 8 ) + "PAKO" + PadR( cIdRoba, 15 )
         aSastav := {}
         // napuni matricu aSastav parovima ("SIFRA",KOLICINA)
         // --------------------------------------------------
         DO WHILE !Eof() .AND. ( id + oznaka + idsif = PadR( "ROBA", 8 ) + "PAKO" + PadR( cIdRoba, 15 ) )
            cPom := Trim( naz )
            IF NumToken( cPom, "_" ) = 2
               AAdd ( aSastav, { Token( cPom, "_", 1 ), Val( Token( cPom, "_", 2 ) )  } )
            ENDIF
            SKIP
         ENDDO
         SELECT kalk_pripr
         // generisi stavke storna zaduzenja primarnih pakovanja ("sirovina")
         // -----------------------------------------------------------------
         nUkNV := 0
         FOR i := 1 TO Len( aSastav )
            cIdPrim := aSastav[ i, 1 ]
            SELECT ROBA; SEEK cIdPrim
            nKolicina := aSastav[ i, 2 ]
            nNC := NCuMP( cIdFirma, cIdPrim, cIdKonto, ;
               ( nUlaz - nIzlaz ) * nKolicina, dDatKalk )
            SELECT kalk_pripr
            IF ( ( nulaz - nizlaz ) * nkolicina  <> 0 )
               APPEND BLANK
               nRBr++
               REPLACE idfirma    WITH cIdFirma,;
                  rbr        WITH Str( nRbr, 3 ),;
                  idvd       WITH cIdVdI,;
                  brdok      WITH cBrDok,;
                  datdok     WITH dDatKalk,;
                  idtarifa   WITH ROBA->idtarifa,;
                  brfaktp    WITH "",;
                  datfaktp   WITH dDatKalk,;
                  idkonto    WITH cidkonto,;
                  idzaduz    WITH "",;
                  idkonto2   WITH "",;
                  idzaduz2   WITH "",;
                  nc         WITH nNC,;
                  mpc        WITH 0,;
                  tmarza2    WITH "A",;
                  tprevoz    WITH "A",;
                  mpcsapp    WITH kalk_get_mpc_by_koncij_pravilo(),;
                  idroba     WITH cidPrim,;
                  KOLICINA   with ( nUlaz - nIzlaz ) * nKolicina
               nUkNV += kolicina * nc
            ENDIF
         NEXT
         // generisi stavku zaduzenja sekundarnog pakovanja
         // -----------------------------------------------
         IF Len( aSastav ) != 0
        --    SELECT ROBA; HSEEK cidroba
            SELECT kalk_pripr        // kalk_priprema dokumenta
            IF ( ( nulaz - nizlaz )  <> 0 )
               nRBr++
               APPEND BLANK
               // zaduzi sekundarno pakovanje, uobicajeno je nulaz-nizlaz = -50 pak
               REPLACE idfirma    WITH cIdFirma,;
                  rbr        WITH Str( nRbr, 3 ),;
                  idvd       WITH cIdVdI,;
                  brdok      WITH cBrDok,;
                  datdok     WITH dDatKalk,;
                  idtarifa   WITH ROBA->idtarifa,;
                  brfaktp    WITH "",;
                  datfaktp   WITH dDatKalk,;
                  idkonto    WITH cidkonto,;
                  idzaduz    WITH "",;
                  idkonto2   WITH "",;
                  idzaduz2   WITH "",;
                  nc         WITH nUkNV / ( nUlaz - nIzlaz ),;
                  mpc        WITH 0,;
                  tmarza2    WITH "A",;
                  tprevoz    WITH "A",;
                  mpcsapp    WITH kalk_get_mpc_by_koncij_pravilo(),;
                  idroba     WITH cidroba,;
                  KOLICINA   WITH -( nUlaz - nIzlaz )
            ENDIF
         ENDIF
         SELECT _KALK
      ENDDO
      cBrDok := UBrojDok( Val( Left( cBrDok, 5 ) ) + 1, 5, Right( cBrDok, 3 ) )
      nRBr := 0
   ENDDO
   Postotak( -1 )

   SELECT kalk_pripr
   IF RecCount() > 0
      UzmiIzINI( my_home() + "FMK.INI", "Indikatori", "ImaU_KALK", "D", "WRITE" )
      MsgBeep( "Stavke iz kalk_pripreme su privremeno sklonjene!" + ;
         "#Prvo obradite izgenerisane stavke u kalk_pripremi, a nakon" + ;
         "#azuriranja sklonjene stavke bice vracene u pripremu!" )
   ELSE
      APPEND FROM _KALK
      MsgBeep( "Nema stavki za generaciju dokumenta " + cIdVdI + "!" )
   ENDIF

   CLOSERET

   RETURN


*/
