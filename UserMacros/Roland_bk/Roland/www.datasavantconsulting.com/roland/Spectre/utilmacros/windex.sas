/*<pre><b>
/ Program   : windex.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return the word count position in a string
/ SubMacros : %words
/ Notes     : none
/ Usage     : %let windex=%windex(string,target);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               String (pos) UNQUOTED
/ target            Target string (pos) UNQUOTED
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  10May07         Break loop if match is found (v1.1)
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: windex v1.1;

%macro windex(str,target);
  %local i res words;
  %let res=0;
  %let words=%words(&str);
  %do i=1 %to &words;
    %if "%scan(&str,&i,%str( ))" EQ "&target" %then %do;
      %let res=&i;
      %let i=&words;
    %end;
  %end;
&res
%mend windex;
