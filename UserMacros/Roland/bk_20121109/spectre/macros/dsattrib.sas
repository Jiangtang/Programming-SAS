/*<pre><b>
/ Program   : dsattrib.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 29-Mar-2007
/ Purpose   : To force a set of attributes, held in a template dataset,
/             on another dataset.
/ SubMacros : %sortedby %dslabel %varlist %nvarsc %nvarsn %missvars %misscnt
/ Notes     : The template dataset can either have observations or not. None of
/             its observations will be carried forward to the output dataset.
/ Usage     : %dsattrib(template,inds,outds)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ template          Template dataset (pos). Please do not rename any sortby
/                   variables on the dataset statement.
/ dsin              Input dataset (pos)
/ dsout             Output dataset (pos) (No drop, keep, rename or where)
/ misscnt           Will display a count of missing values by default. Set this
/                   to "no" to stop this (pos - unquoted)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dsattrib v1.0;

%macro dsattrib(template,dsin,dsout,misscnt);

%local sortedby dslabel varlist nvarsc nvarsn;

%if %length(&misscnt) EQ 0 %then %let misscnt=yes;
%let misscnt=%upcase(%substr(&misscnt,1,1));


*- get the label and sortedby list from the template dataset -;
%let sortedby=%sortedby(%scan(&template,1,%str(%()));
%let dslabel=%dslabel(%scan(&template,1,%str(%()));


*- drop all observations from the template dataset -;
options obs=0;
data _templ;
  set &template;
run;
options obs=max;


*- get the variable list from the template dataset -;
%let varlist=%varlist(_templ);


*- allow where/keep/drop/rename to apply to input dataset -;
data _dsin;
  set &dsin;
run;


*- find out the number of character and numeric variables --;
%let nvarsc=%nvarsc(_dsin);
%let nvarsn=%nvarsn(_dsin);


*- nullify any formats and informats -;
data _dsin;
  set _dsin;
  %if &nvarsc GT 0 %then %do;
    informat _character_ ;
    format _character_ ;
  %end;
  %if &nvarsn GT 0 %then %do;
    informat _numeric_ ;
    format _numeric_ ;
  %end;
run;


*- create the corrected output dataset -;
data &dsout(label="&dslabel");
  set _templ _dsin(keep=&varlist);
run;


*- sort the output dataset if the template dataset was sorted -;
%if %length(&sortedby) GT 0 %then %do;
  proc sort data=&dsout;
    by &sortedby;
  run;
%end;


*- report all-missing variables as an error -;
%missvars(&dsout,globvar=_miss_);
run;
%if %length(&_miss_) GT 0 %then %do;
  %put ERROR: (dsattrib) The following variables in the input dataset were all-missing;
  %put ERROR: (dsattrib) &_miss_;
%end;


*- optionally report missing value count (excluding all-missing variables) -;
*- as a warning.;
%if "&misscnt" EQ "Y" %then %do;
  %misscnt(&dsout,&_miss_,globvar=_miss_);
  run;
  %if %length(&_miss_) GT 0 %then %do;
    %put WARNING: (dsattrib) The following variables have a missing value count as shown;
    %put WARNING: (dsattrib) &_miss_;
  %end; 
%end;


*- tidy up temporary datasets -;
proc datasets nolist;
  delete _templ _dsin;
run;
quit;

%mend;
