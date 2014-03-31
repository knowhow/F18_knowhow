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

#include "fin.ch"

STATIC __tbl_suban := "fin_suban"
STATIC __tbl_nalog := "fin_nalog"
STATIC __tbl_anal := "fin_anal"
STATIC __tbl_sint := "fin_sint"


// ---------------------------------------------------
// ---------------------------------------------------
FUNCTION fin_azur( automatic )

   LOCAL oServer := pg_server()
   LOCAL _nalozi, _i
   LOCAL _id_firma, _id_vn, _br_nal
   LOCAL _vise_naloga := .F.
   LOCAL _ok := .F.

   IF ( automatic == NIL )
      automatic := .F.
   ENDIF

   // otvori potrebne tabele
   o_fin_za_azuriranje()

   IF fin_pripr->( RecCount() == 0 ) .OR. ( !automatic .AND. Pitanje( "pAz", "Izvrsiti azuriranje fin naloga ? (D/N)?", "N" ) == "N" )
      RETURN _ok
   ENDIF

   // daj mi sve naloge iz pripreme u matricu...
   // za azuriranje vise naloga od jednom...
   _nalozi := get_fin_nalozi()

   // ima li vise razlicitih naloga u pripremi ?
   IF Len( _nalozi ) > 1
      _vise_naloga := .T.
   ENDIF

   // napuni mi pomocne tabele
   // ako je u pripremi vise naloga...
   IF _vise_naloga
      // napuni mi pomocne tabele
      StNal( .T. )
      // otvori ponovo tabele
      o_fin_za_azuriranje()
   ENDIF

   // napravi sve provjere prije azuriranja naloga...
   // ako nesto nije ok, prekinut ces operaciju...
   IF !fin_azur_check( automatic, _nalozi )
      RETURN _ok
   ENDIF

   // AZURIRANJE
   // ======================================================

   // lokuj mi tabele prije svega....
   IF !f18_lock_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog } )
      MsgBeep( "Problem sa lock-om tabela za azuriranje !!!#Prekidam operaciju..." )
      RETURN _ok
   ENDIF

   sql_table_update( nil, "BEGIN" )

   MsgO( "Azuriranje naloga u toku ...." )

   FOR _i := 1 TO Len( _nalozi )

      // tekuci nalog...
      _id_firma := _nalozi[ _i, 1 ]
      _id_vn := _nalozi[ _i, 2 ]
      _br_nal := _nalozi[ _i, 3 ]

      // postoji li nalog na serveru ?
      IF fin_doc_exist( _id_firma, _id_vn, _br_nal )

         MsgBeep( "Nalog " + _id_firma + "-" + _id_vn + "-" + _br_nal + " vec postoji azuriran !!!" )

         IF !_vise_naloga

            // zavrsi ti ovu transakciju
            f18_free_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog } )
            sql_table_update( nil, "ROLLBACK" )
	
            MsgC()

            RETURN _ok

         ELSE
            // preskoci do narednog broja naloga
            LOOP
         ENDIF

      ENDIF

      // azuriraj SQL podatke
      IF !fin_azur_sql( oServer, _id_firma, _id_vn, _br_nal )

         f18_free_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog } )
         sql_table_update( nil, "ROLLBACK" )
		
         MsgC()
         MsgBeep( "Problem sa azuriranjem naloga na SQL server !!!" )

         RETURN _ok

      ENDIF

      // azuriraj DBF podatke
      IF !fin_azur_dbf( automatic, _id_firma, _id_vn, _br_nal )

         f18_free_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog } )
         sql_table_update( nil, "ROLLBACK" )
	
         MsgC()
         MsgBeep( "Problem sa azuriranjem naloga u DBF tabele !!!" )

         RETURN _ok

      ENDIF

      // upisi i u log operaciju azuriranja...
      log_write( "F18_DOK_OPER: azuriranje fin naloga: " + _id_firma + "-" + _id_vn + "-" + _br_nal, 2 )

   NEXT

   MsgC()

   // sve proteklo ok... otkljucaj i zavrsi transakciju
   f18_free_tables( { __tbl_suban, __tbl_anal, __tbl_sint, __tbl_nalog } )
   sql_table_update( nil, "END" )
	
   SELECT fin_pripr
   my_dbf_pack()

   // pobrisi pomocne tabele
   fin_brisi_p_tabele( .T. )

   _ok := .T.

   RETURN _ok



