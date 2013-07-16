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


#include "kadev.ch"
#include "f18_separator.ch"


// ----------------------------------------------
// unos podataka
// ----------------------------------------------
function kadev_data()
local _i, _header, _footer
local _x, _y
local _w1 := 30
private ImeKol := {}
private Kol := {}
private fNovi

_x := MAXROWS() - 4
_y := MAXCOLS() - 3

SET EPOCH TO 1910

// otvori tabele
kadev_o_tables()

// setuj kolone pregleda
set_kols( @ImeKol, @Kol )

select kadev_0
set order to tag "2"
go top

_header := ""
_footer := ""

cTrPrezime := kadev_0->prezime
cTrIme     := kadev_0->ime          
cTrID      := kadev_0->id        

Box(, _x, _y )

@ m_x + _x - 4, m_y + 2 SAY PADR(" < c+N > Novi", _w1 ) + ;
                            BROWSE_COL_SEP + PADR( " < T > Trazi (pr+ime)", _w1 ) + ;
                            BROWSE_COL_SEP + PADR( " < ctrl+T > brisanje", _w1 )
@ m_x + _x - 3, m_y + 2 SAY PADR(" < ENT > Ispravka", _w1 ) + ;
                            BROWSE_COL_SEP + PADR( " < S > Trazi (id)", _w1) + ;
                            BROWSE_COL_SEP + PADR( " -", _w1 )
@ m_x + _x - 2, m_y + 2 SAY PADR(" < R > Rjesenje", _w1) + ;
                            BROWSE_COL_SEP + PADR( " -",_w1 ) + ;
                            BROWSE_COL_SEP + PADR( " -", _w1 )
@ m_x + _x - 1, m_y + 2 SAY PADR(" < P > Pregl.promjene", _w1) + ;
                            BROWSE_COL_SEP + PADR( " -", _w1 ) + ;
                            BROWSE_COL_SEP + PADR( " -", _w1 )

ObjDbEdit( 'bpod', _x - 3, _y, {|| data_handler() }, _header, _footer, , , , , 2 )

BoxC()

close all

return


// -----------------------------------------------------------
// setovanje kolone za tabelu pregleda
// -----------------------------------------------------------
static function set_kols( _imekol, _kol )
local _i

AADD( _imekol, { 'Prezime', {|| Prezime } } )
AADD( _imekol, { 'Ime oca', {|| ImeRod } } )
AADD( _imekol, { 'Ime', {|| Ime } } )
AADD( _imekol, { 'RJ', {|| IdRJ } } )
AADD( _imekol, { 'RMJ', {|| IdRMJ } } )
AADD( _imekol, { 'ID-Mat.br', {|| Id } } )
AADD( _imekol, { 'Status', {|| status } } )
AADD( _imekol, { 'StrSpr', {|| idstrspr } } )
AADD( _imekol, { 'RRASP', {|| idrrasp } } )
         
for _i := 1 to LEN( _imekol )
	AADD( _kol, _i )
next

return




// ---------------------------------------------
// key handler
// ---------------------------------------------
static function data_handler()
local _order := 0
local _vars := {}
local _tmp := {}
local _strana := 0
local _tek_strana := 1
local _tmp_2 := {}
private fNovi := .f.

// broj podataka
@ m_x + 1, m_y + 2 SAY "Broj promjena:" COLOR "GR+/B"
@ m_x + 1, col() + 2 SAY PADL( ALLTRIM( STR( kadev_broj_podataka( field->id ), 5, 0 ) ), 8 ) COLOR "W/R+"

do case

    case Ch == K_CTRL_N .or. Ch == K_ENTER

        if ( deleted() .or. EOF() .or. BOF() ) .and. Ch == K_ENTER
            return DE_CONT
        endif

        if Ch == K_CTRL_N
       	    fNovi := .t.
        endif
	
        if fNovi
            append blank
        endif

        // scatter
        set_global_vars_from_dbf()
    
	    if ent_K_0()
            _rec := get_dbf_global_memvars()
            update_rec_server_and_dbf( "kadev_0", _rec, 1, "FULL" )
		    fNovi := .f.
            return DE_REFRESH
        else
	        if fNovi
            	brisi_kadrovski_karton( .t. )
       	    endif	
		    fnovi := .f.
       	    return DE_REFRESH
        endif

    case Ch == K_CTRL_T
	
        if !( deleted() .or. EOF() .or. BOF() )
	        brisi_kadrovski_karton()
    	    return DE_REFRESH
 	    endif

    case Ch == ASC("T") .or. Ch == ASC("t")

        if VarEdit({ {"Prezime","cTrPrezime","","",""},;
                 {"Ime","cTrIme","","",""} },;
                 11,1,16,78,"TRAZENJE RADNIKA","B1")
      
            DO WHILE TB:rowPos>1
      	        TB:up()
                DO WHILE !TB:stable
                    Tb:stabilize()
                ENDDO
            ENDDO
            _order := INDEXORD()
            SET ORDER TO TAG "2"
            SEEK BToE( cTrPrezime + cTrIme )
            DBSETORDER( _order )
            return DE_REFRESH
        endif

    case Ch == ASC("S") .or. Ch == ASC("s")

        if VarEdit({ {"ID","cTrID","","",""} },;
                 11,1,15,78,"TRAZENJE RADNIKA","B1")
            DO WHILE TB:rowPos>1
                TB:up()
                DO WHILE !TB:stable
                    Tb:stabilize()
                ENDDO
            ENDDO
            _order := INDEXORD()
            SET ORDER TO TAG "1"
            SEEK cTrID
            DBSETORDER( _order )
            return DE_REFRESH
        endif

    case Ch == ASC("P") .or. Ch == ASC("p")

	    _t_area := SELECT()
  	
	    Box( "uk0_1", MAXROWS() - 12, MAXCOLS() - 5, .f.)
  	
	        @ m_x + ( MAXROWS() - 13 ), m_y + 2 SAY "RADNIK: " + ALLTRIM( kadev_0->prezime ) + " " + ;
                                        ALLTRIM( kadev_0->ime ) + ", ID: " + ;
                                        ALLTRIM( kadev_0->id )
  	
	        set cursor on
  	
            set_global_vars_from_dbf()
  	
            // daj mi promjene...
	        get_4( NIL, .f. )
 
            _rec := get_dbf_global_memvars()
            update_rec_server_and_dbf( "kadev_0", _rec, 1, "FULL" ) 
  	
	    BoxC()
  	
	    select ( _t_area )

    case Ch == ASC("R") .or. Ch == ASC("r")

        // rjesenje...
        if !rjesenje_za_radnika()
            return DE_CONT
        else
            return DE_REFRESH
        endif

