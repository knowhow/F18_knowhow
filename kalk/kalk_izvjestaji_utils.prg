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



FUNCTION vise_kalk_dok_u_pripremi( cIdd )

/* TODO: ne trebamo ovo vise ?!
   IF field->idPartner + field->brFaktP + field->idKonto + field->idKonto2 <> cIdd
      SET DEVICE TO SCREEN
      Beep( 2 )
      Msg( "Unutar kalkulacije se pojavilo vise dokumenata !", 6 )
      SET DEVICE TO PRINTER
   ENDIF
*/

   RETURN

FUNCTION show_more_info( cPartner, dDatum, cFaktura, cMU_I )

   LOCAL cRet := ""
   LOCAL cMIPart := ""
   LOCAL cTip := ""

   IF !Empty( cPartner )

      cMIPart := AllTrim( Ocitaj( F_PARTN, cPartner, "NAZ" ) )

      IF cMU_I == "1"
         cTip := "dob.:"
      ELSE
         cTip := "kup.:"
      ENDIF

      cRet := DToC( dDatum )
      cRet += ", "
      cRet += "br.dok: "
      cRet += AllTrim( cFaktura )
      cRet += ", "
      cRet += cTip
      cRet += " "
      cRet += cPartner
      cRet += " ("
      cRet += cMIPart
      cRet += ")"

   ENDIF

   RETURN cRet


FUNCTION zadnji_ulazi_info( partner, id_roba, mag_prod )

   LOCAL _data := {}
   LOCAL _count := 3

   IF fetch_metric( "pregled_rabata_kod_ulaza", my_user(), "N" ) == "N"
      RETURN .T.
   ENDIF

   IF mag_prod == NIL
      mag_prod := "P"
   ENDIF

   _data := _kalk_get_ulazi( partner, id_roba, mag_prod )

   IF Len( _data ) > 0
      _prikazi_info( _data, mag_prod, _count )
   ENDIF

   RETURN .T.



FUNCTION zadnji_izlazi_info( partner, id_roba )

   LOCAL _data := {}
   LOCAL _count := 3

   IF fetch_metric( "pregled_rabata_kod_izlaza", my_user(), "N" ) == "N"
      RETURN .T.
   ENDIF

   _data := _fakt_get_izlazi( partner, id_roba )

   IF Len( _data ) > 0
      _prikazi_info( _data, "F", _count )
   ENDIF

   RETURN .T.



STATIC FUNCTION _fakt_get_izlazi( partner, roba )

   LOCAL _qry, _qry_ret, _table
   LOCAL _server := pg_server()
   LOCAL _data := {}
   LOCAL _i, oRow

   _qry := "SELECT idfirma, idtipdok, brdok, datdok, cijena, rabat FROM fmk.fakt_fakt " + ;
      " WHERE idpartner = " + sql_quote( partner ) + ;
      " AND idroba = " + sql_quote( roba ) + ;
      " AND ( idtipdok = " + sql_quote( "10" ) + " OR idtipdok = " + sql_quote( "11" ) + " ) " + ;
      " ORDER BY datdok"

   _table := _sql_query( _server, _qry )
   _table:GoTo(1)

   FOR _i := 1 TO _table:LastRec()

      oRow := _table:GetRow( _i )

      AAdd( _data, { oRow:FieldGet( oRow:FieldPos( "idfirma" ) ), ;
         oRow:FieldGet( oRow:FieldPos( "idtipdok" ) ) + "-" + AllTrim( oRow:FieldGet( oRow:FieldPos( "brdok" ) ) ), ;
         oRow:FieldGet( oRow:FieldPos( "datdok" ) ), ;
         oRow:FieldGet( oRow:FieldPos( "cijena" ) ), ;
         oRow:FieldGet( oRow:FieldPos( "rabat" ) ) } )


   NEXT

   RETURN _data




STATIC FUNCTION _kalk_get_ulazi( partner, roba, mag_prod )

   LOCAL _qry, _qry_ret, _table
   LOCAL _server := pg_server()
   LOCAL _data := {}
   LOCAL _i, oRow
   LOCAL _u_i := "pu_i"

   IF mag_prod == "M"
      _u_i := "mu_i"
   ENDIF

   _qry := "SELECT idkonto, idvd, brdok, datdok, fcj, rabat FROM fmk.kalk_kalk WHERE idfirma = " + ;
      sql_quote( gfirma ) + ;
      " AND idpartner = " + sql_quote( partner ) + ;
      " AND idroba = " + sql_quote( roba ) + ;
      " AND " + _u_i + " = " + sql_quote( "1" ) + ;
      " ORDER BY datdok"

   _table := _sql_query( _server, _qry )
   _table:GoTo(1)

   FOR _i := 1 TO _table:LastRec()

      oRow := _table:GetRow( _i )

      AAdd( _data, { oRow:FieldGet( oRow:FieldPos( "idkonto" ) ), ;
         oRow:FieldGet( oRow:FieldPos( "idvd" ) ) + "-" + AllTrim( oRow:FieldGet( oRow:FieldPos( "brdok" ) ) ), ;
         oRow:FieldGet( oRow:FieldPos( "datdok" ) ), ;
         oRow:FieldGet( oRow:FieldPos( "fcj" ) ), ;
         oRow:FieldGet( oRow:FieldPos( "rabat" ) ) } )


   NEXT

   RETURN _data



