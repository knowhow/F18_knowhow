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

#include "fmk.ch"
#include "dbstruct.ch"
#include "error.ch"
#include "setcurs.ch"
#include "f18_separator.ch"

/*! \fn function ObjDBedit(cImeBoxa,  xw, yw, bUserF,  cMessTop, cMessBot, lInvert, aMessage, nFreeze, bPodvuci, nPrazno, nGPrazno, aPoredak, skipblock)
 * \brief Glavna funkcija tabelarnog prikaza podataka
 * \param cImeBoxa - ime box-a
 * \param xw - duzina
 * \param yw - sirina
 * \param bUserF - kodni blok, user funkcija
 * \param cMessTop - poruka na vrhu
 * \return NIL
 * \note grid - eng -> mreza
 *
 * Funkcija ObjDbedit koristi se za prikaz tabelarnih podataka. Koristi je sifarski sistem, tablela pripreme itd ...
*/

/*! \var ImeKol
 \brief Privatna Varijabla koja se inicijalizira prije "ulaska" u ObjDBedit
 \param - [ 1] Zalavlje kolone 
 \param - [ 2] kodni blok za prikaz kolone {|| id}
 \param - [ 3] izraz koji se edituje (string), obradjuje sa & operatorom
 \param - [ 4] kodni blok When
 \param - [ 5] kodni blok Valid
 \param - [ 6] -
 \param - [ 7] picture
 \param - [ 8] - ima jos getova ????
 \param - [ 9] -
 \param - [10] NIL - prikazi u sljedecem redu,  15 - prikazi u koloni my+15  broj kolone pri editu sa <F2>
*/


function ObjDBedit(cImeBoxa, xw, yw, bUserF, cMessTop, cMessBot, lInvert, aMessage, nFreeze, bPodvuci, nPrazno, nGPrazno, aPoredak, skipblock)
local _params := hb_hash()
local nBroji2
local cSmj, nRez, i, K, aUF, cPomDB, nTTrec
local cLoc := space(40)
local cStVr, cNovVr, nRec, nOrder, nPored, xcpos, ycpos

private  bGoreRed :=NIL
private  bDoleRed :=NIL
private  bDodajRed :=NIL

// trenutno smo u novom redu ?
private  fTBNoviRed:=.f. 

// da li se moze zavrsiti unos podataka ?
private  TBCanClose:=.t. 

private  TBAppend:="N"
private  bZaglavlje:=NIL
           // zaglavlje se edituje kada je kursor u prvoj koloni
           // prvog reda
private  TBScatter:="N"  // uzmi samo tekuce polje
private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                           // ovo se moze setovati u when/valid fjama

private  TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}

  
 if skipblock<>NIL // ovo je zadavanje skip bloka kroz parametar
     TBSkipBlock:=skipblock
else
     TBSkipBlock:=NIL
endif

private bTekCol
private Ch:=0

private azImeKol := ImeKol
private azKol := Kol

if nPrazno==NIL
   nPrazno:=0
endif

if nGPrazno==NIL
   nGPrazno:=0
endif

if aPoredak==NIL
  aPoredak:={}
 endif

if (nPored := LEN(aPoredak))>1
  AADD(aMessage, "<c+U> - Uredi")
endif

PRIVATE TB

if lInvert==NIL
  lInvert:=.f.
endif

_params["ime"]           := cImeBoxa
_params["xw"]            := xw
_params["yw"]            := yw
_params["invert"]        := lInvert
_params["msgs"]          := aMessage
_params["freeze"]        := nFreeze
_params["msg_bott"]      := cMessBot
_params["msg_top"]       := cMessTop
_params["prazno"]        := nPrazno
_params["gprazno"]       := nGPrazno
_params["podvuci_b"]     := bPodvuci

NeTBDirektni(_params, .t.)

