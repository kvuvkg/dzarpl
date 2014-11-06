#include "S_Win.ch"
#include "inkey.ch"
#Define ROUN  2
/////////////////////////////////////////////////////////////////////////////
Function VvodOtp() // Ввод отпускных
Local ColorOld := SetColor(),;
      SelectOld := Select(),;
      SursorOld := SetCursor(),;
      NortonOld := DeskTop:Norton()
Local nNPach, nCex, nTnr, nKdn, nPo, nPr, nPriz, dData
Local tb, nKey, nRow, GetList := {}

BEGIN SEQUENCE
if !OpenDbf_("OTPU") ; break ; End
SetCursor(0)
DbSelectArea("OTPU")
S_Open_S(03,03,22,50,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Чис│Цех │Табел.│  Дата    │К-во│приз│приз│приз"
@ 02,01 wsay "ло │    │номер │  отпуска │дней│опт.│вып.│рас."
@ 03,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"3Удалить","4Регистр","5Корректи"}} )
tb := TBrowseDb(S_wRow()+04,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| str(Otpu->NPach,3)+" "+str(Otpu->Cex,4)+" "+;
                                str(Otpu->Tnr,6)+" "+dtoc(Otpu->Data)+" "+;
                                str(Otpu->Kdn,4)+" "+str(Otpu->Po,4)+" "+;
                                str(Otpu->Pr,4)+" "+str(Otpu->Priz,4) } ))
Otpu->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := S_Inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := S_InKey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3 .and. !Empty(Otpu->Tnr) // Удаление
           if Otpu->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"Otpu")
                 Otpu->(DbDelete())
                 Otpu->(DbUnlock())
                 Otpu->(DbSkip(1))
                 if Otpu->(eof()) ; Otpu->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Вводите данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           While ( .t. )
             Scroll(S_wRow()+04,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1,-1)
             nNPach := nCex := nTnr := nKdn := nPo := nPr := nPriz := 0
             dData := date()
             @ 04,02 wget nNPach pict "99" valid nNPach > 0
             @ 04,05 wget nCex  pict "9999" valid !Empty(nCex)
             @ 04,10 wget nTnr  pict "999999" valid !Empty(nTnr)
             @ 04,17 wget dData pict "@d" valid !Empty(dData)
             @ 04,29 wget nKdn  pict "999" valid nKdn > 0
             @ 04,36 wget nPo   pict "9" range 0,1
             @ 04,41 wget nPr   pict "9" range 0,1
             @ 04,46 wget nPriz pict "9" range 0,1
             read
             if LastKey() == K_ESC ; exit ; End
             if M_Append(20,"Otpu")
               Otpu->NPach:= nNPach
               Otpu->Cex  := nCex
               Otpu->Tnr  := nTnr
               Otpu->Data := dData
               Otpu->Kdn  := nKdn
               Otpu->Po   := nPo
               Otpu->Pr   := nPr
               Otpu->Priz := nPriz
               Otpu->(DbUnlock())
             End
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5 .and. !Empty(Otpu->Tnr) // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nNPach:= Otpu->NPach
           nCex  := Otpu->Cex
           nTnr  := Otpu->Tnr
           dData := Otpu->Data
           nKdn  := Otpu->Kdn
           nPo   := Otpu->Po
           nPr   := Otpu->Pr
           nPriz := Otpu->Priz
           @ nRow,S_wCol()+02 get nNPach pict "99" valid nNPach > 0
           @ nRow,S_wCol()+05 get nCex  pict "9999" Valid nCex > 0
           @ nRow,S_wCol()+10 get nTnr  pict "999999" Valid nTnr > 0
           @ nRow,S_wCol()+17 get dData pict "@d" Valid !Empty(dData)
           @ nRow,S_wCol()+29 get nKdn  pict "999" valid nKdn > 0
           @ nRow,S_wCol()+36 get nPo   pict "9" range 0,1
           @ nRow,S_wCol()+41 get nPr   pict "9" range 0,1
           @ nRow,S_wCol()+46 get nPriz pict "9" range 0,1
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"Otpu")
               Otpu->NPach := nNPach
               Otpu->Cex  := nCex
               Otpu->Tnr  := nTnr
               Otpu->Data := dData
               Otpu->Kdn  := nKdn
               Otpu->Po   := nPo
               Otpu->Pr   := nPr
               Otpu->Priz := nPriz
               Otpu->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
