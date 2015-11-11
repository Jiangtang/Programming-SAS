/*<pre><b>
/ Program   : addautos.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To concatenate a macro library onto the sasautos path
/ SubMacros : none
/ Notes     : To allow the user to add a macro library fileref or full path name
/             to the front or at the back of the current sasautos path.
/ Usage     : %addautos(mymacros)
/ 
/===============================================================================
/ REQUIREMENTS SPECIFICATION:
/ --id--  ---------------------------description--------------------------------
/ REQ001: New items on the sasautos path should be placed either at the start of
/         the list or last on the list according to user choice.
/ REQ002: The default position should be "first" on the sasautos path.
/ REQ003: The position specified should not be case sensitive.
/ REQ004: The position should be triggered by the first letter such that "first"
/         or "front" is activated by the first letter being an "F" whereas
/         "last" can be triggered with the first letter being an "L" or a "B"
/         for "back".
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
/ rrb  24Mar09         No longer puts commas in the sasautos path definition
/                      and requirements specification added to header.
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: addautos v1.1;

%macro addautos(autolib,pos);
  %local place autolist err;
  %let err=ERR%str(OR);
  %let place=&pos;
  %if %length(&place) EQ 0 %then %let place=first;
  %let place=%substr(%upcase(&place),1,1);
  %if %length(%sysfunc(compress(&place,FLB))) GT 0 %then 
  %put &err: (addautos) Position &pos is not recognised;
  %else %do;
    %let autolist=%sysfunc(compress(%sysfunc(getoption(sasautos)),%str(%(%))));
    %if "&place" EQ "F" %then %do;
      options sasautos=(&autolib &autolist);
    %end;
    %else %do;
      options sasautos=(&autolist &autolib);
    %end;
  %end;
%mend addautos;
