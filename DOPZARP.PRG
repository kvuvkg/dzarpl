#include "inkey.ch"
#include "S_win.ch"
///////////////////////////////////////////////////
Function Nakopl()  // Накопление
Local cFile := "Base*.Dbf",  dDataR := sset[121]
Local nDVip := val(left(dtos(sset[121]),6))
Local TekMec := month(sset[121]), TekGod := year(sset[121])

if Empty(aFile := Directory(cFile))
   Return ( Nil )
End
BEGIN SEQUENCE
if S_Err({"Будем формировать накопление",;
          "по заработной плате"," за "+S_cMonth(sset[121])+" месяц "+;
          str(year(sset[121]),4)+" год?",;
          "%   Да   ;   Нет  ;"}) == 2
  break
End
if !OpenSvo()           ; break ; End
if !OpenDbf_("NAKNACH") ; break ; End
if !OpenDbf_("NAKYD")   ; break ; End
//
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
    if Base->Tn <> "******"
      o_Sum := {}
      for j := 1 to 12
        cVo_  := "VO"+alltrim(str(j,2))
        cSvo_ := "SVON"+alltrim(str(j,2))
        cDn_  := "DN"+alltrim(str(j,2))
        cKmn_ := "KMN"+alltrim(str(j,2))
        cVo   := Base->(&cVo_)
        nSvo  := Base->(&cSvo_)/100
        nDn   := Base->(&cDn_)/100
        nKmn  := val(Base->(&cKmn_))
        nData := DayGod(TekMec,TekGod,nKmn)*100+nKmn
        if !Empty(cVo) .and. !Empty(nSvo)
           Svo->(DbSeek(cVo))
           if Substr(Svo->Zmo,5,1) == "1" // облагаеиая
              if ( nPos := ascan(o_Sum,{|x| x[1] == nData } ) ) == 0
                   nPos := len(O_Sum)+1
                   aadd(o_Sum,{nData,0,0})
              End
              o_Sum[nPos][2] += nSvo
            Elseif ( cVo <> "605" .and. cVo <> "607" ) // не облагаемая
              if ( nPos := ascan(o_Sum,{|x| x[1] == nData } ) ) == 0
                   nPos := len(O_Sum)+1
                   aadd(o_Sum,{nData,0,0})
              End
              o_Sum[nPos][3] += nSvo
           End
           if M_Append(20,"NakNach")
             NakNach->Tn     := val(Base->Tn)
             NakNach->D_Vip  := nDVip
             NakNach->D_Nach := DayGod(TekMec,TekGod,nKmn)*100+nKmn
             NakNach->Vo     := cVo
             NakNach->Dn     := nDn
             NakNach->Sum    := nSvo
             NakNach->(DbUnlock())
           End
       End
      Next
      for i := 1 to len(o_Sum)
         if !NakYd->(DbSeek(str(val(Base->Tn),6)+str(o_sum[i][1],6))) .and. ;
                                                         M_Append(20,"NakYd")
            NakYd->Tn     := val(Base->Tn)
            NakYd->D_Yd   := o_sum[i][1]
            NakYd->(DbUnlock())
         End
         if M_Rlock(20,"NakYd")
            NakYd->OblSum  += o_Sum[i][2]
            NakYd->NOblSum += o_Sum[i][3]
            NakYd->(DbUnlock())
         End
      Next
      for j := 1 to 12
         cKu_  := "KU"+alltrim(str(j,2))
         cSKu_ := "SKU"+alltrim(str(j,2))
         cKmu_ := "KMU"+alltrim(str(j,2))
         nSKu  := Base->(&cSKU_)/100
         cKu   := Base->(&cKu_)
         nKmu  := val(Base->(&cKmu_))
         //
         if !Empty(cKu) .and. !Empty(nSKu) .and. !Empty(nKmu)
            nData := DayGod(TekMec,TekGod,nKmu)*100+nKmu
            if !NakYd->(DbSeek(str(val(Base->Tn),6)+str(nData,6))) .and. ;
                                                       M_Append(20,"NakYd")
                NakYd->Tn     := val(Base->Tn)
                NakYd->D_Yd   := nData
                NakYd->(DbUnlock())
            End
            if M_Rlock(20,"NakYd")
              lYes := .f.
              for i := 1 to 12
                 cKvu_   := "KVU"+alltrim(str(i,2))
                 cSumYd_ := "SumYd"+alltrim(str(i,2))
                 if NakYd->(&cKvu_) == cKu
                    NakYd->&cSumYd_ += nSKu
                    lYes := .t.
                    Exit
                 End
              Next
              if !lYes  // не нашли
                 for i := 1 to 12
                    cKvu_   := "KVU"+alltrim(str(i,2))
                    cSumYd_ := "SumYd"+alltrim(str(i,2))
                    if Empty(NakYd->(&cKvu_))
                       NakYd->&cKvu_   := cKu
                       NakYd->&cSumYd_ := nSKu
                       lYes := .t.
                       Exit
                    End
                  Next
              End
              if !lYes  // не куда Вствлять
                 S_Err({"Нет данных для вставки в удержания:",;
                        "Табельный номер "+Base->Tn})
              End
              NakYd->(DbUnlock())
            End
         End
      Next
    End
    Base->(DbSkip(1))
  End
  Base->(DbCloseArea())
  S_Line_N(18,04,65,nLastRec,++nRecno)
Next
S_Beep()
S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
////////////////////////////////////////////////////////////////////////
Static Function DayGod(TekMec,TekGod,Mec)
Local God := TekGod

if Mec == TekMec
   God := TekGod
elseif TekMec >= 4 .and. TekMec <= 9
   God := TekGod
elseif TekMec == 10
  if Mec >= 05 .and. Mec <= 09
     God := TekGod
  else
     God := TekGod + 1
  End
elseif TekMec == 11
  if Mec >= 06 .and. Mec <= 10
     God := TekGod
  else
     God := TekGod + 1
  End
elseif TekMec == 12
  if Mec >= 06 .and. Mec <= 11
     God := TekGod
  else
     God := TekGod + 1
  End
elseif TekMec == 1
  if Mec >= 01 .and. Mec <= 06
     God := TekGod
  else
     God := TekGod - 1
  End
elseif TekMec == 2
  if Mec >= 01 .and. Mec <= 07
     God := TekGod
  else
     God := TekGod - 1
  End
elseif TekMec == 3
  if Mec >= 01 .and. Mec <= 02
     God := TekGod
  elseif Mec >= 10 .and. Mec <= 12
     God := TekGod - 1
  else
     God := TekGod + 1
  End
End
Return ( God )
///////////////////////////////////////////////////////////////////////
Function VedSuper()
Local ColorOld := SetColor(), nKey, nRow, nInd, CursorOld := SetCursor(0)
Local NortonOld := DeskTop:Norton(), tb

