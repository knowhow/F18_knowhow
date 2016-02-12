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


static PicDEM := "9999999999.99"
static PicBHD := "9999999999.99"
static PicKol := "9999999999.999"


// --------------------------------------
// kartice, glavni menij
// --------------------------------------
function mat_kartica()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. sintetika      " )
AADD( _opcexe, { || KSintKont() } )
AADD( _opc, "2. analitika" )
AADD( _opcexe, { || KAnalK() } )
AADD( _opc, "3. subanalitika " )
AADD( _opcexe, { || KSuban() } )


f18_menu("kca", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return


// --------------------------------------
// sinteticka kartica
// --------------------------------------
function KSintKont()
local nC1:=30

O_PARTN

cIdFirma:=gFirma
qqKonto:=SPACE(100)
Box("KSK",4,60,.f.)
do while .t.
@ m_x+1,m_y+2 SAY "SINTETICKA KARTICA"
if gNW$"DR"
  @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
@ m_x+4,m_y+2 SAY KonSeks("KONTO")+":  " GET qqKonto picture "@S50"
READ;  ESC_BCR
 aUsl1 := Parsiraj( qqKonto, "IdKonto", "C" )
 if aUsl1<>NIL
     exit
 endif
enddo

BoxC()

cIdFirma:=left(cIdFirma,2)

O_MAT_SINT
O_KONTO

select mat_sint
set filter to Tacno(aUsl1) .and. IdFirma==cIdFirma
go top

EOF CRET

START PRINT CRET

m := "------- ---- -----------"
for _i := 1 to 4
    m += " " + REPLICATE( "-", LEN( PicDEM ) ) 
next

do while !eof() 
// firma

nUkDug := 0
nUkPot := 0
nUkDug2 := 0
nUkPot2 := 0
cIdKonto := IdKonto

if prow()<>0
    FF
    ZaglKSintK()
endif

DO WHILE !eof() .AND. cIdFirma=IdFirma .and. cIdKonto=IdKonto
   IF prow()==0; ZaglKSintK(); ENDIF
   IF prow()>65; FF; ZaglKSintK(); ENDIF
   ? IdVN, brnal,rbr,"  ",datnal
   nC1:=pcol()+3
   @ prow(),pcol()+3 SAY Dug PICTURE picDEM
   nUkDug+=Dug
   @ prow(),pcol()+1 SAY Pot PICTURE picDEM
   nUkPot+=Pot
   @ prow(),pcol()+1 SAY Dug2 PICTURE picBHD
   nUkDug2+=Dug2
   @ prow(),pcol()+1 SAY Pot2 PICTURE picBHD
   nUkPot2+=Pot2
   SKIP
ENDDO

IF prow()>61; FF; ZaglKSintK(); ENDIF
? m
? "UKUPNO:"
@ prow(),nC1 SAY nUkDug        PICTURE picDEM
@ prow(),pcol()+1 SAY nUkPot  PICTURE picDEM
@ prow(),pcol()+1 SAY nUkDug2 PICTURE picBHD
@ prow(),pcol()+1 SAY nUkPot2 PICTURE picBHD
?  m
? "SALDO:"
nSaldo:=nUkDug-nUkPot
nSaldo2:=nUkDug2-nUkPot2
IF nSaldo>0
   @ prow(),nC1 SAY nSaldo        PICTURE picDEM
   @ prow(),pcol()+1 SAY 0       PICTURE picDEM
   @ prow(),pcol()+1 SAY nSaldo2 PICTURE picBHD
ELSE 
   nSaldo:=-nSaldo
   @ prow(),pcol()+1 SAY 0       PICTURE picDEM
   @ prow(),pcol()+1 SAY nSaldo  PICTURE picDEM
   @ prow(),pcol()+1 SAY 0       PICTURE picBHD
   @ prow(),pcol()+1 SAY nSaldo2 PICTURE picBHD
ENDIF
? m
nUkDug:=nUkPot:=nUkDug2:=nUkPot2:=0

enddo

FF
ENDPRINT

my_close_all_dbf()
return


// ----------------------------------------------
// zaglavlje sinteticke kartice
// ----------------------------------------------
static function ZaglKSintK()
local _line1, _line2, _line3

_line1 := "*NALOG * R. *  DATUM    *"
_line2 := "*      * Br *            "
_line3 := "*      *    *  NALOGA   *"

_line1 += PADC( "I Z N O S  U  " + ValDomaca(), ( LEN( PicDEM ) * 2 ) + 1 ) 
_line1 += "*"
_line1 += PADC( "I Z N O S  U  " + ValPomocna(), ( LEN( PicDEM ) * 2 ) + 1 )
_line1 += "*"

_line2 += REPLICATE( "-", ( LEN( PICDEM ) * 2 ) + 1 )
_line2 += " " 
_line2 += REPLICATE( "-", ( LEN( PICDEM ) * 2 ) + 1 )

_line3 += PADC( "DUGUJE", LEN( PICDEM ) ) + "*"
_line3 += PADC( "POTRAZUJE", LEN( PICDEM ) ) + "*"
_line3 += PADC( "DUGUJE", LEN( PICDEM ) ) + "*"
_line3 += PADC( "POTRAZUJE", LEN( PICDEM ) ) + "*"

?? "MAT.P: SINTETICKA KARTICA   NA DAN "
@ prow(), PCOL() + 1 SAY DATE()

SELECT PARTN
HSEEK cIdFirma

? "FIRMA:", cIdFirma, PADR( partn->naz, 25 ), PADR( partn->naz2, 25 )

SELECT KONTO
HSEEK cIdKonto

? KonSeks("KONTO") + ":", cIdkonto, ALLTRIM( konto->naz )

? m
? _line1
? _line2
? _line3
? m

SELECT mat_sint
RETURN


// -----------------------------------------
// analiticka kartica
// -----------------------------------------
function KAnalK()
local _izbor := 1
local _opc := {}
local _opcexe := {}

AADD( _opc, "1. kartica za pojedinacni konto         " )
AADD( _opcexe, { || KAnKPoj() } )
AADD( _opc, "2. kartica po svim kontima" )
AADD( _opcexe, { || KAnKKonto() } )

f18_menu("ksix", .f., _izbor, _opc, _opcexe )

return



// -----------------------------------------
// -----------------------------------------
function KAnKPoj()
cIdFirma:="  "
qqKonto:=SPACE(100)

O_PARTN

Box("KANP",3,70,.f.)

do while .t.
 @ m_x+1,m_y+6 SAY "ANALITICKA KARTICA"
 if gNW$"DR"
  @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
  cIdFirma:=gFirma
 else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY KonSeks("KONTO  ")+"  : " GET qqKonto  picture "@S50"
 READ;  ESC_BCR

 aUsl1:=Parsiraj(qqKonto,"IdKonto","C")
 if aUsl1<>NIL; exit; endif
enddo

BoxC()

O_MAT_ANAL
O_KONTO

select mat_anal 
set filter to Tacno(aUsl1) .and. IdFirma==cIdFirma
go top
EOF CRET

START PRINT CRET

m := "-- ---- --- -------- "
for _i := 1 to 4
    m += " " + REPLICATE("-", LEN( PICDEM ) ) 
next

a:=0
do while !eof()

  cIdKonto:=IdKonto
  if a<>0; EJECTA0; ZaglKAnalK(); endif
  nUkDug:=nUkPot:=nUkDug2:=nUkPot2:=0
  DO WHILE !eof() .and. cIdKonto==IdKonto //konto
     IF A==0; ZaglKAnalK(); ENDIF
     IF A>64; EJECTA0; ZaglKAnalK(); ENDIF
     @ ++A,0      SAY IdVN
     @ A,pcol()+1 SAY BrNal
     @ A,pcol()+1 SAY RBr
     @ A,pcol()+1 SAY DatNal
     @ A,pcol()+1 SAY Dug PICTURE picDEM
     @ A,pcol()+1 SAY Pot PICTURE picDEM
     @ A,pcol()+1 SAY Dug2 PICTURE picBHD
     @ A,pcol()+1 SAY Pot2 PICTURE picBHD
     nUkDug+=Dug; nUkPot+=Pot; nUkDug2+=Dug2; nUkPot2+=Pot2
     SKIP
  ENDDO

  @ ++A,0 SAY m
  @ ++A,0 SAY "UKUPNO:"
  @ A,21       SAY nUkDug  PICTURE picDEM
  @ A,pcol()+1 SAY nUkPot  PICTURE picDEM
  @ A,pcol()+1 SAY nUkDug2 PICTURE picBHD
  @ A,pcol()+1 SAY nUkPot2  PICTURE picBHD
  @ ++A,0 SAY m
  @ ++A,0 SAY "SALDO:"
  nSaldo:=nUkDug-nUkPot
  nSaldo2:=nUkDug2-nUkPot2
  IF nSaldo>=0
     @ A,21 SAY nSaldo PICTURE picDEM
     @ A,pcol()+1 SAY 0 PICTURE picDEM
     @ A,pcol()+1 SAY nSaldo2 PICTURE picBHD
  ELSE
     nSaldo:=-nSaldo
     @ A,21 SAY 0 PICTURE picDEM
     @ A,pcol()+1 SAY nSaldo PICTURE picDEM
     @ A,pcol()+1 SAY 0 PICTURE picBHD
     @ A,pcol()+1 SAY nSaldo2 PICTURE picBHD
  ENDIF
  @ ++A,0 SAY m
  nUkDug:=nUkPot:=nUkDug2:=nUkPot2:=0

enddo // eof

EJECTNA0

ENDPRINT

set filter to
my_close_all_dbf()

return


static function ZaglKAnalK()
local _line1, _line2, _line3

_line1 := "*V* BR *  DATUM   *"
_line2 := "* *NAL *           "
_line3 := "*N*    *  NALOGA  *"

_line1 += PADC( "I Z N O S  U  " + ValDomaca(), ( LEN( PicDEM ) * 2 ) + 2 ) + "*"
_line1 += PADC( "I Z N O S  U  " + ValPomocna(), ( LEN( PicDEM ) * 2 ) + 2 )

_line2 += REPLICATE( "-", ( LEN( PICDEM ) * 2 ) + 1 )
_line2 += " " + REPLICATE( "-", ( LEN( PICDEM ) * 2 ) + 1 )

_line3 += PADC( "DUGUJE", LEN( PICDEM ) ) + "*"
_line3 += PADC( "POTRAZUJE", LEN( PICDEM ) ) + "*"
_line3 += PADC( "DUGUJE", LEN( PICDEM ) ) + "*"
_line3 += PADC( "POTRAZUJE", LEN( PICDEM ) ) + "*"

P_COND
@ a,0  SAY "MAT.P: KARTICA - ANALITICKI "+KonSeks("KONTO")+" - ZA POJEDINACNI "+KonSeks("KONTO")
@ ++A,0 SAY "FIRMA:"; @ A,pcol()+1 SAY cIdFirma
SELECT PARTN; HSEEK cIdFirma
@ A,pcol()+1 SAY naz; @ A,pcol()+1 SAY naz2

@ ++A,0 SAY KonSeks("KONTO")+":"; @ A,pcol()+1 SAY cIdKonto
SELECT KONTO; HSEEK cIdKonto
@ A,pcol()+1 SAY naz

@ ++A,0 SAY m 
@ ++A,0 SAY _line1
@ ++A,0 SAY _line2
@ ++A,0 SAY _line3
@ ++A,0 SAY m

SELECT mat_anal
RETURN



function KAnKKonto()

cIdFirma:="  "

O_PARTN
O_MAT_ANAL

Box("kankko",2,60,.f.)
@ m_x+1,m_y+2 SAY "ANALITICKA KARTICA - PO "+KonSeks("KONT")+"IMA"
if gNW$"DR"
  @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
  cIdFirma:=gFirma
else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
READ;  ESC_BCR
BoxC()

// cIdFirma:=left(cIdFirma,2)

O_MAT_SUBAN
O_KONTO
O_ROBA
O_SIFK
O_SIFV

SELECT mat_anal
set order to tag "2"
SEEK cIdFirma
NFOUND CRET

START PRINT CRET
A:=0

m := "------- ---------------------------------"
for _i := 1 to 6
    m += " " + REPLICATE( "-", LEN( PICDEM ) ) 
next

nUkDug:=nUkUkDug:=nUkPot:=nUkUkPot:=0
nUkDug2:=nUkUk2Dug:=nUkPot2:=nUkUk2Pot:=0
DO WHILE !eof() .AND. cIdFirma=IdFirma

   cIdKonto:=IdKonto

   DO WHILE !eof() .AND. cIdFirma=IdFirma .AND. cIdKonto=IdKonto
      nUkDug+=Dug; nUkPot+=Pot
      nUkDug2+=Dug2; nUkPot2+=Pot2
      SKIP
   ENDDO

   if A==0; ZagKKAnalK();endif
   if A>62; EJECTA0; ZagKKAnalK();endif
   nSaldo:=nUkDug-nUkPot
   nSaldo2:=nUkDug2-nUkPot2

   @ ++A,1 SAY cIdKonto
   SELECT KONTO; HSEEK cIdKonto
   @ A,8 SAY Naz picture replicate("X",32)

   @ A,42       SAY nUkDug  PICTURE PicDEM
   @ A,pcol()+1 SAY nUkPot  PICTURE PicDEM
   @ A,pcol()+1 SAY nSaldo  PICTURE PicDEM
   @ A,pcol()+1 SAY nUkDug2 PICTURE PicBHD
   @ A,pcol()+1 SAY nUkPot2 PICTURE PicBHD
   @ A,pcol()+1 SAY nSaldo2 PICTURE PicBHD
   nUkUkDug+=nUkDug; nUkUkPot+=nUkPot
   nUkUk2Dug+=nUkDug2; nUkUk2Pot+=nUkPot2
   nUkDug:=nUkPot:=nUkDug2:=nUkPot2:=0
   SELECT mat_anal
ENDDO

if A>62; EJECTA0; ZagKKAnalK();endif
nUkSaldo:=nUkUkDug-nUkUkPot
nUk2Saldo:=nUkUk2Dug-nUkUk2Pot
@ ++A,0 SAY M
@ ++A,0 SAY "UKUPNO ZA FIRMU:"
@ A,42       SAY nUkUkDug  PICTURE PicDEM
@ A,pcol()+1 SAY nUkUkPot  PICTURE PicDEM
@ A,pcol()+1 SAY nUkSaldo  PICTURE PicDEM
@ A,pcol()+1 SAY nUkUk2Dug PICTURE PicBHD
@ A,pcol()+1 SAY nUkUk2Pot PICTURE PicBHD
@ A,pcol()+1 SAY nUk2Saldo PICTURE PicBHD
@ ++A,0 SAY M
nUkUkDug:=nUkUkPot:=nUkUk2Dug:=nUkUk2Pot:=0

EJECTNA0
ENDPRINT
my_close_all_dbf()
return



function ZagKKAnalK()
local _line1, _line2, _line3

_line1 := KonSeks("*KONTO ") + "*  NAZIV " + KonSeks( "KONTA " ) + "               *" 
_line2 := "                                          "
_line3 := "*       *                                 *"

_line1 += PADC( "I Z N O S  U  " + ValDomaca(), ( LEN( PicDEM ) * 2 ) + 3 ) + "*"
_line1 += PADC( "I Z N O S  U  " + ValPomocna(), ( LEN( PicDEM ) * 2 ) + 3 )

_line2 += REPLICATE( "-", ( LEN( PICDEM ) * 3 ) + 1 )
_line2 += " " + REPLICATE( "-", ( LEN( PICDEM ) * 3 ) + 1 )

_line3 += PADC( "DUGUJE", LEN( PICDEM ) ) + "*"
_line3 += PADC( "POTRAZUJE", LEN( PICDEM ) ) + "*"
_line3 += PADC( "SALDO", LEN( PICDEM ) ) + "*"
_line3 += PADC( "DUGUJE", LEN( PICDEM ) ) + "*"
_line3 += PADC( "POTRAZUJE", LEN( PICDEM ) ) + "*"
_line3 += PADC( "SALDO", LEN( PICDEM ) ) + "*"


P_COND
@ a,0  SAY "MAT.P: KARTICA STANJA PO ANALITICKIM "+KonSeks("KONT")+"IMA NA DAN "; @ A,PCOL()+1 SAY DATE()
@ A,0 SAY "FIRMA:"
@ A,10 SAY cIdFirma
SELECT PARTN; HSEEK cIdFirma
@ A,PCOL()+2 SAY naz; @ A,PCOL()+1 SAY naz2

@ ++A,0 SAY m 
@ ++A,0 SAY _line1
@ ++A,0 SAY _line2
@ ++A,0 SAY _line3
@ ++A,0 SAY m

SELECT mat_anal
RETURN



// ---------------------------------------------
// mat_subanaliticka kartica
// ---------------------------------------------
function KSuban()
local _roba := ""
local _partner := ""
local _konto := ""
local _filter := ".t."
local _brza_k := "D"
local _preth_p := "1"
local _col_1
local _col_2
local _id_firma := gFirma
local _dat_od := CTOD( "" )
local _dat_do := CTOD( "" )

O_PARTN
O_KONTO
O_SIFK
O_SIFV
O_ROBA

Box( "", 10, 70, .f. )

    O_PARAMS
    Private cSection:="4",cHistory:=" ",aHistory:={}
    Params1()
    RPar("c1",@_brza_k)
    RPar("c2",@_id_firma)
    RPar("c3",@_konto)
    RPar("c4",@_partner)
    RPar("c5",@_roba)
    RPar("c6",@_preth_p)
    RPar("d1",@_dat_od)
    RPar("d2",@_dat_do)
    
    if gNW$"DR"
        _id_firma := gFirma
    endif

    @ m_x+1, m_y+2 SAY "SUBANALITICKA KARTICA"

    @ m_x+2, m_y+2 SAY "Brza kartica (D/N)" GET _brza_k pict "@!" valid _brza_k $ "DN"
    
    read

    do while .t.
        
        if gNW$"DR"
            @ m_x+3, m_y+2 SAY "Firma "
            ?? gFirma, "-", gNFirma
        else
            @ m_x+3, m_y+2 SAY "Firma: " GET _id_firma ;
                VALID {|| P_Firma( @_id_firma ), _id_firma := left( _id_firma, 2), .t. }
        endif

        if _brza_k == "D"
            _konto := PADR( _konto, 7 )
            _roba := PADR( _roba, 10 )
            @ m_x+4, m_y+2 SAY KonSeks("Konto  ")+"        " GET _konto ;
                pict "@!" valid P_Konto(@_konto)
            @ m_x+5, m_y+2 SAY "Sifra artikla  " GET _roba ;
                pict "@!" valid P_Roba(@_roba)
        else
            _konto := PADR( _konto, 60 )
            _partner := PADR( _partner, 60 )
            _roba := PADR( _roba, 80 )
            @ m_x+4, m_y+2 SAY KonSeks("Konto  ")+"        " GET _konto ;
                PICT "@S50"
            @ m_x+5, m_y+2 SAY "Partner        " GET _partner ;
                PICT "@S50"
            @ m_x+6, m_y+2 SAY "Sifra artikla  " GET _roba ;
                PICT "@S50"
        endif

        @ m_x+8, m_y+2 SAY "BEZ/SA predhodnim prometom (1/2):" GET _preth_p valid _preth_p $ "12"
        @ m_x+10, m_y+2 SAY "Datum dokumenta od:" GET _dat_od
        @ m_x+10, col()+2 SAY "do" GET _dat_do valid _dat_do >= _dat_do
        
        READ
        ESC_BCR

        if _brza_k == "N"
            _usl_partner := Parsiraj(_partner,"IdPartner","C")
            _usl_roba := Parsiraj(_roba,"IdRoba","C")
            _usl_konto:=Parsiraj(_konto,"IdKonto","C")
            if _usl_partner <> NIL .and. _usl_roba <> NIL .and. _usl_konto <> NIL 
 	            exit
            endif
        else
            exit
        endif

    enddo

BoxC()

if Params2()
 WPar("c1",_brza_k)
 WPar("c2",padr(_id_firma,2))
 WPar("c3",_konto)
 WPar("c4",_partner)
 WPar("c5",_roba)
 WPar("c6",_preth_p)
 WPar("d1",_dat_od)
 WPar("d2",_dat_do)
endif
select params
use

O_MAT_SUBAN
O_TDOK

select mat_suban
set order to tag "3"

if _brza_k == "D"
	if _preth_p == "1"
         	if !empty(_dat_od) .and. !empty(_dat_do)
          		set filter to  _dat_od<=DatDok .and. _dat_do>=DatDok
         	else
          		set filter to
         	endif
  	else    
  		// sa predhodnim prometom
         	if  !empty(_dat_do)
          		set filter to  _dat_do>=DatDok
         	else
          		set filter to
         	endif
  	endif
  	
	HSEEK _id_firma + _konto + _roba

else 
       	
	if _preth_p == "1"

		if !EMPTY( _dat_od ) .and. !EMPTY( _dat_do )
 			_filter += " .and. (DatDok >= " + ;
				dbf_quote( _dat_od ) + ;
				" .and. DatDok <= " + ;
				dbf_quote( _dat_do ) + ")"
		endif
	else
		
		if !EMPTY( _dat_do )
			_filter += " .and. (DatDok <= " + ;
				dbf_quote( _dat_do ) + ")"
	
		endif
	endif

	if !EMPTY( _partner )
		_filter += " .and. " + _usl_partner
	endif

	if !EMPTY( _konto )
		_filter += " .and. " + _usl_konto
	endif

	if !EMPTY( _roba )
		_filter += " .and. " + _usl_roba
	endif

	set filter to &(_filter) 
	HSEEK _id_firma
       	
endif 

// cBrza

EOF CRET

m := "-- ---- -- -------- -------- ------"

for _i := 1 to 3
    m += " " + REPLICATE( "-", LEN( PICKOL ) )
next

_i := 1
for _i := 1 to 5
    m += " " + REPLICATE( "-", LEN( PICDEM ) )
next

nStr:=0
START PRINT CRET

A:=0
_col_1:=0
_col_2:=0

do while !eof() .and. IdFirma==_id_firma

  if _brza_k == "D"
    if _konto<>IdKonto .or. _roba<>IdRoba
    	exit
    endif
  endif

  cIdKonto:=IdKonto
  cIdRoba:=IdRoba

  nUlazK:=0
  nIzlazK:=0
  nDugI:=0
  nPotI:=0
  nDugI2:=0
  nPotI2:=0

  ZaglKSif( _id_firma, cIdRoba, cIdKonto, m )
  
  if _preth_p = "2"
    
    do while !eof() .and. IdFirma==_id_firma .AND. IdKonto==cIdKonto .and. IdRoba==cIdRoba .and. datdok<_dat_od
     IF U_I="1"
        nUlazK+=Kolicina
     ELSE
        nIzlazK+=Kolicina
     ENDIF

     IF D_P="1"
        nDugI+=Iznos
        nDugI2+=Iznos2
     ELSE
        nPotI+=Iznos
        nPotI2+=Iznos2
     ENDIF
      skip
    enddo
      ? "Promet do",_dat_od
      @ prow(),36 SAY nUlazK pict pickol
      @ prow(),pcol()+1 SAY nIzlazK pict pickol
      @ prow(),pcol()+1 SAY nUlazK-nIzlazK pict pickol
      if round(nUlazK-nIzlazK,4)<>0
         nCijena=(nDugI-nPotI)/(nUlazK-nIzlazK)
      else
         nCijena:=0
      ENDIF
      @ prow(),pcol()+1 SAY nCijena pict "9999999.999"
      @ prow(),pcol()+1 SAY nDugI pict picdem
      @ prow(),pcol()+1 SAY nPotI pict picdem
      @ prow(),pcol()+1 SAY nDugI2 pict picbhd
      @ prow(),pcol()+1 SAY nPotI2 pict picbhd

  endif

  DO WHILE !eof() .and. IdFirma==_id_firma .AND. IdKonto==cIdKonto .and. IdRoba==cIdRoba
     SELECT mat_suban

     if prow()>61 
         FF
         ZaglKSif( _id_firma, cIdRoba, cIdKonto, m )
     endif
     @ prow()+1,0 SAY IdVN
     @ prow(),pcol()+1 SAY BrNal
     @ prow(),pcol()+1 SAY IdTipDok
     @ prow(),pcol()+1 SAY BrDok
     @ prow(),pcol()+1 SAY DatDok
     @ prow(),pcol()+1 SAY IdPartner
     _col_1 := PCOL()+1
     IF U_I="1"
        @ prow(),pcol()+1 SAY Kolicina PICTURE PicKol
        @ prow(),pcol()+1 SAY 0 PICTURE PicKol
        nUlazK+=Kolicina
     ELSE
        @ prow(),pcol()+1 SAY 0 PICTURE PicKol
        @ prow(),pcol()+1 SAY Kolicina PICTURE PicKol
        nIzlazK+=Kolicina
     ENDIF
     @ prow(),pcol()+1 SAY nUlazK-nIzlazK pict pickol
     @ prow(),pcol()+1 SAY iif(round(Kolicina,4)<>0,Iznos/Kolicina,0) pict PICDEM

     _col_2 := pcol()+1
     IF D_P="1"
        @ prow(),pcol()+1 SAY Iznos PICTURE PicDem
        @ prow(),pcol()+1 SAY 0 PICTURE PicDem
        @ prow(),pcol()+1 SAY Iznos2 PICTURE PicBHD
        @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
        nDugI+=Iznos
        nDugI2+=Iznos2
     ELSE
        @ prow(),pcol()+1 SAY 0 PICTURE PicDem
        @ prow(),pcol()+1 SAY Iznos PICTURE PicDem
        @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
        @ prow(),pcol()+1 SAY Iznos PICTURE PicBHD
        nPotI+=Iznos
        nPotI2+=Iznos2
     ENDIF
     select mat_suban
     skip
  ENDDO

  if prow() > 59
    FF
    ZaglKSif( _id_firma, cIdRoba, cIdKonto, m )
  endif
  
  ? m
  ? "UKUPNO:"
  @ prow(),_col_1 SAY nUlazK PICTURE PicKol
  @ prow(),pcol()+1 SAY nIzlazK PICTURE PicKol
  @ prow(),pcol()+1 SAY nUlazK-nIzlazK PICTURE PicKol
  @ prow(),_col_2    SAY nDugI PICTURE PicDEM
  @ prow(),pcol()+1 SAY nPotI PICTURE PicDEM
  @ prow(),pcol()+1 SAY nDugI2 PICTURE PicBHD
  @ prow(),pcol()+1 SAY nPotI2 PICTURE PicBHD
  ? m
  ? "SALDO:"

  nSaldoI:=nDugI-nPotI
  nSaldoI2:=nDugI2-nPotI2
  nSaldoK:=nUlazK-nIzlazK
  nCijena:=0; nCijena2:=0
  IF round(nSaldoK,4)<>0
     nCijena=nSaldoI/nSaldoK
     nCijena2:=nSaldoI2/nSaldoK
  else
     nCijena:=nCijena2:=0
  ENDIF
  @ prow(),pcol()+2     SAY "CIJENA:"
  @ prow(),pcol()+1 SAY nCijena  picture "999999.999"
  @ prow(),pcol()+1 SAY ValPomocna()

  IF nSaldoK>0
     @ prow(),_col_1 SAY nSaldoK PICTURE PicKol
     @ prow(),pcol()+1 SAY 0   PICTURE PicKol
  ELSE
     nSaldoK:=-nSaldoK
     @ prow(),_col_1    SAY 0       PICTURE PicKol
     @ prow(),pcol()+1 SAY nSaldoK PICTURE PicKol
  ENDIF
  @ prow(),pcol()+1 SAY space(len(pickol))

  IF nSaldoI>0
     @ prow(),_col_2 SAY nSaldoI PICTURE PicDEM
     @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
  ELSE
     nSaldoI:=-nSaldoI
     @ prow(),_col_2  SAY 0         PICTURE PicDEM
     @ prow(),pcol()+1 SAY nSaldoI PICTURE PicDEM
  ENDIF
  IF nSaldoI2>0
     @ prow(),pcol()+1 SAY nSaldoI2 PICTURE PicBHD
     @ prow(),pcol()+1 SAY 0        PICTURE PicBHD
  ELSE
     nSaldoI2:=-nSaldoI2
     @ prow(),pcol()+1 SAY 0         PICTURE PicBHD
     @ prow(),pcol()+1 SAY nSaldoI2  PICTURE PicBHD
  ENDIF

  ? m
  ?
enddo 

FF
ENDPRINT

my_close_all_dbf()
return


// --------------------------------------------------------------------
// zaglavlje
// --------------------------------------------------------------------
static function ZaglKSif( id_firma, id_roba, id_konto, line )

?
P_COND2

?? "MAT.P: SUBANALITICKA KARTICA   NA DAN "
@ prow(),PCOL()+1 SAY DATE()

? "FIRMA:"
@ prow(),pcol()+1 SAY id_firma

SELECT PARTN
HSEEK id_firma

@  prow(),pcol()+2 SAY naz
@  prow(),pcol()+1 SAY naz2
@  prow(),120 SAY "Str."+str(++nStr,3)

? "ARTIKAL:"
@ prow(),pcol()+1 SAY id_roba

select ROBA
HSEEK id_roba

@ prow(),pcol()+1 SAY naz
@ prow(),pcol()+2 SAY jmj

? KonSeks("KONTO")+":"
@ prow(),pcol()+1 SAY id_konto

SELECT KONTO
HSEEK id_konto

@ prow(),pcol()+1 SAY konto->naz

? line

?  "*NALOG *   D O K U M E N T         " + ;
        "*" + PADC( "KOLICINA", LEN( PICKOL ) * 2 + 1 ) + ;
        "*" + PADC( "STANJE", LEN( PICKOL) ) + ;
        "*" + PADC( "CIJENA", LEN( PICDEM) ) + ;
        "*" + PADC( "I Z N O S  U " + ValDomaca(), ( LEN( PICDEM ) * 2 ) + 1 ) + ;
        "*" + PADC( "I Z N O S  U " + ValPomocna(), ( LEN( PICDEM ) * 2 ) + 1 ) + ;
        "*"

?  "------- --------------------------- " + ;
        REPLICATE( "-", LEN( PICKOL ) * 3 + 2 ) + ;
        "*" + REPLICATE( "-", LEN( PICDEM ) ) + ;
        "*" + REPLICATE( "-", LEN( PICDEM ) * 2 + 1 ) + ;
        "*" + REPLICATE( "-", LEN( PICDEM ) * 2 + 1 ) + ;
        "*"

?  "*V*BROJ*TIP* BROJ  * DATUM  * PART *" + ;
        PADC( "ULAZ", LEN( PICKOL ) ) + ;
        "*" + PADC( "IZLAZ", LEN( PICKOL ) ) + ;
        "*" + PADC( "STANJE", LEN( PICKOL ) ) + ;
        "*" + PADC( ValDomaca(), LEN( PICDEM ) ) + ;
        "*" + PADC( "DUGUJE", LEN( PICDEM ) ) + ;
        "*" + PADC( "POTRAZUJE", LEN( PICDEM ) ) + ;
        "*" + PADC( "DUGUJE", LEN( PICDEM ) ) + ;
        "*" + PADC( "POTRAZUJE", LEN( PICDEM ) ) + ;
        "*"
? line

SELECT mat_suban
return


