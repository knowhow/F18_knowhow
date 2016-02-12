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


FUNCTION kalk_povrat_dokumenta()

   LOCAL lBrisiKumulativ
   LOCAL _rec
   LOCAL _id_firma
   LOCAL _id_vd
   LOCAL _br_dok
   LOCAL _del_rec
   LOCAL _t_rec
   LOCAL _dok_hash, oAtrib
   LOCAL lOk := .T.

   IF gCijene == "2" .AND. Pitanje(, "Zadati broj (D) / Povrat po hronologiji obrade (N) ?", "D" ) = "N"
      Beep( 1 )
      povrat_najnovije_kalkulacije()
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   otvori_kalk_tabele_za_povrat()

   _id_firma := gfirma
   _id_vd := Space( 2 )
   _br_dok := Space( 8 )

   Box( "", 1, 35 )
   @ m_x + 1, m_y + 2 SAY "Dokument:"
   IF gNW $ "DX"
      @ m_x + 1, Col() + 1 SAY _id_firma
   ELSE
      @ m_x + 1, Col() + 1 GET _id_firma
   ENDIF
   @ m_x + 1, Col() + 1 SAY "-" GET _id_vd PICT "@!"
   @ m_x + 1, Col() + 1 SAY "-" GET _br_dok
   READ
   ESC_BCR
   BoxC()

   IF _br_dok = "."
      kalk_povrat_prema_kriteriju()
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   IF !kalk_dokument_postoji( _id_firma, _id_vd, _br_dok )
      MsgBeep( "Traženi dokument ne postoji na serveru !"  )
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   IF Pitanje( "", "Kalk. " + _id_firma + "-" + _id_vd + "-" + _br_dok + " vratiti u pripremu (D/N) ?", "D" ) == "N"
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   lBrisiKumulativ := Pitanje(, "Izbrisati dokument iz kumulativne tabele (D/N) ?", "D" ) == "D"

   kalk_kopiraj_dokument_u_tabelu_pripreme( _id_firma, _id_vd, _br_dok )

   _dok_hash := hb_Hash()
   _dok_hash[ "idfirma" ] := _id_firma
   _dok_hash[ "idtipdok" ] := _id_vd
   _dok_hash[ "brdok" ] := _br_dok

   oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
   oAtrib:dok_hash := _dok_hash
   oAtrib:atrib_server_to_dbf()

   IF lBrisiKumulativ

      sql_table_update( nil, "BEGIN" )

      IF !f18_lock_tables( { "kalk_doks", "kalk_kalk", "kalk_doks2" }, .T. )
         sql_table_update( nil, "END" )
         MsgBeep( "Ne mogu zaključati tabele !#Prekidam operaciju povrata." )
         RETURN .F.
      ENDIF

      o_kalk_za_azuriranje()

      MsgO( "Brišem KALK dokument iz kumulativa ..." )

      SELECT kalk
      HSEEK _id_firma + _id_vd + _br_dok

      IF Found()
         _del_rec := dbf_get_rec()
         lOk := oAtrib:delete_atrib_from_server()
      ENDIF

      IF lOk
         lOk := brisi_dokument_iz_tabele_kalk( _id_firma, _id_vd, _br_dok )
      ENDIF

      IF lOk
         lOk := brisi_dokument_iz_tabele_doks( _id_firma, _id_vd, _br_dok )
      ENDIF

      IF lOk
         lOk := brisi_dokument_iz_tabele_doks2( _id_firma, _id_vd, _br_dok )
      ENDIF

      MsgC()

      IF lOk
         sql_table_update( nil, "END" )
         f18_free_tables( { "kalk_doks", "kalk_kalk", "kalk_doks2" } )

         log_write( "F18_DOK_OPER: povrat dokumenta u pripremu, kalk: " + _id_firma + "-" + _id_vd + "-" + ALLTRIM( _br_dok ), 2 )
      ELSE
         sql_table_update( nil, "ROLLBACK" )
         MsgBeep( "Operacija povrata dokumenta u pripremu neuspješna !" )
      ENDIF

   ENDIF

   my_close_all_dbf()

   RETURN .T.




