/*<pre><b>
/ Program   : samplevars.sas
/ Version   : 3.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 29-Sep-2014
/ Purpose   : To sample the non-missing values in all the variables in a dataset
/             and write them to an output dataset either as uncondensed sample
/             values or combined (condensed) sample values.
/ SubMacros : %varlist %words %dsall %dslist %cont2dict %getvalue
/ Notes     : This macro reads an input dataset(s) and samples all the variable
/             values and creates an output dataset with the fields: libname,
/             memname, name, type, format and sample (for uncondensed data) or
/             samples (for condensed data).
/
/             You can specify a maximum number of observations to use for each
/             input dataset and the maximum number of samples to keep for each
/             variable.
/
/             Multiple datasets for dsin= are allowed and the "_all_" notation
/             is supported.
/
/ Usage     : %samplevars(sashelp.class)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input dataset(s) for sampling (no modifiers - multiple
/                   datasets should be separated with spaces).
/ dsout             (pos) Output dataset containing samples (no modifiers -
/                   defaults to _samplevars if not specified).
/ maxobs            (pos) Maximum number of input observations
/ maxsamples        (pos) Maximum number of samples for each variable
/ order             (pos) Count order. Default is null for no ordering but 
/                   "ascending" or "descending" or "A" or "D" (without quotes)
/                   can be specified. Using "A" will give the least common
/                   values with the least common first and using "D" will give
/                   the most common values with the most common first.
/ samplelen=200     Default length of sample field is 200
/ upcasevars=yes    By default, show variable names in the "name" field as upper
/                   case.
/ condense=no       By default, do not condense the samples into one field
/    ########## Further condensing parameters follow ##########
/ comblen=2000      Default length of combined samples field is 2000
/ separator=%str(, ) Default separator for combining sample values is a comma
/                   followed by a space.
/ quotetext=no      By default, do not quote the text values when combining them
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  08Jul14         New (v1.0)
/ rrb  09Jul14         Allow for multiple input datasets and apply any existing
/                      formats to the values. "Format" field added to output
/                      dataset and "type" field now 4 characters long (v2.0)
/ rrb  29Sep14         "order" positional parameter added to allow selection on
/                      the least or most common sample values. %mkformat no
/                      longer used and replaced by using %getvalue (v3.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: samplevars v3.0;

%macro samplevars(dsin
                ,dsout
               ,maxobs
           ,maxsamples
                ,order
            ,samplelen=200
           ,upcasevars=yes
             ,condense=no
              ,comblen=2000
            ,separator=%str(, )
            ,quotetext=no
                 );

  %local i j err errflag savopts varlist maxvars var libname memname
         ds outlib outmem fmt;

  %let err=ERR%str(OR);
  %let errflag=0;


  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (samplevars) No dataset(s) specified for dsin=;
  %end;

  %if &errflag %then %goto exit;
  


  %let savopts=%sysfunc(getoption(notes)) %sysfunc(getoption(msglevel,keyword));
  options nonotes msglevel=N;


  *- set up a format for variable type -;
  proc format;
    value $_vartyp
    'N'='num'
    'C'='char'
    ;
  run;


  *- make sure we have all the parameters values we need -;
  %if not %length(&dsout) %then %let dsout=_samplevars;
  %if not %length(&samplelen) %then %let samplelen=200;
  %if not %length(&comblen) %then %let comblen=200;
  %if not %length(%superq(separator)) %then %let separator=%str(, );
  %if not %length(&condense) %then %let condense=no;
  %if not %length(&quotetext) %then %let quotetext=no;
  %if not %length(&upcasevars) %then %let upcasevars=yes;


  *- reduce the responses to a single uppercase character -;
  %let condense=%upcase(%substr(&condense,1,1));
  %let quotetext=%upcase(%substr(&quotetext,1,1));
  %let upcasevars=%upcase(%substr(&upcasevars,1,1));
  %if %length(&order) %then %let order=%upcase(%substr(&order,1,1));



  *- delete the output dataset if it exists -;
  %if %sysfunc(exist(&dsout)) %then %do;

    %let outlib=%upcase(%scan(&dsout,1,.));
    %let outmem=%upcase(%scan(&dsout,2,.));
    %if not %length(&outmem) %then %do;
      %let outmem=&outlib;
      %let outlib=%upcase(%sysfunc(getoption(user)));
      %if not %length(&outlib) %then %let outlib=WORK;
    %end;

    proc datasets nolist lib=&outlib;
      delete &outmem;
    quit;

  %end;


  *- expand out the list of input datasets -;
  %dsall(&dsin);


  /*########################################
        Loop through the input datasets
    ########################################*/

  %do i=1 %to %words(&_dsall_);

    %let ds=%scan(&_dsall_,&i,%str( ));  

    %let varlist=%varlist(&ds);
    %let maxvars=%words(&varlist);

    %if &upcasevars EQ Y %then %let varlist=%upcase(&varlist);


    *- get the libname and memname of the dataset -;
    %let libname=%upcase(%scan(&ds,1,.));
    %let memname=%upcase(%scan(&ds,2,.));
    %if not %length(&memname) %then %do;
      %let memname=&libname;
      %let libname=%upcase(%sysfunc(getoption(user)));
      %if not %length(&libname) %then %let libname=WORK;
    %end;


    *- Run a "proc contents" on the data -;
    %cont2dict(&ds,_samplefmt);


    *- run proc freq and produce a table for every variable -;
    proc freq noprint data=&ds
    %if %length(&maxobs) %then %do;
      (obs=&maxobs)
    %end;
    ;
    %do j=1 %to &maxvars;
      %let var=%scan(&varlist,&j,%str( ));
      table &var / out=_samp&j(keep=&var count rename=(&var=_val) 
            where=(not missing(_val)));
    %end;
    run;


    *- Make sure the values are all character -;
    *- and store the variable name and type.  -;
    %do j=1 %to &maxvars;

      %if %length(&order) %then %do;
        %if "&order" EQ "A" %then %do;
          proc sort data=_samp&j;
            by count;
          run;
        %end;
        %else %if "&order" EQ "D" %then %do;
          proc sort data=_samp&j;
            by DESCENDING count;
          run;
        %end;
      %end;

      %let var=%scan(&varlist,&j,%str( ));
      %let fmt=%getvalue(_samplefmt(where=(upcase(name)="&var")),format);
      data _samp&j;
        length name   $ 32 
               type   $ 4
               sample $ &samplelen
               format $ 49;
        retain type   "%sysfunc(putc(%vartype(_samp&j,_val),$_vartyp.))" 
               name   "&var"
               format "&fmt";
        set _samp&j
        %if %length(&maxsamples) %then %do;
          (obs=&maxsamples)
        %end;
        ;
        %if %length(&fmt) %then %do;
          sample=put(_val,&fmt);
        %end;
        %else %do;
          sample=_val;
        %end;
        DROP count _val;
      run;
    %end;


    *- bring all the sampled variable data together -;
    data _samplev;
      length libname $ 8 memname $ 32;
      retain libname "&libname" memname "&memname";
      SET
      %do j=1 %to &maxvars;
        _samp&j
      %end;
      ;
    run;


    *- drop the individual variable sample tables -;
    proc datasets nolist;
      delete _samplefmt
      %do j=1 %to &maxvars;
        _samp&j
      %end;
      ;
    quit;


    *- Condense processing to combine samples into one -;
    %if &condense EQ Y %then %do;

      proc sort data=_samplev;
        by libname memname name;
      run;

      data _samplev;
        length samples $ &comblen;
        retain samples ' ';
        set _samplev;
        by libname memname name;
        if first.name then samples=' ';
        %if &quotetext EQ Y %then %do;
          if upcase(subpad(type,1,1))='C' then do;
            if samples=' ' then samples='"'||strip(sample)||'"';
            else samples=strip(samples)||"&separator"||'"'||strip(sample)||'"';
          end;
          else do;
            if samples=' ' then samples=strip(sample);
            else samples=strip(samples)||"&separator"||strip(sample);
          end;
        %end;
        %else %do;
          if samples=' ' then samples=strip(sample);
          else samples=strip(samples)||"&separator"||strip(sample);
        %end;
        if last.name then output;
        DROP sample;
      run;

    %end;

    proc append force base=&dsout data=_samplev;
    run;

    proc datasets nolist;
      delete _samplev;
    quit;

  %end;  %*- end of looping through the input datasets -;


  options &savopts;

  %goto skip;
  %exit: %put &err: (samplevars) Leaving macro due to problem(s) listed;
  %skip:


%mend samplevars;
