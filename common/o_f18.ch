/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

// parametri
#xcommand O_PARAMS    => select (F_PARAMS);  my_use ( "params"); set order to tag  "ID"
#xcommand O_GPARAMS   => select (F_GPARAMS); my_use ( "gparams" )  ;   set order to tag  "ID"
#xcommand O_GPARAMSP  => select (F_GPARAMSP); my_use ( "gparams" )  ; set order to tag  "ID"
#xcommand O_MPARAMS   => select (F_MPARAMS);  my_use ( "mparams" )   ; set order  to tag  "ID"
#xcommand O_KPARAMS   => select (F_KPARAMS); my_use ( "kparams" ) ; set order to tag  "ID"
#xcommand O_SECUR     => select (F_SECUR); my_use ( "secur" )  ; set order to tag "ID"
#xcommand O_ADRES     => select (F_ADRES); my_use ( "adres" )  ; set order to tag "ID"
#xcommand O_SQLPAR    => select (F_SQLPAR); my_use ( ToUnix( KUMPATH + "SQL"+ SLASH + "SQLPAR" ) )

// sifk, sifv
#xcommand O_SIFK => select(F_SIFK);  my_use  ("sifk")     ; set order to tag "ID"
#xcommand O_SIFV => select(F_SIFV);  my_use  ("sifv")     ; set order to tag "ID"

// proizvoljni izvjestaji
#xcommand O_KONIZ  => select (F_KONIZ); my_use("koniz") ; set order to tag "ID"
#xcommand O_IZVJE  => select (F_IZVJE); my_use("izvje") ; set order to tag "ID"
#xcommand O_ZAGLI  => select (F_ZAGLI); my_use("zagli") ; set order to tag "ID"
#xcommand O_KOLIZ  => select (F_KOLIZ); my_use("koliz") ; set order to tag "ID"

// sifrarnici
#xcommand O_ROBA   => select(F_ROBA); my_use ("roba")  ; set order to tag "ID"
#xcommand O_TARIFA   => select(F_TARIFA); my_use  ( "tarifa" )  ; set order to tag "ID"
#xcommand O_KONTO   => select(F_KONTO); my_use  ( "konto" ) ; set order to tag "ID"
#xcommand O_TRFP    => select(F_TRFP); my_use  ( "trfp")       ; set order to tag "ID"
#xcommand O_TRFP2    => select(F_TRFP2);   MY_USE  (SIFPATH+"trfp2")       ; set order to tag "ID"
#xcommand O_TRFP3    => select(F_TRFP3);   MY_USE  (SIFPATH+"trfp3")       ; set order to tag "ID"
#xcommand O_TRMP    => select(F_TRMP); my_use  ( "trmp")       ; set order to tag "ID"
#xcommand O_PARTN   => select(F_PARTN); my_use  ( "partn")  ; set order to tag "ID"
#xcommand O_TNAL   => select(F_TNAL); my_use  ( "tnal" )         ; set order to tag "ID"
#xcommand O_TDOK   => select(F_TDOK); my_use  ( "tdok" )         ; set order to tag "ID"
#xcommand O_KONCIJ => select(F_KONCIJ); my_use  ( "koncij" )     ; set order to tag "ID"
#xcommand O_VALUTE => select(F_VALUTE); my_use  ( "valute" )     ; set order to tag "ID"
#xcommand O_SAST   => select (F_SAST); my_use  ( "sast" )         ; set order to tag "ID"
#xcommand O_REFER   => select(F_REFER);  my_use  ("refer")         ; set order to tag "ID"
#xcommand O_OPS   => select(F_OPS);  my_use  ( "ops" )         ; set order to tag "ID"
#xcommand O_RNAL  => select(F_RNAL);  my_use  ( "rnal" )      ; set order to tag "ID"
#xcommand O_FDEVICE  => select(F_FDEVICE);  my_use ("fdevice") ; set order to tag "1"
#xcommand O__ROBA   => select(F__ROBA);  my_use  ("_roba")
#xcommand O__PARTN   => select(F__PARTN);  my_use  ("_partn")
#xcommand O_BANKE   => select (F_BANKE) ; my_use ("banke")  ; set order to tag "ID"
#xcommand O_LOGK   => select (F_LOGK) ; my_use  ("logk")         ; set order to tag "NO"
#xcommand O_LOGKD  => select (F_LOGKD); my_use  ("logd")        ; set order to tag "NO"
#xcommand O_BARKOD  => select(F_BARKOD);  my_use ("barkod"); set order to tag "1"
#xcommand O_RJ   => select(F_RJ);  my_use  ("rj")         ; set order to tag "ID"
#xcommand O_VRSTEP => SELECT (F_VRSTEP); my_USE ("vrstep"); set order to tag "ID"
#xcommand O_RELAC  => SELECT (F_RELAC) ; my_USE ("relac"); set order to tag "ID"
#xcommand O_VOZILA => SELECT (F_VOZILA); my_USE ("vozila"); set order to tag "ID"
#xcommand O_ADRES     => select (F_ADRES); my_use (ToUnix("adres")) ; set order to tag "ID"
#xcommand O_RELATION => SELECT (F_RELATION); my_USE ("relation"); set order to tag "1"
#xcommand O_FINMAT  => select(F_FINMAT); usex ("finmat")    ; set order to tag "1"
#xcommand O_VPRIH => SELECT (F_VPRIH); MY_USE ("vrprih"); set order to tag "ID"
#xcommand O_ULIMIT => SELECT (F_ULIMIT); MY_USE ("ulimit"); set order to tag "ID"
#xcommand O_TIPBL => SELECT (F_TIPBL); MY_USE ("tipbl"); set order to tag "1"
#xcommand O_VRNAL => SELECT (F_VRNAL); MY_USE ("vrnal"); set order to tag "1"



