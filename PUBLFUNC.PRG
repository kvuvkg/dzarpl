#Define NTXCDX ".Cdx"
#include "inkey.ch"
#include "S_win.ch"
///////////////////////////////////////////////////////////////////////////
Function OpenDbf_(cDataBase,Status,cAlias,nSeconds,lPrint)
Local nRecno, nLastRec, i, nPos, cDir := "", aFile := {}
aadd(aFile, {{"OTPU","========= ���᪭�� ����᪠ ============="},;
             {{"OTPU","str(Cex,4)+str(Tnr,6)",.f.}},;
             { {"Npach",  "N",02,00,"��᫮ �� ����� �뤠���� ���᪭�"},;
               {"DataR",  "D",08,00,"��� ����"},;
               {"Cex",    "N",04,00,"���"},;
               {"Tnr",    "N",06,00,"������� No"},;
               {"Data",   "D",08,00,"��� ��砫� ���᪠"},;
               {"Kdn",    "N",03,00,"���-�� ���� ���᪠"},;
               {"SredSum","N",15,00,"�।���������"},;
               {"Po",     "N",01,00,"�ਧ��� ���᪠"},;
               {"Pr",     "N",01,00,"�ਧ��� �믫���"},;
               {"Priz",   "N",01,00,"�ਧ��� ����"},;
               {"Vo1",    "N",03,00,"��� ������ 1 ���-�"},;
               {"Dat1",   "N",02,00,"��� ��砫� ���᪠ 1 ���-�"},;
               {"Kd1",    "N",02,00,"���-�� ���� ���᪠ � 1 ���-�"},;
               {"Sym1",   "N",15,00,"�㬬� �� 1 ���-�"},;
               {"Vo2",    "N",03,00,"��� ������ 2 ���-�"},;
               {"Dat2",   "N",02,00,"��� ��砫� ���᪠ 2 ���-�"},;
               {"Kd2",    "N",02,00,"���-�� ���� ���᪠ � 2 ���-�"},;
               {"Sym2",   "N",15,00,"�㬬� �� 2 ���-�"},;
               {"Vo3",    "N",03,00,"��� ������ 3 ���-�"},;
               {"Dat3",   "N",02,00,"��� ��砫� ���᪠ 3 ���-�"},;
               {"Kd3",    "N",02,00,"���-�� ���� ���᪠ � 3 ���-�"},;
               {"Sym3",   "N",15,00,"�㬬� �� 3 ���-�"},;
               {"Sym12",  "N",15,00,"�㬬� �� 12 ���"},;
               {"SymKAS", "N",15,00,"�㬬� �믫�祭��� � �����"}}})
aadd(aFile, {{"SPRKO","========= ��ࠢ ���� ���᪠ ============="},;
             {{"SPRKO","dtos(DataC)",.f.}},;
             { {"DataC",  "D",08,00,"��� �"},;
               {"DataP",  "D",08,00,"��� ��"},;
               {"Kf",     "N",06,03,"�����樥��"}}})
aadd(aFile, {{"NEZARP","========= �� �뤠���� ��௫�� ============="},;
             {{"NEZARP","str(Ksp,4)+str(Tnr,6)",.f.}},;
             { {"Ksp",    "N",04,00,"���"},;
               {"Tnr",    "N",06,00,"⠡���� �����"},;
               {"SumNach","N",15,00,"�㬬� ���᫥��"},;
               {"SumYd",  "N",15,00,"�㬬� 㤥ঠ��"},;
               {"SumNar", "N",15,00,"�㬬� �� �㪨"}}})
aadd(aFile, {{"SPRKB","========= ��ࠢ ���� ���쭨��� ============="},;
             {{"SPRKB","dtos(DataC)",.f.}},;
             { {"DataC",  "D",08,00,"��� �"},;
               {"DataP",  "D",08,00,"��� ��"},;
               {"Kf",     "N",06,03,"�����樥��"}}})
