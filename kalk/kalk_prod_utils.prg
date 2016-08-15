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


FUNCTION MarzaMP( cIdVd, lNaprijed, aPorezi )

   LOCAL nPrevMP

   // za svaki slucaj setujemo ovo ako slucajno u dokumentu nije ispranvo
   IF cIdVD $ "11#12#13"
      // inace je _fcj kod ovih dokumenata  = nabavnoj cijeni
      // _nc u ovim dokumentima moze biti uvecana za troskove prevoza
      _VPC := _FCJ
   ENDIF

   IF cIdVD $ "80"
      _vpc := _nc
      _fcj := _nc
   ENDIF


   // ako je prevoz u MP rasporedjen uzmi ga u obzir
   IF  ( cIdVd $ "11#12#13" ) .AND. ( _TPrevoz == "A" )
      nPrevMP := _Prevoz
   ELSE
      nPrevMP := 0
   ENDIF


   IF  ( _Marza2 == 0 ) .AND. !lNaprijed

      nMarza2 := _MPC - _VPC - nPrevMP

      IF _TMarza2 == "%"
         IF Round( _VPC, 5 ) <> 0
            _Marza2 := 100 * ( _MPC / ( _VPC + nPrevMP ) - 1 )
         ELSE
            _Marza2 := 0
         ENDIF

      ELSEIF _TMarza2 == "A"
         _Marza2 := nMarza2

      ELSEIF _TMarza2 == "U"
         _Marza2 := nMarza2 * ( _Kolicina )
      ENDIF

   ELSEIF ( _MPC == 0 ) .OR. lNaprijed

      IF _TMarza2 == "%"
         nMarza2 := _Marza2 / 100 * ( _VPC + nPrevMP )
      ELSEIF _TMarza2 == "A"
         nMarza2 := _Marza2
      ELSEIF _TMarza2 == "U"
         nMarza2 := _Marza2 / ( _Kolicina )
      ENDIF

      _MPC := Round( nMarza2 + _VPC, 2 )

      _MpcSaPP := Round( MpcSaPor( _mpc, aPorezi ), 2 )

   ELSE
      nMarza2 := _MPC - _VPC - nPrevMP
   ENDIF

   AEval( GetList, {| o| o:display() } )

   RETURN



/* Marza2(fMarza)
 *     Postavi _Marza2, _mpc, _mpcsapp
 */

FUNCTION Marza2( fMarza )

   LOCAL nPrevMP, nPPP

   // za svaki slucaj setujemo ovo ako slucajno u dokumentu nije ispranvo
   IF _IdVD $ "11#12#13"
      // inace je _fcj kod ovih dokumenata  = nabavnoj cijeni
      // _nc u ovim dokumentima moze biti uvecana za troskove prevoza
      _VPC := _FCJ
   ENDIF


   IF fMarza == nil
      fMarza := " "
   ENDIF

   _VPC := _FCJ


   // ako je prevoz u MP rasporedjen uzmi ga u obzir
   IF _TPrevoz == "A"
      nPrevMP := _Prevoz
   ELSE
      nPrevMP := 0
   ENDIF

   IF _FCj == 0
      _FCj := _mpc
   ENDIF

   IF  _Marza2 == 0 .AND. Empty( fmarza )
      nMarza2 := _MPC - _VPC - nPrevMP

      IF _TMarza2 == "%"
         IF Round( _vpc, 5 ) <> 0
            _Marza2 := 100 * ( _MPC / ( _VPC + nPrevMP ) - 1 )
         ELSE
            _Marza2 := 0
         ENDIF

      ELSEIF _TMarza2 == "A"
         _Marza2 := nMarza2

      ELSEIF _TMarza2 == "U"
         _Marza2 := nMarza2 * ( _Kolicina )
      ENDIF

   ELSEIF _MPC == 0 .OR. !Empty( fMarza )

      IF _TMarza2 == "%"
         nMarza2 := _Marza2 / 100 * ( _VPC + nPrevMP )
      ELSEIF _TMarza2 == "A"
         nMarza2 := _Marza2
      ELSEIF _TMarza2 == "U"
         nMarza2 := _Marza2 / ( _Kolicina )
      ENDIF
      _MPC := Round( nMarza2 + _VPC, 2 )

      IF !Empty( fMarza )
         _MpcSaPP := Round( MpcSaPor( _mpc, aPorezi ), 2 )
      ENDIF

   ELSE
      nMarza2 := _MPC - _VPC - nPrevMP
   ENDIF

   AEval( GetList, {| o| o:display() } )

   RETURN



