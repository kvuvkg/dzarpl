#include "inkey.ch"
#include "S_win.ch"
//////////////////////////////////////////////////////////////////////////
Local oMen, omenMain,key, cDir, NameExe
Public PathVipZap := "c:\KomPens\"
Set Procedure to Pokaztl.prg
Set Procedure to Otpusk.prg
Set Procedure to Bolnica.prg
Set Procedure to PublFunc.prg
Set Procedure to PlVed.prg
Set Procedure to DopZarp.prg
Set Procedure to Gic.prg
Set(26,.f.)                      // ─┐
Set(32,.f.)                      //  │  Смотрите документацию
Set(4,"dd.mm.yyyy")              //  ├─ по Clipper 5.0
Set(11,.t.)                      //  │
Set(9,.f.)                       //  │
SetBlink(.t.)                    // ─┘
aSize(sset,125)
sset[121] := date() // Дата расчета
sset[122] := 0      // минимальная з/п
SetColor(sset[86] := "n/w")
ErrorBlock( { |ObjError| ErrorSys(ObjError) } )
DeskTop := oKMouseNew()
oNorton := oNortonNew()
DeskTop:Norton := oNorton
DeskTop:Open()
S_cls("░")
@ 00,00 say padc(" ",80)
@ 00,57 say "Время:"
ShowTime(0,64,.F.,"n/w")
S_Nil_Key()
S_SetKey(K_CTRL_F9, { |x| x := Set(4,"dd.mm.yy"),;
                          S_Calend(3,50),;
                          Set(4,x) },"Календ" )
S_SetKey(K_CTRL_F10, { | |S_Calc() },"Калькул" )
oMen := MainMenu()
BEGIN SEQUENCE
omen:refAll()
ReadData()
// Сделать копию головного обьекта
omenMain:=omen
While .T.
  key := S_InKey(0)
  do Case
     case omen == omenMain .and. key == K_ESC
       S_Beep()
       if S_Err({18,28,"Закончить работу?","% Нет ;  Да ; "}) == 2
           omen:close()
           exit
        else
           loop
        end
  End
  omen:work(key,@omen)
End
END SEQUENCE
ShowTime()
DbCloseAll()
S_cls(" ")
quit
return ( Nil )
//////////////////////////////////////////////////////////////
Static Function MainMenu()
Local oPrompt,omenu0,omenu,i,j := 0

// МЕНЮ 0    >>>>>>>>>>>>>>> ГЛАВНОЕ <<<<<<<<<<<<<<<
omen0:=oMenuNew( 2, 0, .F.     ,;
               {"Сервис ",;
                "Отпуск ",;
                "Больничные ",;
                "Пл./ведомость ",;
                "Налоговая ",;
                "Коммунальные ",;
                " Выxод  "})
oprompt1:=oPromptNew(24,0,80)
oprompt1:Color := {"n/w","n/w"}
omen0:Prompt:=oPrompt1
omen0:addPrompt(++j," Сервисные функции")
omen0:addPrompt(++j," Функции по расчету отпускных")
omen0:addPrompt(++j," Функции по расчету больничных")
omen0:addPrompt(++j," Функции по платежным ведомостям")
omen0:addPrompt(++j," Функции по сношению с налоговой администрации")
omen0:addPrompt(++j," Функции по ведению коммунальных услуг")
omen0:addPrompt(++j,"Выход из программы")
omen0:block(j,{||Mquit()})
j := 0
//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("Дата расчета")
omen:addPrompt(++i,"Ввод даты расчета")
omen:block(i,{ || ReadData(1) })

omen:add("Накопление")
omen:addPrompt(++i,"Накопление")
omen:block(i,{ || ZapInf() })

omen:add("Чистка базы")
omen:addPrompt(++i,"Чистка базы")
omen:block(i,{ || ZipBase() })

omen:add("Минимальная З/пл")
omen:addPrompt(++i,"Минимальная заработная плата")
omen:block(i,{ || ReadData(2) })

omen:add("Запись не выданной з/пл")
omen:addPrompt(++i,"Запись не выданной з/пл ")
omen:block(i,{ || ZapNeVud() })

