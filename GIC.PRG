#include "S_Win.ch"
#include "inkey.ch"
#Define KVO_GKX "926"   // квартплата
#Define KVO_VKX "923"   // вода и канализация
#Define KVO_GAZ "924"   // газ
#Define KVO_EL  "927"   // электроэнергия
#Define KVO_PTC "934"   // тепло
//////////////////////////////////////////////////////////////////////////
Function GicVvod(Par) // ввод удержаний за кои усдуги
Local CursorOld := SetCursor(0)
Local ColorOld := SetColor(), nKey, nRow, tb
Local NortonOld := DeskTop:Norton(), oSumVkx, oSumGkx, oSumGaz, oSumPtc, oSumEl
Local nTn, nKodGkx, nGmGkx, nSumGkx, nKodVkx, nGmVkx, nSumVkx, dData, dZajv_
Local nKodPtc, nGmPtc, nSumPtc, nKodEl, nGmEl, nSumEl, nKodGaz, nGmGaz, nSumGaz

BEGIN SEQUENCE
if !OpenList()  ; break ; End
if Par == Nil
  if !OpenVip()  ; break ; End
  if !OpenArx()  ; break ; End
  if !OpenDolg() ; break ; End
  if !OpenDbf_("Gic")    ; break ; End
  if !OpenDbf_("Zajv")   ; break ; End
  if Zajv->(eof()) .and. M_Append(20,"Zajv")
     Zajv->(DbUnlock())
  End
Else
  if !OpenDbf_("GicArx",,"Gic")     ; break ; End
End

DbSelectArea("Gic")
Set Relation to StrZero(Tn,6) into SUPERLIS
S_Open_S(02,00,22,79,sset[32]+","+sset[2]+",,,"+sset[32])
@ 01,01 wsay "Таб.N   Дата уд.   Фамилия Имя Отчество    │Ком. усл.  Л/счет   м-ц    Сумма"
@ 02,01 wsay Repl("─",MaxCol()-1)
@ 02,44 wsay "┼"
For nKey := 3 to MaxRow()-1
  @ nKey,44 wsay "│"
Next
@ 04,45 wsay "Кв.плата  "
@ 05,45 wsay "Хол.вода  "
@ 06,45 wsay "Гор.вода  "
@ 07,45 wsay "Газ       "
@ 08,45 wsay "Эл.энергия"
@ 09,44 wsay "├"+Repl("─",34)
@ 10,45 wsay "ИТОГО     "
@ 12,45 wsay " N заявл.        от            "
if Par == Nil
   oNortonNew( {{"3Удалить","4Регистр","5Корректи","8Поиск","9Сумма"}} )
else
   oNortonNew( {{"8Поиск"}} )
