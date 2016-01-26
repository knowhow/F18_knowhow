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


FUNCTION unos_datuma_isplate_place()

   LOCAL dDatPr
   LOCAL dDat1
   LOCAL dDat2
   LOCAL dDat3
   LOCAL dDat4
   LOCAL dDat5
   LOCAL dDat6
   LOCAL dDat7
   LOCAL dDat8
   LOCAL dDat9
   LOCAL dDat10
   LOCAL dDat11
   LOCAL dDat12
   LOCAL nMjPr
   LOCAL nMj1
   LOCAL nMj2
   LOCAL nMj3
   LOCAL nMj4
   LOCAL nMj5
   LOCAL nMj6
   LOCAL nMj7
   LOCAL nMj8
   LOCAL nMj9
   LOCAL nMj10
   LOCAL nMj11
   LOCAL nMj12
   LOCAL cIsZaPr
   LOCAL cIsZa1
   LOCAL cIsZa2
   LOCAL cIsZa3
   LOCAL cIsZa4
   LOCAL cIsZa5
   LOCAL cIsZa6
   LOCAL cIsZa7
   LOCAL cIsZa8
   LOCAL cIsZa9
   LOCAL cIsZa10
   LOCAL cIsZa11
   LOCAL cIsZa12
   LOCAL cVrIsPr
   LOCAL cVrIs1
   LOCAL cVrIs2
   LOCAL cVrIs3
   LOCAL cVrIs4
   LOCAL cVrIs5
   LOCAL cVrIs6
   LOCAL cVrIs7
   LOCAL cVrIs8
   LOCAL cVrIs9
   LOCAL cVrIs10
   LOCAL cVrIs11
   LOCAL cVrIs12

   LOCAL nGod := Year( Date() )
   LOCAL cObr := "1"
   LOCAL cRj := "  "
   LOCAL nX := 1
   LOCAL cOk := "D"

   my_close_all_dbf()

   O_OBRACUNI
   O_LD_RJ

   IF obracuni->( FieldPos( "DAT_ISPL" ) ) == 0 .OR. obracuni->( FieldPos( "OBR" ) ) == 0
      MsgBeep( "Potrebna modifikacija struktura LD.CHS !!!#Prekidam operaciju" )
      RETURN
   ENDIF


   Box(, 20, 65 )

   @ m_x + nX, m_y + 2 SAY "*** Unos datuma isplata placa" COLOR "I"

   ++nX
   ++nX

   @ m_x + nX, m_y + 2 SAY "Tekuca godina:" GET nGod PICT "9999"

   @ m_x + nX, Col() + 2 SAY "Radna jedinica:" GET cRJ PICT "99" ;
      VALID Empty( cRJ ) .OR. P_LD_RJ( @cRJ )

   @ m_x + nX, Col() + 2 SAY "Obracun:" GET cObr VALID cObr $ " 123456789"

   ++nX

   @ m_x + nX, m_y + 2 SAY "----------------------------------------"
   ++nX

   READ

   dDatPr := g_isp_date( cRj, nGod - 1, 12, cObr, @nMjPr, @cIsZaPr, ;
      @cVrIsPr )

   dDat1 := g_isp_date( cRj, nGod, 1, cObr, @nMj1, @cIsZa1, @cVrIs1 )
   dDat2 := g_isp_date( cRj, nGod, 2, cObr, @nMj2, @cIsZa2, @cVrIs2 )
   dDat3 := g_isp_date( cRj, nGod, 3, cObr, @nMj3, @cIsZa3, @cVrIs3 )
   dDat4 := g_isp_date( cRj, nGod, 4, cObr, @nMj4, @cIsZa4, @cVrIs4 )
   dDat5 := g_isp_date( cRj, nGod, 5, cObr, @nMj5, @cIsZa5, @cVrIs5 )
   dDat6 := g_isp_date( cRj, nGod, 6, cObr, @nMj6, @cIsZa6, @cVrIs6 )
   dDat7 := g_isp_date( cRj, nGod, 7, cObr, @nMj7, @cIsZa7, @cVrIs7 )
   dDat8 := g_isp_date( cRj, nGod, 8, cObr, @nMj8, @cIsZa8, @cVrIs8 )
   dDat9 := g_isp_date( cRj, nGod, 9, cObr, @nMj9, @cIsZa9, @cVrIs9 )
   dDat10 := g_isp_date( cRj, nGod, 10, cObr, @nMj10, @cIsZa10, @cVrIs10 )
   dDat11 := g_isp_date( cRj, nGod, 11, cObr, @nMj11, @cIsZa11, @cVrIs11 )
   dDat12 := g_isp_date( cRj, nGod, 12, cObr, @nMj12, @cIsZa12, @cVrIs12 )

   @ m_x + nX, m_y + 2 SAY PadL( "datum", 7 ) + ;
      PadL( "mj.ispl.", 18 ) + ;
      PadL( "isplata za", 18 ) + ;
      PadL( "vrsta ispl.", 18 )

   ++nX

   @ m_x + nX, m_y + 2 SAY "12." + AllTrim( Str( nGod - 1 ) ) + ;
      " => " GET dDatPr
   @ m_x + nX, Col() + 2 SAY "" GET nMjPr PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZaPr PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIsPr PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "01." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat1
   @ m_x + nX, Col() + 2 SAY "" GET nMj1 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa1 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs1 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "02." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat2
   @ m_x + nX, Col() + 2 SAY "" GET nMj2 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa2 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs2 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "03." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat3
   @ m_x + nX, Col() + 2 SAY "" GET nMj3 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa3 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs3 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "04." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat4
   @ m_x + nX, Col() + 2 SAY "" GET nMj4 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa4 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs4 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "05." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat5
   @ m_x + nX, Col() + 2 SAY "" GET nMj5 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa5 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs5 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "06." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat6
   @ m_x + nX, Col() + 2 SAY "" GET nMj6 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa6 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs6 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "07." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat7
   @ m_x + nX, Col() + 2 SAY "" GET nMj7 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa7 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs7 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "08." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat8
   @ m_x + nX, Col() + 2 SAY "" GET nMj8 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa8 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs8 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "09." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat9
   @ m_x + nX, Col() + 2 SAY "" GET nMj9 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa9 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs9 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "10." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat10
   @ m_x + nX, Col() + 2 SAY "" GET nMj10 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa10 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs10 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "11." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat11
   @ m_x + nX, Col() + 2 SAY "" GET nMj11 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa11 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs11 PICT "@S15"

   ++nX

   @ m_x + nX, m_y + 2 SAY "12." + AllTrim( Str( nGod ) ) + ;
      " => " GET dDat12
   @ m_x + nX, Col() + 2 SAY "" GET nMj12 PICT "99"
   @ m_x + nX, Col() + 2 SAY "" GET cIsZa12 PICT "@S15"
   @ m_x + nX, Col() + 2 SAY "" GET cVrIs12 PICT "@S15"


   ++nX
   ++nX

   @ m_x + nX, m_y + 2 SAY "Unos ispravan (D/N)" GET cOk ;
      VALID cOK $ "DN" ;
      PICT "@!"

   READ
   BoxC()

   IF LastKey() <> K_ESC

      IF cOk == "N"
         RETURN
      ENDIF

      nGodina := nGod

      s_isp_date( cRJ, nGodina - 1, 12, cObr, dDatPr, nMjPr, cIsZaPr, ;
         cVrIsPr )

      s_isp_date( cRJ, nGodina, 1, cObr, dDat1, nMj1, cIsZa1, cVrIs1 )
      s_isp_date( cRJ, nGodina, 2, cObr, dDat2, nMj2, cIsZa2, cVrIs2 )
      s_isp_date( cRJ, nGodina, 3, cObr, dDat3, nMj3, cIsZa3, cVrIs3 )
      s_isp_date( cRJ, nGodina, 4, cObr, dDat4, nMj4, cIsZa4, cVrIs4 )
      s_isp_date( cRJ, nGodina, 5, cObr, dDat5, nMj5, cIsZa5, cVrIs5 )
      s_isp_date( cRJ, nGodina, 6, cObr, dDat6, nMj6, cIsZa6, cVrIs6 )
      s_isp_date( cRJ, nGodina, 7, cObr, dDat7, nMj7, cIsZa7, cVrIs7 )
      s_isp_date( cRJ, nGodina, 8, cObr, dDat8, nMj8, cIsZa8, cVrIs8 )
      s_isp_date( cRJ, nGodina, 9, cObr, dDat9, nMj9, cIsZa9, cVrIs9 )
      s_isp_date( cRJ, nGodina, 10, cObr, dDat10, nMj10, cIsZa10, cVrIs10 )
      s_isp_date( cRJ, nGodina, 11, cObr, dDat11, nMj11, cIsZa11, cVrIs11 )
      s_isp_date( cRJ, nGodina, 12, cObr, dDat12, nMj12, cIsZa12, cVrIs12 )

   ENDIF

   my_close_all_dbf()

   RETURN


