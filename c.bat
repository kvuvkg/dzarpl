erase %1.exe
clipper %1 /B /M /N
if not errorlevel 1 rtlink file %1, D:\CLIP\LIB\ftools1 LIB ftoolsx, ftools1, fproplus
erase %1.obj
