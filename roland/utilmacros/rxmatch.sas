/*<pre><b>
/ Program   : rxmatch.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return those space-delimited elements of a
/             list that match a specified rxparse pattern.
/ SubMacros : %words
/ Notes     : Refer to SAS documentation for how RX pattern matching works.
/             Non-matching elements get returned via the global macro variable
/             _nomatch_.
/ Usage     : %let match=%rxmatch(apopa pop aapop popaa,pop $s);
/             %put &match;
/ pop aapop
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ list              (pos) space-delimited-element list
/ rxpattern         (pos) RX pattern match
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: rxmatch v1.0;

%macro rxmatch(list,rxpattern);
  %local rx i;
  %global _nomatch_;
  %let _nomatch_=;
  %let rx=%qsysfunc(rxparse(&rxpattern));
  %do i=1 %to %words(&list);
    %if %sysfunc(rxmatch(&rx,%scan(&list,&i,%str( )))) %then %scan(&list,&i,%str( ));
    %else %let _nomatch_=&_nomatch_ %scan(&list,&i,%str( ));
  %end;
  %syscall rxfree(rx);
%mend rxmatch;
