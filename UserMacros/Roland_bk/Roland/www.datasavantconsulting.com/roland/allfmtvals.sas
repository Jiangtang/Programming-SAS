/*<pre><b>
/ Program      : allfmtvals.sas
/ Version      : 1.2
/ Author       : Roland Rashleigh-Berry
/ Date         : 13-Feb-2007
/ Purpose      : Create a dataset with every start value of a format in
/ SubMacros    : none
/ Notes        : Works for both numeric and character formats. For character
/                formats it is better if you define the correct length to the
/                length= parameter. You can also specify a decode variable in
/                the output dataset.
/ Usage        : %allfmtvals(fmt=$country,var=country,dsout=temp1,length=2)
/                %allfmtvals(fmt=site,var=site,dsout=temp2)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ fmt               Format name (can end with a "." or not)
/ dsout             Output data set name (no modifiers)
/ var               Variable to go in output dataset containing all the start
/                   values of the format.
/ length=8          Default length for the output variable if format is a
/                   character format.
/ decodevar         Decode variable (optional)
/ decodelen         Length of decode variable
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  14jul05         decodevar= and decodelen= added so that the decoded
/                      version of the variable can be put in the output dataset.
/ rrb  13Feb07         "macro called" message added
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: allfmtvals v1.2;

%macro allfmtvals(fmt=,dsout=,var=,length=8,decodevar=,decodelen=160);

%local error dummyval type ;
%let error=0;


   /*-----------------------*
        Check parameters
    *-----------------------*/

%if not %length(&fmt) %then %do;
  %let error=1;
  %put ERROR: (allfmtvals) No format supplied to fmt=;
%end;
%else %if "%substr(&fmt,%length(&fmt),1)" NE "." %then %let fmt=&fmt..;

%if not %length(&dsout) %then %do;
  %let error=1;
  %put ERROR: (allfmtvals) No output dataset supplied to dsout=;
%end;

%if not %length(&var) %then %do;
  %let error=1;
  %put ERROR: (allfmtvals) No variable name supplied to var=;
%end;

%if &error %then %goto error;

%if "%substr(&fmt,1,1)" EQ "$" %then %do;
  %let type=CHAR;
  %if not %length(&length) %then %let length=8;
  %let dummyval=" ";
%end;
%else %do;
  %let type=NUM;
  %let dummyval=.;
%end;


   /*-----------------------*
             Process
    *-----------------------*/

data &dsout;
  %if &type EQ CHAR %then %do;
    length &var $ &length;
  %end;
  &var=&dummyval;
  format &var &fmt;
run;

proc summary nway missing completetypes data=&dsout;
  class &var / preloadfmt;
  output out=&dsout(drop=_type_ _freq_ where=(&var ne &dummyval));
run;

%if %length(&decodevar) %then %do;
  data &dsout;
    length &decodevar $ &decodelen;
    set &dsout;
    &decodevar=put(&var,&fmt);
  run;
%end;


   /*---------------------*
             Exit
    *---------------------*/

%goto skip;
%error:
%put ERROR: (allfmts) Leaving macro due to error(s) listed;
%skip:
%mend;
