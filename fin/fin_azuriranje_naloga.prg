/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

STATIC __tbl_suban := "fin_suban"
STATIC __tbl_nalog := "fin_nalog"
STATIC __tbl_anal := "fin_anal"
STATIC __tbl_sint := "fin_sint"


FUNCTION fin_azuriranje_naloga( automatic )

   LOCAL oServer := sql_data_conn()
   LOCAL aNalozi, _i
   LOCAL cIdFirma, cIdVn, cBrNal
   LOCAL lViseNalogaUPripremi := .F.
   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL hParams := hb_Hash()

   IF ( automatic == NIL )
      automatic := .F.
   ENDIF

   o_fin_za_azuriranje()

   IF fin_pripr->( RecCount() == 0 ) .OR. ( !automatic .AND. Pitanje(, "Izvršiti ažuriranje fin naloga ? (D/N)?", "N" ) == "N" )
      RETURN lRet
   ENDIF

#ifdef F18_DEBUG_FIN_AZUR
   AltD() // F18_DEBUG_FIN_AZUR
#endif
   aNalozi := fin_nalozi_iz_pripreme_u_matricu()

   IF Len( aNalozi ) > 1
      lViseNalogaUPripremi := .T.
   ENDIF

   IF lViseNalogaUPripremi
      fin_gen_ptabele_stampa_nalozi( .T. )
      o_fin_za_azuriranje()
   ENDIF

   IF !fin_provjera_prije_azuriranja_naloga( automatic, aNalozi )
      RETURN lRet
   ENDIF



   FOR _i := 1 TO Len( aNalozi )

      run_sql_query( "BEGIN" )

/*
      IF !f18_lock_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog }, .T. )
         run_sql_query( "ROLLBACK" )
         MsgBeep( "Ne mogu napraviti zaključavanje tabela !#Poništavam operaciju ažuriranja naloga." )
         RETURN lRet
      ENDIF
*/
      cIdFirma := aNalozi[ _i, 1 ]
      cIdVn := aNalozi[ _i, 2 ]
      cBrNal := aNalozi[ _i, 3 ]

      IF fin_dokument_postoji( cIdFirma, cIdVn, cBrNal )

         MsgBeep( "Nalog " + cIdFirma + "-" + cIdVn + "-" + AllTrim( cBrNal ) + " već postoji ažuriran !" )

         IF !lViseNalogaUPripremi
            run_sql_query( "ROLLBACK" )
            RETURN lRet

         ELSE
            LOOP
         ENDIF

      ENDIF

      IF !fin_azur_sql( oServer, cIdFirma, cIdVn, cBrNal )

         run_sql_query( "ROLLBACK" )
         log_write( "F18_DOK_OPER: greška kod ažuriranja fin naloga: " + cIdFirma + "-" + cIdVn + "-" + cBrNal, 2 )

         MsgBeep( "Problem sa ažuriranjem naloga na SQL server !" )

         RETURN lRet

      ENDIF

      fin_pripr_delete( cIdFirma + cIdVn + cBrNal )

/*
      IF !fin_azur_dbf( automatic, cIdFirma, cIdVn, cBrNal )

         run_sql_query( "ROLLBACK" )
         log_write( "F18_DOK_OPER: greška kod ažuriranja fin naloga: " + cIdFirma + "-" + cIdVn + "-" + cBrNal, 2 )
         MsgBeep( "Problem sa ažuriranjem naloga u DBF tabele !" )

         RETURN lRet

      ENDIF
*/

/*
      hParams[ "unlock" ] := { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog }
      run_sql_query( "COMMIT", hParams )
*/
      run_sql_query( "COMMIT" )

      log_write( "F18_DOK_OPER: azuriranje fin naloga: " + cIdFirma + "-" + cIdVn + "-" + cBrNal, 2 )

   NEXT


   SELECT fin_pripr
   my_dbf_pack()

   fin_brisi_p_tabele( .T. )

   lRet := .T.

   RETURN lRet



/*
   Opis: puni matricu sa nalozima iz pripreme, može ih biti različitih
*/

