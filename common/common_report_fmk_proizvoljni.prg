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


#include "fmk.ch"


// ----------------------------------------------------
// glavni poziv proizvoljnih izvjestaja
// ----------------------------------------------------

function proizvoljni_izvjestaji()
local cScr := SAVESCREEN( 1, 0, 1, 79 )
local GetList := {}
local _my_user := my_user()
local _i
private cV1, cV2, cV3, cV4, cV5, cV6
private opc[10]
private Izbor
private nTekIzv := 1
private cBrI := fetch_metric( "proiz_broj_izvjestaja", _my_user, "01" )
private cPotrazKon := fetch_metric( "proiz_kto_potrazuje", _my_user, "7;811;812;" )
private gnPorDob := fetch_metric( "proiz_por_dob", _my_user, 30 )
private cPIKPolje := ""
private cPIKBaza := ""
private cPIKIndeks := ""
private cPITipTab := ""
private cPIKSif := ""
private cPIImeKP := ""

if goModul:oDatabase:cName == "KALK"
    OtBazPIKalk()
else
	OtBazPIFin()
endif

// # hash na pocetku kaze - obavezno browsaj !
P_Proizv( @cBrI, NIL, NIL, "#Odaberi izvjestaj :" ) 

nTokens := NumToken( izvje->naz, "#" )

if nTokens > 1

    Box(, nTokens + 1, 75 )

        @ m_x+0,m_y+3 SAY "Unesi varijable0 izvjestaja:"

        // popuni ini fajl vrijednostima
        // formira varijable cV1, cV2 redom !!!!1

        for i:=2 to nTokens
            cPom:="cV"+alltrim(str(i-1))
            &cPom:=padr(UzmiIzIni(EXEPATH+'ProIzvj.ini','Varijable0',alltrim(token(izvje->naz,"#",i)),"",'READ'),45)
        next


        for i:=2 to nTokens
            cPom:="cV"+alltrim(str(i-1))
            @ m_X+i, m_y+2 SAY padr(token(izvje->naz,"#",i),20)
            @ m_x+i, col()+2 GET &cPom
        next

        read
  
    BoxC()

    // popuni ini fajl vrijednostima
    for i:=2 to nTokens
        cPom:="cV"+alltrim(str(i-1))
        UzmiIzIni(EXEPATH+'ProIzvj.ini','Varijable0',alltrim(token(izvje->naz,"#",i)),&cPom,'WRITE')
    next

endif

// snimi sql parametre
set_metric( "proiz_broj_izvjestaja", _my_user, cBrI )
set_metric( "proiz_kto_potrazuje", _my_user, cPotrazKon )
set_metric( "proiz_por_dob", _my_user, gnPorDob )

nTekIzv := VAL( cBrI )

opc[1] := "1. generisanje izvještaja                       "      
opc[2] := "2. šifarnik izvjestaja"              
opc[3] := "3. redovi izvjestaja"                
opc[4] := "4. zaglavlje izvjestaja"              
opc[5] := "5. kolone izvjestaja"                 
opc[6] := "6. parametri (svi izvjestaji) "        
opc[7] := "7. tekuci izvjestaj: " + STR(nTekIzv,2) 
opc[8] := "8. preuzimanje definicija izvjestaja sa diskete" 
opc[9] := "9. promjeni broj izvjestaja" 
opc[10] := "A. ispravka proizvj.ini" 

izbor := 1

PrikaziTI( cBrI )

if goModul:oDataBase:cName == "KALK"
	GenProIzvKalk()
	OtBazPIKalk()
elseif goModul:oDataBase:cName == "FIN"
	GenProIzvFin()
	OtBazPIFin()
endif

for _i := 1 to LEN( opc )
    AADD( h, "" )
next

do while .t.
    
    izbor := Menu( "ProIzv", opc, izbor, .f. )
   
    do case
        case izbor == 0
            exit
        case izbor == 1
		    if goModul:oDataBase:cName == "KALK"
			    GenProIzvKalk()
		    	OtBazPIKalk()
		    elseif goModul:oDataBase:cName == "FIN"
			    GenProIzvFin()
			    OtBazPIFin()
		    endif

        case izbor == 2
            P_ProIzv()
            PrikaziTI(cBrI)
        case izbor == 3
            P_KonIz()
        case izbor == 4
            P_ZagProIzv()
        case izbor == 5
            P_KolProIzv()
        case izbor == 6
            if goModul:oDatabase:cName == "KALK"
                ParSviIzvjKalk()
		    elseif goModul:oDataBase:cName == "FIN"
                ParSviIzvjFin()
            endif 
        case izbor == 7
            Box(,3,70)
                @ m_x+2,m_y+2 SAY "Izaberite tekuci izvjestaj (1-99):" GET nTekIzv VALID nTekIzv>0 .and. nTekIzv<100 PICT "99"
                read
            BoxC()
            IF LASTKEY() != K_ESC
                opc[7] := "7. tekuci izvjestaj: "+STR(nTekIzv,2)
                cBrI:=RIGHT("00"+ALLTRIM(STR(nTekIzv)),2)
                PrikaziTI( cBrI )
                UzmiIzIni( EXEPATH + 'ProIzvj.ini','Varijable','OznakaIzvj',cBrI,'WRITE')
                set_metric( "proiz_broj_izvjestaja", _my_user, cBrI )
            ENDIF
        case izbor == 8
            MsgBeep( "nije implementirano !!!!" ) 
        case izbor == 9
            PromBroj()
        case izbor == 10
            MsgBeep( "nije implementirano !!!!" ) 

    endcase

