#include "inkey.ch"
*******************************************************************POKAZTL
// Распределение численности работников по размерам з/п за текущий месяц
Function POKAZTLG(cPasw)
Local prz := 0, nODN :=0, aZat := {} , aPost := {},nGMN := 0, aP :={}, aF :={} 
Local SumP := 0 ,aDisp:={[|],[/],[-],[\],chr(7)},nDisp := 0 ,Sum :=0,SumP1:=nOdn1:=0
Local dData := date()//sset[121]
Private nDat := nDat1:=PathMinZar  :=0 
BEGIN SEQUENCE
S_Get({"Укажите первый предел ","PathminZar","9999999.99"})
if !OpenDbf_("NAKNACH") ; break ; End
DbGotop()
Set(20,[PRINT])
Set(24,[POKAZh.TXT])
for i=1 to 15
	   aadd(aP,0) ; aadd(aF,0)
next
 DbSelectArea( "NAKNACH" )
 go top
   set device to screen
   S_Get({"Укажите  дату c  ","nDat","999999","по","nDat1","999999"})
   if lastkey()=27 ; break .t. ; end
   prz :=0
      S_SYS({10,10,[Ж Д И Т Е],[ Идет формирование текстового файла ! ],;
                   [ ПО окончании будет подан звук.сигнал],[ ]})
      aSize(aZat,0)
      GOD :=str(year(ctod("01."+substr(str(nDat,6),5,2)+"."+substr(str(nDat,6),1,4))),6)
      while ( !eof() ) 
           nTNR :=TN ; sch :=0 ; nDn:=nDn1:=0
           DbSelectArea( "NAKNACH" )
           SumP1:=nOdn1:=0

           while ( !eof() .and.  TN = nTNR ) 

*                 if NAKNACH->D_Nach>=nDat .and.NAKNACH->D_Nach<=nDat1 
                 if NAKNACH->D_Vip>=nDat .and.NAKNACH->D_Vip<=nDat1 
                    if vo='102'
                       nDn1:=Dn/8
                       nDn+=nDn1
                    endif   

                    if vo='101'.or.Vo='361'.or.Vo='346'
                       nDn+=Dn
                    endif
                       SumP1 +=NAKNACH->Sum
                       sch :=1
                    prz :=1
                 end    
SumP:=SumP1
           DbSelectArea( "NAKNACH" )
                 Dbskip()
