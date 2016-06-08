%macro utcomprc(base=_default_,compare=_default_,debug=_default_);
/*soh===========================================================================
  Eli Lilly and Company
   PROGRAM NAME    : utcomprc.sas            Temporary Object Prefix: none
   PROGRAMMER      : Greg Steffens
   DESCRIPTION     : Puts a message to the log base on the return code from
                      PROC COMPARE
   LANGUAGE/VERSION: SAS/Version 8
   INITIATION DATE : dd mmm yyyy
   VALIDATOR       : 
   INPUT FILE(S)   : none
   OUTPUT FILE(S)  : none
   XTRNL PROG CALLS: none
--------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description
   -------- -------- -------- --------------------------------------------------
   BASE     optional base     The base data set name in PROC COMPARE
   COMPARE  optional compare  The compare data set name in PROC COMPARE
   DEBUG    required 0        %ut_logical value specifying whether debug mode is
                               on or off

  Usage Notes:
   Call this macro immediately after PROC COMPARE and you will get a summary
   message in the SAS log file describing the results of the comparison.

  Future enhancement ideas:

--------------------------------------------------------------------------------
                         REVISION HISTORY
================================================================================
  REV#  Date       User ID   Description
  ----  ---------  --------  ---------------------------------------------------
  001   ddmmmyyyy
eoh===========================================================================*/
%ut_parmdef(base,base,_pdmacroname=comprc,_pdrequired=0)
%ut_parmdef(compare,compare,_pdmacroname=comprc,_pdrequired=0)
%ut_parmdef(debug,0,_pdmacroname=comprc,_pdrequired=1)
%ut_logical(debug)
%local comprc2 comprc10;
%let comprc10 = &sysinfo;
%let comprc2 = %sysfunc(putn(&sysinfo,binary16.));
%if %bquote(&base) = %then %let base = base;
%if %bquote(&compare) = %then %let compare = compare;
%if &comprc10 = 0 %then %put UNOTE(comprc): &base is identical to &compare;
%else %do;
  %if %bquote(&base) ^= base | %bquote(&compare) ^= compare %then
   %put UWARNING(comprc): PROC COMPARE of  base:&base  compare:&compare;
  %put UWARNING(comprc): PROC COMPARE return code is sysinfo=&sysinfo
   base10:&comprc10 base2:&comprc2;
  %if %substr(&comprc2,16,1) = 1 %then
   %put UWARNING(comprc): data set labels differ;
  %if %substr(&comprc2,15,1) = 1 %then
   %put UWARNING(comprc): data set types differ;
  %if %substr(&comprc2,14,1) = 1 %then
   %put UWARNING(comprc): variable has different informat;
  %if %substr(&comprc2,13,1) = 1 %then
   %put UWARNING(comprc): variable has different format;
  %if %substr(&comprc2,12,1) = 1 %then
   %put UWARNING(comprc): variable has different length;
  %if %substr(&comprc2,11,1) = 1 %then
   %put UWARNING(comprc): variable has different label;
  %if %substr(&comprc2,10,1) = 1 %then
   %put UWARNING(comprc): &base has observation not in &compare;
  %if %substr(&comprc2,9,1)  = 1 %then
   %put UWARNING(comprc): &compare has observation not in &base;
  %if %substr(&comprc2,8,1)  = 1 %then
   %put UWARNING(comprc): &base has BY group not in &compare;
  %if %substr(&comprc2,7,1)  = 1 %then
   %put UWARNING(comprc): &compare has BY group not in &base;
  %if %substr(&comprc2,6,1)  = 1 %then
   %put UWARNING(comprc): &base has variable not in &compare;
  %if %substr(&comprc2,5,1)  = 1 %then
   %put UWARNING(comprc): &compare has variable not in &base;
  %if %substr(&comprc2,4,1)  = 1 %then
   %put UWARNING(comprc): a value comparison was unequal;
  %if %substr(&comprc2,3,1)  = 1 %then
   %put UWARNING(comprc): conflicting variable types;
  %if %substr(&comprc2,2,1)  = 1 %then
   %put UWARNING(comprc): BY variables do not match;
  %if %substr(&comprc2,1,1)  = 1 %then
   %put UWARNING(comprc): Fatal error: comparison not done;
%end;
%mend;
