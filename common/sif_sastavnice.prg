/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"

MEMVAR wId, wTip, wIdTarifa, wId2
MEMVAR ImeKol, Kol
MEMVAR m_x, m_y
MEMVAR cIdTek // show_sast, PRIVATE var cIdTek

FUNCTION p_sast( cId, dx, dy )

   PRIVATE ImeKol
   PRIVATE Kol

   SELECT roba

   set_a_kol( @ImeKol, @Kol )

   GO TOP

   RETURN PostojiSifra( F_ROBA, "IDP", MAXROWS() -15, MAXCOLS() -3, ;
      "Gotovi proizvodi: <ENTER> Unos norme, <Ctrl-F4> Kopiraj normu, <F7>-lista norm.", ;
      @cId, dx, dy, {| Ch| sast_key_handler( Ch ) } )


// ---------------------------------
// setovanje kolona tabele
// ---------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   LOCAL cPom
   LOCAL cPom2, nI

   aImeKol := {}
   aKol := {}

   AAdd( aImeKol, { PadC( "ID", 10 ), {|| field->id }, "id", {|| .T. }, {|| sifra_postoji( wId ) } } )
   AAdd( aImeKol, { PadC( "Naziv", 20 ), {|| PadR( field->naz, 20 ) }, "naz" } )
   AAdd( aImeKol, { PadC( "JMJ", 3 ), {|| field->jmj }, "jmj" } )
   AAdd( aImeKol, { PadC( "VPC", 10 ), {|| Transform( field->VPC, "999999.999" ) }, "vpc" } )

   // VPC2
   IF ( roba->( FieldPos( "vpc2" ) ) <> 0 )
      AAdd( aImeKol, { PadC( "VPC2", 10 ), {|| Transform( field->VPC2, "999999.999" ) }, "vpc2" } )
   ENDIF

   AAdd( aImeKol, { PadC( "MPC", 10 ), {|| Transform( field->MPC, "999999.999" ) }, "mpc" } )

   FOR nI := 2 TO 10
      cPom := "MPC" + AllTrim( Str( nI ) )
      cPom2 := '{|| transform(' + cPom + ',"999999.999")}'
      IF roba->( FieldPos( cPom ) )  <>  0
         AAdd ( aImeKol, { PadC( cPom, 10 ), ;
            &( cPom2 ), ;
            cPom } )
      ENDIF
   NEXT

   AAdd( aImeKol, { PadC( "NC", 10 ), {|| Transform( field->NC, "999999.999" ) }, "NC" } )

   AAdd( aImeKol, { "Tarifa", {|| field->IdTarifa }, "IdTarifa", {|| .T. }, {|| P_Tarifa( @wIdTarifa ), roba_opis_edit() } } )

   AAdd( aImeKol, { "K1", {|| field->K1 }, "K1", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "Tip", {|| " " + field->Tip + " " }, "Tip", {|| .T. }, {|| wTip $ "P" } } )

   FOR nI := 1 TO Len( aImeKol )
      AAdd( aKol, nI )
   NEXT

   RETURN .T.




STATIC FUNCTION sast_key_handler( Ch )

   LOCAL nTRec, nReturn

   nTRec := RecNo()

   nReturn := DE_CONT

   DO CASE

   CASE Ch == K_CTRL_F9
      // brisanje sastavnica i proizvoda
      bris_sast()
      nReturn := 7

   CASE Ch == K_ENTER
      // prikazi sastavnicu
      show_sast()
      nReturn := DE_REFRESH

   CASE Ch == K_CTRL_F4

      copy_sast() // kopiranje sastavnica u drugi proizvod
      nReturn := DE_REFRESH

   CASE Ch == K_F7

      ISast() // lista sastavnica
      nReturn := DE_REFRESH

   CASE Ch == K_F10
      // ostale opcije
      ost_opc_sast()
      nReturn := DE_CONT

   ENDCASE

   SET ORDER TO TAG "IDP"
   GO ( nTRec )

   RETURN nReturn