STATIC FUNCTION fin_nalozi_iz_pripreme_u_matricu()

   LOCAL _data := {}
   LOCAL _scan

   SELECT fin_pripr
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      _scan := AScan( _data, {| var| VAR[ 1 ] == field->idfirma .AND. ;
         VAR[ 2 ] == field->idvn .AND. ;
         VAR[ 3 ] == field->brnal  } )

      IF _scan == 0
         AAdd( _data, { field->idfirma, field->idvn, field->brnal } )
      ENDIF

      SKIP
   ENDDO

   GO TOP

   RETURN _data



FUNCTION o_fin_za_azuriranje()

   my_close_all_dbf()

   O_KONTO
   O_PARTN
   O_SIFK
   O_SIFV

   o_suban()
   o_anal()
   o_sint()
   o_nalog()

   o_fin_psuban()
   O_PANAL
   O_PSINT
   O_PNALOG

   O_FIN_PRIPR

   RETURN .T.



FUNCTION fin_azur_sql( oServer, id_firma, id_vn, br_nal )

   LOCAL _ok := .T.
   LOCAL _ids := {}
   LOCAL _tmp_id, _count, _tmp_doc, _rec, _msg, _i
   LOCAL _ids_doc := {}
   LOCAL _ids_tmp := {}
   LOCAL _ids_suban := {}
   LOCAL _ids_sint := {}
   LOCAL _ids_anal := {}
   LOCAL _ids_nalog := {}
   LOCAL _n := 1

   Box(, 5, 60 )

   _tmp_id := "x"

   SELECT psuban
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vn + br_nal

   _count := 0

   DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idvn == id_vn .AND. field->brnal == br_nal

      _rec := dbf_get_rec()

      ++ _count

      IF _count == 1

         _tmp_id := _rec[ "idfirma" ] + _rec[ "idvn" ] + _rec[ "brnal" ]

         AAdd( _ids_suban, "#2" + _tmp_id )
         AAdd( _ids_anal, "#2" + _tmp_id )
         AAdd( _ids_sint, "#2" + _tmp_id )

         AAdd( _ids_nalog, _tmp_id )

         @ m_x + 1, m_y + 2 SAY "fin_suban -> server: " + _tmp_id

      ENDIF

      IF !sql_table_update( "fin_suban", "ins", _rec )
         _ok := .F.
         EXIT
      ENDIF

      SKIP

   ENDDO


   IF _ok

      @ m_x + 2, m_y + 2 SAY "fin_anal -> server"

      SELECT panal
      SET ORDER TO TAG "1"
      GO TOP
      SEEK id_firma + id_vn + br_nal

      DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idvn == id_vn .AND. field->brnal == br_nal

         _rec := dbf_get_rec()

         IF !sql_table_update( "fin_anal", "ins", _rec )
            _ok := .F.
            EXIT
         ENDIF

         SKIP

      ENDDO

   ENDIF


   IF _ok

      @ m_x + 3, m_y + 2 SAY "fin_sint -> server"

      SELECT psint
      SET ORDER TO TAG "1"
      GO TOP
      SEEK id_firma + id_vn + br_nal

      DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idvn == id_vn .AND. field->brnal == br_nal

         _rec := dbf_get_rec()

         IF !sql_table_update( "fin_sint", "ins", _rec )
            _ok := .F.
            EXIT
         ENDIF

         SKIP

      ENDDO

   ENDIF

   IF _ok

      @ m_x + 4, m_y + 2 SAY "fin_nalog -> server"

      SELECT pnalog
      SET ORDER TO TAG "1"
      GO TOP
      SEEK id_firma + id_vn + br_nal

      DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idvn == id_vn .AND. field->brnal == br_nal

         _rec := dbf_get_rec()

         IF !sql_table_update( "fin_nalog", "ins", _rec )
            _ok := .F.
            EXIT
         ENDIF

         SKIP

      ENDDO

   ENDIF

   IF _ok
      _ok := push_ids_to_semaphore( __tbl_suban, _ids_suban ) .AND. ;
         push_ids_to_semaphore( __tbl_sint, _ids_sint  ) .AND. ;
         push_ids_to_semaphore( __tbl_anal, _ids_anal  ) .AND. ;
         push_ids_to_semaphore( __tbl_nalog, _ids_nalog )
   ENDIF

   BoxC()

   RETURN _ok



