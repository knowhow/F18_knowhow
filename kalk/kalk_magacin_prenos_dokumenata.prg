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


function prenos_fakt_kalk_magacin()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc,"1. fakt->kalk (10->14) racun veleprodaje               ")
AADD(_opcexe,{||  mag_fa_ka_prenos_10_14() })
AADD(_opc,"2. fakt->kalk (12->96) otpremnica")
AADD(_opcexe,{||  mag_fa_ka_prenos_otpr()  })
AADD(_opc,"3. fakt->kalk (19->96) izlazi po ostalim osnovama")
AADD(_opcexe,{||  mag_fa_ka_prenos_otpr("19") })         
AADD(_opc,"4. fakt->kalk (01->10) ulaz od dobavljaca")
AADD(_opcexe,{||  mag_fa_ka_prenos_otpr("01_10") })          
AADD(_opc,"5. fakt->kalk (0x->16) doprema u magacin")
AADD(_opcexe,{||  mag_fa_ka_prenos_otpr("0x") })          
AADD(_opc,"6. fakt->kalk, prenos otpremnica za period")
AADD(_opcexe,{||  mag_fa_ka_prenos_otpr_period() })          

f18_menu("fkma", .f., _izbor, _opc, _opcexe )

close all
return



/*! \fn mag_fa_ka_prenos_10_14()
 *  \brief Prenos FAKT 10 -> KALK 14 (veleprodajni racun)
 */
 
