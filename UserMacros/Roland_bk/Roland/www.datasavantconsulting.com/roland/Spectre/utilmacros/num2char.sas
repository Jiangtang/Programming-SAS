/*<pre><b>
/ Program   : num2char.sas
/ Version   : 2.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 06-Oct-2014
/ Purpose   : To "effectively" convert a list of numeric variables to character
/ SubMacros : %cont2dict %removew %words %editlist %suffix %lstattrib %quotelst
/             %getvalue
/ Notes     : Converting variable types in SAS datasets is not allowed so this
/             macro will create new character variables having the same name as
/             the original numeric variables with the same variable positional
/             order and variable label. The format used to convert the numeric
/             value to character will be the format already assigned to the
/             numeric variable or BEST. if this is not defined.
/ Usage     : %num2char(test,test2,nvar1 nvar2)
/             %num2char(sashelp.class,class,dontdo=aGe)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input data set (no modifiers)
/ dsout             (pos) Output data set (no modifiers)
/ vars              (pos - optional) Numeric variables (separated by spaces) to
/                   convert to character (if left null then a list of all
/                   numeric variable in the input dataset will be used).
/ dontdo=           (optional - separated by spaces - not case sensitive) List
/                   of numeric variables that should not be converted to
/                   character.
/ len=20            Default length to use for the character variables created
/                   (maximum 32).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  01Oct14         New (v1.0)
/ rrb  03Oct14         Labels and variable positional order kept. fmt= parameter
/                      dropped. Format for output will use any existing format
/                      applied to the numeric variable otherwise BEST. will be
/                      used. The resulting string value will be left-aligned
/                      (v2.0)
/ rrb  06Oct14         Allow maximum of len=32 (v2.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: num2char v2.1;

%macro num2char(dsin,dsout,vars,dontdo=,len=20);

  %local err errflag i var fmt savopts;
  %let err=ERR%str(OR);
  %let errflag=0;
  %let savopts=%sysfunc(getoption(notes));
  options NONOTES;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (num2char) No input dataset specified as first positional parameter;
  %end;

  %if &errflag %then %goto exit;

  %if not %length(&len) %then %let len=20;
  %if &len GT 32 %then %let len=32;


  %cont2dict(&dsin);

  %if not %length(&vars) %then %do;

    PROC SQL NOPRINT;
      select upcase(name) into :vars separated by ' '
      from _cont2dict
      where type='num';
    QUIT;

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
        type='char';
        informat=' ';
        length=&len;
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
        %let fmt=%getvalue(_cont2dict(where=(upcase(name)="&var")),format);
        %if not %length(&fmt) %then %let fmt=BEST&len..;
        &var=left(put(&var._x,&fmt));
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
  %exit: %put &err: (num2char) Leaving macro due to problem(s) listed;
  %skip:

  options &savopts;

%mend num2char;
