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


#include "fakt.ch"


// ---------------------------------
// otvara potrebne tabele
// ---------------------------------
STATIC FUNCTION _o_tables()

   O_FAKT
   O_FAKT_DOKS
   O_PARTN
   O_VALUTE
   O_RJ
   O_SIFK
   O_SIFV
   O_ROBA

   RETURN


// --------------------------------------------------
// vraca matricu sa definicijom polja exp.tabele
// --------------------------------------------------
STATIC FUNCTION get_rpt_fields()

   LOCAL aFields := {}

   AAdd( aFields, { "sifra", "C", 7, 0 } )
   AAdd( aFields, { "naziv", "C", 40, 0 } )
   AAdd( aFields, { "kolicina", "N", 15, 5 } )
   AAdd( aFields, { "osnovica", "N", 15, 5 } )
   AAdd( aFields, { "ukupno", "N", 15, 5 } )

   RETURN aFields


// -------------------------------------------
// filuje export tabelu sa podacima
// -------------------------------------------
STATIC FUNCTION fill_exp_tbl( cIdSif, cNazSif, nKol, nOsn, nUk )

   LOCAL nArr

   nArr := Select()

   O_R_EXP
   APPEND BLANK
   REPLACE field->sifra WITH cIdSif
   REPLACE field->naziv WITH cNazSif
   REPLACE field->kolicina WITH nKol
   REPLACE field->osnovica WITH nOsn
   REPLACE field->ukupno WITH nUk

   SELECT ( nArr )

   RETURN



