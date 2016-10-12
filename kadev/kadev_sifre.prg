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


#include "kadev.ch"

// -----------------------------------------
// mjesne zajednice
// -----------------------------------------
function P_MZ(cId,dx,dy)
local i
private ImeKol := {}
private Kol := {}

ImeKol:={ { "ID",  {|| id},               "id"       },;
          { PADR("Naziv:",20), {|| naz},  "naz"      },;
          { "Naziv2:",{|| naz2},          "naz2"     };
        }
	
for i:=1 to LEN(ImeKol)
	AADD( Kol, i )
next

return PostojiSifra(F_KDV_MZ,"ID",10,50,"Lista Mjesnih zajednica",@cId,dx,dy)



// --------------------------------------
// neradni dani
// --------------------------------------
function P_NerDan(cId,dx,dy)
local i   
private ImeKol := {}
private Kol := {}

ImeKol:={ { "ID (godina)",      {|| id},    "id"      },;
          { PADR("Naziv:",20), {|| naz},   "naz"     },;
          { "Datum",           {|| datum}, "datum"   };
        }

for i:=1 to LEN(ImeKol)
	AADD( Kol, i )
next

return PostojiSifra(F_KDV_NERDAN,"ID",10,70,"Lista neradnih dana���<F5>-generisi subote i nedjelje",@cId,dx,dy,{|Ch| NerDanBlok(Ch)})


// --------------------------------------
// key handler neradni dani
// --------------------------------------
function NerDanBlok(Ch)
if Ch==K_F5
	GenNerDan()
  	return DE_REFRESH
endif
return DE_CONT


function P_Kadev_RJ(cId,dx,dy)
local i
private ImeKol := {}
private Kol := {}

ImeKol:={ { PADR("ID",6),  {|| id},               "id"       },;
          { PADR("Naziv:",50), {|| naz},  "naz"      },;
          { "Naziv2:",{|| naz2},          "naz2"     };
        }
	
for i:=1 to LEN(ImeKol)
	AADD( Kol, i )
next

return PostojiSifra(F_KDV_RJ,"ID",10,70,"Lista Radnih jedinica",@cId,dx,dy)



function P_RMJ(cId,dx,dy)
private ImeKol
private Kol
ImeKol:={ { PADR("ID",4),  {|| id},               "id"       },;
          { PADR("Naziv:",40), {|| naz},  "naz"      },;
          { "Naziv2:",{|| naz2},          "naz2"     };
        }
Kol:={1,2,3}
return PostojiSifra(F_KDV_RMJ,I_ID,10,60,"Lista Radnih mjesta",@cId,dx,dy)




function P_Zanim(cId,dx,dy)
    
PRIVATE ImeKol,Kol
ImeKol:={ { "ID",  {|| id},               "id"       },;
          { PADR("Naziv:",30), {|| naz},  "naz"      },;
          { "Naziv2:",{|| naz2},          "naz2"     };
        }
Kol:={1,2,3}
return PostojiSifra(F_KDV_ZANIM,I_ID,10,60,"Lista zanimanja",@cId,dx,dy)



function P_Promj(cId,dx,dy)
    
PRIVATE ImeKol,Kol
ImeKol:={ { "ID",  {|| id},               "id"       },;
          { PADR("Naziv:",20), {|| naz},  "naz"      },;
          { "Naziv2:",{|| naz2},          "naz2"     },;
          { "Tip:",{|| ' '+tip+' '},      "tip"      },;
          { "Status:",{|| SPACE(3)+status+SPACE(2)},  "status"   },;
          { "SRMJ",{|| '  '+srmj+' '},  "srmj"   },;
          { "URSt",{|| '  '+URadSt+' '},  "URadst"   },;
          { "URRasp",{|| '  '+URRasp+'   '},  "URRasp"   },;
          { "UStrSpr",{|| PADC(UStrSpr,7)},  "UStrSpr"   };
        }
Kol:={1,2,3,4,5,6,7,8,9}
return PostojiSifra(F_KADEV_PROMJ,I_ID,10,70,"Lista promjena",@cId,dx,dy)



function P_Kadev_K1(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { "ID",              {|| id},   "id"       },;
          { PADR("Naziv:",20), {|| naz},  "naz"      },;
          { "Naziv2:",         {|| naz2}, "naz2"     };
        }
Kol:={1,2,3}
return PostojiSifra(F_KDV_K1,I_ID,10,50,"Lista: "+gDodKar1,@cId,dx,dy)



