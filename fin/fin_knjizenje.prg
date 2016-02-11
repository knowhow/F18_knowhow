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


STATIC cTekucaRj := ""
STATIC __par_len
STATIC __rj_len := 6

// FmkIni_KumPath_TekucaRj - Tekuca radna jedinica
// Koristi se u slucaju da u Db unosimo podatke za odredjenu radnu jedinicu
// da ne bi svaki puta ukucavali tu Rj ovaj parametar nam je nudi kao tekucu vrijednost.

// ---------------------------------------------
// Unos fin naloga
// ---------------------------------------------
FUNCTION fin_unos_naloga()

   LOCAL _params := fin_params()
   PRIVATE KursLis := "1"
   PRIVATE gnLOst := 0
   PRIVATE gPotpis := "N"

   fin_read_params()

   cTekucaRj := GetTekucaRJ()
   lBlagAsis := .F.
   cBlagIDVN := "66"

   KnjNal()

   my_close_all_dbf()

   RETURN


/*! \fn KnjNal()
 *  \brief Otvara pripremu za knjizenje naloga
 */

FUNCTION KnjNal()

   LOCAL _sep := BROWSE_COL_SEP
   LOCAL _w := 25
   LOCAL _d := MAXCOLS() - 6
   LOCAL _x_row := MAXROWS() - 5
   LOCAL _y_row := _d
   LOCAL _opt_row
   LOCAL _help_columns := 4
   LOCAL _opts := {}

   o_fin_edit()

   ImeKol := { ;
      { "F.",            {|| dbSelectArea( F_FIN_PRIPR ), IdFirma }, "IdFirma" }, ;
      { "VN",            {|| IdVN    }, "IdVN" }, ;
      { "Br.",           {|| BrNal   }, "BrNal" }, ;
      { "R.br",          {|| RBr     }, "rbr", {|| wrbr() }, {|| vrbr() } }, ;
      { "Konto",         {|| IdKonto }, "IdKonto", {|| .T. }, {|| P_Konto( @_IdKonto ), .T. } }, ;
      { "Partner",       {|| IdPartner }, "IdPartner" }, ;
      { "Br.veze ",      {|| BrDok   }, "BrDok" }, ;
      { "Datum",         {|| DatDok  }, "DatDok" }, ;
      { "D/P",           {|| D_P     }, "D_P" }, ;
      { "Iznos " + AllTrim( ValDomaca() ), {|| Transform( IznosBHD, FormPicL( gPicBHD, 15 ) ) }, "iznosbhd" }, ;
      { "Iznos " + AllTrim( ValPomocna() ), {|| Transform( IznosDEM, FormPicL( gPicDEM, 10 ) ) }, "iznosdem" }, ;
      { "Opis",          {|| PadR( Left( Opis, 37 ) + iif( Len( AllTrim( Opis ) ) > 37, "...", "" ), 40 )  }, "OPIS" }, ;
      { "K1",            {|| k1      }, "k1" }, ;
      { "K2",            {|| k2      }, "k2" }, ;
      { "K3",            {|| K3Iz256( k3 )   }, "k3" }, ;
      { "K4",            {|| k4      }, "k4" } ;
      }


   Kol := {}

   FOR i := 1 TO 16
      AAdd( Kol, i )
   NEXT

   IF gRj == "D" .AND. fin_pripr->( FieldPos( "IDRJ" ) ) <> 0
      AAdd( ImeKol, { "RJ", {|| IdRj }, "IdRj" } )
      AAdd( Kol, 17 )
   ENDIF

   Box( , _x_row, _y_row )

   _opt_d := ( _d / 4 )

   _opt_row := PadR( "<c+N> Nova stavka", _opt_d ) + _sep
   _opt_row += PadR( " <ENT> Ispravka", _opt_d ) + _sep
   _opt_row += PadR( " <c+T> Briši stavku", _opt_d ) + _sep
   _opt_row += " <P> Povrat naloga"

   @ m_x + _x_row - 3, m_y + 2 SAY8 _opt_row

   _opt_row := PadR( "<c+A> Ispravka stavki", _opt_d ) + _sep
   _opt_row += PadR( " <c+P> Štampa naloga", _opt_d ) + _sep
   _opt_row += PadR( " <a+A> Ažuriranje", _opt_d ) + _sep
   _opt_row += " <x> Ažur.bez stampe"

   @ m_x + _x_row - 2, m_y + 2 SAY8 _opt_row

   _opt_row := PadR( "<c+F9> Briši sve", _opt_d ) + _sep
   _opt_row += PadR( " <F5> Kontrola zbira", _opt_d ) + _sep
   _opt_row += PadR( " <a+F5> Pr.dat", _opt_d ) + _sep
   _opt_row += "<a+B> Blag. <F10> Ost."

   @ m_x + _x_row - 1, m_y + 2 SAY8 _opt_row

   _opt_row := PadR( "<a+T> Briši po uslovu", _opt_d ) + _sep
   _opt_row += PadR( " <F9> sredi rbr.", _opt_d ) + _sep
   _opt_row += PadR( "", _opt_d ) + _sep
   _opt_row += ""

   @ m_x + _x_row, m_y + 2 SAY8 _opt_row

   ObjDbedit( "PN2", _x_row, _y_row, {|| edit_fin_pripr() }, "", "Priprema...", , , , , _help_columns )

   BoxC()

   my_close_all_dbf()

   RETURN