STATIC FUNCTION otvori_kalk_tabele_za_povrat()

   O_KALK_DOKS
   O_KALK_DOKS2
   O_KALK_PRIPR
   O_KALK
   SET ORDER TO TAG "1"

   RETURN




STATIC FUNCTION brisi_dokument_iz_tabele_doks( cIdFirma, cIdVd, cBrDok )

   LOCAL lOk := .T.
   LOCAL _rec

   SELECT kalk_doks
   HSEEK cIdFirma + cIdVd + cBrDok

   IF Found()
      _rec := dbf_get_rec()
      lOk := delete_rec_server_and_dbf( "kalk_doks", _rec, 1, "CONT" )
   ENDIF

   RETURN lOk



STATIC FUNCTION brisi_dokument_iz_tabele_doks2( cIdFirma, cIdVd, cBrDok )

   LOCAL lOk := .T.
   LOCAL _rec

   SELECT kalk_doks2
   HSEEK cIdFirma + cIdVd + cBrDok

   IF Found()
      _rec := dbf_get_rec()
      lOk := delete_rec_server_and_dbf( "kalk_doks2", _rec, 1, "CONT" )
   ENDIF

   RETURN lOk



STATIC FUNCTION brisi_dokument_iz_tabele_kalk( cIdFirma, cIdVd, cBrDok )

   LOCAL lOk := .T.
   LOCAL _rec

   SELECT kalk
   HSEEK cIdFirma + cIdVd + cBrDok

   IF Found()
      _rec := dbf_get_rec()
      lOk := delete_rec_server_and_dbf( "kalk_kalk", _rec, 2, "CONT" )
   ENDIF

   RETURN lOk





STATIC FUNCTION kalk_kopiraj_dokument_u_tabelu_pripreme( cFirma, cIdVd, cBroj )

   LOCAL _rec

   SELECT kalk
   HSEEK cFirma + cIdVd + cBroj

   MsgO( "Prebacujem dokument u pripremu ..." )

   DO WHILE !Eof() .AND. cFirma == field->IdFirma .AND. cIdVd == field->IdVD .AND. cBroj == field->BrDok

      SELECT kalk
      _rec := dbf_get_rec()
      SELECT kalk_pripr

      IF ! ( _rec[ "idvd" ] $ "97" .AND. _rec[ "tbanktr" ] == "X" )
         APPEND ncnl
         _rec[ "error" ] := ""
         dbf_update_rec( _rec )
      ENDIF

      SELECT kalk
      SKIP

   ENDDO

   MsgC()

   RETURN



