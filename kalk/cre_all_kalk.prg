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

#include "fmk.ch"
#include "cre_all.ch"


FUNCTION cre_all_kalk( ver )

   LOCAL aDbf
   LOCAL _alias, _table_name
   LOCAL _created
   LOCAL _tbl

   // -----------------------------------------------
   // KALK_DOKS
   // -----------------------------------------------
	
   aDbf := {}
   AAdd( aDBf, { 'IDFIRMA', 'C',   2,  0 } )
   AAdd( aDBf, { 'IDVD', 'C',   2,  0 } )
   AAdd( aDBf, { 'BRDOK', 'C',   8,  0 } )
   AAdd( aDBf, { 'DATDOK', 'D',   8,  0 } )
   AAdd( aDBf, { 'BRFAKTP', 'C',  10,  0 } )
   AAdd( aDBf, { 'IDPARTNER', 'C',   6,  0 } )
   AAdd( aDBf, { 'IdZADUZ', 'C',   6,  0 } )
   AAdd( aDBf, { 'IdZADUZ2', 'C',   6,  0 } )
   AAdd( aDBf, { 'PKONTO', 'C',   7,  0 } )
   AAdd( aDBf, { 'MKONTO', 'C',   7,  0 } )
   AAdd( aDBf, { 'NV', 'N',  12,  2 } )
   AAdd( aDBf, { 'VPV', 'N',  12,  2 } )
   AAdd( aDBf, { 'RABAT', 'N',  12,  2 } )
   AAdd( aDBf, { 'MPV', 'N',  12,  2 } )
   AAdd( aDBf, { 'PODBR', 'C',   2,  0 } )
   AAdd( aDBf, { 'SIFRA', 'C',   6,  0 } )

   _alias := "KALK_DOKS"
   _table_name := "kalk_doks"

   IF_NOT_FILE_DBF_CREATE

   // 0.4.0
   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 0400
      modstru( { "*" + _table_name, "A SIFRA C 6 0" } )
   ENDIF

   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "1", "IdFirma+idvd+brdok", _alias )
   CREATE_INDEX( "2", "IdFirma+MKONTO+idzaduz2+idvd+brdok", _alias )
   CREATE_INDEX( "3", "IdFirma+dtos(datdok)+podbr+idvd+brdok", _alias )
   CREATE_INDEX( "DAT","datdok", _alias )
   CREATE_INDEX( "1S", "IdFirma+idvd+SUBSTR(brdok,6)+LEFT(brdok,5)", _alias )
   CREATE_INDEX( "V_BRF", "brfaktp+idvd", _alias )
   CREATE_INDEX( "V_BRF2", "idvd+brfaktp", _alias )


   // -----------------------------------------------
   // KALK_KALK
   // -----------------------------------------------

   aDbf := {}
   AAdd( aDBf, { 'IDFIRMA', 'C',   2,  0 } )
   AAdd( aDBf, { 'IDROBA', 'C',  10,  0 } )
   AAdd( aDBf, { 'IDKONTO', 'C',   7,  0 } )
   AAdd( aDBf, { 'IDKONTO2', 'C',   7,  0 } )
   AAdd( aDBf, { 'IDZADUZ', 'C',   6,  0 } )
   AAdd( aDBf, { 'IDZADUZ2', 'C',   6,  0 } )
   // ova su polja prakticno tu samo radi kompat
   // istina, ona su ponegdje iskoristena za neke sasvim druge stvari
   // pa zato treba biti pazljiv sa njihovim diranjem
   AAdd( aDBf, { 'IDVD', 'C',   2,  0 } )
   AAdd( aDBf, { 'BRDOK', 'C',   8,  0 } )
   AAdd( aDBf, { 'DATDOK', 'D',   8,  0 } )

   AAdd( aDBf, { 'BRFAKTP', 'C',  10,  0 } )
   AAdd( aDBf, { 'DATFAKTP', 'D',   8,  0 } )

   AAdd( aDBf, { 'IDPARTNER', 'C',   6,  0 } )

   AAdd( aDBf, { 'RBR', 'C',   3,  0 } )
   AAdd( aDBf, { 'PODBR', 'C',   2,  0 } )

   AAdd( aDBf, { 'TPREVOZ', 'C',   1,  0 } )
   AAdd( aDBf, { 'TPREVOZ2', 'C',   1,  0 } )
   AAdd( aDBf, { 'TBANKTR', 'C',   1,  0 } )
   AAdd( aDBf, { 'TSPEDTR', 'C',   1,  0 } )
   AAdd( aDBf, { 'TCARDAZ', 'C',   1,  0 } )
   AAdd( aDBf, { 'TZAVTR', 'C',   1,  0 } )
   AAdd( aDBf, { 'TRABAT', 'C',   1,  0 } )
   AAdd( aDBf, { 'TMARZA', 'C',   1,  0 } )
   AAdd( aDBf, { 'TMARZA2', 'C',   1,  0 } )

   AAdd( aDBf, { 'NC', 'B',  8,  8 } )
   AAdd( aDBf, { 'MPC', 'B',  8,  8 } )

   // currency tip
   AAdd( aDBf, { 'VPC', 'B',  8,  8 } )
   AAdd( aDBf, { 'MPCSAPP', 'B',  8,  8 } )

   AAdd( aDBf, { 'IDTARIFA', 'C',   6,  0 } )
   AAdd( aDBf, { 'MKONTO', 'C',   7,  0 } )
   AAdd( aDBf, { 'PKONTO', 'C',   7,  0 } )


   AAdd( aDBf, { 'MU_I', 'C',   1,  0 } )
   AAdd( aDBf, { 'PU_I', 'C',   1,  0 } )
   AAdd( aDBf, { 'ERROR', 'C',   1,  0 } )

   AAdd( aDBf, { 'KOLICINA', 'B',  8,  8 } )
   AAdd( aDBf, { 'GKOLICINA', 'B',  8,  8 } )
   AAdd( aDBf, { 'GKOLICIN2', 'B',  8,  8 } )
   AAdd( aDBf, { 'FCJ', 'B',  8,  8 } )
   AAdd( aDBf, { 'FCJ2', 'B',  8,  8 } )
   AAdd( aDBf, { 'FCJ3', 'B',  8,  8 } )
   AAdd( aDBf, { 'RABAT', 'B',  8,  8 } )
   AAdd( aDBf, { 'PREVOZ', 'B',  8,  8 } )
   AAdd( aDBf, { 'BANKTR', 'B',  8,  8 } )
   AAdd( aDBf, { 'SPEDTR', 'B',  8,  8 } )
   AAdd( aDBf, { 'PREVOZ2', 'B',  8,  8 } )
   AAdd( aDBf, { 'CARDAZ', 'B',  8,  8 } )
   AAdd( aDBf, { 'ZAVTR', 'B',  8,  8 } )
   AAdd( aDBf, { 'MARZA', 'B',  8,  8 } )
   AAdd( aDBf, { 'MARZA2', 'B',  8,  8 } )
   AAdd( aDBf, { 'RABATV', 'B',  8,  8 } )
   AAdd( aDBf, { 'VPCSAP', 'B',  8,  8 } )




   _alias := "KALK"
   _table_name := "kalk_kalk"

   IF_NOT_FILE_DBF_CREATE

   // 0.8.4
   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 00804
      FOR EACH _tbl in { _table_name, "_kalk_kalk", "kalk_pripr", "kalk_pripr2", "kalk_pripr9" }
         modstru( { "*" + _tbl, ;
            "C KOLICINA N 12 3  KOLICINA B 8 8", ;
            "C GKOLICINA N 12 3 GKOLICINA B 8 8", ;
            "C GKOLICIN2 N 12 3 GKOLICIN2 B 8 8", ;
            "C FCJ N 18 8 FCJ B 8 8", ;
            "C FCJ2 N 18 8 FCJ2 B 8 8", ;
            "C FCJ3 N 18 8 FCJ3 B 8 8", ;
            "C RABAT N 18 8 RABAT B 8 8", ;
            "C PREVOZ N 18 8 PREVOZ B 8 8", ;
            "C PREVOZ2 N 18 8 PREVOZ2 B 8 8", ;
            "C BANKTR N 18 8 BANKTR B 8 8", ;
            "C SPEDTR N 18 8 SPEDTR B 8 8", ;
            "C CARDAZ N 18 8 CARDAZ B 8 8", ;
            "C ZAVTR N 18 8 ZAVTR B 8 8",  ;
            "C MARZA N 18 8 MARZA B 8 8", ;
            "C MARZA2 N 18 8 MARZA2 B 8 8", ;
            "C RABATV N 18 8 RABATV B 8 8", ;
            "C VPCSAP N 18 8 VPCSAP B 8 8", ;
            "C VPC N 18 8 VPC Y 8 4", ;
            "C MPCSAPP N 18 8 MPCSAPP Y 8 4", ;
            "C NC N 18 8 NC B 8 8", ;
            "C MPC N 18 8 MPC B 8 8", ;
            "D ROKTR D 8 0", ;
            "D DATKURS D 8 0" ;
            } )
      NEXT
   ENDIF


   // 0.8.5
   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 00805
      FOR EACH _tbl in { _table_name, "_kalk_kalk", "kalk_pripr", "kalk_pripr2", "kalk_pripr9" }
         modstru( { "*" + _tbl, ;
            "C VPC Y 8 4 VPC B 8 8", ;
            "C MPCSAPP Y 8 4 MPCSAPP B 8 8" ;
            } )
      NEXT
   ENDIF

   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "1", "idFirma+IdVD+BrDok+RBr", _alias )
   CREATE_INDEX( "2", "idFirma+idvd+brdok+IDTarifa", _alias )
   CREATE_INDEX( "3", "idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD", _alias )
   CREATE_INDEX( "4", "idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD", _alias )
   CREATE_INDEX( "5", "idFirma+dtos(datdok)+podbr+idvd+brdok", _alias )
   CREATE_INDEX( "6", "idFirma+IdTarifa+idroba", _alias )
   CREATE_INDEX( "7", "idroba+idvd", _alias )
   CREATE_INDEX( "8", "mkonto", _alias )
   CREATE_INDEX( "9", "pkonto", _alias )
   CREATE_INDEX( "DAT", "datdok", _alias )
   CREATE_INDEX( "MU_I", "mu_i+mkonto+idfirma+idvd+brdok", _alias )
   CREATE_INDEX( "MU_I2", "mu_i+idfirma+idvd+brdok", _alias )
   CREATE_INDEX( "PU_I", "pu_i+pkonto+idfirma+idvd+brdok", _alias )
   CREATE_INDEX( "PU_I2", "pu_i+idfirma+idvd+brdok", _alias )
   CREATE_INDEX( "PMAG", "idfirma+mkonto+idpartner+idvd+dtos(datdok)", _alias )

   // objekti
   _alias := "OBJEKTI"
   _table_name := "objekti"

   aDbf:={}
   AADD(aDbf, {"id","C",2,0})
   AADD(aDbf, {"naz","C",10,0})
   AADD(aDbf, {"IdObj","C", 7,0})

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX("ID", "ID", _alias )
   CREATE_INDEX("NAZ", "NAZ", _alias )
   CREATE_INDEX("IdObj", "IdObj", _alias )

   // pobjekti

   _alias := "POBJEKTI"
   _table := "pobjekti"

   aDbf:={}
   AADD(aDbf, {"id","C",2,0})
   AADD(aDbf, {"naz","C",10,0})
   AADD(aDbf, {"idobj","C", 7,0})
   AADD(aDbf, {"zalt","N", 18, 5})
   AADD(aDbf, {"zaltu","N", 18, 5})
   AADD(aDbf, {"zalu","N", 18, 5})
   AADD(aDbf, {"zalg","N", 18, 5})
   AADD(aDbf, {"prodt","N", 18, 5})
   AADD(aDbf, {"prodtu","N", 18, 5})
   AADD(aDbf, {"prodg","N", 18, 5})
   AADD(aDbf, {"produ","N", 18, 5})

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )


   // KALK_PRIPR

   _alias := "KALK_PRIPR"
   _table_name := "kalk_pripr"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "1", "idFirma+IdVD+BrDok+RBr", _alias )
   CREATE_INDEX( "2", "idFirma+idvd+brdok+IDTarifa", _alias )
   CREATE_INDEX( "3", "idFirma+idvd+brdok+idroba+rbr", _alias )
   CREATE_INDEX( "4", "idFirma+idvd+idroba", _alias )
   CREATE_INDEX( "5", "idFirma+idvd+idroba+STR(mpcsapp,12,2)", _alias )

   // KALK_PRIPR2

   _alias := "KALK_PRIPR2"
   _table_name := "kalk_pripr2"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "1", "idFirma+IdVD+BrDok+RBr", _alias )
   CREATE_INDEX( "2", "idFirma+idvd+brdok+IDTarifa", _alias )

   // KALK_PRIPR2

   _alias := "KALK_PRIPR9"
   _table_name := "kalk_pripr9"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "1", "idFirma+IdVD+BrDok+RBr", _alias )
   CREATE_INDEX( "2", "idFirma+idvd+brdok+IDTarifa", _alias )
   CREATE_INDEX( "3", "dtos(datdok)+mu_i+pu_i", _alias )


   // _KALK

   _alias := "_KALK"
   _table_name := "_kalk"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "1", "idFirma+IdVD+BrDok+RBr", _alias )

   // kalk_doks2
   aDbf := {}
   AAdd( aDBf, { 'IDFIRMA', 'C',   2,  0 } )
   AAdd( aDBf, { 'IDvd', 'C',   2,  0 } )
   AAdd( aDBf, { 'BRDOK', 'C',   8,  0 } )
   AAdd( aDBf, { 'DATVAL', 'D',   8,  0 } )
   AAdd( aDBf, { 'Opis', 'C',  20,  0 } )
   AAdd( aDBf, { 'K1', 'C',  1,  0 } )
   AAdd( aDBf, { 'K2', 'C',  2,  0 } )
   AAdd( aDBf, { 'K3', 'C',  3,  0 } )

   _alias := "KALK_DOKS2"
   _table_name := "kalk_doks2"

   IF_NOT_FILE_DBF_CREATE

   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "1", "IdFirma+idvd+brdok", _alias )


   F18_DOK_ATRIB():new( "kalk", F_KALK_ATRIB ):create_local_atrib_table()

   RETURN .T.