STATIC FUNCTION ost_opc_sast() // ostale opcije nad sastavnicama

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1
   LOCAL _am_x := m_x
   LOCAL _am_y := m_y

   AAdd( _opc, "1. zamjena sirovine u svim sastavnicama                 " )
   AAdd( _opcexe, {|| sast_repl_all() } )
   AAdd( _opc, "2. promjena ucesca pojedine sirovine u svim sastavnicama" )
   AAdd( _opcexe, {|| pr_uces_sast() } )
   AAdd( _opc, "------------------------------------" )
   AAdd( _opcexe, {|| notimp() } )
   AAdd( _opc, "L. pregled sastavnica sa pretpostavkama sirovina" )
   AAdd( _opcexe, {|| pr_pr_sast() } )
   AAdd( _opc, "M. lista sastavnica koje (ne)sadrze sirovinu x" )
   AAdd( _opcexe, {|| pr_ned_sast() } )
   AAdd( _opc, "D. sifre sa duplim sastavnicama" )
   AAdd( _opcexe, {|| pr_dupl_sast() } )
   AAdd( _opc, "P. pregled brojnog stanja sastavnica" )
   AAdd( _opcexe, {|| pr_br_sast() } )
   AAdd( _opc, "E. export sastavnice -> dbf" )
   AAdd( _opcexe, {|| _exp_sast_dbf() } )
   AAdd( _opc, "F. export roba -> dbf" )
   AAdd( _opcexe, {|| exp_roba_dbf() } )

   f18_menu( "o_sast", .F., _izbor, _opc, _opcexe )

   m_x := _am_x
   m_y := _am_y

   RETURN .T.



// ------------------------------------
// ispravka sastavnice
// ------------------------------------
STATIC FUNCTION EdSastBlok( char )

   DO CASE
   CASE char == K_CTRL_F9
      MsgBeep( "Nedozvoljena opcija !!!" )
      RETURN 7
   ENDCASE

   RETURN DE_CONT


// --------------------------------
// sastavnice setovanje kolona
// --------------------------------
STATIC FUNCTION sast_a_kol( aImeKol, aKol )

   LOCAL nI

   aImeKol := {}
   aKol := {}


   AAdd( aImeKol, { "R.Br", {|| field->r_br }, "r_br", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { PadC( "Sifra sirovine", 20 ), {|| field->id2 }, "id2", {|| .T. }, {|| wId := cIdTek, p_roba( @wId2 ) } } )
   AAdd( aImeKol, { "Kolicina", {|| field->kolicina }, "kolicina" } )

   FOR nI := 1 TO Len( aImeKol )
      AAdd( aKol, nI )
   NEXT

   RETURN .T.



FUNCTION exp_roba_dbf() // export robe u dbf

   LOCAL aDbf := {}

   AAdd( aDbf, { "ID", "C", 10, 0 } )
   AAdd( aDbf, { "NAZIV", "C", 200, 0 } )
   AAdd( aDbf, { "JMJ", "C", 3, 0 } )
   AAdd( aDbf, { "NC", "N", 12, 2 } )
   AAdd( aDbf, { "VPC", "N", 12, 2 } )
   AAdd( aDbf, { "MPC", "N", 12, 2 } )

   t_exp_create( aDbf )
   O_R_EXP
   O_ROBA
   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   box(, 1, 50 )
   DO WHILE !Eof()

      @ m_x + 1, m_y + 2 SAY "upisujem: " + roba->id

      SELECT r_export
      APPEND BLANK

      REPLACE field->id WITH roba->id
      REPLACE field->naziv WITH roba->naz
      REPLACE field->jmj WITH roba->jmj
      REPLACE field->nc WITH roba->nc
      REPLACE field->vpc WITH roba->vpc
      REPLACE field->mpc WITH roba->mpc

      SELECT roba
      SKIP
   ENDDO

   boxc()

   MsgBeep( "Podaci se nalaze u " + PRIVPATH + "r_export.dbf tabeli !" )

   SELECT r_export
   USE

   RETURN .T.
