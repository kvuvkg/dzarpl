#include "inkey.ch"
#include "S_Win.ch"

#define IND_FAM   1  // Фамилия
#define IND_NAM   2  // Имя
#define IND_OT    3  // Отчество

FUNCTION SPLIT(cStr, cDelim)
  LOCAL aArr := {}, nPos, nDelimLen, cBuff
  IF EMPTY(cDelim)
    cDelim := " "
  ENDIF
  nDelimLen = len(cDelim)
  IF SUBSTR(cStr, (-1 * nDelimLen), nDelimLen) <> cDelim
    cStr := cStr + cDelim
  ENDIF
  DO WHILE ( nPos :=  AT(cDelim, cStr) ) > 0
    cBuff = SUBSTR(cStr, 1, nPos -1)
    IF !EMPTY(cBuff)
      AADD(aArr, cBuff)
    ENDIF  
    cStr := Substr(cStr, nPos + nDelimLen)
  ENDDO
  RETURN (aArr)


FUNCTION GetArrItem(aArr, nInd)
  LOCAL cRes := ""
  IF nInd <= LEN(aArr) .AND. !EMPTY(aArr[nInd])
    cRes := aArr[nInd]
  ENDIF
  RETURN (cRes)
   

///////////////////////////////////////////////////
Function ZapDolg()  // Формирование долга по з.пл.
Local cFile := "Base*.Dbf", aFile, m, j, nRecno, nLastRec, cTn, nSumN, nSumU
Local cKu_, cSvon_, nSumma

if Empty(aFile := Directory(cFile))
   Return ( Nil )
End
BEGIN SEQUENCE
if S_Err({"Будем формировать задолженность",;
          "по заработной плате"," за "+S_cMonth(sset[121])+" месяц "+;
          str(year(sset[121]),4)+" год?",;
          "%   Да   ;   Нет  ;"}) == 2
  break
End
if !OpenDolg() ; break ; End
if DolgPr->(DbSeek(left(dtos(sset[121]),6)))
   S_Beep(1)
   S_Err({"На данный месяц данные уже имеются!"})
   break
End
//
if !OpenList()   ; break ; End

nLastRec := Len(aFile)
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую долг...."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
for m := 1 to Len(aFile)
  cFile := aFile[m][1]
  use (cFile) new Alias Base
  Base->(DbGotop())
  While !Base->(eof())
    if Base->Tn <> "******" .and. SuperLis->(DbSeek(Base->Tn))
      nSumN := nSumU := 0
      for j := 1 to 12
        cKu_  := "SKU"+alltrim(str(j,2))
        cSvon_:= "SVON"+alltrim(str(j,2))
        nSumN += Base->(&cSvon_)
        nSumU += Base->(&cKu_)
      Next
       nSumN= nSumN + KPM
      if (nSumma := nSumN - nSumU) > 0
         DolgPr->(DbAppend())
         DolgPr->Tn      := Base->Tn
         DolgPr->SumDolg := nSumma/100
         DolgPr->Data    := sset[121]
         DolgPr->Ksp     := SuperLis->Ksp
      End
    End
    Base->(DbSkip(1))
  End
  Base->(DbCloseArea())
  S_Line_N(18,04,65,nLastRec,++nRecno)
Next
S_Beep(3)
S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
////////////////////////////////////////////////////////////////
Function VedDolg() // Ведение задолженности
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      SelectOld := Select(),;
      SursorOld := SetCursor(),;
      NortonOld := DeskTop:Norton()
Local  nTn, nSumVip, nSumDolg
Local tb, nKey, nRow, GetList := {}
Private dData := sset[121]

BEGIN SEQUENCE
S_Open_S(12,38,14,65,sset[32]+","+sset[2]+",,,"+sset[32])
SetCursor(1)
@ 01,01 wsay "Укажите дату " wget dData Pict "@d" valid !empty(dData)
read
S_wClose()
if LastKey() == K_ESC ; break ; End
if !OpenList()   ; break ; End
if !OpenDolg()   ; break ; End
Set Relation to Tn into SUPERLIS
//
SetCursor(0)
DbSelectArea("DolgPr")
S_Open_S(03,03,22,59,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Цех │Табел.│    Ф И О           │Начислено │Выплачено "
@ 02,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"3Удалить","4Регистр","5Корректи"}} )
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| DolgPr->Ksp+" "+DolgPr->Tn+" "+;
                                SuperLis->Fio+" "+;
                                str(DolgPr->SumDolg,10,2)+" "+;
                                str(DolgPr->SumVip,10,2) } ))
tb:goTopBlock    := { | | DolgPr->(DbSeek(Left(dtos(dData),6))) }
tb:goBottomBlock := { | | DtBottom()   }
tb:SkipBlock     := { |n| DtNext_(n)   }
DolgPr->(DbSeek(Left(dtos(dData),6)))
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
       case nKey == K_F3 .and. !Empty(DolgPr->Tn) // Удаление
           if DolgPr->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"DolgPr")
                 DolgPr->(DbDelete())
                 DolgPr->(DbUnlock())
                 DolgPr->(DbSkip(1))
                 if DolgPr->(eof()) ; DolgPr->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Вводите данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           While ( .t. )
             Scroll(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1,-1)
             nTn := nSumDolg := nSumVip :=  0
             @ 03,06 wget nTn pict "999999" valid nTn > 0
             read
             if LastKey() == K_ESC ; exit ; End
             nTn := strzero(nTn,6)
             if !SuperLis->(DbSeek(nTn))
                S_Beep()
                @ 03,13 wsay "Отсутствует"
                Loop
             End
             cKsp := SuperLis->Ksp
             @ 03,13 wsay SuperLis->Fio
             @ 03,01 wsay cKsp
             if DolgPr->(DbSeek(Left(dtos(dData),6)+nTn))
                S_Beep()
                @ 03,13 wsay "Уже иммется"
                @ 03,34 wsay DolgPr->SumDolg pict "9999999.99"
                @ 03,45 wsay DolgPr->SumVip  pict "9999999.99"
                Loop
             End
             @ 03,34 wget nSumDolg pict "9999999.99"
             @ 03,45 wget nSumVip  pict "9999999.99"
             read
             if LastKey() == K_ESC ; Loop ; End
             if M_Append(20,"DolgPr")
               DolgPr->Ksp  := cKsp
               DolgPr->Tn   := nTn
               DolgPr->Data := dData
               DolgPr->SumDolg := nSumDolg
               DolgPr->SumVip  := nSumVip
               DolgPr->(DbUnlock())
             End
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5 .and. !Empty(DolgPr->Tn) // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nSumDolg := DolgPr->SumDolg
           nSumVip  := DolgPr->SumVip
           @ nRow,S_wCol()+34 get nSumDolg pict "9999999.99"  // \\ valid nSumDolg > 0
           @ nRow,S_wCol()+45 get nSumVip  pict "9999999.99"  // \\  valid nSumVip <= nSumDolg
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"DolgPr")
               DolgPr->SumDolg := nSumDolg
               DolgPr->SumVip  := nSumVip
               DolgPr->(DbUnlock())
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
////////////////////////////////////////////////////////////////////
Static function DtNext_(nToSkip)
Local nSkipped := 0, nDir := iif(nToSkip >= 0,1,-1)
if DolgPr->(LastRec()) # 0
  if nToSkip == 0
     DolgPr->(DbSkip(0))
  elseif nToSkip > 0
     While ( nSkipped < nToSkip .and. !DolgPr->(eof()) .and. ;
                        Left(dtos(DolgPr->Data),6) == Left(dtos(dData),6) )
         nSkipped++
         DolgPr->(DbSkip(1))
     end
   elseif nToSkip < 0
     While ( nSkipped > nToSkip .and. !DolgPr->(bof()) .and. ;
                        Left(dtos(DolgPr->Data),6) == Left(dtos(dData),6) )
         nSkipped--
         DolgPr->(DbSkip(-1))
     end
   end
   if DolgPr->(eof() )
       if nSkipped > 0
         nSkipped--
         DtBottom()
       end
    elseif DolgPr->(bof())
         nSkipped++
         DolgPr->(DbSeek(Left(dtos(dData),6)))
    elseif ! ( Left(dtos(DolgPr->Data),6) == Left(dtos(dData),6) )
         nSkipped += -nDir
         DolgPr->(DbSkip(-nDir))
    end
end
return ( nSkipped )
//////////////////////////////////////////////////////////////////////
Static Function DtBottom()
if DolgPr->(DbSeek(Left(dtos(dData),6)))
   While ( !DolgPr->(eof()) .and.  ;
            Left(dtos(DolgPr->Data),6) == Left(dtos(dData),6) )
    DolgPr->(DbSkip(1))
   end
   DolgPr->(DbSkip(-1))
else
   DolgPr->(DbGoBottom())
   DolgPr->(DbSkip(1))
end
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function FormVed() // Формирование ведомости
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      SelectOld := Select(),;
      SursorOld := SetCursor()
Local dData := sset[121], nSumma := nProc := nNumVed := 0, nRegim
Local dDatav:= date()

BEGIN SEQUENCE
if !OpenDolg()   ; break ; End
if !OpenList()   ; break ; End
if !OpenPlat()   ; break ; End

if VedPlat->(LastRec()) > 0
  S_Err({"Имеется не закрытая ведомость",;
         "Закройте эту ведомость",;
         "% Нажмите Enter для продолжения ;"})
  break
