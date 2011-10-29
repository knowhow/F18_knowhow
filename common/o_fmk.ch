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


//#xcommand O_KORISN    => select (F_KORISN);  my_use ( ToUnix (CURDIR + "korisn" ) ) ; set order to tag "IME"
#xcommand O_PARAMS    => select (F_PARAMS);  my_use ( "params"); set order to tag  "ID"
#xcommand O_GPARAMS   => select (F_GPARAMS); my_use ( ToUnix( SLASH + "gparams") )  ;   set order to tag  "ID"
#xcommand O_GPARAMSP  => select (F_GPARAMSP); my_use ( PRIVPATH + "gparams" )  ; set order to tag  "ID"
#xcommand O_MPARAMS   => select (F_MPARAMS);  my_use ( CURDIR + "mparams" )   ; set order  to tag  "ID"
#xcommand O_KPARAMS   => select (F_KPARAMS); my_use ( KUMPATH + "kparams" ) ; set order to tag  "ID"
#xcommand O_SECUR     => select (F_SECUR); my_use ( KUMPATH + "secur" )  ; set order to tag "ID"
#xcommand O_ADRES     => select (F_ADRES); my_use ( SIFPATH + "adres" )  ; set order to tag "ID"

#xcommand O_SQLPAR    => select (F_SQLPAR); my_use ( ToUnix( KUMPATH + "SQL"+ SLASH + "SQLPAR" ) )


#xcommand O_SIFK => select(F_SIFK);  my_use  ("sifk")     ; set order to tag "ID"
#xcommand O_SIFV => select(F_SIFV);  my_use  ("sifv")     ; set order to tag "ID"

// PROIZVOLJNI IZVJESTAJI
#xcommand O_KONIZ  => select (F_KONIZ);    my_use  (KUMPATH + "KONIZ") ; set order to tag "ID"
#xcommand O_IZVJE  => select (F_IZVJE);    my_use  (KUMPATH + "IZVJE") ; set order to tag "ID"
#xcommand O_ZAGLI  => select (F_ZAGLI);    my_use  (KUMPATH + "ZAGLI") ; set order to tag "ID"
#xcommand O_KOLIZ  => select (F_KOLIZ);    my_use  (KUMPATH + "KOLIZ") ; set order to tag "ID"


#xcommand O_ROBA   => select(F_ROBA);    my_use ("roba")  ; set order to tag "ID"
#xcommand O_TARIFA   => select(F_TARIFA);  my_use  (SIFPATH + "tarifa" )  ; set order to tag "ID"
#xcommand O_KONTO   => select(F_KONTO);  my_use  (SIFPATH + "konto" ) ; set order to tag "ID"
#xcommand O_TRFP    => select(F_TRFP);   my_use  (SIFPATH + "trfp")       ; set order to tag "ID"
#xcommand O_TRMP    => select(F_TRMP);   my_use  (SIFPATH + "trmp")       ; set order to tag "ID"
#xcommand O_PARTN   => select(F_PARTN);  my_use  (SIFPATH + "partn")  ; set order to tag "ID"
#xcommand O_TNAL   => select(F_TNAL);  my_use  (SIFPATH + "tnal" )         ; set order to tag "ID"
#xcommand O_TDOK   => select(F_TDOK);  my_use  (SIFPATH + "tdok" )         ; set order to tag "ID"
#xcommand O_KONCIJ => select(F_KONCIJ);  my_use  (SIFPATH + "koncij" )     ; set order to tag "ID"
#xcommand O_VALUTE => select(F_VALUTE);  my_use  (SIFPATH + "valute" )     ; set order to tag "ID"
#xcommand O_SAST   => select (F_SAST); my_use  (SIFPATH + "sast" )         ; set order to tag "ID"

#xcommand O_BARKOD  => select(F_BARKOD);  my_use (PRIVPATH + "barkod"); set order to tag "1"

#xcommand O_RJ   => select(F_RJ);  my_use  (KUMPATH + "rj")         ; set order to tag "ID"
#xcommand O_REFER   => select(F_REFER);  my_use  ("REFER")         ; set order to tag "ID"
#xcommand O_OPS   => select(F_OPS);  my_use  (SIFPATH + "ops" )         ; set order to tag "ID"

#xcommand O_RNAL  => select(F_RNAL);  my_use  (SIFPATH + "rnal" )      ; set order to tag "ID"