BEGIN SEQUENCE
if !OpenList()   ; break ; End
DbSelectArea("SuperLis")
S_Sys({"Минутку"})
Set Filter to Tn <> "******"
SuperLis->(DbGoTop())
S_Sys()
S_Open_S(02,00,22,79,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay " T.N.  Фамилия                   Инд.номер   Прием       Увольн   ЛГ ПД"
@ 02,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"5Корректи","6Поиск"}} )
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| SuperLis->Tn+SuperLis->Fio+;
                                SuperLis->bank+" "+str(SuperLis->IndN,10)+" "+;
                                dtoc(SuperLis->DataPr)+dtoc(SuperLis->DataUv)+" "+;
                                str(SuperLis->PrizLg,2)+" "+;
                                str(SuperLis->KodD,2) }))
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
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
        nbank   := SuperLis->bank
           nIndN   := SuperLis->IndN
           dDataPr := SuperLis->DataPr
           dDataUv := SuperLis->DataUv
           nPrizLg := SuperLis->PrizLg
           nKodD   := SuperLis->KodD
            @ nRow,S_wCol()+20 get nbank pict "xxxxxxxxxxxxxx"
            @ nRow,S_wCol()+34 get nIndN pict "9999999999" valid nIndN > 0
           @ nRow,S_wCol()+44 get dDataPr pict "@d"
           @ nRow,S_wCol()+56 get dDataUv pict "@d"
           @ nRow,S_wCol()+67 get nPrizLg pict "99"
           @ nRow,S_wCol()+70 get nKodD   pict "99"
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"SuperLis")
             SuperLis->bank   := nbank
               SuperLis->IndN   := nIndN
               SuperLis->DataPr := dDataPr
               SuperLis->DataUv := dDataUv
               SuperLis->PrizLg := nPrizLg
               SuperLis->KodD   := nKodD
               SuperLis->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F6 // Поиск
           tb:DeHilite()
           nRow := SuperLis->(Recno())
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Укажите табельный номер [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           @ 03,01 say space(MaxCol()-1)
           cTn := "000000"
           @ 03,01 wget cTn
           read
           if LastKey() <> K_ESC
              if !SuperLis->(DbSeek(cTn))
                S_Err({" Данные отсутствуют"})
                SuperLis->(DbGoto(nRow))
              End
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
///////////////////////////////////////////////////////////////////////////
Function VedNakYd()
Local ColorOld := SetColor(), nKey, nRow, nInd, CursorOld := SetCursor(0)
Local NortonOld := DeskTop:Norton(), tb

BEGIN SEQUENCE
if !OpenList()          ; break ; End
if !OpenDbf_("NAKYD")   ; break ; End

DbSelectArea("NakYd")
Set Relation to strzero(Tn,6) into SuperLis
NakYd->(DbGoTop())
S_Open_S(01,01,22,77,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Таб.N   Дата   Фамилия             Обл.сумма"
@ 02,01 wsay Repl("─",47)
For nKey := 1 to S_wLastRow()-1
  @ nKey,48 wsay "│"
Next
oNortonNew( {{"3Удалить","4Регистр","5Корректи","6Поиск"}} )
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wCol()+47)
tb:AddColumn(TbColumnNew("",{|| str(NakYd->Tn,6)+" "+str(NakYd->D_Yd,6)+" "+;
                                SuperLis->Fio+" "+str(NakYd->OblSum,12,2) }))
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := S_Inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   @ 05,50 wsay " 01 "+Nakyd->Kvu1+" "+str(NakYd->SumYd1,12,2)
   @ 06,50 wsay " 02 "+Nakyd->Kvu2+" "+str(NakYd->SumYd2,12,2)
   @ 07,50 wsay " 03 "+Nakyd->Kvu3+" "+str(NakYd->SumYd3,12,2)
   @ 08,50 wsay " 04 "+Nakyd->Kvu4+" "+str(NakYd->SumYd4,12,2)
   @ 09,50 wsay " 05 "+Nakyd->Kvu5+" "+str(NakYd->SumYd5,12,2)
   @ 10,50 wsay " 06 "+Nakyd->Kvu6+" "+str(NakYd->SumYd6,12,2)
   @ 11,50 wsay " 07 "+Nakyd->Kvu7+" "+str(NakYd->SumYd7,12,2)
   @ 12,50 wsay " 08 "+Nakyd->Kvu8+" "+str(NakYd->SumYd8,12,2)
   @ 13,50 wsay " 09 "+Nakyd->Kvu9+" "+str(NakYd->SumYd9,12,2)
   @ 14,50 wsay " 10 "+Nakyd->Kvu10+" "+str(NakYd->SumYd10,12,2)
   @ 15,50 wsay " 11 "+Nakyd->Kvu11+" "+str(NakYd->SumYd11,12,2)
   @ 16,50 wsay " 12 "+Nakyd->Kvu12+" "+str(NakYd->SumYd12,12,2)
   @ 17,50 wsay "н/обл. "+str(NakYd->NOblSum,12,2)
   if nKey == 0 ; nKey := S_InKey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3  // Удаление
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"NakYd")
                 NakYd->(DbDelete())
                 NakYd->(DbUnlock())
                 NakYd->(DbSkip(1))
                 if NakYd->(eof()) ; NakYd->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4 // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Регистрируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           @ 03,01 wsay space(47)
           nTn := nData := _nOblSum := 0
           cKvu1   := cKvu2   := cKvu3   := cKvu4   := cKvu5   := "   "
           cKvu6   := cKvu7   := cKvu8   := cKvu9   := cKvu10  := "   "
           cKvu11  := cKvu12  := "   "
           nSumYd1  := nSumYd2  := nSumYd3  := nSumYd4  := nSumYd5  := 0
           nSumYd6  := nSumYd7  := nSumYd8  := nSumYd9  := nSumYd10 := 0
           nSumYd11 := nSumYd12 := nNOblSum := 0
           @ 03,01 wget nTn pict "999999" valid nTn > 0
           @ 03,08 wget nData pict "999999" valid nData > 199612
           @ 03,36 wget _nOblSum pict "999999999.99"
           @ 05,54 wget cKvu1
           @ 05,58 wget nSumYd1 pict "999999999.99"
           @ 06,54 wget cKvu2
           @ 06,58 wget nSumYd2 pict "999999999.99"
           @ 07,54 wget cKvu3
           @ 07,58 wget nSumYd3 pict "999999999.99"
           @ 08,54 wget cKvu4
           @ 08,58 wget nSumYd4 pict "999999999.99"
           @ 09,54 wget cKvu5
           @ 09,58 wget nSumYd5 pict "999999999.99"
           @ 10,54 wget cKvu6
           @ 10,58 wget nSumYd6 pict "999999999.99"
           @ 11,54 wget cKvu7
           @ 11,58 wget nSumYd7 pict "999999999.99"
           @ 12,54 wget cKvu8
           @ 12,58 wget nSumYd8 pict "999999999.99"
           @ 13,54 wget cKvu9
           @ 13,58 wget nSumYd9 pict "999999999.99"
           @ 14,54 wget cKvu10
           @ 14,58 wget nSumYd10 pict "999999999.99"
           @ 15,54 wget cKvu11
           @ 15,58 wget nSumYd11 pict "999999999.99"
           @ 16,54 wget cKvu12
           @ 16,58 wget nSumYd12 pict "999999999.99"
           @ 17,58 wget nNOblSum pict "999999999.99"
           read
           if LastKey() <> K_ESC .and. M_Append(20,"NakYd")
               NakYd->Tn     := nTn
               NakYd->D_yd   := nData
               NakYd->OblSum := _nOblSum ;  NakYd->NOblSum  := nNOblSum
               NakYd->Kvu1   := cKvu1   ;  NakYd->SumYd1   := nSumYd1
               NakYd->Kvu2   := cKvu2   ;  NakYd->SumYd2   := nSumYd2
               NakYd->Kvu3   := cKvu3   ;  NakYd->SumYd3   := nSumYd3
               NakYd->Kvu4   := cKvu4   ;  NakYd->SumYd4   := nSumYd4
               NakYd->Kvu5   := cKvu5   ;  NakYd->SumYd5   := nSumYd5
               NakYd->Kvu6   := cKvu6   ;  NakYd->SumYd6   := nSumYd6
               NakYd->Kvu7   := cKvu7   ;  NakYd->SumYd7   := nSumYd7
               NakYd->Kvu8   := cKvu8   ;  NakYd->SumYd8   := nSumYd8
               NakYd->Kvu9   := cKvu9   ;  NakYd->SumYd9   := nSumYd9
               NakYd->Kvu10  := cKvu10  ;  NakYd->SumYd10  := nSumYd10
               NakYd->Kvu11  := cKvu11  ;  NakYd->SumYd11  := nSumYd11
               NakYd->Kvu12  := cKvu12  ;  NakYd->SumYd12  := nSumYd12
               NakYd->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           _nOblSum := NakYd->OblSum ;  nNOblSum := NakYd->NOblSum
           cKvu1   := NakYd->Kvu1   ;  nSumYd1  := NakYd->SumYd1
           cKvu2   := NakYd->Kvu2   ;  nSumYd2  := NakYd->SumYd2
           cKvu3   := NakYd->Kvu3   ;  nSumYd3  := NakYd->SumYd3
           cKvu4   := NakYd->Kvu4   ;  nSumYd4  := NakYd->SumYd4
           cKvu5   := NakYd->Kvu5   ;  nSumYd5  := NakYd->SumYd5
           cKvu6   := NakYd->Kvu6   ;  nSumYd6  := NakYd->SumYd6
           cKvu7   := NakYd->Kvu7   ;  nSumYd7  := NakYd->SumYd7
           cKvu8   := NakYd->Kvu8   ;  nSumYd8  := NakYd->SumYd8
           cKvu9   := NakYd->Kvu9   ;  nSumYd9  := NakYd->SumYd9
           cKvu10  := NakYd->Kvu10  ;  nSumYd10 := NakYd->SumYd10
           cKvu11  := NakYd->Kvu11  ;  nSumYd11 := NakYd->SumYd11
           cKvu12  := NakYd->Kvu12  ;  nSumYd12 := NakYd->SumYd12
           @ nRow,S_wCol()+36 get _nOblSum pict "999999999.99"
           @ 05,54 wget cKvu1
           @ 05,58 wget nSumYd1 pict "999999999.99"
           @ 06,54 wget cKvu2
           @ 06,58 wget nSumYd2 pict "999999999.99"
           @ 07,54 wget cKvu3
           @ 07,58 wget nSumYd3 pict "999999999.99"
           @ 08,54 wget cKvu4
           @ 08,58 wget nSumYd4 pict "999999999.99"
           @ 09,54 wget cKvu5
           @ 09,58 wget nSumYd5 pict "999999999.99"
           @ 10,54 wget cKvu6
           @ 10,58 wget nSumYd6 pict "999999999.99"
           @ 11,54 wget cKvu7
           @ 11,58 wget nSumYd7 pict "999999999.99"
           @ 12,54 wget cKvu8
           @ 12,58 wget nSumYd8 pict "999999999.99"
           @ 13,54 wget cKvu9
           @ 13,58 wget nSumYd9 pict "999999999.99"
           @ 14,54 wget cKvu10
           @ 14,58 wget nSumYd10 pict "999999999.99"
           @ 15,54 wget cKvu11
           @ 15,58 wget nSumYd11 pict "999999999.99"
           @ 16,54 wget cKvu12
           @ 16,58 wget nSumYd12 pict "999999999.99"
           @ 17,58 wget nNOblSum pict "999999999.99"
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"NakYd")
               NakYd->OblSum  := _nOblSum;  NakYd->NOblSum  := nNOblSum
               NakYd->Kvu1   := cKvu1   ;  NakYd->SumYd1   := nSumYd1
               NakYd->Kvu2   := cKvu2   ;  NakYd->SumYd2   := nSumYd2
               NakYd->Kvu3   := cKvu3   ;  NakYd->SumYd3   := nSumYd3
               NakYd->Kvu4   := cKvu4   ;  NakYd->SumYd4   := nSumYd4
               NakYd->Kvu5   := cKvu5   ;  NakYd->SumYd5   := nSumYd5
               NakYd->Kvu6   := cKvu6   ;  NakYd->SumYd6   := nSumYd6
               NakYd->Kvu7   := cKvu7   ;  NakYd->SumYd7   := nSumYd7
               NakYd->Kvu8   := cKvu8   ;  NakYd->SumYd8   := nSumYd8
               NakYd->Kvu9   := cKvu9   ;  NakYd->SumYd9   := nSumYd9
               NakYd->Kvu10  := cKvu10  ;  NakYd->SumYd10  := nSumYd10
               NakYd->Kvu11  := cKvu11  ;  NakYd->SumYd11  := nSumYd11
               NakYd->Kvu12  := cKvu12  ;  NakYd->SumYd12  := nSumYd12
               NakYd->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F6 // Поиск
           tb:DeHilite()
           nRow := NakYd->(Recno())
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Укажите табельный номер [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           @ 03,01 wsay space(47)
           nTn := 0
           @ 03,01 wget nTn pict "999999" valid nTn > 0
           read
           if LastKey() <> K_ESC
              if !NakYd->(DbSeek(str(nTn,6)))
                S_Err({" Данные отсутствуют"})
                NakYd->(DbGoto(nRow))
              End
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
///////////////////////////////////////////////////////////////////////////
Function VedNakNach()
Local ColorOld := SetColor(), nKey, nRow, nInd, CursorOld := SetCursor(0)
Local NortonOld := DeskTop:Norton(), tb

BEGIN SEQUENCE
if !OpenList()            ; break ; End
if !OpenDbf_("NaKNach")   ; break ; End

DbSelectArea("NakNach")
Set Relation to strzero(Tn,6) into SuperLis
NakNach->(DbGoTop())
S_Open_S(01,01,22,68,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Таб.N   Фамилия             Выпл.  Начисл КВО Дни/час    Сумма"
@ 02,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"3Удалить","4Регистр","5Корректи","6Поиск"}} )
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| str(NakNach->Tn,6)+" "+SuperLis->Fio+" "+;
                                str(NakNach->D_Vip,6)+" "+str(NakNach->D_Nach,6)+" "+;
                                NakNach->Vo+" "+str(NakNach->Dn,7,2)+" "+;
                                str(NakNach->Sum,12,2) }))
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
       case nKey == K_F3  // Удаление
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"NakNach")
                 NakNach->(DbDelete())
                 NakNach->(DbUnlock())
                 NakNach->(DbSkip(1))
                 if NakNach->(eof()) ; NakNach->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4 // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Регистрируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           @ 03,01 wsay space(MaxCol()-1)
           nTn := nD_Vip := nD_Nach := nDn := nSum := 0
           cKvo := "   "
           @ 03,01 wget nTn pict "999999" valid nTn > 0
           @ 03,29 wget nD_Vip pict "999999" valid nD_Vip > 199612
           @ 03,36 wget nD_Nach pict "999999" valid nD_Nach > 199612
           @ 03,43 wget cKvo valid !Empty(cKvo)
           @ 03,47 wget nDn pict "9999.99"
           @ 03,55 wget nSum pict "999999999.99"
           read
           if LastKey() <> K_ESC .and. M_Append(20,"NakNach")
               NakNach->Tn     := nTn
               NakNach->D_Vip  := nD_Vip
               NakNach->D_Nach := nD_Nach
               NakNach->Sum    := nSum
               NakNach->Vo     := cKvo
               NakNach->Dn     := nDn
               NakNach->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nSum := NakNach->Sum
           nDn  := NakNach->Dn
           @ nRow,S_wCol()+47 get nDn pict "9999.99"
           @ nRow,S_wCol()+55 get nSum pict "999999999.99"
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"NakNach")
               NakNach->Sum    := nSum
               NakNach->Dn     := nDn
               NakNach->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F6 // Поиск
           tb:DeHilite()
           nRow := NakNach->(Recno())
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Укажите табельный номер [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           @ 03,01 wsay space(MaxCol()-1)
           nTn := 0
           @ 03,01 wget nTn pict "999999" valid nTn > 0
           read
           if LastKey() <> K_ESC
              if !NakNach->(DbSeek(str(nTn,6)))
                S_Err({" Данные отсутствуют"})
                NakNach->(DbGoto(nRow))
              End
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
///////////////////////////////////////////////////////////////////////////
Function VedomNal()
Local ColorOld := SetColor(sset[32]+","+sset[2]), GetList := {}
Local CursorOld := SetCursor(1), cFile := "VedNal.txt", nPP
Local nKv := 1, nGod := 2005, cNaim, cNKod, nData, kData, cKvu_, cSumYd_
Local nMec := {1,4,7,10}, kMec := {3,6,9,12}, i,nS1ob, nS2dn, nS1, nS2, nS3, nTn, nkr,nS11,nS12,nS13
//Local cInnDir := cInnBux := space(10)
Local cInnDir := "2094001190"
Local cInnBux := "2197304484"

Private nPage := 0, nLine, Len := 83
fErase("Ved8dp.txt")
BEGIN SEQUENCE
S_Open_S(12,38,17,72,sset[32]+","+sset[2])
@ 01,01 wsay "Укажите N квартала " wget nKv Pict "99" range 1,4
@ 02,01 wsay "за год " wget nGod pict "9999" valid nGod >= 1997
@ 03,01 wsay "ИНН директора  " wget cInnDir
@ 04,01 wsay "ИНН бухгалтера " wget cInnBux
read
S_wClose()
if LastKey() == K_ESC ; break ; End
nData := nGod*100+nMec[nKv]
kData := nGod*100+kMec[nKv]
cNaim := {ctod("01.02."+str(nGod,4)),;
          ctod("01.05."+str(nGod,4)),;
          ctod("01.08."+str(nGod,4)),;
          ctod("01.11."+str(nGod,4))}[nKv]
dDataNac := S_boq(cNaim)
dDataKon := S_eoq(cNaim)
if !M_Use("Pasp",,,,"DBFNTX") ; break ; End
cNaim := Pasp->Naim
cNkod := Pasp->NKod
Pasp->(DbCloseArea())
if !OpenArx()           ; break ; End
if !OpenDbf_("NaKNach") ; break ; End
if !OpenDbf_("NaKYd")   ; break ; End
if !OpenUder()          ; break ; End
if !OpenList()          ; break ; End
Set Index to SuperTn
Okpo := cNkod
cFileNal := "DA"+"20280"+str(nKv,1)+"." + "dbf"               //+str(nKv,1)
fErase(cFileNal)
DbCreate(cFileNal,{{"Np",      "N",05,00},;
                   {"Period",  "N",01,00},;
                   {"Rik",     "N",04,00},;
                   {"Kod",     "C",10,00},;
                   {"Typ",     "N",01,00},;
                   {"Tin",     "C",10,00},;
                   {"S_nar",   "N",12,02},;
                   {"S_dox",   "N",12,02},;
                   {"S_TaxN",   "N",12,02},;
                   {"S_TaxP",   "N",12,02},;
                   {"Ozn_Dox", "N",02,00},;
                   {"D_Priyn", "D",08,00},;
                   {"D_Zviln", "D",08,00},;
                   {"Ozn_Pilg","N",02,00},;
                   {"Oznaka",  "N",01,00}})
Use (cFileNal) new alias Nal
nLastRec := SuperLis->(LastRec())
SuperLis->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую ведомость"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Set(20,"PRINT")
Set(24,"Ved8dp.txt")
//                 .............................................................................................
@ prow()+1,00 say " "
@ prow()+1,00 say "                                                        ЗАТВЕРЖДЕНО"
@ prow()+1,00 say "                                                   Наказ Державноi податковоi"
@ prow()+1,00 say "                                                    адмнiстрацii Украiни"
@ prow()+1,00 say "                                                       30.12.1997 N 473 "
@ prow()+1,00 say "   "+cNkod+"                          (в редакцii наказу ДНА Украiни вiд 60.01.99 р. N10)"
@ prow()+1,00 say "                                         Зареэстровано в Мiнiстерствi юстiцi Украiни"
@ prow()+1,00 say "                                             15 березня 1999 року за N 163/3456"
@ prow()+1,00 say " "
@ prow()+1,00 say "                                                                           Форма N 1ДФ"
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say padc("ВIДОМОСТI",Len)
@ prow()+1,00 say padc("про нарахованi та виплаченi фiзичним особам суми доходiв i суми утриманих з них податкiв",Len)
@ prow()+1,00 say padc(alltrim(cNaim),Len)
@ prow()+1,00 say " "
@ prow()+1,00 say "2 2 7 0 6 2 6 1  Державнiй податковiй адмiнiстрацii по м.Первомайському"
@ prow()+1,00 say " "
@ prow()+1,00 say padc("за "+str(nKv,1)+" квартал "+str(nGod,4)+" року",Len)
@ prow()+1,00 say " "
fS1 := fS2 := 0
While !SuperLis->(eof())
   if SuperLis->Tn <> "******" .and. SuperLis->IndN > 0
      fS1 += iif(SuperLis->Kodd==1,1,0)
      fS2 += iif(SuperLis->Kodd==2,1,0)
   End
   SuperLis->(DbSkip(1))
End
@ prow()+1,00 say "    Працювало у штатi        "+str(fS1,5)
@ prow()+1,00 say "    Працювало за сумiництвом "+str(fS2,5)
@ prow()+1,00 say "                                          Порцiя N ___"
nLine := 24
nPp   := fS1 := fS2 := fS3 := nKolvo := fS4 := fS5 := 0
SuperLis->(DbGoTop())
While !SuperLis->(eof())
   if SuperLis->Tn <> "******" .and. SuperLis->IndN > 0
      nTn := Val(SuperLis->Tn)
    nkr := SuperLis->Kodd
  aData := {} // Находим Даты выплаченные в данном квартале
      if VedArx->(DbSeek(SuperLis->Tn))
         While SuperLis->Tn == VedArx->Tn .and. !VedArx->(eof())
           _Data := val(left(dtos(VedArx->DataV),6))
           if _Data >= nData .and. _Data <= kData
             _Data := val(left(dtos(VedArx->Data),6))
             if ( nPos := ascan(aData,{|x| x[1] == _Data}) ) == 0
                 aadd(aData,{_Data,0})
                 nPos := Len(aData)
             End
             aData[nPos][2] += VedArx->SumKVip
           End
           VedArx->(DbSkip(1))
         End
      End
      nNSumObl := nS1 :=nS11 :=nS12:= nS13 := nS2 := nS1ob := nS2dn := nS3 :=  iSumS2:= 0
        nS11 := nS12 :=nS13 := nS22 := nS52 := 0
 // Находим суммы дохода и налога
      for i := 1 to Len(aData)
         nSumS1 := nSumS2 := 0
         if Nakyd->(DbSeek(str(nTn,6)+str(aData[i][1],6)))
            iSumS1 := iSumS2 :=0  // nS2dn:= 0
            for j := 1 to 12
              cKvu_   := "KVU"+alltrim(str(j,2))
              cSumYd_ := "SumYd"+alltrim(str(j,2))
              if NakYd->(&cKvu_) == "910"
       iSumS2 += NakYd->(&cSumYd_)
End
              if Suder->(DbSeek(NakYd->(&cKvu_))) .and. SUder->Np == "001"
                 iSumS1 += NakYd->(&cSumYd_)
              End
            Next
            if ( nKoef := if(Nakyd->OblSum-iSumS1<=0,0,;
                          Round(aData[i][2]/(Nakyd->OblSum-iSumS1),5)) ) > 0
               nSumS1 += Round(Nakyd->OblSum*nKoef,2)
               nSumS2 += Round(iSumS2*nKoef,2)
            End
         Else
            iSumS3 := Round(aData[i][2]*0.2,2)
            nSumS1 := aData[i][2] + iSumS3
            nSumS2 := iSumS3
         End
         nS1 += nSumS1
         nS2 += nSumS2

      Next
      // А теперь ищем удержания как начисления
      if Nakyd->(DbSeek(str(nTn,6)))
        While nTn == NakYd->Tn .and. !NakYd->(eof())
         if NakYd->D_Yd >= nData .and. NakYd->D_Yd <= kData
            nNSumObl += NakYd->NOblSum
          iSumS1 := iSumS2 := iSumS3 := 0
            for j := 1 to 12
               cKvu_   := "KVU"+alltrim(str(j,2))
               cSumYd_ := "SumYd"+alltrim(str(j,2))
               if NakYd->(&cKvu_) == "913" .or. NakYd->(&cKvu_) == "914"
                  nS3 += NakYd->(&cSumYd_)
               End
               if NakYd->(&cKvu_) == "910"
    iSumS2 += NakYd->(&cSumYd_)
             nS2dn += NakYd->(&cSumYd_)
               End
               if Suder->(DbSeek(NakYd->(&cKvu_)))
                 if SUder->Np <> "001"
                    iSumS1 += NakYd->(&cSumYd_)
                 else
                    iSumS3 += NakYd->(&cSumYd_)
                 End
               End
            Next
                nS1ob  += NakYd->OblSum   //\\\25.2003
            if ( nKoef := if(Nakyd->OblSum-iSumS3<=0,0,;
                            Round(iSumS1/(Nakyd->OblSum-iSumS3),5)) ) > 0
                nS1 += Round(Nakyd->OblSum*nKoef,2)
                nS2 += Round(iSumS2*nKoef,2)
            End
          End
          NakYd->(DbSkip(1))
        End
      End
      nS3 := Round(nS1*0.015,2)
      nKolvo++

  if NakNach->(DbSeek(str(nTn,6)))
         nS1 :=  nS22:=  nS52:= 0
         While nTn == NakNach->tn .and. !NakNach->(eof())
            if NakNach->D_Nach >= nData .and. NakNach->D_Nach <= kData
                  nS1 += NakNach->Sum
            End
            if NakNach->D_Nach >= nData .and. NakNach->D_Nach <= kData .and. NakNach->VO =="221"
                  nS22 += NakNach->Sum
            End

            if NakNach->D_Nach >= nData .and. NakNach->D_Nach <= kData .and. NakNach->VO == "520"
                  nS52 += NakNach->Sum
            End

            if NakNach->D_Nach >= nData .and. NakNach->D_Nach <= nData+1
                  nS11 += NakNach->Sum
            End
            if NakNach->D_Nach >= nData+1  .and. NakNach->D_Nach <= nData+2
                  nS12 += NakNach->Sum
            End
            if NakNach->D_Nach >= nData+2 .and. NakNach->D_Nach <= kData
                  nS13 += NakNach->Sum
            End

          NakNach->(DbSkip(1))
         End
        // if !Empty(nS1)
       //      PutLine( str(++nPP,3)+" "+str(SuperLis->IndN,10)+" "+;
    //  str(nS1ob,15,2)+" "+   str(nS1,15,2)+" "+space(40)+"    3    " )
      //       AddNal(Npp,nKv,nGod,Okpo,0,SuperLis->IndN,nS1ob,nS1,0,0,3,;
        //            ctod(""),ctod(""),0,0)
        //     fS1 += nS1
       //  End
       End
     nPrizLg := 0
if   nS11<570 .or. nS12<570 .or. nS13<570
     nPrizLg := 1
 End

 if  nkr = 2
     nPrizLg := 0
 End
    if   SuperLis->PrizLg =1
        nPrizLg := 2
    End
        nS22 :=  nS22 + nS52
   if  nS22 = 0
      nS2 :=  nS2dn  //////2005
PutLine( str(++nPP,3)+" "+str(SuperLis->IndN,10)+" "+;
       str(nS1ob,15,2)+" "+str(nS1,15,2)+" "+ str(nS2dn,15,2)+" "+ str(nS2,15,2)+"             1    "+;
                  iif(SuperLis->DataPr>=dDataNac.and.SuperLis->DataPr<=dDataKon,dtoc(SuperLis->DataPr),space(10))+" "+;
                  iif(SuperLis->DataUv>=dDataNac.and.SuperLis->DataUv<=dDataKon,dtoc(SuperLis->DataUv),space(10))+" "+;
                  str(nPrizLg,2)  )
     //         str(SuperLis->PrizLg,2)  )
 AddNal(Npp,nKv,nGod,Okpo,0,SuperLis->IndN,nS1ob,nS1,nS2dn,nS2,1,;
                 iif(SuperLis->DataPr>=dDataNac.and.SuperLis->DataPr<=dDataKon,SuperLis->DataPr,ctod("")),;
                 iif(SuperLis->DataUv>=dDataNac.and.SuperLis->DataUv<=dDataKon,SuperLis->DataUv,ctod("")),;
               nPrizLg,0)
//    SuperLis->PrizLg,0)
         end
  if   nkr =9    // 2
    PutLine( str(++nPP,3)+" "+str(SuperLis->IndN,10)+" "+;
       str(nS1ob,15,2)+" "+str(nS1,15,2)+" "+ str(nS2dn,15,2)+" "+ str(nS2,15,2)+"             2    "+;
                  iif(SuperLis->DataPr>=dDataNac.and.SuperLis->DataPr<=dDataKon,dtoc(SuperLis->DataPr),space(10))+" "+;
                  iif(SuperLis->DataUv>=dDataNac.and.SuperLis->DataUv<=dDataKon,dtoc(SuperLis->DataUv),space(10))+" "+;
                  str(SuperLis->PrizLg,2)  )
      AddNal(Npp,nKv,nGod,Okpo,0,SuperLis->IndN,nS1ob,nS1,nS2dn,nS2,1,;
                 iif(SuperLis->DataPr>=dDataNac.and.SuperLis->DataPr<=dDataKon,SuperLis->DataPr,ctod("")),;
                 iif(SuperLis->DataUv>=dDataNac.and.SuperLis->DataUv<=dDataKon,SuperLis->DataUv,ctod("")),;
                 SuperLis->PrizLg,0)
   end
  //    nS22 :=  nS22 + nS52

  if  nS22 >0
nPrizLg := 22
PutLine( str(++nPP,3)+" "+str(SuperLis->IndN,10)+" "+;
       str(nS1ob,15,2)+" "+str(nS1,15,2)+" "+ str(nS2dn,15,2)+" "+ str(nS2,15,2)+"             1    "+;
                  iif(SuperLis->DataPr>=dDataNac.and.SuperLis->DataPr<=dDataKon,dtoc(SuperLis->DataPr),space(10))+" "+;
                  iif(SuperLis->DataUv>=dDataNac.and.SuperLis->DataUv<=dDataKon,dtoc(SuperLis->DataUv),space(10))+" "+;
                  str(nPrizLg,2)  )
      AddNal(Npp,nKv,nGod,Okpo,0,SuperLis->IndN,nS1ob,nS1,nS2dn,nS2,1,;
                 iif(SuperLis->DataPr>=dDataNac.and.SuperLis->DataPr<=dDataKon,SuperLis->DataPr,ctod("")),;
                 iif(SuperLis->DataUv>=dDataNac.and.SuperLis->DataUv<=dDataKon,SuperLis->DataUv,ctod("")),;
                nPrizLg,0)
   end


     fS1 += nS1
      fS2 += nS2
      fS3 += nS3
  //    fS4 += nS1ob + nNSumObl
     fS4 += nS1ob
 fS5 += nS2dn
  if NakNach->(DbSeek(str(nTn,6)))
         nS1 := 0
         While nTn == NakNach->tn .and. !NakNach->(eof())
            if NakNach->D_Nach >= nData .and. NakNach->D_Nach <= kData .and. ;
                           ( NakNach->Vo == "375" .or. NakNach->Vo == "375" )
                  nS1 += NakNach->Sum
     End
            NakNach->(DbSkip(1))
         End
         if !Empty(nS1)
         nS1ob := nS1
      PutLine( str(++nPP,3)+" "+str(SuperLis->IndN,10)+" "+;
      str(nS1ob,15,2)+" "+   str(nS1,15,2)+" "+space(40)+"    22    " )
             AddNal(Npp,nKv,nGod,Okpo,0,SuperLis->IndN,nS1ob,nS1,0,0,22,;
                    ctod(""),ctod(""),0,0)
             fS1 += nS1
         End
       End
   //    if !Empty(nNSumObl)
  //           PutLine( str(++nPP,3)+" "+str(SuperLis->IndN,10)+" "+;
 //  str(nNSumObl,15,2)+" "+str(nNSumObl,15,2)+" "+space(40)+"    7    " )
//             AddNal(Npp,nKv,nGod,Okpo,0,SuperLis->IndN,nNSumObl,nNSumObl,0,0,7,;
//                    ctod(""),ctod(""),0,0)
//       End
   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   SuperLis->(DbSkip(1))
End
@ prow()+1,00 say Repl("=",Len)
@ prow()+1,00 say space(3)+" "+padr("Итого",10)+" "+;
       str(fS4,15,2)+" "+str(fS1,15,2)+" "+ str(fS5,15,2)+" "+str(fS2,15,2)
@ prow()+1,00 say "КiлькIсть рядкiв "+str(Npp,5)+"        "+;
                  "Кiлькiсть фiзичних осiб "+str(nKolvo,5)+"       "+;
                  "КiлькIсть аркушiв "+str(nPage,5)
@ prow()+1,00 say " "
@ prow()+1,00 say "Керiвник пiприэмства  "+cInnDir+"  _____________       _______________     ___________"
@ prow()+1,00 say " "
@ prow()+1,00 say "             м.п.                                       Дата подання ___________"
@ prow()+1,00 say " "
@ prow()+1,00 say "Головний бухгалтер    "+cInnBux+"  _____________       _______________     ___________"
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say "                                                         Наведена iнформацiя е вiрною"
@ prow()+1,00 say ""
S_Beep(3)
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
AddNal(99991,nKv,nGod,Okpo,0,cInnDir,23018,0,0,0,0,ctod(""),ctod(""),0,0)
AddNal(99992,nKv,nGod,Okpo,0,cInnBux,24122,0,0,0,0,ctod(""),ctod(""),0,0)
AddNal(99999,nKv,nGod,Okpo,0,"     ",fS4,fS1,fs5,fs2,0,ctod(""),ctod(""),0,0)
ShowPrn("Ved8dp.txt","Ведомость",74)
if S_Err({"Сформировани файл "+cFileNal,;
          "Для передачи в налоговую инспекцию",;
          "Будем записывать его сейчас на дискуту?",;
          "%    Нет  ;  Да   ;"}) == 2
   S_Err({"Установите чистую дискуту в дисковод a:\"})
   DbselectArea("Nal")
   S_Sys({"Минутку...","пишу на дискуту"})
   Copy to ("a:\"+cFileNal)
   S_Sys()
End
//S_wClose()
END SEQUENCE
SetColor(ColorOld)
SetCursor(CursorOld)
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Static Function PutLine(cLine)
Local i
if nPage == 0 .or. nLine > 64
   if nLine > 64
     For i := nLine to 67
        @ prow()+1,00 say Padc(" ",Len)
     Next
     @ prow()+1,00 say repl(".",Len)
     nLine := 0
   End
   @ prow()+1,00 say padr(" Лист# "+str(++nPage,3),Len)
//   @ prow()+1,00 say repl("-",Len)
//  @ prow()+1,1 say [                         Порцiя  N                                                                                ]
  @ prow()+1,1 say [_______________________________________________________________________________________________________________________________]
  @ prow()+1,1 say [     :          :                 :               :                                  :       :       Дата          :Ознака     :]
  @ prow()+1,1 say [  N  :Iдентiфiк.:  Сума нара-     : Сума виплаче- :          Сума утриманого         : Ознака:_____________________:пiльги щодо:]
  @ prow()+1,1 say [ п/п :   номер  :  хованого       :  ного доходу  :         прибут. податку          : доходу:прийняття :звiльнення:прибутко-  :]
  @ prow()+1,1 say [     :          :    доходу       :  (грн.,коп.)  :  нарахованого  : перерахованого  :       :на роботу : з роботи :   вого    :]
  @ prow()+1,1 say [     :          :  (грн.,коп.)    :               :   (грн.,коп.)  :   (грн.,коп.)   :       :          : податку  :           :]
  @ prow()+1,1 say [________________________________________________________________________________________________________________________________]

//   @ prow()+1,00 say " N :Iдентiфiк.:сума     сума      :сума утриманого:       :        Дата         :      "
//   @ prow()+1,00 say "п/п:   код    :  виплаченого  :  прибуткового : ознака:---------------------:Ознака"
//   @ prow()+1,00 say " N :          :    доходу     :    податку    : доходу:Прийняття :Звiльнення:пiльги"
//                   ".3.:....10....:......15.......:......15.......:...7...:...10.....:...10.....:...6..
//   @ prow()+1,00 say repl("-",Len)
   nLine += 6
End
@ prow()+1,00 say cLine
nLine++
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Static function AddNal(iNp,iPeriod,iGod,iOkpo,iTyp,iTin,iS1ob,iS1,iS2dn,iS2,iOzn,;
                       iPriem,iZviln,iPilg,iOznaka)
Nal->(DbAppend())
Nal->Np         :=  iNp
Nal->Period     :=  iPeriod
Nal->Rik        :=  iGod
Nal->Kod        :=  iOkpo
Nal->Typ        :=  iTyp
Nal->Tin        :=  iif(ValType(iTin)=="N",str(iTin,10),iTin)
Nal->S_Nar      :=  iS1ob
Nal->S_dox      :=  iS1
Nal->S_TaxN     :=  iS2dn
Nal->S_TaxP     :=  iS2
Nal->Ozn_Dox    :=  iOzn
Nal->D_Priyn    :=  iPriem
Nal->D_Zviln    :=  iZviln
Nal->Ozn_Pilg   :=  iPilg
Nal->Oznaka     :=  iOznaka
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Function Forma3f()  // Формирование данных по форме 3
Local i, nSumMin := nSumMat := 0, nData := 199701, kData := 199712
Local ColorOld := SetColor(sset[32]+","+sset[2]), GetList := {}
Local CursorOld := SetCursor(1)

Ferase("NalF3.Dbf")
Ferase("NalF3.Ntx")
BEGIN SEQUENCE
S_Open_S(12,30,17,64,sset[32]+","+sset[2])
@ 01,01 wsay "Укажите: дату начала" wget nData pict "999999" valid nData > 199612
@ 02,01 wsay "              конца " wget kData pict "999999" valid kData > 199612 .and. ;
                                                           kData >= nData
@ 03,01 wsay "наоблагаемый минимум" wget nSumMin pict "99999999.99" valid nSumMin > 0
@ 04,01 wsay "наобл. мат.помощи   " wget nSumMat pict "99999999.99" valid nSumMat >= 0
read
SetColor(ColorOld)
SetCursor(CursorOld)
if LastKey() == K_ESC ; break ; End
S_wClose()
if !OpenDbf_("NAL")     ; break ; End
if !Nal->(Dbseek(str(nData,6)))
  S_Err({"Отсутствуют данные для расчета в базе NAL",;
         "% Нажмите клавишу ENTER ;"})
  break
End
if !M_Use("SKN",,,,"DBFNTX")  ; break ; End
if !OpenDbf_("NALF3")   ; break ; End
if !OpenDbf_("NAKYD")   ; break ; End
if !OpenDbf_("NAKNACH") ; break ; End
if !OpenList()          ; break ; End
Set Index to SuperTn
nLastRec := SuperLis->(LastRec())
SuperLis->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую данные"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
While !SuperLis->(eof())
   if SuperLis->Tn <> "******"
      nTn := Val(SuperLis->Tn)
      nSObl := nS910 := nKolMec := 0
      if Nakyd->(DbSeek(str(nTn,6)))
         While nTn == Nakyd->tn .and. !NakYd->(eof())
            if NakYd->D_Yd >= nData .and. NakYd->D_Yd <= kData
               nSObl   += NakYd->OblSum
               nKolMec += iif(!Empty(NakYd->OblSum),1,0)
               for i := 1 to 12
                 cKvu_   := "KVU"+alltrim(str(i,2))
                 cSumYd_ := "SumYd"+alltrim(str(i,2))
                 if NakYd->(&cKvu_) == "910"
                    nS910 += NakYd->(&cSumYd_)
                 End
               Next
            End
            NakYd->(DbSkip(1))
         End
      End
      nS605 := 0
      if NakNach->(DbSeek(str(nTn,6)))
         While nTn == NakNach->tn .and. !NakNach->(eof())
            if NakNach->D_Nach >= nData .and. NakNach->D_Nach <= kData .and. ;
                           ( NakNach->Vo == "605" .or. NakNach->Vo == "607" )
                  nS605 += NakNach->Sum
            End
            NakNach->(DbSkip(1))
          End
      End
      nRec := SuperLis->Base_Rec
      cKsp := SuperLis->Ksp
      cTemp := "Base"+cKsp
      use (cTemp) new alias Base
      Base->(DbGoto(nRec))
      nK_Det := Base->K_Det
      cNp    := Base->Np
      Base->(DbCloseArea())
      // Все расчитываем
      nS1   := nSObl + nS605
      nS1_1 := nS605
      nS2_2 := 0
      nS2_1 := iif(nSObl>Round(10*nKolMec*nSumMin,2),0,Round(nK_Det*nSumMin,2))
      nS4   := 0
       nS3   := 0
   if cNp <> " " .and. cNp <> "0"
         DbSelectArea("Skn")
         Locate for Kn = cNp
         if Found()
            nS2_2 := Round(nSumMin*Skn->Spn,2)
         End
      End
      if nS1_1 - nSumMat > 0
         nSumma := nS1 - nS2_2 + ( nS1_1 - nSumMat )
      else
         nSumma := nS1 - nS2_2 - nS1_1
      End
      nSInt := iif(nKolMec==0,0,int(nSumma/nKolMec))
      if nSInt > nSumMin
        for i := 1 to 10
            cS1 := "S1_"+alltrim(str(i,2))
            cS2 := "S2_"+alltrim(str(i,2))
            if nSInt >= Nal->(&cS1) .and. nSInt <= Nal->(&cS2)
               cPr := "Pr_"+alltrim(str(i,2))
               cSd := "Sd_"+alltrim(str(i,2))
               nS4 := Round(nKolMec*((nSInt - Nal->(&cS1))*Nal->(&cPr) + Nal->(&cSd)),2)
               Exit
            End
        Next
        if Empty(nS4)
          S_Err({" По табельному номеру "+str(nTn,6),;
                 " Не возможно вычислить S4","% Нажмите клавишу ENTER ;"})
        End
      End
      nS5   := nS910
      nS6   := nS5 - nS4
      if M_Append(20,"NalF3")
         NalF3->Tn   := nTn
         NalF3->S1   := nS1
         NalF3->S1_1 := nS1_1
         NalF3->S2_1 := nS2_1
         NalF3->S2_2 := nS2_2
         NalF3->S3   := nS3
         NalF3->S4   := nS4
         NalF3->S5   := nS5
         NalF3->S6   := nS6
         NalF3->(DbUnlock())
      End
   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   SuperLis->(DbSkip(1))
End
S_BEEP(3)
S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
////////////////////////////////////////////////////////////////////////
Function VedNalF3()
Local ColorOld := SetColor(), nKey, nRow, nInd, CursorOld := SetCursor(0)
Local NortonOld := DeskTop:Norton(), tb
Local nTn, nS1, nS1_1, nS2_1, nS2_2, nS4, nS5, nS6 , nS3

BEGIN SEQUENCE
if !OpenList()         ; break ; End
if !OpenDbf_("NalF3")  ; break ; End

DbSelectArea("NalF3")
Set Relation to strzero(Tn,6) into SuperLis
NalF3->(DbGoTop())
S_Open_S(01,01,22,65,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Таб.N   Фамилия                Итог       Пересчет   Фактически"
@ 02,01 wsay Repl("─",S_wMaxCol()-1)
@ S_wLastRow()-3,S_wCol()+01 say Repl("─",S_wMaxCol()-1)
@ S_wLastRow()-2,S_wCol()+01 say "3."
@ S_wLastRow()-1,S_wCol()+01 say "1."
@ S_wLastRow()-1,S_wCol()+17 say "1.1"
@ S_wLastRow()-1,S_wCol()+33 say "2.1"
@ S_wLastRow()-1,S_wCol()+49 say "2.2"
oNortonNew( {{"3Удалить","4Регистр","5Корректи","6Поиск"}} )
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-4,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| str(NalF3->Tn,6)+" "+SuperLis->Fio+" "+;
                                str(NalF3->S6,11,2)+" "+str(NalF3->S4,11,2)+" "+;
                                str(NalF3->S5,11,2) }))
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := S_Inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   @ S_wLastRow()-2,S_wCol()+04 say NalF3->S3   pict "99999999.99"
   @ S_wLastRow()-1,S_wCol()+04 say NalF3->S1   pict "99999999.99"
   @ S_wLastRow()-1,S_wCol()+21 say NalF3->S1_1 pict "99999999.99"
   @ S_wLastRow()-1,S_wCol()+37 say NalF3->S2_1 pict "99999999.99"
   @ S_wLastRow()-1,S_wCol()+53 say NalF3->S2_2 pict "99999999.99"
   if nKey == 0 ; nKey := S_InKey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3  // Удаление
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"NalF3")
                 NalF3->(DbDelete())
                 NalF3->(DbUnlock())
                 NalF3->(DbSkip(1))
                 if NalF3->(eof()) ; NalF3->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4 // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Регистрируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           @ 03,01 wsay space(MaxCol()-1)
           nTn := nS1 := nS1_1 := nS2_1 := nS2_2 := nS4 := nS5 := nS6 := nS3 := 0
           @ 03,01 wget nTn   pict "999999" valid nTn > 0
           @ 03,29 wget nS6   pict "99999999.99"
           @ 03,41 wget nS4   pict "99999999.99"
           @ 03,53 wget nS5   pict "99999999.99"
           @ S_wLastRow()-2,S_wCol()+04 get nS3   pict "99999999.99"
           @ S_wLastRow()-1,S_wCol()+04 get nS1   pict "99999999.99"
           @ S_wLastRow()-1,S_wCol()+21 get nS1_1 pict "99999999.99"
           @ S_wLastRow()-1,S_wCol()+37 get nS2_1 pict "99999999.99"
           @ S_wLastRow()-1,S_wCol()+53 get nS2_2 pict "99999999.99"
           read
           if LastKey() <> K_ESC .and. M_Append(20,"NalF3")
               NalF3->Tn   := nTn
               NalF3->S1   := nS1
               NalF3->S1_1 := nS1_1
               NalF3->S2_1 := nS2_1
               NalF3->S2_2 := nS2_2
               NalF3->S3   := nS3
               NalF3->S4   := nS4
               NalF3->S5   := nS5
               NalF3->S6   := nS6
               NalF3->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nS1   := NalF3->S1
           nS1_1 := NalF3->S1_1
           nS2_1 := NalF3->S2_1
           nS2_2 := NalF3->S2_2
           nS3   := NalF3->S3
           nS4   := NalF3->S4
           nS5   := NalF3->S5
           nS6   := NalF3->S6
           @ nRow,S_wCol()+29 get nS6   pict "99999999.99"
           @ nRow,S_wCol()+41 get nS4   pict "99999999.99"
           @ nRow,S_wCol()+53 get nS5   pict "99999999.99"
           @ s_wLastRow()-2,S_wCol()+04 get nS3   pict "99999999.99"
           @ s_wLastRow()-1,S_wCol()+04 get nS1   pict "99999999.99"
           @ s_wLastRow()-1,S_wCol()+21 get nS1_1 pict "99999999.99"
           @ s_wLastRow()-1,S_wCol()+37 get nS2_1 pict "99999999.99"
           @ s_wLastRow()-1,S_wCol()+53 get nS2_2 pict "99999999.99"
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"NalF3")
               NalF3->S1   := nS1
               NalF3->S1_1 := nS1_1
               NalF3->S2_1 := nS2_1
               NalF3->S2_2 := nS2_2
               NalF3->S3   := nS3
               NalF3->S4   := nS4
               NalF3->S5   := nS5
               NalF3->S6   := nS6
               NalF3->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F6 // Поиск
           tb:DeHilite()
           nRow := NalF3->(Recno())
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Укажите табельный номер [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           @ 03,01 wsay space(MaxCol()-1)
           nTn := 0
           @ 03,01 wget nTn pict "999999" valid nTn > 0
           read
           if LastKey() <> K_ESC
              if !NalF3->(DbSeek(str(nTn,6)))
                S_Err({" Данные отсутствуют"})
                NalF3->(DbGoto(nRow))
              End
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
Function FormaF3p()  // Печать формы 3
Local nRecno, nLastRec, bBlock := {|x| .t.}, ListTn := "", i, aTn, nKol
Local nS3, nSumma, aLeft, aRight

BEGIN SEQUENCE
if !OpenDbf_("NalF3") ; break ; End
if !OpenList()        ; break ; End
if S_Err({" Печать полная? ","%  Да  ;  Нет  ;"}) == 2
   nRecno   := SetCursor(1)
   S_Open_S(04,50,20,58,sset[21]+","+sset[8]+",,,"+sset[21])
   @ 01,01 wsay "Укажите"
   @ 02,01 wsay "Таб.N "
   @ 03,01 wsay "_______"
   While ( .t. )
     Scroll(S_wRow()+04,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1,-1)
     i := 0
     @ 04,01 wget i pict "999999" valid i > 0
     read
     if LastKey() == K_ESC ; exit ; End
     ListTn += str(i,6)+"~"
  End
  S_wClose()
  SetCursor(nRecno)
  bBlock := {|x| str(x,6)$ListTn }
End
nLastRec := NalF3->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Внимание..."
@ 01,42 wsay "Следите за печатью и бумагой"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Set(20,"PRINT")
Set(24,"Forma3.txt")
NalF3->(DbGoTop())
aTn := {}
nKol := 0
While !NalF3->(eof())
 if eval(bBlock,NalF3->Tn)
   SuperLis->(DbSeek(strZero(NalF3->Tn,6)))
   aadd(aTn,"                                                  ")
   aadd(aTn,"                                      Форма N 3   ")
   aadd(aTn,"                С П Р А В К А                     ")
   aadd(aTn,padr("Выдана "+SuperLis->Fio,len(aTn[1])) )
   aadd(aTn,padr("Цех "+SuperLis->Ksp+" Табельный номер "+SuperLis->Tn,len(aTn[1])) )
   aadd(aTn,"в том, что ему(ей) в _______ году начислено:      ")
   aadd(aTn,"--------------------------------------------------")
   aadd(aTn,"                            :    I     : за год   ")
   aadd(aTn,"--------------------------------------------------")
   aadd(aTn,"1. Начислено С.Д. в сумме   :"+str(NalF3->S1,10,2)+":"+str(NalF3->S1,10,2) )
   aadd(aTn,"   в том числе:             :          :         " )
   aadd(aTn,"1.1 - мат. помощь           :"+str(NalF3->S1_1,10,2)+":"+str(NalF3->S1_1,10,2) )
   aadd(aTn,"1.2 - дивиденты             :          :         " )
   aadd(aTn,"1.3 - инвалюта              :          :         " )
   aadd(aTn,"                            :          :         " )
   aadd(aTn,"2. Сумма отчислений         :"+str(NalF3->S2_1+NalF3->S2_2,10,2)+":"+str(NalF3->S2_1+NalF3->S2_2,10,2) )
   aadd(aTn,"   в том числе на:          :          :         " )
   aadd(aTn,"2.1 - детей до 6 лет        :"+str(NalF3->S2_1,10,2)+":"+str(NalF3->S2_1,10,2) )
   aadd(aTn,"2.2 - M,5M,10M              :"+str(NalF3->S2_2,10,2)+":"+str(NalF3->S2_2,10,2) )
   aadd(aTn,"2.3 - приобретение акций    :          :         " )
   aadd(aTn,"                            :          :         " )
   aadd(aTn,"3. Облагаемый доход (ОД)    :"+str(NalF3->S3,10,2)+":"+str(NalF3->S3,10,2) )
   aadd(aTn,"                            :          :         " )
   aadd(aTn,"4. Налог с ОД по пересчету  :"+str(NalF3->S4,10,2)+":"+str(NalF3->S4,10,2) )
   aadd(aTn,"                            :          :         " )
   aadd(aTn,"5. Был удержан налог фактич.:"+str(NalF3->S5,10,2)+":"+str(NalF3->S5,10,2) )
   aadd(aTn,"                            :          :         " )
   aadd(aTn,"6. Подл. возвр.(-),доп.(+)  :"+str(NalF3->S6,10,2)+":"+str(NalF3->S6,10,2) )
   aadd(aTn,"                                                 " )
   aadd(aTn,"  Исправления, подтирания не допускаются         " )
   aadd(aTn,"                                                 " )
   aadd(aTn,"                                                 " )
   aadd(aTn,"    мп Главный бухгалтер ______________          " )
   aadd(aTn,"                                                 " )
   aadd(aTn,"                                                 " )
   aadd(aTn,"=================================================" )
   if ++nKol == 1
      aLeft := aclone(aTn)
   else
      aRight:= aclone(aTn)
   end
   aTn := {}
   if nKol == 2
      for i := 1 to len(aLeft)
        @ prow()+1,00 say aLeft[i]+space(10)+aRight[i]
      Next
      nKol := 0
   End
 End
 S_Line_N(18,04,65,nLastRec,++nRecno)
 NalF3->(DbSkip(1))
End
if nKol == 1
  for i := 1 to len(aLeft)
     @ prow()+1,00 say aLeft[i]
  Next
elseif nKol == 2
  for i := 1 to len(aLeft)
     @ prow()+1,00 say aLeft[i]+space(10)+aRight[i]
  Next
End
@ prow()+1,00 say " "
@ prow()+1,00 say ""
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn("Forma3.txt"," Справки ",74)
fErase("Forma3.txt")
END SEQUENCE
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function ZapNal() // запись информации в л/с
Local mRecno, nLastRec, cKsp, nRec, i, j, nRecno, cTnr, cSym, lYes
Local jm, cVo, cSvon, cKmn
Local cMec := Substr(dtos(sset[121]),5,2), cKVO := "933"

BEGIN SEQUENCE
if !OpenDbf_("NalF3") ; break ; End
if !OpenList()        ; break ; End
nLastRec := NalF3->(LastRec())
NalF3->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Делаю запись информации"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
While ( !NalF3->(eof()) )
   cTnr := StrZero(NalF3->Tn,6)
   if !SuperLis->(DbSeek(cTnr))
      S_Err({"Табельный номер - "+cTnr,"Отсутствует в справочнике"})
   elseif !Empty(NalF3->S6)
     cKsp := SuperLis->Ksp        // Код подразделения
     nRec := SuperLis->Base_Rec   // No записи в BASE
     cSym := "Base"+cKsp
     Use (cSym) new alias Base
     Base->(DbGoto(nRec))
     lYes := .f.
     for j := 1 to 12
        jm := Alltrim(str(j,2))
        cVo := "Ku"+jm
        if empty(Base->&cVo) .or. Base->&cVo == cKVO
          lYes := .t.
          Base->&cVo  := cKVO
          cSvon := "Sku"+jm
          Base->&cSvon := Nalf3->S6*100
          cKmn := "Kmu"+jm
          Base->&cKmn := cMec
          Exit
        End
     Next
     if !lYes
       S_Err({"Табельный номер - "+cTnr,"Данные не записаны"})
     End
     Base->(DbCloseArea())
   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   NalF3->(DbSkip(1))
End
S_Beep(3)
S_Line_N()
END SEQUENCE
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////
Function BautNal()
S_Err({1,1,"^О технологии",;
  "  Во-первых, для эксплуатации данного пункта меню, необходимо завести ",;
  "ИНН на всех работников (по данным списка из ГНА)                      ",;
  "                        =================                             ",;
  "  После расчета З/П за текущий месяц (программа ZARP.EXE), необходимо ",;
  "сделать [АРХИВИРОВАНИЕ] в обязательном порядке до того как  перевести ",;
  "работу программы на расчет следующего месяца.                         ",;
  "  [КОРРЕКТИРОВКА НАЧИСЛЕНИЙ] и [КОРРЕКТИРОВКА УДЕРЖАНИЙ] позволяют Вам",;
  "просмотреть и при необходимости скорректировать архивные данные по на-",;
  "числениям и удержаниям до того как формировать ведомость 8ДР и печа-  ",;
  "тать справки по форма 3.                                              ",;
  "  Ведомость 8ДР печатается в конце расчета З/П за отчетный квартал до ",;
  "14 числа следующего месяца для передача в ГНА.                        ",;
  "  В конце года необходимо [СФОРМИРОВАТЬ] данные для печати справки по ",;
  "ФОРМЕ 3. Пунктом [КОРРЕКТИРОВКА ФОРМЫ 3] можно данные при необходимос-",;
  "ти просмотреть с экрана и скорретировать их,а пунктом [ПЕЧАТЬ ФОРМЫ 3]",;
  "вывести данные на печать в виде справки установленного образца.       ",;
  "  При расчете З/П в следующеь году необходимо выполнить пункт [ВВОД   ",;
  "ДАННЫХ В З/П] для того, чтобы отклонения по удержанному налогу за прош",;
  "лый год можно было учесть в З/П за тукущего года.                     "})
Return ( nil )
////////////////////////////////////////////////////////////////////////////
Function PrnSpr() // Печать справки в ГНА
Local nLastRec, nRecno
Local nKol1  := nKol2 := nKol3 := nKol4 := nSum1 := nSum2 := 0

BEGIN SEQUENCE
if !OpenDbf_("NalF3") ; break ; End
if !OpenList()        ; break ; End
nLastRec := SuperLis->(LastRec())+NalF3->(LastRec())
SuperLis->(DbGoTop())
NalF3->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую справку"
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
While ( !SuperLis->(eof()) )
  if SuperLis->Tn<>"******"
     nKol1++
  End
  S_Line_N(18,04,65,nLastRec,+nRecno)
  SuperLis->(DbSkip(1))
End
While ( !NalF3->(eof()) )
   nKol2++
   if Nalf3->S6 > 0
      nKol4++
      nSum2 += Nalf3->S6
   elseif Nalf3->S6 < 0
      nKol3++
      nSum1 += Nalf3->S6
   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   NalF3->(DbSkip(1))
End
S_Beep(3)
S_Line_N()
Set(20,"PRINT")
Set(24,"SprNal.txt")
@ prow()+1,00 say " "
@ prow()+1,00 say "Сведения о пересчете подоходного налога за ________ год"
@ prow()+1,00 say "----------------------------------------------------------------------"
@ prow()+1,00 say " "
@ prow()+1,00 say "Количество лицевых счетов на _________                "+str(nKol1,15)
@ prow()+1,00 say " "
@ prow()+1,00 say "Количество лицевых по которым произведен пересчет п/н "+str(nKol2,15)
@ prow()+1,00 say " "
@ prow()+1,00 say "Количество лицевых счетов со знаком (-)               "+str(nKol3,15)
@ prow()+1,00 say " "
@ prow()+1,00 say "Сумма со знаком (-)                                   "+str(nSum1,15,2)
@ prow()+1,00 say " "
@ prow()+1,00 say "Количество лицевых счетов со знаком (+)               "+str(nKol4,15)
@ prow()+1,00 say " "
@ prow()+1,00 say "Сумма со знаком (+)                                   "+str(nSum2,15,2)
@ prow()+1,00 say " "
@ prow()+1,00 say "----------------------------------------------------------------------"
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say "   Гл. бухгалтер ____________________"
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say ""
Set(24,"")
Set(20,"SCREEN")
ShowPrn("SprNal.txt"," Справку ",74)
fErase("SprNal.txt")
END SEQUENCE
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function VedArx()
Local ColorOld := SetColor(), nKey, nRow, nInd, CursorOld := SetCursor(0)
Local NortonOld := DeskTop:Norton(), tb, cKvu
Local cTn, nNumVed, dData, dDataV, nSumKVip, cKsp

BEGIN SEQUENCE
if !OpenUder() ; break ; End
if !OpenList() ; break ; End
if !OpenArx()  ; break ; End
//
DbSelectArea("VedArx")
Set Relation to Tn into SuperLis
VedArx->(DbGoTop())
S_Open_S(01,01,22,74,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Таб.N   Фамилия             N вед Дата нач.  Дата выпл.   сумма      Кву"
@ 02,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"3Удалить","4Регистр","5Корректи","6Поиск"}} )
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| VedArx->Tn+" "+SuperLis->Fio+" "+;
                                str(VedArx->NumVed,5)+" "+;
                                dtoc(VedArx->Data)+" "+dtoc(VedArx->DataV)+" "+;
                                str(VedArx->SumKVip,12,2)+" "+;
                                VedArx->Kvu }))
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
       case nKey == K_F3  // Удаление
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"VedArx")
                 VedArx->(DbDelete())
                 VedArx->(DbUnlock())
                 VedArx->(DbSkip(1))
                 if VedArx->(eof()) ; VedArx->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4 // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Регистрируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           BEGIN SEQUENCE
           @ 03,01 wsay space(MaxCol()-1)
           cTn := "000000"
           cKvu:= "000"
           nSumkvip := nNumVed := 0
           dData := dDataV := ctod("")
           @ 03,01 wget cTn
           read
           if LastKey() == K_ESC ; break ; End
           if !SuperLis->(DbSeek(cTn))
              @ 03,08 wsay "Отсутствует"
              S_Beep()
              S_Inkey(0)
              break
           End
           cKsp := SuperLis->Ksp
           @ 03,08 wsay SuperLis->Fio
           @ 03,29 wget nNumVed pict "99999" valid nNumVed >= 0
           @ 03,35 wget dData  pict "@d" valid !Empty(dData)
           @ 03,46 wget dDataV pict "@d" valid !Empty(dDataV)
           @ 03,57 wget nSumKvip  pict "999999999.99"
           @ 03,70 wget cKvu valid VedsUder(@cKvu)
           read
           if LastKey() == K_ESC ; break ; End
           if M_Append(20,"VedArx")
               VedArx->Tn     := cTn
               VedArx->Data   := dData
               VedArx->DataV  := dDataV
               VedArx->SumKVip:= nSumKVip
               VedArx->Ksp    := cKsp
               VedArx->NumVed := nNumVed
               VedArx->Kvu    := cKvu
               VedArx->(DbUnlock())
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
           nSumKVip := VedArx->SumKVip
           nNumVed  := VedArx->NumVed
           dDataV   := VedArx->DataV
           cKvu     := VedArx->Kvu
           @ nRow,S_wCol()+29 get nNumVed pict "99999" valid nNumVed >= 0
           @ nRow,S_wCol()+46 get dDataV pict "@d" valid !Empty(dDataV)
           @ nRow,S_wCol()+57 get nSumKvip  pict "999999999.99"
           @ nRow,S_wCol()+70 get cKvu pict "xxx" valid VedsUder(@cKvu)
           read
           if LastKey() <> K_ESC .and. M_Rlock(20,"VedArx")
               VedArx->SumKVip  := nSumkVip
               VedArx->NumVed   := nNumVed
               VedArx->DataV    := dDataV
               VedArx->Kvu      := cKvu
               VedArx->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F6 // Поиск
           tb:DeHilite()
           nRow := VedArx->(Recno())
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Укажите табельный номер [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           @ 03,01 wsay space(MaxCol()-1)
           cTn := "000000"
           @ 03,01 wget cTn
           read
           if LastKey() <> K_ESC
              if !VedArx->(DbSeek(cTn))
                S_Err({" Данные отсутствуют"})
                VedArx->(DbGoto(nRow))
              End
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
/////////////////////////////////////////////////////////////////////////
Function VedsUder(cKvu,pRow,pCol)
Local ColorOld := SetColor(), nKey, SelectOld := Select()
Local CursorOld := SetCursor(0), NortonOld := DeskTop:Norton(), tb

if cKvu <> Nil .and. SUder->(DbSeek(cKvu))
   if S_Err({Suder->Naim," Верно? ","%  Да ;  Нет ;"}) == 1
      if pRow <> Nil
         @ pRow+S_wRow(),pCol+S_wCol() say Suder->Naim
      End
      Return ( .t. )
   End
End
BEGIN SEQUENCE
DbSelectArea("Suder")
Suder->(DbGoTop())
S_Open_S(01,05,22,26,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Кву Наименование"
@ 02,01 wsay Repl("─",S_wMaxCol()-1)
oNortonNew( {{"0 "}} )
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wLastCol()-1)
tb:AddColumn(TbColumnNew("",{|| Suder->Kvoy+" "+Suder->Naim }))
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := S_Inkey() ) != 0 ; exit ; end
   end
   if nKey == 0 ; nKey := S_InKey(0)  ; end
   if nKey == K_ESC .or. nKey == K_ENTER ; exit ; end
   if tb:Stable ;  ApplyKey(nkey,tb) ; End
