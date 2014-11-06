#include "inkey.ch"
#include "S_Win.ch"
#Define ROUN  2
//////////////////////////////////////////////////////////////////////////
Function RaschB() // ввод и расчет больничных листов
Local dRach := Substr(dtos(sset[121]),1,6), CursorOld := SetCursor(0)
Local nMin  := sset[122], ColorOld := SetColor(), nKey, nRow, tb
Local NortonOld := DeskTop:Norton(), dDataR := sset[121]

BEGIN SEQUENCE
if !M_Use("SuperLis",,,,"DBFNTX")   ; break ; End
if !File("SuperTn.Ntx") ; break ; End
Set Index to SuperTn
//
if !M_Use("SuperSrd",,,,"DBFNTX") ; break ; End
if !M_Use("Svo",,,,"DBFNTX")      ; break ; End
if !File("SvoIndex.ntx") ; break ; End
Set Index to SvoIndex
if !OpenDbf_("SprKB") ; break ; End
if !OpenDbf_("Bol")   ; break ; End
DbSelectArea("Bol")
S_Open_S(03,03,22,63,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "   дата   │  номер │цех │таб.  │   дата   │к-во│ % │вид│гр."
@ 02,01 wsay "  р. БЛ   │   БЛ   │    │номер │    БЛ    │дней│опл│рас│бол"
@ 03,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"2Расчет","3Удалить","4Регистр","5Корректи"}} )
tb := TBrowseDb(S_wRow()+04,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| dtoc(Bol->Dt)+" "+str(Bol->Bl,8)+" "+;
   str(Bol->Cex,4)+" "+str(Bol->Tnr,6)+" "+dtoc(Bol->DtBol)+" "+;
   str(Bol->Tm,4)+" "+str(Bol->Proz,3)+" "+str(Bol->Vr,3)+" "+;
   str(Bol->Gr,3) } ))
Bol->(DbGoTop())
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
       case nKey == K_F2 .and. !Empty(Bol->Bl) // расчет
          RachBol()
       case nKey == K_F3 .and. !Empty(Bol->Bl) // Удаление
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"Bol")
                 Bol->(DbDelete())
                 Bol->(DbUnlock())
                 Bol->(DbSkip(1))
                 if Bol->(eof()) ; Bol->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Вводите данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           While ( .t. )
             Scroll(S_wRow()+04,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1,-1)
             nBl := nCex := nTnr := nTm := nProz := nVr := nGr := 0
             dDt := dDtBol := dDataR
             @ 04,01 wget dDt pict "@d" valid !Empty(dDt)
             @ 04,12 wget nBl pict "99999999" valid nBl > 0
             @ 04,21 wget nCex pict "9999" valid nCex >= 0
             @ 04,26 wget nTnr pict "999999" valid nTnr > 0
             @ 04,33 wget dDtBol pict "@d" valid !Empty(dDtBol)
             @ 04,46 wget nTm pict "99" valid nTm > 0
             @ 04,49 wget nProz pict "999" valid nProz > 0
             @ 04,54 wget nVr pict "99" valid str(nVr,2)$" 1, 2, 3,11,13"
             @ 04,59 wget nGr pict "9" valid nGr >= 0
             read
             if LastKey() == K_ESC ; exit ; End
             if M_Append(20,"Bol")
               Bol->Bl  := nBl
               Bol->Cex := nCex
               Bol->Tnr := nTnr
               Bol->Tm  := nTm
               Bol->Proz:= nProz
               Bol->Vr  := nVr
               Bol->Gr  := nGr
               Bol->Dt  := dDt
               Bol->DtBol:= dDtBol
               Bol->(DbUnlock())
               RachBol()
             End
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5 .and. !Empty(Bol->Bl) // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nBl    := Bol->Bl 
           nCex   := Bol->Cex 
           nTnr   := Bol->Tnr 
           nTm    := Bol->Tm
           nProz  := Bol->Proz
           nVr    := Bol->Vr
           nGr    := Bol->Gr
           dDt    := Bol->Dt
           dDtBol := Bol->DtBol
           @ nRow,S_wCol()+01 get dDt pict "@d" valid !Empty(dDt)
           @ nRow,S_wCol()+12 get nBl pict "99999999" valid nBl > 0
           @ nRow,S_wCol()+21 get nCex pict "9999" valid nCex >= 0
           @ nRow,S_wCol()+26 get nTnr pict "999999" valid nTnr > 0
           @ nRow,S_wCol()+33 get dDtBol pict "@d" valid !Empty(dDtBol)
           @ nRow,S_wCol()+46 get nTm pict "99" valid nTm > 0
           @ nRow,S_wCol()+49 get nProz pict "999" valid nProz > 0
           @ nRow,S_wCol()+54 get nVr pict "99" valid str(nVr,2)$" 1, 2, 3,11,13"
           @ nRow,S_wCol()+59 get nGr pict "9" valid nGr >= 0
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"Bol")
               Bol->Bl  := nBl
               Bol->Cex := nCex
               Bol->Tnr := nTnr
               Bol->Tm  := nTm
               Bol->Proz:= nProz
               Bol->Vr  := nVr
               Bol->Gr  := nGr
               Bol->Dt  := dDt
               Bol->DtBol:= dDtBol
               Bol->(DbUnlock())
               RachBol()
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
SetCursor(CursorOld)
DeskTop:Norton := NortonOld
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function VvodSprB() // Ввод коэффициентов оптуска
Local ColorOld := SetColor(),;
      SelectOld := Select(),;
      SursorOld := SetCursor(),;
      NortonOld := DeskTop:Norton()