endcase

return DE_CONT



// -------------------------------------------------------
// rjesenje za radnika...
// -------------------------------------------------------
static function rjesenje_za_radnika()
local _t_area
local _ret := .f.
local _niz_0, _niz, _tmp, _izbaceni, _strana, _tek_strana, _i, _n, _y
local _postoji

private cTempVar := ""
private cTempIzraz := ""
private nGetP0 := 0
private nGetP1 := 0

_t_area := SELECT()

// otvori rjesenja...  	
P_Rjes()
  	
if LastKey() == K_ESC
	select ( _t_area )
	return _ret
endif
  
_niz_0 := {}
_niz := {}
_tmp := {}
_strana := 0
_tek_strana := 1

select kdv_defrjes
set order to tag "3"
seek kdv_rjes->id

do while !EOF() .and. field->idrjes == kdv_rjes->id

    if EMPTY( field->id )
	    skip 1
		loop
	endif
    		
	cTempVar := ALLTRIM( field->id )
    cTempIzraz := ALLTRIM( field->izraz )
    	
    ID&cTempVar := &cTempIzraz
    	
    if field->priun == "0"
        AADD( _niz_0 , { RTRIM( field->upit ), "ID" + cTempVar, RTRIM( field->uvalid ), ;
                        RTRIM( field->upict ), IF( field->obrada == "D", ".t.", ".f." ) } )
        ++ nGetP0
    else
     	AADD( _niz , { RTRIM( field->upit), "ID" + cTempVar, RTRIM( field->uvalid ), ;
                        RTRIM( field->upict ), IF( field->obrada == "D", ".t.", ".f." ) } )
     	++ nGetP1
    endif

    skip 1	

enddo
  	
set order to tag "1"

// unos prioritetnih podataka
if nGetP0 > 0

    _strana := INT(nGetP0/20)+IF(nGetP0%20>0,1,0)

    do while .t.

        _tmp := {}

      	for _i := 1 to 20
        	if _i + ( _tek_strana - 1 ) * 20 > LEN( _niz_0 ) 
                exit
        	else
          		AADD( _tmp , _niz_0[ _i + ( _tek_strana - 1 ) * 20 ] )
        	endif
      	next
      	
        VarEdit( _tmp, 1, 1, 4 + LEN( _tmp ), 79, ;
                ALLTRIM( kdv_rjes->naz ) + "," + ;
                        kadev_0->( TRIM( prezime ) + " " + TRIM( ime ) ) + ;
                        ", STR." + ALLTRIM( STR( _tek_strana ) ) + "/" + ALLTRIM( STR( _strana ) ), "B1" )
      			
		if LastKey() == K_PGUP
            -- _tek_strana
        else
        	++ _tek_strana
      	endif
      		
        if _tek_strana < 1
	        _tek_strana := 1
		endif

        if _tek_strana > _strana
			exit
		endif

    enddo

    if LastKey() == K_ESC
      	select ( _t_area )
		return _ret
    endif

endif

// ispitivanje unosa i eventualne modifikacije unosa preostalih podataka
_postoji := 0
  	
if kdv_rjes->idpromj == "G1"      

    // godisnji odmor
    select ( F_KADEV_1 )
    PushWA()
    set order to tag "3"
    seek kadev_0->id + "G1"

    private nImaDana := 0
    private nIskorDana := 0

    do while !EOF() .and. field->id == kadev_0->id .and. field->idpromj == "G1"
      	if field->natr1 == ID06
		    // ID06 je sad za sad godina prava, kao i nAtr1
        	if field->natr2 > 0
         		nImaDana := field->natr2
          		if FIELDPOS("natr3") > 0
            	    nGOKrit1:=nAtr3
            	    nGOKrit2:=nAtr4
            		nGOKrit3:=nAtr5
            		nGOKrit4:=nAtr6
            		nGOKrit5:=nAtr7
            		nGOKrit6:=nAtr8
            		nGOKrit7:=nAtr9
          		endif
        	endif
        	nIskorDana += ImaRDana( field->DatumOd, field->DatumDo )
        	_postoji ++
      	endif

      	skip 1

    enddo
    	
    private preostd := ALLTRIM( STR( nImaDana - nIskorDana ) )
    	
    PopWA()

endif

if _postoji > 1
    MsgBeep( "Vec postoje " + STR( _postoji, 2 ) + " rjesenja!#Za istu godinu moguce je napraviti max.2 rjesenja!#Provjeriti promjene tipa G1!")
    select ( _t_area )
    return _ret