// ------------------------------------------------
// popunjava sve u matricu iz pripreme
// ubacuje naloge razlicitih vrsta ili jedan
// ------------------------------------------------
STATIC FUNCTION get_fin_nalozi()

   LOCAL _data := {}
   LOCAL _scan

   SELECT fin_pripr
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      _scan := AScan( _data, {|var| VAR[ 1 ] == field->idfirma .AND. ;
         VAR[ 2 ] == field->idvn .AND. ;
         VAR[ 3 ] == field->brnal  } )

      IF _scan == 0
         AAdd( _data, { field->idfirma, field->idvn, field->brnal } )
      ENDIF

      SKIP
   ENDDO

   GO TOP

   RETURN _data


// -----------------------------
// -----------------------------
FUNCTION o_fin_za_azuriranje()

   CLOSE ALL

   // kumulativne...
   O_KONTO
   O_PARTN
   O_SIFK
   O_SIFV

   O_FIN_PRIPR

   O_SUBAN
   O_ANAL
   O_SINT
   O_NALOG

   // pomocne
   O_PSUBAN
   O_PANAL
   O_PSINT
   O_PNALOG

   RETURN






// -----------------------------------------------------------------
// Azuriranje podataka na SQL server
// -----------------------------------------------------------------
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

   // azuriranje FIN_SUBAN
   // ======================================

   SELECT psuban
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vn + br_nal

   // upisi u log operaciju
   log_write( "FIN, azuriranje naloga: " + id_firma + "-" + id_vn + "-" + br_nal + " - START", 3 )
	
   _count := 0

   DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idvn == id_vn .AND. field->brnal == br_nal

      _rec := dbf_get_rec()

      ++ _count

      // dodaj za semafor na prvom zapisu subana...
      IF _count == 1

         // ovo su IDS-ovi
         _tmp_id := _rec[ "idfirma" ] + _rec[ "idvn" ] + _rec[ "brnal" ]
			
         // nivo dokumenta #2
         AAdd( _ids_suban, "#2" + _tmp_id )
         AAdd( _ids_anal, "#2" + _tmp_id )
         AAdd( _ids_sint, "#2" + _tmp_id )
			
         // regularni IDS
         AAdd( _ids_nalog, _tmp_id )

         @ m_x + 1, m_y + 2 SAY "fin_suban -> server: " + _tmp_id

      ENDIF

      // pusti na server...
      IF !sql_table_update( "fin_suban", "ins", _rec )
         _ok := .F.
         EXIT
      ENDIF

      SKIP
	
   ENDDO

	
   // azuriranje FIN_ANAL
   // -----------------------------------

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

	
   // azuriranje FIN_SINT
   // -----------------------------------

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


   // azuriranje FIN_NALOG
   // -----------------------------------

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


   IF !_ok
      // transakcija je neuspjesna...
      _msg := "FIN azuriranje, trasakcija " + _tmp_id + " neuspjesna ?!"
      log_write( _msg, 2 )
      MsgBeep( _msg )
   ELSE

      // pushiraj IDS-ove na semafore
      push_ids_to_semaphore( __tbl_suban, _ids_suban )
      push_ids_to_semaphore( __tbl_sint, _ids_sint  )
      push_ids_to_semaphore( __tbl_anal, _ids_anal  )
      push_ids_to_semaphore( __tbl_nalog, _ids_nalog )

      log_write( "FIN, azuriranje naloga " + id_firma + "-" + id_vn + "-" + br_nal + " - END", 3 )

   ENDIF

   BoxC()

   RETURN _ok



