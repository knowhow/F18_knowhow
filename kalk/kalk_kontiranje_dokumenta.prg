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


#include "kalk.ch"

static dDatMax

 
// -----------------------------------------------------------------------
// kontiranje naloga 
//
// fAuto - .t. automatski se odrjedjuje broj naloga koji se formira, 
//         .f. getuje se broj formiranog naloga - default vrijednost
// lAGen - automatsko generisanje
// lViseKalk - vise kalkulacija
// cNalog - broj naloga koji ce se uzeti, ako je EMPTY() ne uzima se !
// -----------------------------------------------------------------------
function kalk_kontiranje_naloga( fAuto, lAGen, lViseKalk, cNalog, auto_brojac )
local cIdFirma
local cIdVd
local cBrDok
local lAFin
local lAMat
local lAFin2
local lAMat2
local nRecNo
local lPrvoDzok := ( fetch_metric( "kalk_kontiranje_prioritet_djokera", nil, "N" ) == "D" )
local _fakt_params := fakt_params()
private lVrsteP := _fakt_params["fakt_vrste_placanja"]

if ( lAGen == NIL )
    lAGen := .f.
endif

if ( lViseKalk == NIL )
    lViseKalk :=.f.
endif

if ( dDatMax == NIL )
    dDatMax := CTOD("")
endif

if ( cNalog == NIL )
    cNalog := ""
endif

if ( auto_brojac == NIL )
    auto_brojac := .t.
endif

SELECT F_SIFK
if !USED()
    O_SIFK
endif

SELECT F_SIFV
if !USED()
    O_SIFV
endif

SELECT F_ROBA
if !used()
    O_ROBA
endif

SELECT F_FINMAT
if !used()
    O_finmat
endif

SELECT F_TRFP
if !used()
    O_TRFP
endif

SELECT F_KONCIJ
if !used()
    O_KONCIJ
endif

IF FIELDPOS( "IDRJ" ) <> 0
    lPoRj := .t.
ELSE
    lPoRj := .f.
ENDIF

SELECT F_VALUTE
if !used()
    O_VALUTE
endif

if fAuto == NIL
    fAuto := .f.
endif

lAFin := ( fauto .and. gAFin == "D" )

if lAFin

    Beep(1)
    
    if !lAGen
        lAfin := Pitanje(,"Formirati FIN nalog?","D") == "D"
    else 
        lAfin := .t.
    endif
    
endif

lAFin2 := ( !fAuto .and. gAFin <> "0" )
lAMat := ( fAuto .and. gAMat == "D" )

if lAMat
    Beep(1)
    lAMat := Pitanje(, "Formirati MAT nalog?", "D") == "D"
    O_TRMP
endif

lAMat2 := ( !fAuto .and. gAMat <> "0" )

cBrNalF := ""
cBrNalM := ""

if lAFin .or. lAFin2

    O_FIN_PRIPR
    set order to tag "1"
    go top
    
    O_NALOG
    set order to tag "1"
    
endif

select finmat
go top

select koncij
go top
 
if finmat->idvd $ "14#94#96#95"
    seek TRIM( finmat->idkonto2 )
else
    seek TRIM( finmat->idkonto )
endif

select trfp
seek finmat->IdVD+koncij->shema

cIdVN := IdVN   
// uzmi vrstu naloga koja ce se uzeti u odnosu na prvu kalkulaciju
//  koja se kontira

if KONCIJ->(FIELDPOS("FN14"))<>0 .and. !EMPTY(KONCIJ->FN14) .and. finmat->IDVD=="14"
    cIdVN:=KONCIJ->FN14
endif

if lAFin .or. lAFin2

    if EMPTY( cNalog )
        
        if auto_brojac
		    cBrNalF := fin_novi_broj_dokumenta( finmat->idfirma, cIdVn ) 
        else
            cBrNalF := fin_prazan_broj_naloga()
        endif

    else
        // ako je zadat broj naloga taj i uzmi...
        cBrNalF := cNalog
    endif

endif

select finmat
go top

dDatNal := datdok

if lAGen == .f.

    Box("brn?",5,55)
    
    set cursor on

    if fAuto
        if !lAFin
            cBrNalF:=""
        else
            @ m_x+1,m_y+2  SAY "Broj naloga u FIN  "+finmat->idfirma+" - "+cidvn+" - "+cBrNalF
        endif
    
        if !lAMat
            cBrBalM:=""
        else
            if idvd<>"24" // kalkulacija usluge
                @ m_x+2,m_y+2 SAY "Broj naloga u MAT  "+finmat->idfirma+" - "+cidvn+" - "+cBrNalM
            endif
        endif
    
        @ m_x + 4, m_y + 2 SAY "Datum naloga: "
        
        ?? dDatNal
    
        if lAFin .or. lAMat
            inkey(0)
        endif
    
    else
        if lAFin2
            @ m_x+1,m_y+2 SAY "Broj naloga u FIN  "+finmat->idfirma+" - "+cidvn+" -" GET cBrNalF
        endif
    
        if idvd <> "24" .and. lAMat2
            @ m_x+2,m_y+2 SAY "Broj naloga u MAT  "+finmat->idfirma+" - "+cidvn+" -" GET cBrNalM
        endif

        @ m_x+5,m_y+2 SAY "(ako je broj naloga prazan - ne vrsi se kontiranje)"
        read
        ESC_BCR
    endif

    BoxC()

endif

nRbr := 0
nRbr2 := 0

MsgO("Prenos KALK -> FIN")

select finmat
private cKonto1 := NIL

