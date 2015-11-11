/*<pre><b>
/ Program   : liblist.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 24-Nov-2009
/ Purpose   : To list all the libraries.
/ SubMacros : none
/ Notes     : This is NOT a function-style macro. See usage notes.
/             The list of libraries will be written to the global macro variable
/             _liblist_.
/ Usage     : %liblist;
/             %let liblist=&_liblist_;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ none
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: liblist v1.0;

%macro liblist;
  %global _liblist_;
  %let _liblist_=;

  proc sql noprint;
    select distinct libname into :_liblist_ separated by ' '
    from sashelp.vslib;
  quit;
%mend liblist;
