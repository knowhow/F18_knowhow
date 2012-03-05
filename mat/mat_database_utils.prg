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


#include "mat.ch"


// otvara potrebne tabele za povrat
static function _o_tables()
O_MAT_SUBAN
O_MAT_ANAL
O_MAT_SINT
O_MAT_NALOG
O_MAT_PRIPR
O_ROBA
O_SIFK
O_SIFV
return


// ---------------------------------------------
// povrat naloga u pripremu
// ---------------------------------------------
function mat_povrat_naloga( lStorno )
local _rec
local nRec
local _del_rec, _ok
local _field_ids, _where_block

if lStorno == NIL 
    lStorno := .f.
endif

_o_tables()

SELECT MAT_SUBAN
set order to tag "4"

cIdFirma := gFirma
cIdFirma2 := gFirma
cIdVN := cIdVN2  := space(2)
cBrNal:= cBrNal2 := space(4)

Box("", IIF(lStorno, 3, 1), IIF(lStorno, 65, 35))

 @ m_x + 1, m_y + 2 SAY "Nalog:"

 if gNW=="D"
      @ m_x+1,col()+1 SAY cIdFirma PICT "@!"
 else
      @ m_x+1,col()+1 GET cIdFirma PICT "@!"
 endif

 @ m_x + 1, col() + 1 SAY "-" GET cIdVN PICT "@!"
 @ m_x + 1, col() + 1 SAY "-" GET cBrNal VALID !EMPTY( cBrNal )

 IF lStorno

   @ m_x+3,m_y+2 SAY "Broj novog naloga (naloga storna):"

   if gNW=="D"
       @ m_x+3, col()+1 SAY cIdFirma2
   else
       @ m_x+3, col()+1 GET cIdFirma2
   endif

   @ m_x + 3, col() + 1 SAY "-" GET cIdVN2 PICT "@!"
   @ m_x + 3, col() + 1 SAY "-" GET cBrNal2

 ENDIF

 read
 ESC_BCR

BoxC()


if Pitanje(,"Nalog " + cIdFirma + "-" + cIdVN + "-" + cBrNal + IIF(lStorno," stornirati"," povuci u pripremu") + " (D/N) ?","D") == "N"
    close all
    return
endif

lBrisi := .t.

IF !lStorno
    lBrisi := ( Pitanje(,"Nalog "+cIdFirma+"-"+cIdVN+"-"+cBrNal + " izbrisati iz baze azuriranih dokumenata (D/N) ?","D") == "D" )
ENDIF

MsgO("Punim pripremu sa mat_suban: " + cIdfirma + cIdvn + cBrNal )

select MAT_SUBAN
seek cIdfirma + cIdvn + cBrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal

   select mat_pripr

   select mat_suban

   _rec := dbf_get_rec()

   select mat_pripr
   
   if lStorno
       _rec["idfirma"]  := cIdFirma2
       _rec["idvn"]     := cIdVn2
       _rec["brnal"]    := cBrNal2
       _rec["iznos"] := -_iznos
       _rec["iznos2"] := -_iznos2
   endif

   APPEND BLANK

   dbf_update_rec( _rec )

   select MAT_SUBAN
   skip

enddo

MsgC()

if !lBrisi
    close all
    return
endif

_del_rec := hb_hash()
_del_rec["idfirma"] := cIdFirma
_del_rec["idvn"]    := cIdVn
_del_rec["brnal"]   := cBrNal 

if !lStorno

    _ok := .t.

    _field_ids := {"idfirma", "idvn", "brnal"}
    _where_block := { |x| "IDFIRMA=" + _sql_quote(x["idfirma"]) + " AND IDVN=" + _sql_quote(x["idvn"]) + " AND BRNAL=" + _sql_quote(x["brnal"]) } 

    MsgO("del mat_suban")
    // SUBAN TAG = "4"
    _ok :=  _ok .and. delete_rec_server_and_dbf("mat_suban", _del_rec, _field_ids, _where_block,  "4" )
    MsgC()

    MsgO("del mat_anal")
    _ok :=  _ok .and. delete_rec_server_and_dbf("mat_anal", _del_rec, _field_ids, _where_block,  "2" )
    MsgC()

    MsgO("del mat_sint")
    _ok :=  _ok .and. delete_rec_server_and_dbf("mat_sint", _del_rec, _field_ids, _where_block,  "2" )
    MsgC()

    MsgO("del mat_nalog")
    _ok :=  _ok .and. delete_rec_server_and_dbf("mat_nalog", _del_rec, _field_ids, _where_block,  "1" )
    MsgC()