enddo

RESTSCREEN(1,0,1,79,cScr)

close all
return




static function P_ProIzv( cId, dx, dy, cNaslov )
local i := 0
private imekol:={},kol:={}
 
ImeKol:={ { "Sifra"           , {|| id     }, "ID"     ,, {|| vpsifra (wId)}},;
           { "Naziv"           , {|| naz    }, "NAZ"     },;
           { "Filter klj.baze" , {|| uslov  }, "USLOV"   },;
           { "Kljucno polje"   , {|| kpolje }, "KPOLJE"  },;
           { "Opis klj.polja"  , {|| imekp  }, "IMEKP"   },;
           { "Baza sif.k.polja", {|| ksif   }, "KSIF"    },;
           { "Kljucna baza"    , {|| kbaza  }, "KBAZA"   },;
           { "Kljucni indeks"  , {|| kindeks}, "KINDEKS" },;
           { "Tip tabele"      , {|| tiptab }, "TIPTAB"  };
        }

for i := 1 to LEN(ImeKol)
    AADD( Kol, i )
next

aDefSpremBaz := { { F_Baze( "KONIZ" ), "ID", "IZV", ""},;
                 { F_Baze( "KOLIZ" ), "ID", "ID", ""},;
                 { F_Baze( "ZAGLI" ), "ID", "ID", ""} }
if cNaslov = NIL
    cNaslov := "Izvjestaji"
endif

return PostojiSifra( F_Baze( "IZVJE" ), 1, 10, 77, cNaslov, @cId, dx, dy )





static function P_ZagProIzv( cId, dx, dy, lSamoStampaj )
local i := 0
 
IF lSamoStampaj == NIL
    lSamoStampaj := .f.
ENDIF

private imekol:={}, kol:={}
    
SELECT ZAGLI
SET FILTER TO
SET FILTER TO ID == cBrI
dbGoTop()
    
ImeKol:={ { "Sifra"  , {|| Id}, "id", {|| wId:=cBrI,.t.}, {|| .t.} },;
           { "Koord.x", {|| x1 }  , "x1"     },;
           { "Koord.y", {|| y1 }  , "y1"     },;
           { "IZRAZ"  , {|| izraz}, "izraz"  };
        }
    
FOR i:=1 TO LEN(ImeKol)
    AADD(Kol,i)
NEXT
    
IF lSamoStampaj
    dbGoTop()
    P_12CPI
    QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - definicija zaglavlja izvjestaja")
    QOPodv("ZAGLI.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")
    ? 
    Izlaz(,,,.f.,.t.)
    RETURN
ENDIF

return PostojiSifra(F_Baze("ZAGLI"),"1",10,77,"ZAGLAVLJE IZVJESTAJA BR."+ALLTRIM(STR(nTekIzv)) ,@cId,dx,dy,{|Ch| APBlok(Ch)})


static function APBlok(Ch)

LOCAL lVrati:=DE_CONT, nRec:=0, i:=0
 IF Ch==K_ALT_P
     IF Pitanje(,"Želite li preuzeti podatke iz drugog izvjestaja? (D/N)","N")=="D"
       i:=1
       Box(,3,60)
        @ m_x+2, m_y+2 SAY "Preuzeti podatke iz izvjestaja br.? (1-99)" GET i VALID i>0 .and. i<100 .and. i<>nTekIzv PICT "99"
        READ
       BoxC()
       IF LASTKEY()!=K_ESC
         SET FILTER TO
         dbGoTop()
         DO WHILE !EOF()
           SKIP 1; nRec:=RECNO(); SKIP -1
           IF id==RIGHT("00"+ALLTRIM(STR(i)),2)
             Scatter()
             _id:=cBrI
             APPEND BLANK
             Gather()
           ENDIF
           GO (nRec)
         ENDDO
         lVrati:=DE_REFRESH
         SET FILTER TO ID==cBrI
         dbGoTop()
       ENDIF
     ENDIF
 ENDIF
