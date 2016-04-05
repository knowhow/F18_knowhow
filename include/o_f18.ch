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

#xcommand O_SIFK     => o_sifk()
#xcommand O_SIFV     => o_sifv()

#xcommand O_ROBA     => select (F_ROBA)    ;  my_use  ("roba")      ; set order to tag "ID"
#xcommand O_ROBA_NOT_USED  => select (F_ROBA) ;  IF !USED(); my_use("roba" ); ENDIF  ; set order to tag "ID"

#xcommand O_BARKOD   => select (F_BARKOD)  ;  my_use  ("barkod")    ; set order to tag "1"

#xcommand O_KONTO    => select (F_KONTO)   ;  my_use  ("konto" )    ; set order to tag "ID"
#xcommand O_KONTO_NOT_USED  => select (F_KONTO) ;  IF !USED(); my_use("konto" ); ENDIF  ; set order to tag "ID"

#xcommand O_PARTN    => select (F_PARTN)   ;  my_use  ("partn")     ; set order to tag "ID"
#xcommand O_PARTN_NOT_USED  => select (F_PARTN) ;  IF !USED(); my_use("partn" ); ENDIF  ; set order to tag "ID"

#xcommand O_SAST     => select (F_SAST)    ;  my_use  ("sast")      ; set order to tag "ID"

#xcommand O_TARIFA   => o_tarifa()
#xcommand O_TRFP     => select (F_TRFP)    ;  use_sql_trfp()      ; set order to tag "ID"
#xcommand O_TRFP2    => select (F_TRFP2)   ;  use_sql_trfp2()     ; set order to tag "ID"
#xcommand O_TRFP3    => select (F_TRFP3)   ;  use_sql_sif  ("trfp3")     ; set order to tag "ID"
#xcommand O_TRMP     => select (F_TRMP)    ;  use_sql_sif  ("trmp")      ; set order to tag "ID"
#xcommand O_TNAL     => select (F_TNAL)    ;  use_sql_sif  ( "tnal" )  ; set order to tag "ID"
#xcommand O_TDOK     => select (F_TDOK)    ;  use_sql_sif  ( "tdok" )  ; set order to tag "ID"
#xcommand O_KONCIJ   => select (F_KONCIJ)  ;  use_sql_sif  ("koncij")  ; set order to tag "ID"
#xcommand O_VALUTE   => select (F_VALUTE)  ;  use_sql_valute()    ; set order to tag "ID"
#xcommand O_REFER    => select (F_REFER)   ;  use_sql_sif  ("refer" )     ; set order to tag "ID"
#xcommand O_OPS      => select (F_OPS)     ;  use_sql_opstine()      ; set order to tag "ID"
#xcommand O_FAKT_OBJEKTI  => select (F_FAKT_OBJEKTI) ;  use_sql_sif ( "fakt_objekti" ) ; set order to tag "ID"

#xcommand O_LOKAL    => select (F_LOKAL)   ;  use_sql_lokalizacija()
#xcommand O_RJ       => select (F_RJ)      ;  use_sql_rj()        ; set order to tag "ID"
#xcommand O_VRSTEP   => o_vrste_placanja()
#xcommand O_PKONTO   => select (F_PKONTO); use_sql_pkonto()  ; set order to tag "ID"
#xcommand O_KS       => select (F_KS);     use_sql_ks() ; set order to tag "ID"
#xcommand O_BANKE    => select (F_BANKE)   ;  use_sql_sif  ("banke")     ; set order to tag "ID"

#xcommand O__ROBA    => select (F__ROBA)   ;  my_usex("_roba")
#xcommand O__PARTN   => select (F__PARTN)  ;  my_use  ("_partn")

#xcommand O_RELAC    => o_relac()
#xcommand O_VOZILA   => SELECT (F_VOZILA)  ;  my_use  ("vozila")    ; set order to tag "ID"

#xcommand O_RELATION => SELECT (F_RELATION);  my_use ("relation")  ; set order to tag "1"
#xcommand O_FINMAT   => select (F_FINMAT)  ;  my_use ("finmat")    ; set order to tag "1"
#xcommand O_ULIMIT   => o_ulimit()
#xcommand O_TIPBL    => SELECT (F_TIPBL)   ;  my_use ("tipbl")      ; set order to tag "1"
#xcommand O_VRNAL    => o_vrnal()

