%macro title_foot(tstartvar=titlstrt,fstartvar=footstrt,debug=0);
  /*soh*************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : title_foot
   AUTHOR                   : Greg Steffens
   DESCRIPTION              : Determines what the last unused title line number
                              is and returns the value in a macro variable
                              specified by the  tstartvar parameter.  Does the
                              same for footnotes.
   INFRASTRUCTURE           : Windows, MVS
--------------------------------------------------------------------------------
  Parameters:
   Name      Type     Default  Description and Valid Values
   --------  -------- -------- -------------------------------------------------
   TSTARTVAR required titlstrt Name of macro variable that is assigned the 
                                first available title line number
   DEBUG     required 0        %ut_logical value specifying whether to turn
                                debug mode on or not
--------------------------------------------------------------------------------
  Usage Notes:

--------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    title4 'tst';
    footnote2 'test';
    %title_foot;
    %put titlstrt=&titlstrt    footstrt=&footstrt;

    Result:  titlstrt=5    footstrt=3


    %titlstrt;
    title&titlstrt "this is the first unused title line";
    title%eval(&titlstrt + 1) "the next unused title line";
    .
    .
    .
    title&titlstrt;  to be put at end of macro to clear titles it used

--------------------------------------------------------------------------------
 **eoh*************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%global &tstartvar &fstartvar;
%local maxtitle dsid rc;
%let &tstartvar = 1;
%*=============================================================================;
%* Find highest title line number used and add 1 to it;
%*=============================================================================;
%let dsid = %sysfunc(open(sashelp.vtitle (where = (type = 'T')),i));
%if &dsid > 0 %then %do;
  %if &debug %then %put (titlstrt) dsid=&dsid;
  %let &tstartvar = %eval(%sysfunc(attrn(&dsid,nlobsf)) + 1);
  %let rc = %sysfunc(close(&dsid));
  %if &debug %then %do;
    %put (titlstrt) dsid=&dsid close of vtitle view rc=&rc
     &tstartvar=&&&tstartvar;
    proc print data = sashelp.vtitle;
    run;
  %end;
%end;
%else %put UWARNING (titlestart) Unable to open sashelp.vtitle dsid=&dsid;
%*=============================================================================;
%* If the title line number is invalid then set it to 10;
%*=============================================================================;
%if &&&tstartvar < 1 | &&&tstartvar > 10 %then %do;
  %put UWARNING (titlestrt) maximum number of title lines is invalid -
   resetting to 10;
  %let &tstartvar = 10;
%end;
%*=============================================================================;
%* Find highest title line number used and add 1 to it;
%*=============================================================================;
%let dsid = %sysfunc(open(sashelp.vtitle (where = (type = 'F')),i));
%if &dsid > 0 %then %do;
  %if &debug %then %put (titlstrt) dsid=&dsid;
  %let &fstartvar = %eval(%sysfunc(attrn(&dsid,nlobsf)) + 1);
  %let rc = %sysfunc(close(&dsid));
  %if &debug %then %do;
    %put (titlstrt) dsid=&dsid close of vtitle view rc=&rc
     &fstartvar=&&&fstartvar;
    proc print data = sashelp.vtitle;
    run;
  %end;
%end;
%else %put UWARNING (titlestart) Unable to open sashelp.vtitle dsid=&dsid;
%*=============================================================================;
%* If the footnote line number is invalid then set it to 10;
%*=============================================================================;
%if &&&fstartvar < 1 | &&&fstartvar > 10 %then %do;
  %put UWARNING (titlestrt) maximum number of footnote lines is invalid -
   resetting to 10;
  %let &fstartvar = 10;
%end;
%if &debug %then %put titlstrt macro ending;
%mend;