STATIC FUNCTION kalk_povrat_prema_kriteriju()

   LOCAL _br_dok := Space( 80 )
   LOCAL _dat_dok := Space( 80 )
   LOCAL _id_vd := Space( 80 )
   LOCAL _usl_br_dok
   LOCAL _usl_dat_dok
   LOCAL _usl_id_vd
   LOCAL lBrisiKumulativ := .F.
   LOCAL _filter
   LOCAL _id_firma := gFirma
   LOCAL _rec
   LOCAL _del_rec
   LOCAL _dok_hash, oAtrib, __firma, __idvd, __brdok
   LOCAL lOk := .T.
   LOCAL lRet := .F.

   IF !SigmaSif()
      my_close_all_dbf()
      RETURN lRet
   ENDIF

   Box(, 3, 60 )

   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "Vrste kalk.    " GET _id_vd PICT "@S40"
      @ m_x + 2, m_y + 2 SAY "Broj dokumenata" GET _br_dok PICT "@S40"
      @ m_x + 3, m_y + 2 SAY "Datumi         " GET _dat_dok PICT "@S40"
      READ
      _usl_br_dok := Parsiraj( _br_dok, "BrDok", "C" )
      _usl_dat_dok := Parsiraj( _dat_dok, "DatDok", "D" )
      _usl_id_vd := Parsiraj( _id_vd, "IdVD", "C" )
      IF _usl_br_dok <> NIL .AND. _usl_dat_dok <> NIL .AND. _usl_id_vd <> NIL
         EXIT
      ENDIF
   ENDDO

   Boxc()

   IF Pitanje(, "Vratiti u pripremu kalk dokumente sa ovim kriterijom (D/N) ?", "N" ) == "D"

      lBrisiKumulativ := Pitanje(, "Izbrisati dokument iz kumulativne tabele (D/N) ?", "D" ) == "D"

      SELECT kalk

      _filter := "IDFIRMA==" + dbf_quote( _id_firma ) + ".and." + _usl_br_dok + ".and." + _usl_id_vd + ".and." + _usl_dat_dok
      _filter := StrTran( _filter, ".t..and.", "" )

      IF !( _filter == ".t." )
         SET FILTER TO &( _filter )
      ENDIF

      SELECT kalk
      GO TOP

      MsgO( "Prolaz kroz kumulativnu datoteku KALK..." )

      DO WHILE !Eof()

         SELECT kalk

         __firma := field->idfirma
         __idvd := field->idvd
         __brdok := field->brdok

         _rec := dbf_get_rec()

         SELECT kalk_pripr

         IF ! ( _rec[ "idvd" ] $ "97" .AND. _rec[ "tbanktr" ] == "X" )

            APPEND ncnl
            _rec[ "error" ] := ""
            dbf_update_rec( _rec )

            _dok_hash := hb_Hash()
            _dok_hash[ "idfirma" ] := __firma
            _dok_hash[ "idtipdok" ] := __idvd
            _dok_hash[ "brdok" ] := __brdok

            oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
            oAtrib:dok_hash := _dok_hash
            oAtrib:atrib_server_to_dbf()

         ENDIF

         SELECT kalk
         SKIP

      ENDDO

      MsgC()

      SELECT kalk
      SET ORDER TO TAG "1"
      GO TOP

      IF !lBrisiKumulativ
         my_close_all_dbf()
         RETURN lRet
      ENDIF

      MsgO( "Brišem tabele sa servera ..." )

      sql_table_update( nil, "BEGIN" )

      IF !f18_lock_tables( { "kalk_doks", "kalk_kalk", "kalk_doks2" }, .T. )
         sql_table_update( nil, "END" )
         MsgBeep( "Ne mogu zaključati tabele !#Prekidam proceduru povrata." )
         RETURN lRet
      ENDIF

      DO WHILE !Eof()

         _id_firma := field->idfirma
         _id_vd := field->idvd
         _br_dok := field->brdok

         _del_rec := dbf_get_rec()

         DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idvd == _id_vd .AND. field->brdok == _br_dok
            SKIP
         ENDDO

         _t_rec := RecNo()

         _ok := .T.

         _dok_hash := hb_Hash()
         _dok_hash[ "idfirma" ] := _id_firma
         _dok_hash[ "idtipdok" ] := _id_vd
         _dok_hash[ "brdok" ] := _br_dok

         oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
         oAtrib:dok_hash := _dok_hash

         lOk := oAtrib:delete_atrib_from_server()

         IF lOk
            lOk := delete_rec_server_and_dbf( "kalk_kalk", _del_rec, 2, "CONT" )
         ENDIF

         IF lOk
            SELECT kalk_doks
            GO TOP
            SEEK _id_firma + _id_vd + _br_dok

            IF Found()
               log_write( "F18_DOK_OPER: kalk brisanje vise dokumenata: " + _id_firma + _id_vd + _br_dok, 2 )
               _del_rec := dbf_get_rec()
               lOk :=  delete_rec_server_and_dbf( "kalk_doks", _del_rec, 1, "CONT" )
            ENDIF
         ENDIF

         IF !lOk
            EXIT
         ENDIF

         SELECT kalk
         GO ( _t_rec )

      ENDDO

      MsgC()

      IF lOk
         lRet := .T.
         f18_free_tables( { "kalk_doks", "kalk_kalk", "kalk_doks2" } )
         sql_table_update( nil, "END" )
      ELSE
         sql_table_update( nil, "ROLLBACK" )
         MsgBeep( "Problem sa brisanjem podataka iz KALK server tabela !" )
      ENDIF


   ENDIF

   my_close_all_dbf()

   RETURN lRet




