#Define NTXCDX ".Cdx"
#include "inkey.ch"
#include "S_win.ch"
///////////////////////////////////////////////////////////////////////////
Function OpenDbf_(cDataBase,Status,cAlias,nSeconds,lPrint)
Local nRecno, nLastRec, i, nPos, cDir := "", aFile := {}
aadd(aFile, {{"OTPU","========= Отпускная записка ============="},;
             {{"OTPU","str(Cex,4)+str(Tnr,6)",.f.}},;
             { {"Npach",  "N",02,00,"Число на которые выдаются отпускные"},;
               {"DataR",  "D",08,00,"Дата расчета"},;
               {"Cex",    "N",04,00,"Цех"},;
               {"Tnr",    "N",06,00,"Табельный No"},;
               {"Data",   "D",08,00,"Дата начала отпуска"},;
               {"Kdn",    "N",03,00,"Кол-во дней отпуска"},;
               {"SredSum","N",15,00,"Среднедневной"},;
               {"Po",     "N",01,00,"Признак отпуска"},;
               {"Pr",     "N",01,00,"Признак выплаты"},;
               {"Priz",   "N",01,00,"Признак расчета"},;
               {"Vo1",    "N",03,00,"Код оплаты 1 мес-ц"},;
               {"Dat1",   "N",02,00,"Дата начало отпуска 1 мес-ц"},;
               {"Kd1",    "N",02,00,"Кол-во дней отпуска в 1 мес-це"},;
               {"Sym1",   "N",15,00,"Сумма за 1 мес-ц"},;
               {"Vo2",    "N",03,00,"Код оплаты 2 мес-ц"},;
               {"Dat2",   "N",02,00,"Дата начало отпуска 2 мес-ц"},;
               {"Kd2",    "N",02,00,"Кол-во дней отпуска в 2 мес-це"},;
               {"Sym2",   "N",15,00,"Сумма за 2 мес-ц"},;
               {"Vo3",    "N",03,00,"Код оплаты 3 мес-ц"},;
               {"Dat3",   "N",02,00,"Дата начало отпуска 3 мес-ц"},;
               {"Kd3",    "N",02,00,"Кол-во дней отпуска в 3 мес-це"},;
               {"Sym3",   "N",15,00,"Сумма за 3 мес-ц"},;
               {"Sym12",  "N",15,00,"Сумма за 12 мес"},;
               {"SymKAS", "N",15,00,"Сумма выплаченная в кассу"}}})
aadd(aFile, {{"SPRKO","========= Справ коэф отпуска ============="},;
             {{"SPRKO","dtos(DataC)",.f.}},;
             { {"DataC",  "D",08,00,"Дата с"},;
               {"DataP",  "D",08,00,"Дата по"},;
               {"Kf",     "N",06,03,"Коеффициент"}}})
aadd(aFile, {{"NEZARP","========= Не выданная зарплата ============="},;
             {{"NEZARP","str(Ksp,4)+str(Tnr,6)",.f.}},;
             { {"Ksp",    "N",04,00,"Цех"},;
               {"Tnr",    "N",06,00,"табельный номер"},;
               {"SumNach","N",15,00,"Сумма начислено"},;
               {"SumYd",  "N",15,00,"Сумма удержано"},;
               {"SumNar", "N",15,00,"Сумма на руки"}}})
aadd(aFile, {{"SPRKB","========= Справ коэф больничных ============="},;
             {{"SPRKB","dtos(DataC)",.f.}},;
             { {"DataC",  "D",08,00,"Дата с"},;
               {"DataP",  "D",08,00,"Дата по"},;
               {"Kf",     "N",06,03,"Коеффициент"}}})