elseif _postoji > 0
    MsgBeep( "Vec postoji jedno rjesenje koje definise pravo na godisnji odmor!#Mozete napraviti rjesenje samo za drugi dio godisnjeg odmora.#Ako zelite ponovo definisati pravo, provjerite promjene tipa G1!")
endif

if _postoji > 0

    // izbacimo nezeljene stavke iz niza
    _izbaceni := { "ID07","ID08","ID09","ID10","ID11","ID12","ID13","ID14","ID15","ID16","ID17","ID18" }

    for _n := 1 TO LEN( _izbaceni )
        _tmp := _izbaceni[ _n ]       
		// ispraznimo nezeljene
      	&_tmp := BLANK( &_tmp )     
		// varijable
      	_scan := ASCAN( _niz,{|x| x[2] == _izbaceni[ _n ] } )
      	if _scan > 0
         	ADEL( _niz, _scan )
         	ASIZE( _niz, LEN( _niz ) - 1 )
         	nGetP1 --
      	endif
    next
    	
    private samo2 := ".t."

    // kad vec znam da je ID20 br.dana za 2.dio god.odmora
    if !("U" $ TYPE( "nGOKrit1" ) )
        ID07 := INT(nGOKrit1)
        ID08 := INT(nGOKrit2)
        ID09 := INT(nGOKrit3)
        ID10 := INT(nGOKrit4)
        ID11 := INT(nGOKrit5)
      	ID12 := INT(nGOKrit6)
        ID13 := INT(nGOKrit7)
      	ID14 := INT(nImaDana)
    endif
    		
	ID20 := INT( nImaDana - nIskorDana )

else
    private samo2 := ".f."
endif

// unos ostalih podataka
if nGetP1 > 0
    _strana := INT( nGetP1 / 20 ) + IF( nGetP1%20 > 0, 1, 0 )
    _tek_strana := 1
    do while .t.
        _tmp_3 := {}
      	for _y := 1 to 20
            if _y + ( _tek_strana - 1 ) * 20 > LEN( _niz )
          	    exit
            else
          		AADD( _tmp_3, _niz[ _y + ( _tek_strana - 1 ) * 20 ] )
        	endif
      	next
      	
        VarEdit( _tmp_3, 1, 1, 4 + LEN( _tmp_3 ), 79, ;
                ALLTRIM( kdv_rjes->naz ) + "," + kadev_0->( TRIM( prezime ) + " " + TRIM( ime ) ) + ;
                ", STR." + ALLTRIM( STR( _tek_strana ) ) + "/" + ALLTRIM( STR( _strana ) ), "B1" )
      		
        if LastKey() == K_PGUP
            -- _tek_strana
      	else
        	++ _tek_strana
      	endif
      	
        if _tek_strana < 1
		    _tek_strana := 1
		endif
      	
        if _tek_strana > _strana
			exit
		endif

    enddo
    	
    if LastKey() == K_ESC
      	select ( _t_area ) 
		return _ret 
    endif

endif

rpt_rjes()

if !EMPTY( kdv_rjes->idpromj ) .and. ;
    Pitanje(, "Zelite li da se efekat ovog rjesenja evidentira u promjenama? (D/N)", "D" ) == "D"
    
    ERUP( _izbaceni )
endif

select ( _t_area )
_ret := .t.

return _ret





// -----------------------------------------
// stampa rjesenja
// -----------------------------------------
function rpt_rjes()
local aPom := {}
local i
local nLin
local nPocetak
local nPreskociRedova
local cLin
local cPom

START PRINT CRET

if EMPTY( kdv_rjes->fajl )
	for i := 1 to gnTMarg
		QOUT()
	next
else

	nLin:=BrLinFajla(my_home()+ALLTRIM(KDV_RJES->fajl))
	nPocetak:=0
	nPreskociRedova:=0

	FOR i:=1 TO nLin
		aPom:=SljedLin(my_home()+ALLTRIM(KDV_RJES->fajl),nPocetak)
      	nPocetak:=aPom[2]
      	cLin:=aPom[1]
      	
		IF nPreskociRedova>0
        	--nPreskociRedova
        	LOOP
      	ENDIF
      	
		IF i>1
			?
		ENDIF
      	
		DO WHILE .t.
        		nPom:=AT("#",cLin)
        		IF nPom>0
          			cPom:=SUBSTR(cLin,nPom,4)
          			aPom:=UzmiVar( SUBSTR(cPom,2,2) )
          			?? LEFT(cLin,nPom-1)
          			cLin:=SUBSTR(cLin,nPom+4)
          			
				IF !EMPTY(aPom[1])
            				PrnKod_ON(aPom[1])
         			ENDIF
				
          			IF aPom[1]=="K"  
					// ako evaluacija vrsi i stampu npr.
            				cPom:=&(aPom[2]) 
					// ako je aPom[2]="gPU_ON()"
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
	NEXT
endif

FF
END PRINT

return



function UzmiVar(cVar)
local cVrati:={"","''"}
SELECT KDV_DEFRJES
SEEK KDV_RJES->id+cVar
IF FOUND()                           
	cVrati := { tipslova , iizraz }    
ENDIF
return cVrati






static function erup( arr )
local _t_area := SELECT()
local _dok := ""
local _rec, _ima_podataka, _t_id_promj
private cPP := ""
private cPR := ""
  
select kadev_1
append blank

set_global_vars_from_dbf()

_id := kadev_0->id
_idpromj := kdv_rjes->idpromj
   
select kdv_defrjes
set order to tag "2"
seek kdv_rjes->id

_t_id_promj := field->ipromj
   
_ima_podataka := .f.
   