tb := nil
S_wClose()
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DeskTop:Norton := NortonOld
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function VvodSprO() // Ввод коэффициентов оптуска
Local ColorOld := SetColor(),;
      SelectOld := Select(),;
      SursorOld := SetCursor(),;
      NortonOld := DeskTop:Norton()
Local dDataC, dDataP, nKf, tb, nKey, nRow, GetList := {}

BEGIN SEQUENCE
if !OpenDbf_("SprKO") ; break ; End
SetCursor(0)
DbSelectArea("SprKO")
S_Open_S(03,03,22,32,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "       Период        │Коэф- "
@ 02,01 wsay "    с     │    по    │фиент."
@ 03,01 wsay Repl("─",MaxCol()-1)
oNortonNew( {{"3Удалить","4Регистр","5Корректи"}} )
tb := TBrowseDb(S_wRow()+04,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| dtoc(SprKO->DataC)+" "+dtoc(SprKO->DataP)+;
                                " "+str(SprKO->Kf,6,3) } ))
SprKO->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := S_Inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := S_InKey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3 .and. !Empty(SprKO->kf) // Удаление
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"SprKO")
                 SprKO->(DbDelete())
                 SprKO->(DbUnlock())
                 SprKO->(DbSkip(1))
                 if SprKO->(eof()) ; SprKO->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Вводите данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           While ( .t. )
             Scroll(S_wRow()+04,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1,-1)
             nKf := 0
             dDataP := dDataC := date()
             @ 04,01 wget dDataC pict "@d" valid !Empty(dDataC)
             @ 04,12 wget dDataP pict "@d" valid dDataP >= dDataC
             @ 04,23 wget nKf    pict "99.999" valid nKf > 0
             read
             if LastKey() == K_ESC ; exit ; End
             if M_Append(20,"SprKO")
               SprKO->DataC := dDataC
               SprKO->DataP := dDataP
               SprKO->kf    := nkf
               SprKO->(DbUnlock())
             End
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5 .and. !Empty(SprKO->Kf) // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nkf := SprKO->Kf
           @ nRow,S_wCol()+23 get nKf pict "99.999" valid nKf > 0
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"SprKO")
               SprKO->Kf := nKf
               SprKO->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
tb := nil
S_wClose()
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DeskTop:Norton := NortonOld
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function RaschO() // расчет отпускных
Local dDataR := sset[121] // Дата расчета
Local nMin   := sset[122] // Минимальная з/п
Local dData1, dData2, nMecStop, nMecStart, nFzpo

dData1 := S_AddMon(S_Bom(dDataR),1)
dData2 := S_AddMon(dData1,1)
BEGIN SEQUENCE
cPrazDni := MemoRead("Praz.Dni")
if !OpenDbf_("OTPU")  ; break ; End
if !OpenDbf_("SPRKO") ; break ; End
if !OpenList()        ; break ; End
if !OpenSvo()         ; break ; End

