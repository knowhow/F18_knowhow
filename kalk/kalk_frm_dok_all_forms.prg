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


FUNCTION VRoba( lSay )

   P_Roba( @_IdRoba )

   IF lSay == NIL
      lSay := .T.
   ENDIF

   IF lSay
      say_from_valid( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + AllTrim( roba->jmj ) + ")", 40 )
   ENDIF

   IF fNovi
      cTarifa := Tarifa( _idkonto, _idroba, @aPorezi )
   ELSE
      // za postojece dokumente uzmi u obzir unesenu tarifu
      SELECT TARIFA
      SEEK _idtarifa
      SetAPorezi( @aPorezi )
   ENDIF

   IF fNovi
      _idtarifa := cTarifa
   ENDIF

   RETURN .T.





/* WMpc(fRealizacija,fMarza)
 *     When blok za unos MPC
 *   param: fRealizacija -
 *   param: fMarza -
 */

FUNCTION WMpc( fRealizacija, fMarza )

   IF fRealizacija == nil
      fRealizacija := .F.
   ENDIF

   IF fRealizacija
      fMarza := " "
   ENDIF

   IF _mpcsapp <> 0
      _marza2 := 0
      _mpc := MpcBezPor( _mpcsapp, aPorezi, , _nc )
   ENDIF

   IF fRealizacija
      IF ( _idvd == "47" )
         _nc := _mpc
      ENDIF
   ENDIF

   RETURN .T.





/* VMpc(fRealizacija,fMarza)
 *     Valid blok za unos MPC
 *   param: fRealizacija -
 *   param: fMarza -
 */

FUNCTION VMpc( fRealizacija, fMarza )

   IF fRealizacija == NIL
      fRealizacija := .F.
   ENDIF

   IF fRealizacija
      fMarza := " "
   ENDIF

   IF fMarza == NIL
      fMarza := " "
   ENDIF

   Marza2( fMarza )

   IF _mpcsapp == 0
      _MPCSaPP := Round( MpcSaPor( _mpc, aPorezi ), 2 )
   ENDIF

   RETURN .T.





/* VMpcSaPP(fRealizacija,fMarza)
 *     Valid blok za unos MpcSaPP
 *   param: fRealizacija -
 *   param: fMarza -
 */

FUNCTION VMpcSaPP( fRealizacija, fMarza )

   // {
   LOCAL nRabat

   IF fRealizacija == NIL
      fRealizacija := .F.
   ENDIF

   IF fRealizacija
      nRabat := _rabatv
   ELSE
      nRabat := 0
   ENDIF

   IF fMarza == NIL
      fMarza := " "
   ENDIF

   IF _mpcsapp <> 0 .AND. Empty( fMarza )

      _mpc := MpcBezPor( _mpcsapp, aPorezi, nRabat, _nc )

      _marza2 := 0
      IF fRealizacija
         Marza2R()
      ELSE
         Marza2()
      ENDIF
      ShowGets()

      IF fRealizacija
         DuplRoba()
      ENDIF
   ENDIF

   fMarza := " "

   RETURN .T.
// }




/* SayPorezi(nRow)
 *     Ispisuje poreze
 *   param: nRow - relativna kooordinata reda u kojem se ispisuju porezi
 */

FUNCTION SayPorezi( nRow )

   // {
   IF IsPDV()
      @ m_x + nRow, m_y + 2  SAY "PDV (%):"
      @ Row(), Col() + 2 SAY aPorezi[ POR_PPP ] PICTURE "99.99"
      IF glUgost
         @ m_x + nRow, Col() + 8  SAY "PP (%):"
         @ Row(), Col() + 2  SAY aPorezi[ POR_PP ] PICTURE "99.99"
      ENDIF
   ELSE
      @ m_x + nRow, m_y + 2  SAY "PPP (%):"
      @ Row(), Col() + 2 SAY  aPorezi[ POR_PPP ] PICTURE "99.99"
      @ m_x + nRow, Col() + 8  SAY "PPU (%):"
      @ Row(), Col() + 2  SAY PrPPUMP() PICTURE "99.99"
      @ m_x + nRow, Col() + 8  SAY "PP (%):"
      @ Row(), Col() + 2  SAY aPorezi[ POR_PP ] PICTURE "99.99"
   ENDIF

   RETURN
// }




/* FillIzgStavke(pIzgStavke)
 *     Puni polja izgenerisane stavke
 *   param: pIzgStavke - .f. ne puni, .t. puni
 */