// ----------------------------
// provjeri prije azuriranja
// pokrece se serija testova...
// ----------------------------
FUNCTION fin_azur_check( auto, lista_naloga )

   LOCAL _t_area, _i, _t_rec
   LOCAL _id_firma, _id_vn, _br_nal
   LOCAL _vise_naloga := .F.
   LOCAL _ok := .F.

   _t_area := Select()

   // ima li vise naloga
   IF Len( lista_naloga ) > 1
      _vise_naloga := .T.
   ENDIF

   // da li je nalog ogroman, treba li ga provjeravati uopste ?
   IF !_vise_naloga .AND. fin_p_nalog_bez_provjere( auto )
      _ok := .T.
      RETURN _ok
   ENDIF

   // 1) provjera pomocnih tabela
   IF !fin_p_tabele_provjera( lista_naloga )
	
      // u slucaju da je samo jedan nalog u pitanju
      // to je moguci uzrok !

      IF !_vise_naloga
         MsgBeep( "Potrebno izvrsiti stampu naloga prije azuriranja !!!" )
      ENDIF

      RETURN _ok

   ENDIF

   // fin, provjeri konto/partner
   IF !fin_provjeri_konto_partn( lista_naloga )
      MsgBeep( "Ispravite greske sa nepostojecim siframa pa pokusajte ponovo !!!" )
      RETURN _ok
   ENDIF

   // prodji seriju testova
   FOR _i := 1 TO Len( lista_naloga )

      _id_firma := lista_naloga[ _i, 1 ]
      _id_vn := lista_naloga[ _i, 2 ]
      _br_nal := lista_naloga[ _i, 3 ]

      // pronadji mi nalog prvo !!!
      SELECT fin_pripr
      SET ORDER TO TAG "1"
      GO TOP
      SEEK _id_firma + _id_vn + _br_nal

      _t_rec := RecNo()
	
      // 2) provjeri da li je broj naloga zadovoljen
      // ovo ce raditi jos u tekucoj 1.4.x verziji a poslije treba izbaciti !!!

      IF Len( AllTrim( field->brnal ) ) < 8
         // mora biti LEN = 8
         MsgBeep( "Broj naloga mora biti sa vodecim nulama !?!" )
         SELECT ( _t_area )
         RETURN _ok
      ENDIF

      // 3) provjera rednih brojeva u nalogu
      IF !fin_p_provjeri_redni_broj( _id_firma, _id_vn, _br_nal )
         SELECT ( _t_area )
         RETURN _ok
      ENDIF

      // 4) fin saldo provjera
      IF !fin_p_saldo_provjera( _id_firma, _id_vn, _br_nal )
         SELECT ( _t_area )
         RETURN _ok
      ENDIF

   NEXT

   // sve je ok
   _ok := .T.

   RETURN _ok


// ---------------------------------------------------------------
// provjerava zapise konto/partn i pretrazuje po sifrniku
// ---------------------------------------------------------------
STATIC FUNCTION fin_provjeri_konto_partn( lista_naloga )

   LOCAL _ok := .F.
   LOCAL _err := {}

   SELECT psuban
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      // ima li partnera ?
      psuban_partner_check( @_err, .T. )
      // ima li konto ??
      psuban_konto_check( @_err, .T. )

      SKIP

   ENDDO

   IF Len( _err ) > 0

      // imamo gresaka !!!
      fin_brisi_p_tabele( .T. )

      // prikazi na ekranu
      _rpt_error( _err )

      o_fin_za_azuriranje()
      SELECT fin_pripr
      GO TOP

      RETURN _ok

   ENDIF

   _ok := .T.

   RETURN _ok