FUNCTION WRbr()

   LOCAL _rec
   LOCAL _rec_2

   _rec := dbf_get_rec()

   IF Val( _rec[ "rbr" ] ) < 2
      @ m_x + 1, m_y + 2 SAY8 "Dokument:" GET _rec[ "idvn" ]
      @ m_x + 1, Col() + 2  GET _rec[ "brnal" ]
      READ
   ENDIF

   SET ORDER TO 0
   GO TOP
   DO WHILE !Eof()
      _rec_2 := dbf_get_rec()
      _rec_2[ "idvn" ]  := _rec[ "idvn" ]
      _rec_2[ "brnal" ] := _rec[ "brnal" ]
      dbf_update_rec( _rec_2 )
      SKIP
   ENDDO

   SET ORDER TO TAG "1"
   GO TOP

   RETURN .T.


FUNCTION vrbr()
   RETURN .T.



FUNCTION o_fin_edit()

   my_close_all_dbf()

   O_VRSTEP
   O_ULIMIT

   IF ( IsRamaGlas() )
      O_FAKT_OBJEKTI
   ENDIF

   O_RJ

   IF gTroskovi == "D"
      O_FOND
      O_FUNK
   ENDIF

   O_PSUBAN
   O_PANAL
   O_PSINT
   O_PNALOG
   O_PAREK
   O_KONTO
   O_PARTN
   O_TNAL
   O_TDOK
   O_NALOG
   O_FIN_PRIPR

   SELECT fin_pripr
   SET ORDER TO TAG "1"
   GO TOP

   RETURN




FUNCTION edit_fin_priprema()

   LOCAL _fakt_params := fakt_params()
   LOCAL _fin_params := fin_params()
   LOCAL _ostav := NIL
   LOCAL _iznos_unesen := .F.
   PARAMETERS fNovi

   IF fNovi .AND. nRbr == 1
      _IdFirma := gFirma
   ENDIF

   IF fNovi
      _OtvSt := " "
   ENDIF

   IF ( ( gRj == "D" ) .AND. fNovi )
      _idrj := cTekucaRj
   ENDIF

   SET CURSOR ON

   IF gNW == "D"
      @  m_x + 1, m_y + 2 SAY8 "Firma: "
      ?? gFirma, "-", gNFirma
      @  m_x + 3, m_y + 2 SAY "NALOG: "
      @  m_x + 3, m_y + 14 SAY "Vrsta:" GET _idvn VALID browse_tnal( @_IdVN, 3, 26 ) PICT "@!"
   ELSE
      @  m_x + 1, m_y + 2 SAY "Firma:" GET _idfirma VALID {|| P_Firma( @_IdFirma, 1, 20 ), _idfirma := Left( _idfirma, 2 ), .T. }
      @  m_x + 3, m_y + 2 SAY "NALOG: "
      @  m_x + 3, m_y + 14 SAY "Vrsta:" GET _idvn VALID browse_tnal( @_IdVN, 3, 26 )
   ENDIF

   READ

   ESC_RETURN 0

   IF fNovi .AND. ( _idfirma <> idfirma .OR. _idvn <> idvn )

      // momenat setovanja broja naloga
      // setujemo sve na 0, ali kada uvedemo globalni brojac
      _brnal := fin_prazan_broj_naloga()
      // _brnal := nextnal( _idfirma, _idvn )
      SELECT  fin_pripr

   ENDIF

   SET KEY K_ALT_K TO DinDem()
   SET KEY K_ALT_O TO KonsultOS()

   @ m_x + 3, m_y + 55 SAY "Broj:" GET _brnal VALID Dupli( _idfirma, _idvn, _brnal ) .AND. !Empty( _brnal )
   @ m_x + 5, m_y + 2 SAY "Redni broj stavke naloga:" GET nRbr PICTURE "9999"
   @ m_x + 7, m_y + 2 SAY "DOKUMENT: "

   // if gNW <> "D"
   IF _fin_params[ "fin_tip_dokumenta" ]
      @ m_x + 7, m_y + 14  SAY "Tip:" GET _IdTipDok VALID browse_tdok( @_IdTipDok, 7, 26 )
   ENDIF

   IF ( IsRamaGlas() )
      @ m_x + 8, m_y + 2 SAY8 "Vezni broj (račun/r.nalog):"  GET _BrDok VALID BrDokOK()
   ELSE
      @ m_x + 8, m_y + 2 SAY "Vezni broj:" GET _brdok
   ENDIF

   @ m_x + 8, m_y + Col() + 2  SAY "Datum:" GET _DatDok

   IF gDatVal == "D"
      @ m_x + 8, Col() + 2 SAY "Valuta" GET _DatVal
   ENDIF

   @ m_x + 11, m_y + 2 SAY "Opis :" GET _opis WHEN {|| .T. } VALID {|| .T. } PICT "@S50"

   IF _fin_params[ "fin_k1" ]
      @ m_x + 11, Col() + 2 SAY "K1" GET _k1 PICT "@!"
   ENDIF

   IF _fin_params[ "fin_k2" ]
      @ m_x + 11, Col() + 2 SAY "K2" GET _k2 PICT "@!"
   ENDIF

   IF _fin_params[ "fin_k3" ]
      IF IzFMKIni( "FIN", "LimitiPoUgovoru_PoljeK3", "N", SIFPATH ) == "D"
         _k3 := K3Iz256( _k3 )
         @ m_x + 11, Col() + 2 SAY "K3" GET _k3 VALID Empty( _k3 ) .OR. P_ULIMIT( @_k3 ) PICT "999"
      ELSE
         @ m_x + 11, Col() + 2 SAY "K3" GET _k3 PICT "@!"
      ENDIF
   ENDIF

   IF _fin_params[ "fin_k4" ]
      IF _fakt_params[ "fakt_vrste_placanja" ]
         @ m_x + 11, Col() + 2 SAY "K4" GET _k4 VALID Empty( _k4 ) .OR. P_VRSTEP( @_k4 ) PICT "@!"
      ELSE
         @ m_x + 11, Col() + 2 SAY "K4" GET _k4 PICT "@!"
      ENDIF
   ENDIF

   IF gRj == "D"
      @ m_x + 11, Col() + 2 SAY "RJ" GET _idrj VALID Empty( _idrj ) .OR. P_Rj( @_idrj ) PICT "@!"
   ENDIF

   IF gTroskovi == "D"
      @ m_x + 12, m_y + 22 SAY "      Funk." GET _Funk VALID Empty( _Funk ) .OR. P_Funk( @_Funk ) PICT "@!"
      @ m_x + 12, m_y + 44 SAY "      Fond." GET _Fond VALID Empty( _Fond ) .OR. P_Fond( @_Fond ) PICT "@!"
   ENDIF

   @ m_x + 13, m_y + 2 SAY "Konto  :" GET _IdKonto ;
      PICT "@!" ;
      VALID Partija( @_IdKonto ) .AND. P_Konto( @_IdKonto, 13, 20 ) ;
      .AND. BrDokOK() .AND. MinKtoLen( _IdKonto ) .AND. fin_pravilo_konto()


   @ m_x + 14, m_y + 2 SAY "Partner:" GET _IdPartner PICT "@!" ;
      VALID ;
      {|| iif( Empty( _idpartner ), Reci( 14, 20, Space( 25 ) ), ), ;
      ( P_Firma( @_IdPartner, 14, 20 ) ) .AND. fin_pravilo_partner() .AND. ;
      iif( g_knjiz_help == "D" .AND. !Empty( _idpartner ), g_box_stanje( _idpartner, _idkonto, NIL ), .T. ) } ;
      WHEN ;
      {|| iif( ChkKtoMark( _idkonto ), .T., .F. ) }


   @ m_x + 16, m_y + 2  SAY8 "Duguje/Potražuje (1/2):" GET _D_P VALID V_DP() .AND. fin_pravilo_dug_pot() .AND. fin_pravilo_broj_veze()

   @ m_x + 16, m_y + 65 GET _ostav PUSHBUTTON  CAPTION "<Otvorene stavke>" WHEN {|| _iznos_unesen } VALID {|| _iznos_unesen := .F., .T. } ;
      SIZE X 15 Y 2 STATE {| param| KonsultOs( param ) }

   @ m_x + 16, m_y + 46  GET _IznosBHD  PICTURE "999999999999.99" WHEN {|| _iznos_unesen := .T., .T. }

   @ m_x + 17, m_y + 46  GET _IznosDEM  PICTURE '9999999999.99' ;
      WHEN {|| DinDEM( , , "_IZNOSBHD" ), .T. }

   READ

   IF ( gRJ == "D" .AND. cTekucaRJ <> _idrj )
      cTekucaRJ := _idrj
      SetTekucaRJ( cTekucaRJ )
   ENDIF

   _IznosBHD := Round( _iznosbhd, 2 )
   _IznosDEM := Round( _iznosdem, 2 )

   ESC_RETURN 0

   SET KEY K_ALT_K TO

   _k3 := K3U256( _k3 )
   _Rbr := Str( nRbr, 4 )

   SELECT fin_pripr

   RETURN 1