End
S_Open_S(12,38,14,65,sset[32]+","+sset[2]+",,,"+sset[32])
SetCursor(1)
@ 01,01 wsay "Укажите дату " wget dData Pict "@d" valid !empty(dData)
read
S_wClose()
if LastKey() == K_ESC ; break ; End
if !DolgPr->(DbSeek(Left(dtos(dData),6)))
  S_Err({"Отсутствуют данные",;
         "по задолженности",;
         "% Нажмите Enter для продолжения ;"})
  break
End
nRegim := S_Err({"Процент или сумма?","% Процент ; Сумма ;"})
S_Open_S(12,38,16,74,sset[32]+","+sset[2]+",,,"+sset[32])
if nRegim == 1
 @ 01,01 wsay "Укажите процент" wget nProc Pict "999" range 1,100
else
 @ 01,01 wsay "Укажите сумму" wget nSumma Pict "9999999.99" valid nSumma >= 0
End
@ 02,01 wsay "         N ведомости" wget nNumVed Pict "99999" valid nNumVed > 0
@ 03,01 wsay "         дату ведомости" wget dDataV Pict "@d" valid !Empty(dDataV)
read
S_wClose()
if LastKey() == K_ESC ; break ; End
if S_Err({" Ведомость по табельным номерам полная?","%  Да  ;  Нет  ;"}) == 1
  S_Sys({"Ожидайте","Формирую ведомость"})
  While ( !DolgPr->(eof()) .and. Left(dtos(DolgPr->Data),6) == Left(dtos(dData),6) )
   if nRegim == 1
      nSumKvip := round((DolgPr->SumDolg - DolgPr->SumVip)*nProc/100,2)
   else
      nSumKVip := min((DolgPr->SumDolg - DolgPr->SumVip),nSumma)
   End
   if nSumKvip > 0 .and. M_Append(20,"VedPlat")
      VedPlat->NumVed  := nNumVed
      VedPlat->DataV   := dDataV
      VedPlat->Data    := dData
      VedPlat->Ksp     := DolgPr->Ksp
      VedPlat->Tn      := DolgPr->Tn
      VedPlat->SumKvip := nSumKvip
      VedPlat->(DbUnlock())
   End
   DolgPr->(DbSkip(1))
  End
  S_Beep()
  S_Sys()
else
  S_Open_S(07,10,20,40,sset[32]+","+sset[2]+",,,"+sset[32])
  While .t.
   Scroll(S_wRow()+01,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1,-1)
   cTn := 0
   @ 01,08 wsay "<--- Табельный номер"
   @ 01,01 wget cTn pict "999999" valid cTn > 0
   read
   if LastKey() == K_ESC ; exit ; End
   cTn := strZero(cTn,6)
   if DolgPr->(Dbseek(Left(dtos(dData),6)+cTn))
      if nRegim == 1
         nSumKvip := round((DolgPr->SumDolg - DolgPr->SumVip)*nProc/100,2)
      else
         nSumKVip := min((DolgPr->SumDolg - DolgPr->SumVip),nSumma)
      End
      SuperLis->(Dbseek(cTn))
      @ 01,08 wsay SuperLis->Fio
      if nSumKvip > 0 .and. M_Append(20,"VedPlat")
        VedPlat->NumVed  := nNumVed
        VedPlat->DataV   := dDataV
        VedPlat->Data    := dData
        VedPlat->Ksp     := DolgPr->Ksp
        VedPlat->Tn      := DolgPr->Tn
        VedPlat->SumKvip := nSumKvip
        VedPlat->(DbUnlock())
      End
   else
     @ 01,08 wsay "Нет заработной платы "
   End
  End
  S_wClose()
End
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DbCloseAll()
Return ( Nil )
/////////////////////////////////////////////////////////////////////////
Function VedVed() // Ведение ведомости
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      SelectOld := Select(),;
      SursorOld := SetCursor(),;
      NortonOld := DeskTop:Norton()
Local  nTn, nSumKVip, dData, dDataV, nNumVed, nSumma
Local tb, nKey, nRow, GetList := {}

BEGIN SEQUENCE
if !OpenDolg()  ; break ; End
if !OpenList()  ; break ; End
if !OpenPlat()  ; break ; End
Set relation to Tn into SuperLis

if VedPlat->(LastRec()) == 0
  S_Err({"Ведомость отсутствует",;
         "% Нажмите Enter для продолжения ;"})
  break
End
dData  := VedPlat->Data
dDataV := VedPlat->DataV
nNumVed:= VedPlat->NumVed
//
SetCursor(0)
DbSelectArea("VedPlat")
S_Open_S(03,03,22,47,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Вед-ть "+str(nNumVed,5)+" от "+dtoc(dDataV)+" (за "+dtoc(dData)+")"
@ 02,01 wsay Repl("─",S_wMaxCol()-1)
@ 03,01 wsay "Цех │Табел.│    Ф И О           │    Сумма "
@ 04,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"3Удалить","4Регистр","5Корректи"}} )
tb := TBrowseDb(S_wRow()+05,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| VedPlat->Ksp+" "+VedPlat->Tn+" "+;
                                SuperLis->Fio+" "+;
                                str(VedPlat->SumKVip,10,2) } ))
VedPlat->(DbGoTop())
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
       case nKey == K_F3 .and. !Empty(VedPlat->Tn) // Удаление
           if VedPlat->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"VedPlat")
                 VedPlat->(DbDelete())
                 VedPlat->(DbUnlock())
                 VedPlat->(DbSkip(1))
                 if VedPlat->(eof()) ; VedPlat->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Вводите данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           While ( .t. )
             Scroll(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1,-1)
             nTn := nSumKVip :=  0
             @ 03,06 wget nTn pict "999999" valid nTn > 0
             read
             if LastKey() == K_ESC ; exit ; End
             nTn := strzero(nTn,6)
             if !SuperLis->(DbSeek(nTn))
                S_Beep()
                @ 03,13 wsay "Отсутствует"
                Loop
             End
             cKsp := SuperLis->Ksp
             @ 03,13 wsay SuperLis->Fio
             @ 03,01 wsay cKsp
             if VedPlat->(DbSeek(nTn))
                S_Beep()
                @ 03,13 wsay "Уже иммется"
                @ 03,34 wsay VedPlat->SumKVip pict "9999999.99"
                Loop
             End
             if !DolgPr->(DbSeek(left(dtos(dData),6)+nTn))
                S_Beep()
                @ 03,13 wsay "Нет задолженности"
                Loop
             End
             nSumma := DolgPr->SumDolg - DolgPr->SumVip
             @ 03,34 wget nSumKVip pict "9999999.99" range 0.01,nSumma
             read
             if LastKey() == K_ESC ; Loop ; End
             if M_Append(20,"VedPlat")
               VedPlat->Ksp  := cKsp
               VedPlat->Tn   := nTn
               VedPlat->Data := dData
               VedPlat->DataV:= dDataV
               VedPlat->SumKvip := nSumKVip
               VedPlat->NumVed  := nNumVed
               VedPlat->(DbUnlock())
             End
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5 .and. !Empty(VedPlat->Tn) // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nSumKVip := VedPlat->SumKVip
           BEGIN SEQUENCE
           if !DolgPr->(DbSeek(left(dtos(dData),6)+VedPlat->Tn))
              S_Beep()
              @ nRow,S_wCol()+13 say "Нет задолженности, Удалите запись"
              S_Inkey(3)
              break
           End
           nSumma := DolgPr->SumDolg - DolgPr->SumVip
           @ nRow,S_wCol()+34 get nSumKVip pict "9999999.99" range 0.01,nSumma
           read
           if LastKey() <> K_ESC .and.  M_Rlock(20,"VedPlat")
              VedPlat->SumKVip := nSumKVip
              VedPlat->(DbUnlock())
           End
           END SEQUENCE
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
//////////////////////////////////////////////////////////////////////
Function CloseVed() // Закрытие ведомости
Local dData, dDataV, nNumVed, nRecno, nLastrec, cKvu := "000"
Local ColorOld := SetColor(), CursorOld := SetCursor()

BEGIN SEQUENCE
if !OpenUder() ; break ; End
if !OpenDolg() ; break ; End
if !OpenArx()  ; break ; End
if !OpenPlat() ; break ; End

if VedPlat->(LastRec()) == 0
  S_Err({"Ведомость отсутствует",;
         "% Нажмите Enter для продолжения ;"})
  break
End
dData  := VedPlat->Data
dDataV := VedPlat->DataV
nNumVed:= VedPlat->NumVed
if S_Err({"Вы уверены, что желаите закрыть ",;
          "ведомость N "+str(nNumVed,5)+" от "+dtoc(dDataV),;
          "по задолженности за "+dtoc(dData),;
          "%  Нет  ;  Да  ;"}) == 1
  break
End
SetCursor(1)
S_Open_S(12,38,14,65,sset[32]+","+sset[2])
@ 01,01 wsay "Укажите вид удержания " wget cKvu valid VedsUder(@cKvu)
read
S_wClose()
SetColor(ColorOld)
SetCursor(CursorOld)
nLastRec := VedPlat->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Идет закрытие...."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
VedPlat->(DbGoTop())
While !VedPlat->(eof())
  if M_Append(20,"VedArx")
    VedArx->NumVed  := VedPlat->NumVed
    VedArx->DataV   := VedPlat->DataV
    VedArx->Data    := VedPlat->Data
    VedArx->Ksp     := VedPlat->Ksp
    VedArx->Tn      := VedPlat->Tn
    VedArx->SumKVip := VedPlat->SumKVip
    VedArx->Kvu     := cKvu
    VedArx->(DbUnlock())
  End
  if DolgPr->(Dbseek(Left(dtos(VedPlat->Data),6)+VedPlat->Tn)) .and. ;
                                                         M_Rlock(20,"DolgPr")
    DolgPr->SumVip += VedPlat->SumKVip
    DolgPr->(DbUnlock())
  End
  if M_Rlock(20,"VedPlat")
    VedPlat->(DbDelete())
    VedPlat->(DbUnlock())
  End
  S_Line_N(18,04,65,nLastRec,++nRecno)
  VedPlat->(Dbskip(1))