// ------------------------------------------------------------
// prikazi listu nedostajecih konta, partnera
// ------------------------------------------------------------
STATIC FUNCTION _rpt_error( err )

   LOCAL _i
   LOCAL _cnt := 0
   LOCAL _head, _line

   _head := PadR( "R.br", 5 )
   _head += Space( 1 )
   _head += PadR( "Vrsta", 10 )
   _head += Space( 1 )
   _head += PadR( "Sifra", 10 )
   _head += Space( 1 )
   _head += PadR( "Na rednom broju", 30 )

   _line := Replicate( "-", 5 )
   _line += Space( 1 )
   _line += Replicate( "-", 10 )
   _line += Space( 1 )
   _line += Replicate( "-", 10 )
   _line += Space( 1 )
   _line += Replicate( "-", 30 )

   START PRINT CRET
   ?

   ? "Lista nepostojecih sifara na dokumentu:"
   ? "===================================================="
   ?
   ? _line
   ? _head
   ? _line

   FOR _i := 1 TO Len( err )
      ? PadL( AllTrim( Str( ++_cnt ) ), 4 ) + "."
      @ PRow(), PCol() + 1 SAY PadR( err[ _i, 1 ], 10 )
      @ PRow(), PCol() + 1 SAY PadR( err[ _i, 2 ], 10 )
      @ PRow(), PCol() + 1 SAY AllTrim( err[ _i, 3 ] )

   NEXT

   ? _line
   ? "Prije azuriranja naloga, u sifrarnike potrebno ubaciti nabrojane sifre !"

   FF
   ENDPRINT

   RETURN





// ------------------------------------------------
// provjera rednog broja u tabeli
// ------------------------------------------------
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





// -----------------------------------------------------------------------------------
// provjerava da li se radi o velikom nalogu i treba li ga uopste provjeravati ?
// -----------------------------------------------------------------------------------
STATIC FUNCTION fin_p_nalog_bez_provjere( auto )

   LOCAL _ok := .F.

   SELECT psuban
   SET ORDER TO TAG "1"
   GO TOP

   IF RecCount2() > 9999 .AND. !auto
      IF Pitanje(, "Staviti na stanje bez provjere ?", "N" ) == "D"
         _ok := .T.
      ENDIF
   ENDIF

   RETURN _ok



// --------------------------------------------------------------------------------------
// provjera salda naloga
// --------------------------------------------------------------------------------------
STATIC FUNCTION fin_p_saldo_provjera( id_firma, id_vn, br_nal )

   LOCAL _ok := .F.
   LOCAL _tmp, _saldo

   // ako nije neophodna ravnoteza naloga, bye bye
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

   // saldo nije dobar !!!
   IF Round( _saldo, 4 ) <> 0
      Beep( 3 )
      Msg( "Neophodna ravnoteza naloga " + id_firma + "-" + id_vn + "-" + AllTrim( br_nal ) + "##, azuriranje nece biti izvrseno!" )
      RETURN _ok
   ENDIF

   // sve ok
   _ok := .T.

   RETURN _ok




// -------------------------------------------------------
// provjera pomocnih tabela, prije stampe
// -------------------------------------------------------
STATIC FUNCTION fin_p_tabele_provjera( lista_naloga )

   LOCAL _ok := .F.
   LOCAL _i
   LOCAL _id_firma, _id_vn, _br_nal

   SELECT psuban
   IF RecCount2() == 0
      RETURN _ok
   ENDIF

   SELECT panal
   IF RecCount2() == 0
      RETURN _ok
   ENDIF

   SELECT psint
   IF RecCount2() == 0
      RETURN _ok
   ENDIF

   // treba provjeriti ima li naloga u psuban ???? takodjer
   // na osnovu liste
   FOR _i := 1 TO Len( lista_naloga )

      _id_firma := lista_naloga[ _i, 1 ]
      _id_vn := lista_naloga[ _i, 2 ]
      _br_nal := lista_naloga[ _i, 3 ]

      SELECT psuban
      SET ORDER TO TAG "1"
      GO TOP
      SEEK _id_firma + _id_vn + _br_nal

      IF !Found()
         MsgBeep( "Nalog " + _id_firma + "-" + _id_vn + "-" + AllTrim( _br_nal ) + " ne postoji u PSUBAN !!!" )
         RETURN _ok
      endif

   NEXT

   _ok := .T.

   RETURN _ok