// ugovori
#xcommand O_UGOV     => select(F_UGOV)     ;  my_use  ("ugov")      ; set order to tag "ID"
#xcommand O_RUGOV    => select(F_RUGOV)    ;  my_use  ("rugov")     ; set order to tag "ID"
#xcommand O_GEN_UG   => select(F_GEN_UG)   ;  my_use  ("gen_ug")    ; set order to tag "DAT_GEN"
#xcommand O_G_UG_P   => select(F_G_UG_P)   ;  my_use  ("gen_ug_p")  ; set order to tag "DAT_GEN"

// grupe i karakteristike
#xcommand O_STRINGS  => select(F_STRINGS)  ;  my_use ("strings")   ; set order to tag "1"

// temp tabela za izvjestaje
#xcommand O_R_EXP    => select (F_R_EXP)   ; my_usex ( "r_export" )
#xcommand O_TEMP     => select (F_TEMP)    ; my_usex ("temp")


// fmk rules
#xcommand O_RULES  => select (F_RULES); use_sql_rules() ; set order to tag "2"

// tabele DOK_SRC
#xcommand O_DOKSRC    => SELECT (F_DOKSRC)  ; my_use ("doksrc")    ; set order to tag "1"
#xcommand O_P_DOKSRC  => SELECT (F_P_DOKSRC); my_usex ("p_doksrc")  ; set order to tag "1"

// stampa PDV racuna
#xcommand O_DRN       => select(F_DRN)      ; my_use ("drn")      ; set order to tag "1"
#xcommand O_RN        => select(F_RN)       ; my_use ("rn")       ; set order to tag "1"
#xcommand O_DRNTEXT   => select(F_DRNTEXT)  ; my_use ("drntext")  ; set order to tag "1"

// tabele provjere integriteta
#xcommand O_DINTEG1 => SELECT (F_DINTEG1)   ; my_usex ("dinteg1")  ; set order to tag "1"
#xcommand O_DINTEG2 => SELECT (F_DINTEG2)   ; my_usex ("dinteg2")  ; set order to tag "1"
#xcommand O_INTEG1  => SELECT (F_INTEG1)    ; my_usex ("integ1")   ; set order to tag "1"
#xcommand O_INTEG2  => SELECT (F_INTEG2)    ; my_usex ("integ2")   ; set order to tag "1"
#xcommand O_ERRORS  => SELECT (F_ERRORS)    ; my_usex ("errors")   ; set order to tag "1"

// modul FIN
#xcommand O_FIN_PRIPR    => select (F_FIN_PRIPR);  my_use ("fin_pripr", NIL, .F.) ; set order to tag "1"

#xcommand O_PNALOG       => select (F_PNALOG);     my_usex ( "pnalog" )    ; set order to tag "1"
#xcommand O_PSUBAN       => select (F_PSUBAN);     my_usex ( "psuban" )    ; set order to tag "1"
#xcommand O_PANAL        => select (F_PANAL);      my_usex ( "panal" )     ; set order to tag "1"
#xcommand O_PSINT        => select (F_PSINT);      my_usex ( "psint" )     ; set order to tag "1"

#xcommand O_KAM_PRIPR    => select (F_KAMPRIPR);  my_use ("kam_pripr") ; set order to tag "1"
#xcommand O_KAM_KAMAT    => select (F_KAMAT);  my_use ("kam_kamat") ; set order to tag "1"

#xcommand O_KOMP_DUG    => select (F_FIN_KOMP_DUG);  my_use ("komp_dug")
#xcommand O_KOMP_POT    => select (F_FIN_KOMP_POT);  my_use ("komp_pot")

#xcommand O_SUBAN     => SELECT (F_SUBAN);    my_use("suban")     ; set order to tag "1"
#xcommand O_ANAL      => SELECT (F_ANAL);     my_use("anal")      ; set order to tag "1"
#xcommand O_NALOG     => SELECT (F_NALOG);    my_use("nalog")     ; set order to tag "1"
#xcommand O_SINT      => SELECT (F_SINT);     my_use("sint")      ; set order to tag "1"
#xcommand O_RSUBAN    => select (F_SUBAN);    my_usex("suban")    ; set order to tag "1"
#xcommand O_RANAL     => select (F_ANAL);     my_usex("anal")     ; set order to tag "1"
#xcommand O_SINTSUB   => select (F_SUBAN);    my_use("suban")     ; set order to tag "1"
#xcommand O_BUDZET    => select (F_BUDZET);   my_use("budzet")    ; set order to tag "1"
#xcommand O_PAREK     => select (F_PAREK);    my_use("parek")     ; set order to tag "1"
#xcommand O_BBKLAS    => select (F_BBKLAS);   my_use("bbklas")    ; set order to tag "1"
#xcommand O_IOS       => select (F_IOS);      my_use("ios")      ; set order to tag "1"

