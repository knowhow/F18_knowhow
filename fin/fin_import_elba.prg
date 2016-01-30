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

// vars
STATIC __delimit
STATIC __rbr
STATIC __nalbr
STATIC __k_kup

// ----------------------------------------
// import elba txt... glavna funkcija
// ----------------------------------------
FUNCTION _imp_elba_txt( cTxt )

   LOCAL nItems
   LOCAL cImpView

   IF cTxt == nil
      cTxt := ""
   ENDIF

   // provjeri da li je priprema prazna
   IF __ck_pripr() > 0
      MsgBeep( "Priprema mora biti prazna !!!#Ispraznite pripremu i ponovite proceduru." )
      RETURN
   ENDIF

   // uzmi parametre...
   IF _get_params( @cTxt, @cImpView ) == 0
      MsgBeep( "Prekidam operaciju..." )
      RETURN
   ENDIF

   O_FIN_PRIPR
   O_NALOG

   // delimiter je TAB
   __delimit := Chr( 9 )

   // kupac konto
   __k_kup := r_get_konto( "KUP_KONTO" )


   // uzmi lokaciju fajla txt ako nije proslijedjeno...
   IF Empty( cTxt )
      _g_elba_file( @cTxt )
   ENDIF

   // napuni pripremu sa stavkama... iz txt
   nItems := _g_el_items( cTxt, cImpView )

   IF nItems > 0
      MsgBeep( "Obradjeno: " + AllTrim( Str( nItems ) ) + " stavki.#Stavke se nalaze u pripremi." )
   ENDIF

   RETURN

// -------------------------------------------------------
// provjerava koliko zapisa postoji u pripremi
// -------------------------------------------------------
STATIC FUNCTION __ck_pripr()

   LOCAL nReturn := 0

   O_FIN_PRIPR
   SELECT fin_pripr
   nReturn := RecCount2()

   RETURN nReturn


// -------------------------------------------
// parametri importa
// -------------------------------------------
STATIC FUNCTION _get_params( cFile, cImpView )

   LOCAL nX := 1
   LOCAL cImpOk := "D"
   LOCAL GetList := {}

   cFile := PadR( "c:\temp\elba.txt", 300 )
   cFile := fetch_metric( "import_elba_lokacija_fajla", my_user(), cFile )
   cImpView := "D"

   Box(, 9, 65 )

   @ m_x + nX, m_y + 2 SAY "Parametri importa" COLOR "BG+/B"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Lokacija i naziv fajla za import:"

   nX += 1

   @ m_x + nX, m_y + 2 GET cFile PICT "@S60" VALID _file_valid( cFile )

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Pregled importa (D/N)?" GET cImpView VALID cImpView $ "DN" PICT "@!"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Importovati podatke (D/N)?" GET cImpOk VALID cImpOk $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC .OR. cImpOk == "N"
      RETURN 0
   ENDIF

   cFile := AllTrim( cFile )
   set_metric( "import_elba_lokacija_fajla", my_user(), cFile )

   RETURN 1

// ------------------------------------------
// validacija fajla
// ------------------------------------------
STATIC FUNCTION _file_valid( cFile )

   LOCAL lRet := .T.

   cFile := AllTrim( cFile )

   IF Empty( cFile )
      MsgBeep( "Lokacija i ime fajla moraju biti popunjeni !" )
      lRet := .F.
   ELSE
      IF !File( cFile )
         MsgBeep( "Ovaj fajl ne postoji !!!" )
         lRet := .F.
      ENDIF
   ENDIF

   RETURN lRet


// -------------------------------------------------------
// vraca gdje se nalazi txt fajl za import
// -------------------------------------------------------
STATIC FUNCTION _g_elba_file( cTxt )

   cTxt := EXEPATH + "elba.txt"

   RETURN