// ------------------------
// azuriraj dbf-ove
// -----------------------
FUNCTION fin_azur_dbf( auto, id_firma, id_vn, br_nal )

   LOCAL _n_c
   LOCAL _t_area := Select()
   LOCAL _saldo
   LOCAL _ctrl
   LOCAL _ok := .T.

   Box( "ad", 10, MAXCOLS() - 10 )

   log_write( "FIN, azuriranje DBF tabela " + id_firma + "-" + id_vn + "-" + br_nal + " - START", 7 )

   SELECT psuban
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vn + br_nal

   _saldo := 0

   DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idvn == id_vn .AND. field->brnal == br_nal

      _ctrl := field->idfirma + field->idvn + field->brnal

      @ m_x + 1, m_y + 2 SAY "DBF: azuriram nalog: " + field->idfirma + "-" + field->idvn + "-" + AllTrim( field->brnal )

      IF field->d_p == "1"
         _saldo += field->iznosbhd
      ELSE
         _saldo -= field->iznosbhd
      ENDIF

      SKIP

   ENDDO

   log_write( "azuriram fin nalog: " + _ctrl + " saldo " + Str( _saldo, 17, 2 ), 5 )

   // prebaci iz p tabele u tekucu
   pnalog_nalog( _ctrl )
   panal_anal( _ctrl )
   psint_sint( _ctrl )
   psuban_suban( _ctrl )

   // brisi iz pripreme stavke ovog naloga
   fin_pripr_delete( _ctrl )

   SELECT psuban

   BoxC()

   RETURN _ok



// ------------------------------------------------------------
// brisanje pomocnih tabela
// ------------------------------------------------------------
STATIC FUNCTION fin_brisi_p_tabele( close_all )

   IF close_all == NIL
      close_all := .F.
   ENDIF

   SELECT PNALOG
   zapp()

   SELECT PSUBAN
   zapp()

   SELECT PANAL
   zapp()

   SELECT PSINT
   zapp()

   IF close_all
      CLOSE ALL
   ENDIF

   RETURN



// -------------------------------------------------------------
// -------------------------------------------------------------
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
   hseek psuban->idpartner

   IF !Found()

      _ok := .F.

      _scan := AScan( arr, {| val| val[ 1 ] + val[ 2 ] == "PARTN" + psuban->idpartner } )

      IF _scan == 0
         // dodaj u kontrolnu matricu
         AAdd( arr, { "PARTN", psuban->idpartner, psuban->rbr } )
      ENDIF

      IF !silent
         MsgBeep( "Stavka br." + psuban->rbr + " : Nepostojeca sifra partnera!#Partner id: " + psuban->idpartner )
      ENDIF

   ENDIF

   SELECT psuban

   RETURN _ok



// --------------------------------------------------------------
// --------------------------------------------------------------
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
   hseek psuban->idkonto

   IF !Found()

      _ok := .F.

      _scan := AScan( arr, {|val| val[ 1 ] + val[ 2 ] == "KONTO" + psuban->idkonto } )

      IF _scan == 0
         // dodaj u kontrolnu matricu
         AAdd( arr, { "KONTO", psuban->idkonto, psuban->rbr } )
      ENDIF

      IF !silent
         MsgBeep( "Stavka br." + psuban->rbr + " : Nepostojeca sifra konta!#Konto id: " + psuban->idkonto )
      ENDIF

   ENDIF

   SELECT psuban

   RETURN _ok



