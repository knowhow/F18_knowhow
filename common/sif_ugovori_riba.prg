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


STATIC __partn
STATIC _x_pos
STATIC _y_pos

// --------------------------------------
// otvara stavke ugovora - robu iz RUGOV
// --------------------------------------
FUNCTION V_Rugov( cId )

   LOCAL nLenTbl := 12
   LOCAL nWidthTbl := 65
   PRIVATE cIdUgov
   PRIVATE GetList := {}
   PRIVATE ImeKol
   PRIVATE Kol

   _x_pos := MIN( 20, MAXROWS() - 10 )
   _y_pos := MAXCOLS() - 15

   cIdUgov := cId

   Box(, _x_pos, _y_pos )

   SELECT rugov

   set_a_kol( @ImeKol, @Kol )
   set_f_tbl( cIdUgov )

   SET CURSOR ON

   @ m_x + 1, m_y + 1 SAY ""

   ?? "Ugovor:", ugov->id, ugov->naz, ugov->DatOd

   __partn := ugov->idpartner


   my_db_edit( "", _x_pos, _y_pos, {|| key_handler( cIdUgov ) }, "", "",,,,, 2 )

   // izbacen brkey... bezveze

   SELECT ugov
   BoxC()

   SET FILTER TO

   RETURN .T.


STATIC FUNCTION set_f_tbl( cIdUgov )

   LOCAL cFilt := ""

   cFilt := "id == " + dbf_quote( cIdUgov )
   SET FILTER to &cFilt
   GO TOP

   RETURN .T.


// -------------------------------------
// setovanje kolona pregleda
// -------------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   aImeKol := {}
   aKol := {}

   AAdd( aImeKol, { "ID roba",   {|| IdRoba } } )
   AAdd( aImeKol, { PadC( "Kol.", Len( pickol ) ), {|| Transform( Kolicina, pickol ) } } )

   IF rugov->( FieldPos( "cijena" ) ) <> 0
      AAdd( aImeKol, { "Cijena", {|| Transform( cijena, picdem ) },  "cijena"    } )
   ENDIF

   AAdd( aImeKol, { "Rabat",   {|| Rabat }  } )
   AAdd( aImeKol, { "Porez",   {|| Porez }  } )

   IF rugov->( FieldPos( "K1" ) ) <> 0
      AAdd( aImeKol, { "K1", {|| K1 },    "K1"    } )
      AAdd( aImeKol, { "K2", {|| K2 },    "K2"    } )
   ENDIF

   IF rugov->( FieldPos( "dest" ) ) <> 0
      AAdd( aImeKol, { "Dest.", {|| get_dest_info( __partn, dest, 65 ) }, "dest"  } )
   ENDIF

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN .T.


// ------------------------------------------------
// key handler
// ------------------------------------------------
STATIC FUNCTION key_handler( cIdUgov )

   LOCAL nRet := DE_CONT
   LOCAL _rec

   // prikazi destinaciju
   s_box_dest()

   DO CASE

   CASE Ch == K_CTRL_N

      nRet := edit_rugov( .T. )

   CASE Ch == K_F2

      nRet := edit_rugov( .F. )

   CASE Ch == K_CTRL_T

      IF Pitanje(, "Izbrisati stavku ?", "N" ) == "D"
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
      ENDIF

      nRet := DE_REFRESH
   ENDCASE

   RETURN nRet



// prikazuje box sa informacijama o destinaciji...
STATIC FUNCTION s_box_dest()

   get_dest_binfo( _x_pos, _y_pos, __partn, rugov->dest )

   RETURN