STATIC FUNCTION fin_provjera_prije_azuriranja_naloga( auto, lista_naloga )

   LOCAL _t_area, _i, _t_rec
   LOCAL cIdFirma, cIdVn, cBrNal
   LOCAL _vise_naloga := .F.
   LOCAL _ok := .F.

   _t_area := Select()
#ifdef F18_DEBUG_FIN_AZUR
   AltD() // F18_DEBUG_FIN_AZUR
#endif

   IF Len( lista_naloga ) > 1
      _vise_naloga := .T.
   ENDIF

   IF !_vise_naloga .AND. fin_p_nalog_bez_provjere( auto )
      _ok := .T.
      RETURN _ok
   ENDIF


   IF !fin_p_tabele_provjera( lista_naloga )

      IF !_vise_naloga
         MsgBeep( "Potrebno izvršiti štampu naloga prije ažuriranja !" )
      ENDIF

      RETURN _ok

   ENDIF

   IF !fin_provjeri_konto_partn( lista_naloga )
      MsgBeep( "Ispravite greške sa nepostojećim šiframa pa pokusajte ponovo !" )
      RETURN _ok
   ENDIF

   FOR _i := 1 TO Len( lista_naloga )

      cIdFirma := lista_naloga[ _i, 1 ]
      cIdVn := lista_naloga[ _i, 2 ]
      cBrNal := lista_naloga[ _i, 3 ]

      SELECT fin_pripr
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cIdFirma + cIdVn + cBrNal

      _t_rec := RecNo()

      IF Len( AllTrim( field->brnal ) ) < 8
         MsgBeep( "Broj naloga mora biti sa vodećim nulama !" )
         SELECT ( _t_area )
         RETURN _ok
      ENDIF

      IF !fin_p_provjeri_redni_broj( cIdFirma, cIdVn, cBrNal )
         SELECT ( _t_area )
         RETURN _ok
      ENDIF


      IF !fin_saldo_provjera_psuban( cIdFirma, cIdVn, cBrNal )
         SELECT ( _t_area )
         RETURN _ok
      ENDIF

   NEXT

   _ok := .T.

   RETURN _ok


STATIC FUNCTION fin_provjeri_konto_partn( lista_naloga )

   LOCAL _ok := .F.
   LOCAL _err := {}

   SELECT psuban
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()
      psuban_partner_check( @_err, .T. )
      psuban_konto_check( @_err, .T. )
      SKIP
   ENDDO

   IF Len( _err ) > 0
      fin_brisi_p_tabele( .T. )
      prikazi_greske_provjere_konta_i_partnera( _err )
      o_fin_za_azuriranje()
      SELECT fin_pripr
      GO TOP
      RETURN _ok
   ENDIF

   _ok := .T.

   RETURN _ok


STATIC FUNCTION prikazi_greske_provjere_konta_i_partnera( err )

   LOCAL _i
   LOCAL _cnt := 0
   LOCAL _head, _line

   _head := PadR( "R.br", 5 )
   _head += Space( 1 )
   _head += PadR( "Vrsta", 10 )
   _head += Space( 1 )
   _head += PadR( "Šifra", 10 )
   _head += Space( 1 )
   _head += PadR( "Na rednom broju", 30 )

   _line := Replicate( "-", 5 )
   _line += Space( 1 )
   _line += Replicate( "-", 10 )
   _line += Space( 1 )
   _line += Replicate( "-", 10 )
   _line += Space( 1 )
   _line += Replicate( "-", 30 )

   start_print_editor()
   ?

   ?U "Lista nepostojećih šifara na dokumentu:"
   ? "===================================================="
   ?
   ? _line
   ?U _head
   ? _line

   FOR _i := 1 TO Len( err )
      ? PadL( AllTrim( Str( ++_cnt ) ), 4 ) + "."
      @ PRow(), PCol() + 1 SAY PadR( err[ _i, 1 ], 10 )
      @ PRow(), PCol() + 1 SAY PadR( err[ _i, 2 ], 10 )
      @ PRow(), PCol() + 1 SAY AllTrim( err[ _i, 3 ] )

   NEXT

   ? _line
   ?U "Prije ažuriranja naloga, u šifarnike potrebno ubaciti nabrojane šifre !"


   end_print_editor()

   RETURN .T.





