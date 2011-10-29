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


#xcommand O_PRIPR     => select (F_PRIPR);   usex (PRIVPATH + "PRIPR") ; set order to tag "1"
#xcommand O_PRIPRRP   => select (F_PRIPRRP); usex (strtran(cDirPriv, goModul:oDataBase:cSezonDir, SLASH) + "PRIPR", "priprrp"); set order to tag "1"

#xcommand O_SUBAN    => SELECT (F_SUBAN); my_use("suban"); set order to tag "1"
#xcommand O_KUF      => OKumul(F_KUF  ,KUMPATH,"KUF"  , 2); set order to tag "ID"
#xcommand O_KIF      => OKumul(F_KIF  ,KUMPATH,"KIF"  , 2); set order to tag "ID"
#xcommand O_ANAL    =>  OKumul(F_ANAL,KUMPATH,"ANAL", 3)  ; set order to tag "1"
#xcommand O_SINT    =>  OKumul(F_SINT,KUMPATH,"SINT", 2)  ; set order to tag "1"
#xcommand O_NALOG    => OKumul(F_NALOG,KUMPATH,"NALOG", 2); set order to tag "1"

#xcommand O_RSUBAN    => select (F_SUBAN);  user (KUMPATH + "SUBAN"); set order to tag "1"
#xcommand O_RANAL    => select (F_ANAL);    user (KUMPATH + "ANAL") ; set order to tag "1"
#xcommand O_SINTSUB => select (F_SUBAN);    MY_USE  (KUMPATH + "SUBAN"); set order to tag "1"
#xcommand O_BUDZET   => select (F_BUDZET);    MY_USE  (KUMPATH + "BUDZET") ; set order to tag "1"
#xcommand O_PAREK   => select (F_PAREK);    MY_USE  (KUMPATH + "PAREK")   ; set order to tag "1"

#xcommand O_BBKLAS    => O_POMDB(F_BBKLAS,"BBKLAS"); set order to tag "1"
#xcommand O_IOS    =>   O_POMDB(F_IOS,"IOS"); set order to tag "1"

#xcommand O_PNALOG   => select (F_PNALOG); usex (PRIVPATH + "PNALOG"); set order to tag "1"
#xcommand O_PSUBAN   => select (F_PSUBAN); usex (PRIVPATH + "PSUBAN"); set order to tag "1"
#xcommand O_PANAL   => select (F_PANAL); usex (PRIVPATH + "PANAL")   ; set order to tag "1"
#xcommand O_PSINT   => select (F_PSINT); usex (PRIVPATH + "PSINT")   ; set order to tag "1"

#xcommand O_RJ   => select (F_RJ);          MY_USE  (KUMPATH + "RJ")    ; set order to tag "ID"
#xcommand O_FUNK   => select (F_FUNK);    MY_USE  (KUMPATH+"FUNK") ; set order to tag "ID"
#xcommand O_FOND   => select (F_FOND);    MY_USE  (KUMPATH+"FOND") ; set order to tag "ID"
#xcommand O_KONIZ  => select (F_KONIZ);    MY_USE  (KUMPATH+"KONIZ") ; set order to tag "ID"
#xcommand O_IZVJE  => select (F_IZVJE);    MY_USE  (KUMPATH+"IZVJE") ; set order to tag "ID"
#xcommand O_ZAGLI  => select (F_ZAGLI);    MY_USE  (KUMPATH+"ZAGLI") ; set order to tag "ID"
#xcommand O_KOLIZ  => select (F_KOLIZ);    MY_USE  (KUMPATH+"KOLIZ") ; set order to tag "ID"
#xcommand O_BUIZ   => select (F_BUIZ);    MY_USE  (KUMPATH+"BUIZ") ; set order to tag "ID"
#xcommand O_KONTO    => select (F_KONTO);  MY_USE (SIFPATH+"KONTO");  set order to tag "ID"
#xcommand OX_KONTO    => select (F_KONTO);  usex (SIFPATH+"KONTO")  ;  set order to tag "ID"
#xcommand O_VKSG     => select (F_VKSG);  MY_USE (SIFPATH+"VKSG");  set order to tag "1"
#xcommand OX_VKSG     => select (F_VKSG);  usex (SIFPATH+"VKSG")  ;  set order to tag "1"

