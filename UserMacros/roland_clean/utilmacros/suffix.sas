/*<pre><b>
/ Program   : suffix.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 12-Jun-2011
/ Purpose   : Function-style macro to return a list with a suffix added.
/ SubMacros : none
/ Notes     : Items in matching quotes are treated as single elements
/ Usage     : %let sufflist=%suffix(.sas,fname1 "fname 2" fname3);
/             
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ suffix            (pos) Text to suffix each item with (unquoted)
/ list              (pos) List of items to suffix (separated by spaces)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: suffix v1.0;

%macro suffix(suffix,list);
  %local i bit;
  %let i=1;
  %let bit=%sysfunc(scanq(&list,&i,%str( )));
  %do %while(%length(&bit));
&bit.&suffix
    %let i=%eval(&i+1);
    %let bit=%sysfunc(scanq(&list,&i,%str( )));
  %end;
%mend suffix;