End
tb := nKey == K_ENTER
S_wClose()
END SEQUENCE
SetColor(ColorOld)
SetCursor(CursorOld)
DeskTop:Norton := NortonOld
cKvu := Suder->Kvoy
if pRow <> Nil
   @ pRow+S_wRow(),pCol+S_wCol() say Suder->Naim
End
DbSelectArea(SelectOld)
Return ( tb )
/////////////////////////////////////////////////////////////////////////
Function IndexZp()
Local cFile := "BASE*.Dbf", aFile, i, j, nSumInd, nSumma, lYes
Local  cSvon_, cKmn_, cVo_

if Empty(aFile := Directory(cFile))
   Return ( Nil )
End
nLastRec := Len(aFile)
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую индексацию...."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 wsay nRecno
nRecno := 0
for i := 1 to Len(aFile)
  cFile := aFile[i][1]
  use (cFile) new Alias Base
  Base->(DbGotop())
  While !Base->(eof())
    if Base->Tn <> "******"
       nSumma := 0
       for j := 1 to 12
          cSvon_:= "SVON"+alltrim(str(j,2))
          cVo_  := "VO"+alltrim(str(j,2))
          cKmn_ := "KMN"+alltrim(str(j,2))
          if Base->&cVo_ <> "241"
             nSumma += Base->&cSvon_/100
          else
             Base->&cKmn_ := "  "
             Base->&cSvon_:= 0
             Base->&cVo_  := "  "
          End
       next
       if nSumma > 0
          nSumInd := 0