#xcommand O_FUNK   => o_funk()
#xcommand O_FOND   => o_fond()
#xcommand O_BUIZ   => select (F_BUIZ);    MY_USE  ("buiz") ; set order to tag "ID"
#xcommand OX_KONTO    => select (F_KONTO);  my_usex ("konto")  ;  set order to tag "ID"
#xcommand O_RKONTO    => select (F_KONTO);  my_usex ("konto") ; set order to tag "ID"
#xcommand OX_PARTN    => select (F_PARTN);  my_usex ("partn") ; set order to tag "ID"
#xcommand O_RPARTN    => select (F_PARTN);  my_usex ("partn") ; set order to tag "ID"
#xcommand OX_TNAL    => select (F_TNAL);  my_usex ("tnal")      ; set order to tag "ID"
#xcommand OX_TDOK    => select (F_TDOK);  my_usex ("tdok")      ; set order to tag "ID"
#xcommand OX_PKONTO   => select (F_PKONTO); my_use  ("pkonto")  ; set order to tag "ID"
#xcommand OX_VALUTE   => select(F_VALUTE);  my_usex  ("valute")  ; set order to tag "ID"
#xcommand O__KONTO => select(F__KONTO); MY_USE  ("_konto")
#xcommand O__PARTN => select(F__PARTN); MY_USE  ("_partn")
#xcommand O_PRENHH   => select(F_PRENHH); my_usex ("prenhh"); set order to tag "1"
#xcommand O_OSTAV   => o_ostav()


// modul KALK
#xcommand O_KALK_PRIPR    => o_kalk_pripr()
#xcommand O_KALK_S_PRIPR  => select(F_KALK_PRIPR); my_usex ( "kalk_pripr") ; set order to tag "1"
#xcommand O_KALK_PRIPR2   => select(F_KALK_PRIPR2); my_use ("kalk_pripr2") ; set order to tag "1"
#xcommand O_KALK_PRIPR9   => select(F_KALK_PRIPR9); my_use ("kalk_pripr9") ; set order to tag "1"
#xcommand O_KALK_KARTICA  => select(F_KALK_KARTICA); my_use ( "kalk_kartica" ) ; set order to tag "ID"
#xcommand O__KALK         => select(F__KALK); my_usex ("_kalk" )
#xcommand O_KALK_FINMAT   => select(F_KALK_FINMAT); my_usex ("kalk_finmat")    ; set order to tag "1"
#xcommand O_KALK          => select(F_KALK);  my_use  ("kalk")  ; set order to tag "1"
#xcommand O_KALKSEZ       => select(F_KALKSEZ);  my_use  ("KALK")  ; set order to "1"
#xcommand O_ROBASEZ       => select(F_ROBASEZ);  my_use  ("ROBA")  ; set order to tag "ID"
#xcommand O_KALKX         => select(F_KALK);  usex  (KUMPATH +"kalk")  ; set order to tag "1"
#xcommand O_KALKS         => select(F_KALKS);  my_use  ("kalks")  ; set order to tag "1"
#xcommand O_KALKREP => if gKalks; select(F_KALK); use; select(F_KALK) ; my_use  ("kalks", "KALK") ; set order to tag "1";else; select(F_KALK);  my_use  ("KALK")  ; set order to tag "1"; end
#xcommand O_SKALK          => select(F_KALK);  my_use( "kalk_pripr", "kalk_kalk" ) ; set order to tag "1"
#xcommand O_KALK_DOKS      => select(F_KALK_DOKS);  my_use( "kalk_doks") ; set order to tag "1"
#xcommand O_KALK_DOKS2     => select(F_KALK_DOKS2);  my_use( "kalk_doks2" ) ; set order to tag "1"
#xcommand O_PORMP          => select(F_PORMP); usex ("pormp")     ; set order to tag "1"
#xcommand O_PRODNC         => select(F_PRODNC);  my_use  ("prodnc")  ; set order to tag "PRODROBA"
#xcommand O_RVRSTA         => select(F_RVRSTA);  my_use  ("rvrsta")  ; set order to tag "ID"

