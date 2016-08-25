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

#define BOX_HEIGHT (MAXROWS() - 8)
#define BOX_WIDTH  (MAXCOLS() - 6)

MEMVAR PicDEM, PicProc, PicCDem, PicKol, gPicCDEM, gPicDEM, gPICPROC, gPICKol
MEMVAR ImeKol, Kol
MEMVAR picv
MEMVAR m_x, m_y
// MEMVAR lKalkAsistentUToku, lAutoObr, lAsist, lAAzur, lAAsist
MEMVAR Ch
MEMVAR opc, Izbor, h
MEMVAR _idfirma, _idvd, _brdok
MEMVAR cSection, cHistory, aHistory

STATIC cENTER := Chr( K_ENTER ) + Chr( K_ENTER ) + Chr( K_ENTER )

/*
FUNCTION kalk_unos_dokumenta()

   PRIVATE PicCDEM := gPicCDEM
   PRIVATE PicProc := gPicProc
   PRIVATE PicDEM := gPICDEM
   PRIVATE Pickol := gPICKOL

   // PRIVATE lKalkAsistentUToku := .F.

   kalk_pripr_obrada()

   my_close_all_dbf()

   RETURN .T.
*/

FUNCTION kalk_pripr_obrada_stavki_sa_asistentom()

   RETURN kalk_pripr_obrada( .T. ) // kalk unos sa pozovi asistenta


FUNCTION kalk_pripr_obrada( lAObrada )

   LOCAL nMaxCol := MAXCOLS() - 3
   LOCAL nMaxRow := MAXROWS() - 4
   LOCAL nI
   LOCAL _opt_row, _opt_d
   LOCAL _sep := BROWSE_COL_SEP
   LOCAL cPicKol := "999999.999"
   LOCAL bPodvuci := {|| iif( field->ERROR == "1", .T., .F. ) }

   // O_PARAMS

   hb_default( @lAObrada, .F. )
   // PRIVATE lAutoObr := .F.
   // PRIVATE lAAsist := .F.
   // PRIVATE lAAzur := .F.

   // IF lAObrada == nil
   // lAutoObr := .F.
   // ELSE
   // lAutoObr := lAObrada
   // lAAsist := .T.
   // lAAzur := .T.
   // ENDIF

   // PRIVATE cSection := "K"
   // PRIVATE cHistory := " "
   // PRIVATE aHistory := {}

   // SELECT 99
   // USE

   o_kalk_edit()
   PRIVATE fNovi := .F.
   PRIVATE PicCDEM := gPicCDEM
   PRIVATE PicProc := gPicProc
   PRIVATE PicDEM := gPicDEM
   PRIVATE Pickol := gPicKol

   PRIVATE gVarijanta := "2"
   PRIVATE PicV := "99999999.9"

   PRIVATE ImeKol := {}
   PRIVATE Kol := {}

   AAdd( ImeKol, { "F.", {|| dbSelectArea( F_KALK_PRIPR ), field->idfirma   }, "idfirma"   } )
   AAdd( ImeKol, { "VD", {|| field->IdVD                     }, "IdVD"        } )
   AAdd( ImeKol, { "BrDok", {|| field->BrDok                 }, "BrDok"       } )
   AAdd( ImeKol, { "R.Br", {|| field->Rbr                    }, "Rbr"         } )
   AAdd( ImeKol, { "Dat.Kalk", {|| field->DatDok             }, "DatDok"      } )
   AAdd( ImeKol, { "Dat.Fakt", {|| field->DatFaktP           }, "DatFaktP"    } )
   AAdd( ImeKol, { "K.zad. ", {|| field->IdKonto             }, "IdKonto"     } )
   AAdd( ImeKol, { "K.razd.", {|| field->IdKonto2            }, "IdKonto2"    } )
   AAdd( ImeKol, { "IdRoba", {|| field->IdRoba                }, "IdRoba"      } )

   IF roba_barkod_pri_unosu()
      AAdd( ImeKol, { "Barkod", {|| roba_ocitaj_barkod( field->idroba ) }, "IdRoba" } )
   ENDIF

   AAdd( ImeKol, { _u( "Količina" ), {|| say_kolicina( field->Kolicina, "99999.999" ) }, "kolicina"    } )
   AAdd( ImeKol, { "IdTarifa", {|| field->idtarifa                 }, "idtarifa"    } )
   AAdd( ImeKol, { "F.Cj.", {|| say_cijena( field->FCJ, "99999.999" )      }, "fcj"         } )
   AAdd( ImeKol, { "F.Cj2.", {|| say_cijena( field->FCJ2, "99999.999" )     }, "fcj2"        } )
   AAdd( ImeKol, { "Nab.Cj.", {|| say_cijena( field->NC, "99999.999" )       }, "nc"          } )
   AAdd( ImeKol, { "VPC", {|| say_cijena( field->VPC, "99999.999" )      }, "vpc"         } )
   // AAdd( ImeKol, { "VPCj.sa P.", {|| say_cijena( field->VPCsaP )   }, "vpcsap"      } )
   AAdd( ImeKol, { "MPC", {|| say_cijena( field->MPC, "99999.999" )      }, "mpc"         } )
   AAdd( ImeKol, { "MPC sa PP", {|| say_cijena( field->MPCSaPP, "99999.999" )  }, "mpcsapp"     } )
   AAdd( ImeKol, { "RN", {|| field->idzaduz2                 }, "idzaduz2"    } )
   AAdd( ImeKol, { "Br.Fakt", {|| field->brfaktp                  }, "brfaktp"     } )
   AAdd( ImeKol, { "Partner", {|| field->idpartner                }, "idpartner"   } )
   AAdd( ImeKol, { "Marza", {|| field->tmarza                     }, "tmarza"   } )
   AAdd( ImeKol, { "Marza 2", {|| field->tmarza2                  }, "tmarza2"   } )
   AAdd( ImeKol, { "E", {|| field->error                           },  "error"       } )

   FOR nI := 1 TO Len( ImeKol )
      AAdd( Kol, nI )
   NEXT

   Box(, nMaxRow, nMaxCol )

   _opt_d := ( nMaxCol / 4 )
   _opt_row :=  _upadr( "<c+N> Nova stavka", _opt_d ) + _sep
   _opt_row +=  _upadr( "<ENT> Ispravka", _opt_d ) + _sep
   _opt_row +=  _upadr( "<c+T> Briši stavku", _opt_d ) + _sep
   _opt_row +=  _upadr( "<K> Kalk.cijena",  _opt_d ) + _sep

   @ m_x + nMaxRow - 3, m_y + 2 SAY8 _opt_row
   _opt_row :=  _upadr( "<c+A> Ispravka", _opt_d ) + _sep
   _opt_row +=  _upadr( "<c+P> Štampa dok.", _opt_d ) + _sep
   _opt_row +=  _upadr( "<a+A>|<X> Ažuriranje", _opt_d ) + _sep
   _opt_row +=  _upadr( "<Q> Etikete", _opt_d )  + _sep

   @ m_x + nMaxRow - 2, m_y + 2 SAY8 _opt_row
   _opt_row := _upadr( "<a+K> Kontiranje", _opt_d ) + _sep
   _opt_row += _upadr( "<c+F9> Briši sve", _opt_d ) + _sep
   _opt_row += _upadr( "<a+P> Štampa pripreme", _opt_d ) + _sep
   _opt_row += _upadr( "<E> greške, <I> info", _opt_d ) + _sep

   @ m_x + nMaxRow - 1, m_y + 2 SAY8 _opt_row
   _opt_row := _upadr( "<c+F8> Rasp.troškova", _opt_d ) + _sep
   _opt_row += _upadr( "<A> Asistent", _opt_d ) + _sep
   _opt_row += _upadr( "<F10> Dodatne opc.", _opt_d ) + _sep
   _opt_row += _upadr( "<F11> Dodatne opc./2", _opt_d ) + _sep

   @ m_x + nMaxRow, m_y + 2 SAY8 _opt_row

