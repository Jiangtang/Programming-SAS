/*<pre><b>
/ Program      : allocr.sas
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
/                formats in read mode.
/ SubMacros    : none
/ Notes        : This is just an example macro
/ Usage        : %allocr
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

%macro allocr;

  %*- declare which libref to use for the "protocol" and "titles" dataset -;
  %global _ptlibref_;
  %let _ptlibref_=der;

  libname der "C:\pharma\xenuyama\tokyo\DRUG001\DRUG001C3001\24weeks\data\derived"
  access=readonly;
  libname stats "C:\pharma\xenuyama\tokyo\DRUG001\DRUG001C3001\24weeks\data\analysis"
  access=readonly;

  *- assign format libraries for increment, protocol, drug, office and client -;
  libname iformats "C:\pharma\xenuyama\tokyo\DRUG001\DRUG001C3001\24weeks\formats"
  access=readonly;
  libname pformats "C:\pharma\xenuyama\tokyo\DRUG001\DRUG001C3001\formats"
  access=readonly;
  libname dformats "C:\pharma\xenuyama\tokyo\DRUG001\formats" access=readonly;
  libname oformats "C:\pharma\xenuyama\tokyo\formats" access=readonly;
  libname cformats "C:\pharma\xenuyama\formats" access=readonly;

  options fmtsearch=(iformats.formats pformats.formats dformats.formats
   oformats.formats cformats.formats);
  run;

  %put NOTE: fmtsearch=%sysfunc(getoption(fmtsearch));

%mend allocr;