endif

if !_ok
  MsgBeep("Ajoooooooj del suban/anal/sint/nalog nije ok ?! " + cIdFirma + "-" + cIdVn + "-" + cBrNal )
endif

close all
return



// ----------------------------------------------
// generacija dokumenta pocetnog stanja
// ----------------------------------------------
function mat_prenos_podataka()

O_MAT_PRIPR

if reccount2()<>0
    MsgBeep("Tabela pripreme mora biti prazna !!!")
    close all
    return
endif

zap
set order to
index on idfirma+idkonto+idpartner+idroba to "PRIPTMP"
GO TOP

Box(,5,60)
    nMjesta := 3
    dDatDo := DATE()
    @ m_x+3, m_y+2 SAY "Datum do kojeg se promet prenosi" GET dDatDo
    read
    ESC_BCR
BoxC()

START PRINT CRET

O_MAT_SUBAN

// ovo je bio stari indeks, stari prenos bez partnera
//set order to tag "3"
// "3" - "IdFirma+IdKonto+IdRoba+dtos(DatDok)"

set order to tag "5"
// "5" - "IdFirma+IdKonto+IdPartner+IdRoba+dtos(DatDok)"

? "Prolazim kroz bazu...."
select mat_suban
go top

// idfirma, idkonto, idpartner, idroba, datdok
do while !eof()

    nRbr := 0
    cIdFirma := idfirma
    
    do while !eof() .and. cIdFirma == IdFirma
      
        cIdKonto := IdKonto
        select mat_suban
      
        nDin:=0
        nDem:=0
      
        do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto
        
            cIdPartner := idpartner

            do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto .and. IdPartner==cIdPartner
    
                cIdRoba:=IdRoba
        
                ? "Konto:", cIdKonto, ", partner:", cIdPartner, ", roba:", cIdRoba
        
                do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto .and. IdRoba==cIdRoba
         
                    select mat_pripr
         
                    hseek mat_suban->(idfirma + idkonto + idpartner + idroba)
         
                    if !found()

                        append blank
                
                        replace idfirma with cIdFirma
                        replace idkonto with cIdkonto
                        replace idpartner with cIdPartner
                        replace idRoba  with cIdRoba
                        replace datdok with dDatDo + 1
                        replace datkurs with dDatDo + 1
                        replace idvn with "00"
                        replace idtipdok with "00"
                        replace brnal with "0001"
                        replace d_p with "1"
                        replace u_i with "1"
                        replace rbr with "9999"
                        replace kolicina with ;
                            iif(mat_suban->U_I=="1", mat_suban->kolicina, ;
                                -mat_suban->kolicina)
                        replace iznos with ;
                            iif(mat_suban->D_P=="1", mat_suban->iznos, ;
                                -mat_suban->iznos)
                        replace iznos2 with ;
                            iif(mat_suban->D_P=="1", mat_suban->iznos2, ;
                                -mat_suban->iznos2)
            
                    else
           
                        replace kolicina with ;
                            kolicina + iif(mat_suban->U_I=="1", ;
                            mat_suban->kolicina, -mat_suban->kolicina)
                        
                        replace iznos with ;
                            iznos + iif(mat_suban->D_P=="1", ;
                            mat_suban->iznos,-mat_suban->iznos)
                        
                        replace iznos2 with ;
                            iznos2 + iif(mat_suban->D_P=="1", ;
                            mat_suban->iznos2,-mat_suban->iznos2)
         
                    endif
         
                    select mat_suban
                    skip
        
                enddo 
                //  roba

            enddo 
            // partner

        enddo 
        // konto
  
    enddo 
    // firma

enddo 
// eof

select mat_pripr
// set order to 0
set order to
go top
do while !eof()
    if round(iznos,2)==0 .and. round(iznos2,2)==0 .and. ;
        round(kolicina,3) == 0
            dbdelete2()
    endif
    skip
enddo
__dbpack()

set order to tag "1"
go top

nTrec := 0

do while !eof()
    cIdFirma := idfirma
    nRbr := 0
    do while !eof() .and. cIdFirma==IdFirma
        skip 
        nTrec := recno()
        skip -1
        replace rbr with str(++nRbr,4)
        replace cijena with iif(Kolicina<>0,Iznos/Kolicina,0)
        go nTrec
    enddo
enddo
close all

END PRINT

closeret

return