/*
   IF gCijene == "1" .AND. gMetodaNC == " "
      Soboslikar( { { nMaxRow - 3, m_y + 1, nMaxRow, m_y + 77 } }, 23, 14 )
   ENDIF
*/
   // PRIVATE lKalkAsistentAuto := .F.


   my_db_edit( "PNal", nMaxRow, nMaxCol, {|| kalk_pripr_key_handler( lAObrada ) }, "<F5>-kartica magacin, <F6>-kartica prodavnica", "Priprema...", , , , bPodvuci, 4 )

   BoxC()

   my_close_all_dbf()

   RETURN .T.




FUNCTION o_kalk_edit()

   O_PARTN
   // o_kalk_doks()
   O_ROBA
   // o_kalk()
   O_KONTO
   O_TDOK
   O_VALUTE
   O_TARIFA
   o_koncij()
   O_SIFK
   O_SIFV
   o_kalk_pripr()

   SELECT kalk_pripr
   SET ORDER TO TAG "1"
   GO TOP

   RETURN .T.


STATIC FUNCTION printaj_duple_stavke_iz_pripreme()

   LOCAL _data := {}
   LOCAL _dup := {}
   LOCAL _scan, _i

   O_ROBA
   o_kalk_pripr()

   SELECT kalk_pripr
   GO TOP

   DO WHILE !Eof()

      SELECT roba
      HSEEK kalk_pripr->idroba

      SELECT kalk_pripr

      _scan := AScan( _data, {| var| VAR[ 1 ] == kalk_pripr->idroba } )

      IF _scan == 0
         AAdd( _data, { kalk_pripr->idroba } )
      ELSE
         AAdd( _dup, { kalk_pripr->idroba, roba->naz, roba->barkod, kalk_pripr->rbr } )
      ENDIF

      SKIP

   ENDDO

   GO TOP

   IF Len( _dup ) > 0

      START PRINT CRET .F.

      ?U "Sljedeći artikli u pripremi su dupli:"
      ? Replicate( "-", 80 )
      ? PadR( "R.br", 5 ) + " " + PadR( "Rb.st", 5 ) + " " + PadR( "ID", 10 ) + " " + PadR( "NAZIV", 40 ) + " " + PadR( "BARKOD", 13 )
      ? Replicate( "-", 80 )

      FOR _i := 1 TO Len( _dup )
         ? PadL( AllTrim( Str( _i, 5 ) ) + ".", 5 )
         @ PRow(), PCol() + 1 SAY PadR( _dup[ _i, 4 ], 5 )
         @ PRow(), PCol() + 1 SAY _dup[ _i, 1 ]
         @ PRow(), PCol() + 1 SAY PadR( _dup[ _i, 2 ], 40 )
         @ PRow(), PCol() + 1 SAY _dup[ _i, 3 ]
      NEXT

      ENDPRINT

   ENDIF

   RETURN .T.


STATIC FUNCTION kalk_kontiraj_alt_k()

   LOCAL cBrNal := NIL

   my_close_all_dbf()

   kalk_kontiranje_gen_finmat()

   IF Pitanje(, "Želite li izvršiti kontiranje dokumenta (D/N) ?", "D" ) == "D"
      kalk_kontiranje_fin_naloga( NIL, NIL, NIL, cBrNal )
   ENDIF

   o_kalk_edit()

   RETURN DE_REFRESH



FUNCTION kalk_pripr_key_handler( lAObrada )

   LOCAL nTr2
   LOCAL iSekv
   LOCAL _log_info

   hb_default( @lAObrada, .F. )


   IF lAObrada
      kalk_unos_asistent()
      kalk_unos_asistent_send_esc()
      RETURN DE_ABORT
   ENDIF

   IF ( Ch == K_CTRL_T .OR. Ch == K_ENTER ) .AND. Eof()
      RETURN DE_CONT
   ENDIF



   select_o_kalk_pripr()

   DO CASE

      // CASE Ch == K_ALT_H
      // Savjetnik()

   CASE Ch == K_ALT_K
      RETURN kalk_kontiraj_alt_k()

   CASE Ch == K_SH_F9

      renumeracija_kalk_pripr( nil, nil, .F. )
      RETURN DE_REFRESH

   CASE Ch == K_SH_F8

      IF kalk_pripr_brisi_od_do()
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == K_ALT_L

      my_close_all_dbf()
      label_bkod()
      o_kalk_edit()

      RETURN DE_REFRESH

   CASE Upper( Chr( Ch ) ) == "Q"

      IF Pitanje(, "Štampa naljepnica za robu (D/N) ?", "D" ) == "D"

         my_close_all_dbf()

         RLabele()
         o_kalk_edit()

         RETURN DE_REFRESH

      ENDIF

      RETURN DE_CONT

   CASE is_key_alt_a( Ch ) .OR. Ch == Asc( 'x' ) .OR. Ch == Asc( 'X' )

      my_close_all_dbf()

      kalk_azuriranje_dokumenta( .F. )  // .F. - lAuto - postaviit pitanja, hoces-neces uravnoteziti, stampati
      o_kalk_edit()

/* "Indikatori", "ImaU_KALK"
      IF kalk_pripr->( RecCount() ) == 0 .AND. my_get_from_ini( "Indikatori", "ImaU_KALK", "N", PRIVPATH ) == "D"

         O__KALK

         SELECT _kalk
         DO WHILE !Eof()
            _rec := dbf_get_rec()
            SELECT kalk_pripr
            APPEND BLANK
            dbf_update_rec( _rec )
            SELECT _kalk
            SKIP
         ENDDO

         SELECT kalk_pripr

         UzmiIzINI( PRIVPATH + "FMK.INI", "Indikatori", "ImaU_KALK", "N", "WRITE" )
         my_close_all_dbf()

         o_kalk_edit()
         MsgBeep( "Stavke koje su bile privremeno uklonjene sada su vraćene! Obradite ih!" )

      ENDIF
*/
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_P

      my_close_all_dbf()
      kalk_stampa_dokumenta()

      my_close_all_dbf()
      o_kalk_edit()

      RETURN DE_REFRESH

   CASE Ch == K_CTRL_T

      IF Pitanje(, "Želite izbrisati ovu stavku (D/N) ?", "D" ) == "D"

         _log_info := kalk_pripr->idfirma + "-" + kalk_pripr->idvd + "-" + kalk_pripr->brdok
         cStavka := kalk_pripr->rbr
         cArtikal := kalk_pripr->idroba
         nKolicina := kalk_pripr->kolicina
         nNc := kalk_pripr->nc
         nVpc := kalk_pripr->vpc

         my_delete()
         log_write( "F18_DOK_OPER: kalk, brisanje stavke u pripremi: " + _log_info + " stavka br: " + cStavka, 2 )


         RETURN DE_REFRESH

      ENDIF

      RETURN DE_CONT

   CASE IsDigit( Chr( Ch ) )
      Msg( "Ako želite započeti unos novog dokumenta: <Ctrl-N>" )
      RETURN DE_CONT

   CASE Ch == K_ENTER
      RETURN kalk_edit_stavka()

   CASE ( Ch == K_CTRL_A )
      RETURN kalk_edit_sve_stavke()


   CASE Ch == K_CTRL_N
      fNovi := .T.
      RETURN kalk_unos_nova_stavka()

   CASE Ch == K_CTRL_F8 .OR. ( is_mac() .AND. Ch == K_F8 )
      kalk_raspored_troskova()
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_F9
      IF Pitanje(, "Želite izbrisati kompletnu tabelu pripreme (D/N) ?", "N" ) == "D"

         cOpis := kalk_pripr->idfirma + "-" + ;
            kalk_pripr->idvd + "-" + ;
            kalk_pripr->brdok

         my_dbf_zap()

         log_write( "F18_DOK_OPER: kalk, brisanje pripreme: " + cOpis, 2 )

         RETURN DE_REFRESH

      ENDIF
      RETURN DE_CONT

   CASE Upper( Chr( Ch ) ) == "A" .OR. lAObrada // lKalkAsistentAuto .OR.

      // kalk_unos_asistent()
      kalk_edit_sve_stavke( .T. )

      // CASE lAutoObr .AND. lAAsist
      // lAAsist := .F.
      // RETURN kalk_unos_asistent()

      // CASE lAutoObr .AND. !lAAsist
      // lAutoObr := .F.

      // IF lAObrada
      // kalk_unos_asistent_send_esc()
      // ENDIF
      RETURN DE_REFRESH

   CASE Upper( Chr( Ch ) ) == "K"
      kalkulacija_cijena( .F. )
      SELECT kalk_pripr
      GO TOP
      RETURN DE_CONT

   CASE Ch == K_F10
      RETURN kalk_meni_f10()

   CASE Ch == K_F11
      RETURN MeniF11()

   CASE Ch == K_F5
      Kmag()
      RETURN DE_CONT

   CASE Ch == K_F6
      KPro()
      RETURN DE_CONT



   ENDCASE

   RETURN DE_CONT