nMecR := Month(dDataR)                     // N месяца расчета
nGodR := str(year(dDataR),4)               // год даты расчета
nGodP := str(year(S_AddMon(dDataR,-12)),4) // предыдущий год
DbSelectArea("OTPU")
nLastRec := Otpu->(LastRec())
Otpu->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Делаю расчет...."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
While ( !Otpu->(eof()) )
   if Otpu->Priz == 0
      cTnr := StrZero(Otpu->Tnr,6)
      if !SuperLis->(DbSeek(cTnr))
         S_Err({"Табельный номер - "+cTnr,"Отсутствует в справочнике"})
      else
         dData:= Otpu->Data           // Дата отпуска
         cKsp := SuperLis->Ksp        // Код подразделения
         nRec := SuperLis->Base_Rec   // No записи в BASE
         Use Base&cKsp new alias Base
         Use Seba&cKsp new alias Seba
         nRecSeba := (nRec-1)*12+1    // N записи в SEBA
         Seba->(DbGoto(nRecSeba))
         aSumma := {0,0,0,0,0,0,0,0,0,0,0,0}  // Суммы по месецам
         aMec   := {0,0,0,0,0,0,0,0,0,0,0,0}  // входимость месяца
         nMecStop := month(dData)
         nFzpo := 0
         for i := 1 to 12
            for j := 1 to 12
              cKmn_ := "KMN"+alltrim(str(j,2))
              cVo_  := "VO"+alltrim(str(j,2))
              cSvon_:= "SVON"+alltrim(str(j,2))
              if !Empty( cVo := Seba->(&cVo_) )
                 Svo->(DbSeek(cVo))
                 if Substr(Svo->Zmo,10,1) == "1"
                    cSvon := Seba->(&cSvon_)
                    cKmn  := Seba->(&cKmn_)
                    nKf   := 1
                    dDataKf := ctod("01."+cKmn+"."+;
                                    iif(val(cKmn) >= nMecR,nGodP,nGodR))
                    SprKO->(DbGoTop())
                    While ( !SprKo->(eof()) )
                      if dDataKf >= SprKo->DataC .and. dDataKf <= SprKo->DataP
                         nKf := SprKo->Kf
                         Exit
                      End
                      SprKo->(DbSkip(1))
                    End
                    cKmn := val(cKmn)
                    // Ну наконец-то добрались
                    aSumma[cKmn] += Round(cSvon*nKf,ROUN)
                    if Empty(aMec[cKmn])
                       aMec[cKmn] := S_LastDayM(dDataKf) - ;
                                    NumAt(substr(dtoc(dDataKf),3,8),cPrazDni)
                    End
                 End
              End
            next
            Seba->(DbSkip(1))
         Next
         if ( pMes := Sum_(aMec) ) > 0
           nFzpo := Sum_(aSumma)
           nSredSum := Round(nFzpo/pMes,ROUN)
           nSumFzp  := Round(nSredSum*Otpu->Kdn,ROUN)
           nSymKas  := 0
           if Otpu->Pr == 0
             nSymKas := round(nSumFzp*0.9,ROUN)
           End
           i := 1
           dData := Otpu->Data
           nKdn1 := nKdn2 := nKdn3 := 0
           if Otpu->po == 1
              nKdn1 := Otpu->Kdn
           else
              dData1 := S_AddMon(S_Bom(Otpu->Data),1)
              dData2 := S_AddMon(dData1,1)
              While ( i <= Otpu->Kdn )
                dData++
                if !dtoc(dData)$cPrazDni // не праздник
                  if dData >= Otpu->Data .and. dData < dData1
                     nKdn1++
                  elseif dData >= dData1 .and. dData < dData2
                     nKdn2++
                  else
                     nKdn3++
                  End
                  i++
                End
              End
            End
           if M_Rlock(20,"Otpu")
              Otpu->SredSum := nSredSum
              Otpu->DataR := dDataR
              Otpu->Kd1   := nKdn1
              Otpu->Kd2   := nKdn2
              Otpu->Kd3   := nKdn3
              Otpu->Sym1  := round(nKdn1*nSredSum/100,ROUN)*100
              Otpu->Sym2  := round(nKdn2*nSredSum/100,ROUN)*100
              Otpu->Sym3  := round(nKdn3*nSredSum/100,ROUN)*100
              Otpu->Dat1  := Month(Otpu->Data)
              Otpu->Dat2  := Month(dData1)
              Otpu->Dat3  := Month(dData2)
              Otpu->Sym12 := nFzpo
              Otpu->vo1   := iif(Otpu->po==1,203,201)
              if Otpu->Sym1 == 0
                Otpu->vo1   := 0
                Otpu->Dat1  := 0
              End
              Otpu->vo2   := iif(Otpu->po==1,203,202)
              if Otpu->Sym2 == 0
                Otpu->vo2   := 0
                Otpu->Dat2  := 0
              End
              Otpu->vo3   := iif(Otpu->po==1,203,202)
              if Otpu->Sym3 == 0
                Otpu->vo3   := 0
                Otpu->Dat3  := 0
              End
              Otpu->SymKas:= nSymKas
              Otpu->Priz  := 1
              Otpu->(DbUnlock())
           End
         End
         Seba->(DbCloseArea())
         Base->(DbCloseArea())
     End
   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   Otpu->(DbSkip(1))
End
S_Beep(3)
S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
////////////////////////////////////////////////////////////////////
Static function Sum_(array)
Local nSum := 0, i
For i := 1 to Len(array)
  nSum += array[i]
