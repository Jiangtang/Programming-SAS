/*<pre><b>
/ Program   : qcompress.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 31-Jul-2007
/ Purpose   : Function-style macro to compress a macro variable string and
/             return the result quoted.
/ SubMacros : none
/ Notes     : 
/ Usage     : %let tidy=%qcompress(&string);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) String to compress.
/ ref               (pos) Reference characters to remove from the string.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: qcompress v1.0;

%macro qcompress(string,ref);
%local i error;
%let error=0;

%if not %length(&string) %then %goto skip;

%if not %length(&ref) %then %do;
  %put ERROR: (qcompress) No reference characters supplied to compress string with.;
  %let error=1;
%end;

%if &error %then %goto error;


%qsysfunc(compress(&string,&ref))

%goto skip;
%error: %put ERROR: (qcompress) Leaving qcompress macros due to error(s) listed.;
%skip:
%mend;
  