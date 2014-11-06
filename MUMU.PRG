Local cFile := "Base*.Dbf", cDir := "c:\sveta\"

if Empty(aFile := Directory(cDir+cFile))
   Return ( Nil )
End
nLastRec := Len(aFile)
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
for m := 1 to Len(aFile)
  cFile := aFile[m][1]
  @ 01,42 say padc(cFile,10)
  use (cDir+cFile) new Alias Svet
  use (cFile) new Alias Base
  Index on tn to Base
  Svet->(DbGotop())
  While !Svet->(eof())
    if Svet->Tn <> "******" .and. Base->(DbSeek(Svet->Tn))
       Base->kpm := Svet->Kpm
    End
    Svet->(DbSkip(1))
  End
  DbCloseAll()
  S_Line_N(18,04,65,nLastRec,++nRecno)
Next
S_Line_N()
