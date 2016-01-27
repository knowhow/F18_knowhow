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
#include "hbclass.ch"
#include "f18_separator.ch"



FUNCTION TFrmInvNew()

   LOCAL oObj

   oObj := TFrmInv():new()
   oObj:self := oObj
   oObj:lTerminate := .F.

   RETURN oObj



FUNCTION fakt_unos_inventure()

   LOCAL oMainFrm

   oMainFrm := TFrmInvNew()
   oMainFrm:open()
   oMainFrm:close()

   RETURN


CREATE CLASS TFrmInv

   EXPORTED:
   VAR self
	
   // is partner field loaded
   VAR lPartnerLoaded
   VAR lTerminate

   VAR nActionType
   VAR nCh
   VAR oApp
   VAR aImeKol
   VAR aKol
   VAR nStatus

   METHOD open
   METHOD CLOSE
   METHOD PRINT
   METHOD printOPop
   METHOD deleteItem
   METHOD deleteAll
   METHOD itemsCount
   METHOD setColumns
   METHOD onKeyboard

   METHOD walk
   METHOD noveStavke
   METHOD popup
   METHOD sayKomande
	
   METHOD genDok
   METHOD genDokManjak
   METHOD genDokVisak

   METHOD open_tables

END CLASS


METHOD open_tables()

   O_FAKT_DOKS
   O_FAKT
   O_SIFK
   O_SIFV
   O_PARTN
   O_ROBA
   O_TARIFA
   O_FAKT_PRIPR

   RETURN .T.


METHOD open()

   PRIVATE imekol
   PRIVATE kol

   close_open_fakt_tabele()

   SELECT fakt_pripr
   SET ORDER TO TAG "1"

   if ::lTerminate
      RETURN
   ENDIF

   ::setColumns()

   Box(, 21, 77 )
   TekDokument()
   ::sayKomande()
   ObjDbedit( "FInv", 21, 77, {|| ::onKeyBoard() }, "", "Priprema inventure", , , , , 4 )

   RETURN



METHOD onKeyboard()

   LOCAL nRet
   LOCAL oFrmItem

   ::nCh := Ch

   if ::lTerminate
      RETURN DE_ABORT
   ENDIF

   SELECT fakt_pripr

   IF ( ::nCh == K_ENTER  .AND. Empty( field->brdok ) .AND. Empty( field->rbr ) )
      RETURN DE_CONT
   ENDIF

   DO CASE

   case ::nCh == K_CTRL_T
      if ::deleteItem() == 1
         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   case ::nCh == K_ENTER
      oFrmItem := TFrmInvItNew( self )
      nRet := oFrmItem:open()
      oFrmItem:close()

      IF nRet == 1
         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   case ::nCh == K_CTRL_A
      ::walk()
      RETURN DE_REFRESH

   case ::nCh == K_CTRL_N
      ::noveStavke()
      RETURN DE_REFRESH

   case ::nCh == K_CTRL_P
      ::print()
      RETURN DE_REFRESH
	
   case ::nCh == K_ALT_P
      ::printOPop()
      RETURN DE_REFRESH

   case ::nCh == K_ALT_A
      my_close_all_dbf()
      azur_fakt()
      close_open_fakt_tabele()
      RETURN DE_REFRESH

   case ::nCh == K_CTRL_F9
      ::deleteAll()
      RETURN DE_REFRESH

   case ::nCh == K_F10
      ::Popup()
      if ::lTerminate
         RETURN DE_ABORT
      ENDIF
      RETURN DE_REFRESH

   case ::nCh == K_ALT_F10
	
   case ::nCh == K_ESC
      RETURN DE_ABORT
   ENDCASE
	
   RETURN DE_CONT



METHOD walk()

   LOCAL oFrmItem

   oFrmItem := TFrmInvItNew( self )

   DO WHILE .T.

      oFrmItem:lNovaStavka := .F.
      oFrmItem:open()
      oFrmItem:close()

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      IF oFrmItem:nextItem() == 0
         EXIT
      ENDIF

   ENDDO

   oFrmItem := nil

   RETURN