FUNCTION Marza2O( fMarza )

   // {
   LOCAL nPrevMP, nPPP

   IF fMarza == nil
      fMarza := " "
   ENDIF

   IF roba->tip == "K"  // samo za tip k
      nPPP := 1 / ( 1 + tarifa->opp / 100 )
   ELSE
      nPPP := 1
   ENDIF

   // ako je prevoz u MP rasporedjen uzmi ga u obzir
   IF _TPrevoz == "A"
      nPrevMP := _Prevoz
   ELSE
      nPrevMP := 0
   ENDIF

   IF _fcj == 0
      _fcj := _mpc
   ENDIF

   IF  _Marza2 == 0 .AND. Empty( fmarza )
      nMarza2 := _MPC - _VPC * nPPP - nPrevMP
      IF _TMarza2 == "%"
         IF Round( _vpc, 5 ) <> 0
            _Marza2 := 100 * ( _MPC / ( _VPC * nPPP + nPrevMP ) -1 )
         ELSE
            _Marza2 := 0
         ENDIF
      ELSEIF _TMarza2 == "A"
         _Marza2 := nMarza2
      ELSEIF _TMarza2 == "U"
         _Marza2 := nMarza2 * ( _Kolicina )
      ENDIF

   ELSEIF _MPC == 0 .OR. !Empty( fMarza )
      IF _TMarza2 == "%"
         nMarza2 := _Marza2 / 100 * ( _VPC * nPPP + nPrevMP )
      ELSEIF _TMarza2 == "A"
         nMarza2 := _Marza2
      ELSEIF _TMarza2 == "U"
         nMarza2 := _Marza2 / ( _Kolicina )
      ENDIF
      _MPC := Round( nMarza2 + _VPC, 2 )
      IF !Empty( fMarza )
         IF roba->tip == "V"
            _mpcsapp := Round( _mpc * ( 1 + TARIFA->PPP / 100 ), 2 )
         ELSEIF roba->tip = "X"
            // ne diraj _mpcsapp
         ELSE
            _mpcsapp := Round( MpcSaPor( _mpc, aPorezi ), 2 )
         ENDIF
      ENDIF

   ELSE
      nMarza2 := _MPC - _VPC * nPPP - nPrevMP
   ENDIF

   AEval( GetList, {| o| o:display() } )

   RETURN
// }




/* Marza2R()
 *     Marza2 pri realizaciji prodavnice je MPC-NC
 */

FUNCTION Marza2R()

   // {
   LOCAL nPPP

   nPPP := 1 / ( 1 + tarifa->opp / 100 )

   IF _nc == 0
      _nc := _mpc
   ENDIF

   IF  _Marza2 == 0
      nMarza2 := _MPC - _NC
      IF roba->tip == "V"
         nMarza2 := ( _MPC - roba->VPC ) + roba->vpc * nPPP - _NC
      ENDIF

      IF _TMarza2 == "%"
         _Marza2 := 100 * ( _MPC / _NC - 1 )
      ELSEIF _TMarza2 == "A"
         _Marza2 := nMarza2
      ELSEIF _TMarza2 == "U"
         _Marza2 := nMarza2 * ( _Kolicina )
      ENDIF
   ELSEIF _MPC == 0
      IF _TMarza2 == "%"
         nMarza2 := _Marza2 / 100 * _NC
      ELSEIF _TMarza2 == "A"
         nMarza2 := _Marza2
      ELSEIF _TMarza2 == "U"
         nMarza2 := _Marza2 / ( _Kolicina )
      ENDIF
      _MPC := nMarza2 + _NC
   ELSE
      nMarza2 := _MPC - _NC
   ENDIF
   AEval( GetList, {| o| o:display() } )

   RETURN
// }


/* Marza2R()
 *     Marza pri realizaciji prodavnice
 */

FUNCTION MarzaMpR()

   // {
   LOCAL nPPP

   nPPP := 1 / ( 1 + tarifa->opp / 100 )

   IF _nc == 0
      _nc := _mpc
   ENDIF

   nMpcSaPop := _MPC - RabatV

   IF  ( _Marza2 == 0 )
      nMarza2 := nMpcSaPop - _NC

      IF _TMarza2 == "%"
         _Marza2 := 100 * ( nMpcSaPop / _NC - 1 )
      ELSEIF _TMarza2 == "A"
         _Marza2 := nMarza2
      ELSEIF _TMarza2 == "U"
         _Marza2 := nMarza2 * ( _Kolicina )
      ENDIF
   ELSEIF ( _MPC == 0 )
      IF _TMarza2 == "%"
         nMarza2 := _Marza2 / 100 * _NC
      ELSEIF _TMarza2 == "A"
         nMarza2 := _Marza2
      ELSEIF _TMarza2 == "U"
         nMarza2 := _Marza2 / ( _Kolicina )
      ENDIF

      _MPC := nMarza2 + _NC + _RabatV

   ELSE
      nMarza2 := nMpcSaPop - _NC
   ENDIF
   AEval( GetList, {| o| o:display() } )

   RETURN





FUNCTION kalk_fakticka_mpc( nMPC, cIdFirma, cPKonto, cIdRoba, dDatum )

   LOCAL nOrder

   nMPC := kalk_get_mpc_by_koncij_pravilo()

   PushWA()

   find_kalk_by_pkonto_idroba( cIdFirma, cPKonto, cIdRoba )
   GO BOTTOM

   DO WHILE !Bof() .AND. idfirma + pkonto + idroba == cIdFirma + cPKonto + cIdRoba

      IF dDatum <> NIL .AND. dDatum < datdok
         SKIP -1
         LOOP
      ENDIF

      IF idvd $ "11#80#81"
         nMPC := field->mpcsapp
         EXIT
      ELSEIF idvd == "19"
         nMPC := fcj + mpcsapp
         EXIT
      ENDIF

      SKIP -1 // od dna kartice ka vrhu
   ENDDO
   PopWa()

   RETURN .T.