End
DbCloseAll()
use VedPlat
zap
ferase("VedPlat.ntx")
S_Beep(3)
S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////
Function PrnVed() // Печать ведомости
    Local nRecno, nLastRec, aFio, cFam, cName, cOt

    BEGIN SEQUENCE
        if !OpenList()  ; break ; End
        if !OpenPlat()  ; break ; End
        Set Relation to Tn into SuperLis

        cFileNal := "z010.dbf"               //+str(nKv,1)

        fErase(cFileNal)
        DbCreate(cFileNal,{{"branch",  "c",3,00},;
                           {"zpkod",   "c",10,00},;
                           {"card_no", "c",16,00},;
                           {"lstbl",   "c",10,00},;
                           {"fam",     "c",50,00},;
                           {"name",    "c",50,00},;
                           {"ot",      "c",50,00},;
                           {"rlsum",   "n",15,02},;
                           {"inn",     "c",10,00},;
                           {"rlkod",   "c",20,00}})
        Use (cFileNal)   new alias z010

        if VedPlat->(LastRec()) == 0
            S_Err({"Ведомость отсутствует",;
                   "% Нажмите Enter для продолжения ;"})
            break
        End
        dData  := VedPlat->Data
        dDataV := VedPlat->DataV
        nNumVed:= VedPlat->NumVed
        //
        nLastRec := VedPlat->(LastRec())
        S_Line_N(18,04,65,nLastRec,1)
        @ 01,06 wsay "Ожидайте..."
        @ 01,42 wsay "Формирую ведомость"
        nRecno := "[ По окончании будет подан звуковой сигнал ]"
        @ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
        nRecno := 0
        VedPlat->(DbGoTop())
        Set(20,"PRINT")
        Set(24,"VedPlat.txt")
        nSumList := nSumVsego := nList := nLine := nPp := 0
        While ( !VedPlat->(eof()) )
            if nList == 0 .or. nLine > 60
                if nList > 0
                    @ prow()+1,00 say "---------------------------------------------------------------------------"
                    @ prow()+1,00 say padr("Итого по листу ",33)+str(nSumList,10,2)
                    nLine += 2
                    for i := nLine to 65
                        @ prow()+1,00 say " "
                    Next
                    @ prow()+1,00 say "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
                    @ prow()+1,00 say " "
                EndIf
                @ prow()+1,00 say "  Платежная ведомость N "+str(nNumVed,5)+" на выплату зарплаты за "+S_cMonth(dData)+" месяц "+str(year(dData),4)+" г."
                @ prow()+1,00 say "                                                           Лист "+str(++nList,3)
                @ prow()+1,00 say "---------------------------------------------------------------------------"
                @ prow()+1,00 say " N  |Табель|   Фамилия Имя      |   Сумма  |    Роспись    | Примечание    "
                @ prow()+1,00 say "п/п |ноиер |   Отчество         |          |  в получении  |               "
                @ prow()+1,00 say "---------------------------------------------------------------------------"
                nLine := 6
                //nSumVsego += nSumList
                nSumList := 0
            EndIf
            @ prow()+1,00 say str(++nPp,4)+" "+VedPlat->Tn+" "+SuperLis->Fio+" "+;
              str(VedPlat->SumKVip,10,2)+" ______________________________"
            aFio  := SPLIT(SuperLis->Fio)
            aFio  := aSize(aFio, 3)
            cFam  := Alltrim(GetArrItem(aFio, IND_FAM))
            cName := Alltrim(GetArrItem(aFio, IND_NAM))
            cOt   := Alltrim(GetArrItem(aFio, IND_OT))
            IF M_Append(20,"z010")
                z010->branch := "358"
                z010->zpkod := "008"
                z010->lstbl := str(SuperLis->Indn) //VedPlat->Tn 
                z010->fam   := cFam
                z010->name  := cName
                z010->ot    := cOt
                z010->rlsum := VedPlat->SumKVip
                z010->inn   := str(SuperLis->Indn)
                z010->(DbUnlock())
            ENDIF
            @ prow()+1,00 say " "
            nSumList += VedPlat->SumKVip
            nSumVsego += VedPlat->SumKVip
            nLine += 2
            S_Line_N(18,04,65,nLastRec,++nRecno)
            VedPlat->(DbSkip(1))
        End
        //nSumVsego += nSumList
        @ prow()+1,00 say "---------------------------------------------------------------------------"
        @ prow()+1,00 say padr("Итого по листу ",33)+str(nSumList,10,2)
        nLine += 2
        for i := nLine to 65
          @ prow()+1,00 say " "
        Next
        @ prow()+1,00 say "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " В KАССУ ДЛЯ ОПЛАТЫ В СРОK "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " С ________ ПО ________ 20__ Г"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        nLine := PropisSum(nSumVsego,70)
        @ prow()+1,00 say  "В СУММЕ: "+nLine[1]
        for i := 2 to len(nLine)
          @ prow()+1,00 say  "         "+nLine[i]
        Next
        @ prow()+1,00 say  "                             ( ГРH. "+ltrim(str(int(nSumVsego),10))+" KОП. "+;
                           substr(str(nSumVsego,15,2),14,2)+")"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "                               ______________________ РУKОВОДИТЕЛЬ"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "                               ______________________ ГЛ.БУХГАЛТЕР"
        @ prow()+1,00 say  [ "__"________20__Г]
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "          ПЛАТЕЖHАЯ ВЕДОМОСТЬ N "+alltrim(str(nNumVed,5))
        @ prow()+1,00 say  "       НА ВЫПЛАТУ ЗАРАБОТНОЙ ПЛАТЫ"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "         ЗА "+S_cMonth(dData)+" месяц "+str(year(dData),4)+" года"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "                                        KОЛИЧЕСТВО ЛИСТОВ "+str(nList,3)
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "ПО HАСТОЯЩЕЙ ПЛАТЕЖHОЙ ВЕДОМОСТИ ВЫПЛАЧЕHО РУБЛЕЙ __________"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "____________________________________________________________"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "____________________________(__________ ГРН.____KОП.)"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "И ДЕПОHИРОВАHO ______________________________________________"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "____________________________(__________ ГРН.____KОП.)"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " ВЫПЛАТУ ПРОИЗВЕЛ _____________________________"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " ПРОВЕРИЛ БУХГАЛТЕР ___________________________"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        S_Beep(3)
        S_Line_N()
        Set(24,"")
        Set(20,"SCREEN")
        ShowPrn("VedPlat.txt","Ведомость",74)
        fErase("VedPlat.txt")
    END SEQUENCE
    DbCloseAll()
    Return ( Nil )
