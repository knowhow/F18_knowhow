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

#include "inkey.ch"
#include "getexit.ch"
#include "box.ch"
#include "dbedit.ch"
#include "achoice.ch"

#include "hbclass.ch"
#include "fileio.ch"

#require "rddsql.ch"
#require "sddpg.ch"

#include "dbinfo.ch"
#include "error.ch"
#include "fileio.ch"
#include "hbclass.ch"


#include "set.ch"
#include "hbgtinfo.ch"
#include "common.ch"
#include "dbstruct.ch"
#include "setcurs.ch"
#include "dbedit.ch"

#include "hbthread.ch"

#include "o_f18.ch"
#include "f_f18.ch"
#include "f18_separator.ch"
#include "f18_rabat.ch"
#include "f18_ver.ch"
#include "f18_request.ch"
#include "f18_cre_all.ch"

#include "memoedit.ch"


#define F18_DEFAULT_LOG_LEVEL_DEBUG 9
#define F18_DEFAULT_LOG_LEVEL       3

#define INFO_BAR_ROWS             3
#define INFO_PANEL_COLOR           "GR+/B,R/N+,,,N/W"
#define ERROR_PANEL_COLOR          "N/W,R/N+,,,R/B+"
#define F18_COLOR_P1               "GR+/N"
#define F18_COLOR_NORMAL           "W/B,R/N+,,,N/W"
#define F18_COLOR_NORMAL_BW        "W/N,N/W,,,N/W"
#define F18_COLOR_INVERT           "N/W,R/N+,,,R/B+"

#define INFO_MESSAGES_LENGTH       40
#define ERROR_MESSAGES_LENGTH      40

#xcommand LOG_CALL_STACK <cLogStr>                 ;
  => FOR nI := 1 TO 30                             ;
    ;  IF !Empty( ProcName( nI ) )                 ;
    ;   cMsg := Str( nI, 3 ) + " " + ProcName( nI ) + " / " + AllTrim( Str( ProcLine( nI ), 6 ) ) ;                       ;
    ;   <cLogStr> := <cLogStr> + " // " + cMsg    ;
    ;  END                                        ;
    ; NEXT

#define FIELD_LEN_KALK_BRDOK  8
#define FIELD_LEN_KALK_RBR    3

#ifndef TEST
  #ifndef F18_RELEASE_DEFINED
      #include "f18_release.ch"
  #endif
#else
  #ifndef F18_TEST_DEFINED
      #include "f18_test.ch"
  #endif
#endif

#define CHR254   254
#define D_STAROST_DANA   25


// #define BOX_CHAR_BACKGROUND Chr( 176 )
#define BOX_CHAR_BACKGROUND Chr( 177 )
#define BOX_CHAR_BACKGROUND_HEAD " "

#define oF_ERROR_MIN          1
#define oF_CREATE_OBJECT      1
#define oF_OPEN_FILE          2
#define oF_READ_FILE          3
#define oF_CLOSE_FILE         4
#define oF_ERROR_MAX          4
#define oF_DEFAULT_READ_SIZE  4096


#define K_UNDO          K_CTRL_U
// format of array used to preserve state variables
#define GSV_KILLREAD  1
#define GSV_BUMPTOP  2
#define GSV_BUMPBOT  3
#define GSV_LASTEXIT  4
#define GSV_LASTPOS  5
#define GSV_ACTIVEGET  6
#define GSV_READVAR   7
#define GSV_READPROCNAME 8
#define GSV_READPROCLINE 9

#define GSV_COUNT  9



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
#define SEMAPHORE_LOCK_RETRY_NUM 10

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


// F18.log, F18_2.log, F18_3.log ...
#define F18_LOG_FILE "F18.log"
#define OUTF_FILE "outf.txt"
#define OUT_ODT_FILE "out.odt"
#define DATA_XML_FILE "data.xml"

#command QUIT_1                    => ErrorLevel(1); Altd(); __Quit()

#command @ <row>, <col> SAY8 <exp> [PICTURE <pic>] [COLOR <clr>] => ;
         DevPos( <row>, <col> ) ; DevOutPict( hb_utf8toStr( <exp> ), <pic> [, <clr>] )
#command @ <row>, <col> SAY8 <exp> [COLOR <clr>] => ;
         DevPos( <row>, <col> ) ; DevOut( hb_utf8toStr( <exp> ) [, <clr>] )

#command @ <row>, <col> SAY8 <say> [<sayexp,...>] GET <get> [<getexp,...>] => ;
         @ <row>, <col> SAY8 <say> [ <sayexp>] ;;
         @ Row(), Col() + 1 GET <get> [ <getexp>]


#command ?U  [<explist,...>]         => QOutU( <explist> )
#command ??U [<explist,...>]         => QQOutU( <explist> )
#translate _ue( <arg> )              => hb_UTF8ToStr( <arg> )

#command RREPLACE <f1> WITH <v1> [, <fN> WITH <vN> ]    ;
      => my_rlock();
         ;   _FIELD-><f1> := <v1> [; _FIELD-><fN> := <vN>];
         ;my_unlock()


#define EXEPATH   my_home_root()
#define SIFPATH   my_home()

