/*<pre><b>
/ Program   : alluniq.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To create a dataset with all unique occurences of a variable
/             throughout a library.
/ SubMacros : %hasvars
/ Notes     : The output dataset will be in sorted order if valid
/ Usage     : %alluniq(in,subject,allsubj)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ libref            (pos) Libref
/ variable          (pos) Variable name
/ dsout             (pos) Output dataset name (defaults to "alluniq")
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  16Jun03         Create null output dataset and use %hasvars
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: alluniq v1.0;

%macro alluniq(libref,variable,dsout);

  %local err;
  %let err=ERR%str(OR);

  %if not %length(&libref) %then %let libref=%sysfunc(getoption(user));
  %if not %length(&libref) %then %let libref=work;

  %if not %length(&variable) %then %do;
    %put &err: (alluniq) No variable name specified;
    %goto skip;
  %end;

  %if not %length(&dsout) %then %let dsout=alluniq;


  *- create null output dataset -;
  data &dsout;
  _u_m_b_j=.;
  run;


  data _null_;
    set sashelp.vcolumn(where=(libname="%upcase(&libref)" 
                               and upcase(name)="%upcase(&variable)"));
    if _n_=1 then do;
      call execute('proc sort nodupkey data='||trim(libname)||'.'||trim(memname)||
      "(keep=&variable) out=&dsout;by &variable;run;");
    end;
    else do;
      call execute('proc sort nodupkey data='||trim(libname)||'.'||trim(memname)||
      "(keep=&variable) out=_alluniq;by &variable;");
      call execute('proc append base=&dsout data=_alluniq;run;');
    end;
  run;


  %if %hasvars(&dsout,&variable) %then %do;
    proc sort nodupkey data=&dsout;
      by &variable;
    run;
  %end;
  %else %put &err: (alluniq) Library &libref has no instances of variable &variable;


  proc datasets nolist;
    delete _alluniq;
  run;
  quit;

  %skip:

%mend alluniq;
