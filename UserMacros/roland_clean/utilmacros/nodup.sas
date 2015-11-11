/*<pre><b>
/ Program   : nodup.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to drop duplicates in a space-delimited list
/ SubMacros : %words
/ Notes     : 
/ Usage     : %let str=%nodup(aaa bbb aaa);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ list              (pos) space-delimited list of items
/ casesens=no       Case sensitive. no by default.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: nodup v1.0;

%macro nodup(list,casesens=no);

  %local i j match item errflag err;
  %let err=ERR%str(OR);
  %let errflag=0;
  %if not %length(&casesens) %then %let casesens=no;
  %let casesens=%upcase(%substr(&casesens,1,1));

  %if not %index(YN,&casesens) %then %do;
    %put &err: (nodup) casesens must be set to yes or no;
    %let errflag=1;
  %end;

  %if &errflag %then %goto exit;

  %do i=1 %to %words(&list);
    %let item=%scan(&list,&i,%str( ));
    %let match=NO;
    %if &i LT %words(&list) %then %do;
      %do j=%eval(&i+1) %to %words(&list);
        %if &casesens EQ Y %then %do;
          %if "&item" EQ "%scan(&list,&j,%str( ))" %then %let match=YES;
        %end;
        %else %do;
          %if "%upcase(&item)" EQ "%upcase(%scan(&list,&j,%str( )))" %then %let match=YES;
        %end;
      %end;
    %end;
    %if &match EQ NO %then &item;
  %end;

  %goto skip;
  %exit: %put &err: (nodup) Leaving macro due to problem(s) listed;
  %skip:

%mend nodup;
  