omen:add("Индексация з/пл")
omen:addPrompt(++i,"Индексирование заработной платы ")
omen:block(i,{ || IndexZp() })

omen:add("Компенсация з/пл")
omen:addPrompt(++i,"Компенсация заработной платы ")
omen:block(i,{ || Kompens() })

omen:add("Удаление информации")
omen:addPrompt(++i,"Удаление информации из базы NakNach и NakYd ")
omen:block(i,{ || PackArx() })

omen:add("Удаление компенсации")
omen:addPrompt(++i,"Удаление компенсации из базы  ")
omen:block(i,{ || DelKomp() })

omen:add("Ведение коеффициента на компенсацию з/пл")
omen:addPrompt(++i,"Ведение коеффициента на компенсацию з/пл")
omen:block(i,{ || VedKomp() })

omen:add("Сумма из начисленной з/пл")
omen:addPrompt(++i,"Сумма из начисленной з/пл ")
omen:block(i,{ || Fornak() })

omen:add("Сумма из удерженой з/пл")
omen:addPrompt(++i,"Сумма из удерженой з/пл ")
omen:block(i,{ || Fornaky() })


omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("Ввод отпускных")
omen:addPrompt(++i,"Ввод отпускных")
omen:block(i,{ || VvodOtp() })

omen:add("Расчет")
omen:addPrompt(++i,"Расчет отпускных")
omen:block(i,{ || RaschO() })

omen:add("Печать плат отпуск")
omen:addPrompt(++i,"Печать плат отпуск")
omen:block(i,{ || PrnVedO() })

omen:add("Запись информации")
omen:addPrompt(++i,"Перенос начисленных отпускных в лицевые счета")
omen:block(i,{ || ZapInfO() })

omen:add("Справ коэф отпуска")
omen:addPrompt(++i,"Справ коэф отпуска")
omen:block(i,{ || VvodSprO() })

omen:add("Ведомость")
omen:addPrompt(++i,"Формирование и печать ведомости")
omen:block(i,{ || PrnOtpu() })

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("Ввод больничных")
omen:addPrompt(++i,"Ввод больничных")
omen:block(i,{ || RaschB() })

omen:add("Запись информации")
omen:addPrompt(++i,"Перенос начисленных больничных в лицевые счета")
omen:block(i,{ || ZapInfB() })

omen:add("Справ коэф больничных")
omen:addPrompt(++i,"справ коэф больничных")
omen:block(i,{ || VvodSprB() })

omen:add("Ведомость")
omen:addPrompt(++i,"Формирование и печать ведомости")
omen:block(i,{ || PrnBol() })

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("Формирование задолженности")
omen:addPrompt(++i,"Формирование не выплаченной заработной платы")
omen:block(i,{ || ZapDolg() })

omen:add("Формирование ведомости")
omen:addPrompt(++i,"Расчет платежной ведомости")
omen:block(i,{ || FormVed() })

omen:add("Корректировка ведомости")
omen:addPrompt(++i,"Корректировка платежной ведомости")
omen:block(i,{ || VedVed() })

omen:add("Печать ведомости")
omen:addPrompt(++i,"Печать платежной ведомости")
omen:block(i,{ || PrnVed() })

omen:add("Печать ведомости в банк")
omen:addPrompt(++i,"Печать платежной ведомости в банк")
omen:block(i,{ || PrnVedb() })

omen:add("Печать ведомости в банкy")
omen:addPrompt(++i,"Печать платежной ведомости в банк")
omen:block(i,{ || PrnVedby() })

omen:add("Закрытие ведомости")
omen:addPrompt(++i,"Закрытие платежной ведомости")
omen:block(i,{ || CloseVed() })

omen:add("Корректировка задолженности")
omen:addPrompt(++i,"Корректировка задолженности по заработной плате")
omen:block(i,{ || VedDolg() })

omen:add("Корректировка Архива")
omen:addPrompt(++i,"Корректировка архива удержаний")
omen:block(i,{ || VedArx() })

omen:add("Просмотр задолженности")
omen:addPrompt(++i,"Просмотр задолженности по заработной плате")
omen:block(i,{ || LookDolg() })