// -------------------------------------------------------
// vraca matricu napunjenu stavkama iz txt fajla...
// -------------------------------------------------------
STATIC FUNCTION _g_el_items( cTxt, cImpView )

   LOCAL nItems := 0
   LOCAL aHeader := {}
   LOCAL aItem := {}
   LOCAL cTemp := ""
   LOCAL i
   LOCAL cNalBr

   LOCAL _o_file

   PRIVATE aPartArr := {}
   PRIVATE GetList := {}

   __nalbr := ""
   __rbr := 0

   _o_file := TFileRead():New( cTxt )
   _o_file:Open()

   IF _o_file:Error()
      msgbeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " ) )
      RETURN 0
   ENDIF

   Box( , 22, 70 )

   @ m_x + 1, m_y + 2 SAY "Vrsim import podataka u pripremu ..." COLOR "BG+/B"

   // for i:=1 to nFLines
   WHILE _o_file:MoreToRead()

      cTemp := hb_StrToUTF8( _o_file:ReadLine() )

      IF Empty( cTemp )
         LOOP
      ENDIF

      aItem := TokToNiz( cTemp, __delimit )

      aFinItem := {}

      // izvuci u FIN pripr matricu aFinItem podatke za nalog
      IF _g_elba_item( aItem, aHeader, @aFinItem, cTemp, nItems ) == .T.

         // sada ubaci elba item u pripr
         _i_elba_item( aFinItem, cImpView )

         ++ nItems

         @ m_x + 3, m_y + 2 SAY PadR( "", 60 ) COLOR "BG+/B"
         @ m_x + 3, m_y + 2 SAY "stavka " + AllTrim( Str( nItems ) ) COLOR "BG+/B"

      ELSE

         // ovo su parametri izvoda...
         aHeader := aItem

         __nalbr := PadL( aHeader[ 1 ], 8, "0" )

         @ m_x + 4, m_y + 2 SAY "Izvod broj: " + PadL( aHeader[ 1 ], 8, "0" )

      ENDIF

   ENDDO

   _o_file:Close()

   // sada uzmi pravi broj naloga i broj veze
   SELECT fin_pripr
   SET ORDER TO TAG "0"
   GO TOP
   my_flock()
   DO WHILE !Eof()
      REPLACE brnal WITH __nalbr
      REPLACE brdok WITH __nalbr
      SKIP
   ENDDO
   my_unlock()
   SET ORDER TO TAG "1"
   GO TOP

   BoxC()

   RETURN nItems


// ----------------------------------------------------------------
// vraca napunjenu matricu aFin pripremljenu za import u pripr
// ----------------------------------------------------------------
STATIC FUNCTION _g_elba_item( aItem, aHeader, aFin, cLine, nLineNo )

   LOCAL nItemLen := Len( aItem )
   LOCAL cFirma := gFirma
   LOCAL cIdVn := "I1"

   aFin := {}

   // aFin[1] = idfirma
   // aFin[2] = idvn
   // aFin[3] = brnal
   // aFin[4] = brveze
   // aFin[5] = datnal
   // aFin[6] = konto
   // aFin[7] = partner
   // aFin[8] = duguje / potrazuje
   // aFin[9] = valuta
   // aFin[10] = iznos
   // aFin[11] = opis
   // aFin[12] = naziv firme iz TXT fajla


   IF aItem[ 1 ] $ "+-"


      // standardna transakcija....
      IF nItemLen == 12

         // {1} - tip transakcije (+/-)
         // {2} - datum i vrijeme "27.11.2006 15:15:02"
         // {3} - broj transakcije
         // {4} - uplata UP, ili ???
         // {5} - 2664508 ????
         // {6} - 0 ????
         // {7} - Banka naziv
         // {8} - transakcijski racun primaoca
         // {9} - naziv firme
         // {10} - opis + "/" + racun + puni naziv firme
         // {11} - valuta KM ili drugo
         // {12} - iznos

         AAdd( aFin, { cFirma, ;
            cIdVn, ;
            __nalbr, ;
            __nalbr, ;
            _g_elba_date( aItem[ 2 ] ), ;
            _g_konto( aItem[ 1 ], aItem[ 10 ] ), ;
            _g_partn( aItem[ 1 ], aItem[ 9 ], aItem[ 8 ] ), ;
            _g_elba_dp( aItem[ 1 ] ), ;
            aItem[ 11 ], ;
            Val( aItem[ 12 ] ), ;
            _g_opis( aItem[ 10 ] ), ;
            AllTrim( aItem[ 9 ] ) } )


         // elseif nItemLen == 11

         // AADD(aFin, { cFirma, ;
         // cIdVn, ;
         // __nalbr, ;
         // __nalbr, ;
         // _g_elba_date( aItem[2]), ;
         // _g_konto(aItem[1], aItem[9]), ;
         // _g_partn(aItem[1], aItem[8], aItem[7] ), ;
         // _g_elba_dp( aItem[1] ), ;
         // aItem[10], ;
         // VAL( aItem[11] ), ;
         // _g_opis( aItem[9] ) })



         // naknada - transakcija
      ELSEIF nItemLen == 9

         // matrica je sljedeca
         // aItem
         // ----------------------------------
         // {1} - tip transakcije (+/-)
         // {2} - datum i vrijeme "27.11.2006 15:15:02"
         // {3} - vrsta transakcije  (NR)
         // {4} - broj dokumenta (XXXX)
         // {5} - ???? (0)
         // {6} - primaoc racun  (005914)
         // {7} - opis stavke (obracun naknade za juli)
         // {8} - valuta (KM)
         // {9} - iznos (5)


         AAdd( aFin, { cFirma, ;
            cIdVn, ;
            __nalbr, ;
            __nalbr, ;
            _g_elba_date( aItem[ 2 ] ), ;
            _g_konto( aItem[ 1 ], aItem[ 3 ] ), ;
            _g_partn( aItem[ 1 ], aItem[ 5 ], aItem[ 3 ] ), ;
            _g_elba_dp( aItem[ 1 ] ), ;
            aItem[ 8 ], ;
            Val( aItem[ 9 ] ), ;
            _g_opis( aItem[ 7 ] ), ;
            AllTrim( aItem[ 3 ] ) + " - " + AllTrim( aItem[ 4 ] ) } )

      ELSE

         msgbeep( "nepoznata transakcija#broj elemenata = " + ;
            AllTrim( Str( Len( aItem ) ) ) + " ???#" + ;
            "linija broj: " + AllTrim( Str( nLineNo ) ) )
         msgbeep( cLine )

         RETURN .F.

      ENDIF

   ELSE
      RETURN .F.
   ENDIF

   RETURN .T.