///////////////////////////////////////////////////////////////////////
Function PrnVedb() // Печать ведомости
    Local nRecno, nLastRec

    BEGIN SEQUENCE
        if !OpenList()  ; break ; End
        if !OpenPlat()  ; break ; End
        ///if !z008()  ; break ; End
        Set Relation to Tn into SuperLis
        cFileNal := "z008.dbf"               //+str(nKv,1)

        fErase(cFileNal)
        DbCreate(cFileNal,{{"fio",     "c",15,00},;
                           {"lstbl",   "C",10,00},;
                           {"rlsum","N",09,02},;
                           {"rlkod",  "c",05,00}})
        Use (cFileNal)   new alias z008


        if VedPlat->(LastRec()) == 0
          S_Err({"Ведомость отсутствует",;
                 "% Нажмите Enter для продолжения ;"})
          break
        End
        dData  := VedPlat->Data
        dDataV := VedPlat->DataV
        nNumVed:= VedPlat->NumVed
        //
        nLastRec := VedPlat->(LastRec())
        S_Line_N(18,04,65,nLastRec,1)
        @ 01,06 wsay "Ожидайте..."
        @ 01,42 wsay "Формирую ведомость"
        nRecno := "[ По окончании будет подан звуковой сигнал ]"
        @ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
        nRecno := 0
        VedPlat->(DbGoTop())
        Set(20,"PRINT")
        Set(24,"VedPlatb.txt")
        nSumList := nSumVsego := nList := nLine := nPp := 0
        While ( !VedPlat->(eof()) )
            if nList == 0 .or. nLine > 60
                if nList > 0
                    @ prow()+1,00 say "---------------------------------------------------------------------------"
                    @ prow()+1,00 say padr("Итого по листу ",33)+str(nSumList,10,2)
                    nLine += 2
                    for i := nLine to 65
                        @ prow()+1,00 say " "
                    Next
                    @ prow()+1,00 say "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
                    @ prow()+1,00 say " "
                EndIf
                @ prow()+1,00 say "  Платежная ведомость N "+str(nNumVed,5)+" на выплату зарплаты за "+S_cMonth(dData)+" месяц "+str(year(dData),4)+" г."
                @ prow()+1,00 say "                                                           Лист "+str(++nList,3)
                @ prow()+1,00 say "---------------------------------------------------------------------"
                @ prow()+1,00 say " N  |Табель|Индент    |   Фамилия Имя      |                 Сумма  | "
                @ prow()+1,00 say "п/п |номер |номер     |   Отчество         |                        | "
                @ prow()+1,00 say "--------------------------------------------------------------------- "
                nLine := 6
                * nSumVsego += nSumList
                nSumList := 0
            EndIf
            // @ prow()+1,00 say str(++nPp,4)+" "+VedPlat->Tn+" "+SuperLis->Fio+" "+;
            @ prow()+1,00 say str(++nPp,4)+" "+VedPlat->Tn+" "+str(SuperLis->Indn)+" "+SuperLis->Fio+" "+SuperLis->Bank +;
              str(VedPlat->SumKVip,10,2)+"             __________________"

            M_Append(20,"z008")
            z008->fio  := SuperLis->Fio
            z008->lstbl   := str(SuperLis->Indn)
            z008->rlsum    := VedPlat->SumKVip
            z008->(DbUnlock())

            @ prow()+1,00 say " "
            nSumList += VedPlat->SumKVip
            nSumVsego += VedPlat->SumKVip
            nLine += 2
            S_Line_N(18,04,65,nLastRec,++nRecno)
            VedPlat->(DbSkip(1))
        End
        * nSumVsego += nSumList
        @ prow()+1,00 say "---------------------------------------------------------------------------"
        @ prow()+1,00 say padr("Итого по листу ",33)+str(nSumList,10,2)
        //nLine += 2
        //for i := nLine to 65
        //  @ prow()+1,00 say " "
        //Next
        //@ prow()+1,00 say "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        @ prow()+1,00 say  " Итого по ведомости выдыно в ПРИВАТ БАНКЕ "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " С ________ ПО ________ 20__ Г"
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        nLine := PropisSum(nSumVsego,70)
        @ prow()+1,00 say  "В СУММЕ: "+nLine[1]
        for i := 2 to len(nLine)
          @ prow()+1,00 say  "         "+nLine[i]
        Next
        @ prow()+1,00 say  "                             ( ГРH. "+ltrim(str(int(nSumVsego),10))+" KОП. "+;
                           substr(str(nSumVsego,15,2),14,2)+")"
        //@ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "                               ______________________ РУKОВОДИТЕЛЬ"
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  " "
        @ prow()+1,00 say  "                               ______________________ ГЛ.БУХГАЛТЕР"
        @ prow()+1,00 say  [ "__"________20__Г]
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  "          ПЛАТЕЖHАЯ ВЕДОМОСТЬ N "+alltrim(str(nNumVed,5))
        //@ prow()+1,00 say  "       НА ВЫПЛАТУ ЗАРАБОТНОЙ ПЛАТЫ"
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  "         ЗА "+S_cMonth(dData)+" месяц "+str(year(dData),4)+" года"
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  "                                        KОЛИЧЕСТВО ЛИСТОВ "+str(nList,3)
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  "ПО HАСТОЯЩЕЙ ПЛАТЕЖHОЙ ВЕДОМОСТИ ВЫПЛАЧЕHО РУБЛЕЙ __________"
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  "____________________________________________________________"
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  "____________________________(__________ ГРН.____KОП.)"
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  "И ДЕПОHИРОВАHO ______________________________________________"
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  "____________________________(__________ ГРН.____KОП.)"
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " ВЫПЛАТУ ПРОИЗВЕЛ _____________________________"
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " ПРОВЕРИЛ БУХГАЛТЕР ___________________________"
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        //@ prow()+1,00 say  " "
        S_Beep(3)
        S_Line_N()
        Set(24,"")
        Set(20,"SCREEN")
        ShowPrn("VedPlatb.txt","Ведомость",74)
        //fErase("VedPlat.txt")
    END SEQUENCE
    DbCloseAll()
    Return ( Nil )
////////////////////////////////////////
Function PrnVedby() // Печать ведомости
Local nRecno, nLastRec

BEGIN SEQUENCE
if !OpenList()  ; break ; End
if !OpenPlat()  ; break ; End
///if !z008()  ; break ; End
Set Relation to Tn into SuperLis
     cFileNal := "z6.dbf"               //+str(nKv,1)

        fErase(cFileNal)
  
     DbCreate(cFileNal,{{"tran_date","d",08,00},;
                   {"slip_nr","n",5,00},;
                   {"tan_type",   "C",02,00},;
                   {"card_acct","N",14,00},;
                   {"amount","N",12,02},;
                   {"currency",   "C",03,00},;
                   {"operator",  "c",05,00}})
         Use (cFileNal)   new alias z6
//DbCreate(cFileNal,{{"fio",     "c",15,00},;
//                   {"lstbl",   "C",10,00},;
//                   {"rlsum","N",09,02},;
//                   {"rlkod",  "c",05,00}})
//Use (cFileNal)   new alias z008

if VedPlat->(LastRec()) == 0
  S_Err({"Ведомость отсутствует",;
         "% Нажмите Enter для продолжения ;"})
  break
End
dData  := VedPlat->Data
dDataV := VedPlat->DataV
nNumVed:= VedPlat->NumVed
//
nLastRec := VedPlat->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую ведомость"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
VedPlat->(DbGoTop())
Set(20,"PRINT")
Set(24,"VedPlatb.txt")
nSumList := nSumVsego := nList := nLine := nPp :=nPp1 := 0
While ( !VedPlat->(eof()) )
 if nList == 0 .or. nLine > 60
   if nList > 0
      @ prow()+1,00 say "---------------------------------------------------------------------------"
      @ prow()+1,00 say padr("Итого по листу ",33)+str(nSumList,10,2)
      nLine += 2
      for i := nLine to 65
          @ prow()+1,00 say " "
      Next
      @ prow()+1,00 say "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
      @ prow()+1,00 say " "
   End
   @ prow()+1,00 say "  Платежная ведомость N "+str(nNumVed,5)+" на выплату зарплаты за "+S_cMonth(dData)+" месяц "+str(year(dData),4)+" г."
   @ prow()+1,00 say "                                                           Лист "+str(++nList,3)
   @ prow()+1,00 say "---------------------------------------------------------------------"
   @ prow()+1,00 say " N  |Табель|Индент    |   Фамилия Имя      |                 Сумма  | "
   @ prow()+1,00 say "п/п |номер |номер     |   Отчество         |                        | "
   @ prow()+1,00 say "--------------------------------------------------------------------- "
   nLine := 6
  * nSumVsego += nSumList
   nSumList := 0
  End
 // @ prow()+1,00 say str(++nPp,4)+" "+VedPlat->Tn+" "+SuperLis->Fio+" "+;
 @ prow()+1,00 say str(++nPp,4)+" "+VedPlat->Tn+" "+str(SuperLis->Indn)+" "+SuperLis->Fio+" "+SuperLis->Bank +;
  str(VedPlat->SumKVip,10,2)+"             __________________"

    M_Append(20,"z6")
    z6->tran_date := VedPlat->DataV
    z6->slip_nr  := ++NPP1
    z6->card_acct  := val(SuperLis->Bank)
      z6->tan_type   := "20"     
      z6->amount    := VedPlat->SumKVip
      z6-> currency  := "UAH"
      z6-> operator  := "BIFIT"
 z6->(DbUnlock())


  @ prow()+1,00 say " "
  nSumList += VedPlat->SumKVip
  nSumVsego += VedPlat->SumKVip
nLine += 2
  S_Line_N(18,04,65,nLastRec,++nRecno)
  VedPlat->(DbSkip(1))
End
* nSumVsego += nSumList
@ prow()+1,00 say "---------------------------------------------------------------------------"
@ prow()+1,00 say padr("Итого по листу ",33)+str(nSumList,10,2)
//nLine += 2
//for i := nLine to 65
//  @ prow()+1,00 say " "
//Next
//@ prow()+1,00 say "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
//@ prow()+1,00 say  " "
//@ prow()+1,00 say  " "
//@ prow()+1,00 say  " "
@ prow()+1,00 say  " Итого по ведомости выдыно в ПРИВАТ БАНКЕ "
//@ prow()+1,00 say  " "
//@ prow()+1,00 say  " С ________ ПО ________ 20__ Г"
//@ prow()+1,00 say  " "
//@ prow()+1,00 say  " "
nLine := PropisSum(nSumVsego,70)
@ prow()+1,00 say  "В СУММЕ: "+nLine[1]
for i := 2 to len(nLine)
  @ prow()+1,00 say  "         "+nLine[i]
Next
@ prow()+1,00 say  "                             ( ГРH. "+ltrim(str(int(nSumVsego),10))+" KОП. "+;
                   substr(str(nSumVsego,15,2),14,2)+")"
//@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  "                               ______________________ РУKОВОДИТЕЛЬ"
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  "                               ______________________ ГЛ.БУХГАЛТЕР"
@ prow()+1,00 say  [ "__"________20__Г]
S_Beep(3)
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn("VedPlatb.txt","Ведомость",74)
//fErase("VedPlat.txt")
END SEQUENCE
DbCloseAll()
Return ( Nil )

/////////////////////////////////////////////////////////
Function LookDolg() // Просмотр задолженности
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      SelectOld := Select(),;
      SursorOld := SetCursor(),;
      NortonOld := DeskTop:Norton()
Local tb, nKey, nRow, GetList := {}, nTn

BEGIN SEQUENCE
if !OpenArx()  ; break ; End
if !OpenList() ; break ; End
if !OpenDolg() ; break ; End
Sx_SetTagNo(2)
Set Relation to Tn into SUPERLIS

