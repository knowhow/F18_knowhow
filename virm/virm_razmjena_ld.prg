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


#include "virm.ch"

function virm_prenos_ld()
// ovom procedurom cu uzeti iz pripreme zeljena konta i baciti ih u
// virmane

O_BANKE
O_JPRIH
O_SIFK
O_SIFV
O_KRED
O_REKLD
O_PARTN
O_VRPRIM
O_LDVIRM
O_VIRM_PRIPR

cKome_Txt := ""
lOpresa := .f. 
cPozBr := ""

qqKonto := PADR( "6;", 60 )
dDatVir := DATE()

private _godina := fetch_metric( "virm_godina", my_user(), STR(YEAR(DATE()), 4 ) )
private _mjesec := fetch_metric( "virm_mjesec", my_user(), STR(MONTH(DATE()), 2 ) ) 
private cBezNula := "D"
private cIsplPos := "N"

cPNaBr := fetch_metric( "virm_poziv_na_broj", my_user(), PADR( "", 10 ) ) 

// dodati na opis "plate za mjesec ...."
cOpisPlus1 := fetch_metric( "virm_dodatni_opis_virmana_1", nil, "N" ) 
cOpisPlus2 := fetch_metric( "virm_dodatni_opis_virmana_2", nil, "N" ) 

cKo_ZR := fetch_metric( "virm_zr_uplatioca", my_user(), SPACE(16) ) 

dPod := CTOD("")
dPdo := CTOD("")


Box(,10,70)

    @ m_x + 1, m_y + 2 SAY "PRENOS REKAPITULACIJE IZ LD -> VIRM"

    cIdBanka := PADR( cKo_zr, 3 )

    @ m_x + 2, m_y + 2 SAY "Posiljaoc (sifra banke):       " GET cIdBanka valid OdBanku( gFirma, @cIdBanka )
    read

    cKo_zr := cIdBanka

    select partn 
    seek gFirma

    select virm_pripr

    cKo_txt := TRIM(partn->naz) + ", " + TRIM(partn->mjesto) + ", " + TRIM(partn->adresa) + ", " + TRIM(partn->telefon)

    @ m_x+3,m_y+2 SAY "Poziv na broj " GET cPNABR
    @ m_x+4,m_y+2 SAY "Godina" GET _godina pict "9999"
    @ m_x+5,m_y+2 SAY "Mjesec" GET _mjesec  pict "99"
    @ m_x+7,m_y+2 SAY "Datum" GET dDatVir
    @ m_x+8,m_y+2 SAY "Porezni period od" GET dPOd
    @ m_x+8,col()+2 SAY "do" GET dPDo
    @ m_x+9,m_y+2 SAY "Isplate prebaciti pojedinacno za svakog radnika (D/N)?" GET cIsplPos VALID cIsplPos$"DN" PICT "@!"
    @ m_x+10,m_y+2 SAY "Formirati samo stavke sa iznosima vecim od 0 (D/N)?" GET cBezNula VALID cBezNula$"DN" PICT "@!"
    
    read

    ESC_BCR

BoxC()
    
set_metric( "virm_zr_uplatioca", my_user(), cKo_zr ) 
set_metric( "virm_godina", my_user(), _godina )
set_metric( "virm_mjesec", my_user(), _mjesec ) 
set_metric( "virm_poziv_na_broj", my_user(), cPNaBr ) 

if cOpisPlus1 == "D"
    cDOpis := ", za " + STR(_MJESEC,2)+"." +str(_godina,4)
else
    cDOpis := ""
endif

cDOBrRad:=""  // opis, broj radnika

SELECT LDVIRM
GO TOP

nRbr:=0