aadd(aFile, {{"BOL","========= Больничные листы ============="},;
             {{"BOL","str(Bl,8)",.f.}},;
             { {"Bl",     "N",08,00,"No больничного лита"},;
               {"Tnr",    "N",06,00,"Табельный номер"},;
               {"Dt",     "D",08,00,"Дата расчета БЛ"},;
               {"DtBol",  "D",08,00,"Дата БЛ"},;
               {"Cex",    "N",04,00,"Цех"},;
               {"Dni1",   "N",08,02,"Дни/часы 1 месяца"},;
               {"Dni2",   "N",08,02,"Дни/часы 2 месяца"},;
               {"Kvo",    "N",03,00,"КВО"},;
               {"Gr",     "N",01,00,"Группа болезни"},;
               {"Vr",     "N",02,00,"Вид расчета"},;
               {"Proz",   "N",03,00,"% оплаты"},;
               {"Tm",     "N",06,02,"Часы/дни"},;
               {"Sum1",   "N",15,00,"сумма 1 месяца"},;
               {"Sum2",   "N",15,00,"сумма 2 месяца"},;
               {"SrZar",  "N",15,00,"средний заработок"},;
               {"Tarif",  "N",15,00,"тариф"},;
               {"SumN",   "N",15,00,"Сумма начислено"}}})

aadd(aFile, {{"NAKNACH","========= Архив начислений ============="},;
             {{"NAKNACH","str(TN,6)+str(d_Nach,6)+Vo",.f.}},;
             { {"Tn",     "N",06,00,"Табельный номер"},;
               {"D_Vip",  "N",06,00,"Дата расчета "},;
               {"D_Nach", "N",06,00,"Дата начисления"},;
               {"Vo",     "C",03,00,"Вид оплаты"},;
               {"Dn",     "N",08,02,"Дни/часы "},;
               {"Sum",    "N",15,02,"Сумма начислено"}}})
                        
aadd(aFile, {{"NAKYD","========= Архив Удержаний ============="},;
             {{"NAKYD","str(TN,6)+str(D_Yd,6)",.f.}},;
             { {"Tn",     "N",06,00,"Табельный номер"},;
               {"D_Yd",   "N",06,00,"Дата удержания "},;
               {"OblSum", "N",15,02,"Облагаемая сумма"},;
               {"NOblSum","N",15,02,"Не облагаемая сумма"},;
               {"Kvu1",   "C",03,00,"Вид удержания"},;
               {"SumYd1", "N",15,02,"Сумма ужердания "},;
               {"Kvu2",   "C",03,00,"Вид удержания"},;
               {"SumYd2", "N",15,02,"Сумма ужердания "},;
               {"Kvu3",   "C",03,00,"Вид удержания"},;
               {"SumYd3", "N",15,02,"Сумма ужердания "},;
               {"Kvu4",   "C",03,00,"Вид удержания"},;
               {"SumYd4", "N",15,02,"Сумма ужердания "},;
               {"Kvu5",   "C",03,00,"Вид удержания"},;
               {"SumYd5", "N",15,02,"Сумма ужердания "},;
               {"Kvu6",   "C",03,00,"Вид удержания"},;
               {"SumYd6", "N",15,02,"Сумма ужердания "},;
               {"Kvu7",   "C",03,00,"Вид удержания"},;
               {"SumYd7", "N",15,02,"Сумма ужердания "},;
               {"Kvu8",   "C",03,00,"Вид удержания"},;
               {"SumYd8", "N",15,02,"Сумма ужердания "},;
               {"Kvu9",   "C",03,00,"Вид удержания"},;
               {"SumYd9", "N",15,02,"Сумма ужердания "},;
               {"Kvu10",  "C",03,00,"Вид удержания"},;
               {"SumYd10","N",15,02,"Сумма ужердания "},;
               {"Kvu11",  "C",03,00,"Вид удержания"},;
               {"SumYd11","N",15,02,"Сумма ужердания "},;
               {"Kvu12",  "C",03,00,"Вид удержания"},;
               {"SumYd12","N",15,02,"Сумма ужердания "}}})
               