FUNCTION kalk_edit_stavka()

   LOCAL _atributi := hb_Hash()
   LOCAL _dok
   LOCAL _rok, _opis, _hAttrId
   LOCAL _old_dok, _new_dok
   LOCAL oAttr, _t_rec

   _old_dok := hb_Hash()

   _rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"
   _opis := fetch_metric( "kalk_dodatni_opis_kod_unosa_dokumenta", NIL, "N" ) == "D"

   IF RecCount() == 0
      Msg( "Ako želite započeti unos novog dokumenta: <Ctrl-N>" )
      RETURN DE_CONT
   ENDIF

   Scatter()

   IF Left( _idkonto2, 3 ) = "XXX"
      Beep( 2 )
      Msg( "Ne možete ispravljati protustavke !" )
      RETURN DE_CONT
   ENDIF

   nRbr := RbrUNum( _Rbr )
   _ERROR := ""

   Box( "ist", BOX_HEIGHT, BOX_WIDTH, .F. )

   _old_dok[ "idfirma" ] := _idfirma
   _old_dok[ "idvd" ] := _idvd
   _old_dok[ "brdok" ] := _brdok

   _dok := hb_Hash()
   _dok[ "idfirma" ] := _idfirma
   _dok[ "idtipdok" ] := _idvd
   _dok[ "brdok" ] := _brdok
   _dok[ "rbr" ] := _rbr

   IF _rok
      _atributi[ "rok" ] := get_kalk_attr_rok( _dok, .F. )
   ENDIF

   IF _opis
      _atributi[ "opis" ] := get_kalk_attr_opis( _dok, .F. )
   ENDIF

   IF kalk_edit_priprema( .F., @_atributi ) == 0
      BoxC()
      RETURN DE_CONT
   ELSE

      BoxC()

      IF _error <> "1"
         _error := "0"
      ENDIF

      IF _idvd == "16"
         _oldval := _vpc * _kolicina
      ELSE
         _oldval := _mpcsapp * _kolicina
      ENDIF

      _oldvaln := _nc * _kolicina

      my_rlock()
      Gather()
      my_unlock()

      _hAttrId := hb_Hash()
      _hAttrId[ "idfirma" ] := field->idfirma
      _hAttrId[ "idtipdok" ] := field->idvd
      _hAttrId[ "brdok" ] := field->brdok
      _hAttrId[ "rbr" ] := field->rbr

      oAttr := DokAttr():new( "kalk", F_KALK_ATTR )
      oAttr:hAttrId := _hAttrId
      oAttr:push_attr_from_mem_to_dbf( _atributi )

      SELECT kalk_pripr

      IF nRbr == 1
         _t_rec := RecNo()
         _new_dok := dbf_get_rec()
         izmjeni_sve_stavke_dokumenta( _old_dok, _new_dok )
         SELECT kalk_pripr
         GO ( _t_rec )
      ENDIF

      IF _idvd $ "16#80" .AND. !Empty( _idkonto2 )

         cIdkont := _idkonto
         cIdkont2 := _idkonto2
         _idkonto := cIdkont2
         _idkonto2 := "XXX"
         _kolicina := -kolicina

         nRbr := RbrUNum( _rbr ) + 1
         _rbr := RedniBroj( nRbr )

         Box( "", BOX_HEIGHT, BOX_WIDTH, .F., "Protustavka" )

         SEEK _idfirma + _idvd + _brdok + _rbr

         _tbanktr := "X"

         DO WHILE !Eof() .AND. _idfirma + _idvd + _brdok + _rbr == field->idfirma + ;
               field->idvd + field->brdok + field->rbr
            IF Left( field->idkonto2, 3 ) == "XXX"
               Scatter()
               _tbanktr := ""
               EXIT
            ENDIF
            SKIP
         ENDDO

         _idkonto := cIdKont2
         _idkonto2 := "XXX"

         IF _idvd == "16"
            kalk_get_1_16()
         ELSE
            kalk_get_1_80_protustavka()
         ENDIF

         IF _tbanktr == "X"
            APPEND ncnl
         ENDIF

         IF _error <> "1"
            _error := "0"
         ENDIF

         my_rlock()
         Gather()
         my_unlock()

         BoxC()

      ENDIF

      RETURN DE_REFRESH

   ENDIF

   RETURN DE_CONT



