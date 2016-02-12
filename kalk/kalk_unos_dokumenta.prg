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

STATIC cENTER := Chr( K_ENTER ) + Chr( K_ENTER ) + Chr( K_ENTER )
STATIC __box_x
STATIC __box_y


FUNCTION kalk_unos_dokumenta()

   PRIVATE PicCDEM := gPicCDEM
   PRIVATE PicProc := gPicProc
   PRIVATE PicDEM := gPICDEM
   PRIVATE Pickol := gPICKOL
   PRIVATE lAsistRadi := .F.

   __box_x := MAXROWS() - 8
   __box_y := MAXCOLS() - 6

   kalk_unos_stavki_dokumenta()

   my_close_all_dbf()

   RETURN .T.



FUNCTION kalk_unos_stavki_dokumenta( lAObrada )

   LOCAL nMaxCol := MAXCOLS() - 3
   LOCAL nMaxRow := MAXROWS() - 4
   LOCAL _opt_row, _opt_d
   LOCAL _sep := BROWSE_COL_SEP

   O_PARAMS

   PRIVATE lAutoObr := .F.
   PRIVATE lAAsist := .F.
   PRIVATE lAAzur := .F.

   IF lAObrada == nil
      lAutoObr := .F.
   ELSE
      lAutoObr := lAObrada
      lAAsist := .T.
      lAAzur := .T.
   ENDIF

   PRIVATE cSection := "K"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   SELECT 99
   USE

   o_kalk_edit()

   PRIVATE gVarijanta := "2"
   PRIVATE PicV := "99999999.9"

   PRIVATE ImeKol := {}
   PRIVATE Kol := {}

   AAdd( ImeKol, { "F.", {|| dbSelectArea( F_KALK_PRIPR ), idfirma   }, "idfirma"   } )
   AAdd( ImeKol, { "VD", {|| IdVD                     }, "IdVD"        } )
   AAdd( ImeKol, { "BrDok", {|| BrDok                    }, "BrDok"       } )
   AAdd( ImeKol, { "R.Br", {|| Rbr                      }, "Rbr"         } )
   AAdd( ImeKol, { "Dat.Kalk", {|| DatDok                   }, "DatDok"      } )
   AAdd( ImeKol, { "Dat.Fakt", {|| DatFaktP                 }, "DatFaktP"    } )
   AAdd( ImeKol, { "K.zad. ", {|| IdKonto                  }, "IdKonto"     } )
   AAdd( ImeKol, { "K.razd.", {|| IdKonto2                 }, "IdKonto2"    } )
   AAdd( ImeKol, { "IdRoba", {|| IdRoba                   }, "IdRoba"      } )

   IF lKoristitiBK
      AAdd( ImeKol, { "Barkod", {|| roba_ocitaj_barkod( idroba ) }, "IdRoba" } )
   ENDIF

   AAdd( ImeKol, { "Kolicina", {|| Transform( Kolicina, picv ) }, "kolicina"    } )
   AAdd( ImeKol, { "IdTarifa", {|| idtarifa                 }, "idtarifa"    } )
   AAdd( ImeKol, { "F.Cj.", {|| Transform( FCJ, picv )      }, "fcj"         } )
   AAdd( ImeKol, { "F.Cj2.", {|| Transform( FCJ2, picv )     }, "fcj2"        } )
   AAdd( ImeKol, { "Nab.Cj.", {|| Transform( NC, picv )       }, "nc"          } )
   AAdd( ImeKol, { "VPC", {|| Transform( VPC, picv )      }, "vpc"         } )
   AAdd( ImeKol, { "VPCj.sa P.", {|| Transform( VPCsaP, picv )   }, "vpcsap"      } )
   AAdd( ImeKol, { "MPC", {|| Transform( MPC, picv )      }, "mpc"         } )
   AAdd( ImeKol, { "MPC sa PP", {|| Transform( MPCSaPP, picv )  }, "mpcsapp"     } )
   AAdd( ImeKol, { "RN", {|| idzaduz2                 }, "idzaduz2"    } )
   AAdd( ImeKol, { "Br.Fakt", {|| brfaktp                  }, "brfaktp"     } )
   AAdd( ImeKol, { "Partner", {|| idpartner                }, "idpartner"   } )
   AAdd( ImeKol, { "Marza", {|| tmarza                   }, "tmarza"   } )
   AAdd( ImeKol, { "Marza 2", {|| tmarza2                  }, "tmarza2"   } )
   AAdd( ImeKol, { "E", {|| error                    }, "error"       } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   Box(, nMaxRow, nMaxCol )

   _opt_d := ( nMaxCol / 4 )

   _opt_row := PadR( "<c+N> Nova stavka", _opt_d ) + _sep
   _opt_row += PadR( "<ENT> Ispravka", _opt_d ) + _sep
   _opt_row += PadR( "<c+T> Briši stavku", _opt_d ) + _sep
   _opt_row += "<K> Kalk.cijena"

   @ m_x + nMaxRow - 3, m_y + 2 SAY8 _opt_row

   _opt_row := PadR( "<c+A> Ispravka", _opt_d ) + _sep
   _opt_row += PadR( "<c+P> Štampa dok.", _opt_d ) + _sep
   _opt_row += PadR( "<a+A> Ažuriranje", _opt_d ) + _sep
   _opt_row += "<Q> Etikete"

   @ m_x + nMaxRow - 2, m_y + 2 SAY8 _opt_row

   _opt_row := PadR( "<a+K> Kontiranje", _opt_d ) + _sep
   _opt_row += PadR( "<c+F9> Briši sve", _opt_d ) + _sep
   _opt_row += PadR( "<a+P> Štampa pripreme", _opt_d ) + _sep

   @ m_x + nMaxRow - 1, m_y + 2 SAY8 _opt_row

   _opt_row := PadR( "<c+F8> Rasp.troškova", _opt_d ) + _sep
   _opt_row += PadR( "<A> Asistent", _opt_d ) + _sep
   _opt_row += PadR( "<F10> Dodatne opc.", _opt_d ) + _sep
   _opt_row += "<F11> Dodatne opc./2"

   @ m_x + nMaxRow, m_y + 2 SAY8 _opt_row

   IF gCijene == "1" .AND. gMetodaNC == " "
      Soboslikar( { { nMaxRow - 3, m_y + 1, nMaxRow, m_y + 77 } }, 23, 14 )
   ENDIF

   PRIVATE lAutoAsist := .F.

   ObjDbedit( "PNal", nMaxRow, nMaxCol, {|| kalk_pripr_key_handler( lAutoObr ) }, "<F5>-kartica magacin, <F6>-kartica prodavnica", "Priprema...", , , , , 4 )

   BoxC()

   my_close_all_dbf()

   RETURN




FUNCTION o_kalk_edit()

   O_KALK_DOKS
   O_SIFK
   O_SIFV
   O_ROBA
   O_KALK
   O_KONTO
   O_PARTN
   O_TDOK
   O_VALUTE
   O_TARIFA
   O_KONCIJ
   O_KALK_PRIPR

   SELECT kalk_pripr
   SET ORDER TO TAG "1"
   GO TOP

   RETURN


STATIC FUNCTION printaj_duple_stavke_iz_pripreme()

   LOCAL _data := {}
   LOCAL _dup := {}
   LOCAL _scan

   O_ROBA
   O_KALK_PRIPR

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

      START PRINT CRET

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

   RETURN


STATIC FUNCTION kalk_24_rekapitulacija()

   my_close_all_dbf()

   RekapK()

   IF Pitanje(, "Želite li izvršiti kontiranje dokumenta (D/N) ?", "D" ) == "D"
      kalk_kontiranje_naloga()
   ENDIF

   o_kalk_edit()

   RETURN DE_REFRESH


FUNCTION kalk_pripr_key_handler()

   LOCAL nTr2
   LOCAL cSekv
   LOCAL nKekk
   LOCAL iSekv
   LOCAL _log_info

   IF ( Ch == K_CTRL_T .OR. Ch == K_ENTER ) .AND. Eof()
      RETURN DE_CONT
   ENDIF

   PRIVATE fNovi := .F.
   PRIVATE PicCDEM := gPicCDEM
   PRIVATE PicProc := gPicProc
   PRIVATE PicDEM := gPicDEM
   PRIVATE Pickol := gPicKol

   SELECT kalk_pripr

   DO CASE

   CASE Ch == K_ALT_H
      Savjetnik()

   CASE Ch == K_ALT_K
      RETURN kalk_24_rekapitulacija()

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

   CASE is_key_alt_a( Ch )

      my_close_all_dbf()

      kalk_azuriranje_dokumenta()
      o_kalk_edit()

      IF kalk_pripr->( RecCount() ) == 0 .AND. IzFMKINI( "Indikatori", "ImaU_KALK", "N", PRIVPATH ) == "D"

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

         _t_rec := RecNo()

         GO ( _t_rec )

         RETURN DE_REFRESH

      ENDIF

      RETURN DE_CONT

   CASE IsDigit( Chr( Ch ) )
      Msg( "Ako želite započeti unos novog dokumenta: <Ctrl-N>" )
      RETURN DE_CONT
   CASE Ch == K_ENTER
      RETURN EditStavka()
   CASE Ch == K_CTRL_A .OR. lAsistRadi
      RETURN EditAll()

   CASE Ch == K_CTRL_N
      fNovi := .T.
      RETURN kalk_unos_nova_stavka()

   CASE Ch == K_CTRL_F8
      RaspTrosk()
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
   CASE Upper( Chr( Ch ) ) == "A" .OR. lAutoAsist

      RETURN kalk_unos_asistent()
   CASE Upper( Chr( Ch ) ) == "K"
      kalkulacija_cijena( .F. )
      SELECT kalk_pripr
      GO TOP
      RETURN DE_CONT
   CASE Ch == K_F10
      RETURN MeniF10()
   CASE Ch == K_F11
      RETURN MeniF11()
   CASE Ch == K_F5
      Kmag()
      RETURN DE_CONT
   CASE Ch == K_F6
      KPro()
      RETURN DE_CONT
   CASE lAutoObr .AND. lAAsist
      lAAsist := .F.
      RETURN kalk_unos_asistent()
   CASE lAutoObr .AND. !lAAsist
      lAutoObr := .F.
      KEYBOARD Chr( K_ESC )
      RETURN DE_REFRESH
   ENDCASE

   RETURN DE_CONT


// ------------------------------------------------------------
// ispravka stavke
// ------------------------------------------------------------
FUNCTION EditStavka()

   LOCAL _atributi := hb_Hash()
   LOCAL _dok
   LOCAL _rok, _opis, _dok_hash
   LOCAL _old_dok, _new_dok
   LOCAL oAtrib, _t_rec

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

   Box( "ist", __box_x, __box_y, .F. )

   _old_dok[ "idfirma" ] := _idfirma
   _old_dok[ "idvd" ] := _idvd
   _old_dok[ "brdok" ] := _brdok

   _dok := hb_Hash()
   _dok[ "idfirma" ] := _idfirma
   _dok[ "idtipdok" ] := _idvd
   _dok[ "brdok" ] := _brdok
   _dok[ "rbr" ] := _rbr

   IF _rok
      _atributi[ "rok" ] := get_kalk_atribut_rok( _dok, .F. )
   ENDIF

   IF _opis
      _atributi[ "opis" ] := get_kalk_atribut_opis( _dok, .F. )
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

      _dok_hash := hb_Hash()
      _dok_hash[ "idfirma" ] := field->idfirma
      _dok_hash[ "idtipdok" ] := field->idvd
      _dok_hash[ "brdok" ] := field->brdok
      _dok_hash[ "rbr" ] := field->rbr

      oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
      oAtrib:dok_hash := _dok_hash
      oAtrib:atrib_hash_to_dbf( _atributi )

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

         Box( "", __box_x, __box_y, .F., "Protustavka" )

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
            IF IsPDV()
               Get1_16bPDV()
            ELSE
               Get1_16b()
            ENDIF
         ELSE
            Get1_80b()
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
   LOCAL _dok, _dok_hash
   LOCAL _old_dok := hb_Hash()
   LOCAL _new_dok
   LOCAL oAtrib
   LOCAL _rok, _opis
   LOCAL _rbr_uvecaj := 0

   // isprazni kontrolnu matricu
   aNC_ctrl := {}

   _rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"
   _opis := fetch_metric( "kalk_dodatni_opis_kod_unosa_dokumenta", NIL, "N" ) == "D"

   Box( "knjn", __box_x, __box_y, .F., "Unos novih stavki" )

   _TMarza := "A"

   IF field->IdVd == "PR"
      SET FILTER TO Val( field->rBr ) < 10
   ELSE
      SET FILTER TO
   ENDIF

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

      _dok_hash := hb_Hash()
      _dok_hash[ "idfirma" ] := field->idfirma
      _dok_hash[ "idtipdok" ] := field->idvd
      _dok_hash[ "brdok" ] := field->brdok
      _dok_hash[ "rbr" ] := field->rbr

      oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
      oAtrib:dok_hash := _dok_hash
      oAtrib:atrib_hash_to_dbf( _atributi )

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

         Box( "", __box_x, __box_y, .F., "Protustavka" )

         IF _idvd == "16"
            IF IsPDV()
               Get1_16bPDV()
            ELSE
               Get1_16b()
            ENDIF
         ELSE
            Get1_80b()
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



FUNCTION EditAll()

   LOCAL _atributi := hb_Hash()
   LOCAL _dok
   LOCAL oAtrib, _dok_hash, _old_dok, _new_dok
   LOCAL _rok, _opis

   PushWA()
   SELECT kalk_pripr

   _rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"
   _opis := fetch_metric( "kalk_dodatni_opis_kod_unosa_dokumenta", NIL, "N" ) == "D"

   Box( "anal", __box_x, __box_y, .F., "Ispravka naloga" )

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

      IF lAsistRadi
         CLEAR TYPEAHEAD
         cSekv := ""
         FOR nkekk := 1 TO 17
            cSekv += cEnter
         NEXT
         KEYBOARD cSekv
      ENDIF

      _dok := hb_Hash()
      _dok[ "idfirma" ] := _idfirma
      _dok[ "idtipdok" ] := _idvd
      _dok[ "brdok" ] := _brdok
      _dok[ "rbr" ] := _rbr

      IF _opis
         _atributi[ "opis" ] := get_kalk_atribut_opis( _dok, .F. )
      ENDIF

      IF _rok
         _atributi[ "rok" ] := get_kalk_atribut_rok( _dok, .F. )
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

      oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
      oAtrib:dok_hash := _dok
      oAtrib:atrib_hash_to_dbf( _atributi )

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

         Box( "", __box_x, __box_y, .F., "Protustavka" )
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
         _idkonto := cIdkont2
         _idkonto2 := "XXX"
         IF _idvd == "16"
            Get1_16b()
         ELSE
            Get1_80b()
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

   CLEAR TYPEAHEAD
   PopWA()

   BoxC()

   lAsistRadi := .F.

   RETURN DE_REFRESH



FUNCTION kalk_unos_asistent()

   lAutoAsist := .F.
   lAsistRadi := .T.

   PushWa()
   IF Select( "kalk_prir" ) > 0
      IF kalk_pripr->idVd == "PR"
         RETURN .F.
      ENDIF
   ENDIF
   PopWa()
   cSekv := Chr( K_CTRL_A )
   KEYBOARD cSekv

   RETURN DE_REFRESH


FUNCTION MeniF10()

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
   AAdd( opc, "D. preuzmi tarife iz šifrarnika"            )
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
         FaktKalk()
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
         ip()
      CASE izbor == 8
         GenNivP()
      CASE izbor == 9
         aRezim := { gCijene, gMetodaNC }
         O_PARAMS
         PRIVATE cSection := "K", cHistory := " "; aHistory := {}
         cIspravka := "D"
         kalk_par_metoda_nc()
         SELECT params; USE
         IF gCijene <> aRezim[ 1 ] .OR. gMetodaNC <> aRezim[ 2 ]
            IF gCijene == "1" .AND. gMetodaNC == " "
               Soboslikar( { { m_x + 17, m_y + 1, m_x + 20, m_y + 77 } }, 23, 14 )
            ELSEIF aRezim[ 1 ] == "1" .AND. aRezim[ 2 ] == " "
               Soboslikar( { { m_x + 17, m_y + 1, m_x + 20, m_y + 77 } }, 14, 23 )
            ENDIF
         ENDIF

      CASE izbor == 10 .AND. cIdVDTek == "19"
         o_kalk_edit()
         SELECT kalk_pripr
         GO TOP
         cidfirma := idfirma
         cidvd := idvd
         cbrdok := brdok
         Obraz19()
         SELECT kalk_pripr
         GO TOP
         RETURN DE_REFRESH

      CASE izbor == 11
         Iz11u412()

      CASE izbor == 12
         PlusMinusKol()

      CASE izbor == 13
         UzmiTarIzSif()

      CASE izbor == 14
         storno_kalk_dokument()

      CASE izbor == 15
         DiskMPCSAPP()

      CASE izbor == 16

         kalk_dokument_prenos_cijena()

      CASE izbor == 17
         VPCSifUDok()

      CASE izbor == 18
         Iz12u97()     // 11,12 -> 96,97

      CASE izbor == 19
         Iz10u11()

      CASE izbor == 20
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
   @ m_x + 1, m_y + 2 SAY8 "Prenos cijena dokument/šifrarnik ****"
   @ m_x + 3, m_y + 2 SAY8 "1) prenos MPCSAPP (dok) => šifrarnik"
   @ m_x + 4, m_y + 2 SAY8 "2) prenos šifrarnik => MPCSAPP (dok)"
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

      O_KALK_PRIPR
      O_ROBA
      O_KONCIJ
      O_KONTO

      Box(, 1, 50 )
      @ m_x + 1, m_y + 2 SAY8 "Prodavnički konto:" GET _konto VALID p_konto( @_konto )
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN
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
         _rec[ "mpcsapp" ] := UzmiMpcSif()

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
      MsgBeep( "Ubačene cijene iz šifrarnika !#Odradite asistenta sa opcijom A" )
   ENDIF

   RETURN



FUNCTION MeniF11()

   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc, "1. ubacivanje troškova-uvozna kalkulacija" )
   AAdd( opcexe, {|| KalkTrUvoz() } )
   AAdd( opc, "2. pretvori maloprodajni popust u smanjenje MPC" )
   AAdd( opcexe, {|| PopustKaoNivelacijaMP() } )
   AAdd( opc, "3. obračun poreza pri uvozu" )
   AAdd( opcexe, {|| ObracunPorezaUvoz() } )
   AAdd( opc, "4. pregled smeća" )
   AAdd( opcexe, {|| kalk_pripr9View() } )
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

   O_KALK_PRIPR
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

   RETURN