// ---------------------------------------
// specifikacija prodaje
// ---------------------------------------
FUNCTION fakt_real_kolicina()

   LOCAL nX := 1
   LOCAL cExport := "N"
   LOCAL lExpRpt := .F.
   LOCAL lRelations := .F.
   LOCAL cDDokOtpr := "D"
   PRIVATE cPrikaz
   PRIVATE cSection := "N"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   PRIVATE cIdPartner
   PRIVATE nStrana := 0
   PRIVATE cLinija
   PRIVATE lGroup := .F.
   PRIVATE cRelation := Space( 4 )
   PRIVATE cSvediJmj := "N"

   // da li se koriste relacije
   O_FAKT
   SELECT fakt

   IF fakt->( FieldPos( "idrelac" ) ) <> 0
      lRelations := .T.
   ENDIF

   _o_tables()
   O_OPS

   // partneri po grupama
   lGroup := p_group()

   cIdfirma := gFirma
   dDatOd := CToD( "" )
   dDatDo := Date()
   qqTipDok := Space( 20 )

   Box( "#SPECIFIKACIJA PRODAJE PO ARTIKLIMA", 16, 77 )
   O_PARAMS
   RPar( "c1", @cIdFirma )
   RPar( "d1", @dDatOd )
   RPar( "d2", @dDatDo )
   RPar( "d3", @cDDokOtpr )
   qqIdRoba := Space( 20 )
   cPrikaz := "2"
   cIdRoba := Space( 20 )
   cImeKup := Space( 20 )
   cOpcina := Space( 200 )
   qqPartn := Space( 20 )
   RPar( "sk", @qqPartn )
   RPar( "td", @qqTipDok )
   qqPartn := PadR( qqPartn, Len( partn->id ) )
   qqIdRoba := PadR( qqIdRoba, 200 )
   qqTipDok := PadR( qqTipDok, 40 )

   nX := 2

   DO WHILE .T.
 		
      cIdFirma := PadR( cIdFirma, 2 )
 		
      @ m_x + nX, m_y + 2 SAY "RJ            " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. cIdFirma == gFirma .OR. P_RJ( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
 		
      ++nX
		
      @ m_x + nX, m_y + 2 SAY "Tip dokumenta " GET qqTipDok PICT "@!S20"
 		
      ++nX
		
      @ m_x + nX, m_y + 2 SAY "Od datuma "  GET dDatOd
 		
      @ m_x + nX, Col() + 1 SAY "do"  GET dDatDo
		
      ++ nX

      @ m_x + nX, m_y + 2 SAY "gledati dat. (D)dok. (O)otpr. (V)valute:" GET cDDokOtpr VALID cDDokOtpr $ "DOV" PICT "@!"

      nX := nX + 3
		
      @ m_x + nX, m_y + 2 SAY "Uslov po sifri partnera (prazno svi) "  GET qqPartn PICT "@!" valid {|| Empty( qqPartn ) .OR. P_Firma( @qqPartn ) }
 		
      ++nX
		
      @ m_x + nX, m_y + 2 SAY "Uslov po artiklu (prazno svi) "  GET qqIdRoba PICT "@S30"
   			
      ++nX
			
      @ m_x + nX, m_y + 2 SAY "Uslov po opcini (prazno sve) "  GET cOpcina PICT "@S30"
 		
 		
      IF lRelations == .T.
			
         ++ nX
         @ m_x + nX, m_y + 2 SAY "Relacija (prazno sve):" GET cRelation
      ENDIF
		
      IF lGroup
   			
         PRIVATE cPGroup := Space( 3 )
         ++nX
         @ m_x + nX, m_y + 2 SAY "Grupa partnera (prazno sve):" GET cPGroup VALID Empty( cPGroup ) .OR. cPGroup $ "VP #AMB#SIS#OST"
		
      ENDIF
		
      ++nX

      @ m_x + nX, m_y + 2 SAY "Svedi na jedinicu mjere ?" GET cSvediJmj VALID cSvediJmj $ "DN" PICT "@!"

      nX := nX + 2
		
      @ m_x + nX, m_y + 2 SAY "Export izvjestaja u DBF?" GET cExport VALID cExport $ "DN" PICT "@!"
		
		
      READ
 		
      ESC_BCR

      aUslRB := Parsiraj( qqIdRoba, "IDROBA", "C" )

      aUslOpc := Parsiraj( cOpcina, "IDOPS", "C" )

      aUslTD := Parsiraj( qqTipdok, "IdTipdok", "C" )
 		
      IF ( aUslTD <> NIL )
         EXIT
      ENDIF
		
		
   ENDDO

   qqTipDok := Trim( qqTipDok )
   qqPartn := Trim( qqPartn )
   qqIdRoba := Trim( qqIdRoba )
   qqTipDok := Trim( qqTipDok )
   Params2()
   WPar( "c1", cIdFirma )
   WPar( "d1", dDatOd )
   WPar( "d2", dDatDo )
   WPar( "d3", cDDokOtpr )
   WPar( "vi", cPrikaz )
   WPar( "td", qqTipDok )
	
   SELECT params
   USE
   BoxC()

   // ako je export izabran
   IF cExport == "D"
      lExpRpt := .T.
   ENDIF

   // export dokumenta
   IF lExpRpt == .T.
      aExpFields := get_rpt_fields()
      t_exp_create( aExpFields )
   ENDIF

   _o_tables()

   IF fakt_doks->( FieldPos( "dat_isp" ) ) = 0
      // ako nema ovog polja, samo gledaj po dokumentima
      cDDokOtpr := "D"
   ENDIF

   SELECT fakt

   PRIVATE cFilter := ".t."

   IF ( !Empty( dDatOd ) .OR. !Empty( dDatDo ) )

      IF cDDokOtpr == "D"
         cFilter += ".and.  datdok>=" + Cm2Str( dDatOd ) + " .and. datdok<=" + Cm2Str( dDatDo )
      ENDIF
   ENDIF

   IF ( !Empty( cIdFirma ) )
      cFilter += " .and. IdFirma=" + Cm2Str( cIdFirma )
   ENDIF

   IF ( !Empty( qqPartn ) )
      cFilter += " .and. IdPartner=" + Cm2Str( qqPartn )
   ENDIF

   IF ( !Empty( qqIdRoba ) )
      cFilter += " .and. " + aUslRB
   ENDIF

   IF ( !Empty( qqTipDok ) )
      cFilter += " .and. " + aUslTD
   ENDIF

   IF ( !Empty( cRelation ) )
      cFilter += " .and. idrelac == " + Cm2Str( cRelation )
   ENDIF

   IF ( cFilter = " .t. .and. " )
      cFilter := SubStr( cFilter, 9 )
   ENDIF

   IF ( cFilter == ".t." )
      SET FILTER TO
   ELSE
      SET FILTER to &cFilter
   ENDIF

   EOF CRET

   START PRINT CRET

   IF cPrikaz == "1"
      cLinija := "---- ------ -------------------------- ------------"
   ELSE
      cLinija := "---- ----------- " + REPL( "-", 40 ) + " ------------" + ;
         " ------------ -------------"
   ENDIF

   IF cSvediJmj == "D"
      cLinija += " ------------"
   ENDIF

   cIdPartner := idPartner

   zagl_sp_prod()

   IF cPrikaz == "1"
	
      SET ORDER TO TAG "1"
      SEEK cIdFirma
      nC := 0
      nCol1 := 10
      nTKolicina := 0
  	
      DO WHILE !Eof() .AND. IdFirma = cIdFirma
    		
         IF cDDokOtpr == "O"
            SELECT fakt_doks
            SEEK fakt->idfirma + fakt->idtipdok + fakt->brdok
            IF fakt_doks->dat_otpr < dDatOd .OR. fakt_doks->dat_otpr > dDatDo
               SELECT fakt
               SKIP
               LOOP
            ENDIF
            SELECT fakt
         ENDIF
    		
         IF cDDokOtpr == "V"
            SELECT fakt_doks
            SEEK fakt->idfirma + fakt->idtipdok + fakt->brdok
            IF fakt_doks->dat_val < dDatOd .OR. fakt_doks->dat_val > dDatDo
               SELECT fakt
               SKIP
               LOOP
            ENDIF
            SELECT fakt
         ENDIF

         nKolicina := 0
         cIdPartner := IdPartner
    		
         DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. idpartner == cIdpartner
        		
            IF cDDokOtpr == "O"
               SELECT fakt_doks
               SEEK fakt->idfirma + fakt->idtipdok + ;
                  fakt->brdok
               IF fakt_doks->dat_otpr < dDatOd .OR. ;
                     fakt_doks->dat_otpr > dDatDo
                  SELECT fakt
                  SKIP
                  LOOP
               ENDIF
               SELECT fakt
            ENDIF
    		
            IF cDDokOtpr == "V"
               SELECT fakt_doks
               SEEK fakt->idfirma + fakt->idtipdok + ;
                  fakt->brdok
               IF fakt_doks->dat_val < dDatOd .OR. ;
                     fakt_doks->dat_val > dDatDo
                  SELECT fakt
                  SKIP
                  LOOP
               ENDIF
               SELECT fakt
            ENDIF
			
            SELECT partn
            HSEEK fakt->idPartner
            SELECT fakt
            IF !( partn->( &aUslOpc ) )
               SKIP 1
               LOOP
            ENDIF
      			
            nKolicina += kolicina
      			
			
            SKIP 1
			
         ENDDO

         IF PRow() > 61
            FF
            zagl_sp_prod()
         ENDIF

         SELECT partn
         hseek cIdPartner
         SELECT fakt
    		
         IF Round( nKolicina, 4 ) <> 0
            ? Space( gnLMarg )
            ?? Str( ++nC, 4 ) + ".", cIdPartner, partn->naz
            nCol1 := PCol() + 1
            @ PRow(), PCol() + 1 SAY Str( nKolicina, 12, 2 )
            nTKolicina += nKolicina
         ENDIF

         IF lExpRpt
            fill_exp_tbl( cIdPartner, partn->naz, nKolicina, 0 )
         ENDIF
      ENDDO
   ELSE
      // ako je izabrano "2"
      SET ORDER TO TAG "3"
      GO TOP
      nC := 0
      nCol1 := 10
      nTKolicina := 0
      nTKolJmj := 0
      nTOsn := 0
      nTUkupno := 0
      nCounter := 0
      nMX := 0
      nMY := 0
	
      Box(, 3, 60 )
	
      SET DEVICE TO SCREEN
      @ 1 + m_x, 2 + m_y SAY "formiranje izvjestaja u toku..."
      nMX := 3 + m_x
      nMY := 2 + m_y
      SET DEVICE TO PRINTER
	
      DO WHILE !Eof()
	
         nKolicina := 0
         nKolJmj := 0
         nOsn := 0
         nPojOsn := 0
         nUkupno := 0
         nPojUk := 0
         cIdRoba := IdRoba
		
         IF cDDokOtpr == "O"
            SELECT fakt_doks
            SEEK fakt->idfirma + fakt->idtipdok + fakt->brdok
            IF fakt_doks->dat_otpr < dDatOd .OR. fakt_doks->dat_otpr > dDatDo
               SELECT fakt
               SKIP
               LOOP
            ENDIF
            SELECT fakt
         ENDIF
    		
         IF cDDokOtpr == "V"
            SELECT fakt_doks
            SEEK fakt->idfirma + fakt->idtipdok + fakt->brdok
            IF fakt_doks->dat_val < dDatOd .OR. fakt_doks->dat_val > dDatDo
               SELECT fakt
               SKIP
               LOOP
            ENDIF
            SELECT fakt
         ENDIF

         DO WHILE !Eof() .AND. idRoba == cIdRoba
        			
            IF cDDokOtpr == "O"
               SELECT fakt_doks
               SEEK fakt->idfirma + fakt->idtipdok + ;
                  fakt->brdok
               IF fakt_doks->dat_otpr < dDatOd .OR. ;
                     fakt_doks->dat_otpr > dDatDo
                  SELECT fakt
                  SKIP
                  LOOP
               ENDIF
               SELECT fakt
            ENDIF
    		
            IF cDDokOtpr == "V"
               SELECT fakt_doks
               SEEK fakt->idfirma + fakt->idtipdok + ;
                  fakt->brdok
               IF fakt_doks->dat_val < dDatOd .OR. ;
                     fakt_doks->dat_val > dDatDo
                  SELECT fakt
                  SKIP
                  LOOP
               ENDIF
               SELECT fakt
            ENDIF
			
            SELECT partn
            HSEEK fakt->idPartner
            SELECT fakt
            IF !( partn->( &aUslOpc ) )
               SKIP 1
               LOOP
            ENDIF
			
            IF lGroup .AND. !Empty( cPGroup )
               cPartn := fakt->idpartner
               SELECT partn
               hseek cPartn
               SELECT fakt
               IF !p_in_group( cPartn, cPGroup )
                  SKIP
                  LOOP
               ENDIF
            ENDIF
     			
            nKolicina += kolicina
			
            IF cSvediJmj == "D"
				
               cJmj := ""
               nKolJmj += SJMJ( kolicina, idroba, @cJmj )
			
            ENDIF
			
            // pojedinacna osnova
            nPojOsn := Round( kolicina * Cijena * ( 1 -Rabat / 100 ) * ( 1 + Porez / 100 ), ZAOKRUZENJE )
			
            // ukupni iznos sa PDV
            nPojUk := nPojOsn

            // ako je rijec o MP dokumentima
            // potrebno je izvuci osnovicu iz iznosa
            // jer se radi o cijeni sa PDV-om

            IF field->idtipdok $ "11#13#23"
			
               nPojOsn := _osnovica( field->idtipdok, ;
                  field->idpartner, nPojOsn )
			
            ENDIF
			
            // ako je rijec o VP dokumentima, treba izracunati
            // ukupno sa PDV

            IF field->idtipdok $ "10#12"
               nPojUk := _uk_sa_pdv( field->idtipdok, ;
                  field->idpartner, nPojUk )
            ENDIF

            // dodaj na total
            nOsn += nPojOsn
            nUkupno += nPojUk

            ++ nCounter
			
            // ispisi progres u box-u
            IF nCounter % 50 == 0
               SET DEVICE TO SCREEN
               @ nMX, nMY SAY "obradjeno " + AllTrim( Str( nCounter ) ) + " zapisa"
               SET DEVICE TO PRINTER
            ENDIF
      			
            SKIP 1
         ENDDO
		
         IF PRow() > 61
            FF
            zagl_sp_prod()
         ENDIF
    		
         SELECT roba
         hseek cIdRoba
         SELECT fakt
    		
         IF Round( nKolicina, 4 ) <> 0
            ? Space( gnLMarg )
            ?? Str( ++nC, 4 ) + ".", cIdRoba, Left( roba->naz, 40 )
            nCol1 := PCol() + 1
            @ PRow(), PCol() + 1 SAY Str( nKolicina, 12, 2 )
            IF cSvediJmj == "D"
               @ PRow(), PCol() + 1 SAY Str( nKolJmj, 12, 2 )
               nTKolJmj += nKolJmj
            ENDIF
			
            @ PRow(), PCol() + 1 SAY Str( nOsn, 12, 2 )
            @ PRow(), PCol() + 1 SAY Str( nUkupno, 12, 2 )
      			
            nTKolicina += nKolicina
            nTOsn += nOsn
            nTUkupno += nUkupno
         ENDIF
		
         IF lExpRpt
            fill_exp_tbl( cIdRoba, Left( roba->naz, 40 ), ;
               nKolicina, nOsn, nUkupno )
         ENDIF
		
      ENDDO

      BoxC()
	
   ENDIF

   IF PRow() > 59
      FF
      zagl_sp_prod()
   ENDIF

   ? Space( gnLMarg )
   ?? cLinija
   ? Space( gnLMarg )
   ?? " Ukupno"
   @ PRow(), nCol1 SAY Str( nTKolicina, 12, 2 )
   IF cSvediJmj == "D"
      @ PRow(), PCol() + 1 SAY Str( nTKolJmj, 12, 2 )
   ENDIF
   @ PRow(), PCol() + 1 SAY Str( nTOsn, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTUkupno, 12, 2 )
   ? Space( gnLMarg )
   ?? cLinija

   // ukini filter
   SET FILTER TO

   IF lExpRpt
      fill_exp_tbl( "UKUPNO", "", nTKolicina, nTOsn, nTUkupno )
   ENDIF

   FF
   ENDPRINT

   // lansiraj export....
   IF lExpRpt
      tbl_export()
   ENDIF

   RETURN


// ---------------------------------------------
// zaglavlje izvjestaja specifikacija prodaje
// ---------------------------------------------
STATIC FUNCTION zagl_sp_prod()

   ?
   P_12CPI

   ?? Space( gnLMarg )
   IspisFirme( cIdFirma )

   ?

   SET CENTURY ON

   P_12CPI

   IF cPrikaz == "1"
      ? Space( gnLMarg )
      ?? "Specifikacija prodaje po partnerima na dan", Date(), Space( 8 ), "Strana:", Str( ++nStrana, 3 )
   ELSE
      ? Space( gnLMarg )
      ?? "Specifikacija prodaje po artiklima na dan", Date(), Space( 8 ), "Strana:", Str( ++nStrana, 3 )
   ENDIF

   ? Space( gnLMarg )
   ?? "      za period:", dDatOd, " - ", dDatDo

   ? Space( gnLMarg )
   ?? "Izvjestaj za tipove dokumenata : ", Trim( qqTipDok )

   IF !Empty( cRelation )
      ? Space( gnLMarg )
      ?? "Relacija : " + cRelation
   ENDIF

   IF cPrikaz == "2" .AND. !Empty( qqPartn )
      ? Space( gnLMarg )
      ?? "Partner: " + qqPartn + " - " + Ocitaj( F_PARTN, qqPartn, "naz" )
   ENDIF

   IF !Empty( cOpcina )
      ? Space( gnLMarg )
      ?? "Opcine: " + Trim( cOpcina )
   ENDIF

   IF lGroup .AND. !Empty( cPGroup )
      ? Space( gnLMarg )
      ?? "Grupa partnera: " + Trim( cPGroup ), " - " + gr_opis( cPGroup )
   ENDIF

   SET CENTURY OFF

   P_COND

   ? Space( gnLMarg )
   ?? cLinija

   IF cPrikaz == "1"
      ? Space( gnLMarg )
      ?? " Rbr  Sifra     Partner                  Kolicina                           "
   ELSE
      ? Space( gnLMarg )
      ?? " Rbr  Sifra      " + ;
         PadC( "Naziv", 40 ) + ;
         "   Kolicina   " + ;
         if( cSvediJmj == "D", "  Kol.po jmj ", "" ) + ;
         " Uk.bez PDV " + ;
         "  Uk.sa PDV "
   ENDIF

   ? Space( gnLMarg )
   ?? "                                                                            "
   ? Space( gnLMarg )
   ?? cLinija

   RETURN