next
Return ( nSum )
/////////////////////////////////////////////////////////////////////
Function PrnVedO()
Local nSumTotal := 0, dData := sset[121], nToList, nSumma, nPage, aSumma
Local nLine, nSumPage, nList, cTnr, i, cNaimPred, nDniNac, nDniKon
Local ColorOld := SetColor(), CursorOld := SetCursor()

BEGIN SEQUENCE
if !OpenDbf_("OTPU")  ; break ; End
if !OpenDbf_("SPRKO") ; break ; End
if !OpenList()        ; break ; End
if !M_Use("Pasp",,,,"DBFNTX") ; break ; End
cNaimPred := Pasp->Naim

nDniNac := 1
nDniKon := 31
SetCursor(1)
S_Open_S(03,03,07,28,Sset[76]+","+sset[77]+",,,"+sset[76])
@ 01,02 wsay "Начальное число: " wget nDniNac pict "99" range 1,31
@ 02,02 wsay "Конечное число:  " wget nDniKon pict "99" range nDniNac,31
read
S_wClose()
SetColor(ColorOld)
SetCursor(CursorOld)
S_Sys({" Внимательно следите за печатью","и бумагой"})
Set(20,"PRINT")
Otpu->(DbGoTop())
While ( !Otpu->(eof()) )
  if Otpu->Npach >= nDniNac .and. Otpu->Npach <= nDniKon .and. Otpu->SymKAS/100 > 0
    nSumTotal += Otpu->SymKAS/100
  End
  Otpu->(DbSkip(1))
End
nToList := if( (nSumma := Otpu->(LastRec()))%30==0,29,30)
nPage   := int(nSumma/nToList) + 1
aSumma  := PropisSum(nSumTotal,30)
@ prow()+1,00 say " = = = = = = л и н и я  р а з р ы в а  = = = = = = = = = ="
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say cNaimPred
@ prow()+1,00 say "                                       В кассу для оплаты в срок"
@ prow()+1,00 say "   "
@ prow()+1,00 say "                                        с ____ по _________ 19___"
@ prow()+1,00 say "    К расчетной "
@ prow()+1,00 say "    ведомости N______      в сумме: "+aSumma[1]
nLine := 12
for i := 2 to len(aSumma)
  @ prow()+1,00 say "                                    "+aSumma[i]
  nLine++
Next
@ prow()+1,00 say "                                    ("+alltrim(str(nSumTotal,15,2))+" крб.)"
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say "                  РУКОВОДИТЕЛЬ ___________________"
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say "                  ГЛ. БУХГАЛТЕР __________________"
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say "         П Л А Т Е Ж Н А Я    В Е Д О М О С Т Ь  ________"
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say "                        Количество листов "+str(nPage,3)
@ prow()+1,00 say " "
@ prow()+1,00 say "                        за "+;
                  S_cMonth(dData)+" месяц "+str(year(dData),4)+" г."
@ prow()+1,00 say "                         на выдачу отпускных"
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say "   по настоящей платежной ведомости выплачено крб."
@ prow()+1,00 say " _______________________________________________________"
@ prow()+1,00 say " _______________________________________________________"
@ prow()+1,00 say " ____________________________(_______________крб_____коп)"
@ prow()+1,00 say " и депонировано _________________________________________"
@ prow()+1,00 say " ____________________________(_______________крб_____коп)"
nLine += 25
for i := 1 to 10
   @ prow()+1,00 say " "
   nLine++
End
@ prow()+1,00 say "   Выплату произвел ______________________________ 19___ г."
@ prow()+1,00 say " "
@ prow()+1,00 say "   Проверил бухгалтер ____________________________ 19___ г."
@ prow()+1,00 say " "
@ prow()+1,00 say "   Кассовый ордер N_______ от __________________ 19 ___ г."
nLine += 5
for i := nLine to 66
   @ prow()+1,00 say " "