DO WHILE .T.

   Ch := INKEY()

    if deleted() 
       // nalazim se na brisanom record-u
       skip
       if eof()
         Tb:Down()
       else
         Tb:Up()
       endif   
       Tb:RefreshCurrent()
    endif


    DO WHILE !TB:stable .AND. ( Ch := INKEY() ) == 0 
        Tb:stabilize()
    ENDDO

    if TB:stable .AND. (Ch := INKEY()) == 0
         
      if bUserF <>NIL
         xcpos:=ROW()
         ycpos:=COL()
         Eval(bUserF)
         @ xcpos, ycpos SAY ""
      endif

      Ch := inkey(0)
   endif

   if bUserF <> NIL
     
     // potpuna stabilizacija 
     DO While !TB:stabilize()
     END
   
     nRez:=Eval(bUserF)

   else
     nRez:=DE_CONT
   endif

   do case

     CASE Ch==K_UP
        TB:up()

     CASE Ch==K_DOWN
       TB:down()

     CASE Ch==K_LEFT
       TB:left()
     CASE Ch==K_RIGHT
       TB:right()
     CASE Ch==K_PGUP
       TB:PageUp()
     CASE Ch==K_CTRL_PGUP
        Tb:GoTop()
     CASE Ch==K_CTRL_PGDN
        Tb:GoBottom()
     CASE Ch==K_PGDN
        TB:PageDown()

     otherwise
       StandTBKomande( Tb, Ch, @nRez, nPored, aPoredak )

   endcase

   do case

     CASE nRez==DE_REFRESH
       TB:RefreshAll()
       @ m_x + 1, m_y + yw-6 SAY STR( RECCOUNT(), 5 )

     CASE Ch==K_ESC
        
        if nPrazno==0
            BoxC()
        endif
        exit

     CASE nRez==DE_ABORT .or. Ch==K_CTRL_END .or. Ch==K_ESC
        
        if nPrazno==0
            BoxC()
        endif

       EXIT


   endcase

ENDDO

return


// -------------------------------------------------------
//
// -------------------------------------------------------
function NeTBDirektni(params, lIzOBJDB)
LOCAL i, j, k
local _rows, _width

IF lIzOBJDB==NIL
  lIzOBJDB:=.f.
ENDIF

_rows        :=  params["xw"] 
_rows_poruke :=  params["prazno"] + iif(params["prazno"] <> 0, 1 , 0)
_width       :=  params["yw"]

if params["prazno"]==0
 
 IF !lIzOBJDB
    BoxC()
 ENDIF

  Box(params["ime"], _rows, _width, params["invert"], params["msgs"])

else

  @ m_x + params["xw"] - params["prazno"], m_y + 1 SAY replicate( BROWSE_PODVUCI, params["yw"])

endif

IF !lIzOBJDB
  ImeKol := azImeKol
  Kol := azKol
ENDIF

@ m_x, m_y + 2                       SAY params["msg_top"] + IIF(!lIzOBJDB, REPL(BROWSE_PODVUCI_2,  42), "")
@ m_x + params["xw"] + 1,  m_y + 2   SAY params["msg_bott"] COLOR "GR+/B"

@ m_x + params["xw"] + 1,  col() + 1 SAY IIF(!lIzOBJDB, REPL(BROWSE_PODVUCI_2, 42),"")
@ m_x + 1, m_y + params["yw"] - 6    SAY STR( RECCOUNT(), 5)


TB := TBRowseDB( m_x + 2 + params["prazno"], m_y + 1, m_x + _rows - _rows_poruke, m_y + _width) 

if TBSkipBlock<>NIL
     Tb:skipBlock := TBSkipBlock
endif

  // Dodavanje kolona  za stampanje
  FOR k:=1 TO Len(Kol)

    i := ASCAN(Kol, k)
    IF i <>0  .and. (ImeKol[i,2] <> NIL)     // kodni blok <> 0
       TCol:=TBColumnNew(ImeKol[i,1],ImeKol[i,2])

       if params["podvuci_b"] <> NIL
         TCol:colorBlock:={|| IIF(EVAL(params["podvuci_b"]), {5,2}, {1,2} ) }
       endif

       TB:addColumn(TCol)
    END IF

  NEXT

  TB:headSep := BROWSE_HEAD_SEP 
  TB:colsep :=  BROWSE_COL_SEP
  
  if params["freeze"] == NIL
     TB:Freeze:=1
  else
     Tb:Freeze := params["freeze"]
  endif

return


static function ForceStable()

DO WHILE .NOT. TB:stabilize()
    ENDDO
RETURN

//-----------------------------------------------------
//-----------------------------------------------------
static function InsToggle()

IF READINSERT()
        READINSERT(.F.)
        SETCURSOR(SC_NORMAL)
    ELSE
        READINSERT(.T.)
        SETCURSOR(SC_INSERT)
    ENDIF
