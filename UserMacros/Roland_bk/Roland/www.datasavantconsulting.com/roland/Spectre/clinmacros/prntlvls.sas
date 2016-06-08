/*<pre><b>
/ Program   : prntlvls.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 02-Nov-2011
/ Purpose   : To print data created by the %freqlvls and %comblvls macros
/ SubMacros : %words
/ Notes     : This is only for printing a "levels" style dataset
/ Usage     : %prntlvls(dsin=myds,lvls=5,trtvars=TRT1 TRT2,colw=40)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Input dataset
/ lvls              Number of levels
/ breaklvl          Level for skipping a line
/ colw              column width of the COMBLVLS variable
/ comblabel         Label for the combined text column
/ pvalvar           P-value variable name if present
/ trtlabel          Label for all the transposed treatment variables
/ trtvars           Transposed treatment variables to display
/ trtw=13           Width for the treatment variables
/ trtalign=left     Alignment of treatment variable column headers
/ split=@           Split character
/ spacing=4         Spacing between columns
/ topline=yes       Default is to show a line at the top of the report
/ pageon            List of beginning text items in quotes of LVL1 values to
/                   force a page throw.
/ pageline=no       Default is not to show a line under the report on each page
/ pageline1-15      Additional lines (in quotes) to show at the bottom of each
/                   page.
/ pagemacro         Name of macro (no starting "%") to assign the page line
/                   values instead of setting them manually. This macro will be
/                   called in a "proc report" compute block so it must not
/                   contain any data step or procedure boundaries in any code
/                   it calls and must resolve to something that is syntactically
/                   correct for compute block processing. You can have 
/                   parameter settings in the macro call.
/ endline=no        Default is not to show a line under the end of the report.
/                   This is the best setting for ODS RTF tables and the like.
/ endline1-15       Additional lines (in quotes) to show at end of report
/ endmacro          Name of macro (no starting "%") to assign the end line
/                   values instead of setting them manually. This macro will be
/                   called in a "proc report" compute block so it must not
/                   contain any data step or procedure boundaries in any code
/                   it calls and must resolve to something that is syntactically
/                   correct for compute block processing. You can have 
/                   parameter settings in the macro call.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  27Oct11         New (v1.0)
/ rrb  01Nov11         pvalvar= parameter added (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: prntlvls v1.1;

%macro prntlvls(dsin=,
                lvls=,
            breaklvl=,
                colw=,
           comblabel=,
             pvalvar=,
            trtlabel=,
             trtvars=,
                trtw=13,
            trtalign=left,
               split=@,
             spacing=4,
              pageon=,
             topline=yes,
            pageline=no,
           pageline1=,
           pageline2=,
           pageline3=,
           pageline4=,
           pageline5=,
           pageline6=,
           pageline7=,
           pageline8=,
           pageline9=,
          pageline10=,
          pageline11=,
          pageline12=,
          pageline13=,
          pageline14=,
          pageline15=,
           pagemacro=,
             endline=no,
            endline1=,
            endline2=,
            endline3=,
            endline4=,
            endline5=,
            endline6=,
            endline7=,
            endline8=,
            endline9=,
           endline10=,
           endline11=,
           endline12=,
           endline13=,
           endline14=,
           endline15=,
            endmacro=
                );

  %local i err errflag ls center repwidth startcol numtrt pagevar lvlordlist;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (prntlvls) No dataset specified to dsin=;
  %end;

  %if not %length(&lvls) %then %do;
    %let errflag=1;
    %put &err: (prntlvls) No levels count specified to lvls=;
  %end;

  %if not %length(&colw) %then %do;
    %let errflag=1;
    %put &err: (prntlvls) No combined column width specified to colw=;
  %end;

  %if not %length(&trtvars) %then %do;
    %let errflag=1;
    %put &err: (prntlvls) No transposed treatment variables specified to trtvars=;
  %end;

  %if &errflag %then %goto exit;

  %let numtrt=%words(&trtvars);

  %if not %length(&topline) %then %let topline=yes;
  %let topline=%upcase(%substr(&topline,1,1));

  %if not %length(&pageline) %then %let pageline=no;
  %let pageline=%upcase(%substr(&pageline,1,1));
 
  %if not %length(&endline) %then %let endline=no;
  %let endline=%upcase(%substr(&endline,1,1));

  %let ls=%sysfunc(getoption(linesize));
  %let center=%sysfunc(getoption(center));

  %if not %length(&breaklvl) %then %let breaklvl=1;

  %if not %length(&split) %then %let split=@;

  %if not %length(&trtw) %then %let trtw=13;

  %if not %length(&spacing) %then %let spacing=4;

  %let repwidth=%eval(&colw+(&trtw+&spacing)*&numtrt);

  %if &center EQ NOCENTER %then %let startcol=1;
  %else %let startcol=%eval((&ls-&repwidth)/2 + 1);


  %if %length(&pageon) %then %let pagevar=_page;
  %else %let pagevar=_PAGE_;

  %let lvlordlist=;
  %do i=1 %to &lvls;
    %let lvlordlist=&lvlordlist lvl&i.ord;
  %end;

  proc sort data=&dsin out=_prnt;
    by &lvlordlist;
  run;


  data _prnt;
    retain _page 0;
    set _prnt;
    by &lvlordlist;
    %if %length(&pageon) %then %do;
      if first.lvl1ord and lvl1 in: (&pageon) then _page=_page+1;
    %end;
  run;


  proc report nowd headline headskip missing split="&split" spacing=&spacing data=_prnt;
    columns
    %if "&topline" EQ "Y" %then %do;
      ( "___" " " 
    %end;
    _page &lvlordlist comblvls 
    %if %length(&trtlabel) %then %do;
      (&trtlabel &trtvars)
    %end;
    %else %do;
      &trtvars &pvalvar
    %end;
    %if "&topline" EQ "Y" %then %do;
      )
    %end;
    ;
    define _page / order noprint;
    %do i=1 %to &lvls;
      define lvl&i.ord / order noprint;
    %end;
    define comblvls / display &comblabel spacing=0 width=&colw flow;
    %do i=1 %to &numtrt;
      define %scan(&trtvars,&i,%str( )) / display width=&trtw &trtalign;
    %end;
    %if %length(&pvalvar) %then %do;
      define &pvalvar / display width=8;
    %end;
    break after lvl&breaklvl.ord / skip;
    break after _page / page;

    %if "&pageline" EQ "Y" or %length(&pageline1.&pageline2.&pageline3.&pageline4) 
      or %length(&pagemacro) %then %do;
      compute after &pagevar;
        %if "&pageline" EQ "Y" %then %do;
          line @&startcol &repwidth*'_';
        %end;
        %if %length(&pagemacro) %then %do;
          %&pagemacro;
        %end;
        %else %do;
          %do i=1 %to 15;
            %if %length(&&pageline&i) %then %do;
              line @&startcol &&pageline&i;
            %end;
          %end;
        %end;
      endcomp;
    %end;

    %if "&endline" EQ "Y" or %length(&endline1.&endline2.&endline3.&endline4)
      or %length(&endmacro) %then %do;
      compute after;
        %if "&endline" EQ "Y" %then %do;
          line @&startcol &repwidth*'_';
        %end;
        %if %length(&endmacro) %then %do;
          %&endmacro;
        %end;
        %else %do;
          %do i=1 %to 15;
            %if %length(&&endline&i) %then %do;
              line @&startcol &&endline&i;
            %end;
          %end;
        %end;
      endcomp;
    %end;
  run;


  proc datasets nolist;
    delete _prnt;
  run;
  quit;


  %goto skip;
  %exit: %put &err: (prntlvls) Leaving macro due to problem(s) listed;
  %skip:
 
%mend prntlvls;