function mag_fa_ka_prenos_10_14()
*{
local nRabat:=0
local cIdFirma:=gFirma
local cIdTipDok:="10"
local cBrDok:=SPACE(8)
local cBrKalk:=SPACE(8)
local cFaktFirma:=gFirma
local dDatPl:=ctod("")
local fDoks2:=.f.

PRIVATE lVrsteP := ( IzFmkIni("FAKT","VrstePlacanja","N",SIFPATH)=="D" )

O_KONCIJ
O_KALK_PRIPR
O_KALK
O_KALK_DOKS
if file(KUMPATH+"DOKS2.DBF")
    fDoks2:=.t.
    O_KALK_DOKS2
endif
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

O_FAKT

dDatKalk:=date()
cIdKonto:=padr("1200",7)
cIdKonto2:=padr("1310",7)
cIdZaduz2:=space(6)

if glBrojacPoKontima
    Box("#FAKT->KALK",3,70)
        @ m_x+2, m_y+2 SAY "Konto razduzuje" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
        read
    BoxC()
    cSufiks:=SufBrKalk(cIdKonto2)
    cBrKalk:=SljBrKalk("14", cIdFirma, cSufiks)
    //cBrKalk:=GetNextKalkDoc(cIdFirma, "14")
else
    //******* izbaceno koristenje stare funkcije !!!
    //cBrKalk:=SljBrKalk("14",cIdFirma)
    cBrKalk:=GetNextKalkDoc(cIdFirma, "14")
endif

Box(,15,60)

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 14 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  //@ m_x+3,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  @ m_x+4,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" when !glBrojacPoKontima valid P_Konto(@cIdKonto2)
  if gNW<>"X"
   @ m_x+4,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif

  cFaktFirma:=IF(cIdKonto2==gKomKonto,gKomFakt,cIdFirma)
  @ m_x+6,m_y+2 SAY "Broj fakture: " GET cFaktFirma
  @ m_x+6,col()+2 SAY "- "+cidtipdok
  @ m_x+6,col()+2 SAY "-" GET cBrDok
  read
  if lastkey()==K_ESC
    exit
  endif

  select fakt
  seek cFaktFirma+cIdTipDok+cBrDok
  if !found()
     Beep(4)
     @ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     inkey(4)
     @ m_x+14,m_y+2 SAY space(30)
     loop
  else
     IF lVrsteP
       cIdVrsteP := idvrstep
     ENDIF
     aMemo:=parsmemo(txt)
     if len(aMemo)>=5
       @ m_x+10,m_y+2 SAY padr(trim(amemo[3]),30)
       @ m_x+11,m_y+2 SAY padr(trim(amemo[4]),30)
       @ m_x+12,m_y+2 SAY padr(trim(amemo[5]),30)
     else
        cTxt:=""
     endif
     if len(aMemo)>=9
       dDatPl:=ctod(aMemo[9])
     endif

     cIdPartner:=space(6)
     if !empty(idpartner)
       cIdPartner:=idpartner
     endif
     private cBeze:=" "
     @ m_x+14,m_y+2 SAY "Sifra partnera:"  GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
     @ m_x+15,m_y+2 SAY "<ENTER> - prenos" GET cBeze
     read; ESC_BCR

     select kalk_pripr
     locate for BrFaktP=cBrDok // faktura je vec prenesena
     if found()
      Beep(4)
      @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      inkey(4)
      @ m_x+8,m_y+2 SAY space(30)
      loop
     endif
     go bottom
     if brdok==cBrKalk
     nRbr:=val(Rbr)
     endif
     select fakt
     IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       LOOP
     ENDIF

     if fdoks2
        select kalk_doks2; hseek cidfirma+"14"+cbrkalk
        if !found()
           append blank
           replace idvd with "14",;   // izlazna faktura
                   brdok with cBrKalk,;
                   idfirma with cidfirma
        endif
        replace DatVal with dDatPl
        IF lVrsteP
          replace k2 with cIdVrsteP
        ENDIF
        select fakt

     endif

     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA
       hseek fakt->idroba

       select tarifa
       hseek roba->idtarifa

       if (RobaZastCijena(roba->idTarifa) .and. !IsPdvObveznik(cIdPartner))
            // nije pdv obveznik
        // roba ima zasticenu cijenu
            nRabat := 0
       else
        nRabat:= fakt->rabat
       endif

       select fakt
       if alltrim(podbr)=="."  .or. roba->tip $ "UY"
          skip
      loop
       endif

       select kalk_pripr
       APPEND BLANK
       replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with "14",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idpartner with cIdPartner,;
               idtarifa with ROBA->idtarifa,;
               brfaktp with fakt->brdok,;
               datfaktp with fakt->datdok,;
               idkonto   with cidkonto,;
               idkonto2  with cidkonto2,;
               idzaduz2  with cidzaduz2,;
               datkurs with fakt->datdok,;
               kolicina with fakt->kolicina,;
               idroba with fakt->idroba,;
               nc  with ROBA->nc,;
               vpc with fakt->cijena,;
               rabatv with nRabat,;
               mpc with fakt->porez
       select fakt
       skip
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     if gBrojac=="D"
      cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     endif
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
  endif

enddo
BoxC()
closeret
return


static function _o_prenos_tbls()
O_KONCIJ
O_KALK_PRIPR
O_KALK
O_KALK_DOKS
O_ROBA
O_KONTO
O_PARTN
O_TARIFA
O_FAKT
return

// ----------------------------------------------------------
// magacin: fakt->kalk prenos otpremnica
// ----------------------------------------------------------
function mag_fa_ka_prenos_otpr(cIndik)
local cIdFirma := gFirma
local cIdTipDok := "12"
local cBrDok := SPACE(8)
local cBrKalk := SPACE(8)
local cTipKalk := "96"
local cFaktDob := SPACE(10)
local dDatKalk, cIdZaduz2, cIdKonto, cIdKonto2
local cSufix

IF cIndik != nil .and. cIndik == "19"
    cIdTipDok := "19"
ENDIF

IF cIndik != nil .and. cIndik == "0x"
    cIdTipDok := "0x"
ENDIF

IF cIndik = "01_10"
    cTipKalk:="10"
    cIdtipdok:="01"
ELSEIF cIndik="0x"
    cTipKalk:="16"
ENDIF

_o_prenos_tbls()

dDatKalk := date()

IF cIdTipDok=="01"
    cIdKonto:=padr("1310",7)
    cIdKonto2:=padr("",7)
ELSEIF cIdTipDok=="0x"
    cIdKonto:=padr("1310",7)
    cIdKonto2:=padr("",7)
ELSE
    cIdKonto:=padr("",7)
    cIdKonto2:=padr("1310",7)
ENDIF

cIdZaduz2 := space(6)

IF glBrojacPoKontima
    
    Box("#FAKT->KALK",3,70)
        @ m_x+2, m_y+2 SAY "Konto zaduzuje" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
        read
    BoxC()
    
    cSufiks := SufBrKalk( cIdKonto )
    cBrKalk := SljBrKalk( cTipKalk, cIdFirma, cSufiks )

ELSE
    
    cBrKalk := GetNextKalkDoc( cIdFirma, cTipKalk )
    
ENDIF

Box(,15,60)

do while .t.

    nRBr := 0
  
    @ m_x+1,m_y+2   SAY "Broj kalkulacije "+cTipKalk+" -" GET cBrKalk pict "@!"
    @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
    @ m_x+3,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" when !glBrojacPoKontima valid P_Konto(@cIdKonto)
    @ m_x+4,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" valid empty(cidkonto2) .or. P_Konto(@cIdKonto2)
    if gNW<>"X"
        @ m_x+4,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
    endif

    cFaktFirma := cIdFirma
  
    @ m_x+6,m_y+2 SAY SPACE(60)
    @ m_x+6,m_y+2 SAY "Broj dokumenta u FAKT: " GET cFaktFirma
    @ m_x+6,col()+1 SAY "-" GET cIdTipDok VALID cIdTipDok $ "00#01#10#12#19#16"
    @ m_x+6,col()+1 SAY "-" GET cBrDok

    read

    if cIDTipDok == "10" .and. cTipKalk == "10"
        @ m_x + 7, m_y + 2 SAY "Faktura dobavljaca: " GET cFaktDob
    else
        cFaktDob := cBrDok
    endif
 
    read
  
    if lastkey()==K_ESC
        exit
    endif

    select fakt
    seek cFaktFirma+cIdTipDok+cBrDok
  
    if !found()
        Beep(4)
        @ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
        inkey(4)
        @ m_x+14,m_y+2 SAY space(30)
        loop
    else
        aMemo:=parsmemo(txt)
        if len(aMemo)>=5
            @ m_x+10,m_y+2 SAY padr(trim(amemo[3]),30)
            @ m_x+11,m_y+2 SAY padr(trim(amemo[4]),30)
            @ m_x+12,m_y+2 SAY padr(trim(amemo[5]),30)
        else
            cTxt:=""
        endif
     
        // uzmi i partnera za prebaciti
        cIdPartner := field->idpartner
     
        private cBeze:=" "

        if cTipKalk $ "10"
       
            cIdPartner:=space(6)
            @ m_x+14,m_y+2 SAY "Sifra partnera:"  GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
            @ m_x+15,m_y+2 SAY "<ENTER> - prenos" GET cBeze
       
            read
     
        endif

        select kalk_pripr
        locate for BrFaktP=cBrDok // faktura je vec prenesena
        if found()
            Beep(4)
            @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
            inkey(4)
            @ m_x+8,m_y+2 SAY space(30)
            loop
        endif
     
        go bottom
     
        if brdok == cBrKalk
            nRbr:=val(Rbr)
        endif

        SELECT KONCIJ
        SEEK TRIM(cIdKonto)

        select fakt
     
        IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
            MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
            LOOP
        ENDIF
     
        do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
            select ROBA
            hseek fakt->idroba

            select tarifa
            hseek roba->idtarifa

            select fakt
            if alltrim(podbr)=="."  .or. roba->tip $ "UY"
                skip
                loop
            endif

            select kalk_pripr
            APPEND BLANK
            replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with cTipKalk,;
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idpartner with cIdPartner,;
               idtarifa with ROBA->idtarifa,;
               brfaktp with cFaktDob,;
               datfaktp with fakt->datdok,;
               idkonto   with cidkonto,;
               idkonto2  with cidkonto2,;
               idzaduz2  with cidzaduz2,;
               datkurs with fakt->datdok,;
               kolicina with fakt->kolicina,;
               idroba with fakt->idroba,;
               nc  with ROBA->nc,;
               vpc with fakt->cijena,;
               rabatv with fakt->rabat,;
               mpc with fakt->porez

            if cTipKalk $ "10#16" // kod ulaza puni sa cijenama iz sifranika
                // replace vpc with roba->vpc
                replace vpc with KoncijVPC()
            endif

            if cTipKalk $ "96" .and. fakt->(fieldpos("idrnal"))<>0
                replace idzaduz2 with fakt->idRNal
            endif

            select fakt
            skip

        enddo
     
        @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     
        if gBrojac=="D"
            cBrKalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
        endif
     
        inkey(4)
     
        @ m_x+8,m_y+2 SAY space(30)
  
    endif

enddo

BoxC()

close all

return



// ----------------------------------------------------------
// magacin: fakt->kalk prenos otpremnica za period
// ----------------------------------------------------------
function mag_fa_ka_prenos_otpr_period()
local _id_firma := gFirma
local _fakt_id_firma := gFirma
local _tip_dok_fakt := PADR( "12;", 150 )
local _dat_fakt_od, _dat_fakt_do
local _br_kalk_dok := SPACE(8)
local _tip_kalk := "96"
local _dat_kalk
local _id_konto
local _id_konto_2
local _sufix, _r_br, _razduzuje
local _fakt_dobavljac := SPACE(10)
local _artikli := SPACE(150)
local _usl_roba

_o_prenos_tbls()

_dat_kalk := DATE()
_id_konto := PADR( "", 7 )
_id_konto_2 := PADR( "1010", 7 )
_razduzuje := SPACE(6)
_dat_fakt_od := DATE()
_dat_fakt_do := DATE()
_br_kalk_dok := GetNextKalkDoc( _id_firma, _tip_kalk )
    
Box(, 15, 70 )

DO WHILE .t.

    _r_br := 0
  
    @ m_x + 1, m_y + 2 SAY "Broj kalkulacije " + _tip_kalk + " -" GET _br_kalk_dok PICT "@!"
    @ m_x + 1, col() + 2 SAY "Datum:" GET _dat_kalk
    @ m_x + 3, m_y + 2 SAY "Konto zaduzuje :" GET _id_konto PICT "@!" VALID EMPTY( _id_konto ) .OR. P_Konto( @_id_konto )
    @ m_x + 4, m_y + 2 SAY "Konto razduzuje:" GET _id_konto_2 PICT "@!" VALID EMPTY( _id_konto_2 ) .OR. P_Konto( @_id_konto_2 )

    if gNW <> "X"
        @ m_x + 4, col() + 2 SAY "Razduzuje:" GET _razduzuje PICT "@!" VALID EMPTY(_razduzuje) .OR. P_Firma( @_razduzuje )
    endif

    _fakt_id_firma := _id_firma
 
    // postavi uslove za period...
    @ m_x + 6, m_y + 2 SAY "FAKT: id firma:" GET _fakt_id_firma
    @ m_x + 7, m_y + 2 SAY "Vrste dokumenata:" GET _tip_dok_fakt PICT "@S30"
    @ m_x + 8, m_y + 2 SAY "Dokumenti u periodu od" GET _dat_fakt_od 
    @ m_x + 8, col() + 1 SAY "do" GET _dat_fakt_do

    // uslov za sifre artikla
    @ m_x + 10, m_y + 2 SAY "Uslov po artiklima:" GET _artikli PICT "@S30"
    
    READ

    IF LastKey() == K_ESC
        EXIT
    ENDIF

    SELECT fakt
    SET ORDER TO TAG "1"
    SEEK _fakt_id_firma
  
    DO WHILE !EOF() .AND. field->idfirma == _fakt_id_firma

        // provjeri po vrsti dokumenta
        IF !( field->idtipdok $ _tip_dok_fakt )
            SKIP
            LOOP
        ENDIF

        // provjeri po datumskom uslovu
        IF field->datdok < _dat_fakt_od .OR. field->datdok > _dat_fakt_do  
            SKIP
            LOOP
        ENDIF

        // provjera po robama...
        IF !EMPTY( _artikli )

            _usl_roba := Parsiraj( _artikli, "idroba" )
                   
            IF !( &_usl_roba )
                SKIP
                LOOP
            ENDIF
          
        ENDIF

        SELECT KONCIJ
        SEEK TRIM( _id_konto )

        SELECT fakt
     
        // provjeri sifru u sifrarniku...
        IF !ProvjeriSif("!eof() .and. '" + fakt->idfirma + fakt->idtipdok + fakt->brdok + "'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
            MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
            LOOP
        ENDIF
     
        SELECT ROBA
        hseek fakt->idroba

        SELECT tarifa
        hseek roba->idtarifa

        SELECT fakt

        // preskoci ako su usluge ili podbroj stavke...
        IF ALLTRIM( podbr ) == "." .OR. roba->tip $ "UY"
            SKIP
            LOOP
        ENDIF

        // dobro, sada imam prave dokumente koje treba da prebacujem,
        // bacimo se na posao...

        SELECT kalk_pripr
        GO BOTTOM
        // provjeri da li već postoji artikal prenesen, pa ga saberi sa prethodnim
        LOCATE FOR idroba == fakt->idroba        

        IF FOUND()

            // saberi ga sa prethodnim u pripremi
            REPLACE kolicina with kolicina + fakt->kolicina        
        
        ELSE
            
            // nema artikla, dodaj novi...        
            APPEND BLANK

            REPLACE idfirma with _id_firma,;
               rbr with str( ++ _r_br, 3 ),;
               idvd with _tip_kalk,;
               brdok with _br_kalk_dok,;
               datdok with _dat_kalk,;
               idpartner with "",;
               idtarifa with ROBA->idtarifa,;
               brfaktp with _fakt_dobavljac,;
               datfaktp with fakt->datdok,;
               idkonto   with _id_konto,;
               idkonto2  with _id_konto_2,;
               idzaduz2  with _razduzuje,;
               datkurs with fakt->datdok,;
               kolicina with fakt->kolicina,;
               idroba with fakt->idroba,;
               nc  with ROBA->nc,;
               vpc with fakt->cijena,;
               rabatv with fakt->rabat,;
               mpc with fakt->porez

            IF _tip_kalk $ "96" .and. fakt->(fieldpos("idrnal")) <> 0
                REPLACE idzaduz2 with fakt->idRNal
            ENDIF

        ENDIF

        SELECT fakt
        SKIP
    
    ENDDO
     
    @ m_x + 14, m_y + 2 SAY "Dokument je generisan !!"
     
    inkey(4)
     
    @ m_x + 14, m_y + 2 SAY SPACE(30)
  
ENDDO

BoxC()

close all

return




// --------------------------
// --------------------------
function SufBrKalk(cIdKonto)

local nArr    := SELECT()
local cSufiks := SPACE(3)

select koncij
seek cIdKonto

if found() 
    if FIELDPOS("sufiks") <> 0
        cSufiks := field->sufiks
    endif
endif
select (nArr)

return cSufiks

// --------------------------
// --------------------------
function IsNumeric(cString)
*{
if AT(cString, "0123456789")<>0
    lResult:=.t.
else
    lResult:=.f.
endif

return lResult
*}