#xcommand O_K1             => select(F_ROBASEZ)  ;  my_use  ("k1")       ; set order to tag "1"
#xcommand O_OBJEKTI        => select(F_OBJEKTI)  ;  my_use  ("objekti")  ; set order to tag "1"
#xcommand O_REKAP1         => select(F_REKAP1)   ;  my_use  ("rekap1")   ; set order to tag "1"
#xcommand O_REKAP2         => select(F_REKAP2)   ;  my_use  ("rekap2")   ; set order to tag "1"
#xcommand O_REKA22         => select(F_REKA22)   ;  my_use  ("reka22")   ; set order to tag "1"
#xcommand O_R_UIO          => select(F_R_UIO)    ;  my_use  ("r_uio")
#xcommand O_RPT_TMP        => select(F_RPT_TMP)  ;  my_use  ("rpt_tmp")


// modul FAKT
#xcommand O_FAKT           => o_fakt()
#xcommand O_FAKT_DOKS      => o_fakt_doks()


#xcommand O_FAKT_DOKS2     => select(F_FAKT_DOKS2) ; my_use ( "fakt_doks2" )  ; set order to tag "1"

// fakt pripr
#xcommand O_FAKT_PRIPR     => select (F_FAKT_PRIPR)     ; my_use ("fakt_pripr", NIL, .F.)   ; set order to tag "1"
#xcommand O_FAKT_PRIPRRP   => select (F_FAKT_PRIPR)     ; my_use ("fakt_pripr")   ; set order to tag  "1"
#xcommand O_FAKT_S_PRIPR   => select (F_FAKT_PRIPR)     ; my_use ("fakt_pripr")   ; set order to "1"

// fakt tmp
#xcommand O__FAKT          => select(F__FAKT)      ; my_use ("_fakt")
#xcommand O_FAKT_PRIPR9    => select (F_PRIPR9)    ; my_use  ("fakt_pripr9") ; set order to tag  "1"
#xcommand O_FAKT_ATRIB     => select (F_FAKT_ATRIB) ; my_use ("fakt_atrib") ; set order to tag  "1"
#xcommand O_KALK_ATRIB     => select (F_KALK_ATRIB) ; my_use ("kalk_atrib") ; set order to tag  "1"

#xcommand O__SDIM          => select(F__SDIM)      ; my_use ("_sdim"); set order to tag "1"

#xcommand O_PFAKT          => select (F_FAKT)      ; my_use  ("fakt_pripr", "fakt_fakt", .f.); set order to tag "1"
#xcommand O_POMGN          => select (F_POMGN)     ; my_use  ("pomgn"); set order to tag "4"
#xcommand O_POM            => select (F_POM)       ; my_usex ("pom")
#xcommand O_SDIM           => select (F_SDIM)      ; my_use  ("sdim"); set order to tag "1"
#xcommand O_KALPOS         => SELECT (F_KALPOS)    ; my_use  ("kalpos"); set order to tag "1"
#xcommand O_CROBA          => SELECT (F_CROBA)     ; my_use  ("croba"); set order to tag "IDROBA"

#xcommand O_FADO           => select (F_FADO)      ; my_use  ("fado")    ; set order to tag "ID"
#xcommand O_FADE           => select (F_FADE)      ; my_use  ("fade")    ; set order to tag "ID"

#xcommand O_FTXT           => select (F_FTXT)      ; my_use  ("ftxt")    ; set order to tag "ID"
#xcommand O_POR            => select (F_FTXT)      ; my_use  ("por")
#xcommand O_UPL            => select (F_UPL)       ; my_usex  ("upl")      ; set order to tag "1"
#xcommand O_DEST           => select (F_DEST)      ; my_use  ("dest")     ; set order to tag "ID"
#xcommand O_DOKSTXT        => select (F_DOKSTXT)   ; my_use  ("dokstxt") ; set order to tag "ID"

// modul RNAL
#xcommand O__DOCS => select (F__DOCS); my_use ("_docs"); set order to tag "1"
#xcommand O__DOC_IT => select (F__DOC_IT); my_use ("_doc_it"); set order to tag "1"
#xcommand O__DOC_IT2 => select (F__DOC_IT2); my_use ("_doc_it2"); set order to tag "1"
#xcommand O__DOC_OPS => select (F__DOC_OPS); my_use ("_doc_ops"); set order to tag "1"
#xcommand O__DOC_OPST => select (F__DOC_OPST); my_use ("_doc_opst"); set order to tag "1"
#xcommand O_T_DOCIT => select (F_T_DOCIT); my_use ("t_docit"); set order to tag "1"
#xcommand O_T_DOCIT2 => select (F_T_DOCIT2); my_use ("t_docit2"); set order to tag "1"
#xcommand O_T_DOCOP => select (F_T_DOCOP); my_use ("t_docop"); set order to tag "1"
#xcommand O_T_PARS => my_use ("t_pars"); set order to tag "id_par"
#xcommand O__TMP1 => select (F__TMP1); my_use ("_tmp1"); set order to tag "1"
#xcommand O__TMP2 => select (F__TMP2); my_use ("_tmp2"); set order to tag "1"