RETURN lVrati



STATIC FUNCTION P_KolProIzv(cId,dx,dy,lSamoStampaj)
 LOCAL i:=0
 IF lSamoStampaj==NIL; lSamoStampaj:=.f.; ENDIF
 private imekol:={}, kol:={}
 SELECT KOLIZ
 SET FILTER TO
 SET FILTER TO ID==cBrI
 dbGoTop()
 ImeKol:={ { "Sifra"          , {|| Id      }, "id", {|| wId:=cBrI,.t.}, {|| .t.}},;
           { "Red.broj"       , {|| RBR     }, "RBR"      },;
           { "Ime kol."       , {|| NAZ     }, "NAZ"      },;
           { "Formula"        , {|| FORMULA }, "FORMULA"  },;
           { "Uslov"          , {|| KUSLOV  }, "KUSLOV"   },;
           { "Izraz zbrajanja", {|| SIZRAZ  }, "SIZRAZ"   },;
           { "Tip"            , {|| TIP     }, "TIP"      },;
           { "Sirina"         , {|| SIRINA  }, "SIRINA"   },;
           { "Decimale"       , {|| DECIMALE}, "DECIMALE" },;
           { "Sumirati"       , {|| SUMIRATI}, "SUMIRATI" },;
           { "K1"             , {|| K1      }, "K1"       },;
           { "K2"             , {|| K2      }, "K2"       },;
           { "N1"             , {|| N1      }, "N1"       },;
           { "N2"             , {|| N2      }, "N2"       };
        }
 IF lSamoStampaj
   dbGoTop()
   P_12CPI
   QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - definicija kolona izvjestaja")
   QOPodv("KOLIZ.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")
   P_COND2
   ?
   ? ".........................................."
   DO WHILE !EOF()

     IF ( prow() > 50+gPStranica )
       FF
       P_12CPI
       QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - definicija kolona izvjestaja")
       QOPodv("KOLIZ.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")
       P_COND2
       ?
       ? ".........................................."
     ENDIF
     ? PADR("Redni broj     :",16); ?? RBR
     ? PADR("Ime kolone     :",16); ?? NAZ
     ? PADR("Formula        :",16); ?? TRIM(FORMULA)
     ? PADR("Uslov          :",16); ?? KUSLOV
     ? PADR("Izraz zbrajanja:",16); ?? SIZRAZ
     ? PADR("Tip            :",16); ?? TIP
     ? PADR("Sirina         :",16); ?? SIRINA
     ? PADR("Decimale       :",16); ?? DECIMALE
     ? PADR("Sumirati       :",16); ?? SUMIRATI
     ? PADR("K1             :",16); ?? K1
     ? PADR("K2             :",16); ?? K2
     ? PADR("N1             :",16); ?? N1
     ? PADR("N2             :",16); ?? N2
     ? ".........................................."

     SKIP 1
   ENDDO
   RETURN
 ENDIF
 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
return PostojiSifra(F_Baze("KOLIZ"),"1",10,77,"KOLONE IZVJESTAJA BR."+ALLTRIM(STR(nTekIzv)) ,@cId,dx,dy,{|Ch| APBlok(Ch)})





STATIC PROCEDURE P_KonIz()
 LOCAL i:=0
 PRIVATE ImeKol:={},Kol:={}

 IF LASTKEY()==K_ESC; RETURN; ENDIF

 SELECT KONIZ
 SET ORDER TO TAG "1"
 SET FILTER TO
 SET FILTER TO IZV==cBrI
 dbGoTop()

 AADD( ImeKol , { "IZVJ."        , {|| IZV }, "IZV"  } )
 AADD( ImeKol , { cPIImeKP       , {|| ID  }, "ID"   } )
 AADD( ImeKol , { "R.BROJ"       , {|| RI  }, "RI"   } )
 AADD( ImeKol , { "K(  /Sn/An)"  , {|| K   }, "K"    } )
 AADD( ImeKol , { "FORMULA"      , {|| FI  }, "FI"   } )
 AADD( ImeKol , { "PREDZNAK"     , {|| PREDZN }, "PREDZN"   } )
 AADD( ImeKol , { "OPIS"         , {|| OPIS}, "OPIS" , {|| .t.}, {|| .t.}  } )
 AADD( ImeKol , { cPIImeKP+"2"   , {|| ID2 }, "ID2"  } )
 AADD( ImeKol , { "K2(  /Sn/An)" , {|| K2  }, "K2"   } )
 AADD( ImeKol , { "FORMULA2"     , {|| FI2 }, "FI2"  } )
 AADD( ImeKol , { "PREDZNAK2"    , {|| PREDZN2 }, "PREDZN2"   } )
 AADD( ImeKol , { "PODVUCI"      , {|| PODVUCI }, "PODVUCI"   } )
 IF FIELDPOS("K1")<>0
   AADD( ImeKol , { "K1"           , {|| K1      }, "K1"        } )
   AADD( ImeKol , { "U1"           , {|| U1      }, "U1"        } )
 ENDIF

 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

 Box(,20,77)
  @ m_x+18,m_y+2 SAY "<a-P> popuni bazu iz sifrarnika   <a-N> preuzmi iz drugog izvjestaja"
  @ m_x+19,m_y+2 SAY "<c-N> nova stavka                 <c-I> nuliranje po uslovu         "
  @ m_x+20,m_y+2 SAY "<c-T> brisi stavku              <Enter> ispravka stavke             "
  ObjDBEdit("PKONIZ",20,77,{|| KonIzBlok()},"","Priprema redova za izvjestaj br."+cBrI+"ÍÍÍÍÍ<c-P> vidi komplet definiciju", , , , ,3)
 BoxC()