FUNCTION MinKtoLen( cIdKonto )

   IF gKtoLimit == "N"
      RETURN .T.
   ENDIF

   IF gKtoLimit == "D" .AND. gnKtoLimit > 0
      IF Len( AllTrim( cIdKonto ) ) > gnKtoLimit
         RETURN .T.
      ELSE
         MsgBeep( "Dužina konta mora biti veća od " + AllTrim( Str( gnKtoLimit ) ) )
         RETURN .F.
      ENDIF
   ENDIF

   RETURN



/*! \fn CheckMark(cIdKonto)
 *  \brief Provjerava da li je konto markiran, ako nije izbrisi zapamceni _IdPartner
 *  \param cIdKonto - oznaka konta
 *  \param cIdPartner - sifra partnera koja ce se ponuditi
 *  \param cNewPartner - zapamcena sifra partnera
 */

FUNCTION CheckMark( cIdKonto, cIdPartner, cNewPartner )

   IF ( ChkKtoMark( _idkonto ) )
      cIdPartner := cNewPartner
   ELSE
      cIdPartner := Space( 6 )
   ENDIF

   RETURN .T.



/*! \fn Partija(cIdKonto)
 *  \brief
 *  \param cIdKonto - oznaka konta
 */

FUNCTION Partija( cIdKonto )

   IF Right( Trim( cIdkonto ), 1 ) == "*"
      SELECT parek
      HSEEK StrTran( cIdkonto, "*", "" ) + " "
      cIdkonto := idkonto
      SELECT fin_pripr
   ENDIF

   RETURN .T.