#xcommand O_DOCS => select (F_DOCS); my_use ("docs"); set order to tag "1"
#xcommand O_DOC_IT => select (F_DOC_IT); my_use ("doc_it"); set order to tag "1"
#xcommand O_DOC_IT2 => select (F_DOC_IT2); my_use ("doc_it2"); set order to tag "1"
#xcommand O_DOC_OPS => select (F_DOC_OPS); my_use ("doc_ops"); set order to tag "1"
#xcommand O_E_GROUPS => select_o_dbf_e_groups()
#xcommand O_CUSTOMS => select(F_CUSTOMS); my_use ("customs"); set order to tag "1"
#xcommand O_OBJECTS => select(F_OBJECTS); my_use ("objects"); set order to tag "1"
#xcommand O_CONTACTS => select(F_CONTACTS); my_use ("contacts"); set order to tag "1"

#xcommand O_E_GR_ATT => select_o_dbf_e_gr_att()
#xcommand O_E_GR_VAL => select_o_dbf_e_gr_val()
#xcommand O_AOPS => select_o_dbf_aops()
#xcommand O_AOPS_ATT => select_o_dbf_aops_att()
#xcommand O_ARTICLES => select_o_dbf_articles()
#xcommand O_ELEMENTS => select_o_dbf_elements()
#xcommand O_E_AOPS => select_o_dbf_e_aops()
#xcommand O_E_ATT => select_o_dbf_e_att()
#xcommand O_RAL => use_sql_rnal_ral()

// modul EPDV
#xcommand O_P_KUF     => select (F_P_KUF);   my_usex ("p_kuf") ; set order to tag "r_br"
#xcommand O_P_KIF     => select (F_P_KIF);   my_usex ("p_kif") ; set order to tag "r_br"
#xcommand O_KUF     => select (F_KUF);   my_use ("kuf") ; set order to tag "datum"
#xcommand O_KIF     => select (F_KIF);   my_use ("kif") ; set order to tag "datum"
#xcommand O_PDV     => select (F_PDV);   my_use ("pdv") ; set order to tag "datum"
#xcommand O_SG_KIF   => select(F_SG_KIF);  my_usex  ("sg_kif")  ; set order to tag "ID"
#xcommand O_SG_KUF   => select(F_SG_KUF);  my_usex  ("sg_kuf")  ; set order to tag "ID"
#xcommand O_R_KUF   => select(F_R_KUF);  my_usex  ("r_kuf")
#xcommand O_R_KIF   => select(F_R_KIF);  my_usex  ("r_kif")
#xcommand O_R_PDV   => select(F_R_PDV);  my_usex  ("r_pdv")

// modul LD
#xcommand O_RADN    => select (F_RADN)    ;  my_use ("radn")     ; set order to tag "1"
#xcommand O_RADN_NOT_USED  => select (F_RADN) ;  IF !USED(); my_use( "radn" ); ENDIF  ; set order to tag "1"

#xcommand O_LD_RJ   => open_ld_rj()
#xcommand O_LD_RJ_NOT_USED   => select (F_LD_RJ)   ; IF !Used();  my_use ("ld_rj") ; ENDIF;   ; set order to tag "ID"

