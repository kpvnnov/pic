@echo off
echo Assembling
tasm /ml /m2 /t /zi  %1
if not exist %1.obj goto err
rem tlink /v/l %1
echo ... all right.
goto end
:err 
echo .        !----------------------------!
echo .        !       Found errors.        !
echo .        !____________________________!
:end