Local dDataC, dDataP, nKf, tb, nKey, nRow, GetList := {}

BEGIN SEQUENCE
if !OpenDbf_("sprKB") ; break ; End
SetCursor(0)
DbSelectArea("sprKB")
S_Open_S(03,03,22,32,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "       Период        │Коэф- "
@ 02,01 wsay "    с     │    по    │фиент."
@ 03,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"3Удалить","4Регистр","5Корректи"}} )
tb := TBrowseDb(S_wRow()+04,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| dtoc(sprKB->DataC)+" "+dtoc(sprKB->DataP)+;
                                " "+str(sprKB->Kf,6,3) } ))
sprKB->(DbGoTop())
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
       case nKey == K_F3 .and. !Empty(sprKB->kf) // Удаление
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"sprKB")
                 sprKB->(DbDelete())
                 sprKB->(DbUnlock())
                 sprKB->(DbSkip(1))
                 if sprKB->(eof()) ; sprKB->(DbGoBottom()) ; end
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
             if M_Append(20,"sprKB")
               sprKB->DataC := dDataC
               sprKB->DataP := dDataP
               sprKB->kf    := nkf
               sprKB->(DbUnlock())
             End
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5 .and. !Empty(sprKB->Kf) // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nkf := sprKB->Kf
           @ nRow,S_wCol()+23 get nKf pict "99.999" valid nKf > 0
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"sprKB")
               sprKB->Kf := nKf
               sprKB->(DbUnlock())
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
Static function RachBol()
Local cTnr := strzero(Bol->Tnr,6), nMec  := strzero(Month(Bol->Dt),2)
Local dData1, nMec1, dData2,  nMec2, nMin  := sset[122]*100

if M_Rlock(20,"Bol")
   Bol->Dni1  := 0
   Bol->Dni2  := 0
   Bol->Kvo   := 0
   Bol->Sum1  := 0
   Bol->Sum2  := 0
   Bol->SrZar := 0
   Bol->Tarif := 0
   Bol->SumN  := 0
   Bol->(DbUnlock())
End
if !SuperLis->(Dbseek(cTnr))
 S_Err({"Табельный номер - "+cTnr,"отсутствует в справочнике"})
else
 dData1 := S_AddMon(Bol->Dt,-1)
 nMec1 := Month(dData1)
 dData2 := S_AddMon(dData1,-1)
 nMec2 := Month(dData2)
 nRec := SuperLis->Base_Rec
 cKsp := SuperLis->Ksp
 cTemp := "Base"+cKsp
 use (cTemp) new alias Base
 Base->(DbGoto(nRec))
 nZarp13 := Base->Zarp13
 nOks := iif(Base->Pts=="2",Base->Oks/100,Base->Oks)
