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


// -----------------------------------------------
// otvaranje tabele fakt_objekti
// -----------------------------------------------
FUNCTION p_fakt_objekti( cId, dx, dy )

   LOCAL _t_area := Select()
   PRIVATE ImeKol
   PRIVATE Kol

   ImeKol := {}
   Kol := {}

   O_FAKT_OBJEKTI

   AAdd( ImeKol, { PadC( "Id", 10 ), {|| id }, "id", {|| .T. }, {|| vpsifra( wId ) } } )
   AAdd( ImeKol, { PadC( "Naziv", 60 ), {|| naz }, "naz" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   SELECT ( _t_area )

   RETURN PostojiSifra( F_FAKT_OBJEKTI, 1, MAXROWS() - 15, MAXCOLS() - 20,"Lista objekata", @cId, dx, dy )




/*! \fn RobaBlok(Ch)
 *  \brief
 *  \param Ch
 */

FUNCTION FaRobaBlock( Ch )

   LOCAL cSif := ROBA->id, cSif2 := ""
   LOCAL nArr := Select()

   IF Upper( Chr( Ch ) ) == "K"
      RETURN 6

   ELSEIF Upper( Chr( Ch ) ) == "D"
      // prikaz detalja sifre
      roba_opis_edit( .T. )
      RETURN 6

   ELSEIF Upper( Chr( Ch ) ) == "S"
      TB:Stabilize()
      PushWA()
      FaktStanje( roba->id )
      PopWa()
      RETURN 6

   ELSEIF Upper( Chr( ch ) ) == "P"

      IF gen_all_plu()
         RETURN DE_REFRESH
      ENDIF

   ELSEIF Ch == K_CTRL_T .AND. gSKSif == "D"
      // provjerimo da li je sifra dupla
      PushWA()
      SET ORDER TO TAG "ID"
      SEEK cSif
      SKIP 1
      cSif2 := ROBA->id
      PopWA()
      IF !( cSif == cSif2 )
         // ako nije dupla provjerimo da li postoji u kumulativu
         IF ima_u_fakt_kumulativ( cSif, "3" )
            Beep( 1 )
            Msg( "Stavka artikla/robe se ne moze brisati jer se vec nalazi u dokumentima!" )
            RETURN 7
         ENDIF
      ENDIF

   ELSEIF Ch == K_F2 .AND. gSKSif == "D"
      IF ima_u_fakt_kumulativ( cSif, "3" )
         RETURN 99
      ENDIF

   ELSE // nista od magicnih tipki
      RETURN DE_CONT
   ENDIF

   RETURN DE_CONT



/*! \fn FaktStanje(cIdRoba)
 *  \brief Stanje robe fakt-a
 *  \param cIdRoba
 */

FUNCTION FaktStanje( cIdRoba )

   LOCAL nUl, nIzl, nRezerv, nRevers, fOtv := .F., nIOrd, nFRec, aStanje

   SELECT roba
   SELECT ( F_FAKT )
   IF !Used()
      O_FAKT; fOtv := .T.
   ELSE
      nIOrd := IndexOrd()
      nFRec := RecNo()
   ENDIF
   // "3","Idroba+dtos(datDok)","FAKT")  // za karticu, specifikaciju
   SET ORDER TO TAG "3"
   SEEK cIdRoba

   aStanje := {}
   // {idfirma, nUl,nIzl,nRevers,nRezerv }
   nUl := nIzl := nRezerv := nRevers := 0
   DO WHILE !Eof()  .AND. cIdRoba == IdRoba
      nPos := AScan ( aStanje, {| x| x[ 1 ] == FAKT->IdFirma } )
      IF nPos == 0
         AAdd ( aStanje, { IdFirma, 0, 0, 0, 0 } )
         nPos := Len ( aStanje )
      ENDIF
      IF idtipdok = "0"  // ulaz
         aStanje[ nPos ][ 2 ] += kolicina
      ELSEIF idtipdok = "1"   // izlaz faktura
         IF !( Left( serbr, 1 ) == "*" .AND. idtipdok == "10" )  // za fakture na osnovu optpremince ne ra~unaj izlaz
            aStanje[ nPos ][ 3 ] += kolicina
         ENDIF
      ELSEIF idtipdok $ "20#27"
         IF serbr = "*"
            aStanje[ nPos ][ 5 ] += kolicina
         ENDIF
      ELSEIF idtipdok == "21"
         aStanje[ nPos ][ 4 ] += kolicina
      ENDIF
      SKIP
   ENDDO

   IF fotv
      SELEC fakt; USE
   ELSE
      // set order to (nIOrd)
      dbSetOrder( nIOrd )
      GO nFRec
   ENDIF
   SELECT roba
   fakt_box_stanje( aStanje, cIdRoba )      // nUl,nIzl,nRevers,nRezerv)

   RETURN



/*! \fn fakt_box_stanje(aStanje,cIdRoba)
 *  \brief
 *  \param aStanje
 *  \param cIdRoba
 */

FUNCTION fakt_box_stanje( aStanje, cIdroba )

   LOCAL picdem := "9999999.999", nR, nC, nTSta := 0, nTRev := 0, nTRez := 0, ;
      nTOst := 0, npd, cDiv := " ³ ", nLen

   npd := Len ( picdem )
   nLen := Len ( aStanje )

   // ucitajmo dodatne parametre stanja iz FMK.INI u aDodPar

   aDodPar := {}
   FOR i := 1 TO 6
      cI := AllTrim( Str( i ) )
      cPomZ := my_get_from_ini( "BoxStanje", "ZaglavljeStanje" + cI, "", KUMPATH )
      cPomF := my_get_from_ini( "BoxStanje", "FormulaStanje" + cI, "", KUMPATH )
      IF !Empty( cPomF )
         AAdd( aDodPar, { cPomZ, cPomF } )
      ENDIF
   NEXT
   nLenDP := IF( Len( aDodPar ) > 0, Len( aDodPar ) + 1, 0 )

   SELECT roba
   // PushWA()
   SET ORDER TO TAG "ID"; SEEK cIdRoba
   Box(, 6 + nLen + Int( ( nLenDP ) / 2 ), 75 )
   Beep( 1 )
   @ m_x + 1, m_y + 2 SAY "ARTIKAL: "
   @ m_x + 1, Col() SAY PadR( AllTrim( cIdRoba ) + " - " + Left( roba->naz, 40 ), 51 ) COLOR "GR+/B"
   @ m_x + 3, m_y + 2 SAY cDiv + "RJ" + cDiv + PadC ( "Stanje", npd ) + cDiv + ;
      PadC ( "Na reversu", npd ) + cDiv + ;
      PadC ( "Rezervisano", npd ) + cDiv + PadC ( "Ostalo", npd ) ;
      + cDiv
   nR := m_x + 4
   FOR nC := 1 TO nLen
      // {idfirma, nUl,nIzl,nRevers,nRezerv }
      @ nR, m_y + 2 SAY cDiv
      @ nR, Col() SAY aStanje[nC ][ 1 ]
      @ nR, Col() SAY cDiv
      nPom := aStanje[nC ][ 2 ] -aStanje[nC ][ 3 ]
      @ nR, Col() SAY nPom PICT picdem
      @ nR, Col() SAY cDiv
      nTSta += nPom
      @ nR, Col() SAY aStanje[nC ][ 4 ] PICT picdem
      @ nR, Col() SAY cDiv
      nTRev += aStanje[nC ][ 4 ]
      nPom -= aStanje[nC ][ 4 ]
      @ nR, Col() SAY aStanje[nC ][ 5 ] PICT picdem
      @ nR, Col() SAY cDiv
      nTRez += aStanje[nC ][ 5 ]
      nPom -= aStanje[nC ][ 5 ]
      @ nR, Col() SAY nPom PICT picdem
      @ nR, Col() SAY cDiv
      nTOst += nPom
      nR ++
   NEXT
   @ nR, m_y + 2 SAY cDiv + "--" + cDiv + REPL ( "-", npd ) + cDiv + ;
      REPL ( "-", npd ) + cDiv + ;
      REPL ( "-", npd ) + cDiv + REPL ( "-", npd ) + cDiv
   nR ++
   @ nR, m_y + 2 SAY " ³ UK.³ "
   @ nR, Col() SAY nTSta PICT picdem
   @ nR, Col() SAY cDiv
   @ nR, Col() SAY nTRev PICT picdem
   @ nR, Col() SAY cDiv
   @ nR, Col() SAY nTRez PICT picdem
   @ nR, Col() SAY cDiv
   @ nR, Col() SAY nTOst PICT picdem
   @ nR, Col() SAY cDiv

   // ispis dodatnih parametara stanja

   IF nLenDP > 0
      ++nR
      @ nR, m_y + 2 SAY REPL( "-", 74 )
      FOR i := 1 TO nLenDP - 1

         cPom777 := aDodPar[ i, 2 ]

         IF "TARIFA->" $ Upper( cPom777 )
            SELECT ( F_TARIFA )
            IF !Used(); O_TARIFA; ENDIF
            SET ORDER TO TAG "ID"
            HSEEK ROBA->idtarifa
            SELECT ROBA
         ENDIF

         IF i % 2 != 0
            ++nR
            @ nR, m_y + 2 SAY PadL( aDodPar[ i, 1 ], 15 ) COLOR "W+/B"
            @ nR, Col() + 2 SAY &cPom777 COLOR "R/W"
         ELSE
            @ nR, m_y + 37 SAY PadL( aDodPar[ i, 1 ], 15 ) COLOR "W+/B"
            @ nR, Col() + 2 SAY &cPom777 COLOR "R/W"
         ENDIF

      NEXT
   ENDIF

   Inkey( 0 )
   BoxC()

   RETURN




FUNCTION P_FTxt( cId, dx, dy )

   LOCAL _vrati
   LOCAL _t_area := Select()
   LOCAL _p_bottom
   LOCAL _p_top
   LOCAL _p_left
   LOCAL _p_right
   LOCAL _box_h := MAXROWS() - 20
   LOCAL _box_w := MAXCOLS() - 3
   PRIVATE ImeKol
   PRIVATE Kol

   O_FTXT

   ImeKol := {}
   Kol := {}

   AAdd( ImeKol, { PadR( "ID", 2 ),   {|| id },     "id", {|| .T. }, {|| vpsifra( wid ) }    } )
   add_mcode( @ImeKol )
   AAdd( ImeKol, { "Naziv",  {|| naz },  "naz", {|| .T. }, ;
      {|| wnaz := StrTran( wnaz, "##", hb_eol() ), .T. }, NIL, "@S50" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   _p_bottom := 15
   _p_top := 3
   _p_left := 1
   _p_right := maxcols() -3

   Prozor1( _p_top, _p_left, _p_bottom, _p_right, "PREGLED TEKSTA" )

   @ _p_bottom, 0 SAY ""

   _vrati := PostojiSifra( F_FTXT, 1, _box_h, _box_w, "Faktura - tekst na kraju fakture", @cId, , , {|| PrikFTXT( _p_top, _p_left, 8, _p_right ) } )

   Prozor0()

   SELECT ( _t_area )

   RETURN _vrati



/*! \fn PrikFTxt()
 *  \brief Prikazuje uzorak teksta
 */

FUNCTION PrikFTxt( top_pos, left_pos, bott_pos, text_length )

   LOCAL _i := 0
   LOCAL _arr := {}

   @ top_pos, 6 SAY "uzorak teksta id: " + field->id

   _arr := TXTuNIZ( field->naz, text_length - 1 - left_pos )

   FOR _i := 1 TO bott_pos
      IF _i > Len( _arr )
         @ top_pos + _i, left_pos + 1 SAY Space( text_length - 1 - left_pos )
      ELSE
         @ top_pos + _i, left_pos + 1 SAY PadR( _arr[ _i ], text_length - 1 - left_pos )
      ENDIF
   NEXT

   RETURN -1


/*! \fn fn ObSif()
 *  \brief
 */

STATIC FUNCTION ObSif()

   IF glDistrib
      O_RELAC
      O_VOZILA
      O_KALPOS
   ENDIF

   O_SIFK
   O_SIFV
   O_KONTO
   O_PARTN
   O_ROBA
   O_FTXT
   O_TARIFA
   O_VALUTE
   O_RJ
   O_SAST
   O_UGOV
   O_RUGOV

   IF RUGOV->( FieldPos( "DEST" ) ) <> 0
      O_DEST
   ENDIF

   IF gNW == "T"
      O_FADO
      O_FADE
   ENDIF

   O_VRSTEP
   O_OPS

   RETURN



/*! \fn ima_u_fakt_kumulativ(cKljuc,cTag)
 *  \brief
 *  \param cKljuc
 *  \param cTag
 */

FUNCTION ima_u_fakt_kumulativ( cKljuc, cTag )

   LOCAL lVrati := .F., lUsed := .T., nArr := Select()

   SELECT ( F_FAKT )

   IF !Used()
      lUsed := .F.
      O_FAKT
   ELSE
      PushWA()
   ENDIF

   IF !Empty( IndexKey( Val( cTag ) + 1 ) )
      SET ORDER TO TAG ( cTag )
      SEEK cKljuc
      lVrati := Found()
   ENDIF

   IF !lUsed
      USE
   ELSE
      PopWA()
   ENDIF
   SELECT ( nArr )

   RETURN lVrati