do while !EOF()
    
    // datoteka finmat
    cIDVD := IdVD
    cBrDok := BrDok
 
    if valtype(cKonto1) <> "C"
        private cKonto1:=""
        private cKonto2:=""
        private cKonto3:=""
        private cPartner1:=cPartner2:=cPartner3:=cPartner4:=cPartner5:=""
        private cBrFakt1:=cBrFakt2:=cBrFakt3:=cBrFakt4:=cBrFakt5:=SPACE(10)
        private dDatFakt1:=dDatFakt2:=dDatFakt3:=dDatFakt4:=dDatFakt5:=CTOD("")
        private cRj1:=""
        private cRj2:=""
    endif

    private dDatVal := CTOD("") 
    // inicijalizuj datum valute
    private cIdVrsteP := "  "    
    // i vrstu placanja

    do while cIdVD==IdVD .and. cBrDok==BrDok .and. !eof()
        
        lDatFakt:=.f.   
     
        select koncij
        go top

        if finmat->idvd $ "14#94#96#95"
            seek finmat->idkonto2
        else
            seek finmat->idkonto
        endif
     
        select roba
        hseek finmat->idroba

        select trfp
        go top
        seek cIdVD + koncij->shema

        do while !EOF() .and. !EMPTY( cBrNalF ) .and. field->idvd == cIDVD  .and. field->shema == koncij->shema
        
            lDatFakt := .f.
            cStavka := Id
            
            select finmat
            nIz := &cStavka
            
            select trfp
            
            if !empty( trfp->idtarifa ) .and. trfp->idtarifa<>finmat->idtarifa
                // ako u {ifrarniku parametara postoji tarifa prenosi po tarifama
                nIz := 0
            endif

            if empty( trfp->idtarifa ) .and. roba->tip $ "U"
                // roba tipa u,t
                nIz := 0
            endif
     
            // iskoristeno u slucaju RN, gdje se za kontiranje stavke
            // 901-999 koriste sa tarifom XXXXXX
            if finmat->idtarifa == "XXXXXX" .and. trfp->idtarifa <> finmat->idtarifa
                nIz := 0
            endif

            if nIz <> 0  
                
                // ako je iznos elementa <> 0, dodaj stavku u fpripr
                if lPoRj
                    if TRFP->porj = "D"
                        cIdRj := KONCIJ->idrj
                    elseif TRFP->porj = "S"
                        cIdRj := KONCIJ->sidrj
                    else
                        cIdRj := ""
                    endif
                endif

                select fin_pripr

                if trfp->znak == "-"
                    nIz := -nIz
                endif
         
                if "#DF#" $ ( trfp->naz )
                    lDatFakt := .t.
                endif
          
                dDFDok := CTOD("")
                if lDatFakt
                    dDFDok := finmat->DatFaktP
                endif
      
                nIz2 := Round7( nIz, RIGHT( TRFP->naz, 2 ))
                nIz := Round7( nIz2, RIGHT( TRFP->naz, 2 ))


                if "IDKONTO"==padr(trfp->IdKonto,7)
                    cIdKonto:=finmat->idkonto
                elseif "IDKONT2"==padr(trfp->IdKonto,7)
                    cIdKonto:=finmat->idkonto2
                else
                    cIdKonto:=trfp->Idkonto
                endif

                IF lPrvoDzok
                    cPomFK777:=TRIM(gFunKon1)
                    cIdkonto:=STRTRAN(cidkonto,"F1",&cPomFK777)
                    cPomFK777:=TRIM(gFunKon2)
                    cIdkonto:=STRTRAN(cidkonto,"F2",&cPomFK777)

                    cIdkonto:=STRTRAN(cidkonto,"A1",right(trim(finmat->idkonto),1))
                    cIdkonto:=STRTRAN(cidkonto,"A2",right(trim(finmat->idkonto),2))
                    cIdkonto:=STRTRAN(cidkonto,"B1",right(trim(finmat->idkonto2),1))
                    cIdkonto:=STRTRAN(cidkonto,"B2",right(trim(finmat->idkonto2),2))
                ENDIF

                if (cIdkonto='KK')  .or.  (cIdkonto='KP')  .or. (cIdkonto='KO')
                    if right(trim(cIdkonto),3)=="(2)"  // gonjaj idkonto2
                        select koncij
                        nRecno:=recno()
                        seek finmat->idkonto2
                        cIdkonto:=strtran(cIdkonto,"(2)","")
                        cIdkonto:=koncij->(&cIdkonto)
                        select koncij
                        go nRecNo  
                        // vrati se na glavni konto
                        select fin_pripr 
                        // finansije, priprema
                    elseif right(trim(cIdkonto),3)=="(1)"  // gonjaj idkonto
                        select koncij
                        nRecNo:=recno()
                        seek finmat->idkonto
                        cIdkonto:=strtran(cIdkonto,"(1)","")
                        cIdkonto:=koncij->(&cIdkonto)
                        select koncij
                        go nRecNo   
                        // vrati se na glavni konto
                        select fin_pripr 
                        // finansije, priprema
                    else
                        cIdkonto:=koncij->(&cIdkonto)
                    endif

                elseif !lPrvoDzok
                    cPomFK777:=TRIM(gFunKon1)
                    cIdkonto:=STRTRAN(cidkonto,"F1",&cPomFK777)
                    cPomFK777:=TRIM(gFunKon2)
                    cIdkonto:=STRTRAN(cidkonto,"F2",&cPomFK777)

                    cIdkonto:=STRTRAN(cidkonto,"A1",right(trim(finmat->idkonto),1))
                    cIdkonto:=STRTRAN(cidkonto,"A2",right(trim(finmat->idkonto),2))
                    cIdkonto:=STRTRAN(cidkonto,"B1",right(trim(finmat->idkonto2),1))
                    cIdkonto:=STRTRAN(cidkonto,"B2",right(trim(finmat->idkonto2),2))
                endif

                cIdkonto:=STRTRAN(cidkonto,"?1",trim(ckonto1))
                cIdkonto:=STRTRAN(cidkonto,"?2",trim(ckonto2))
                cIdkonto:=STRTRAN(cidkonto,"?3",trim(ckonto3))
                cIdkonto:=padr(cidkonto,7)
                cBrDok:=space(8)
                dDatDok:=finmat->datdok

                if trfp->Dokument == "R"  
                    // radni nalog
                    cBrDok := finmat->idZaduz2
                elseif trfp->Dokument=="1"
                    cBrDok := finmat->brdok
                elseif trfp->Dokument=="2"
                    cBrDok := finmat->brfaktp
                    dDatDok := finmat->datfaktp
                elseif trfp->Dokument=="3"
                    dDatDok := dDatNal
                elseif trfp->Dokument=="9"
                    // koristi se za vise kalkulacija
                    dDatDok := dDatMax
                endif

                cIdPartner := space(6)
                if trfp->Partner == "1"  //  stavi Partnera
                    cIdPartner := finmat->IdPartner
                elseif trfp->Partner=="2"   // stavi  Lice koje se zaduzuje
                    cIdpartner:=finmat->IdZaduz
                elseif trfp->Partner=="3"   // stavi  Lice koje se zaduz2
                    cIdpartner:=finmat->IdZaduz2
                elseif trfp->Partner=="A"
                    cIdpartner:=cPartner1
                    IF !EMPTY(dDatFakt1)
                        DatDok:=dDatFakt1
                    ENDIF
                    IF !EMPTY( cBrFakt1)
                        cBrDok := cBrFakt1
                    ENDIF
                elseif trfp->Partner=="B"
                    cIdpartner:=cPartner2
                    IF !EMPTY(dDatFakt2)
                        dDatDok := dDatFakt2
                    ENDIF
                    IF !EMPTY( cBrFakt2)
                        cBrDok := cBrFakt2
                    ENDIF
                elseif trfp->Partner=="C"
                    cIdpartner:=cPartner3
                    IF !EMPTY(dDatFakt3)
                        dDatDok:=dDatFakt3
                    ENDIF
                    IF !EMPTY( cBrFakt3)
                        cBrDok := cBrFakt3
                    ENDIF
                elseif trfp->Partner=="D"
                    cIdpartner:=cPartner4
                    IF !EMPTY(dDatFakt4)
                        dDatDok := dDatFakt4
                    ENDIF
                    IF !EMPTY( cBrFakt4)
                        cBrDok := cBrFakt4
                    ENDIF
                elseif trfp->Partner=="E"
                    cIdpartner:=cPartner5
                    IF !EMPTY(dDatFakt5)
                        dDatDok:=dDatFakt5
                    ENDIF
                    IF !EMPTY( cBrFakt5)
                        cBrDok := cBrFakt5
                    ENDIF
                elseif trfp->Partner=="O"   // stavi  banku
                    cIdpartner:=KONCIJ->banka
                endif

                fExist := .f.
                seek finmat->IdFirma+cidvn+cBrNalF
            
                if found()
                    fExist:=.f.
                    do while !EOF() .and. finmat->idfirma+cidvn+cBrNalF==IdFirma+idvn+BrNal
                        if IdKonto==cIdKonto .and. IdPartner==cIdPartner .and.;
                                trfp->d_p==d_p  .and. idtipdok==finmat->idvd .and.;
                                padr(brdok,10)==padr(cBrDok,10) .and. datdok==dDatDok .and.;
                                IF(lPoRj,TRIM(idrj)==TRIM(cIdRj),.t.)
                            // provjeriti da li se vec nalazi stavka koju dodajemo
                            fExist:=.t.
                            exit
                        endif
                        skip
                    enddo
                    
                    if !fExist
                        SEEK finmat->idfirma+cIdVN+cBrNalF+"ZZZZ"
                        SKIP -1
                        IF idfirma+idvn+brnal==finmat->idfirma+cIdVN+cBrNalF
                            nRbr:=val(Rbr)+1
                        ELSE
                            nRbr:=1
                        ENDIF
                        APPEND BLANK
                    endif
                else
                    SEEK finmat->idfirma+cIdVN+cBrNalF+"ZZZZ"
                    SKIP -1
                    IF idfirma+idvn+brnal==finmat->idfirma+cIdVN+cBrNalF
                        nRbr:=val(Rbr)+1
                    ELSE
                        nRbr:=1
                    ENDIF
                    APPEND BLANK
                endif

                replace iznosDEM with iznosDEM+nIz
                replace iznosBHD with iznosBHD+nIz2
                replace idKonto  with cIdKonto
                replace IdPartner  with cIdPartner
                replace D_P      with trfp->d_P
        
                replace idFirma  with finmat->idfirma,;
                    IdVN     with cIdVN,;
                    BrNal    with cBrNalF,;
                    IdTipDok with finmat->IdVD,;
                    BrDok    with cBrDok
           
                replace DatDok   with dDatDok
                replace opis     with trfp->naz

                if LEFT(RIGHT(trfp->naz,2),1)$".;"  // nacin zaokruzenja
                    replace opis with LEFT(trfp->naz,LEN(trfp->naz)-2)
                endif

                if "#V#" $  trfp->naz  // stavi datum valutiranja
                    replace datval with dDatVal
                    replace opis with strtran( trfp->naz, "#V#", "" )
                    IF lVrsteP
                        replace k4 with cIdVrsteP
                    ENDIF
                endif

                // kontiraj radnu jedinicu
                if "#RJ1#" $  trfp->naz  // stavi datum valutiranja
                    replace IdRJ with cRj1, opis with strtran(trfp->naz,"#RJ1#","")
                endif

                if "#RJ2#" $  trfp->naz  // stavi datum valutiranja
                    replace IdRJ with cRj2, opis with strtran(trfp->naz,"#RJ2#","")
                endif

                IF lPoRj
                    replace IdRJ with cIdRj
                ENDIF

                if !fExist
                    replace Rbr  with str(nRbr,4)
                endif

            endif // nIz <>0

            select trfp
            skip
        enddo // trfp->id==cIDVD

        if gAMat<>"0"     // za materijalni nalog

            select trmp
            HSEEK cIdVD
            
            do while !empty(cBrNalM) .and. trmp->id==cIdVD .and. !eof()

                cIznos:=naz

                // mpripr
                select mpripr

                cIdPartner:=""
                if trmp->Partner=="1"  //  stavi Partnera
                    cIdpartner:=finmat->IdPartner
                endif

                cIdzaduz:=""
                if trmp->Zaduz=="1"
                    cIdKonto:=finmat->idkonto
                    cIdZaduz:=finmat->idzaduz
                elseif trmp->Zaduz=="2"
                    cIdKonto:=finmat->idkonto2
                    cIdZaduz:=finmat->idzaduz2
                endif

                cBrDok:=""
                dDatDok:=finmat->Datdok
                if trmp->dokument=="1"
                    cBrDok:=finmat->Brdok
                elseif trmp->dokument=="2"
                    cBrDok:=finmat->BrFaktP
                    dDatDok:=finmat->DatFaktP
                endif
                nKol:=finmat->Kolicina
                nIz:=finmat->&cIznos

                if trim(cIznos)=="GKV"
                    nKol:=finmat->Gkol
                elseif trim(cIznos)=="GKV2"
                    nKol:=finmat->GKol2
                elseif trim(cIznos)=="MARZA2"
                    nKol:=finmat->(Gkol+GKol2)
                elseif  trim(cIznos)=="RABATV"
                    nKol:=0
                endif

                if trmp->znak=="-"
                    nIz:= -nIz
                    nKol:= -nKol
                endif

                nIz:=round(nIz,2)

                if nIz==0
                    select trmp
                    skip
                    loop
                endif
             
                go bottom
                nRbr2:=val(rbr)+1
                append blank

                replace IdFirma   with finmat->IdFirma,;
                     BrNal     with cBrNalM,;
                     IdVN      with cIdVN,;
                     IdPartner with cIdPartner,;
                     IdRoba    with finmat->idroba,;
                     Kolicina  with nKol,;
                     IdKonto   with cIdKonto,;
                     IdZaduz   with cIdZaduz,;
                     IdTipDok  with finmat->IdVD,;
                     BrDok     with cBrDok,;
                     DatDok    with dDatDok,;
                     Rbr       with str(nRbr2,4),;
                     IdPartner with cIdPartner,;
                     Iznos    with nIz,;
                     Iznos2   with round(nIz,2),;
                     Cijena   with iif(nKol<>0,Iznos/nKol,0),;
                     U_I      with trmp->u_i,;
                     D_P      with trmp->u_i


                select trmp
                skip
            enddo // trmp->id = cIDVD

        endif    // za materijalni nalog

        select finmat
        skip
    enddo