// -----------------------------------------------------
// Ispis duguje/potrazuje u domacoj i pomocnoj valuti
// -----------------------------------------------------
FUNCTION V_DP()

   SetPos( m_x + 16, m_y + 30 )

   IF _d_p == "1"
      ?? "   DUGUJE"
   ELSE
      ??U "POTRAŽUJE"
   ENDIF

   ?? " " + ValDomaca()

   SetPos( m_x + 17, m_y + 30 )

   IF _d_p == "1"
      ?? "   DUGUJE"
   ELSE
      ??U "POTRAŽUJE"
   ENDIF

   ?? " " + ValPomocna()

   RETURN _d_p $ "12"



// -----------------------------------------------------
// konvertovanje valute u pripremi...
// -----------------------------------------------------
FUNCTION fin_konvert_valute( rec, tip )

   LOCAL _ok := .T.
   LOCAL _kurs := Kurs( rec[ "datdok" ] )

   IF tip == "P"
      rec[ "iznosbhd" ] := rec[ "iznosdem" ] * _kurs
   ELSEIF tip == "D"
      IF Round( _kurs, 4 ) == 0
         rec[ "iznosdem" ] := 0
      ELSE
         rec[ "iznosdem" ] := rec[ "iznosbhd" ] / _kurs
      ENDIF
   ENDIF

   RETURN _ok



/*! \fn DinDem(p1,p2,cVar)
 *  \brief
 *  \param p1
 *  \param p2
 *  \param cVar
 */
FUNCTION DinDem( p1, p2, cVar )

   LOCAL _kurs

   _kurs := Kurs( _datdok )

   IF cVar == "_IZNOSDEM"
      _iznosbhd := _iznosdem * _kurs
   ELSEIF cVar = "_IZNOSBHD"
      IF Round( _kurs, 4 ) == 0
         _iznosdem := 0
      ELSE
         _iznosdem := _iznosbhd / _kurs
      ENDIF
   ENDIF

   AEval( GetList, {| o| o:display() } )

   RETURN



// poziva je ObjDbedit u KnjNal
// c-T  -  Brisanje stavke,  F5 - kontrola zbira za jedan nalog
// F6 -  Suma naloga, ENTER-edit stavke, c-A - ispravka naloga


// ---------------------------------------------------
// setuj datval na osnovu datdok u pripremi
// ---------------------------------------------------
STATIC FUNCTION set_datval_datdok()

   LOCAL _ret := .F.
   LOCAL _dana, _dat_dok, _id_konto

   IF Pitanje(, "Za konto u nalogu postaviti datum val. DATDOK->DATVAL", "N" ) == "N"
      RETURN _ret
   ENDIF

   _id_konto := Space( 7 )
   _dat_dok := Date()
   _dana := 15

   Box(, 5, 60 )

   @ m_x + 1, m_y + 2 SAY "Promjena za konto  " GET _id_konto
   @ m_x + 3, m_y + 2 SAY "Novi datum dok " GET _dat_dok
   @ m_x + 5, m_y + 2 SAY "uvecati stari datdok za (dana) " GET _dana PICT "99"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ret
   ENDIF

   SELECT fin_pripr
   GO TOP

   DO WHILE !Eof()

      IF field->idkonto == _id_konto .AND. Empty( field->datval )

         // bilo je promjena
         _ret := .T.

         _rec := dbf_get_rec()
         _rec[ "datval" ] := field->datdok + _dana
         _rec[ "datdok" ] := _dat_dok

         dbf_update_rec( _rec )

      ENDIF
      SKIP
   ENDDO

   GO TOP

   RETURN _ret




/*! \fn edit_fin_pripr()
 *  \brief Ostale operacije u ispravki stavke
 */