#xcommand O_UGOV     => select(F_UGOV);  my_use  (KUMPATH + "ugov" )     ; set order to tag "ID"

#xcommand O_RUGOV    => select(F_RUGOV); my_use  (KUMPATH + "rugov" )   ; set order to tag "ID"

// KALK

#xcommand O_PRIPR   => select(F_PRIPR); usex (PRIVPATH + "pripr") ; set order to tag "1"
#xcommand O_S_PRIPR   => select(F_PRIPR); use (PRIVPATH + "pripr") ; set order to tag "1"

#xcommand O_PRIPRRP   => select (F_PRIPRRP);   usex (strtran(cDirPriv,goModul:oDataBase:cSezonDir, SLASH) + "pripr") alias priprrp ; set order to tag "1"

#xcommand O_PRIPR2  => select(F_PRIPR2); usex (PRIVPATH + "pripr2") ; set order to tag "1"
#xcommand O_PRIPR9  => select(F_PRIPR9); usex (PRIVPATH + "pripr9") ; set order to tag "1"
#xcommand O__KALK  => select(F__KALK); usex (PRIVPATH + "_kalk" )

#xcommand O_FINMAT  => select(F_FINMAT); usex (PRIVPATH + "finmat")    ; set order to tag "1"

#xcommand O_KALK   => select(F_KALK);  my_use  (KUMPATH + "kalk")  ; set order to tag "1"
#xcommand O_KALKX  => select(F_KALK);  usex  (KUMPATH +"kalk")  ; set order to tag "1"

#xcommand O_KALKS  => select(F_KALKS);  my_use  (KUMPATH + "kalks")  ; set order to tag "1"
#xcommand O_KALKREP => if gKalks; select(F_KALK); use; select(F_KALK) ; my_use  ("kalks", "KALK") ; set order to tag "1";else; select(F_KALK);  my_use  ("KALK")  ; set order to tag "1"; end

#xcommand O_SKALK   => select(F_KALK);  my_use  (KUMPATH + "kalk")  alias PRIPR ; set order to tag "1"
#xcommand O_DOKS    => select(F_DOKS);  my_use  (KUMPATH + "doks")     ; set order to tag "1"
#xcommand O_DOKS2   => select(F_DOKS2);  my_use  (KUMPATH + "doks2")     ; set order to tag "1"
#xcommand O_PORMP  => select(F_PORMP); usex ("pormp")     ; set order to tag "1"

#xcommand O__ROBA   => select(F__ROBA);  my_use  ("_roba")

#xcommand O__PARTN   => select(F__PARTN);  my_use  ("_partn")


#xcommand O_KONTO   => select(F_KONTO);  my_use  ("konto") ; set order to tag "ID"
#xcommand O_TRFP    => select(F_TRFP);   my_use  ("trfp")       ; set order to tag "ID"
#xcommand O_TRMP    => select(F_TRMP);   my_use  ("trmp")       ; set order to tag "ID"
#xcommand O_PARTN   => select(F_PARTN);  my_use  ("partn")  ; set order to tag "ID"
#xcommand O_TNAL   => select(F_TNAL);  my_use  ("tnal")         ; set order to tag "ID"
#xcommand O_TDOK   => select(F_TDOK);  my_use  ("tdok")         ; set order to tag "ID"
#xcommand O_KONCIJ => select(F_KONCIJ);  my_use  ("koncij")     ; set order to tag "ID"
#xcommand O_VALUTE => select(F_VALUTE);  my_use  ("valute")     ; set order to tag "ID"
#xcommand O_SAST   => select (F_SAST);  my_use  ("sast")         ; set order to tag "ID"
#xcommand O_BANKE   => select (F_BANKE) ; my_use ("banke")  ; set order to tag "ID"

#xcommand O_LOGK   => select (F_LOGK) ; my_use  ("logk")         ; set order to tag "NO"
#xcommand O_LOGKD  => select (F_LOGKD); my_use  ("logd")        ; set order to tag "NO"

#xcommand O_BARKOD  => select(F_BARKOD);  my_use ("barkod"); set order to tag "1"


