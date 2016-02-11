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


// ---------------------------------------------------------
// unos radnih sati kod obracuna plate
// ---------------------------------------------------------
FUNCTION FillRadSati( cIdRadnik, nRadniSati )

   // uzmi prethodne sate...
   cSatiPredhodni := GetStatusRSati( cIdRadnik )

   IF Pitanje(, Lokal( "Unos placenih sati (D/N)?" ), "D" ) == "N"
      RETURN Val( cSatiPredhodni )
   ENDIF

   nPlacenoRSati := 0
   cOdgovor := "D"

   Box(, 9, 48 )
   @ m_x + 1, m_y + 2 SAY Lokal( "Radnik:   " ) + AllTrim( cIdRadnik )
   @ m_x + 2, m_y + 2 SAY Lokal( "Ostalo iz predhodnih obracuna: " ) + AllTrim( cSatiPredhodni ) + " sati"
   @ m_x + 3, m_y + 2 SAY "-----------------------------------------------"
   @ m_x + 4, m_y + 2 SAY Lokal( "Uplaceno sati: " ) GET nPlacenoRSati PICT "99999999"
   READ
   @ m_x + 5, m_y + 2 SAY "-----------------------------------------------"
   @ m_x + 6, m_y + 2 SAY Lokal( "Radni sati ovaj mjesec  : " ) + AllTrim( Str( nRadniSati ) )
   @ m_x + 7, m_y + 2 SAY Lokal( "Placeni sati ovaj mjesec: " ) + AllTrim( Str( nPlacenoRSati ) )
   @ m_x + 8, m_y + 2 SAY Lokal( "Ostalo " ) + AllTrim( Str( nRadniSati - nPlacenoRSati + Val( cSatiPredhodni ) ) ) + Lokal( " sati za sljedeci mjesec !" )
   @ m_x + 9, m_y + 2 SAY Lokal( "Sacuvati promjene (D/N)? " ) GET cOdgovor VALID cOdgovor $ "DN" PICT "@!"
   READ

   IF cOdgovor == "D"
      UbaciURadneSate( cIdRadnik, nRadniSati - nPlacenoRSati )
   ELSE
      MsgBeep( Lokal( "Promjene nisu sacuvane !!!" ) )
   ENDIF
   BoxC()

   RETURN Val( cSatiPredhodni )


// ------------------------------------------------
// vraca status uplacenih sati za tekuci mjesec
// ------------------------------------------------
FUNCTION GetUplaceniRSati( cIdRadn )

   LOCAL nArr
   LOCAL nSati := 0

   nArr := Select()

   SELECT radsat
   HSEEK cIdRadn

   IF Found() .AND. field->idradn == cIdRadn
      nSati := field->up_sati
   ENDIF

   SELECT ( nArr )

   RETURN Str( nSati )



// ------------------------------------------------
// vraca status radnih sati za obracun
// ------------------------------------------------
FUNCTION GetStatusRSati( cIdRadn )

   LOCAL nArr
   LOCAL nSati := 0

   nArr := Select()

   SELECT radsat
   HSEEK cIdRadn

   IF Found() .AND. field->idradn == cIdRadn
      nSati := field->sati
   ENDIF

   SELECT ( nArr )

   RETURN Str( nSati )


// ----------------------------------------------------
// ubaci podatke u tabelu radnih sati
// ----------------------------------------------------
FUNCTION UbaciURadneSate( id_radnik, iznos_sati )

   LOCAL _t_area := Select()
   LOCAL _rec

   SELECT radsat
   SET ORDER TO TAG "IDRADN"
   GO TOP
   SEEK id_radnik

   IF Found()
      _rec := dbf_get_rec()
      _rec[ "sati" ] := _rec[ "sati" ] + iznos_sati
   ELSE
      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "idradn" ] := id_radnik
      _rec[ "sati" ] := iznos_sati
   ENDIF

   update_rec_server_and_dbf( "ld_radsat", _rec, 1, "FULL" )

   SELECT ( _t_area )

   RETURN