FUNCTION edit_fin_pripr()

   LOCAL nTr2
   LOCAL lLogUnos := .F.
   LOCAL lLogBrisanje := .F.
   LOCAL _log_info

   IF ( Ch == K_CTRL_T .OR. Ch == K_ENTER ) .AND. RecCount2() == 0
      RETURN DE_CONT
   ENDIF

   SELECT fin_pripr

   DO CASE

      // setuj datdok na osnovu datval
   CASE Ch == K_ALT_F5

      IF set_datval_datdok()
         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   CASE Ch == K_F8

      // brisi stavke u pripremi od - do
      IF br_oddo() = 1
         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   CASE Ch == K_F9

      SrediRbrFin()
      RETURN DE_REFRESH

   CASE Ch == K_ALT_T

      IF _brisi_pripr_po_uslovu()
         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   CASE Ch == K_CTRL_T

      IF Pitanje(, "Želite izbrisati ovu stavku ?", "D" ) == "D"

         cBDok := field->idfirma + "-" + field->idvn + "-" + field->brnal
         cStavka := field->rbr
         cBKonto := field->idkonto
         cBDP := field->d_p
         dBDatnal := field->datdok
         cBIznos := Str( field->iznosbhd )

         my_rlock()
         DELETE
         my_unlock()
         _t_rec := RecNo()
         my_dbf_pack()
         GO ( _t_rec )

         BrisiPBaze()

         log_write( "F18_DOK_OPER: fin, brisanje stavke u pripremi: " + AllTrim( cBDok ) + " stavka br: " + cStavka, 2 )

         RETURN DE_REFRESH
      ENDIF

      RETURN DE_CONT

   CASE Ch == K_F5

      kontrola_zbira_naloga()
      RETURN DE_REFRESH

   CASE Ch == K_ENTER

      Box( "ist", MAXROWS() - 5, MAXCOLS() - 8, .F. )
      set_global_vars_from_dbf( "_" )

      nRbr := Val( _Rbr )

      IF edit_fin_priprema( .F. ) == 0
         BoxC()
         RETURN DE_CONT
      ELSE
         dbf_update_rec( get_dbf_global_memvars( "_" ), .F. )
         BrisiPBaze()
         BoxC()
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == K_CTRL_A

      PushWA()
      SELECT fin_pripr

      Box( "anal", MAXROWS() - 4, MAXCOLS() - 5, .F., "Ispravka naloga" )

      nDug := 0
      nPot := 0

      DO WHILE !Eof()
         SKIP

         nTR2 := RecNo()
         SKIP -1
         set_global_vars_from_dbf()
         nRbr := Val( _Rbr )
         @ m_x + 1, m_y + 1 CLEAR TO m_x + 19, m_y + 74
         IF edit_fin_priprema( .F. ) == 0
            EXIT
         ELSE
            BrisiPBaze()
         ENDIF
         IF _D_P == '1'
            nDug += _IznosBHD
         ELSE
            nPot += _IznosBHD
         ENDIF

         @ m_x + 19, m_y + 1 SAY "ZBIR NALOGA:"
         @ m_x + 19, m_y + 14 SAY nDug PICTURE '9 999 999 999.99'
         @ m_x + 19, m_y + 35 SAY nPot PICTURE '9 999 999 999.99'
         @ m_x + 19, m_y + 56 SAY nDug - nPot PICTURE '9 999 999 999.99'
         Inkey( 10 )

         SELECT fin_pripr
         dbf_update_rec( get_dbf_global_memvars(), .F. )
         GO nTR2
      ENDDO

      PopWA()
      BoxC()
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_N

      // nove stavke
      SELECT fin_pripr
      nDug := 0
      nPot := 0
      nPrvi := 0
      GO TOP
      DO WHILE ! Eof()
         // kompletan nalog sumiram
         IF D_P = '1'
            nDug += IznosBHD
         ELSE
            nPot += IznosBHD
         ENDIF
         SKIP
      ENDDO
      GO BOTTOM

      Box( "knjn", MAXROWS() - 4, MAXCOLS() - 3, .F., "Knjizenje naloga - nove stavke" )
      DO WHILE .T.
         set_global_vars_from_dbf()

         IF ( IsRamaGlas() )
            _idKonto := Space( Len( _idKonto ) )
            _idPartner := Space( Len( _idPartner ) )
            _brDok := Space( Len( _brDok ) )
         ENDIF

         nRbr := Val( _Rbr ) + 1
         @ m_x + 1, m_y + 1 CLEAR TO m_x + 19, m_y + 76
         IF edit_fin_priprema( .T. ) == 0
            EXIT
         ELSE
            BrisiPBaze()
         ENDIF

         IF _D_P = '1'
            nDug += _IznosBHD
         ELSE
            nPot += _IznosBHD
         ENDIF
         @ m_x + 19, m_y + 1 SAY "ZBIR NALOGA:"
         @ m_x + 19, m_y + 14 SAY nDug PICTURE '9 999 999 999.99'
         @ m_x + 19, m_y + 35 SAY nPot PICTURE '9 999 999 999.99'
         @ m_x + 19, m_y + 56 SAY nDug - nPot PICTURE '9 999 999 999.99'

         Inkey( 10 )

         SELECT fin_pripr
         APPEND BLANK
         dbf_update_rec( get_dbf_global_memvars(), .F. )

         IF lLogUnos
            cOpis := fin_pripr->idfirma + "-" + ;
               fin_pripr->idvn + "-" + ;
               fin_pripr->brnal

         ENDIF

      ENDDO
      BoxC()

      RETURN DE_REFRESH

   CASE Ch == K_CTRL_F9

      IF Pitanje(, "Želite li izbrisati pripremu !!????", "N" ) == "D"

         _log_info := fin_pripr->idfirma + "-" + fin_pripr->idvn + "-" + fin_pripr->brnal

         fin_reset_broj_dokumenta( fin_pripr->idfirma, fin_pripr->idvn, fin_pripr->brnal )

         my_dbf_zap()

         BrisiPBaze()

         log_write( "F18_DOK_OPER: fin, brisanje pripreme: " + _log_info, 2  )

      ENDIF

      RETURN DE_REFRESH

   CASE Ch == K_CTRL_P


      fin_set_broj_dokumenta()
      fin_nalog_priprema()
      o_fin_edit()


      RETURN DE_REFRESH


   CASE Upper( Chr( Ch ) ) == "X"

      fin_set_broj_dokumenta()

      my_close_all_dbf()
      fin_gen_ptabele_stampa_nalozi( .T. )
      my_close_all_dbf()

      fin_azuriranje_naloga( .T. )
      o_fin_edit()
      RETURN DE_REFRESH


   CASE is_key_alt_a( Ch )

      fin_set_broj_dokumenta()
      fin_azuriranje_naloga()
      o_fin_edit()
      RETURN DE_REFRESH

   CASE Ch == K_ALT_B

      fin_set_broj_dokumenta()

      my_close_all_dbf()
      Blagajna()

      o_fin_edit()

      RETURN DE_REFRESH

   CASE Ch == K_ALT_I

      fin_set_broj_dokumenta()
      OiNIsplate()

      RETURN DE_CONT

#ifdef __PLATFORM__DARWIN
   CASE Ch == Asc( "0" )
#else
   CASE Ch == K_F10
#endif
      OstaleOpcije()
      RETURN DE_REFRESH

   CASE Upper( Chr( Ch ) ) == "P"

      IF RecCount() != 0
         MsgBeep( "Povrat nije nedozvoljen, priprema nije prazna !" )
         RETURN DE_CONT
      ENDIF

      my_close_all_dbf()
      povrat_fin_naloga()
      o_fin_edit()

      RETURN DE_REFRESH

   ENDCASE

   RETURN DE_CONT