FUNCTION SetNcTo0()

   IF Pitanje(, "Setovati NC na 0 (D/N)?", "N" ) == "N"
      RETURN
   ENDIF

   O_KALK_PRIPR
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

   RETURN




FUNCTION kalk_edit_priprema( fNovi, atrib )

   PRIVATE nMarza := 0
   PRIVATE nMarza2 := 0
   PRIVATE nR
   PRIVATE PicDEM := "9999999.99999999"
   PRIVATE PicKol := gPicKol

   nStrana := 1

   DO WHILE .T.

      @ m_x + 1, m_y + 1 CLEAR TO m_x + __box_x, m_y + __box_y

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

   RETURN





/* fn Get1()
 *  param fnovi
 *  brief Prva strana/prozor maske unosa/ispravke stavke dokumenta
 */

FUNCTION kalk_unos_1( fNovi, atrib )

   PRIVATE pIzgSt := .F.
   PRIVATE Getlist := {}

   IF Get1Header( fNovi ) == 0
      RETURN K_ESC
   ENDIF

   SELECT kalk_pripr
   SET FILTER TO
   
   IF _idvd == "10"

      RETURN Get1_10PDV()

   ELSEIF _idvd == "11"
      RETURN GET1_11()

   ELSEIF _idvd == "12"
      RETURN GET1_12()

   ELSEIF _idvd == "13"
      RETURN GET1_12()

   ELSEIF _idvd == "14"
      RETURN Get1_14PDV()

   ELSEIF _idvd == "KO"
      RETURN GET1_14PDV()

   ELSEIF _idvd == "16"
      RETURN GET1_16PDV()

   ELSEIF _idvd == "18"
      RETURN GET1_18()

   ELSEIF _idvd == "19"
      RETURN GET1_19()

   ELSEIF _idvd $ "41#42#43#47#49"
      RETURN GET1_41()

   ELSEIF _idvd == "81"
      RETURN kalk_unos_dok_81( @atrib )

   ELSEIF _idvd == "80"
      RETURN GET1_80( @atrib )

   ELSEIF _idvd == "24"
      RETURN GET1_24PDV()

   ELSEIF _idvd $ "95#96#97"
      RETURN GET1_95()

   ELSEIF _idvd $  "94#16"    // storno fakture, storno otpreme, doprema
      RETURN GET1_94()

   ELSEIF _idvd == "82"
      RETURN GET1_82()

   ELSEIF _idvd == "IM"
      RETURN GET1_IM()

   ELSEIF _idvd == "IP"
      RETURN GET1_IP()

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



