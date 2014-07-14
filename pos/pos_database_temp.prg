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


#include "pos.ch"


// ---------------------------------------------------------
// uglavnom funkcije za manipulaciju sa temporary tabelama
// _priprz, _pos, _priprg itd...
// ---------------------------------------------------------



// -------------------------------------------------------------
// prebacuje stavke iz tabele _pos_pripr u tabelu _pos
// -------------------------------------------------------------
FUNCTION _pripr2_pos( cIdVrsteP )

   LOCAL cBrdok
   LOCAL nTrec := 0
   LOCAL _rec

   IF cIdVrsteP == nil
      cIdVrsteP := ""
   ENDIF

   SELECT _pos_pripr
   GO TOP

   cBrdok := field->brdok

   DO WHILE !Eof()

      _rec := dbf_get_rec()

      SELECT _pos
      APPEND BLANK

      IF ( gRadniRac == "N" )
         // u _pos_pripr mora biti samo jedan dokument!!!
         _rec[ "brdok" ] := cBrDok
      ENDIF

      _rec[ "idvrstep" ] := cIdVrsteP

      dbf_update_rec( _rec )

      SELECT _pos_pripr
      SKIP

   ENDDO

   // pobrisi mi _pos_pripr
   SELECT _pos_pripr
   my_dbf_zap()

   RETURN


// ------------------------------------------
// odabir opcija za povrat pripremu
// ------------------------------------------
STATIC FUNCTION pripr_choice()

   LOCAL _ch := "1"

   // brisati
   // spojiti

   Box(, 3, 50 )
   @ m_x + 1, m_y + 2 SAY "Priprema nije prazna, sta dalje ? "
   @ m_x + 2, m_y + 2 SAY " (1) brisati pripremu  "
   @ m_x + 3, m_y + 2 SAY " (2) spojiti na postojeci dokument " GET _ch VALID _ch $ "12"
   READ
   BoxC()

   // na ESC
   IF LastKey() == K_ESC
      // marker "0" za nista odabrano
      _ch := "0"
      RETURN _ch
   ENDIF

   RETURN _ch




// -------------------------------------------
// pos -> priprz
// -------------------------------------------
FUNCTION pos_2_priprz()

   LOCAL _rec
   LOCAL _t_area := Select()
   LOCAL _oper := "1"
   LOCAL _exist, _rec2

   O_PRIPRZ
   SELECT priprz

   IF RecCount() <> 0
      _oper := pripr_choice()
   ENDIF

   // brisat cemo pripremu....
   IF _oper == "1"
      my_dbf_zap()
   ENDIF

   IF _oper == "2"
      // postojeci zapis... u priprz
      _rec2 := dbf_get_rec()
   ENDIF

   MsgO( "Vrsim povrat dokumenta u pripremu ..." )

   SELECT pos
   SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

   DO WHILE !Eof() .AND. pos->( IdPos + IdVd + DToS( datum ) + BrDok ) == ;
         pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

      _rec := dbf_get_rec()

      hb_HDel( _rec, "rbr" )

      SELECT roba
      HSEEK _rec[ "idroba" ]

      _rec[ "robanaz" ] := roba->naz
      _rec[ "jmj" ] := roba->jmj
      _rec[ "barkod" ] := roba->barkod

      // ako je operacija spajanja
      // spoji dokumente sa postojecim u pripremi....
      IF _oper == "2"
         _rec[ "idpos" ] := _rec2[ "idpos" ]
         _rec[ "idvd" ] := _rec2[ "idvd" ]
         _rec[ "brdok" ] := _rec2[ "brdok" ]
      ENDIF

      SELECT priprz

      IF _oper <> "2"
         APPEND BLANK
      ENDIF

      IF _oper == "2"

         // pronadji postojeci artikal...
         SET ORDER TO TAG "1"
         hseek _rec[ "idroba" ]

         IF !Found()
            APPEND BLANK
         ELSE
            // uzmi postojeci zapis iz pripreme
            _exist := dbf_get_rec()
            // dodaj na postojecu kolicinu kolicinu sa novog dokumenta
            _rec[ "kol2" ] := _rec[ "kol2" ] + _exist[ "kol2" ]
         ENDIF

      ENDIF

      dbf_update_rec( _rec )

      SELECT pos
      SKIP

   ENDDO

   MsgC()

   SELECT ( _t_area )

   RETURN



