/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1995-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"

/*! \fn SintFilt(lSint,cFilter)
 *  \brief Iz filterisane SUBAN.DBF tabele generise POM.DBF
 *  \brief Ova funkcija ne podrzava varijantu gDatNal:="D"
 *  \param lSint   - .t.-POM.DBF je analitika, .f.-POM.DBF
 *  \param cFilter
 

   fin/fin_rpt_bilans.prg
   fin/fin_rpt_kartica_sinteticka.prg
   fin/fin_rpt_specifikacija_anal5.prg
   fin/fin_specifikacija.prg

*/

function SintFilt(lSint, cFilter)

IF lSint==NIL
   lSint:=.f. 
ENDIF

  // napravimo pomocnu bazu
  aDbf := {}
  AADD(aDBf,{ 'IDFIRMA'   , 'C' ,   5 ,  0 })
  AADD(aDBf,{ 'IDKONTO'   , 'C' , IF(lSint,3,7) ,  0 })
  AADD(aDBf,{ 'IDVN'      , 'C' ,   2 ,  0 })
  AADD(aDBf,{ 'BRNAL'     , 'C' ,   8 ,  0 })
  AADD(aDBf,{ 'RBR'       , 'C' ,   3 ,  0 })
  AADD(aDBf,{ 'DATNAL'    , 'D' ,   8 ,  0 })
  AADD(aDBf,{ 'DUGBHD'    , 'N' ,  17 ,  2 })
  AADD(aDBf,{ 'POTBHD'    , 'N' ,  17 ,  2 })
  AADD(aDBf,{ 'DUGDEM'    , 'N' ,  15 ,  2 })
  AADD(aDBf,{ 'POTDEM'    , 'N' ,  15 ,  2 })

  DBCREATE2 (PRIVPATH+"POM", aDbf)
  IF !lSint
    USEX (PRIVPATH+"POM", "ANAL", .t.)
  ELSE
    USEX (PRIVPATH+"POM", "SINT", .f.)
  ENDIF
  INDEX ON idFirma+IdVN+BrNal+IdKonto TAG "0"
  IF lSint
    INDEX ON IdFirma+IdKonto+dtos(DatNal) TAG "1"
    INDEX ON idFirma+IdVN+BrNal+Rbr       TAG "2"
  ELSE
    INDEX ON IdFirma+IdKonto+dtos(DatNal) TAG "1"
    INDEX ON idFirma+IdVN+BrNal+Rbr       TAG "2"
    INDEX ON idFirma+dtos(DatNal)         TAG "3"
    INDEX ON Idkonto                      TAG "4"
    INDEX ON DatNal                       TAG "5"
  ENDIF
  SET ORDER TO TAG "0"
  GO TOP

  O_SUBAN
  Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cFilt:=cFilter
  cSort1:="idFirma+IdVN+BrNal+IdKonto"
  INDEX ON &cSort1 TO "SUBTMP" FOR &cFilt EVAL(fin_tek_rec_2()) EVERY 1
  GO TOP
  nArr:=SELECT()
  BoxC()

  DO WHILE !eof()   // svi nalozi

    nD1:=nD2:=nP1:=nP2:=0
    cIdFirma:=IdFirma; cIDVn=IdVN; cBrNal:=BrNal

    DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog

        cIdkonto:=idkonto

        nDugBHD:=nDugDEM:=0
        nPotBHD:=nPotDEM:=0
        IF D_P="1"
          nDugBHD:=IznosBHD; nDugDEM:=IznosDEM
        ELSE
          nPotBHD:=IznosBHD; nPotDEM:=IznosDEM
        ENDIF

        IF !lSint
          SELECT ANAL     // analitika
          seek cidfirma+cidvn+cbrnal+cidkonto
          fNasao:=.f.
          DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                     .and. IdKonto==cIdKonto
            if month((nArr)->datdok)==month(datnal)
              fNasao:=.t.
              exit
            endif
            skip 1
          enddo
          if !fNasao
             append blank
          endif

          RREPLACE IdFirma WITH cIdFirma,IdKonto WITH cIdKonto,IdVN WITH cIdVN,;
                  BrNal with cBrNal,;
                  DatNal WITH max((nArr)->datdok,datnal),;
                  DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
                  DugDEM WITH DugDEM+nDugDEM, PotDEM WITH PotDEM+nPotDEM

        ELSE             // sintetika
  
          SELECT SINT
          seek cidfirma+cidvn+cbrnal+left(cidkonto,3)
          fNasao:=.f.
          DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                    .and. left(cidkonto,3)==idkonto
            if  month((nArr)->datdok)==month(datnal)
              fNasao:=.t.
              exit
            endif
            skip 1
          enddo
          if !fNasao
              append blank
          endif

          RREPLACE IdFirma WITH cIdFirma,IdKonto WITH left(cIdKonto,3),IdVN WITH cIdVN,;
               BrNal WITH cBrNal,;
               DatNal WITH max((nArr)->datdok,datnal),;
               DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
               DugDEM WITH DugDEM+nDugDEM,PotDEM WITH PotDEM+nPotDEM
        ENDIF
        SELECT (nArr)
        skip 1
    ENDDO  // nalog

    SELECT (nArr)

  ENDDO  // svi nalozi
  SELECT (nArr); USE

  IF !lSint
    SELECT ANAL
  ELSE
    SELECT SINT
  ENDIF
  go top
  do while !eof()
    nRbr:=0
    cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
    do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
      replace rbr with str(++nRbr,3)
      skip 1
    enddo
  enddo
  SET ORDER TO TAG "1"
  GO TOP

RETURN