enddo

select finmat
skip -1  

if lAFin .or. lAFin2
    select fin_pripr
    go top
    seek finmat->idfirma+cIdVN+cBrNalF
    if found()
        do while !eof() .and. IDFIRMA+IDVN+BRNAL==finmat->idfirma+cIdVN+cBrNalF
            cPom:=right(opis,1)
            // na desnu stranu opisa stavim npr "ZADUZ MAGACIN          0"
            // onda ce izvrsiti zaokruzenje na 0 decimalnih mjesta
            if cPom $ "0125"
                nLen:=len(trim(opis))
                replace opis with left(trim(opis),nLen-1)
                if cPom="5"  // zaokruzenje na 0.5 DEM
                    replace iznosbhd with round2(iznosbhd,2)
                    replace iznosdem with round2(iznosdem,2)
                else
                    replace iznosbhd with round(iznosbhd,MIN(val(cPom),2))
                    replace iznosdem with round(iznosdem,MIN(val(cPom),2))
                endif
            endif 
            skip
        enddo 
    endif
endif 

MsgC()

// ako je vise kalkulacija ne zatvaraj tabele
if !lViseKalk
    close all
    return
endif

return



// --------------------------------
// validacija broja naloga
// --------------------------------
static function __val_nalog( cNalog )
local lRet := .t.
local cTmp
local cChar
local i