/*! fn Get2()
 *  param fnovi
 *  \brief Druga strana/prozor maske unosa/ispravke stavke dokumenta
 */

FUNCTION kalk_unos_2( fNovi )

   IF _idvd $ "10"
      IF !IsPDV()
         RETURN Get2_10()
      ENDIF
   ELSEIF _idvd == "RN"
      RETURN Get2_RN()
   ELSEIF _idvd == "PR"
      RETURN Get2_PR()
   ENDIF

   RETURN K_ESC





FUNCTION Get1Header( fNovi )

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

   IF fNovi .AND. gBrojac == "D" .AND. ( _idfirma <> idfirma .OR. _idvd <> idvd )

      IF glBrojacPoKontima

         Box( "#Glavni konto", 3, 70 )
         IF _idvd $ "10#16#18#IM#"
            @ m_x + 2, m_y + 2 SAY8 "Magacinski konto zadužuje" GET _idKonto VALID P_Konto( @_idKonto ) PICT "@!"
            READ
            cSufiks := SufBrKalk( _idKonto )
         ELSE
            @ m_x + 2, m_y + 2 SAY8 "Magacinski konto razdužuje" GET _idKonto2 VALID P_Konto( @_idKonto2 ) PICT "@!"
            READ
            cSufiks := SufBrKalk( _idKonto2 )
         ENDIF
         BoxC()

         _brDok := SljBrKalk( _idvd, _idfirma, cSufiks )

      ELSE

         _brDok := SljBrKalk( _idvd, _idfirma )

      ENDIF

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
   LOCAL oAtrib
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

   oAtrib := F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB )
   oAtrib:open_local_table()

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






