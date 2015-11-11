/*<pre><b>
/ Program      : ctitlepgmrk.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 30-Jul-2007
/ Purpose      : Create a centered top title with a right-most "ff"x page mark
/ SubMacros    : none
/ Notes        : The title must be in quotes. 
/ Usage        : %ctitlepgmrk("centred title")
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) (in quotes) Title to center
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: ctitlepgmrk v1.0;

%macro ctitlepgmrk(string);

%local ls ;
%let ls=%sysfunc(getoption(linesize));

%if not %length(&string) %then %let string=" ";

data _null_;
  length text $ &ls;
  substr(text,((&ls-length(&string))/2)+1)=&string;
  substr(text,&ls,1)="FF"x;
  call execute('title1 '||'"'||trim(text)||'";');
run;

%mend;

