/*<pre><b>
/ Program   : flatten.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To "flatten" data so there is only one observation per "by group"
/ SubMacros : %words %varnum
/ Notes     : This calls proc transpose repeatedly for each variable you specify.
/             You must have sorted on what you define to the bygroup= parameter
/             plus any other variables required to put the data in the correct
/             sorted order. Typically, you will have sorted by the bygroup=
/             variables plus date or time (or both) variables. A variable is
/             added that contains the count of the number of observations in
/             each by group. Variables will be given the suffix 1, 2, etc.
/ Usage     : %flatten(dsin=test,bygroup=by1 by2,vars=str num)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin=             Input dataset
/ vars=             Variables you want transposing
/ dsout=            Output dataset
/ bygroup=          The "by group" variables
/ nobs=nobs         Name of the variable to contain the number of observation
/                   per "by group"
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  25Jun03         Make nobs= a mandatory parameter and write highest value
/                      out to global macro variable _maxn_. Now version 2
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: flatten v2.0;

%macro flatten(dsin=,
               vars=,
              dsout=,
            bygroup=,
               nobs=nobs
              );

  %local errflag i var err;
  %let err=ERR%str(OR);
  %let errflag=0;

  %global _maxn_;
  %let _maxn_=0;


         /*-----------------------------------------*
             Check we have enough parameters set
          *-----------------------------------------*/

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (flatten) No input dataset defined to dsin=;
  %end;

  %if not %length(&vars) %then %do;
    %let errflag=1;
    %put &err: (flatten) No transpose variables defined to vars=;
  %end;

  %if not %length(&bygroup) %then %do;
    %let errflag=1;
    %put &err: (flatten) No by group variables defined to bygroup=;
  %end;

  %if &errflag %then %goto exit;

  %if not %length(&dsout) %then %let dsout=%scan(&dsin,1,%str(%());

  %if not %length(&nobs) %then %let nobs=nobs;



         /*-----------------------------------------*
                  Start processing the data
          *-----------------------------------------*/

  data _flatten;
    set &dsin;
    keep &bygroup &vars;
  run;



         /*-----------------------------------------*
                   Add the observation count
          *-----------------------------------------*/

  proc summary nway missing data=_flatten;
    class &bygroup;
    output out=_flatnobs(drop=_type_ rename=(_freq_=&nobs));
  run;

  proc summary nway data=_flatnobs;
    id &nobs;
    output out=_flatn(drop=_type_ _freq_);
  run;

  data _null_;
    set _flatn;
    call symput('_maxn_',compress(put(&nobs,13.)));
  run;

  data _flatten;
    merge _flatnobs _flatten;
    by &bygroup;
  run;



         /*-----------------------------------------*
               Transpose each variable in turn
          *-----------------------------------------*/

  %do i=1 %to %words(&vars);

    %let var=%scan(&vars,&i,%str( ));

    proc transpose data=_flatten prefix=&var
                   out=_flatten&i(drop=_name_);
      by &bygroup &nobs;
      var &var;
    run;

  %end;



         /*-----------------------------------------*
                  Create final output dataset
          *-----------------------------------------*/

  data _flatout;
    merge
    %do i=1 %to %words(&vars);
      _flatten&i
    %end;
    ;
    by &bygroup;
  run;

  data &dsout;
    set _flatout;
    %if %varnum(_flatout,_label_) %then %do;
      drop _label_;
    %end;
  run;


         /*-----------------------------------------*
                        Tidy up and exit
          *-----------------------------------------*/

  proc datasets nolist;
    delete _flat:
    ;
  run;
  quit;


  %goto skip;
  %exit: %put &err: (flatten) Leaving macro due to problem(s) listed;
  %skip:
%mend flatten;