FUNCTION kalk_unos_nova_stavka()

   LOCAL _atributi := hb_Hash()
   LOCAL _dok, _hAttrId
   LOCAL _old_dok := hb_Hash()
   LOCAL _new_dok
   LOCAL oAttr
   LOCAL _rok, _opis
   LOCAL _rbr_uvecaj := 0

   // isprazni kontrolnu matricu
   aNC_ctrl := {}

   _rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"
   _opis := fetch_metric( "kalk_dodatni_opis_kod_unosa_dokumenta", NIL, "N" ) == "D"

   Box( "knjn", BOX_HEIGHT, BOX_WIDTH, .F., "Unos novih stavki" )

   _TMarza := "A"


   GO BOTTOM
   IF Left( field->idkonto2, 3 ) = "XXX"
      _rbr_uvecaj := 1
      SKIP -1
   ENDIF

   cIdkont := ""
   cIdkont2 := ""

   DO WHILE .T.

      Scatter()

      _atributi := hb_Hash()

      IF _rok
         _atributi[ "rok" ] := Space( 10 )
      ENDIF
      IF _opis
         _atributi[ "opis" ] := Space( 300 )
      ENDIF

      _ERROR := ""

      IF _idvd $ "16#80" .AND. _idkonto2 = "XXX"
         _idkonto := cIdkont
         _idkonto2 := cIdkont2
      ENDIF

      IF _idvd == "PR" // locirati se na zadnji proizvod
         DO WHILE !Bof() .AND. Val( field->rBr ) > 9
            IF Val( field->rBr ) > 9
               SKIP -1
            ELSE
               EXIT
            ENDIF
         ENDDO
         Scatter()

      ENDIF

      IF fetch_metric( "kalk_reset_artikla_kod_unosa", my_user(), "N" ) == "D"
         _idroba := Space( 10 )
      ENDIF

      _Kolicina := _GKolicina := _GKolicin2 := 0
      _FCj := _FCJ2 := _Rabat := 0

      IF !( _idvd $ "10#81" )
         _Prevoz := _Prevoz2 := _Banktr := _SpedTr := _CarDaz := _ZavTr := 0
      ENDIF

      _NC := _VPC := _VPCSaP := _MPC := _MPCSaPP := 0

      nRbr := RbrUNum( _rbr ) + 1 + _rbr_uvecaj

      _old_dok[ "idfirma" ] := _idfirma
      _old_dok[ "idvd" ] := _idvd
      _old_dok[ "brdok" ] := _brdok

      IF kalk_edit_priprema( .T., @_atributi ) == 0
         EXIT
      ENDIF

      APPEND BLANK

      IF _error <> "1"
         _error := "0"
      ENDIF

      IF _idvd == "16"
         _oldval := _vpc * _kolicina
      ELSE
         _oldval := _mpcsapp * _kolicina
      ENDIF

      _oldvaln := _nc * _kolicina

      Gather()

      _hAttrId := hb_Hash()
      _hAttrId[ "idfirma" ] := field->idfirma
      _hAttrId[ "idtipdok" ] := field->idvd
      _hAttrId[ "brdok" ] := field->brdok
      _hAttrId[ "rbr" ] := field->rbr

      oAttr := DokAttr():new( "kalk", F_KALK_ATTR )
      oAttr:hAttrId := _hAttrId
      oAttr:push_attr_from_mem_to_dbf( _atributi )

      IF nRbr == 1
         SELECT kalk_pripr
         _t_rec := RecNo()
         _new_dok := dbf_get_rec()
         izmjeni_sve_stavke_dokumenta( _old_dok, _new_dok )
         SELECT kalk_pripr
         GO ( _t_rec )
      ENDIF

      IF _idvd $ "16#80" .AND. !Empty( _idkonto2 )

         cIdkont := _idkonto
         cIdkont2 := _idkonto2

         _idkonto := cIdKont2
         _idkonto2 := "XXX"
         _kolicina := -kolicina

         nRbr := RbrUNum( _rbr ) + 1
         _Rbr := RedniBroj( nRbr )

         Box( "", BOX_HEIGHT, BOX_WIDTH, .F., "Protustavka" )

         IF _idvd == "16"
            Get1_16bPDV()

         ELSE
            kalk_get_1_80_protustavka()
         ENDIF

         APPEND BLANK

         IF _error <> "1"
            _error := "0"
         ENDIF

         Gather()

         BoxC()

         _idkonto := cIdkont
         _idkonto2 := cIdkont2

      ENDIF

   ENDDO

   BoxC()

   RETURN DE_REFRESH



FUNCTION kalk_edit_sve_stavke( lAObrada )

   LOCAL _atributi := hb_Hash()
   LOCAL _dok
   LOCAL oAttr, _hAttrId, _old_dok, _new_dok
   LOCAL _rok, _opis

   PushWA()
   SELECT kalk_pripr

   _rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"
   _opis := fetch_metric( "kalk_dodatni_opis_kod_unosa_dokumenta", NIL, "N" ) == "D"

   Box( "anal", BOX_HEIGHT, BOX_WIDTH, .F., "Ispravka naloga" )

   nDug := 0
   nPot := 0

   DO WHILE !Eof()

      SKIP
      nTR2 := RecNo()
      SKIP -1

      _old_dok := dbf_get_rec()

      Scatter()

      _error := ""

      IF Left( _idkonto2, 3 ) == "XXX"
         // 80-ka
         SKIP 1
         SKIP 1
         nTR2 := RecNo()
         SKIP -1
         Scatter()
         _error := ""
         IF Left( _idkonto2, 3 ) == "XXX"
            EXIT
         ENDIF
      ENDIF

      nRbr := RbrUNum( _rbr )

      IF lAObrada
         kalk_unos_asistent_send_entere()
      ENDIF

      _dok := hb_Hash()
      _dok[ "idfirma" ] := _idfirma
      _dok[ "idtipdok" ] := _idvd
      _dok[ "brdok" ] := _brdok
      _dok[ "rbr" ] := _rbr

      IF _opis
         _atributi[ "opis" ] := get_kalk_attr_opis( _dok, .F. )
      ENDIF

      IF _rok
         _atributi[ "rok" ] := get_kalk_attr_rok( _dok, .F. )
      ENDIF

      IF kalk_edit_priprema( .F., @_atributi ) == 0
         EXIT
      ENDIF

      SELECT kalk_pripr

      IF _error <> "1"
         _error := "0"
      ENDIF

      _oldval := _mpcsapp * _kolicina  // vrijednost prosle stavke
      _oldvaln := _nc * _kolicina

      my_rlock()
      Gather()
      my_unlock()

      oAttr := DokAttr():new( "kalk", F_KALK_ATTR )
      oAttr:hAttrId := _dok
      oAttr:push_attr_from_mem_to_dbf( _atributi )

      SELECT kalk_pripr

      IF nRbr == 1
         _t_rec := RecNo()
         _new_dok := dbf_get_rec()
         izmjeni_sve_stavke_dokumenta( _old_dok, _new_dok )
         SELECT kalk_pripr
         GO ( _t_rec )
      ENDIF

      IF _idvd $ "16#80" .AND. !Empty( _idkonto2 )

         cIdkont := _idkonto
         cIdkont2 := _idkonto2
         _idkonto := cIdkont2
         _idkonto2 := "XXX"
         _kolicina := -kolicina

         nRbr := RbrUNum( _rbr ) + 1
         _Rbr := RedniBroj( nRbr )

         Box( "", BOX_HEIGHT, BOX_WIDTH, .F., "Protustavka" )
         SEEK _idfirma + _idvd + _brdok + _rbr
         _tbanktr := "X"
         DO WHILE !Eof() .AND. _idfirma + _idvd + _brdok + _rbr == field->idfirma + field->idvd + field->brdok + field->rbr
            IF Left( field->idkonto2, 3 ) == "XXX"
               Scatter()
               _tbanktr := ""
               EXIT
            ENDIF
            SKIP
         ENDDO
         _idkonto := cIdkont2
         _idkonto2 := "XXX"
         IF _idvd == "16"
            kalk_get_1_16()
         ELSE
            kalk_get_1_80_protustavka()
         ENDIF

         IF _tbanktr == "X"
            APPEND ncnl
         ENDIF
         IF _error <> "1"
            _error := "0"
         ENDIF
         // stavka onda postavi ERROR
         my_rlock()
         Gather()
         my_unlock()
         BoxC()
      ENDIF
      GO nTR2
   ENDDO

   Beep( 1 )


   PopWA()

   BoxC()

   IF lAObrada
      kalk_unos_asistent_stop()
   ENDIF

   RETURN DE_REFRESH



FUNCTION kalk_unos_asistent()

   // LOCAL cSekv
   // lKalkAsistentAuto := .F.
   // lKalkAsistentUToku := .T.

   // cSekv :=
   kalk_edit_sve_stavke( .T. )
   // KEYBOARD Chr( K_CTRL_A )

   RETURN DE_REFRESH


FUNCTION kalk_unos_asistent_send_esc()

   KEYBOARD Chr( K_ESC )

   RETURN DE_REFRESH