RETURN



STATIC FUNCTION KonIzBlok()
 LOCAL GetList:={}
 LOCAL lVrati:=DE_CONT, i:=0, nRec:=0, n0:=0, n1:=0, nSRec:=0, cUslov:=""
 PRIVATE aUslov:=""
 DO CASE
   CASE Ch==K_CTRL_P
     // --------- stampanje definicije izvjestaja ---------
     // ---------------------------------------------------
     SELECT IZVJE
     SEEK cBrI
     StartPrint()

     P_12CPI
     QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - osnovna definicija izvjestaja")
     QOPodv("IZVJE.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")

     ?
     ? PADL("Sifra"           ,17); ?? ":", id
     ? PADL("Naziv"           ,17); ?? ":", TRIM(naz)
     ? PADL("Filter klj.baze" ,17); ?? ":", TRIM(uslov)
     ? PADL("Kljucno polje"   ,17); ?? ":", TRIM(kpolje)
     ? PADL("Opis klj.polja"  ,17); ?? ":", TRIM(imekp)
     ? PADL("Baza sif.k.polja",17); ?? ":", TRIM(ksif)
     ? PADL("Kljucna baza"    ,17); ?? ":", TRIM(kbaza)
     ? PADL("Kljucni indeks"  ,17); ?? ":", TRIM(kindeks)
     ? PADL("Tip tabele"      ,17); ?? ":", tiptab


     FF

     P_ZagProizv(,,,.t.); FF

     P_KolProizv(,,,.t.); FF

     P_12CPI
     QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - definicija redova izvjestaja")
     QOPodv("KONIZ.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")
     SELECT KONIZ; nRec:=RECNO()
     dbGoTop()
     ?
     ? ".........................................."
     DO WHILE !EOF()
       IF prow() > 50+gPStranica
         P_12CPI
         FF
         QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - definicija redova izvjestaja")
         QOPodv("KONIZ.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")
         ?
         ? ".........................................."
       ENDIF
       ?  "Redni broj  :"           ; ?? ri
       ?  PADR(cPIImeKP,12)+":"     ; ?? id
       ?  "K(  /Sn/An) :"           ; ?? k
       ?  "Formula     :"           ; ?? fi
       ?  "Predznak    :"           ; ?? predzn
       ?  PADR(cPIImeKP+"2",12)+":" ; ?? id2
       ?  "K2(  /Sn/An):"           ; ?? k2
       ?  "Formula2    :"           ; ?? fi2
       ?  "Predznak2   :"           ; ?? predzn2
       ?  "OPIS        :"           ; ?? opis
       ?  "PODVUCI( /x):"           ; ?? podvuci
       IF FIELDPOS("K1")<>0
         ? "K1          :"          ; ?? k1
         ? "U1 ( ,>0,<0):"          ; ?? u1
       ENDIF
       ? ".........................................."
       SKIP 1
     ENDDO
     FF

     EndPrint()
     SELECT KONIZ; GO (nRec)

   CASE Ch==K_ALT_P      // popuni nanovo iz sifrarnika kljucnog polja
     IF cPIKSif!="BEZ" .and. Pitanje( ,"Zelite li obrisati bazu i formirati novu na osnovu sifrar.klj.polja?(D/N)","N")=="D"
       SELECT KONIZ
       ZAPP()

       O_KSIF()
       dbGoTop()
       DO WHILE !EOF()
         ++i
         SELECT KONIZ
         APPEND BLANK
         REPLACE izv WITH RIGHT("00"+ALLTRIM(STR(nTekIzv)),2),;
                 id WITH IzKSIF("id"),  ri WITH i
         SEL_KSif()
         SKIP 1
       ENDDO
       USE      // zatvaram KONTO.DBF
       SELECT KONIZ; dbGoTop()
       lVrati:=DE_REFRESH
     ENDIF
   CASE Ch==K_ALT_N      // popuni iz drugog izvjestaja
     IF Pitanje(,"Zelite li postojeće zamijeniti podacima iz drugog izvještaja?(D/N)","N")=="D"
       i:=1
       Box(,3,60)
        @ m_x+2, m_y+2 SAY "Preuzeti podatke iz izvjestaja br.? (1-99)" GET i VALID i>0 .and. i<100 .and. i<>nTekIzv PICT "99"
        READ
       BoxC()
       IF LASTKEY()!=K_ESC
         SELECT KONIZ
         dbGoTop()
         DO WHILE !EOF() .and. izv==cBrI
           SKIP 1; nRec:=RECNO(); SKIP -1; DELETE; GO (nRec)
         ENDDO
         SET FILTER TO
         SEEK RIGHT("00"+ALLTRIM(STR(i)),2)
         DO WHILE !EOF() .and. izv==RIGHT("00"+ALLTRIM(STR(i)),2)
           SKIP 1; nRec:=RECNO(); SKIP -1
           Scatter()
           _IZV:=cBrI
           APPEND BLANK
           Gather()
           GO (nRec)
         ENDDO
         SET FILTER TO izv==cBrI
         dbGoTop()
         lVrati:=DE_REFRESH
       ENDIF
     ENDIF
   CASE Ch==K_ENTER              // ispravka
     Box(,15,77)
     Scatter()
     n0:=_ri
      @ m_x, m_y+2 SAY "ISPRAVKA STAVKE - IZVJESTAJ "+cBrI
      @ m_x+ 2, m_y+2 SAY "Redni broj  :" GET _ri PICT "9999"
      @ m_x+ 3, m_y+2 SAY PADR(cPIImeKP,12)+":" GET _id
      @ m_x+ 4, m_y+2 SAY "K(  /Sn/An) :" GET _k
      @ m_x+ 5, m_y+2 SAY "Formula     :" GET _fi PICT "@S60"
      @ m_x+ 6, m_y+2 SAY "Predznak    :" GET _predzn VALID _predzn<=1 .and. _predzn>=-1 PICT "99"
      @ m_x+ 7, m_y+2 SAY PADR(cPIImeKP+"2",12)+":" GET _id2
      @ m_x+ 8, m_y+2 SAY "K2(  /Sn/An):" GET _k2
      @ m_x+ 9, m_y+2 SAY "Formula2    :" GET _fi2 PICT "@S60"
      @ m_x+10, m_y+2 SAY "Predznak2   :" GET _predzn2 VALID _predzn2<=1 .and. _predzn2>=-1 PICT "99"
      @ m_x+11, m_y+2 SAY "OPIS        :" GET _opis  when {|| .t.} valid {|| .t.}
      @ m_x+12, m_y+2 SAY "PODVUCI( /x):" GET _podvuci
      IF FIELDPOS("K1")<>0
        @ m_x+13, m_y+2 SAY "K1          :" GET _k1
        @ m_x+14, m_y+2 SAY "U1 ( ,>0,<0):" GET _u1
      ENDIF
      READ
     BoxC()
     n1:=_ri
     IF LASTKEY()!=K_ESC
       Gather()
       // DbfRBrSort(n0,n1,"RI",RECNO())
       lVrati:=DE_REFRESH
     ENDIF
   CASE Ch==K_CTRL_N             // nova stavka
     Box(,15,77)
     SET KEY K_ALT_R TO UzmiIzPreth()
     DO WHILE .t.
       nRec:=RECNO()
       GO BOTTOM
       i:=ri; SKIP 1
       Scatter()
       _izv:=cBrI
       _ri:=i+1
       n0:=_ri
        @ m_x, m_y+2 SAY "UNOS NOVE STAVKE - IZVJESTAJ "+cBrI
        @ m_x+ 2, m_y+2 SAY "Redni broj  :" GET _ri PICT "9999"
        @ m_x+ 3, m_y+2 SAY PADR(cPIImeKP,12)+":" GET _id
        @ m_x+ 4, m_y+2 SAY "K(  /Sn/An) :" GET _k
        @ m_x+ 5, m_y+2 SAY "Formula     :" GET _fi PICT "@S60"
        @ m_x+ 6, m_y+2 SAY "Predznak    :" GET _predzn VALID _predzn<=1 .and. _predzn>=-1 PICT "99"
        @ m_x+ 7, m_y+2 SAY PADR(cPIImeKP+"2",12)+":" GET _id2
        @ m_x+ 8, m_y+2 SAY "K2(  /Sn/An):" GET _k2
        @ m_x+ 9, m_y+2 SAY "Formula2    :" GET _fi2 PICT "@S60"
        @ m_x+10, m_y+2 SAY "Predznak2   :" GET _predzn2 VALID _predzn2<=1 .and. _predzn2>=-1 PICT "99"
        @ m_x+11, m_y+2 SAY "OPIS        :" GET _opis  when {|| .t.} valid {|| .t.}
        @ m_x+12, m_y+2 SAY "PODVUCI( /x):" GET _podvuci
        IF FIELDPOS("K1")<>0
          @ m_x+13, m_y+2 SAY "K1          :" GET _k1
          @ m_x+14, m_y+2 SAY "U1 ( ,>0,<0):" GET _u1
        ENDIF
        READ
       n1:=_ri
       IF LASTKEY()!=K_ESC
         APPEND BLANK
         Gather()
         // DbfRBrSort(n0,n1,"RI",RECNO())
         lVrati:=DE_REFRESH
       ELSE
         GO BOTTOM
         EXIT
       ENDIF
     ENDDO
     SET KEY K_ALT_R TO
     BoxC()
   CASE Ch==K_CTRL_I             // iskljucenje (nuliranje) po uslovu
     cUslov:=SPACE(80)
     Box(,4,77)
     DO WHILE .t.
      @ m_x+2, m_y+2 SAY "Uslov za nuliranje stavki (za "+cPIImeKP+"):"
      @ m_x+3, m_y+2 GET cUslov PICT "@S70"
      READ
      aUslov:=Parsiraj(cUslov,"ID","C")
      IF aUslov<>NIL .or. LASTKEY()==K_ESC; EXIT; ENDIF
     ENDDO
     BoxC()
     IF LASTKEY()!=K_ESC
       i:=0
       dbGoTop()
       SEEK cBrI
       DO WHILE !EOF() .and. izv==cBrI
         SKIP 1; nSRec:=RECNO(); SKIP -1
         IF ri<>0 .and. &aUslov
           Scatter(); _ri:=0; Gather()
         ELSEIF ri<>0
           ++i
           Scatter(); _ri:=i; Gather()
         ENDIF
         GO (nSRec)
       ENDDO
       lVrati:=DE_REFRESH
     ENDIF

   CASE Ch==K_CTRL_T
     IF Pitanje(,"Zelite li izbrisati ovu stavku ?","D")=="D"
       n0:=ri
       DELETE
       // DbfRBrSort(n0,0,"ri",RECNO())     // recno() je ovdje nebitan
       lVrati:=DE_REFRESH
     ENDIF
 ENDCASE