omen:add("Справка по задолженности")
omen:addPrompt(++i,"Печать справки по задолженности по заработной плате")
omen:block(i,{ || SpravDolg() })

omen:add("Чистка базы")
omen:addPrompt(++i,"Удаление информации из базы")
omen:block(i,{ || PackVed() })

omen:add("Прочие удержания")
omen:addPrompt(++i,"Ведение прочих удержаний")
omen:block(i,{ || VedProc() })

omen:add("Закрытие прочих удержаний")
omen:addPrompt(++i,"Закрытие прочих удержаний")
omen:block(i,{ || CloseProc() })

omen:add("Сводная ведомость")
omen:addPrompt(++i,"Формирование и печать сводной ведомости")
omen:block(i,{ || PrnSvod() })

omen:add("Ведомость ХЛЕБНАЯ")
omen:addPrompt(++i,"Формирование и печать ведомости выдачи талонов на хлеб")
omen:block(i,{ || XlebVed() })

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("Архивирование ")
omen:addPrompt(++i,"Архивирование начисленной заработной платы")
omen:block(i,{ || Nakopl() })

omen:add("Корректировка УДЕРЖАНИЙ")
omen:addPrompt(++i,"Корректировка архива удержаний ")
omen:block(i,{ || VedNakYd() })

omen:add("Корректировка НАЧИСЛЕНИЙ")
omen:addPrompt(++i,"Корректировка архива начислений ")
omen:block(i,{ || VedNakNach() })

omen:add("Ведомость 1Дф")
omen:addPrompt(++i,"Формирование и печать ведомости формы 1ДФ ")
omen:block(i,{ || VedomNal() })

omen:add("Формирование ФОРМЫ 3")
omen:addPrompt(++i,"Формирование данных для печати ФОРМЫ 3 ")
omen:block(i,{ || Forma3F() })

omen:add("Корректировка ФОРМЫ 3")
omen:addPrompt(++i,"Корректировка данных ФОРМЫ 3 ")
omen:block(i,{ || VedNalF3() })

omen:add("Печать ФОРМЫ 3")
omen:addPrompt(++i,"Печать справок по ФОРМЕ 3 ")
omen:block(i,{ || FormaF3p() })

omen:add("Справка в ГНА")
omen:addPrompt(++i,"Печать справок в ГНА ")
omen:block(i,{ || PrnSpr() })

omen:add("Ввод данных Ф3 в з/п")
omen:addPrompt(++i,"Ввод данных из формы 3 в заработную плату ")
omen:block(i,{ || ZapNal() })

omen:add("Справка по пенсии")
omen:addPrompt(++i,"Печать справки по пенсии ")
omen:block(i,{ || PrnPens() })

omen:add("Справка по соц")
omen:addPrompt(++i,"Печать справки по соц ")
omen:block(i,{ || PrnCoc() })

omen:add("Справка по безраб")
omen:addPrompt(++i,"Печать справки по безраб ")
omen:block(i,{ || Prnbez() })

omen:add("────────────────────────────")
omen:addPrompt(++i,"")
omen:hide := i

omen:add("Корректировка ИНН")
omen:addPrompt(++i,"Корректировка налоговых номеров работников")
omen:block(i,{ || VedSuper() })

omen:add("О технологии")
omen:addPrompt(++i,"Вывод краткой информации о технологии данного меню")
omen:block(i,{ || BautNal() })

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("Ввод заявление")
omen:addPrompt(++i,"Ведение заявлений на удержание коммунальных услуг ")
omen:block(i,{ || GicVvod() })

omen:add("Просмотр архива заявление")
omen:addPrompt(++i,"Просмотр архива заявлений ")
omen:block(i,{ || GicVvod(999) })

omen:add("Архивирование")
omen:addPrompt(++i,"Архиварование заявлений ")
omen:block(i,{ || GicArx() })

omen:add("Ведомости")
omen:addPrompt(++i,"Формирование ведомостей и данных для передачи в КП ")
omen:block(i,{ || GicPrn() })