FUNCTION kalk_unos_asistent_send_entere()

   LOCAL nKekk, cSekv

   // IF lKalkAsistentUToku
   CLEAR TYPEAHEAD // kalk_unos_asistent_send_entere
   cSekv := ""
   FOR nKekk := 1 TO 17
      cSekv += cEnter
   NEXT
   KEYBOARD cSekv
   // ENDIF

   RETURN .T.


FUNCTION kalk_unos_asistent_stop()

   CLEAR TYPEAHEAD
   // lKalkAsistentUToku := .F.

   RETURN .T.


FUNCTION kalk_meni_f10()

   PRIVATE opc[ 9 ]

   opc[ 1 ] := "1. prenos dokumenta fakt->kalk                                  "
   opc[ 2 ] := "2. povrat dokumenta u pripremu"
   opc[ 3 ] := "3. priprema -> smeće"
   opc[ 4 ] := "4. smeće    -> priprema"
   opc[ 5 ] := "5. najstariji dokument iz smeća u pripremu"
   opc[ 6 ] := "6. generacija dokumenta inventure magacin "
   opc[ 7 ] := "7. generacija dokumenta inventure prodavnica"
   opc[ 8 ] := "8. generacija nivelacije prodavn. na osnovu niv. za drugu prod"
   opc[ 9 ] := "9. parametri obrade - nc / obrada sumnjivih dokumenata"
   h[ 1 ] := h[ 2 ] := ""

   SELECT kalk_pripr
   GO TOP

   cIdVDTek := IdVD

   IF cIdVdTek == "19"
      AAdd( opc, "A. obrazac promjene cijena" )
   ELSE
      AAdd( opc, "--------------------------" )
   ENDIF

   AAdd( opc, "B. pretvori 11 -> 41  ili  11 -> 42"        )
   AAdd( opc, "C. promijeni predznak za količine"          )
   // AAdd( opc, "D. preuzmi tarife iz šifarnika"            )
   AAdd( opc, "E. storno dokumenta"                        )
   AAdd( opc, "F. prenesi VPC(sifr)+POREZ -> MPCSAPP(dok)" )
   AAdd( opc, "G. prenesi MPCSAPP(dok)    -> MPC(sifr)"    )
   AAdd( opc, "H. prenesi VPC(sif)        -> VPC(dok)"     )
   AAdd( opc, "I. povrat (12,11) -> u drugo skl.(96,97)"   )
   AAdd( opc, "J. zaduženje prodavnice iz magacina (10->11)"   )
   AAdd( opc, "K. veleprodaja na osnovu dopreme u magacin (16->14)"   )

   my_close_all_dbf()

   PRIVATE am_x := m_x, am_y := m_y
   PRIVATE Izbor := 1

   DO WHILE .T.
      Izbor := menu( "prip", opc, Izbor, .F. )
      DO CASE
      CASE Izbor == 0
         EXIT
      CASE izbor == 1
         fakt_kalk()
      CASE izbor == 2
         kalk_povrat_dokumenta()
      CASE izbor == 3
         kalk_azuriranje_tabele_pripr9()
      CASE izbor == 4
         kalk_povrat_dokumenta_iz_pripr9()
      CASE izbor == 5
         kalk_povrat_najstariji_dokument_iz_pripr9()
      CASE izbor == 6
         kalk_generisi_inventuru_magacina()
      CASE izbor == 7
         kalk_generisi_ip()
      CASE izbor == 8
         GenNivP()
      CASE izbor == 9
         // aRezim := { gCijene, gMetodaNC }
         O_PARAMS
         PRIVATE cSection := "K", cHistory := " "; aHistory := {}
         cIspravka := "D"
         kalk_par_metoda_nc()
         SELECT params
         USE
/*
      --   IF gCijene <> aRezim[ 1 ] .OR. gMetodaNC <> aRezim[ 2 ]
            IF !dozvoljeno_azuriranje_sumnjivih_stavki() .AND. gMetodaNC == " "
               Soboslikar( { { m_x + 17, m_y + 1, m_x + 20, m_y + 77 } }, 23, 14 )
            ELSEIF aRezim[ 1 ] == "1" .AND. aRezim[ 2 ] == " "
               Soboslikar( { { m_x + 17, m_y + 1, m_x + 20, m_y + 77 } }, 14, 23 )
            ENDIF
         ENDIF
*/

      CASE Izbor == 10 .AND. cIdVDTek == "19"

         o_kalk_edit()
         SELECT kalk_pripr
         GO TOP
         cIdfirma := field->idfirma
         cIdvd := field->idvd
         cBrdok := field->brdok
         Obraz19()
         SELECT kalk_pripr
         GO TOP
         RETURN DE_REFRESH

      CASE izbor == 11
         Iz11u412()

      CASE izbor == 12
         kalk_plus_minus_kol()

         // CASE izbor == 13
         // UzmiTarIzSif()

      CASE izbor == 13
         storno_kalk_dokument()

      CASE izbor == 14
         kalk_set_diskont_mpc()

      CASE izbor == 15
         kalk_dokument_prenos_cijena()

      CASE izbor == 16
         VPCSifUDok()

      CASE izbor == 17
         Iz12u97()     // 11,12 -> 96,97

      CASE izbor == 18
         Iz10u11()

      CASE izbor == 19
         Iz16u14()


      ENDCASE
   ENDDO
   m_x := am_x; m_y := am_y
   o_kalk_edit()

   RETURN DE_REFRESH



STATIC FUNCTION kalk_dokument_prenos_cijena()

   LOCAL _opt := 2
   LOCAL _update := .F.
   LOCAL _konto := Space( 7 )
   LOCAL _t_area := Select()
   PRIVATE getList := {}

   Box(, 7, 65 )
   @ m_x + 1, m_y + 2 SAY8 "Prenos cijena dokument/šifarnik ****"
   @ m_x + 3, m_y + 2 SAY8 "1) prenos MPCSAPP (dok) => šifarnik"
   @ m_x + 4, m_y + 2 SAY8 "2) prenos šifarnik => MPCSAPP (dok)"
   @ m_x + 6, m_y + 2 SAY "    odabir > " GET _opt PICT "9"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   IF _opt == 1
      IF Pitanje(, "Koristiti dokument iz pripreme (D) ili ažurirani (N) ?", "N" ) == "D"
         MPCSAPPuSif()
      ELSE
         MPCSAPPiz80uSif()
      ENDIF
      RETURN
   ENDIF

   IF _opt == 2

      o_kalk_pripr()
      O_ROBA
      o_koncij()
      O_KONTO

      Box(, 1, 50 )
      @ m_x + 1, m_y + 2 SAY8 "Prodavnički konto:" GET _konto VALID p_konto( @_konto )
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN .F.
      ENDIF

      SELECT koncij
      HSEEK _konto

      SELECT kalk_pripr
      GO TOP

      DO WHILE !Eof()

         _update := .T.
         _rec := dbf_get_rec()

         SELECT roba
         HSEEK _rec[ "idroba" ]

         IF !Found()
            MsgBeep( "Nepostojeća šifra artikla " + _rec[ "idroba" ] )
            SELECT kalk_pripr
            SKIP
            LOOP
         ENDIF

         SELECT kalk_pripr
         _rec[ "mpcsapp" ] := kalk_get_mpc_by_koncij_pravilo()

         IF Round( _rec[ "mpcsapp" ], 2 ) <= 0
            MsgBeep( "Artikal " + _rec[ "idroba" ] + " cijena <= 0 !"  )
         ENDIF

         dbf_update_rec( _rec )

         SKIP

      ENDDO

      SELECT kalk_pripr
      GO TOP

   ENDIF

   IF _update
      MsgBeep( "Ubačene cijene iz šifarnika !#Odradite asistenta sa opcijom A" )
   ENDIF

   RETURN