RETURN lVrati





STATIC PROCEDURE UzmiIzPreth()
 LOCAL nRec:=RECNO()
 GO BOTTOM
 _id:=id; _id2:=id2; _k:=k; _k2:=k2; _fi:=fi; _fi2:=fi2; _opis:=opis
 _predzn:=predzn; _predzn2:=predzn2; _podvuci:=podvuci
 GO (nRec)
 AEVAL(GetList,{|o| o:display()})
RETURN




FUNCTION TxtUKod(cTxt,cBUI)
 LOCAL lPrinter:=SET(_SET_PRINTER,.t.)
 LOCAL nRow:=PROW(), nCol:=PCOL()
 IF "B" $ cBUI; gPB_ON(); ENDIF
 IF "U" $ cBUI; gPU_ON(); ENDIF
 IF "I" $ cBUI; gPI_ON(); ENDIF
 SETPRC(nRow,nCol)
 SET(_SET_PRINTER,lPrinter)
 ?? cTxt
 lPrinter:=SET(_SET_PRINTER,.t.); nRow:=PROW(); nCol:=PCOL()
 IF "B" $ cBUI; gPB_OFF(); ENDIF
 IF "U" $ cBUI; gPU_OFF(); ENDIF
 IF "I" $ cBUI; gPI_OFF(); ENDIF
 SETPRC(nRow,nCol)
 SET(_SET_PRINTER,lPrinter)
