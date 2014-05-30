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


#include "ld.ch"


// ------------------------------------------------
// specifikacija place
// ------------------------------------------------
FUNCTION Specif()

   LOCAL GetList := {}
   LOCAL aPom := {}
   LOCAL nGrupaPoslova := 5
   LOCAL nLM := 5
   LOCAL nLin
   LOCAL nPocetak
   LOCAL i := 0
   LOCAL j := 0
   LOCAL k := 0
   LOCAL nPreskociRedova
   LOCAL cLin
   LOCAL nPom
   LOCAL aOps := {}
   PRIVATE aSpec := {}
   PRIVATE cFNTZ := "N"
   PRIVATE gPici := "9,999,999,999,999,999" + IF( gZaok > 0, PadR( ".", gZaok + 1, "9" ), "" )
   PRIVATE gPici2 := "9,999,999,999,999,999" + IF( gZaok2 > 0, PadR( ".", gZaok2 + 1, "9" ), "" )
   PRIVATE gPici3 := "999,999,999,999.99"

   FOR i := 1 TO nGrupaPoslova + 1
      AAdd( aSpec, { 0, 0, 0, 0 } )
      // br.bodova, br.radnika, minuli rad, uneto
   NEXT

   cIdRJ := "  "
   qqIDRJ := ""
   qqOpSt := ""

   nPorOlaksice := 0
   nBrutoOsnova := 0
   nOstaleObaveze := 0
   nBolPreko := 0
   nPorezOstali := 0
   nObustave := 0
   nOstOb1 := 0
   nOstOb2 := 0
   nOstOb3 := 0
   nOstOb4 := 0
   nMjesec := gMjesec
   nGodina := gGodina
   cObracun := gObracun
   cMRad := "17"
   cPorOl := "33"
   cBolPr := "  "
   cObust := Space( 60 )
   cOstObav := Space( 60 )

   ccOO1 := Space( 20 )
   ccOO2 := Space( 20 )
   ccOO3 := Space( 20 )
   ccOO4 := Space( 20 )
   cnOO1 := Space( 20 )
   cnOO2 := Space( 20 )
   cnOO3 := Space( 20 )
   cnOO4 := Space( 20 )

   cDopr1 := "10"
   cDopr2 := "11"
   cDopr3 := "12"
   cDopr5 := "20"
   cDopr6 := "21"
   cDopr7 := "22"
   cDoprOO := ""
   cPorOO := ""
   cIspl1 := Space( 30 )
   cIspl2 := Space( 15 )
   cIspl3 := Space( 20 )  // naziv, sjediste i broj racuna isplatioca
   nLimG1 := 0
   nLimG2 := 0
   nLimG3 := 0
   nLimG4 := 0
   nLimG5 := 0

   OSpecif()

   IF ( FieldPos( "DNE" ) <> 0 )
      GO TOP
      DO WHILE !Eof()
         AAdd( aOps, { id, dne, 0 } ) // sifra opstine, dopr.koje nema, neto
         SKIP 1
      ENDDO
      lPDNE := .T.
   ELSE
      lPDNE := .F.
   ENDIF

   SELECT params

   PRIVATE cSection := "4"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "i1", @cIspl1 )
   RPar( "i2", @cIspl2 )
   RPar( "i3", @cIspl3 )
   RPar( "i4", @cMRad )
   RPar( "i5", @cPorOl )
   RPar( "i6", @cBolPr )

   cBolPr := Trim( cBolPr )

   IF ( !Empty( cBolPr ) .AND. Right( cBolPr, 1 ) <> ";" )
      cBolPr := cBolPr + ";"
   ENDIF

   cBolPr := PadR( cBolPr, 20 )

   RPar( "i7", @cObust )
   RPar( "i8", @cOstObav )
   RPar( "i9", @cFNTZ )
   RPar( "d1", @cDopr1 )
   RPar( "d2", @cDopr2 )
   RPar( "d3", @cDopr3 )
   RPar( "d5", @cDopr5 )
   RPar( "d6", @cDopr6 )
   RPar( "d7", @cDopr7 )
   RPar( "a1", @ccOO1 )
   RPar( "a2", @ccOO2 )
   RPar( "a3", @ccOO3 )
   RPar( "a4", @ccOO4 )
   RPar( "a5", @cnOO1 )
   RPar( "a6", @cnOO2 )
   RPar( "a7", @cnOO3 )
   RPar( "a8", @cnOO4 )
   RPar( "l1", @nLimG1 )
   RPar( "l2", @nLimG2 )
   RPar( "l3", @nLimG3 )
   RPar( "l4", @nLimG4 )
   RPar( "l5", @nLimG5 )
   RPar( "qj", @qqIdRJ )
   RPar( "st", @qqOpSt )

   qqIdRj := PadR( qqIdRj, 80 )
   qqOpSt := PadR( qqOpSt, 80 )

   // maticni broj, porezni djelovodni broj , datum isplate place

   cMatBr := IzFmkIni( "Specif", "MatBr", "--", KUMPATH )
   cPorDBR := IzFmkIni( "Specif", "PorDBR", "--", KUMPATH )
   cSBR := IzFmkIni( "Specif", "SBR", "--", KUMPATH )
   cSPBR := IzFmkIni( "Specif", "SPBR", "--", KUMPATH )
   cMatBR := PadR( cMatBr, 13 ) ; cPorDBR := PadR( cPorDBR, 8 )
   cNOPU := Space( 10 )  // broj koji dodjeljuje poreska uprava
   dDatIspl := Date()

   IF IzFmkIni( 'LD', 'StatBroj9mjesta', 'N', KUMPATH ) == 'D'
      cSBR := PadR( cSBR, 9 )
   ELSE
      cSBR := PadR( cSBR, 8 )
   ENDIF

   cSPBR := PadR( cSPBR, 4 )

   DO WHILE .T.
      Box(, 22 + IF( gVarSpec == "1", 0, 1 ), 75 )
      @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve): "  GET qqIdRJ PICT "@!S20"
      @ m_x + 2, m_y + 2 SAY "Opstina stanov.(prazno-sve): "  GET qqOpSt PICT "@!S20"

      @ m_x + 3, m_y + 2 SAY "Mjesec:"  GET  nMjesec  PICT "99"
      @ m_x + 3, Col() + 2 SAY "Obracun:"  GET  cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
      @ m_x + 3, Col() + 2 SAY "Godina:"  GET  nGodina  PICT "9999"
      @ m_x + 3, Col() + 2 SAY "Format iznosa 9.999,99 (D/N)?"  GET  cFNTZ  VALID cFNTZ $ "DN" PICT "@!"
      @ m_x + 4, m_y + 2 SAY "Naziv    " GET cIspl1
      @ m_x + 5, m_y + 2 SAY "sjediste " GET cIspl2
      @ m_x + 6, m_y + 2 SAY "br.racuna" GET cIspl3
      @ m_x + 4, m_y + 50 SAY "     No :" GET cNoPU
      @ m_x + 5, m_y + 50 SAY "Mat.br  :" GET cMatBR
      @ m_x + 6, m_y + 50 SAY "Por.d.br:" GET cPorDBR
      @ m_x + 7, m_y + 50 SAY "Dat.ispl:" GET dDatIspl
      @ m_x + 8, m_y + 50 SAY "Stat.broj" GET cSBR
      @ m_x + 9, m_y + 50 SAY "Stat.podb" GET cSPBR
      @ m_x + 8, m_y + 2 SAY "Sifra por.olaksice" GET cPorOl VALID LD->( FieldPos( "I" + cPorOl ) ) > 0 .OR. Empty( cPorOl ) PICT "99"
      @ m_x + 9, m_y + 2 SAY "Sifra bolovanja 'preko 42' " GET cBolPr PICT "@!S20"
      @ m_x + 10, m_y + 2 SAY "Obustave (nabrojati sifre - npr. 29;30;)" GET cObust  PICT "@!S20"
      @ m_x + 11, m_y + 2 SAY "Ostale obaveze (nabrojati sifre - npr. D->AX;D->BX;)" GET cOstObav  PICT "@!S20"
      @ m_x + 12, m_y + 2 SAY "Doprinos za penz.i inv.osig. -iz plate" GET cDopr1
      @ m_x + 13, m_y + 2 SAY "Doprinos za zdravstv.osigur. -iz plate" GET cDopr2
      @ m_x + 14, m_y + 2 SAY "Doprinos za osig.od nezaposl.-iz plate" GET cDopr3
      @ m_x + 15, m_y + 2 SAY "Doprinos za penz.i inv.osig. -na platu" GET cDopr5
      @ m_x + 16, m_y + 2 SAY "Doprinos za zdravstv.osigur. -na platu" GET cDopr6
      @ m_x + 17, m_y + 2 SAY "Doprinos za osig.od nezaposl.-na platu" GET cDopr7
      @ m_x + 18, m_y + 2 SAY "Ost.obaveze: NAZIV                  USLOV"
      @ m_x + 19, m_y + 2 SAY " 1." GET ccOO1
      @ m_x + 19, m_y + 30 GET cnOO1
      @ m_x + 20, m_y + 2 SAY " 2." GET ccOO2
      @ m_x + 20, m_y + 30 GET cnOO2
      @ m_x + 21, m_y + 2 SAY " 3." GET ccOO3
      @ m_x + 21, m_y + 30 GET cnOO3
      @ m_x + 22, m_y + 2 SAY " 4." GET ccOO4
      @ m_x + 22, m_y + 30 GET cnOO4
      IF gVarSpec == "2"
         @ m_x + 23, m_y + 2 SAY "Limit za gr.posl.1" GET nLimG1 PICT "9999.99"
         @ m_x + 23, m_y + 29 SAY "2" GET nLimG2 PICT "9999.99"
         @ m_x + 23, m_y + 39 SAY "3" GET nLimG3 PICT "9999.99"
         @ m_x + 23, m_y + 49 SAY "4" GET nLimG4 PICT "9999.99"
         @ m_x + 23, m_y + 59 SAY "5" GET nLimG5 PICT "9999.99"
      ENDIF
      READ
      clvbox()
      ESC_BCR
      BoxC()
   	
      aUslRJ := Parsiraj( qqIdRj, "IDRJ" )
      aUslOpSt := Parsiraj( qqOpSt, "IDOPSST" )
      IF ( aUslRJ <> NIL .AND. aUslOpSt <> nil )
         EXIT
      ENDIF
   ENDDO


   WPar( "i1", cIspl1 )
   WPar( "i2", cIspl2 )
   WPar( "i3", cIspl3 )
   WPar( "i4", cMRad )
   WPar( "i5", cPorOl )
   WPar( "i6", cBolPr )
   WPar( "i7", cObust )
   WPar( "i8", cOstObav )
   WPar( "i9", cFNTZ )
   WPar( "d1", cDopr1 )
   WPar( "d2", cDopr2 )
   WPar( "d3", cDopr3 )
   WPar( "d5", cDopr5 )
   WPar( "d6", cDopr6 )
   WPar( "d7", cDopr7 )
   WPar( "a1", ccOO1 )
   WPar( "a2", ccOO2 )
   WPar( "a3", ccOO3 )
   WPar( "a4", ccOO4 )
   WPar( "a5", cnOO1 )
   WPar( "a6", cnOO2 )
   WPar( "a7", cnOO3 )
   WPar( "a8", cnOO4 )
   WPar( "l1", nLimG1 )
   WPar( "l2", nLimG2 )
   WPar( "l3", nLimG3 )
   WPar( "l4", nLimG4 )
   WPar( "l5", nLimG5 )

   qqIdRj := Trim( qqIdRj )
   qqOpSt := Trim( qqOpSt )

   WPar( "qj", qqIdRJ )
   WPar( "st", qqOpSt )

   SELECT params
   USE

   PoDoIzSez( nGodina, nMjesec )

   // fmk.ini parametri
   cPom := KUMPATH + "fmk.ini"
   UzmiIzIni( cPom, 'Specif', "MatBr", cMatBr, 'WRITE' )
   UzmiIzIni( cPom, 'Specif', "PorDBR", cPorDBR, 'WRITE' )
   UzmiIzIni( cPom, 'Specif', "SBR", cSBR, 'WRITE' )
   UzmiIzIni( cPom, 'Specif', "SPBR", cSPBR, 'WRITE' )

   cIniName := EXEPATH + 'proizvj.ini'

   //
   // Radi DRB6 iskoristio f-ju Razrijedi()
   // npr.:    string  ->  s t r i n g
   //
   UzmiIzIni( cIniName, 'Varijable', "NAZISJ", cIspl1 + ", " + cIspl2,'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "NOPU", cNoPU,'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "GOD", Razrijedi( Str( nGodina, 4 ) ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "MJ", Razrijedi( StrTran( Str( nMjesec, 2 ), " ", "0" ) ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "BRRAC", cIspl3, 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "MATBR", Razrijedi( cMatBR ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "PORDBR", Razrijedi( cPorDBR ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "SBR", Razrijedi( cSBR ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "SPBR", Razrijedi( cSPBR ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "DATISPL", DToC( dDatIspl ), 'WRITE' )

   cObracun := Trim( cObracun )

   cPorOO := Izrezi( "P->", 2, @cOstObav )
   cDoprOO := Izrezi( "D->", 2, @cOstObav )
   cDoprOO1 := Izrezi( "D->", 2, @cnOO1 )
   cDoprOO2 := Izrezi( "D->", 2, @cnOO2 )
   cDoprOO3 := Izrezi( "D->", 2, @cnOO3 )
   cDoprOO4 := Izrezi( "D->", 2, @cnOO4 )

   // ----------- MS 07.04.01
   // SELECT PAROBR; HSEEK STR(nMjesec,2)+cObracun
   // IF !FOUND()
   // MsgBeep("Greska: ne postoje parametri obracuna za "+ALLTRIM(STR(nMjesec))+". mjesec!")
   // CLOSERET
   // ENDIF

   ParObr( nMjesec, nGodina, cObracun, Left( qqIdRJ, 2 ) )

   // ----------- MS 07.04.01

   SELECT LD
   SET ORDER TO TAG ( TagVO( "2" ) )

   PRIVATE cFilt := ".t."

   IF !Empty( qqIdRJ )
      cFilt += ( ".and." + aUslRJ )
   ENDIF

   IF !Empty( cObracun )
      cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
   ENDIF

   SET FILTER TO &cFilt

   GO TOP
   HSEEK Str( nGodina, 4 ) + Str( nMjesec, 2 )

   IF !Found()
      MsgBeep( "Obracun za ovaj mjesec ne postoji !" )
      my_close_all_dbf()
      RETURN .T.
   ENDIF

   nUNeto := 0
   nUNetoOsnova := 0
   nPorNaPlatu := 0
   nURadnika := 0
   DO WHILE Str( nGodina, 4 ) + Str( nMjesec, 2 ) == Str( godina, 4 ) + Str( mjesec, 2 )
      SELECT RADN; HSEEK LD->idradn
      SELECT LD
      IF ! ( RADN->( &aUslOpSt ) )
         SKIP 1; LOOP
      ENDIF
      nP77 := IF( !Empty( cMRad ), LD->&( "I" + cMRad ), 0 )
      nP78 := IF( !Empty( cPorOl ), LD->&( "I" + cPorOl ), 0 )

      // nP79 := IF( !EMPTY(cBolPr) , LD->&("I"+cBolPr) , 0 )
      nP79 := 0
      IF !Empty( cBolPr ) .OR. !Empty( cBolPr )
         FOR t := 1 TO 99
            cPom := IF( t > 9, Str( t, 2 ), "0" + Str( t, 1 ) )
            IF LD->( FieldPos( "I" + cPom ) ) <= 0
               EXIT
            ENDIF
            nP79 += IF( cPom $ cBolPr, LD->&( "I" + cPom ), 0 )
         NEXT
      ENDIF

      nP80 := nP81 := nP82 := nP83 := nP84 := nP85 := 0
      IF !Empty( cObust ) .OR. !Empty( cOstObav )
         FOR t := 1 TO 99
            cPom := IF( t > 9, Str( t, 2 ), "0" + Str( t, 1 ) )
            IF LD->( FieldPos( "I" + cPom ) ) <= 0
               EXIT
            ENDIF
            nP80 += IF( cPom $ cObust, LD->&( "I" + cPom ), 0 )
            nP81 += IF( cPom $ cOstObav, LD->&( "I" + cPom ), 0 )
            nP82 += IF( cPom $ cnOO1, LD->&( "I" + cPom ), 0 )
            nP83 += IF( cPom $ cnOO2, LD->&( "I" + cPom ), 0 )
            nP84 += IF( cPom $ cnOO3, LD->&( "I" + cPom ), 0 )
            nP85 += IF( cPom $ cnOO4, LD->&( "I" + cPom ), 0 )
         NEXT
      ENDIF
      IF LD->uneto > 0  // zbog npr.bol.preko 42 dana koje ne ide u neto
         IF Len( aPom ) < 1 .OR. ( nPom := AScan( aPom, {| x| x[ 1 ] == LD->brbod } ) ) == 0
            AAdd( aPom, { LD->brbod, 1, nP77, LD->uneto } )
         ELSE
            IF ! ( lViseObr .AND. Empty( cObracun ) .AND. LD->obr $ "23456789" )
               aPom[ nPom, 2 ] += 1  // broj radnika
            ENDIF
            aPom[ nPom, 3 ] += nP77  // minuli rad
            aPom[ nPom, 4 ] += LD->uneto // neto
         ENDIF
      ENDIF

      nUNeto += ld->uneto
      nUNetoOsnova += Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 )


      // porez na platu i ostali porez
      SELECT POR
      GO TOP

      DO WHILE !Eof()
         PozicOps( POR->poopst )
         IF !ImaUOp( "POR", POR->id )
            SKIP 1; LOOP
         ENDIF
         IF ID == "01"
            // nPorNaPlatu  += ROUND2(POR->iznos * MAX(ld->uneto,PAROBR->prosld*gPDLimit/100) / 100,gZaok2)
            nPorNaPlatu  += POR->iznos * Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 ) / 100
         ELSE
            IF ID $ cPorOO
               nPorezOstali   += ROUND2( POR->iznos * Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 ) / 100, gZaok2 )
               // nOstaleObaveze += ROUND2(POR->iznos * MAX(ld->uneto,PAROBR->prosld*gPDLimit/100) / 100,gZaok2)
            ENDIF
         ENDIF
         SKIP 1
      ENDDO

      SELECT LD

      nURadnika++
      nPorOlaksice += nP78
      nBolPreko += nP79
      nObustave += nP80
      nOstaleObaveze += nP81
      nOstOb1 += nP82; nOstOb2 += nP83; nOstOb3 += nP84; nOstOb4 += nP85
      IF lPDNE
         nOps := AScan( aOps, {| x| x[ 1 ] == RADN->idopsst } )
         IF nOps > 0
            aOps[ nOps, 3 ] += Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 )
         ELSE
            AAdd( aOps, { RADN->idopsst, "", Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 ) } )
         ENDIF
      ENDIF
      SKIP 1
   ENDDO

   nPorNaPlatu := round2( nPorNaPlatu, gZaok2 )

   // obustave iz place
   UzmiIzIni( cIniName, 'Varijable', 'O18I', FormNum2( -nObustave, 16, gPici2 ), 'WRITE' )

   // Ostale obaveze = OstaleObaveze.1

   ASort( aPom, , , {| x, y| x[ 1 ] > y[ 1 ] } )
   FOR i := 1 TO Len( aPom )
      IF gVarSpec == "1"
         IF i <= nGrupaPoslova
            aSpec[ i, 1 ] := aPom[ i, 1 ]; aSpec[ i, 2 ] := aPom[ i, 2 ]; aSpec[ i, 3 ] := aPom[ i, 3 ]
            aSpec[ i, 4 ] := aPom[ i, 4 ]
         ELSE
            aSpec[ nGrupaPoslova, 2 ] += aPom[ i, 2 ]; aSpec[ nGrupaPoslova, 3 ] += aPom[ i, 3 ]
            aSpec[ nGrupaPoslova, 4 ] += aPom[ i, 4 ]
         ENDIF
      ELSE     // gVarSpec=="2"
         DO CASE
         CASE aPom[ i, 1 ] <= nLimG5
            aSpec[ 5, 1 ] := aPom[ i, 1 ]; aSpec[ 5, 2 ] += aPom[ i, 2 ]
            aSpec[ 5, 3 ] += aPom[ i, 3 ]; aSpec[ 5, 4 ] += aPom[ i, 4 ]
         CASE aPom[ i, 1 ] <= nLimG4
            aSpec[ 4, 1 ] := aPom[ i, 1 ]; aSpec[ 4, 2 ] += aPom[ i, 2 ]
            aSpec[ 4, 3 ] += aPom[ i, 3 ]; aSpec[ 4, 4 ] += aPom[ i, 4 ]
         CASE aPom[ i, 1 ] <= nLimG3
            aSpec[ 3, 1 ] := aPom[ i, 1 ]; aSpec[ 3, 2 ] += aPom[ i, 2 ]
            aSpec[ 3, 3 ] += aPom[ i, 3 ]; aSpec[ 3, 4 ] += aPom[ i, 4 ]
         CASE aPom[ i, 1 ] <= nLimG2
            aSpec[ 2, 1 ] := aPom[ i, 1 ]; aSpec[ 2, 2 ] += aPom[ i, 2 ]
            aSpec[ 2, 3 ] += aPom[ i, 3 ]; aSpec[ 2, 4 ] += aPom[ i, 4 ]
         CASE aPom[ i, 1 ] <= nLimG1
            aSpec[ 1, 1 ] := aPom[ i, 1 ]; aSpec[ 1, 2 ] += aPom[ i, 2 ]
            aSpec[ 1, 3 ] += aPom[ i, 3 ]; aSpec[ 1, 4 ] += aPom[ i, 4 ]
         ENDCASE
      ENDIF
      aSpec[ nGrupaPoslova + 1, 2 ] += aPom[ i, 2 ]; aSpec[ nGrupaPoslova + 1, 3 ] += aPom[ i, 3 ]
      aSpec[ nGrupaPoslova + 1, 4 ] += aPom[ i, 4 ]
   NEXT



   // ukupno radnika
   UzmiIzIni( cIniName, 'Varijable', 'U016', Str( nURadnika, 0 ),'WRITE' )
   // ukupno neto
   UzmiIzIni( cIniName, 'Varijable', 'U018', FormNum2( nUNETO, 16, gPici2 ), 'WRITE' )



   // 31.01.01 nPorNaPlatu  := ROUND2(POR->iznos * aSpec[nGrupaPoslova+1,4] / 100,gZaok2)
   // SELECT POR; HSEEK "01"  // por.na platu
   // nPorNaPlatu  := ROUND2(POR->iznos * nUNeto / 100,gZaok2)
   // 01.02.01 prebaceno u do while petlju

   // 13.02.2001
   // UzmiIzIni(cIniName,'Varijable','D13N', FormNum2(POR->IZNOS,16,gpici3)+"%",'WRITE')
   UzmiIzIni( cIniName, 'Varijable', 'D13N', " ", 'WRITE' )
   SELECT POR; SEEK "01"
   UzmiIzIni( cIniName, 'Varijable', 'D13_1N', FormNum2( POR->IZNOS, 16, gpici3 ) + "%", 'WRITE' )

   nPom = nPorNaPlatu - nPorOlaksice
   UzmiIzIni( cIniName, 'Varijable', 'D13I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   nPom = nPorNaPlatu
   UzmiIzIni( cIniName, 'Varijable', 'D13_1I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   nPom := nPorOlaksice
   UzmiIzIni( cIniName, 'Varijable', 'D13_2I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   nPom := nBolPreko
   UzmiIzIni( cIniName, 'Varijable', 'N17I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // ------------------------------------------------------------------
   // ------------------------------------------------------------------
   nBrutoOsnova := Round( PAROBR->k3 * nUNetoOsnova / 100, gZaok2 )
   // ukupno bruto
   nPom := nBrutoOsnova
   UzmiIzIni( cIniName, 'Varijable', 'U017', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   SELECT DOPR; GO TOP
   DO WHILE !Eof()
      IF DOPR->poopst == "1" .AND. lPDNE
         nBOO := 0
         FOR i := 1 TO Len( aOps )
            IF ! ( DOPR->id $ aOps[ i, 2 ] )
               nBOO += aOps[ i, 3 ]
            ENDIF
         NEXT
         nBOO := Round( PAROBR->k3 * nBOO / 100,gZaok2 )
      ELSE
         nBOO := nBrutoOsnova
      ENDIF
      IF ID $ cDoprOO1  // Ostale obaveze - 1
         IF Empty( ccOO1 ) .AND. nOstOb1 == 0; ccOO1 := NAZ; ENDIF
         nOstOb1 += round2( Max( DLIMIT, nBOO * iznos / 100 ), gZaok2 )
      ENDIF
      IF ID $ cDoprOO2  // Ostale obaveze - 2
         IF Empty( ccOO2 ) .AND. nOstOb2 == 0; ccOO2 := NAZ; ENDIF
         nOstOb2 += round2( Max( DLIMIT, nBOO * iznos / 100 ), gZaok2 )
      ENDIF
      IF ID $ cDoprOO3  // Ostale obaveze - 3
         IF Empty( ccOO3 ) .AND. nOstOb3 == 0; ccOO3 := NAZ; ENDIF
         nOstOb3 += round2( Max( DLIMIT, nBOO * iznos / 100 ), gZaok2 )
      ENDIF
      IF ID $ cDoprOO4 // Ostale obaveze - 4
         IF Empty( ccOO4 ) .AND. nOstOb4 == 0; ccOO4 := NAZ; ENDIF
         nOstOb4 += round2( Max( DLIMIT, nBOO * iznos / 100 ), gZaok2 )
      ENDIF
      IF ID $ cDoprOO   // Ostale obaveze
         nOstaleObaveze += round2( Max( DLIMIT, nBOO * iznos / 100 ), gZaok2 )
      ENDIF
      SKIP 1
   ENDDO


   nkD1X := Ocitaj( F_DOPR, cDopr1, "iznos", .T. )
   nkD2X := Ocitaj( F_DOPR, cDopr2, "iznos", .T. )
   nkD3X := Ocitaj( F_DOPR, cDopr3, "iznos", .T. )
   nkD5X := Ocitaj( F_DOPR, cDopr5, "iznos", .T. )
   nkD6X := Ocitaj( F_DOPR, cDopr6, "iznos", .T. )
   nkD7X := Ocitaj( F_DOPR, cDopr7, "iznos", .T. )


   // stope na bruto

   nPom := nKD1X + nKD2X + nKD3X
   UzmiIzIni( cIniName, 'Varijable', 'D11B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
   nPom := nKD1X
   UzmiIzIni( cIniName, 'Varijable', 'D11_1B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
   nPom := nKD2X
   UzmiIzIni( cIniName, 'Varijable', 'D11_2B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
   nPom := nKD3X
   UzmiIzIni( cIniName, 'Varijable', 'D11_3B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )

   nPom := nKD5X + nKD6X + nKD7X
   UzmiIzIni( cIniName, 'Varijable', 'D12B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
   nPom := nKD5X
   UzmiIzIni( cIniName, 'Varijable', 'D12_1B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
   nPom := nKD6X
   UzmiIzIni( cIniName, 'Varijable', 'D12_2B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
   nPom := nKD7X
   UzmiIzIni( cIniName, 'Varijable', 'D12_3B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )

   nDopr1X := round2( nBrutoOsnova * nkD1X / 100, gZaok2 )
   nDopr2X := round2( nBrutoOsnova * nkD2X / 100, gZaok2 )
   nDopr3X := round2( nBrutoOsnova * nkD3X / 100, gZaok2 )
   nDopr5X := round2( nBrutoOsnova * nkD5X / 100, gZaok2 )
   nDopr6X := round2( nBrutoOsnova * nkD6X / 100, gZaok2 )
   nDopr7X := round2( nBrutoOsnova * nkD7X / 100, gZaok2 )

   // iznos doprinosa
   nPom := nDopr1X + nDopr2X + nDopr3X
   UzmiIzIni( cIniName, 'Varijable', 'D11I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   nPom := nDopr1X
   UzmiIzIni( cIniName, 'Varijable', 'D11_1I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   nPom := nDopr2X
   UzmiIzIni( cIniName, 'Varijable', 'D11_2I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   nPom := nDopr3X
   UzmiIzIni( cIniName, 'Varijable', 'D11_3I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   nPom := nDopr5X + nDopr6X + nDopr7X
   UzmiIzIni( cIniName, 'Varijable', 'D12I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   nPom := nDopr5X
   UzmiIzIni( cIniName, 'Varijable', 'D12_1I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   nPom := nDopr6X
   UzmiIzIni( cIniName, 'Varijable', 'D12_2I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   nPom := nDopr7X
   UzmiIzIni( cIniName, 'Varijable', 'D12_3I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   nPorOlaksice   := Abs( nPorOlaksice   )
   nBolPreko      := Abs( nBolPreko      )
   nObustave      := Abs( nObustave      )
   nOstOb1        := Abs( nOstOb1        )
   nOstOb2        := Abs( nOstOb2        )
   nOstOb3        := Abs( nOstOb3        )
   nOstOb4        := Abs( nOstOb4        )
   nOstaleObaveze := Abs( IF( nOstaleObaveze == 0, nOstOb1 + nOstOb2 + nOstOb3 + nOstOb4, nOstaleObaveze ) )

   nPom := nDopr1X + nDopr2x + nDopr3x + ;
      nDopr5x + nDopr6x + nDopr7x + ;
      nPorNaPlatu + nPorezOstali - ;
      nPorOlaksice + nOstaleOBaveze;
      // ukupno obaveze
   UzmiIzIni( cIniName, 'Varijable', 'U15I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // ukupno placa_i_obaveze = obaveze + ukupno_neto + poreskeolaksice
   nPom := nPom + nUNETO + nPorOlaksice
   UzmiIzIni( cIniName, 'Varijable', 'U16I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // obustave
   nPom := nObustave
   UzmiIzIni( cIniName, 'Varijable', 'O18I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // neto za isplatu  = neto  + nPorOlaksice
   // -----------------------------------------
   // varijanta D - specificno za FEB jer treba da izbazi bol.preko.42
   // dana iz neta za isplatu na specifikaciji, vec je uracunat u netu.

   IF IzFmkIni( 'LD', 'BolPreko42IzbaciIz19', 'N', KUMPATH ) == 'D'
      nPom := nUNETO + nPorOlaksice - nObustave
   ELSE
      nPom := nUNETO + nBolPreko + nPorOlaksice - nObustave
   ENDIF
   UzmiIzIni( cIniName, 'Varijable', 'N19I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // PIO iz + PIO na placu
   nPom := nDopr1x + nDopr5x
   UzmiIzIni( cIniName, 'Varijable', 'D20', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   // zdravsveno iz + zdravstveno na placu
   nPom := nDopr2x + nDopr6x
   UzmiIzIni( cIniName, 'Varijable', 'D21', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
   // nezaposlenost iz + nezaposlenost na placu
   nPom := nDopr3x + nDopr7x
   UzmiIzIni( cIniName, 'Varijable', 'D22', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   nPom = nPorNaPlatu - nPorOlaksice
   UzmiIzIni( cIniName, 'Varijable', 'P23', FormNum2( nPom, 16, gPici2 ), 'WRITE' )


   nPom = nPorezOstali
   UzmiIzIni( cIniName, 'Varijable', 'O14_1I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   nPom = nOstaleObaveze + nPorezOstali
   UzmiIzIni( cIniName, 'Varijable', 'O14I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )


   IniRefresh()
   // Odstampaj izvjestaj

   IF LastKey() != K_ESC

      f18_rtm_print( "ldspec", "DUMMY", "1" )

   ENDIF

   my_close_all_dbf()

   RETURN



// ---------------------------------------------------
// vraca naziv mjeseca
// ---------------------------------------------------
FUNCTION ld_naziv_mjeseca( nMjesec, nGodina, lShort, lGodina )

   LOCAL aVrati := { "Januar", "Februar", "Mart", "April", "Maj", "Juni", "Juli", ;
      "Avgust", "Septembar", "Oktobar", "Novembar", "Decembar", "UKUPNO" }
   LOCAL cTmp

   IF lShort == nil
      lShort := .F.
   ENDIF
   IF lGodina == nil
      lGodina := .T.
   ENDIF

   IF nGodina == nil
      nGodina := 0
   ENDIF

   IF ( nMjesec > 0 .AND. nMjesec < 14 )
	
      cTmp := aVrati[ nMjesec ]

      IF lShort == .T.
         cTmp := PadR( cTmp, 3 )
      ENDIF

      IF nGodina > 0 .AND. lGodina == .T.
         cTmp := cTmp + " " + AllTrim( Str( nGodina ) )
      ENDIF

      RETURN cTmp

   ELSE
      RETURN ""
   ENDIF

   RETURN



FUNCTION Specif2()

   O_RADN
   O_LD_RJ
   O_STRSPR
   O_OPS
   O_LD

   cIdRj := gRj
   cMjesec := gMjesec
   cGodina := gGodina
   cObracun := gObracun
   gOstr := "D"
   gTabela := 1
   cMRad := "17"
   cIdRadn := Space( 6 )
   cStrSpr := Space( 3 )
   cOpsSt := Space( 4 )
   cOpsRad := Space( 4 )
   qqRJ := Space( 60 )

   O_PARAMS

   PRIVATE cSection := "4"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "i4", @cMRad )

   Box(, 12, 70 )
   DO WHILE .T.
      @ m_x + 2, m_y + 2 SAY "Radne jedinice: "  GET  qqRJ PICT "@!S25"
      @ m_x + 3, m_y + 2 SAY "Mjesec: "  GET  cmjesec  PICT "99"
      @ m_x + 3, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
      @ m_x + 4, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
      @ m_x + 6, m_y + 2 SAY "Sifra minulog rada" GET cMRad VALID LD->( FieldPos( "I" + cMRad ) ) > 0 .OR. Empty( cMRad ) PICT "99"
      @ m_x + 7, m_y + 2 SAY "Opstina stanovanja: "  GET  cOpsSt PICT "@!" VALID Empty( cOpsSt ) .OR. P_Ops( @cOpsSt )
      @ m_x + 8, m_y + 2 SAY "Opstina rada:       "  GET  cOpsRad  PICT "@!" VALID Empty( cOpsRad ) .OR. P_Ops( @cOpsRad )
      @ m_X + 11, m_y + 2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr $ "DN" PICT "@!"
      @ m_X + 11, m_y + 38 SAY "Tip tabele (0/1/2)" GET gTabela VALID gTabela < 3 .AND. gTabela >= 0 PICT "9"
      read; clvbox(); ESC_BCR
      aUsl1 := Parsiraj( qqRJ, "IDRJ" )
      aUsl2 := Parsiraj( qqRJ, "ID" )
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL; exit; ENDIF
   ENDDO
   BoxC()

   WPar( "i4", cMRad )
   SELECT params
   USE

   SELECT LD

   Box(, 2, 30 )
   nSlog := 0; nUkupno := RECCOUNT2()
   cSort1 := "IDSTRSPR"
   cFilt  := "Tacno(aUsl1) .and. cGodina==GODINA .and. cMjesec==MJESEC .and. ImaUOps(cOpsSt,cOpsRad)"
   IF lViseObr .AND. !Empty( cObracun )
      cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
   ENDIF
   INDEX ON &cSort1 TO "tmpld" FOR &cFilt Eval( TekRec2() ) EVERY 1
   BoxC()

   GO TOP
   IF Eof(); Msg( "Ne postoje trazeni podaci...", 6 ); closeret; ENDIF

   START PRINT CRET

   PRIVATE cIdSS := "", cNIdSS := ""
   PRIVATE nUkRad := 0, nUkMin := 0, nUkNet := 0, nSveUk := 0

   aKol := { { "STRUCNA SPREMA", {|| cIdSS + "(" + cNIdSS + ")" }, .F., "C", 15, 0, 1, 1 }, ;
      { "BR.RADNIKA", {|| nUKRad              }, .T., "N", 10, 0, 1, 2 }, ;
      { "NETO", {|| nUkNet              }, .T., "N", 12, 2, 1, 3 }, ;
      { "MINULI RAD", {|| nUkMin              }, .T., "N", 12, 2, 1, 4 }, ;
      { "NETO-MINULI RAD", {|| nSveUk              }, .T., "N", 12, 2, 1, 5 } }

   P_10CPI

   ?? gnFirma
   ?
   ? Lokal( "Mjesec:" ), Str( cmjesec, 2 ) + IspisObr()
   ?? Space( 4 ) + Lokal( "Godina:" ), Str( cGodina, 5 )

   O_LD_RJ
   SELECT ld_rj

   ? Lokal( "Obuhvacene radne jedinice: " )

   IF !Empty( qqRJ )
      SET FILTER TO &aUsl2
      GO TOP
      DO WHILE !Eof()
         ?? field->id + " - " + field->naz
         ? Space( 27 )
         SKIP 1
      ENDDO
   ELSE
      ?? "SVE"
      ?
   ENDIF

   SELECT LD

   ? Lokal( "Opstina stanovanja :" ), ;
      IF( Empty( cOpsSt ), "SVE", Ocitaj( F_OPS, cOpsSt, "id+'-'+naz" ) )
   ? Lokal( "Opstina rada       :" ), ;
      IF( Empty( cOpsRad ), "SVE", Ocitaj( F_OPS, cOpsRad, "id+'-'+naz" ) )
   ?

   StampaTabele( aKol, {|| FSvaki1() },, gTabela,, ;
      , Lokal( "SPECIFIKACIJA NETA I MINULOG RADA PO OPSTINAMA I RAD.JEDINICAMA" ), ;
      {|| FFor1() }, IF( gOstr == "D",, -1 ),,,,, )
   FF

   END PRINT

   CLOSERET

   RETURN
// }


FUNCTION FFor1()

   // {
   cIdSS := _FIELD->IDSTRSPR
   nUKRad := nUkMin := nUkNet := nSveUk := 0
   cNIdSS := Ocitaj( F_STRSPR, _FIELD->IDSTRSPR, "TRIM(naz)" )
   DO WHILE !Eof() .AND. cIdSS == _FIELD->IDSTRSPR
      IF ! ( lViseObr .AND. Empty( cObracun ) .AND. obr <> "1" )
         nUkRad++
      ENDIF
      nUkMin += &( "I" + cMRad )
      nUkNet += _FIELD->UNETO
      SKIP 1
   ENDDO
   nSveUk := nUkNet - nUkMin
   SKIP -1

   RETURN .T.


STATIC FUNCTION FSvaki1()

   // {

   RETURN
// }

STATIC FUNCTION TekRec2()

   // {
   nSlog++
   @ m_x + 1, m_y + 2 SAY PadC( AllTrim( Str( nSlog ) ) + "/" + AllTrim( Str( nUkupno ) ), 20 )
   @ m_x + 2, m_y + 2 SAY "Obuhvaceno: " + Str( 0 )

   RETURN ( NIL )
// }


FUNCTION ImaUOps( cOStan, cORada )

   LOCAL lVrati := .F.

   IF ( Empty( cOStan ) .OR. Ocitaj( F_RADN, _FIELD->IDRADN, "IDOPSST" ) == cOStan ) .AND. ;
         ( Empty( cORada ) .OR. Ocitaj( F_RADN, _FIELD->IDRADN, "IDOPSRAD" ) == cORada )
      lVrati := .T.
   ENDIF

   RETURN lVrati




// -------------------------------------------------------
// kreiranje mtemp tabele
// -------------------------------------------------------
STATIC FUNCTION _create_mtemp()

   LOCAL _i, _struct
   LOCAL _table := "mtemp"
   LOCAL _ret := .T.

   // pobrisi tabelu
   IF File( my_home() + _table + ".dbf" )
      FErase( my_home() + _table + ".dbf" )
   ENDIF

   _struct := LD->( dbStruct() )

   // ovdje cemo sva numericka polja prosiriti za 4 mjesta
   // (izuzeci su polja GODINA i MJESEC)

   FOR _i := 1 TO Len( _struct )
      IF _struct[ _i, 2 ] == "N" .AND. !( Upper( AllTrim( _struct[ _i, 1 ] ) ) $ "GODINA#MJESEC" )
         _struct[ _i, 3 ] += 4
      ENDIF
   NEXT

   // kreiraj tabelu
   dbCreate( my_home() + _table + ".dbf", _struct )

   IF !File( my_home() + _table + ".dbf" )
      MsgBeep( "Ne postoji " + _table + ".dbf !!!" )
      _ret := .F.
   ENDIF

   RETURN _ret


// ---------------------------------------------------------
// specifikacija primanja po mjesecima
// ---------------------------------------------------------
FUNCTION SpecifPoMjes()

   gnLMarg := 0
   gTabela := 1
   gOstr := "N"
   cIdRj := gRj
   cGodina := gGodina
   cIdRadn := Space( 6 )
   cSvaPrim := "S"
   qqOstPrim := ""
   cSamoAktivna := "D"

   O_LD

   // napravi pomocnu tabelu
   IF !_create_mtemp()
      RETURN
   ENDIF

   my_close_all_dbf()

   O_LD_RJ
   O_STRSPR
   O_OPS
   O_RADN
   O_LD

   cIdRadn := fetch_metric( "ld_spec_po_rasponu_id_radnik", my_user(), cIdRadn )
   cSvaPrim := fetch_metric( "ld_spec_po_rasponu_sva_primanja", my_user(), cSvaPrim )
   qqOstPrim := fetch_metric( "ld_spec_po_rasponu_ostala_primanja", my_user(), qqOstPrim )
   cSamoAktivna := fetch_metric( "ld_spec_po_rasponu_samo_aktivna", my_user(), cSamoAktivna )

   qqOstPrim := PadR( qqOstPrim, 100 )

   cPrikKolUk := "D"

   Box(, 7, 77 )

   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno sve): "  GET cIdRJ VALID Empty( cIdRj ) .OR. P_LD_RJ( @cIdRj )
   @ m_x + 2, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 3, m_y + 2 SAY "Radnik (prazno-svi radnici): "  GET  cIdRadn  VALID Empty( cIdRadn ) .OR. P_Radn( @cIdRadn )
   @ m_x + 4, m_y + 2 SAY "Prikazati primanja (N-neto,V-van neta,S-sva primanja,0-nista)" GET cSvaPrim PICT "@!" VALID cSvaPrim $ "NVS0"
   @ m_x + 5, m_y + 2 SAY "Ostala primanja za prikaz (navesti sifre npr. 25;26;27;):" GET qqOstPrim PICT "@S15"
   @ m_x + 6, m_y + 2 SAY "Prikazati samo aktivna primanja ? (D/N)" GET cSamoAktivna PICT "@!" VALID cSamoAktivna $ "DN"
   @ m_x + 7, m_y + 2 SAY "Prikazati kolonu 'ukupno' ? (D/N)" GET cPrikKolUk PICT "@!" VALID cPrikKolUk $ "DN"

   READ
   ESC_BCR

   BoxC()

   qqOstPrim := Trim( qqOstPrim )

   set_metric( "ld_spec_po_rasponu_id_radnik", my_user(), cIdRadn )
   set_metric( "ld_spec_po_rasponu_sva_primanja", my_user(), cSvaPrim )
   set_metric( "ld_spec_po_rasponu_ostala_primanja", my_user(), qqOstPrim )
   set_metric( "ld_spec_po_rasponu_samo_aktivna", my_user(), cSamoAktivna )

   // otvori mtemp tabelu...
   SELECT ( F_TMP_1 )
   my_use_temp( "MTEMP", my_home() + "mtemp" )

   O_TIPPR

   SELECT LD

   PRIVATE cFilt1 := "GODINA==" + cm2str( cGodina ) + ;
      IF( Empty( cIdRJ ), "", ".and.IDRJ==" + cm2str( cIdRJ ) ) + ;
      IF( Empty( cIdRadn ), "", ".and.IDRADN==" + cm2str( cIdRadn ) )

   SET FILTER TO &cFilt1
   SET ORDER TO TAG "2"
   GO TOP

   DO WHILE !Eof()
      cMjesec := mjesec
      DO WHILE !Eof() .AND. cMjesec == mjesec
         SELECT MTEMP
         IF MTEMP->mjesec != cMjesec
            APPEND BLANK
            REPLACE mjesec WITH cMjesec
         ENDIF
         FOR i := 1 TO cLDPolja
            cSTP := PadL( AllTrim( Str( i ) ), 2, "0" )
            IF cSvaPrim != "S" .AND. !( cSTP $ qqOstPrim )
               SELECT TIPPR; HSEEK cSTP; SELECT MTEMP
               IF cSvaPrim == "N" .AND. TIPPR->uneto == "N" .OR. ;
                     cSvaPrim == "V" .AND. TIPPR->uneto == "D" .OR. ;
                     cSvaPrim == "0"
                  LOOP
               ENDIF
            ENDIF
            cNPPI := "I" + cSTP
            cNPPS := "S" + cSTP
            nFPosI := FieldPos( cNPPI )
            nFPosS := FieldPos( cNPPS )
            IF nFPosI > 0
               FieldPut( nFPosI, FieldGet( nFPosI ) + LD->( FieldGet( nFPosI ) ) )
               IF ! ( lViseObr .AND. LD->obr <> "1" ) // samo sati iz 1.obracuna
                  FieldPut( nFPosS, FieldGet( nFPosS ) + LD->( FieldGet( nFPosS ) ) )
               ENDIF
            ELSE
               EXIT
            ENDIF
         NEXT
         SELECT LD
         SKIP 1
      ENDDO
   ENDDO


   nSum := {}
   aKol := {}

   nKol := 1
   nRed := 0
   nKorekcija := 0

   nPicISUk := IF( cPrikKolUk == "D", 9, 10 )  // ako nema kolone ukupno mo§e i 10
   nPicSDec := Decimala( gPicS )
   nPicIDec := Decimala( gPicI )

   NUK := IF( cPrikKolUk == "D", 13, 12 )   // ukupno kolona za iznose

   FOR i := 1 TO cLDPolja

      cSTP := PadL( AllTrim( Str( i ) ), 2, "0" )

      cNPPI := "I" + cSTP
      cNPPS := "S" + cSTP

      SELECT TIPPR; HSEEK cSTP; cAktivno := aktivan
      SELECT LD

      IF FieldPos( cNPPI ) > 0

         IF ( cSamoAktivna == "N" .OR. Upper( cAktivno ) == "D" ) .AND. ;
               ( cSvaPrim == "S" .OR. cSTP $ qqOstPrim .OR. ;
               cSvaPrim == "N" .AND. TIPPR->uneto == "D" .OR. ;
               cSvaPrim == "V" .AND. TIPPR->uneto == "N" )

            cNPrim := "{|| '" + cSTP + "-" + ;
               TIPPR->naz + "'}"

            AAdd( aKol, { IF( ( i - nKorekcija ) == 1, "TIP PRIMANJA", "" ), &cNPrim., .F., "C", 25, 0, 2 * ( i - nKorekcija ) -1, 1 } )

            FOR j := 1 TO NUK

               cPomMI := "nSum[" + AllTrim( Str( i - nKorekcija ) ) + "," + AllTrim( Str( j ) ) + ",1]"
               cPomMS := "nSum[" + AllTrim( Str( i - nKorekcija ) ) + "," + AllTrim( Str( j ) ) + ",2]"

               AAdd( aKol, { IF( i - nKorekcija == 1, ld_naziv_mjeseca( j ), "" ), {|| &cPomMI. }, .F., "N", nPicISUk + IF( j > 12, 1, 0 ), nPicIDec, 2 * ( i - nKorekcija ) -1, j + 1 } )
               AAdd( aKol, { IF( i - nKorekcija == 1, "IZNOS/SATI", "" ), {|| &cPomMS. }, .F., "N", nPicISUk + IF( j > 12, 1, 0 ), nPicSDec, 2 * ( i - nKorekcija ), j + 1 } )

            NEXT

         ELSE

            nKorekcija += 1

         ENDIF

      ELSE
         EXIT
      ENDIF

   NEXT

   // dodati sumu svega (red "UKUPNO")
   // --------------------------------
   AAdd( aKol, { "", {|| REPL( "=", 25 ) }, .F., "C", 25, 0, 2 * ( i - nKorekcija ) -1, 1 } )

   AAdd( aKol, { "", {|| "U K U P N O"    }, .F., "C", 25, 0, 2 * ( i - nKorekcija ), 1 } )
   FOR j := 1 TO NUK
      cPomMI := "nSum[" + AllTrim( Str( i - nKorekcija ) ) + "," + AllTrim( Str( j ) ) + ",1]"
      cPomMS := "nSum[" + AllTrim( Str( i - nKorekcija ) ) + "," + AllTrim( Str( j ) ) + ",2]"

      AAdd( aKol, { "", {|| &cPomMI. }, .F., "N", nPicISUk + IF( j > 12, 1, 0 ), nPicIDec, 2 * ( i - nKorekcija ), j + 1 } )
      AAdd( aKol, { "", {|| &cPomMS. }, .F., "N", nPicISUk + IF( j > 12, 1, 0 ), nPicSDec, 2 * ( i - nKorekcija ) + 1, j + 1 } )
   NEXT
   // --------------------------------

   nSumLen := i - 1 -nKorekcija + 1
   nSum := Array( nSumLen, NUK, 2 )
   FOR k := 1 TO nSumLen
      FOR j := 1 TO NUK
         FOR l := 1 TO 2
            nSum[ k, j, l ] := 0
         NEXT
      NEXT
   NEXT

   SELECT MTEMP
   GO TOP

   START PRINT CRET

   P_12CPI

   ?? Space( gnLMarg ); ?? Lokal( "LD: Izvjestaj na dan" ), Date()
   ? Space( gnLMarg ); IspisFirme( "" )
   ? Space( gnLMarg ); ?? Lokal( "RJ:" ) + Space( 1 ); B_ON; ?? IF( Empty( cIdRJ ), "SVE", cIdRJ ); B_OFF
   ?? Space( 2 ) + Lokal( "GODINA: " ); B_ON; ?? cGodina; B_OFF
   ? Lokal( "RADNIK: " )
   IF Empty( cIdRadn )
      ?? "SVI"
   ELSE
      SELECT ( F_RADN ); HSEEK cIdRadn
      SELECT ( F_STRSPR ); HSEEK RADN->idstrspr
      SELECT ( F_OPS ); HSEEK RADN->idopsst; cOStan := naz
      HSEEK RADN->idopsrad
      SELECT ( F_RADN )
      B_ON; ?? cIdRadn + "-" + Trim( naz ) + ' (' + Trim( imerod ) + ') ' + ime; B_OFF
      ? Lokal( "Br.knjiz: " ); B_ON; ?? brknjiz; B_OFF
      ?? Lokal( "  Mat.br: " ); B_ON; ?? matbr; B_OFF
      ?? Lokal( "  R.mjesto: " ); B_ON; ?? rmjesto; B_OFF

      ? Lokal( "Min.rad: " ); B_ON; ?? kminrad; B_OFF
      ?? Lokal( "  Str.spr: " ); B_ON; ?? STRSPR->naz; B_OFF
      ?? Lokal( "  Opst.stan: " ); B_ON; ?? cOStan; B_OFF

      ? Lokal( "Opst.rada: " ); B_ON; ?? OPS->naz; B_OFF
      ?? Lokal( "  Dat.zasn.rad.odnosa: " ); B_ON; ?? datod; B_OFF
      ?? Lokal( "  Pol: " ); B_ON; ?? pol; B_OFF
      SELECT MTEMP
   ENDIF

   StampaTabele( aKol, {|| FSvaki3() },, gTabela,, ;
      , Lokal( "Specifikacija primanja po mjesecima" ), ;
      {|| FFor3() }, IF( gOstr == "D",, -1 ),,,,,, .F. )

   SELECT ld

   my_close_all_dbf()

   FF
   END PRINT

   RETURN


STATIC FUNCTION FFor3()

   LOCAL nArr := Select()

   DO WHILE !Eof()
      nKorekcija := 0
      FOR i := 1 TO cLDPolja
         cSTP := PadL( AllTrim( Str( i ) ), 2, "0" )
         cNPPI := "I" + cSTP
         cNPPS := "S" + cSTP
         SELECT TIPPR; HSEEK cSTP; cAktivno := aktivan
         SELECT ( nArr )
         nFPosI := FieldPos( cNPPI )
         nFPosS := FieldPos( cNPPS )
         IF nFPosI > 0
            IF ( cSamoAktivna == "N" .OR. Upper( cAktivno ) == "D" ) .AND. ;
                  ( cSvaPrim == "S" .OR. cSTP $ qqOstPrim .OR. ;
                  cSvaPrim == "N" .AND. TIPPR->uneto == "D" .OR. ;
                  cSvaPrim == "V" .AND. TIPPR->uneto == "N" )
               nSum[ i - nKorekcija, mjesec, 1 ] := FieldGet( nFPosI )
               nSum[ nSumLen, mjesec, 1 ] += FieldGet( nFPosI )
               nSum[ i - nKorekcija, mjesec, 2 ] := FieldGet( nFPosS )
               nSum[ nSumLen, mjesec, 2 ] += FieldGet( nFPosS )

               IF NUK > 12
                  // kolona 13.mjeseca tj."ukupno" iznos
                  nSum[ i - nKorekcija, NUK, 1 ] += FieldGet( nFPosI )
                  // red ukupno kolone 13.mjeseca tj."sveukupno" iznos
                  nSum[ nSumLen, NUK, 1 ] += FieldGet( nFPosI )
                  // kolona 13.mjeseca tj."ukupno" sati
                  nSum[ i - nKorekcija, NUK, 2 ] += FieldGet( nFPosS )
                  // red ukupno kolone 13.mjeseca tj."sveukupno" sati
                  nSum[ nSumLen, NUK, 2 ] += FieldGet( nFPosS )
               ENDIF
            ELSE
               nKorekcija += 1
            ENDIF
         ELSE
            EXIT
         ENDIF
      NEXT
      SKIP 1
   ENDDO
   // SKIP -1

   RETURN .T.


STATIC FUNCTION FSvaki3()
   RETURN



FUNCTION Izrezi( cPoc, nIza, cOstObav )

   LOCAL cVrati := "", nPoz := 0

   DO WHILE ( nPoz := At( cPoc, cOstObav ) ) > 0
      cVrati := cVrati + SubStr( cOstObav, nPoz + Len( cPoc ), nIza ) + ";"
      cOstObav := Stuff( cOstObav, nPoz, Len( cPoc ) + nIza, "" )
      cOstObav := StrTran( cOstObav, ";;", ";" )
   ENDDO

   RETURN cVrati


STATIC FUNCTION FormNum1( nIznos, nDuz, pici )

   LOCAL cVrati

   cVrati := Transform( nIznos, pici )
   cVrati := StrTran( cVrati, ".", ":" )
   cVrati := StrTran( cVrati, ",", "." )
   cVrati := StrTran( cVrati, ":", "," )
   cVrati := AllTrim( cVrati )
   cVrati := IF( Len( cVrati ) > nDuz, REPL( "*", nDuz ), PadL( cVrati, nDuz ) )

   RETURN cVrati


FUNCTION FormNum2( nIznos, nDuz, pici )
   RETURN AllTrim( formnum1( nIznos, nDuz, pici ) )



PROCEDURE Specif3()

   O_RADN
   O_LD_RJ
   O_STRSPR
   O_OPS
   O_LD

   cIdRj := gRj; cmjesec := gMjesec; cMjesecDo := gMjesec
   cGodina := gGodina
   cObracun := gObracun
   gOstr := "D"; gTabela := 1

   cIdRadn := Space( 6 )
   cStrSpr := Space( 3 )
   cOpsSt := Space( 4 )
   cOpsRad := Space( 4 )

   qqRJ := Space( 60 )

   // O_PARAMS
   // Private cSection:="4",cHistory:=" ",aHistory:={}
   // RPar("i4",@cMRad)

   Box(, 11, 70 )
   DO WHILE .T.
      @ m_x + 2, m_y + 2 SAY "Radne jedinice: "  GET  qqRJ PICT "@!S25"
      @ m_x + 3, m_y + 2 SAY "Od mjeseca: "  GET  cmjesec  PICT "99"
      @ m_x + 3, Col() + 2 SAY "do mjeseca: "  GET  cmjesecdo  PICT "99"
      @ m_x + 3, Col() + 2 SAY "Obracun: "  GET  cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
      @ m_x + 4, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
      @ m_x + 6, m_y + 2 SAY "Opstina stanovanja: "  GET  cOpsSt PICT "@!" VALID Empty( cOpsSt ) .OR. P_Ops( @cOpsSt )
      @ m_x + 7, m_y + 2 SAY "Opstina rada:       "  GET  cOpsRad  PICT "@!" VALID Empty( cOpsRad ) .OR. P_Ops( @cOpsRad )
      @ m_X + 10, m_y + 2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr $ "DN" PICT "@!"
      @ m_X + 10, m_y + 38 SAY "Tip tabele (0/1/2)" GET gTabela VALID gTabela < 3 .AND. gTabela >= 0 PICT "9"
      read; clvbox(); ESC_BCR
      aUsl1 := Parsiraj( qqRJ, "IDRJ" )
      aUsl2 := Parsiraj( qqRJ, "ID" )
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL; exit; ENDIF
   ENDDO
   BoxC()

   // WPar("i4",cMRad)
   // select params; use

   SELECT LD

   Box(, 2, 30 )
   nSlog := 0; nUkupno := RECCOUNT2()
   cSort1 := "IDSTRSPR"
   cFilt  := aUsl1 + " .and. cGodina==GODINA .and." + IF( cMjesec <> cMjesecdo, " cMjesec<=MJESEC .and. cMjesecDo>=MJESEC", " cMjesec==MJESEC" ) + " .and. ImaUOps(cOpsSt,cOpsRad)"
   IF lViseObr .AND. !Empty( cObracun )
      cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
   ENDIF
   INDEX ON &cSort1 TO "ldtmp" FOR &cFilt Eval( TekRec2() ) EVERY 1
   BoxC()

   GO TOP
   IF Eof(); Msg( "Ne postoje trazeni podaci...", 6 ); closeret; ENDIF

   START PRINT CRET

   PRIVATE cIdSS := "", cNIdSS := ""
   PRIVATE nUkRad := 0, nUkNet := 0, nSUkRad := 0, nSUkNet := 0

   aKol := { { "STRUCNA SPREMA", {|| cIdSS + "(" + cNIdSS + ")" }, .F., "C",15, 0, 1, 1 }, ;
      { "(1)", {|| "#"                 }, .F., "C",15, 0, 2, 1 }, ;
      { "BR.RADNIKA", {|| nUKRad              }, .F., "N",10, 0, 1, 2 }, ;
      { "(2)", {|| "#"                 }, .F., "C",10, 0, 2, 2 }, ;
      { "NETO", {|| nUkNet              }, .F., "N",12, 2, 1, 3 }, ;
      { "(3)", {|| "#"                 }, .F., "C",12, 0, 2, 3 }, ;
      { "PROSJECNI NETO", {|| IF( nUkRad == 0, 0, nUkNet / nUkRad ) }, .F., "N-", 16, 2, 1, 4 }, ;
      { "(4) = (3)/(2)", {|| "#"                 }, .F., "C",16, 0, 2, 4 } }

   P_10CPI
   ?? gnFirma
   ?
   IF cMjesec == cMjesecDo
      ? Lokal( "Mjesec:" ), Str( cmjesec, 2 ) + IspisObr()
      ?? Space( 4 ) + Lokal( "Godina:" ), Str( cGodina, 5 )
   ELSE
      ? Lokal( "Od mjeseca:" ), Str( cmjesec, 2 ) + ".", Lokal( "do mjeseca:" ), Str( cmjesecdo, 2 ) + "." + IspisObr()
      ?? Space( 4 ) + Lokal( "Godina:" ), Str( cGodina, 5 )
   ENDIF

   O_LD_RJ
   SELECT ld_rj
   ? Lokal( "Obuhvacene radne jedinice: " )
   IF !Empty( qqRJ )
      SET FILTER TO &aUsl2
      GO TOP
      DO WHILE !Eof()
         ?? id + " - " + naz
         ? Space( 27 )
         SKIP 1
      ENDDO
   ELSE
      ?? "SVE"
      ?
   ENDIF
   SELECT LD
   ? Lokal( "Opstina stanovanja :" ), ;
      IF( Empty( cOpsSt ), "SVE", Ocitaj( F_OPS, cOpsSt, "id+'-'+naz" ) )
   ? Lokal( "Opstina rada       :" ), ;
      IF( Empty( cOpsRad ), "SVE", Ocitaj( F_OPS, cOpsRad, "id+'-'+naz" ) )
   ?

   gaDodStavke := {}

   StampaTabele( aKol, {|| FSvaki31() },, gTabela,, ;
      , Lokal( "SPECIFIKACIJA PROSJECNOG NETA PO STRUCNOJ SPREMI" ), ;
      {|| FFor31() }, IF( gOstr == "D",, -1 ),,,,, )

   END PRINT

   CLOSERET

STATIC FUNCTION FFor31()

   gaDodStavke := {}
   cIdSS := _FIELD->IDSTRSPR
   nUKRad := nUkNet := 0
   cNIdSS := Ocitaj( F_STRSPR, _FIELD->IDSTRSPR, "TRIM(naz)" )
   DO WHILE !Eof() .AND. cIdSS == _FIELD->IDSTRSPR
      IF ! ( lViseObr .AND. Empty( cObracun ) .AND. _FIELD->OBR <> "1" )
         nUkRad++
      ENDIF
      nUkNet += _FIELD->UNETO
      SKIP 1
   ENDDO
   nSUkRad += nUkRad
   nSUkNet += nUkNet
   IF Eof()
      gaDodStavke  := { { "UKUPNO", nSUkRad, nSUkNet, IF( nSUkRad == 0, 0, nSUkNet / nSUkRad ) } }
   ENDIF
   SKIP -1

   RETURN .T.


STATIC FUNCTION FSvaki31()
   RETURN IF( !Empty( gaDodStavke ), "PODVUCI" + "=", NIL )




FUNCTION OSpecif()

   O_DOPR
   O_POR
   O_PAROBR
   O_KBENEF
   O_VPOSLA
   O_LD_RJ
   O_RADN
   O_PARAMS
   O_LD
   O_OPS

   RETURN