STATIC FUNCTION fin_p_provjeri_redni_broj( id_firma, id_vn, br_nal )

   LOCAL _ok := .T.
   LOCAL _tmp

   SELECT psuban
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vn + br_nal

   DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idvn == id_vn .AND. field->brnal == br_nal

      _tmp := field->rbr

      SKIP 1

      IF _tmp == field->rbr
         _ok := .F.
         MsgBeep( "Nalog " + id_firma + "-" + id_vn + "-" + br_nal + " nema ispravne redne brojeve !" )
         RETURN _ok
      ENDIF

   ENDDO

   RETURN _ok





STATIC FUNCTION fin_p_nalog_bez_provjere( auto )

   LOCAL _ok := .F.

   SELECT psuban
   SET ORDER TO TAG "1"
   GO TOP

   IF RecCount2() > 9999 .AND. !auto
      IF Pitanje(, "Staviti na stanje bez provjere (D/N) ?", "N" ) == "D"
         _ok := .T.
      ENDIF
   ENDIF

   RETURN _ok



STATIC FUNCTION fin_saldo_provjera_psuban( id_firma, id_vn, br_nal )

   LOCAL _ok := .F.
   LOCAL _tmp, _saldo

   IF gRavnot == "N"
      _ok := .T.
      RETURN _ok
   ENDIF

   SELECT psuban
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vn + br_nal

   _saldo := 0

   DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idvn == id_vn .AND. field->brnal == br_nal

      IF field->d_p == "1"
         _saldo += field->iznosbhd
      ELSE
         _saldo -= field->iznosbhd
      ENDIF

      SKIP

   ENDDO

   IF Round( _saldo, 4 ) <> 0
      Beep( 3 )
      Msg( "Neophodna ravnoteža naloga " + id_firma + "-" + id_vn + "-" + AllTrim( br_nal ) + "##, ažuriranje neće biti izvršeno!" )
      RETURN _ok
   ENDIF

   _ok := .T.

   RETURN _ok




STATIC FUNCTION fin_p_tabele_provjera( lista_naloga )

   LOCAL _ok := .F.
   LOCAL _i
   LOCAL cIdFirma, cIdVn, cBrNal

   SELECT psuban
   IF RecCount2() == 0
      RETURN .F.
   ENDIF

   SELECT panal
   IF RecCount2() == 0
      RETURN .F.
   ENDIF

   SELECT psint
   IF RecCount2() == 0
      RETURN .F.
   ENDIF

   FOR _i := 1 TO Len( lista_naloga )

      cIdFirma := lista_naloga[ _i, 1 ]
      cIdVn := lista_naloga[ _i, 2 ]
      cBrNal := lista_naloga[ _i, 3 ]

      SELECT psuban
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cIdFirma + cIdVn + cBrNal

      IF !Found()
         MsgBeep( "Nalog " + cIdFirma + "-" + cIdVn + "-" + AllTrim( cBrNal ) + " ne postoji u PSUBAN !" )
         RETURN _ok
      ENDIF

   NEXT

   _ok := .T.

   RETURN _ok