End
tb := TBrowseDb(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wCol()+43)
tb:AddColumn(TbColumnNew("",{|| str(Gic->Tn,6)+" "+dtoc(Gic->Data)+" "+SuperLis->Fio+"     "} ))
Gic->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := S_Inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   @ 04,55 wsay Gic->KodGkx pict "99999999"
   @ 04,64 wsay Gic->GmGkx  pict "999999"
   @ 04,70 wsay Gic->SumGkx pict "999999.99"
   @ 05,55 wsay Gic->KodVkx pict "99999999"
   @ 05,64 wsay Gic->GmVkx  pict "9999"
   @ 05,70 wsay Gic->SumVkx pict "999999.99"
   @ 06,55 wsay Gic->KodPtc pict "99999999"
   @ 06,64 wsay Gic->GmPtc  pict "9999"
   @ 06,70 wsay Gic->SumPtc pict "999999.99"
   @ 07,55 wsay Gic->KodGaz pict "99999999"
   @ 07,64 wsay Gic->GmGaz  pict "9999"
   @ 07,70 wsay Gic->SumGaz pict "999999.99"
   @ 08,55 wsay Gic->KodEl  pict "99999999"
   @ 08,64 wsay Gic->GmEl   pict "9999"
   @ 08,70 wsay Gic->SumEl  pict "999999.99"
   @ 10,69 wsay Gic->SumGkx+Gic->SumVkx+Gic->SumPtc+Gic->SumGaz+Gic->SumEl pict "9999999.99"   
   @ 12,55 wsay Gic->Zajv   pict "999999"
   @ 12,65 wsay Gic->Dzajv  Pict "@d"
   if nKey == 0 ; nKey := S_InKey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3 .and. Par == Nil .and. !Empty(Gic->tn) // Удаление
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. ;
                                                    M_Rlock(20,"Gic")
                 nSumGkx := Gic->SumGkx
                 nSumVkx := Gic->SumVkx
                 nSumPtc := Gic->SumPtc
                 nSumGaz := Gic->SumGaz
                 nSumEl  := Gic->SumEl
                 nSumVkx := Gic->SumVkx
                 nTn     := Gic->Tn
                 dData   := Gic->Data
                 Gic->(DbDelete())
                 Gic->(DbUnlock())
                 Gic->(DbSkip(1))
                 if Gic->(eof()) ; Gic->(DbGoBottom()) ; end
                 if !Empty(Gic->Data)
                   DelVedArx(nSumGkx,nSumVkx,nSumPtc,nSumGaz,nSumEl,dData,nTn)
                   if DolgPr->(Dbseek(Left(dtos(dData),6)+strZero(nTn,6))) .and. ;
                      M_Rlock(20,"DolgPr")
                      DolgPr->SumVip -= nSumGkx + nSumVkx + nSumPtc + nSumGaz + nSumEl
                      DolgPr->(DbUnlock())
                   End
                 End
           end
           FreshOrder(tb)
       case nKey == K_F4 .and. Par == Nil // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Вводите данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           While ( .t. )
             Scroll(S_wRow()+03,S_wCol()+01,S_wLastRow()-1,S_wCol()+43,-1)
             @ 14,45 wsay "                                 "    
             nTn := nKodGkx := nGmGkx := nSumGkx := nKodGaz := nGmGaz := nSumGaz := 0
             nKodVkx := nGmVkx := nSumVkx := nKodPtc := nGmPtc := nSumptc := 0
             nKodEl  := nGmEl  := nSumEl  := 0
             dData := ctod("")
             dZajv_ := date()
             lYes   := .t.
             @ 03,01 wget nTn pict "999999" valid nTn > 0
             read
             if LastKey() == K_ESC ; Exit ; End
             if !SuperLis->(DbSeek(strZero(nTn,6)))
                S_Beep(1)
                @ 03,19 wsay padr("Табельный отсутствует",25)
                S_inkey(0)
                Loop
             End
             @ 03,19 wsay SuperLis->Fio
             @ 03,08 wget dData pict "@d"
             read
             if LastKey() == K_ESC ; Loop ; End
             fSumma := 0
             if !empty(dData)
                lYes   := .f.
                if DolgPr->(Dbseek(Left(dtos(dData),6)+strZero(nTn,6))) 
                   fSumma := Round(DolgPr->SumDolg - DolgPr->SumVip,2)
                   lYes   := .t.
                elseif S_Err({"Отсутствует сумма","Продолжать?","% Нет ;  Да ;"}) == 1
                   loop
                End
                @ 14,45 say "Сумма остатка равна "+str(fSumma,13,2)
             End
             @ 04,55 wget nKodGkx pict "99999999" valid ( nKodGkx == 0 .or. ;
                                                         nKodGkx > 1000000 )
             read
             if LastKey() == K_ESC ; Loop ; End
             if nKodGkx > 0
                @ 04,64 wget nGmGkx  pict "999999" when !empty(dData) ;
                             valid ( int(nGmGkx/100) > 96 .and. ;
                             mod(nGmGkx,100) >= 01 .and. mod(nGmGkx,100) <= 12 )
                @ 04,70 wget nSumGkx pict "999999.99" valid nSumGkx > 0
                read
                if LastKey() == K_ESC ; Loop ; End
             End
             @ 05,55 wget nKodVkx pict "99999999" valid ( nKodVkx == 0 .or. ;
                                                         nKodVkx > 1000000 )
             read
             if LastKey() == K_ESC ; Loop ; End
             if nKodVkx > 0
                 @ 05,64 wget nGmVkx  pict "999999" when !empty(dData) ;
                             valid (int(nGmVkx/100) > 96 .and. ;
                             mod(nGmVkx,100) >= 01 .and. mod(nGmVkx,100) <= 12 )
                @ 05,70 wget nSumVkx pict "999999.99" valid nSumVkx > 0
                read
                if LastKey() == K_ESC ; Loop ; End
             End              
             @ 06,55 wget nKodPtc pict "99999999" valid ( nKodPtc == 0 .or. ;
                                                         nKodPtc > 1000000 )
             read
             if LastKey() == K_ESC ; Loop ; End
             if nKodPtc > 0
                @ 06,64 wget nGmPtc  pict "9999" when !empty(dData) ;
                             valid (int(nGmPtc/100) > 96 .and. ;
                             mod(nGmPtc,100) >= 01 .and. mod(nGmPtc,100) <= 12 )
                @ 06,70 wget nSumPtc pict "999999.99" valid nSumPtc > 0
                read
                if LastKey() == K_ESC ; Loop ; End
             End              
             @ 07,55 wget nKodGaz pict "99999999" valid nKodGaz >= 0
             read
             if LastKey() == K_ESC ; Loop ; End
             if nKodGaz > 0
                @ 07,64 wget nGmGaz  pict "9999" when !empty(dData) ;
                             valid (int(nGmGaz/100) > 96 .and. ;
                             mod(nGmGaz,100) >= 01 .and. mod(nGmGaz,100) <= 12 )
                @ 07,70 wget nSumGaz pict "999999.99" valid nSumGaz > 0
                read
                if LastKey() == K_ESC ; Loop ; End
             End              
             @ 08,55 wget nKodEl pict "99999999" valid nKodEl >= 0
             read
             if LastKey() == K_ESC ; Loop ; End
             if nKodEl > 0
                @ 08,64 wget nGmEl  pict "9999" when !empty(dData) ;
                             valid (int(nGmEl/100) > 96 .and. ;
                             mod(nGmEl,100) >= 01 .and. mod(nGmEl,100) <= 12 )
                @ 08,70 wget nSumEl pict "999999.99" valid nSumEl > 0
                read
                if LastKey() == K_ESC ; Loop ; End
             End              
             if !Empty(dData) .and. lYes .and. fSumma < Round(nSumGkx + nSumVkx + nSumPtc + nSumGaz + ;
                nSumEl,2) .and. S_Err({"Превышен лимит долга","Продолжать?",;
                                    "%  Нет  ;  Да ;"}) == 1
                       Loop
             End
             @ 10,69 wsay nSumGkx+nSumVkx+nSumPtc+nSumGaz+nSumEl pict "9999999.99"   
             if !Empty(dData)
               nZajv := GetZajv()
               @ 12,55 wsay nZajv  pict "999999"
               @ 12,65 wget dZajv_  Pict "@d" valid !Empty(dZajv_)
               read
               if LastKey() == K_ESC ; Loop ; End
             else
               nZajv := 0
               dZajv_ := ctod("")
             End
             if M_Append(20,"Gic")
               Gic->Tn     := nTn
               Gic->Data   := dData
               Gic->KodGkx := nKodGkx
               Gic->GmGkx  := nGmGkx
               Gic->SumGkx := nSumGkx
               Gic->KodVkx := nKodVkx
               Gic->GmVkx  := nGmVkx
               Gic->SumVkx := nSumVkx
               Gic->KodPtc := nKodPtc
               Gic->GmPtc  := nGmPtc
               Gic->SumPtc := nSumPtc
               Gic->KodGaz := nKodGaz
               Gic->GmGaz  := nGmGaz
               Gic->SumGaz := nSumGaz
               Gic->KodEl  := nKodEl
               Gic->GmEl   := nGmEl
               Gic->SumEl  := nSumEl
               Gic->Zajv   := nZajv
               Gic->Dzajv  := dZajv_
               Gic->(DbUnlock())
               if !Empty(dData)
                AddVedArx(nSumVkx,dData,nTn,KVO_VKX)
                AddVedArx(nSumGkx,dData,nTn,KVO_GKX)
                AddVedArx(nSumPtc,dData,nTn,KVO_PTC)
                AddVedArx(nSumGaz,dData,nTn,KVO_GAZ)
                AddVedArx(nSumEl, dData,nTn,KVO_EL)
                if lYes .and. M_Rlock(20,"DolgPr")
                  DolgPr->SumVip += nSumGkx + nSumVkx + nSumPtc + nSumGaz + nSumEl
                  DolgPr->(DbUnlock())
                End
              End
             End
           End
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)           
           FreshOrder(tb)
       case nKey == K_F5 .and. Par == Nil .and. !Empty(Gic->tn) // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Корректируйте данные [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           SetCursor(1)
           nTn     := Gic->Tn
           dData   := Gic->Data
           nKodGkx := Gic->KodGkx
           nGmGkx  := Gic->GmGkx
           oSumGkx := nSumGkx := Gic->SumGkx
           nKodVkx := Gic->KodVkx
           nGmVkx  := Gic->GmVkx
           oSumVkx := nSumVkx := Gic->SumVkx
           nKodPtc := Gic->KodPtc
           nGmPtc  := Gic->GmPtc
           oSumPtc := nSumPtc := Gic->SumPtc
           nKodGaz := Gic->KodGaz
           nGmGaz  := Gic->GmGaz
           oSumGaz := nSumGaz := Gic->SumGaz
           nKodEl  := Gic->KodEl
           nGmEl   := Gic->GmEl
           oSumEl  := nSumEl := Gic->SumEl
           BEGIN SEQUENCE
           lYes := .f.
           fSumma := 0
           if !empty(dData)
            if DolgPr->(Dbseek(Left(dtos(dData),6)+strZero(nTn,6))) 
                fSumma := Round(DolgPr->SumDolg - DolgPr->SumVip + oSumGkx + oSumVkx + ;
                          oSumPtc + oSumGaz + oSumEl,2)
                lYes   := .t.
            elseif S_Err({"Отсутствует сумма","Продолжать?","% Нет ;  Да ;"}) == 1
                break
            End
            @ 14,45 wsay "Сумма остатка равна "+str(fSumma,13,2)
           End
           @ 04,55 wget nKodGkx pict "99999999" valid ( nKodGkx == 0 .or. ;
                                                         nKodGkx > 1000000 )
           read
           if LastKey() == K_ESC ; break ; End
           if nKodGkx > 0
              @ 04,64 wget nGmGkx  pict "999999" when !empty(dData) ;
                           valid (int(nGmGkx/100) > 96 .and. ;
                           mod(nGmGkx,100) >= 01 .and. mod(nGmGkx,100) <= 12 )
              @ 04,70 wget nSumGkx pict "999999.99" valid nSumGkx > 0
              read
              if LastKey() == K_ESC ; break ; End
           else
              nGmGkx := nSumGkx := 0
           End
           @ 05,55 wget nKodVkx pict "99999999" valid ( nKodVkx == 0 .or. ;
                                                       nKodVkx > 1000000 )
           read
           if LastKey() == K_ESC ; break ; End
           if nKodVkx > 0
              @ 05,64 wget nGmVkx  pict "9999" when !empty(dData) ;
                          valid (int(nGmVkx/100) > 96 .and. ;
                          mod(nGmVkx,100) >= 01 .and. mod(nGmVkx,100) <= 12 )
              @ 05,70 wget nSumVkx pict "999999.99" valid nSumVkx > 0
              read
              if LastKey() == K_ESC ; break ; End
           else
              nGmVkx := nSumVkx := 0            
           End              
           @ 06,55 wget nKodPtc pict "99999999" valid ( nKodPtc == 0 .or. ;
                                                       nKodPtc > 1000000 )
           read
           if LastKey() == K_ESC ; break ; End
           if nKodPtc > 0
              @ 06,64 wget nGmPtc  pict "9999" when !empty(dData) ;
                           valid (int(nGmPtc/100) > 96 .and. ;
                           mod(nGmPtc,100) >= 01 .and. mod(nGmPtc,100) <= 12 )
              @ 06,70 wget nSumPtc pict "999999.99" valid nSumPtc > 0
              read
              if LastKey() == K_ESC ; break ; End
           else
              nGmPtc := nSumPtc := 0
           End
           @ 07,55 wget nKodGaz pict "99999999" valid nKodGaz >= 0
           read
           if LastKey() == K_ESC ; break ; End
           if nKodGaz > 0
              @ 07,64 wget nGmGaz  pict "9999" when !empty(dData) ;
                           valid (int(nGmGaz/100) > 96 .and. ;
                           mod(nGmGaz,100) >= 01 .and. mod(nGmGaz,100) <= 12 )
              @ 07,70 wget nSumGaz pict "999999.99" valid nSumGaz > 0
              read
              if LastKey() == K_ESC ; break ; End
           else
              nGmGaz := nSumGaz := 0
           End
           @ 08,55 wget nKodEl pict "99999999" valid nKodEl >= 0
           read
           if LastKey() == K_ESC ; break ; End
           if nKodEl > 0
              @ 08,64 wget nGmEl pict "9999" when !empty(dData) ;
                           valid (int(nGmEl/100) > 96 .and. ;
                           mod(nGmEl,100) >= 01 .and. mod(nGmEl,100) <= 12 )
              @ 08,70 wget nSumEl pict "999999.99" valid nSumEl > 0
              read
              if LastKey() == K_ESC ; break ; End
           else
              nGmEl := nSumEl := 0
           End
           if !empty(dData) .and. lYes .and. fSumma < Round(nSumGkx + nSumVkx + nSumPtc + nSumGaz + ;
             nSumEl,2) .and. S_Err({"Превышен лимит долга","Продолжать?",;
                          "%  Нет  ;  Да ;"}) == 1
                       break
           End             
           if M_Rlock(20,"Gic")
               Gic->KodGkx := nKodGkx
               Gic->GmGkx  := nGmGkx
               Gic->SumGkx := nSumGkx
               Gic->KodVkx := nKodVkx
               Gic->GmVkx  := nGmVkx
               Gic->SumVkx := nSumVkx
               Gic->KodPtc := nKodPtc
               Gic->GmPtc  := nGmPtc
               Gic->SumPtc := nSumPtc
               Gic->KodGaz := nKodGaz
               Gic->GmGaz  := nGmGaz
               Gic->SumGaz := nSumGaz
               Gic->KodEl  := nKodEl
               Gic->GmEl   := nGmEl
               Gic->SumEl  := nSumEl
               Gic->(DbUnlock())
               if !Empty(dData)
                 DelVedArx(oSumGkx,oSumVkx,oSumPtc,oSumGaz,oSumEl,dData,nTn)
                 AddVedArx(nSumGkx,dData,nTn,KVO_GKX)
                 AddVedArx(nSumVkx,dData,nTn,KVO_VKX)
                 AddVedArx(nSumPtc,dData,nTn,KVO_PTC)
                 AddVedArx(nSumGaz,dData,nTn,KVO_GAZ)
                 AddVedArx(nSumEl, dData,nTn,KVO_EL)
                 if lYes .and. M_Rlock(20,"DolgPr")
                      DolgPr->SumVip -= ( nSumGkx + nSumVkx + nSumPtc + nSumGaz + nSumEl )
                      DolgPr->SumVip += ( oSumGkx + oSumVkx + oSumPtc + oSumGaz + oSumEl )
                      DolgPr->(DbUnlock())
                 End
              End
           End
           END SEQUENCE
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)
           @ 14,45 wsay "                                 "    
           FreshOrder(tb)
       case nKey == K_F8  // Поиск
           nKey := SaveScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1)
           @ S_wLastRow(),S_wCol()+01 say padc("Укажите табельный номер [ESC - отказ]",S_wMaxCol()-1) color sset[15]
           nTn := 0
           @ 03,01 wsay space(43)
           @ 03,08 wsay "<---- Табельный номер для поиска"
           nRow := Gic->(Recno())
           SetCursor(1)
           BEGIN SEQUENCE
           @ 03,01 wget nTn pict "999999" valid nTn > 0
           read
           if LastKey() == K_ESC ; break ; End
           if !Gic->(DbSeek(str(nTn,6)))
             S_Beep(1)
             @ 03,08 wsay " Табельный номер отсутствует    "
             S_Inkey(0)
             Gic->(DbGoTo(nRow))
           End           
           END SEQUENCE
           SetCursor(0)
           RestScreen(S_wLastRow(),S_wCol()+01,S_wLastRow(),S_wLastCol()-1,nKey)           
           FreshOrder(tb)
       case nKey == K_F9 .and. Par == Nil // Сумма
           S_Sys({"Минутку"," Идет подсчет суммы"})
           nSumGkx := nSumVkx := nSumPtc := nSumGaz := nSumEl := 0
           nKey := Gic->(Recno())
           Gic->(DbGoTop())
           While !Gic->(eof())
              nSumGkx += Gic->SumGkx
              nSumVkx += Gic->SumVkx
              nSumPtc += Gic->SumPtc
              nSumGaz += Gic->SumGaz
              nSumEl  += Gic->SumEl
              Gic->(DbSkip(1))
          End
          Gic->(DbGoTo(nKey))
          S_Sys()
          S_Err({"Сумма удержаний составляет:",;
                 " в ПУЖКХ  - "+str(nSumGkx,15,2),;
                 " в ПУBКХ  - "+str(nSumVkx,15,2),;
                 " в ПМПТС  - "+str(nSumPtc,15,2),;
                 " в ГОРГАЗ - "+str(nSumGaz,15,2),;
                 " в ЭНЕРГО - "+str(nSumEl,15,2),;
                 "---------------------------",;
                 " ВСЕГО   - "+str(nSumGkx+nSumVkx+nSumPtc+nSumGaz+nSumEl,15,2)})
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
///////////////////////////////////////////////////////////////////////
Static Func AddVedArx(nSumma,dData,nTn,cKvo)