RETURN ""



FUNCTION StKod(cKod)
  Setpxlat(); qqout(cKod); konvtable()
RETURN ""




PROCEDURE RazvijUslove(cUsl)
 LOCAL nPoz:=0, i:=0
 PRIVATE cPom:=""
 DO WHILE .t.
   nPoz:=AT("#",cUsl)
   cPom:="USL"+ALLTRIM(STR(++i))
   IF nPoz>0
     REPLACE &cPom WITH LEFT(cUsl,nPoz-1)
     cUsl := SUBSTR(cUsl,nPoz+1)
   ELSE
     REPLACE &cPom WITH TRIM(cUsl)
     EXIT
   ENDIF
 ENDDO
RETURN



FUNCTION PreformIznos(x,y,z)
  LOCAL xVrati:=""
  IF INT(x)==x     // moze format bez decimala
    xVrati:=STR(x,y)
  ELSE             // ide format sa decimalama ukoliko su zadane
    xVrati:=STR(x,y,z)
  ENDIF
RETURN xVrati



STATIC FUNCTION RacForm(cForm,cSta)
LOCAL nVrati:=0, nRec:=RECNO(), nPoz:=0, cAOP:=""
PRIVATE cForm77:=ALLTRIM(SUBSTR(cForm,2))
DO WHILE .t.
  nPoz:=AT("ST",cForm77)
  IF nPoz>0
    cAOP:=""
    DO WHILE .t.
      IF LEN(cForm77)>=nPoz+2 .and. SUBSTR(cForm77,nPoz+2,1)$"0123456789"
        cAOP+=SUBSTR(cForm77,nPoz+2,1)
        ++nPoz
      ELSE
        EXIT
      ENDIF
    ENDDO
    cForm77:=STRTRAN(cForm77,"ST"+cAOP,"("+ALLTRIM(STR(CupajAOP(cAOP,cSta)))+")",1,1)
    IF !lObradjen
      EXIT
    ENDIF
  ELSE
    EXIT
  ENDIF