RETURN


//-----------------------------------------------------
//-----------------------------------------------------
function StandTBKomande( TB, Ch, nRez, nPored, aPoredak )
local _tr := hb_Utf8ToStr("Traži:"), _zam := "Zamijeni sa:" 
local _last_srch := "N"
local _has_semaphore := .f.
local cSmj, i, K, aUF
local cLoc := space(40)
local cStVr, cNovVr, nRec, nOrder, xcpos, ycpos
local _trazi_val, _zamijeni_val, _trazi_usl 
local _sect, _pict
local _rec, _saved

DO CASE

	CASE Ch == K_SH_F1
		calc()

    case (Ch==K_F3)
         new_f18_session_thread()

	CASE Ch == K_CTRL_F
 
    	bTekCol :=( TB:getColumn( TB:colPos ) ):Block
     	
		if valtype(EVAL(bTekCol))=="C"

       		Box("bFind", 2, 50,.f.)
        		Private GetList:={}
        		set cursor on
        		cLoc := PADR(cLoc,40)
        		cSmj := "+"
        		@ m_x+1, m_y+2 SAY _tr GET cLoc PICT "@!"
        		@ m_x+2, m_y+2 SAY "Prema dolje (+), gore (-)" GET cSmj VALID cSmj $ "+-"
        		read
       		BoxC()

       		if lastkey() <> K_ESC

        		cLoc:=TRIM(cLoc)
        		aUf:=nil
        		if right(cLoc,1)==";"
          			Beep(1)
          			aUF:=parsiraj(cLoc,"EVAL(bTekCol)")
        		endif
        		Tb:hitTop:=TB:hitBottom:=.f.
        		do while !(Tb:hitTop .or. TB:hitBottom)
         			if aUF<>NIL
          				if Tacno(aUF)
            				exit
          				endif
         			else
          				if UPPER(LEFT(EVAL(bTekCol),LEN(cLoc)))==cLoc
           					exit
          				endif
         			endif
          			if cSmj="+"
           				Tb:down()
           				Tb:Stabilize()
          			else
           				Tb:Up()
           				Tb:Stabilize()
          			endif

        		enddo
        		Tb:hitTop:=TB:hitBottom:=.f.
       		endif
     	endif

	// ------------------
	// trazi-zamjeni opcija nad string, datum poljima
	CASE Ch == K_ALT_R

    	IF ( gReadOnly .or. !ImaPravoPristupa(goModul:oDatabase:cName,"CUI","STANDTBKOMANDE-ALTR_ALTS") )
    		Msg("Nemate pravo na koristenje ove opcije",15)
    	ELSE
			
			// da li tabela ima semafor ?
			_has_semaphore := alias_has_semaphore()

     		private cKolona

     		if LEN( Imekol[ TB:colPos ] ) > 2

       			if !EMPTY( ImeKol[ TB:colPos, 3 ] )

          			cKolona := ImeKol[ TB:ColPos, 3 ]

          			if VALTYPE( &cKolona ) $ "CD"

      					Box(, 3, 60, .f.)
             				
							private GetList:={}
             				set cursor on

                			@ m_x + 1, m_y+2 SAY "Uzmi podatke posljednje pretrage ?" GET _last_srch VALID _last_srch $ "DN" PICT "@!"

							read

                			// svako polje ima svoj parametar
                			_sect := "_brow_fld_find_" + ALLTRIM( LOWER( cKolona ) )
                			_trazi_val := &cKolona 
                			
							if _last_srch == "D"
								_trazi_val := fetch_metric(_sect, "<>", _trazi_val )
							endif

                			_zamijeni_val := _trazi_val
                			_sect := "_brow_fld_repl_" + ALLTRIM(LOWER(cKolona))
								
							if _last_srch == "D"
                				_zamijeni_val := fetch_metric(_sect, "<>", _zamijeni_val)
							endif

                			_pict := ""

                			if VALTYPE( _trazi_val ) == "C" .and. LEN( _trazi_val ) > 45
                   				_pict := "@S45"
                			endif

                			@ m_x + 2, m_y+2 SAY PADR( _tr, 12) GET _trazi_val PICT _pict
                			@ m_x + 3, m_y+2 SAY PADR( _zam, 12) GET _zamijeni_val PICT _pict
                			
							read

            			BoxC()

            			if LASTKEY() <> K_ESC
             				
							nRec := recno()
             				nOrder := indexord()
             				
							set order to 0
             				go top
             				
							_saved := .f.

							if _has_semaphore
								my_use_semaphore_off()
								sql_table_update( nil, "BEGIN" )
							endif

             				do while !eof()

               					if EVAL(FIELDBLOCK(cKolona)) == _trazi_val
                   				
									_rec := dbf_get_rec()
                   					_rec[ LOWER(cKolona) ] := _zamijeni_val
                   				
									if _has_semaphore
										update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )
									else
										dbf_update_rec(_rec)
									endif

                   					if !_saved .and. _last_srch == "D"
                      	 				// snimi
                       					_sect := "_brow_fld_find_" + ALLTRIM(LOWER(cKolona))
                       					set_metric( _sect, "<>", _trazi_val )

                       					_sect := "_brow_fld_repl_" + ALLTRIM(LOWER(cKolona))
                       					set_metric( _sect, "<>", _zamijeni_val )
                       					_saved := .t.
                    				endif

               					endif

               					if VALTYPE( _trazi_val ) == "C"
                   			
									_rec := dbf_get_rec()

                   					cDio1 := left(_trazi_val, len(trim(_trazi_val)) - 2)
                   					cDio2 := left(_zamijeni_val, len(trim(_zamijeni_val)) -2)

                   					if right(trim(_trazi_val), 2) == "**" .and. cDio1 $  _rec[LOWER(cKolona)]

                       					_rec[LOWER(cKolona)] := STRTRAN( _rec[LOWER(cKolona)], cDio1, cDio2)

										if _has_semaphore
											update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )
										else
                       						dbf_update_rec(_rec)
										endif

                   					endif

               					endif

               					skip

             				enddo

							if _has_semaphore
								sql_table_update( nil, "END" )
								my_use_semaphore_on()
							endif
             				
							dbsetorder( nOrder )
             				go nRec
             				TB:RefreshAll()

            			endif
          			endif
       			endif
     		endif
    	endif

	// trazi i zamjeni numeričke vrijednosti u tabeli
	// -----------------------
	CASE Ch==K_ALT_S
    
    	if ( gReadOnly .or. !ImaPravoPristupa(goModul:oDatabase:cName,"CUI","STANDTBKOMANDE-ALTR_ALTS") )
     		Msg("Nemate pravo na koristenje ove opcije",15)
    	else

     		private cKolona

			// imamo li semafor na tabeli ?
			_has_semaphore := alias_has_semaphore()

     		if LEN( Imekol[ TB:colPos ] ) > 2

       			if !EMPTY( ImeKol[ TB:colPos, 3 ] )

          			cKolona := ImeKol[ TB:ColPos, 3 ]

          			if VALTYPE( &cKolona ) == "N"

            			Box(, 3, 66, .f. )

             				private GetList:={}
             				set cursor on

                			_trazi_val := &cKolona 
             				_trazi_usl := SPACE(80)

             				@ m_x + 1, m_y + 2 SAY "Postavi na:" GET _trazi_val
             				@ m_x + 2, m_y + 2 SAY "Uslov za obuhvatanje stavki (prazno-sve):" GET _trazi_usl ;
												PICT "@S20" ;
												VALID EMPTY( _trazi_usl ) .or. EvEr( _trazi_usl, "Greska! Neispravno postavljen uslov!" )

             				read

            			BoxC()

            			if LASTKEY() <> K_ESC

             				nRec := recno()
             				nOrder := indexord()

             				set order to 0

             				if Pitanje(, "Promjena ce se izvrsiti u " + IIF( EMPTY( _trazi_usl ), "svim ", "" ) + "stavkama" + IIF( !EMPTY( _trazi_usl ), " koje obuhvata uslov","") + ". Zelite nastaviti ?","N")=="D"

								if _has_semaphore
									my_use_semaphore_off()
									sql_table_update( nil, "BEGIN" )
								endif

               					go top

               					do while !eof()

                	 				IF EMPTY( _trazi_usl ) .or. &(_trazi_usl )

										_rec := dbf_get_rec()
										_rec[ LOWER( cKolona ) ] := _trazi_val

										if _has_semaphore
											update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )
										else
											dbf_update_rec( _rec )
										endif

                 					ENDIF

                 					skip

               					enddo

								if _has_semaphore
									sql_table_update( nil, "END" )
									my_use_semaphore_on()
								endif
	
             				endif
			
             				dbsetorder(nOrder)
            	 			go nRec
             				TB:RefreshAll()

            			endif
          			endif
       			endif
     		endif
    	endif

  	CASE Ch == K_CTRL_U .and. nPored > 1
     
    	Private GetList:={}
     	nRez:=INDEXORD()
     	Prozor1(12,20,17+nPored, 59, "UTVRDJIVANJE PORETKA", , , "GR+/N", "W/N,B/W, , , B/W", 2)
     	FOR i:=1 TO nPored
      		@ 13+i,23 SAY PADR("poredak po "+aPoredak[i],33,"ú") + STR(i,1)
     	NEXT
     	@ 18,27 SAY "UREDITI TABELU PO BROJU:" GET nRez VALID nRez>0 .AND. nRez<nPored+1 PICT "9"
     	READ
    	Prozor0()

     	IF LASTKEY()!=K_ESC
       		DBSETORDER(nRez+1)
      		nRez:=DE_REFRESH
     	ELSE
       		nRez:=DE_CONT
     	ENDIF

