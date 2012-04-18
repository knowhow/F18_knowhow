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

static picBHD
static picDEM

// ------------------------------------
// otvori tabele
// ------------------------------------
static function _o_tables()
O_KONTO
O_PARTN
return


// -----------------------------------------------------------------------
// vraca uslove generisanja kompenzacije
// -----------------------------------------------------------------------
static function _get_vars( vars )
local _id_firma := gFirma
local _dat_od := CTOD("")
local _dat_do := CTOD("")
local _usl_kto := PADR("", 7)
local _usl_kto2 := PADR("", 7)
local _usl_partn := PADR("", 6)
local _po_vezi := "D"
local _prelom := "N"
local _x := 1
local _ret := .t.

// citaj parametre
_usl_kto := fetch_metric("fin_komen_konto", my_user(), _usl_kto )
_usl_kto2 := fetch_metric("fin_komen_konto_2", my_user(), _usl_kto2 )
_usl_partn := fetch_metric("fin_komen_partn", my_user(), _usl_partn )
_dat_od := fetch_metric("fin_komen_datum_od", my_user(), _dat_od )
_dat_do := fetch_metric("fin_komen_datum_do", my_user(), _dat_do )
_po_vezi := fetch_metric("fin_komen_po_vezi", my_user(), _po_vezi )
_prelom := fetch_metric("fin_komen_prelomljeno", my_user(), _prelom )


Box( "", 18, 65 )

    set cursor on
        
    @ m_x + _x, m_y + 2 SAY 'KREIRANJE OBRASCA "IZJAVA O KOMPENZACIJI"'

    _x := _x + 4

    do while .t.

        if gNW=="D"
            @ m_x + _x, m_y + 2 SAY "Firma "
            ?? gFirma, "-", PADR( gNFirma, 30 )
        else
            @ m_x + _x, m_y + 2 SAY "Firma: " GET _id_firma valid {|| P_Firma(@_id_firma),_id_firma:=left(_id_firma,2),.t.}
        endif

        ++ _x
        @ m_x + _x, m_y + 2 SAY "Konto duguje   " GET _usl_kto  valid P_KontoFin(@_usl_kto)
        ++ _x
        @ m_x + _x, m_y + 2 SAY "Konto potrazuje" GET _usl_kto2  valid P_KontoFin(@_usl_kto2) .and. _usl_kto2 > _usl_kto
        ++ _x
        @ m_x + _x, m_y + 2 SAY "Partner-duznik " GET _usl_partn valid P_Firma(@_usl_partn)  pict "@!"
        ++ _x
        @ m_x + _x, m_y + 2 SAY "Datum dokumenta od:" GET _dat_od
        @ m_x + _x, col() + 2 SAY "do" GET _dat_do   valid _dat_od <= _dat_do

        ++ _x
        ++ _x
        
        @ m_x + _x, m_y + 2 SAY "Sabrati po brojevima veze D/N ?"  GET _po_vezi valid _po_vezi $ "DN" pict "@!"
        @ m_x + _x, col() + 2 SAY "Prikaz prebijenog stanja " GET _prelom valid _prelom $ "DN" pict "@!"

        read
        ESC_BCR

        exit

    enddo

BoxC()

if LastKey() == K_ESC
    _ret := .f.
    return _ret
endif

// snimi parametre
set_metric("fin_komen_konto", my_user(), _usl_kto )
set_metric("fin_komen_konto_2", my_user(), _usl_kto2 )
set_metric("fin_komen_partn", my_user(), _usl_partn )
set_metric("fin_komen_datum_od", my_user(), _dat_od )
set_metric("fin_komen_datum_do", my_user(), _dat_do )
set_metric("fin_komen_po_vezi", my_user(), _po_vezi )
set_metric("fin_komen_prelomljeno", my_user(), _prelom )

vars["konto"] := _usl_kto
vars["konto2"] := _usl_kto2
vars["partn"] := _usl_partn
vars["dat_od"] := _dat_od
vars["dat_do"] := _dat_do
vars["po_vezi"] := _po_vezi
vars["prelom"] := _prelom
vars["firma"] := _id_firma

return _ret