aadd(aFile, {{"BOL","========= ���쭨�� ����� ============="},;
             {{"BOL","str(Bl,8)",.f.}},;
             { {"Bl",     "N",08,00,"No ���쭨筮�� ���"},;
               {"Tnr",    "N",06,00,"������� �����"},;
               {"Dt",     "D",08,00,"��� ���� ��"},;
               {"DtBol",  "D",08,00,"��� ��"},;
               {"Cex",    "N",04,00,"���"},;
               {"Dni1",   "N",08,02,"���/��� 1 �����"},;
               {"Dni2",   "N",08,02,"���/��� 2 �����"},;
               {"Kvo",    "N",03,00,"���"},;
               {"Gr",     "N",01,00,"��㯯� �������"},;
               {"Vr",     "N",02,00,"��� ����"},;
               {"Proz",   "N",03,00,"% ������"},;
               {"Tm",     "N",06,02,"����/���"},;
               {"Sum1",   "N",15,00,"�㬬� 1 �����"},;
               {"Sum2",   "N",15,00,"�㬬� 2 �����"},;
               {"SrZar",  "N",15,00,"�।��� ��ࠡ�⮪"},;
               {"Tarif",  "N",15,00,"���"},;
               {"SumN",   "N",15,00,"�㬬� ���᫥��"}}})

aadd(aFile, {{"NAKNACH","========= ��娢 ���᫥��� ============="},;
             {{"NAKNACH","str(TN,6)+str(d_Nach,6)+Vo",.f.}},;
             { {"Tn",     "N",06,00,"������� �����"},;
               {"D_Vip",  "N",06,00,"��� ���� "},;
               {"D_Nach", "N",06,00,"��� ���᫥���"},;
               {"Vo",     "C",03,00,"��� ������"},;
               {"Dn",     "N",08,02,"���/��� "},;
               {"Sum",    "N",15,02,"�㬬� ���᫥��"}}})
                        
aadd(aFile, {{"NAKYD","========= ��娢 ���ঠ��� ============="},;
             {{"NAKYD","str(TN,6)+str(D_Yd,6)",.f.}},;
             { {"Tn",     "N",06,00,"������� �����"},;
               {"D_Yd",   "N",06,00,"��� 㤥ঠ��� "},;
               {"OblSum", "N",15,02,"���������� �㬬�"},;
               {"NOblSum","N",15,02,"�� ���������� �㬬�"},;
               {"Kvu1",   "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd1", "N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu2",   "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd2", "N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu3",   "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd3", "N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu4",   "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd4", "N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu5",   "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd5", "N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu6",   "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd6", "N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu7",   "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd7", "N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu8",   "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd8", "N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu9",   "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd9", "N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu10",  "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd10","N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu11",  "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd11","N",15,02,"�㬬� 㦥ठ��� "},;
               {"Kvu12",  "C",03,00,"��� 㤥ঠ���"},;
               {"SumYd12","N",15,02,"�㬬� 㦥ठ��� "}}})
               
aadd(aFile, {{"NAL","========= ������ ============="},;
             {{"NAL","str(DatG,6)",.f.}},;
             { {"DatG",   "N",06,00,"���"},;
               {"Min",    "N",07,02,"����������� ������"},;
               {"S1_1",   "N",09,02,"���ࢠ� �� "},;
               {"S2_1",   "N",09,02,"���ࢠ� �� "},;
               {"Pr_1",   "N",09,02,"% ���᫥���"},;
               {"Sd_1",   "N",09,02,"����� �㬬� "},;
               {"S1_2",   "N",09,02,"���ࢠ� �� "},;
               {"S2_2",   "N",09,02,"���ࢠ� �� "},;
               {"Pr_2",   "N",09,02,"% ���᫥���"},;
               {"Sd_2",   "N",09,02,"����� �㬬� "},;
               {"S1_3",   "N",09,02,"���ࢠ� �� "},;
               {"S2_3",   "N",09,02,"���ࢠ� �� "},;
               {"Pr_3",   "N",09,02,"% ���᫥���"},;
               {"Sd_3",   "N",09,02,"����� �㬬� "},;
               {"S1_4",   "N",09,02,"���ࢠ� �� "},;
               {"S2_4",   "N",09,02,"���ࢠ� �� "},;
               {"Pr_4",   "N",09,02,"% ���᫥���"},;
               {"Sd_4",   "N",09,02,"����� �㬬� "},;
               {"S1_5",   "N",09,02,"���ࢠ� �� "},;
               {"S2_5",   "N",09,02,"���ࢠ� �� "},;
               {"Pr_5",   "N",09,02,"% ���᫥���"},;
               {"Sd_5",   "N",09,02,"����� �㬬� "},;
               {"S1_6",   "N",09,02,"���ࢠ� �� "},;
               {"S2_6",   "N",09,02,"���ࢠ� �� "},;
               {"Pr_6",   "N",09,02,"% ���᫥���"},;
               {"Sd_6",   "N",09,02,"����� �㬬� "},;
               {"S1_7",   "N",09,02,"���ࢠ� �� "},;
               {"S2_7",   "N",09,02,"���ࢠ� �� "},;
               {"Pr_7",   "N",09,02,"% ���᫥���"},;
               {"Sd_7",   "N",09,02,"����� �㬬� "},;
               {"S1_8",   "N",09,02,"���ࢠ� �� "},;
               {"S2_8",   "N",09,02,"���ࢠ� �� "},;
               {"Pr_8",   "N",09,02,"% ���᫥���"},;
               {"Sd_8",   "N",09,02,"����� �㬬� "},;
               {"S1_9",   "N",09,02,"���ࢠ� �� "},;
               {"S2_9",   "N",09,02,"���ࢠ� �� "},;
               {"Pr_9",   "N",09,02,"% ���᫥���"},;
               {"Sd_9",   "N",09,02,"����� �㬬� "},;
               {"S1_10",  "N",09,02,"���ࢠ� �� "},;
               {"S2_10",  "N",09,02,"���ࢠ� �� "},;
               {"Pr_10",  "N",09,02,"% ���᫥���"},;
               {"Sd_10",  "N",09,02,"����� �㬬� "} }})