cTmp := RIGHT( cNalog, 4 )

// vidi jesu li sve brojevi
for i := 1 to LEN( cTmp )
    
    cChar := SUBSTR( cTmp, i, 1 )
    
    if cChar $ "0123456789"
        loop
    else
        lRet := .f.
        exit
    endif

next

return lRet



/*! \fn Konto(nBroj,cDef,cTekst)
 *  \param nBroj - koju varijablu punimo (1-ckonto1,2-ckonto2,3-ckonto3)
 *  \param cDef - default tj.ponudjeni tekst
 *  \param cTekst - opis podatka koji se unosi
 *  \brief Edit proizvoljnog teksta u varijablu ckonto1,ckonto2 ili ckonto3 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  \return 0
 */

function Konto(nBroj, cDef, cTekst)
private GetList:={}

if (nBroj==1 .and. len(ckonto1)<>0) .or. ;
   (nBroj==2 .and. len(ckonto2)<>0) .or. ;
   (nBroj==3 .and. len(ckonto3)<>0)
    return 0
endif

Box(,2,60)
    set cursor on
    @ m_x+1,m_y+2 SAY cTekst
    if nBroj==1
        ckonto1:=cdef
        @ row(),col()+1 GET cKonto1
    elseif nBroj==2
        ckonto2:=cdef
        @ row(),col()+1 GET cKonto2
    else
        ckonto3:=cdef
        @ row(),col()+1 GET cKonto3
    endif
    read
BoxC()

return 0


// Primjer SetKonto(1, IsInoDob(finmat->IdPartner) , "30", "31")
//
function SetKonto(nBroj, lValue, cTrue , cFalse)
local cPom


if (nBroj==1 .and. len(cKonto1)<>0) .or. ;
   (nBroj==2 .and. len(cKonto2)<>0) .or. ;
   (nBroj==3 .and. len(cKonto3)<>0)
    return 0
endif

if lValue
    cPom := cTrue
else
    cPom := cFalse
endif
    
if nBroj==1
    cKonto1:=cPom
elseif nBroj==2
    cKonto2:=cPom
else
    cKonto3:=cPom
endif

return 0




/*! \fn RJ(nBroj,cDef,cTekst)
 *  \param nBroj - koju varijablu punimo (1-cRj1,2-cRj2)
 *  \param cDef - default tj.ponudjeni tekst
 *  \param cTekst - opis podatka koji se unosi
 *  \brief Edit proizvoljnog teksta u varijablu cRj1 ili cRj2 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  \return 0
 */

function RJ(nBroj,cDef,cTekst)
private GetList:={}

if (nBroj==1 .and. len(cRJ1)<>0) .or. (nBroj==2 .and. len(cRj2)<>0)
  return 0
endif

  Box(,2,60)
    set cursor on
    @ m_x+1,m_y+2 SAY cTekst
    if nBroj==1
      cRJ1:=cdef
     @ row(),col()+1 GET cRj1
    elseif nBroj==2
      cRJ2:=cdef
     @ row(),col()+1 GET cRj2
    endif
    read
  BoxC()

return 0





/*! \fn DatVal()
 *  \brief Odredjivanje datuma valute - varijabla dDatVal
 */

function DatVal()
local _uvecaj := 15
local _rec
private GetList := {}

// uzmi datval iz doks2
PushWa()

O_KALK_DOKS2
set order to tag "1"
go top
seek finmat->( idfirma + idvd + brdok )

if FOUND()
    dDatVal := field->datval
else
    dDatVal := CTOD("")
endif

if lVrsteP
    cIdVrsteP := k2
endif

if !EMPTY( dDatVal )
    _uvecaj := ( dDatVal - finmat->datfaktp )
endif

if dDatVal == CTOD("")

    Box(, 3 + IIF( lVrsteP .and. EMPTY( cIdVrsteP ), 1, 0 ), 60 )

        set cursor on

        @ m_x + 1, m_y + 2 SAY "Datum dokumenta: " 
        ??  finmat->datfaktp

        @ m_x + 2, m_y + 2 SAY "Uvecaj dana    :" GET _uvecaj PICT "999"
        @ m_x + 3, m_y + 2 SAY "Valuta         :" GET dDatVal WHEN {|| dDatVal := finmat->datfaktp + _uvecaj, .t. }
    
        if lVrsteP .and. EMPTY(cIdVrsteP)
            @ m_x + 4, m_y + 2 SAY "Sifra vrste placanja:" GET cIdVrsteP PICT "@!"
        endif

        read

    BoxC()

    select kalk_doks2
    go top
    seek finmat->(idfirma+idvd+brdok)

    if !FOUND() 
        APPEND BLANK 
        // ovo se moze desiti ako je neko mjenjao dokumenta u KALK
        _rec := dbf_get_rec()
        _rec["idfirma"] := finmat->idfirma
        _rec["idvd"] := finmat->idvd
        _rec["brdok"] := finmat->brdok
    else
        _rec := dbf_get_rec()
    endif
        
    _rec["datval"] := dDatVal
        
    if lVrsteP
        _rec["k2"] := cIdVrsteP
    endif
        
    update_rec_server_and_dbf( "kalk_doks2", _rec, 1, "FULL" )
    
endif

PopWa()
    
return 0





/*! \fn Partner(nBroj,cDef,cTekst,lFaktura,dp)
 *  \param nBroj - 1 znaci da se sifrom partnera puni varijabla cPartner1
 *  \param cDef - default tj.ponudjeni tekst
 *  \param cTekst - opis podatka koji se unosi u varijablu cPartner1
 *  \param lFaktura - .t. i ako je npr.nBroj==1 filuju se i varijable cBrFakt1 i dDatFakt1 koje cuvaju broj i datum fakture, .f. - ne edituju se ove varijable sto je i default vrijednost
 *  \param dp - duzina sifre partnera, ako se ne navede default vrijednost=6
 *  \brief Edit sifre partnera u varijablu cPartner1...ili...cPartner5 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  \return 0
 */