// ---------------------------------------------------------
// kreiranje tmp tabela
// ---------------------------------------------------------
static function _cre_tmp_tables()
local _dbf
local _tmp1, _tmp2

// struktura tabele
_dbf := {}
AADD( _dbf , { "BRDOK"    , "C" , 10 , 0 } )
AADD( _dbf , { "IZNOSBHD" , "N" , 17 , 2 } )
AADD( _dbf , { "MARKER"   , "C" ,  1 , 0 } )
 
_tmp1 := my_home() + "temp12.dbf"
_tmp2 := my_home() + "temp60.dbf"

if !FILE( _tmp1 )
    DbCreate( _tmp1, _dbf )
ENDIF

if !FILE( _tmp2 )
    DbCreate( _tmp2, _dbf )
ENDIF

// otvori tabele
select ( F_TMP_1 )
my_use_temp( "TEMP12", _tmp1, .f., .f. )

select ( F_TMP_2 )
my_use_temp( "TEMP60", _tmp2, .f., .f. )

return



// ---------------------------------------------------------------
// komenzacije
// ---------------------------------------------------------------
function kompenzacija()
local _is_gen := .f.
local _vars := hb_hash()
local _i, _n
local _row := MAXCOLS() - 4
local _col := MAXCOLS() - 3
local _usl_kto, _usl_kto2

picBHD := FormPicL(gPicBHD,16)
picDEM := FormPicL(gPicDEM,12)

// otvori tabele
_o_tables()

if Pitanje(, "Izgenerisati stavke za kompenzaciju?", "N" ) == "D"

    _is_gen := .t.
    
    // daj mi parametre...
    if !_get_vars( @_vars )
        return    
    endif
    
    _usl_kto := _vars["konto"]
    _usl_kto2 := _vars["konto2"]

else
    _usl_kto := PADR("", 7)
    _usl_kto2 := _usl_kto
endif

// kreiraj temp tabele za kompenzacije
_cre_tmp_tables()

// generisi stavke za kompenzaciju
if _is_gen 
    _gen_kompen( _vars )
endif

// browsanje
ImeKol:={ ;
          {"Br.racuna", {|| brdok    }, "brdok"    } ,;
          {"Iznos",     {|| iznosbhd }, "iznosbhd" } ,;
          {"Marker",    {|| IF(marker=="K","ÛÛKÛÛÛ","      ") }, "marker" } ;
        }

Kol:={}
for _i := 1 to LEN(ImeKol)
    AADD( Kol, _i )  
next

Box(, _row, _col )

    @ m_x, m_y + 20 SAY ' KREIRANJE OBRASCA "IZJAVA O KOMPENZACIJI" '
    @ m_x + _row - 4, m_y + 1 SAY REPLICATE( "Í", 77 )
    @ m_x + _row - 3, m_y + 1 SAY "<K> - izaberi/ukini racun za kompenzaciju"
    @ m_x + _row - 2, m_y + 1 SAY "<CTRL>+<P> - stampanje kompenzacije               <T> - promijeni tabelu"
    @ m_x + _row - 1, m_y + 1 SAY "<CTRL>+<N> - nova,   <CTRL>+<T> - brisanje,   <ENTER> - ispravka stavke "

    for _n := 1 to 17
        @ m_x + _n, m_y + 39 SAY "º"
    next

    select temp60
    go top
    select temp12
    go top

    m_y += 40

    do while .t.

        if ALIAS() == "TEMP12"
            m_y -= 40
        elseif ALIAS() == "TEMP60"
            m_y += 40
        endif

        ObjDbedit( "komp1", 15, 38, {|| key_handler() }, "", if( ALIAS() == "TEMP12", "DUGUJE " + _usl_kto, "POTRAZUJE " + _usl_kto2 ), , , , ,1)

        if LASTKEY() == K_ESC
            exit
        endif

    enddo

BoxC()

close all
return