aadd(aFile, {{"NAL","========= Налоги ============="},;
             {{"NAL","str(DatG,6)",.f.}},;
             { {"DatG",   "N",06,00,"Дата"},;
               {"Min",    "N",07,02,"Необлагаемый минимум"},;
               {"S1_1",   "N",09,02,"Интервал от "},;
               {"S2_1",   "N",09,02,"Интервал до "},;
               {"Pr_1",   "N",09,02,"% отчисления"},;
               {"Sd_1",   "N",09,02,"минус сумма "},;
               {"S1_2",   "N",09,02,"Интервал от "},;
               {"S2_2",   "N",09,02,"Интервал до "},;
               {"Pr_2",   "N",09,02,"% отчисления"},;
               {"Sd_2",   "N",09,02,"минус сумма "},;
               {"S1_3",   "N",09,02,"Интервал от "},;
               {"S2_3",   "N",09,02,"Интервал до "},;
               {"Pr_3",   "N",09,02,"% отчисления"},;
               {"Sd_3",   "N",09,02,"минус сумма "},;
               {"S1_4",   "N",09,02,"Интервал от "},;
               {"S2_4",   "N",09,02,"Интервал до "},;
               {"Pr_4",   "N",09,02,"% отчисления"},;
               {"Sd_4",   "N",09,02,"минус сумма "},;
               {"S1_5",   "N",09,02,"Интервал от "},;
               {"S2_5",   "N",09,02,"Интервал до "},;
               {"Pr_5",   "N",09,02,"% отчисления"},;
               {"Sd_5",   "N",09,02,"минус сумма "},;
               {"S1_6",   "N",09,02,"Интервал от "},;
               {"S2_6",   "N",09,02,"Интервал до "},;
               {"Pr_6",   "N",09,02,"% отчисления"},;
               {"Sd_6",   "N",09,02,"минус сумма "},;
               {"S1_7",   "N",09,02,"Интервал от "},;
               {"S2_7",   "N",09,02,"Интервал до "},;
               {"Pr_7",   "N",09,02,"% отчисления"},;
               {"Sd_7",   "N",09,02,"минус сумма "},;
               {"S1_8",   "N",09,02,"Интервал от "},;
               {"S2_8",   "N",09,02,"Интервал до "},;
               {"Pr_8",   "N",09,02,"% отчисления"},;
               {"Sd_8",   "N",09,02,"минус сумма "},;
               {"S1_9",   "N",09,02,"Интервал от "},;
               {"S2_9",   "N",09,02,"Интервал до "},;
               {"Pr_9",   "N",09,02,"% отчисления"},;
               {"Sd_9",   "N",09,02,"минус сумма "},;
               {"S1_10",  "N",09,02,"Интервал от "},;
               {"S2_10",  "N",09,02,"Интервал до "},;
               {"Pr_10",  "N",09,02,"% отчисления"},;
               {"Sd_10",  "N",09,02,"минус сумма "} }})

aadd(aFile, {{"NALF3","========= Форма 3 ============="},;
             {{"NALF3","str(Tn,6)",.f.}},;
             { {"Tn",     "N",06,00,"Табельный номер"},;
               {"S1",     "N",09,02,"Сумма облаг. 1"},;
               {"S1_1",   "N",09,02,"Сумма мат помощи 1.1"},;
               {"S2_1",   "N",09,02,"Сумма отчисления на детей 2.1"},;
               {"S2_2",   "N",09,02,"Сумма отчисления льготы 2.2"},;
               {"S3",     "N",09,02,"Сумма налога по пересчету"},;
               {"S4",     "N",09,02,"Сумма налога по пересчету"},;
               {"S5",     "N",09,02,"Сумма налога удержанного"},;
               {"S6",     "N",09,02,"Разница"} }})

aadd(aFile, {{"YDPROC","======= Прочие удержания ========"},;
             {{"YDPROCT","str(Tn,6)",.f.},;
              {"YDPROCD","str(Data,6)+str(Tn,6)",.f.}},;
             { {"Tn",     "N",06,00,"Табельный номер"},;
               {"Ksp",    "C",04,00,"Цех "},;
               {"Summa",  "N",09,02,"Сумма удержанная"},;
               {"Data",   "N",06,00,"Дата"},;
               {"Kvu",    "C",03,00,"Код удержания"}}})

