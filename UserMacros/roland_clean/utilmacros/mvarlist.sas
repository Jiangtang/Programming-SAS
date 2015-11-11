/*<pre><b>
/ Program   : mvarlist.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return a list of macro variable names
/             satisfying the supplied scope.
/ SubMacros : none
/ Notes     : All macro variable names returned will be in uppercase. If no
/             scope name is supplied then the scope will be set to GLOBAL. The
/             supplied scope name can be lower or upper case because it will be
/             converted to upper case automatically.
/ Usage     : %macro dummy(a=123,b=345,c=);
/               %let setparmlist=%mvarlist(dummy,s);
/             %mend dummy;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ scopename         (pos) Name of the scope of the macro variables (no quotes)
/                   such as GLOBAL or MACRONAME. Value will be converted to
/                   upper case. If left blank then "GLOBAL" is used.
/ contents          (pos - no quotes) Default is "any" macro variables with the
/                   supplied scope but you can specify "empty" or "set" to
/                   select on macro variables with no assigned values or only
/                   macro variables with assigned values. Only the first
/                   character is inspected so "a"="any", "e"="empty" and
/                   "s"="set".
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: mvarlist v1.0;

%macro mvarlist(scopename,contents);

  %local dsid rc name namenum value valuenum mvarlist contents2 err;
  %let err=ERR%str(OR);
  %let mvarlist=;

  %if not %length(&scopename) %then %let scopename=GLOBAL;
  %else %let scopename=%upcase(&scopename);

  %if not %length(&contents) %then %let contents=any;
  %let contents2=%upcase(%substr(&contents,1,1));
  %if not %index(ASE,&contents2) %then %do;
    %put &err: (mvarlist) Expected "any", "empty" or "set" but you supplied "&contents";
    %goto exit;
  %end; 

  %let dsid=%sysfunc(open(sashelp.vmacro(where=(scope="&scopename")),is));
  %if &dsid EQ 0 %then %do;
    %put &err: (mvarlist) sashelp.vmacro not opened due to the following reason:;
    %put %sysfunc(sysmsg());
    %goto exit;
  %end;
  %else %do;
    %let namenum=%sysfunc(varnum(&dsid,name));
    %let valuenum=%sysfunc(varnum(&dsid,value));
  %end;

  %readloop:
    %let rc=%sysfunc(fetch(&dsid));
    %if &rc %then %goto endoff;
    %let name=%sysfunc(getvarc(&dsid,&namenum));
    %let value=%sysfunc(getvarc(&dsid,&valuenum));
    %if &contents2 EQ A %then %let mvarlist=&mvarlist &name;
    %else %if &contents2 EQ S %then %do;
      %if %length(&value) %then %let mvarlist=&mvarlist &name;
    %end;
    %else %if &contents2 EQ E %then %do;
      %if not %length(&value) %then %let mvarlist=&mvarlist &name;
    %end;
  %goto readloop;


  %endoff:
&mvarlist
  %let rc=%sysfunc(close(&dsid));


  %goto skip;
  %exit: %put &err: (mvarlist) Leaving macro due to problem(s) listed;
  %skip:

%mend mvarlist;