// ----------------------------------------------------------------
// izgenerisi stavke za kompenzaciju
// ----------------------------------------------------------------
static function _gen_kompen( vars )
local _usl_kto := vars["konto"]
local _usl_kto2 := vars["konto2"]
local _usl_partn := vars["partn"]
local _dat_od := vars["dat_od"]
local _dat_do := vars["dat_do"]
local _po_vezi := vars["po_vezi"]
local _prelom := vars["prelom"]
local _id_firma := vars["firma"]
local _filter
local _id_konto, _id_partner, _prolaz, _prosao
local _otv_st, _t_id_konto
local _br_dok
local _d_bhd, _p_bhd, _d_dem, _p_dem
local _pr_d_bhd, _pr_p_bhd, _pr_d_dem, _pr_p_dem
local _dug_bhd, _pot_bhd, _dug_dem, _pot_dem
local _kon_d, _kon_p, _kon_d2, _kon_p2 
local _svi_d, _svi_p, _svi_d2, _svi_p2 

O_SUBAN
O_TDOK

select SUBAN
    
if _po_vezi == "D"
    set order to tag "3"
endif

// postavi filter
_filter := ".t." 

if !EMPTY( _dat_od )
    _filter += " .and. DATDOK >= " + cm2str( _dat_od )
endif

if !EMPTY( _dat_do )
    _filter += " .and. DATDOK <= " + cm2str( _dat_do )
endif    

if _filter == ".t."
    set filter to
else
    set filter to &(_filter)
endif

seek _id_firma + _usl_kto + _usl_partn 
   
// pretrazi na drugom kontu 
if !FOUND() 
    seek _id_firma + _usl_kto2 + _usl_partn 
endif

NFOUND CRET

_svi_d := 0
_svi_p := 0
_svi_d2 := 0
_svi_p2 := 0
_kon_d := 0
_kon_p := 0
_kon_d2 := 0
_kon_p2 := 0

_id_konto := field->idkonto

_prolaz := 0
if EMPTY( _usl_partn )  
    // prodji tri puta
    _prolaz := 1
    HSEEK _id_firma + _usl_kto 
    if EOF()
        _prolaz := 2
        HSEEK _id_firma + _usl_kto2 
    endif
endif