do while !EOF() .and. field->idrjes == kdv_rjes->id

    if ASCAN( arr, {|x| RIGHT( x, 2 ) == kdv_defrjes->id }) > 0
        skip
        loop
    endif
     
    if field->ipromj <> _t_id_promj .and. LEN( arr ) == 0
        
        _t_id_promj := field->ipromj
        
        select kadev_1

        // gather()
        _rec := get_dbf_global_memvars()
        update_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )
        
        // scatter
        set_global_vars_from_dbf()
        
        IF !_ima_podataka
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )
        ENDIF
        
        _ima_podataka := .f.
       
        append blank

        select kdv_defrjes
    
    endif

    if !EMPTY( field->ppromj )
       
        cPP := ALLTRIM( field->ppromj )
        cPR := "ID" + ALLTRIM( field->id )
        _&cPP := &cPR
       
        if !EMPTY( &cPR )
            _ima_podataka := .t.
            if ALLTRIM( field->ppromj ) == "DOKUMENT"
                _dok := _dokument
            endif
        endif
    
    endif
    
    skip 1

enddo
   
set order to tag "1"
select kadev_1
  
_rec := get_dbf_global_memvars()
update_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )
  
if !_ima_podataka
    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )
endif

if !EMPTY( _dok )
    select kdv_rjes
    _rec := dbf_get_rec()
    _rec["zadbrdok"] := _dok
    update_rec_server_and_dbf( "kadev_rjes", _rec, 1, "FULL" )
endif

select ( _t_area )

return



// ----------------------------------------------------------
// unos "kadev_0" podataka
// ----------------------------------------------------------
function ent_K_0()
local _max_x := MAXROWS() - 10
local _max_y := MAXCOLS() - 5
local _strana
local _ret 

Box( "uk0_1", _max_x, _max_y , .f. )

    set cursor on

    _strana := 1

    do while .t.

        @ m_x + ( _max_x + 1 ), m_y + 2 SAY "RADNIK: " + ;
                    TRIM( kadev_0->prezime ) + " " + TRIM( kadev_0->ime ) + ", ID: " + TRIM( kadev_0->id )

        @ m_x + 1, m_y + 1 CLEAR TO m_x + _max_x, m_y + ( _max_y + 1 )

        if _strana == 1
            _ret := GET_1( _strana )
        elseif _strana == 2
            _ret := GET_2( _strana )
        elseif _strana == 3
            _ret := GET_3( _strana )
        elseif _strana == 4
            _ret := GET_4( _strana, NIL )
        endif

        if _ret == K_ESC
            exit
        elseif _ret == K_PGUP
            -- _strana
        elseif _ret == K_PGDN .or. _ret == K_ENTER
            ++ _strana
        endif

        if _strana == 0
            _strana ++
        elseif _strana == 5
            exit
        endif

    enddo

BoxC()

if LastKey() <> K_ESC
    return .t.
else
    return .f.
endif

return


// --------------------------------------
// unos prve stranice
// --------------------------------------
static function get_1( strana )
local _left := 30

@ m_x + 1, m_y + 2 SAY PADR( " 1. Prezime", _left ) GET _prezime PICT "@!"

@ m_x + 3, m_y + 2 SAY PADR( " 2. Ime jednog roditelja", _left ) GET _imerod PICT "@!"

@ m_x + 5, m_y + 2 SAY PADR( " 3. Ime", _left ) GET _ime PICT "@!"
@ m_x + 5, col() + 2 SAY " Pol (M/Z) " GET _pol VALID _pol $ "MZ" PICT "@!"

@ m_x + 7, m_y + 2 SAY PADR( " 4. Nacija", _left ) GET _idnac ;
            VALID { || P_Nac( @_idnac, 7, 40 ) } PICT "@!"

@ m_x + 9, m_y + 2 SAY PADR( " 5. Jedinstveni mat.broj", _left ) GET _id ;
            VALID _dobar_id( @_id ) PICT "@!"
@ m_x + 9, col() + 2 SAY " b) ID broj/2  " GET _id2 VALID _dobar_id2( @_id2 ) PICT "@!"

@ m_x + 11, m_y + 2 SAY PADR( " 7. Mjesto rodjenja", _left ) GET _mjrodj PICT "@!"

@ m_x + 13, m_y + 2 SAY PADR( " 8. Datum. rodj ", _left ) GET _datrodj
@ m_x + 13, col() + 2 SAY "  9. Broj LK " GET _brlk PICT "@!"

@ m_x + 15, m_y + 2 SAY " 10. Adresa stanovanja *****"
@ m_x + 16, m_y + 2 SAY PADR( "  a) mjesto", _left ) GET _mjst PICT "@!"
@ m_x + 17, m_y + 2 SAY PADR( "  b) mjesna zajednica", _left ) GET _idmzst ;
                VALID P_MZ( @_idmzst, 17, 40 ) PICT "@!"
@ m_x + 18, m_y + 2 SAY PADR( "  c) ulica", _left ) GET _ulst PICT "@!"
@ m_x + 19, m_y + 2 SAY PADR( "  d) broj kucnog telefona", _left ) GET _brtel1 PICT "@!"

read

if !_dobar_id( _id )
	-- strana
endif

return LastKey()




// --------------------------------------------
// unos druge stranice
// --------------------------------------------
static function get_2( strana )
local aRstE
local aRstB
local aRstU
local _left := 30

@ m_x + 1, m_y + 2 SAY " 11. Strucna sprema " + _idstrspr + "-" + P_STRSPR( @_idstrspr, -2 )

@ m_x + 3, m_y + 2 SAY " 12. Vrsta str.spr. " + _idzanim + "-" + P_Zanim( @_idzanim, -2 )