function P_Kadev_K2(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { "ID",  {|| id},               "id"       },;
          { PADR("Naziv:",30), {|| naz},  "naz"      },;
          { "Naziv2:",{|| naz2},          "naz2"     };
        }
Kol:={1,2,3}
return PostojiSifra(F_KDV_K2,I_ID,10,60,"Lista: "+gDodKar2,@cId,dx,dy)




function P_RRasp(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { "ID",  {|| id},               "id"       },;
          { PADR("Naziv:",30), {|| naz},  "naz"      },;
          { "Naziv2:",{|| naz2},          "naz2"     },;
          { "cAtr:",{|| cAtr},            "cAtr"     };
        }
Kol:={1,2,3,4}
return PostojiSifra(F_KDV_RRASP,I_ID,10,60,"Ratni raspored",@cId,dx,dy)


function P_CIN(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { "ID",  {|| id},               "id"       },;
          { PADR("Naziv:",20), {|| naz},  "naz"      },;
          { "Naziv2:",{|| naz2},          "naz2"     };
        }
Kol:={1,2,3}
return PostojiSifra(F_KDV_CIN,I_ID,10,60,"Lista cinova",@cId,dx,dy)



function P_VES(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { "ID     ",  {|| id},               "id"       },;
          { PADR("Naziv:",40), {|| naz},  "naz"      },;
          { "Naziv2:",{|| naz2},          "naz2"     };
        }
Kol:={1,2,3}
return PostojiSifra(F_KDV_VES,I_ID,10,60,"Lista "+IF(glBezVoj,"pozn.str.jezika","VES-ova"),@cId,dx,dy)


function P_NAC(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { "ID",  {|| id},               "id"       },;
          { PADR("Naziv:",20), {|| naz},  "naz"      },;
          { "Naziv2:",{|| naz2},          "naz2"     };
        }
Kol:={1,2,3}
return PostojiSifra(F_KDV_NAC,I_ID,10,60,"Lista nacija",@cId,dx,dy)




function P_RJRMJ(cIdRj,cIdRMJ,dx,dy)
local cRet
PRIVATE ImeKol,Kol

ImeKol:={ { PADR("RJ",57),  {|| IdRJ+"-"+P_KADEV_RJ(idrj,-2)}       },;
          { PADR("RMJ",45), {|| IdRMJ+"-"+P_RMJ(idrmj,-2)}    },;
          { "Br.Izvr.",{|| SPACE(3)+str(brizvrs,2)+SPACE(3)}  },;
          { "Str.Spr.Od",{|| PADC(IdStrSprOd,10)}            },;
          { "Str.Spr.Do",{|| PADC(IdStrSprDo,10)}            },;
          { "Vrsta /1",{|| PADC(Idzanim1,8)}            },;
          { "Vrsta /2",{|| PADC(Idzanim2,8)}            },;
          { "Vrsta /3",{|| PADC(Idzanim3,8)}            },;
          { "Vrsta /4",{|| PADC(Idzanim4,8)}            },;
          { "S.benef",{|| PADC(SBenefRSt,7)}             },;
          { "K1",{|| " "+IdK1}                           }, ;
          { "K2",{|| " "+IdK2}                           }, ;
          { "K3",{|| " "+IdK3}                           }, ;
          { "K4",{|| " "+IdK4}                           }, ;
          { "Opis",{|| Opis}                           } ;
        }
Kol:={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}

PushWA()

select kdv_RjRMJ
set order to tag "ID"

if cIDRj <> NIL
	seek cIDRj+cIdRmj
else
	go top
endif

if !FOUND() .or. cIdRj==NIL
	
	if EOF()
       		skip -1
      	endif
      	
	my_db_edit("",10,76,{|| EdRJRMJ()},;
                  "Sistematizacija radnih mjesta","",.t.,;
                {"<c-N> Novi","<F2>  Ispravka","<ENT> Odabir","<c-T> Brisi",;
                 "<c-P> Print","<c-F> Trazi"},1)
      	
	cIDRj:=idRj
      	cIdRMJ:=idRMJ
endif

if dx <> NIL .and. dy <> nil
	@ m_x+dx,m_y+dy SAY TRIM(P_KADEV_RJ(cIdRj,-2))+"-"+P_RMJ(cIdRMJ,-2)
endif

PopWa()

return .t.



function EdRJRMJ()

Ch := Lastkey()

