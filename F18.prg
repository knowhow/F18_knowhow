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

static cHostName := "localhost"
static nPort := 5433
static cUser := "admin"
static cPassWord := "admin"
static cDataBase := "demo_db1"
static cDBFDataPath := ""
static cSchema := "public"
static oServer := NIL
static cF18Home := NIL

function Main(...)

? "hernad settings"
cHostName :=  "localhsot"
nPort := 5433
cDatabase := "quick38"
? "------ brisi ovo na drugom racunaru !!!! ----"


//function Main(cKorisn, cSifra, p3, p4, p5, p6, p7)

set_f18_params( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10 )

init_f18_app(cHostName, cDatabase, cUser, cPassword, nPort, cShema)

// ~/.F18/
cF18HomeDir := get_f18_home_dir()

/*
PUBLIC gTabele:={ ;
  { F_SUBAN, "fin_suban"  ,  "fmk.fin_suban", "fmk.sem_ver_fin_suban"},;
  { F_KONTO, "konto"  ,  "fmk.konto", "fmk.sem_ver__konto"},;
  { F_PARTN, "partn"  ,  "fmk.partn", "fmk_sem_ver__partn"};
}
*/


MainFin(cKorisn, cSifra, p3, p4, p5, p6, p7)

return

// ---------------
// ~/.F18/
// ---------------
function my_home()

return cF18HomeDir