ENDCASE

return


// ---------------------------------------------------------------
// ---------------------------------------------------------------
function StandTBTipke()

// * ove tipke ne smiju aktivirati edit-mod


if Ch==K_ESC .or. Ch==K_CTRL_T .or. Ch=K_CTRL_P .or. Ch=K_CTRL_N .or. ;
   Ch==K_ALT_A .or. Ch==K_ALT_P .or. Ch=K_ALT_S .or. Ch=K_ALT_R .or. ;
   Ch==K_DEL .or. Ch=K_F2 .or. Ch=K_F4 .or. Ch=K_CTRL_F9 .or. Ch=0
   return .t.
endif

return .f.


// ---------------------------------------
// ---------------------------------------
static function ObjDbGet()

/*! 
 *Izvrsi GET za tekucu kolonu u browse-u
 */


LOCAL bIns, lScore, lExit
LOCAL col, get, nKey
LOCAL xOldKey, xNewKey


// Make sure screen is fully updated, dbf position is correct, etc.
ForceStable()

// Save the current record's key value (or NIL)
// (for an explanation, refer to the rambling note below)
xOldKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )

// Save global state
lScore := Set(_SET_SCOREBOARD, .F.)
lExit := Set(_SET_EXIT, .T.)
bIns := SetKey(K_INS)