*?ntnr,'*'
            end
            if nDN >= 12
               do case 
                  case SUMP < PathMinZar .and. SUMP <> 0 .and.sch = 1 
                       aP[1]++ ; aF[1] := aF[1]+SUMP   
                  case SUMP>=PathMinZar .and. SUMP<PathMinZar*1.93 
                       aP[2]++ ; aF[2] := aF[2]+SUMP   
                  case SUMP >=PathMinZar*1.93 .and. SUMP < PathMinZar*2.07  //1.33-1.67 
                       aP[3]++ ; aF[3] := aF[3]+SUMP
                  case SUMP >=PathMinZar*2.07 .and. SUMP < PathMinZar*2.21//67-2
                       aP[4]++ ; aF[4] := aF[4]+SUMP
                  case SUMP >=PathMinZar*2.21 .and. SUMP < PathMinZar*2.67  //2-2.33
                       aP[5]++ ; aF[5] := aF[5]+SUMP
                  case SUMP >=PathMinZar*2.67 .and. SUMP < PathMinZar*3.02  //2.33-2.67
                       aP[6]++ ; aF[6] := aF[6]+SUMP
                  case SUMP >=PathMinZar*3.02 .and. SUMP < PathMinZar*3.33  //2.67-3
                       aP[7]++ ; aF[7] := aF[7]+SUMP
                  case SUMP >=PathMinZar*3.33 .and. SUMP < PathMinZar*4.00//-5
                       aP[8]++ ; aF[8] := aF[8]+SUMP
                  case SUMP >=PathMinZar*4.00 .and. SUMP < PathMinZar*5.00  //5-7
                       aP[9]++ ; aF[9] := aF[9]+SUMP
                  case SUMP >=PathMinZar*5.00 .and. SUMP < PathMinZar*6.00//
                       aP[10]++ ; aF[10] := aF[10]+SUMP
                  case SUMP >=PathMinZar*6.00 .and. SUMP < PathMinZar*6.67 //9-11
                       aP[11]++ ; aF[11] := aF[11]+SUMP
                  case SUMP >=PathMinZar*6.67 .and. SUMP < PathMinZar*9.00//11-13
                       aP[12]++ ; aF[12] := aF[12]+SUMP
                  case SUMP >=PathMinZar*9.00 .and. SUMP < PathMinZar*13.33  //13-15
                       aP[13]++ ; aF[13] := aF[13]+SUMP
                  case SUMP >=PathMinZar*13.33      //20
                       aP[15]++ ; aF[15] := aF[15]+SUMP
               endcase    
               SumP := nDN :=nDn1:=0 
             endif
      end
      aEval(aF,{ |x| Sum += x } )
      Set(20,[PRINT])
      Set(24,[POKAZh.TXT])
      @ prow()+1,0 say '**********************************************************'
      @ prow()+1,0 say '*     Расчет  показателей за     '+s_cMonth(dData)+" месяц "+str(year(dData),4)+" года"
      @ prow()+1,0 say '*     количества людей , у которых основная зарплата     *'
      @ prow()+1,0 say '*                                                        *' 
      @ prow()+1,0 say '*                                        Фонд зарплаты   *' 
      @ prow()+1,0 say '*                                                        *' 
      @ prow()+1,0 say '*  до 150                      '+str(aP[1],5)+'    '+str(aF[1],13,2)+'    * '
      @ prow()+1,0 say '*  от 150 до 290  грн.         '+str(aP[2],5)+'    '+str(aF[2],13,2)+'    * '
      @ prow()+1,0 say '*  от 290 до 310  грн.         '+str(aP[3],5)+'    '+str(aF[3],13,2)+'    * '
      @ prow()+1,0 say '*  от 310 до 332  грн.         '+str(aP[4],5)+'    '+str(aF[4],13,2)+'    * '
      @ prow()+1,0 say '*  от 332 до 400  грн.         '+str(aP[5],5)+'    '+str(aF[5],13,2)+'    * '
      @ prow()+1,0 say '*  от 400 до 453  грн.         '+str(aP[6],5)+'    '+str(aF[6],13,2)+'    * '
      @ prow()+1,0 say '*  от 453 до 500  грн.         '+str(aP[7],5)+'    '+str(aF[7],13,2)+'    * '
      @ prow()+1,0 say '*  от 500 до 600  грн.         '+str(aP[8],5)+'    '+str(aF[8],13,2)+'    * '
      @ prow()+1,0 say '*  от 600 до 750  грн.         '+str(aP[9],5)+'    '+str(aF[9],13,2)+'    * '
      @ prow()+1,0 say '*  от 750 до 900  грн.         '+str(aP[10],5)+'    '+str(aF[10],13,2)+'    * '
      @ prow()+1,0 say '*  от 900 до1000  грн.         '+str(aP[11],5)+'    '+str(aF[11],13,2)+'    * '
      @ prow()+1,0 say '*  от1000 до1350  грн.         '+str(aP[12],5)+'    '+str(aF[12],13,2)+'    * '
      @ prow()+1,0 say '*  от1350 до2000  грн.         '+str(aP[13],5)+'    '+str(aF[13],13,2)+'    * '
  //    @ prow()+1,0 say '*  от 1000до 2000 грн.            '+str(aP[14],5)+'  '+str(aF[14],15,2)+'  * '
      @ prow()+1,0 say '*  свыше     2000 грн.         '+str(aP[15],5)+'  '+str(aF[15],15,2)+'    * '
      @ prow()+1,0 say '*                                                        *' 
      @ prow()+1,0 say '*            Итого по предприятию    '+str(sum,15,2)+'     *' 
      @ prow()+1,0 say '**********************************************************'
      @ prow()+1,0 say ' '
   if prz=0
      Set(24,[])
      Set(20,[SCREEN])
      S_SYS({15,15,[],[ Информация отсутствует ],[ ],[ ]})
      inkey(2)
      S_SYS()
   endif
   S_SYS()