do while .t.

    if !EOF() .and. field->idfirma == _id_firma .and. ;
            ( ( _prolaz == 0 .and. ( field->idkonto == _usl_kto .or. field->idkonto == _usl_kto2 ) ) .or. ;
            ( _prolaz == 1 .and. field->idkonto = _usl_kto ) .or. ;
            ( _prolaz == 2 .and. field->idkonto = _usl_kto2 ) )
    else
        exit
    endif

    _d_bhd := 0
    _p_bhd := 0
    _d_dem := 0
    _p_dem := 0          
    _pr_d_bhd := 0
    _pr_p_bhd := 0
    _pr_d_dem := 0
    _pr_p_dem := 0          
    _dug_bhd := 0
    _pot_bhd := 0
    _dug_dem := 0
    _pot_dem := 0          

    _id_partner := field->idpartner
    _prosao := .f.
        
    do whilesc !EOF() .and. field->IdFirma == _id_firma .and. field->idpartner == _id_partner ;
                        .and. ( field->idkonto == _usl_kto .or. field->idkonto == _usl_kto2 )

        _id_konto := field->idkonto
        _otv_st := field->otvst

        if !( _otv_st == "9" )

            _prosao := .t.

            select suban
            if _id_konto == _usl_kto 
                select TEMP12
            else
                select TEMP60
            endif
              
            append blank
            replace field->brdok with suban->brdok

            _t_id_konto := _id_konto 
            select suban

        endif 

        _d_bhd := 0
        _p_bhd := 0
        _d_dem := 0
        _p_dem := 0          

        if _po_vezi == "D"

            _br_dok := field->brdok

            do whilesc !EOF() .and. field->IdFirma == _id_firma .and. field->idpartner == _id_partner ;
                                .and. ( field->idkonto == _usl_kto .or. field->idkonto == _usl_kto2 ) .and. field->brdok == _br_dok
                if field->d_p == "1"
                    _d_bhd += field->iznosbhd
                    _d_dem += field->iznosdem
                else
                    _p_bhd += field->iznosbhd
                    _p_dem += field->iznosdem
                endif

                skip

             enddo

             if _prelom == "D"
                 Prelomi( @_d_bhd, @_p_bhd )
                 Prelomi( @_d_dem, @_p_dem )
             endif
        
        else

             if field->d_p == "1"
                _d_bhd += field->iznosbhd
                _d_dem += field->iznosdem
             else
                _p_bhd += field->iznosbhd
                _p_dem += field->iznosdem
             endif

        endif
           
        if _otv_st == "9"
             _dug_bhd += _d_bhd
             _pot_bhd += _p_bhd
        else 
             
            // otvorena stavka
            if _t_id_konto == _usl_kto 
                select TEMP12
                if _d_bhd > 0
                    replace field->iznosbhd with _d_bhd
                    if _p_bhd > 0
                        _rec := dbf_get_rec()
                        append blank
                        dbf_update_rec( _rec )
                        replace field->iznosbhd with -_p_bhd
                    endif
                else
                    replace field->iznosbhd with -_p_bhd
                endif
            else
               
                select TEMP60
                if _p_bhd > 0
                    replace field->iznosbhd with _p_bhd
                    if _d_bhd > 0
                        _rec := dbf_get_rec()
                        append blank
                        dbf_update_rec( _rec )
                        replace field->iznosbhd with -_d_bhd
                    endif
                else
                    replace field->iznosbhd with -_d_bhd
                endif
            endif
    
            SELECT SUBAN
           
            _dug_bhd += _d_bhd
            _pot_bhd += _p_bhd 
           
        endif

        if _po_vezi <> "D"
            skip
        endif
          
        if _prolaz == 0 .or. _prolaz == 1
            if ( field->idkonto <> _id_konto .or. field->idpartner <> _id_partner ) .and. _id_konto == _usl_kto
                hseek _id_firma + _usl_kto2 + _id_partner 
            endif
        endif

    enddo 

    _kon_d += _dug_bhd
    _kon_p += _pot_bhd
    _kon_d2 += _dug_dem
    _kon_p2 += _pot_dem

    if _prolaz == 0
        exit
    elseif _prolaz == 1
        seek _id_firma + _usl_kto + _id_partner + CHR(255)
        if _usl_kto <> field->idkonto 
            // nema vise
            _prolaz := 2
            seek _id_firma + _usl_kto2 
            _id_partner := REPLICATE( "", LEN( field->idpartner ) )
            if !found()
                exit
            endif
        endif
    endif

    if nprolaz==2
        do while .t.
            seek _id_firma + _usl_kto2 + _id_partner + CHR(255)
            _t_rec := RECNO()
            if field->idkonto == _usl_kto2
                _id_partner := field->idpartner
                hseek _id_firma + _usl_kto + _id_partner
                if !found() 
                    // ove kartice nije bilo
                    go ( _t_rec )
                    exit
                else
                    loop  
                    // vrati se traziti
                endif
            endif
            exit
        enddo
    endif

enddo

return


// ---------------------------------------------------------------
// obrada dogadjaja tastature
// ---------------------------------------------------------------
static function key_handler()
local nTr2, GetList:={}, nRec:=RECNO(), nX:=m_x, nY:=m_y, nVrati:=DE_CONT