if nSumma > 0 .and. M_Append(20,"VedArx")
   VedArx->NumVed  := 0
   VedArx->DataV   := S_eom(sset[121])
   VedArx->Data    := dData
   VedArx->Ksp     := SuperLis->Ksp
   VedArx->Tn      := strzero(nTn,6)
   VedArx->SumKVip := nSumma
   VedArx->Kvu     := cKvo
   VedArx->(DbUnlock())
End
    if nSumma  > 0 .and. M_Append(20,"VipZap")
      VipZap->Ksp := SUPERLIS->Ksp
      VipZap->Tnr := strzero(nTn,6)
      VipZap->Summa :=  nSumma
      VipZap->Data  := dData
      VipZap->(DbUnlock())
    End
Return ( Nil )
///////////////////////////////////////////////////////////////////////
Static Func DelVedArx(nSumGkx,nSumVkx,nSumPtc,nSumGaz,nSumEl,dData,nTn)

if VedArx->(DbSeek(strzero(nTn,6)+dtos(dData)))
   While VedArx->Tn == strzero(nTn,6) .and. VedArx->Data == dData ;
                          .and. !VedArx->(eof())
       if ( ( VedArx->SumKVip == nSumVkx .and. ;
              VedArx->NumVed == 0 .and. ;
              VedArx->Data  == dData .and. ;
              VedArx->Kvu == KVO_VKX .and. ;
              VedArx->DataV  == S_eom(sset[121]) ) .or. ;
            ( VedArx->SumKVip == nSumGkx .and. ;
              VedArx->NumVed == 0 .and. ;
              VedArx->Data  == dData .and. ;
              VedArx->Kvu == KVO_GKX .and. ;
              VedArx->DataV  == S_eom(sset[121]) ) .or. ;
            ( VedArx->SumKVip == nSumPtc .and. ;
              VedArx->NumVed == 0 .and. ;
              VedArx->Data  == dData .and. ;
              VedArx->Kvu == KVO_PTC .and. ;
              VedArx->DataV  == S_eom(sset[121]) ) .or. ;
            ( VedArx->SumKVip == nSumGaz .and. ;
              VedArx->NumVed == 0 .and. ;
              VedArx->Data  == dData .and. ;
              VedArx->Kvu == KVO_GAZ .and. ;
              VedArx->DataV  == S_eom(sset[121]) ) .or. ;
            ( VedArx->SumKVip == nSumEL .and. ;
              VedArx->NumVed == 0 .and. ;
              VedArx->Data  == dData .and. ;
              VedArx->Kvu == KVO_EL .and. ;
              VedArx->DataV  == S_eom(sset[121]) ) )  .and.  M_Rlock(20,"VedArx")
            VedArx->(DbDelete())
            VedArx->(DbUnlock())
       End
       VedArx->(DbSkip(1))
   End
 End
