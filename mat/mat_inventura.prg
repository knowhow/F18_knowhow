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

static PicDEM:="99999999.99"
static PicBHD:="9999999999.99"
static PicKol:="9999999.99"


// ---------------------------------------------
// inventura - menij
// ---------------------------------------------
function mat_inventura()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. unos,ispravka stvarnih kolicina            " )
AADD( _opcexe, { || mat_unos_pop_listi() } )
AADD( _opc, "2. pregled unesenih kolicina" )
AADD( _opcexe, { || mat_pregl_unesenih_stavki() } )
AADD( _opc, "3. obracun inventure" )
AADD( _opcexe, { || mat_obracun_inv() } )
AADD( _opc, "4. nalog sravnjenja" )
AADD( _opcexe, { || mat_nal_inventure() } )
AADD( _opc, "5. inventura - obrac r.por" )
AADD( _opcexe, { || mat_inv_obr_poreza() } )

f18_menu("invnt", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return


// -------------------------------------------
// unos kolicina
// -------------------------------------------
function mat_unos_pop_listi()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. generisanje stavki inventure             " )
AADD( _opcexe, { || mat_inv_gen() } )
AADD( _opc, "2. pregled tabele " )
AADD( _opcexe, { || mat_inv_tabela() } )
AADD( _opc, "3. popisna lista za inveturisanje" )
AADD( _opcexe, { || mat_popisna_lista() } )

f18_menu("bedpl", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return


// ------------------------------------------------
// ispravka stvarnih kolicina
// ------------------------------------------------
function mat_inv_gen()
local _id_firma := gFirma
local _datum := date()
local _konto := SPACE(7)
local _r_br
local _kolicina 
local _iznos 
local _iznos_2 
local _cijena 
local _id_roba
local _vars := hb_hash()
local _partner, _partn_usl, _id_partner
local _filter

O_KONTO
O_PARTN

if !_get_inv_vars( @_vars )
    my_close_all_dbf()
    return
endif

_konto := _vars["konto"]
_datum := _vars["datum"]
_id_firma := LEFT( _vars["id_firma"], 2 )
_partner := _vars["partner"]
_id_partner := ""

O_MAT_INVENT
O_MAT_SUBAN

msgO( "Generisem stavke inventure..." )

select MAT_INVENT
my_dbf_zap()


_r_br := 0
_kolicina := 0
_iznos := 0
_iznos_2 := 0
_cijena := 0

SELECT mat_suban
set order to tag "3"

_filter := "datdok <= " + cm2str( _datum )

if !EMPTY( _partner )
    _id_partner := _partner
    _filter += ".and. idpartner == " + cm2str( _partner )
endif

set filter to &(_filter)

SEEK _id_firma + _konto

NFOUND CRET

do while !EOF() .and. _id_firma == field->IdFirma .and. _konto == field->Idkonto

    _id_roba := field->idroba
    _kolicina := 0
    _iznos := 0
    _iznos_2 := 0
    
    do while !EOF() .and. _id_firma == field->IdFirma .and. _konto == field->IdKonto .and. _id_roba == field->IdRoba

        if field->d_p = "1"
            _kolicina += field->Kolicina
        else
            _kolicina -= field->Kolicina
        endif

        if field->d_p = "1"
            _iznos += field->Iznos
            _iznos_2 += field->Iznos2
        else
            _iznos -= field->Iznos
            _iznos_2 -= field->Iznos2
        endif

        skip

    enddo

    if ROUND( _kolicina, 4 ) <> 0 
        _cijena := _iznos / _kolicina
    elseif ROUND( _iznos, 4 ) <> 0 
        _cijena := 0
    endif
    
    select MAT_INVENT
    append blank
    
    _vars := dbf_get_rec()
    _vars["idroba"] := _id_roba
    _vars["rbr"] := STR( ++_r_br, 4)
    _vars["kolicina"] := _kolicina
    _vars["cijena"] := _cijena
    _vars["iznos"] := _iznos
    _vars["iznos2"] := _iznos_2
    _vars["idpartner"] := _id_partner
        
    dbf_update_rec( _vars )
    
    select mat_suban

enddo

msgC()

my_close_all_dbf()
return



// -------------------------------------------------
// -------------------------------------------------
function mat_inv_tabela()
local _cnt
local _header := ""
private kol := {}
private imekol := {}

O_MAT_INVENT
O_ROBA
O_SIFK
O_SIFV
O_PARTN

SELECT MAT_INVENT
GO TOP

set order to tag "1"

AADD( ImeKol, { "R.br", {|| rbr } } )
AADD( ImeKol, { PADR( "Roba", 60 ), {|| pr_roba( idroba ) } } )
AADD( ImeKol, { "Cijena", {|| cijena } } )
AADD( ImeKol, { "Kolicina", {|| kolicina } } )
AADD( ImeKol, { "Iznos " + ValDomaca(), {|| iznos } } )
AADD( ImeKol, { "Partner", {|| idpartner } } )

for _cnt := 1 to LEN( ImeKol )
    AADD( Kol, _cnt )
next

_header := "<c-T> Brisi stavku <ENT> Ispravka <c-A> Ispravka svih stavki <c-N> Nova stavka <c-Z> Brisi"

ObjDbedit( "USKSP", MAXROW() - 4, MAXCOL() - 3, {|| _ed_pop_list_khandler() }, _header, ;
    "Pregled popisne liste..." )

my_close_all_dbf()
return


// prikaz naziva robe u tabeli pregleda inventure
static function pr_roba( id_roba )
local _txt := "!!! u sifrarniku nema stavke"
local _t_area := SELECT()

select roba
hseek id_roba

if FOUND()
    _txt := PADL( ALLTRIM( id_roba ), 10 )
    _txt += " - "
    _txt += PADR( ALLTRIM( roba->naz ), 40 )
endif

select (_t_area)

return _txt

// -----------------------------------------------
// -----------------------------------------------
static function _ed_pop_list_khandler()
local _new
local _vars 
local _r_br

do case

    // nova ili ispravka
    case Ch==K_ENTER .or. Ch==K_CTRL_N
        
        _new := .f.
        
        if Ch == K_CTRL_N
            _new := .t.
        endif
        
        if Ch == K_CTRL_N
            append blank
        endif
        
        _vars := dbf_get_rec()        
        
        Box( "edpopl", 6, 70, .f., "Stavka popisne liste" )
            
            set cursor on
            
            _r_br := VAL( _vars["rbr"] )
            
            _form_data( @_r_br, @_vars )
            
            read
            
            _vars["rbr"] := PADL( ALLTRIM( STR( _r_br, 4 )), 4 )

        BoxC()
        
        if lastkey() == K_ESC .and. _new == .t.
            my_delete_with_pack()
            return DE_CONT
        endif
        
        dbf_update_rec(_vars)
        
        return DE_REFRESH

    case Ch==K_CTRL_A

        go top

        Box( "edpopl", 6, 70, .f., "Ispravka popisne liste.." )

        do while !eof()
            
            _vars := dbf_get_rec()

            set cursor on
            
            _r_br := VAL( _vars["rbr"] )
            _form_data( @_r_br, @_vars )
            
            read

            _vars["rbr"] := PADL( ALLTRIM(STR( _r_br, 4 )), 4 )
            if lastkey()==K_ESC
                BoxC()
                return DE_REFRESH
            endif
            
            dbf_update_rec(_vars)
            
            if lastkey() == K_PGUP
                skip -1
            else
                skip
            endif
        enddo

        BoxC()

        skip -1
        return DE_REFRESH

    case Ch==K_CTRL_T

        if Pitanje("ppl","Zelite izbrisati ovu stavku (D/N) ?","N")=="D"
            my_delete_with_pack()
            return DE_REFRESH
        endif
        return DE_CONT

    case Ch==K_CTRL_Z

        if Pitanje("ppl","Zelite sve stavke (D/N) !!!!????","N")=="D"
			my_dbf_zap()

            go top
            return DE_REFRESH
        endif
        return DE_CONT

endcase

return DE_CONT



// ------------------------------------
// forma za unos podataka
// ------------------------------------
static function _form_data( r_br, vars )
local _ed_id_roba
local _ed_cijena
local _ed_kolicina 
local _ed_iznos 

_ed_id_roba := vars["idroba"]
_ed_cijena := vars["cijena"]
_ed_kolicina := vars["kolicina"]
_ed_iznos := vars["iznos"]

@ m_x+1,m_y+2 SAY "Red.br:  " GET r_br PICT "9999"
@ m_x+3,m_y+2 SAY "Roba:    " GET _ed_id_roba VALID P_Roba(@_ed_id_roba,3,24)
@ m_x+4,m_y+2 SAY "Cijena:  " GET _ed_cijena PICT PicDEM
@ m_x+5,m_y+2 SAY "Kolicina:" GET _ed_kolicina PICT PicKol ;
    VALID {|| _ed_iznos := _ed_cijena * _ed_kolicina, ;
        qqout("  Iznos:", TRANSFORM( _ed_iznos, PicDEM ) ), Inkey(5), .t. }

vars["idroba"] := _ed_id_roba
vars["cijena"] := _ed_cijena
vars["kolicina"] := _ed_kolicina
vars["iznos"] := _ed_iznos

return



// -------------------------------------------------
// vraca uslove standardne kod inventure
// -------------------------------------------------
static function _get_inv_vars( vars )
local _ret := .t.
local _id_firma := gFirma
local _konto := SPACE(7)
local _datum := DATE()
local _partner := SPACE(6)

_id_firma := fetch_metric( "mat_inv_firma", my_user(), _id_firma )
_konto := fetch_metric( "mat_inv_konto", my_user(), _konto )
_datum := fetch_metric( "mat_inv_datum", my_user(), _datum )
_partner := fetch_metric( "mat_inv_partner", my_user(), _partner )

Box( "", 5, 60, .f. )

    @ m_x+1, m_y+6 SAY  "PREGLED UNESENIH KOLICINA"

    if gNW$"DR"
        @ m_x+2, m_y+2 SAY "Firma "
        ?? gFirma,"-",gNFirma
    else
        @ m_x+2, m_y+2 SAY "Firma: " GET _id_firma ;
            VALID {|| P_Firma( @_id_firma ), _id_firma := left(_id_firma, 2 ), .t. }
    endif

    @ m_x + 3, m_y + 2 SAY "  Konto " GET _konto ;
        VALID P_Konto( @_konto )
    @ m_x + 4, m_y + 2 SAY "Partner " GET _partner ;
        VALID EMPTY( _partner ) .or. P_Firma( @_partner )
    @ m_x + 5, m_y + 2 SAY "  Datum " GET _datum
    
    read

BoxC()

if LastKey() == K_ESC
    _ret := .f.
    return _ret
endif

// snimi u hash matricu parametre...
vars["id_firma"] := LEFT( _id_firma, 2 )
vars["konto"] := _konto
vars["datum"] := _datum
vars["partner"] := _partner

// snimi u sql/db
set_metric( "mat_inv_firma", my_user(), _id_firma )
set_metric( "mat_inv_konto", my_user(), _konto )
set_metric( "mat_inv_datum", my_user(), _datum )
set_metric( "mat_inv_partner", my_user(), _partner )

return _ret




function mat_pregl_unesenih_stavki()
local _id_firma 
local _partner
local _konto 
local _datum
local _r_br 
local _vars := hb_hash()

O_MAT_INVENT
O_ROBA
O_SIFK
O_SIFV
O_KONTO
O_PARTN

if !_get_inv_vars( @_vars )
    my_close_all_dbf()
    return
endif

_konto := _vars["konto"]
_datum := _vars["datum"]
_id_firma := LEFT( _vars["id_firma"], 2 )
_partner := _vars["partner"]

SELECT MAT_INVENT
set order to tag "1"
GO TOP

START PRINT CRET
?

_r_br := 0

m:="---- ---------- ---------------------------------------- --- ---------- ------------ -------------"

ZPrUnKol( _vars, m )

nU:=0
nC1:=60

do while !eof()

    if prow()>62
        FF
        ZPrUnKol( _vars, m )
    endif

    select roba
    HSEEK MAT_INVENT->IdRoba
    select mat_invent

    @ prow()+1,0 SAY ++_r_br PICTURE '9999'
    @ prow(),pcol()+1 SAY field->idroba
    @ prow(),pcol()+1 SAY PADR( roba->naz, 40 )
    @ prow(),pcol()+1 SAY roba->jmj
    @ prow(),pcol()+1 SAY field->Kolicina PICTURE '999999.999'
    @ prow(),pcol()+1 SAY field->Cijena PICTURE '99999999.999'
    nC1:=pcol()+1
    @ prow(),pcol()+1 SAY nIznos := field->Cijena * field->kolicina PICTURE '999999999.99'
    nU+=nIznos

    skip
enddo

if prow() > 60
    FF
    ZPrUnKol( _vars, m )
ENDIF

? m
? "UKUPNO:"
@ prow(), nC1 SAY nU PICTURE '999999999.99'
? m

END  PRINT
my_close_all_dbf()
return


// zaglavlje
static function ZPrUnKol( vars, line )

P_COND
?

@ prow(), 0 SAY "MAT.P: PREGLED UNESENIH KOLICINA NA DAN:"
@ prow(), pcol() + 1 SAY vars["datum"]
@ prow() + 1, 0 SAY "Firma:"
@ prow(), pcol() + 1 SAY vars["id_firma"]

SELECT PARTN
HSEEK vars["id_firma"]

@ prow(), pcol() + 1 SAY ALLTRIM( field->naz )
@ prow(), pcol() + 1 SAY ALLTRIM( field->naz2 )

SELECT PARTN
HSEEK vars["partner"]
@ prow() + 1, 0 SAY "Partner:"
@ prow(), pcol() + 1 SAY ALLTRIM( field->naz )
@ prow(), pcol() + 1 SAY ALLTRIM( field->naz2 )

select KONTO
HSEEK vars["konto"]

? "Konto: ", vars["konto"], ALLTRIM( field->naz )

SELECT MAT_INVENT

? line

? "*R. *  SIFRA   *         NAZIV ARTIKLA                  *J. * KOLICINA *   CIJENA   *   IZNOS    *"
? "*B. * ARTIKLA  *                                        *MJ.*          *            *            *"

? line

return



function mat_obracun_inv()

cIdF:=gFirma
cIdK:=SPACE(7)
cIdD:=date()
cIdF:=left(cIdF,2)

O_PARTN; O_KONTO
Box("",4,60)
@ m_x+1,m_y+6 SAY "OBRACUN INVENTURE"
if gNW$"DR"
  @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdF valid {|| P_Firma(@cIdF),cidf:=left(cidf,2),.t.}
endif
@ m_x+3,m_y+2 SAY "Konto  " GET cIdK valid P_Konto(@cIdK)
@ m_x+4,m_y+2 SAY "Datum  " GET cIdD
READ; ESC_BCR
BoxC()

picD:='@Z 99999999999.99'
picD1:='@Z 99999999.99'
picK:='@Z 99999.99'

O_MAT_INVENT
O_ROBA
O_SIFK
O_SIFV
O_MAT_SUBAN
set order to tag "3"
set filter to DatDok<=cIdD

SELECT MAT_INVENT
go top

START PRINT CRET

A:=0

nRBr:=0
SK:=SV:=0
KK:=KV:=0
VK:=VV:=MK:=MV:=0

SV1:=KV1:=0
VV1:=MV1:=0

DO WHILE !eof()

   IF A==0
      P_COND
      @ A,0 SAY "MAT.P:INVENTURNA LISTA NA DAN:"; @ A,pcol()+1 SAY cIdD
      @ ++A,0 SAY "Firma:"
      @ A,pcol()+1 SAY cIdF
      SELECT PARTN; HSEEK cIdF
      @ A,pcol()+1 SAY naz; @ A,pcol()+1 SAY naz2

      @ ++A,0 SAY "KONTO:"
      @ A,pcol()+1 SAY cIdK
      SELECT KONTO; HSEEK cIdK
      @ A,pcol()+1 SAY naz
      select MAT_INVENT
      A+=2
      @ ++A,0 SAY "---- ---------- -------------------- --- ---------- -------------------- -------------------- -------------------- ---------------------"
      @ ++A,0 SAY "*R. *  SIFRA   *  NAZIV ARTIKLA     *J. *  CIJENA  *   STVARNO STANJE   *   KNJIZNO STANJE   *   RAZLIKA VISAK    *   RAZLIKA MANJAK   *"
      @ ++A,0 SAY "                                                    -------------------- -------------------- -------------------- ---------------------"
      @ ++A,0 SAY "*B. * ARTIKLA  *                    *MJ.*          *KOLICINA*   IZNOS   *KOLICINA*   IZNOS   *KOLICINA*   IZNOS   *KOLICINA*   IZNOS   *"
      @ ++A,0 SAY "---- ---------- -------------------- --- ---------- -------- ----------- -------- ----------- -------- ----------- -------- ------------"
   ENDIF

   IF A>63; EJECTA0;  ENDIF

   SK:=Kolicina; SV:=Iznos

   cIdRoba:=IdRoba
   select mat_suban
   SEEK cIdF+cIdK+cIdRoba
   kK:=kV:=0         // KK - knjizena kolicina, KV - knjizena vrijednost
   DO WHILE !eof() .AND. cIdF=IdFirma .AND. cIdK=IdKonto .AND. cIdRoba=IdRoba
      IF D_P="1"; kK+=Kolicina; ELSE; kK-=Kolicina; ENDIF
      IF D_P="1"; kV+=Iznos; ELSE; kV-=Iznos; ENDIF
     SKIP
   ENDDO



   RK:=SK-KK
   RV:=SV-KV

   VK:=MK:=0
   If RK>=0; VK:=RK; ELSE; MK:=-RK; ENDIF
   VV:=MV:=0
   If RV>=0; VV:=RV; ELSE; MV:=-RV; ENDIF


   @ ++A,0 SAY ++nRBr PICTURE "9999"
   @ A,5 SAY cIdRoba
   select ROBA; HSEEK cIdRoba
   @ A,16 SAY Naz PICTURE replicate ("X",20)
   @ A,37 SAY jmj
   select MAT_INVENT
   @ A,40       SAY  Cijena PICTURE picD1
   @ A,pcol()+1 SAY  round(SK,2) PICTURE picK
   @ A,pcol()+1 SAY  round(SV,2) PICTURE picD1
   @ A,pcol()+1 SAY  round(KK,2)  PICTURE picK
   @ A,pcol()+1 SAY  round(KV,2) PICTURE picD1
   @ A,pcol()+1 SAY  round(VK,2) PICTURE picK
   @ A,pcol()+1 SAY  round(VV,2) PICTURE picD1
   @ A,pcol()+1 SAY  round(MK,2) PICTURE picK
   @ A,pcol()+1 SAY  round(MV,2) PICTURE picD1

   SKIP
   SV1+=SV; KV1+=KV
   VV1+=VV; MV1+=MV

ENDDO

@ ++A,0 SAY "---- ---------- -------------------- --- ---------- -------- ----------- -------- ----------- -------- ----------- -------- ------------"
@ ++A,0 SAY "UKUPNO:"
@ a,40       SAY 0 PICTURE PicD1
@ A,pcol()+1 SAY 0 PICTURE picK
@ A,pcol()+1 SAY round(SV1,2) PICTURE picD1
@ A,pcol()+1 SAY 0 PICTURE PicK
@ A,pcol()+1 SAY round(KV1,2) PICTURE picD1
@ A,pcol()+1 SAY 0 PICTURE PicK
@ A,pcol()+1 SAY round(VV1,2) PICTURE picD1
@ A,pcol()+1 SAY 0 PICTURE PicK
@ A,pcol()+1 SAY round(MV1,2) PICTURE picD1
@ ++A,0 SAY "---- ---------- -------------------- --- ---------- -------- ----------- -------- ----------- -------- ----------- -------- ------------"

EJECTNA0
ENDPRINT
my_close_all_dbf()
return


function mat_nal_inventure()

cIdF:=gFirma
cIdK:=SPACE(7)
cIdD:=date()
if file(PRIVPATH+"invent.mem")
     restore from (PRIVPATH+"invent.mem") additive
endif
cIdF:=left(cIdF,2)
cIdZaduz:=space(6)
cidvn:="  "; cBrNal:=space(4)
cIdTipDok:="09"
O_PARTN; O_KONTO
Box("",7,60)
@ m_x+1,m_y+6 SAY "FORMIRANJE NALOGA IZLAZA - USAGLASAVANJE"
@ m_x+2,m_y+6 SAY "KNJIZNOG I STVARNOG STANJA"
@ m_x+4,m_y+2 SAY "Nalog  " GET cIdF
@ m_x+4,col()+2 SAY "-" GET cIdVN
@ m_x+4,col()+2 SAY "-" GET cBrNal
@ m_x+4,col()+4 SAY "Datum  " GET cIdD
@ m_x+5,m_y+2 SAY "Tip dokumenta" GET cIdTipDok
@ m_x+6,m_y+2 SAY "Konto  " GET cIdK valid P_Konto(@cIdK)
@ m_x+7,m_y+2 SAY "Zaduzuje" GET cIdZaduz valid empty(@cIdZaduz) .or. P_Firma(@cIdZaduz)
READ; ESC_BCR

BoxC()
save to  (PRIVPATH+"invent.mem") all like cId?

picD:='@Z 99999999999.99'
picD1:='@Z 99999999.99'
picK:='@Z 99999.99'

O_VALUTE
O_MAT_PRIPR
O_MAT_INVENT
O_ROBA
O_SIFK
O_SIFV
O_MAT_SUBAN
set order to tag "3"
set filter to DatDok<=cIdD

SELECT MAT_INVENT
go top

A:=0

nRBr:=0
SK:=SV:=0
KK:=KV:=0
VK:=VV:=MK:=MV:=0

SV1:=KV1:=0
VV1:=MV1:=0

nRbr:=0
KursLis:="1"

DO WHILE !eof()


   SK:=Kolicina; SV:=Iznos

   cIdRoba:=IdRoba
   select mat_suban
   SEEK cIdF+cIdK+cIdRoba
   kK:=kV:=0         // KK - knjizena kolicina, KV - knjizena vrijednost
   DO WHILE !eof() .AND. cIdF=IdFirma .AND. cIdK=IdKonto .AND. cIdRoba=IdRoba
      IF D_P="1"; kK+=Kolicina; ELSE; kK-=Kolicina; ENDIF
      IF D_P="1"; kV+=Iznos; ELSE; kV-=Iznos; ENDIF
     SKIP
   ENDDO



   RK:=KK-SK
   RV:=KV-SV
   nCj:=0
   if round(rk,3)<>0; nCj:=rv/rk;endif

   if round(rk,3)<>0 .or. round(rv,3)<>0
    select mat_pripr
    append blank
    replace idfirma with cidf, idvn with cidvn, brnal with cbrnal,;
            idkonto with cidk, rbr with str(++nRbr,4), ;
            idzaduz with cidzaduz,;
            idroba with cidroba, u_i with "2", d_p with "2",;
            kolicina with rk, cijena with nCj, iznos with rv,;
            iznos2 with iznos*Kurs(cIdD),;
            datdok with cidD, datkurs with cidd,;
            idtipdok with cIdTipDok

   endif

   select MAT_INVENT
   skip
ENDDO

my_close_all_dbf()
return


// ---------------------------------------------------
// prenos iz materijalnog u obracun  poreza
// ---------------------------------------------------
function mat_inv_obr_poreza()
local cIdDir

cIdF:=gFirma
cIdK:=SPACE(7)
cIdD:=date()
cIdX:=space(35)
if file(PRIVPATH+"invent.mem")
     restore from (PRIVPATH+"invent.mem") additive
endif
cIdF:=left(cIdF,2)
cIdX:=padr(cIdX,35)
cIdZaduz:=space(6)
cidvn:="  "; cBrNal:=space(4)
cIdTipDok:="09"
O_TARIFA; O_KONTO
O_MAT_INVENT
O_SIFK
O_SIFV
O_ROBA
nMjes:=month(cIdD)
Box("",7,60)
@ m_x+1,m_y+6 SAY "PRENOS INV. STANJA U OBRACUN POREZA MP"
@ m_x+5,m_y+2 SAY "Mjesec " GET  nMjes pict "99"
@ m_x+6,m_y+2 SAY "Konto  " GET cIdK valid P_Konto(@cIdK)
READ; ESC_BCR
BoxC()

save to  (PRIVPATH+"invent.mem") all like cId?

cIdDir:=gDirPor

use (ciddir+"pormp") new index (ciddir+"pormpi1"), (ciddir+"pormpi2"), (ciddir+"pormpi3")
set order to tag "3"           
// str(mjesec,2)+idkonto+idtarifa+id

SELECT MAT_INVENT
go top

DO WHILE !eof()

   select roba; hseek mat_invent->idroba; select tarifa; hseek roba->idtarifa
   select mat_invent
   nMPVSAPP:=kolicina*cijena
   if nMPVSAPP==0; skip; loop; endif
   nMPV:=nMPVSAPP/(1+tarifa->ppp/100)/(1+tarifa->opp/100)
   select pormp
   seek str(nmjes,2)+cidk+roba->idtarifa+"3. SAD.INVENT"
   if !found()
        append blank
   endif
   replace id with "3. SAD.INVENT",;
           mjesec  with nmjes,;
           idkonto with cIDK,;
           idtarifa with roba->IdTarifa,;
           znak with "-",;
           MPV      with MPV-nMPV,;
           MPVSaPP  with MPVSaPP-nMPVSAPP
   seek str(nmjes+1,2)+cidk+roba->idtarifa+"1. PREDH INV."   // sljedeci mjesec
   if !found()
        append blank
   endif
   replace id with "1. PREDH INV.",;
           mjesec  with nmjes+1,;
           idkonto with cIDK,;
           idtarifa with roba->IdTarifa,;
           znak with "+",;
           MPV      with MPV+nMPV,;
           MPVSaPP  with MPVSaPP+nMPVSAPP


   select MAT_INVENT
   skip
ENDDO

my_close_all_dbf()
return


// ------------------------------------
// ------------------------------------
function mat_popisna_lista()
local _vars := hb_hash()
local _id_firma 
local _konto
local _datum
local _partner
local _filter := ""
local _my_xml := my_home() + "data.xml"

O_KONTO
O_PARTN

IF !_get_inv_vars( @_vars )
    my_close_all_dbf()
    return
ENDIF

_konto := _vars["konto"]
_datum := _vars["datum"]
_id_firma := LEFT( _vars["id_firma"], 2 )
_partner := _vars["partner"]

I := 0
K := 0
C := 0

O_MAT_SUBAN
O_SIFK
O_SIFV
O_ROBA

SELECT mat_suban
set order to tag "3"

set filter to datdok<=_datum .and. IF( !EMPTY(_partner), idpartner == _partner, .t. )
go top

SEEK _id_firma + _konto
NFOUND CRET

A := 0
B := 0

open_xml( _my_xml )
xml_head()

xml_subnode( "inv", .f. )

DO WHILE !EOF() .AND. _id_firma == field->idfirma .and. _konto == field->idkonto
   
    IF A == 0

        xml_node( "modul", "MAT" )
        xml_node( "datum", DTOC( _datum ) )

        select partn
        hseek _id_firma

        xml_node( "fid", to_xml_encoding( gFirma ) )
        xml_node( "fnaz", to_xml_encoding( gNFirma ) )

        if !EMPTY( _konto )
 
            select konto
            hseek _konto

            xml_node( "kid", to_xml_encoding( _konto ) )
            xml_node( "knaz", to_xml_encoding( ALLTRIM( field->naz ) ) )

        else

            xml_node( "kid", "" )
            xml_node( "knaz", "" )

        endif
 
        if !EMPTY( _partner )        

            select partn
            hseek _partner

            xml_node( "pid", to_xml_encoding( _partner ) )
            xml_node( "pnaz", to_xml_encoding( ALLTRIM( field->naz ) ) )

        else

            xml_node( "pid", "" )
            xml_node( "pnaz", "" )

        endif
 
    endif

    ++ A

    SELECT mat_suban
    cIdRoba := IdRoba

    if EMPTY( cIdRoba )
        skip
        loop
    endif

    nIznos := nIznos2 := nStanje := nCijena := 0

    DO WHILE !eof() .AND. _id_firma == field->IdFirma .and. _konto == field->IdKonto .and. cIdRoba == field->IdRoba

        // saberi za jednu robu

        IF field->U_I="1"
            nStanje += field->kolicina
        ELSE
            nStanje -= field->Kolicina
        ENDIF

        IF D_P="1"
            nIznos+=field->Iznos
            nIznos2+=field->Iznos2
        ELSE
            nIznos-=field->Iznos
            nIznos2-=field->Iznos2
        ENDIF

        SKIP

    ENDDO

    IF round(nStanje,4)<>0 .or. round(nIznos,4)<>0  

        // uzimaj samo one koji su na stanju  <> 0
        SELECT ROBA
        HSEEK cIdRoba

        IF round(nStanje,4) <> 0
            nCijena := nIznos/nStanje
        ELSE
            nCijena := 0
        ENDIF    
 
        xml_subnode( "items", .f. )
        
        xml_node( "rbr", ALLTRIM(STR( ++B ) ) )
        xml_node( "rid", to_xml_encoding( field->id ) )
        xml_node( "naz", to_xml_encoding( field->naz ) )
        xml_node( "jmj", to_xml_encoding( field->jmj ) )
        xml_node( "cijena", STR( nCijena, 12, 3 )  )
        xml_node( "stanje", STR( nStanje, 12, 3 )  )

        xml_subnode( "items", .t. )

        SELECT mat_suban

    ENDIF

ENDDO

xml_subnode( "inv", .t. )
close_xml()

my_close_all_dbf()

if B > 0
    if generisi_odt_iz_xml( "mat_invent.odt", _my_xml )
        prikazi_odt()
    endif
endif

return