End
nPage := 0
Otpu->(DbGoTop())
While ( !Otpu->(eof()) )
  @ prow()+1,00 say " = = = = = = л и н и я  р а з р ы в а  = = = = = = = = = ="
  @ prow()+1,00 say " "
  @ prow()+1,00 say padr(" Лист# "+str(++nPage,3),74)
  @ prow()+1,00 say Repl("-",74)
  @ prow()+1,00 say "Цех | Таб.N|   Фамилия  Имя  Отчество     |  Сумма      |подпись"
  @ prow()+1,00 say Repl("-",74)
  nLine := 5
  nSumPage := nList := 0
  While ( !Otpu->(eof()) .and. nList <= nToList )
    if Otpu->Npach >= nDniNac .and. Otpu->Npach <= nDniKon .and. ;
                                                           Otpu->SymKAS/100 > 0
       cTnr := StrZero(Otpu->Tnr,6)
       SuperLis->(DbSeek(cTnr))
       @ prow()+1,00 say SuperLis->Ksp+"|"+str(Otpu->Tnr,6)+"|"+;
                         padr(SuperLis->Fio,30)+"|"+str(Otpu->SymKAS/100,13,2)+"|"
       @ prow()+1,00 say Repl("-",74)
       nLine += 2
       nList++
       nSumPage += Otpu->SymKAS/100
     End
     Otpu->(DbSkip(1))
  End
  @ prow()+1,00 say padl(" Итого по листу ............."+str(nSumPage,15,2)+"      ",74)
  nLine++
  if !Otpu->(eof())
     for i := nLine to 66
         @ prow()+1,00 say " "
     End
  End
End
@ prow()+1,00 say padl(" Итого по ведомости.........."+str(nSumTotal,15,2)+"      ",74)
aSumma := PropisSum(nSumTotal,70)
@ prow()+1,00 say "К выдаче: "+aSumma[1]
nLine += 2
for i := 2 to len(aSumma)
     @ prow()+1,11 say aSumma[i]
     nLine++
Next
@ prow()+1,00 say " "
@ prow()+1,00 say "   Ведомость проверил _______________________"
@ prow()+1,00 say " "
@ prow()+1,00 say "   Ведомость составил _______________________"
@ prow()+1,00 say " "
nLine += 5
for i := nLine to 66
    @ prow()+1,00 say " "
End
@ prow()+1,00 say " = = = = = = л и н и я  р а з р ы в а  = = = = = = = = = ="
@ prow()+1,00 say " "
Set(20,"SCREEN")
S_Sys()
END SEQUENCE
DbCloseAll()
//////////////////////////////////////////////////////////////////////////////
Function ZapInfO() // запись информации в л/с
Local mRecno, nLastRec, cKsp, nRec, i, j, im, jm, cSym, cVo, cSvon, cDn, cKn

BEGIN SEQUENCE
if !OpenDbf_("OTPU")  ; break ; End
if !OpenList()        ; break ; End

nLastRec := Otpu->(LastRec())
Otpu->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Делаю запись информации"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
While ( !Otpu->(eof()) )
   cTnr := StrZero(Otpu->Tnr,6)
   if !SuperLis->(DbSeek(cTnr))
      S_Err({"Табельный номер - "+cTnr,"Отсутствует в справочнике"})
   else
     cKsp := SuperLis->Ksp        // Код подразделения
     nRec := SuperLis->Base_Rec   // No записи в BASE
     cSym := "Base"+cKsp
     Use (cSym) new alias Base
     Base->(DbGoto(nRec))
     for i := 1 to 3
       im := Alltrim(str(i,2))
       cSym := "Sym"+im
       cBo  := "Vo"+im
       cKd  := "Kd"+im
       if Otpu->&cSym > 0
          lYes := .f.
          for j := 1 to 12
            jm := Alltrim(str(j,2))
            cVo := "Vo"+jm
            if empty(Base->&cVo)
               lYes := .t.
               Base->&cVo  := strzero(Otpu->&cBo,3)
               cSvon := "Svon"+jm
               Base->&cSvon := Otpu->&cSym
               cKmn := "Kmn"+jm
               Base->&cKmn := strzero(month(Otpu->DataR),2)
               cDn := "Dn"+jm
               Base->&CDn := Otpu->&cKd*100
               Exit
            End
         Next
      End
    Next
    if Otpu->SymKas > 0
       for j := 1 to 12
          jm := Alltrim(str(j,2))
          cVo := "KU"+jm
          if empty(Base->&cVo)
             Base->&cVo  := "925"
             cSvon := "Sku"+jm
             Base->&cSvon := Otpu->SymKas
             cKmn := "Kmu"+jm
             Base->&cKmn := strzero(month(Otpu->DataR),2)
             Exit
          End
       Next
    End
    Base->(DbCloseArea())
  End
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Otpu->(DbSkip(1))
End
S_Beep(3)
S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Function PrnOtpu() // Печать отпускных
Local nLastRec, nRecno, cTnr, nItog := 0, cFile := "OtpuPrn.txt", nLen := 87