// ugovori
#xcommand O_UGOV     => select(F_UGOV);  my_use  ( "ugov" )     ; set order to tag "ID"
#xcommand O_RUGOV    => select(F_RUGOV); my_use  ( "rugov" )   ; set order to tag "ID"
#xcommand O_GEN_UG   => select(F_GEN_UG);  my_use  ("gen_ug")  ; set order to tag "DAT_GEN"
#xcommand O_G_UG_P  => select(F_G_UG_P);  my_use  ("gen_ug_p")   ; set order to tag "DAT_GEN"

// lokalizacija
#xcommand O_LOKAL => select (F_LOKAL); my_use ("lokal")

// grupe i karakteristike
#xcommand O_STRINGS  => select(F_STRINGS);  my_use  (SIFPATH + "strings")   ; set order to tag "1"

// temp tabela za izvjestaje
#xcommand O_R_EXP => select (F_R_EXP); my_use ("r_export")
#xcommand O_TEMP => select (F_TEMP); my_use ("temp")


// fmk rules
#xcommand O_FMKRULES  => select (F_FMKRULES); my_use ("fmkrules") ; set order to tag "2"

// tabele DOK_SRC
#xcommand O_DOKSRC => SELECT (F_DOKSRC); my_USE ("doksrc"); set order to tag "1"
#xcommand O_P_DOKSRC => SELECT (F_P_DOKSRC); my_USE ("p_doksrc"); set order to tag "1"

// security system tabele
#xcommand O_EVENTS  => select (F_EVENTS); my_use ("events") ; set order to tag "ID"
#xcommand O_EVENTLOG  => select (F_EVENTLOG); my_use ("eventlog") ; set order to tag "ID"
#xcommand O_USERS  => select (F_USERS); my_use ("users") ; set order to tag "ID"
#xcommand O_GROUPS  => select (F_GROUPS); my_use ("groups") ; set order to tag "ID"
#xcommand O_RULES  => select (F_RULES); my_use ("rules") ; set order to tag "ID"

// stampa PDV racuna
#xcommand O_DRN => select(F_DRN); my_use ("drn"); set order to tag "1"
#xcommand O_RN => select(F_RN); my_use ("rn"); set order to tag "1"
#xcommand O_DRNTEXT => select(F_DRNTEXT); my_use ("drntext"); set order to tag "1"
#xcommand O_DOKSPF => select(F_DOKSPF); my_use ("dokspf"); set order to tag "1"

// tabele provjere integriteta
#xcommand O_DINTEG1 => SELECT (F_DINTEG1); USEX ("dinteg1"); set order to tag "1"
#xcommand O_DINTEG2 => SELECT (F_DINTEG2); USEX ("dinteg2"); set order to tag "1"
#xcommand O_INTEG1 => SELECT (F_INTEG1); USEX ("integ1"); set order to tag "1"
#xcommand O_INTEG2 => SELECT (F_INTEG2); USEX ("integ2"); set order to tag "1"
#xcommand O_ERRORS => SELECT (F_ERRORS); USEX ("errors"); set order to tag "1"

