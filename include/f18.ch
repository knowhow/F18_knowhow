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

#define F18_F18_DEFINED
#define FMK_DEFINED
#define F18_DEFINED

#include "o_f18.ch"
#include "f_f18.ch"
#include "inkey.ch"
#include "box.ch"
#include "dbedit.ch"
#include "hbclass.ch"
#include "achoice.ch"
#include "fileio.ch"
#require "rddsql"
#require "sddpg"
#include "dbinfo.ch"
#include "error.ch"
/*

// NTX
#define NTX_INDICES
#undef  CDX_INDICES


#define INDEXEXT      "ntx"
#define OLD_INDEXEXT  "cdx"
#define DBFEXT        "dbf"
#define MEMOEXT       "dbt"

#define  INDEXEXTENS  "ntx"
#define  MEMOEXTENS   "dbt"


#define RDDENGINE "DBFNTX"
#define DBFENGINE "DBFNTX"

*/

// CDX
#define CDX_INDICES
#undef NTX_INDICES
#define INDEXEXT      "cdx"
#define OLD_INDEXEXT  "ntx"
#define DBFEXT        "dbf"
#define MEMOEXT       "fpt"

#define  INDEXEXTENS  "cdx"
#define  MEMOEXTENS   "fpt"


#define RDDENGINE "DBFCDX"
#define DBFENGINE "DBFCDX"
// CDX end


// komande koje se koriste
// koje nam ne trebaju
#command REPLSQL <f1> WITH <v1> [, <fN> WITH <vN> ] ;
    => replsql_dummy()

#command REPLSQL TYPE <cTip> <f1> WITH <v1> [, <fN> WITH <vN> ] ;
    => replsql_dummy()

#define SEMAPHORE_LOCK_RETRY_IDLE_TIME 1
#define SEMAPHORE_LOCK_RETRY_NUM 50

#define SIFK_LEN_DBF     8
#define SIFK_LEN_OZNAKA  4
#define SIFK_LEN_IDSIF   15

//#define RPT_PAGE_LEN 60
#define RPT_PAGE_LEN fetch_metric( "rpt_duzina_stranice", my_user(), 60 )

#define F18_CLIENT_ID_INI_SECTION "client_id"
#define F18_SCREEN_INI_SECTION "F18_screen"
#define F18_DBF_INI_SECTION "F18_dbf"

#ifdef __PLATFORM__WINDOWS
    #define F18_TEMPLATE_LOCATION "c:" + SLASH + "knowhowERP" + SLASH + "template" + SLASH
#else
    #define F18_TEMPLATE_LOCATION SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "template" + SLASH
#endif

#define F18_SECUR_WARRNING "Opcija nije dostupna za ovaj nivo !#Da bi koristili opciju potrebna podesenja privilegija"

#ifndef TEST
  #ifndef F18_RELEASE_DEFINED
      #include "f18_release.ch"
  #endif
#else
  #ifndef F18_TEST_DEFINED
      #include "f18_test.ch"
  #endif
#endif

// F18.log, F18_2.log, F18_3.log ...
#define F18_LOG_FILE "F18.log"
#define OUTF_FILE "outf.txt"
#define OUT_ODT_FILE "out.odt"
#define DATA_XML_FILE "data.xml"

#command QUIT_1                    => ErrorLevel(1); __Quit()

#command @ <row>, <col> SAY8 <exp> [PICTURE <pic>] [COLOR <clr>] => ;
         DevPos( <row>, <col> ) ; DevOutPict( hb_utf8toStr( <exp> ), <pic> [, <clr>] )
#command @ <row>, <col> SAY8 <exp> [COLOR <clr>] => ;
         DevPos( <row>, <col> ) ; DevOut( hb_utf8toStr( <exp> ) [, <clr>] )

#command @ <row>, <col> SAY8 <say> [<sayexp,...>] GET <get> [<getexp,...>] => ;
         @ <row>, <col> SAY8 <say> [ <sayexp>] ;;
         @ Row(), Col() + 1 GET <get> [ <getexp>]