/*! \fn VpcSaPpp()
 *  \brief Vrsi se preracunavanje veleprodajnih cijena ako je _VPC=0
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




/*! \fn RaspTrosk(fSilent)
 *  \brief Rasporedjivanje troskova koji su predvidjeni za raspored. Takodje se koristi za raspored ukupne nabavne vrijednosti na pojedinacne artikle kod npr. unosa pocetnog stanja prodavnice ili magacina
 */

FUNCTION RaspTrosk( fSilent )

   LOCAL nStUc := 20

   IF fsilent == NIL
      fsilent := .F.
   ENDIF
   IF fsilent .OR.  Pitanje(, "Rasporediti troškove (D/N) ?", "N" ) == "D"
      PRIVATE qqTar := ""
      PRIVATE aUslTar := ""
      IF idvd $ "16#80"
         Box(, 1, 55 )
         IF idvd == "16"
            @ m_x + 1, m_y + 2 SAY8 "Stopa marže (vpc - stopa*vpc)=nc:" GET nStUc PICT "999.999"
         ELSE
            @ m_x + 1, m_y + 2 SAY8 "Stopa marže (mpc-stopa*mpcsapp)=nc:" GET nStUc PICT "999.999"
         ENDIF
         READ
         BoxC()
      ENDIF
      GO TOP

      SELECT F_KONCIJ
      IF !Used(); O_KONCIJ; ENDIF
      SELECT koncij
      SEEK Trim( kalk_pripr->mkonto )
      SELECT kalk_pripr

      IF IsVindija()
         PushWA()
         IF !Empty( qqTar )
            aUslTar := Parsiraj( qqTar, "idTarifa" )
            IF aUslTar <> NIL .AND. !aUslTar == ".t."
               SET FILTER to &aUslTar
            ENDIF
         ENDIF
      ENDIF

      DO WHILE !Eof()
         nUKIzF := 0
         nUkProV := 0
         cIdFirma := idfirma;cIdVD := idvd;cBrDok := Brdok
         nRec := RecNo()
         DO WHILE !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok
            IF cidvd $ "10#16#81#80"
               // zaduzenje magacina,prodavnice
               nUkIzF += Round( fcj * ( 1 -Rabat / 100 ) * kolicina, gZaokr )
            ENDIF
            IF cidvd $ "11#12#13"
               // magacin-> prodavnica,povrat
               nUkIzF += Round( fcj * kolicina, gZaokr )
            ENDIF
            IF cidvd $ "RN"
               IF Val( Rbr ) < 900
                  nUkProV += Round( vpc * kolicina, gZaokr )
               ELSE
                  nUkIzF += Round( nc * kolicina, gZaokr )  // sirovine
               ENDIF
            ENDIF
            SKIP
         ENDDO
         IF cidvd $ "10#16#81#80#RN"  // zaduzenje magacina,prodavnice
            GO nRec
            RTPrevoz := .F. ; RPrevoz := 0
            RTCarDaz := .F. ;RCarDaz := 0
            RTBankTr := .F. ;RBankTr := 0
            RTSpedTr := .F. ;RSpedTr := 0
            RTZavTr := .F. ;RZavTr := 0
            IF TPrevoz == "R"; RTPrevoz := .T. ;RPrevoz := Prevoz; ENDIF
            IF TCarDaz == "R"; RTCarDaz := .T. ;RCarDaz := CarDaz; ENDIF
            IF TBankTr == "R"; RTBankTr := .T. ;RBankTr := BankTr; ENDIF
            IF TSpedTr == "R"; RTSpedTr := .T. ;RSpedTr := SpedTr; ENDIF
            IF TZavTr == "R"; RTZavTr := .T. ;RZavTr := ZavTr ; ENDIF

            UBankTr := 0   // do sada utroçeno na bank tr itd, radi "sitniça"
            UPrevoz := 0
            UZavTr := 0
            USpedTr := 0
            UCarDaz := 0
            DO WHILE !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok
               Scatter()

               IF _idvd $ "RN" .AND. Val( _rbr ) < 900
                  _fcj := _fcj2 := _vpc / nUKProV * nUkIzF
                  // nabavne cijene izmisli proporcionalno prodajnim
               ENDIF

               IF RTPrevoz    // troskovi 1
                  IF Round( nUkIzF, 4 ) == 0
                     _Prevoz := 0
                  ELSE
                     _Prevoz := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkIzF * RPrevoz, gZaokr )
                     UPrevoz += _Prevoz
                     IF Abs( RPrevoz - UPrevoz ) < 0.1 // sitniç, baci ga na zadnju st.
                        SKIP
                        IF ! ( !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok )
                           _Prevoz += ( RPrevoz - UPrevoz )
                        ENDIF
                        SKIP -1
                     ENDIF
                  ENDIF
                  _TPrevoz := "U"
               ENDIF
               IF RTCarDaz   // troskovi 2
                  IF Round( nUkIzF, 4 ) == 0
                     _CarDaz := 0
                  ELSE
                     _CarDaz := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkIzF * RCarDaz, gZaokr )
                     UCardaz += _Cardaz
                     IF Abs( RCardaz - UCardaz ) < 0.1 // sitniç, baci ga na zadnju st.
                        SKIP
                        IF ! ( !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok )
                           _Cardaz += ( RCardaz - UCardaz )
                        ENDIF
                        SKIP -1
                     ENDIF
                  ENDIF
                  _TCarDaz := "U"
               ENDIF
               IF RTBankTr  // troskovi 3
                  IF Round( nUkIzF, 4 ) == 0
                     _BankTr := 0
                  ELSE
                     _BankTr := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkIzF * RBankTr, gZaokr )
                     UBankTr += _BankTr
                     IF Abs( RBankTr - UBankTr ) < 0.1 // sitniç, baci ga na zadnju st.
                        SKIP
                        IF ! ( !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok )
                           _BankTr += ( RBankTr - UBankTr )
                        ENDIF
                        SKIP -1
                     ENDIF
                  ENDIF
                  _TBankTr := "U"
               ENDIF
               IF RTSpedTr    // troskovi 4
                  IF Round( nUkIzF, 4 ) == 0
                     _SpedTr := 0
                  ELSE
                     _SpedTr := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkIzF * RSpedTr, gZaokr )
                     USpedTr += _SpedTr
                     IF Abs( RSpedTr - USpedTr ) < 0.1 // sitniç, baci ga na zadnju st.
                        SKIP
                        IF ! ( !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok )
                           _SpedTr += ( RSpedTr - USpedTr )
                        ENDIF
                        SKIP -1
                     ENDIF
                  ENDIF
                  _TSpedTr := "U"
               ENDIF
               IF RTZavTr    // troskovi
                  IF Round( nUkIzF, 4 ) == 0
                     _ZavTr := 0
                  ELSE
                     _ZavTr := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkIzF * RZavTr, gZaokr )
                     UZavTR += _ZavTR
                     IF Abs( RZavTR - UZavTR ) < 0.1 // sitniç, baci ga na zadnju st.
                        SKIP
                        IF ! ( !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok )
                           _ZavTR += ( RZavTR - UZavTR )
                        ENDIF
                        SKIP -1
                     ENDIF
                  ENDIF
                  _TZavTr := "U"
               ENDIF
               SELECT roba; HSEEK _idroba
               SELECT tarifa; HSEEK _idtarifa; SELECT kalk_pripr
               IF _idvd == "RN"
                  IF Val( _rbr ) < 900
                     NabCj()
                  ENDIF
               ELSE
                  NabCj()
               ENDIF
               IF _idvd == "16"
                  _nc := _vpc * ( 1 -nStUc / 100 )
               ENDIF
               IF _idvd == "80"
                  _nc := _mpc - _mpcsapp * nStUc / 100
                  _vpc := _nc
                  _TMarza2 := "A"
                  _Marza2 := _mpc - _nc
               ENDIF
               IF koncij->naz == "N1"; _VPC := _NC; ENDIF
               IF _idvd == "RN"
                  IF Val( _rbr ) < 900
                     Marza()
                  ENDIF
               ELSE
                  Marza()
               ENDIF
               my_rlock()
               Gather()
               my_unlock()
               SKIP
            ENDDO
         ENDIF // cidvd $ 10
         IF cidvd $ "11#12#13"
            GO nRec
            RTPrevoz := .F. ;RPrevoz := 0
            IF TPrevoz == "R"; RTPrevoz := .T. ;RPrevoz := Prevoz; ENDIF
            nMarza2 := 0
            DO WHILE !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok
               Scatter()
               IF RTPrevoz    // troskovi 1
                  IF Round( nUkIzF, 4 ) == 0
                     _Prevoz := 0
                  ELSE
                     _Prevoz := _fcj / nUkIzF * RPrevoz
                  ENDIF
                  _TPrevoz := "A"
               ENDIF
               _nc := _fcj + _prevoz
               IF koncij->naz == "N1"; _VPC := _NC; ENDIF
               _marza := _VPC - _FCJ
               _TMarza := "A"
               SELECT roba
               HSEEK _idroba
               SELECT tarifa
               HSEEK _idtarifa
               SELECT kalk_pripr
               Marza2()
               _TMarza2 := "A"
               _Marza2 := nMarza2
               my_rlock()
               Gather()
               my_unlock()
               SKIP
            ENDDO
         ENDIF // cidvd $ "11#12#13"
      ENDDO  // eof()

      IF IsVindija()
         SELECT kalk_pripr
         PopWA()
      ENDIF

   ENDIF // pitanje
   GO TOP

   RETURN




