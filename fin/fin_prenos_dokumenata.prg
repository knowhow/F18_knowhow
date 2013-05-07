/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"


// ----------------------------------------------------------------
// kreiranje pomocne tabele temp77
// ----------------------------------------------------------------
static function _cre_temp77()
local _table := "temp77"
local _ret := .t.
local _dbf

if !FILE( my_home() + _table + ".dbf" )

    _dbf := DBSTRUCT()

    AADD( _dbf, {"KONTO2","C",7,0} )
    AADD( _dbf, {"PART2", "C",6,0} )
    AADD( _dbf, {"NSLOG","N",10,0} )

    DBCREATE( my_home() + _table + ".dbf", _dbf )

endif

my_use_temp( "TEMP77", my_home() + _table, .f., .t. )

ZAPP()

return


// ---------------------------------------------------------------
// prebacivanje kartica 
// ---------------------------------------------------------------
function fin_prekart()
local _arr := {}
local _usl_kto, _usl_part, _tmp_dbf
private _id_konto := fetch_metric( "fin_preb_kart_id_konto", my_user(), SPACE(60) )
private _id_partn := fetch_metric( "fin_preb_kart_id_partner", my_user(), SPACE(60) )
private _dat_od := fetch_metric( "fin_preb_kart_dat_od", my_user(), CTOD("") )
private _dat_do := fetch_metric( "fin_preb_kart_dat_do", my_user(), CTOD("") )
private _id_firma := gFirma

Msg( "Ova opcija omogucava prebacivanje svih ili dijela stavki sa#" + ;
     "postojeceg na drugi konto. Zeljeni konto je u tabeli prikazan#" + ;
     "u koloni sa zaglavljem 'Novi konto'. POSLJEDICA OVIH PROMJENA#" + ;
     "JE DA CE NALOZI KOJI SADRZE IZMIJENJENE STAVKE BITI RAZLICITI#" + ;
     "OD ODSTAMPANIH, PA SE PREPORUCUJE PONOVNA STAMPA TIH NALOGA." )

AADD ( _arr, { "Firma (prazno-sve)", "_id_firma",,,})
AADD ( _arr, { "Konto (prazno-sva)", "_id_konto",,"@!S30",})
AADD ( _arr, { "Partner (prazno-svi)", "_id_partner",,"@!S30",})
AADD ( _arr, { "Za period od datuma", "_dat_od",,,})
AADD ( _arr, { "          do datuma", "_dat_do",,,})

do while .t.
   
    if !VarEdit( _arr, 9,5,17,74,;
               'POSTAVLJANJE USLOVA ZA IZDVAJANJE SUBANALITICKIH STAVKI',;
               "B1")
        close all
        return
    endif
   
    _usl_kto := Parsiraj( _id_konto, "idkonto" )
    _usl_part := Parsiraj( _id_partn, "idpartner" )
    
    if _usl_kto <> NIL .and. _usl_part <> NIL
        exit
    elseif _usl_part <> NIL
        MsgBeep ("Kriterij za partnera nije korektno postavljen!")
    elseif _usl_kto <> NIL
        MsgBeep ("Kriterij za konto nije korektno postavljen!")
    else
        MsgBeep ("Kriteriji za konto i partnera nisu korektno postavljeni!")
    endif
 
enddo 

// otvaranje potrebnih baza
///////////////////////////

O_KONTO
O_PARTN
O_SINT
SET ORDER TO tag "2"
O_ANAL
SET ORDER TO tag "2"
O_SUBAN

// kreriraj i otvori temp77 na osnovu tabele suban
_cre_temp77()

SELECT ( F_SUBAN )

_filter := ".t." + IF(!EMPTY(_id_firma),".and.IDFIRMA=="+cm2str(_id_firma),"")+ IIF(!EMPTY(_dat_od),".and.DATDOK>="+cm2str(_dat_do),"")+;
           IF(!EMPTY(_dat_do), ".and.DATDOK<=" + cm2str(_dat_do),"") + ".and."+_usl_kto+".and."+_usl_part

_filter := STRTRAN( _filter , ".t..and." , "" )
 
IF !( _filter == ".t." )
    SET FILTER TO &(_filter)
ENDIF

