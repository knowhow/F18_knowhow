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

FUNCTION kalk_sifrarnik()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   PRIVATE PicDem

   PicDem := gPICDem
   my_close_all_dbf()

   AAdd( _opc, "1. opći šifarnici                  " )
   AAdd( _opcexe, {|| SifFmkSvi() } )
   AAdd( _opc, "2. robno-materijalno poslovanje" )
   AAdd( _opcexe, {|| SifFmkRoba() } )
   AAdd( _opc, "3. magacinski i prodajni objekti" )
   AAdd( _opcexe, {|| P_Objekti() } )

   f18_menu( "msif", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN .F.



FUNCTION kalk_serv_functions()

   Msg( "Nije u upotrebi" )
   closeret

   RETURN


FUNCTION KalkRobaBlock( Ch )

   LOCAL cSif := ROBA->id, cSif2 := ""

   IF Ch == K_CTRL_T .AND. gSKSif == "D"

      PushWA()
      SET ORDER TO TAG "ID"
      SEEK cSif
      SKIP 1
      cSif2 := ROBA->id
      PopWA()
      IF !( cSif == cSif2 )
         IF ima_u_kalk_kumulativ( cSif, "7" )
            Beep( 1 )
            Msg( "Stavka se ne moze brisati jer se vec nalazi u dokumentima!" )
            RETURN 7
         ENDIF
      ENDIF

   ELSEIF Ch == K_ALT_M
      RETURN MpcIzVpc()

   ELSEIF Ch == K_F2 .AND. gSKSif == "D"

      IF ima_u_kalk_kumulativ( cSif, "7" )
         RETURN 99
      ENDIF

   ELSEIF Ch == K_F8

      PushWa()
      nRet := CjenR()
      OSifBaze()
      SELECT ROBA
      PopWA()
      RETURN nRet

   ELSEIF Upper( Chr( Ch ) ) == "O"

      IF roba->( FieldPos( "strings" ) ) == 0
         RETURN 6
      ENDIF
      TB:Stabilize()
      PushWa()
      m_strings( roba->strings, roba->id )
      SELECT roba
      PopWa()
      RETURN 7

   ELSEIF Upper( Chr( Ch ) ) == "S"

      TB:Stabilize()
      PushWa()
      KalkStanje( roba->id )
      PopWa()
      RETURN 6

   ELSEIF Upper( Chr( Ch ) ) == "D"
      roba_opis_edit( .T. )
      RETURN 6

   ENDIF

   RETURN DE_CONT



FUNCTION OSifBaze()

   O_KONTO
   O_KONCIJ
   O_PARTN
   O_TNAL
   O_TDOK
   O_TRFP
   O_TRMP
   O_VALUTE
   O_TARIFA
   O_ROBA
   O_SAST

   RETURN


FUNCTION P_Objekti()

   LOCAL nTArea
   PRIVATE ImeKol
   PRIVATE Kol

   ImeKol := {}
   Kol := {}

   nTArea := Select()
   O_OBJEKTI

   AAdd( ImeKol, { "ID", {|| id }, "id" } )
   add_mcode( @ImeKol )
   AAdd( ImeKol, { "Naziv", {|| PadR( ToStrU( naz ), 20 ) }, "naz" } )
   AAdd( ImeKol, { "IdObj", {|| idobj }, "idobj" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   SELECT ( nTArea )
   p_sifra( F_OBJEKTI, 1, MAXROWS() -15, MAXCOLS() -20, "Objekti" )

   RETURN

