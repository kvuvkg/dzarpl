#include "Inkey.ch"
///////////////////////////////////////////////////////////////////////////
Function PlPor() // �ନ஢���� � ����� ���⥦��� ����祭��
Local dData := year(sset[100]), nPlPor, i, nKolEkz, nSumma, nNdc,;
      ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {},cText1, cText2, dDataPor, aProp, nEnt, nLen
Local NaimMec := {"�i�� ","��⮣� ","��१�� ","��i�� ","�ࠢ�� ",;
      "��ࢭ� ","����� ","��௭� ","����� ","����� ","���⮯��� ",;
      "��㤭� "}

            
S_Open_M(07,03,19,59,sset[32],sset[2])
While .t.
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ 10,01 say repl("�",MaxCol()-1)
  @ 11,01 say padc(" ������....",MaxCol()-1) color sset[15]
  if PlPor->(DbSeek(str(dData,4)))
     While !PlPor->(eof()) .and. PlPor->GodPor == dData
        nPlPor := PlPor->PlPor
        PlPor->(DbSkip(1))
     End
     nPlPor++
  else
     nPlPor := 0
  End
  @ 11,01 say padc(" ESC - ����� ࠡ���",MaxCol()-1) color sset[15]
  @ 01,02 say "No ���⥦���� ����祭��" get nPlPor pict "999999" valid nPlPor > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if PlPor->(DbSeek(str(dData,4)+str(nPlPor,6)))
     lAppend := .f.
     @ 10,01 say padc(" ������������ ���������",MaxCol()-1) color sset[15]
  else
     @ 10,01 say padc(" ������������ ���������",MaxCol()-1) color sset[15]
     lAppend := .t.
     PlPor->(DbGoBottom())
     PlPor->(DbSkip(1))
  End
  dDataPor  := PlPor->DataPor
  nEnt      := PlPor->EntPor
  nSumma    := PlPor->SumPor
  nNdc      := PlPor->Ndc
  cText1    := PlPor->Text1
  cText2    := PlPor->Text2
  cText3    := space(45)
  S_Ent->(DbSeek(str(nEnt,4)))
  @ 01,33 say "�� "+dtoc(dDataPor)+" �."
  @ 02,02 say "�࣠������ "+str(nEnt,4)+" "+S_Ent->Naim
  @ 03,14 say "��� "+S_Ent->Mfo+" ��� "+S_Ent->Schet
  @ 04,14 say "���� "+S_Ent->Okpo
  @ 05,14 say "���� "+S_Ent->Bank
  @ 06,02 say "�㬬� "+str(nSumma,15,2)+" ��."
  @ 06,28 say "� �.�. ��� "+str(nNdc,15,2)
  @ 07,02 say "�� �� "+cText1
  @ 08,02 say "       "+cText2
  ///////////////////////////////////  G E T /////////////////////////
  @ 01,36 get dDataPor pict "@d" valid !Empty(dDataPor)
  @ 02,14 get nEnt pict "9999" valid VedEnt(@nEnt,02,19)
  read
  if LastKey()==K_ESC ; Loop ; End
  @ 02,19 say S_Ent->Naim
  @ 03,14 say "��� "+S_Ent->Mfo+" ��� "+S_Ent->Schet
  @ 04,14 say "���� "+S_Ent->Okpo
  @ 05,14 say "���� "+S_Ent->Bank
  @ 06,08 get nSumma pict "999999999999.99" valid nSumma > 0
  read
  if LastKey()==K_ESC ; Loop ; End
  nNdc := if(empty(nNdc),round(nSumma*0.16667,2),nNdc)
  @ 06,39 get nNdc   pict "999999999999.99" valid nNdc < nSumma .and. nNdc >= 0
  @ 07,09 get cText1
  @ 08,09 get cText2
  @ 09,09 get cText3
  read
  if LastKey()==K_ESC ; Loop ; End
  nKolEkz := 2
  @ 11,01 say padc(" ",MaxCol()-1) 
  @ 11,07 say "������ ������⢮ ��������஢--->" get nKolEkz pict "99"
  read
  if LastKey()<>K_ESC .and. nKolEkz > 0
     @ 11,01 say padc("������ �� ������ � �㬠���",MaxCol()-1) color sset[15]
     BEGIN SEQUENCE
     nLen  := 65
     aProp := PropisSum(nSumma,58)
     set(20,"PRINT")
     set(24,"PlPor6.txt")
     @ prow()+1,00 say ""
     @ Prow()+1,00 say "                                                         0401002"
     @ Prow()+1,00 say "                                                     ���ঠ�� ������"
     @ Prow()+1,00 say [                                                  "__" _____________ 19__ �.]
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say "                       ����I��� ��������� N "+str(nPlPor,6)
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say "                     "+;
        str(day(ddataPor),2)+" "+NaimMec[month(ddataPor)]+;
        str(year(ddataPor),4)+" ப�"
     @ Prow()+1,00 say "  "
     @ Prow()+1,00 say "���⭨�                                           �����         ����     "
     @ Prow()+1,00 say "��ࢮ����쪥  ������                        ���������������������������Ŀ"
     @ Prow()+1,00 say "                                            �26009200028000�"+str(nSumma,12,2)+"�"
     @ Prow()+1,00 say "ڊ��������Ŀ                                �   ��. N     �            �"
     @ Prow()+1,00 say "�22714272  ��������������������������������Ĵ              �            �"
     @ Prow()+1,00 say " ��ࢮ����쪨� �i�.����� ����I���     ���   ��������������Ĵ            �"
     @ Prow()+1,00 say " ���� ���⭨�� �. ��ࢮ����쪨� �   351027  �   ������     �            �"
     @ Prow()+1,00 say " ��. �㣠�祭�� 17             �           �              �            �"
     @ Prow()+1,00 say "�����������������������������������������������������������������������Ĵ"
     @ Prow()+1,00 say " ����㢠�                                  �              �            �"
     @ Prow()+1,00 say S_Ent->Naim+"         �"+S_Ent->Schet+"�            �"
     @ Prow()+1,00 say "ڊ���������Ŀ                               �    ���. N    �            �"
     @ Prow()+1,00 say "�"+S_Ent->Okpo+"����������������������������������������������Ĵ            �"
     @ Prow()+1,00 say "���� "+left(S_Ent->Bank,29)+"�  ���    �              �            �"
     @ Prow()+1,00 say "                                  �"+S_Ent->Mfo+"�              �            �"
     @ Prow()+1,00 say "�������������������������������������������������������������������������"
     @ Prow()+1,00 say "�㬠 �i�ࠬ� "+aProp[1]
     for i := 2 to Len(aProp)
       @ Prow()+1,00 say "             "+aProp[i]
     Next
     @ Prow()+1,00 say "�������������������������������������������������������������������������"
     @ Prow()+1,00 say "�ਧ��祭�� ���⥦� "+cText1
     @ Prow()+1,00 say "                    "+cText2
     @ Prow()+1,00 say "                    "+cText3
     if nNdc > 0
        @ Prow()+1,00 say " � ⮬� ��i ��� - "+str(nNdc,15,2)
     End
     @ Prow()+1,00 say "  "
     @ Prow()+1,00 say "    �.�.                                      �஢����� ������        "
     @ Prow()+1,00 say [                                        "__" _____________ 19__ �.   ]
     @ Prow()+1,00 say "  "
     @ Prow()+1,00 say "  �i���� ���⭨��                           �i���� �����"
     @ Prow()+1,00 say "  "
     @ Prow()+1,00 say "  "
     @ Prow()+1,00 say repl("= ",nLen/2)
     @ prow()+1,00 say ""
     set(24,"")
     set(20,"SCREEN")
     for i := 1 to nKolEkz
        if S_TPRN("PlPor6.txt",,1) < 0 ; break ; End
     Next
     END SEQUENCE     
  End
  if lAppend
     PlPor->(DbAppend())
     PlPor->GodPor:= dData
     PlPor->PlPor := nPlPor
  End
  PlPor->DataPor := dDataPor
  PlPor->EntPor  := nEnt
  PlPor->SumPor  := nSumma
  PlPor->Ndc     := nNdc
  PlPor->Text1   := cText1
  PlPor->Text2   := cText2
