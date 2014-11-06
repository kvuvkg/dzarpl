erase dZarpl.exe
Set Lib=D:\Clip53\lib
Set include=D:\Clip53\include
D:\Clip53\Bin\clipper dZarpl
if not errorlevel 1 D:\Clip53\bin\exospace FI dZarpl LIB ctp,_DBFCDX,DBFCDX,MyLib
erase dZarpl.obj