// Set insert key to toggle insert mode and cursor shape
SetKey( K_INS, {|| InsToggle()} )

// edit polja
col := TB:getColumn(TB:colPos)

IF LEN(ImeKol[TB:colpos])>4 // ima validaciju
  EditPolja(ROW(),COL(),EVAL(col:block),ImeKol[TB:ColPos,3],ImeKol[TB:ColPos,4],ImeKol[TB:ColPos,5],TB:colorSpec)
ELSEIF LEN(ImeKol[TB:colpos])>2  // nema validaciju
  EditPolja(ROW(),COL(),EVAL(col:block),ImeKol[TB:ColPos,3],{|| .t.},{|| .t.},TB:colorSpec)
ENDIF

// Restore state
Set(_SET_SCOREBOARD, lScore)
Set(_SET_EXIT, lExit)
SetKey(K_INS, bIns)

// Get the record's key value (or NIL) after the GET
xNewKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )

// If the key has changed (or if this is a new record)
IF .NOT. (xNewKey == xOldKey)

    // Do a complete refresh
    TB:refreshAll()
    ForceStable()

    // Make sure we're still on the right record after stabilizing
    DO WHILE &(INDEXKEY()) > xNewKey .AND. .NOT. TB:hitTop()
        TB:up()
        ForceStable()
    ENDDO

ENDIF

// Check exit key from get
nKey := LASTKEY()

IF nKey == K_UP .OR. nKey == K_DOWN .OR. ;
    nKey == K_PGUP .OR. nKey == K_PGDN

    // Ugh
    KEYBOARD( CHR(nKey) )

ENDIF

RETURN