/*! \fn Savjetnik()
 *  \brief Zamisljeno da se koristi kao pomoc u rjesavanju problema pri unosu dokumenta. Nije razradjeno.
 */

FUNCTION Savjetnik()

   LOCAL nRec := RecNo(), lGreska := .F.

   MsgO( "Priprema izvjestaja..." )
   SET CONSOLE OFF
   cKom := PRIVPATH + "savjeti.txt"
   SET PRINTER OFF
   SET DEVICE TO PRINTER
   cDDir := Set( _SET_DEFAULT )
   SET DEFAULT TO
   SET PRINTER to ( ckom )
   SET PRINTER ON
   Set( _SET_DEFAULT, cDDir )

   SELECT kalk_pripr
   GO TOP

   DO WHILE !Eof()
      lGreska := .F.
      DO CASE

      CASE idvd == "11"     // magacin->prodavnica
         IF vpc == 0
            OpisStavke( @lGreska )
            ? "PROBLEM: - veleprodajna cijena = 0"
            ? "OPIS:    - niste napravili ulaz u magacin, ili nemate veleprodajnu"
            ? "           cijenu (VPC) u sifrarniku za taj artikal"
         ENDIF

      ENDCASE

      IF Empty( datdok )
         OpisStavke( @lGreska )
         ? "DATUM KALKULACIJE NIJE UNESEN!!!"
      ENDIF

      IF Empty( error )
         OpisStavke( @lGreska )
         ? "STAVKA PRIPADA AUTOMATSKI FORMIRANOM DOKUMENTU !!!"
         ? "Pokrenite opciju <A> - asistent ako zelite da program sam prodje"
         ? "kroz sve stavke ili udjite sa <Enter> u ispravku samo ove stavke."
         IF idvd == "11"
            ? "Kada pokrenete <A> za ovu kalkulaciju (11), veleprodajna"
            ? "cijena ce biti preuzeta: 1) Ako program omogucava azuriranje"
            ? "sumnjivih dokumenata, VPC ce ostati nepromijenjena; 2) Ako program"
            ? "radi tako da ne omogucava azuriranje sumnjivih dokumenata, VPC ce"
            ? "biti preuzeta iz trenutne kartice artikla. Ako nemate evidentiranih"
            ? "ulaza artikla u magacin, bice preuzeta 0 sto naravno nije korektno."
         ENDIF
      ENDIF

      IF lGreska; ?; ENDIF
      SKIP 1
   ENDDO

   SET PRINTER TO
   SET PRINTER OFF
   SET CONSOLE ON
   SET DEVICE TO SCREEN
   SET PRINTER TO
   MsgC()
   SAVE SCREEN TO cS
   VidiFajl( cKom )
   RESTORE SCREEN FROM cS
   SELECT kalk_pripr
   GO ( nRec )

   RETURN