omen:add("Печать бланка заявлений")
omen:addPrompt(++i,"Печать бланка заявлений ")
omen:block(i,{ || PrnZajv() })
***
omen:add("Распределение численности работников")
omen:addPrompt(++i,"Распределение численности работников ")
omen:block(i,{ || Pokaztlg() })
***
omen:add("Распределение  работающих и денег")
omen:addPrompt(++i,"Распределение работающих и денег ")
omen:block(i,{ || Raspred() })
***
omen:add("начисленная зарплаты женщинам    ")
omen:addPrompt(++i,"начисленная зарплата женщинам    ")
omen:block(i,{ || PrnGen() })

***
omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

return ( oMen0 )
////////////////////////////////////////////////////////////////////////////
Static Function Mquit()
KeyBoard(Chr(K_ESC))
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static Function ReadData(Par)
Local __dData := date(), __nMin := 0
Local ColorOld := SetColor(sset[32]+","+sset[2]), GetList := {}, i

if Par == Nil
     if File("Data.!!!")
        i := S_ArRest("Data.!!!")
        sset[121] := ctod(i[1])
        sset[122] := i[2]
      else
        S_Open_S(12,38,15,72,sset[32]+","+sset[2])
        @ 01,01 wsay "Укажите дату   " wget __dData Pict "@d" valid !empty(__dData)
        @ 02,01 wsay "Минимальную з/п" wget __nMin  pict "999999999999.99" valid __nMin > 0
        read
        S_wClose()
        SetColor(ColorOld)
        S_ArSave({dtoc(__dData),__nMin},"Data.!!!")
        sset[121] := __dData
        sset[122] := __nMin
     end
Elseif File("Data.!!!")
     i := S_ArRest("Data.!!!")
     __dData := ctod(i[1])
     __nMin  := i[2]
     S_Open_S(12,38,14,72,sset[32]+","+sset[2])
     if Par == 1
        @ 01,01 wsay "Дата расчета   " wget __dData Pict "@d" valid !empty(__dData)
     else
        @ 01,01 wsay "Минимальная з/п" wget __nMin  pict "999999999999.99" valid __nMin > 0
     End
     Read
     S_wClose()
     SetColor(ColorOld)
     S_ArSave({dtoc(__dData),__nMin},"Data.!!!")
     sset[121] := __dData
     sset[122] := __nMin
End
return ( Nil )
///////////////////////////////////////////////////////////////////////////////
Function OpenArx(lOpen)
Local lRet := .f.
if M_Use("VedArx",lOpen)
  TagCrt({{"TABNO","Tn+dtos(Data)"}},"VedArx.Cdx")
  lRet := .t.
End
Return ( lRet)
////////////////////////////////////////////////////////////////////////////
Function OpenDolg(lOpen)
Local lRet := .f.
if M_Use("DolgPr",lOpen)
  TagCrt({{"DATA","Left(dtos(Data),6)+Tn"},;
           {"TABNO","Tn+Left(dtos(Data),6)"}},"DolgPr.Cdx")
  lRet := .t.
End
Return ( lRet)
//////////////////////////////////////////////////////////////////////////
Function OpenPlat(lOpen)
Local lRet := .f.
if M_Use("VedPlat",lOpen)
  TagCrt({{"TABNO","Tn"}},"VedPlat.Cdx")
  lRet := .t.
End
Return ( lRet)
//////////////////////////////////////////////////////////////////////////////

Function OpenUder()
Local lRet := .f.
if M_Use("Suder",,,,"DBFNTX") .and. File("SuderInd.Ntx")
   Set index to SuderInd
  lRet := .t.
End
Return ( lRet)
///////////////////////////////////////////////////////////////////////
Function OpenList()
Local lRet := .f.
if M_Use("SuperLis",,,,"DBFNTX") .and. File("SuperTn.Ntx")
   Set index to SuperTn
   lRet := .t.
End
Return ( lRet)
///////////////////////////////////////////////////////////////////////
Function OpenSvo()
Local lRet := .f.
if M_Use("Svo",,,,"DBFNTX") .and. File("SvoIndex.Ntx")
   Set Index to SvoIndex
   lRet := .t.
