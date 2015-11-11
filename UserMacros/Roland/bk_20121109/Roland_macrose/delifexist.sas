/*<pre><b>
/ Program   : delifexist.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 05-Apr-2011
/ Purpose   : To delete a dataset if it exists
/ SubMacros : none
/ Notes     : none
/ Usage     : %delifexist(sasuser.myds)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsname            (pos) One or two level dataset name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: delifexist v1.0;

%macro delifexist(dsname);

  %if %sysfunc(exist(&dsname)) %then %do;
    %if %length(%scan(&dsname,2,.)) %then %do;
      proc datasets nolist lib=%scan(&dsname,1,.);
        delete %scan(&dsname,2,.);
      run;
      quit;
    %end;
    %else %do;
      proc datasets nolist;
        delete &dsname;
      run;
      quit;
    %end;
  %end;

%mend delifexist;
