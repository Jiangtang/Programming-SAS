/*<pre><b>
/ Program   : char2num.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 05-Oct-2014
/ Purpose   : To "effectively" convert a list of character variables to numeric
/ SubMacros : %cont2dict %removew %words %editlist %suffix %lstattrib %quotelst
/             %nvarsc
/ Notes     : Converting variable types in SAS datasets is not allowed so this
/             macro will create new numeric variables having the same name as
/             the original character variables with the same variable positional
/             order and variable label.
/
/             If a value for vars= is not given then the qualifying list of
/             character variables will be those that convert to numeric using
/             the comma32. informat.
/
/ Usage     : %char2num(test,test2,cvar1 cvar2)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input data set (no modifiers)
/ dsout             (pos) Output data set (no modifiers)
/ vars              (pos - optional) character variables (separated by spaces)
/                   to convert to numeric using the comma32. informat (if left
/                   null then a list of all qualifying character variable in the
/                   input dataset will be used).
/ dontdo=           (optional - separated by spaces - not case sensitive) List
/                   of character variables that should not be converted to
/                   numeric even if they have a numeric text content.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  05Oct14         New (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: char2num v2.0;

%macro char2num(dsin,dsout,vars,dontdo=);

  %local err errflag i var savopts;
  %let err=ERR%str(OR);
  %let errflag=0;
  %let savopts=%sysfunc(getoption(notes));
  options NONOTES;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (char2num) No input dataset specified as first positional parameter;
  %end;

  %if &errflag %then %goto exit;


  %cont2dict(&dsin);

  %if not %length(&vars) %then %do;

    %numchars(&dsin);
    %let vars=%upcase(&_numchars_);

  %end;

  %if %length(&dontdo) %then %let vars=%removew(&vars,&dontdo);

  %if not %length(&vars) %then %do;

    %if %length(&dsout) and "&dsout" NE "&dsin" %then %do;
      data &dsout;
        set &dsin;
      run;
    %end;

    %goto skip;

  %end;
  %else %do;

    data _cont2dict2;
      set _cont2dict;
      if upcase(name) IN (%quotelst(&vars)) then do;
        type='num';
        informat=' ';
        length=8;
        format=' ';
      end;
    run;

    filename _lengths TEMP;
    filename _attribs TEMP;

    %lstattrib(dsattr=_cont2dict2,dsset=,init=no,
               lenfile=_lengths,attrfile=_attribs);


    %if not %length(&dsout) %then %let dsout=&dsin;

    data &dsout;
      %include _lengths / nosource;
      set &dsin(rename=(%editlist(&vars,'&item=&item._x')));
      %do i=1 %to %words(&vars);
        %let var=%scan(&vars,&i,%str( ));
        &var=input(&var._x,comma32.);
      %end;
      %include _attribs / nosource;
    run;

    filename _lengths CLEAR;
    filename _attribs CLEAR;

    proc datasets nolist;
      delete _cont2dict _cont2dict2;
    quit;

  %end;


  %goto skip;
  %exit: %put &err: (char2num) Leaving macro due to problem(s) listed;
  %skip:

  options &savopts;

%mend char2num;