METHOD noveStavke()

   LOCAL oFrmItem

   oFrmItem := TFrmInvItNew( self )

   DO WHILE .T.
      oFrmItem:lNovaStavka := .T.
      oFrmItem:open()
      oFrmItem:close()
      IF LastKey() == K_ESC
         oFrmItem:deleteItem()
         EXIT
      ENDIF
   ENDDO
   oFrmItem := NIL

   RETURN



METHOD sayKomande()

   @ m_x + 18, m_y + 2 SAY " <c-N> Nove Stavke       " + BROWSE_COL_SEP + "<ENT> Ispravi stavku      " + BROWSE_COL_SEP + "<c-T> Brisi Stavku "
   @ m_x + 19, m_y + 2 SAY " <c-A> Ispravka Dokumenta" + BROWSE_COL_SEP + "<c-P> Stampa dokumenta    " + BROWSE_COL_SEP + "<a-P> Stampa obr. popisa"
   @ m_x + 20, m_y + 2 SAY " <a-A> Azuriranje dok.   " + BROWSE_COL_SEP + "<c-F9> Brisi pripremu     " + BROWSE_COL_SEP + ""
   @ m_x + 21, m_y + 2 SAY " <F10>  Ostale opcije    " + BROWSE_COL_SEP + "<a-F10> Asistent  "

   RETURN


METHOD setColumns()

   LOCAL i

   ::aImeKol := {}
   AAdd( ::aImeKol, { "Red.br",        {|| Str( RbrUNum( field->rBr ), 4 ) } } )
   AAdd( ::aImeKol, { "Roba",          {|| Roba() } } )
   AAdd( ::aImeKol, { "Knjiz. kol",    {|| field->serBr } } )
   AAdd( ::aImeKol, { "Popis. kol",    {|| field->kolicina } } )
   AAdd( ::aImeKol, { "Cijena",        {|| field->cijena }, "cijena" } )
   AAdd( ::aImeKol, { "Rabat",         {|| field->rabat }, "rabat" } )
   AAdd( ::aImeKol, { "Porez",         {|| field->porez }, "porez" } )
   AAdd( ::aImeKol, { "RJ",            {|| field->idFirma }, "idFirma" } )
   AAdd( ::aImeKol, { "Partn",         {|| field->idPartner }, "idPartner" } )
   AAdd( ::aImeKol, { "IdTipDok",      {|| field->idTipDok }, "idtipdok" } )
   AAdd( ::aImeKol, { "Brdok",         {|| field->brDok }, "brdok" } )
   AAdd( ::aImeKol, { "DatDok",        {|| field->datDok }, "datDok" } )

   IF fakt_pripr->( FieldPos( "k1" ) ) <> 0 .AND. gDK1 == "D"
      AAdd( ::aImeKol, { "K1", {|| field->k1 }, "k1" } )
      AAdd( ::aImeKol, { "K2", {|| field->k2 }, "k2" } )
   ENDIF


   ::aKol := {}
   FOR i := 1 TO Len( ::aImeKol )
      AAdd( ::aKol, i )
   NEXT

   ImeKol := ::aImeKol
   Kol := ::aKol

   RETURN



METHOD PRINT()

   PushWA()
   RptInv()
   ::open_tables()
   PopWA()

   RETURN


METHOD printOPop()

   PushWA()
   RptInvObrPopisa()
   ::open_tables()
   PopWA()

   RETURN

METHOD CLOSE

   BoxC()
   CLOSERET

   RETURN

METHOD itemsCount()

   LOCAL nCnt

   PushWA()
   SELECT fakt_pripr
   nCnt := 0
   DO WHILE !Eof()
      nCnt++
      SKIP
   ENDDO
   PopWa()

   RETURN nCnt


