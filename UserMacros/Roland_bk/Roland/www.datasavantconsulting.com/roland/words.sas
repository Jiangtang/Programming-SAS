/*<pre><b>
/ Program   : words.sas
/ Version   : 3.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 01-Sep-2009
/ Purpose   : Function-style macro to return the number of words in a string
/ SubMacros : none
/ Notes     : You can change the delimiter to other than a space if required.
/ Usage     : %let words=%words(string);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               String (pos) UNQUOTED
/ delim=%str( )     Delimeter (defaults to a space)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  26Sep08         "countw" used for sas version 9 onwards for v2.0
/ rrb  01Sep09         Use of countw() function discontinued (v3.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: words v3.0;

%macro words(str,delim=%str( ));

%local i;
%let i=1;
%do %while(%length(%qscan(&str,&i,&delim)) GT 0);
  %let i=%eval(&i + 1);
%end;
%eval(&i - 1)

%mend;