Return ( Nil )
///////////////////////////////////////////////////////////////////////
Static Function GetZajv() // Получение номера заявления
Local i := 0
if M_Rlock(20,"Zajv")
   i := Zajv->Zajv + 1
   Zajv->Zajv := i
   Zajv->(DbUnlock())
End
Return ( i )
///////////////////////////////////////////////////////////////////////
Function GicArx() // Архивирование информации
Local i, nLastRec, nRecno, dData := sset[121]

if S_Err({"Вы действительно желаите",;
          "сделать архивирование ",;
          "удержаний за коммунальные услуги",;
          "за текущий месяц",;
          "и не пожалеите об этом?",;
          "%  Нет  ;  Да  ;"}) == 1
  Return ( Nil )
End
BEGIN SEQUENCE
if !OpenList()                ; break ; End
if !OpenDbf_("GicArx",,"Arx") ; break ; End
if !OpenDbf_("Gic",.t.)       ; break ; End

DbSelectArea("Gic")
nLastRec := Gic->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Архивирую...."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Gic->(DbGoTop())
While !Gic->(eof())
   if !Empty(Gic->Data) .and. left(dtos(Gic->Data),6) <> left(dtos(dData),6)
     if M_Append(20,"Arx")
        For i := 1 to Arx->(Fcount())
          Arx->(FieldPut(i,Gic->(FieldGet(i))))
        Next
        Arx->(DbUnlock())
        Gic->(DbDelete())
     End
   else
      AddInf(dData)
   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   Gic->(DbSkip(1))
End
S_Line_N()
S_Beep(3)
S_Sys({"Еще минутку....","Пакую базу"})
Pack
S_Sys()
DbCloseAll()
fErase("Gic.Ntx")
END SEQUENCE
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Static Function AddInf(Data)
Local SelectOld := Select(), cTnr := strzero(Gic->Tn,6)
Local j, cKsp, nRec, cSym

if SuperLis->(DbSeek(cTnr))
  cKsp := SuperLis->Ksp        // Код подразделения
  nRec := SuperLis->Base_Rec   // No записи в BASE
  cSym := "Base"+cKsp
  Use (cSym) new alias Base
  Base->(DbGoto(nRec))
  if Gic->SumGkx > 0 ; AddRec(Data,KVO_GKX,Gic->SumGkx) ; End
  if Gic->SumVkx > 0 ; AddRec(Data,KVO_VKX,Gic->SumVkx) ; End
  if Gic->SumGaz > 0 ; AddRec(Data,KVO_GAZ,Gic->SumGaz) ; End
  if Gic->SumPtc > 0 ; AddRec(Data,KVO_PTC,Gic->SumPtc) ; End
  if Gic->SumEl > 0  ; AddRec(Data,KVO_EL, Gic->SumEl)  ; End
  Base->(DbCloseArea())
  DbSelectArea(SelectOld)
End
Return ( Nil )
//////////////////////////////////////////////////////////////////////
Static Function AddRec(Data,Kvo,Summa)
Local lYes := .f., i, Jm, cVo, cSvon, cKmn

for j := 1 to 12
    jm := Alltrim(str(j,2))
    cVo := "Ku"+jm
    if empty(Base->&cVo) //.or. Base->&cVo == Kvo
       lYes := .t.
       Base->&cVo  := Kvo
       cSvon := "Sku"+jm
       Base->&cSvon := Summa*100
       cKmn := "Kmu"+jm
       Base->&cKmn := StrZero(month(Data),2)
       Exit
    End
