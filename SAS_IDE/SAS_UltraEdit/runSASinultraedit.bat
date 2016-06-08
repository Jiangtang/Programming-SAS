
set CONFIGSAS=C:\Program Files\SASHome\SASFoundation\9.3\nls\en\SASV9.CFG
set AUTOEXECSAS=C:\Users\jhu\Documents\GitHub\Programming-SAS\autoexec.sas


Set EXESAS=C:\Program Files\SASHome\SASFoundation\9.3\sas.exe
"%EXESAS%" ^
 -CONFIG "%CONFIGSAS%" ^
 -autoexec "%AUTOEXECSAS%" -sysin %1 -log %2 -nodms 
