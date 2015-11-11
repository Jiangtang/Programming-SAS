/*<pre><b>
/ Program   : therest.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 27-May-2014
/ Purpose   : Function-style macro to give you everything following any found
/             target string character.
/ SubMacros : none
/ Notes     : This macro is OBSOLETE. It has been replaced by the %allafterc
/             macro which does exactly the same thing.
/
/             It does an "indexc" on a string to find the first occurrence of
/             any of the characters in the target string and returns all the
/             string after that. If none of the target characters are found then
/             a null string is returned. The search is case sensitive.
/
/ Usage     : %let rest=%therest(&str,\/);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) String to search
/ target            (pos) Target string
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  04May11         Code tidy
/ rrb  27May14         This macro flagged as OBSOLETE
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: therest v1.0 (obsolete - replaced by allafterc macro);

%macro therest(string,target);
  %local pos;
  %if %sysfunc(indexc(&string,&target)) %then %do;
    %let pos=%sysfunc(indexc(&string,&target));
    %if &pos LT %length(&string) %then %qsubstr(&string,&pos+1);
  %end;
%mend therest;  