ENDDO
IF lObradjen
  nVrati:=&cForm77
ENDIF
GO (nRec)
RETURN nVrati


STATIC FUNCTION CupajAOP(cAOP,cSta)
  LOCAL nVrati:=0
  PRIVATE cSta77:=cSta
  HSEEK PADL(cAOP,5)
  IF FOUND()
    IF EMPTY(U1)
      nVrati:=&cSta77
    ELSE
      cPUTS:=cSta77+TRIM(U1)
      IF &cPUTS
        nVrati:=&cSta77
      ENDIF
    ENDIF
    IF LEFT(uslov,1)=="="
      lObradjen:=.f.
    ENDIF
  ENDIF
RETURN nVrati




// -------------------------------------------------------------
// otvara tabelu sifranika koja je zadata u definicijama
// -------------------------------------------------------------
function O_KSif()
local _area := F_KSif()

select ( _area )

my_use( LOWER( cPIKSif ) )
set order to tag "ID"

return


// -------------------------------------------------------------
// vraca podrucje sifrarnika zadatog u definicijama
// -------------------------------------------------------------
function F_KSif()
return F_Baze( cPIKSif )





// -------------------------------------------------------------
// selektuje bazu zadatu definicijom
// -------------------------------------------------------------
function Sel_KSif()
Sel_Bazu( cPIKSif )
return




// -------------------------------------------------------------
// vraca vrijednost polja iz tabele zadate definicijom
// -------------------------------------------------------------
function IzKSif(cPolje)
PRIVATE cPom:=cPIKSif+"->"+cPolje
RETURN (&cPom)




// -------------------------------------------------------------
// otvara kumulativnu bazu zadatu u definicijama
// -------------------------------------------------------------
function O_KBaza()
local _area := F_KBAZA()

select ( _area )
my_use( LOWER( cPIKBaza ) )

return


// -------------------------------------------------------------
// vraca podrucje kumulativne baze
// -------------------------------------------------------------
function F_KBaza()
return F_Baze( cPIKBaza )



// -------------------------------------------------------------
// selektuje kumulativnu bazu
// -------------------------------------------------------------
function Sel_KBaza()
Sel_Bazu(cPIKBaza)
return



// -------------------------------------------------------------
// vraca polje iz kumulativne tabele
// -------------------------------------------------------------
function IzKBaza(cPolje)
private cPom := cPIKBaza + "->" + cPolje
return (&cPom)




function PripKBPI()

IF cPIKSif != "BEZ"
    O_KSif()
ENDIF
  
SELECT IZVJE                    // u sifrarniku pozicioniramo se
SET ORDER TO TAG "ID"
  
SEEK cBrI                       // na trazeni izvjestaj
IF !EMPTY(IZVJE->uslov)
    cFilter+=".and.("+ALLTRIM(IZVJE->uslov)+")"
ENDIF

cFilter:=CistiTacno(cFilter)
  
O_KBaza()
  
IF cPIKIndeks=="BEZ"
    SET ORDER TO
    SET FILTER TO
    SET FILTER TO &cFilter
ELSEIF UPPER(LEFT(cPIKIndeks,3))=="TAG"
    SET ORDER TO TAG (SUBSTR(cPIKIndeks,4))     // idkonto
    SET FILTER TO
    SET FILTER TO &cFilter
ELSE
    INDEX ON &cPIKIndeks TO "KBTEMP" FOR &cFilter
ENDIF

RETURN




function StTabPI()
local nRed := 1
local aKol := {}
  
SELECT KOLIZ
dbGoTop()
  
