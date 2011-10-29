/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


/*! \fn KontrZbNal()
 *  \brief Kontrola zbira naloga
 */
 
function KontrZbNal()

PushWa()

Box("kzb",12,70,.f.,"Kontrola zbira naloga")
      
    set cursor on
    
    cIdFirma:=IdFirma
    cIdVN:=IdVN
    cBrNal:=BrNal

    @ m_x+1,m_y+1 SAY "       Firma: "+cIDFirma
    @ m_x+2,m_y+1 SAY "Vrsta naloga:" GET cIdVn valid P_VN(@cIdVN,2,20)
    @ m_x+3,m_y+1 SAY " Broj naloga:" GET cBrNal

    READ
    
    if lastkey()==K_ESC
       BoxC()
       PopWA()
       return DE_CONT
    endif
    
    set cursor off
    cIdFirma:=left(cIdFirma,2)
    
    
    set order to tag "1"
    seek cIdFirma+cIdVn+cBrNal
    if !(IdFirma+IdVn+BrNal==cIdFirma+cIdVn+cBrNal)
        Msg("Ovaj nalog nije unesen ...",10)
        BoxC()
        PopWa()
        return DE_CONT
    endif

    dug:=dug2:=Pot:=Pot2:=0
    do while  !eof() .and. (IdFirma+IdVn+BrNal==cIdFirma+cIdVn+cBrNal)
        if D_P=="1"; dug+=IznosBHD; dug2+=iznosdem; else; pot+=IznosBHD;pot2+=iznosdem; endif
        skip
    enddo
    SKIP -1
    
    Scatter()

    cPic:=FormPicL("9 "+gPicBHD,20)
    
    @ m_x+5,m_y+2 SAY "Zbir naloga:"
    @ m_x+6,m_y+2 SAY "     Duguje:"
    @ m_x+6,COL()+2 SAY Dug PICTURE cPic
    @ m_x+6,COL()+2 SAY Dug2 PICTURE cPic
    @ m_x+7,m_y+2 SAY "  Potrazuje:"
    @ m_x+7,COL()+2 SAY Pot  PICTURE cPic
    @ m_x+7,COL()+2 SAY Pot2  PICTURE cPic
    @ m_x+8,m_y+2 SAY "      Saldo:"
    @ m_x+8,COL()+2 SAY Dug-Pot  PICTURE cPic
    @ m_x+8,COL()+2 SAY Dug2-Pot2  PICTURE cPic
    Inkey(0)

    
    if round(Dug-Pot,2) <> 0  .and. gRavnot=="D"
        
	cDN:="N"
        set cursor on
        @ m_x+10,m_y+2 SAY "Zelite li uravnoteziti nalog (D/N) ?" GET cDN valid (cDN $ "DN") pict "@!"
        read

        if cDN=="D"
          
	  _Opis:=PADR("?",LEN(_opis))
          _BrDok:=""
          _D_P:="2"
	  _IdKonto:=SPACE(7)
          
	  @ m_x+11,m_y+2 SAY "Opis" GET _opis  WHEN {|| USTipke(),.t.} VALID {|| BosTipke(),.t.} PICT "@S40"
          @ m_x+12,m_y+2 SAY "Staviti na konto ?" GET _IdKonto valid P_Konto(@_IdKonto)
          @ m_x+12,col()+1 SAY "Datum dokumenta:" GET _DatDok
          read
          
	  if lastkey()<>K_ESC
            _Rbr:=str(val(_Rbr)+1,4)
            _IdPartner:=""
            _IznosBHD:=Dug-Pot
            DinDem(NIL,NIL,"_IZNOSBHD")
            append blank
            Gather()
	  endif

        endif // cDN=="D"

    endif  // dug-pot<>0
BoxC()
PopWA()

return