// ----------------------------------------------------
// insert stavke u pripremu
// aItem - matrica sa stavkom
// aHeader - ovo su parametri header izvoda...
// ----------------------------------------------------
STATIC FUNCTION _i_elba_item( aFinItem, cImpView )

   LOCAL cFirma
   LOCAL cIdVn
   LOCAL cBrNal
   LOCAL cOpis
   LOCAL cKtoProt
   LOCAL cDP
   LOCAL cRbr
   LOCAL cKonto
   LOCAL cPartner
   LOCAL cPartRule
   LOCAL nIznos
   LOCAL cPartOpis
   LOCAL nCurr := 1

   // RULES get
   // ----------------------------------------------
   // vraca konto protustavke - maticna banka
   // recimo: 2001
   cKtoProt := PadR( r_get_konto( "PROT_KONTO" ), 7 )


   // items get
   // ----------------------------------------------

   // firma
   cFirma := aFinItem[ nCurr, 1 ]
   // vrsta naloga
   cIdVn := aFinItem[ nCurr, 2 ]
   // brnal
   cBrNal := aFinItem[ nCurr, 3 ]
   // broj veze
   cBrVeze := PadR( aFinItem[ nCurr, 4 ], 10 )
   // datum dokumenta
   dDatDok := aFinItem[ nCurr, 5 ]
   // konto
   cKonto := PadR( aFinItem[ nCurr, 6 ], 7 )
   // partner
   cPartner := PadR( aFinItem[ nCurr, 7 ], 6 )
   // duguje/potrazuje
   cDP := aFinItem[ nCurr, 8 ]
   // valuta
   cValuta := aFinItem[ nCurr, 9 ]
   // iznos dokumenta
   nIznos := aFinItem[ nCurr, 10 ]
   // opis
   cOpis := PadR( aFinItem[ nCurr, 11 ], 40 )
   // opis partnera
   cPartOpis := aFinItem[ nCurr, 12 ]

   // vrati iz RULES partnera prema kontu - ako postoji !!
   // i postavi to kao partnera za ovu stavku

   cPartRule := r_get_kpartn( cKonto )
   IF !Empty( cPartRule ) .AND. AllTrim( cPartRule ) <> "XX"
      cPartner := cPartRule
   ENDIF


   // sredi redni broj stavke
   ++__rbr
   cRbr := Str( __rbr, 4 )

   IF cImpView == "D"

      @ m_x + 6, m_y + 2 SAY Space( 70 )
      @ m_x + 6, m_y + 2 SAY PadR( cPartOpis, 45 ) + " -> partner fmk:" GET cPartner

      @ m_x + 7, m_y + 2 SAY "datum knjizenja:" GET dDatDok
      @ m_x + 7, Col() + 2 SAY "broj veze:" GET cBrVeze
      @ m_x + 8, m_y + 2 SAY "opis knjizenja:" GET cOpis
      @ m_x + 9, m_y + 2 SAY Replicate( "=", 60 )


      @ m_x + 11, m_y + 2 SAY PadR( "rbr.stavke:", 20 ) GET cRbr
      @ m_x + 12, m_y + 2 SAY "dug/pot:" GET cDP
      @ m_x + 12, Col() + 2 SAY "konto:" GET cKonto
      @ m_x + 12, Col() + 2 SAY PadR( "IZNOS STAVKE:", 20, 20 ) GET nIznos PICT "9999999.99"

      IF LastKey() <> K_ESC
         READ
      ENDIF

   ENDIF

   SELECT fin_pripr
   APPEND BLANK

   REPLACE idfirma WITH cFirma
   REPLACE idvn WITH cIdVn
   REPLACE brnal WITH cBrNal
   REPLACE brdok WITH cBrVeze
   REPLACE opis WITH cOpis
   REPLACE rbr WITH cRbr
   REPLACE datdok WITH dDatDok
   REPLACE d_p WITH cDP
   REPLACE idkonto WITH cKonto
   REPLACE idpartner WITH cPartner

   IF cValuta == "KM"
      REPLACE iznosbhd WITH nIznos
   ELSE
      REPLACE iznosdem WITH nIznos
   ENDIF


   // druga stavka naloga, racun vb
   // PROTUSTAVKA....

   IF cDP == "1"
      cDP := "2"
   ELSE
      cDP := "1"
   ENDIF


   // sredi opet redni broj za protustavku
   ++__rbr
   cRbr := Str( __rbr, 4 )


   IF cImpView == "D"

      @ m_x + 13, m_y + 2 SAY Replicate( "-", 60 )
      @ m_x + 14, m_y + 2 SAY PadR( "rbr.protustavke:", 20 ) GET cRbr
      @ m_x + 15, m_y + 2 SAY "dug/pot:" GET cDP
      @ m_x + 15, Col() + 2 SAY "konto:" GET cKtoProt
      @ m_x + 15, Col() + 2 SAY PadR( "IZNOS PROTUSTAVKE:", 20 ) GET nIznos PICT "9999999.99"

      IF LastKey() <> K_ESC
         READ
      ENDIF

   ENDIF

   SELECT fin_pripr
   APPEND BLANK


   REPLACE idfirma WITH cFirma
   REPLACE idvn WITH cIdVn
   REPLACE brnal WITH cBrNal
   REPLACE rbr WITH cRbr
   REPLACE datdok WITH dDatDok
   REPLACE d_p WITH cDP
   REPLACE opis WITH cOpis
   REPLACE brdok WITH cBrVeze
   REPLACE idkonto WITH cKtoProt
   REPLACE idpartner WITH ""

   IF AllTrim( cValuta ) == "KM"
      REPLACE iznosbhd WITH nIznos
   ELSE
      REPLACE iznosdem WITH nIznos
   ENDIF

   RETURN