// ----------------------------------------
// brisi stavke iz pripreme od-do
// ----------------------------------------
STATIC FUNCTION br_oddo()

   LOCAL nRet := 1
   LOCAL GetList := {}
   LOCAL cOd := Space( 4 )
   LOCAL cDo := Space( 4 )
   LOCAL nOd
   LOCAL nDo

   Box(, 1, 31 )
   @ m_x + 1, m_y + 2 SAY "Brisi stavke od:" GET cOd VALID _rbr_fix( @cOd )
   @ m_x + 1, Col() + 1 SAY "do:" GET cDo VALID _rbr_fix( @cDo )
   READ
   BoxC()

   IF LastKey() == K_ESC .OR. ;
         Pitanje(, "Sigurno zelite brisati zapise ?", "N" ) == "N"
      RETURN 0
   ENDIF

   GO TOP

   DO WHILE !Eof()

      cRbr := field->rbr

      IF cRbr >= cOd .AND. cRbr <= cDo
         my_delete()
      ENDIF

      SKIP
   ENDDO

   my_dbf_pack()

   GO TOP

   RETURN nRet


// -----------------------------------------
// fiksiranje rednog broja
// -----------------------------------------
STATIC FUNCTION _rbr_fix( cStr )

   cStr := PadL( AllTrim( cStr ), 4 )

   RETURN .T.



FUNCTION IdPartner( cIdPartner )

   LOCAL cRet

   cRet := cIdPartner

   RETURN cRet



/*! \fn DifIdP(cIdPartner)
 *  \brief Formatira cIdPartner na 6 mjesta ako mu je duzina 8
 *  \param cIdPartner - id partnera
 */

FUNCTION DifIdP( cIdPartner )
   RETURN 0



/*! \fn BrisiPBaze()
 *  \brief Brisi pomocne baze
 */

FUNCTION BrisiPBaze()

   PushWA()

   SELECT F_PSUBAN
   my_dbf_zap()
   SELECT F_PANAL
   my_dbf_zap()
   SELECT F_PSINT
   my_dbf_zap()
   SELECT F_PNALOG
   my_dbf_zap()

   PopWA()

   RETURN ( NIL )


/*! \fn fin_tek_rec_2()
 *  \brief Tekuci zapis
 */

FUNCTION fin_tek_rec_2()

   nSlog ++
   @ m_x + 1, m_y + 2 SAY PadC( AllTrim( Str( nSlog ) ) + "/" + AllTrim( Str( nUkupno ) ), 20 )
   @ m_x + 2, m_y + 2 SAY "Obuhvaceno: " + Str( 0 )

   RETURN ( NIL )



/*! \fn OstaleOpcije()
 *  \brief Ostale opcije koje se pozivaju sa <F10>
 */

FUNCTION OstaleOpcije()

   PRIVATE opc[ 4 ]

   opc[ 1 ] := "1. novi datum->datum, stari datum->dat.valute "
   opc[ 2 ] := "2. podijeli nalog na vise dijelova"

   h[ 1 ] := h[ 2 ] := h[ 3 ] := h[ 4 ] := ""
   PRIVATE Izbor := 1
   PRIVATE am_x := m_x, am_y := m_y
   my_close_all_dbf()
   DO WHILE .T.
      Izbor := menu( "prip", opc, Izbor, .F. )
      DO CASE
      CASE Izbor == 0
         EXIT
      CASE izbor == 1
         SetDatUPripr()
      CASE izbor == 2
         PodijeliN()
      ENDCASE
   ENDDO
   m_x := am_x
   m_y := am_y
   o_fin_edit()

   RETURN


/*! \fn PodijeliN()
 *  \brief
 */