/*! \fn OpisStavke(lGreska)
 *  \brief Daje informacije o dokumentu i artiklu radi lociranja problema. Koristi je opcija "savjetnik"
 *  \sa Savjetnik()
 */

FUNCTION OpisStavke( lGreska )

   IF !lGreska
      ? "Dokument:    " + idfirma + "-" + idvd + "-" + brdok + ", stavka " + rbr
      ? "Artikal: " + idroba + "-" + Left( Ocitaj( F_ROBA, idroba, "naz" ), 40 )
      lGreska := .T.
   ENDIF

   RETURN




FUNCTION Soboslikar( aNiz, nIzKodaBoja, nUKodBoja )

   LOCAL i, cEkran

   FOR i := 1 TO Len( aNiz )
      cEkran := SaveScreen( aNiz[ i, 1 ], aNiz[ i, 2 ], aNiz[ i, 3 ], aNiz[ i, 4 ] )
      cEkran := StrTran( cEkran, Chr( nIzKodaBoja ), Chr( nUKodBoja ) )
      RestScreen( aNiz[ i, 1 ], aNiz[ i, 2 ], aNiz[ i, 3 ], aNiz[ i, 4 ], cEkran )
   NEXT

   RETURN


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

   RETURN


STATIC FUNCTION NazProdObj()

   LOCAL cVrati := ""

   SELECT KONTO
   SEEK kalk_pripr->pkonto
   cVrati := naz
   SELECT kalk_pripr

   RETURN cVrati






/*! fn PlusMinusKol()
 *  \brief Mijenja predznak kolicini u svim stavkama u kalk_pripremi
 */

FUNCTION PlusMinusKol()

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
   // lAutoAsist:=.t.
   KEYBOARD Chr( K_ESC )

   my_close_all_dbf()

   RETURN




/*! \fn UzmiTarIzSif()
 *  \brief Filuje tarifu u svim stavkama u kalk_pripremi odgovarajucom sifrom tarife iz sifrarnika robe
 */

FUNCTION UzmiTarIzSif()

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
   lAutoAsist := .T.
   KEYBOARD Chr( K_ESC )
   my_close_all_dbf()

   RETURN




/*! \fn DiskMPCSAPP()
 *  \brief Formira diskontnu maloprodajnu cijenu u svim stavkama u kalk_pripremi
 */

FUNCTION DiskMPCSAPP()

   // {
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
      Tarifa( kalk_pripr->pKonto, kalk_pripr->idRoba, @aPorezi )
      SELECT kalk_pripr
      Scatter()

      _mpcSaPP := MpcSaPor( roba->vpc, aPorezi )

      _ERROR := " "
      Gather()
      SKIP 1
   ENDDO
   my_unlock()
   Msg( "Automatski pokrećem asistenta (opcija A)!", 1 )
   lAutoAsist := .T.
   KEYBOARD Chr( K_ESC )
   my_close_all_dbf()

   RETURN .T.




/*! \fn MPCSAPPuSif()
 *  \brief Maloprodajne cijene svih artikala u kalk_pripremi kopira u sifrarnik robe
 */