GO TOP
DO WHILE !EOF()

    _rec := dbf_get_rec()
    _rec["konto2"] := _rec["idkonto"]
    _rec["part2"] := _rec["idpartner"]
    _rec["nslog"] := RECNO()
    
    SELECT TEMP77
    APPEND BLANK
    
    dbf_update_rec( _rec )
   
    SELECT F_SUBAN
    SKIP 1

ENDDO

SELECT TEMP77
GO TOP

ImeKol:={ ;
          {"F.",            {|| IdFirma }, "IdFirma" } ,;
          {"VN",            {|| IdVN    }, "IdVN" } ,;
          {"Br.",           {|| BrNal   }, "BrNal" },;
          {"R.br",          {|| RBr     }, "rbr" , {|| wrbr()}, {|| vrbr()} } ,;
          {"Konto",         {|| IdKonto }, "IdKonto", {|| .t.}, {|| P_Konto(@_IdKonto),.t. } } ,;
          {"Novi konto",    {|| konto2  }, "konto2", {|| .t.}, {|| P_Konto(@_konto2),.t. } } ,;
          {"Partner",       {|| IdPartner }, "IdPartner", {|| .t.}, {|| P_Firma(@_idpartner), .t. } } ,;
          {"Novi partner",  {|| part2  }, "part2", {|| .t.}, {|| P_Firma(@_part2),.t. } } ,;
      {"Br.veze ",      {|| BrDok   }, "BrDok" } ,;
          {"Datum",         {|| DatDok  }, "DatDok" } ,;
          {"D/P",           {|| D_P     }, "D_P" } ,;
          {ValDomaca(),     {|| transform(IznosBHD,FormPicL(gPicBHD,15)) }, "iznos "+ALLTRIM(ValDomaca()) } ,;
          {ValPomocna(),    {|| transform(IznosDEM,FormPicL(gPicDEM,10)) }, "iznos "+ALLTRIM(ValPomocna()) } ,;
          {"Opis",          {|| Opis      }, "OPIS" }, ;
          {"K1",            {|| k1      }, "k1" },;
          {"K2",            {|| k2      }, "k2" },;
          {"K3",            {|| k3iz256(k3)      }, "k3" },;
          {"K4",            {|| k4      }, "k4" } ;
        }

Kol:={}
for i := 1 to LEN(ImeKol)
    AADD( Kol, i )
next

DO WHILE .t.
 
    Box(,20,77)
        @ m_x+19,m_y+2 SAY "                         ³                        ³                   "
        @ m_x+20,m_y+2 SAY " <c-T>  Brisi stavku     ³ <ENTER>  Ispravi konto ³ <a-A> Azuriraj    "
        ObjDbedit("PPK",20,77,{|| EPPK()},"","Priprema za prebacivanje stavki", , , , ,2)
    BoxC()
    
    IF RECCOUNT2()>0
        i:=KudaDalje("ZAVRSAVATE SA PRIPREMOM PODATAKA. STA RADITI SA URADJENIM?",;
            { "AZURIRATI PODATKE",;
              "IZBRISATI PODATKE",;
              "VRATIMO SE U PRIPREMU" })
        DO CASE
            CASE i==1
                AzurPPK()
                EXIT
            CASE i==2
                EXIT
            CASE i==3
                GO TOP
        ENDCASE
    ELSE
        EXIT
    ENDIF
ENDDO

close all
return ( NIL )



static function EPPK()
local nTr2