#xcommand O_RKONTO    => select (F_KONTO);  user (SIFPATH+"KONTO") ; set order to tag "ID"
#xcommand O_PARTN    => select (F_PARTN);  MY_USE (SIFPATH+"PARTN") ; set order to tag "ID"
#xcommand OX_PARTN    => select (F_PARTN);  usex (SIFPATH+"PARTN") ; set order to tag "ID"
#xcommand O_RPARTN    => select (F_PARTN);  user (SIFPATH+"PARTN") ; set order to tag "ID"
#xcommand O_TNAL    => select (F_TNAL);  MY_USE (SIFPATH+"TNAL")      ; set order to tag "ID"
#xcommand OX_TNAL    => select (F_TNAL);  usex (SIFPATH+"TNAL")      ; set order to tag "ID"
#xcommand O_TDOK    => select (F_TDOK);  MY_USE (SIFPATH+"TDOK")      ; set order to tag "ID"
#xcommand OX_TDOK    => select (F_TDOK);  usex (SIFPATH+"TDOK")      ; set order to tag "ID"
#xcommand O_PKONTO   => select (F_PKONTO); MY_USE  (SIFPATH+"pkonto")  ; set order to tag "ID"
#xcommand OX_PKONTO   => select (F_PKONTO); usex  (SIFPATH+"pkonto")  ; set order to tag "ID"
#xcommand O_VALUTE   => select(F_VALUTE);  MY_USE  (SIFPATH+"VALUTE")  ; set order to tag "ID"
#xcommand OX_VALUTE   => select(F_VALUTE);  usex  (SIFPATH+"VALUTE")  ; set order to tag "ID"

#xcommand O_FAKT      => select (F_FAKT) ;   MY_USE  (gFaktKum+"FAKT") ; set order to tag  "1"
#xcommand O_KALK      => select (F_KALK) ;   MY_USE  (gKalkKum+"KALK") ; set order to tag  "1"

#xcommand O_ROBA   => select(F_ROBA);  MY_USE  (SIFPATH+"ROBA")  ; set order to tag "ID"
#xcommand O_SAST   => select(F_SAST);  MY_USE  (SIFPATH+"SAST")  ; set order to tag "ID"
#xcommand O_TARIFA   => select(F_TARIFA);  MY_USE  (SIFPATH+"TARIFA")  ; set order to tag "ID"
#xcommand O_TRFP2    => select(F_TRFP2);   MY_USE  (SIFPATH+"trfp2")       ; set order to tag "ID"
#xcommand O_TRFP3    => select(F_TRFP3);   MY_USE  (SIFPATH+"trfp3")       ; set order to tag "ID"
#xcommand O_KONCIJ => select(F_KONCIJ);  MY_USE  (SIFPATH+"KONCIJ")     ; set order to tag "ID"
#xcommand O_FINMAT  => select(F_FINMAT); usex (PRIVPATH+"FINMAT")    ; set order to tag "1"

#xcommand O__KONTO => select(F__KONTO); MY_USE  (PRIVPATH+"_KONTO")
#xcommand O__PARTN => select(F__PARTN); MY_USE  (PRIVPATH+"_PARTN")

#xcommand O_UGOV     => select(F_UGOV);  MY_USE  (strtran(KUMPATH,"FIN","FAKT")+"UGOV")     ; set order to tag "ID"
#xcommand O_RUGOV    => select(F_RUGOV);  MY_USE (STRTRAN(KUMPATH,"FIN","FAKT")+"RUGOV")   ; set order to tag "ID"
#xcommand O_DEST     => select(F_DEST);  MY_USE  (STRTRAN(KUMPATH,"FIN","FAKT")+"DEST")     ; set order to tag "1"
#xcommand O_VRSTEP => SELECT (F_VRSTEP); MY_USE (SIFPATH+"VRSTEP"); set order to tag "ID"
#xcommand O_VPRIH => SELECT (F_VPRIH); MY_USE (SIFPATH+"VPRIH"); set order to tag "ID"
#xcommand O_ULIMIT => SELECT (F_ULIMIT); MY_USE (SIFPATH+"ULIMIT"); set order to tag "ID"
#xcommand O_TIPBL => SELECT (F_TIPBL); MY_USE (SIFPATH+"TIPBL"); set order to tag "1"
#xcommand O_VRNAL => SELECT (F_VRNAL); MY_USE (SIFPATH+"VRNAL"); set order to tag "1"

#xcommand O_PRENHH   => select(F_PRENHH); usex (PRIVPATH+"PRENHH"); set order to tag "1"