#xcommand O__RADN   => select (F__RADN)   ;  my_use ("_radn")
#xcommand O_TPRSIHT => select (F_TPRSIHT) ;  my_use ("tprsiht")  ; set order to tag "ID"
#xcommand O_NORSIHT => select (F_NORSIHT) ;  my_use ("norsiht")  ; set order to tag "ID"
#xcommand O_RADSIHT => select (F_RADSIHT) ;  my_use ("radsiht")  ; set order to tag "1"
#xcommand O_RADKR   => select (F_RADKR)   ;  my_use ("radkr")    ; set order to tag "1"
#xcommand O_RADKRX  => select (F_RADKR)   ;  my_use ("radkr")    ; set order to tag "0"
#xcommand O__RADKR  => select (F__RADKR)  ;  my_use ("_radkr")
#xcommand O_LD      => select (F_LD)      ;  my_use ("ld")       ; set order to tag "1"
#xcommand O_LDX     => select (F_LD)      ;  my_use ("ld")       ; set order to tag "1"
#xcommand O__LD     => select (F__LD)     ;  my_use ("_ld")
#xcommand O_LDSM    => select (F_LDSM)    ;  my_use ("ldsm")     ; set order to tag "1"
#xcommand O_LDSMX   => select (F_LDSM)    ;  my_use ("ldsm")     ; set order to tag "0"
#xcommand O_OPSLD   => select (F_OPSLD)   ;  my_usex ("opsld")    ; set order to tag "1"
#xcommand O_REKLD0  => select (F_REKLD)   ;  my_usex ("rekld")
#xcommand O_REKLD   => select (F_REKLD)   ;  my_usex ("rekld")   ; set order to tag "1"
#xcommand O_REKLDP  => select (F_REKLDP)  ;  my_usex ("rekldp")  ; set order to tag "1"

#xcommand O_KBENEF  => select (F_KBENEF)  ;  my_use ("kbenef")   ; set order to tag "ID"
#xcommand O_POR     => select (F_POR)     ;  my_use ("por")      ; set order to tag "ID"
#xcommand O_DOPR    => select (F_DOPR)    ;  my_use ("dopr")     ; set order to tag "ID"
#xcommand O_KRED    => select (F_KRED)    ;  my_use ("kred")     ; set order to tag "ID"
#xcommand O__KRED   => select (F__KRED)   ;  my_use ("_kred")    ; set order to tag "ID"
#xcommand O_STRSPR  => select (F_STRSPR)  ;  my_use ("strspr")   ; set order to tag "ID"
#xcommand O_VPOSLA  => select (F_VPOSLA)  ;  my_use  ("vposla")  ; set order to tag "ID"
#xcommand O_PAROBR  => select (F_PAROBR)  ;  my_use ("parobr")   ; set order to tag "ID"
#xcommand O_TIPPR   => select (F_TIPPR)   ;  my_use ("tippr")    ; set order to tag "ID"
#xcommand O_TIPPR2  => select (F_TIPPR2)  ;  my_use ("tippr2")   ; set order to tag "ID"
#xcommand O_OBRACUNI => select (F_OBRACUNI) ; my_use("obracuni"); set order to tag "RJ"
#xcommand O_RADSAT  => select (F_RADSAT)  ; my_use ("radsat")    ; set order to tag "IDRADN"
#xcommand O_PK_RADN => select (F_PK_RADN)  ; my_use ("pk_radn")   ; set order to tag "1"
#xcommand O_PK_DATA => select (F_PK_DATA)  ; my_use ("pk_data")   ; set order to tag "1"

#xcommand O_LDT22 => select (F_LDT22)  ; my_use ("LDT22")        ; set order to tag "1"

#xcommand O_TIPPRN  => IF cObracun <> "1" .and. !EMPTY( cObracun );
                      ;  select (F_TIPPR2)                  ;
                      ;  my_use ("tippr", "tippr2")   ;
                      ;  set order to tag "ID"              ;
                      ;ELSE                                 ;
                      ;  select (F_TIPPR)                   ;
                      ;  my_use ("tippr")              ;
                      ;  set order to tag "ID"              ;
                      ;ENDIF

// modul OS
#xcommand O_OS => select (F_OS) ; my_use ( "os" ) ;  set order to tag "1"
#xcommand O_SII => select (F_SII) ; my_use ( "sii" ) ; set order to tag "1"
#xcommand O_PROMJ => select (F_PROMJ) ; my_use ( "promj" ) ; set order to tag "1"
#xcommand O_SII_PROMJ => select (F_SII_PROMJ) ; my_use ( "sii_promj" ) ; set order to tag "1"
#xcommand O_INVENT       => select (F_INVENT)  ; my_use ("invent") ; set order to tag "1"
#xcommand O_AMORT        => select (F_AMORT)   ; my_use ("amort")  ; set order to tag "ID"
#xcommand O_REVAL        => select (F_REVAL)   ; my_use ("reval")  ; set order to tag "ID"
#xcommand O_K1           => select (F_K1)      ; my_use ("k1")     ; set order to tag "ID"

