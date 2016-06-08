/*<pre><b>
/ Program   : dsattr.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 02-Apr-2013
/ Purpose   : Extract attributes for a dataset from dictionary.columns
/ SubMacros : none
/ Notes     : This is a simple macro to extract dataset attributes from
/             dictionary.columns and write them to an output dataset in variable
/             name order. Variables present will be name, length, type, format,
/             informat, label and varnum. The dataset created is suitable for
/             the dsattr= parameter for the %lstattrib macro and is also
/             suitable to be updated by the dataset coming out of the %optlength
/             macro.
/
/             See also the %dsattrib macro.
/
/ Usage     : %dsattr(sashelp.class,classattr);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) (unquoted) One-level or two-level input dataset name
/ dsout             (pos) (unquoted) One-level or two-level output dataset name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  02Apr13         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: dsattr v1.0;

%macro dsattr(dsin,
              dsout
             );

  %local lib dsname errflag err savopts;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (dsattr) No input dataset specified as first positional parameter;
  %end;

  %if &errflag %then %goto exit;

  %if not %length(&dsout) %then %let dsout=_dsattr;

  %let savopts=%sysfunc(getoption(notes));


  %if not (%sysfunc(exist(&dsin)) OR %sysfunc(exist(&dsin,VIEW))) %then %do;
    %let errflag=1;
    %put &err: (dsattr) Specified dataset &dsin does not exist;
  %end;
  %if &errflag %then %goto exit;

  %if not %length(%scan(&dsin,2,.)) %then %do;
    %let lib=%sysfunc(getoption(user));
    %if not %length(&lib) %then %let lib=work;
    %let lib=%upcase(&lib);
    %let dsname=%upcase(&dsin);
  %end;
  %else %do;
    %let lib=%upcase(%scan(&dsin,1,.));
    %let dsname=%upcase(%scan(&dsin,2,.));
  %end;

  options nonotes;

  proc sql noprint;
    create table &dsout as
    select name, length, type, format, informat, label, varnum
    from dictionary.columns
    where libname="&lib" and memname="&dsname"
    order by name;
  quit;

  options &savopts;

  %goto skip;
  %exit: %put &err: (dsattr) Leaving macro due to problem(s) listed;
  %skip:

%mend dsattr;