//          if nSumma <= 73.7
//             nSumInd := Round(nSumma*11.3/100,2)
//          elseif nSumma > 73.7 .and. nSumma <= 147.4
//             nSumInd := Round((nSumma-73.7)*9.0/100,2) + 8.33
//          elseif nSumma > 147.4 .and. nSumma <= 221.1
//             nSumInd := Round((nSumma-147.4)*7.9/100,2) + 14.96
//          else
//             nSumInd := 20.78
//          End
//          if nSumma <= 118.30
//             nSumInd := Round(nSumma*1.4/100,2)
//             if ( nSumma + nSumInd) >= 118.30
//                nSumInd := 118.30 - nSumma
//             End
//          End
          if nSumma < 496
             nSumInd := Round(nSumma*1.8/100,2)
                End
          if  nSumma  >=496
                nSumInd := 8.93
          End

          if nSumInd > 0
            lYes := .f.
            for j := 1 to 12
               cSvon_:= "SVON"+alltrim(str(j,2))
               cKmn_ := "KMN"+alltrim(str(j,2))
               cVo_  := "VO"+alltrim(str(j,2))
               if Base->&cVo_ == "241" .or. empty(Base->&cKmn_)
                  lYes := .t.
                  Base->&cKmn_ := StrZero(Month(sset[121]),2) //"12"
                  Base->&cSvon_:= nSumInd*100
                  Base->&cVo_  := "241"
                  Exit
               End
             Next
             if !lYes
                S_Beep()
                S_Err({"Табельный номер - "+Base->Tn,"Данные не записаны"})
             End
          End
       End
    End
    Base->(DbSkip(1))
  End
  use
  S_Line_N(18,04,65,nLastRec,++nRecno)
