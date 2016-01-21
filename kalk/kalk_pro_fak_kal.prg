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



// ---------------------------------------------
// meni za razmjenu dokumenata proizvodnje
// ---------------------------------------------
function FaKaProizvodnja()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc,"1. fakt->kalk 96 po normativima za period            ")
AADD(_opcexe,{||          PrenosNo()  })
AADD(_opc,"2. fakt->kalk 96 po normativima po fakturama")
AADD(_opcexe,{||          PrenosNoFakt()  })
AADD(_opc,"3. fakt->kalk 10 got.proizv po normativima za period")
AADD(_opcexe,{||          PrenosNo2() })

f18_menu("fkno", .f., _izbor, _opc, _opcexe )

return


// -------------------------------------------------------
// prenos po normativima za period
// -------------------------------------------------------
function PrenosNo( dD_from, dD_to, cIdKonto2, cIdTipDok, dDatKalk, cRobaUsl, ;
    cRobaIncl, cSezona, cSirovina )

local lTest := .f.
local cBrDok := SPACE(8)
local cBrKalk := SPACE(8)
local cIdFirma := gFirma
local cIdKonto:=padr("",7)
local cIdZaduz2:=space(6)

if pcount() == 0
    cIdTipDok:="10;11;12;      "
    cRobaUsl:=SPACE(100)
    cRobaIncl:="I"
    dDatKalk := date()
    cIdKonto2 := padr("1310",7)
    cSezona := ""
    cSirovina := ""
else
    lTest := .t.
endif


o_tbl_roba( lTest, cSezona )
o_tables()

if !EMPTY( cSirovina )
    O_R_EXP
endif

if gBrojac=="D" .and. lTest == .f.
    select kalk
    set order to tag "1"
    seek cidfirma+"96X"
    skip -1
    if idvd<>"96"
        cbrkalk:=space(8)
    else
        cbrkalk:=brdok
    endif
endif

if lTest == .t.
    cBrKalk := "99999"
endif

Box(,15,60)