do case

    case Ch = K_ENTER
     	return DE_ABORT

  	case ( Ch = K_CTRL_N .or. Ch == K_F2 .or. Ch == K_F4 )

    	set cursor on

    	fNovi := .f.

    	if Ch == K_CTRL_N .or. Ch == K_F4

      		fNovi := .t.

            if Ch == K_F4
    	        set_global_vars_from_dbf("s")
            endif

      		append blank

            if Ch == K_CTRL_N
    	        set_global_vars_from_dbf("s")
            endif
        else
    	    set_global_vars_from_dbf("s")
    	endif
        
    	Box("bd09s",11,77,.f.)

    		Private Getlist:={}

    		@ m_x+1, m_y+2 SAY "R.jedinica " GET sIDRJ valid P_KADEV_RJ(@sIdRJ,1,25) PICTURE "@!"
    		@ m_x+2, m_y+2 SAY "R.mjesto   " GET sIDRMJ valid P_RMJ(@sIdRMJ,2,25) PICTURE "@!"
    		@ m_x+3, m_y+2 SAY "Strucna sprema OD " GET sIdStrsprOd valid P_STRSPR(@sIdStrSprOd,3,40) PICTURE "@!"
    		@ m_x+4, m_y+2 SAY "Strucna sprema DO " GET sIdStrSprDo valid P_STRSPR(@sIdStrSprDo,4,40) PICTURE "@!"
    		@ m_x+5, m_y+2 SAY "Vrsta str.spr /1  " GET sIdZanim1   valid P_Zanim(@sIdZanim1, 5 ,30) PICTURE "@!"
    		@ m_x+6, m_y+2 SAY "              /2  " GET sIdZanim2   valid empty(sIDZanim2) .or. P_Zanim(@sIdZanim2, 6 ,30) PICTURE "@!"
    		@ m_x+7, m_y+2 SAY "              /3  " GET sIdZanim3   valid empty(sIDZanim3) .or. P_Zanim(@sIdZanim3, 7 ,30) PICTURE "@!"
    		@ m_x+8, m_y+2 SAY "              /4  " GET sIdZanim4   valid empty(sIDZanim4) .or. P_Zanim(@sIdZanim4, 8 ,30) PICTURE "@!"
    		@ m_x+9, m_y+2 SAY "Broj izvrsilaca   " GET sBrIzvrs valid sBrIzvrs>=0
    		@ m_x+9,COL()+2 SAY "Br.bodova " GET sBodova valid sBodova>=0
    		@ m_x+9,COL()+2 SAY  "Stopa.benef.R.St " GET sSBenefRSt  VALID P_KBENEF(@sSBenefRSt)
    		@ m_x+10,m_y+2 SAY "Karakteristika /1 " GET sIdK1 PICTURE "@!"
    		@ m_x+10,COL()+2 SAY "K./2 " GET sIdK2 PICTURE "@!"
    		@ m_x+10,COL()+2 SAY "K./3 " GET sIdK3 PICTURE "@!"
    		@ m_x+10,COL()+2 SAY "K./4 " GET sIdK4 PICTURE "@!"
    		@ m_x+11,m_y+2 SAY "Opis              " GET sOpis   

    		read

    	BoxC()

    	if lastkey() == K_ESC

      		if fNovi
                _rec := dbf_get_rec()
                delete_rec_server_and_dbf( "kadev_rjrmj", _rec, 1, "FULL" )
				skip -1
         		return DE_REFRESH
            else
         		return DE_CONT
      		endif
    	else
      		_rec := get_hash_record_from_global_vars("s")
            update_rec_server_and_dbf( "kadev_rjrmj", _rec, 1, "FULL" )
      		return DE_REFRESH
    	endif

  	case Ch = K_CTRL_T

    	if Pitanje("psist","Zelite li izbrisati ovu stavku ??","D")=="D"
      		_rec := dbf_get_rec()
            delete_rec_server_and_dbf( "kadev_rjrmj", _rec, 1, "FULL" )
            return DE_REFRESH
    	else
      		return DE_CONT
    	endif

  	otherwise
    	return DE_CONT

endcase

return



function P_Rjes(cId,dx,dy)
LOCAL nArr := SELECT()
PRIVATE ImeKol, Kol := {}

select KDV_DEFRJES
select (nArr)