// modul POS
#xcommand O_POS_DOKS  => o_pos_doks()
#xcommand O_POS       => o_pos_pos()
#xcommand O_RNGPLA    => SELECT (F_RNGPLA); my_use ("rngpla"); set order to tag "1"
#xcommand O_PROMVP    => SELECT (F_PROMVP); my_use ("promvp"); set order to tag "1"
#xcommand O__POS      => SELECT (F__POS)  ; my_use("_pos")  ; set order to tag "1"
#xcommand O__POS_PRIPR  => SELECT (F__PRIPR); my_use("_pos_pripr"); set order to tag "1"
#xcommand O_PRIPRZ    => SELECT (F_PRIPRZ); my_use("priprz"); set order to tag "1"
#xcommand O_PRIPRG    => SELECT (F_PRIPRG); my_use("priprg"); set order to tag "1"
#xcommand O__POSP     => select(F__POSP)  ; my_use("_posp")
#xcommand O__POS_DOKSP  => select(F__DOKSP) ; my_use("_pos_doksp")
#xcommand O_K2C       => SELECT (F_K2C)   ; my_use("k2c")   ; set order to tag "1"
#xcommand O_MJTRUR    => SELECT (F_MJTRUR); my_use("mjtrur"); set order to tag "1"
#xcommand O_ROBAIZ    => SELECT (F_ROBAIZ); my_use("robaiz"); set order to tag "1"
#xcommand O_RAZDR     => SELECT (F_RAZDR) ; my_use("razdr")
#xcommand O_STRAD     => o_pos_strad()
#xcommand O_OSOB      => o_pos_osob()
#xcommand O_KASE      => o_pos_kase()
#xcommand O_ODJ       => SELECT (F_ODJ); my_use("odj"); set order to tag "ID"
#xcommand O_DIO       => SELECT (F_DIO); my_use("dio"); set order to tag "ID"
#xcommand O_UREDJ     => SELECT (F_UREDJ); my_use("uredj"); set order to tag "ID"
#xcommand O_MARS      => SELECT (F_MARS); my_use("mars"); set order to tag "ID"
#xcommand O_DOKSPF    => select (F_DOKSPF); my_use ("dokspf"); set order to tag "1"

// modul MAT
#xcommand O_MAT_PRIPR    =>  select(F_MAT_PRIPR); my_use("mat_pripr") ; set order to tag "1"
#xcommand O_MAT_PRIPRRP  =>  select(F_MAT_PRIPR); my_use("mat_priprrp", "mat_pripr"); set order to tag "1"
#xcommand O_MAT_SUBAN    =>  select(F_MAT_SUBAN); my_use( "mat_suban" ); set order to tag "1"
#xcommand O_MAT_SUBANX   =>  select(F_MAT_SUBAN); my_use( "mat_suban" ); set order to tag "1"
#xcommand O_MAT_SUBAN2   =>  select(F_MAT_SUBAN); my_use( "mat_pripr", "mat_suban" ); set order to tag "4"
#xcommand O_MAT_ANAL     =>  select(F_MAT_ANAL); my_use( "mat_anal" ); set order to tag "1"
#xcommand O_MAT_SINT     =>  select(F_MAT_SINT); my_use( "mat_sint" ); set order to tag "1"
#xcommand O_MAT_NALOG    =>  select(F_MAT_NALOG); my_use( "mat_nalog" ); set order to tag "1"
#xcommand O_IZDEF        =>  select(F_IZDEF); my_use ( "izdef" ); set order to tag "1"
#xcommand O_IZOP         =>  select(F_IZOP ); my_use ( "izop" ); set order to tag "1"
#xcommand O_MAT_PNALOG   =>  select(F_MAT_PNALOG); my_use( "mat_pnalog" ); set order to tag "1"
#xcommand O_MAT_PSUBAN   =>  select(F_MAT_PSUBAN); my_use( "mat_psuban" ); set order to tag "1"
#xcommand O_MAT_PSUBAN2  =>  select(F_MAT_PSUBAN); my_use( "mat_suban", "mat_psuban" ); set order to tag "1"
#xcommand O_MAT_PANAL    =>  select(F_MAT_PANAL) ; my_use( "mat_panal") ; set order to tag "1"
#xcommand O_MAT_PANAL2   =>  select(F_MAT_PANAL) ; my_use( "mat_anal", "mat_panal"); set order to tag "1"
#xcommand O_MAT_PSINT    =>  select(F_MAT_PSINT) ; my_use( "mat_psint" ) ; set order to tag "1"
#xcommand O_MAT_INVENT   =>  select(F_MAT_INVENT); my_use( "mat_invent" ); set order to tag "1"
#xcommand O_KARKON       =>  select(F_KARKON); my_use ( "karkon" ); set order to tag "ID"

