/*<pre><b>
/ Program      : checkv6.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 11-May-2011
/ Purpose      : Check a dataset for Version 6 compatibility
/ SubMacros    : none
/ Notes        : This will check a dataset for SAS V6 compatibility issues. You
/                can use this to check a dataset you intend to convert to a SAS
/                transport file. Any detected issues will be written to the log
/                as warning messages. For variables defined with a length of
/                more than 200 characters, the length of the contents of these
/                variables will be checked and a warning issued if there is a
/                non-zero count of these.
/
/ Usage        : %checkv6(sasuser.myds);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Name of input dataset (no quotes) 
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  11May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: checkv6 v1.0;

%macro checkv6(ds);

  %let ds=%upcase(&ds);

  %local longvars longcnt i var gt200 wrn;
  %let wrn=WAR%str(NING);

  options nonotes;

  proc contents short data=&ds noprint out=_chkv6;
  run;

  data _null_;
    length longvars $ 2000;
    retain longvars;
    set _chkv6 end=_last;
    if _n_=1 then do;
      put "----- Checking dataset &ds for Version 6 transport file compatibility ----";
      if length(memname)>8 then put "&wrn: Dataset name " MEMNAME "longer than 8 characters";
      if length(memlabel)>40 then put "&wrn: Dataset label longer than 40 characters " memlabel=;
    end;
    put "-- Checking variable " name "--";
    lablen=length(label);
    if length(name)>8 then put "&wrn: Variable name " NAME "longer than 8 characters";
    if lablen>40 then put "&wrn: Label of variable longer than 40 characters " lablen=;
    if type=2 and length>200 then do;
      put "&wrn: Character variable length greater than 200 characters " length=;
      longvars=left(trim(longvars))||" "||name;
    end;
    if type=1 and length NE 8 then put "&wrn: Numeric variable length not equal to 8 bytes " length=;
    if _last then do;
      put "---- Checking of dataset &ds complete ----";
      call symput('longvars',trim(compbl(longvars)));
    end;
  run;

  proc datasets nolist;
    delete _chkv6;
  run;
  quit;

  %let longcnt=%sysfunc(countw(&longvars,%str( )));

  %if &longcnt GT 0 %then %do;
    %put;
    %put ---- Checking content length of long character variable(s) &longvars in dataset &ds ----;
    %do i=1 %to &longcnt;
      %let var=%scan(&longvars,&i,%str( ));
      %put -- Checking variable &var --;
      proc sql noprint;
        select count(&var) into :gt200 separated by " " from &ds
        where length(&var) GT 200;
      quit;
      %if &gt200 EQ 0 %then %put No obs had content length GT 200 characters;
      %else %put &wrn: &gt200 obs had a content length GT 200 characters;
    %end;
    %put ---- Checking of dataset &ds long variable content lengths complete ----;
    %put;
  %end;

  options notes;

%mend checkv6;