#command ?U  [<explist,...>]         => QOutU( <explist> )
#command ??U [<explist,...>]         => QQOutU( <explist> )


#command RREPLACE <f1> WITH <v1> [, <fN> WITH <vN> ]    ;
      => my_rlock();
         ;   _FIELD-><f1> := <v1> [; _FIELD-><fN> := <vN>];
         ;my_unlock()


#define EXEPATH   my_home_root()
#define SIFPATH   my_home()

#define PRIVPATH my_home()

#define KUMPATH  my_home()
#define CURDIR   my_home()

#define I_ID 1
#define DE_ADD  5
#define DE_DEL  6


#define RECI_GDJE_SAM   PROCNAME(1) + " (" + ALLTRIM(STR(PROCLINE(1))) + ")"
#define RECI_GDJE_SAM0  PROCNAME(0) + " (" + ALLTRIM(STR(PROCLINE(0))) + ")"

#command ESC_EXIT  => if lastkey()=K_ESC;
                      ;exit             ;
                      ;endif

#command ESC_RETURN <x> => if lastkey()=K_ESC;
                           ;return <x>       ;
                           ;endif

#command ESC_RETURN    => if lastkey()=K_ESC;
                           ;return        ;
                           ;endif

#command HSEEK <xpr>     => dbSeek(<xpr> ,.f.)

#command MSEEK <xpr>             => dbSeek(<xpr> )


#command EJECTA0          => qqout(chr(13)+chr(10)+chr(12))  ;
                           ; setprc(0,0)             ;
                           ; A:=0

#command EJECTNA0         => qqout(chr(13)+chr(10)+chr(18)+chr(12))  ;
                           ; setprc(0,0)             ;
                           ; A:=0


#command FF               => gPFF()
#command P_FF               => gPFF()

#xcommand P_INI              =>  gpini()
#xcommand P_NR              =>   gpnr()
#xcommand P_COND             =>  gpCOND()
#xcommand P_COND2            =>  gpCOND2()
#xcommand P_10CPI            =>  gP10CPI()
#xcommand P_12CPI            =>  gP12CPI()
#xcommand F10CPI            =>  gP10CPI()
#xcommand F12CPI            =>  gP12CPI()
#xcommand P_B_ON             =>  gPB_ON()
#xcommand P_B_OFF            =>  gPB_OFF()
#xcommand P_I_ON             =>  gPI_ON()
#xcommand P_I_OFF            =>  gPI_OFF()
#xcommand P_U_ON             =>  gPU_ON()
#xcommand P_U_OFF            =>  gPU_OFF()

#xcommand P_PO_P             =>  gPO_Port()
#xcommand P_PO_L             =>  gPO_Land()
#xcommand P_RPL_N            =>  gRPL_Normal()
#xcommand P_RPL_G            =>  gRPL_Gusto()


#xcommand INI              =>  gPB_ON()
#xcommand B_ON             =>  gPB_ON()
#xcommand B_OFF            =>  gPB_OFF()
#xcommand I_ON             =>  gPI_ON()
#xcommand I_OFF            =>  gPI_OFF()
#xcommand U_ON             =>  gPU_ON()
#xcommand U_OFF            =>  gPU_OFF()

#xcommand PO_P             =>  gPO_Port()
#xcommand PO_L             =>  gPO_Land()
#xcommand RPL_N            =>  gRPL_Normal()
#xcommand RPL_G            =>  gRPL_Gusto()


#xcommand RESET            =>  gPRESET()



#xcommand CLOSERET2      => my_close_all_dbf(); return
#xcommand CLOSERET       => my_close_all_dbf(); return


#xcommand ESC_BCR   =>  if LastKey() == K_ESC     ;
                         ; my_close_all_dbf()     ;
                         ; BoxC()                 ;
                         ;return .F.              ;
                         ;endif