BEGIN SEQUENCE
if !OpenDbf_("OTPU")  ; break ; End
if !OpenList()        ; break ; End

nLastRec := Otpu->(LastRec())
Otpu->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Делаю запись информации"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Set Device to Print
@ prow()+1,00 say " "
@ prow()+1,00 say padc(" В Е Д О М О С Т Ь",nLen)
@ prow()+1,00 say padc("начисления оплаты по отпускным",nLen)
@ prow()+1,00 say padc(" от "+dtoc(sset[121]),nLen)
@ prow()+1,00 say repl("-",nLen)
@ prow()+1,00 say "    |   Фамилия          |Табель|Заработок за   |кол-во|   средне-     |    Сумма      |"
@ prow()+1,00 say "Цех |     Имя            | ный  |   прошлые     | дней |   дневной     | начисленная   |"
@ prow()+1,00 say "    |    Отчество        |номер |  12 месяцев   |      |               |               |"
@ prow()+1,00 say "    |                    |      |               |      |               |               |"
@ prow()+1,00 say repl("-",nLen)
While ( !Otpu->(eof()) )
   cTnr := StrZero(Otpu->Tnr,6)
   SuperLis->(DbSeek(cTnr))
   @ prow()+1,00 say str(Otpu->Cex,4)+" "+SuperLis->Fio+" "+str(Otpu->Tnr,6)+" "+;
     str(Otpu->Sym12/100,15,2)+" "+str(Otpu->Kdn,6)+" "+;
     str(Otpu->SredSum/100,15,2)+" "+str((Otpu->Sym1+Otpu->Sym2+Otpu->Sym3)/100,15,2)
   nItog += (Otpu->Sym1+Otpu->Sym2+Otpu->Sym3)/100
   S_Line_N(18,04,65,nLastRec,++nRecno)
   Otpu->(DbSkip(1))
End
@ prow()+1,00 say repl("=",nLen)
@ prow()+1,00 say padl(" И Т О Г О  "+str(nItog,15,2),nlen)
@ prow()+1,00 say ""
Set Device to Screen
S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Function VedKomp() // Ввод коэффициентов компенсации
Local ColorOld := SetColor(),;
      SelectOld := Select(),;
      SursorOld := SetCursor(),;
      NortonOld := DeskTop:Norton()
Local nData, nKoef, nKey, nRow, GetList := {}

BEGIN SEQUENCE
if !OpenUvZad() ; break ; End
SetCursor(0)
DbSelectArea("UvZadol")
S_Open_S(03,03,22,17,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Период|Коеф-т"
@ 02,01 wsay "─────────────"
oNortonNew( {{"3Удалить","4Регистр","5Корректи"}} )
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| Str(UvZadol->Data)+" "+str(UvZadol->Koef,6,3) } ))
UvZadol->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := S_Inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := S_InKey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3 .and. !Empty(UvZadol->koef) // Удаление
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"UvZadol")
                 UvZadol->(DbDelete())
                 UvZadol->(DbUnlock())
                 UvZadol->(DbSkip(1))
                 if UvZadol->(eof()) ; UvZadol->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Вводите данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           While ( .t. )
             Scroll(S_wRow()+04,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1,-1)
             nKoef := nData := 0
             @ 04,01 wget nData pict "999999"
             @ 04,08 wget nKoef pict "99.999" valid nKoef > 0
             read
             if LastKey() == K_ESC ; exit ; End
             if M_Append(20,"UvZadol")
               UvZadol->Data := nData
               UvZadol->koef := nkoef
               UvZadol->(DbUnlock())
             End
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5 .and. !Empty(UvZadol->Koef) // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nkoef := UvZadol->Koef
           @ nRow,S_wCol()+08 get nKoef pict "99.999" valid nKoef > 0
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"UvZadol")
               UvZadol->Koef := nKoef
               UvZadol->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
tb := nil
S_wClose()
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DeskTop:Norton := NortonOld
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