#xcommand O_FAKT      => select (F_FAKT) ;   my_use  ("fakt") ; set order to tag  "1"
#xcommand O__FAKT     => select(F__FAKT)  ; my_use ("_fakt") 
#xcommand O__ROBA   => select(F__ROBA);  my_use  ("_roba")
#xcommand O_PFAKT     => select (F_FAKT);  my_use  ("fakt") alias PRIPR; set order to tag   "1"
#xcommand O_DOKS      => select(F_DOKS);    my_use  ("doks")  ; set order to tag "1"
#xcommand O_DOKS2     => select(F_DOKS2);    my_use  ("doks2")  ; set order to tag "1"

#xcommand O_FTXT    => select (F_FTXT);    my_use ("ftxt")    ; set order to tag "ID"
#xcommand O_DEST     => select(F_DEST);  my_use  ("dest")     ; set order to tag "1"
#xcommand O_POR      => select 95; usex ("por") 

#xcommand O_VRSTEP => SELECT (F_VRSTEP); my_USE ("vrstep"); set order to tag "ID"
#xcommand O_OPS    => SELECT (F_OPS)   ; my_USE ("ops"); set order to tag "ID"

#xcommand O_RELAC  => SELECT (F_RELAC) ; my_USE ("relac"); set order to tag "ID"
#xcommand O_VOZILA => SELECT (F_VOZILA); my_USE ("vozila"); set order to tag "ID"
#xcommand O_KALPOS => SELECT (F_KALPOS); my_USE ("kalpos"); set order to tag "1"

#xcommand O_ADRES     => select (F_ADRES); my_use (ToUnix("adres")) ; set order to tag "ID"

#xcommand O_DOKSTXT  => select (F_DOKSTXT); my_use (ToUnix("dokstxt")) ; set order to tag "ID"

#xcommand O_EVENTS  => select (F_EVENTS); my_use (ToUnix(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"events")) ; set order to tag "ID"

#xcommand O_EVENTLOG  => select (F_EVENTLOG); my_use (ToUnix(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"eventlog")) ; set order to tag "ID"

#xcommand O_USERS  => select (F_USERS); my_use (ToUnix(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"users")) ; set order to tag "ID"

#xcommand O_GROUPS  => select (F_GROUPS); my_use (ToUnix(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"groups")) ; set order to tag "ID"

#xcommand O_RULES  => select (F_RULES); my_use (ToUnix(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"rules")) ; set order to tag "ID"

//KALK ProdNC
#xcommand O_PRODNC   => select(F_PRODNC);  my_use  ("prodnc")  ; set order to tag "PRODROBA"

//KALK RVrsta
#xcommand O_RVRSTA   => select(F_RVRSTA);  my_use  ("rvrsta")  ; set order to tag "ID"

#xcommand O_R_EXP => select (F_R_EXP); my_use ("r_export")


#xcommand O_FMKRULES  => select (F_FMKRULES); my_use ("fmkrules") ; set order to tag "2"


#xcommand O_GEN_UG   => select(F_GEN_UG);  my_use  ("gen_ug")  ; set order to tag "DAT_GEN"

#xcommand O_G_UG_P  => select(F_G_UG_P);  my_use  ("gen_ug_p")   ; set order to tag "DAT_GEN"

// grupe i karakteristike
#xcommand O_STRINGS  => select(F_STRINGS);  my_use  (SIFPATH + "strings")   ; set order to tag "1"

#xcommand O_LOKAL => select (F_LOKAL); usex ("lokal")


// tabele DOK_SRC
#xcommand O_DOKSRC => SELECT (F_DOKSRC); my_USE ("doksrc"); set order to tag "1"
#xcommand O_P_DOKSRC => SELECT (F_P_DOKSRC); my_USE ("p_doksrc"); set order to tag "1"

#xcommand O_RELATION => SELECT (F_RELATION); my_USE ("relation"); set order to tag "1"

// POS modul

#xcommand O_KALKSEZ   => select(F_KALKSEZ);  my_use  ("2005"+SLASH+"kalk") alias kalksez ; set order to tag "1"
#xcommand O_ROBASEZ   => select(F_ROBASEZ);  my_use  ("2005"+SLASH+"kalk") alias robasez ; set order to tag "ID"


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

#define F_MSGNEW 234

#xcommand O_MESSAGE   => select(F_MESSAGE); my_use ("message"); set order to tag "1"
#xcommand O_AMESSAGE   => select(F_AMESSAGE); my_use (EXEPATH+"amessage"); set order to tag "1"
#xcommand O_TMPMSG  => select(F_TMPMSG); my_use (EXEPATH+"tmpmsg"); set order to tag "1"