aadd(aFile, {{"NALF3","========= ��ଠ 3 ============="},;
             {{"NALF3","str(Tn,6)",.f.}},;
             { {"Tn",     "N",06,00,"������� �����"},;
               {"S1",     "N",09,02,"�㬬� �����. 1"},;
               {"S1_1",   "N",09,02,"�㬬� ��� ����� 1.1"},;
               {"S2_1",   "N",09,02,"�㬬� ���᫥��� �� ��⥩ 2.1"},;
               {"S2_2",   "N",09,02,"�㬬� ���᫥��� �죮�� 2.2"},;
               {"S3",     "N",09,02,"�㬬� ������ �� �������"},;
               {"S4",     "N",09,02,"�㬬� ������ �� �������"},;
               {"S5",     "N",09,02,"�㬬� ������ 㤥ঠ�����"},;
               {"S6",     "N",09,02,"������"} }})

aadd(aFile, {{"YDPROC","======= ��稥 㤥ঠ��� ========"},;
             {{"YDPROCT","str(Tn,6)",.f.},;
              {"YDPROCD","str(Data,6)+str(Tn,6)",.f.}},;
             { {"Tn",     "N",06,00,"������� �����"},;
               {"Ksp",    "C",04,00,"��� "},;
               {"Summa",  "N",09,02,"�㬬� 㤥ঠ����"},;
               {"Data",   "N",06,00,"���"},;
               {"Kvu",    "C",03,00,"��� 㤥ঠ���"}}})

aadd(aFile, {{"GIC","========= ����㭠��� ��㣨 ======"},;
             {{"Gic","str(Tn,6)+dtos(Data)",.f.}},;
             { {"Tn",     "N",06,00,"������� �����"},;
               {"Data",   "D",08,00,"��� 㤥ठ���"},;
               {"KodGkx", "N",08,00,"�/� ����⯫��"},;
               {"GmGkx",  "N",04,00,"����� ������"},;
               {"SumGkx", "N",09,02,"�㬬� ������"},;
               {"KodVkx", "N",08,00,"�/� �������� ����"},;
               {"GmVkx",  "N",04,00,"����� ������"},;
               {"SumVkx", "N",09,02,"�㬬� ������"},;
               {"KodPtc", "N",08,00,"�/� �����"},;
               {"GmPtc",  "N",04,00,"����� ������"},;
               {"SumPtc", "N",09,02,"�㬬� ������"},;
               {"KodGaz", "N",08,00,"�/� ���"},;
               {"GmGaz",  "N",04,00,"����� ������"},;
               {"SumGaz", "N",09,02,"�㬬� ������"},;
               {"KodEl",  "N",08,00,"�/� �/���ࣨ�"},;
               {"GmEl",   "N",04,00,"����� ������"},;
               {"SumEl",  "N",09,02,"�㬬� ������"},;
               {"Zajv",   "N",06,00,"N ������"},;
               {"DZajv",  "D",08,00,"��� ������"} }})