if gBrojac=="D" .and. lTest == .f.
    cbrkalk := UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  
  if lTest == .f.
  
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 96 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif
  @ m_x+4,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)

  cFaktFirma:=cIdFirma
  dDatFOd:=ctod("")
  dDatFDo:=date()
  @ m_x+6,m_y+2 SAY "RJ u FAKT: " GET  cFaktFirma
  @ m_x+7,m_Y+2 SAY "Dokumenti tipa iz fakt:" GET cidtipdok
  @ m_x+8,m_y+2 SAY "period od" GET dDAtFOd
  @ m_x+8,col()+2 SAY "do" GET dDAtFDo
  
  @ m_x+10,m_y+2 SAY "Uslov za robu:" GET cRobaUsl PICT "@S40"
  @ m_x+11,m_y+2 SAY "Navedeni uslov [U]kljuciti / [I]skljuciti" GET cRobaIncl VALID cRobaIncl$"UI" PICT "@!"
  
  read
  
  if lastkey()==K_ESC
    exit
  endif

  endif

  if lTest == .t.
    dDatFOd := dD_from
    dDatFDo := dD_to
    cFaktFirma := "10"
  endif

  select fakt
  seek cFaktFirma
  
  IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+"'==IdFirma","IDROBA",F_ROBA,"idtipdok $ '"+cIdTipdok+"' .and. dDatFOd<=datdok .and. dDatFDo>=datdok", lTest )
    
        MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
    loop
    
  ENDIF
  
  aNotIncl := {}
  
  do while !eof() .and. cFaktFirma==IdFirma

    if idtipdok $ cIdTipdok .and. dDatFOd<=datdok .and. dDatFDo>=datdok 
        // pripada odabranom intervalu

       cFBrDok := fakt->brdok

       select kalk_doks
       set order to tag "V_BRF"
       go top
       seek PADR( cFBrDok, 10 ) + "96"

       if FOUND() .and. ALLTRIM(kalk_doks->brfaktp) == ALLTRIM(cFBrDok) .and. kalk_doks->idvd == "96"
            
        cTmp := fakt->idfirma + "-" + (cFBrDok)
        dTmpDate := fakt->datdok
        
        select partn
        hseek fakt->idpartner
        
        cTmpPartn := ALLTRIM( partn->naz )
        
        select kalk_doks
        
        nScan := ASCAN(aNotIncl, {|xVar| xVar[1] == cTmp })
        
        if nScan == 0
            AADD(aNotIncl, { cTmp, dTmpDate, cTmpPartn, kalk_doks->idvd + "-" + kalk_doks->brdok })
        endif
        
        select fakt
        skip
        loop
        
       endif
       
       select ROBA
       hseek fakt->idroba
       
       // provjeri prije svega uslov za robu...
       if !EMPTY( cRobaUsl )
       
        cTmp := Parsiraj( cRobaUsl, "idroba" )
       
            if &cTmp
            if cRobaIncl == "I"
                select fakt
                skip
                loop
            endif
        else
                if cRobaIncl == "U"
                    select fakt
                    skip
                    loop
            endif
        endif
       
       endif
       
       if roba->tip = "P"  
          
      // radi se o proizvodu

          select sast
          hseek  fakt->idroba
          
      do while !eof() .and. id==fakt->idroba // setaj kroz sast
            
        if !EMPTY( cSirovina )
            if cSirovina <> sast->id2
            skip
            loop
        endif
        endif
        
        select roba
        hseek sast->id2
            
        select kalk_pripr
        locate for idroba==sast->id2
            
        if found()

              RREPLACE kolicina with kolicina + fakt->kolicina*sast->kolicina
            
        else
              
          select kalk_pripr
              append blank
              replace idfirma with cIdFirma,;
                      rbr     with str(++nRbr,3),;
                       idvd with "96",;   // izlazna faktura
                       brdok with cBrKalk,;
                       datdok with dDatKalk,;
                       idtarifa with ROBA->idtarifa,;
                       brfaktp with "",;
                       datfaktp with dDatKalk,;
                       idkonto   with cidkonto,;
                       idkonto2  with cidkonto2,;
                       idzaduz2  with cidzaduz2,;
                       kolicina with fakt->kolicina*sast->kolicina,;
                       idroba with sast->id2,;
                       nc  with ROBA->nc,;
                       vpc with fakt->cijena,;
                       rabatv with fakt->rabat,;
                       mpc with fakt->porez
            
     
        endif
            
        if !EMPTY( cSirovina )
    
           select r_export
           append blank
               
           replace field->idsast with cSirovina
           replace field->idroba with fakt->idroba
           replace field->r_naz with ""
           replace field->idpartner with fakt->idpartner
           replace field->rbr with fakt->rbr
           replace field->brdok with fakt->idtipdok + ;
                "-" + fakt->brdok
           replace field->kolicina with fakt->kolicina
           replace field->kol_sast with ;
                fakt->kolicina * sast->kolicina

    
        endif

        select sast
            skip
          
      enddo

       endif // roba->tip == "P"
    endif  // $ cidtipdok
    select fakt
    skip
  enddo
  
  if lTest == .f.

    if LEN(aNotIncl) > 0
    rpt_not_incl( aNotIncl )
    endif

    @ m_x+10,m_y+2 SAY "Dokumenti su preneseni !!"
  
    if gBrojac=="D"
    cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
    endif
  
    inkey(4)
    @ m_x+8,m_y+2 SAY space(30)

  else
    exit
  endif


enddo
Boxc()
if lTest == .f.
    closeret
endif
return

// ---------------------------------------------
// prikazi sta nije ukljuceno u prenos
// ---------------------------------------------
static function rpt_not_incl( aArr )
local i
local nCnt := 0

START PRINT CRET

? "----------------------------------------------"
? "U prenosu nisu ukljuceni sljedeci dokumenti:"
? "----------------------------------------------"

?
? "---- ----------- ----------- -------- --------------------------------------"
? "rbr  br.dok      br.dok       datum   partner" 
? "     u fakt      u kalk"
? "---- ----------- ----------- -------- --------------------------------------"

for i :=1 to LEN( aArr )

    //       rbr             brdok f.   brdok k.  datum       partner
    ? STR(++nCnt, 3) + ".", aArr[i, 1], aArr[i, 4], aArr[i, 2], aArr[i, 3]

next

?
? "Ovi dokumenti su preneseni opcijom prenosa po"
? "broju fakture."

FF
END PRINT

return


// -------------------------------------
// otvori tabele za prenos
// -------------------------------------
static function o_tables()

O_KALK_PRIPR
O_KALK
O_KALK_DOKS
O_KONTO
O_PARTN
O_TARIFA
O_FAKT


return


// -------------------------------------------
// otvaranje roba - sast
// -------------------------------------------
static function o_tbl_roba( lTest, cSezSif )
local cSifPath