FUNCTION kalk_get_mpc_by_koncij_pravilo( cIdKonto )

   LOCAL nCV := 0, cRule

   IF cIdKonto != NIL
      PushWa()
      SELECT koncij
      SEEK cIdKonto
      cRule := koncij->naz
      PopWa()
   ELSE
      cRule := koncij->naz
   ENDIF

   IF cRule == "M2"
      nCV := roba->mpc2
   ELSEIF cRule == "M3"
      nCV := roba->mpc3
   ELSEIF cRule == "M4" .AND. roba->( FieldPos( "mpc4" ) ) <> 0
      nCV := roba->mpc4
      // ELSEIF koncij->naz == "M5" .AND. roba->( FieldPos( "mpc5" ) ) <> 0
      // nCV := roba->mpc5
      // ELSEIF koncij->naz == "M6" .AND. roba->( FieldPos( "mpc6" ) ) <> 0
      // nCV := roba->mpc6
   ELSEIF roba->( FieldPos( "mpc" ) ) <> 0
      nCV := roba->mpc
   ENDIF

   RETURN nCV




// ------------------------------------
// StaviMPCSif(nCijena, lUpit)
// ------------------------------------
FUNCTION StaviMPCSif( nCijena, lUpit )

   LOCAL lAzuriraj
   LOCAL lRet := .F.
   LOCAL lIsteCijene
   LOCAL _rec

   IF lUpit == nil
      lUpit := .F.
   ENDIF

   PRIVATE cMpc := ""

   DO CASE
   CASE koncij->naz == "M2"
      cMpc := "mpc2"
   CASE koncij->naz == "M3"
      cMpc := "mpc3"
   CASE koncij->naz == "M4"
      cMpc := "mpc4"
      // CASE koncij->naz == "M5"
      // cMpc := "mpc5"
      // CASE koncij->naz == "M6"
      // cMpc := "mpc6"
   OTHERWISE
      cMpc := "mpc"
   ENDCASE

   lIsteCijene := ( Round( roba->( &cMpc ), 4 ) == Round( nCijena, 4 ) )

   IF lIsteCijene
      // iste cijene nemam sta mijenjati
      RETURN .F.
   ENDIF

   IF lUpit
      IF gAutoCjen == "D" .AND. Pitanje(, "Staviti " + cMpc + " u sifrarnik ?", gDefNiv ) == "D"
         lAzuriraj := .T.
      ELSE
         lAzuriraj := .F.
      ENDIF
   ELSE
      lAzuriraj := .T.
      IF gAutoCjen == "N"
         lAzuriraj := .F.
      ENDIF
   ENDIF

   IF lAzuriraj
      PushWA()
      SELECT ROBA
      _rec := dbf_get_rec()
      _rec[ cMpc ] := nCijena

      update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )

      PopWa()
      lRet := .T.
   ENDIF

   RETURN lRet





FUNCTION kalk_valid_kolicina_prod()

   LOCAL ppKolicina

   IF Empty( gMetodaNC ) .OR. _TBankTr == "X"
      RETURN .T.
   ENDIF

   IF roba->tip $ "UTY"; RETURN .T. ; ENDIF

   ppKolicina := _Kolicina
   IF _idvd == "11"
      ppKolicina := Abs( _Kolicina )
   ENDIF

   IF nKolS < ppKolicina

      sumnjive_stavke_error()

      // Msg( "U prodavnici je samo" + Str( nKolS, 10, 3 ) + " robe !", 6 )
      error_bar( "KA_" + _pkonto + "/" + _idroba, ;
         _pkonto + " / " + _idroba + "na stanju: " + AllTrim( Str( nKolS, 10, 4 ) ) + " treba " +  AllTrim( Str( _kolicina, 10, 4 ) ) )


   ENDIF

   RETURN .T.




/* StanjeProd(cKljuc,ddatdok)
 *
 */

FUNCTION StanjeProd( cKljuc, ddatdok )

   LOCAL nUlaz := 0, nIzlaz := 0

   SELECT KALK
   SET ORDER TO TAG "4"
   GO TOP
   SEEK cKljuc
   DO WHILE !Eof() .AND. cKljuc == idfirma + pkonto + idroba
      IF ddatdok < datdok  // preskoci
         skip; LOOP
      ENDIF
      IF roba->tip $ "UT"
         skip; LOOP
      ENDIF

      IF pu_i == "1"
         nUlaz += kolicina - GKolicina - GKolicin2

      ELSEIF pu_i == "5"  .AND. !( idvd $ "12#13#22" )
         nIzlaz += kolicina

      ELSEIF pu_i == "5"  .AND. ( idvd $ "12#13#22" )    // povrat
         nUlaz -= kolicina

      ELSEIF pu_i == "I"
         nIzlaz += gkolicin2
      ENDIF

      SKIP 1
   ENDDO

   RETURN ( nUlaz - nIzlaz )
