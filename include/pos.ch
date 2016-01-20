#ifndef F18_DEFINED
  #include "f18.ch"
#endif

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
#define I_ID         1
#define I_ID2        2

//#define PICT_POS_ARTIKAL "@K"
#define PICT_POS_ARTIKAL "@!S10"

                    
