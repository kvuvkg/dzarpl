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
Set(26,.f.)                      // Ŀ
Set(32,.f.)                      //  �  ������ ���㬥����
Set(4,"dd.mm.yyyy")              //  �� �� Clipper 5.0
Set(11,.t.)                      //  �
Set(9,.f.)                       //  �
SetBlink(.t.)                    // ��
aSize(sset,125)
sset[121] := date() // ��� ����
sset[122] := 0      // �������쭠� �/�
SetColor(sset[86] := "n/w")
ErrorBlock( { |ObjError| ErrorSys(ObjError) } )
DeskTop := oKMouseNew()
oNorton := oNortonNew()
DeskTop:Norton := oNorton
DeskTop:Open()
S_cls("�")
@ 00,00 say padc(" ",80)
@ 00,57 say "�६�:"
ShowTime(0,64,.F.,"n/w")
S_Nil_Key()
S_SetKey(K_CTRL_F9, { |x| x := Set(4,"dd.mm.yy"),;
                          S_Calend(3,50),;
                          Set(4,x) },"������" )
S_SetKey(K_CTRL_F10, { | |S_Calc() },"�����" )
oMen := MainMenu()
BEGIN SEQUENCE
omen:refAll()
ReadData()
// ������� ����� ��������� ��쥪�
omenMain:=omen
While .T.
  key := S_InKey(0)
  do Case
     case omen == omenMain .and. key == K_ESC
       S_Beep()
       if S_Err({18,28,"�������� ࠡ���?","% ��� ;  �� ; "}) == 2
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

// ���� 0    >>>>>>>>>>>>>>> ������� <<<<<<<<<<<<<<<
omen0:=oMenuNew( 2, 0, .F.     ,;
               {"��ࢨ� ",;
                "���� ",;
                "���쭨�� ",;
                "��./��������� ",;
                "��������� ",;
                "����㭠��� ",;
                " ��x��  "})
oprompt1:=oPromptNew(24,0,80)
oprompt1:Color := {"n/w","n/w"}
omen0:Prompt:=oPrompt1
omen0:addPrompt(++j," ��ࢨ�� �㭪樨")
omen0:addPrompt(++j," �㭪樨 �� ����� ���᪭��")
omen0:addPrompt(++j," �㭪樨 �� ����� ���쭨���")
omen0:addPrompt(++j," �㭪樨 �� ���⥦�� ���������")
omen0:addPrompt(++j," �㭪樨 �� ᭮襭�� � ��������� ���������樨")
omen0:addPrompt(++j," �㭪樨 �� ������� ����㭠���� ���")
omen0:addPrompt(++j,"��室 �� �ணࠬ��")
omen0:block(j,{||Mquit()})
j := 0
//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("��� ����")
omen:addPrompt(++i,"���� ���� ����")
omen:block(i,{ || ReadData(1) })

omen:add("����������")
omen:addPrompt(++i,"����������")
omen:block(i,{ || ZapInf() })

omen:add("���⪠ ����")
omen:addPrompt(++i,"���⪠ ����")
omen:block(i,{ || ZipBase() })

omen:add("�������쭠� �/��")
omen:addPrompt(++i,"�������쭠� ��ࠡ�⭠� ����")
omen:block(i,{ || ReadData(2) })

omen:add("������ �� �뤠���� �/��")
omen:addPrompt(++i,"������ �� �뤠���� �/�� ")
omen:block(i,{ || ZapNeVud() })

omen:add("�������� �/��")
omen:addPrompt(++i,"������஢���� ��ࠡ�⭮� ����� ")
omen:block(i,{ || IndexZp() })

omen:add("��������� �/��")
omen:addPrompt(++i,"��������� ��ࠡ�⭮� ����� ")
omen:block(i,{ || Kompens() })

omen:add("�������� ���ଠ樨")
omen:addPrompt(++i,"�������� ���ଠ樨 �� ���� NakNach � NakYd ")
omen:block(i,{ || PackArx() })

omen:add("�������� �������樨")
omen:addPrompt(++i,"�������� �������樨 �� ����  ")
omen:block(i,{ || DelKomp() })

omen:add("������� �����樥�� �� ��������� �/��")
omen:addPrompt(++i,"������� �����樥�� �� ��������� �/��")
omen:block(i,{ || VedKomp() })

omen:add("�㬬� �� ���᫥���� �/��")
omen:addPrompt(++i,"�㬬� �� ���᫥���� �/�� ")
omen:block(i,{ || Fornak() })

omen:add("�㬬� �� 㤥থ��� �/��")
omen:addPrompt(++i,"�㬬� �� 㤥থ��� �/�� ")
omen:block(i,{ || Fornaky() })


omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("���� ���᪭��")
omen:addPrompt(++i,"���� ���᪭��")
omen:block(i,{ || VvodOtp() })

omen:add("�����")
omen:addPrompt(++i,"����� ���᪭��")
omen:block(i,{ || RaschO() })

omen:add("����� ���� ����")
omen:addPrompt(++i,"����� ���� ����")
omen:block(i,{ || PrnVedO() })