METHOD deleteAll()

   IF Pitanje( , "Želite li zaista izbrisati cijeli dokument?", "N" ) == "D"
      my_dbf_zap()
   ENDIF

   RETURN



METHOD deleteItem()

   my_delete_with_pack()

   RETURN 1



METHOD popup

   PRIVATE opc
   PRIVATE opcexe
   PRIVATE Izbor

   opc := {}
   opcexe := {}
   Izbor := 1
   AAdd( opc, "1. generacija dokumenta inventure      " )
   AAdd( opcexe, {|| ::genDok() } )

   AAdd( opc, "2. generisi otpremu za kolicinu manjka" )
   AAdd( opcexe, {|| ::genDokManjak() } )
   AAdd( opc, "3. generisi dopremu za kolicinu viska" )
   AAdd( opcexe, {|| ::genDokVisak() } )

   Menu_SC( "ppin" )

   RETURN NIL


METHOD genDok()

   LOCAL cIdRj

   cIdRj := gFirma
   Box(, 2, 40 )
   @ m_x + 1, m_y + 2 SAY "RJ:" GET cIdRj
   READ
   BoxC()

   IF Pitanje(, "Generisati dokument inventure za RJ " + cIdRj, "N" ) == "D"
      my_close_all_dbf()
      fakt_generisi_inventuru( cIdRj )
      close_open_fakt_tabele()
   ENDIF

   RETURN



METHOD genDokManjak()

   LOCAL cIdRj
   LOCAL cBrDok

   cIdRj := gFirma
   cBrDok := Space( Len( field->brDok ) )
   DO WHILE .T.
      Box(, 4, 60 )
      @ m_x + 1, m_y + 2 SAY "Broj (azuriranog) dokumenta za koji generisete"
      @ m_x + 2, m_y + 2 SAY "otpremu po osnovu manjka"

      @ m_x + 4, m_y + 2 SAY "RJ:" GET cIdRJ
      @ m_x + 4, Col() + 2 SAY "- IM -" GET cBrDok

      READ
      BoxC()
      IF LastKey() == K_ESC
         RETURN
      ENDIF

      IF !fakt_dokument_postoji( cIdRj, "IM", cBrDok )
         MsgBeep( "Dokument ne postoji ?!" )
      ELSE
         EXIT
      ENDIF
   ENDDO

   MsgBeep( "Not imp: GDokInvManjak" )

   // generisem dokumenat 19 - izlaz po ostalim osnovama
   fakt_inventura_manjak( cIdRj, cBrDok )

   // obrada "obicnih" dokumenata
   fakt_unos_dokumenta()

   ::lTerminate := .T.

   RETURN



METHOD genDokVisak

   LOCAL cIdRj
   LOCAL cBrDok

   cIdRj := gFirma
   cBrDok := Space( Len( field->brDok ) )

   DO WHILE .T.
      Box(, 4, 60 )
      @ m_x + 1, m_y + 2 SAY "Broj (azuriranog) dokumenta za koji generisete"
      @ m_x + 2, m_y + 2 SAY "prijem po osnovu viska"

      @ m_x + 4, m_y + 2 SAY "RJ:" GET cIdRJ
      @ m_x + 4, Col() + 2 SAY "- IM -" GET cBrDok

      READ
      BoxC()
      IF LastKey() == K_ESC
         RETURN
      ENDIF

      IF !fakt_dokument_postoji( cIdRj, "IM", cBrDok )
         MsgBeep( "Dokument " + cIdRj + "-IM-" + cBrDok + "ne postoji ?!" )
      ELSE
         EXIT
      ENDIF
   ENDDO

   MsgBeep( "Not imp: GDokInvVisak" )
   // generisem dokumenat 01 - prijem
   fakt_inventura_visak( cIdRj, cBrDok )

   // obrada "obicnih" dokumenata
   fakt_unos_dokumenta()

   ::lTerminate := .T.

   RETURN