@ m_x + 5, m_y + 2 SAY " 13. R.jedinica RJ " + _idrj + "-" + P_Kadev_Rj( _idrj, -2 )

@ m_x + 7, m_y + 2 SAY " 14. R.mjesto RMJ " + _idrmj + "-" + P_RMJ( _idrmj, -2 )
@ m_x + 8, m_y + 2 SAY "    Broj bodova   " + STR( Ocitaj( F_KDV_RJRMJ, _idrj + _idrmj, "BODOVA", .t. ), 7, 2 )
@ m_x + 9, m_y + 2 SAY " 15. Na radnom mjestu od: " + DTOC( _daturmj )
@ m_x + 9, m_y + 40 SAY "U Firmi od: " + DTOC( _datuf )

@ m_x + 11, m_y + 2 SAY " 16. Van firme od: " + DTOC( _datvrmj )

aRstE := GMJD( _radste )
aRstB := GMJD( _radstb )

aRStU := ADDGMJD( aRStE, aRStB )

@ m_x + 13, m_y + 2 SAY " 17. Radni staz:      Efekt  " + ;
            STR( aRstE[1], 2 ) + "g." + STR( aRstE[2], 2 ) + ;
            "m." + STR( aRstE[3], 2 ) + "d."

@ m_x + 14, m_y + 2 SAY "                     Benef  " + ;
            STR( aRstB[1], 2 ) + "g." + STR( aRstB[2], 2 ) + "m." + STR( aRstB[3], 2 ) + "d."

@ m_x + 15, m_y + 2 SAY "                         ä  " + ;
            STR( aRstU[1], 2 ) + "g." + STR( aRstU[2], 2 ) + "m." + STR( aRstU[3], 2 ) + "d."

@ m_x + 16, m_y + 2 SAY PADR( " 18. Status ...............", _left ) + _status

@ m_x + 18, m_y + 2 SAY PADR( " 19. broj telefona /2", _left ) GET _brtel2 PICT "@!"
@ m_x + 19, m_y + 2 SAY PADR( " 20. broj telefona /3", _left ) GET _brtel3 PICT "@!"

read

return LastKey()




// --------------------------------------------
// unos treæe stranice
// --------------------------------------------
static function get_3( strana )
local _left := 30

aVr := GMJD( _vrslvr )

@ m_x + 1, m_y + 2 SAY " 21.PORODICA, OPSTI PODACI"

@ m_x + 3, m_y + 2 SAY PADR( "  a) Bracno stanje ", _left ) GET _bracst PICT "@!"
@ m_x + 4, m_y + 2 SAY PADR( "  b) Broj djece ", _left ) GET _brdjece PICT "@!"
@ m_x + 5, m_y + 2 SAY PADR( "  c) Stambene prilike ", _left ) GET _stan PICT "@!"
@ m_x + 6, m_y + 2 SAY PADR( "  d) Krvna grupa ", _left ) GET _krv VALID _krv $ "   #A+ #A- #B+ #B- #AB+#AB-#0+ #0- #A  #B  #AB #0  "  PICT "@!"
@ m_x + 7, m_y + 2 SAY PADR( "  e) " + gDodKar1, _left ) GET _idk1 ;
                VALID P_Kadev_K1( @_idk1, 7, 40 ) PICT "@!"
@ m_x + 8, m_y + 2 SAY PADR( "  f) " + gDodKar2, _left ) GET _idk2 ;
                VALID P_Kadev_K2( @_idk2, 8, 40 ) PICT "@!"

@ m_x + 9, m_y + 2 SAY PADR( "  g) Karakt. (opisno)..... 1", _left ) GET _kop1 PICT "@!"
@ m_x + 10, m_y + 2 SAY PADR( "  h) Karakt. (opisno)..... 2", _left ) GET _kop2 PICT "@!"

@ m_x + 12, m_y + 2 SAY " 22. ODBRANA"

@ m_x + 14, m_y + 2 SAY "  a) Ratni raspored        " + _idrrasp + "-" + P_RRASP( _idrrasp, -2 )
@ m_x + 15, m_y + 2 SAY "  b) Sluzio vojni rok      " + _slvr

if _slvr == "D"
    @ m_x + 15, col() + 2 SAY ", u trajanju: " + STR( aVr[1], 2 ) + "g." + ;
                            STR( aVr[2], 2 ) + "m." + STR( aVr[3], 2 ) +"d."
endif

@ m_x + 16, m_y + 2 SAY "  c) " + IF( glBezVoj, "Pozn.rada na racunaru", "Sposobnost za voj.sl." ) GET _sposvsl PICT "@!"
@ m_x + 17, m_y + 2 SAY "  d) Cin       " GET _idcin VALID P_Cin( @_idcin, 17, 30 ) PICT "@!"

@ m_x + 18, m_y + 2 SAY "  e) " + IF( glBezVoj, "Str.jezici ", "VES       " ) GET _idves ;
            VALID P_Ves( @_idves, 18, 30 ) PICT "@!"

@ m_x + 19, m_y + 2 SAY "  f) " + IF( glBezVoj, "Otisli bi iz firme?  ", "Sekretarijat odbrane " ) GET _nazsekr PICT "@!S40"

read

return LastKey()



// ---------------------------------------
// unos cetvrte stranice
// ---------------------------------------
static function get_4( strana, brzi_unos )
private ImeKol

if brzi_unos == NIL
	brzi_unos := .f.
endif