// ---------------------------------
// upisi u iznos radne sate
// ---------------------------------
FUNCTION delRadSati( id_radnik, iznos_sati )

   LOCAL _t_arr := Select()
   LOCAL _rec

   SELECT radsat
   SET ORDER TO TAG "IDRADN"
   GO TOP
   SEEK id_radnik

   IF Found()
      _rec := dbf_get_rec()
      _rec[ "sati" ] := iznos_sati
      update_rec_server_and_dbf( "ld_radsat", _rec, 1, "FULL" )
   ENDIF

   SELECT ( _t_arr )

   RETURN

// -------------------------------------------------
// ispravka pregled radnih sati
// -------------------------------------------------
FUNCTION edRadniSati()

   PRIVATE ImeKol := {}
   PRIVATE Kol := {}

   PushWA()

   O_RADN
   O_RADSAT
   SELECT radsat
   SET ORDER TO TAG "IDRADN"
   GO TOP

   PRIVATE Imekol := {}

   AAdd( ImeKol, { "radn",         {|| IdRadn   } } )
   AAdd( ImeKol, { "ime i prezime", {|| g_naziv( IdRadn ) } } )
   AAdd( ImeKol, { "sati",          {|| sati   } } )
   AAdd( ImeKol, { "status",        {|| status   } } )

   Kol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   Box(, MAXROWS() - 16, MAXCOLS() - 5 )
   ObjDbedit( "RadSat", MAXROWS() - 16, MAXCOLS() - 5, {|| key_handler() }, "Pregled radnih sati za radnike", "", , , , )
   Boxc()

   PopwA()

   RETURN



// ---------------------------------------
// key handler za radne sate
// ---------------------------------------
STATIC FUNCTION key_handler()

   LOCAL _rec

   DO CASE
   CASE CH == K_F2

      Box(, 1, 40 )
      nSati := field->sati
      @ m_x + 1, m_y + 2 SAY "novi sati:" GET nSati
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN DE_CONT
      ELSE
         _rec := dbf_get_rec()
         _rec[ "sati" ] := nSati
         update_rec_server_and_dbf( "ld_radsat", _rec, 1, "FULL" )
         RETURN DE_REFRESH
      ENDIF

   CASE CH == K_CTRL_T
      IF Pitanje(, "izbrisati stavku ?", "N" ) == "D"
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( "ld_radsat", _rec, 1, "FULL" )
         RETURN DE_REFRESH
      ENDIF

   CASE CH == K_CTRL_P
      stRadniSati()
      RETURN DE_CONT
   ENDCASE

   RETURN DE_CONT


// -----------------------------------------------
// printanje sadrzaja radnih sati
// -----------------------------------------------
STATIC FUNCTION stRadniSati()

   LOCAL nCnt
   LOCAL cTxt := ""
   LOCAL cLine := ""
   LOCAL aSati

   SELECT radsat
   SET ORDER TO TAG "1"
   GO TOP

   START PRINT CRET

   ?
   P_COND

   cTxt += PadR( "r.br", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "id", 6 )
   cTxt += Space( 1 )
   cTxt += PadR( "naziv radnika", 25 )
   cTxt += Space( 1 )
   cTxt += PadR( "radni sati", 10 )
   cTxt += Space( 1 )
   cTxt += PadR( "status", 6 )

   cLine += Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 6 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 25 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 10 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 6 )

   ? "Pregled radnih sati:"

   ? cLine
   ? cTxt
   ? cLine

   aSati := {}

   nCnt := 0
   DO WHILE !Eof()

      IF field->sati = 0
         SKIP
         LOOP
      ENDIF

      AAdd( aSati, { idradn, PadR( g_naziv( idradn ), 25 ), sati, status } )

      SKIP
   ENDDO

   // sada istampaj
   // napravi sort po ime+prezime
   ASort( aSati,,, {| x, y| x[ 2 ] < y[ 2 ] } )

   FOR i := 1 TO Len( aSati )

      ? PadL( AllTrim( Str( ++nCnt ) ), 4 ) + "."
      @ PRow(), PCol() + 1 SAY aSati[ i, 1 ]
      @ PRow(), PCol() + 1 SAY aSati[ i, 2 ]
      @ PRow(), PCol() + 1 SAY aSati[ i, 3 ]
      @ PRow(), PCol() + 1 SAY aSati[ i, 4 ]

   NEXT

   ? cLine

   FF
   ENDPRINT

   RETURN