Next
S_Beep()
S_Line_N()
DbCloseAll()
return ( nil )
////////////////////////////////////////////////////////////////////////
Function PrnPens()
Local cFile := "BASE*.Dbf", aFile
Local nKol1 := nKol2 := nSum1 :=  nSum3 :=nSum4 := nSum2 := 0, nSumma, i, j
Local cVo_, cSvo_, cDn_, cKmn_, cVo, nSvo, nLastRec, nRecno
BEGIN SEQUENCE

if Empty(aFile := Directory(cFile))
//   Return ( Nil )
End
if !M_Use("SVO",,,,"DBFNTX")  ; break ; End
Set Index to SvoIndex
nLastRec := Len(aFile)
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую справку..."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 wsay nRecno
nRecno := 0
for i := 1 to Len(aFile)
  cFile := aFile[i][1]
  use (cFile) new Alias Base
  Base->(DbGotop())
  While !Base->(eof())
    nSumma := nSum913 := 0
    if Base->Tn <> "******"
        for j := 1 to 12
           cVo_  := "VO"+alltrim(str(j,2))
           cSvo_ := "SVON"+alltrim(str(j,2))
           cDn_  := "DN"+alltrim(str(j,2))
           cKmn_ := "KMN"+alltrim(str(j,2))
           cKu_  := "KU"+alltrim(str(j,2))
           cSKu_ := "SKU"+alltrim(str(j,2))
           cVo   := Base->(&cVo_)
           nSvo  := Base->(&cSvo_)/100
           cKu   := Base->(&cKu_)
           nSKu  := Base->(&cSku_)/100
           if !Empty(cVo) .and. !Empty(nSvo)
               Svo->(DbSeek(cVo))
               if Substr(Svo->Zmo,13,1) == "1"
                 nSumma += nSvo
               End
           End
           if cKu == "913" 
 nSum913 := nSku 
   nSum1 += nSum913
 End
        Next
        if nSumma > 0 .and. nSumma <= 884
           nKol1++
          // nSum1 += nSum913 //Round(nSumma*0.01,2)
           nSum3 += nSumma
        elseif nSumma > 884
           nKol2++
         //  nSum2 += nSum913 // Round(nSumma*0.02,2)
    nSum4 += nSumma   
     End
    End
    Base->(DbSkip(1))
  End
  Base->(DbCloseArea())
  S_Line_N(18,04,65,nLastRec,++nRecno)