FUNCTION MeniF11()

   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc, "1. ubacivanje troškova-uvozna kalkulacija" )
   AAdd( opcexe, {|| KalkTrUvoz() } )

   /*
   AAdd( opc, "2. pretvori maloprodajni popust u smanjenje MPC" )
   AAdd( opcexe, {|| PopustKaoNivelacijaMP() } )
   */

   AAdd( opc, "3. obračun poreza pri uvozu" )
   AAdd( opcexe, {|| ObracunPorezaUvoz() } )
   AAdd( opc, "4. pregled smeća" )
   AAdd( opcexe, {|| kalk_pregled_smece_pripr9() } )
   AAdd( opc, "5. briši sve protu-stavke" )
   AAdd( opcexe, {|| ProtStErase() } )
   AAdd( opc, "6. setuj sve NC na 0" )
   AAdd( opcexe, {|| SetNcTo0() } )
   AAdd( opc, "7. renumeracija kalk priprema" )
   AAdd( opcexe, {|| renumeracija_kalk_pripr( nil, nil, .F. ) } )
   AAdd( opc, "8. provjeri duple stavke u pripremi" )
   AAdd( opcexe, {|| printaj_duple_stavke_iz_pripreme() } )

   my_close_all_dbf()
   PRIVATE am_x := m_x, am_y := m_y
   PRIVATE Izbor := 1

   Menu_SC( "osop2" )
   m_x := am_x
   m_y := am_y

   o_kalk_edit()

   RETURN DE_REFRESH



FUNCTION ProtStErase()

   IF Pitanje(, "Pobrisati protustavke dokumenta (D/N)?", "N" ) == "N"
      RETURN
   ENDIF

   o_kalk_pripr()
   SELECT kalk_pripr
   GO TOP

   DO WHILE !Eof()
      IF "XXX" $ idkonto2
         my_delete()
      ENDIF
      SKIP
   ENDDO

   my_dbf_pack()

   GO TOP

   RETURN .T.



FUNCTION SetNcTo0()

   IF Pitanje(, "Setovati NC na 0 (D/N)?", "N" ) == "N"
      RETURN .F.
   ENDIF

   o_kalk_pripr()
   SELECT kalk_pripr
   GO TOP
   my_flock()
   DO WHILE !Eof()
      Scatter()
      _nc := 0
      Gather()
      SKIP
   ENDDO
   my_unlock()
   GO TOP

   RETURN .T.




FUNCTION kalk_edit_priprema( fNovi, atrib )

   PRIVATE nMarza := 0
   PRIVATE nMarza2 := 0
   PRIVATE nR
   PRIVATE PicDEM := "9999999.99999999"
   PRIVATE PicKol := gPicKol

   nStrana := 1

   DO WHILE .T.

      @ m_x + 1, m_y + 1 CLEAR TO m_x + BOX_HEIGHT, m_y + BOX_WIDTH

      SetKey( K_PGDN, {|| NIL } )
      SetKey( K_PGUP, {|| NIL } )
      SetKey( K_CTRL_K, {|| a_val_convert() } )

      IF nStrana == 1
         nR := kalk_unos_1( fNovi, @atrib )
      ELSEIF nStrana == 2
         nR := kalk_unos_2( fNovi )
      ENDIF

      SetKey( K_PGDN, NIL )
      SetKey( K_PGUP, NIL )
      SetKey( K_CTRL_K, NIL )

      SET ESCAPE ON

      IF nR == K_ESC
         EXIT
      ELSEIF nR == K_PGUP
         --nStrana
      ELSEIF nR == K_PGDN .OR. nR == K_ENTER
         ++nStrana
      ENDIF

      IF nStrana == 0
         nStrana++
      ELSEIF nStrana >= 3
         EXIT
      ENDIF

   ENDDO

   IF LastKey() <> K_ESC
      _Rbr := RedniBroj( nRbr )
      _Dokument := P_TipDok( _IdVD, -2 )
      RETURN 1
   ELSE
      RETURN 0
   ENDIF

   RETURN .T.





/*
 *  Prva strana/prozor maske unosa/ispravke stavke dokumenta
 */

FUNCTION kalk_unos_1( fNovi, atrib )

   PRIVATE pIzgSt := .F.
   PRIVATE Getlist := {}

   IF kalk_header_get1( fNovi ) == 0
      RETURN K_ESC
   ENDIF

   SELECT kalk_pripr

   IF _idvd != "PR"
      SET FILTER TO
   ENDIF

   IF _idvd == "10"

      RETURN kalk_get_1_10()

   ELSEIF _idvd == "11"
      RETURN kalk_get_1_11()

   ELSEIF _idvd == "12"
      RETURN kalk_get_1_12()

   ELSEIF _idvd == "13"
      RETURN kalk_get_1_12()

   ELSEIF _idvd == "14"
      RETURN kalk_get_1_14()

   ELSEIF _idvd == "KO"
      RETURN kalk_get_1_14()

   ELSEIF _idvd == "16"
      RETURN kalk_get_1_16()

   ELSEIF _idvd == "18"
      RETURN kalk_get_1_18()

   ELSEIF _idvd == "19"
      RETURN kalk_get_1_19()

   ELSEIF _idvd $ "41#42#43#47#49"
      RETURN kalk_get_1_41()

   ELSEIF _idvd == "81"
      RETURN kalk_unos_dok_81( @atrib )

   ELSEIF _idvd == "80"
      RETURN GET1_80( @atrib )


   ELSEIF _idvd $ "95#96#97"
      RETURN kalk_get_1_95()

   ELSEIF _idvd $  "94"    // storno fakture, storno otpreme, doprema
      RETURN kalk_get_1_94()

   ELSEIF _idvd == "82"
      RETURN GET1_82()

   ELSEIF _idvd == "IM"
      RETURN kalk_get_1_im()

   ELSEIF _idvd == "IP"
      RETURN kalk_get_1_ip()

   ELSEIF _idvd == "RN"
      RETURN GET1_RN()

   ELSEIF _idvd == "PR"
      RETURN kalk_unos_dok_pr()
   ELSE
      RETURN K_ESC
   ENDIF

   RETURN .T.


FUNCTION ispisi_naziv_sifre( area, id, x, y, len )

   LOCAL _naz := ""
   LOCAL _t_area := Select()

   IF Empty( id )
      RETURN .T.
   ENDIF

   SELECT ( area )
   GO TOP
   SEEK id

   IF ( area )->( FieldPos( "naz" ) ) <> 0

      _naz := AllTrim( field->naz )

      IF ( area )->( FieldPos( "jmj" ) ) <> 0
         IF Len( _naz ) >= len
            _naz := PadR( _naz, len - 6 )
         ENDIF
         _naz += " (" + AllTrim( field->jmj ) + ")"
      ENDIF

   ENDIF

   @ x, y SAY PadR( _naz, len )

   SELECT ( _t_area )

   RETURN .T.



/*
 *  param fnovi
 *  Druga strana/prozor maske unosa/ispravke stavke dokumenta
 */

FUNCTION kalk_unos_2( fNovi )

   IF _idvd == "RN"
      RETURN Get2_RN()
   ELSEIF _idvd == "PR"
      RETURN Get2_PR()
   ENDIF

   RETURN K_ESC