// ---------------------------------
// edit rugov
// ---------------------------------
FUNCTION edit_rugov( lNovi )

   LOCAL cIdRoba
   LOCAL nKolicina
   LOCAL cDestinacija
   LOCAL nRabat
   LOCAL nPorez
   LOCAL nCijena
   LOCAL lCijena := .F.
   LOCAL lK1 := .F.
   LOCAL lDest := .F.
   LOCAL cK1
   LOCAL cK2
   LOCAL nX := 1
   LOCAL nBoxLen := 20
   LOCAL _vars

   cIdRoba := IdRoba
   nKolicina := kolicina
   nRabat := rabat
   nPorez := porez

   IF is_dest()
      lDest := .T.
   ENDIF

   IF rugov->( FieldPos( "K1" ) ) <> 0
      cK1 := k1
      cK2 := k2
      lK1 := .T.
   ENDIF

   IF rugov->( FieldPos( "cijena" ) ) <> 0
      nCijena := cijena
      lCijena := .T.
   ENDIF

   IF lDest
      cDestinacija := dest
   ENDIF

   Box(, 8, 75, .F. )

   @ m_x + nX, m_y + 2 SAY PadL( "Roba", nBoxLen ) GET cIdRoba PICT "@!" VALID P_Roba( @cIDRoba )

   IF lDest

      ++ nX
      @ m_x + nX, m_y + 2 SAY PadL( "Destinacija:", nBoxLen ) GET cDestinacija PICT "@!" valid {|| Empty( cDestinacija ) .OR. p_dest_2( @cDestinacija, __partn ) }

   ENDIF

   ++ nX

   @ m_x + nX, m_y + 2 SAY8 PadL( "Količina", nBoxLen ) GET nKolicina PICT "99999999.999" VALID _val_num( nKolicina )

   IF lCijena
      ++ nX
      @ m_x + nX, m_y + 2 SAY PadL( "Cijena", nBoxLen ) GET nCijena PICT pic_cijena_bilo_gpiccdem() VALID _val_num( nCijena )
   ENDIF

   ++ nX
   @ m_x + nX, m_y + 2 SAY PadL( "Rabat", nBoxLen ) GET nRabat PICT "99.999"

   ++ nX
   @ m_x + nX, m_y + 2 SAY PadL( "Porez", nBoxLen ) GET nPorez PICT "99.99"

   IF lK1
      ++ nX
      @ m_x + nX, m_y + 2 SAY PadL( "K1", nBoxLen ) GET cK1 PICT "@!"
      ++ nX
      @ m_x + nX, m_y + 2 SAY PadL( "K2", nBoxLen ) GET cK2 PICT "@!"
   ENDIF

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN DE_CONT
   ENDIF

   IF lNovi
      APPEND BLANK
      _vars := dbf_get_rec()
      _vars[ "id" ] := cIdUgov
   ELSE
      _vars := dbf_get_rec()
   ENDIF


   _vars[ "idroba" ] := cIdRoba
   _vars[ "kolicina" ] := nKolicina
   _vars[ "rabat" ] := nRabat
   _vars[ "porez" ] := nPorez

   IF lDest
      _vars[ "dest" ] := cDestinacija
   ENDIF

   IF lCijena
      _vars[ "cijena" ] := nCijena
   ENDIF

   IF lK1
      _vars[ "k1" ] := cK1
      _vars[ "k2" ] := cK2
   ENDIF


   IF !update_rec_server_and_dbf( Alias(), _vars, 1, "FULL" )
      delete_with_rlock()
   ENDIF

   RETURN DE_REFRESH


// ----------------------------------------
// validacija numerika
// ----------------------------------------
STATIC FUNCTION _val_num( nNum )

   LOCAL lRet := .T.

   IF nNum <= 0
      lRet := .F.
   ENDIF

   IF lRet == .F.
      MsgBeep( "Vrijednost mora biti > 0 !!!" )
   ENDIF

   RETURN lRet




FUNCTION vrati_opis_ugovora( cIdUgov )

   LOCAL cOpis := ""

   PushWA()

   SELECT (F_RUGOV)
   IF !USED()
      O_RUGOV
   ENDIF

   SELECT rugov
   SET FILTER TO
   SEEK cIdUgov

   IF Found()
      cOpis += Trim( idroba ) + " " + AllTrim( Transform( kolicina, pickol ) ) + " x " + AllTrim( Transform( cijena, picdem ) )
   ENDIF

   PopWa()

   RETURN cOpis