s_Beep()
Set(24,[])
Set(20,[SCREEN])
inkey(2)
ShowPrn([POKAZh.TXT],[  Расчет показателей за текущий месяц])
END SEQUENCE
DbCloseAll()
Return Nil
**********************************************************************
Function Raspred() //  вед-ть распр-ния раб-щих и денег
Local  nSum1:=nSum2:=nSum3:=nSum4:=0 ,nKol:= nKolO:= nSumO :=PrUv:=nKolUv:=0
Local  nKol1:=nKol2:=nKol3:=nKol4:=nKol5:=nKol6:=nKol7:=nDolgUv:=0	
Local nSumZ1 :=nSumZ2 :=nSumZ3 :=nSumZ4 :=nSumZ5 :=nSumZ6 :=nSumZ7 := nKola301:=0
Local dData :=date()  , nMec:=0,nLastRec, nRecno //sset[121]
Private nDat1:=nDat2:=nSumTM := nKolDn:=0
BEGIN SEQUENCE
*
if !OpenDbf_("NAKNACH") ; break ; End
if !OpenDbf_("NAKYD")   ; break ; End
if !OpenDolg() ; break ; End
Sx_SetTagNo(2)
*
S_Get({"Укажите номер месяца с ","nDat1","999999","по","nDat2","999999"})
if int(nDat1/100)=int(ndat2/100) ; nMec:=(nDat2-nDat1)+1 ;nKolDn:=nMec*30 ; endif
if int(nDat1/100)#int(ndat2/100) 
  nMec:=mod(ndat2,100) 
  nGod:=int(nDat2/100)-int(ndat1/100)-1 
  if nGod>0 
     nMec+=12*nGod+(13-mod(ndat1,100))
  elseif nGod<=0 
     nMec+=13-mod(ndat1,100) 
  endif   
  nKolDn:=nMec*30  
endif
S_Get({"Подтвердите  кол-во дней ","nKolDn","9999"})

nLastRec := DolgPr->(LastRec())
DolgPr->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Set(20,[PRINT]) ; Set(24,[Raspred.TXT])
nKol:=nKol1:=nKol2:=nKol3:=nKol4:=nKol5:=nKol6:=nKol7:=0	
nSumZ1 :=nSumZ2 :=nSumZ3 :=nSumZ4 :=nSumZ5 :=nSumZ6 :=nSumZ7 := 0
nKolO:= nSumO :=nKolO1:=0
nSumDolg:=nDolgUv:=nKolUv:=0
@ prow()+1,1 say ' Распределение работающих и денег в соответствии со сроками задолженности'
@ prow()+1,0 say '      за     '+s_cMonth(dData)+" месяц "+str(year(dData),4)+" года"
@ prow()+1,1 say ' ________________________________________________________________________'
@ prow()+1,1 say '                    :       : Общая численность   : Сумма задолженности  :'
@ prow()+1,1 say ' Срок задолженности :  Код  : штатных раб.,которым: по выплате заработной:'
@ prow()+1,1 say ' календарных дней   :порядка: своевременно        : платы тыс.грн.       :' 
@ prow()+1,1 say '                    :       : не выплаченная з/п  :                      :'
@ prow()+1,1 say ' ________________________________________________________________________'
@ prow()+1,1 say '          1         :   2   :            3        :           4          :'
@ prow()+1,1 say ' ________________________________________________________________________'
While (!eof() )
  nTnr:=Tn ; nSum1:= nSum4:=nKol:=0
  DbSelectArea("DolgPr")
  While (Tn=nTnr .and. !eof() )
    if substr(dtos(Data),1,6)>=str(nDat1,6) .and.substr(dtos(Data),1,6)<=str(nDat2,6)
       nSum1+=(SumDolg-SumVip)
    endif   
  S_Line_N(18,04,65,nLastRec,++nRecno)
    DbSkip()
  enddo