Next
if !lYes
    S_Err({"Табельный номер - "+str(Gic->Tn,6),"Данные не записаны по "+Kvo})
End
Return ( Nil )
//////////////////////////////////////////////////////////////////
Function GicPrn() // Формирование информации для передачи в КП
Local cPref := Substr(dtos(S_eom(sset[121])),3,6)
Local cFileWk := "GicPrn"
Local cFileZp, cFileGkx, cFileVkx, nSumGkx := nSumVkx := 0
Local oFileGkx, oFileVkx, oFilePtc, oFileGaz, oFileEl
Local nSumPtc := nSumGaz := nSumEl := 0, cFileGaz, cFilePtc, cFileEl
Private aKvo := {}

cFileGkx := "CC"+cPref
cFileVkx := "CK"+cPref
cFileGaz := "CG"+cPref
cFilePtc := "CB"+cPref
cFileEl  := "CE"+cPref
oFileGkx := oFileNew(cFileGkx+".txt")  ; oFileGkx:Open()
oFileVkx := oFileNew(cFileVkx+".Txt")  ; oFileVkx:Open()
oFilePtc := oFileNew(cFilePtc+".Txt")  ; oFilePtc:Open()
oFileGaz := oFileNew(cFileGaz+".Txt")  ; oFileGaz:Open()
oFileEl  := oFileNew(cFileEl+".Txt")   ; oFileEl:Open()
ferase(cFileGkx+".Dbf")
fErase(cFileVkx+".Dbf")
fErase(cFilePtc+".Dbf")
fErase(cFileGaz+".Dbf")
fErase(cFileWk+".Dbf")
fErase(cFileWk+".Ntx")
BEGIN SEQUENCE
DbCreate(cFileWk,{ {"Data", "D",08,00},;
                   {"Tnr",  "N",06,00},;
                   {"Kvo",  "C",03,00},;
                   {"Summa","N",15,02} })
if !M_Use(cFileWk,.t.,"Work") ; break ; end
Index on dtos(Data)+Kvo+str(Tnr,6) to (cFileWk)
//
DbCreate(cFileGkx,{ {"Bank",  "C",09,00},;
                    {"DatO",  "D",08,00},;
                    {"Fail",  "C",08,00},;
                    {"Npl",   "N",04,00},;
                    {"Nfil",  "N",04,00},;
                    {"KodLc", "N",08,00},;
                    {"SumGaz","N",15,02},;
                    {"SumEl", "N",15,02},;
                    {"KolEl", "N",05,00},;
                    {"RcNac", "N",05,00},;
                    {"RcKon", "N",05,00},;
                    {"SumPr", "N",15,02},;
                    {"SumKw", "N",15,02},;
                    {"Gmab",  "N",06,00},;
                    {"GmEl",  "N",04,00},;
                    {"PrizUp","N",01,00} })
DbCreate(cFileVkx,{ {"Bank",  "C",09,00},;
                    {"DatO",  "D",08,00},;
                    {"Fail",  "C",08,00},;
                    {"Npl",   "N",04,00},;
                    {"Nfil",  "N",04,00},;
                    {"KodLc", "N",08,00},;
                    {"SumGaz","N",15,02},;
                    {"KolEl", "N",05,00},;
                    {"RcKon", "N",05,00},;
                    {"SumPr", "N",15,02},;
                    {"GmAb",  "N",04,00},;
                    {"SumKw", "N",15,02},;
                    {"PrizUp","N",01,00} })
DbCreate(cFilePtc,{ {"Bank",  "C",09,00},;
                    {"DatO",  "D",08,00},;
                    {"Npl",   "N",04,00},;
                    {"Fail",  "C",08,00},;
                    {"KodLc", "N",08,00},;
                    {"SumGaz","N",15,02},;
                    {"SumPr", "N",15,02},;
                    {"GmAb",  "N",04,00},;
                    {"SumKw", "N",15,02} })
DbCreate(cFileGaz,{ {"Bank",  "C",09,00},;
                    {"DatO",  "D",08,00},;
                    {"Fail",  "C",08,00},;
                    {"Npl",   "N",04,00},;
                    {"Nfil",  "N",04,00},;
                    {"KodLc", "N",08,00},;
                    {"SumGaz","N",15,02},;
                    {"KolEl", "N",05,00},;
                    {"SumEl", "N",15,02},;
                    {"RcNac", "N",05,00},;
                    {"SumPr", "N",15,02},;
                    {"GmAb",  "N",04,00},;
                    {"SumKw", "N",15,02},;
                    {"DatPer","D",08,00},;
                    {"SumPer","N",15,02},;
                    {"SumSbor","N",15,02},;
                    {"KodPl", "C",01,00},;
                    {"PrizUp","N",01,00} })
if !M_Use(cFileGkx,.t.,"Gkx") ; break ; end
if !M_Use(cFileVkx,.t.,"Vkx") ; break ; end
if !M_Use(cFilePtc,.t.,"Ptc") ; break ; end
if !M_Use(cFileGaz,.t.,"Gaz") ; break ; end
if !OpenList()      ; break ; End
if !OpenUder()      ; break ; End
if !OpenDbf_("Gic") ; break ; End

DbSelectArea("Gic")
Set Relation to StrZero(Tn,6) into SUPERLIS
nLastRec := Gic->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "Ожидайте..."
@ 01,42 wsay "Формирую ведомости...."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := nppGkx := nppVkx := nppPtc := nppGaz := nppEl := 0
Gic->(DbGoTop())
dDato := S_eom(sset[121])
oFileGkx:WriteLn( "              Список                                                        Список " )
oFileGkx:WriteLn( "         Работников ПУЖКХ                                               Работников ПУЖКХ " )
oFileGkx:WriteLn( "    на удержанние из заработной платы                                на удержанние из заработной платы" )
oFileGkx:WriteLn( "           за квартплату                                                  за квартплату " )
oFileGkx:WriteLn( "     в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года"+space(30)+;
                  "     в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года" )
//
oFileVkx:WriteLn( "                 Список                                                        Список " )
oFileVkx:WriteLn( "             Работников ПУЖКХ                                               Работников ПУЖКХ " )
oFileVkx:WriteLn( "      на удержанние из заработной платы                                на удержанние из заработной платы" )
oFileVkx:WriteLn( "        за холодную воду и канализацию                                  за холодную воду и канализацию " )
oFileVkx:WriteLn( "     в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года"+space(30)+;
                  "     в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года" )
//
oFilePtc:WriteLn( "                 Список                                                        Список " )
oFilePtc:WriteLn( "             Работников ПУЖКХ                                               Работников ПУЖКХ " )
oFilePtc:WriteLn( "      на удержанние из заработной платы                                на удержанние из заработной платы" )
oFilePtc:WriteLn( "        за горячую воду и отопление                                        за горячую воду и отопление " )
oFilePtc:WriteLn( "     в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года"+space(30)+;
                  "     в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года" )