FUNCTION MPCSAPPuSif()

   o_kalk_edit()
   SELECT kalk_pripr
   GO TOP
   DO WHILE !Eof()
      cIdKonto := kalk_pripr->pkonto
      SELECT KONCIJ; HSEEK cIdKonto
      SELECT kalk_pripr
      DO WHILE !Eof() .AND. pkonto == cIdKonto
         SELECT ROBA; HSEEK kalk_pripr->idroba
         IF Found()
            StaviMPCSif( kalk_pripr->mpcsapp, .F. )
         ENDIF
         SELECT kalk_pripr
         SKIP 1
      ENDDO
   ENDDO
   my_close_all_dbf()

   RETURN



/*! \fn MPCSAPPiz80uSif()
 *  \brief Maloprodajne cijene svih artikala iz izabranog azuriranog dokumenta tipa 80 kopira u sifrarnik robe
 */

FUNCTION MPCSAPPiz80uSif()

   o_kalk_edit()

   cIdFirma := gFirma
   cIdVdU   := "80"
   cBrDokU  := Space( Len( kalk_pripr->brdok ) )

   Box(, 4, 75 )
   @ m_x + 0, m_y + 5 SAY8 "FORMIRANJE MPC U ŠIFRARNIKU OD MPCSAPP DOKUMENTA TIPA 80"
   @ m_x + 2, m_y + 2 SAY8 "Dokument: " + cIdFirma + "-" + cIdVdU + "-"
   @ Row(), Col() GET cBrDokU VALID postoji_kalk_dok( cIdFirma + cIdVdU + cBrDokU )
   READ; ESC_BCR
   BoxC()

   // pocnimo
   SELECT KALK
   SEEK cIdFirma + cIdVDU + cBrDokU
   cIdKonto := KALK->pkonto
   SELECT KONCIJ; HSEEK cIdKonto
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

   RETURN




/*! fn VPCSifUDok()
 *  brief Filuje VPC u svim stavkama u kalk_pripremi odgovarajucom VPC iz sifrarnika robe
 */

FUNCTION VPCSifUDok()

   // {
   o_kalk_edit()
   SELECT kalk_pripr
   GO TOP
   my_flock()
   DO WHILE !Eof()
      SELECT ROBA; HSEEK kalk_pripr->idroba
      SELECT KONCIJ; SEEK Trim( kalk_pripr->mkonto )
      // SELECT TARIFA; HSEEK ROBA->idtarifa
      SELECT kalk_pripr
      Scatter()
      _vpc := KoncijVPC()
      _ERROR := " "
      Gather()
      SKIP 1
   ENDDO
   my_unlock()
   Msg( "Automatski pokrećem asistenta (opcija A) !", 1 )
   lAutoAsist := .T.
   KEYBOARD Chr( K_ESC )
   my_close_all_dbf()

   RETURN .T.




STATIC FUNCTION kalk_open_tables( azurirana )

   O_KONCIJ
   O_ROBA
   O_TARIFA
   O_PARTN
   O_KONTO
   O_TDOK

   IF azurirana
      O_SKALK
   ELSE
      O_KALK_PRIPR
   ENDIF

   RETURN




