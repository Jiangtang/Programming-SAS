/*<pre><b>
/ Program   : prefix.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 12-Jun-2011
/ Purpose   : Function-style macro to return a list with a prefix added.
/ SubMacros : none
/ Notes     : Items in matching quotes are treated as single elements
/ Usage     : %let preflist=%prefix(C:\mylib\,fname1 "fname 2" fname3);
/             
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ prefix            (pos) Text to prefix each item with (unquoted)
/ list              (pos) List of items to prefix (separated by spaces)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: prefix v1.0;

%macro prefix(prefix,list);
  %local i bit;
  %let i=1;
  %let bit=%sysfunc(scanq(&list,&i,%str( )));
  %do %while(%length(&bit));
&prefix.&bit
    %let i=%eval(&i+1);
    %let bit=%sysfunc(scanq(&list,&i,%str( )));
  %end;
%mend prefix;