////? "оклад",Base->Pts,Base->Oks,nOks
////wait
 aSum := {0,0}
 aDni := {0,0}
 if Bol->Vr == 2 // по тарифу
    nTar2    := nOks
    ////////////////////////////////////////////// Находим плановые дни
    if Base->Kalendar == "0" .or. Base->Kalendar == " "
        cTemp := "Srd"
    else
       cTemp := "Srd"+Base->Kalendar
    End
    nPlDni := nPlChas := 0
    use (cTemp) new alias Srd
    Srd->( __DbLocate({||Srd->km == nMec}) )
    if Srd->(Found())
       nPlDni  := Srd->Dn
       nPlChas := Srd->Chas
    End
    Srd->(DbCloseArea())
    nSredSum := Round( iif(nOks > nMin, nOks/nPlDni, nOks*nPlChas/nPlDni),ROUN)
 else  // Vr == 1
    nZarp13 := 0
    cTemp := "Seba"+cKsp
    use (cTemp) new alias Seba
    Seba->(DbGoTo((nRec-1)*12+1))
    for i := 1 to 12
      for j := 1 to 12
       jm := alltrim(str(j,2))
       cKmn_ := "KMN"+jm
       cVo_  := "VO"+jm
       cSvon_:= "SVON"+jm
       cDnCh_:= "DNCH"+jm
       nKmn := val(Seba->(&cKmn_))
       if !Empty( cVo := Seba->(&cVo_) ) 
          Svo->(DbSeek(cVo))
          // Зарплата
          if Substr(Svo->Zmo,9,1) == "1" .and. ( nKmn == nMec1 .or. nKmn == nMec2 )
             nKf   := 1
             SprKB->(DbGoTop())
             While ( !SprKB->(eof()) )
               if Bol->Dt >= SprKB->DataC .and. Bol->Dt <= SprKB->DataP
                  nKf := SprKB->Kf
                  Exit
                End
                SprKB->(DbSkip(1))
            End
            // Ну наконец-то добрались
            aSum[iif(nKmn == nMec1,1,2)] += Round(Seba->(&cSvon_)*nKf,ROUN)
          End
          if cVo == "630" // 13 зарплата
              nZarp13 += Seba->(&cSvon_)
          End
          // Дни
          if Substr(Svo->Zmo,21,1) == "1" .and. ( nKmn == nMec1 .or. nKmn == nMec2 )
             nKf   := 1
             SprKB->(DbGoTop())
             While ( !SprKB->(eof()) )
               if Bol->Dt >= SprKB->DataC .and. Bol->Dt <= SprKB->DataP
                  nKf := SprKB->Kf
                  Exit
                End
                SprKB->(DbSkip(1))
            End
            // Ну наконец-то добрались
            aDni[iif(nKmn == nMec1,1,2)] += Seba->(&cDnCh_)
         End
       End
     next
     Seba->(DbSkip(1))
   Next
   Seba->(DbCloseArea())
   if ( Bol->Vr == 1 .or. Bol->Vr == 3 ) .and. Base->Pts == "2"
     cTemp := iif(Base->Kalendar=="0"," ",Base->Kalendar)
     SuperSrd->( __DbLocate({||SuperSrd->Kod == cTemp}) )
     if SuperSrd->(Found())
        aDni[1] := Round(aDni[1]/SuperSrd->Prd,0)
        aDni[2] := Round(aDni[2]/SuperSrd->Prd,0)
     End
   End
////? "Суммы ",aSum[1],aSum[2],nZarp13,aDni[1],aDni[2]
////wait
   nSredSum := Round( (aSum[1]+aSum[2]+nZarp13/6)/(aDni[1]+aDni[2]),ROUN)
   ////////////////////////////////// Находим двойной тариф
   if Bol->Vr == 3 .or. Bol->Vr == 13
      nTar2 := nSredSum 
   else // 1 или 11
     ////////////////////////////////////////////// Находим плановые дни
     if Base->Kalendar == "0" .or. Base->Kalendar == " "
        cTemp := "Srd"
     else
       cTemp := "Srd"+Base->Kalendar
     End
     nPlDni := nPlChas := 0
     use (cTemp) new alias Srd
     Srd->( __DbLocate({||Srd->km == nMec}) )
     if Srd->(Found())
       nPlDni  := Srd->Dn
       nPlChas := Srd->Chas
     End
     Srd->(DbCloseArea())
     /////////////////////////////////////////////////////////////////////
     if Bol->Vr == 1
        nTar2  := iif(nOks > nMin,2*nOks/nPlDni,2*nOks*nPlChas/nPlDni)
/////? "план",nOks,nMin,nPlDni,nPlChas
/////wait
     else  // 11
        nTar2 := iif(nOks > nMin, 2*nOks/nPlDni, 2*nOks)
     End
     nTar2  := Round(nTar2,ROUN)
   End
/////? "тариф",nTar2      
/////wait
 End
 // Находим сумму
 nSumma := round(Bol->Tm*min(nSredSum,nTar2)/100*Bol->Proz/100,ROUN)*100
 j  := val(left(dtos(Bol->DtBol),6)) // из б/л
 jm := val(left(dtos(sset[121]),6))  // из сервиса
 if j < jm
    nKvo := 216
 elseif j == jm
    nKvo := 217
 else
    nKvo := 218
 End
 ///////////////////////////////////// Записываем в базу
 if M_Rlock(20,"Bol")
   Bol->Dni1  := aDni[1]
   Bol->Dni2  := aDni[2]
   Bol->Kvo   := nKvo
   Bol->Sum1  := aSum[1]
   Bol->Sum2  := aSum[2]
   Bol->SrZar := nSredSum
   Bol->Tarif := nTar2
   Bol->SumN  := nSumma
   Bol->(DbUnlock())
 End
 Base->(DbCloseArea())