IF ! ( (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0 )
 do case

   case Ch==ASC("K") .or. Ch==ASC("k")    
     REPLACE marker WITH IF( marker=="K" , " " , "K" )
     nVrati := DE_REFRESH

   case Ch==K_CTRL_P   
     StKompenz()
     nVrati := DE_CONT

   case Ch==K_CTRL_N 
      GO BOTTOM
      SKIP 1
      Scatter()
      Box(, 5, 70)
        @ m_x+2, m_y+2 SAY "Br.racuna " GET _brdok
        @ m_x+3, m_y+2 SAY "Iznos     " GET _iznosbhd
        READ
      BoxC()
      IF LASTKEY() == K_ESC
        GO (nRec)
      ELSE
        APPEND BLANK; Gather()
        nVrati := DE_REFRESH
      ENDIF

   case Ch==K_CTRL_T                        // brisanje stavke
      if Pitanje("p01","Zelite izbrisati ovu stavku ?","D")=="D"
        delete
        nVrati := DE_REFRESH
      endif

   case Ch==K_ENTER                        
      Scatter()
      Box(,5,70)
        @ m_x+2, m_y+2 SAY "Br.racuna " GET _brdok
        @ m_x+3, m_y+2 SAY "Iznos     " GET _iznosbhd
        READ
      BoxC()
      IF LASTKEY() == K_ESC
        GO (nRec)
      ELSE
        Gather()
        nVrati := DE_REFRESH
      ENDIF

   case Ch==ASC("T") .or. Ch==ASC("t")      // prebacivanje na drugu tabelu
      IF ALIAS()=="TEMP12"
        SELECT TEMP60; GO TOP
      ELSEIF ALIAS()=="TEMP60"
        SELECT TEMP12
    GO TOP
      ENDIF
     nVrati := DE_ABORT

 endcase
ENDIF
m_x:=nX
m_y:=nY
return nVrati


// stampa kompenzacije
static function StKompenz()

LOCAL a1:={}, a2:={}, GetList:={}
 LOCAL cIdPov:=SPACE(6)
 LOCAL nLM:=5, nLin, nPocetak, i:=0, j:=0, k:=0

 nUkup12:=0; nUkup60:=0; cBrKomp:=SPACE(10); nSaldo:=0; nRokPl:=7
 cVal:="D"; dKomp:=DATE()

 PushWA()

 O_PARAMS
 Private cSection:="4",cHistory:=" ",aHistory:={}
 RPar("ip",@cIdPov)
 RPar("bk",@cBrKomp)

 Box(,8,50)
   @ m_x+2, m_y+2 SAY "Datum kompenzacije: " GET dKomp
   @ m_x+3, m_y+2 SAY "Rok placanja (dana): " GET nRokPl VALID nRokPl>=0 PICT "999"
   @ m_x+4, m_Y+2 SAY "Valuta kompenzacije (D/P): " GET cVal  valid cVal $ "DP"  pict "!@"
   @ m_x+5, m_Y+2 SAY "Broj kompenzacije: " GET cBrKomp
   @ m_x+6, m_Y+2 SAY "Sifra (ID) povjerioca: " GET cIdPov VALID P_Firma(@cIdPov) PICT "@!"
   READ
 BoxC()

 WPar("ip",cIdPov)
 WPar("bk",cBrKomp)
 select params
 use

  START PRINT RET
  ?
  P_10CPI

  SELECT (F_PARTN)
  HSEEK cIdPov
  aPov1:=ALLTRIM(naz)
  aPov2:=ALLTRIM(mjesto)
  aPov3:=ALLTRIM(ziror)
  aPov4:=ALLTRIM(dziror)
  aPov5:=IzSifK( "PARTN" , "REGB" , id , .f. )
  aPov6:=IzSifK( "PARTN" , "PORB" , id , .f. )
  aPov7:=ALLTRIM(telefon)
  aPov8:=ALLTRIM(adresa)
  aPov10:=ALLTRIM(fax)

  if cVal=="P"
    aPov9:=ALLTRIM(IzFmkIni("KOMPEN","RacunPomValute","",KUMPATH))
  else
        aPov9:=aPov3
  endif

  HSEEK qqPartner
  aDuz5:=IzSifK( "PARTN" , "REGB" , id , .f. )
  aDuz6:=IzSifK( "PARTN" , "PORB" , id , .f. )
  aDuz7:=ALLTRIM(telefon)
  aDuz8:=ALLTRIM(adresa)
  aDuz10:=ALLTRIM(fax)

  if empty(gFKomp)
    for i:=1 to gnTMarg; QOUT(); next
  else
    nLin:=BrLinFajla(PRIVPATH+TRIM(gFKomp))
    nPocetak:=0; nPreskociRedova:=0
    FOR i:=1 TO nLin
      aPom:=SljedLin(PRIVPATH+TRIM(gFKomp),nPocetak)
      nPocetak:=aPom[2]
      cLin:=aPom[1]
      IF nPreskociRedova>0
        --nPreskociRedova
        LOOP
      ENDIF
      IF RIGHT(cLin,4)=="#T1#"
        nLM:=LEN(cLin)-4

        SELECT TEMP12; GO TOP; SELECT TEMP60; GO TOP

        lTemp12:=.t.; lTemp60:=.t.; nBrSt:=0

        SkipT12i60()

        DO WHILE lTemp12 .or. lTemp60

          ++nBrSt

          IF lTemp60
            ? SPACE(nLM) + "³"+STR(nBrSt,4)+".³"+brdok+"³"+STR(iznosbhd,17,2)
            nUkup60+=iznosbhd
          ELSE
            ? SPACE(nLM) + "³     ³"+SPACE(10)+"³"+SPACE(17)
          ENDIF

          SELECT TEMP12
          IF lTemp12
            ?? "³"+STR(nBrSt,4)+".³"+brdok+"³"+STR(iznosbhd,17,2)+"³"
            nUkup12+=iznosbhd
          ELSE
            ?? "³     ³"+SPACE(10)+"³"+SPACE(17)+"³"
          ENDIF
          SKIP 1

          SELECT TEMP60; SKIP 1
          SkipT12i60()

        ENDDO

        FOR j:=nBrSt+1 TO 11
          ? SPACE(nLM) + "³     ³"+SPACE(10)+"³"+SPACE(17)+"³     ³"+SPACE(10)+"³"+SPACE(17)+"³"
        NEXT
        nSaldo:=ABS(nUkup12-nUkup60)

      ELSE
        ?
        DO WHILE .t.
          nPom:=AT("#", cLin)
      nPom2:=AT("#%", cLin)
      if nPom == nPom2 
        nPom := 0
      endif
          IF nPom>0
            cPom:=SUBSTR(cLin,nPom,4)
            IF SUBSTR(cPom,2,2)=="LS"             // uslov za saldo
              IF nSaldo==0 .or. nUkup60>nUkup12
                nPreskociRedova := VAL(SUBSTR(cLin,nPom+4,2)) - 1
                EXIT
              ELSE     // nUkup60<nUkup12
                cLin:=STUFF(cLin,nPom,7,"")
                nPom:=AT("#",cLin)
              ENDIF
            ELSEIF SUBSTR(cPom,2,2)=="2S"             // uslov za saldo
              IF nSaldo==0 .or. nUkup60<nUkup12
                nPreskociRedova := VAL(SUBSTR(cLin,nPom+4,2)) - 1
                EXIT
              ELSE     // nUkup60>nUkup12
                cLin:=STUFF(cLin,nPom,7,"")
                nPom:=AT("#",cLin)
              ENDIF
            ENDIF
          ENDIF
          IF nPom>0
            cPom:=SUBSTR(cLin,nPom,4)
            aPom:=UzmiVar( SUBSTR(cPom,2,2) )
            ?? LEFT(cLin,nPom-1)
            cLin:=SUBSTR(cLin,nPom+4)
            IF !EMPTY(aPom[1])
              PrnKod_ON(aPom[1])
            ENDIF
            IF aPom[1]=="K"
              cPom:=&(aPom[2])
            ELSE
              cPom:=&(aPom[2])
              ?? cPom
            ENDIF
            IF !EMPTY(aPom[1])
              PrnKod_OFF(aPom[1])
            ENDIF
          ELSE
            ?? cLin
            EXIT
          ENDIF
        ENDDO
      ENDIF
    NEXT
  endif
  FF
  END PRINT
 PopWA()
RETURN (NIL)



/*! \fn SkipT12i60()
 *  \brief 
 */
 
static function SkipT12i60()

LOCAL nArr:=SELECT()

  SELECT TEMP12
  DO WHILE marker!="K" .and. !EOF(); SKIP 1; ENDDO
  IF EOF(); lTemp12:=.f.; ENDIF

  SELECT TEMP60
  DO WHILE marker!="K" .and. !EOF(); SKIP 1; ENDDO
  IF EOF(); lTemp60:=.f.; ENDIF

  SELECT (nArr)
RETURN (NIL)



/*! \fn UzmiVar(cVar)
 *  \brief Uzmi varijable 
 *  \param cVar - varijabla
 */
 
static function UzmiVar(cVar)

LOCAL cVrati:=""
 DO CASE
   CASE cVar=="01"
       cVrati := { "UI", "PADR(aPov1,22)" }
   CASE cVar=="02"
       cVrati := { "UI", "PADR(PARTN->naz,22)" }
   CASE cVar=="03"
       cVrati := { "UI", "PADR(aPov2,22)" }
   CASE cVar=="04"
       cVrati := { "UI", "PADR(PARTN->mjesto,22)" }
   CASE cVar=="05"
       cVrati := { "UI", "PADR(aPov3,22)" }
   CASE cVar=="06"
       cVrati := { "UI", "PADR(PARTN->ziror,22)" }
   CASE cVar=="07"
       cVrati := { "UI", "PADR(aPov4,22)" }
   CASE cVar=="08"
       cVrati := { "UI", "PADR(PARTN->dziror,22)" }
   CASE cVar=="09"
       cVrati := { "I", "TRIM(cBrKomp)" }
   CASE cVar=="10"
       cVrati := { "I", "STR(nUkup60,21,2)" }
   CASE cVar=="11"
       cVrati := { "I", "STR(nUkup12,21,2)" }
   CASE cVar=="12"
       cVrati := { "I", "STR(nSaldo,17,2)" }
   CASE cVar=="13"
       cVrati := { "UI", "ALLTRIM(STR(nSaldo))" }
   CASE cVar=="14"
       cVrati := { "UI", "IF( cVal=='D' , aPov3 , aPov4 )" }
   CASE cVar=="15"
       cVrati := { "UI", "IF( nRokPl==0 , '  ' , ALLTRIM(STR(nRokPl)) )" }
   CASE cVar=="16"
       cVrati := { "UI", "IF( cVal=='D' , ValDomaca() , ValPomocna() )" }
   CASE cVar=="17"
       cVrati := { "UI", "SrediDat(dKomp)" }
   CASE cVar=="18"
       cVrati := { "UI", "SrediDat(dKomp)" }
   CASE cVar=="19"
       cVrati := { "", "IF( cVal=='D' , ValDomaca() , ValPomocna() )" }
   CASE cVar=="20"
       cVrati := { "", "ValDomaca()" }
   CASE cVar=="21"
       cVrati := { "", "ValPomocna()" }
   CASE cVar=="23"
       cVrati := { "UI", "PADR(aPov5,22)" }
   CASE cVar=="24"
       cVrati := { "UI", "PADR(aDuz5,22)" }
   CASE cVar=="25"
       cVrati := { "UI", "PADR(aPov6,22)" }
   CASE cVar=="26"
       cVrati := { "UI", "PADR(aDuz6,22)" }
   CASE cVar=="27"
       cVrati := { "UI", "PADR(aPov7,22)" }
   CASE cVar=="28"
       cVrati := { "UI", "PADR(aDuz7,22)" }
   CASE cVar=="29"
       cVrati := { "UI", "PADR(aPov8,22)" }
   CASE cVar=="30"
       cVrati := { "UI", "PADR(aDuz8,22)" }
   CASE cVar=="31"
       cVrati := { "UI", "PADR(aPov9,22)" }
   CASE cVar=="32"
       cVrati := { "UI", "PADR(aPov10,22)" }
   CASE cVar=="33"
       cVrati := { "UI", "PADR(aDuz10,22)" }
   CASE cVar=="B1"
       cVrati := { "K", "gPB_ON()" }
   CASE cVar=="B0"
       cVrati := { "K", "gPB_OFF()" }
   CASE cVar=="U1"
       cVrati := { "K", "gPU_ON()" }
   CASE cVar=="U0"
       cVrati := { "K", "gPU_OFF()" }
   CASE cVar=="I1"
       cVrati := { "K", "gPI_ON()" }
   CASE cVar=="I0"
       cVrati := { "K", "gPI_OFF()" }
 ENDCASE
RETURN cVrati



/*! \fn PrnKod_ON(cKod)
 *  \brief
 */
 
function PrnKod_ON(cKod)

LOCAL i:=0
  FOR i:=1 TO LEN(cKod)
    DO CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_ON()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_ON()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_ON()
    ENDCASE
  NEXT
RETURN (NIL)




/*! \fn PrnKod_OFF(cKod)
 *  \brief Iskljucivanje printerskog koda
 *  \param cKod - kod printera
 */
 
function PRNKod_OFF(cKod)

LOCAL i:=0
  FOR i:=1 TO LEN(cKod)
    DO CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_OFF()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_OFF()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_OFF()
    ENDCASE
  NEXT
RETURN (NIL)



