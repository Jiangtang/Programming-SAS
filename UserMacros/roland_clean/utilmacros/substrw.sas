/*<pre><b>
/ Program      : substrw.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : Function-style macro to substring words assigned to a macro
/                variable.
/ SubMacros    : none
/ Notes        : This works like %substr() but acts on words instead. If number
/                parameter is not set then all following words are returned.
/ Usage        : %let whatsleft=%substrw(&mvar,4);
/                %let twothree=%substrw(&str,2,2);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) String to work on
/ start             (pos) Start word number
/ number            (pos) Number of words (optional)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called2 message added
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: substrw v1.0;

%macro substrw(str,start,number);

  %local errflag err i pos bit;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&start) %then %do;
    %let errflag=1;
    %put &err: No start word number provided as second positional parameter;
  %end;

  %if &errflag %then %goto exit;

  %if %length(&str) %then %do;
    %if not %length(&number) %then %do;
      %let pos=&start;
      %let bit=%scan(&str,&pos,%str( ));
      %do %while(%length(&bit));
&bit
        %let pos=%eval(&pos+1);
        %let bit=%scan(&str,&pos,%str( ));
      %end;
    %end;
    %else %do;
      %do i=1 %to &number;
%scan(&str,%eval(&start-1+&i),%str( ))
      %end;
    %end;
  %end;

  %goto skip;
  %exit: %put &err: (substrw) Leaving macro due to problem(s) listed;
  %skip:

%mend substrw;