if (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0
    return DE_CONT
endif

select temp77

do case

    case Ch==K_CTRL_T
        
        if Pitanje("p01","Zelite izbrisati ovu stavku ?","D")=="D"
            MY_DELETE
            return DE_REFRESH
        endif
        
        return DE_CONT

    case Ch==K_ENTER
        Scatter()
        IF !VarEdit({{"Konto","_konto2","P_Konto(@_konto2)",,}}, 9,5,17,74,;
               'POSTAVLJANJE NOVOG KONTA',;
               "B1")
            return DE_CONT
        ELSE
            Gather()
            return DE_REFRESH
        ENDIF

    case Ch==K_ALT_A
        AzurPPK()
        return DE_REFRESH

endcase

return DE_CONT



 
static function AzurPPK()
local lIndik1:=.f., lIndik2:=.f., nZapisa:=0, nSlog:=0, cStavka:="   "
  
SELECT SUBAN
SET FILTER TO
GO TOP
  
SELECT TEMP77
  
Postotak(1,RECCOUNT2(),"Azuriranje promjena na subanalitici",,,.t.)
  
GO TOP
  
f18_lock_tables({"fin_suban", "fin_anal", "fin_sint"})      
sql_table_update( nil, "BEGIN" )

DO WHILE !EOF()

    // azuriraj subanalitiku
    if ( TEMP77->idkonto != TEMP77->konto2 )  
        SELECT SUBAN
        GO TEMP77->NSLOG
        _rec := dbf_get_rec()
        _rec["idkonto"] := temp77->konto2
        update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )
    endif

    if ( TEMP77->idpartner != TEMP77->part2 )  
        SELECT SUBAN
        GO TEMP77->NSLOG
        _rec := dbf_get_rec()
        _rec["idpartner"] := temp77->part2
        update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )
    endif

    // azuriraj analitiku
    if TEMP77->idkonto!=TEMP77->konto2
    
        SELECT ANAL
        GO TOP
        SEEK TEMP77->(idfirma+idvn+brnal)
    
        lIndik1:=.f.
        lIndik2:=.f.
    
        DO WHILE !EOF() .and. idfirma+idvn+brnal==TEMP77->(idfirma+idvn+brnal)
    
            IF idkonto==TEMP77->idkonto .and. !lIndik1

                lIndik1:=.t.

                _rec := dbf_get_rec()

                IF TEMP77->d_p=="1"
                    _rec["dugbhd"] := _rec["dugbhd"] - TEMP77->iznosbhd
                    _rec["dugdem"] := _rec["dugdem"] - TEMP77->iznosdem
                ELSE
                    _rec["potbhd"] := _rec["potbhd"] - TEMP77->iznosbhd
                    _rec["potdem"] := _rec["potdem"] - TEMP77->iznosdem
                ENDIF

                update_rec_server_and_dbf( "fin_anal", _rec, 1, "CONT" )
    
            ELSEIF idkonto == TEMP77->konto2 .and. !lIndik2

                lIndik2:=.t.

                _rec := dbf_get_rec()

                IF TEMP77->d_p=="1"
                    _rec["dugbhd"] := _rec["dugbhd"] + TEMP77->iznosbhd
                    _rec["dugdem"] := _rec["dugdem"] + TEMP77->iznosdem
                ELSE
                    _rec["potbhd"] := _rec["potbhd"] + TEMP77->iznosbhd
                    _rec["potdem"] := _rec["potdem"] + TEMP77->iznosdem
                ENDIF

                update_rec_server_and_dbf( "fin_anal", _rec, 1, "CONT" )

            ENDIF

            SKIP 1

        ENDDO
        
        SKIP -1
      
        IF !lIndik2

            _rec := dbf_get_rec()

            _rec["idkonto"] := TEMP77->konto2
            _rec["rbr"] := NovaSifra( _rec["rbr"] )

            IF gDatNal=="N"
                _rec["datnal"] := TEMP77->datdok
            ENDIF

            _rec["dugbhd"] := IF(TEMP77->d_p=="1",TEMP77->iznosbhd,0)
            _rec["potbhd"] := IF(TEMP77->d_p=="2",TEMP77->iznosbhd,0)
            _rec["dugdem"] := IF(TEMP77->d_p=="1",TEMP77->iznosdem,0)
            _rec["potdem"] := IF(TEMP77->d_p=="2",TEMP77->iznosdem,0)

            APPEND BLANK

            update_rec_server_and_dbf( "fin_anal", _rec, 1, "CONT" )

        ENDIF
    
    endif

    // azuriraj sintetiku
    if LEFT( TEMP77->idkonto, 3 ) != LEFT( TEMP77->konto2, 3 )

        SELECT SINT
        GO TOP
        SEEK TEMP77->(idfirma+idvn+brnal)

        lIndik1:=.f.
        lIndik2:=.f.
        
        DO WHILE !EOF() .and. idfirma+idvn+brnal == TEMP77->(idfirma+idvn+brnal)
            
            IF idkonto==LEFT(TEMP77->idkonto,3) .and. !lIndik1

                lIndik1:=.t.
    
                _rec := dbf_get_rec()

                IF TEMP77->d_p=="1"
                    _rec["dugbhd"] := _rec["dugbhd"] + TEMP77->iznosbhd
                    _rec["dugdem"] := _rec["dugdem"] + TEMP77->iznosdem
                ELSE
                    _rec["potbhd"] := _rec["potbhd"] + TEMP77->iznosbhd
                    _rec["potdem"] := _rec["potdem"] + TEMP77->iznosdem
                ENDIF

                update_rec_server_and_dbf( "fin_sint", _rec, 1, "CONT" )

            ELSEIF idkonto == LEFT(TEMP77->konto2,3) .and. !lIndik2
                
                lIndik2:=.t.

                _rec := dbf_get_rec()

                IF TEMP77->d_p=="1"
                    _rec["dugbhd"] := _rec["dugbhd"] + TEMP77->iznosbhd
                    _rec["dugdem"] := _rec["dugdem"] + TEMP77->iznosdem
                ELSE
                    _rec["potbhd"] := _rec["potbhd"] + TEMP77->iznosbhd
                    _rec["potdem"] := _rec["potdem"] + TEMP77->iznosdem
                ENDIF

                update_rec_server_and_dbf( "fin_sint", _rec, 1, "CONT" )

            ENDIF
    
            SKIP 1
     
        ENDDO
      
        SKIP -1
      
        IF !lIndik2

            _rec := dbf_get_rec()

            _rec["idkonto"] := LEFT( TEMP77->konto2, 3 )
            _rec["rbr"] := NovaSifra( _rec["rbr"] )

            IF gDatNal=="N"
                _rec["datnal"] := TEMP77->datdok
            ENDIF

            _rec["dugbhd"] := IF(TEMP77->d_p=="1",TEMP77->iznosbhd,0)
            _rec["potbhd"] := IF(TEMP77->d_p=="2",TEMP77->iznosbhd,0)
            _rec["dugdem"] := IF(TEMP77->d_p=="1",TEMP77->iznosdem,0)
            _rec["potdem"] := IF(TEMP77->d_p=="2",TEMP77->iznosdem,0)

            APPEND BLANK

            update_rec_server_and_dbf( "fin_sint", _rec, 1, "CONT" )

        ENDIF

    endif

    SELECT TEMP77
    SKIP 1

    Postotak( 2, ++ nZapisa,,,, .f. )
  
