/*<pre><b>
/ Program   : numchars.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 05-Oct-2014
/ Purpose   : To create a list of character variables that contain numeric-like
/             text.
/ SubMacros : %nvarsc
/ Notes     : It is not possible to implement this as a function-style macro due
/             to the data step boundary so the results will be written out to a
/             global macro variable. You can use this list in the char2num macro
/             that converts character fields to numeric fields. This macro uses
/             the commas32. informat to test whether the content of a variable
/             is numeric. It does not handle date or datetime text values.
/ Usage     : %numchars(dsname,globvar=_numchars_);
/             %put ######## &_numchars_;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset under test (no modifiers)
/ globvar=_numchars_    Name of the global macro variable to set up to contain
/                   the list of numeric-looking variables.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/ rrb  05Oct14         Informat comma32. used to test variable content (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: numchars v2.0;

%macro numchars(ds,globvar=_numchars_);

  %local err savopts;
  %let err=ERR%str(OR);

  %global &globvar;
  %let &globvar=;

  %let nvarsc=%nvarsc(&ds);

  %if &nvarsc EQ 0 %then %goto skip;

  %let savopts=%sysfunc(getoption(notes));
  options NONOTES;

  data _null_;
    array _num {&nvarsc} $ 1 _temporary_ (&nvarsc*'1');
    set &ds end=last;
    array _char (*) _character_;
    do i=1 to &nvarsc;
      if left(_char(i)) NOT IN (' ',',') then do;
        if missing(input(_char(i),?? comma32.)) then _num(i)='0';
      end;
    end;
    if last then do;
      do i=1 to &nvarsc;
        if _num(i) EQ '1' then call execute('%let &globvar=&&&globvar '||
          trim(upcase(vname(_char(i))))||';');
      end;
    end;
  run;

  options &savopts;

  %skip:

%mend numchars;