//
oFileGaz:WriteLn( "                 Список                                                        Список " )
oFileGaz:WriteLn( "             Работников ПУЖКХ                                               Работников ПУЖКХ " )
oFileGaz:WriteLn( "      на удержанние из заработной платы                                на удержанние из заработной платы" )
oFileGaz:WriteLn( "                 за газ                                                        за газ " )
oFileGaz:WriteLn( "     в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года"+space(30)+;
                  "     в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года" )
//
oFileEl:WriteLn( "                 Список                                                        Список " )
oFileEl:WriteLn( "             Работников ПУЖКХ                                               Работников ПУЖКХ " )
oFileEl:WriteLn( "      на удержанние из заработной платы                                на удержанние из заработной платы" )
oFileEl:WriteLn( "              за электроэнергию                                              за электроэнергию " )
oFileEl:WriteLn( "     в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года"+space(30)+;
                  "     в "+S_cMonth(dDato)+" месяце "+str(year(dDato),4)+" года" )
//
nLineGkx := nLineVkx := nLinePtc := nLineGaz := nLineEl := 5
nPageGkx := nPageVkx := nPagePtc := nPageGaz := nPageEl := 0
While !Gic->(eof())
   GicData  := if(!Empty(Gic->Data),Gic->Data,dDato)
   AddWork(GicData)
   if Gic->SumGkx > 0
      AddKvo(GicData,KVO_GKX,Gic->SumGkx)
      GicGmGkx := if(!Empty(Gic->GmGkx),Gic->GmGkx,Val(Substr(dtos(dDato),3,4)))
      Gkx->(DbAppend())
      Gkx->Bank := "ПУЖКХ"
      Gkx->Dato := dDato
      Gkx->Fail := cFileGkx
      Gkx->KodLc:= Gic->KodGkx
      Gkx->SumGaz := Gic->SumGkx
      Gkx->SumKw  := Gic->SumGkx
      Gkx->GmAb   := GicGmGkx
      PutKm(oFileGkx, str(++nppGkx,3)+" "+str(Gic->KodGkx,8)+" "+;
                      SuperLis->Fio+" "+str(GicGmGkx,4)+" "+;
                      str(Gic->SumGkx,9,2)+"        "+;
                        str(nppGkx,3)+" "+str(Gic->Zajv,6)+" "+;
                        Substr(dtoc(GicData),4)+" "+str(Gic->Tn,6)+" "+;
                        SuperLis->Fio+" "+str(Gic->KodGkx,8)+" "+;
                        str(Gic->SumGkx,9,2),;
            @nLineGkx, @nPageGkx )
      nSumGkx += Gic->SumGkx
   End
   if Gic->SumVkx > 0
      AddKvo(GicData,KVO_VKX,Gic->SumVkx)
      GicGmVkx := if(!Empty(Gic->GmVkx),Gic->GmVkx,Val(Substr(dtos(dDato),3,4)))
      Vkx->(DbAppend())
      Vkx->Bank := "ПУЖКХ"
      Vkx->Dato := dDato
      Vkx->Fail := cFileVkx
      Vkx->KodLc:= Gic->KodVkx
      Vkx->SumGaz := Gic->SumVkx
      Vkx->SumKw  := Gic->SumVkx
      Vkx->GmAb   := GicGmVkx
      PutKm(oFileVkx, str(++nppVkx,3)+" "+str(Gic->KodVkx,8)+" "+;
                      SuperLis->Fio+" "+str(GicGmVkx,4)+" "+;
                      str(Gic->SumVkx,9,2)+"        "+;
                        str(nppVkx,3)+" "+str(Gic->Zajv,6)+" "+;
                        Substr(dtoc(GicData),4)+" "+str(Gic->Tn,6)+" "+;
                        SuperLis->Fio+" "+str(Gic->KodVkx,8)+" "+;
                        str(Gic->SumVkx,9,2),;
             @nLineVkx, @nPageVkx )
      nSumVkx += Gic->SumVkx
   End
   if Gic->SumPtc > 0
      AddKvo(GicData,KVO_PTC,Gic->SumPtc)
      GicGmPtc := if(!Empty(Gic->GmPtc),Gic->GmPtc,Val(Substr(dtos(dDato),3,4)))
      Ptc->(DbAppend())
      Ptc->Bank := "ПУЖКХ"
      Ptc->Dato := dDato
      Ptc->Fail := cFilePtc
      Ptc->KodLc:= Gic->KodPtc
      Ptc->SumGaz := Gic->SumPtc
      Ptc->SumKw  := Gic->SumPtc
      Ptc->GmAb   := GicGmPtc
      PutKm(oFilePtc, str(++nppPtc,3)+" "+str(Gic->KodPtc,8)+" "+;
                      SuperLis->Fio+" "+str(GicGmPtc,4)+" "+;
                      str(Gic->SumPtc,9,2)+"        "+;
                        str(nppPtc,3)+" "+str(Gic->Zajv,6)+" "+;
                        Substr(dtoc(GicData),4)+" "+str(Gic->Tn,6)+" "+;
                        SuperLis->Fio+" "+str(Gic->KodPtc,8)+" "+;
                        str(Gic->SumPtc,9,2),;
             @nLinePtc, @nPagePtc )
      nSumPtc += Gic->SumPtc
   End
   if Gic->SumEl > 0
      AddKvo(GicData,KVO_EL,Gic->SumEl)
      GicGmEl := if(!Empty(Gic->GmEl),Gic->GmEl,Val(Substr(dtos(dDato),3,4)))
      PutKm(oFileEl, str(++nppEl,3)+" "+str(Gic->KodEl,8)+" "+;
                     SuperLis->Fio+" "+str(GicGmEl,4)+" "+;
                     str(Gic->SumEl,9,2)+"        "+;
                       str(nppEl,3)+" "+str(Gic->Zajv,6)+" "+;
                       Substr(dtoc(GicData),4)+" "+str(Gic->Tn,6)+" "+;
                       SuperLis->Fio+" "+str(Gic->KodEl,8)+" "+;
                       str(Gic->SumEl,9,2),;
             @nLineEl, @nPageEl )
      nSumEl += Gic->SumEl
   End
   if Gic->SumGaz > 0
      AddKvo(GicData,KVO_GAZ,Gic->SumGaz)
      GicGmGaz := if(!Empty(Gic->GmGaz),Gic->GmGaz,Val(Substr(dtos(dDato),3,4)))
      Gaz->(DbAppend())
      Gaz->Bank := "ПУЖКХ"
      Gaz->Dato := dDato
      Gaz->Fail := cFileGaz
      Gaz->KodLc:= Gic->KodGaz
      Gaz->SumGaz := Gic->SumGaz
      Gaz->SumKw  := Gic->SumGaz
      Gaz->GmAb   := GicGmGaz
      PutKm(oFileGaz, str(++nppGaz,3)+" "+str(Gic->KodGaz,8)+" "+;
                      SuperLis->Fio+" "+str(GicGmGaz,4)+" "+;
                      str(Gic->SumGaz,9,2)+"        "+;
                        str(nppGaz,3)+" "+str(Gic->Zajv,6)+" "+;
                        Substr(dtoc(GicData),4)+" "+str(Gic->Tn,6)+" "+;
                        SuperLis->Fio+" "+str(Gic->KodGaz,8)+" "+;
                        str(Gic->SumGaz,9,2),;
             @nLineGaz, @nPageGaz )
      nSumGaz += Gic->SumGaz
   End
