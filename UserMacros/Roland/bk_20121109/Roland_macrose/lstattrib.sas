/*<pre><b>
/ Program   : lstattrib.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 30-Aug-2011
/ Purpose   : Lists the variable attributes of the specified dataset in the
/             form of a LENGTH statement and ATTRIB statement that can be used
/             in sas code.
/ SubMacros : none
/ Notes     : The information is written to the log as syntactically correct sas
/             code so you can copy and paste it into your sas program to help
/             you create a new dataset with the same attributes as the original
/             dataset. An actual example of what is written to the log is shown
/             below in the usage notes section.
/             
/             This macro is intended for interactive use as part of a data
/             pooling exercise, to generate correct LENGTH and ATTRIB statements
/             for the final pooled datasets. This macro could be run against
/             correct template datasets or datasets known to be correct so that
/             the LENGTH and ATTRIB statements could be stored in a central
/             location where programmers can copy and paste the code into their
/             own data pooling programs. The aim is to ensure that the final
/             datasets have all the correct variables and attributes.
/
/             See also the %dsattrib macro.
/
/ Usage     : %lstattrib(sasuser.demog)
/===============================================================================
/ TEST CODE FOLLOWS:
/===============================================================================

%lstattrib(sasuser.demog)

/===============================================================================
/ TEST OUTPUT FOLLOWS:
/===============================================================================

******  Attributes obtained from sasuser.demog  ******;
DATA xxxxxx;
  *- The order of the variables in the following LENGTH statement matches -;
  *- the variable order in the original dataset so do not change.         -;
  LENGTH dob 8 trtcd 8 sexcd 8 racecd 8 weight 8 height 8 patno 8 invid 8
         sitecd 8 fascd 8 age 8 trtcdx 8 trtsex 8
         ;

  *- The MERGE or SET statement for the input dataset(s) should go here.  -;
  SET yyyyyy;

  *- Overwrite the following missing values with what you are populating the  -;
  *- variables with. You may have to change the order of the variables where  -;
  *- there are dependencies such that the source variable is populated first. -;
  *- If you follow this method then when you get notes in the log about       -;
  *- uninitialised variables you will know that you are trying to populate a  -;
  *- variable with another variable that does not exist. You also avoid the   -;
  *- problem of spelling a variable name incorrectly when you assign a value  -;
  *- to it which can easily happen if there are a large number of variables.  -;

  dob    = .  ;
  trtcd  = .  ;
  sexcd  = .  ;
  racecd = .  ;
  weight = .  ;
  height = .  ;
  patno  = .  ;
  invid  = .  ;
  sitecd = .  ;
  fascd  = .  ;
  age    = .  ;
  trtcdx = .  ;
  trtsex = .  ;

  *- Cancel existing formats and informats in the input dataset(s) -;
  FORMAT   _all_ ;
  INFORMAT _all_ ;

  *- Assign output variable attributes -;
  ATTRIB
    age    format=3.                        label="AGE (YEARS)"
    dob    format=DATE9.  informat=DATE7.   label="DATE OF BIRTH"
    fascd  format=NY.     informat=COMMA13. label="FULL ANALYSIS SET (N/Y)"
    height format=5.1     informat=COMMA13. label="HEIGHT (CM)"
    invid                 informat=COMMA13. label="INVESTIGATOR ID"
    patno                 informat=COMMA13. label="PATIENT NUMBER"
    racecd format=RACECD. informat=COMMA13. label="RACE CODE"
    sexcd  format=SEXCD.  informat=COMMA13. label="GENDER CODE"
    sitecd                informat=COMMA13. label="SITE CODE"
    trtcd  format=TRTCD.  informat=COMMA13. label="TREATMENT REGIMEN"
    trtcdx format=TRTCDX.                   label=" "
    trtsex format=TRTSEX.                   label=
"GENDER/TREATMENT REGIMEN (1+2 female, 11+12 male)"
    weight format=5.1     informat=COMMA13. label="WEIGHT (KG)"
    ;

  *- KEEP statement for the variables listed above -;
  KEEP age dob fascd height invid patno racecd sexcd sitecd trtcd trtcdx
       trtsex weight
       ;
RUN;

/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) (unquoted) One-level or two-level dataset name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Apr11         Comment in generated code changed
/ rrb  04May11         Code tidy
/ rrb  30Aug11         Code added such that all the variables are initialised
/                      with missing values (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: lstattrib v2.0;

%macro lstattrib(ds);

  %local lib dsname dslabel maxname maxformat maxinformat errflag err savopts;
  %let err=ERR%str(OR);
  %let errflag=0;

  %let savopts=%sysfunc(getoption(notes));

  %if not %sysfunc(exist(&ds)) %then %do;
    %let errflag=1;
    %put &err: (lstattrib) Specified dataset &ds does not exist;
  %end;
  %if &errflag %then %goto exit;
  options nonotes;

  %if not %length(%scan(&ds,2,.)) %then %do;
    %let lib=%sysfunc(getoption(user));
    %if not %length(&lib) %then %let lib=work;
    %let lib=%upcase(&lib);
    %let dsname=%upcase(&ds);
  %end;
  %else %do;
    %let lib=%upcase(%scan(&ds,1,.));
    %let dsname=%upcase(%scan(&ds,2,.));
  %end;
 
  proc sql noprint;
    select memlabel into :dslabel separated by " "
    from dictionary.tables
    where libname="&lib" and memname="&dsname";

    create table _attr as
    select name, length, type, format, informat, label, varnum
    from dictionary.columns
    where libname="&lib" and memname="&dsname"
    order by name;

    create table _lens as
    select name, length, type, varnum
    from _attr
    order by varnum;
    
    select max(length(name)), max(length(format)), max(length(informat))
    into :maxname, :maxformat, :maxinformat separated by " "
    from _attr;
  quit;
 
  data _null_;
    length _str _str2 $ 200 _allvars $ 4000;
    retain maxname &maxname maxformat &maxformat maxinformat &maxinformat
           _allvars;
    file log;

    if _n_=1 then do;
      if maxformat=1 then maxformat=-8;
      if maxinformat=1 then maxinformat=-10;
      put;
      put @1 "******  Attributes obtained from &ds  ******;";
      %if %length(&dslabel) %then %do;
        _str='DATA xxxxxx(label="'||"&dslabel"||'");';
      %end;
      %else %do;
        _str='DATA xxxxxx;';
      %end;
      put @1 _str;
      put @3 "*- The order of the variables in the following LENGTH statement matches -;";
      put @3 "*- the variable order in the original dataset so do not change.         -;";
      put @3 "LENGTH " @;
      __i=1;
      _str=" ";
      do until(__i>_nobs);
        do until(length(_str)>60 or __i>_nobs);
          set _lens nobs=_nobs point=__i;
          if type EQ "char" then _str2=trim(name)||" $ "||left(put(length,5.));
          else _str2=trim(name)||" "||left(put(length,5.));
          _str=trim(_str)||" "||_str2;
          __i=__i+1;
        end;
        put @10 _str;
        _str=" ";
      end;
      put @10 ";";

      put;
      put @3 "*- The MERGE or SET statement for the input dataset(s) should go here.  -;";
      put @3 "SET yyyyyy;";
      put;
      put @3 "*- Overwrite the following missing values with what you are populating the  -;";
      put @3 "*- variables with. You may have to change the order of the variables where  -;";
      put @3 "*- there are dependencies such that the source variable is populated first. -;";
      put @3 "*- If you follow this method then when you get notes in the log about       -;";
      put @3 "*- uninitialised variables you will know that you are trying to populate a  -;";
      put @3 "*- variable with another variable that does not exist. You also avoid the   -;";
      put @3 "*- problem of spelling a variable name incorrectly when you assign a value  -;";
      put @3 "*- to it which can easily happen if there are a large number of variables.  -;";
      put;
      __i=1;
      _str=" ";
      do until(__i>_nobs);
        set _lens nobs=_nobs point=__i;
        if type EQ "char" then _str="= ' ';";
        else _str='= .  ;';
        put @3 name @(maxname+4) _str;
        __i=__i+1;
      end;
      put;
      put @3 "*- Cancel existing formats and informats in the input dataset(s) -;";
      put @3 "FORMAT   _all_ ;";
      put @3 "INFORMAT _all_ ;";
      put;
      put @3 "*- Assign output variable attributes -;";
      put @3 "ATTRIB" ;
    end; *- end of _n_=1 -;

    set _attr end=last;
    _allvars=trim(_allvars)||" "||name;

    if type="char" then _str="$"||trim(left(put(length,6.)));
    else _str=trim(left(put(length,6.)));
    put @5 name @;
    if format ne " " then put @(maxname+6) "format=" format @;
    if informat ne " " then put @(maxname+maxformat+14) "informat=" informat @;
    _str='"'||trim(tranwrd(label,'"','""'))||'"';
    put @(maxname+maxformat+maxinformat+24) "label=" _str @;
    put ;
    if last then do;
      put @5 ";" ;
      put;
      put @3 "*- KEEP statement for the variables listed above -;";
      put @3 "KEEP " @;
      scanidx=1;
      do until(scan(_allvars,scanidx," ")=" ");
        _str=" ";
        do until(scan(_allvars,scanidx," ")=" " or length(_str)>65);
          _str=trim(_str)||" "||scan(_allvars,scanidx," ");
          scanidx=scanidx+1;
        end;
        put @8 _str;
      end;
      put @8 ";" ;
      put @1 "RUN;";     
    end;
  run;
  %put;

  proc datasets nolist;
    delete _attr _lens;
  run;
  quit;

  options &savopts;

  %goto skip;
  %exit: %put &err: (lstattrib) Leaving macro due to problem(s) listed;
  %skip:

%mend lstattrib;
