/*<pre><b>
/ Program   : numchars.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 29-Mar-2007
/ Purpose   : To create a list of character variables that contain numeric-like
/             text.
/ SubMacros : %nvarsc
/ Notes     : It is not possible to implement this as a function-style macro due
/             to the data step boundary so the results will be written out to a
/             global macro variable. You can use this list in the char2num macro
/             that converts character fields to numeric fields. This macro uses
/             the verify function with the test string '0123456789., ' to test
/             for numeric-like entries which is not a perfect test. Using this
/             test then if a field is character and all-missing then it will be
/             assumed to be a possible numeric field.
/ Usage     : %numchars(dsname,globvar=_numchars_);
/             %put ######## &_numchars_;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                Dataset (pos) (must be pure dataset name and have no keep,
/                   drop, where or rename associated with it).
/ globvar=_numchars_    Name of the global macro variable to set up to contain
/                   the list of all-missing variables.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: numchars v1.0;

%macro numchars(ds,globvar=_numchars_);

%global &globvar;
%let &globvar=;

%let nvarsc=%nvarsc(&ds);

%if &nvarsc EQ 0 %then %do;
  %put ERROR: (numchars) Data set &ds does not contain any character variables;
  %goto error;
%end;


data _null_;
  array _num {&nvarsc} $ 1 _temporary_ (&nvarsc*'1');
  set &ds end=last;
  array _char (*) _character_;
  do i=1 to &nvarsc;
    if verify(_char(i),'0123456789., ') then _num(i)='0';
  end;
  if last then do;
    do i=1 to &nvarsc;
      if _num(i) EQ '1' then call execute('%let &globvar=&&&globvar '||
        trim(vname(_char(i)))||';');
    end;
  end;
run;

%goto skip;
%error:
%put ERROR: Leaving numchars macro due to error(s) listed;
%skip:
%mend;