#xcommand START PRINT CRET <x>  => PRIVATE __print_opt := NIL ;
                                  ; if EMPTY(f18_start_print(NIL, @__print_opt))       ;
                                  ;    my_close_all_dbf()             ;
                                  ;    return <x>                     ;
                                  ;endif

#xcommand STARTPRINT CRET <x>  => PRIVATE __print_opt := NIL ;
                                  ; if EMPTY(f18_start_print(NIL, @__print_opt))       ;
                                  ;    my_close_all_dbf()             ;
                                  ;    return <x>                     ;
                                  ;endif

#xcommand STARTPRINT CRET       => PRIVATE __print_opt := NIL ;
                                  ; if EMPTY(f18_start_print(NIL, @__print_opt))       ;
                                  ;    my_close_all_dbf()             ;
                                  ;    return .F.                     ;
                                  ;endif





#xcommand START PRINT CRET  =>    private __print_opt := NIL ;
                                  ; if EMPTY(f18_start_print(NIL, @__print_opt))       ;
                                  ;    my_close_all_dbf()             ;
                                  ;    return .F.                     ;
                                  ;endif

#xcommand START PRINT RET <x>  =>  private __print_opt := NIL ;
                                  ;if EMPTY(f18_start_print(NIL, @__print_opt))      ;
                                  ; return <x>            ;
                                  ;endif

#xcommand START PRINT RET      =>  ;private __print_opt := NIL ;
                                  ;if EMPTY(f18_start_print(NIL, @__print_opt))      ;
                                  ;  return NIL             ;
                                  ;endif


#command START PRINT CRET DOCNAME <y>    =>  PRIVATE __print_opt := NIL ;
                                             ;if !StartPrint(nil, nil, <y>)    ;
                                             ;my_close_all_dbf()             ;
                                             ;return                ;
                                             ;endif

#command START PRINT CRET <x> DOCNAME  <y> => ;private __print_opt := NIL ;
                                  ;if !StartPrint(nil, nil, <y>  )  ;
                                  ;my_close_all_dbf()             ;
                                  ;return <x>            ;
                                  ;endif


#command STARTPRINTPORT CRET <p>, <x> =>  PRIVATE __print_opt := NIL ;
                                        ;IF !SPrint2(<p>)       ;
                                        ;my_close_all_dbf()             ;
                                        ;return <x>            ;
                                        ;endif

#command STARTPRINTPORT CRET <p>   => PRIVATE __print_opt := NIL ;
                                     ;if !Sprint2(<p>)          ;
                                     ;my_close_all_dbf()        ;
                                     ;return <p>               ;
                                     ;endif

#command END PRN2 <x> => Eprint2(<x>)
#command ENDPRN2 <x> => Eprint2(<x>)

#command END PRN2     => Eprint2()
#command ENDPRN2     => Eprint2()


#command END PRINT => f18_end_print(NIL, __print_opt)

#command ENDPRINT => f18_end_print(NIL, __print_opt)

#command EOF CRET <x> =>  if EofFndret(.T., .T.)       ;
                          ;return <x>                  ;
                          ;endif

#command EOF CRET     =>  if EofFndret(.T., .T.)         ;
                          ;return .F.                     ;
                          ;endif

#command EOF RET <x> =>   if EofFndret(.T., .F.)    ;
                          ; return <x>               ;
                          ;endif

#command EOF RET     =>   if EofFndret(.T., .F.)          ;
                          ;    return .F.                 ;
                          ;endif

#command NFOUND CRET <x> =>  if EofFndret(.F., .T.)      ;
                             ;    return <x>             ;
                             ;endif

#command NFOUND CRET     =>  if EofFndret(.F., .T.)        ;
                             ;   return .F.                ;
                             ;endif

#command NFOUND RET <x> =>  if EofFndret(.F., .F.)       ;
                            ;   return  <x>             ;
                            ;endif

#command NFOUND RET     =>  if EofFndret(.F., .F.)       ;
                            ;   return  .F.              ;
                            ;endif

