/*<pre><b>
/ Program   : lookahead.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To do the opposite of lag and allow the user to look ahead at the
/             variables in the following observations in the same by group.
/ SubMacros : %words
/ Notes     : The input dataset must be sorted into the correct order. The
/             "bygroup" parameter will be set to the grouping variables which is
/             not the same as the list of sort variables since the records will
/             be sorted WITHIN the group as well. Suppose your sort variables 
/             were "subject, date, time" then your "bygroup" variable might just
/             be "subject". The look-ahead is only done within the "bygroup" set.
/             
/             The lookahead variables created will have the same name as the 
/             original variables except with a numeric suffix on the end. So for
/             the observation following it will have the suffix "1" and for the
/             second observation it will have the suffix "2" etc.
/ Usage     : 
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin=             Input dataset
/ dsout=            Output dataset
/ bygroup=          Grouping variables(s)
/ vars=             Variables you want to look ahead for
/ lookahead=1       Number of observations to look ahead
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/==============================================================================*/

%put MACRO CALLED: lookahead v1.0;

%macro lookahead(dsin=,dsout=,bygroup=,vars=,lookahead=1);

  %local errflag i err;
  %let err=ERR%str(OR);
  %let errflag=0;


              /*--------------------------------------*
                 Check we have enough parameters set
               *--------------------------------------*/

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (lookahead) Nothing specified to dsin= parameter;
  %end;

  %if not %length(&bygroup) %then %do;
    %let errflag=1;
    %put &err: (lookahead) Nothing specified to bygroup= parameter;
  %end;

  %if not %length(&vars) %then %do;
    %let errflag=1;
    %put &err: (lookahead) Nothing specified to vars= parameter;
  %end;

  %if &errflag %then %goto exit;

  %if not %length(&dsout) %then %let dsout=%scan(&dsin,1,%str(%());

  %if not %length(&lookahead) %then %let lookahead=1;



            /*--------------------------------------*
                   Start processing the data
             *--------------------------------------*/

  data _look;
    retain _seq 0;
    set &dsin;
    by &bygroup;
    if first.%scan(&bygroup,-1,%str( )) then _seq=0;
    _seq=_seq+1;
  run;

  %do i=1 %to &lookahead;
    data _look&i;
      set _look(keep=_seq &bygroup &vars);
      _seq=_seq-&i;
      rename
      %do j=1 %to %words(&vars);
        %scan(&vars,&j,%str( ))=%scan(&vars,&j,%str( ))&i
      %end;
      ;
    run;  
  %end;

  data &dsout;
    merge _look(in=_look)
    %do i=1 %to &lookahead;
        _look&i
    %end;
        ;
    by &bygroup _seq;
    if _look;
    drop _seq;
  run;



            /*--------------------------------------*
                         Tidy up and exit
             *--------------------------------------*/

  proc datasets nolist;
    delete _look
    %do i=1 %to &lookahead;
      _look&i
    %end;
    ;
  run;
  quit;


  %goto skip;
  %exit: %put &err: (lookahead) Leaving macro due to problem(s) listed;
  %skip:

%mend lookahead;