//   if Empty(Gic->Data)
//      ZapInf()
//   End
   S_Line_N(18,04,65,nLastRec,++nRecno)
   Gic->(DbSkip(1))
End
CloseVed(oFileGkx,nSumGkx,nLineGkx)
CloseVed(oFileVkx,nSumVkx,nLineVkx)
CloseVed(oFilePtc,nSumPtc,nLinePtc)
CloseVed(oFileGaz,nSumGaz,nLineGaz)
CloseVed(oFileEl, nSumEl, nLineEl)
//
S_Line_N()
S_Beep(3)

if nSumGkx > 0
   ShowPrn(cFileGkx+".txt","Ведомость в ПУЖКХ",74)
   fErase(cFileGkx+".txt")
else
   fErase(cFileGkx+".Dbf")
   fErase(cFileGkx+".txt")
End
if nSumVkx > 0
   ShowPrn(cFileVkx+".txt","Ведомость в ПУВКХ",74)
   fErase(cFileVkx+".txt")
else
   fErase(cFileVkx+".Dbf")
   fErase(cFileVkx+".txt")
End
if nSumPtc > 0
   ShowPrn(cFilePtc+".txt","Ведомость в ПМПТС",74)
   fErase(cFilePtc+".txt")
else
   fErase(cFilePtc+".Dbf")
   fErase(cFilePtc+".txt")
End
if nSumGaz > 0
   Gaz->(DbGoTop())
   While !Gaz->(Eof())
     Gaz->DatPer := dDato
     Gaz->SumPer := nSumGaz
     Gaz->(DbSkip(1))
   End
   ShowPrn(cFileGaz+".txt","Ведомость в ГорГаз",74)
   fErase(cFileGaz+".txt")
else
   fErase(cFileGaz+".Dbf")
   fErase(cFileGaz+".txt")
End
if nSumEl > 0
   ShowPrn(cFileEl+".txt","Ведомость в ЭНЕРГО",74)
   fErase(cFileEl+".txt")
else
   fErase(cFileEl+".txt")
End
DbSelectArea("Work")
Set Relation to StrZero(Tnr,6) into SUPERLIS
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
nLen := 71
@ prow()+1,00 say padc("Ведомость",nLen)
@ prow()+1,00 say padc("на удержанние из заработной платы",nLen)
@ prow()+1,00 say padc("за коммунальные услуги",nLen)
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
                         str(Work->Tnr,6)+" "+SuperLis->Fio+" "+;
                         Work->Kvo+" "+Suder->Naim+" "+;
                         str(Work->Summa,15,2)
       cSumma += Work->Summa
       S_Line_N(18,04,65,nLastRec,++nRecno)
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
if Len(aKvo) > 0
   @ prow()+1,00 say padl("         В том числе по видам оплат:           ",nLen)
   @ prow()+1,00 say padl("-----------------------------------------------",nLen)
   @ prow()+1,00 say padl("Вид удержания      Из задолж.     Тек. месяц   ",nLen)
   @ prow()+1,00 say padl("-----------------------------------------------",nLen)
   nLineGkx := nLineVkx := 0
   for dSumma := 1 to Len(aKvo)
      nSumma := space(15)
      if aKvo[dSumma][1] == KVO_GKX
         nSumma := "Квартплата     "
      elseif aKvo[dSumma][1] == KVO_VKX
         nSumma := "Холодная вола  "
      elseif aKvo[dSumma][1] == KVO_PTC
         nSumma := "Горячая вода   "
      elseif aKvo[dSumma][1] == KVO_GAZ
         nSumma := "Газ            "
      elseif aKvo[dSumma][1] == KVO_EL
         nSumma := "Электроэнергия "
      End
      @ prow()+1,00 say padl(nSumma+" "+str(aKvo[dSumma][2],15,2)+" "+;
                                        str(aKvo[dSumma][3],15,2),nLen)
      nLineGkx += aKvo[dSumma][2]
      nLineVkx += aKvo[dSumma][3]
   Next
   @ prow()+1,00 say padl("-----------------------------------------------",nLen)
   @ prow()+1,00 say padl("  ИТОГО         "+str(nLineGkx,15,2)+" "+;
                                             str(nLineVkx,15,2),nLen)
   @ prow()+1,00 say " "
End
@ prow()+1,00 say ""
S_Beep()
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn(cFileWk+".txt","Ведомость удержаний за комуслуги",74)
DbCloseAll()
S_Err({"Сформированы файлы для передачи:",;
       iif(nSumGkx > 0,"в ПУЖКХ  - "+cFileGkx+".dbf",""),;
       iif(nSumPtc > 0,"в ПМПТС  - "+cFilePtc+".dbf",""),;
       iif(nSumGaz > 0,"в ГорГаз - "+cFileGaz+".dbf",""),;
       iif(nSumVkx > 0,"в ПУВКХ  - "+cFileVkx+".dbf","")})
END SEQUENCE
DbCloseAll()
fErase(cFileWk+".Dbf")
fErase(cFileWk+".Ntx")
fErase(cFileWk+".Txt")
Return ( Nil )
///////////////////////////////////////////////////////////////////////
Static Function AddKvo(pData,pKvo,pSumma)
Local nPos
if ( nPos := ascan(aKvo,{|x| x[1] == pKvo } ) ) == 0
   aadd(aKvo,{pKvo,0,0})
   nPos := len(aKvo)
End
if Left(dtos(pData),6) == Left(dtos(sset[121]),6)
   aKvo[nPos][3] += pSumma    
else
   aKvo[nPos][2] += pSumma    
End
Return ( Nil )   
///////////////////////////////////////////////////////////////////////
Static Function PutKm(oFile,cLine,nLine,nPage)
Local i
if nPage == 0 .or. nLine > 64
   if nLine > 64
     For i := nLine to 67
        oFile:WriteLn( " " )
     Next
     oFile:WriteLn( Repl(".",60) )
     nLine := 0
   End
   oFile:WriteLn( " Лист# "+str(++nPage,3) )
   oFile:WriteLn( "-------------------------------------------------       ------------------------------------------------------------------" )
   oFile:WriteLn( "Nпп|  Л/с   |Фио плательщика     |м-ц | сумма   |       Nпп|N заяв| Дата  |Таб.N |Фио плательщика     |  Л/с   | сумма   |" )
   oFile:WriteLn( "-------------------------------------------------       ------------------------------------------------------------------" )
   nLine += 4
End
oFile:WriteLn( cLine )
nLine++
Return ( Nil )
//////////////////////////////////////////////////////////////////////
Static Function CloseVed(oFile,nSumma,nLine)
Local i
oFile:WriteLn( "-------------------------------------------------       ------------------------------------------------------------------" )
oFile:WriteLn( padr("   Итого",38)+" "+str(nSumma,9,2)+"        "+;
               padr("   Итого",55)+" "+str(nSumma,9,2) )