omen:add("������ ���ଠ樨")
omen:addPrompt(++i,"��७�� ���᫥���� ���᪭�� � ��楢� ���")
omen:block(i,{ || ZapInfO() })

omen:add("��ࠢ ���� ���᪠")
omen:addPrompt(++i,"��ࠢ ���� ���᪠")
omen:block(i,{ || VvodSprO() })

omen:add("���������")
omen:addPrompt(++i,"��ନ஢���� � ����� ��������")
omen:block(i,{ || PrnOtpu() })

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("���� ���쭨���")
omen:addPrompt(++i,"���� ���쭨���")
omen:block(i,{ || RaschB() })

omen:add("������ ���ଠ樨")
omen:addPrompt(++i,"��७�� ���᫥���� ���쭨��� � ��楢� ���")
omen:block(i,{ || ZapInfB() })

omen:add("��ࠢ ���� ���쭨���")
omen:addPrompt(++i,"�ࠢ ���� ���쭨���")
omen:block(i,{ || VvodSprB() })

omen:add("���������")
omen:addPrompt(++i,"��ନ஢���� � ����� ��������")
omen:block(i,{ || PrnBol() })

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("��ନ஢���� ������������")
omen:addPrompt(++i,"��ନ஢���� �� �믫�祭��� ��ࠡ�⭮� �����")
omen:block(i,{ || ZapDolg() })

omen:add("��ନ஢���� ��������")
omen:addPrompt(++i,"����� ���⥦��� ��������")
omen:block(i,{ || FormVed() })

omen:add("���४�஢�� ��������")
omen:addPrompt(++i,"���४�஢�� ���⥦��� ��������")
omen:block(i,{ || VedVed() })

omen:add("����� ��������")
omen:addPrompt(++i,"����� ���⥦��� ��������")
omen:block(i,{ || PrnVed() })

omen:add("����� �������� � ����")
omen:addPrompt(++i,"����� ���⥦��� �������� � ����")
omen:block(i,{ || PrnVedb() })

omen:add("����� �������� � ����y")
omen:addPrompt(++i,"����� ���⥦��� �������� � ����")
omen:block(i,{ || PrnVedby() })

omen:add("�����⨥ ��������")
omen:addPrompt(++i,"�����⨥ ���⥦��� ��������")
omen:block(i,{ || CloseVed() })

omen:add("���४�஢�� ������������")
omen:addPrompt(++i,"���४�஢�� ������������ �� ��ࠡ�⭮� ����")
omen:block(i,{ || VedDolg() })

omen:add("���४�஢�� ��娢�")
omen:addPrompt(++i,"���४�஢�� ��娢� 㤥ঠ���")
omen:block(i,{ || VedArx() })

omen:add("��ᬮ�� ������������")
omen:addPrompt(++i,"��ᬮ�� ������������ �� ��ࠡ�⭮� ����")
omen:block(i,{ || LookDolg() })

omen:add("��ࠢ�� �� ������������")
omen:addPrompt(++i,"����� �ࠢ�� �� ������������ �� ��ࠡ�⭮� ����")
omen:block(i,{ || SpravDolg() })

omen:add("���⪠ ����")
omen:addPrompt(++i,"�������� ���ଠ樨 �� ����")
omen:block(i,{ || PackVed() })

omen:add("��稥 㤥ঠ���")
omen:addPrompt(++i,"������� ���� 㤥ঠ���")
omen:block(i,{ || VedProc() })

omen:add("�����⨥ ���� 㤥ঠ���")
omen:addPrompt(++i,"�����⨥ ���� 㤥ঠ���")
omen:block(i,{ || CloseProc() })

omen:add("������� ���������")
omen:addPrompt(++i,"��ନ஢���� � ����� ᢮���� ��������")
omen:block(i,{ || PrnSvod() })

omen:add("��������� �������")
omen:addPrompt(++i,"��ନ஢���� � ����� �������� �뤠� ⠫���� �� 嫥�")
omen:block(i,{ || XlebVed() })

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("��娢�஢���� ")
omen:addPrompt(++i,"��娢�஢���� ���᫥���� ��ࠡ�⭮� �����")
omen:block(i,{ || Nakopl() })

omen:add("���४�஢�� ���������")
omen:addPrompt(++i,"���४�஢�� ��娢� 㤥ঠ��� ")
omen:block(i,{ || VedNakYd() })

omen:add("���४�஢�� ����������")
omen:addPrompt(++i,"���४�஢�� ��娢� ���᫥��� ")
omen:block(i,{ || VedNakNach() })

omen:add("��������� 1��")
omen:addPrompt(++i,"��ନ஢���� � ����� �������� ��� 1�� ")
omen:block(i,{ || VedomNal() })

omen:add("��ନ஢���� ����� 3")
omen:addPrompt(++i,"��ନ஢���� ������ ��� ���� ����� 3 ")
omen:block(i,{ || Forma3F() })

omen:add("���४�஢�� ����� 3")
omen:addPrompt(++i,"���४�஢�� ������ ����� 3 ")
omen:block(i,{ || VedNalF3() })