if lTest == .t.
    my_close_all_dbf()
    
    cSifPath := PADR( SIFPATH , 14 )
    // "c:\sigma\sif1\"

    if !EMPTY( cSezSif ) .and. cSezSif <> "RADP"
        cSifPath += cSezSif + SLASH
    endif

    select (F_ROBA)
    use
    select (F_ROBA)
    use ( cSifPath + "ROBA" ) alias "ROBA"
    set order to tag "ID"

    select (F_SAST)
    use
    select (F_SAST)
    use ( cSifPath + "SAST" ) alias "SAST"
    set order to tag "ID"

else
    O_ROBA
    O_SAST
endif

return



// -------------------------------------------------------
// prenos po normativima po broju faktura
// -------------------------------------------------------
function PrenosNoFakt()
local cIdFirma := gFirma
local cIdTipDok := "10"
local cBrDok := space(8)
local cBrKalk := space(8)
local cFaBrDok := space(8)
// otvori tabele prenosa
o_tables()

dDatKalk := date()
cIdKonto := padr("",7)
cIdKonto2 := padr("1310",7)
cIdZaduz2 := space(6)

cBrkalk:=space(8)

if gBrojac=="D"
    select kalk
    set order to tag "1"
    seek cIdFirma + "96X"
    skip -1
    if idvd<>"96"
        cBrKalk:=space(8)
    else
        cBrKalk:=brdok
    endif
endif

Box(,15,60)

if gBrojac=="D"
    cBrKalk := UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

    nRBr:=0
  
    @ m_x+1,m_y+2   SAY "Broj kalkulacije 96 -" GET cBrKalk pict "@!"
    @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
    @ m_x+3,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  
    if gNW<>"X"
            @ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
    endif
  
    @ m_x+4,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)

    cFaktFirma:=cIdFirma
    
    @ m_x+6,m_y+2 SAY "RJ u FAKT: " GET  cFaktFirma
    @ m_x+7,m_Y+2 SAY "Dokument tipa u fakt:" GET cIdTipDok
    
    @ m_x+8,m_Y+2 SAY "Broj dokumenta u fakt:" GET cFaBrDok

    
    read
  
    if lastkey()==K_ESC
        exit
    endif

    select fakt
    seek cFaktFirma
    
    if !ProvjeriSif("!eof() .and. '"+cFaktFirma+"'==IdFirma","IDROBA",F_ROBA,"idtipdok = '"+cIdTipdok+"' .and. brdok = '" + cFaBrDok + "'" )
    
            MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
            loop
    endif
  
    do while !eof() .and. cFaktFirma==IdFirma

            if idtipdok = cIdTipdok .and. cFaBrDok = brdok 

                select ROBA
            hseek fakt->idroba
                if roba->tip="P"  
                // radi se o proizvodu
                select sast
                    hseek  fakt->idroba
                    do while !eof() .and. id==fakt->idroba 
                    // setaj kroz sast
                            select roba
                    hseek sast->id2
                            select kalk_pripr
                            locate for idroba==sast->id2
                            if found()
                                RREPLACE kolicina with kolicina + fakt->kolicina*sast->kolicina
                            else
                                select kalk_pripr
                                append blank
                                replace idfirma with cIdFirma,;
                                    rbr     with str(++nRbr,3),;
                                    idvd with "96",;   
                                    brdok with cBrKalk,;
                                    datdok with dDatKalk,;
                                    idtarifa with ROBA->idtarifa,;
                                    brfaktp with fakt->brdok,;
                        idpartner with fakt->idpartner,;
                                    datfaktp with dDatKalk,;
                                    idkonto   with cidkonto,;
                                    idkonto2  with cidkonto2,;
                                    idzaduz2  with cidzaduz2,;
                                    kolicina with fakt->kolicina*sast->kolicina,;
                                    idroba with sast->id2,;
                                    nc  with ROBA->nc,;
                                    vpc with fakt->cijena,;
                                    rabatv with fakt->rabat,;
                                    mpc with fakt->porez
                            endif
                            
                    select sast
                            skip
                    enddo

                endif 
            endif 
            
        select fakt
            skip
    enddo

    @ m_x+10,m_y+2 SAY "Dokumenti su preneseni !!"
    
    if gBrojac=="D"
        cBrKalk:=UBrojDok(val(left(cBrKalk,5)) +1, 5, right(cBrKalk,3))
    endif
  
    cFaBrDok := UBrojDok(val(left(cFaBrDok, 5)) + 1, 5, right(cFaBrDok,3))
  
    inkey(4)
    
    @ m_x+8,m_y+2 SAY space(30)

