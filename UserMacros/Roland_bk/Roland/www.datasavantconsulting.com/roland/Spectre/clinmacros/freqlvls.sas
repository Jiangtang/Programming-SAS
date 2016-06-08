/*<pre><b>
/ Program   : freqlvls.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 31-Oct-2011
/ Purpose   : To give frequency counts by category and sub-category levels
/ SubMacros : %words %vartype %varfmt %comblvls %splitvar
/ Notes     : The number of controls offered to tailor the output dataset are
/             limited because it is expected that the output dataset will be
/             extensively post-processed.
/
/             New text variables named LVL1, LVL2 etc. are created for the
/             output dataset that correspond to the heirarchical list of
/             category variables supplied to varlist= so that they are converted
/             to character where required and are wide enough to accept the "ANY
/             varname" summation label. The labels of the LVL1, LVL2 etc.
/             variables for the group summation will be "ANY " followed by the
/             original variable name. It is up to you to change these or drop
/             these as needed when post processing.
/
/             For the default calcord=yes, ordering variables named LVL1ORD,
/             LVL2ORD etc. are created. The zero values correspond to the "ANY"
/             group summations and the rank values above zero are based on the
/             descending frequency count with the LVL1, LVL2 etc. value as a
/             secondary key. You may want to use a different ordering system in
/             which case you will have to overwrite some of these values or not
/             calculate them by setting calcord=no.
/
/             The output dataset will be named _freq unless you specify a value
/             to dsout= (which will allow dataset modifiers).
/
/             You can specify a treatment variable. If you also specify a value
/             for the total treatment arm then duplicate observations will be 
/             generated for this total treatment arm value and it will be
/             included in the summation.
/
/             You would typically use the nodupvars= to specify variables that
/             uniquely identify a patient and in this case you will get unique
/             patient counts rather than event counts. If you want both types
/             of counts then make two calls to this macro and merge the output
/             datasets together. For the event counts you might want to set
/             calcord=no to save time if you are using the LVL1ORD, LVL2ORD
/             etc. variables from the patient counts dataset.
/
/             This macro was written to be the core macro for an AE table macro
/             to remove some of the complexity. The output dataset would
/             typically be merged with a denominator dataset to calculate
/             percentages and then the counts, percentages and perhaps event
/             counts shown in a text field that gets transposed by treatment arm
/             with the LVL1ORD, LVL2ORD etc. values from the total treatment arm
/             used as the display order for the transposed values. The %trnslvls
/             macros can be used to do the transpose and the %comblvls macro
/             can be used to combine the values in a single variable.
/
/             For debugging purposes and to help understand what this macro is
/             doing then you can set print=yes to print the output dataset so
/             that the summation levels can be clearly seen. If you also set
/             comblvls=yes the LVLn values will be combined in the variable
/             COMBLVLS and this will be shown in the print instead of the
/             separate LVLn variables.
/
/ Usage     : %freqlvls(sashelp.cars,make type model,trtvar=origin,
/                       trttot="ALL");
/             data cars;
/               length pat $ 3;
/               set sashelp.cars;
/               pat=model;
/             run;
/             %freqlvls(cars,make type model,trtvar=origin,trttot="ALL",
/                       nodupvars=pat);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) input dataset
/ varlist           (pos) list of category variables
/ dsout=_freq       Name of output dataset (defaults to _freq)
/ varlen=256        "Level" variable length (defaults to 256)
/ trtvar            Treatment variable (optional)
/ trttot            Value that represents tot total treatment arm (optional)
/ nodupvars         Variables for dropping duplicates (optional)
/ print=no          By default, do not print the output datset
/ comblvls=no       By default, do not combine the LVLn variables into an
/                   indented version in the variable named COMBLVLS
/ colw=50           column width to use to display a flowing COMBLVLS
/ split=@           Split character to use for COMBLVLS
/ usecolon=yes      By default, if ": " occurs in the string start within 30% of
/                   the defined width then use this to align following line
/                   segments.
/ indent=3          Number of spaces to indent each level
/ hindent=0         Hanging indent for overflowing lines in COMBLVLS
/ calcord=yes       By default, calculate the LVL1ORD, LVL2ORD etc. variables
/                   ranked by descending frequency count.
/ sortbyord=no      By default, do not sort the output dataset by the generated
/                   LVLnORD variables (if you set print=yes or comblvls=yes then
/                   the dataset will be sorted in any case). The default sort
/                   order is the treatment variable (if used) followed by the
/                   LVLn variables.
/ mvarmax           You can specify the name of a macro variable to receive the
/                   maximum frequency value.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  27Oct11         New (v1.0)
/ rrb  31Oct11         Drop _freq_ on a merge to avoid info lines in log
/                      and added mvarmax= parameter processing (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: freqlvls v1.1;

%macro freqlvls(dsin,
             varlist,
               dsout=_freq,
              varlen=256,
              trtvar=,
              trttot=,
           nodupvars=,
               debug=no,
               print=no,
            comblvls=no,
               colw=50,
               split=@,
            usecolon=yes,
              indent=3,
             hindent=0,
             calcord=yes,
           sortbyord=no,
             mvarmax=
                );

  %local i err errflag var oldvar keepvars totvars varfmt vartype workds;
  %let errflag=0;
  %let err=ERR%str(OR);

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (freqlvls) No input dataset specified as the first positional parameter;
  %end;

  %if not %length(&varlist) %then %do;
    %let errflag=1;
    %put &err: (freqlvls) No variable list specified as the second positional parameter;
  %end;

  %if &errflag %then %goto exit;

  %let totvars=%words(&varlist);

  %if not %length(&varlen) %then %let varlen=256;

  %if not %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));

  %if not %length(&print) %then %let print=no;
  %let print=%upcase(%substr(&print,1,1));

  %if not %length(&comblvls) %then %let comblvls=no;
  %let comblvls=%upcase(%substr(&comblvls,1,1));

  %if not %length(&calcord) %then %let calcord=yes;
  %let calcord=%upcase(%substr(&calcord,1,1));

  %if not %length(&sortbyord) %then %let sortbyord=no;
  %let sortbyord=%upcase(%substr(&sortbyord,1,1));

  %if not %length(&dsout) %then %let dsout=_freq;

  *- create a new input dataset with wider columns named LVL1 etc. -;
  data _dsin;
    length
    %do i=1 %to &totvars;
      lvl&i
    %end;
    $ &varlen ;
    set &dsin;
    %do i=1 %to &totvars;
      %let var=%scan(&varlist,&i,%str( ));
      %let vartype=%vartype(&dsin,&var);
      %let varfmt=%varfmt(&dsin,&var);
      %if &vartype EQ N %then %do;
        %if %length(&varfmt) %then %do;
          lvl&i=left(put(&var,&varfmt.));
        %end;
        %else %do;
          lvl&i=left(put(&var,best16.));
        %end;
      %end;
      %else %do;
        %if %length(&varfmt) %then %do;
          lvl&i=left(put(&var,&varfmt.));
        %end;
        %else %do;
          lvl&i=left(&var);
        %end;
      %end;
    %end;
    %if %length(&trtvar) and %length(&trttot) %then %do;
      output;
      &trtvar=&trttot;
      output;
    %end;
    keep &trtvar &nodupvars
    %do i=1 %to &totvars;
      lvl&i
    %end;
    ;
    label
    %do i=1 %to &totvars;
      lvl&i="%upcase(%scan(&varlist,&i,%str( )))"
    %end;
    ;
  run;

  %let workds=_dsin;
  %if %length(&nodupvars) %then %let workds=_dsin2;
 
  %if %length(&nodupvars) %then %do;
    proc sort nodupkey data=_dsin out=_dsin2;
      by &trtvar &nodupvars;
    run;
  %end;

  proc summary nway missing data=&workds;
    %if %length(&trtvar) %then %do;
      class &trtvar;
    %end;
    output out=lvl0sum(drop=_type_);
  run;

  %if %length(&mvarmax) %then %do;
    proc sql noprint;
      select max(_freq_) into: &mvarmax from lvl0sum;
    quit;
  %end;


  %let keepvars=;
  %do i=1 %to &totvars;

    %let var=lvl&i;
    %let oldvar=%scan(&varlist,&i,%str( ));
    %if %length(&nodupvars) %then %do;
      proc sort nodupkey data=_dsin out=_dsin2;
        by &trtvar &keepvars &var &nodupvars;
      run;
    %end;

    proc summary nway missing data=&workds;
      class &trtvar &keepvars &var;
      output out=lvl&i.sum(drop=_type_);
    run;

    %if &calcord NE N %then %do;
      data lvl&i.sum;
        set lvl&i.sum;
        ord=1/_freq_;
      run;

      proc sort data=lvl&i.sum;
        by &trtvar &keepvars ord &var;
      run;

      data lvl&i.sum;
        retain lvl&i.ord 0;
        set lvl&i.sum;
        by &trtvar &keepvars ord &var;
        %if %length(&trtvar &keepvars) %then %do;
          if first.%scan(&trtvar &keepvars,-1,%str( )) then lvl&i.ord=0;
        %end;
        if first.&var then lvl&i.ord=lvl&i.ord+1;
        drop ord;
      run;
    %end;

    data lvl&i.sum;
      set lvl&i.sum 
          lvl%eval(&i-1)sum(keep=&trtvar &keepvars _freq_ in=_x);
      if _x then do;
        %if &calcord NE N %then %do;
          lvl&i.ord=0;
        %end;
        &var="ANY %upcase(&oldvar)";
      end;
    run;

    proc sort data=lvl&i.sum;
      by &trtvar &keepvars &var;
    run;

    %if &i GT 1 %then %do;
      *- merge in lvlxord values -;
      data lvl&i.sum;
        merge lvl%eval(&i-1)sum(drop=_freq_) lvl&i.sum;
        by &trtvar &keepvars;
      run;
    %end;

    %let keepvars=&keepvars &var;
  %end;


  data &dsout;
    set lvl&totvars.sum;
  run;


  %if &debug NE Y %then %do;
    proc datasets nolist;
      delete lvl0sum _dsin _dsin2
      %do i=1 %to &totvars;
        lvl&i.sum
      %end;
      ;
    run;
    quit;
  %end;


       /*****************************************
           Demonstration and printing section
        *****************************************/

  %if &comblvls EQ Y %then %do;
    %comblvls(&dsout,&totvars,&colw,varlen=&varlen,split=&split,usecolon=&usecolon,
              indent=&indent,hindent=&hindent,byvars=&trtvar);
  %end;
  %else %do;
    %if &print EQ Y or &sortbyord EQ Y %then %do;
      proc sort data=&dsout;
        by &trtvar
        %do i=1 %to &totvars;
          lvl&i.ord
        %end;
        ;
      run;
    %end;
  %end;


  %if &print EQ Y %then %do;
    proc report nowd headline headskip missing split="&split" data=&dsout;
      columns &trtvar
      %if &comblvls NE Y %then %do;
        %do i=1 %to &totvars;
          lvl&i.ord lvl&i
        %end;
      %end;
      %else %do;
        %do i=1 %to &totvars;
          lvl&i.ord
        %end;
        comblvls
      %end;
      _freq_;
      %if %length(&trtvar) %then %do;
        define &trtvar / order;
      %end;
      %do i=1 %to &totvars;
        define lvl&i.ord / order noprint;
        %if &comblvls NE Y %then %do;
          define lvl&i / order width=22 flow;
        %end;
      %end;
      %if &comblvls EQ Y %then %do;
        define comblvls / display width=&colw flow;
      %end;
      define _freq_ / display;
      %if &comblvls EQ Y %then %do;
        break after lvl2ord / skip;
      %end;
      %else %do;
        break after lvl%eval(&totvars-1)ord / skip;
      %end;
    run;
  %end;

  %goto skip;
  %exit: %put &err: (freqlvls) Leaving macro due to problem(s) listed;
  %skip:
 
%mend freqlvls;