FUNCTION kalk_header_get1( fNovi )

   IF fnovi
      _idfirma := gFirma
   ENDIF

   IF fnovi .AND. _TBankTr == "X"
      _TBankTr := "%"
   ENDIF

   IF gNW $ "DX"
      @  m_x + 1, m_y + 2 SAY "Firma: "
      ?? gFirma, "-", gNFirma
   ELSE
      @  m_x + 1, m_y + 2 SAY "Firma:" GET _IdFirma VALID P_Firma( @_IdFirma, 1, 25 ) .AND. Len( Trim( _idFirma ) ) <= 2
   ENDIF

   @  m_x + 2, m_y + 2 SAY "KALKULACIJA: "
   @  m_x + 2, Col() SAY "Vrsta:" GET _idvd VALID P_TipDok( @_idvd, 2, 25 ) PICT "@!"

   READ
   ESC_RETURN 0


   IF fNovi .AND. gBrojacKalkulacija == "D" .AND. ( _idfirma <> idfirma .OR. _idvd <> idvd )

      _brDok := get_kalk_brdok( _idfirma, _idvd, _idkonto, _idkonto2 )

      SELECT kalk_pripr

   ENDIF

   @ m_x + 2, m_y + 40  SAY "Broj:" GET _brdok valid {|| !kalk_dokument_postoji( _idfirma, _idvd, _brdok ) }

   @ m_x + 2, Col() + 2 SAY "Datum:" GET _datdok

   @ m_x + 3, m_y + 2  SAY "Redni broj stavke:" GET nRBr PICT '9999' ;
      VALID {|| valid_kalk_rbr_stavke( _idvd ) }


   READ

   ESC_RETURN 0

   RETURN 1


FUNCTION valid_kalk_rbr_stavke( cIdVd )

   RETURN .T.


STATIC FUNCTION izmjeni_sve_stavke_dokumenta( old_dok, new_dok )

   LOCAL _old_firma := old_dok[ "idfirma" ]
   LOCAL _old_brdok := old_dok[ "brdok" ]
   LOCAL _old_tipdok := old_dok[ "idvd" ]
   LOCAL _rec, _tek_dok, _t_rec
   LOCAL _new_firma := new_dok[ "idfirma" ]
   LOCAL _new_brdok := new_dok[ "brdok" ]
   LOCAL _new_tipdok := new_dok[ "idvd" ]
   LOCAL oAttr
   LOCAL _vise_konta := fetch_metric( "kalk_dokument_vise_konta", NIL, "N" ) == "D"

   SELECT kalk_pripr
   GO TOP

   SEEK _new_firma + _new_tipdok + _new_brdok

   IF !Found()
      RETURN .F.
   ENDIF

   _tek_dok := dbf_get_rec()

   GO TOP
   SEEK _old_firma + _old_tipdok + _old_brdok

   IF !Found()
      RETURN .F.
   ENDIF

   DO WHILE !Eof() .AND. field->idfirma + field->idvd + field->brdok == ;
         _old_firma + _old_tipdok + _old_brdok

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      _rec := dbf_get_rec()
      _rec[ "idfirma" ] := _tek_dok[ "idfirma" ]
      _rec[ "idvd" ] := _tek_dok[ "idvd" ]
      _rec[ "brdok" ] := _tek_dok[ "brdok" ]
      _rec[ "datdok" ] := _tek_dok[ "datdok" ]

      IF !_vise_konta
         _rec[ "idpartner" ] := _tek_dok[ "idpartner" ]
      ENDIF

      IF ! ( _rec[ "idvd" ] $ "16#80" ) .AND. !_vise_konta
         _rec[ "idkonto" ] := _tek_dok[ "idkonto" ]
         _rec[ "idkonto2" ] := _tek_dok[ "idkonto2" ]
         _rec[ "pkonto" ] := _tek_dok[ "pkonto" ]
         _rec[ "mkonto" ] := _tek_dok[ "mkonto" ]
      ENDIF

      dbf_update_rec( _rec )

      GO ( _t_rec )

   ENDDO
   GO TOP

   oAttr := DokAttr():new( "kalk", F_KALK_ATTR )
   oAttr:open_attr_dbf()

   GO TOP

   DO WHILE !Eof()

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      _rec := dbf_get_rec()

      _rec[ "idfirma" ] := _tek_dok[ "idfirma" ]
      _rec[ "idtipdok" ] := _tek_dok[ "idvd" ]
      _rec[ "brdok" ] := _tek_dok[ "brdok" ]

      dbf_update_rec( _rec )

      GO ( _t_rec )

   ENDDO

   USE

   SELECT kalk_pripr
   GO TOP

   RETURN .T.






/*
 *  Vrsi se preracunavanje veleprodajnih cijena ako je _VPC=0
 */

FUNCTION VpcSaPpp()

   IF _VPC == 0
      _RabatV := 0
      _VPC := ( _VPCSAPPP + _NC * tarifa->vpp / 100 ) / ( 1 + tarifa->vpp / 100 + _mpc / 100 )
      nMarza := _VPC - _NC
      _VPCSAP := _VPC + nMarza * TARIFA->VPP / 100
      _PNAP := _VPC * _mpc / 100
      _VPCSAPP := _VPC + _PNAP
   ENDIF
   ShowGets()

   RETURN .T.





FUNCTION Soboslikar( aNiz, nIzKodaBoja, nUKodBoja )

   LOCAL i, cEkran

   FOR i := 1 TO Len( aNiz )
      cEkran := SaveScreen( aNiz[ i, 1 ], aNiz[ i, 2 ], aNiz[ i, 3 ], aNiz[ i, 4 ] )
      cEkran := StrTran( cEkran, Chr( nIzKodaBoja ), Chr( nUKodBoja ) )
      RestScreen( aNiz[ i, 1 ], aNiz[ i, 2 ], aNiz[ i, 3 ], aNiz[ i, 4 ], cEkran )
   NEXT

   RETURN .T.


FUNCTION kalk_zagl_firma()

   P_12CPI
   U_OFF
   B_OFF
   I_OFF
   ? "Subjekt:"
   U_ON
   ?? PadC( Trim( gTS ) + " " + Trim( gNFirma ), 39 )
   U_OFF
   ? "Prodajni objekat:"
   U_ON
   ?? PadC( AllTrim( NazProdObj() ), 30 )
   U_OFF
   ? "(poslovnica-poslovna jedinica)"
   ? "Datum:"
   U_ON
   ?? PadC( SrediDat( DATDOK ), 18 )
   U_OFF
   ?
   ?

   RETURN .T.


STATIC FUNCTION NazProdObj()

   LOCAL cVrati := ""

   SELECT KONTO
   SEEK kalk_pripr->pkonto
   cVrati := naz
   SELECT kalk_pripr

   RETURN cVrati






/*
 *     Mijenja predznak kolicini u svim stavkama u kalk_pripremi
 */

FUNCTION kalk_plus_minus_kol()

   o_kalk_edit()
   SELECT kalk_pripr
   GO TOP
   my_flock()
   DO WHILE !Eof()
      Scatter()
      _kolicina := -_kolicina
      _ERROR := " "
      Gather()
      SKIP 1
   ENDDO
   my_unlock()

   // Msg("Automatski pokrecem asistenta (Alt+F10)!",1)
   // lKalkAsistentAuto:=.t.
   // KEYBOARD Chr( K_ESC )
   kalk_unos_asistent()

   my_close_all_dbf()

   RETURN .T.