Next
S_Line_N()
Set(20,"PRINT")
Set(24,"VedPenc.txt")
nSum3=nSum1/0.02
nSum4=nSum2/0.02
@ prow()+1,00 say " "
@ prow()+1,00 say "         Справка в пенсионный фонд"
@ prow()+1,00 say "             за _____________ "
@ prow()+1,00 say "     -------------------------------------------------------------"
*@ prow()+1,00 say "          0.5%                       :       2%                     "
*@ prow()+1,00 say "     -------------------------------------------------------------"
*@ prow()+1,00 say "     Кол.  : сумма     : сумма       :Кол. : сумма     : сумма      "
*@ prow()+1,00 say "     -------------------------------------------------------------"
*@ prow()+1,00 say space(5)+str(nKol1,5)+" "+str(nSum1,12,2)+":"+str(nSum3,12,2)+":"+;
*                           str(nKol2,5)+" "+str(nSum2,12,2)+" "+str(nSum4,12,2)
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say "Итого "+str(nKol1+nKol2,5)+" "+str((nSum1+nSum2),12,2)+" "+str(nSum3+nSum4,12,2) 
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say ""
Set(24,"")
Set(20,"SCREEN")
ShowPrn("VedPenc.txt","справку",74)
ferase("VedPenc.txt")
END SEQUENCE
DbCloseAll()

