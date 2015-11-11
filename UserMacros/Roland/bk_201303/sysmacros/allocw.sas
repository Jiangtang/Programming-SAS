/*<pre><b>
/ Program      : allocw.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 30-Jul-2007
/ SAS version  : 9.1.3
/ Client       : xenuyama
/ Office       : tokyo
/ Drug         : DRUG001
/ Protocol     : DRUG001C3001
/ Increment    : 24weeks
/ Purpose      : Spectre (Clinical) example macro to allocate data libraries and
/                formats in write mode.
/ SubMacros    : none
/ Notes        : This is just an example macro
/ Usage        : %allocw
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ 
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/=============================================================================*/

%macro allocw;

  %*- declare which libref to use for the "protocol" and "titles" dataset -;
  %global _ptlibref_;
  %let _ptlibref_=der;

  libname raw "C:\pharma\xenuyama\tokyo\DRUG001\DRUG001C3001\24weeks\data\raw"
  access=readonly;
  libname der "C:\pharma\xenuyama\tokyo\DRUG001\DRUG001C3001\24weeks\data\derived";
  libname stats "C:\pharma\xenuyama\tokyo\DRUG001\DRUG001C3001\24weeks\data\analysis";

  *- assign format libraries for increment, protocol, drug, office and client -;
  libname iformats "C:\pharma\xenuyama\tokyo\DRUG001\DRUG001C3001\24weeks\formats";
  libname pformats "C:\pharma\xenuyama\tokyo\DRUG001\DRUG001C3001\formats";
  libname dformats "C:\pharma\xenuyama\tokyo\DRUG001\formats";
  libname oformats "C:\pharma\xenuyama\tokyo\formats";
  libname cformats "C:\pharma\xenuyama\formats";

  options fmtsearch=(iformats.formats pformats.formats dformats.formats
   oformats.formats cformats.formats);
  run;

  %put NOTE: fmtsearch=%sysfunc(getoption(fmtsearch));

%mend allocw;