DO WHILE !EOF()

     private cFormula := formula
     
     // nema formule - preskoci...
     if EMPTY(cFormula)
        skip
        loop
     endif
     
     cSvrha_pl:=id

     select VRPRIM
     hseek ldvirm->id

     select partn
     hseek gFirma

     select virm_pripr
    
     nFormula := &cFormula  
     // npr. RLD("DOPR1XZE01")

     select virm_pripr

     IF cBezNula=="N" .or. nFormula > 0

       APPEND BLANK
       replace rbr with ++nrbr, ;
               mjesto with gmjesto,;
               svrha_pl with csvrha_pl,;
               iznos with nFormula,;
               PnaBR with cPNABR,;
               VUpl with '0'

       // posaljioc
       replace na_teret with gFirma,;
               Ko_Txt with cKo_TXT,;
               Ko_ZR with cKo_ZR ,;
               mjesto with gMjesto ,;
               kome_txt with VRPRIM->naz


       cPomOpis := trim(VRPRIM->pom_txt)+IF(!EMPTY(cDOpis)," "+cDOpis,"")+;
                   IF(!EMPTY(cDOBrRad) .and. cOpisPlus2=="D" ,", "+cDOBrRad,"")

       private _kome_zr:=""
       _kome_txt:=""
       _budzorg:=""
       
       if vrprim->idpartner="JP  " // javni prihodi
          // setuj varijable _kome_zr, _kome_txt , _budzorg
          SetJPVar()
          cKome_zr:=_kome_zr
          cKome_txt:=_kome_txt
          cBudzOrg:=_BudzOrg
          cBPO:=gOrgJed  
          // iskoristena za broj poreskog obveznika
       else
          if vrprim->dobav=="D"
             cKome_ZR:=padr(cKome_ZR,3)
             select partn
             seek vrprim->idpartner
             select virm_pripr
             MsgBeep("Odrediti racun za partnera :"+vrprim->idpartner)
             OdBanku(vrprim->idpartner,@cKome_ZR)
          else
             ckome_zr:=vrprim->racun
          endif
          cBudzOrg:="" ; cBPO:=""
          dPod:=ctod(""); dPDO:=ctod("")
          cPorDBR:=""
          cBPO:=""
       endif
       replace kome_zr with cKome_zr,;
               dat_upl with dDatVir,;
               svrha_doz with cPomOpis,;
               POD with dPOD, PDO with dPDO,;
               budzorg with cBudzOrg,;
               BPO with cBPO

     ENDIF

     SELECT LDVIRM
     SKIP 1

ENDDO //LDVIRM


// odraditi kredite
select REKLD
seek str(_godina,4)+str(_mjesec,2)+"KRED"
do while !eof() .and. id="KRED"

     cIdKred:=substr(id,5)  // sifra kreditora

     select kred;   hseek padr(cidkred,len(kred->id))
     // partija kreditora
     cOpresa1 := KRED->zirod
     cOpresa2 := ""
     select partn;  hseek padr(cidkred,len(partn->id))
     if !found()  // dodaj kreditora u listu partnera
         append blank
         replace id with kred->id ,;
                 naz with kred->naz ,;
                 ziror with kred->ziro

                 //dziror with kred->zirod
     endif
     select vrprim; hseek PADR("KR",LEN(id))  // SPECIJALNA SIFRA ZA KREDITE
     if !found()
       APPEND BLANK
       replace id with "KR",;
               naz with "KREDIT",;
               pom_txt with "Kredit",;
               NACIN_PL WITH "1",;
               DOBAV WITH "D"
     endif

     // VRPRIM->dobav=="D"
     cSvrha_pl:=id
     select partn
     seek CIDKRED
     cU_korist:=id
     cKome_txt:=naz
     cKome_sj:=mjesto
     cNacPl:="1"

     cKome_ZR:=space(16)
     OdBanku(cU_korist,@cKome_ZR, .f.)

     select virm_pripr; go top   // uzmi podatke iz prve stavke
     cKo_Txt:=ko_txt
     cKo_ZR :=ko_zr

     select partn;hseek  gFirma

     nRekLDI1:=0
       nKrOpresa:=0
       SELECT REKLD
       cSKOpresa := idpartner // SK=sifra kreditora
       DO WHILE !EOF() .and. id="KRED" .and. IDPARTNER=cSKOpresa
         ++nKrOpresa
         cOpresa2:=rekld->opis2
         nRekLDI1 += rekld->iznos1
         SKIP 1
       ENDDO
       SKIP -1

     select virm_pripr
     IF cBezNula=="N" .or. nRekLDI1>0
       APPEND BLANK
       replace rbr with ++nrbr, ;
               mjesto with gmjesto,;
               svrha_pl with "KR",;
               iznos with nRekLDI1,;
               na_teret  with gFirma,;
               kome_txt with ckome_txt ,;
               ko_txt   with cKo_txt,;
               ko_zr    with cKo_zr,;
               kome_sj  with ckome_sj,;
               kome_zr with ckome_zr,;
               dat_upl with dDatVir,;
               svrha_doz with trim(VRPRIM->pom_txt)+" "+cDOpis,;
               U_KORIST WITH cidkred  // SIFRA KREDITORA

        // popuniti podatke o partiji kredita
        if lOpresa
         if nKrOpresa>1 // vise radnika za jednog kreditora, zajednicka part.
           if !empty(cOpresa1)
              replace svrha_doz with trim(svrha_doz) +", Partija "+ TRIM(cOpresa1)
           endif
         else
           // jedan radnik
           replace svrha_doz with trim(svrha_doz) +", "+trim(cOpresa2)+", Partija:"+TRIM(REKLD->opis)
         endif
       endif        
     ENDIF
  SELECT REKLD
  skip