End
ferase("PlPor6.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )
/////////////////////////////////////////////////////////////////////
Static function PropisSum(Sum,Dlina,Krb,Kop)
local Bank,Sumc,Prop,i,T,J,Kc,P,K,Adr,Baza, Ret := {}
Bank := "001���� 002��i 003�� 004��� 005�'��� "+;
        "006�i��� 007�i� 008�i�i� 009���'��� 010������ "+;
        "011���������� 012���������� 013�ਭ������ "+;
        "014��ୠ����� 015�'�⭠����� 016�i�⭠����� "+;
        "017�i�������� 018�i�i�������� 019���'�⭠����� "+;
        "020�������� 030�ਤ���� 040�ப 050�'�⤥��� "+;
        "060�i�⤥��� 070�i������ 080�i�i������ "+;
        "090���'ﭮ�� 100�� 200��i��i 300���� 400����� "+;
        "500�'����� 600�i����� 700�i��� 800�i�i��� "+;
        "900���'�����   "
Dlina := iif(Dlina=NIL .or. Dlina=0,128,Dlina)
Krb := if(Krb==Nil,"��. ",Krb)
Kop := if(Kop==Nil,"���. ",Kop)
Sumc  := strzero(Sum,15,2)
if Sum=0
   Prop := "��� "
 else
   Adr := "000"
   Prop := ""
   for i=1 to 4
      T := (I-1)*3
      Bank := stuff(Bank,4,11,iif(I=3,"���� 002��i","���� 002���"))
      for J=1 to 3
        P := T+J
        Kc := substr(Sumc,P,1)
        K :=  val(KC)
        Adr := stuff(Adr,J,1,Kc)
        if ( Adr#"010" .or. J#2 ) .and. Adr#"000"
            P := at(Adr,Bank)
            P += 3
            Baza := substr(Bank,P,13)
            P := at(" ",Baza)
            Prop += substr(Baza,1,P)
            Adr :=  "000"
        end
     next
     do case
        case I=3 .and. Sum>=1000  .and. substr(Sumc,7,3)#"000"
           Prop += "����"
           if K>0 .and. K<=4 .and. substr(Sumc,8,1)<>"1"
              Prop += substr("�iii",K,1)
           end
           Prop += " "
        case I=2 .and. Sum>=1000000 .and. substr(Sumc,4,3)#"000"
           Prop += "�i�쩮�"
           if K>=2 .and. K<=4 .and. substr(Sumc,5,1)#"1" .and. ;
                                                      substr(Sumc,6,1)#"0"
              Prop += "�"
            else
              if K>=5 .or. substr(Sumc,5,1)="1" .or. substr(Sumc,6,1)="0"
                 Prop += "i�"
              end
           end
           Prop += " "
        case I=1 .and. Sum>=1000000000
           Prop += "�i����"
           if K>=2 .and. K<=4 .and. substr(Sumc,2,1)#"1" .and. ;
                                                substr(Sumc,3,1)#"0"
              Prop += "�"
            else
              if K>=5 .or. substr(Sumc,2,1)="1" .or. substr(Sumc,3,1)="0"
                 Prop += "i�"
              end
           end
           Prop += " "
     endcase
  next
end
P := asc(Prop)
P := iif(P>=160 .and. P<=175,P-32,P-80)
Prop := stuff(Prop,1,1,chr(P))
Prop := left(Prop,len(Prop)-1)+"#"+Krb+" "+right(Sumc,2)+"#"+Kop
Bank := Adr := ""
While ( ( I := at(" ",Prop) ) # 0 )
   Adr := left(Prop,I)
   if len(Adr+Bank) < Dlina
      Bank += Adr
     else
      aadd(Ret,padr(StrTran(Bank,"#"," "),Dlina))
      Bank := Adr
   end
   Prop := substr(Prop,I+1)
end
if Len(Bank+Prop) > Dlina
   aadd(Ret,Padr(StrTran(Bank,"#"," "),Dlina))
   Bank := ""
end
Bank += Prop
if len(Bank)>0
   aadd(Ret,padr(StrTran(Bank,"#"," "),Dlina))
end
Return ( Ret )
//////////////////////////////////////////////////////////////////////////////
Function ChFakt() // �ନ஢���� � ����� ���-䠪����
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)
      
Local NaimMec := {"ﭢ��� ","䥢ࠫ�","����","��५�","���",;
      "���","���","������","ᥭ����","������","�����",;
      "�������"}
            
S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
  nChFakt := Fakt->NomChF + 1
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - ����� ࠡ���",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N ���-䠪����" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  Fakt->(Dbseek(str(nChFakt,6)))
  dDataCh := Fakt->DataCh
  dData   := Fakt->Data
  nEnt    := Fakt->Ent
  @ 02,24 say "��" get dDataCh pict "@d" valid !Empty(dDataCh)
  @ 03,02 say "��" get dData   pict "@d" valid !Empty(dData)
  @ 03,16 say "� ���-��" get nKolEkz pict "99" valid nKolEkz >= 0
  read
  if LastKey() == K_ESC ; exit ; End
  @ 05,02 say "��� �࣠����樨" get nEnt pict "9999" valid VedEnt(@nEnt,06,02)
  read
  if LastKey() == K_ESC ; exit ; End
  if nKolEkz > 0 
     if !Prixod->(DbSeek(str(nEnt,4)))
       S_Beep()
       @ MaxRow()-1,01 say padc(" ���������� �����",MaxCol()-1) color sset[15]
       M_inkey(0)
       Loop
     End
     @ MaxRow()-1,01 say padc(" ������ �� ������",MaxCol()-1) color sset[15]
     cNaimMec := NaimMec[Month(dData)]
     BEGIN SEQUENCE
     nLen  := 73
     nSumma:= 0
     S_Ent->(DbSeek(str(nEnt,4)))
     cDogovor := S_Ent->Dogovor
     dDataDog := S_Ent->DataDog
     if Empty(cDogovor) .or. Empty(dDataDog)
        S_Open_M(16,07,18,42,sset[32],sset[2])     
        @ 01,01 say "�������" get cDogovor
        @ 01,20 say "��" get dDataDog pict "@d"
        read
        if LastKey() <> K_ESC
          S_Ent->Dogovor := cDogovor
          S_Ent->DataDog := dDataDog
        End
        S_wCloseSl(S_RanDom()%22+1)        
     End
     set(20,"PRINT")
     set(24,"ChFakt.txt")
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say padc("� � � � - � � � � � � �  No "+alltrim(str(nChFakt,6)),nLen)
     @ Prow()+1,00 say padc("�� "+dtoc(dDataCh),nLen)
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say " ���������: ��ࢮ���᪮� ������"
     @ Prow()+1,00 say "            ��� 26009200028000 ��� 22714272 ��� 351027"
     @ Prow()+1,00 say [            � ��� ��� "�������"]
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say " ����������: "+S_Ent->Naim
     @ Prow()+1,00 say "             ��� "+S_Ent->Schet+" ��� "+S_Ent->Okpo+" ��� "+S_Ent->Mfo
     @ Prow()+1,00 say "             "+S_Ent->Bank
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say " ������� "+cDogovor+" �� "+dtoc(dDataDog)
     @ prow()+1,00 say "-------------------------------------------------------------------------"
     @ Prow()+1,00 say "��.  | ������⢮ |    ����     | ������������           |     �㬬�    |"
     @ prow()+1,00 say "-------------------------------------------------------------------------"
     aFakt := {}
     While Prixod->Ent == nEnt .and. !Prixod->(eof())
       @ prow()+1,00 say "�.�� "+str(Prixod->Kolvo,12)+" "+str(Prixod->Cena,13,2)+" "+;
         padr(iNaim(Prixod->Chet)+" �� "+cNaimMec,24)+" "+;
         str(Prixod->Summa-Prixod->Ndc-Prixod->Fec-Prixod->SumBank,14,2)
       S_Price->(DbSeek(str(Prixod->Chet,5,2)+str(S_Ent->Tip,1)))
       if !Empty(Prixod->Ndc)
         @ prow()+1,00 say space(33)+padr("��� "+;
           iif(S_Price->Ndc=0,"",str(S_Price->Ndc*100,4,1)+"%"),24)+" "+str(Prixod->Ndc,14,2)
       End
       if !Empty(Prixod->Fec)
         @ prow()+1,00 say space(33)+padr("��� "+;
           iif(S_Price->Fec=0,"",str(S_Price->Fec*100,4,1)+"%"),24)+" "+str(Prixod->Fec,14,2)
       End
       if !Empty(Prixod->SumBank)
         @ prow()+1,00 say space(33)+padr("��㣨 ����� ",24)+" "+str(Prixod->SumBank,14,2)
       End

       if !Empty(Prixod->Ndc) .or. !Empty(Prixod->Fec) .or. !Empty(Prixod->SumBank)
         @ prow()+1,00 say space(33)+padr("�⮣� "+iNaim(Prixod->Chet),24)+" "+;
           str(Prixod->Summa,14,2)
       End
       nSumma += Prixod->Summa
       aadd(aFakt,{"�.�� ",Prixod->Kolvo,Prixod->Cena,;
                  padr(iNaim(Prixod->Chet)+" �� "+cNaimMec,24),;
                  Prixod->Summa-Prixod->Ndc-Prixod->Fec-Prixod->SumBank,;
                  Prixod->Ndc})
       Prixod->(DbSkip(1))     
     End
     @ prow()+1,00 say space(33)+padr("�ᥣ� �� ����� ",24)+" "+str(nSumma,14,2)
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say " "
     aProp := PropisSum_(nSumma,59)     
     @ Prow()+1,00 say "�㬬� � �����: "+aProp[1]
     for i := 2 to len(aProp)
       @ Prow()+1,00 say "                "+aProp[i]
     Next
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say "  ��砫쭨� "
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say "  ��. ��壠���"
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say " "
     @ Prow()+1,00 say repl("= ",nLen/2)
     @ prow()+1,00 say ""
     set(24,"")
     set(20,"SCREEN")
     for i := 1 to nKolEkz
        if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
     Next
     END SEQUENCE     
     if Fakt->(DbSeek(Str(nChFakt,6)))
        While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           Fakt->(DbDelete())
           Fakt->(DbSkip(1))
        End
     End
     For i := 1 to len(aFakt)
       Fakt->(DbAppend())
       Fakt->NomChF  := nChFakt
       Fakt->DataCh  := dDataCh
       Fakt->Data    := dData
       Fakt->Ent     := nEnt
       Fakt->EdIzm   := aFakt[i][1]
       Fakt->Kolvo   := aFakt[i][2]
       Fakt->Cena    := aFakt[i][3]
       Fakt->Naim    := aFakt[i][4]
       Fakt->Summa   := aFakt[i][5]
       Fakt->Ndc     := aFakt[i][6]
     Next
  End
End
ferase("ChFakt.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )
////////////////////////////////////////////////////////////////////////////
Static Function iNaim(nChet)
if nChet == 46.01
   Return ( "����" )
elseif nChet == 46.02
   Return ( "�⮪�" )
End
Return ( "��稥" )
//////////////////////////////////////////////////////////////////////////////
Static function PropisSum_(Sum,Dlina,Krb,Kop)
local Bank,Sumc,Prop,i,T,J,Kc,P,K,Adr,Baza, Ret := {}
Bank := "001���� 002��� 003�� 004���� 005���� "+;
        "006���� 007ᥬ� 008��ᥬ� 009������ 010������ "+;
        "011���������� 012��������� 013�ਭ����� "+;
        "014���ୠ���� 015��⭠���� 016��⭠���� "+;
        "017ᥬ������ 018��ᥬ������ 019����⭠���� "+;
        "020������� 030�ਤ��� 040�ப 050���줥��� "+;
        "060���줥��� 070ᥬ줥��� 080��ᥬ줥��� "+;
        "090���ﭮ�� 100�� 200����� 300���� 400������ "+;
        "500������ 600������ 700ᥬ��� 800��ᥬ��� "+;
        "900��������   "
Dlina := iif(Dlina=NIL .or. Dlina=0,128,Dlina)
Krb := if(Krb==Nil,"��. ",Krb)
Kop := if(Kop==Nil,"���. ",Kop)
Sumc  := strzero(Sum,15,2)
if Sum=0
   Prop := "���� "
 else
   Adr := "000"
   Prop := ""
   for i=1 to 4
      T := (I-1)*3
      Bank := stuff(Bank,4,11,iif(I=3,"���� 002���","���� 002���"))
      for J=1 to 3
        P := T+J
        Kc := substr(Sumc,P,1)
        K :=  val(KC)
        Adr := stuff(Adr,J,1,Kc)
        if ( Adr#"010" .or. J#2 ) .and. Adr#"000"
            P := at(Adr,Bank)
            P += 3
            Baza := substr(Bank,P,13)
            P := at(" ",Baza)
            Prop += substr(Baza,1,P)
            Adr :=  "000"
        end
     next
     do case
        case I=3 .and. Sum>=1000  .and. substr(Sumc,7,3)#"000"
           Prop += "�����"
           if K>0 .and. K<=4 .and. substr(Sumc,8,1)<>"1"
              Prop += substr("����",K,1)
           end
           Prop += " "
        case I=2 .and. Sum>=1000000 .and. substr(Sumc,4,3)#"000"
           Prop += "�������"
           if K>=2 .and. K<=4 .and. substr(Sumc,5,1)#"1" .and. ;
                                                      substr(Sumc,6,1)#"0"
              Prop += "�"
            else
              if K>=5 .or. substr(Sumc,5,1)="1" .or. substr(Sumc,6,1)="0"
                 Prop += "��"
              end
           end
           Prop += " "
        case I=1 .and. Sum>=1000000000
           Prop += "�������"
           if K>=2 .and. K<=4 .and. substr(Sumc,2,1)#"1" .and. ;
                                                substr(Sumc,3,1)#"0"
              Prop += "�"
            else
              if K>=5 .or. substr(Sumc,2,1)="1" .or. substr(Sumc,3,1)="0"
                 Prop += "��"
              end
           end
           Prop += " "
     endcase
  next
end
P := asc(Prop)
P := iif(P>=160 .and. P<=175,P-32,P-80)
Prop := stuff(Prop,1,1,chr(P))
Prop := left(Prop,len(Prop)-1)+"#"+Krb+" "+right(Sumc,2)+"#"+Kop
Bank := Adr := ""
While ( ( I := at(" ",Prop) ) # 0 )
   Adr := left(Prop,I)
   if len(Adr+Bank) < Dlina
      Bank += Adr
     else
      aadd(Ret,padr(StrTran(Bank,"#"," "),Dlina))
      Bank := Adr
   end
   Prop := substr(Prop,I+1)
end
if Len(Bank+Prop) > Dlina
   aadd(Ret,Padr(StrTran(Bank,"#"," "),Dlina))
   Bank := ""
end
Bank += Prop
if len(Bank)>0
   aadd(Ret,padr(StrTran(Bank,"#"," "),Dlina))
end
Return ( Ret )
////////////////////////////////////////////////////////////////////////////
