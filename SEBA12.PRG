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
    for nKol := 1 to 11
        Seba->(DbSkip(1))
    next
    for j := 1 to 12
       cKwn_:= "KMN"+alltrim(str(j,2))
       Seba->&cKwn_ := "12"
    next
    ? cFile, Seba->(Recno())
    Seba->(DbSkip(1))
  End
  use
Next
return ( nil )