End
DbSelectArea("Bol")
Return ( Nil )
/////////////////////////////////////////////////////////////////////////
Function ZapInfB() // запись информации в л/с
Local mRecno, nLastRec, cKsp, nRec, i, j, im, jm, cSym, cVo, cSvon, cDn, cKn

BEGIN SEQUENCE
if !OpenDbf_("BOL")  ; break ; End
if !M_Use("SuperLis",,,,"DBFNTX")   ; break ; End
if !File("SuperTn.Ntx") ; break ; End
Set Index to SuperTn
nLastRec := Bol->(LastRec())
Bol->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Делаю запись информации"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
While ( !Bol->(eof()) )
   cTnr := StrZero(Bol->Tnr,6)
   if !SuperLis->(DbSeek(cTnr))
      S_Err({"Табельный номер - "+cTnr,"Отсутствует в справочнике"})
   elseif Bol->SumN > 0
     cKsp := SuperLis->Ksp        // Код подразделения
     nRec := SuperLis->Base_Rec   // No записи в BASE
     cSym := "Base"+cKsp
     Use (cSym) new alias Base
     Base->(DbGoto(nRec))
     lYes := .f.      
     for j := 1 to 12
        jm := Alltrim(str(j,2))
        cVo := "Vo"+jm
        if empty(Base->&cVo)
          lYes := .t.
          Base->&cVo  := strzero(Bol->KVO,3)
          cSvon := "Svon"+jm
          Base->&cSvon := Bol->SumN
          cKmn := "Kmn"+jm
          Base->&cKmn := strzero(month(Bol->DtBol),2)
          cDn := "Dn"+jm
          Base->&CDn := Bol->Tm*100
          Exit
        End
     Next
     Base->(DbCloseArea())
   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   Bol->(DbSkip(1))
End
S_Beep()
S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Function PrnBol() // Печать больничных листов
Local nLastRec, nRecno, cTnr, nItog := 0, cFile := "BolPrn.txt", nLen := 130
Local nSet := Set(4,"dd.mm.yy")

BEGIN SEQUENCE
if !OpenDbf_("BOL")  ; break ; End
if !M_Use("SuperLis",,,,"DBFNTX")   ; break ; End
if !File("SuperTn.Ntx") ; break ; End
Set Index to SuperTn
nLastRec := Bol->(LastRec())
Bol->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Делаю запись информации"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Set Device to Print
@ prow()+1,00 say " "
@ prow()+1,00 say padc(" В Е Д О М О С Т Ь",nLen)
@ prow()+1,00 say padc("начисления оплаты по временной нетрудоспособности",nLen)
@ prow()+1,00 say padc(" от "+dtoc(sset[121]),nLen)
@ prow()+1,00 say repl("-",nLen)
@ prow()+1,00 say "    |   Фамилия         |Табель| Номер  |  Заработок за     | количество  |среднедн.|  двойной |ра|вид| % |        |Время | Сумма   |"
@ prow()+1,00 say "Цех |     Имя           | ный  |листка  | прошлые месяцы    |     дней    |заработок|   тариф  |сч|опл|опл|  Дата  |оплаты|начислен-|"
@ prow()+1,00 say "    |    Отчество       |номер |нетрудос|-------------------| в месяце    |фактическ|          |ет|аты|аты|болезни |      |   ная   |"
@ prow()+1,00 say "    |                   |      |пособнос|    1    |    2    |  1   |  2   |         |          |  |   |   |        |      |         |"
@ prow()+1,00 say repl("-",nLen)
While ( !Bol->(eof()) )
   cTnr := StrZero(Bol->Tnr,6)
   SuperLis->(DbSeek(cTnr))   
   @ prow()+1,00 say str(Bol->Cex,4)+" "+SuperLis->Fio+" "+str(Bol->Tnr,6)+" "+;
     str(Bol->Bl,8)+" "+str(Bol->Sum1/100,9,2)+" "+str(Bol->Sum2/100,9,2)+" "+;
     str(Bol->Dni1,6,2)+" "+str(Bol->Dni2,6,2)+" "+str(Bol->SrZar/100,9,2)+" "+;
     str(Bol->Tarif/100,9,2)+" "+str(Bol->Vr,2)+" "+str(Bol->Kvo,3)+" "+;
     str(Bol->Proz,3)+" "+dtoc(Bol->Dt)+" "+str(Bol->Tm,6,2)+" "+;
     str(Bol->SumN/100,9,2)
   nItog += Bol->SumN/100
   S_Line_N(18,04,65,nLastRec,++nRecno)
   Bol->(DbSkip(1))
End
@ prow()+1,00 say repl("=",nLen)
@ prow()+1,00 say padl(" И Т О Г О  "+str(nItog,15,2),nlen)
@ prow()+1,00 say ""
Set Device to Screen
S_Line_N()
END SEQUENCE
Set(4,nSet)
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