ImeKol:={ { "ID/SIFRA"      , {|| id      } , "id"       } ,;
          { "Naziv"         , {|| naz     } , "naz"      } ,;
          { "Fajl obrasca"  , {|| fajl    } , "fajl"     , , {|| V_FRjes() } } ,;
          { "Poslj.broj"    , {|| zadbrdok} , "zadbrdok" , {|| .f.} } ,;
          { "ID promjene"   , {|| idpromj } , "idpromj"   } ;
        }

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

return PostojiSifra(F_KDV_RJES,1,10,60,"Lista rjesenja ���� <F5> - definisi rjesenje",@cId,dx,dy,{|Ch| RjesBlok(Ch)})




static function v_frjes()
private cKom := "gvim "+PRIVPATH + ALLTRIM(wfajl)

if EMPTY(wfajl)
	return .t.
endif

if Pitanje(,"Zelite li izvrsiti ispravku fajla obrasca rjesenja ?","N")=="D"
    Box(,25,80)
   	hb_run( cKom )
    BoxC()
endif

return .t.






static function RjesBlok(Ch)
local _id, _old_id, _rec

if Ch == K_CTRL_T
 
    if Pitanje(, "Izbrisati rjesenje sa pripadajucim stavkama ?", "N" ) == "D"
    
        _id := field->id
    
        select kdv_defrjes
        seek _id
   
        if FOUND()
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "kadev_defrjes", _rec, 2, "FULL" )
        endif
       
        select kdv_rjes
        seek _id

        if FOUND() 
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "kadev_rjes", _rec, 1, "FULL" )
        endif
    
        return 7  
    
    endif

elseif Ch == K_F2

    if Pitanje(, "Promjena sifre rjesenja ?", "N" ) == "D"
        
        _old_id := field->id
        _id := field->Id

        Box(,2,50)
            @ m_x + 1, m_y + 2 SAY "Sifra rjesenja" GET _id VALID ( !EMPTY( _id ) .and. _id <> _old_id )
            read
        BoxC()

        if LastKey() == K_ESC
            return DE_CONT
        endif
     
        select kdv_defrjes
        seek _old_id

        if !f18_lock_tables( { "kadev_defrjes", "kadev_rjes" } )
            MsgBeep( "Problem sa lokovanjem tabele kadev_defrjes !!!" )
            return DE_CONT
        endif 

        run_sql_query( "BEGIN" )
 
        do while !EOF() .and. _old_id == field->idrjes

            skip
            _t_rec := RecNo()
            skip -1

            _rec := dbf_get_rec()
            _rec["idrjes"] := _id

            update_rec_server_and_dbf( "kadev_defrjes", _rec, 1, "CONT" )
            
            go ( _t_rec )

        enddo
 
       
        select kdv_rjes
        _rec := dbf_get_rec()
        _rec["id"] := _id
        update_rec_server_and_dbf( "kadev_rjes", _rec, 1, "CONT" )

        f18_unlock_tables( { "kadev_defrjes", "kadev_rjes" } )
        run_sql_query( "COMMIT" )
 
    endif
    
    return DE_CONT

elseif Ch == K_F5

    // pregledaj rjesenje...    
    pregledaj_defrjes( kdv_rjes->id )

    return 6

else

    return DE_CONT

endif

return DE_CONT






static function pregledaj_defrjes()
parameters cId
local _i
private GetList := {}
private ImeKol := {}
private Kol := {}

Box(,15,77)

    select kdv_defrjes

    ImeKol:={ { "ID/SIFRA"       , {|| id      } , "id"       } ,;
           { "Obrada(D/N)"    , {|| obrada  } , "obrada"   } ,;
           { "Upit/opis"      , {|| upit    } , "upit"     } ,;
           { "Izraz"          , {|| izraz   } , "izraz"    } ,;
           { "Validacija"     , {|| uvalid  } , "uvalid"   } ,;
           { "Format"         , {|| upict   } , "upict"    } ,;
           { "Tip slova(BUI)" , {|| tipslova} , "tipslova" } ,;
           { "Izraz izlaza"   , {|| iizraz  } , "iizraz"   } ,;
           { "Polje promjene" , {|| ppromj  } , "ppromj"   } ,;
           { "Index promjene" , {|| ipromj  } , "ipromj"   } ,;
           { "Prior.unosa"    , {|| priun   } , "priun"    } ;
         }

    for _i := 1 to LEN( ImeKol )
        AADD( Kol, _i )
    next

    set cursor on

    @ m_x + 1, m_y + 1 SAY ""
    ?? "Rjesenje:", KDV_RJES->id, ALLTRIM( KDV_RJES->naz )
    BrowseKey( m_x + 3, m_y + 1, m_x + 14, m_y + 77, ImeKol, ;
                {|Ch| EdDefRjes(Ch)}, " idrjes == cId ", cId, 2,,,{|| .f.})

    select kdv_rjes