// -------------------------------------------------------------
// -------------------------------------------------------------
FUNCTION panal_anal( nalog_ctrl )

   LOCAL _rec

   @ m_x + 3, m_y + 2 SAY "ANALITIKA       "

   SELECT panal
   SEEK nalog_ctrl

   DO WHILE !Eof() .AND. nalog_ctrl == IdFirma + IdVn + BrNal

      _rec := dbf_get_rec()

      SELECT ANAL

      APPEND BLANK

      dbf_update_rec( _rec, .F. )

      SELECT PANAL
      SKIP

   ENDDO

   RETURN




// -------------------
// -------------------
FUNCTION psint_sint( nalog_ctrl )

   LOCAL _rec

   @ m_x + 3, m_y + 2 SAY "SINTETIKA       "
   SELECT PSINT
   SEEK nalog_ctrl

   DO WHILE !Eof() .AND. nalog_ctrl == IdFirma + IdVn + BrNal

      _rec := dbf_get_rec()

      SELECT SINT

      APPEND BLANK
      dbf_update_rec( _rec, .F. )

      SELECT PSINT
      SKIP

   ENDDO

   RETURN




// -----------------------
// -----------------------
FUNCTION pnalog_nalog( nalog_ctrl )

   LOCAL _rec

   SELECT pnalog
   SEEK nalog_ctrl

   IF Found()

      _rec := dbf_get_rec()

      SELECT nalog
      APPEND BLANK

      dbf_update_rec( _rec, .F. )

   ELSE

      Beep( 4 )
      Msg( "Greska... ponovi stampu naloga ..." )

   ENDIF

   RETURN



// -----------------------
// -----------------------
FUNCTION psuban_suban( nalog_ctrl )

   LOCAL nSaldo := 0
   LOCAL nC := 0
   LOCAL _rec

   @ m_x + 3, m_y + 2 SAY "SUBANALITIKA   "

   SELECT SUBAN
   SET ORDER TO TAG "3"

   SELECT PSUBAN
   SEEK nalog_ctrl

   nC := 0

   DO WHILE !Eof() .AND. nalog_ctrl == IdFirma + IdVn + BrNal

      @ m_x + 3, m_y + 25 SAY ++nC  PICT "99999999999"

      _rec := dbf_get_rec()

      IF _rec[ "d_p" ] == "1"
         nSaldo := _rec[ "iznosbhd" ]
      ELSE
         nSaldo := -_rec[ "iznosbhd" ]
      ENDIF

      SELECT SUBAN
      SEEK _rec[ "idfirma" ] + _rec[ "idkonto" ] + _rec[ "idpartner" ] + _rec[ "brdok" ]

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

   RETURN



// ------------------------------
// ------------------------------
FUNCTION fin_pripr_delete( nalog_ctrl )

   LOCAL _t_rec

   // nalog je uravnotezen, moze se izbrisati iz PRIPR
   SELECT fin_pripr
   SEEK nalog_ctrl

   @ m_x + 3, m_y + 2 SAY "BRISEM PRIPREMU "

   my_flock()

   DO WHILE !Eof() .AND. nalog_ctrl == IdFirma + IdVn + BrNal

      SKIP
      _t_rec := RecNo()
      SKIP -1
      DELETE
      GO ( _t_rec )

   ENDDO

   RETURN .T.