oFile:WriteLn( "  " )
oFile:WriteLn( "  " )
oFile:WriteLn( "  Начальник ПУЖКХ                 Павленко В.Н.            Начальник ПУЖКХ               Павленко В.Н." )
oFile:WriteLn( "  " )
oFile:WriteLn( "  Главный бухгалтер               Бордунова В.П.         Главный бухгалтер               Бордунова В.П." )
For i := nLine+7 to 64
  oFile:WriteLn( "  " )
Next
oFile:WriteLn("")
oFile:close()
Return ( Nil )
///////////////////////////////////////////////////////////////////////
Static Function AddWork(Data)
if Gic->SumGkx > 0
   Work->(DbAppend())
   Work->Data := Data
   Work->Tnr  := Gic->Tn
   Work->Kvo  := KVO_GKX
   Work->Summa:= Gic->SumGkx
End
if Gic->SumVkx > 0
   Work->(DbAppend())
   Work->Data := Data
   Work->Tnr  := Gic->Tn
   Work->Kvo  := KVO_VKX
   Work->Summa:= Gic->SumVkx
End
if Gic->SumGaz > 0
   Work->(DbAppend())
   Work->Data := Data
   Work->Tnr  := Gic->Tn
   Work->Kvo  := KVO_GAZ
   Work->Summa:= Gic->SumGaz
End
if Gic->SumPtc > 0
   Work->(DbAppend())
   Work->Data := Data
   Work->Tnr  := Gic->Tn
   Work->Kvo  := KVO_PTC
   Work->Summa:= Gic->SumPtc
End
if Gic->SumEl > 0
   Work->(DbAppend())
   Work->Data := Data
   Work->Tnr  := Gic->Tn
   Work->Kvo  := KVO_EL
   Work->Summa:= Gic->SumEl
End
Return ( Nil )
///////////////////////////////////////////////////////////////////////
Function PrnZajv()
Local ColorOld := SetColor(sset[32]+","+sset[2])
Local nKolEkz := 1, i, Par
Local CursorOld := SetCursor(1), GetList := {}

S_Open_S(12,38,14,65,sset[32]+","+sset[2])
@ 01,01 wsay "Кол-во экземпляров" wget nKolEkz Pict "99" valid nKolEkz >= 0
read
SetColor(ColorOld)
SetCursor(CursorOld)
S_wClose()
if LastKey() == K_ESC ; Return ( Nil ) ; End
Bum := S_Err({" Укажите тип бумаги в принтере: ","% широкая  ;  узкая ;"})

BEGIN SEQUENCE
S_Sys({" Следите за бумагой и принтером"})
Set Device to Print
if Bum == 1
    nKolEkz := int(nKolEkz/3) + iif(mod(nKolEkz,3)==0,0,1)
    @ prow()+1,00 say chr(15)
End
for i := 1 to nKolEkz
  PrnLine(" ",Bum)
  PrnLine("                                   Начальнику Первомайского ПУЖКХ   ",Bum)
  PrnLine("                                   от ______________________________",Bum)
  PrnLine("                                   __________________________________",Bum)
  PrnLine(" ",Bum)
  PrnLine("                                   табельный номер ________",Bum)
  PrnLine(" ",Bum)
  PrnLine("                                   Рег.N __________ От ____________",Bum)
  PrnLine(" ",Bum)
  PrnLine(" ",Bum)
  PrnLine("                           З А Я В Л Е Н И Е",Bum)
  PrnLine(" ",Bum)
  PrnLine("              Прошу провести платежи за коммунальные и прочие услуги в счет",Bum)
  PrnLine(" ",Bum)
  PrnLine("           невыплаченной мне заработной платы за ___________ месяц 20__ год",Bum)
  PrnLine(" ",Bum)
  PrnLine("           в следующих размерах:",Bum)
  PrnLine(" ",Bum)
  PrnLine("           ---------------------------------------------------------",Bum)
  PrnLine("           Вид платежа                 | Лиц.сч    |Мес.опл|  Сумма ",Bum)
  PrnLine("           ---------------------------------------------------------",Bum)
  PrnLine("           Квартплата                  |           |       |        ",Bum)
  PrnLine("           ---------------------------------------------------------",Bum)
  PrnLine("           Холодная вода и канализация |           |       |        ",Bum)
  PrnLine("           ---------------------------------------------------------",Bum)
  PrnLine("           Горячая вода и отопление    |           |       |        ",Bum)
  PrnLine("           ---------------------------------------------------------",Bum)
  PrnLine("           Газ                         |           |       |        ",Bum)
  PrnLine("           ---------------------------------------------------------",Bum)
  PrnLine("           Электроэнергия              |           |       |        ",Bum)
  PrnLine("           ---------------------------------------------------------",Bum)
  PrnLine(" ",Bum)
  PrnLine(" ",Bum)
  PrnLine(" ",Bum)
  PrnLine("             _____________                       _______________",Bum)
  PrnLine("                дата                                роспись",Bum)
  PrnLine(" ",Bum)
  PrnLine(" ",Bum)
  PrnLine(" ",Bum)
  PrnLine("..",Bum)
Next
@ prow()+1,00 say chr(18)
Set Device to Screen
S_Sys()
END SEQUENCE
Return ( Nil )
////////////////////////////////////////////////////////////////////////////
Static Function PrnLine(cLine,Tip)
@ prow()+1,00 say iif(Tip==2,cLine,repl(padr(cLine,70)+space(7),3))
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static Function ZapInf() // запись информации в л/с
Local cKsp, nRec, cSym

if !Empty(SuperLis->Base_Rec)
  cKsp := SuperLis->Ksp        // Код подразделения
  nRec := SuperLis->Base_Rec   // No записи в BASE
  cSym := "Base"+cKsp
  Use (cSym) new alias Base
  Base->(DbGoto(nRec))
  AddBase(Gic->SumGkx,KVO_GKX)
  AddBase(Gic->SumVkx,KVO_VKX)
  AddBase(Gic->SumPtc,KVO_PTC)
  AddBase(Gic->SumGaz,KVO_GAZ)
  AddBase(Gic->SumEl, KVO_EL)
  Base->(DbCloseArea())
End
DbSelectArea("Gic")
Return ( Nil )
////////////////////////////////////////////////////////////////
Static Function AddBase(nSumma,cKvu_)
Local j, jm, cKvo, cSvon, cKmn, cDn
Local cKmu_ := Substr(dtos(sset[121]),5,2)

if nSumma > 0
  for j := 1 to 12
    jm := Alltrim(str(j,2))
    cVo := "Ku"+jm
    if empty(Base->&cVo) // .or. Base->&cVo == cKvu_
       Base->&cVo  := cKvu_
       cSvon := "SKu"+jm
       Base->&cSvon := nSumma*100
       cKmn := "Kmu"+jm
       Base->&cKmn := cKmu_
       cDn := "Dn"+jm
       Base->&CDn := 0
       Exit
    End
  Next
End
Return ( Nil )
////////////////////////////////////////////////////////////////