#define PRIVPATH  my_home()

#define KUMPATH   my_home()
#define CURDIR    my_home()

#define I_ID 1
#define DE_ADD  5
#define DE_DEL  6


#define RECI_GDJE_SAM   PROCNAME(1) + " (" + ALLTRIM(STR(PROCLINE(1))) + ")"
#define RECI_GDJE_SAM0  PROCNAME(0) + " (" + ALLTRIM(STR(PROCLINE(0))) + ")"

#command ESC_EXIT  => if lastkey()=K_ESC;
                      ;exit             ;
                      ;endif

#command ESC_RETURN <x> => if lastkey()=K_ESC;
                           ; altd()          ;
                           ;return <x>       ;
                           ;end

#command ESC_RETURN    => if lastkey()=K_ESC;
                           ; altd()         ;
                           ;return          ;
                           ;end

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


#command ?C  [ <xList,...> ] => ( OutStd( hb_eol() ) [, OutStd( <xList> ) ] )
#command ??C [ <xList,...> ] => OutStd( <xList> )

#command ?E  [ <xList,...> ] => ( OutErr( hb_eol() ) [, OutErr( <xList> ) ] )
#command ??E [ <xList,...> ] => OutErr( <xList> )

// ----- fin.ch ------------
#define D_FI_VERZIJA "0.9.0"
#define D_FI_PERIOD "11.94-25.11.11"
#define DABLAGAS lBlagAsis .and. _IDVN == cBlagIDVN

// ------- ld.ch -----------
#define D_LD_VERZIJA "0.2.0"
#define D_LD_PERIOD "06.96-10.11.11"

#define RADNIK radn->(PADR(TRIM(naz)+" ("+TRIM(imerod)+") "+ime,35))
#define RADNZABNK radn->(PADR(TRIM(naz)+" ("+TRIM(imerod)+") "+TRIM(ime), 40))

// ------ epdv ---------
#define D_EPDV_VERZIJA "0.2.0"
#define D_EPDV_PERIOD "06.04-10.11.11"


// ------- fakt --------------
#define D_FAKT_VERZIJA "0.3.0"
#define D_FAKT_PERIOD "11.94-19.11.11"

#define __g10Str2T g10Str2T
#define __g10Str g10Str

#define FAKT_DOKS_PARTNER_LENGTH 100

// --------- os --------------
#define D_OS_VERZIJA "0.2.0"
#define D_OS_PERIOD "06.98-10.11.11"

// -------- mat ------------------
#define D_MAT_VERZIJA "0.2.0"
#define D_MAT_PERIOD "06.98-10.11.11"


// ------ POS ---------
#define D_POS_VERZIJA "0.2.0"
#define D_POS_PERIOD "06.95-10.11.11"

// definicija korisnickih nivoa
#define L_SYSTEM           "0"
#define L_ADMIN            "0"
#define L_UPRAVN           "1"
#define L_UPRAVN_2         "2"
#define L_PRODAVAC         "3"

// ulaz / izlaz roba /sirovina
#define R_U       "1"           // roba - ulaz
#define R_I       "2"           //      - izlaz
#define S_U       "3"           // sirovina - ulaz
#define S_I       "4"           //          - izlaz
#define SP_I      "I"           // inventura - stanje
#define SP_N      "N"           // nivelacija

// vrste dokumenata
#define VD_RN        "42"       // racuni
#define VD_ZAD       "16"       // zaduzenje
#define VD_OTP       "95"       // otpis
#define VD_REK       "98"       // reklamacija
#define VD_INV       "IN"       // inventura
#define VD_NIV       "NI"       // nivelacija
#define VD_RZS       "96"       // razduzenje sirovina-otprema pr. magacina
#define VD_PCS       "00"       // pocetno stanje
#define VD_PRR       "01"       // prenos realizacije iz prethodnih sezona
#define VD_CK        "90"       // dokument cek
#define VD_SK        "91"       // dokument sindikalni kredit
#define VD_GP        "92"       // dokument garatno pismo
#define VD_PP        "88"       // dokument polog pazara
#define VD_ROP       "99"       // reklamacije ostali podaci

#define DOK_ULAZA "00#16"
#define DOK_IZLAZA "42#01#96#98"

// vrste zaduzenja
#define ZAD_NORMAL   "0"
#define ZAD_OTPIS    "1"

// flagovi da li je slog sa kase prebacen na server
#define OBR_NIJE     "1"
#define OBR_JEST     "0"

// flagovi da li je racun placen
#define PLAC_NIJE    "1"
#define PLAC_JEST    "0"

// ako ima potrebe, brojeve zaokruzujemo na
#define N_ROUNDTO    2
//#define I_ID         1
#define I_ID2        2

//#define PICT_POS_ARTIKAL "@K"
#define PICT_POS_ARTIKAL "@!S10"

// ----------rnal -------------------
#define D_RNAL_VERZIJA "0.2.0"
#define D_RNAL_PERIOD "06.08-08.11.11"

// -------- kalk --------------------
#define D_KALK_VERZIJA "0.7.0"
#define D_KALK_PERIOD "11.94-24.11.11"

// -----------------------------

#DEFINE DRVPATH ":\"