omen:add("����� ����� 3")
omen:addPrompt(++i,"����� �ࠢ�� �� ����� 3 ")
omen:block(i,{ || FormaF3p() })

omen:add("��ࠢ�� � ���")
omen:addPrompt(++i,"����� �ࠢ�� � ��� ")
omen:block(i,{ || PrnSpr() })

omen:add("���� ������ �3 � �/�")
omen:addPrompt(++i,"���� ������ �� ��� 3 � ��ࠡ���� ����� ")
omen:block(i,{ || ZapNal() })

omen:add("��ࠢ�� �� ���ᨨ")
omen:addPrompt(++i,"����� �ࠢ�� �� ���ᨨ ")
omen:block(i,{ || PrnPens() })

omen:add("��ࠢ�� �� ��")
omen:addPrompt(++i,"����� �ࠢ�� �� �� ")
omen:block(i,{ || PrnCoc() })

omen:add("��ࠢ�� �� ���ࠡ")
omen:addPrompt(++i,"����� �ࠢ�� �� ���ࠡ ")
omen:block(i,{ || Prnbez() })

omen:add("����������������������������")
omen:addPrompt(++i,"")
omen:hide := i

omen:add("���४�஢�� ���")
omen:addPrompt(++i,"���४�஢�� ��������� ����஢ ࠡ�⭨���")
omen:block(i,{ || VedSuper() })

omen:add("� �孮�����")
omen:addPrompt(++i,"�뢮� ��⪮� ���ଠ樨 � �孮����� ������� ����")
omen:block(i,{ || BautNal() })

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

//////////////////////////////////////////////////
i := 0
omen:=oMenuNew()

omen:add("���� ������")
omen:addPrompt(++i,"������� ������ �� 㤥ঠ��� ����㭠���� ��� ")
omen:block(i,{ || GicVvod() })

omen:add("��ᬮ�� ��娢� ������")
omen:addPrompt(++i,"��ᬮ�� ��娢� ������ ")
omen:block(i,{ || GicVvod(999) })

omen:add("��娢�஢����")
omen:addPrompt(++i,"��娢�஢���� ������ ")
omen:block(i,{ || GicArx() })

omen:add("��������")
omen:addPrompt(++i,"��ନ஢���� �������⥩ � ������ ��� ��।�� � �� ")
omen:block(i,{ || GicPrn() })

omen:add("����� ������ ������")
omen:addPrompt(++i,"����� ������ ������ ")
omen:block(i,{ || PrnZajv() })
***
omen:add("���।������ �᫥����� ࠡ�⭨���")
omen:addPrompt(++i,"���।������ �᫥����� ࠡ�⭨��� ")
omen:block(i,{ || Pokaztlg() })
***
omen:add("���।������  ࠡ����� � �����")
omen:addPrompt(++i,"���।������ ࠡ����� � ����� ")
omen:block(i,{ || Raspred() })
***
omen:add("���᫥���� ��௫��� ���騭��    ")
omen:addPrompt(++i,"���᫥���� ��௫�� ���騭��    ")
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
        @ 01,01 wsay "������ ����   " wget __dData Pict "@d" valid !empty(__dData)
        @ 02,01 wsay "���������� �/�" wget __nMin  pict "999999999999.99" valid __nMin > 0
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
        @ 01,01 wsay "��� ����   " wget __dData Pict "@d" valid !empty(__dData)
     else
        @ 01,01 wsay "�������쭠� �/�" wget __nMin  pict "999999999999.99" valid __nMin > 0
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
Function Fornak()  // �㬬�஢ �� �� ������� �� ⠡
Local i, nSumMin := nSumMat := 0, nData := 200301, kData := 200312
Local ColorOld := SetColor(sset[32]+","+sset[2]), GetList := {}
Local CursorOld := SetCursor(1)

BEGIN SEQUENCE
S_Open_S(12,30,17,64,sset[32]+","+sset[2])
@ 01,01 wsay "������: ���� ��砫�" wget nData pict "999999" valid nData > 199612
@ 02,01 wsay "              ���� " wget kData pict "999999" valid kData > 199612 .and. ;
                                                           kData >= nData
@ 03,01 wsay "⠡���� �����     " wget nSumMin pict "999999" valid nSumMin > 0
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
Function Fornaky()  // �㬬�஢ �� �� ������� �� ⠡
Local i, nSumMin := nSumMat := 0, nData := 200301, kData := 200312
Local ColorOld := SetColor(sset[32]+","+sset[2]), GetList := {}
Local CursorOld := SetCursor(1)

BEGIN SEQUENCE
S_Open_S(12,30,17,64,sset[32]+","+sset[2])
@ 01,01 wsay "������: ���� ��砫�" wget nData pict "999999" valid nData > 199612
@ 02,01 wsay "              ���� " wget kData pict "999999" valid kData > 199612 .and. ;
                                                           kData >= nData
@ 03,01 wsay "⠡���� �����     " wget nSumMin pict "999999" valid nSumMin > 0
@ 04,01 wsay "��� 㤥ঠ���       " wget nSumMat pict "999"

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