/*


-- FUNCTION UzmiTarIzSif()

   o_kalk_edit()
   SELECT kalk_pripr
   GO TOP
   my_flock()
   DO WHILE !Eof()
      Scatter()
      _idtarifa := Ocitaj( F_ROBA, _idroba, "idtarifa" )
      _ERROR := " "
      Gather()
      SKIP 1
   ENDDO
   my_unlock()
   Msg( "Automatski pokrećem asistenta (opcija A)!", 1 )
   --lKalkAsistentAuto := .T.
   -- KEYBOARD Chr( K_ESC )
   my_close_all_dbf()

   RETURN

   *     Filuje tarifu u svim stavkama u kalk_pripremi odgovarajucom sifrom tarife iz sifrarnika robe
*/



/*
 *     Formira diskontnu maloprodajnu cijenu u svim stavkama u kalk_pripremi
 */

FUNCTION kalk_set_diskont_mpc()

   aPorezi := {}
   o_kalk_edit()
   SELECT kalk_pripr
   GO TOP
   my_flock()

   DO WHILE !Eof()
      SELECT ROBA
      HSEEK kalk_pripr->idroba
      SELECT TARIFA
      HSEEK ROBA->idtarifa
      get_tarifa_by_koncij_region_roba_idtarifa_2_3( kalk_pripr->pKonto, kalk_pripr->idRoba, @aPorezi )
      SELECT kalk_pripr
      Scatter()

      _mpcSaPP := MpcSaPor( roba->vpc, aPorezi )

      _ERROR := " "
      Gather()
      SKIP 1
   ENDDO

   my_unlock()

   // Msg( "Automatski pokrećem asistenta (opcija A)!", 1 )
   // lKalkAsistentAuto := .T.
   // KEYBOARD Chr( K_ESC )
   kalk_unos_asistent()

   my_close_all_dbf()

   RETURN .T.




/*
 *     Maloprodajne cijene svih artikala u kalk_pripremi kopira u sifrarnik robe
 */

FUNCTION MPCSAPPuSif()

   o_kalk_edit()
   SELECT kalk_pripr
   GO TOP
   DO WHILE !Eof()
      cIdKonto := kalk_pripr->pkonto
      SELECT KONCIJ
      HSEEK cIdKonto
      SELECT kalk_pripr
      DO WHILE !Eof() .AND. pkonto == cIdKonto
         SELECT ROBA
         HSEEK kalk_pripr->idroba
         IF Found()
            StaviMPCSif( kalk_pripr->mpcsapp, .F. )
         ENDIF
         SELECT kalk_pripr
         SKIP 1
      ENDDO
   ENDDO
   my_close_all_dbf()

   RETURN .T.



/*
 *     Maloprodajne cijene svih artikala iz izabranog azuriranog dokumenta tipa 80 kopira u sifrarnik robe
 */

FUNCTION MPCSAPPiz80uSif()

   o_kalk_edit()

   cIdFirma := gFirma
   cIdVdU   := "80"
   cBrDokU  := Space( Len( kalk_pripr->brdok ) )

   Box(, 4, 75 )
   @ m_x + 0, m_y + 5 SAY8 "FORMIRANJE MPC U šifarnikU OD MPCSAPP DOKUMENTA TIPA 80"
   @ m_x + 2, m_y + 2 SAY8 "Dokument: " + cIdFirma + "-" + cIdVdU + "-"
   @ Row(), Col() GET cBrDokU VALID postoji_kalk_dok( cIdFirma + cIdVdU + cBrDokU )
   READ
   ESC_BCR
   BoxC()

   SELECT KALK
   SEEK cIdFirma + cIdVDU + cBrDokU
   cIdKonto := KALK->pkonto
   SELECT KONCIJ
   HSEEK cIdKonto

   SELECT KALK
   DO WHILE !Eof() .AND. cIdFirma + cIdVDU + cBrDokU == IDFIRMA + IDVD + BRDOK
      SELECT ROBA; HSEEK KALK->idroba
      IF Found()
         StaviMPCSif( KALK->mpcsapp, .F. )
      ENDIF
      SELECT KALK
      SKIP 1
   ENDDO

   my_close_all_dbf()

   RETURN .T.




/*
 *  brief Filuje VPC u svim stavkama u kalk_pripremi odgovarajucom VPC iz sifrarnika robe
 */

FUNCTION VPCSifUDok()

   o_kalk_edit()
   SELECT kalk_pripr
   GO TOP
   my_flock()
   DO WHILE !Eof()
      SELECT ROBA
      HSEEK kalk_pripr->idroba
      SELECT KONCIJ
      SEEK Trim( kalk_pripr->mkonto )
      // SELECT TARIFA; HSEEK ROBA->idtarifa
      SELECT kalk_pripr
      Scatter()
      _vpc := KoncijVPC()
      _ERROR := " "
      Gather()
      SKIP 1
   ENDDO
   my_unlock()

   // Msg( "Automatski pokrećem asistenta (opcija A) !", 1 )
   // lKalkAsistentAuto := .T.
   // KEYBOARD Chr( K_ESC )
   kalk_unos_asistent()

   my_close_all_dbf()

   RETURN .T.




FUNCTION kalk_open_tables_unos( lAzuriraniDok, cIdFirma, cIdVD, cBrDok )

   o_koncij()
   O_ROBA
   O_TARIFA
   O_PARTN
   O_KONTO
   O_TDOK

   IF lAzuriraniDok
      open_kalk_as_pripr( .T., cIdFirma, cIdVd, cBrDok ) // .T. => SQL table
   ELSE
      o_kalk_pripr()
   ENDIF

   RETURN .T.





// ---------------------------------------------------------------------
// provjerava da li kalkulacija ima sve potrebne cijene
// ---------------------------------------------------------------------
FUNCTION kalkulacija_ima_sve_cijene( firma, tip_dok, br_dok )

   LOCAL _ok := .T.
   LOCAL _area := Select()
   LOCAL _t_rec := RecNo()

   DO WHILE !Eof() .AND. field->idfirma + field->idvd + field->brdok == firma + tip_dok + br_dok

      IF field->idvd $ "11#41#42#RN#19"
         IF field->fcj == 0
            _ok := .F.
            MsgBeep( "Stavka broj " + AllTrim( field->rbr ) + " FCJ <= 0 !" )
            EXIT
         ENDIF
      ELSEIF field->idvd $ "10#16#96#94#95#14#80#81#"
         IF field->nc == 0
            _ok := .F.
            MsgBeep( "Stavka broj " + AllTrim( field->rbr ) + " NC <= 0 !" )
            EXIT
         ENDIF
      ENDIF

      SKIP

   ENDDO

   SELECT ( _area )
   GO ( _t_rec )

   RETURN _ok




/*
 *  Umjesto iskazanog popusta odradjuje smanjenje MPC


FUNCTION PopustKaoNivelacijaMP()

   LOCAL lImaPromjena := .F.

   o_kalk_edit()
   SELECT kalk_pripr
   GO TOP

   DO WHILE !Eof()
      IF ( !idvd = "4" .OR. rabatv == 0 )
         SKIP 1
         LOOP
      ENDIF
      lImaPromjena := .T.
      Scatter()
      _mpcsapp := Round( _mpcsapp - _rabatv, 2 )
      _rabatv := 0
      PRIVATE aPorezi := {}
      PRIVATE fNovi := .F.
      VRoba( .F. )
      WMpc( .T. )
      _error := " "
      SELECT kalk_pripr
      my_rlock()
      Gather()
      my_unlock()
      SKIP 1
   ENDDO
   IF lImaPromjena
      Msg( "Izvršio promjene!", 1 )
      KEYBOARD Chr( K_ESC )
   ELSE
      MsgBeep( "Nisam našao niti jednu stavku sa maloprodajnim popustom !" )
   ENDIF
   CLOSERET

   RETURN .T.
*/