// ------------------------------------------------------------
// provjeri duple stavke u pripremi za vise dokumenata
// ------------------------------------------------------------
STATIC FUNCTION prov_duple_stavke()

   LOCAL cSeekNal
   LOCAL lNalExist := .F.

   SELECT fin_pripr
   GO TOP

   // provjeri duple dokumente
   DO WHILE !Eof()
      cSeekNal := fin_pripr->( idfirma + idvn + brnal )
      IF dupli_nalog( cSeekNal )
         lNalExist := .T.
         EXIT
      ENDIF

      SELECT fin_pripr
      SKIP
   ENDDO

   // postoje dokumenti dupli
   IF lNalExist
      MsgBeep( "U pripremi su se pojavili dupli nalozi !!!" )
      IF Pitanje(, "Pobrisati duple naloge (D/N)?", "D" ) == "N"
         MsgBeep( "Dupli nalozi ostavljeni u tabeli pripreme!#Prekidam operaciju azuriranja!" )
         RETURN 1
      ELSE
         Box(, 1, 60 )
         cKumPripr := "P"
         @ m_x + 1, m_y + 2 SAY "Zelite brisati stavke iz kumulativa ili pripreme (K/P)" GET cKumPripr VALID !Empty( cKumPripr ) .OR. cKumPripr $ "KP" PICT "@!"
         READ
         BoxC()

         IF cKumPripr == "P"
            // brisi pripremu
            RETURN prip_brisi_duple()
         ELSE
            // brisi kumulativ
            RETURN kum_brisi_duple()
         ENDIF
      ENDIF
   ENDIF

   RETURN 0

// ------------------------------------------------------------
// brisi stavke iz pripreme koje se vec nalaze u kumulativu
// ------------------------------------------------------------
STATIC FUNCTION prip_brisi_duple()

   LOCAL cSeek
   LOCAL _brisao := .F.

   SELECT fin_pripr
   GO TOP

   DO WHILE !Eof()

      cSeek := fin_pripr->( idfirma + idvn + brnal )

      IF dupli_nalog( cSeek )
         // pobrisi stavku
         SELECT fin_pripr
         DELETE
         _brisao := .T.
      ENDIF

      SELECT fin_pripr
      SKIP

   ENDDO

   IF _brisao
      my_dbf_pack()
   ENDIF

   RETURN 0


// -------------------------------------------------------------
// brisi stavke iz kumulativa koje se vec nalaze u pripremi
// -------------------------------------------------------------
STATIC FUNCTION kum_brisi_duple()

   LOCAL cSeek

   SELECT fin_pripr
   GO TOP

   cKontrola := "XXX"

   DO WHILE !Eof()

      cSeek := fin_pripr->( idfirma + idvn + brnal )

      IF cSeek == cKontrola
         SKIP
         LOOP
      ENDIF

      IF dupli_nalog( cSeek )

         MsgO( "Brisem stavke iz kumulativa ... sacekajte trenutak!" )

         // brisi nalog
         SELECT nalog

         IF !FLock()
            msg( "Datoteka je zauzeta ", 3 )
            closeret
         ENDIF

         SET ORDER TO TAG "1"
         GO TOP
         SEEK cSeek

         IF Found()

            DO WHILE !Eof() .AND. nalog->( idfirma + idvn + brnal ) == cSeek
               SKIP 1
               nRec := RecNo()
               SKIP -1
               DbDelete2()
               GO nRec
            ENDDO
         ENDIF

         // brisi iz suban
         SELECT suban
         IF !FLock()
            msg( "Datoteka je zauzeta ", 3 )
            closeret
         ENDIF

         SET ORDER TO TAG "4"
         GO TOP
         SEEK cSeek
         IF Found()
            DO WHILE !Eof() .AND. suban->( idfirma + idvn + brnal ) == cSeek

               SKIP 1
               nRec := RecNo()
               SKIP -1
               DbDelete2()
               GO nRec
            ENDDO
         ENDIF

         // brisi iz sint
         SELECT sint
         IF !FLock()
            msg( "Datoteka je zauzeta ", 3 )
            closeret
         ENDIF

         SET ORDER TO TAG "2"
         GO TOP
         SEEK cSeek
         IF Found()
            DO WHILE !Eof() .AND. sint->( idfirma + idvn + brnal ) == cSeek

               SKIP 1
               nRec := RecNo()
               SKIP -1
               DbDelete2()
               GO nRec
            ENDDO
         ENDIF

         // brisi iz anal
         SELECT anal
         IF !FLock()
            msg( "Datoteka je zauzeta ", 3 )
            closeret
         ENDIF

         SET ORDER TO TAG "2"
         GO TOP
         SEEK cSeek
         IF Found()
            DO WHILE !Eof() .AND. anal->( idfirma + idvn + brnal ) == cSeek
               SKIP 1
               nRec := RecNo()
               SKIP -1
               DbDelete2()
               GO nRec
            ENDDO
         ENDIF


         MsgC()
      ENDIF

      cKontrola := cSeek

      SELECT fin_pripr
      SKIP

   ENDDO

   RETURN 0




