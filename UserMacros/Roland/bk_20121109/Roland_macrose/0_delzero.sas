/*<pre><b>
/ Program   : delzero.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To delete all datasets in a library with zero observations. This
/             macro was written for illustration purposes and is of limited use.
/ SubMacros : %dslist %words %nlobs
/ Notes     : Datasets will be deleted if they have zero logical observations.
/ Usage     : %delzero(work)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ libref            (pos) Libref of library.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: delzero v1.0;

%macro delzero(libref);
  %local del;
  %dslist(&libref)
  %do i=1 %to %words(&_dslist_);
    %if not %nlobs(&libref..%scan(&_dslist_,&i,%str( ))) 
      %then %let del=&del %scan(&_dslist_,&i,%str( ));
  %end;
  %if %length(&del) %then %do;
    proc datasets nolist lib=&libref;
      delete &del;
    run;
    quit;
  %end;
%mend delzero;
