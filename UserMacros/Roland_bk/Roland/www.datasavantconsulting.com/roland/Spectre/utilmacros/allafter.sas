/*<pre><b>
/ Program   : allafter.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 26-May-2014
/ Purpose   : Function-style macro to give you everything following a target
/             string.
/ SubMacros : none
/ Notes     : It does an "index" on a string to find the first occurrence of
/             the target string and returns all the string after the end of the
/             target. The search is case sensitive.
/ Usage     : %let rest=%allafter(&str,xx);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) String to search
/ target            (pos) Target string (case sensitive)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26May14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: allafter v1.0;

%macro allafter(string,target);
  %local pos;
  %if %sysfunc(index(&string,&target)) %then %do;
    %let pos=%eval(%sysfunc(index(&string,&target))+%length(&target));
    %if &pos LE %length(&string) %then %qsubstr(&string,&pos);
  %end;
%mend allafter;
