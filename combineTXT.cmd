@echo off

:: COMBINETXT V1.1 (fusionner des fichiers txt)
:: V1.1 2014.02.06
:: 
:: THIS SCRIPT READS TXTs FROM FOLDER2 AND ADDED THEM TO CORRESPOND FILES IN FOLDER1
::
:: FOR EXAMPLE, ACDC_10000.txt ACDC_10100.txt etc FROM FOLDER2 WILL BE ADDED TO FILES
:: ACDC_10000.txt ACDC_10100.txt and so on IN FOLDER1. IN ADDITON, *boundary WILL BE
:: REMOVED FROM ALL HEADERS IN FOLDER2
::
:: IT USES UNIX UTILITIES PLACED IN FOLDER e:\usr\%username%\therm 
:: WHICH GOES WITH CALCULABA: GREP, UNIQ, SED and CAT. CAT IS DELIVERED FROM V1.5g8
::
:: HOW TO USE
::
:: BE SURE THAT YOU HAVE CREATED A BACKUP OF YOUR SOURCE FILES!
::
:: PUT THE FILES TO BE MODIFIED IN FOLDER1, AND THE FILES TO BE READ IN FOLDER2
:: RUN THE COMBINETXT.CMD AND WAIT

  set PATH=e:\usr\%username%\therm;%PATH%
  del *.lst >nul 2>&1
  
  if not exist e:\usr\%username%\therm\cat.exe xcopy /y \\ws-3\e\usr\sr01201\therm\cat.exe e:\usr\%username%\therm >nul 2>&1
  if not exist e:\usr\%username%\therm\sed.exe xcopy /y \\ws-3\e\usr\sr01201\therm e:\usr\%username% >nul 2>&1
  if not exist e:\usr\%username%\therm\uniq.exe (
    echo "PUT SED.EXE (>v4.0.1), GREP.EXE, UNIQ.EXE TO e:\usr\%username%\therm"
    goto fin
    )

:: scan source folder for TXTs
  dir *.txt folder1 /s /b /-p /o:gn | sort | grep txt | uniq> _list2.lst

:: scan destination folder for TXTs, make a backup
  dir *.txt folder2 /s /b /-p /o:gn | sort | grep txt | uniq> _list1.lst

:: add sign to EOF
  if exist _list1.lst echo hare>> _list1.lst

:: clean lists
  :: 1) because windows 'dir' command creates list with excess data including all folders
  sed -i -e "/folder2/d" _list1.lst
  sed -i -e "/folder1/d" _list2.lst
    :: 2) and because we do not need to process some txt's
    sed -i -e "/decoupage/d" _list1.lst
    rem sed -i -e "/NT11/d" _list1.lst
    sed -i -e "/Sets_nodes/d" _list1.lst

:cycle
:: read 1st line and remove it
  set /p dest1=<_list1.lst
  set /p src1=<_list2.lst
  ::echo SRC %src1%
  ::echo DST %dest1%
  echo %dest1%
    sed -i -e "1d" _list1.lst
    sed -i -e "1d" _list2.lst

:: remove *boundary in source
  sed -i -e "/boundary/d" %src1%
  
:: clean temp files
  del sed* >nul 2>&1

:: add 2nd file to 1st
  cat %src1% >> %dest1%
  
:: remove blank lines
::  sed -i -e "/./!d" %dest1%

:: read next line and check for EOF
  set /p dest1=<_list1.lst
  if /i %dest1% neq hare goto :cycle
  
  echo Completed!
  del hare *.lst >nul 2>&1
  
  :fin
  pause