ENDDO
 
Postotak(-1,,,,,.f.)

select TEMP77  
ZAPP()

SELECT ANAL
nZapisa := 0
  
Postotak(1,RECCOUNT2(),"Azuriranje promjena na analitici",,,.f.)
  
GO TOP
  
DO WHILE !EOF()
    IF dugbhd==0 .and. potbhd==0 .and. dugdem==0 .and. potdem==0
        SKIP 1
        nSlog:=RECNO()
        SKIP -1
        _rec := dbf_get_rec()
        delete_rec_server_and_dbf( "fin_anal", _rec, 1, "CONT" )
        GO nSlog
    ELSE
        SKIP 1
    ENDIF
    Postotak(2,++nZapisa,,,,.f.)
ENDDO
  
Postotak(-1,,,,,.f.)

SELECT SINT
nZapisa:=0
  
Postotak(1,RECCOUNT2(),"Azuriranje promjena na sintetici",,,.f.)
  
GO TOP

DO WHILE !EOF()
    
    IF dugbhd==0 .and. potbhd==0 .and. dugdem==0 .and. potdem==0
        SKIP 1
        nSlog:=RECNO()
        SKIP -1
        _rec := dbf_get_rec()
        delete_rec_server_and_dbf( "fin_sint", _rec, 1, "CONT" )
        GO nSlog
    ELSE
        SKIP 1
    ENDIF
    Postotak(2,++nZapisa,,,,.f.)
ENDDO
  
Postotak(-1,,,,,.t.)

f18_free_tables({"fin_suban", "fin_anal", "fin_sint"})      
sql_table_update( nil, "END" )

select TEMP77
use

RETURN



/*! \fn ZadnjiRbr()
 *  \brief Vraca zadnji redni broj 
 */
 
function ZadnjiRBR()

local nZRBR:=0
local nObl:=SELECT()

O_FIN_PRIPR
go bottom
nZRBR:=VAL(rbr)
select (nObl)
return (nZRBR)


