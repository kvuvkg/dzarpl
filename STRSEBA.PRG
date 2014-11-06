para cNum
cFile := "Seba"+strzero(val(cNum),4)
oFile := "Old_"+strzero(val(cNum),4)
if !File(cFile+".Dbf")
  S_Err({" файл отсутствует"})
  return ( Nil )
End
use (cFile) new Alias Old
a := Old->(DbStruct())
nLen := len(a)
for i := 1 to 12
  aadd(a,{"DnCh"+alltrim(str(i,2)),"N",06,2})
Next  
iFile := "new"+strzero(val(cNum),4)
DbCreate((iFile),a)
use (iFile) new alias new
nRec := Old->(LastRec())
S_Line_N(18,04,65,nRec,1)
nR := 0
Old->(DbGoTop())
While !Old->(eof())
  New->(DbAppend())
  For i := 1 to nLen
     New->(FieldPut(i,Old->(FieldGet(i))))
  Next
  S_Line_N(18,04,65,nRec,++nR)
  Old->(DbSkip(1))
End
S_Beep(1)
S_Line_N()
DbCloseAll()
fRename( ( cFile+".Dbf"), ( oFile+".Dbf") )
fRename( ( iFile+".Dbf"), ( cFile+".Dbf") )
return ( nil )