aadd(aFile, {{"GIC","========= Коммунальные услуги ======"},;
             {{"Gic","str(Tn,6)+dtos(Data)",.f.}},;
             { {"Tn",     "N",06,00,"Табельный номер"},;
               {"Data",   "D",08,00,"Дата удердания"},;
               {"KodGkx", "N",08,00,"Л/с квартплата"},;
               {"GmGkx",  "N",04,00,"Месяц оплаты"},;
               {"SumGkx", "N",09,02,"Сумма оплаты"},;
               {"KodVkx", "N",08,00,"Л/с Холодная вода"},;
               {"GmVkx",  "N",04,00,"Месяц оплаты"},;
               {"SumVkx", "N",09,02,"Сумма оплаты"},;
               {"KodPtc", "N",08,00,"Л/с Тепло"},;
               {"GmPtc",  "N",04,00,"Месяц оплаты"},;
               {"SumPtc", "N",09,02,"Сумма оплаты"},;
               {"KodGaz", "N",08,00,"Л/с ГАЗ"},;
               {"GmGaz",  "N",04,00,"Месяц оплаты"},;
               {"SumGaz", "N",09,02,"Сумма оплаты"},;
               {"KodEl",  "N",08,00,"Л/с э/энергия"},;
               {"GmEl",   "N",04,00,"Месяц оплаты"},;
               {"SumEl",  "N",09,02,"Сумма оплаты"},;
               {"Zajv",   "N",06,00,"N заявления"},;
               {"DZajv",  "D",08,00,"Дата заявления"} }})

aadd(aFile, {{"GICARX","===== Коммунальные услуги  АРХИВ ======"},;
             {{"GicArx","str(Tn,6)+dtos(Data)",.f.}},;
             { {"Tn",     "N",06,00,"Табельный номер"},;
               {"Data",   "D",08,00,"Дата удердания"},;
               {"KodGkx", "N",08,00,"Л/с квартплата"},;
               {"GmGkx",  "N",04,00,"Месяц оплаты"},;
               {"SumGkx", "N",09,02,"Сумма оплаты"},;
               {"KodVkx", "N",08,00,"Л/с Холодная вода"},;
               {"GmVkx",  "N",04,00,"Месяц оплаты"},;
               {"SumVkx", "N",09,02,"Сумма оплаты"},;
               {"KodPtc", "N",08,00,"Л/с Тепло"},;
               {"GmPtc",  "N",04,00,"Месяц оплаты"},;
               {"SumPtc", "N",09,02,"Сумма оплаты"},;
               {"KodGaz", "N",08,00,"Л/с ГАЗ"},;
               {"GmGaz",  "N",04,00,"Месяц оплаты"},;
               {"SumGaz", "N",09,02,"Сумма оплаты"},;
               {"KodEl",  "N",08,00,"Л/с э/энергия"},;
               {"GmEl",   "N",04,00,"Месяц оплаты"},;
               {"SumEl",  "N",09,02,"Сумма оплаты"},;
               {"Zajv",   "N",06,00,"N заявления"},;
               {"DZajv",  "D",08,00,"Дата заявления"} }})

aadd(aFile, {{"ZAJV","========= N Заявления ======"},;
             {},;
             { {"Zajv",  "N",06,00,"N заявления"}  }})
               