return ( nil )
/////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
Function Prncoc()
Local cFile := "BASE*.Dbf", aFile
Local nKol1 := nKol2 := nSum1 :=nSum3 :=nSum4 := nSum2 :=nSum5 := nSum6 := 0, nSumma, i, j
Local cVo_, cSvo_, cDn_, cKmn_, cVo, nSvo, nLastRec, nRecno

if Empty(aFile := Directory(cFile))
   Return ( Nil )
End
if !M_Use("SVO",,,,"DBFNTX")  ; break ; End
Set Index to SvoIndex
nLastRec := Len(aFile)
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую справку..."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 wsay nRecno
nRecno := 0
for i := 1 to Len(aFile)
  cFile := aFile[i][1]
  use (cFile) new Alias Base
  Base->(DbGotop())
  While !Base->(eof())
    nSumma := nSum913 := 0
    if Base->Tn <> "******"
        for j := 1 to 12
           cVo_  := "VO"+alltrim(str(j,2))
           cSvo_ := "SVON"+alltrim(str(j,2))
           cDn_  := "DN"+alltrim(str(j,2))
           cKmn_ := "KMN"+alltrim(str(j,2))
           cKu_  := "KU"+alltrim(str(j,2))
           cSKu_ := "SKU"+alltrim(str(j,2))
           cVo   := Base->(&cVo_)
           nSvo  := Base->(&cSvo_)/100
           cKu   := Base->(&cKu_)
           nSKu  := Base->(&cSku_)/100
           if !Empty(cVo) .and. !Empty(nSvo)
               Svo->(DbSeek(cVo))
               if Substr(Svo->Zmo,19,1) == "1"
                 nSumma += nSvo
               End
           End
           if cKu == "945" .and. nSku  <= 8.69
          nSum913 := nSku  
           nSum1 += nSum913
     End
       if cKu == "945" .and. nSku  > 8.69
          nSum913 := nSku  
           nSum2 += nSum913
     End
   Next
        if nSum5 > 0 .and. nSum5 <= 8.69
           nKol1++
          // nSum1 += nSum5       /////nSum913 //Round(nSumma*0.01,2)
            nSum3 += nSumma
         nSum5 :=0
        elseif nSum5 > 8.69
           nKol2++