enddo

// odraditi isplate na tekuci racun
select REKLD
seek str(_godina,4)+str(_mjesec,2)+"IS_"

do while !eof() .and. id="IS_"

    cIdKred:=substr(id,4)  // sifra banke

        select kred
        hseek padr(cidkred,len(kred->id))
     
        // partija kreditora / banke
        cOpresa1 := KRED->zirod
        cOpresa2 := ""
     
        select partn
        hseek padr(cidkred,len(partn->id))
     
        if !found()  
            // dodaj kreditora u listu partnera
            append blank
            replace id with kred->id ,;
                    naz with kred->naz ,;
                    ziror with kred->ziro
        endif
     
        select vrprim
        hseek PADR("IS",LEN(id))  
        // SPEC.SIFRA ZA ISPLATU NA TR
     
        if !found()
            APPEND BLANK
            replace id with "IS",;
                    naz with "ISPLATA NA TEKUCI RACUN",;
                    pom_txt with "Plata",;
                    NACIN_PL WITH "1",;
                    DOBAV WITH "D"
        endif

        // VRPRIM->dobav=="D"
        cSvrha_pl:=id
        select partn
        seek CIDKRED
        cU_korist:=id
        cKome_txt:=naz
        cKome_sj:=mjesto
        cNacPl:="1"

        //cKome_zr:=ziror
        cKome_ZR:=space(16)
        OdBanku(cU_korist,@cKome_ZR, .f.)

        select virm_pripr
        go top   
        // uzmi podatke iz prve stavke
        cKo_Txt:=ko_txt
        cKo_ZR :=ko_zr

        select partn
        hseek  gFirma

        nRekLDI1 := 0
        nKrOpresa := 0
     
        SELECT REKLD
        cSKOpresa := idpartner 
    // SK=sifra kreditora/banke
     
        // isplate za jednu banku - sumirati
        if cIsplPos == "N"

            DO WHILE !EOF() .and. id="IS_" .and. IDPARTNER=cSKOpresa
                ++nKrOpresa
                cOpresa2:=rekld->opis2
                nRekLDI1 += rekld->iznos1
                SKIP 1
            ENDDO
            SKIP -1
     
        else
     
        // svaka isplata ce se tretirati posebno
        nKrOpresa := 1
        nRekLDI1 := rekld->iznos1
        cOpresa2 := rekld->opis2

        endif

        select virm_pripr

        IF cBezNula == "N" .or. nRekLDI1 > 0
            
        APPEND BLANK
            replace rbr with ++nrbr, ;
                    mjesto with gmjesto,;
                    svrha_pl with "IS",;
                    iznos with nRekLDI1,;
                    na_teret  with gFirma,;
                    kome_txt with ckome_txt ,;
                    ko_txt   with cKo_txt,;
                    ko_zr    with cKo_zr,;
                    kome_sj  with ckome_sj,;
                    kome_zr with ckome_zr,;
                    dat_upl with dDatVir,;
                    svrha_doz with trim(VRPRIM->pom_txt)+" "+cDOpis,;
                    U_KORIST WITH cidkred  // SIFRA BANKE

                // popuniti podatke o partiji kredita

            if nKrOpresa > 1 
            // vise radnika za jednog kreditora, zajednicka part.
                if !empty(cOpresa1)
                        replace svrha_doz with trim(svrha_doz)
                endif
            else
                // jedan radnik
                replace svrha_doz with trim(svrha_doz) +", "+trim(cOpresa2)+", Tekuci rn:"+TRIM(REKLD->opis)
            endif
        ENDIF
    
    SELECT REKLD
    skip

enddo


// odraditi autorske honorare
// "NETO"
select REKLD
seek str(_godina,4) + str(_mjesec,2) + "NETO"