STATIC FUNCTION povrat_najnovije_kalkulacije()

   LOCAL nRec
   LOCAL cBrsm
   LOCAL fbof
   LOCAL nVraceno := 0
   LOCAL _rec, _del_rec
   LOCAL lOk := .T.

   otvori_kalk_tabele_za_povrat()

   SELECT kalk
   SET ORDER TO TAG "5"

   cIdfirma := gfirma
   cIdVD := Space( 2 )
   cBrDok := Space( 8 )

   GO BOTTOM

   cIdfirma := idfirma
   dDatDok := datdok

   IF Eof()
      Msg( "Na stanju nema dokumenata !" )
      my_close_all_dbf()
      RETURN
   ENDIF

   IF Pitanje(, "Vratiti u pripremu dokumente od " + DToC( dDatDok ) + " ?", "N" ) == "N"
      my_close_all_dbf()
      RETURN
   ENDIF

   SELECT kalk

   MsgO( "Povrat dokumenata od " + DToC( dDatDok ) + " u pripremu" )

   DO WHILE !Bof() .AND. cIdFirma == IdFirma .AND. datdok == dDatDok

      cIDFirma := idfirma
      cIdvd := idvd
      cBrDok := brdok
      cBrSm := ""

      DO WHILE !Bof() .AND. cIdFirma == IdFirma .AND. cidvd == idvd .AND. cbrdok == brdok

         SELECT kalk

         _rec := dbf_get_rec()

         IF !( _rec[ "tbanktr" ] == "X" )

            SELECT kalk_pripr
            APPEND BLANK

            _rec[ "error" ] := ""
            dbf_update_rec( _rec )

            nVraceno ++

         ELSEIF _rec[ "tbanktr" ] == "X" .AND. ( _rec[ "mu_i" ] == "5" .OR. _rec[ "pu_i" ] == "5" )

            SELECT kalk_pripr

            IF rbr <> _rec[ "rbr" ] .OR. ( idfirma + idvd + brdok ) <> _rec[ "idfirma" ] + _rec[ "idvd" ] + _rec[ "brdok" ]
               nVraceno++
               APPEND BLANK
               _rec[ "error" ] := ""
            ELSE
               _rec[ "kolicinai" ] += kalk_pripr->kolicina
            ENDIF

            _rec[ "error" ] := ""
            _rec[ "tbanktr" ] := ""

            dbf_update_rec( _rec )

         ELSEIF _rec[ "tbanktr" ] == "X" .AND. ( _rec[ "mu_i" ] == "3" .OR. _rec[ "pu_i" ] == "3" )
            IF cBrSm <> ( cBrSm := idfirma + "-" + idvd + "-" + brdok )
               Beep( 1 )
               Msg( "Dokument: " + cbrsm + " je izgenerisan,te je izbrisan bespovratno" )
            ENDIF
         ENDIF

         SELECT kalk
         SKIP -1

         IF Bof()
            fBof := .T.
            nRec := 0
         ELSE
            fBof := .F.
            nRec := RecNo()
            SKIP 1
         ENDIF

         SELECT kalk_doks
         SEEK kalk->( idfirma + idvd + brdok )

         IF Found()
            _del_rec := dbf_get_rec()
            lOk := delete_rec_server_and_dbf( "kalk_doks", _del_rec, 1, "FULL" )
         ENDIF

         IF lOk
            SELECT kalk
            _del_rec := dbf_get_rec()
            lOk := delete_rec_server_and_dbf( "kalk_kalk", _del_rec, 1, "FULL" )
         ENDIF

         IF !lOk
            EXIT
         ENDIF

         GO nRec

         IF fBof
            EXIT
         ENDIF

      ENDDO

      IF !lOk
         EXIT
      ENDIF

   ENDDO

   MsgC()

   my_close_all_dbf()

   RETURN