#define SLASH  HB_OSPATHSEPARATOR()

#DEFINE DRVPATH ":\"

#define NRED chr(13)+chr(10)

#define P_NRED QOUT()

#xcommand DO WHILESC <exp>      => while <exp>                     ;
                                   ;if inkey()==27                 ;
                                   ; dbcloseall()                  ;
                                   ;   SET(_SET_DEVICE,"SCREEN")   ;
                                   ;   SET(_SET_CONSOLE,"ON")      ;
                                   ;   SET(_SET_PRINTER,"")        ;
                                   ;   SET(_SET_PRINTFILE,"")      ;
                                   ;   MsgC()                      ;
                                   ;   return                      ;
                                   ;endif

#command KRESI <x> NA <len> =>  <x>:=left(<x>,<len>)

// Force reread/redisplay of all data rows
#define DE_REF      12

#command DEL2                                                            ;
      => (nArr)->(DbDelete2())                                            ;
        ;(nTmpArr)->(DbDelete2())

#define DBFBASEPATH "C:" + SLASH +  "SIGMA"

#define P_KUMPATH  1
#define P_SIFPATH  2
#define P_PRIVPATH 3
#define P_TEKPATH  4
#define P_MODULPATH  5
#define P_KUMSQLPATH 6
#define P_ROOTPATH 7
#define P_EXEPATH 8
#define P_SECPATH 9

#command @ <row>, <col> GETB <var>                                      ;
                        [PICTURE <pic>]                                 ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [SEND <msg>]                                    ;
                                                                        ;
      => SetPos( m_x+<row>, m_y+<col> )                                 ;
       ; AAdd(                                                          ;
               GetList,                                                 ;
               _GET_( <var>, <(var)>, <pic>, <{valid}>, <{when}> )      ;
             )                                                          ;
      [; ATail(GetList):<msg>]



#command @ <row>, <col> SAYB <sayxpr>                                   ;
                        [<sayClauses,...>]                              ;
                        GETB <var>                                      ;
                        [<getClauses,...>]                              ;
                                                                        ;
      => @ <row>, <col> SAYB <sayxpr> [<sayClauses>]                    ;
       ; @ Row(), Col()+1 GETB <var> [<getClauses>]



#command @ <row>, <col> SAYB <xpr>                                      ;
                        [PICTURE <pic>]                                 ;
                        [COLOR <color>]                                 ;
                                                                        ;
      => DevPos( m_x+<row>, m_y+<col> )                                 ;
       ; DevOutPict( <xpr>, <pic> [, <color>] )

#command SET MRELATION                                                  ;
         [<add:ADDITIVE>]                                               ;
         [TO <key1> INTO <(alias1)> [, [TO] <keyn> INTO <(aliasn)>]]    ;
                                                                        ;
      => if ( !<.add.> )                                                ;
       ;    dbClearRel()                                                ;
       ; end                                                            ;
                                                                        ;
       ; dbSetRelation( <(alias1)>,{||'1'+<key1>}, "'1'+"+<"key1"> )      ;
      [; dbSetRelation( <(aliasn)>,{||'1'+<keyn>}, "'1'+"+<"keyn"> ) ]


#command POCNI STAMPU   => if !lSSIP99 .and. !StartPrint()       ;
                           ;my_close_all_dbf()             ;
                           ;return                ;
                           ;endif

#command ZAVRSI STAMPU  => if !lSSIP99; EndPrint(); endif


#command APPEND NCNL    =>  appblank2(.f.,.f.)

#command APPEND BLANKS  => appblank2()

#command MY_DELETE      =>    delete2()



#command AP52 [FROM <(file)>]                                         ;
         [FIELDS <fields,...>]                                          ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [VIA <rdd>]                                                    ;
         [ALL]                                                          ;
                                                                        ;
      => __dbApp(                                                       ;
                  <(file)>, { <(fields)> },                             ;
                  <{for}>, <{while}>, <next>, <rec>, <.rest.>, <rdd>    ;
                )
