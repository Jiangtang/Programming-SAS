/*<pre><b>
/ Program   : zerogrid.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To create a "grid" of combined values with a variable set to zero
/             for all combinations of values.
/ SubMacros : %commas
/ Notes     : Output sort order will be by supplied variable name if nothing is
/             specified.
/ Usage     : %zerogrid(dsout=grid,var1=subject,ds1=demog,var2=tmtarm,
/             ds2=demog,zerovar=count,sortby=tmtarm subject)
/             %zerogrid(zerovar=str,zero="  0 (  0.0)",var1=trtrand ddose,
/                       ds1=period1,var2=day,ds2=period1)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsout=zerogrid    Output dataset name (defaults to "zerogrid")
/ zero=0            By default, the zero setting is numeric 0
/ zerovar           Name of variable to receive zero setting for all obs
/ sortby            Variable list to sort output dataset by (defaults to
/                   supplied variable order)
/ var1              First variable(s) for extracting distinct values
/ ds1               Dataset source of first variable
/ var2              Second variable(s) for extracting distinct values
/ ds2               Dataset source of second variable
/ var3              Third variable(s) for extracting distinct values
/ ds3               Dataset source of third variable
/ var4              Fourth variable(s) for extracting distinct values
/ ds4               Dataset source of fourth variable
/ var5              Fifth variable(s) for extracting distinct values
/ ds5               Dataset source of fifth variable
/ (9 of these)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Apr05         Ability to change zero setting added
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: zerogrid v1.0;

%macro zerogrid(dsout=zerogrid,
               sortby=,
                 zero=0,
              zerovar=,
                 var1=,
                  ds1=,
                 var2=,
                  ds2=,
                 var3=,
                  ds3=,
                 var4=,
                  ds4=,
                 var5=,
                  ds5=,
                 var6=,
                  ds6=,
                 var7=,
                  ds7=,
                 var8=,
                  ds8=,
                 var9=,
                  ds9=,
                  ); 

  %local errflag i err;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&zero) %then %let zero=0;

  %if not %length(&dsout) %then %do;
    %let errflag=1;
    %put &err: (zerogrid) Output dataset dsout= not given a name;
  %end;

  %if not %length(&zerovar) %then %do;
    %let errflag=1;
    %put &err: (zerogrid) Zero value variable zerovar= not given a name;
  %end;

  %do i=1 %to 9;
    %if %length(&&var&i) and not %length(&&ds&i) %then %do;
      %let errflag=1;
      %put &err: (zerogrid) Variable name supplied as var&i=&&var&i but no ds&i=;
    %end;
    %if %length(&&ds&i) and not %length(&&var&i) %then %do;
      %let errflag=1;
      %put &err: (zerogrid) Dataset name supplied as ds&i=&&ds&i but no var&i=;
    %end;
  %end;

  %if &errflag %then %goto exit;

  %if not %length(&sortby) %then 
    %let sortby=&var1 &var2 &var3 &var4 &var5 &var6 &var7 &var8 &var9;


  proc sql noprint;
    create table &dsout as 
    select &zero as &zerovar, * from
    %if %length(&var1) and %length(&ds1) %then %do;
    (select distinct %commas(&var1) from &ds1)
    %end;
    %if %length(&var2) and %length(&ds2) %then %do;
    , (select distinct %commas(&var2) from &ds2)
    %end;
    %if %length(&var3) and %length(&ds3) %then %do;
    , (select distinct %commas(&var3) from &ds3)
    %end;
    %if %length(&var4) and %length(&ds4) %then %do;
    , (select distinct %commas(&var4) from &ds4)
    %end;
    %if %length(&var5) and %length(&ds5) %then %do;
    , (select distinct %commas(&var5) from &ds5)
    %end;
    %if %length(&var6) and %length(&ds6) %then %do;
    , (select distinct %commas(&var6) from &ds6)
    %end;
    %if %length(&var7) and %length(&ds7) %then %do;
    , (select distinct %commas(&var7) from &ds7)
    %end;
    %if %length(&var8) and %length(&ds8) %then %do;
    , (select distinct %commas(&var8) from &ds8)
    %end;
    %if %length(&var9) and %length(&ds9) %then %do;
    , (select distinct %commas(&var9) from &ds9)
    %end;
    order by %commas(&sortby);
  quit;

  %goto skip;
  %exit: %put &err: (zerogrid) Leaving macro due to problem(s) listed;
  %skip:

%mend zerogrid;