// ----------------------------------------
// prebaci iz pos u _pripr
// ----------------------------------------
FUNCTION pos2_pripr()

   LOCAL _rec

   SELECT _pos_pripr

   my_dbf_zap()

   GO TOP
   scatter()

   SELECT pos
   SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

   DO WHILE !Eof() .AND. POS->( IdPos + IdVd + DToS( datum ) + BrDok ) == pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

      _rec := dbf_get_rec()
      hb_HDel( _rec, "rbr" )

      SELECT roba
      HSEEK _IdRoba
      _rec[ "robanaz" ] := roba->naz
      _rec[ "jmj" ] := roba->jmj

      SELECT _pos_pripr
      APPEND BLANK

      dbf_update_rec( _rec )

      SELECT pos
      SKIP

   ENDDO

   SELECT _pos_pripr

   RETURN






/*! \fn UkloniRadne(cIdRadnik)
 *  \brief Ukloni radne racune (koj se nalaze u _POS tabeli)
 *  \param cIdRadnik
 */

FUNCTION UkloniRadne( cIdRadnik )

   SELECT _POS
   SET ORDER TO TAG "1"
   SEEK gIdPos + VD_RN
   WHILE !Eof() .AND. _POS->( IdPos + IdVd ) == ( gIdPos + VD_RN )
      IF _POS->IdRadnik == cIdRadnik .AND. _POS->M1 == "Z"
         Del_Skip ()
      ELSE
         SKIP
      ENDIF
   END
   SELECT ZAKSM

   RETURN



// --------------------------------------------------------------------------
// vraca dokumente iz privremene pripreme u pripremu zaduzenja itd...
// --------------------------------------------------------------------------
FUNCTION pos_vrati_dokument_iz_pripr( cIdVd, cIdRadnik, cIdOdj, cIdDio )

   LOCAL cSta
   LOCAL cBrDok

   DO CASE
   CASE cIdVd == VD_ZAD
      cSta := "zaduzenja"
   CASE cIdVd == VD_OTP
      cSta := "otpisa"
   CASE cIdVd == VD_INV
      cSta := "inventure"
   CASE cIdVd == VD_NIV
      cSta := "nivelacije"
   OTHERWISE
      cSta := "ostalo"
   ENDCASE

   SELECT _pos
   SET ORDER TO TAG "2"
   // IdVd+IdOdj+IdRadnik

   SEEK cIdVd + cIdOdj + cIdDio

   IF Found()
      // .and. (Empty (cIdDio) .or. _POS->IdDio==cIdDio)
      IF _pos->idradnik <> cIdRadnik
         // ne mogu dopustiti da vise radnika radi paralelno inventuru, nivelaciju
         // ili zaduzenje
         MsgBeep ( "Drugi radnik je poceo raditi pripremu " + cSta + "#" + "AKO NASTAVITE, PRIPREMA SE BRISE!!!", 30 )
         IF Pitanje(, "Zelite li nastaviti?", " " ) == "N"
            RETURN .F.
         ENDIF
         // xIdRadnik := _POS->IdRadnik
         DO WHILE !Eof() .AND. _POS->( IdVd + IdOdj + IdDio ) == ( cIdVd + cIdOdj + cIdDio )
            // IdRadnik, xIdRadnik
            Del_Skip()
         ENDDO
         MsgBeep( "Izbrisana je priprema " + cSta )
      ELSE

         Beep ( 3 )

         IF Pitanje(, "Poceli ste pripremu! Zelite li nastaviti? (D/N)", "D" ) == "N"
            // brisanje prethodne pripreme
            DO WHILE !Eof() .AND. _POS->( IdVd + IdOdj + IdDio ) == ( cIdVd + cIdOdj + cIdDio )
               Del_Skip()
            ENDDO
            MsgBeep ( "Priprema je izbrisana ... " )
         ELSE
            // vrati ono sto je poceo raditi
            SELECT _POS
            DO WHILE !Eof() .AND. _POS->( IdVd + IdOdj + IdDio ) == ( cIdVd + cIdOdj + cIdDio )
               Scatter()
               SELECT PRIPRZ
               APPEND BLANK
               Gather()
               SELECT _POS
               Del_Skip()
            ENDDO
            SELECT PRIPRZ
            GO TOP
         ENDIF
      ENDIF
   ENDIF

   SELECT _POS
   SET ORDER TO TAG "1"

   RETURN .T.