STATIC FUNCTION _prikazi_info( ulazi, mag_prod, ul_count )

   LOCAL GetList := {}
   LOCAL _line := ""
   LOCAL _head := ""
   LOCAL _ok := " "
   LOCAL _n := 4
   LOCAL _i, _len

   _len := Len( ulazi )

   _head := PadR( IF( mag_prod == "F", "FIRMA", "KONTO" ), 7 )
   _head += " "
   _head += PadR( "DOKUMENT", 10 )
   _head += " "
   _head += PadR( "DATUM", 8 )
   _head += " "
   _head += PadL( IF ( mag_prod == "F", "CIJENA", "NC" ), 12 )
   _head += " "
   _head += PadL( "RABAT", 13 )

   DO WHILE .T.

      _n := 4

      Box(, 5 + ul_count, 60 )

      @ m_x + 1, m_y + 2 SAY PadR( "*** Pregled rabata", 59 ) COLOR "I"
      @ m_x + 2, m_y + 2 SAY _head
      @ m_x + 3, m_y + 2 SAY Replicate( "-", 59 )

      FOR _i := _len to ( _len - ul_count ) STEP -1

         IF _i > 0

            _line := PadR( ulazi[ _i, 1 ], 7 )
            _line += " "
            _line += PadR( ulazi[ _i, 2 ], 10 )
            _line += " "
            _line += DToC( ulazi[ _i, 3 ] )
            _line += " "
            _line += Str( ulazi[ _i, 4 ], 12, 3 )
            _line += " "
            _line += Str( ulazi[ _i, 5 ], 12, 3 ) + "%"

            @ m_x + _n, m_y + 2 SAY _line
            ++ _n

         ENDIF

      NEXT

      @ m_x + _n, m_y + 2 SAY Replicate( "-", 59 )
      ++ _n
      @ m_x + _n, m_y + 2 SAY "Pritisni 'ENTER' za nastavak ..." GET _ok

      READ

      BoxC()

      IF LastKey() == K_ENTER
         EXIT
      ENDIF

   ENDDO

   RETURN




/*! \fn PrikaziDobavljaca(cIdRoba, nRazmak, lNeIspisujDob)
 *  \brief Funkcija vraca dobavljaca cIdRobe na osnovu polja roba->dob
 *  \param cIdRoba
 *  \param nRazmak - razmak prije ispisa dobavljaca
 *  \param lNeIspisujDob - ako je .t. ne ispisuje "Dobavljac:"
 *  \return cVrati - string "dobavljac: xxxxxxx"
 */

FUNCTION PrikaziDobavljaca( cIdRoba, nRazmak, lNeIspisujDob )

   IF lNeIspisujDob == NIL
      lNeIspisujDob := .T.
   ELSE
      lNeIspisujDob := .F.
   ENDIF

   cIdDob := Ocitaj( F_ROBA, cIdRoba, "SifraDob" )

   IF lNeIspisujDob
      cVrati := Space( nRazmak ) + "Dobavljac: " + Trim( cIdDob )
   ELSE
      cVrati := Space( nRazmak ) + Trim( cIdDob )
   ENDIF

   IF !Empty( cIdDob )
      RETURN cVrati
   ELSE
      cVrati := ""
      RETURN cVrati
   ENDIF

FUNCTION PrikTipSredstva( cKalkTip )

   IF !Empty( cKalkTip )
      ? "Uslov po tip-u: "
      IF cKalkTip == "D"
         ?? cKalkTip, ", donirana sredstva"
      ELSEIF cKalkTip == "K"
         ?? cKalkTip, ", kupljena sredstva"
      ELSE
         ?? cKalkTip, ", --ostala sredstva"
      ENDIF
   ENDIF

   RETURN


FUNCTION g_obj_naz( cKto )

   LOCAL cVal := ""
   LOCAL nTArr

   nTArr := Select()

   O_OBJEKTI
   SELECT objekti
   SET ORDER TO TAG "idobj"
   GO TOP
   SEEK cKto

   IF Found()
      cVal := objekti->naz
   ENDIF

   SELECT ( nTArr )

   RETURN cVal
