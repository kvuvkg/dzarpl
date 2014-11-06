cls
cFile := "SEBA*.Dbf"
if Empty(aFile := Directory(cFile))
   Return ( Nil )
End
for i := 1 to Len(aFile)
  cFile := aFile[i][1]
  use (cFile) new Alias Seba
  Seba->(DbGotop())  
  While !Seba->(eof())
    iSum := int(round(Seba->Cd/100000,0))
    Seba->Cd := iSum
    iSum := int(round(Seba->Uder/100000,0))
    Seba->Uder := iSum
    for j := 1 to 12
       cSvon_:= "SVON"+alltrim(str(j,2))
       iSum  := int(round(Seba->&cSvon_/100000,0))
       Seba->&cSvon_ := iSum
    next
    ? cFile, Seba->(Recno())
    Seba->(DbSkip(1))
  End
  use
Next
return ( nil )