if brzi_unos
	
    ImeKol:={ {"Datum ", {|| datumOd} }, ;
          {"Do    ", {|| datumDo} }, ;
          {"Kar.",  {|| IdK}      }, ;
          {"Opis", {|| opis}    } ,;
          {"Dokument",  {|| Dokument}      }, ;
          {"Nadlezan",  {|| Nadlezan}      }, ;
          {"RJ", {|| IdRJ}    } ,;
          {"RMj",{|| IdRMJ}    } ,;
          {"nAtr1",{|| natr1}    }, ;
          {"nAtr2",{|| natr2}    }, ;
          {"cAtr1",{|| catr1}    }, ;
          {"cAtr2",{|| catr2}    } ;
        }
  	
	@ m_x, m_y + 2 SAY PADC( " TIP PROMJENE: " + gTrPromjena + "-" + ;
                TRIM( Ocitaj( F_KADEV_PROMJ, gTrPromjena, "naz" ) ) + " ", 70, "Í" )

else

	ImeKol:={ {"Datum ", {|| datumOd} }, ;
          {"Do    ", {|| datumDo} }, ;
          {"Promjena", {|| IdPromj + "-" + P_Promj( IdPromj, -2 ) }      }, ;
          {"Kar.",  {|| IdK}      }, ;
          {"Dokument",  {|| Dokument}      }, ;
          {"Nadlezan",  {|| Nadlezan}      }, ;
          {"Opis", {|| opis}    } ,;
          {"RJ", {|| IdRJ}    } ,;
          {"RMj",{|| IdRMJ}    } ,;
          {"nAtr1",{|| natr1}    }, ;
          {"nAtr2",{|| natr2}    }, ;
          {"cAtr1",{|| catr1}    }, ;
          {"cAtr2",{|| catr2}    } ;
        }
endif

cID := kadev_0->id

select kadev_1
 
if brzi_unos
	set order to tag "3"
else
   	set order to tag "1"
endif

cOldH := h[1]

h[1] := "Lista promjena "

// bilo 24
//CentrTxt( h[1], MAXROWS()-10 )

@ m_x + 1, m_y + 2 SAY " 23. Promjene - <Ctrl-End> Kraj pregleda, <Strelice> setanje kroz listu"
@ m_x + 2, m_y + 2 SAY "                <Ctrl-N> Novi zapis, <Ctrl-T> brisanje, <ENTER> edit"
@ m_x + 3, m_y + 2 SAY "                <Alt-K> Zatvaranje intervalne promjene"

BrowseKey( m_x + 5, ;
            m_y + 2, ;
            m_x + ( MAXROWS() - 22 ), ;
            m_y + ( MAXCOLS() - 5 ), ;
            ImeKol, ;
            {|Ch| EdPromj(Ch)}, ;
            IF( brzi_unos, "id + idpromj == cID + gTrPromjena", "id == cID" ), ;
            cId, 2, 4, 60 )

h[1] := cOldH

@ m_x + 19, m_y + 2 SAY "24. Operater " GET _operater PICT "@!"

read

if !brzi_unos
	@ m_x + 20, m_y + 2 SAY "  ----  <PgUp> Prethodna strana, <PgDn> snimi, <ESC> otkazi promjene --- "
  	Inkey(0)
endif

set relation to
select kadev_0

return lastkey()




// --------------------------------------
// edit promjena
// --------------------------------------
function EdPromj(ch)
local lPom := .f.
local _t_area := SELECT()