SetCursor(0)
DbSelectArea("DolgPr")
S_Open_S(03,03,22,75,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Табел.│    Ф И О           │Начислено │Выплачено │Остаток   │ Дата     "
@ 02,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"6Поиск","7Выплата","8Справка"}} )
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| DolgPr->Tn+" "+;
                                SuperLis->Fio+" "+;
                                str(DolgPr->SumDolg,10,2)+" "+;
                                str(DolgPr->SumVip,10,2)+" "+;
                                str(DolgPr->SumDolg-DolgPr->SumVip,10,2)+" "+;
                                dtoc(DolgPr->Data) }))
DolgPr->(DbGoTop())
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
       case nKey == K_F6  // Поиск
           tb:DeHilite()
           nRow := DolgPr->(Recno())
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Укажите табельный номер",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           Scroll(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1,-1)
           BEGIN SEQUENCE
           nTn := 0
           @ 03,01 wget nTn pict "999999" valid nTn > 0
           read
           if LastKey() == K_ESC ; break ; End
           nTn := strzero(nTn,6)
           if !DolgPr->(DbSeek(nTn))
              S_Err({"Данные отсутствует","% Нажмите ENTER ;"})
              DolgPr->(DbGoTo(nRow))
              break
           End
           END SEQUENCE
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F7 .and. !Empty(DolgPr->Tn) // Выплата
           LookVipl(DolgPr->Tn)
           FreshOrder(tb)
       case nKey == K_F8 .and. !Empty(DolgPr->Tn) // Справка
           BEGIN SEQUENCE
           nRow := DolgPr->(Recno())
           cTn  := DolgPr->Tn
           Set(20,"PRINT")
           Set(24,"Sprav.txt")
           if DolgPr->(Dbseek(cTn))
              nSumma := 0
              @ prow()+1,00 say " "
              @ prow()+1,00 say DolgPr->Tn+" "+SuperLis->Fio
              @ prow()+1,00 say "-----------------------------------------------------------------------"
              @ prow()+1,00 say " Дата     | Сумма    | Сумма    | Остаток  * N   |   Дата   |  Сумма   "
              @ prow()+1,00 say "задолж.   | начислена| выплачена|за предпр.*ведом|ведомости |выплачена "
              @ prow()+1,00 say "-----------------------------------------------------------------------"
              While !DolgPr->(eof()) .and. cTn == DolgPr->Tn
                dData := DolgPr->Data
                cLine := dtoc(dData)+" "+str(DolgPr->SumDolg,10,2)+" "+;
                         str(DolgPr->SumVip,10,2)+" "+;
                         str(DolgPr->SumDolg-DolgPr->SumVip,10,2)+"*"
                if VedArx->(Dbseek(cTn+left(dtos(dData),6)))
                  cLine += str(VedArx->NumVed,5)+" "+dtoc(VedArx->DataV)+" "+;
                           str(VedArx->SumKVip,10,2)
                  @ prow()+1,00 say cLine
                  VedArx->(DbSkip(1))
                  While !VedArx->(eof()) .and. cTn == VedArx->Tn .and. ;
                              left(dtos(VedArx->Data),6) == left(dtos(dData),6)
                     @ prow()+1,43 say "*"+str(VedArx->NumVed,5)+" "+dtoc(VedArx->DataV)+" "+;
                       str(VedArx->SumKVip,10,2)
                     VedArx->(DbSkip(1))
                  End
                else
                  @ prow()+1,00 say cLine
                End
                nSumma += DolgPr->SumDolg-DolgPr->SumVip
                DolgPr->(DbSkip(1))
              End
           End
           @ prow()+1,00 say "-----------------------------------------------------------------------"
           @ prow()+1,00 say space(33)+str(nSumma,10,2)
           @ prow()+1,00 say " "
           END SEQUENCE
           Set(24,"")
           Set(20,"SCREEN")
           ShowPrn("Sprav.txt"," Данные ",74)
           fErase("Sprav.txt")
           DolgPr->(DbGoTo(nRow))
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
////////////////////////////////////////////////////////////////////////
Function LookVipl(cTn) // Просмотр Выплаты
Local ColorOld := SetColor(sset[5]+","+sset[6]+",,,"+sset[32]),;
      SelectOld := Select(),;
      SursorOld := SetCursor(),;
      NortonOld := DeskTop:Norton()
Local tb, nKey, GetList := {}
Private pTn := cTn

if !VedArx->(Dbseek(pTn))
  S_Err({"Данные отсутствуют"})
  Return ( Nil )
End
BEGIN SEQUENCE
DbSelectArea("VedArx")
S_Open_S(05,11,21,55,sset[5]+","+sset[6]+",,,"+sset[32])
@ 01,01 wsay pTn+" "+SuperLis->Fio
@ 02,01 wsay Repl("─",S_wMaxCol()-1)
@ 03,01 wsay "  N  │  Дата    │   Сумма  │ За какую │вид"
@ 04,01 wsay "ведом│ выплаты  │ выплаты  │  дату    │уд."
@ 05,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"9 "}} )
tb := TBrowseDb(S_wRow()+06,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| str(VedArx->NumVed,5)+" "+;
                                dtoc(VedArx->DataV)+" "+;
                                str(VedArx->SumKVip,10,2)+" "+;
                                dtoc(VedArx->Data)+" "+;
                                VedArx->Kvu }))
tb:goTopBlock    := { | | VedArx->(DbSeek(pTn)) }
tb:goBottomBlock := { | | TnBottom()   }
tb:SkipBlock     := { |n| TnNext_(n)   }
Vedarx->(DbSeek(pTn))
While ( .t. )
  nKey := 0
  While ( !tb:Stabilize() )
    if ( nKey := S_Inkey() ) != 0 ; exit ; end
  end
  if nKey == 0 ; nKey := S_InKey(0)  ; end
  if nKey == K_ESC ; exit ; end
  if tb:Stable  ; ApplyKey(nkey,tb) ; End
End
tb := nil
S_wClose()
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DeskTop:Norton := NortonOld
DbselectArea(SelectOld)
Return ( Nil )
///////////////////////////////////////////////////////////////////////
Static function TnNext_(nToSkip)
Local nSkipped := 0, nDir := iif(nToSkip >= 0,1,-1)
if VedArx->(LastRec()) # 0
  if nToSkip == 0
     VedArx->(DbSkip(0))
  elseif nToSkip > 0
     While ( nSkipped < nToSkip .and. !VedArx->(eof()) .and. pTn == VedArx->Tn )
         nSkipped++
         VedArx->(DbSkip(1))
     end
   elseif nToSkip < 0
     While ( nSkipped > nToSkip .and. !VedArx->(bof()) .and. pTn == VedArx->Tn )
         nSkipped--
         VedArx->(DbSkip(-1))
     end
   end
   if VedArx->(eof() )
       if nSkipped > 0
         nSkipped--
         DtBottom()
       end
    elseif VedArx->(bof())
         nSkipped++
         VedArx->(DbSeek(pTn))
    elseif ! ( pTn == VedArx->Tn )
         nSkipped += -nDir
         VedArx->(DbSkip(-nDir))
    end
end
return ( nSkipped )
//////////////////////////////////////////////////////////////////////
Static Function TnBottom()
if VedArx->(DbSeek(pTn))
   While ( !VedArx->(eof()) .and.  pTn == VedArx->Tn )
    VedArx->(DbSkip(1))
   end
   VedArx->(DbSkip(-1))
else
   VedArx->(DbGoBottom())
   VedArx->(DbSkip(1))
end
Return ( Nil )
//////////////////////////////////////////////////////////////////////
Function SpravDolg()  // справка
Local nLastRec, nRecno, dData, nSumDolg, nSumVip, nSumma
Local dDataRas := sset[121]

BEGIN SEQUENCE
if !OpenArx()  ; break ; End
if !OpenDolg() ; break ; End

nLastRec := DolgPr->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую справку...."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
DolgPr->(DbGoTop())
Set(20,"PRINT")
Set(24,"Spavka.txt")
@ prow()+1,00 say " "
@ prow()+1,00 say " Справка по задолженности"
@ prow()+1,00 say "   по заработной плате"
@ prow()+1,00 say "-----------------------------------------------------"
@ prow()+1,00 say " Дата  |Начислено |Выплачено |Остаток   |Выпл тек мес"
@ prow()+1,00 say "-----------------------------------------------------"
fSumDolg := fSumVip := fSumma := fSumTek := 0
While !DolgPr->(eof())
  dData := DolgPr->Data
  nSumDolg := nSumVip := nSumTek := 0
  While !DolgPr->(eof()) .and. left(dtos(DolgPr->Data),6) == left(dtos(dData),6)
    nSumDolg += DolgPr->SumDolg
    nSumVip  += DolgPr->SumVip
    if VedArx->(DbSeek(DolgPr->Tn+left(dtos(dDataRas),6)))
       While DolgPr->Tn == VedArx->Tn .and. ;
             left(dtos(VedArx->DataV),6) == left(dtos(dDataRas),6) .and. ;
             !VedArx->(eof())
          if left(dtos(VedArx->Data),6) == left(dtos(dData),6)
              nSumTek += VedArx->SumKVip
          End
          VedArx->(DbSkip(1))
       End
    End
    S_Line_N(18,04,65,nLastRec,++nRecno)
    DolgPr->(DbSkip(1))
  End
  @ prow()+1,00 say Substr(dtoc(dData),4)+" "+;
    str(nSumDolg,10,2)+" "+;
    str(nSumVip,10,2)+" "+;
    str(nSumDolg-nSumVip,10,2)+" "+str(nSumTek,10,2)
  fSumma += nSumDolg-nSumVip
  fSumDolg += nSumDolg
  fSumVip  += nSumVip
  fSumTek  += nSumTek