aadd(aFile, {{"GICARX","===== ����㭠��� ��㣨  ����� ======"},;
             {{"GicArx","str(Tn,6)+dtos(Data)",.f.}},;
             { {"Tn",     "N",06,00,"������� �����"},;
               {"Data",   "D",08,00,"��� 㤥ठ���"},;
               {"KodGkx", "N",08,00,"�/� ����⯫��"},;
               {"GmGkx",  "N",04,00,"����� ������"},;
               {"SumGkx", "N",09,02,"�㬬� ������"},;
               {"KodVkx", "N",08,00,"�/� �������� ����"},;
               {"GmVkx",  "N",04,00,"����� ������"},;
               {"SumVkx", "N",09,02,"�㬬� ������"},;
               {"KodPtc", "N",08,00,"�/� �����"},;
               {"GmPtc",  "N",04,00,"����� ������"},;
               {"SumPtc", "N",09,02,"�㬬� ������"},;
               {"KodGaz", "N",08,00,"�/� ���"},;
               {"GmGaz",  "N",04,00,"����� ������"},;
               {"SumGaz", "N",09,02,"�㬬� ������"},;
               {"KodEl",  "N",08,00,"�/� �/���ࣨ�"},;
               {"GmEl",   "N",04,00,"����� ������"},;
               {"SumEl",  "N",09,02,"�㬬� ������"},;
               {"Zajv",   "N",06,00,"N ������"},;
               {"DZajv",  "D",08,00,"��� ������"} }})

aadd(aFile, {{"ZAJV","========= N ������ ======"},;
             {},;
             { {"Zajv",  "N",06,00,"N ������"}  }})
               
if lPrint <> Nil
  cFile := cDatabase
  if ( nPos := ascan(aFile,{|x| x[1][1]==Upper(cFile)}) ) == 0 ; return ( Nil ) ; End
  Set(20,"PRINT")
  @ prow()+1,00 say "������� 䠩��: "+cFile+" "+aFile[nPos][1][2]
  @ prow()+1,00 say "-----------------------------------------------------"
  @ prow()+1,00 say " ������.|���|�����|���| ������������               "
  @ prow()+1,00 say "-----------------------------------------------------"
  for i := 1 to len(aFile[nPos][3])
      @ prow()+1,00 say aFile[nPos][3][i][1]
      @ prow(),10 say aFile[nPos][3][i][2]
      @ prow(),15 say aFile[nPos][3][i][3] pict "99"
      @ prow(),20 say aFile[nPos][3][i][4] pict "99"
      @ prow(),25 say aFile[nPos][3][i][5]
  next
  @ prow()+1,00 say "-----------------------------------------------------"
  @ prow()+1,00 say "           ����:                                     "
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
  @ 01,01 wsay padc("������..",MaxCol()-1)
  OpenDbf_(alltrim(cName),,,,999)
  Set(20,"SCREEN")
End
Set(20,"SCREEN")
S_wClose()
Return ( Nil )
////////////////////////////////////////////////////////////////////////////
Function ZapInf()  // ����� ���ଠ樨
Local nMesR := month(sset[121])  // ����� ����
Local cKsp, nRecno, nLastrec, nRec, nS1, nS2, i, im, cVo, cVo_

BEGIN SEQUENCE
if !OpenDbf_("NEZARP")       ; break ; End
if !OpenList()               ; break ; End
if !M_Use("ssp",,,,"DBFNTX") ; break ; End

nLastRec := ssp->(LastRec())
ssp->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "�������..."
@ 01,42 wsay "����� ������ ���ଠ樨"
nRecno := "[ �� ����砭�� �㤥� ����� ��㪮��� ᨣ��� ]"
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
           S_Err({"������� ����� - "+Base->Tn,"��������� � �ࠢ�筨��"})
        else
           nRec := SuperLis->Base_Rec   // No ����� � BASE
           if Base->(Recno()) <> nRec
             S_Err({"������� ����� - "+Base->Tn,"�� ᮢ������ N �����"})
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
function ZapNeVud() // ������ �� �뤠���� �/�
local nMesR := substr(dtos(sset[121]),5,2), nRecno, nLastrec
Local i, im, cVo, nRec

BEGIN SEQUENCE
if !OpenDbf_("NEZARP")       ; break ; End
if !OpenList()               ; break ; End
if !M_Use("ssp",,,,"DBFNTX") ; break ; End

nLastRec := NeZarp->(LastRec())
ssp->(DbGoTop())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 wsay "�������..."
@ 01,42 wsay "����� ������ ���ଠ樨"
nRecno := "[ �� ����砭�� �㤥� ����� ��㪮��� ᨣ��� ]"
@ S_wRow()+00,S_wCol()+(S_wMaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
While ( !Nezarp->(eof()) )
  cTn := strzero(Nezarp->Tnr,6)
  if !SuperLis->(DbSeek(cTn))
    S_Err({"������� ����� - "+cTn,"��������� � �ࠢ�筨��"})
  else
   cVo  := "Base"+SuperLis->Ksp
   nRec := SuperLis->Base_Rec   // No ����� � BASE
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
function ZipBase() // ���⪠ ����

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