do case

    case Ch == K_ENTER .or. Ch == K_CTRL_N

     	if EOF() .and. Ch == K_ENTER
            select ( _t_area )
      		return DE_CONT
     	endif

     	if Ch == K_CTRL_N
       		append blank
     	endif

        set_global_vars_from_dbf( "q" )

        if Ch == K_CTRL_N
            qId := cId
        endif     		

     	Box( "btxt", 12 + IF( ! ("U" $ TYPE("qnAtr3") ), 7 , 0 ), 60, .f., "<ESC> otkazi operaciju" )

     		set cursor on

     		@ m_x + 1, m_y + 2 SAY "Datum         " GET qdatumod
     		@ m_x + 3, m_y + 2 SAY "Tip promjene  " GET qidpromj;
			            VALID P_Promj( @qidpromj, 3, 40 ) PICTURE "@!"
     		@ m_x + 4, m_y + 2 SAY "Karakteristika" GET qidk PICT "@!"
     		
		    read

     		if qIdPromj == "G1"     
			    // godisnji odmor
       			@ m_x+6, m_y+2 SAY "Koristi pravo na godisnji odmor za godinu   :"  GET qnAtr1 PICT "9999"
       			@ m_x+7, m_y+2 SAY "Broj dana godisnjeg odmora na koji ima pravo:"  GET qnAtr2  PICT "9999"
       			
			    if !("U" $ TYPE("qnAtr3"))
          			@ m_x+ 8,m_y+2 SAY "Zakonski minimum                         :"  GET qnAtr3  PICTURE "999"
          			@ m_x+ 9,m_y+2 SAY "Po osnovu vrste poslova i zadataka       :"  GET qnAtr4  PICTURE "999"
          			@ m_x+10,m_y+2 SAY "Po osnovu slozenosti poslova i zadataka  :"  GET qnAtr5  PICTURE "999"
          			@ m_x+11,m_y+2 SAY "Po osnovu duzine radnog staza            :"  GET qnAtr6  PICTURE "999"
          			@ m_x+12,m_y+2 SAY "Po osnovu uslova pod kojim radnik zivi   :"  GET qnAtr7  PICTURE "999"
          			@ m_x+13,m_y+2 SAY "Po osnovu zdravstvenog stanja radnika    :"  GET qnAtr8  PICTURE "999"
          			@ m_x+14,m_y+2 SAY "Umanjenje preko 30 dana                  :"  GET qnAtr9  PICTURE "999"
       			endif
     		endif

     		if qdatumod >= _daturmj 
			    // ako se ubacuje stara promjena ovaj uslov
      			qIdRJ := _idRJ   
			    // nije zadovoljen
      			qIdRMJ := _idRmj
     		endif

     		if P_Promj( qIdPromj, -6 ) == "1"  
			    // srj = "1" ako se mijenja promjenom radno mjesto
			    @ m_x+6, m_y+2 SAY "RJ" GET qIdRj PICT "@!"
			    @ m_x+6, col()+2 SAY "RMJ" GET qIdRmj VALID EVAL({|| lPom := P_RJRMJ(@qIdRj,@qIdRmj), SETPOS(m_x+7,m_y+3), QQOUT(Ocitaj(F_KDV_RJ,qIdRj,1)),SETPOS(m_x+8,m_y+3),QQOUT(Ocitaj(F_KDV_RMJ,qIdRmj,1)),lPom}) PICTURE "@!"
     		endif

     		if (cTipPromj := P_PROMJ(qIdPromj, -4)) == "X" ;
			        .and. P_Promj(qIdPromj, -7) $ "+-*A=" 
	            // -7 = URst
        		// znaci da se setuje Radni staz
       			aRe := GMJD(nAtr1)
                aRb := GMJD(nAtr2)
       			nGE:=aRe[1]
                nME:=aRe[2]
                nDe:=aRe[3]
       			nGB:=aRb[1]
                nMb:=aRb[2]
                nDb:=aRb[3]
       			@ m_x+6,m_y+2  SAY "Radni staz '"+cTipPromj +"'"
       			@ m_x+7,m_y+2  SAY "Efektivan G." GET nGE PICTURE "99"
       			@ m_x+7,COL() SAY " Mj." GET nME  PICTURE "99"
       			@ m_x+7,COL() SAY " D." GET nDE  PICTURE "99"
      			@ m_x+7,COL() SAY "    Benef. G." GET nGB  PICTURE "99"
       			@ m_x+7,COL() SAY " Mj." GET nMB PICTURE "99"
       			@ m_x+7,COL() SAY " D." GET nDB PICTURE "99"
      			read
       			qnAtr1:=nGE*365.125+nME*30.41+nDE
       			qnAtr2:=nGB*365.125+nMB*30.41+nDB
     		endif

     		if P_PROMJ(qIdPromj,-8) == "1" 
			    // u Ratni raspored
       			cRRasp:=LEFT(qcAtr1,4)
       			@ m_x+6,m_y+2 SAY "Ratni raspored "  GET cRRasp VALID P_RRasp(@cRRasp,7,2)  PICTURE "@!"
       			read
       			qcAtr1:=cRRasp
     		endif

     		if P_PROMJ(qIdPromj,-9) == "1" 
			    // u strucnu spremu
       			cStrSpr:=LEFT(qcAtr1,3)
       			cVStrSpr:=LEFT(qcAtr2,4)
       			@ m_x+6,m_y+2 SAY "Stepen str.spr"  GET cStrSpr VALID  P_StrSpr(@cStrSpr)  PICTURE "@!"
       			@ m_x+7,m_y+2 SAY " Vrsta str.spr"  GET cVStrSpr VALID P_Zanim(@cVStrSpr)  PICTURE "@!"
       			read
       			qcAtr1:=cStrSpr
       			qcAtr2:=cVstrSpr
     		endif
	
     		@ m_x+ 9+IF(!("U" $ TYPE("qnAtr3")),7,0),m_y+2 SAY "Dokument  " GET qDokument PICTURE "@!"
     		@ m_x+10+IF(!("U" $ TYPE("qnAtr3")),7,0),m_y+2 SAY "Opis      " GET qOpis     PICTURE "@!"
     		@ m_x+12+IF(!("U" $ TYPE("qnAtr3")),7,0),m_y+2 SAY "Nadlezan  " GET qNadlezan PICTURE "@!"
     		
		    read
     		
        BoxC()

     	if LastKey() <> K_ESC

            _rec := get_dbf_global_memvars( "q", .f. )
            update_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )

        	if ( Ch == K_CTRL_N .and. Pitanje( "p09", "Zelite li azurirati ovu promjenu ?", "D" ) == "D" ) ;
                    .or. ( Ch == K_ENTER .and. Pitanje( "p10", "Zelite li ponovo azurirati ovu promjenu ?", "N" ) == "D" )

           		if P_PROMJ( qIDPromj, -4 ) <> "X" 
				    // Tip X - samo postavlja odre|ene parametre
            		_status := P_PROMJ( qIdPromj,-5)
           		endif

           		if P_PROMJ(qIdPromj,-6)=="1"  // SRMJ=="1" - promjena radnog mjesta
              		_idRj:=qIdRj
               		_idRMJ:=qIdRMJ
               		_DatURMJ:=qDatumOd
               		if empty(_datuf)
                		_DatUF:=qDatumOd
               		endif
               		_DatVRmj:=CTOD("")
           		endif

           		if P_PROMJ(qIdPromj,-4)=="I"  
				    // intervalna promjena
               		_DatVRMJ:=qDatumOd
               		
                    _rec := dbf_get_rec()
                    _rec["datumdo"] := CTOD("")
                    update_rec_server_and_dbf( "kadev_1" , _rec, 1, "FULL" )
					 // "otvori promjenu !"
                endif

           		if P_PROMJ(qIDPromj,-8)=="1"   
	   			    // uRRasp = 1
              		_IdRRasp:=qcAtr1
           		endif

           		if P_PROMJ(qIDPromj,-9)=="1"    // uStrSpr = 1
              		_IdStrSpr:=qcAtr1
              		_IdZanim:=qcAtr2
           		endif

        	endif
        		
			return DE_REFRESH
     		
        else
        		
            if Ch == K_CTRL_N
                _rec := dbf_get_rec()
                delete_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" )
            	skip -1
            endif
        		
			return DE_REFRESH
     		
        endif
	    
    case Ch == K_CTRL_T
     	if Pitanje("p08","Sigurno zelite izbrisati ovu promjenu ???","N")=="D"
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" ) 
		    skip -1
      		return DE_REFRESH
        else
      		return DE_CONT
     	endif

  	case Ch == K_CTRL_END
     		return DE_ABORT
	case Ch == K_ALT_K
     	
        if P_PROMJ(IdPromj,-4)="I" .and. empty(DatumDo) 
		    
            // intervalna promjena
            dPom:=DATE()
        	
            Box("bzatv",3,40,.f.)
        		set cursor on
        		@ m_x+1,m_y+1 SAY "Datum zatvaranja:" GET dPom VALID dPom>=DatumOd
        		read
        	BoxC()
        	
            if lastkey()<>K_ESC
          		_status:="A" 
			    // zatvaranje promjene
          		_datVRMJ:=CTOD("")
                _rec := dbf_get_rec()
                _rec["datumdo"] := dPom
                update_rec_server_and_dbf( "kadev_1", _rec, 1, "FULL" ) 

          		if P_PROMJ(IDPromj,-8)=="1"
            		_IdRRasp:=""
          		endif

          		if P_PROMJ(IdPromj,-5)="M" .and.;
					P_RRASP(left(cAtr1,4),-4)="V" 
					// sluzenje vojnog roka
             		_SlVr:="D"
             		_VrSlVr+=DatumDo-DatumOd
             		_IdRRasp:=""
          		endif
        	endif
      	else
        	Msg("Promjena mora biti nezatvorena, intervalnog tipa",5)
      	endif
      	return DE_REFRESH

  	otherwise
     	return DE_CONT