// --------------------------------------------------------------
// --------------------------------------------------------------
static function EditPolja( nX, nY, xIni, cNazPolja, ;
                           bWhen, bValid, cBoje )
  
  local i
  local cStaraVr:=gTBDir
  local cPict
  local bGetSet
  local nSirina

  if TBScatter == "N"
   cPom77I := cNazpolja
   cPom77U := "w"+cNazpolja
   &cPom77U := xIni
  else
   Scatter()
   if fieldpos(cNazPolja)<>0 // field varijabla
    cPom77I := cNazpolja
    cPom77U := "_"+cNazpolja
   else
    cPom77I := cNazpolja
    cPom77U := cNazPolja
   endif
  endif

  cpict:=NIL
  if len(ImeKol[TB:Colpos])>=7  // ima picture
    cPict:=ImeKol[TB:Colpos,7]
  endif


  // provjeriti kolika je sirina get-a!!

  aTBGets:={}
  get := GetNew(nX, nY, MEMVARBlock(cPom77U),;
               cPom77U, cPict, "W+/BG,W+/B")
  get:PreBlock:=bWhen
  get:PostBlock:=bValid
  AADD(aTBGets,Get)
  nSirina:=8
  if cPict<>NIL
     nSirina:=len(transform(&cPom77U,cPict))
  endif

  //@ nX, nY GET &cPom77U VALID EVAL(bValid) WHEN EVAL(bWhen) COLOR "W+/BG,W+/B" pict cPict
  if len(ImeKol[TB:Colpos])>=8  // ima joç getova
    aPom:=ImeKol[TB:Colpos,8]  // matrica
    for i:=1 to len(aPom)
      nY:=nY+nSirina+1
      get := GetNew(nX, nY, MEMVARBlock(aPom[i,1]),;
               aPom[i,1],aPom[i,4], "W+/BG,W+/B")
      nSirina:=len(transform(&(aPom[i,1]),aPom[i,4]))
      get:PreBlock:=aPom[i,2]
      get:PostBlock:=aPom[i,3]
      AADD(aTBGets,Get)
    next

    if nY + nsirina > MAXCOLS()-2

       for i:=1 to len(aTBGets)
          aTBGets[i]:Col:= aTBGets[i]:Col   - (nY+nSirina-78)
          // smanji col koordinate
       next
    endif

  endif

  //READ
    readmodal(aTBGets)

    if TBScatter="N"
     // azuriraj samo ako nije zadan when blok !!!
     REPLACE &cPom77I WITH &cPom77U
     sql_azur(.t.)
     //REPLSQL &cPom77I WITH &cPom77U
    else
     IF LASTKEY()!=K_ESC .and. cPom77I<>cPom77U  // field varijabla
       Gather()
       sql_azur(.t.)
       GathSQL()
     endif
    endif

RETURN


/*! \fn function TBPomjeranje(TB, cPomjeranje)
 *  \brief Opcije pomjeranja tbrowsea u direkt rezimu
 *  \param TB          -  TBrowseObjekt
 *  \param cPomjeranje - ">", ">2", "V0"
 */

function TBPomjeranje(TB, cPomjeranje)

local cPomTB

if (cPomjeranje)=">"
   cPomTb:=substr(cPomjeranje, 2, 1)
   TB:Right()
   if !empty(cPomTB)
     for i:=1 to val(cPomTB)
         TB:Right()
     next
   endif

elseif (cPomjeranje)="V"
   TB:Down()
   cPomTb:=substr(cPomjeranje,2,1)
   if !empty(cPomTB)
     TB:PanHome()
     for i:=1 to val(cPomTB)
         TB:Right()
     next
   endif
   if bDoleRed=NIL .or. Eval(bDoleRed)
      fTBNoviRed:=.f.
   endif
elseif (cPomjeranje)="<"
   TB:left()
elseif (cPomjeranje)="0"
   TB:PanHome()
endif



// ----------------------------------------
// ----------------------------------------
function EvEr( cExpr, cMes, cT)
 
LOCAL lVrati:=.t.
 
IF cMes==nil
   cmes:="Greska!"
ENDIF

IF cT==nil
    cT:="L"
ENDIF
 
 
PRIVATE cPom:=cExpr
 
IF !(TYPE(cPom)=cT)
   lVrati:=.f.
   msgbeep(cMes)
ENDIF

RETURN lVrati

