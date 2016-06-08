/*<pre><b>
/ Program   : optvarlen.sas
/ Version   : 1.2
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-Apr-2013
/ Purpose   : To create an output dataset with the same variable order as the
/             input dataset but with character variables reduced to their
/             optimum length such that they are long enough to hold the longest
/             value but no longer.
/ SubMacros : %dsattr %optlength %quotelst %dslabel
/ Notes     : Specify variables you do not want optimized to the notvars=
/             parameter (variable names will be ignored if not present in the
/             input dataset).
/
/             You can specify modifiers with the input dataset (such as a drop
/             list) and this will be processed before variable optimization.
/             If the output dataset is specified without modifiers then it will
/             be assigned the dataset label of the input dataset (if it exists).
/
/             A practical use for this macro (and why it was written) is to
/             achieve a single step SDTM Plus to SDTM conversion. The drop
/             variables could be written to a macro variable and resolved as
/             a drop list modifier for the input dataset in the call to this
/             macro and the output SDTM dataset would have these variables
/             dropped with the remaining variables in the same relative order as
/             the input dataset plus all the character fields optimised for
/             length with selected fields such as --TESTCD unchanged if desired.
/             &domain.TESTCD could be used as a notvars= variable for all
/             domains because if the variable does not exist in the domain it
/             will be ignored.
/
/ Usage     : %optvarlen(sashelp.class,classattr);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) (unquoted) One-level or two-level input dataset name
/                   (modifiers allowed).
/ dsout             (pos) (unquoted) One-level or two-level output dataset name
/ notvars           List of variable names separated by spaces where you do not
/                   want the variable lengths to be changed.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  03Apr13         New (v1.0)
/ rrb  04Apr13         Modifiers allowed for input dataset plus output dataset
/                      assigned the label of the input dataset (v1.1)
/ rrb  04Apr13         Minor bugs fixed (v1.2)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: optvarlen v1.2;

%macro optvarlen(dsin,dsout,notvars=);

  %local sasvge92 err errflag savopts dslabel;
  %let err=ERR%str(OR);
  %let errflag=0;


  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (optvarlen) No input dataset specified as the first positional parameter;
  %end;

  %if not %length(&dsout) %then %do;
    %let errflag=1;
    %put &err: (optvarlen) No output dataset specified as the second positional parameter;
  %end;

  %if &errflag %then %goto exit;


  %let savopts=%sysfunc(getoption(NOTES));
  options nonotes;


  *- assume all variable names will be upcase -;
  %let notvars=%upcase(&notvars);


  *- store the input dataset label -;
  %let dslabel=%dslabel(%scan(&dsin,1,%str(%()));


  %if %index(&dsin,%str(%()) %then %do;
    *- allow modifiers to take effect -;
    data _optvds;
      set &dsin;
    run;
    %let dsin=_optvds;
  %end;


  *- detect if user is using sas 9.2 or later -;
  %if %sysevalf(&sysver GE 9.2) %then %let sasvge92=1;
  %else %let sasvge92=0;


  *- get variable info -;
  %dsattr(&dsin,dsout=_optvin);


  *- calculate optimum lengths -;
  %optlength(&dsin,dsout=_optvlens);


  *- drop optimum lengths for selected variables -;
  %if %length(&notvars) %then %do;
    data _optvlens;
      set _optvlens;
      where name not in (%quotelst(&notvars));
    run;
  %end;


  *- use the output from optlength to update the variable info -;
  data _optvnew;
    update _optvin _optvlens;
    by name;
  run;


  *- assign filerefs to receive length and other code from lstattrib -;
  filename _optvlen TEMP;
  filename _optjunk TEMP;


  *- call lstattrib to write the length code -;
  %lstattrib(dsattr=_optvnew,lenfile=_optvlen,attrfile=_optjunk);


  *- switch off variable length warnings -;
  %if &sasvge92 %then options varlenchk=nowarn;;


  *- apply the length code and create the output dataset -;
  data &dsout
    %if %length(&dslabel) and not %length(%scan(&dsout,2,%str(%())) %then %do;
      (label="&dslabel")
    %end;
    ;
    %include _optvlen;
    set &dsin;
  run;


  *- switch back on variable length warnings -;
  %if &sasvge92 %then options varlenchk=warn;;


  *- clear the filerefs -;
  filename _optvlen CLEAR;
  filename _optjunk CLEAR;


  *- delete work datasets -;
  proc datasets nolist;
    delete _optvin _optvlens _optvnew
    %if "&dsin" EQ "_optvds" %then %do;
           _optvds
    %end;
    ;
  run;
  quit;


  *- restore incoming notes option -;
  options &savopts;


  %goto skip;
  %exit: %put &err: (optvarlen) Leaving macro due to problem(s) listed;
  %skip:

%mend optvarlen;