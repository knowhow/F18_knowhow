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


function Otpis16SI()
O_KONCIJ
O_KALK_PRIPR
O_KALK_PRIPR2
O_KALK
O_SIFK
O_SIFV
O_ROBA

select kalk_pripr; go top
private cIdFirma:=idfirma,cIdVD:=idvd,cBrDok:=brdok
if !(cidvd $ "16") .or. "-X"$cBrDok .or. Pitanje(,"Formirati dokument radi evidentiranja otpisanog dijela? (D/N)","N")=="N"
  my_close_all_dbf()
  return .f.
endif

cBrUlaz := PADR( TRIM(kalk_pripr->brdok)+"-X" , 8 )

select kalk_pripr
go top
private nRBr:=0
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
  scatter()
  select kalk_pripr2
   append blank
    _brdok:=cBrUlaz
    _idkonto:="X-"+TRIM(kalk_pripr->idkonto)
    _MKonto:=_idkonto
    _TBankTr:="X"    // izgenerisani dokument
     gather()
  select kalk_pripr
  skip
enddo

my_close_all_dbf()
RETURN .t.
*}