enddo

Boxc()
closeret

return



// ----------------------------------------------------------------------
// Prenos FAKT -> KALK 10 po normativima
// ----------------------------------------------------------------------
function PrenosNo2()
local cIdFirma := gFirma
local cIdTipDok := "10;11;12;      "
local cBrDok := SPACE(8)
local cBrKalk := SPACE(8)

O_KALK_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA
O_SAST
O_FAKT

dDatKalk := DATE()
cIdKonto := PADR( "5100", 7 )
cIdZaduz2 := SPACE(6)

if gBrojac=="D"
    select kalk
    set order to tag "1"
    seek cIdFirma + "10X"
    skip -1
    if idvd<>"10"
        cBrKalk := space(8)
    else
        cBrKalk := brdok
    endif
endif

Box(,15,60)

    if gBrojac == "D"
        cBrKalk := UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
    endif

    do while .t.

        nRBr:=0
        nRbr2:=900
        @ m_x+1,m_y+2   SAY "Broj kalkulacije 10 -" GET cBrKalk pict "@!"
        @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
        @ m_x+4,m_y+2   SAY "Konto got. proizvoda zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)

        cFaktFirma:=cIdFirma
        dDatFOd:=ctod("")
        dDatFDo:=date()
        @ m_x+6,m_y+2 SAY "RJ u FAKT: " GET  cFaktFirma
        @ m_x+7,m_Y+2 SAY "Dokumenti tipa iz fakt:" GET cidtipdok
        @ m_x+8,m_y+2 SAY "period od" GET dDAtFOd
        @ m_x+8,col()+2 SAY "do" GET dDAtFDo
        read
        
        if lastkey() == K_ESC
            exit
        endif

        select fakt
        seek cFaktFirma
        if !ProvjeriSif("!eof() .and. '"+cFaktFirma+"'==IdFirma","IDROBA",F_ROBA,"idtipdok $ '"+cIdTipdok+"' .and. dDatFOd<=datdok .and. dDatFDo>=datdok")
            MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
            loop
        endif

        do while !EOF() .and. cFaktFirma==IdFirma

            if idtipdok $ cIdTipdok .and. dDatFOd<=datdok .and. dDatFDo>=datdok // pripada odabranom intervalu

                select roba
                hseek fakt->idroba
                if roba->tip="P"  
                    // radi se o proizvodu

                    select roba
                    hseek fakt->idroba
                    
                    select kalk_pripr
                    locate for idroba==fakt->idroba
                    if found()
                        RREPLACE kolicina with kolicina + fakt->kolicina
                    else
                        select kalk_pripr
                        append blank
                        replace idfirma with cIdFirma,;
                                rbr     with str(++nRbr,3),;
                                idvd with "10",;   // izlazna faktura
                                brdok with cBrKalk,;
                                datdok with dDatKalk,;
                                idtarifa with ROBA->idtarifa,;
                                brfaktp with "",;
                                datfaktp with dDatKalk,;
                                idkonto   with cidkonto,;
                                idroba with fakt->idroba,;
                                vpc with fakt->cijena,;
                                rabatv with fakt->rabat,;
                                kolicina with fakt->kolicina,;
                                mpc with fakt->porez
                    endif

                endif 
            endif  

            select fakt
            skip
        enddo

        select kalk_pripr
        go top
  
        do while !eof()
            select sast
            hseek  kalk_pripr->idroba
            do while !eof() .and. id==kalk_pripr->idroba 
                // setaj kroz sast
                // utvr|ivanje nabavnih cijena po sastavnici !!!!!
                select roba
                hseek sast->id2
                
                select kalk_pripr
                // roba->nc - nabavna cijena sirovine
                // sast->kolicina - kolicina po jedinici mjera
                RREPLACE fcj with fcj + (roba->nc*sast->kolicina)
       
                select sast
                skip
            enddo

            select roba 
            // nafiluj nabavne cijene proizvoda u sifrarnik robe!!!
            hseek kalk_pripr->idroba
            
            if FOUND()
                _rec := dbf_get_rec()     
                _rec["nc"] := kalk_pripr->fcj
                update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )
            endif

            select kalk_pripr
            skip

        enddo
        
        @ m_x+10,m_y+2 SAY "Dokumenti su preneseni !!"
        
        if gBrojac=="D"
            cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
        endif
        
        inkey(4)
        @ m_x+8,m_y+2 SAY space(30)

    enddo
    
Boxc()

my_close_all_dbf()

return