// sql messages
#xcommand O_MESSAGE   => select(F_MESSAGE); my_use ("message"); set order to tag "1"
#xcommand O_AMESSAGE   => select(F_AMESSAGE); my_use (EXEPATH+"amessage"); set order to tag "1"
#xcommand O_TMPMSG  => select(F_TMPMSG); my_use (EXEPATH+"tmpmsg"); set order to tag "1"


// modul FIN
#xcommand O_FIN_PRIPR     => select (F_FIN_PRIPR);  usex ("fin_pripr") ; set order to tag "1"
#xcommand O_FIN_PRIPRRP   => select (F_FIN_PRIPRRP); usex (strtran(cDirPriv, goModul:oDataBase:cSezonDir, SLASH) + "FIN_PRIPR", "fin_priprrp"); set order to tag "1"
#xcommand O_PNALOG   => select (F_PNALOG); usex ("pnalog"); set order to tag "1"
#xcommand O_PSUBAN   => select (F_PSUBAN); usex ("psuban"); set order to tag "1"
#xcommand O_PANAL   => select (F_PANAL); usex ("panal")   ; set order to tag "1"
#xcommand O_PSINT   => select (F_PSINT); usex ("psint")   ; set order to tag "1"
#xcommand O_SUBAN    => SELECT (F_SUBAN); my_use("suban"); set order to tag "1"
#xcommand O_KUF      => SELECT (F_KUF); my_use("kuf"); set order to tag "ID"
#xcommand O_KIF      => SELECT (F_KIF); my_use("kif"); set order to tag "ID"
#xcommand O_ANAL    => SELECT (F_ANAL); my_use("anal"); set order to tag "1"
#xcommand O_NALOG    => SELECT (F_NALOG); my_use("nalog"); set order to tag "1"
#xcommand O_SINT    => SELECT (F_SINT); my_use("sint"); set order to tag "1"
#xcommand O_RSUBAN    => select (F_SUBAN);  usex("suban"); set order to tag "1"
#xcommand O_RANAL    => select (F_ANAL);    usex("anal") ; set order to tag "1"
#xcommand O_SINTSUB => select (F_SUBAN);    my_use("suban"); set order to tag "1"
#xcommand O_BUDZET   => select (F_BUDZET);    my_use("budzet") ; set order to tag "1"
#xcommand O_PAREK   => select (F_PAREK);    my_use("parek")   ; set order to tag "1"
#xcommand O_BBKLAS   => select (F_BBKLAS);    my_use("bbklas")   ; set order to tag "1"
#xcommand O_IOS   => select (F_IOS);    my_use("ios")   ; set order to tag "1"
#xcommand O_FIN_RJ   => select (F_FIN_RJ);          MY_USE  ("fin_rj")    ; set order to tag "ID"
#xcommand O_FUNK   => select (F_FUNK);    MY_USE  ("funk") ; set order to tag "ID"
#xcommand O_FOND   => select (F_FOND);    MY_USE  ("fond") ; set order to tag "ID"
#xcommand O_BUIZ   => select (F_BUIZ);    MY_USE  ("buiz") ; set order to tag "ID"
#xcommand OX_KONTO    => select (F_KONTO);  usex ("konto")  ;  set order to tag "ID"
#xcommand O_VKSG     => select (F_VKSG);  MY_USE ("vksg");  set order to tag "1"
#xcommand OX_VKSG     => select (F_VKSG);  usex ("vksg")  ;  set order to tag "1"
#xcommand O_RKONTO    => select (F_KONTO);  usex ("konto") ; set order to tag "ID"
#xcommand OX_PARTN    => select (F_PARTN);  usex ("partn") ; set order to tag "ID"
#xcommand O_RPARTN    => select (F_PARTN);  usex ("partn") ; set order to tag "ID"
#xcommand OX_TNAL    => select (F_TNAL);  usex ("tnal")      ; set order to tag "ID"
#xcommand OX_TDOK    => select (F_TDOK);  usex ("tdok")      ; set order to tag "ID"
#xcommand O_PKONTO   => select (F_PKONTO); MY_USE  ("pkonto")  ; set order to tag "ID"
#xcommand OX_PKONTO   => select (F_PKONTO); usex  ("pkonto")  ; set order to tag "ID"
#xcommand OX_VALUTE   => select(F_VALUTE);  usex  ("valute")  ; set order to tag "ID"
#xcommand O__KONTO => select(F__KONTO); MY_USE  ("_konto")
#xcommand O__PARTN => select(F__PARTN); MY_USE  ("_partn")
#xcommand O_PRENHH   => select(F_PRENHH); usex ("prenhh"); set order to tag "1"


