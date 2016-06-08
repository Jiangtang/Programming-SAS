/*<pre><b>
/ Program   : stdtc.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Jan-2015
/ Purpose   : Function-style macro to return the first variable name that ends
/             with "STDTC" or failing that the first variable name that ends
/             with "DTC" or failing that to return the null string.
/ SubMacros : %varlist
/ Notes     : You can specify a character to exclude variables that contain this
/             character which by default is set to an underscore.
/ Usage     : %put #### %stdtc(mydset);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset for checking variable names of
/ notifchar=_       Ignore variables that contain the specified character
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Jan15         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: stdtc v1.0;

%macro stdtc(ds,notifchar=_);
  %local varlist varlist2 pos var scan i;
  %let varlist=%varlist(&ds);
  %let i=0;
  %let varlist2=;
  %let scan=%scan(&varlist,1,%str( ));
  %if %length(&notifchar) %then %do %while(%length(&scan));
    %if not %index(%nrbquote(&scan),&notifchar) 
      %then %let varlist2=&varlist2 &scan;
    %let i=%eval(&i+1);
    %let scan=%scan(&varlist,&i,%str( ));
  %end;
  %else %let varlist2=&varlist;
  %let pos=%sysfunc(prxmatch(/[^\s]+stdtc/i,&varlist2));
  %if &pos EQ 0 %then
    %let pos=%sysfunc(prxmatch(/[^\s]+dtc/i,&varlist2));
  %if &pos EQ 0 %then %let var=;
  %else %let var=%scan(%substr(&varlist2,&pos),1,%str( ));
&var
%mend stdtc;