endcase

return



function _dobar_id( noviId )
local _t_rec
local _t_order

if EMPTY( noviId )
    MsgO( "ID broj ne moze biti prazan!" )
    Inkey(0)
    MsgC()
    return .f.
endif

_t_rec := RECNO()
_t_order := INDEXORD()

set order to tag "1"
seek ( noviId )

if FOUND() .and. RECNO() <> _t_rec
    MsgO("Vec postoji zapis sa ovim ID brojem. Ispravite to !")
    Inkey(0)
    MsgC()
    dbsetorder( _t_order )
    go ( _t_rec )
    noviId := kadev_0->id
    return .f.
endif

dbsetorder( _t_order )
go ( _t_rec )

if noviId <> kadev_0->id

    if !EMPTY( kadev_0->id ) .and. !( KLevel $ "01" )
        Msg("Vi ne mozete mijenjati postojece podatke !",15)
        noviId := kadev_0->id
        return .t.
    endif

    if EMPTY( kadev_0->id ) .or. Pitanje( "p01", "Promijenili ste ID broj. Zelite li ovo snimiti (D/N) ?"," ")=="D"

        if !f18_lock_tables( { "kadev_1", "kadev_0" } )
            return .t.
        endif

        sql_table_update( nil, "BEGIN" )

        select kadev_1
        set order to tag "1"
        seek kadev_0->id

        do while kadev_0->id == field->id .and. !eof()

            skip
            nSRec := RECNO()
            skip -1

            _rec := dbf_get_rec()
            _rec["id"] := noviId

            update_rec_server_and_dbf( "kadev_1", _rec, 1, "CONT" )
            go nSRec

        enddo

        select kadev_0

        _rec := dbf_get_rec()
        _rec["id"] := noviID

        update_rec_server_and_dbf( "kadev_0", _rec, 1, "CONT" )

        f18_free_tables( { "kadev_1", "kadev_0" } )
        sql_table_update( nil, "END" )

   else
        noviId := kadev_0->id
   endif

endif

return .t.



function _dobar_id2( noviId2 )
local _t_rec, _t_order 

if !EMPTY( noviId2 )  

    // dozvoljeno je da je noviId2 prazan
    _t_rec := RECNO()
    _t_order := INDEXORD()
    set order to tag "3"
    seek ( noviId2 )

    if FOUND() .and. RECNO() <> _t_rec
        MsgO("Vec postoji zapis sa ovim ID2 brojem. Ispravite to !")
        Inkey(0)
        MsgC()
        dbsetorder( _t_order )
        go ( _t_rec )
        noviId2 := kadev_0->id2
        return .f.
    endif

    dbsetorder( _t_order )
    go ( _t_rec )

endif 

return .t.



// ---------------------------------------------------------
// brisanje osnovnog i njemu pridruzenih slogova
// ---------------------------------------------------------
function brisi_kadrovski_karton( erase )

if erase == NIL
    erase := .f.
endif

if erase .or. Pitanje("p02","Izbrisati karton: "+id+" (D/N) ?","N")=="D"
    
    MsgO("Brisem pridruzene zapise")

    if !f18_lock_tables({"kadev_0", "kadev_1"})
        return
    endif

    sql_table_update( nil, "BEGIN" )
    
    select kadev_1
    set order to tag "1"
    seek kadev_0->id
   
    if FOUND()
         _rec := dbf_get_rec()
        delete_rec_server_and_dbf( "kadev_1", _rec, 2, "CONT" )
    endif
 
    select kadev_0
    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( "kadev_0", _rec, 1, "CONT" )

    skip -1
 
    f18_free_tables({"kadev_0", "kadev_1"})
    sql_table_update( nil, "END" )
   
    MsgC()

endif

return 