/*
FUNCTION fin_azur_dbf( auto, id_firma, id_vn, br_nal )

   LOCAL _n_c
   LOCAL _t_area := Select()
   LOCAL _saldo
   LOCAL _ctrl
   LOCAL _ok := .T.

   Box( "ad", 10, MAXCOLS() - 10 )

   SELECT psuban
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vn + br_nal

   _saldo := 0

   DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idvn == id_vn .AND. field->brnal == br_nal

      _ctrl := field->idfirma + field->idvn + field->brnal

      @ m_x + 1, m_y + 2 SAY8 "DBF: ažuriram nalog: " + field->idfirma + "-" + field->idvn + "-" + AllTrim( field->brnal )

      IF field->d_p == "1"
         _saldo += field->iznosbhd
      ELSE
         _saldo -= field->iznosbhd
      ENDIF

      SKIP

   ENDDO

   pnalog_nalog( _ctrl )
   panal_anal( _ctrl )
   psint_sint( _ctrl )
   psuban_suban( _ctrl )

   fin_pripr_delete( _ctrl )

   SELECT psuban

   BoxC()

   RETURN _ok

*/

STATIC FUNCTION fin_brisi_p_tabele( close_all )

   IF close_all == NIL
      close_all := .F.
   ENDIF

   SELECT PNALOG
   my_dbf_zap()

   SELECT PSUBAN
   my_dbf_zap()

   SELECT PANAL
   my_dbf_zap()

   SELECT PSINT
   my_dbf_zap()

   IF close_all
      my_close_all_dbf()
   ENDIF

   RETURN .T.



FUNCTION psuban_partner_check( arr, silent )

   LOCAL _ok := .T.
   LOCAL _scan

   IF Empty( psuban->idpartner )
      RETURN _ok
   ENDIF

   IF silent == NIL
      silent := .F.
   ENDIF

   SELECT partn
   HSEEK psuban->idpartner

   IF !Found()

      _ok := .F.

      _scan := AScan( arr, {| val| val[ 1 ] + val[ 2 ] == "PARTN" + psuban->idpartner } )

      IF _scan == 0
         AAdd( arr, { "PARTN", psuban->idpartner, Str( psuban->rbr, 5, 0 ) } )
      ENDIF

      IF !silent
         MsgBeep( "Stavka br." + psuban->rbr + " : Nepostojeća šifra partnera!#Partner id: " + psuban->idpartner )
      ENDIF

   ENDIF

   SELECT psuban

   RETURN _ok



FUNCTION psuban_konto_check( arr, silent )

   LOCAL _ok := .T.
   LOCAL _scan

   IF Empty( psuban->idkonto )
      RETURN _ok
   ENDIF

   IF silent == NIL
      silent := .F.
   ENDIF

   SELECT konto
   HSEEK psuban->idkonto

   IF !Found()

      _ok := .F.

      _scan := AScan( arr, {| val| val[ 1 ] + val[ 2 ] == "KONTO" + psuban->idkonto } )

      IF _scan == 0
         AAdd( arr, { "KONTO", psuban->idkonto, Str( psuban->rbr, 5, 0 ) } )
      ENDIF

      IF !silent
         MsgBeep( "Stavka br." + psuban->rbr + " : Nepostojeća šifra konta!#Konto id: " + psuban->idkonto )
      ENDIF

   ENDIF

   SELECT psuban

   RETURN _ok



FUNCTION panal_anal( cNalogId )

   LOCAL _rec

   @ m_x + 3, m_y + 2 SAY "ANALITIKA       "

   SELECT panal
   SEEK cNalogId

   DO WHILE !Eof() .AND. cNalogId == IdFirma + IdVn + BrNal

      _rec := dbf_get_rec()

      SELECT ANAL
      APPEND BLANK

      dbf_update_rec( _rec, .F. )

      SELECT PANAL
      SKIP

   ENDDO

   RETURN .T.




FUNCTION psint_sint( cNalogId )

   LOCAL _rec

   @ m_x + 3, m_y + 2 SAY "SINTETIKA       "
   SELECT PSINT
   SEEK cNalogId

   DO WHILE !Eof() .AND. cNalogId == IdFirma + IdVn + BrNal

      _rec := dbf_get_rec()

      SELECT SINT

      APPEND BLANK
      dbf_update_rec( _rec, .F. )

      SELECT PSINT
      SKIP

   ENDDO

   RETURN .T.