// ---------------------------------------------
// vraca datum iz elba txt datumskog polja
// ---------------------------------------------
STATIC FUNCTION _g_elba_date( cDate )

   LOCAL dDate

   dDate := CToD( Left( cDate, 10 ) )

   RETURN dDate


// ---------------------------------------------
// vraca D/P za tip transakcije
// ---------------------------------------------
STATIC FUNCTION _g_elba_dp( cTransType )

   LOCAL cRet := "1"

   cTransType := AllTrim( cTransType )
   DO CASE
   CASE cTransType == "-"
      cRet := "1"
   CASE cTransType == "+"
      cRet := "2"
   ENDCASE

   RETURN cRet


// ---------------------------------------------
// vraca D/P za naknade
// ---------------------------------------------
STATIC FUNCTION _g_nakn_dp( cTransType )

   LOCAL cRet := "1"

   cTransType := AllTrim( cTransType )
   DO CASE
   CASE cTransType == "-"
      cRet := "1"
   CASE cTransType == "+"
      cRet := "2"
   ENDCASE

   RETURN cRet


// -----------------------------------------------
// vraca konto po pretpostavci...
// -----------------------------------------------
STATIC FUNCTION _g_konto( cTrans, cOpis )

   LOCAL cKonto := "?????"
   LOCAL cKtoKup := __k_kup

   IF "NR" $ cOpis
      cKonto := r_get_konto( "UPL_KONTO", "NR" )
      RETURN cKonto

   ELSEIF "PRK" $ cOpis
      cKonto := r_get_konto( "UPL_KONTO", "PRK" )
      RETURN cKonto

   ENDIF

   // ako je uplata na nas racun onda je to KUPAC 2120
   IF AllTrim( cTrans ) == "+"
      cKonto := cKtoKup
      RETURN cKonto
   ENDIF

   cOpis := KonvZnWin( cOpis )

   IF AllTrim( cTrans ) == "-"

      DO CASE

      CASE "PROVIZIJA" $ Upper( cOpis )
         cKonto := r_get_konto( "UPL_KONTO", "PROVIZIJA" )

      CASE "PDV" $ cOpis
         cKonto := r_get_konto( "UPL_KONTO", "PDV" )

      OTHERWISE
         cKonto := r_get_konto( "UPL_KONTO" )
      ENDCASE

   ENDIF

   RETURN cKonto

