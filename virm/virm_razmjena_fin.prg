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


function virm_prenos_fin()
local _firma := PADR( fetch_metric("virm_org_id", nil, "" ), 6 )

O_JPRIH
O_SIFK
O_SIFV
O_BANKE
O_PARTN
O_VRPRIM
O_VIRM_PRIPR
O_FIN_PRIPR

cKome_Txt:=""

qqKonto:=padr(IzFmkIni("VIRM","UslKonto","5;"),60)
dDatVir:=datdok

cDOpis:=space(36)

private cKo_txt:= ""
private cKo_zr:=""

Box(,5,70)

 @ m_x+1,m_y+2 SAY "PRENOS FIN NALOGA (koji je trenutno u pripremi) u VIRM"
 cIdBanka:=padr(cko_zr,3)
 @ m_x+2,m_y+2 SAY "Posiljaoc (sifra banke):       " GET cIdBanka valid  OdBanku( _firma, @cIdBanka )
 read
 cKo_zr:=cIdBanka
 select partn
 seek gVirmFirma
 select fin_pripr
 cKo_txt := trim(partn->naz) + ", " + trim(partn->mjesto)+", "+trim(partn->adresa) + ", " + trim(partn->telefon)
 @ m_x+3,m_y+2 SAY "Konta za koja se prave virmani ?"  GET qqKonto pict "@!S30"
 @ m_x+4,m_y+2 SAY "Dodatak na opis:" GET cDOpis
 @ m_x+5,m_y+2 SAY "Datum" GET dDatVir
 read; ESC_BCR
BoxC()

UzmiIzIni(EXEPATH+"fmk.ini","VIRM","UslKonto",qqKonto,"WRITE")

select fin_pripr

private aUsl1:=Parsiraj(qqKonto,"IdKonto")
if aUsl1<>NIL
 set filter to &aUsl1
endif
go top


// fin_pripr finansije

nRbr:=0
do while !eof()

    select VRPRIM
    set order to TAG "IDKONTO"

     if empty(fin_pripr->idpartner)
       hseek fin_pripr->(idkonto)
     else
       hseek fin_pripr->(idkonto+idpartner)
     endif

     select VRPRIM
     if found()
        cSvrha_pl:=id
     else // probaj 6000, 6010 naci
        hseek fin_pripr->(idkonto)
        if found() .and. VRPRIM->dobav=="D"
          cSvrha_pl:=id
          select partn
          seek fin_pripr->idpartner
          cU_korist:=id
          cKome_txt:=naz
          cKome_zr:=ziror
          cKome_sj:=mjesto
          cNacPl:="1"
          Box(,3,70)
            _IdBanka2:=space(3)
            _u_korist:=cu_korist
            _kome_txt:=cKome_txt
            _kome_zr:=cKome_zr
            Beep(1)
              cIdBanka2:=space(3)
              @ m_x+1,m_y+2 SAY ckome_txt+" "+fin_pripr->brdok+str(fin_pripr->iznosbhd,12,2)
              @ m_x+2,m_y+2 SAY "Primaoc (partner/banka):" GET _u_korist valid P_Firma(@_u_korist)  pict "@!"
              @ m_x+2,col()+2 GET _IdBanka2 valid {|| OdBanku(cu_korist,@_IdBanka2), SetPrimaoc()}
            read
            cKome_txt:=_kome_txt
            cKome_zr:=_kome_zr
            cu_korist:=_u_korist

          BoxC()
          //if cnacpl=="2"
            //ckome_zr:=dziror
          //endif
       else
         select fin_pripr
         skip
         loop
        endif
     endif

     cTmp_doz := fin_pripr->brdok

     if !EMPTY( cTmp_doz )
        cTmp_doz := "rn: " + cTmp_doz
     endif

     // firma nalogdbodavac
     select partn
     hseek  gVirmFirma


     select virm_pripr
     APPEND BLANK
     replace rbr with ++nrbr, ;
             mjesto with gmjesto,;
             svrha_pl with csvrha_pl,;
             iznos with fin_pripr->iznosbhd,;
             na_teret  with gVirmFirma,;
             Ko_Txt with cKo_txt,;
             Ko_ZR with  cKo_zr ,;
             kome_txt with VRPRIM->naz,;
             kome_sj  with "",;
             kome_zr with VRPRIM->racun,;
             dat_upl with dDatVir,;
             svrha_doz with trim(VRPRIM->pom_txt) + ;
            " " + cTmp_doz + " " + cDOpis


           //  Ko_SJ  with partn->Mjesto,;
           //  nacpl with VRPRIM->nacin_pl, ;
           //  orgjed with gorgjed,;
           //  dat_dpo with dDatVir,;
           //  sifra with VRPRIM->sifra

     //if nacpl=="2"
     //       replace iznos with fin_pripr->iznosDEM,;
     //               ko_zr with partn->dziror
     //endif

     if VRPRIM->dobav=="D"
         if valtype(cKome_Txt)<>"C"  .or. empty(ckome_Txt)
             Beep(2)
             Msg("Nije pronadjen dobavljac !!")
         else
             replace kome_txt with cKome_txt, ;
                  kome_zr with cKome_zr ,;
                  kome_sj with cKome_sj ,;
                  u_korist with cU_korist

           //if cNacPl=="1"
                replace iznos with fin_pripr->iznosbhd
                //       nacpl with   cNacPl
           //else
           //     replace iznos with fin_pripr->iznosdem ,;
           //            nacpl with   cNacPl
           //endif
         endif
     endif

     select fin_pripr
     skip

enddo

select virm_pripr

FillJPrih()  
// popuni polja javnih prihoda

return





