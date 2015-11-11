/*<pre><b>
/ Program   : rename8.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 12-Feb-2011
/ Purpose   : Function-style macro to return a variable rename list for variable
/             names longer than 8 characters to shorten them to 8 characters.
/ SubMacros : %varlist
/ Notes     : No checking for the uniqueness of variable names is done. Use this 
/             macro to get legacy code working where for some reason you are
/             getting variable names more than 8 characters long where you are
/             not expecting it. Most problems come from transposes but if you
/             set VALIDVARNAME=V6 before the transpose and VALIDVARNAME=V7 after
/             the transpose then it should solve the problem. If you can not do
/             that for some reason or somebody sends you a dataset with variable
/             names longer than 8 characters and you need to shorten them then
/             perhaps this macro can be of use. Note that this will not work on 
/             variable names that have spaces in them created with the option
/             VALIDVARNAME=ANY in effect. If none of the variables names are
/             more than 8 characters long then the null string is returned. This
/             will not cause a problem in a RENAME statement (see Usage below)
/             as then the RENAME statement will be ignored.
/ Usage     : data myds2;
/               set myds;
/               rename %rename8(myds);
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: rename8 v1.0;

%macro rename8(ds);
  %local i varlist renlist var;
  %let varlist=%varlist(&ds);
  %let var=%scan(&varlist,1,%str( ));
  %do %while(%length(&var));
    %if %length(&var) GT 8 %then %let renlist=&renlist &var=%substr(&var,1,8);
    %let i=%eval(&i+1);
    %let var=%scan(&varlist,&i,%str( ));
  %end;
&renlist
%mend rename8;
