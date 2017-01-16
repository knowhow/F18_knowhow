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


FUNCTION P_Tarifa( cid, dx, dy )

   PRIVATE ImeKol
   PRIVATE Kol

   ImeKol := {}
   Kol := {}

   PushWA()
   O_TARIFA

   AAdd( ImeKol, { "ID", {|| id }, "id", {|| .T. }, {|| sifra_postoji( wId ) }  } )
   AAdd( ImeKol, { PadC( "Naziv", 35 ), {|| PadR( ToStrU( naz ), 35 ) }, "naz" } )
   AAdd( ImeKol,  { "PDV ", {|| opp },  "opp", NIL, NIL, NIL, "999.99" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   lRet := p_sifra( F_TARIFA, 1, MAXROWS() -15, MAXCOLS() -25, "Tarifne grupe", @cid, dx, dy )

   PopWa()

   RETURN lRet



/*
 *   Ispitivanje tarife, te punjenje matrice aPorezi
 * param: cIdKonto - Oznaka konta
 * param: cIdRoba - Oznaka robe
 * param: aPorezi - matrica za vrijednosti poreza
 * param: cIdTar - oznaka tarife, ovaj parametar je nil, ali se koristi za izvjestaje radi starih dokumenata (gdje je bilo promjene tarifa)
 */

FUNCTION get_tarifa_by_koncij_region_roba_idtarifa_2_3( cIdKonto, cIdRoba, aPorezi, cIdTar )

   LOCAL cTarifa
   LOCAL lUsedRoba
   LOCAL lUsedTarifa
   LOCAL cIdTarifa

   PRIVATE cPolje

   lUsedRoba := .T.
   lUsedTarifa := .T.

   PushWA()

   IF Empty( cIdKonto )
      cPolje := "IdTarifa"

   ELSE
      SELECT ( F_KONCIJ )
      IF ( !Used() )
         o_koncij()
      ENDIF
      SEEK cIdKonto
      IF !Found()
         cPolje := "IdTarifa"
      ELSE

         IF ( koncij->region == "1" .OR. koncij->region == " " )
            cPolje := "IdTarifa"
         ELSEIF koncij->region == "2"
            cPolje := "IdTarifa2"
         ELSEIF koncij->region == "3"
            cPolje := "IdTarifa3"
         ELSE
            cPolje := "IdTarifa"
         ENDIF

      ENDIF
   ENDIF

   IF cIdTar == nil
      Select( F_ROBA )
      IF ( !Used() )
         lUsedRoba := .F.
         O_ROBA
      ENDIF
      SEEK cIdRoba
      cTarifa := &cPolje

      Select( F_TARIFA )
      IF ( !Used() )
         lUsedTarifa := .F.
         O_TARIFA
      ENDIF
      SEEK cTarifa
      cIdTarifa := tarifa->id
   ELSE
      cTarifa := cIdTar
      Select( F_TARIFA )
      IF ( !Used() )
         lUsedTarifa := .F.
         O_TARIFA
      ENDIF
      SEEK cTarifa
      cIdTarifa := cIdTar
   ENDIF

   set_pdv_array( @aPorezi )

   IF ( !lUsedRoba )
      Select( F_ROBA )
      USE
   ENDIF

   IF ( !lUsedTarifa )
      Select( F_TARIFA )
      USE
   ENDIF

   PopWa()

   RETURN cIdTarifa




/* MpcSaPorUgost(nPosebniPorez, nPorezNaRuc, aPorezi)
 *     Racuna maloprodajnu cijenu u ugostiteljstvu
 *   param: nPosebniPorez Posebni porez
 *   param: nPorezNaRuc Porez na razliku u cijeni
 *   param: aPorezi Matrica sa porezima
 */
FUNCTION MpcSaPorUgost( nPosebniPorez, nPorezNaRuc, aPorezi )

   LOCAL nPom

   // (MpcSapp - PorezNaRuc) * StopaPP = PosebniPorez
   // PosebniPorez/StopaPP = MpcSaPP - PorezNaRuc
   // MpcSaPP = PosebniPorez/StopaPP + PorezNaRuc

   nPom := nPosebniPorez / ( aPorezi[ POR_P_PRUC ] / 100 ) + nPorezNaRUC

   RETURN nPom


/* MpcSaPor(nMpcBP, aPorezi, aPoreziIzn)
 *     Racuna maloprodajnu cijenu sa porezom
 *   param: nMpcBP Maloprodajna cijena bez poreza
 *   param: aPorezi Matrica poreza
 *   param: aPoreziIzn Matrica sa izracunatim porezima
 */
FUNCTION MpcSaPor( nMPCBp, aPorezi, aPoreziIzn )

   LOCAL nPom
   LOCAL nMPP
   LOCAL nPP
   LOCAL nPPP

   nPDV := aPorezi[ POR_PPP ] / 100

   IF glUgost
      nPP := aPorezi[ POR_PP ] / 100
   ELSE
      nPP := 0
   ENDIF


   // bez poreza * ( 0.17 + 0 + 1)
   nPom := nMpcBp * ( nPDV + nPP + 1 )

   RETURN nPom


FUNCTION MpcSaPorO( nMPCBp, aPorezi, aPoreziIzn )

   LOCAL nPom
   LOCAL nDLRUC
   LOCAL nMPP
   LOCAL nPP
   LOCAL nPPP
   LOCAL nPPU

   nDLRUC := 0
   nMPP := 0
   nPP := aPorezi[ POR_PP ] / 100
   nPPP := aPorezi[ POR_PPP ] / 100
   nPPU := aPorezi[ POR_PPU ] / 100

   nPom := nMpcBp * ( nPP + ( nPPP + 1 ) * ( 1 + nPPU ) )

   RETURN nPom


/*
 *     Racuna maloprodajnu cijenu bez poreza
 *   param: nMpcSaPP maloprodajna cijena sa porezom
 *   param: aPorezi Matrica poreza
 *   param: nRabat Rabat
 *   param: nNC Nabavna cijena
 */

FUNCTION MpcBezPor( nMpcSaPP, aPorezi, nRabat, nNC )

   LOCAL nStopa
   LOCAL nPor1
   LOCAL nPor2
   LOCAL nPom
   LOCAL nMPP
   LOCAL nPP
   LOCAL nPDV
   LOCAL nBrutoMarza
   LOCAL nMpcBezPor

   IF nRabat == nil
      nRabat := 0
   ENDIF

   nPDV := aPorezi[ POR_PPP ]

   nPP := 0

   RETURN nMpcSaPP / ( ( nPDV + nPP ) / 100 + 1 )








/*

FUNCTION KorekTar()

   LOCAL cTekIdTarifa
   LOCAL cPriprema

   IF !spec_funkcije_sifra( "SIGMATAR" )
      RETURN .F.
   ENDIF

   my_close_all_dbf()

   O_ROBA

   SELECT 0

   cIdVD := Space( 2 )
   cIdTarifa := Space( 6 )

   SET CURSOR ON

   cPriprema := "D"

   Box(, 3, 60 )
   @ m_x + 1, m_y + 2 SAY "Vrsta dokumenta (prazno svi)" GET cIdVD
   @ m_x + 2, m_y + 2 SAY "Tarifa koju treba zamijeniti (prazno svi)" GET cIdTarifa PICT "@!"
   IF gModul == "KALK"
      @ m_x + 3, m_y + 2 SAY "Izvrsiti korekciju nad pripremom D/N ? " GET cPriprema PICT "@!" VALID cPriprema  $ "DN"
   ENDIF

   READ
   Boxc()
   IF LastKey() == K_ESC
      RETURN
   ENDIF

   nKumArea := 0

   IF gModul == "KALK"
      IF cPriprema == "D"
         USE ( PRIVPATH + "PRIPR" )
      ELSE
         USE ( KUMPATH + "KALK" )
      ENDIF
   ELSEIF gModul == "POS"
      USE ( KUMPATH + "POS" )
   ELSE
      CLOSERET
   ENDIF
   nKumArea := Select()

   nC := 0
   Box(, 1, 50 )
   GO TOP
   DO WHILE !Eof()
      IF ( Empty( cIdVD ) .OR. cIdvd == IDVD ) .AND. ( Empty( cIdTarifa ) .OR. cIdTarifa == ( nKumArea )->IdTarifa )
         SELECT roba; HSEEK ( nKumArea )->idroba
         IF !Found()
            MsgBeep( "Artikal " + ( nKumArea )->idroba + " ne postoji u sifraniku robe" )
         ELSE
            SELECT ( nKumArea )

            PRIVATE aPorezi := {}
            IF gModul == "KALK"
               cTekIdTarifa := get_tarifa_by_koncij_region_roba_idtarifa_2_3( ( nKumArea )->PKONTO, ( nKumArea )->IdRoba, @aPorezi )
            ELSE
               cTekIdTarifa := roba->IdTarifa
            ENDIF
            IF ( nKumArea )->IdTarifa <> cTekIdTarifa
               SELECT ( nKumArea )
               @ m_x + 1, m_y + 2 SAY ++Nc PICT "999999"
               @ m_x + 1, Col() + 2 SAY IdTarifa
               @ m_x + 1, Col() + 2 SAY "->"
               @ m_x + 1, Col() + 2 SAY cTekIdTarifa

               REPLACE IdTarifa WITH cTekIdTarifa
               // REPLSQL IdTarifa with cTekIdTarifa
            ENDIF
         ENDIF
      ENDIF
      SELECT ( nKumArea )
      SKIP 1
   ENDDO
   BoxC()

   Select( nKumArea )
   USE

   CLOSERET

   RETURN
*/



/*  RacPorezeMP(aPorezi, nMpc, nMpcSaPP, nNc)
 *    Racunanje poreza u maloprodaji
 *  param: aPorezi Matrica poreza
 *  param: nMpc Maloprodajna cijena
 *  param: nMpcSaPP Maloprodajna cijena sa porezom
 *  param: nNc Nabavna cijena
*/
FUNCTION RacPorezeMP( aPorezi, nMpc, nMpcSaPP, nNc )

   LOCAL nIznPRuc
   LOCAL nP1, nP2, nP3

   // PDV
   nP1 := kalk_porezi_maloprodaja( nMpc, aPorezi, nMpcSaPP )
   nP2 := 0
   nP3 := 0

   RETURN { nP1, nP2, nP3 }


// formatiraj stopa pdv kao string
// " 17 %"
// "15.5%"
FUNCTION stopa_pdv( nPdv )

   IF nPdv == nil
      nPdv := tarifa->opp
   ENDIF

   IF Round( nPdv, 1 ) == Round( nPdv, 0 )
      RETURN Str( nPdv, 3, 0 ) + " %"
   ELSE
      RETURN Str( nPdv, 3, 1 ) + "%"
   ENDIF