FUNCTION FillIzgStavke( pIzgStavke )

   // {
   IF pIzgSt .AND. _kolicina > 0 .AND. LastKey() <> K_ESC // izgenerisane stavke postoje
      PRIVATE nRRec := RecNo()
      GO TOP
      my_flock()
      DO WHILE !Eof()  // nafiluj izgenerisane stavke
         IF kolicina == 0
            SKIP
            PRIVATE nRRec2 := RecNo()
            SKIP -1
            my_delete()
            GO nRRec2
            LOOP
         ENDIF
         IF brdok == _brdok .AND. idvd == _idvd .AND. Val( Rbr ) == nRbr
            REPLACE nc WITH kalk_pripr->fcj, ;
               vpc WITH _vpc, ;
               tprevoz WITH _tprevoz, ;
               prevoz WITH _prevoz, ;
               mpc    WITH _mpc, ;
               mpcsapp WITH _mpcsapp, ;
               tmarza  WITH _tmarza, ;
               marza  WITH _vpc / ( 1 + _PORVT ) -kalk_pripr->fcj, ;      // konkretna vp marza
            tmarza2  WITH _tmarza2, ;
               marza2  WITH _marza2, ;
               mkonto WITH _mkonto, ;
               mu_i WITH  _mu_i, ;
               pkonto WITH _pkonto, ;
               pu_i WITH  _pu_i,;
               error WITH "0"
         ENDIF
         SKIP
      ENDDO
      my_unlock()
      GO nRRec
   ENDIF

   RETURN
// }



/* VRoba_lv(fNovi, aPorezi)
 *     Setuje tarifu i poreze na osnovu sifrarnika robe i tarifa
 *  \note koristi lokalne varijable
 */

FUNCTION VRoba_lv( fNovi, aPorezi )

   LOCAL _tezina := 0
   LOCAL _ocitani_barkod := _idroba

   P_Roba( @_IdRoba )

   IF fNovi
      // nadji odgovarajucu tarifu regiona
      cTarifa := Tarifa( _IdKonto, _IdRoba, @aPorezi )
   ELSE
      // za postojece dokumente uzmi u obzir unesenu tarifu
      SELECT TARIFA
      SEEK _IdTarifa
      SetAPorezi( @aPorezi )
   ENDIF

   IF fNovi
      _IdTarifa := cTarifa
   ENDIF

   // momenat kada mozemo ocitati tezinu iz barkod-a ako se koristi...
   IF tezinski_barkod_get_tezina( _ocitani_barkod, @_tezina ) .AND. _tezina <> 0

      // ako je ocitan tezinski barkod...
      _kolicina := _tezina

      // kod predispozicije kolicina treba biti negativna kod prvog ocitanja
      IF _idvd == "80" .AND. ( !Empty( _idkonto2 ) .AND. _idkonto2 <> "XXX" )
         _kolicina := -_kolicina
      ENDIF

   ENDIF

   RETURN .T.



// -----------------------------------------------------------
// WHEN validator na polju MPC
// -----------------------------------------------------------
FUNCTION W_Mpc_( cIdVd, lNaprijed, aPorezi )

   LOCAL _st_popust

   // formiraj cijenu naprijed
   IF lNaprijed
      // postavi _Mpc bez poreza
      MarzaMP( cIdVd, .T., aPorezi )
   ENDIF

   IF cIdVd $ "41#42#47"
      nMpcSaPDV := _MpcSaPP
      _st_popust := _rabatv
   ELSE
      nMpcSaPDV := _MpcSapp
      _st_popust := 0
   ENDIF

   // postoji MPC, idi unazad
   IF !lNaprijed .AND. _MpcSapp <> 0
      _Marza2 := 0
      _Mpc := MpcBezPor( nMpcSaPDV, aPorezi, , _nc ) - _st_popust
   ENDIF

   RETURN .T.



/* WMpc_lv(fRealizacija, fMarza, aPorezi)
 *     When blok za unos MPC
 *   param: fRealizacija -
 *   param: fMarza -
 *  \note koriste se lokalne varijable
 */

FUNCTION WMpc_lv( fRealizacija, fMarza, aPorezi )

   // {

   // legacy

   IF fRealizacija == nil
      fRealizacija := .F.
   ENDIF

   IF fRealizacija
      fMarza := " "
   ENDIF

   IF _MpcSapp <> 0
      _marza2 := 0
      _Mpc := MpcBezPor( _MpcSaPP, aPorezi, , _nc )
   ENDIF

   IF fRealizacija
      IF ( _idvd == "47" )
         _nc := _mpc
      ENDIF
   ENDIF

   RETURN .T.
// }




/* VMpc_lv(fRealizacija, fMarza, aPorezi)
 *     Valid blok za unos MPC
 *   param: fRealizacija -
 *   param: fMarza -
 *  \note koriste se lokalne varijable
 */