// --------------------------------------------------
// uzmi partnera za stavku
// --------------------------------------------------
STATIC FUNCTION _g_partn( cTrType, cTxt, cTrRN )

   LOCAL nSeek

   cTxt := KonvZnWin( cTxt )


   IF AllTrim( cTrRN ) $ "#PRK#NR#"
      RETURN ""
   ENDIF

   // pokusaj pronaci po matrici
   nSeek := AScan( aPartArr, {| xVal| xVal[ 1 ] == cTxt } )

   IF nSeek <> 0

      // nasao sam ga u matrici
      RETURN aPartArr[ nSeek, 2 ]

   ENDIF

   IF AllTrim( cTrType ) == "+"

      // trazi partnera za uplate na zr
      _g_part_upl( cTxt )

   ELSEIF AllTrim( cTrType ) == "-"

      // trazi partnera za isplate sa zr
      _g_part_isp( cTxt, cTrRN )
   ENDIF

   RETURN


// -----------------------------------------------
// vraca id partnera za uplate na zr
// -----------------------------------------------
STATIC FUNCTION _g_part_upl( cTxt )

   LOCAL nTArea := Select()
   LOCAL cDesc := ""
   LOCAL cBank := ""
   LOCAL cPartnId := "?????"
   LOCAL nSeek

   // uzmi banku i opis ako postoji "/"
   IF Left( cTxt, 1 ) == "/"

      cDesc := AllTrim( SubStr( cTxt, 18, Len( cTxt ) ) )
      cBank := AllTrim( SubStr( cTxt, 2, 16 ) )

   ELSE

      cDesc := AllTrim( cTxt )

   ENDIF

   cDesc := KonvZnWin( cDesc )

   // pokusaj naci po banci...
   cPartnId := _src_p_bank( cBank )

   // ako nema nista, pokusaj po nazivu....
   IF Empty( cPartnId )
      cPartnId := _src_p_desc( cDesc )
   ENDIF

   // ako nema nista... ???
   IF Empty( cPartnId )

      Msgbeep( "Nepostojeci partner !!!#Opis: " + PadR( cTxt, 50 ) + ;
         "" )
      cPartnId := PadR( cDesc, 3 ) + ".."

      // otvori sifranik..
      p_firma( @cPartnId )

      // setuj partneru transakcijski racun
      _set_part_bank( cPartnId, cBank )

   ENDIF


   nSeek := AScan( aPartArr, {| xVal| xVal[ 2 ] == cPartnId } )

   IF nSeek == 0
      AAdd( aPartArr, { cTxt, cPartnId } )
   ENDIF

   SELECT ( nTArea )

   RETURN cPartnId


// -----------------------------------------------
// vraca id partnera za isplate sa zr
// -----------------------------------------------
STATIC FUNCTION _g_part_isp( cTxt, cTrRN )

   LOCAL nTArea := Select()
   LOCAL cDesc := ""
   LOCAL cBank := ""
   LOCAL cPartnId := "?????"
   LOCAL nSeek

   // uzmi banku i opis ako postoji "/"
   IF Left( cTxt, 1 ) == "/"
      cDesc := AllTrim( SubStr( cTxt, 18, Len( cTxt ) ) )
   ELSE
      cDesc := AllTrim( cTxt )
   ENDIF

   cDesc := KonvZnWin( cDesc )


   // pokusaj naci po banci...
   cPartnId := _src_p_bank( cTrRN )

   // ako nema nista, pokusaj po nazivu....
   IF Empty( cPartnId )

      // cPartnId := _src_p_desc( cDesc )

      Msgbeep( "Nepostojeci partner !!!#Opis: " + PadR( cTxt, 50 ) + ;
         "#" + "trans.rn: " + cTrRN )

      cPartnId := PadR( cDesc, 3 ) + ".."

      // otvori sifranik..
      p_firma( @cPartnId )

      // setuj partneru transakcijski racun
      _set_part_bank( cPartnId, cTrRN )

   ENDIF


   nSeek := AScan( aPartArr, {| xVal| xVal[ 2 ] == cPartnId } )

   IF nSeek == 0
      AAdd( aPartArr, { cTxt, cPartnId } )
   ENDIF

   SELECT ( nTArea )

   RETURN cPartnId