// modul KALK
#xcommand O_KALK_PRIPR   => select(F_KALK_PRIPR); usex (PRIVPATH + "kalk_pripr") ; set order to tag "1"
#xcommand O_KALK_S_PRIPR   => select(F_KALK_PRIPR); use (PRIVPATH + "kalk_pripr") ; set order to tag "1"
#xcommand O_KALK_PRIPRRP   => select (F_KALK_PRIPRRP);   usex (strtran(cDirPriv,goModul:oDataBase:cSezonDir, SLASH) + "pripr") alias priprrp ; set order to tag "1"
#xcommand O_KALK_PRIPR2  => select(F_KALK_PRIPR2); usex (PRIVPATH + "kalk_pripr2") ; set order to tag "1"
#xcommand O_KALK_PRIPR9  => select(F_KALK_PRIPR9); usex (PRIVPATH + "kalk_pripr9") ; set order to tag "1"
#xcommand O__KALK  => select(F__KALK); usex (PRIVPATH + "_kalk" )
#xcommand O_FINMAT  => select(F_FINMAT); usex (PRIVPATH + "finmat")    ; set order to tag "1"
#xcommand O_KALK   => select(F_KALK);  my_use  (KUMPATH + "kalk")  ; set order to tag "1"
#xcommand O_KALKSEZ   => select(F_KALKSEZ);  my_use  (KUMPATH+"2005"+SLASH+"KALK") alias kalksez ; set order to "1"
#xcommand O_ROBASEZ   => select(F_ROBASEZ);  my_use  (SIFPATH+"2005"+SLASH+"ROBA") alias robasez ; set order to tag "ID"
#xcommand O_KALKX  => select(F_KALK);  usex  (KUMPATH +"kalk")  ; set order to tag "1"
#xcommand O_KALKS  => select(F_KALKS);  my_use  (KUMPATH + "kalks")  ; set order to tag "1"
#xcommand O_KALKREP => if gKalks; select(F_KALK); use; select(F_KALK) ; my_use  ("kalks", "KALK") ; set order to tag "1";else; select(F_KALK);  my_use  ("KALK")  ; set order to tag "1"; end
#xcommand O_SKALK   => select(F_KALK);  my_use  (KUMPATH + "kalk")  alias PRIPR ; set order to tag "1"
#xcommand O_DOKS    => select(F_DOKS);  my_use  (KUMPATH + "doks")     ; set order to tag "1"
#xcommand O_DOKS2   => select(F_DOKS2);  my_use  (KUMPATH + "doks2")     ; set order to tag "1"
#xcommand O_PORMP  => select(F_PORMP); usex ("pormp")     ; set order to tag "1"
#xcommand O_PRODNC   => select(F_PRODNC);  my_use  ("prodnc")  ; set order to tag "PRODROBA"
#xcommand O_RVRSTA   => select(F_RVRSTA);  my_use  ("rvrsta")  ; set order to tag "ID"
#xcommand O_KALKSEZ   => select(F_KALKSEZ);  my_use  ("2005"+SLASH+"kalk") alias kalksez ; set order to tag "1"
#xcommand O_ROBASEZ   => select(F_ROBASEZ);  my_use  ("2005"+SLASH+"kalk") alias robasez ; set order to tag "ID"


// modul FAKT
#xcommand O_FAKT_PRIPR   => select(F_FAKT_PRIPR); usex (PRIVPATH + "fakt_pripr") ; set order to tag "1"
#xcommand O_FAKT      => select (F_FAKT) ;   my_use  ("fakt") ; set order to tag  "1"
#xcommand O__FAKT     => select(F__FAKT)  ; my_use ("_fakt") 
#xcommand O__ROBA   => select(F__ROBA);  my_use  ("_roba")
#xcommand O_PFAKT     => select (F_FAKT);  my_use  ("fakt") alias PRIPR; set order to tag   "1"
#xcommand O_DOKS      => select(F_DOKS);    my_use  ("doks")  ; set order to tag "1"
#xcommand O_DOKS2     => select(F_DOKS2);    my_use  ("doks2")  ; set order to tag "1"
#xcommand O_FTXT    => select (F_FTXT);    my_use ("ftxt")    ; set order to tag "ID"
#xcommand O_DEST     => select(F_DEST);  my_use  ("dest")     ; set order to tag "1"
#xcommand O_POR      => select 95; usex ("por") 
#xcommand O_KALPOS => SELECT (F_KALPOS); my_USE ("kalpos"); set order to tag "1"
#xcommand O_DOKSTXT  => select (F_DOKSTXT); my_use (ToUnix("dokstxt")) ; set order to tag "ID"