function Partner(nBroj,cDef,cTekst,lFaktura,dp)
*{
IF lFaktura==NIL; lFaktura:=.f.; ENDIF
IF dp==NIL; dp:=6; ENDIF
IF cDef==NIL; cDef:=""; ENDIF
IF cTekst==NIL; cTekst:="Sifra partnera "+ALLTRIM(STR(nBroj)); ENDIF
private GetList:={}

if (nBroj==1 .and. len(cPartner1)<>0) .or. ;
   (nBroj==2 .and. len(cPartner2)<>0) .or. ;
   (nBroj==3 .and. len(cPartner3)<>0) .or. ;
   (nBroj==4 .and. len(cPartner4)<>0) .or. ;
   (nBroj==5 .and. len(cPartner5)<>0)
  return 0
endif

  Box(,2+IF(lFaktura,2,0),60)
    set cursor on
    @ m_x+1,m_y+2 SAY cTekst
    if nBroj==1
      cPartner1:=padr(cdef,dp)
      @ row(),col()+1 GET cPartner1
      IF lFaktura
        @ m_x+2,m_y+2 SAY "Broj fakture " GET cBrFakt1
        @ m_x+3,m_y+2 SAY "Datum fakture" GET dDatFakt1
      ENDIF
    elseif nBroj==2
      cPartner2:=padr(cdef,dp)
      @ row(),col()+1 GET cPartner2
      IF lFaktura
        @ m_x+2,m_y+2 SAY "Broj fakture " GET cBrFakt2
        @ m_x+3,m_y+2 SAY "Datum fakture" GET dDatFakt2
      ENDIF
    elseif nBroj==3
      cPartner3:=padr(cdef,dp)
      @ row(),col()+1 GET cPartner3
      IF lFaktura
        @ m_x+2,m_y+2 SAY "Broj fakture " GET cBrFakt3
        @ m_x+3,m_y+2 SAY "Datum fakture" GET dDatFakt3
      ENDIF
    elseif nBroj==4
      cPartner4:=padr(cdef,dp)
      @ row(),col()+1 GET cPartner4
      IF lFaktura
        @ m_x+2,m_y+2 SAY "Broj fakture " GET cBrFakt4
        @ m_x+3,m_y+2 SAY "Datum fakture" GET dDatFakt4
      ENDIF
    else
      cPartner5:=padr(cdef,dp)
      @ row(),col()+1 GET cPartner5
      IF lFaktura
        @ m_x+2,m_y+2 SAY "Broj fakture " GET cBrFakt5
        @ m_x+3,m_y+2 SAY "Datum fakture" GET dDatFakt5
      ENDIF
    endif
    read
  BoxC()

return 0




function kalk_set_doks_total_fields( nNv, nVpv, nMpv, nRabat )

if field->mu_i = "1"
    nNV += field->nc * (field->kolicina - field->gkolicina - field->gkolicin2)
    nVPV += field->vpc * (field->kolicina - field->gkolicina - field->gkolicin2)
elseif mu_i = "P"
    nNV += field->nc * (field->kolicina - field->gkolicina - field->gkolicin2)
    nVPV += field->vpc*( field->kolicina - field->gkolicina - field->gkolicin2)
elseif mu_i = "3"
    nVPV += field->vpc * (field->kolicina - field->gkolicina - field->gkolicin2)
elseif mu_i == "5"
    nNV -= field->nc * (field->kolicina)
    nVPV -= field->vpc * (field->kolicina)
    nRabat += field->vpc * (field->rabatv / 100) * field->kolicina
endif

if field->pu_i == "1"
    if empty(field->mu_i)
        nNV += field->nc * field->kolicina
    endif
    nMPV += field->mpcsapp * field->kolicina
elseif field->pu_i=="P"
    if empty(field->mu_i)
        nNV += field->nc * field->kolicina
    endif
    nMPV += field->mpcsapp * field->kolicina
elseif field->pu_i=="5"
    if empty(field->mu_i)
        nNV -= field->nc * field->kolicina
    endif
    nMPV -= field->mpcsapp * field->kolicina
elseif field->pu_i=="I"
    nMPV -= field->mpcsapp * field->gkolicin2
    nNV -= field->nc * field->gkolicin2
elseif pu_i=="3"
    nMPV += field->mpcsapp * field->kolicina
endif

return






/*! \fn IspitajRezim()
 *  \brief Ako se radi o privremenom rezimu obrade KALK dokumenata setuju se vrijednosti parametara gCijene i gMetodaNC na vrijednosti u dvoclanom nizu aRezim
 */

function IspitajRezim()
if !EMPTY(aRezim)
    gCijene   = aRezim[1]
    gMetodaNC = aRezim[2]
endif
return





/*! \fn RekapK()
 *  \param fstara - .f. znaci poziv iz tabele pripreme, .t. radi se o azuriranoj kalkulaciji pa se prvo getuje broj dokumenta (cIdFirma,cIdVD,cBrdok)
 *  \brief Pravi rekapitulaciju kalkulacija a ako je ulazni parametar fstara==.t. poziva se i kontiranje dokumenta
 */

function RekapK()
parameters fStara, cIdFirma, cIdVd, cBrDok, lAuto

local fprvi
local n1:=n2:=n3:=n4:=n5:=n6:=n7:=n8:=n9:=na:=nb:=0
local nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=nTotb:=0
local nCol1:=nCol2:=nCol3:=0
local _fin_auto_broj := "N"
// kontira se vise kalkulacija
local lViseKalk := .f.
local _predispozicija := .f.
private aPorezi

aPorezi := {}

if pcount() == 0
    fstara := .f.
endif

if lAuto == nil
    lAuto := .f.
endif

lVoSaTa := .f.

// prvi prolaz
fprvi := .t.  

do while .t.

    _predispozicija := .f.

    O_FINMAT
    O_KONTO
    O_PARTN
    O_TDOK
    O_ROBA
    O_TARIFA

    if fStara
        // otvara se KALK sa aliasom priprema
        SELECT F_KALK
        if !used()
            O_SKALK  
        endif
    else
        SELECT F_KALK_PRIPR
        if !used()
            O_KALK_PRIPR
        endif
    endif

    select finmat
    zapp()

    select KALK_PRIPR
    // idfirma+ idvd + brdok+rbr
    set order to tag "1" 

    if fPrvi
        // nisu prosljedjeni parametri
        if cIdFirma == nil
    
            cIdFirma:=IdFirma
            cIdVD:=IdVD
            cBrdok:=brdok
            if empty(cIdFirma)
                cIdFirma:=gFirma
            endif
            lViseKalk := .f.
        
        else
            // parametri su prosljedjeni RekapK funkciji
            lViseKalk := .t.
        endif
        fPrvi:=.f.
        
    endif

    if fStara

        if !lViseKalk

            Box("",1, 50)
                set cursor on
                @ m_x+1,m_y+2 SAY "Dokument broj:"
                if gNW $ "DX"
                    @ m_x+1,col()+2  SAY cIdFirma
                else
                    @ m_x+1,col()+2 GET cIdFirma
                endif
                @ m_x+1,col()+1 SAY "-" GET cIdVD
                @ m_x+1,col()+1 SAY "-" GET cBrDok
                read
                ESC_BCR
            BoxC()
        endif
    
        hseek cIdFirma + cIdVd + cBrDok

    else
        go top
        cIdFirma := IdFirma
        cIdVD := IdVD
        cBrdok := brdok
    endif

    // potrebno je ispitati da li je predispozicija !
    if idvd == "80" .and. !EMPTY( idkonto2 )
        _predispozicija := .t.
    endif

    EOF CRET

    if fStara .and. lAuto == .f.
    
        // - info o izabranom dokumentu -
        Box( "#DOKUMENT " + cIdFirma + "-" + cIdVd + "-" + cBrDok, 9, 77 )

            cDalje:="D"
            cAutoRav := gAutoRavn

            SELECT PARTN
            HSEEK KALK_PRIPR->IDPARTNER
            SELECT KONTO
            HSEEK KALK_PRIPR->MKONTO
            cPom:=naz
            SELECT KONTO
            HSEEK KALK_PRIPR->PKONTO
            select kalk_pripr
            @ m_x+2, m_y+2 SAY "DATUM------------>"             COLOR "W+/B"
            @ m_x+2, col()+1 SAY DTOC(DATDOK)                   COLOR "N/W"
            @ m_x+3, m_y+2 SAY "PARTNER---------->"             COLOR "W+/B"
            @ m_x+3, col()+1 SAY IDPARTNER + "-" + PADR( partn->naz, 20 ) COLOR "N/W"
            @ m_x+4, m_y+2 SAY "KONTO MAGACINA--->"             COLOR "W+/B"
            @ m_x+4, col()+1 SAY MKONTO+"-"+PADR(cPom,49)       COLOR "N/W"
            @ m_x+5, m_y+2 SAY "KONTO PRODAVNICE->"             COLOR "W+/B"
            @ m_x+5, col()+1 SAY PKONTO+"-"+PADR(KONTO->naz,49) COLOR "N/W"
            @ m_x+7, m_y+2 SAY "Automatski uravnotezi dokument? (D/N)" GET cAutoRav VALID cAutoRav$"DN" PICT "@!"
            @ m_x+8, m_y+2 SAY "Zelite li kontirati dokument? (D/N)" GET cDalje VALID cDalje$"DN" PICT "@!"
            @ m_x+9, m_y+2 SAY "Automatski broj fin.naloga? (D/N)" GET _fin_auto_broj VALID _fin_auto_broj $ "DN" PICT "@!"
    
            READ

        BoxC()
        
        IF LASTKEY()==K_ESC .or. cDalje<>"D"
            if lViseKalk
                exit
            else
                LOOP
            endif
        ENDIF
    endif

    if cIdVd=="24"
        START PRINT CRET
        ?
    endif

    nStr:=0
    nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=nTotb:=nTotC:=0

    do whilesc !eof() .and. cIdFirma==idfirma .and. cidvd==idvd
        
        cBrDok:=BrDok
        cIdPartner:=IdPartner
        cBrFaktP:=BrFaktP
        dDatFaktP:=DatFaktP
        cIdKonto:=IdKonto
        cIdKonto2:=IdKonto2
    
        if cIdVd=="24" .and. (prow()==0 .or. prow()>55)
            if prow()-gPStranica>55
                FF
            endif
            P_COND
            ?? "KALK: REKAPITULACIJA NA DAN:",date()
            @ prow(),125 SAY "Str:"+str(++nStr,3)
        endif

        if cIdVd=="24"
            ?
            ? "KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
            select PARTN
            HSEEK cIdPartner
            ?  "KUPAC:",cIdPartner,"-",naz,SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP
        endif

        select KONTO
        HSEEK cIdKonto

        HSEEK cIdKonto2
        select KALK_PRIPR

        m:=""
        if cidvd == "24"
            m:="---- -------------- -------------- -------------- -------------- -------------- ---------- ---------- ---------- ---------- ----------"
            P_COND2
            ? m
            if IsPDV()
            ? "*R. * "+left(c24T1,12)+" * "+left(c24T2,12)+" * "+left(c24T3,12)+" * "+left(c24T4,12)+" * "+left(c24T5,12)+" *   FV     *   PDV    *   PDV    *   FV     * PRIHOD  *"
                ? "*Br.* "+left(c24T6,12)+" * "+left(c24T7,12)+" * "+left(c24T8,12)+" * "+space(12)+" * "+space(12)+" * BEZ PDV  *   %      *          * SA PDV   *         *"
            else
            ? "*R. * "+left(c24T1,12)+" * "+left(c24T2,12)+" * "+left(c24T3,12)+" * "+left(c24T4,12)+" * "+left(c24T5,12)+" *   FV     * POREZ    *  POREZ   *   FV     * PRIHOD  *"
                ? "*Br.* "+left(c24T6,12)+" * "+left(c24T7,12)+" * "+space(12)+" * "+space(12)+" * "+space(12)+" * BEZ POR  *   %      *          * SA POR   *         *"
            endif
            ? m
        endif

        IF lVoSaTa
            cIdd:=idpartner+idkonto+idkonto2
        ELSE
            cIdd:=idpartner+brfaktp+idkonto+idkonto2
        ENDIF

        do whilesc !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

            if cIdVd == "97"
                if field->tbanktr == "X"
                    skip
                    loop
                endif
            endif
            
            if gMagacin<>"1" .and. ( !lVoSaTa .and. idpartner+brfaktp+idkonto+idkonto2<>cidd .or. lVoSaTa .and. idpartner+idkonto+idkonto2<>cidd )
                set device to screen
                if ! ( (idvd $ "16#80" )  .and. !empty(idkonto2)  )
                    if !idvd $ "24"
                        Beep(2)
                        Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
                    endif
                endif
                if cidvd=="24"
                    set device to printer
                endif
            endif

            // iznosi troskova koji se izracunavaju u KTroskovi()
            private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2

            nFV:=FCj*Kolicina

            if gKalo=="1"
                SKol:=Kolicina-GKolicina-GKolicin2
            else
                SKol:=Kolicina
            endif

            if cidvd=="24" .and. prow()>62
                FF
                @ prow(),125 SAY "Str:"+str(++nStr,3)
            endif

            select ROBA
            HSEEK KALK_PRIPR->IdRoba
            select TARIFA
            HSEEK KALK_PRIPR->idtarifa
            select KALK_PRIPR

            if cIdVd == "24"
                Tarifa(pkonto, idroba, @aPorezi, kalk_pripr->idtarifa)
            else
                Tarifa(pkonto, idroba, @aPorezi)
            endif
        
            KTroskovi()

            if cidvd=="24"
                @ prow()+1,0 SAY  Rbr PICTURE "999"
            endif

            if cidvd=="24"
                nCol1:=pcol()+6
                @ prow(),pcol()+6 SAY n1:=prevoz    pict picdem
                @ prow(),pcol()+5 SAY n2:=banktr    pict picdem
                @ prow(),pcol()+5 SAY n3:=spedtr    pict picdem
                @ prow(),pcol()+5 SAY n4:=cardaz    pict picdem
                @ prow(),pcol()+5 SAY n5:=zavtr     pict picdem
                @ prow(),pcol()+1 SAY n6:=fcj       pict picdem
            
                if IsPDV()
                    @ prow(),pcol()+1 SAY tarifa->opp   pict picproc
                else
                    @ prow(),pcol()+1 SAY tarifa->vpp   pict picproc
                endif
            
                @ prow(),pcol()+1 SAY n7:=nc-fcj    pict picdem
                @ prow(),pcol()+1 SAY n8:=nc        pict picdem
                @ prow(),pcol()+1 SAY n9:=marza     pict picdem
                @ prow()+1,nCol1  SAY nA:=mpc       pict picdem
                @ prow(),pcol()+5 SAY nB:=mpcsapp pict picdem
                @ prow(),pcol()+5 SAY nJCI:=fcj3 pict picdem
                nTot1+=n1; nTot2+=n2; nTot3+=n3; nTot4+=n4
                nTot5+=n5; nTot6+=n6; nTot7+=n7; nTot8+=n8
                nTot9+=n9; nTotA+=na; nTotB+=nB; nTotC+=nJCI
            endif

            VtPorezi()
    
            aIPor := RacPorezeMP( aPorezi, mpc, mpcSaPP, nc )

            select finmat
            append blank
    
            replace IdFirma   with kalk_PRIPR->IdFirma,;
                IdKonto   with kalk_PRIPR->IdKonto,;
                IdKonto2  with kalk_pripr->IdKonto2,;
                IdTarifa  with kalk_pripr->IdTarifa,;
                IdPartner with kalk_pripr->IdPartner,;
                IdZaduz   with kalk_pripr->IdZaduz,;
                IdZaduz2  with kalk_pripr->IdZaduz2,;
                BrFaktP   with kalk_pripr->BrFaktP,;
                DatFaktP  with kalk_pripr->DatFaktP,;
                IdVD      with kalk_pripr->IdVD,;
                BrDok     with kalk_pripr->BrDok,;
                DatDok    with kalk_pripr->DatDok,;
                GKV       with round(kalk_PRIPR->(GKolicina*FCJ2),gZaokr),;   // vrijednost transp.kala
                GKV2      with round(kalk_PRIPR->(GKolicin2*FCJ2),gZaokr)   // vrijednost ostalog kala
                
            replace Prevoz    with round(kalk_PRIPR->(nPrevoz*SKol),gZaokr) ,;
                CarDaz    with round(kalk_PRIPR->(nCarDaz*SKol),gZaokr) ,;
                BankTr    with round(kalk_PRIPR->(nBankTr*SKol),gZaokr) ,;
                SpedTr    with round(kalk_PRIPR->(nSpedTr*SKol),gZaokr) ,;
                ZavTr     with round(kalk_PRIPR->(nZavTr*SKol),gZaokr)  ,;
                NV        with round(kalk_PRIPR->(NC*(Kolicina-GKolicina-GKolicin2)),gZaokr)  ,;
                Marza     with round(kalk_PRIPR->(nMarza*(Kolicina-GKolicina-GKolicin2)),gZaokr)  ,;           // marza se ostvaruje nad stvarnom kolicinom
                VPV       with round(kalk_PRIPR->(VPC*(Kolicina-GKolicina-GKolicin2)),gZaokr)        // vpv se formira nad stvarnom kolicinom
        
           
            nPom := kalk_pripr->(RabatV/100*VPC*Kolicina)
            nPom := round(nPom, gZaokr)
            replace RABATV  with nPom

            if IsPDV() .and.  kalk_pripr->idvd == "24"
                nPom := kalk_pripr->(FCJ3 * Skol)
                nPom := round(nPom, gZaokr)
                replace VPVSAP with nPom
            else
                nPom := kalk_pripr->(VPCSaP*Kolicina)
                nPom := round(nPom, gZaokr)
                replace VPVSAP with  nPom
            endif
       
            nPom := kalk_pripr->(nMarza2*(Kolicina-GKolicina-GKolicin2))
            nPom := round(nPom, gZaokr)
            replace Marza2 with nPom

            if kalk_pripr->idvd $ "14#94" 
                nPom := kalk_pripr->(VPC*(1-RabatV/100)*MPC/100*Kolicina)
            else
                nPom := kalk_pripr->(MPC*(Kolicina-GKolicina-GKolicin2))
            endif
            nPom := round(nPom, gZaokr)
            replace MPV with nPom
        
            // PDV

            nPom := kalk_pripr->(aIPor[1]*(Kolicina-GKolicina-GKolicin2))
            nPom := round(nPom, gZaokr)
            replace Porez with nPom 
    
            // ugostiteljstvo porez na potr
            replace Porez2    with round(kalk_PRIPR->(aIPor[3]*(Kolicina-GKolicina-GKolicin2)),gZaokr)  
    

            nPom := kalk_pripr->(MPCSaPP*(Kolicina-GKolicina-GKolicin2))
            nPom := round(nPom, gZaokr)
            replace MPVSaPP with nPom
        
            // porezv je aIPor[2] koji se ne koristi
            nPom := kalk_pripr->(aIPor[2]*(Kolicina-GKolicina-GKolicin2))
            nPom := round(nPom, gZaokr)
            replace Porezv with nPom 
      
            replace idroba    with kalk_pripr->idroba
            replace  Kolicina  with kalk_pripr->(Kolicina-GKolicina-GKolicin2)

            if !(kalk_pripr->IdVD $ "IM#IP")
                replace   FV        with round(nFV,gZaokr) 
                replace   Rabat     with round(kalk_pripr->(nFV*Rabat/100),gZaokr)
            endif

            if idvd == "IP"
                replace  GKV2  with round(kalk_pripr->((Gkolicina-Kolicina)*MPcSAPP),gZaokr),;
                        GKol2 with kalk_pripr->(Gkolicina-Kolicina)
            endif

            if idvd $ "14#94"
                replace  MPVSaPP   with  kalk_pripr->( VPC*(1-RabatV/100)*(Kolicina-GKolicina-GKolicin2) )
            endif
      
            if !empty(kalk_pripr->mu_i)
                select tarifa
                hseek roba->idtarifa
                select finmat
                if IsPDV()
                    replace UPOREZV with  round(kalk_pripr->(nMarza*kolicina*TARIFA->OPP/100/(1+TARIFA->OPP/100)),gZaokr)
                else
                    replace UPOREZV with  round(kalk_pripr->(nMarza*kolicina*TARIFA->VPP/100/(1+TARIFA->VPP/100)),gZaokr)
                endif
                select tarifa
                hseek roba->idtarifa
                select finmat
            endif

            if gKalo=="2" .and.  kalk_pripr->idvd $ "10#81"  // kalo ima vrijednost po NC
                replace GKV   with round(kalk_pripr->(GKolicina*NC),gZaokr),;   // vrijednost transp.kala
                       GKV2  with round(kalk_pripr->(GKolicin2*NC),gZaokr),;   // vrijednost ostalog kala
                       GKol  with round(kalk_pripr->GKolicina,gZaokr),;
                       GKol2 with round(kalk_pripr->GKolicin2,gZaokr) ,;
                       POREZV with round(nMarza*kalk_pripr->(GKolicina+Gkolicin2),gZaokr) // negativna marza za kalo
            endif

            if kalk_pripr->idvd=="24"
                replace mpv     with kalk_pripr->mpc,;
                    mpvsapp with kalk_pripr->mpcsapp
            endif
            
            if kalk_pripr->IDVD $ "18#19"
                replace Kolicina with 0
            endif

            if (kalk_pripr->IdVD $ "41#42")
                // popust maloprodaje se smjesta ovdje
                REPLACE Rabat WITH kalk_pripr->RabatV * kalk_pripr->kolicina
                if ALLTRIM(gnFirma) == "TEST FIRMA"
                    MsgBeep("Popust MP = finmat->rabat " + STR(Rabat, 10,2))
                endif
            endif

            if !IsPdv()

                if glUgost
                    REPLACE prucmp WITH round(kalk_pripr->(aIPor[2]*(Kolicina-GKolicina-GKolicin2)),gZaokr)
                    REPLACE porpot WITH round(kalk_pripr->(aIPor[3]*(Kolicina-GKolicina-GKolicin2)),gZaokr)
                endif


                if  idvd $ "14#94"
                    /// ppp porezi
                    if  gVarVP=="2"  // unazad VPC - preracunata stopa
                        replace POREZV with round(TARIFA->VPP/100/(1+tarifa->vpp/100)*iif(nMarza<0,0,nMarza)*Kolicina,gZaokr)
                    endif
                endif
            endif
     
            // napuni marker da se radi o predispoziciji...
            if _predispozicija
                replace k1 with "P"
            endif

            select kalk_pripr
            skip
        enddo // brdok

        if cIdVd=="24"
            ? m
        else
            if fStara
                exit
            endif
        endif

    enddo // idfirma,idvd
 
    if cidvd=="24" .and. prow()>60
        FF
        @ prow(),125 SAY "Str:"+str(++nStr,3)
    endif

    if cidvd == "24"
        ?
        ? m
        @ prow()+1,0      SAY  "Ukup."+cIdVD+":"
        @ prow(),nCol1    SAY  nTot1         picture   picdem
        @ prow(),pcol()+5 SAY  nTot2         picture   picdem
        @ prow(),pcol()+5 SAY  nTot3         picture   picdem
        @ prow(),pcol()+5 SAY  nTot4         picture   picdem
        @ prow(),pcol()+5 SAY  nTot5         picture   picdem
        @ prow(),pcol()+1 SAY  nTot6         picture   picdem
        @ prow(),pcol()+1 SAY  space(len(picproc))
        @ prow(),pcol()+1  SAY  nTot7        picture   picdem
        @ prow(),pcol()+1  SAY  nTot8        picture   picdem
        @ prow(),pcol()+1  SAY  nTot9        picture   picdem
        @ prow()+1,nCol1   SAY  nTota         picture   picdem
        @ prow(),pcol()+5  SAY  nTotb         picture   picdem
        @ prow(),pcol()+5  SAY  nTotC         picture   picdem
        ? m
        ?
        END PRINT
    endif

    if !fStara .or. lAuto == .t.
        exit
    else

        cIdFirma := idfirma
        cIdVd := idvd
        cBrdok := brdok

        if !lViseKalk
            close all
        endif

        // kontiranje dokumenta...
        kalk_kontiranje_naloga( .f., NIL, lViseKalk, NIL, _fin_auto_broj == "D" )
    
        // automatska ravnoteza naloga
        if cAutoRav == "D"
            KZbira( .t. )
        endif

        // ne vrti se ukrug u ovoj do wile petlji
        if lViseKalk
            exit
        endif

    endif

enddo 

if fStara .and. !lViseKalk
    select kalk_pripr
    use
endif

if !lViseKalk
    close all
    return
endif

return



// provjerava u finmat tabeli da li se radi o predispoziciji
function predisp()
local _ret := .f.
if field->k1 == "P"
    _ret := .t.
endif
return _ret




// -----------------------------------
// kontiraj vise dokumenata u jedan
// -----------------------------------
function KontVise()
local nCount
local aD
local dDatOd
local dDatDo
local cVrsta
local cMKonto
local cPKonto

aD := kalk_rpt_datumski_interval( DATE() )

cVrsta := SPACE(2)

dDatOd := aD[1]
dDatDo := aD[2]

cMKonto := PADR("", 7)
cPKonto := PADR("", 7)

SET CURSOR ON
Box(, 6, 60)
  @ m_x+1,m_y+2 SAY  "Vrsta kalkulacije " GET cVrsta ;
        PICT "@!" ;
    VALID !empty(cVrsta)
    
  @ m_x+3,m_y+2 SAY  "Magacinski konto (prazno svi) " GET cMKonto ;
        PICT "@!" 

  @ m_x+4, m_y+2 SAY "Prodavnicki kto (prazno svi)  " GET cPKonto ;
        PICT "@!" 


  @ m_x+6,m_y+2 SAY  "Kontirati za period od " GET dDatOd
  @ m_x+6, col()+2  SAY  " do " GET dDatDo
  
  READ
  
BoxC()

// koristi se kao datum kontiranja za trfp.dokument = "9"
dDatMax := dDatDo

if LASTKEY() == K_ESC
    close all
    return
endif

SELECT F_KALK_DOKS
if !used()
    O_KALK_DOKS
endif


// "1","IdFirma+idvd+brdok"
PRIVATE cFilter := "DatDok >= "  + cm2str(dDatOd) + ".and. DatDok <= " + cm2str(dDatDo) + ".and. IdVd==" + cm2str(cVrsta)

if !empty(cMKonto)
    cFilter += ".and. mkonto==" + cm2str(cMKonto)
endif

if !empty(cPKonto)
    cFilter += ".and. pkonto==" + cm2str(cPKonto)
endif

SET FILTER TO &cFilter
GO TOP

nCount := 0
do while !eof()
    nCount ++
    cIdFirma := idFirma
    cIdVd := idvd
    cBrDok := brdok
    
    RekapK(.t., cIdFirma, cIdVd, cBrDok)
    
    SELECT KALK_DOKS
    SKIP
enddo

MsgBeep("Obradjeno " + STR(nCount, 7, 0) + " dokumenata")
close all
RETURN



// Ako je dan < 10
//     return { 01.predhodni_mjesec , zadnji.predhodni_mjesec}
//     else
//     return { 01.tekuci_mjesec, danasnji dan }

function kalk_rpt_datumski_interval(dToday)
local nDay, nFDOm
local dDatOd, dDatDo
nDay:= DAY(dToday)
nFDOm := BOM(dToday)

if nDay < 10
    // prvi dan u tekucem mjesecu - 1
    dDatDo := nFDom - 1
    // prvi dan u proslom mjesecu
    dDatOd := BOM(dDatDo)
    
else
    dDatOd := nFDom
    dDatDo := dToday
endif


return { dDatOd, dDatDo }

