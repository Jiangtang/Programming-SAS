/*<pre><b>
/ Program   : savopts.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 14-Jun-2011
/ Purpose   : Function-style macro to return a list of active sas options so
/             that these options can be restored at a later point.
/ SubMacros : none
/ Notes     : %sysfunc(getoption(OPTION,keyword)) is used and for badly formed
/             responses such as "MISSING= " then these are corrected.
/ Usage     : %let savopts=%savopts(missing mprint);
/             option &savopts;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ optlist           (pos) Options to save separated by spaces (no quotes)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: savopts v1.0;

%macro savopts(optlist);
  %local i bit resp newopts;
  %let i=1;
  %let bit=%scan(&optlist,&i,%str( ));
  %do %while(%length(&bit));
    %let resp=%sysfunc(getoption(&bit,keyword));
    %if "&resp" EQ "MISSING=" %then %let resp=MISSING=" ";
    %else %if "&resp" EQ "FORMDLIM=" %then %let resp=FORMDLIM=" ";
    %let newopts=&newopts &resp;
    %let i=%eval(&i+1);
    %let bit=%scan(&optlist,&i,%str( ));
  %end;
&newopts
%mend savopts;