if lPrint <> Nil
  cFile := cDatabase
  if ( nPos := ascan(aFile,{|x| x[1][1]==Upper(cFile)}) ) == 0 ; return ( Nil ) ; End
  Set(20,"PRINT")
  @ prow()+1,00 say "Структура файла: "+cFile+" "+aFile[nPos][1][2]
  @ prow()+1,00 say "-----------------------------------------------------"
  @ prow()+1,00 say " Идентиф.|Форм|Длина|Дес| Наименование               "
  @ prow()+1,00 say "-----------------------------------------------------"
  for i := 1 to len(aFile[nPos][3])
      @ prow()+1,00 say aFile[nPos][3][i][1]
      @ prow(),10 say aFile[nPos][3][i][2]
      @ prow(),15 say aFile[nPos][3][i][3] pict "99"
      @ prow(),20 say aFile[nPos][3][i][4] pict "99"
      @ prow(),25 say aFile[nPos][3][i][5]
  next
  @ prow()+1,00 say "-----------------------------------------------------"
  @ prow()+1,00 say "           Теги:                                     "
  for i := 1 to Len(aFile[nPos][2])
     @ prow()+1,01 say aFile[nPos][2][i][1]+" --------> "+aFile[nPos][2][i][2]
  Next
  @ prow()+1,00 say "  "
  @ prow()+1,00 say "  "
  @ prow()+1,00 say "  "
  @ prow()+1,00 say ""
  Set(20,"SCREEN")
  Return ( Nil )
End 
if cDatabase == Nil .or. empty(cDatabase) ;  return ( .f.)  ;   end
cDir  := S_GetDrive(cDatabase)+S_GetPath(cDatabase)
cFile := S_GetName(cDatabase)
if ( nPos := ascan(aFile,{|x| x[1][1]==Upper(cFile)}) ) == 0 ; return ( .f. ) ; End
if !File(cDir+cFile+".Dbf")
  fErase(cDir+cFile+".Cdx")
  Select 0
  DbCreate(cDir+cFile+".Dbf",aFile[nPos][3])
  Use
End
cAlias := if(cAlias==Nil,cFile,cAlias)
Status:= if(status==Nil,.f.,Status)
nSeconds:= if(nSeconds==Nil,20,nSeconds)
if !M_Use(cDir+cFile,Status,cAlias,nSeconds) ; Return ( .f. ) ; end
nRecno := {}
for i := 1 to Len(aFile[nPos][2])
  aadd(nRecno,{aFile[nPos][2][i][1],aFile[nPos][2][i][2],,aFile[nPos][2][i][3]})
Next
TagCrt(nRecno,cDir+cFile+".Cdx")
SX_SetTagNo(1)
Return ( .t. )
////////////////////////////////////////////////////////////////////////////
Static Function PrnDbf()
Local cName := space(10), cDir := padr(sset[SSET_BAZA],30)

S_Open_S(10,03,12,17,sset[32]+","+sset[2])
While .t.
  @ 01,01 wsay padc(" ",MaxCol()-1)
  @ 01,01 wget cName color sset[2]+","+sset[1]
  read
  if LastKey()==K_ESC ; Exit ; End
  @ 01,01 wsay padc("Следите..",MaxCol()-1)
  OpenDbf_(alltrim(cName),,,,999)
  Set(20,"SCREEN")
End
Set(20,"SCREEN")
S_wClose()
Return ( Nil )
////////////////////////////////////////////////////////////////////////////
Function ZapInf()  // Записи информации
Local nMesR := month(sset[121])  // Месяц расчета
Local cKsp, nRecno, nLastrec, nRec, nS1, nS2, i, im, cVo, cVo_

BEGIN SEQUENCE
if !OpenDbf_("NEZARP")       ; break ; End
if !OpenList()               ; break ; End
if !M_Use("ssp",,,,"DBFNTX") ; break ; End