if FOUND() .and. rekld->(FIELDPOS("izdanje")) <> 0

   do while !eof() .and. id = "NETO"

    cAutor := idpartner
    cAutNaz := ALLTRIM(opis2)
    
    // aKreditor := { kreditor_id, broj_racuna, partija }
    aKreditor := TokToNiz( opis, "#" )
    
    cKredId := aKreditor[1]
    cRadnBrRn := PADR(aKreditor[2], 16)
    
    if LEN(aKreditor) > 2
        cRadnPart := " partija: " + aKreditor[3]
    else
        cRadnPart := ""
    endif

    select partn
    hseek PADR(cAutor, LEN(partn->id))

    if !FOUND()
        append blank
        replace id with cAutor
        replace naz with cAutNaz
        replace ziror with cRadnBrRn
    endif

    select vrprim
    hseek PADR("AH", LEN(id) ) 
        
    if !FOUND()
            APPEND BLANK
            replace id with "AH",;
                    naz with "Autorski honorar",;
                    pom_txt with "Autorski honorar",;
                    nacin_pl WITH "1",;
                    dobav WITH "D"
        endif

    cSvrha_pl := id
    
        select partn
        seek cAutor

    cU_korist := cAutor
        cKome_txt := cAutNaz
        cKome_sj := mjesto
        cNacPl := "1"
    cKome_ZR := cRadnBrRn

        select virm_pripr
    go top   
        
    cKo_Txt := ko_txt
        cKo_ZR := ko_zr

        select rekld
    
        nAIzn := 0
    
    do while !EOF() .and. id = "NETO" .and. idpartner = cAutor
    
        nAIzn += rekld->iznos1
        skip 1
        
        enddo
    
        select virm_pripr
        
    IF cBezNula == "N" .or. nAIzn > 0
    
            append blank
            replace rbr with ++nRbr, ;
                    mjesto with gMjesto,;
                    svrha_pl with "AH",;
                    iznos with nAIzn,;
                    na_teret with gFirma,;
                    kome_txt with cKome_txt ,;
                    ko_txt   with cKo_txt,;
                    ko_zr    with cKo_zr,;
                    kome_sj  with cKome_sj,;
                    kome_zr with cKome_zr,;
                    dat_upl with dDatVir,;
                    svrha_doz with TRIM(VRPRIM->pom_txt) + " " + cDOpis,;
                    u_korist WITH cAutor

            replace svrha_doz with trim(svrha_doz) + ;
            ", " + cRadnPart 
            
        endif
    
    select rekld
    //skip
    
   enddo
endif

FillJPrih()  // popuni polja javnih prihoda

closeret


// --------------------------------------------
// RLD, funkcija koju zadajemo 
// kao formulu pri prenosu...
// --------------------------------------------
function RLD(cId, nIz12, qqPartn)
local nPom1:=0
local nPom2:=0

if nIz12 == NIL
    nIz12:=1
endif

// prolazim kroz rekld i trazim npr DOPR1XSA01
rekapld(cId, _godina, _mjesec, @nPom1, @nPom2, , @cDOBrRad, qqPartn)

if nIz12 == 1
    return nPom1
else
    return nPom2
endif

return 0



// --------------------------------------
// Rekapitulacija LD-a
// --------------------------------------
static function Rekapld( cId, ;
        nGodina, ;
        nMjesec, ;
        nIzn1, ;
        nIzn2, ;
        cIdPartner, ;
        cOpis, ;
        qqPartn )

local lGroup := .f.

PushWA()

if cIdPartner == NIL
    cIdPartner := ""
endif
if cOpis == NIL
    cOpis := ""
endif

// ima li marker "*"
if "**" $ cId
    lGroup := .t.
    // izbaci zvjezdice..
    cId := STRTRAN(cId, "**", "")
endif

select rekld
go top

if qqPartn == NIL
    
    hseek STR(nGodina, 4) + STR(nMjesec, 2) + cId
    
    if lGroup == .t.
    
        do while !EOF() .and. STR(nGodina, 4) == godina ;
                .and. STR(nMjesec, 2) == mjesec ;
                .and. id = cId
        
                nIzn1 += iznos1
                nIzn2 += iznos2
        
                skip
        enddo
        
    else
        nIzn1 := iznos1
        nIzn2 := iznos2
    endif
    
    cIdPartner:=idpartner
    cOpis:=opis

else
    nIzn1 := nIzn2 := nRadnika := 0
    aUslP := Parsiraj(qqPartn,"IDPARTNER")
    seek STR(nGodina, 4) + STR(nMjesec, 2) + cId
    do while !eof() .and.;
            godina+mjesec+id = STR(nGodina, 4) + STR(nMjesec, 2) + cId
        if &aUslP
                nIzn1 += iznos1
                nIzn2 += iznos2
                if LEFT(opis,1)=="("
                    cOpis    := opis
                    cOpis    := STRTRAN(cOpis,"(","")
                    cOpis    := ALLTRIM(STRTRAN(cOpis,")",""))
                    nRadnika += VAL(cOpis)
                endif
        endif
        skip 1
    enddo
    
    cIdPartner:=""
    IF nRadnika>0
        cOpis:="("+ALLTRIM(STR(nRadnika))+")"
    ELSE
        cOpis:=""
    ENDIF
endif

PopWA()
return