*?ntnr
  if nSum1#0
     DbSelectArea( "NAKNACH" ) //201h
     nSum2:=0
     nTnr:=val(nTnr)  
     if DbSeek(str(nTnr,6))
        While (Tn=nTnr .and. !eof() )
          if D_Vip>=nDat1 .and.D_Vip<=nDat2 
             nSum2+=Sum
          endif   
          DbSkip()
        enddo
     endif //dbseek
     DbSelectArea( "NakYd" )//221p
     nSum3:=0
     if DbSeek(str(nTnr,6))
        While (Tn=nTnr .and. !eof() )
          if D_Yd>=nDat1 .and.D_Yd<=nDat2 
             if Kvu1='910'.or.Kvu1='912'.or.Kvu1='913'.or.Kvu1='914'.or.Kvu1='945'
                nSum3+=SumYd1
             endif
             if Kvu2='910'.or.Kvu2='912'.or.Kvu2='913'.or.Kvu2='914'.or.Kvu2='945'
                nSum3+=SumYd2
             endif
             if Kvu3='910'.or.Kvu3='912'.or.Kvu3='913'.or.Kvu3='914'.or.Kvu3='945'
                nSum3+=SumYd3
             endif
             if Kvu4='910'.or.Kvu4='912'.or.Kvu4='913'.or.Kvu4='914'.or.Kvu4='945'
                nSum3+=SumYd4
             endif
             if Kvu5='910'.or.Kvu5='912'.or.Kvu5='913'.or.Kvu5='914'.or.Kvu5='945'
                nSum3+=SumYd5
             endif
             if Kvu6='910'.or.Kvu6='912'.or.Kvu6='913'.or.Kvu6='914'.or.Kvu6='945'
                nSum3+=SumYd6
             endif
             if Kvu7='910'.or.Kvu7='912'.or.Kvu7='913'.or.Kvu7='914'.or.Kvu7='945'
                nSum3+=SumYd7
             endif
             if Kvu8='910'.or.Kvu8='912'.or.Kvu8='913'.or.Kvu8='914'.or.Kvu8='945'
                nSum3+=SumYd8
             endif
             if Kvu9='910'.or.Kvu9='912'.or.Kvu9='913'.or.Kvu9='914'.or.Kvu9='945'
                nSum3+=SumYd9
             endif
             if Kvu10='910'.or.Kvu10='912'.or.Kvu10='913'.or.Kvu10='914'.or.Kvu10='945'
                nSum3+=SumYd10
             endif
             if Kvu11='910'.or.Kvu11='912'.or.Kvu11='913'.or.Kvu11='914'.or.Kvu11='945'
                nSum3+=SumYd11
             endif
             if Kvu12='910'.or.Kvu12='912'.or.Kvu12='913'.or.Kvu12='914'.or.Kvu12='945'
                nSum3+=SumYd12
             endif
          endif   
          DbSkip()
        enddo
     endif //dbseek
     nSum4:=(nSum2-nSum3)/nKolDn    //300 -12 месяцев  330 -13 месяцев
     nKol:=(nSum1)/nSum4
  endif//sum1
  if nKol<=30.and.nKol#0 ; nKol1++ ; nSumZ1+=nSum1 ; endif
  if nKol>30  .and.nKol<=60  ;  nKol2++ ;   nSumZ2+=nSum1  ; endif
  if nKol>60  .and.nKol<=90  ;  nKol3++ ;   nSumZ3+=nSum1  ; endif
  if nKol>90  .and.nKol<=120 ;  nKol4++ ;   nSumZ4+=nSum1  ; endif
  if nKol>120 .and.nKol<=150 ;  nKol5++ ;   nSumZ5+=nSum1  ; endif
  if nKol>150 .and.nKol<=180 ;  nKol6++ ;   nSumZ6+=nSum1  ; endif
  if nKol>180 ;  nKol7++ ;   nSumZ7+=nSum1  ; endif
  nkolo1++
  DbSelectArea("DolgPr")
enddo//dolgpr
nKolO :=nKol1+nKol2+nKol3+nKol4+nKol5+nKol6+nKol7
nSumO:=nSumZ1+nSumZ2+nSumZ3+nSumZ4+nSumZ5+nSumZ6+nSumZ7
@ prow()+1,1 say repl([_],80)
@ prow()+1,1 say '   до 30 дней          :  202   :         '+str(nKol1,6)+[  :      ]+str(nSumZ1,13,2)
@ prow()+1,1 say '   31  -  60           :  203   :         '+str(nKol2,6)+[  :      ]+str(nSumZ2,13,2)
@ prow()+1,1 say '   61  -  90           :  204   :         '+str(nKol3,6)+[  :      ]+str(nSumZ3,13,2)
@ prow()+1,1 say '   91  - 120           :  205   :         '+str(nKol4,6)+[  :      ]+str(nSumZ4,13,2)
@ prow()+1,1 say '   121 - 150           :  206   :         '+str(nKol5,6)+[  :      ]+str(nSumZ5,13,2)
@ prow()+1,1 say '   151 - 180           :  207   :         '+str(nKol6,6)+[  :      ]+str(nSumZ6,13,2)
@ prow()+1,1 say '   свыше 180 дней      :  208   :         '+str(nKol7,6)+[  :      ]+str(nSumZ7,13,2)
@ prow()+1,1 say repl([_],80)
@ prow()+1,1 say 'Итого:                                    '+str(nKolO,6)+[  :      ]+str(nSumO,13,2)
@ prow()+1,1 say repl([_],80)
@ prow()+1,1 say repl([ ],20)
@ prow()+1,1 say repl([ ],20)
**
S_BEEP()
S_Line_N()
Set(24,[]) ; Set(20,[SCREEN])                                  //; inkey(2)
ShowPrn([Raspred.TXT],[    ])
END SEQUENCE
Set(20,"SCREEN")
DbCloseAll()
return NIL
*************************