// ------------------------------------------------
// setovanje bank racuna za partnera
// ------------------------------------------------
STATIC FUNCTION _set_part_bank( cPartn, cBank )

   LOCAL cRead := ""
   LOCAL nTArea := Select()
   LOCAL cOldBank
   LOCAL cNewBank

   // nema banke, nista...
   IF Empty( cBank )
      SELECT ( nTArea )
      RETURN
   ENDIF

   O_SIFK
   O_SIFV

   cNewBank := ""

   // stara banka
   cOldBank := AllTrim( IzSifKPartn( "BANK", cPartn ) )

   // dodaj staru banku ako postoji
   IF !Empty( cOldBank )
      cNewBank += cOldBank
   ENDIF

   // dodaj i , posto je potrebno
   IF Right( cNewBank, 1 ) <> ","
      cNewBank += ","
   ENDIF

   // dodaj konacno novu banku...
   cNewBank += cBank

   USifK( "PARTN", "BANK", cPartn, Unicode():New( cNewBank, .F. ) )

   SELECT ( nTArea )

   RETURN



// ------------------------------------------------------
// pretraga partnera po nazivu ili dijelu naziva
// ------------------------------------------------------
STATIC FUNCTION _src_p_desc( cDesc )

   LOCAL aTemp
   LOCAL cTemp := ""
   LOCAL cPartner := ""

   IF Empty( cDesc )
      RETURN cPartner
   ENDIF

   aTemp := TokToNiz( cDesc, " " )

   IF Len( aTemp ) > 1

      cTemp := AllTrim( aTemp[ 1 ] )

      IF Len( cTemp ) < 4
         cTemp += " " + AllTrim( aTemp[ 2 ] )
      ENDIF

   ELSE

      cTemp := AllTrim( aTemp[ 1 ] )

   ENDIF

   O_PARTN
   SET ORDER TO TAG "naz"
   GO TOP
   SEEK cTemp

   IF Found()
      cPartner := partn->id
   ENDIF

   RETURN cPartner


// -------------------------------------------
// pretraga po banci - SIFV
// -------------------------------------------
STATIC FUNCTION _src_p_bank( cBank )

   LOCAL cPartner := ""
   LOCAL nTArea := Select()

   IF Empty( cBank )
      RETURN cPartner
   ENDIF

   O_PARTN
   O_SIFV
   SELECT sifv
   SET ORDER TO TAG "NAZ"

   GO TOP

   SEEK PadR( "PARTN", 8 ) + PadR( "BANK", 4 )

   DO WHILE !Eof() .AND. field->id == PadR( "PARTN", 8 ) ;
         .AND. field->oznaka == PadR( "BANK", 4 )


      // ako trazena banka postoji vec u bankama...
      IF ( cBank $ field->naz )

         cPartner := PadR( AllTrim( sifv->idsif ), 6 )

         // sada pogledaj da li taj partner postoji uopste
         SELECT partn
         GO TOP
         SEEK cPartner

         IF Found() .AND. field->id == cPartner
            EXIT
         ENDIF

      ENDIF

      cPartner := ""

      // idi dalje i vidi ima li koga...
      SELECT sifv

      SKIP

   ENDDO

   RETURN cPartner



// ----------------------------------------------
// vraca opis ...
// ----------------------------------------------
STATIC FUNCTION _g_opis( cOpis )

   LOCAL cRet := ""
   LOCAL aTemp

   aTemp := TokToNiz( cOpis, "/" )

   cRet := AllTrim( aTemp[ 1 ] )

   cRet := KonvZnWin( cRet )

   RETURN PadR( cRet, 40 )


// -------------------------------------------------
// vraca broj veze...
// -------------------------------------------------
STATIC FUNCTION _g_br_veze( cTrans, dDatum, cOpis )

   LOCAL cRet := ""

   DO CASE
   CASE "PDV" $ cOpis
      cRet := "pdv " + PadL( AllTrim( Str( Month( dDatum ) - 1 ) ), 2, "0" )
   ENDCASE

   RETURN cRet