End
@ prow()+1,00 say "----------------------------------------------------"
@ prow()+1,00 say "        "+;
              str(fSumDolg,10,2)+" "+;
              str(fSumVip,10,2)+" "+;
              str(fSumma,10,2)+" "+str(fSumTek,10,2)
@ prow()+1,00 say " "
@ prow()+1,00 say ""
Set(24,"")
Set(20,"SCREEN")
S_Line_N()
S_Beep(3)
ShowPrn("Spavka.txt"," Справку ",74)
fErase("Spavka.txt")
END SEQUENCE
Set(20,"SCREEN")
DbCloseall()
fErase("VedArxR.Cdx")
Return ( Nil )
/////////////////////////////////////////////////////////////////////////
Function PackVed() // Удаление информации
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      SursorOld := SetCursor()
Local dData := sset[121]

if S_Err({"Вы уверены в том, что хочите удалить информацию?",;
   "%  Нет  ;   Да  ;"}) == 1
   Return ( Nil )
End
BEGIN SEQUENCE
S_Open_S(12,38,14,65,sset[32]+","+sset[2]+",,,"+sset[32])
SetCursor(1)
@ 01,01 wsay "Укажите дату " wget dData Pict "@d" valid !empty(dData)
read
S_wClose()
if LastKey() == K_ESC ; break ; End
//
if !OpenDolg()   ; break ; End
if !OpenArx(.t.) ; break ; End

S_Sys({"Ожидайте...","Удаляю информацию"})
DbSelectArea("DolgPr")
Delete all for left(dtos(DolgPr->Data),6) == left(dtos(dData),6)
Pack
//
DbSelectArea("VedArx")
Delete all for left(dtos(VedArx->Data),6) == left(dtos(dData),6)
Pack
//
S_Sys()
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////
Function VedProc()
Local ColorOld := SetColor(), nKey, nRow, nInd, CursorOld := SetCursor(0)
Local NortonOld := DeskTop:Norton(), tb

BEGIN SEQUENCE
if !OpenUder()  ; break ; End
if !OpenList()  ; break ; End
if !OpenDbf_("YdProc")   ; break ; End

DbSelectArea("YdProc")
Set Relation to strzero(Tn,6) into SuperLis
YdProc->(DbGoTop())
S_Open_S(01,13,22,71,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Таб.N   Фамилия             Сумма      Дата    Кву  N вед"
//            ...... .................... ......... ...... ...
@ 02,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"3Удалить","4Регистр","5Корректи","6Поиск","8Ведомость","9Сумма"}} )
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| str(YdProc->Tn,6)+" "+SuperLis->Fio+" "+;
                                str(YdProc->Summa,9,2)+" "+;
                                str(YdProc->Data,8)+" "+;
                                YdProc->Kvu+" "+;
                                str(YdProc->Ved,3) }))
nItog := 0
While !YdProc->(eof())
 nItog += YdProc->Summa
 YdProc->(DbSkip(1))
End
YdProc->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := S_Inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   @ 02,28 wsay nItog pict "9999999.99"
   if nKey == 0 ; nKey := S_InKey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F9  // Сумма
           nKey := YdProc->(Recno())
           YdProc->(DbGoTop())
           nSumma := 0
           S_Sys({"Минутку.....","Подсчитываю сумму"})
           While !YdProc->(eof())
            nSumma += YdProc->Summa
            YdProc->(DbSkip(1))
           End
           S_Sys()
           S_Err({"Общая сумма составляет:"+alltrim(str(nSumma,15,2))})
           YdProc->(DbGoTo(nKey))
           FreshOrder(tb)
       Case nKey == K_F8  // Ведомость
           ProcVed()
           FreshOrder(tb)
       case nKey == K_F3  // Удаление
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"YdProc")
                 nItog -= YdProc->Summa
                 YdProc->(DbDelete())
                 YdProc->(DbUnlock())
                 YdProc->(DbSkip(1))
                 if YdProc->(eof()) ; YdProc->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4 // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Регистрируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           BEGIN SEQUENCE
           @ 03,01 wsay space(S_wMaxCol()-1)
           nTn := nData := nSumma := nVed := 0
           cKvu:= "000"
           @ 03,01 wget nTn pict "999999" valid nTn > 0
           read
           if LastKey() == K_ESC ; break ; End
           if !SuperLis->(DbSeek(strzero(nTn,6)))
              S_Err({"Отсутствует в базе"})
              break
           End
           @ 03,08 wsay SuperLis->Fio
           @ 03,29 wget nSumma pict "999999.99"
           @ 03,39 wget nData  pict "99999999" valid int(nData/10000) > 1998 .and. ;
             val(Substr(str(nData,8),5,2)) >= 1 .and. val(Substr(str(nData,8),5,2)) <= 12 .and. ;
             val(Substr(str(nData,8),7,2)) >= 1 .and. val(Substr(str(nData,8),7,2)) <= 31
           @ 03,48 wget cKvu valid VedsUder(@cKvu)
           @ 03,52 wget nVed pict "999"
           read

           if LastKey() <> K_ESC .and. M_Append(20,"YdProc")
               YdProc->Tn     := nTn
               YdProc->Ksp    := SuperLis->Ksp
               YdProc->Data   := nData
               YdProc->Summa  := nSumma
               YdProc->Kvu    := cKvu
               YdProc->Ved    := nVed
               YdProc->(DbUnlock())
               nItog += YdProc->Summa
           End
           END SEQUENCE
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nSumma := nSumOld := YdProc->Summa
           nData  := YdProc->Data
           cKvu   := YdProc->Kvu
           nVed   := YdProc->Ved
           @ nRow,S_wCol()+29 get nSumma pict "999999.99"
           @ nrow,S_wCol()+39 get nData  pict "99999999" valid int(nData/10000) > 1998 .and. ;
             val(Substr(str(nData,8),5,2)) >= 1 .and. val(Substr(str(nData,8),5,2)) <= 12 .and. ;
             val(Substr(str(nData,8),7,2)) >= 1 .and. val(Substr(str(nData,8),7,2)) <= 31
           @ nRow,S_wCol()+48 get cKvu valid VedsUder(@cKvu)
           @ nRow,S_wCol()+52 get nVed pict "999"
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"YdProc")
               YdProc->Summa  := nSumma
               YdProc->Data   := nData
               YdProc->Kvu    := cKvu
               nItog += YdProc->Summa
               YdProc->Ved    := nVed
               nItog -= nSumOld
               YdProc->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F6 // Поиск
           tb:DeHilite()
           nRow := YdProc->(Recno())
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Укажите табельный номер [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           @ 03,01 wsay space(S_wMaxCol()-1)
           nTn := 0
           @ 03,01 wget nTn pict "999999" valid nTn > 0
           read
           if LastKey() <> K_ESC
              if !YdProc->(DbSeek(str(nTn,6)))
                S_Err({" Данные отсутствуют"})
                YdProc->(DbGoto(nRow))
              End
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F10 // Чистка
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите сделать чистку",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1
               nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
               @ S_wLastRow(),S_wCol()+01 say padc("Ожидайте... Идет чистка",S_wMaxCol()-1) color sset[15]
               YdProc->(DbGoTop())
               While !YdProc->(eof())
                 if M_Rlock(20,"YdProc")
                    nItog -= YdProc->Summa
                    YdProc->(DbDelete())
                    YdProc->(DbUnlock())
                  End
                  YdProc->(DbSkip(1))
               End
               YdProc->(DbGoTop())
               RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           end
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
SetCursor(CursorOld)
DeskTop:Norton := NortonOld
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Static function ProcVed()
Local nRecno := YdProc->(Recno()), cFile := "VedProc", nLen, dData, dSumma
Local nLastRec := YdProc->(LastRec()), nCurRecno, cData, nSumma, cKvo, cSumma
Local dDato := sset[121], nVed

DbCreate(cFile,{   {"Data", "D",08,00},;
                   {"Tnr",  "N",06,00},;
                   {"Fio",  "C",20,00},;
                   {"Kvo",  "C",03,00},;
                   {"VED",  "N",03,00},;
                   {"Summa","N",15,02} })

if !M_Use(cFile,.t.,"Work") ; break ; end
Index on dtos(Data)+Kvo+str(Tnr,6) to (cFile)
//
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую данные...."
nCurRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nCurRecno))/2 say nCurRecno
nCurRecno := 0
YdProc->(DbGoTop())
nVed := YdProc->Ved
While !YdProc->(eof())
  cData := iif(!Empty(YdProc->Data),str(YdProc->Data,6),Left(dtos(dDato),6))
  Work->(Dbappend())
  Work->Data  := ctod("01."+substr(cData,5,2)+"."+Substr(cData,1,4))
  Work->Tnr   := YdProc->Tn
  Work->Fio   := SuperLis->Fio
  Work->Kvo   := YdProc->Kvu
  Work->Summa := YdProc->Summa
  S_Line_N(18,04,65,nLastRec,++nCurRecno)
  YdProc->(Dbskip(1))