DO WHILE !EOF()

    IF ALLTRIM( KOLIZ->formula ) == '"#"'
        ++nRed
    ELSE
        nRed:=1
    ENDIF

    cPom77 := "{|| " + KOLIZ->formula + " }"

    AADD( aKol , { KOLIZ->naz , &cPom77. , KOLIZ->sumirati=="D" ,;
                   ALLTRIM(KOLIZ->tip) , KOLIZ->sirina , KOLIZ->decimale ,;
                   nRed , KOLIZ->rbr  } )
    SKIP 1
ENDDO

IF lIzrazi
    // potrebna dorada ka univerzalnosti (polje TEKSUMA ?)
    // ---------------------------------------------------
    SELECT POM
    SET ORDER TO TAG "3"

    nProlaz:=0
    DO WHILE .t.

        lJos:=.f.

        ++nProlaz

        if nProlaz>10
            MsgBeep("Greska! Rekurzija(samopozivanje) u formulama tipa '=STXXX+STYYY...'!")
            EXIT
        endif

        dbGoTop()
        DO WHILE !EOF()
            IF LEFT(uslov,1)=="="
                PRIVATE lObradjen:=.t.
                REPLACE POM->TEKSUMA WITH RacForm(uslov,"TEKSUMA")
                IF lObradjen
                    REPLACE uslov WITH SUBSTR(uslov,2)
                ELSE
                    lJos:=.t.
                    SKIP 1
                    LOOP
                ENDIF
            ENDIF

            IF !EMPTY(U1)
                PRIVATE cPUTS
                cPUTS:="TEKSUMA"+TRIM(U1)  // U1 JE USLOV
                IF &cPUTS
                    uTekSuma:=ABS(TEKSUMA)
                ELSE
                    uTekSuma:=0
                ENDIF
                REPLACE TEKSUMA WITH uTekSuma,;
                   U1      WITH SPACE(LEN(U1))
            ENDIF

            SKIP 1
        ENDDO

        IF !lJos
            EXIT
        ENDIF

    ENDDO

ENDIF

SELECT POM
SET ORDER TO
dbGoTop()
  
cPodvuci:=" "
IF cPrikBezDec=="D"
    gbFIznos:={|x,y,z| PreformIznos(x,y,z)}
ELSE
    gbFIznos:=NIL
ENDIF

PRIVATE uTekSuma := 0

StampaTabele( aKol, {|| FSvakiPI() },, gTabela,,,,{|| FForPI() }, IF( gOstr == "D",, -1 ),,,,,)

IF nBrRedStr > -99
    gPO_Port()
    gPStranica := nBrRedStr
ENDIF

EndPrint()

return


function StZagPI()
LOCAL xKOT:=0

StartPrint()  
  
SELECT ZAGLI
SET FILTER TO
SET FILTER TO id==cBrI
SET ORDER TO TAG "1"
  
dbGoTop()
xKOT:=PROW()
DO WHILE !EOF()
    IF "GPO_LAND()" $ UPPER(ZAGLI->izraz)
       nBrRedStr  := gPStranica
       gPStranica := nKorZaLands
    ENDIF
    cPom77 := ZAGLI->izraz
    @ xKOT+ZAGLI->x1, ZAGLI->y1 SAY ""
    @ xKOT+ZAGLI->x1, ZAGLI->y1 SAY &cPom77
    SKIP 1
ENDDO

RETURN


static function prombroj()
local i,cstbroj,cnbroj
MsgBeep("Nije jos implementirano ...")
return




function QOPodv(cT)
 ? cT
 ? REPL("-",LEN(cT))
RETURN

FUNCTION DoHasha(cT)
  LOCAL n:=AT("#",cT)
RETURN IF(n=0,cT,LEFT(cT,n-1))



FUNCTION CistiTacno(cFilter)
  LOCAL nT:=0, cSta:="", nZ:=0, nP:=0, cPom:=""
  cSta:="Tacno("
  nT:=AT(cSta,cFilter)
  IF nT>0
    nZ:=1
    nP:=nT+LEN(cSta)
    DO WHILE nZ>0
      cPom:=SUBSTR(cFilter,nP,1)
      IF cPom=="("; ++nZ; ENDIF
      IF cPom==")"; --nZ; ENDIF
      IF LEN(cPom)<1; EXIT; ENDIF
      IF nZ>0; ++nP; ENDIF
    ENDDO
    cSta:=SUBSTR(cFilter,nT,nP-nT+1)
    cPom777:=SUBSTR(cSta,7); cPom777:=LEFT(cPom777,LEN(cPom777)-1)
    cFilter:=STRTRAN(cFilter,cSta,&cPom777)
  ENDIF
RETURN cFilter




function OProizv()
O_KOLIZ
O_KONIZ
O_ZAGLI
O_IZVJE
return