FUNCTION kalk_stampa_dokumenta()

   PARAMETERS fStara, cSeek, lAuto
   LOCAL nCol1
   LOCAL nCol2
   LOCAL nPom

   nCol1 := 0
   nCol2 := 0
   nPom := 0

   PRIVATE PicCDEM := gPICCDEM
   PRIVATE PicProc := gPICPROC
   PRIVATE PicDEM  := gPICDEM
   PRIVATE Pickol  := gPICKOL
   PRIVATE nStr := 0

   IF ( PCount() == 0 )
      fstara := .F.
   ENDIF

   IF ( fStara == nil )
      fStara := .F.
   ENDIF

   IF ( lAuto == nil )
      lAuto := .F.
   ENDIF

   IF ( cSeek == nil )
      cSeek := ""
   ENDIF

   my_close_all_dbf()

   kalk_open_tables( fstara )

   SELECT kalk_pripr
   SET ORDER TO TAG "1"
   GO TOP

   IF ( field->idvd == "24" )
      RETURN kalk_24_rekapitulacija()
   ENDIF

   fTopsD := .F.
   fFaktD := .F.

   DO WHILE .T.

      cIdFirma := IdFirma
      cBrDok := BrDok
      cIdVD := IdVD

      IF Eof()
         EXIT
      ENDIF

      IF Empty( cIdvd + cBrdok + cIdfirma )
         SKIP
         LOOP
      ENDIF

      IF !lAuto

         IF ( cSeek == "" )
            Box( "", 1, 50 )
            SET CURSOR ON
            @ m_x + 1, m_y + 2 SAY "Dokument broj:"
            IF ( gNW $ "DX" )
               @ m_x + 1, Col() + 2  SAY cIdFirma
            ELSE
               @ m_x + 1, Col() + 2 GET cIdFirma
            ENDIF
            @ m_x + 1, Col() + 1 SAY "-" GET cIdVD  PICT "@!"
            @ m_x + 1, Col() + 1 SAY "-" GET cBrDok
            READ
            ESC_BCR
            BoxC()
         ENDIF

      ENDIF

      IF ( !Empty( cSeek ) .AND. cSeek != 'IZDOKS' )
         HSEEK cSeek
         cIdfirma := SubStr( cSeek, 1, 2 )
         cIdvd := SubStr( cSeek, 3, 2 )
         cBrDok := PadR( SubStr( cSeek, 5, 8 ), 8 )
      ELSE
         HSEEK cIdFirma + cIdVD + cBrDok
      ENDIF

      // provjeri da li kalkulacija ima sve cijene ?
      IF !kalkulacija_ima_sve_cijene( cIdFirma, cIdVd, cBrDok )
         MsgBeep( "Unutar kalkulacije nedostaju pojedine cijene bitne za obračun!#Štampanje onemogućeno." )
         my_close_all_dbf()
         RETURN .F.
      ENDIF

      IF ( cSeek != 'IZDOKS' )
         EOF CRET
      ELSE
         PRIVATE nStr := 1
      ENDIF

      START PRINT CRET
      ?

      DO WHILE .T.
         IF ( cidvd == "10" .AND. !( ( gVarEv == "2" ) .OR. ( gmagacin == "1" ) ) .OR. ( cidvd $ "11#12#13" ) ) .AND. ( c10Var == "3" )
            gPSOld := gPStranica
            gPStranica := Val( IzFmkIni( "KALK", "A3_GPSTRANICA", "-20", EXEPATH ) )
            P_PO_L
         ENDIF

         IF ( cSeek == 'IZDOKS' )
            // stampaj sve odjednom !!!
            IF ( PRow() > 42 )
               ++nStr
               FF
            ENDIF
            SELECT kalk_pripr
            cIdfirma := kalk_pripr->idfirma
            cIdvd := kalk_pripr->idvd
            cBrdok := kalk_pripr->brdok
            HSEEK cIdFirma + cIdVD + cBrDok
         ENDIF

         Preduzece()

         IF ( cidvd == "10" .OR. cidvd == "70" ) .AND. !IsPDV()
            IF ( gVarEv == "2" )
               StKalk10_sk()
            ELSEIF ( gMagacin == "1" )
               // samo po nabavnim
               StKalk10_1()
            ELSE
               IF ( c10Var == "1" )
                  StKalk10_2()
               ELSEIF ( c10Var == "2" )
                  StKalk10_3()
               ELSE
                  StKalk10_4()
               ENDIF
            ENDIF
         ELSEIF cIdVD == "10" .AND. IsPDV()
            IF ( gMagacin == "1" )
               // samo po nabavnim
               StKalk10_1()
            ELSE
               // PDV ulazna kalkulacija
               StKalk10_PDV()
            ENDIF
         ELSEIF cidvd $ "15"
            IF !IsPDV()
               StKalk15()
            ENDIF
         ELSEIF ( cidvd $ "11#12#13" )
            IF ( c10Var == "3" )
               StKalk11_3()
            ELSE
               IF ( gmagacin == "1" )
                  StKalk11_1()
               ELSE
                  StKalk11_2()
               ENDIF
            ENDIF
         ELSEIF ( cidvd $ "14#94#74#KO" )
            IF ( c10Var == "3" )
               Stkalk14_3()
            ELSE
               StKalk14PDV()
            ENDIF
         ELSEIF ( cidvd $ "16#95#96#97" ) .AND. IsPDV()
            IF gPDVMagNab == "D"
               StKalk95_1()
            ELSE
               StKalk95_PDV()
            ENDIF
         ELSEIF ( cidvd $ "95#96#97#16" ) .AND. !IsPDV()
            IF ( gVarEv == "2" )
               Stkalk95_sk()
            ELSEIF ( gMagacin == "1" )
               Stkalk95_1()
            ELSE
               Stkalk95()
            ENDIF
         ELSEIF ( cidvd $ "41#42#43#47#49" )
            StKalk41()
         ELSEIF ( cIdvd == "18" )
            StKalk18()
         ELSEIF ( cIdvd == "19" )
            StKalk19()
         ELSEIF ( cIdvd == "80" )
            StKalk80()
         ELSEIF ( cidvd == "81" )
            IF ( c10Var == "1" )
               StKalk81()
            ELSE
               StKalk81_2()
            ENDIF
         ELSEIF ( cidvd == "82" )
            StKalk82()
         ELSEIF ( cidvd == "IM" )
            StKalkIm()
         ELSEIF ( cidvd == "IP" )
            StKalkIp()
         ELSEIF ( cidvd == "RN" )
            IF !fStara
               RaspTrosk( .T. )
            ENDIF
            StkalkRN()
         ELSEIF ( cidvd == "PR" )
            st_kalk_dokument_pr()
         ENDIF

         IF ( cSeek != 'IZDOKS' )
            EXIT
         ELSE
            SELECT kalk_pripr
            SKIP
            IF Eof()
               EXIT
            ENDIF
            ?
            ?
         ENDIF

         IF ( cidvd == "10" .AND. !( ( gVarEv == "2" ) .OR. ( gmagacin == "1" ) ) .OR. ( cidvd $ "11#12#13" ) ) .AND. ( c10Var == "3" )
            gPStranica := gPSOld
            P_PO_P
         ENDIF

      ENDDO // cSEEK

      IF ( gPotpis == "D" )
         IF ( PRow() > 57 + gPStranica )
            FF
            @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
         ENDIF
         ?
         ?
         P_12CPI
         @ PRow() + 1, 47 SAY "Obrada AOP  "; ?? Replicate( "_", 20 )
         @ PRow() + 1, 47 SAY "Komercijala "; ?? Replicate( "_", 20 )
         @ PRow() + 1, 47 SAY "Likvidatura "; ?? Replicate( "_", 20 )
      ENDIF

      ?
      ?

      FF

      // zapamti tabelu, zapis na kojima si stao
      PushWA()
      my_close_all_dbf()
      ENDPRINT

      kalk_open_tables( fstara )
      PopWa()

      IF ( cidvd $ "80#11#81#12#13#IP#19" )
         fTopsD := .T.
      ENDIF

      IF ( cidvd $ "10#11#81" )
         fFaktD := .T.
      ENDIF

      IF ( !Empty( cSeek ) )
         EXIT
      ENDIF

   ENDDO  // vrti kroz kalkulacije

   IF ( fTopsD .AND. !fstara .AND. gTops != "0 " )
      start PRINT cret
      SELECT kalk_pripr
      SET ORDER TO TAG "1"
      GO TOP
      cIdFirma := IdFirma
      cBrDok := BrDok
      cIdVD := IdVD
      IF ( cIdVd $ "11#12" )
         StKalk11_2( .T. )  // maksuzija za tops - bez NC
      ELSEIF ( cIdVd == "80" )
         Stkalk80( .T. )
      ELSEIF ( cIdVd == "81" )
         Stkalk81( .T. )
      ELSEIF ( cIdVd == "IP" )
         StkalkIP( .T. )
      ELSEIF ( cIdVd == "19" )
         Stkalk19()
      ENDIF
      my_close_all_dbf()
      FF
      ENDPRINT

      kalk_generisi_tops_dokumente()

   ENDIF

   IF ( fFaktD .AND. !fStara .AND. gFakt != "0 " )
      start PRINT cret
      o_kalk_edit()
      SELECT kalk_pripr
      SET ORDER TO TAG "1"
      GO TOP
      cIdFirma := IdFirma
      cBrDok := BrDok
      cIdVD := IdVD
      IF ( cIdVd $ "11#12" )
         StKalk11_2( .T. )
      ELSEIF ( cIdVd == "10" )
         StKalk10_3( .T. )
      ELSEIF ( cIdVd == "81" )
         StKalk81( .T. )
      ENDIF
      my_close_all_dbf()
      FF
      ENDPRINT

   ENDIF

   my_close_all_dbf()

   RETURN NIL



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




/*! \fn PopustKaoNivelacijaMP()
 *  \brief Umjesto iskazanog popusta odradjuje smanjenje MPC
 */

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