End
S_Beep()
S_Line_N()
DbSelectArea("Work")
nCurRecno := Work->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую ведомость удержаний"
nCurRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nCurRecno))/2 say nCurRecno
nCurRecno := nSumma := 0
Work->(DbGoTop())
Set(20,"PRINT")
Set(24,cFile+".Txt")
nLen := 71
@ prow()+1,00 say padc("Ведомость N"+str(nVed,3),nLen)
@ prow()+1,00 say padc("на удержанние из заработной платы",nLen)
@ prow()+1,00 say padc("ПРОЧИЕ УДЕРЖАНИЯ",nLen)
@ prow()+1,00 say padc("в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года",nLen)
@ prow()+1,00 say Repl("-",nLen)
@ prow()+1,00 say " Дата   Таб.N  Фамилия              Вид Удержания              Сумма   "
@ prow()+1,00 say Repl("-",nLen)
While !Work->(eof())
  dData  := Left(dtos(Work->Data),6)
  dSumma := 0
  While dData == Left(dtos(Work->Data),6) .and. !Work->(eof())
    cKvo   := Work->Kvo
    cSumma := 0
    Suder->(Dbseek(cKvo))
    While cKvo == Work->Kvo .and. dData == Left(dtos(Work->Data),6) .and. !Work->(eof())
       @ prow()+1,00 say Substr(dtoc(Work->Data),4)+" "+;
                         str(Work->Tnr,6)+" "+Work->Fio+" "+;
                         Work->Kvo+" "+Suder->Naim+" "+;
                         str(Work->Summa,15,2)
       cSumma += Work->Summa
       S_Line_N(18,04,65,nLastRec,++nCurRecno)
       Work->(DbSkip(1))
    End
    @ prow()+1,00 say padl("Итого по виду оплаты      "+str(cSumma,15,2),nLen)
    dSumma += cSumma
  End
  @ prow()+1,00 say padl("Итого по дате               "+str(dSumma,15,2),nLen)
  nSumma += dSumma
End
@ prow()+1,00 say Repl("=",nLen)
@ prow()+1,00 say padl("Всего за месяц         "+str(nSumma,15,2),nLen)
@ prow()+1,00 say " "
@ prow()+1,00 say ""
S_Beep(3)
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn(cFile+".txt","Ведомость прочих удержаний",74)
Work->(DbCloseArea())
DbSelectArea("YdProc")
YdProc->(DbGoto(nRecno))
fErase(cFile+".txt")
fErase(cFile+".Dbf")
fErase(cFile+".Cdx")
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Function CloseProc() // Закрытие прочих удержаний
Local dDato := sset[121], dDataV, nNumVed, nRecno, nLastrec, dData
Local cFileWk := "ClosProc", nSumma, dSumma, cSumma, cKvo
Local cData := dtos(sset[121]), lYes

BEGIN SEQUENCE
DbCreate(cFileWk,{ {"Data", "D",08,00},;
                   {"Tnr",  "N",06,00},;
                   {"Kvo",  "C",03,00},;
                   {"VED",  "N",03,00},;
                   {"Summa","N",15,02},;
                   {"SumNo","N",15,02} })
if !M_Use(cFileWk,.t.,"Work") ; break ; end
Index on str(Tnr,6)+Kvo to (cFileWk)
//
if !OpenVip()  ; break ; End
if !OpenList()  ; break ; End
if !OpenUder()  ; break ; End
if !OpenDolg()  ; break ; End
DolgPr->(Sx_SetTagNo(2))
if !OpenArx()   ; break ; End
if !OpenDbf_("YdProc") ; break ; End
if YdProc->(LastRec()) == 0
  S_Err({"Данные отсутствуют",;
         "% Нажмите Enter для продолжения ;"})
  break
End
nVed := YdProc->Ved
nLastRec := YdProc->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Идет закрытие...."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
YdProc->(DbGoTop())
nData := str(YdProc->data,8)
nData := ctod(Substr(nData,7,2)+"."+;
              Substr(nData,5,2)+"."+;
              Substr(nData,1,4))
While !YdProc->(eof())
  nSumYd := YdProc->Summa
  lYes   := .f.
  if !DolgPr->(Dbseek(strZero(YdProc->Tn,6)))
     Work->(Dbappend())
     Work->Data  := nData
     Work->Tnr   := YdProc->Tn
     Work->Kvo   := YdProc->Kvu
     Work->Summa := 0
     Work->SumNo := nSumYd
  Else
     While DolgPr->Tn == strZero(YdProc->Tn,6) .and. !DolgPr->(eof())
       if DolgPr->SumDolg - DolgPr->SumVip  > 0
          nSumma := min(DolgPr->SumDolg - DolgPr->SumVip,nSumYd)
          Work->(Dbappend())
          Work->Data  := DolgPr->Data
          Work->Tnr   := YdProc->Tn
          Work->Kvo   := YdProc->Kvu
          Work->Summa := nSumma
          Work->SumNo := 0
          lYes   := .t.
          if M_Rlock(20,"DolgPr")
             DolgPr->SumVip += nSumma
             DolgPr->(DbUnlock())
          End
          if Empty(nSumYd -= nSumma) ; Exit ; End
       End
       DolgPr->(DbSkip(1))
    End
    if nSumYd > 0
      if lYes
         Work->SumNo := nSumYd
      else
          Work->(Dbappend())
          Work->Data  := nData
          Work->Tnr   := YdProc->Tn
          Work->Kvo   := YdProc->Kvu
          Work->Summa := 0
          Work->SumNo := nSumYd
      End
    End
  End
  YdProc->(DbSkip(1))
End
DbSelectArea("Work")
Set Relation to StrZero(Tnr,6) into SUPERLIS,;
             to Kvo into Suder
nLastRec := Work->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую ведомость удержаний"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := nSumma := 0
Work->(DbGoTop())
Set(20,"PRINT")
Set(24,cFileWk+".Txt")
nLen := 90
@ prow()+1,00 say   padc("Ведомость N"+str(nVed,3),nLen) //  padc("Ведомость",nLen)
@ prow()+1,00 say padc("на удержанние из заработной платы",nLen)
@ prow()+1,00 say padc("ПРОЧИЕ УДЕРЖАНИЯ",nLen)
@ prow()+1,00 say padc("в "+str(day(nData),2)+" "+;
                 S_cMonth(nData)+" месяце "+str(year(nData),4)+" года",nLen)
@ prow()+1,00 say Repl("-",nLen)
@ prow()+1,00 say " Таб.N  Фамилия              Вид Удержания           Дата удерж.   Сумма   Примечание"
@ prow()+1,00 say Repl("-",nLen)
While !Work->(eof())
    if M_Append(20,"VedArx")
      VedArx->NumVed  := 0
      VedArx->DataV   := sset[121]
      VedArx->Data    := Work->Data
      VedArx->Ksp     := SUPERLIS->Ksp
      VedArx->Tn      := strzero(Work->Tnr,6)
      VedArx->SumKVip := Work->Summa
      VedArx->Kvu     := Work->Kvo
      VedArx->Numved  := nVed
      VedArx->(DbUnlock())
    End
    if Work->SumNo > 0
//       AddInf(Work->Data,Work->SumNo,Work->Kvo)
    End
    @ prow()+1,00 say str(Work->Tnr,6)+" "+SuperLis->Fio+" "+;
                      Work->Kvo+" "+Suder->Naim+" "+;
                      dtoc(Work->Data)+" "+;
                      str(Work->Summa,15,2)+" "+;
                      str(Work->SumNo,15,2)
    nSumma += Work->Summa
    if Work->Summa > 0 .and. M_Append(20,"VipZap")
      VipZap->Ksp := SUPERLIS->Ksp
      VipZap->Tnr := strZero(Work->Tnr,6)
      VipZap->Summa := Work->Summa
      VipZap->Data  := Work->Data
      VipZap->(DbUnlock())
    End
    Work->(DbDelete())
    S_Line_N(18,04,65,nLastRec,++nRecno)
    Work->(DbSkip(1))
End
@ prow()+1,00 say Repl("=",nLen)
@ prow()+1,00 say padl("Всего за месяц         "+str(nSumma,15,2),nLen-16)
@ prow()+1,00 say " "
@ prow()+1,00 say ""
S_Beep(3)
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn(cFileWk+".txt","Ведомость прочих удержаний",74)
DbCloseAll()
use YdProc
zap
ferase(cFileWk+".ntx")
ferase(cFileWk+".Dbf")
ferase(cFileWk+".Cdx")
END SEQUENCE
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////
Function Kompens() // Компенсация
Local dDato := sset[121]

BEGIN SEQUENCE
//
if !OpenList()  ; break ; End
if !OpenVip()    ; break ; End
if !OpenUvZad()  ; break ; End
nLastRec := VipZap->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Идет компенсация...."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
VipZap->(DbGoTop())
While !VipZap->(eof())
   cTnr   := VipZap->Tnr
   dData  := Left(dtos(VipZap->Data),6)
   nSumma := 0
   While cTnr == VipZap->Tnr .and. dData == Left(dtos(VipZap->Data),6) ;
              .and. !VipZap->(eof())
     nSumma += VipZap->Summa
     S_Line_N(18,04,65,nLastRec,++nRecno)
     VipZap->(dBskip(1))
   End
   if UvZadol->(DbSeek(dData))
      nKoef := UvZadol->Koef
      nSumma := Round(nKoef*nSumma,2)
      if SuperLis->(DbSeek(cTnr))
         cKsp := SuperLis->Ksp        // Код подразделения
         nRec := SuperLis->Base_Rec   // No записи в BASE
         cSym := "Base"+cKsp
         Use (cSym) new alias Base
         Base->(DbGoto(nRec))
         lYes := .f.
         for j := 1 to 12
            jm := Alltrim(str(j,2))
            cKmn_ := "KMN"+jm
            cVo_  := "VO"+jm
            cSvon_:= "SVON"+jm
            if empty(Base->&cVo_)
               lYes := .t.
               Base->&cVo_  := "306"
               Base->&cSvon_ := nSumma*100
               Base->&cKmn_ := StrZero(month(dDato),2)
               Exit
            End
         Next
         if !lYes
           S_Err({"Табельный номер - "+cTnr,"Данные не записаны"})
         End
         Base->(DbCloseArea())
         DbSelectArea("VipZap")
      else
         S_Beep(1)
         S_Err({"Табельный номер "+cTnr,"не разнесен в листок"})
      End
   else

   End
