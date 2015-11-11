/*<pre><b>
/ Program   : look4lwork.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 01-Jun-2014
/ Purpose   : To look for the fileref LWORK and if found to change the "srclib"
/             value from "work" to "lwork" and to assign lwork.formats to the
/             format search path.
/ SubMacros : none
/ Notes     : This is an early attempt to detect when code is running remotely
/             and to adjust to the situation. LWORK is assumed to be the 
/             inherited WORK library from the calling program and if this libref
/             is found then the value of "srclib" wil be reassigned to "lwork".
/
/             The intention of the macro is to help you design code members that
/             will work in both local and remote sessions without change. It is
/             intended mainly for "reporting" members that report on datasets
/             that are prebuilt in the WORK library and this is why you see
/             the assignment to "srclib" in the usage notes below. It is assumed
/             that this will be resolved in your code as &srclib..dset1 etc. to
/             access the prebuilt datasets. This value of "work" can then be
/             replaced with "lwork" if you are running in a remote session.
/             "lwork" will also be added to the format search path if this
/             situation is detected.
/
/             You should call this macro as early as convenient in your code as
/             shown in the usage notes.
/
/ Usage     : %let srclib=work;  *- the expected source of prebuilt datasets -;
/             %look4lwork
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  01Jun14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: look4lwork v1.0;

%macro look4lwork; 
  %if (%sysfunc(libref(lwork))) EQ 0 %then %do; 
    *- data and formats will be in the LWORK library -; 
    %let srclib=lwork; 
    options fmtsearch=(lwork.formats); 
  %end; 
%mend look4lwork; 
