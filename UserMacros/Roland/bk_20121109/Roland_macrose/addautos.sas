/*<pre><b>
/ Program   : addautos.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 31-Jul-2007
/ Purpose   : To concatenate a macro library onto the sasautos path
/ SubMacros : none
/ Notes     : none
/ Usage     : %addautos(mymacros)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ autolib           (pos) Name of the macro library to concatenate. This should
/                   be unquoted if it is a fileref or quoted if a path name.
/ pos               (pos - unquoted) Position in the list. Can be first or last
/                   or front or back (defaults to first)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: addautos v1.0;

%macro addautos(autolib,pos);
%local place autolist;
%let place=&pos;
%if %length(&place) EQ 0 %then %let place=first;
%let place=%substr(%upcase(&place),1,1);
%if %length(%sysfunc(compress(&place,FLB))) GT 0 %then 
%put ERROR: (addautos) Position &pos is not recognised;
%else %do;
  %let autolist=%sysfunc(compress(%sysfunc(getoption(sasautos)),%str(%(%))));
  %if "&place" EQ "F" %then %do;
    options sasautos=(&autolib, &autolist);
  %end;
  %else %do;
    options sasautos=(&autolist, &autolib);
  %end;
%end;
%mend;