FUNCTION pnalog_nalog( cNalogId )

   LOCAL _rec

   SELECT pnalog
   SEEK cNalogId

   IF Found()

      _rec := dbf_get_rec()

      SELECT nalog
      APPEND BLANK

      dbf_update_rec( _rec, .F. )

   ELSE

      Beep( 4 )
      Msg( "Greška... ponovi štampu naloga ..." )

   ENDIF

   RETURN .T.



FUNCTION psuban_suban( cNalogId )

   LOCAL nSaldo := 0
   LOCAL nC := 0
   LOCAL _rec

   @ m_x + 3, m_y + 2 SAY "SUBANALITIKA   "


   SELECT PSUBAN
   SEEK cNalogId

   find_suban_by_broj_dokumenta( psuban->idfirma, psuban->idvn, psuban->brnal, .T. )


   SELECT PSUBAN
   nC := 0

   DO WHILE !Eof() .AND. cNalogId == IdFirma + IdVn + BrNal

      @ m_x + 3, m_y + 25 SAY ++nC  PICT "99999999999"

      _rec := dbf_get_rec()

      IF _rec[ "d_p" ] == "1"
         nSaldo := _rec[ "iznosbhd" ]
      ELSE
         nSaldo := -_rec[ "iznosbhd" ]
      ENDIF

      find_suban_by_konto_partner( _rec[ "idfirma" ], _rec[ "idkonto" ], _rec[ "idpartner" ], _rec[ "brdok" ] )

      nRec := RecNo()
      DO WHILE  !Eof() .AND. ( _rec[ "idfirma" ] + _rec[ "idkonto" ] + _rec[ "idpartner" ] + _rec[ "brdok" ] ) == ( IdFirma + IdKonto + IdPartner + BrDok )
         IF _rec[ "d_p" ] == "1"
            nSaldo += field->IznosBHD
         ELSE
            nSaldo -= field->IznosBHD
         ENDIF
         SKIP
      ENDDO

      IF Abs( Round( nSaldo, 3 ) ) <= gnLOSt

         GO nRec
         DO WHILE  !Eof() .AND. ( _rec[ "idfirma" ] + _rec[ "idkonto" ] + _rec[ "idpartner" ] + _rec[ "brdok" ] ) == ( IdFirma + IdKonto + IdPartner + BrDok )

            _rec_2 := dbf_get_rec()
            _rec_2[ "otvst" ] := "9"
            update_rec_server_and_dbf( "fin_suban", _rec_2, 1, "FULL" )

            SKIP

         ENDDO
         _rec[ "otvSt" ] := "9"

      ENDIF

      SELECT SUBAN
      APPEND BLANK

      dbf_update_rec( _rec, .T. )

      SELECT PSUBAN
      SKIP

   ENDDO

   RETURN .T.



FUNCTION fin_pripr_delete( cNalogId )

   LOCAL _t_rec

   SELECT fin_pripr
   SEEK cNalogId

   // @ m_x + 3, m_y + 2 SAY8 "BRIŠEM PRIPREMU "
   MsgO( "Brisanje fin_pripr" )
   my_flock()

   DO WHILE !Eof() .AND. cNalogId == IdFirma + IdVn + BrNal

      SKIP
      _t_rec := RecNo()
      SKIP -1
      DELETE
      GO ( _t_rec )

   ENDDO

   MsgC()

   RETURN .T.


FUNCTION fin_dokument_postoji( id_firma, id_vn, br_nal )

   LOCAL lExist := .F.
   LOCAL cWhere

   cWhere := "idfirma = " + sql_quote( id_firma )
   cWhere += " AND idvn = " + sql_quote( id_vn )
   cWhere += " AND brnal = " + sql_quote( br_nal )

   IF table_count( F18_PSQL_SCHEMA_DOT + "fin_nalog", cWhere ) > 0
      lExist := .T.
   ENDIF

   RETURN lExist