End
Return ( lRet)
///////////////////////////////////////////////////////////////////////
Function OpenVip(lOpen)
Local lRet := .f.
if !File(PathVipZap+"VipZap.Dbf")
   DbCreate(PathVipZap+"VipZap.Dbf",{{"Ksp",  "C",04,00},;
                                      {"Tnr",  "C",06,00},;
                                      {"Summa","N",12,02},;
                                      {"Data", "D",08,00}})
End
if M_Use(PathVipZap+"VipZap",lOpen)
  TagCrt({{"TNR","Tnr+dtos(Data)"}},PathVipZap+"VipZap.Cdx")
  lRet := .t.
End
Return ( lRet)
///////////////////////////////////////////////////////////////////////////
Function Fornak()  // суммиров сум из накопит по таб
Local i, nSumMin := nSumMat := 0, nData := 200301, kData := 200312
Local ColorOld := SetColor(sset[32]+","+sset[2]), GetList := {}
Local CursorOld := SetCursor(1)

BEGIN SEQUENCE
S_Open_S(12,30,17,64,sset[32]+","+sset[2])
@ 01,01 wsay "Укажите: дату начала" wget nData pict "999999" valid nData > 199612
@ 02,01 wsay "              конца " wget kData pict "999999" valid kData > 199612 .and. ;
                                                           kData >= nData
@ 03,01 wsay "табельный номер     " wget nSumMin pict "999999" valid nSumMin > 0
read
SetColor(ColorOld)
SetCursor(CursorOld)
if LastKey() == K_ESC ; break ; End
S_wClose()
nS605:=0
nTn :=nSumMin
if !OpenDbf_("NAKNACH") ; break ; End
      if NakNach->(DbSeek(str(nTn,6)))
         While nTn == NakNach->tn .and. !NakNach->(eof())
            if NakNach->D_Nach >= nData .and. NakNach->D_Nach <= kData
                  nS605 += NakNach->Sum
            End
            NakNach->(DbSkip(1))
          End
      End
@ 16,01 wsay nS605
S_BEEP(3)
//  S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
Function Fornaky()  // суммиров сум из накопит по таб
Local i, nSumMin := nSumMat := 0, nData := 200301, kData := 200312
Local ColorOld := SetColor(sset[32]+","+sset[2]), GetList := {}
Local CursorOld := SetCursor(1)

BEGIN SEQUENCE
S_Open_S(12,30,17,64,sset[32]+","+sset[2])
@ 01,01 wsay "Укажите: дату начала" wget nData pict "999999" valid nData > 199612
@ 02,01 wsay "              конца " wget kData pict "999999" valid kData > 199612 .and. ;
                                                           kData >= nData
@ 03,01 wsay "табельный номер     " wget nSumMin pict "999999" valid nSumMin > 0
@ 04,01 wsay "код удержаний       " wget nSumMat pict "999"

read
SetColor(ColorOld)
SetCursor(CursorOld)
if LastKey() == K_ESC ; break ; End
S_wClose()
nS910:=0
nTn :=nSumMin
nRecno := 0
   if !OpenDbf_("Nakyd") ; break ; End
      if Nakyd->(DbSeek(str(nTn,6)))
         While nTn == Nakyd->tn .and. !NakYd->(eof())
            if NakYd->D_Yd >= nData .and. NakYd->D_Yd <= kData
               for i := 1 to 12
                 cKvu_   := "KVU"+alltrim(str(i,2))
                 cSumYd_ := "SumYd"+alltrim(str(i,2))
                 if NakYd->(&cKvu_) == str(nSumMat)
                    nS910 += NakYd->(&cSumYd_)
                 End
               Next
            End
            NakYd->(DbSkip(1))
         End
      End

S_BEEP(3)
@ 16,01 wsay nS910
//  S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
/////////
//////////////////////////////////////////////////////////////////
Function OpenUvzad(lOpen)
Local lRet := .f.
if M_Use("UvZadol",lOpen)
  TagCrt({{"DATA","str(Data,6)"}},"UvZadol.Cdx")
  lRet := .t.
End
Return ( lRet)
///////////////////////////////////////////////////////////////
