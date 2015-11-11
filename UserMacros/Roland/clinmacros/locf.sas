/*<pre><b>
/ Program   : locf.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 15-Mar-2013
/ Purpose   : Clinical reporting utility macro to perform "Last Observation
/             Carried Forward" processing. 
/ SubMacros : %words %vartype %commas 
/ Notes     : This is a free utility macro that is placed in the clinical macro
/             library because it is the more appropriate place for it. You do
/             not need a licence to use this macro.
/
/             READ THE FOLLOWING NOTES CAREFULLY:
/
/             Note that "last observation carried forward" does NOT mean last
/             dataset observations carried forward. It is the last non-missing
/             observation (in the sense of "as observed") for possibly multiple
/             measures being independently carried forward and assigned to
/             visits where no measure was available.
/
/             The only data you should feed in to this macro is data eligible to
/             be carried forward. If, for example, baseline data be not eligible
/             for carrying forward then do not supply baseline data to this
/             macro. If you only want data carrying forward for a subset of the
/             measures taken then only supply that subset of data to this macro.
/
/             Note that if you only want to keep carried forward data for one or
/             two specific timepoints then subset the output dataset AFTERWARDS. 
/             Data you want to keep and data eligible to be carried forward are
/             two different things. The data you feed into this macro is the
/             data ELIGIBLE for carrying forward. This is typically all
/             on-treatment measures (not including baseline) up to and including
/             the end-point.
/
/             This macro will assume that a numeric value is missing if it
/             equals missing values and a character value is missing if it
/             equals a space.  If, for example, a "0" signified a missing value
/             in the input data then you should reset it to what this macro
/             recognises as a missing value before feeding it in. 
/
/             The output dataset you get out of this macro is pure LOCF data. It
/             is up to you what you do with it. If you merge it in with your
/             original data then it is up to you to signify what is LOCF data
/             and what is original data.
/ Usage     : 
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin=             Input dataset name containing LOCF eligible data only
/ dsout=            Output dataset containing pure generated LOCF data
/ vars=             Variable or variables for which you want to carry forward
/                   data for. Multiple variable names to be separated by spaces.
/ bygroup=          Variable or variables signifying the grouping for values to
/                   be carried forward. It could be something like "subject" but
/                   it could be an extra grouping variable as well like "subject
/                   parameter".
/ visitvars=        Visit variables. This will most often be a simple variable
/                   like "visit". Multiple variables must be separated by spaces.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  01Apr04         Allow for multiple values per visit window and take the 
/                      latest.
/ rrb  13Feb07         "macro called" message added
/ rrb  28Sep08         This is now classed as a "Clinical reporting" macro
/ rrb  08May11         Code tidy
/ rrb  15Mar13         Header update to make it clear that this is a free macro
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: locf v1.0;

%macro locf(dsin=,
           dsout=,
            vars=,
         bygroup=,
       visitvars=
            );

  %local errflag err i var vartype;
  %let err=ERR%str(OR);
  %let errflag=0;


       /*-------------------------------------------------*
          Check we have enough parameters set to continue
        *-------------------------------------------------*/

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (locf) No input dataset name supplied to dsin= parameter;
  %end;

  %if not %length(&vars) %then %do;
    %let errflag=1;
    %put &err: (locf) No variables to carry forward supplied to vars= parameter;
  %end;

  %if not %length(&bygroup) %then %do;
    %let errflag=1;
    %put &err: (locf) No grouping variables supplied to bygroup= parameter;
  %end;

  %if not %length(&visitvars) %then %do;
    %let errflag=1;
    %put &err: (locf) No visit variables supplied to visitvars= parameter;
  %end;

  %if &errflag %then %goto exit;

  %if not %length(dsout) %then %let dsout=%scan(&dsin,1,%str(%());



     /*-------------------------------------------------*
                  Start processing the data
      *-------------------------------------------------*/

  proc sort data=&dsin out=_locfin(keep=&bygroup &visitvars &vars);
    by &bygroup &visitvars;
  run;



   /*--------------------------------------------------------*
      Create an empty grid of bygroup/visitvars combinations
    *--------------------------------------------------------*/

  proc sort nodupkey data=_locfin(keep=&bygroup) out=_locfby;
    by &bygroup;
  run;

  proc sort nodupkey data=_locfin(keep=&visitvars) out=_locfvis;
    by &visitvars;
  run;

  proc sql noprint;
    create table _locfgrid as 
    select * from _locfby, _locfvis
    order by %commas(&bygroup &visitvars);
  quit;

  proc datasets nolist;
    delete _locfby _locfvis;
  run;
  quit;



     /*-------------------------------------------------*
         Build up the output dataset one var at a time
      *-------------------------------------------------*/

  %do i=1 %to %words(&vars);
    %let var=%scan(&vars,&i,%str( ));
    %let vartype=%vartype(_locfin,&var);

    %*- extract information specific to this variable -;
    data _locfval;
      set _locfin(keep=&bygroup &visitvars &var 
                 where=(&var NE
      %if "&vartype" EQ "C" %then %do;
        ' '
      %end;
      %else %do;
        .
      %end;
                 ));
    run;

    data _locfval;
      set _locfval;
      by &bygroup &visitvars;
      if last.%scan(&bygroup &visitvars,-1,%str( ));
    run;

    data _locfgrid;
      retain _seq 0;
      merge _locfgrid _locfval(in=_val drop=&var);
      by &bygroup &visitvars;
      if first.%scan(&bygroup,-1,%str( )) then _seq=0;
      if _val then _seq=_seq+1;
    run;

    data _locfval;
      retain _seq 0;
      set _locfval;
      by &bygroup;
      if first.%scan(&bygroup,-1,%str( )) then _seq=0;
      _seq=_seq+1;
    run;

    data _locfgrid;
      merge _locfval _locfgrid;
      by &bygroup _seq;
      drop _seq;
    run;

  %end;



     /*-------------------------------------------------*
                       Tidy up and exit
      *-------------------------------------------------*/

  data &dsout;
    set _locfgrid;
  run;

  proc datasets nolist;
    delete _locfval _locfgrid _locfin;
  run;
  quit;



  %goto skip;
  %exit: %put &err: (locf) Leaving macro due to problem(s) listed;
  %skip:

%mend locf;