FUNCTION g_isp_date( cRj, nGod, nMjesec, cObr, nMjIsp, cIsplZa, cVrsta )

   LOCAL dDate := CToD( "" )
   LOCAL nTArea := Select()

   nMjIsp := 0
   cIsplZa := Space( 50 )
   cVrsta := Space( 50 )

   SELECT F_OBRACUNI
   IF !Used()
      O_OBRACUNI
   ENDIF

   SELECT obracuni
   SET ORDER TO TAG "RJ"
   GO TOP

   SEEK  cRJ + AllTrim( Str( nGod ) ) + ld_formatiraj_mjesec( nMjesec ) + "G" + cObr

   IF field->rj == cRj .AND. ;
         field->mjesec = nMjesec .AND. ;
         field->godina = nGod .AND. ;
         field->obr == cObr .AND. ;
         field->status == "G"

      dDate := field->dat_ispl
      nMjIsp := field->mj_ispl
      cIsplZa := field->ispl_za
      cVrsta := field->vr_ispl

   ELSE
      dDate := CToD( "" )
   ENDIF

   SELECT ( nTArea )

   RETURN dDate


STATIC FUNCTION s_isp_date( cRj, nGod, nMjesec, cObr, dDatIspl, nMjIspl, ;
      cIsplZa, cVrsta )

   LOCAL nTArea := Select()
   LOCAL _rec
   LOCAL _field_ids, _where_cond

   SELECT F_OBRACUNI
   IF !Used()
      O_OBRACUNI
   ENDIF

   SELECT obracuni
   SET ORDER TO TAG "RJ"
   GO TOP
   SEEK  cRJ + AllTrim( Str( nGod ) ) + ld_formatiraj_mjesec( nMjesec ) + "G" + cObr


   IF field->rj == cRj .AND. ;
         field->mjesec = nMjesec .AND. ;
         field->godina = nGod .AND. ;
         field->obr == cObr .AND. ;
         field->status == "G"

      _rec := dbf_get_rec()
      _rec[ "dat_ispl" ] := dDatIspl
      _rec[ "mj_ispl" ] := nMjIspl
      _rec[ "ispl_za" ] := cIsplZa
      _rec[ "vr_ispl" ] := cVrsta
   ELSE

      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "rj" ] := cRj
      _rec[ "godina" ] := nGod
      _rec[ "mjesec" ] := nMjesec
      _rec[ "obr" ] := cObr
      _rec[ "status" ] := "G"
      _rec[ "dat_ispl" ] := dDatIspl
      _rec[ "mj_ispl" ] := nMjIspl
      _rec[ "ispl_za" ] := cIsplZa
      _rec[ "vr_ispl" ] := cVrsta

   ENDIF

   // azuriranje na sql server
   update_rec_server_and_dbf( "ld_obracuni", _rec, 1, "FULL" )

   SELECT ( nTArea )

   RETURN




FUNCTION ld_provjeri_dat_isplate_za_mjesec( godina, mjesec, rj )

   LOCAL _qry, _data, _count

   _qry := "SELECT "
   _qry += "  COUNT(*) "
   _qry += "FROM fmk.ld_ld ld "
   _qry += "LEFT JOIN fmk.ld_obracuni obr ON ld.godina = obr.godina AND ld.mjesec = obr.mjesec AND obr.status = 'G' "

   IF rj <> NIL .and. !EMPTY( rj )
      _qry += " AND obr.rj = " + _sql_quote( rj )
   ELSE
      _qry += " AND ld.idrj = obr.rj"
   ENDIF

   _qry += " WHERE "
   _qry += " ld.godina = " + ALLTRIM( STR( godina ) )
   _qry += " AND ld.mjesec = " + ALLTRIM( STR( mjesec ) )
   _qry += " AND obr.dat_ispl IS NULL "
   _qry += "GROUP BY ld.godina, ld.mjesec, ld.idrj, obr.dat_ispl  "

   _data := _sql_query( my_server(), _qry )

   _count := _data:FieldGet(1)

   RETURN _count
