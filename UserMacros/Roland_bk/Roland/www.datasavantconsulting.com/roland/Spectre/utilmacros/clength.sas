/*<pre><b>
/ Program   : clength.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To create a length statement to unify character lengths in a list
/             of data sets to the maximum variable length.
/ SubMacros : %words %nobs
/ Notes     : This is not a function-style macro. A length statement will be 
/             generated in the form "length cvar1 $ 5 cvar2 $ 12" BUT ONLY IF
/             THERE IS AN INCONSISTENCY IN THE INPUT DATASETS. Otherwise it will
/             be blank. Names, labels and other attributes will be taken from
/             the first data set in the list. The length statement string is
/             written out to a global macro variable which can then be resolved
/             in a later data step.
/ Usage     : %clength(ds1 ds2 ds3);
/             data all;
/               &_clength_;
/               set ds1 ds2 ds3;
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsets             (pos) Input datasets
/ globvar=_clength_ Name of global macro variable to write length string to
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: clength v1.0;

%macro clength(dsets,globvar=_clength_);

  %local i w;
  %let w=%words(&dsets);

  %global &globvar;
  %let &globvar=;

  %do i=1 %to &w;
    proc contents data=%scan(&dsets,&i,%str( )) noprint
    out=_clen&i(keep=name type length where=(type=2));
    data _clen&i;
      retain seq &i;
      length ucname $ 32;
      set _clen&i;
      ucname=upcase(name);
      drop type;
    run;
  %end;

  *- bring all the data sets together -;
  data _clenall;
    set
    %do i=1 %to &w;
      _clen&i
    %end;
    ;
  run;

  *- sort ready to get first form of variable name -;
  proc sort data=_clenall;
    by ucname seq;
  run;

  *- first form of variable name encountered -;
  data _clenf;
    set _clenall(keep=ucname name);
    by ucname;
    if first.ucname;
    rename name=fname;
  run;

  *- merge first form of name in with rest -;
  data _clenall(keep=fname length);
    merge _clenf _clenall;
    by ucname;
  run;

  *- get rid of duplicate lengths -;
  proc sort nodupkey data=_clenall;
    by fname length;
  run;

  *- sort in descending length order -;
  proc sort data=_clenall;
    by fname descending length;
  run;

  *- we only want the one with the longest length where there is a clash -;
  data _clenall;
    set _clenall;
    by fname;
    if first.fname and not last.fname then output;
  run;

  %if %nobs(_clenall) %then %do;
    *- gemerate the length statement and output to global macro variable -;
    data _null_;
      length str $ 32767;
      retain str 'length';
      set _clenall end=last;
      str=trim(str)||' '||trim(fname)||' $ '||compress(put(length,5.));
      if last then call symput("&globvar",trim(str));
    run;
  %end;

  *- tidy up -;
  proc datasets nolist;
    delete _clen:;
  run;
  quit;

%mend clength;