End
S_Line_N()
S_Beep(2)
END SEQUENCE
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////
Function DelKomp() // Удаление Компенсация

BEGIN SEQUENCE
//
if !OpenVip(.t.)    ; break ; End
Zap
DbCloseAll()
erase("VipZap.cdx")
S_Err({"ок!"})
END SEQUENCE
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Static Function AddInf(Data,nSumma,cKvo)
Local SelectOld := Select(), cTnr
Local j, cKsp, nRec, cSym, lYes, jm, cVo, cSvon, cKmn, cDn

cTnr := StrZero(YdProc->Tn,6)
if SuperLis->(DbSeek(cTnr))
     cKsp := SuperLis->Ksp        // Код подразделения
     nRec := SuperLis->Base_Rec   // No записи в BASE
     cSym := "Base"+cKsp
     Use (cSym) new alias Base
     Base->(DbGoto(nRec))
     lYes := .f.
     for j := 1 to 12
        jm := Alltrim(str(j,2))
        cVo := "Ku"+jm
        if empty(Base->&cVo) //// .or. Base->&cVo == YdProc->Kvu
          lYes := .t.
          Base->&cVo  := cKvo
          cSvon := "Sku"+jm
          Base->&cSvon := nSumma*100
          cKmn := "Kmu"+jm
          Base->&cKmn := StrZero(month(Data),2)
          Exit
        End
     Next
     if !lYes
       S_Err({"Табельный номер - "+cTnr,"Данные не записаны"})
     End
     Base->(DbCloseArea())
     DbSelectArea(SelectOld)
else
   S_Beep(1)
   S_Err({"Табельный номер "+cTnr,"не разнесен в листок"})
End
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function PrnSvod()  // сводная ведомость
Local nLastRec, nRecno, dData, nSumDolg, nSumVip, nSumma
Local dDataRas := sset[121], cFile := "svod"

BEGIN SEQUENCE
DbCreate(cFile,{ {"Mec",  "C",07,00},;
                 {"Kvu",  "C",03,00},;
                 {"Summa","N",15,02}})
Use (cFile) alias Work
Index on Mec+Kvu to (cFile)
//
if !OpenUder() ; break ; End
if !OpenArx()  ; break ; End

S_Sys({"Ожидайте...","Выбираю данные для формирования ведомости"})
DbSelectArea("VedArx")
Set Index to
TagCrt({{"DATAV", "dtos(DataV)"}},"VedArxD.Cdx")
//
if VedArx->(DbSeek(Left(dtos(dDataRas),6)))
  While Left(dtos(dDataRas),6) == Left(dtos(VedArx->DataV),6) .and. !VedArx->(eof())
    nLastRec := Substr(dtos(VedArx->Data),1,4)+"."+;
                Substr(dtos(VedArx->Data),5,2)
    if !Work->(DbSeek(nLastRec+VedArx->Kvu))
        Work->(DbAppend())
        Work->Mec := nLastRec
        Work->Kvu := VedArx->Kvu
    End
    Work->Summa += VedArx->SumKVip
    VedArx->(DbSkip(1))
  End
End
S_Sys()
nLastRec := Work->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую Ведомость...."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Work->(DbGoTop())
Set(20,"PRINT")
Set(24,"Svod.txt")
@ prow()+1,00 say " "
@ prow()+1,00 say "             Сводная ведомость"
@ prow()+1,00 say " удержаний из задолженности по заработной плате"
@ prow()+1,00 say "     в "+s_cMonth(dDataRas)+" месяце "+str(year(dDataRas),4)+" года"
@ prow()+1,00 say "-------------------------------------------"
@ prow()+1,00 say " Дата   Код  Наименование        Сумма     "
@ prow()+1,00 say "-------------------------------------------"
fSumma := 0
While !Work->(eof())
  cMec := Work->Mec
  nSumma := nKol := 0
  While !Work->(eof()) .and. cMec == Work->Mec
    Suder->(DbSeek(Work->Kvu))
    @ prow()+1,00 say Work->Mec+" "+Work->Kvu+" "+Suder->Naim+" "+;
      str(Work->Summa,15,2)
    nKol++
    nSumma += Work->Summa
    S_Line_N(18,04,65,nLastRec,++nRecno)
    Work->(DbSkip(1))
  End
  fSumma += nSumma
  if nKol > 1
    @ prow()+1,00 say "     Итого                  "+str(nSumma,15,2)
  End
End
@ prow()+1,00 say "-------------------------------------------"
@ prow()+1,00 say "     Всего                  "+str(fSumma,15,2)
@ prow()+1,00 say " "
@ prow()+1,00 say ""
Set(24,"")
Set(20,"SCREEN")
S_Line_N()
S_Beep()
ShowPrn("Svod.txt"," Ведомость",74)
fErase("Svod.txt")
END SEQUENCE
Set(20,"SCREEN")
DbCloseall()
fErase("VedArxD.Cdx")
fErase(cFile+".Cdx")
fErase(cFile+".Dbf")
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function XlebVed() // Печать ведомости на выдачу талонов на хлеб
Local nRecno, nLastRec, dData := sset[121], nPP := 0

BEGIN SEQUENCE
if !OpenList()  ; break ; End
nLastRec := SuperLis->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую ведомость"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
SuperLis->(DbGoTop())
Set(20,"PRINT")
Set(24,"Xleb.txt")
nList := nLine := nPp := 0
While ( !SuperLis->(eof()) )
 if SuperLis->Tn <> "******"
   if nList == 0 .or. nLine > 60
     if nList > 0
        @ prow()+1,00 say "---------------------------------------------------------------------------"
        @ prow()+1,00 say padr("Итого по листу ",33)+"__________"
        nLine += 2
        for i := nLine to 65
            @ prow()+1,00 say " "
        Next
        @ prow()+1,00 say "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
        @ prow()+1,00 say " "
     End
     @ prow()+1,00 say "  список работников       ПКПУВКХ                         "+S_cMonth(dData)+" месяц "+str(year(dData),4)+" г."
     @ prow()+1,00 say "                                                           Лист "+str(++nList,3)
     @ prow()+1,00 say "---------------------------------------------------------------------------"
     @ prow()+1,00 say " N  |Табель|   Фамилия Имя      |          |    Роспись    | Примечание    "
     @ prow()+1,00 say "п/п |номер |   Отчество         |          |  в получении  |               "
     @ prow()+1,00 say "---------------------------------------------------------------------------"
     nLine := 6
    End
    @ prow()+1,00 say str(++nPp,4)+" "+SuperLis->Tn+" "+SuperLis->Fio+" "+;
    "__________ ______________________________"
    @ prow()+1,00 say " "
    nLine += 2
  End
  S_Line_N(18,04,65,nLastRec,++nRecno)
  SuperLis->(DbSkip(1))
End
@ prow()+1,00 say "---------------------------------------------------------------------------"
@ prow()+1,00 say padr("Итого по листу ",33)+"__________"
nLine += 2
for i := nLine to 65
  @ prow()+1,00 say " "
Next
@ prow()+1,00 say "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " В KАССУ ДЛЯ ОПЛАТЫ В СРОK "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " С ________ ПО ________ 20__ Г"
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  "В СУММЕ: _____________________________________________"
@ prow()+1,00 say  "         _____________________________________________"
@ prow()+1,00 say  "                             ( ГРH.______________) "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  "                               ______________________ РУKОВОДИТЕЛЬ"
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  "                               ______________________ ГЛ.БУХГАЛТЕР"
@ prow()+1,00 say  [ "__"________20__Г]
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  "          ПЛАТЕЖHАЯ ВЕДОМОСТЬ N ______"
@ prow()+1,00 say  "                                   "
@ prow()+1,00 say  " "
@ prow()+1,00 say  "         ЗА "+S_cMonth(dData)+" месяц "+str(year(dData),4)+" года"
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  "                                        KОЛИЧЕСТВО ЛИСТОВ "+str(nList,3)
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  "ПО HАСТОЯЩЕЙ ПЛАТЕЖHОЙ ВЕДОМОСТИ ВЫПЛАЧЕHО РУБЛЕЙ __________"
@ prow()+1,00 say  " "
@ prow()+1,00 say  "____________________________________________________________"
@ prow()+1,00 say  " "
@ prow()+1,00 say  "____________________________(__________ ГРН.____KОП.)"
@ prow()+1,00 say  " "
@ prow()+1,00 say  "И ДЕПОHИРОВАHO ______________________________________________"
@ prow()+1,00 say  " "
@ prow()+1,00 say  "____________________________(__________ ГРН.____KОП.)"
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " ВЫПЛАТУ ПРОИЗВЕЛ _____________________________"
@ prow()+1,00 say  " "
@ prow()+1,00 say  " ПРОВЕРИЛ БУХГАЛТЕР ___________________________"
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
@ prow()+1,00 say  " "
S_Beep(3)
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn("Xleb.txt","Ведомость",74)
END SEQUENCE
DbCloseAll()
Return ( Nil )