FUNCTION PodijeliN()

   LOCAL _rec
   LOCAL nDug, nPot
   LOCAL nRbr1 := nRbr2 := nRbr3 := nRbr4 := 0
   LOCAL cBRnal1, cBrnal2, cBrnal3, cBrnal4, cBrnal5
   LOCAL dDatDok
   LOCAL cPomKTO := "9999999"
   LOCAL cIdFirma, cIdVN, cBrNal

   IF !SigmaSif( "PVNAPVN" )
      RETURN
   ENDIF

   O_FIN_PRIPR

   cBRnal1 := cBrnal2 := cBrnal3 := cBrnal4 := cBrnal5 := fin_pripr->brnal
   dDatDok := fin_pripr->datdok

   Box( , 10, 60 )

   @ m_x + 1, m_y + 2 SAY "Redni broj / 1 " GET nRbr1
   @ m_x + 1, Col() + 2 SAY "novi broj naloga" GET cBRNAL1
   @ m_x + 2, m_y + 2 SAY "Redni broj / 2 " GET nRbr2
   @ m_x + 2, Col() + 2 SAY "novi broj naloga" GET cBRNAL2
   @ m_x + 3, m_y + 2 SAY "Redni broj / 3 " GET nRbr3
   @ m_x + 3, Col() + 2 SAY "novi broj naloga" GET cBRNAL3
   @ m_x + 4, m_y + 2 SAY "Redni broj / 4 " GET nRbr4
   @ m_x + 4, Col() + 2 SAY "novi broj naloga" GET cBRNAL4

   @ m_x + 6, m_y + 6 SAY "Zadnji dio, broj naloga  " GET cBrnal5
   @ m_x + 8, m_y + 6 SAY "Pomocni konto  " GET cPomKTO
   @ m_x + 9, m_y + 6 SAY "Datum dokumenta" GET dDatDok

   READ

   Boxc()

   IF LastKey() == K_ESC
      my_close_all_dbf()
      RETURN DE_CONT
   ENDIF


   nDug := nPot := 0

   cIdfirma := idfirma
   cIdVN    := IDVN
   cBrnal   := BRNAL

   GO TOP
   MsgO( "Prvi krug..." )

   DO WHILE !Eof()

      IF d_p == "1"
         nDug += iznosbhd
      ELSE
         nPot += iznosbhd
      ENDIF

      IF nRbr1 <> 0 .AND. nRbr1 == Val( fin_pripr->Rbr )
         nRbr := nRbr1

      ELSEIF nRbr2 <> 0 .AND. nRbr2 == Val( fin_pripr->Rbr )
         nRbr := nRbr2

      ELSEIF nRbr3 <> 0 .AND. nRbr3 == Val( fin_pripr->Rbr )
         nRbr := nRbr3

      ELSEIF nRbr4 <> 0 .AND. nRbr4 == Val( fin_pripr->Rbr )
         nRbr := nRbr4
      ELSE
         nRbr := 0  // nista
      ENDIF

      IF nRbr <> 0

         APPEND BLANK
         _rec := dbf_get_rec()
         _rec[ "idvn" ]    := cIdvn
         _rec[ "idfirma" ] := cIdfirma
         _rec[ "brnal" ]   := cBrnal
         _rec[ "idkonto" ] := cPomKTO
         _rec[ "datdok" ]  := dDatDok


         IF nDug > nPot // dugovni saldo
            _rec[ "d_p" ]      := "2"
            _rec[ "iznosbhd" ] :=  nDug - nPot
         ELSE
            _rec[ "d_p" ]      := "1"
            _rec[ "iznosbhd" ] :=  nPot - nDug
         ENDIF

         _rec[ "rbr" ] := Str( nRbr, 4 )
         dbf_update_rec( _rec )

         // slijedi dodavanje protustavke
         APPEND BLANK
         _rec[ "iznosbhd" ] :=  -_rec[ "iznosbhd" ]
         _rec[ "opis" ]     := ">prenos iz p.n.<"
         dbf_update_rec( _rec )

         IF _d_p == "2"
            nPot := iznosbhd
            nDug := 0
         ELSE
            nDug := iznosbhd
            nPot := 0
         ENDIF

      ENDIF


      SKIP
   ENDDO

   MsgC()

   MsgO( "Drugi krug..." )
   SET ORDER TO
   GO TOP
   my_flock()
   DO WHILE !Eof()
      IF nRbr1 <> 0 .AND. Val( fin_pripr->Rbr ) <= nRbr1
         IF opis = ">prenos iz p.n.<"   .AND. idkonto = cPomKTO
            IF nRbr2 = 0
               REPLACE brnal WITH cBrnal5
            ELSE
               REPLACE brnal WITH cBrnal2
            ENDIF
         ELSE
            REPLACE brnal WITH cBrnal1
         ENDIF
      ELSEIF nRbr2 <> 0 .AND. Val( fin_pripr->Rbr ) <= nRbr2
         IF opis = ">prenos iz p.n.<"     .AND. idkonto = cPomKTO
            IF nRbr3 = 0
               REPLACE brnal WITH cBrnal5
            ELSE
               REPLACE brnal WITH cBrnal3
            ENDIF
         ELSE
            REPLACE brnal WITH cBrnal2
         ENDIF
      ELSEIF nRbr3 <> 0 .AND. Val( fin_pripr->Rbr ) <= nRbr3
         IF opis = ">prenos iz p.n.<"      .AND. idkonto = cPomKTO
            IF nRbr4 = 0
               REPLACE brnal WITH cBrnal5
            ELSE
               REPLACE brnal WITH cBrnal4
            ENDIF
         ELSE
            REPLACE brnal WITH cBrnal3
         ENDIF
      ELSEIF nRbr4 <> 0 .AND. Val( fin_pripr->Rbr ) <= nRbr4
         IF opis = ">prenos iz p.n.<"    .AND. idkonto = cPomKTO
            REPLACE brnal WITH cBrnal5
         ELSE
            REPLACE brnal WITH cBrnal4
         ENDIF
      ELSE
         REPLACE brnal WITH cBrnal5
      ENDIF
      SKIP
   ENDDO
   my_unlock()
   MsgC()

   my_close_all_dbf()

   RETURN DE_REFRESH



FUNCTION BrDokOK()

   LOCAL nArr
   LOCAL lOK
   LOCAL nLenBrDok

   IF ( !IsRamaGlas() )
      RETURN .T.
   ENDIF
   nArr := Select()
   lOK := .T.
   nLenBrDok := Len( _brDok )
   SELECT konto
   SEEK _idkonto
   IF field->oznaka = "TD"
      SELECT rnal
      HSEEK PadR( _brDok, 10 )
      IF !Found() .OR. Empty( _brDok )
         MsgBeep( "Unijeli ste nepostojeci broj radnog naloga. Otvaram sifrarnik radnih##naloga da biste mogli izabrati neki od postojecih!" )
         P_fakt_objekti( @_brDok, 9, 2 )
         _brDok := PadR( _brDok, nLenBrDok )
         ShowGets()
      ENDIF
   ENDIF
   SELECT ( nArr )

   RETURN lOK




