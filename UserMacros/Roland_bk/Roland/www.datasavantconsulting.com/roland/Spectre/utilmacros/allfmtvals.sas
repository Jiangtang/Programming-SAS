/*<pre><b>
/ Program      : allfmtvals.sas
/ Version      : 1.3
/ Author       : Roland Rashleigh-Berry
/ Date         : 13-Apr-2011
/ Purpose      : Create a dataset with every start value of a format in it
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
/ nmissval=.        Default missing numeric value to be excluded from the output
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  14jul05         decodevar= and decodelen= added so that the decoded
/                      version of the variable can be put in the output dataset.
/ rrb  13Feb07         "macro called" message added
/ rrb  12Apr11         Added nmissval= parameter and indented code
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: allfmtvals v1.3;

%macro allfmtvals(fmt=,dsout=,var=,length=8,decodevar=,decodelen=160,nmissval=.);

  %local errflag dummyval type err;
  %let errflag=0;
  %let err=ERR%STR(OR);


   /*----------------------*
        Check parameters
    *----------------------*/

  %if not %length(&fmt) %then %DO;
    %let errflag=1;
    %put &err: (allfmtvals) No format supplied to fmt=;
  %end;
  %else %if "%substr(&fmt,%length(&fmt),1)" NE "." %then %let fmt=&fmt..;

  %if not %length(&dsout) %then %DO;
    %let errflag=1;
    %put &err: (allfmtvals) No output dataset supplied to dsout=;
  %end;

  %if not %length(&var) %then %DO;
    %let errflag=1;
    %put &err: (allfmtvals) No variable name supplied to var=;
  %end;

  %if &errflag %then %goto exit;

  %if "%substr(&fmt,1,1)" EQ "$" %then %DO;
    %let type=CHAR;
    %if not %length(&length) %then %let length=8;
    %let dummyval=" ";
  %end;
  %else %DO;
    %let type=NUM;
    %let dummyval=&nmissval;
  %end;


   /*-----------------------*
             Process
    *-----------------------*/

  data &dsout;
    %if &type EQ CHAR %then %DO;
      length &var $ &length;
    %end;
    &var=&dummyval;
    format &var &fmt;
  run;

  proc summary nway missing completetypes data=&dsout;
    class &var / preloadfmt;
    output out=&dsout(drop=_type_ _freq_ where=(&var ne &dummyval));
  run;

  %if %length(&decodevar) %then %DO;
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
  %exit:
  %put &err: (allfmtvals) Leaving macro due to problem(s) listed;
  %skip:
%mend allfmtvals;