// modul VIRM
#xcommand O_VIRM_PRIPR   => select (F_VIPRIPR); my_use("virm_pripr") ; set order to tag "1"
#xcommand O_VRPRIM   => select (F_VRPRIM) ; my_use  ("vrprim") ; set order to tag "ID"
#xcommand O_VRPRIM2  => select (F_VRPRIM2); my_use  ("vrprim2") ; set order to tag "ID"
#xcommand O_LDVIRM   => select (F_LDVIRM) ; my_use ("ldvirm") ; set order to tag "ID"
#xcommand O_KALVIR   => select (F_KALVIR) ; my_use ("kalvir") ; set order to tag "ID"
#xcommand O_JPRIH   => select (F_JPRIH) ; my_use  ("jprih")  ; set order to tag "ID"
#xcommand O_IZLAZ   => select (F_IZLAZ) ; my_use ("izlaz") ; set order to tag "1"


// --------------------------------------------------------------------------------------
// legacy - izbaciti donje tabele
// --------------------------------------------------------------------------------------
#xcommand O_ADRES     => select (F_ADRES)     ; my_use ( "adres" )  ; set order to tag "ID"
#xcommand O_SQLPAR    => select (F_SQLPAR)    ; my_use ( "SQLPAR" )

// proizvoljni izvjestaji
#xcommand O_KONIZ  => select (F_KONIZ) ; my_use("koniz") ; set order to tag "ID"
#xcommand O_IZVJE  => select (F_IZVJE) ; my_use("izvje") ; set order to tag "ID"
#xcommand O_ZAGLI  => select (F_ZAGLI) ; my_use("zagli") ; set order to tag "ID"
#xcommand O_KOLIZ  => select (F_KOLIZ) ; my_use("koliz") ; set order to tag "ID"

// parametri
#xcommand O_PARAMS    => select (F_PARAMS)    ; my_use ( "params")   ; set order to tag  "ID"
#xcommand O_GPARAMS   => select (F_GPARAMS)   ; my_use ( "gparams" )  ;   set order to tag  "ID"
#xcommand O_GPARAMSP  => select (F_GPARAMSP)  ; my_use ( "gparams" )  ; set order to tag  "ID"
#xcommand O_MPARAMS   => select (F_MPARAMS)   ;  my_use ( "mparams" ) ; set order  to tag  "ID"
#xcommand O_KPARAMS   => select (F_KPARAMS)   ; my_use ( "kparams" )  ; set order to tag  "ID"
#xcommand O_SECUR     => select (F_SECUR)     ; my_use ( "secur" )    ; set order to tag "ID"

#xcommand O_LOGK     => select (F_LOGK)    ; my_use  ("logk")          ; set order to tag "NO"
#xcommand O_LOGKD    => select (F_LOGKD); my_use  ("logd")        ; set order to tag "NO"

// security system tabele
#xcommand O_EVENTS  => select (F_EVENTS); my_use ("events") ; set order to tag "ID"
#xcommand O_USERS  => select (F_USERS); my_use ("users") ; set order to tag "ID"
#xcommand O_GROUPS  => select (F_GROUPS); my_use ("groups") ; set order to tag "ID"

// sql messages
#define F_MSGNEW 234
#xcommand O_MESSAGE   => select(F_MESSAGE); my_usex ("message"); set order to tag "1"
#xcommand O_AMESSAGE   => select(F_AMESSAGE); my_usex ("amessage"); set order to tag "1"
#xcommand O_TMPMSG  => select(F_TMPMSG); my_use ("tmpmsg"); set order to tag "1"

#xcommand O_FIN_PRIPRRP   => select (F_FIN_PRIPR); my_usex("fin_priprrp", "fin_pripr"); set order to tag "1"

#xcommand O_KALKSEZ        => select(F_KALK);  my_use  ("kalk")  ; set order to tag "1"
#xcommand O_ROBASEZ        => select(F_ROBA);  my_use  ("roba")  ; set order to tag "ID"
#xcommand O_CACHE          => select(F_CACHE);  my_use  ("cache")  ; set order to tag "1"
#xcommand O_PRIPT          => select(F_PRIPT);  my_usex  ("pript", "kalk_pript")  ; set order to tag "1"

#xcommand O_POBJEKTI       => select(F_POBJEKTI);  my_use  ("pobjekti") ; set order to tag "1"