nLastRec := ssp->(LastRec())
ssp->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Делаю запись информации"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
While ( !ssp->(eof()) )
   cKsp := ssp->ksp
   cVo := "Seba"+cKsp
   use (cVo) new alias Seba
   cVo := "Base"+cKsp
   use (cVo) new alias Base
   Base->(DbGotop())
   While !Base->(eof())
     if Base->Tn <> "******" .and. Base->Ys <> "+"
        if !SuperLis->(DbSeek(Base->Tn))
           S_Err({"Табельный номер - "+Base->Tn,"Отсутствует в справочнике"})
        else
           nRec := SuperLis->Base_Rec   // No записи в BASE
           if Base->(Recno()) <> nRec
             S_Err({"Табельный номер - "+Base->Tn,"Не совподает N записи"})
           Else
            seba->(DbGoto((nRec-1)*12+nMesR))
            nS1 := nS2 := 0
            for i := 1 to 12
               im := alltrim(str(i,2))
               cVo := "Vo"+im
               Seba->&cVo   := Base->&cVo
               cVo := "Svon"+im
               Seba->&cVo   := Base->&cVo
               ns1 += Base->&cVo
               cVo := "Kmn"+im
               Seba->&cVo   := Base->&cVo
               cVo := "DnCh"+im
               cVo_:= "Dn"+im
               Seba->&cVo  := Base->&cVo_/100
               cVo := "Sku"+im
               ns2 += Base->&cVo
            Next
            if !Nezarp->(Dbseek(str(val(ssp->Ksp),4)+str(val(Base->Tn),6))) .and. ;
                                                 M_Append(20,"Nezarp")
               Nezarp->Ksp := val(ssp->Ksp)
               Nezarp->Tnr := val(Base->Tn)
               Nezarp->(DbUnlock())
           End
           if M_Rlock(20,"Nezarp")
              Nezarp->SumNach := nS1
              Nezarp->SumYd   := nS2
              Nezarp->SumNar  := Nezarp->SumNach - Nezarp->SumYd
              Nezarp->(DbUnlock())
           End
          End
        End
     End
     Base->(DbSkip(1))
   End
   Base->(DbCloseArea())
   Seba->(DbCloseArea())
   S_Line_N(18,04,65,nLastRec,++nRecno)
   ssp->(DbSkip(1))
End
S_Beep(3)
S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
function ZapNeVud() // запись не выданной з/п
local nMesR := substr(dtos(sset[121]),5,2), nRecno, nLastrec
Local i, im, cVo, nRec

BEGIN SEQUENCE
if !OpenDbf_("NEZARP")       ; break ; End
if !OpenList()               ; break ; End
if !M_Use("ssp",,,,"DBFNTX") ; break ; End

nLastRec := NeZarp->(LastRec())
ssp->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Делаю запись информации"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
While ( !Nezarp->(eof()) )
  cTn := strzero(Nezarp->Tnr,6)
  if !SuperLis->(DbSeek(cTn))
    S_Err({"Табельный номер - "+cTn,"Отсутствует в справочнике"})
  else
   cVo  := "Base"+SuperLis->Ksp
   nRec := SuperLis->Base_Rec   // No записи в BASE
   use (cVo) new alias Base
   Base->(DbGoTo(nRec))
   for i := 1 to 12
       im := Alltrim(str(i,2))
       cVo := "Vo"+im
       if Empty(Base->&cVo)
         Base->&cVo := "380"
         cVo := "Svon"+im
         Base->&cVo := Nezarp->SumNar
         cVo := "Kmn"+im
         Base->&cVo := nMesR
         Exit
       End
   Next
   Base->(DbCloseArea())
  End
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Nezarp->(DbSkip(1))
End
S_Beep(3)
S_Line_N()
END SEQUENCE
DbCloseall()
//////////////////////////////////////////////////////////////////////////
function ZipBase() // Чистка базы

BEGIN SEQUENCE
if !OpenDbf_("NEZARP",.t.) ; break ; End
NEZARP->(__DbZap())
NEZARP->(DbCloseArea())

if !OpenDbf_("OTPU",.t.) ; break ; End
Otpu->(__DbZap())
Otpu->(DbCloseArea())

if !OpenDbf_("BOL",.t.) ; break ; End
Bol->(__DbZap())
Bol->(DbCloseArea())
END SEQUENCE
DbCloseall()
//////////////////////////////////////////////////////////////////////////
Function FreshOrder(o)
local nRec := recno()
o:RefReshAll()
While ( !o:stabilize() ) ; end
return ( Nil )
/////////////////////////////////////////////////////////////////////////