// ------------------------------------------
// provjerava da li je dokument dupli
// ------------------------------------------
STATIC FUNCTION dupli_nalog( cSeek )

   SELECT nalog
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cSeek
   IF Found()
      RETURN .T.
   ENDIF

   RETURN .F.



// ------------------------------------------------------------
// postoji fin nalog ?
// ------------------------------------------------------------
FUNCTION fin_doc_exist( id_firma, id_vn, br_nal )

   LOCAL _exist := .F.
   LOCAL _tbl, _result

   _tbl := "fmk.fin_nalog"
   _result := table_count( _tbl, "idfirma=" + _sql_quote( id_firma ) + " AND idvn=" + _sql_quote( id_vn ) + " AND brnal=" + _sql_quote( br_nal ) )

   IF _result <> 0
      _exist := .T.
   ENDIF

   RETURN _exist



// --------------------------------
// validacija broja naloga
// --------------------------------
STATIC FUNCTION __val_nalog( cNalog )

   LOCAL lRet := .T.
   LOCAL cTmp
   LOCAL cChar
   LOCAL i

   cTmp := Right( cNalog, 4 )

   // vidi jesu li sve brojevi
   FOR i := 1 TO Len( cTmp )

      cChar := SubStr( cTmp, i, 1 )

      IF cChar $ "0123456789"
         LOOP
      ELSE
         lRet := .F.
         EXIT
      ENDIF

   NEXT

   RETURN lRet




// ----------------------------------------------------------------
// specijalna funkcija regeneracije brojeva naloga u kum tabelama
// C(4) -> C(8) konverzija
// stari broj A001 -> 0000A001
// ----------------------------------------------------------------
FUNCTION regen_tbl()

   IF !SigmaSIF( "REGEN" )
      MsgBeep( "Ne diraj lava dok spava !" )
      RETURN
   ENDIF

   // otvori sve potrebne tabele
   O_SUBAN

   IF Len( suban->brnal ) = 4
      msgbeep( "potrebno odraditi modifikaciju FIN.CHS prvo !" )
      RETURN
   ENDIF

   O_NALOG
   O_ANAL
   O_SINT

   // pa idemo redom
   SELECT suban
   _renum_convert()
   SELECT nalog
   _renum_convert()
   SELECT anal
   _renum_convert()
   SELECT sint
   _renum_convert()

   RETURN


// --------------------------------------------------
// konvertuje polje BRNAL na zadatoj tabeli
// --------------------------------------------------
STATIC FUNCTION _renum_convert()

   LOCAL xValue
   LOCAL nCnt
   LOCAL _rec

   SET ORDER TO TAG "0"
   GO TOP

   Box(, 2, 50 )

   @ m_x + 1, m_y + 2 SAY "Konvertovanje u toku... "

   f18_lock_tables( { Lower( Alias() ) } )

   sql_table_update( nil, "BEGIN" )

   nCnt := 0
   DO WHILE !Eof()

      xValue := field->brnal

      IF !Empty( xValue )

         _rec := dbf_get_rec()
         _rec[ "brnal" ] := PadL( AllTrim( xValue ), 8, "0" )
         update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )
         ++ nCnt

      ENDIF

      @ m_x + 2, m_y + 2 SAY PadR( "odradjeno " + AllTrim( Str( nCnt ) ), 45 )

      SKIP

   ENDDO

   f18_free_tables( { Lower( Alias() ) } )
   sql_table_update( nil, "END" )

   BoxC()

   RETURN
