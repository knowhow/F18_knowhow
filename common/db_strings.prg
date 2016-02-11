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


// otvaranje sifrarnika strings
FUNCTION p_strings( cId, dx, dy )

   LOCAL nTArea := Select()
   PRIVATE ImeKol
   PRIVATE Kol

   IF !SigmaSIF( "STRING" )
      MsgBeep( "Opcija nedostupna !!!" )
      RETURN
   ENDIF

   O_STRINGS
   set_a_kol( @ImeKol, @Kol )

   SELECT ( nTArea )

   RETURN PostojiSifra( F_STRINGS, "1", 10, 65, "Strings", @cId, dx, dy, {| Ch| key_handler( Ch ) } )


// setovanje kolona tabele
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   aImeKol := {}
   aKol := {}

   AAdd( aImeKol, { PadC( "ID", 10 ), {|| id }, "id", {|| inc_id( @wId ), .F. }, {|| .T. } } )
   AAdd( aImeKol, { PadC( "Veza 1", 10 ), {|| veza_1 }, "veza_1", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { PadC( "Veza 2", 10 ), {|| veza_2 }, "veza_2", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { PadC( "Oznaka", 10 ), {|| oznaka }, "oznaka", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { PadC( "Aktivan", 7 ), {|| aktivan }, "aktivan", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { PadC( "Naziv", 20 ), {|| PadR( naz, 20 ) }, "naz", {|| .T. }, {|| .T. } } )
   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN


// key handler
STATIC FUNCTION key_handler()
   RETURN DE_CONT


// uvecaj ID
STATIC FUNCTION inc_id( wId )

   LOCAL lRet := .T.

   IF ( ( Ch == K_CTRL_N ) .OR. ( Ch == K_F4 ) )
      IF ( LastKey() == K_ESC )
         RETURN lRet := .F.
      ENDIF

      nRecNo := RecNo()

      str_new_id( @wId )

      AEval( GetList, {| o| o:display() } )
   ENDIF

   RETURN lRet

// da li je definisana opcija strings
FUNCTION is_strings()

   LOCAL nTArea := Select()
   LOCAL lRet := .F.

   O_ROBA
   IF roba->( FieldPos( "STRINGS" ) ) <> 0
      lRet := .T.
   ENDIF
   SELECT ( nTArea )

   RETURN lRet


// provjerava da li roba ima definisan string
FUNCTION is_roba_strings( cIDRoba )

   LOCAL lRet := .F.
   LOCAL nTArea := Select()

   O_ROBA
   SET ORDER TO TAG "ID"
   GO TOP
   SEEK cIdRoba
   IF Found() .AND. field->strings <> 0
      lRet := .T.
   ENDIF
   SELECT ( nTArea )

   RETURN lRet


// uporedi nizove...
STATIC FUNCTION arr_integ_ok( aModArr, aDefArr )

   LOCAL lRet := .F.

   RETURN lRet

// *******************************************
// GET funkcije.....
// *******************************************


// vraca naziv odabrane grupe...
FUNCTION g_roba_grupe( cGrupa )

   LOCAL nSelection := 0
   LOCAL aGrupe := {}

   aGrupe := get_strings( "R_GRUPE", .T. )

   // otvori meni i vrati odabir
   nSelection := arr_menu( aGrupe, "R_GRUPE" )

   cGrupa := g_naz_byid( nSelection )

   RETURN .T.


// vraca polje strings->naz po id pretrazi
STATIC FUNCTION g_naz_byid( nId )

   LOCAL cNaz := ""

   SELECT strings
   SET ORDER TO TAG "1"
   HSEEK Str( nId, 10, 0 )

   IF Found()
      cNaz := Trim( field->naz )
   ENDIF

   RETURN cNaz


// vraca strings->id za grupu iz stringa...
STATIC FUNCTION g_gr_byid( nId )

   LOCAL nVeza_1
   LOCAL nGrupa := 0

   SELECT strings
   SET ORDER TO TAG "1"
   HSEEK Str( nId, 10, 0 )

   IF Found()
      nVeza_1 := field->veza_1

      // sada trazi grupe - atribute
      HSEEK Str( nVeza_1, 10, 0 )

      IF Found()
         // dobio sam grupu
         nGrupa := field->veza_1
      ENDIF
   ENDIF

   RETURN nGrupa


// vraca oznaku atributa iz id-a
STATIC FUNCTION g_attr_byid( nId )

   LOCAL nVeza_1
   LOCAL nVeza_2
   LOCAL nAtribut := 0

   SELECT strings
   SET ORDER TO TAG "1"
   HSEEK Str( nId, 10, 0 )

   IF Found()
      nVeza_1 := field->veza_1

      // sada trazi grupe - atribute
      HSEEK Str( nVeza_1, 10, 0 )

      IF Found()
         // dobio sam atribut
         nAtribut := field->veza_2
      ENDIF
   ENDIF

   RETURN nAtribut


// vraca oznaku atributa-veze iz id-a
STATIC FUNCTION g_attv_byid( nId )

   LOCAL nAtribut := 0

   SELECT strings
   SET ORDER TO TAG "1"
   HSEEK Str( nId, 10, 0 )

   IF Found()
      nAtribut := field->veza_1
   ENDIF

   RETURN nAtribut


// vraca matricu sa nazivima po uslovu "cOznaka"
FUNCTION get_strings( cOznaka, lAktivni )

   LOCAL nTRec := RecNo()
   LOCAL nTArea := Select()
   LOCAL aRet := {}

   IF lAktivni == nil
      lAktivni := .T.
   ENDIF

   O_STRINGS
   SELECT strings
   // oznaka + id
   SET ORDER TO TAG "2"
   GO TOP
   SEEK PadR( cOznaka, 10 )

   DO WHILE !Eof() .AND. field->oznaka == PadR( cOznaka, 10 )

      IF lAktivni
         // dodaj samo aktivne
         IF field->aktivan <> "D"
            SKIP
            LOOP
         ENDIF
      ENDIF

      AAdd( aRet, { field->id, Trim( field->naz ) } )

      SKIP
   ENDDO

   SELECT ( nTArea )
   GO ( nTRec )

   RETURN aRet



// vraca matricu sa stringovima po uslovu "nIdString"
FUNCTION get_str_val( nIdString )

   LOCAL nTRec := RecNo()
   LOCAL nTArea := Select()
   LOCAL aRet := {}
   LOCAL aTemp := {}
   LOCAL cStrings := ""
   LOCAL aStrings := {}
   LOCAL i
   LOCAL nIdStr
   LOCAL nIdAttr

   O_STRINGS
   SELECT strings
   // id
   SET ORDER TO TAG "1"
   GO TOP
   SEEK Str( nIdString, 10, 0 )

   IF Found()
      IF field->aktivan == "D" .AND. field->veza_1 == -1
         cStrings := Trim( field->naz )
      ENDIF
   ELSE
      fill_strings( @aRet )
      RETURN aRet
   ENDIF

   IF !Empty( AllTrim( cStrings ) )

      // sada kada sam dobio strings napuni matricu aRet
      aStrings := TokToNiz( cStrings, "#" )
      // 15#16

      IF Len( aStrings ) > 0

         nIdStr := Val( aStrings[ 1 ] )

         // prvo dodaj grupu ....
         nIdAttr := g_gr_byid( nIdStr )

         // naziv grupe
         cPom := g_naz_byid( nIdAttr )

         // filuj grupu i dostupne atribute....
         fill_str_attr( @aRet, nIdAttr, cPom )

         // sada napuni atribute ...

         // 15#16...
         FOR i := 1 TO Len( aStrings )

            nIdStr := Val( aStrings[ i ] )
            nIdAttr := g_attr_byid( nIdStr )
            nIdAttV := g_attv_byid( nIdStr )

            nScan := AScan( aRet, {| xVal| xVal[ 2 ] == nIdAttV } )

            IF nScan == 0
               AAdd( aRet, { nIdStr, nIdAttV, "R_G_ATTRIB", g_naz_byid( nIdAttr ) + ":", g_naz_byid( nIdStr ) } )
            ELSE
               aRet[ nScan, 1 ] := nIdStr
               aRet[ nScan, 2 ] := nIdAttV
               aRet[ nScan, 3 ] := "R_G_ATTRIB"

               cPom := g_naz_byid( nIdAttr ) + ":"

               aRet[ nScan, 4 ] := cPom

               cPom := g_naz_byid( nIdStr )

               aRet[ nScan, 5 ] := cPom
            ENDIF
         NEXT
      ENDIF
   ELSE
      fill_strings( @aRet )
   ENDIF

   SELECT ( nTArea )
   GO ( nTRec )

   RETURN aRet



// **********************************************
// FILL funkcije
// **********************************************

// filuj prazan aStrings
STATIC FUNCTION fill_strings( aStrings )

   AAdd( aStrings, { 0, 0, "R_GRUPE", "Grupa:", "-" } )

   RETURN

// filuj prazan aArr
STATIC FUNCTION fill_arr( aArr )

   AAdd( aArr, { 0, "-" } )

   RETURN


// napuni matricu sa atributima...
STATIC FUNCTION fill_str_attr( aStrings, nIdGrupa, cNazGrupa )

   LOCAL cGrOzn := PadR( "R_GRUPE", 10 )
   LOCAL cAtOzn := PadR( "R_G_ATTRIB", 10 )
   LOCAL i
   LOCAL nTArea := Select()

   // ponovo napravi aStrings
   aStrings := {}
   AAdd( aStrings, { nIdGrupa, nIdGrupa, cGrOzn, "Grupa:", cNazGrupa } )

   O_STRINGS
   SELECT strings
   // oznaka + veza_1
   SET ORDER TO TAG "3"
   SEEK cAtOzn + Str( nIdGrupa, 10, 0 )

   IF Found()
      DO WHILE !Eof() .AND. field->oznaka == cAtOzn;
            .AND. field->veza_1 == nIdGrupa

         IF field->aktivan <> "D"
            SKIP
            LOOP
         ENDIF

         AAdd( aStrings, { 0, field->id, cAtOzn, Trim( field->naz ) + ":", "-" } )

         SKIP
      ENDDO
   ENDIF

   SELECT ( nTArea )

   RETURN



// **********************************************
// MENI funkcije
// **********************************************

// glavni meni strings
FUNCTION m_strings( nIdString, cRoba )

   LOCAL aStrings := {}
   LOCAL aMStrings := {}
   LOCAL nRet := -99

   // aStrings { idstr, idatr, oznaka, naz_atributa, vrijednost }
   // 9  ,  6   , "R_G_ATTRIB", "proizvodjac", "proizvodjac 1"

   IF ( nIdString == 0 )
      // ako je strings == 0 napravi praznu matricu...
      fill_strings( @aStrings )
   ELSE
      // generisi matricu na osnovu podataka...
      aStrings := get_str_val( nIdString )
   ENDIF

   // uzmi za usporedbu matricu strings
   aMStrings := aStrings

   // non stop do izlaska regenerisi meni
   DO WHILE .T.
      IF gen_m_str( @aStrings ) == 0

         IF !arr_integ_ok( aStrings, aMStrings ) .AND. Pitanje(, "Snimiti promjene?", "D" ) == "D"
            // snimi promjene napravljene na nizu
            save_str_state( aStrings, cRoba )
         ENDIF

         EXIT
      ENDIF
   ENDDO

   RETURN


// generisi menij sa aStrings
FUNCTION gen_m_str( aStrings )

   LOCAL cPom
   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   FOR i := 1 TO Len( aStrings )

      cPom := PadL( aStrings[ i, 4 ], 20 )
      cPom += " "
      IF aStrings[ i, 5 ] == "-"
         cPom += PadR( "nije setovano", 30 )
      ELSE
         cPom += PadR( aStrings[ i, 5 ], 30 )
      ENDIF

      AAdd( opc, cPom )
      AAdd( opcexe, {|| key_strings( @aStrings, izbor ), izbor := 0 } )

   NEXT

   Menu_SC( "str" )

   ESC_RETURN 0

   // test - debug / print matrice
   // pr_strings(aStrings)

   RETURN 1


// obrada dogadjaja menija strings na ENTER
STATIC FUNCTION key_strings( aStrings, nIzbor )

   LOCAL cOznaka
   LOCAL nTIzbor
   LOCAL cAkcija

   // 10001
   nTIzbor := nIzbor

   // "" - enter
   // "K_CTRL_N" - novi
   // "K_CTRL_T" - brisi ...
   cAkcija := what_action( nTIzbor )

   // 1
   nIzbor := retitem( nIzbor )

   cOznaka := aStrings[ nIzbor, 3 ]

   DO CASE
      // ako su grupe....
   CASE AllTrim( cOznaka ) == "R_GRUPE"

      // enter
      IF cAkcija == ""
         // definisi grupu
         def_group( @aStrings, nIzbor )
      ELSE
         // ostale tipke....
         // definisi attribute - veze
         def_attveze( @aStrings, nIzbor, cAkcija )
      ENDIF

      // ako su atributi veze
   CASE AllTrim( cOznaka ) == "R_G_ATTRIB"

      IF cAkcija == ""
         // odabir atributa....
         def_attrib( @aStrings, nIzbor )
      ELSE
         // ostale tipke....
         // definisi attribute - veze
         def_attveze( @aStrings, nIzbor, cAkcija )
      ENDIF

   ENDCASE

   RETURN


// funkcij za iscrtavanje menija sa nizom aArr te citanjem odabira
STATIC FUNCTION arr_menu( aArr, cGrupa, nGrId )

   LOCAL i
   LOCAL cPom
   LOCAL nArrRet := 0
   LOCAL nReturn := -99
   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   IF Len( aArr ) == 0
      fill_arr( @aArr )
   ENDIF

   FOR i := 1 TO Len( aArr )
      IF ( aArr[ i, 2 ] == "-" )
         cPom := PadR( "nema setovanih stavki", 30 )
      ELSE
         cPom := PadR( aArr[ i, 2 ], 30 )
      ENDIF
      AAdd( opc, cPom )
      AAdd( opcexe, {|| key_array( @nArrRet, aArr, izbor, cGrupa, nGrId ), izbor := 0 } )
   NEXT

   Menu_SC( "arr" )

   IF nArrRet > 0
      nReturn := aArr[ nArrRet, 1 ]
   ENDIF

   IF nArrRet == 0
      nReturn := 0
   ENDIF

   RETURN nReturn


// obrada dogadjaja tipke na array menu
STATIC FUNCTION key_array( nArrRet, aArr, nIzbor, cGrupa, nGrId )

   LOCAL nTIzbor := nIzbor
   LOCAL cAction

   nIzbor := retitem( nTIzbor )
   cAction := what_action( nTIzbor )

   IF nGrId == nil
      nGrId := aArr[ nIzbor, 1 ]
   ENDIF

   DO CASE
   CASE cAction == "K_CTRL_N"
      add_s_item( aArr, cGrupa, nGrId, nIzbor )
      nArrRet := -99

   CASE cAction == "K_F2"
      edit_s_item( aArr, cGrupa, nGrId, nIzbor )
      nArrRet := -99
   CASE cAction == "K_CTRL_T"
      del_s_item( aArr, cGrupa, nGrId, nIzbor )
      nArrRet := -99
   OTHERWISE
      nArrRet := nIzbor
   ENDCASE

   RETURN


// dodaje novi zapis u strings
STATIC FUNCTION add_s_item( aArr, cGrupa, nGrId, nIzbor, nVeza_1 )

   LOCAL cItNaz := Space( 200 )
   LOCAL nNStr1 := 0
   LOCAL nNStr2 := 0
   LOCAL nTArea := Select()
   PRIVATE getlist := {}

   Box(, 1, 60 )
   @ m_x + 1, m_y + 2 SAY "Naziv:" GET cItNaz PICT "@S40"
   READ
   BoxC()

   IF Pitanje(, "Dodati novu stavku (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   O_STRINGS

   // daj novi id
   str_new_id( @nNStr1 )

   SELECT strings
   APPEND BLANK
   REPLACE id WITH nNStr1
   REPLACE oznaka WITH cGrupa
   REPLACE aktivan WITH "D"
   REPLACE naz WITH cItNaz

   // ako nisu grupe.... dodaj odmah veze atributa
   IF cGrupa <> "R_GRUPE"
      add_att_veza( nGrId, nNStr1, cItNaz )
   ENDIF

   SELECT ( nTArea )

   RETURN


// dodaje attribute - veze...
STATIC FUNCTION add_att_veza( nVeza_1, nVeza_2, cNaz )

   LOCAL nNewId
   LOCAL nTArea := Select()
   LOCAL nRet := 0

   O_STRINGS
   SELECT strings
   SET ORDER TO TAG "5"
   GO TOP
   SEEK PadR( "R_G_ATTRIB", 10 ) + Str( nVeza_1, 10, 0 ) + Str( nVeza_2, 10, 0 )

   IF Found() .AND. field->aktivan == "D"

      // vec postoji ova veza...
      nRet := field->id

      RETURN nRet
   ENDIF

   // daj novi id
   str_new_id( @nNewId )

   SELECT strings
   APPEND BLANK
   REPLACE id WITH nNewId
   REPLACE veza_1 WITH nVeza_1
   REPLACE veza_2 WITH nVeza_2
   REPLACE oznaka WITH "R_G_ATTRIB"
   REPLACE aktivan WITH "D"
   REPLACE naz WITH cNaz

   SELECT ( nTArea )

   nRet := nNewId

   RETURN nRet


// ispravka zapisa u strings
STATIC FUNCTION edit_s_item( aArr, cGrupa, nGrId, nIzbor, nVeza_1 )

   LOCAL cItNaz := Space( 200 )
   LOCAL nTArea := Select()
   LOCAL nStrId := aArr[ nIzbor, 1 ]
   LOCAL cVal
   PRIVATE getlist := {}

   IF Pitanje(, "Ispraviti stavku (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   O_STRINGS
   SELECT strings
   SET ORDER TO TAG "1"
   GO TOP
   SEEK Str( nStrId, 10, 0 )

   IF Found()
      Scatter()
      Box(, 1, 60 )
      @ m_x + 1, m_y + 2 SAY "Naziv:" GET _naz PICT "@S40"
      READ
      BoxC()
      Gather()
   ENDIF

   SELECT ( nTArea )

   RETURN


// brisanje zapisa u strings
STATIC FUNCTION del_s_item( aArr, cGrupa, nGrId, nIzbor, nVeza_1 )

   LOCAL nNStrId := 0
   LOCAL nTArea := Select()
   LOCAL nStrId := aArr[ nIzbor, 1 ]

   IF Pitanje(, "Izbrisati stavku (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   O_STRINGS
   SELECT strings
   SET ORDER TO TAG "1"
   GO TOP
   SEEK Str( nStrId, 10, 0 )

   IF Found()
      Scatter()
      _aktivan := "N"
      Gather()
   ENDIF

   SELECT ( nTArea )

   RETURN


// ********************************************
// DEF funkcije....
// ********************************************


// definisanje grupe
STATIC FUNCTION def_group( aStrings, nIzbor )

   LOCAL aGrupe := {}
   LOCAL nSelection
   LOCAL cPom := ""

   nSelection := aStrings[ nIzbor, 2 ]

   // otvori meni sa dostupnim grupama...
   IF ( nSelection == 0 ) .OR. ( nSelection <> 0 .AND. Pitanje(, "Promjeniti grupu artikla ?", "D" ) == "D" )

      nSelection := -99

      DO WHILE nSelection == -99
         // generisi matricu sa grupama... (aktivnim)
         aGrupe := get_strings( "R_GRUPE", .T. )

         // otvori meni i vrati odabir
         nSelection := arr_menu( aGrupe, "R_GRUPE" )

         IF nSelection == 0
            RETURN
         ENDIF

      ENDDO

      // uzmi naziv grupe
      cPom := g_naz_byid( nSelection )

      // regenerisi niz aStrings sa pripadajucim atributima
      // grupa + atributi
      fill_str_attr( @aStrings, nSelection, cPom )

   ENDIF

   RETURN


// definisanje grupe
STATIC FUNCTION def_attveze( aStrings, nIzbor, cAkcija )

   LOCAL nAttrib := {}
   LOCAL nSelection := -99

   // id grupe
   LOCAL nIdGrupa := aStrings[ 1, 2 ]
   LOCAL cAttNaz := ""
   LOCAL nScan

   DO WHILE nSelection == -99

      // izvuci u matricu sve atribute...
      nAttrib := get_strings( "R_D_ATTRIB", .T. )

      nSelection := arr_menu( @nAttrib, "R_D_ATTRIB", nIdGrupa )

      IF nSelection == 0
         RETURN
      ENDIF

      IF nSelection > 1
         // ako je nesto odabrano onda dodaj vezu sa grupom
         cAttNaz := g_naz_byid( nSelection )
         nAttVeza := add_att_veza( nIdGrupa, nSelection, cAttNaz )

         nScan := AScan( aStrings, {| xVal| xVal[ 2 ] == nAttVeza } )

         // napuni matricu sa atributima... ako ne postoji...
         IF nScan == 0
            AAdd( aStrings, { 0, nAttVeza, PadR( "R_G_ATTRIB", 10 ), AllTrim( cAttNaz ) + ":", "-" } )
         ENDIF
      ENDIF
   ENDDO

   RETURN



// definisanje atributa...
STATIC FUNCTION def_attrib( aStrings, nIzbor )

   LOCAL cAttrVal
   LOCAL nDozId := aStrings[ nIzbor, 2 ]
   LOCAL nAttrId

   cAttrVal := Space( 200 )

   Box(, 1, 60 )
   @ m_x + 1, m_y + 2 SAY "Unesi/trazi vrijednost:" GET cAttrVal PICT "@S30" VALID find_attr( @cAttrVal, nDozId, @nAttrId )
   READ
   BoxC()

   IF LastKey() == K_ESC
      cAttrVal := ""
      RETURN
   ENDIF

   // napuni matricu sa trazenim pojmom

   aStrings[ nIzbor, 1 ] := nAttrId
   aStrings[ nIzbor, 5 ] := cAttrVal

   RETURN


// ******************************************
// DB funkcije ...
// ******************************************

// dodaje u strings dozvoljenu vrijednost atributa
STATIC FUNCTION add_atr_doz( cVal, nVeza_1 )

   LOCAL nRet := 0
   LOCAL nNewId := 0
   LOCAL nTArea := Select()
   LOCAL cIme

   O_STRINGS
   SELECT strings
   SET ORDER TO TAG "1"

   str_new_id( @nNewId )

   APPEND BLANK
   REPLACE id WITH nNewId
   REPLACE oznaka WITH PadR( "ATTRIB_DOZ", 10 )
   REPLACE veza_1 WITH nVeza_1
   REPLACE naz WITH cVal
   REPLACE aktivan WITH "D"

   SELECT ( nTArea )

   RETURN nNewId


// pronadji dozvoljenu vrijednost...
STATIC FUNCTION find_attr( cAttr, nDozId, nAttrId )

   LOCAL aAttrVal := {}
   LOCAL nTArea := Select()
   LOCAL cOznaka := PadR( "ATTRIB_DOZ", 10 )
   LOCAL cSeek

   O_STRINGS
   SELECT strings
   SET ORDER TO TAG "4"
   GO TOP

   cSeek := cOznaka + Str( nDozId, 10, 0 )
   IF !Empty( cAttr )
      cSeek += AllTrim( cAttr )
   ENDIF

   SEEK cSeek

   IF Found()
      // nafiluj matricu dostupnih vrijednosti....
      DO WHILE !Eof() .AND. field->oznaka == cOznaka ;
            .AND. field->veza_1 == nDozId

         IF field->aktivan <> "D"
            SKIP
            LOOP
         ENDIF

         // pregledaj i po nazivu
         IF !Empty( AllTrim( cAttr ) )
            IF AllTrim( Upper( field->naz ) ) = AllTrim( Upper( cAttr ) )
               //
            ELSE
               SKIP
               LOOP
            ENDIF
         ENDIF

         AAdd( aAttrVal, { field->id, Trim( field->naz ) } )

         SKIP
      ENDDO

      IF Len( aAttrVal ) > 0

         // otvori meni sa dozvoljenim vrijednostima
         nAttrId := arr_menu( aAttrVal )

         // vrijednost atributa
         cAttr := g_naz_byid( nAttrId )

         RETURN .T.
      ENDIF
   ENDIF

   // trazeni pojam ne postoji - dodaj ga!
   MsgBeep( "Trazeni pojam ne postoji!" )

   IF Pitanje(, "Dodati novi pojam ? ", "N" ) == "D"
      PRIVATE getlist := {}
      // dodaj novi pojam....
      Box(, 4, 60 )
      cAttr := Space( 200 )
      @ m_x + 1, m_y + 2 SAY "Unos novog pojma..."
      @ m_x + 3, m_y + 2 SAY "pojam->" GET cAttr PICT "@S40"
      READ
      BoxC()

      // dodaj novi pojam...
      nAttrId := add_atr_doz( cAttr, nDozId )
      cAttr := g_naz_byid( nAttrId )
   ENDIF

   RETURN .T.


// snimi promjene u polje roba->strings
STATIC FUNCTION save_str_state( aStrings, cRoba )

   LOCAL cStr := ""
   LOCAL nNewId := 0
   LOCAL nStrNId := 0

   // preskacem prvi jer je to grupa
   FOR i := 2 TO Len( aStrings )
      IF aStrings[ i, 1 ] <> 0
         cStr += AllTrim( Str( aStrings[ i, 1 ] ) ) + "#"
      ENDIF
   NEXT

   cStr := Left( cStr, Len( cStr ) - 1 )

   str_new_id( @nNewId )

   O_STRINGS
   SET ORDER TO TAG "2"
   SEEK cRoba

   IF !Found()
      APPEND BLANK
      REPLACE id WITH nNewId
      REPLACE veza_1 WITH -1
      REPLACE oznaka WITH cRoba
      REPLACE aktivan WITH "D"
   ENDIF

   REPLACE naz WITH cStr
   nStrNId := strings->id

   SELECT roba
   Scatter()
   _strings := nStrNId
   Gather()

   RETURN


// novi id za tabelu strings
FUNCTION str_new_id( nId )

   LOCAL nTArea := Select()
   LOCAL nTRec := RecNo()
   LOCAL nNewId := 0

   SELECT strings
   SET ORDER TO TAG "1"
   GO BOTTOM

   nNewId := field->id + 1

   SELECT ( nTArea )
   GO ( nTRec )

   nId := nNewId

   RETURN .T.


STATIC FUNCTION pr_strings( aStrings )

   LOCAL i

   START PRINT CRET

   FOR i := 1 TO Len( aStrings )

      ? aStrings[ i, 1 ], aStrings[ i, 2 ], aStrings[ i, 3 ], aStrings[ i, 4 ], aStrings[ i, 5 ]

   NEXT

   ENDPRINT
   FF

   RETURN