BoxC()

return .t.



static function EdDefRjes(Ch)
local _ret := DE_CONT
local _vpp := ""
private GetList:={}

_vpp := SPACE(10)+"#"+PADR("ID",10)+"#"+PADR("DATUMOD",10)+"#"+;
      PADR("DATUMDO",10)+"#"+PADR("NATR1",10)+"#"+PADR("NATR2",10)+"#"+;
      PADR("NATR3",10)+"#"+PADR("NATR4",10)+"#"+;
      PADR("NATR5",10)+"#"+PADR("NATR6",10)+"#"+;
      PADR("NATR7",10)+"#"+PADR("NATR8",10)+"#"+;
      PADR("NATR9",10)+"#"+;
      PADR("CATR1",10)+"#"+PADR("CATR2",10)+"#"+PADR("IDK",10)+"#"+;
      PADR("DOKUMENT",10)+"#"+PADR("OPIS",10)+"#"+PADR("NADLEZAN",10)+"#"+;
      PADR("IDRJ",10)+"#"+PADR("IDRMJ",10)

do case

    case Ch == K_F2 .or. Ch == K_CTRL_N

        scID       := ID
        scIZRAZ    := IZRAZ
        scOBRADA   := OBRADA
        scUPIT     := UPIT
        scUVALID   := UVALID
        scUPICT    := UPICT
        scIIZRAZ   := IIZRAZ
        scTIPSLOVA := TIPSLOVA
        scPPROMJ   := PPROMJ
        scIPROMJ   := IPROMJ
        scPRIUN    := PRIUN

        Box(,11,75,.f.)

            @ m_x+ 1,m_y+2 SAY "ID/SIFRA      " GET scID     PICT "@!"
            @ m_x+ 2,m_y+2 SAY "Obrada(D/N)   " GET scOBRADA PICT "@!" VALID scOBRADA $ "DN"
            @ m_x+ 3,m_y+2 SAY "Upit/opis     " GET scUPIT
            @ m_x+ 4,m_y+2 SAY "Izraz         " GET scIZRAZ  PICT "@S60"
            @ m_x+ 5,m_y+2 SAY "Validacija    " GET scUVALID PICT "@S60"
            @ m_x+ 6,m_y+2 SAY "Format        " GET scUPICT  PICT "@!"
            @ m_x+ 7,m_y+2 SAY "Tip slova(BUI)" GET scTIPSLOVA PICT "@!"
            @ m_x+ 8,m_y+2 SAY "Izraz izlaza  " GET scIIZRAZ PICT "@S60"
            @ m_x+ 9,m_y+2 SAY "Polje promjene" GET scPPROMJ PICT "@!" valid scPPROMJ $ _vpp .or. MsgPPromj()
            @ m_x+10,m_y+2 SAY "Index promjene" GET scIPROMJ PICT "@!"
            @ m_x+11,m_y+2 SAY "Priorit. unosa" GET scPRIUN  PICT "9"
            READ
        
        BoxC()

        // izadji...
        if LastKey() == K_ESC
            return _ret
        endif

        if Ch == K_CTRL_N
            append blank
        endif

        _rec := dbf_get_rec()

        if Ch == K_CTRL_N
            _rec["idrjes"] := cId
        endif
            
        _rec["id"] := scID
        _rec["izraz"] := scIZRAZ
        _rec["obrada"] := scOBRADA
        _rec["upit"] := scUPIT
        _rec["uvalid"] := scUVALID
        _rec["upict"] := scUPICT
        _rec["tipslova"] := scTIPSLOVA
        _rec["iizraz"] := scIIZRAZ
        _rec["ppromj"] := scPPROMJ
        _rec["ipromj"] := scIPROMJ
        _rec["priun"] := scPRIUN

        update_rec_server_and_dbf( "kadev_defrjes", _rec, 1, "FULL" )

        _ret := DE_REFRESH

    case Ch == K_CTRL_T

        if Pitanje(, "Izbrisati stavku ?", "N" ) == "D"
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "kadev_defrjes", _rec, 1, "FULL" )
        endif
        
        _ret := DE_DEL

endcase

return _ret