//nSum2 += nSum5  ////nSum913 // Round(nSumma*0.02,2)
            nSum4 += nSumma
nSum5 :=0   
End
    End
    Base->(DbSkip(1))
  End
  Base->(DbCloseArea())
  S_Line_N(18,04,65,nLastRec,++nRecno)
Next
S_Line_N()
Set(20,"PRINT")
Set(24,"VedPenc.txt")
 nSum3=nSum1/0.005
   nSum4=nSum2/0.01
@ prow()+1,00 say " "
@ prow()+1,00 say "         Справка в coц фонд"
@ prow()+1,00 say "             за _____________ "
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say "          0.5%                         :       0.1%                     "
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say "     Кол.  : сумма     : сумма       :Кол. : сумма     : сумма      "
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say space(5)+str(nKol1,5)+" "+str(nSum1,12,2)+":"+str(nSum3,12,2)+":"+;
                           str(nKol2,5)+" "+str(nSum2,12,2)+" "+str(nSum4,12,2)
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say "Итого "+str(nKol1+nKol2,5)+" "+str(nSum1+nSum2,12,2)
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say ""
Set(24,"")
Set(20,"SCREEN")
ShowPrn("VedPenc.txt","справку",74)
ferase("VedPenc.txt")
return ( nil )
/////////////////////////////////////////////////////////////////////////
Function PrnBEZ()
Local cFile := "BASE*.Dbf", aFile
Local nKol1 := nKol2 := nSum1 := nSum2 := 0, nSumma, i, j
Local cVo_, cSvo_, cDn_, cKmn_, cVo, nSvo, nLastRec, nRecno

if Empty(aFile := Directory(cFile))
   Return ( Nil )
End
if !M_Use("SVO",,,,"DBFNTX")  ; break ; End
Set Index to SvoIndex
nLastRec := Len(aFile)
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую справку..."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 wsay nRecno
nRecno := 0
for i := 1 to Len(aFile)
  cFile := aFile[i][1]
  use (cFile) new Alias Base
  Base->(DbGotop())
  While !Base->(eof())
    nSumma := nSum913 := 0
    if Base->Tn <> "******"
        for j := 1 to 12
           cVo_  := "VO"+alltrim(str(j,2))
           cSvo_ := "SVON"+alltrim(str(j,2))
           cDn_  := "DN"+alltrim(str(j,2))
           cKmn_ := "KMN"+alltrim(str(j,2))
           cKu_  := "KU"+alltrim(str(j,2))
           cSKu_ := "SKU"+alltrim(str(j,2))
           cVo   := Base->(&cVo_)
           nSvo  := Base->(&cSvo_)/100
           cKu   := Base->(&cKu_)
           nSKu  := Base->(&cSku_)/100
        
      if !Empty(cVo) .and. !Empty(nSvo)
               Svo->(DbSeek(cVo))
               if Substr(Svo->Zmo,11,1) == "1"
                 nSumma += nSvo
               End
           End
           if cKu == "914" 
      nSum913 := nSku 
 nSum1 += nSum913
 End
        Next
        if nSumma > 0 
           nKol1++
      //     nSum1 += nSum913 //Round(nSumma*0.01,2)
       //  ?  nSum1 
         //  wait
          elseif nSumma > 884
           nKol2++
 //          nSum2 += nSum913 // Round(nSumma*0.02,2)
        End
    End
    Base->(DbSkip(1))
  End
  Base->(DbCloseArea())
  S_Line_N(18,04,65,nLastRec,++nRecno)
Next
S_Line_N()
Set(20,"PRINT")
Set(24,"VedPenc.txt")

@ prow()+1,00 say " "
@ prow()+1,00 say "         Справка в фонд безраб "
@ prow()+1,00 say "             за _____________ "
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say "                                        :                                "
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say "     Кол.  : сумма     : сумма       :Кол. : сумма     : сумма      "
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say space(5)+str(nKol1,5)+" "+str(nSum1,12,2)+":"+str(nSum1/0.006,12,2)+":"+;
                           str(nKol2,5)+" "+str(nSum2,12,2)+" "+str(nSum2/0.06,12,2)
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say "Итого "+str(nKol1+nKol2,5)+" "+str(nSum1+nSum2,12,2)
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say ""
Set(24,"")
Set(20,"SCREEN")
ShowPrn("VedPenc.txt","справку",74)
ferase("VedPenc.txt")
return ( nil )
/////////////////////////////////////////////////////////////////////////
Function PrnGEN()
Local cFile := "BASE*.Dbf", aFile
Local nKol1 := nKol2 := nSum1 := nSum2 := 0, nSumma, i, j
Local cVo_, cSvo_, cDn_, cKmn_, cVo, nSvo, nLastRec, nRecno,nStud

if Empty(aFile := Directory(cFile))
   Return ( Nil )
End
if !M_Use("SVO",,,,"DBFNTX")  ; break ; End
Set Index to SvoIndex
nLastRec := Len(aFile)
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую справку..."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 wsay nRecno
nRecno := 0
for i := 1 to Len(aFile)
  cFile := aFile[i][1]
  use (cFile) new Alias Base
  Base->(DbGotop())
  While !Base->(eof())
    nSumma := nSum913 := 0
    if Base->Tn <> "******"
        for j := 1 to 12
           cVo_  := "VO"+alltrim(str(j,2))
           cSvo_ := "SVON"+alltrim(str(j,2))
           cDn_  := "DN"+alltrim(str(j,2))
           cKmn_ := "KMN"+alltrim(str(j,2))
           cKu_  := "KU"+alltrim(str(j,2))
           cSKu_ := "SKU"+alltrim(str(j,2))
           cVo   := Base->(&cVo_)
           nSvo  := Base->(&cSvo_)/100
           cKu   := Base->(&cKu_)
           nSKu  := Base->(&cSku_)/100
          nStud := Base->Stud
    if !Empty(cVo) .and. !Empty(nSvo)
               Svo->(DbSeek(cVo))
   if  nStud ="2"
    nSumma += nSvo

****       nKol1++

              End
           End
        Next
    if cVo_#"216".and.cVo_#"217".and.cVo_#"218".and.cVo_#"221".and.cVo_#"222"
         nSum1 += nSumma
   end
 End
 if  nStud ="2"
    nKol1++
   End
 Base->(DbSkip(1))
  End
  Base->(DbCloseArea())
  S_Line_N(18,04,65,nLastRec,++nRecno)
Next
S_Line_N()
Set(20,"PRINT")
Set(24,"VedPenc.txt")
@ prow()+1,00 say " "
@ prow()+1,00 say "         НАЧИСЛЕННАЯ З\П ЖЕН   "
@ prow()+1,00 say "             за _____________ "
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say "                                        :                                "
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say "     Кол.  : сумма     :             :     :           :            "
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say space(5)+str(nKol1,5)+" "+str(nSum1,12,2)+":"+str(nSum2/0.025,12,2)+":"+;
                           str(nKol2,5)+" "+str(nSum2,12,2)+" "+str(nSum2/0.05,12,2)
@ prow()+1,00 say "     -------------------------------------------------------------"
@ prow()+1,00 say "Итого "+str(nKol1+nKol2,5)+" "+str(nSum1+nSum2,12,2)
@ prow()+1,00 say " "
@ prow()+1,00 say " "
@ prow()+1,00 say ""
Set(24,"")
Set(20,"SCREEN")
ShowPrn("VedPenc.txt","справку",74)
ferase("VedPenc.txt")
return ( nil )
/////////////////////////////////////////////////////////////////////////
Function PackArx()
Local dDataN := dDataK := date(), nDataN, nDataK, nLastRec, nRecno
Local ColorOld := SetColor(), CursorOld := SetCursor()

BEGIN SEQUENCE
if !OpenDbf_("NAKNACH",.t.) ; break ; End
if !OpenDbf_("NAKYD",.t.)   ; break ; End
if !OpenDolg(.t.)           ; break ; End
SetColor(sset[32]+","+sset[2]+",,,"+sset[32])
SetCursor(1)
S_Open_S(12,30,15,72,sset[32]+","+sset[2])
@ 01,01 wsay "Укажите дату начала   " wget dDataN Pict "@d" valid !Empty(dDataN)
@ 02,01 wsay "        дату окончания" wget dDataK Pict "@d" valid dDataK >= dDataN
read
S_wClose()
if LastKey() == K_ESC ; break ; End
nDataN := val(Substr(dtos(dDataN),1,6))
nDataK := val(Substr(dtos(dDataK),1,6))
nLastRec := NakNach->(LastRec()) + NakYd->(LastRec()) + DolgPr->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Удаляю данные..."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
NakNach->(DbGoTop())
While !NakNach->(eof())
   if NakNach->D_Vip >= nDataN .and. NakNach->D_Vip <= nDataK
      NakNach->(Dbdelete())
   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   NakNach->(DbSkip(1))
End
NakYd->(DbGoTop())
While !NakYd->(eof())
   if NakYd->D_Yd >= nDataN .and. NakYd->D_Yd <= nDataK
      NakYd->(Dbdelete())
   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   NakYd->(DbSkip(1))
End
DolgPr->(DbGoTop())
While !DolgPr->(eof())
   if DolgPr->Data >= dDataN .and. DolgPr->Data <= dDataK
      DolgPr->(Dbdelete())
   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   DolgPr->(DbSkip(1))
End
S_Line_N()
S_Sys({"Еще минутку","делаю паковку базы"})
DbSelectArea("NakNach")
Pack
DbSelectArea("NakYd")
pack
DbSelectArea("DolgPr")
pack
S_Sys()
END SEQUENCE
DbCloseAll()
SetColor(ColorOld)
SetCursor(CursorOld)
Return( Nil )
////////////////////////////////////////////////////////////////////////