FUNCTION VMpc_lv( fRealizacija, fMarza, aPorezi )

   // {
   IF fRealizacija == nil
      fRealizacija := .F.
   ENDIF
   IF fRealizacija
      fMarza := " "
   ENDIF
   IF fMarza == nil
      fMarza := " "
   ENDIF

   Marza2( fMarza )
   IF ( _mpcsapp == 0 )
      _MPCSaPP := Round( MpcSaPor( _mpc, aPorezi ), 2 )
   ENDIF

   RETURN .T.
// }



FUNCTION V_Mpc_( cIdVd, lNaprijed, aPorezi )

   LOCAL nPopust

   IF cIdVd $ "41#42#47"
      nPopust := _RabatV
   ELSE
      nPopust := 0
   ENDIF

   MarzaMp( cIdVd, lNaprijed, aPorezi )

   IF ( _Mpcsapp == 0 )
      _mpcsapp := Round( MpcSaPor( _mpc, aPorezi ), 2 ) + nPopust
   ENDIF

   RETURN .T.





/* VMpcSaPP_lv(fRealizacija, fMarza, aPorezi)
 *     Valid blok za unos MpcSaPP
 *   param: fRealizacija -
 *   param: fMarza -
 *  \note koriste se lokalne varijable
 */

FUNCTION VMpcSaPP_lv( fRealizacija, fMarza, aPorezi, lShowGets )

   LOCAL nPom

   IF lShowGets == nil
      lShowGets := .T.
   ENDIF

   IF fRealizacija == NIL
      fRealizacija := .F.
   ENDIF

   IF fRealizacija
      nPom := _mpcsapp
   ELSE
      nPom := _mpcsapp
   ENDIF

   IF fMarza == nil
      fMarza := " "
   ENDIF

   IF _mpcsapp <> 0 .AND. Empty( fMarza )
      _mpc := MpcBezPor ( nPom, aPorezi, , _nc ) - _rabatv
      _marza2 := 0
      IF fRealizacija
         Marza2R()
      ELSE
         Marza2()
      ENDIF
      IF lShowGets
         ShowGets()
      ENDIF
      IF fRealizacija
         DuplRoba()
      ENDIF
   ENDIF

   fMarza := " "

   RETURN .T.


// ---------------------------------------------------------------
// racuna mpc sa porezom
// ---------------------------------------------------------------
FUNCTION V_MpcSaPP_( cIdVd, lNaprijed, aPorezi, lShowGets )

   LOCAL nPom

   IF lShowGets == nil
      lShowGets := .T.
   ENDIF

   IF cIdvd $ "41#42"
      nPom := _mpcsapp
   ELSE
      nPom := _mpcsapp
   ENDIF

   IF _Mpcsapp <> 0 .AND. !lNaprijed

      // mpc ce biti umanjena mpc sa pp - porez - rabat (ako postoji)
      _mpc := MpcBezPor( nPom, aPorezi, , _nc ) - _rabatv

      _marza2 := 0

      MarzaMP( cIdVd, lNaprijed, aPorezi )

      IF lShowGets
         ShowGets()
      ENDIF

      IF cIdVd $ "41#42"
         DuplRoba()
      ENDIF

   ENDIF

   RETURN .T.





/* SayPorezi_lv(nRow, aPorezi)
 *     Ispisuje poreze
 *   param: nRow - relativna kooordinata reda u kojem se ispisuju porezi
 *  \aPorezi - koristi lokalne varijable
 */

FUNCTION SayPorezi_lv( nRow, aPorezi )

   // {
   IF IsPDV()
      @ m_x + nRow, m_y + 2  SAY "PDV (%):"
      @ Row(), Col() + 2 SAY  aPorezi[ POR_PPP ] PICTURE "99.99"

      IF glUgost
         @ m_x + nRow, Col() + 8  SAY "PP (%):"
         @ Row(), Col() + 2  SAY aPorezi[ POR_PP ] PICTURE "99.99"
      ENDIF
   ELSE
      @ m_x + nRow, m_y + 2  SAY "PPP (%):"
      @ Row(), Col() + 2 SAY  aPorezi[ POR_PPP ] PICTURE "99.99"
      @ m_x + nRow, Col() + 8  SAY "PPU (%):"
      @ Row(), Col() + 2  SAY PrPPUMP() PICTURE "99.99"
      @ m_x + nRow, Col() + 8  SAY "PP (%):"
      @ Row(), Col() + 2  SAY aPorezi[ POR_PP ] PICTURE "99.99"
   ENDIF

   RETURN
// }