FUNCTION SetTekucaRJ( cRJ )

   set_metric( "fin_knjiz_tek_rj", my_home(), cRJ )

   RETURN



FUNCTION GetTekucaRJ()
   RETURN fetch_metric( "fin_knjiz_tek_rj", my_home(), PadR( "", __rj_len ) )




// --------------------------------------------------------
// brisanje podataka pripreme po uslovu
// --------------------------------------------------------
STATIC FUNCTION _brisi_pripr_po_uslovu()

   LOCAL _params
   LOCAL _od_broj, _do_broj, _partn, _konto, _opis, _br_veze, _br_nal, _tip_nal
   LOCAL _deleted := .F.
   LOCAL _delete_rec := .F.
   LOCAL _ok := .F.

   IF !_brisi_pripr_uslovi( @_params )
      RETURN _ok
   ENDIF

   IF Pitanje(, "Sigurno zelite izvrsiti brisanje podataka (D/N)?", "N" ) == "N"
      RETURN _ok
   ENDIF

   // ovo su dati parametri...
   _od_broj := _params[ "rbr_od" ]
   _do_broj := _params[ "rbr_do" ]
   _partn := _params[ "partn" ]
   _konto := _params[ "konto" ]
   _opis := _params[ "opis" ]
   _br_veze := _params[ "veza" ]
   _br_nal := _params[ "broj" ]
   _tip_nal := _params[ "vn" ]

   SELECT fin_pripr
   // skini order
   SET ORDER TO
   GO TOP

   DO WHILE !Eof()

      _delete_rec := .F.

      // idemo sada na uslove i brisanje podataka...
      IF !Empty( _br_nal )
         _tmp := Parsiraj( _br_nal, "brnal" )
         if &_tmp
            _delete_rec := .T.
         ENDIF
      ENDIF

      IF !Empty( _tip_nal )
         _tmp := Parsiraj( _tip_nal, "idvn" )
         if &_tmp
            _delete_rec := .T.
         ENDIF
      ENDIF

      IF !Empty( _partn )
         _tmp := Parsiraj( _partn, "idpartner" )
         if &_tmp
            _delete_rec := .T.
         ENDIF
      ENDIF

      IF !Empty( _konto )
         _tmp := Parsiraj( _konto, "idkonto" )
         if &_tmp
            _delete_rec := .T.
         ENDIF
      ENDIF

      IF !Empty( _opis )
         _tmp := Parsiraj( _opis, "opis" )
         if &_tmp
            _delete_rec := .T.
         ENDIF
      ENDIF

      IF !Empty( _br_veze )
         _tmp := Parsiraj( _br_veze, "brdok" )
         if &_tmp
            _delete_rec := .T.
         ENDIF
      ENDIF

      // redni brojevi...
      IF ( _od_broj + _do_broj ) > 0
         IF Val( field->rbr ) >= _od_broj .AND. Val( field->rbr ) <= _do_broj
            _delete_rec := .T.
         ENDIF
      ENDIF

      // brisi ako treba ?
      IF _delete_rec
         _deleted := .T.
         my_delete()
      ENDIF

      SKIP

   ENDDO

   SELECT fin_pripr
   SET ORDER TO TAG "1"
   GO TOP

   IF _deleted

      _ok := .T.

      my_dbf_pack()

      // renumerisi fin pripremu...
      sredirbrfin( .T. )

   ELSE
      MsgBeep( "Nema stavki za brisanje po zadanom kriteriju !" )
   ENDIF

   RETURN _ok


// -------------------------------------------------------
// uslovi brisanja pripreme po zadatom uslovu
// -------------------------------------------------------
STATIC FUNCTION _brisi_pripr_uslovi( param )

   LOCAL _ok := .F.
   LOCAL _x := 1
   LOCAL _od_broja := 0
   LOCAL _do_broja := 0
   LOCAL _partn := Space( 500 )
   LOCAL _konto := Space( 500 )
   LOCAL _opis := Space( 500 )
   LOCAL _br_veze := Space( 500 )
   LOCAL _vn := Space( 200 )
   LOCAL _br_nal := Space( 500 )

   Box(, 13, 70 )

   @ m_x + _x, m_y + 2 SAY "Brisanje pripreme po zadatom uslovu ***"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "brisi od rednog broja:" GET _od_broja PICT "9999999"
   @ m_x + _x, Col() + 1 SAY "do:" GET _do_broja PICT "9999999"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "               vrste naloga:" GET _vn PICT "@S30"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "             brojeve naloga:" GET _br_nal PICT "@S30"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "stavke koje sadrze partnere:" GET _partn PICT "@S30"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "   stavke koje sadrze konta:" GET _konto PICT "@S30"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "    stavke koje sadrze opis:" GET _opis PICT "@S30"

   ++ _x
   @ m_x + _x, m_y + 2 SAY " stavke koje sadrze br.veze:" GET _br_veze PICT "@S30"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   // dodaj u matricu sa parametrima
   param := hb_Hash()
   PARAM[ "rbr_od" ] := _od_broja
   PARAM[ "rbr_do" ] := _do_broja
   PARAM[ "partn" ] := _partn
   PARAM[ "konto" ] := _konto
   PARAM[ "opis" ] := _opis
   PARAM[ "veza" ] := _br_veze
   PARAM[ "broj" ] := _br_nal
   PARAM[ "vn" ] := _vn

   _ok := .T.

   RETURN _ok
