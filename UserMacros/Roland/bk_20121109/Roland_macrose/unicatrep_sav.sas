/*<pre><b>
/ Program      : unicatrep.sas
/ Version      : 4.4
/ Author       : Roland Rashleigh-Berry
/ Date         : 27-Jan-2008
/ Purpose      : Clinical reporting macro to produce a report from the dataset
/                output from the %unistats macro of treatment-transposed
/                categories counts and statistics.
/ SubMacros    : %words (assumes %popfmt and %titles already run)
/ Notes        : You can call this macro directly from %unistats by setting the
/                unicatrep= parameter.
/
/ Usage        : %unicatrep(dsin=_unitran)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Input dataset
/ byvars            By variable(s)
/ style=1           Layout style; 1=indented, 2=separate columns
/ catlabel          (quoted) By default, do not display a label for the category
/                   column.
/ total=yes         By default, print the total for all treatment groups if it
/                   exists in the input dataset.
/ pvalues=yes       By default, print the pvalues as a treatment column if it
/                   exists in the input dataset.
/ varw=12           Width of variable label column for style=2 reports
/ varlabel          (quoted) By default, do not display a label for the 
/                   variable column for style=2 reports.
/ catw              By default this macro will assign a category column width
/                   to meet the page width.
/ trtlabel          (quoted) Default is not to show a treatment label
/ topline=no        Default is not to show a line at the top of the report. This
/                   is the best setting for ODS RTF tables and the like.
/ pageline=no       Default is not to show a line under the report on each page
/ pageline1-9       Additional lines (in quotes) to show at the bottom of each
/                   page.
/ endline=no        Default is not to show a line under the report at the end.
/                   This is the best setting for ODS RTF tables and the like.
/ endline1-9        Additional lines (in quotes) to show at end of report
/ pgbrkpos=before   Page break position defaults to "before". This will allow
/                   the endline1-9 to be put after the last item is displayed.
/                   If set to "after" (no quotes) then endline1-9 will be forced
/                   onto a new page.
/ trtspace=4        Default spaces to leave between treatment arms
/ trtw1-9           Widths for each treatment column
/ indent=4          Spaces to indent categories for report
/ split=@           Split character (no quotes) for proc report if requested
/ headskip=yes      Skip a line at the top
/ breakvar=_varord  Identity of break variable for line skipping
/ breakpos=after    Position to skip a line for the break variable
/ spantotal=yes     Include total column under trtlabel
/ out               Named output dataset from proc report if required
/ odsrtf            Give the "file='filename' style=style" (unquoted) to create
/                   rtf output. "ods rtf   ;" and "ods rtf close;" will be
/                   automatically generated. If you want to suppress the plain
/                   text output then use "ods listing close;" before the call to
/                   the macro and "ods listing;" afterwards to reinstate listing
/                   output. Use of topline=no is advised with ods options.
/ odshtml           Works the same way as odsrtf
/ odshtmlcss        Works the same way as odsrtf
/ odscsv            Works the same way as odsrtf
/ odspdf            Works the same way as odsrtf
/ odsother          Works the same way as odsrtf but you have to supply the
/                   destination word as the first word.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  11jul05         Version 2.0 has logic for handling byvars= changed. It is
/                      now used in a "by" statement in "proc report".
/ rrb  25Jan06         endline= parameters added
/ rrb  13Feb07         "macro called" message added
/ rrb  21Mar07         Allow for the "nocenter" option (v2.1)
/ rrb  23Mar07         strlen= parameter added for default variable length to go
/                      with a change in %unistats that allows for catnfmt=
/                      format length to be greater than 3.
/ rrb  24Mar07         Treat "A0"x like "FE"x (v3.1)
/ rrb  25Mar07         Checks to see if _strlen_ has a value and uses that if
/                      strlen= null else uses 11.
/ rrb  16May07         "FE"x no longer treated as a space (v3.3)
/ rrb  30Jul07         Header tidy
/ rrb  16Sep07         Added out= parameter to save output dataset from proc
/                      report.
/ rrb  18Sep07         style= and odsrtf= parameters added for v4.0
/ rrb  19Sep07         odshtml= and odspdf= parameters added
/ rrb  21Sep07         odsother= parameter added
/ rrb  23Sep07         Header tidy
/ rrb  30Sep07         topline=no is now the default which is better suited to
/                      ODS output.
/ rrb  27Jan08         odshtmlcss=, odscsv= and varlabel= parameters added and
/                      trtlabel= now defaults to null.
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: unicatrep v4.4;

%macro unicatrep(dsin=,
               byvars=,
                style=1,
             catlabel=,
                total=yes,
              pvalues=yes,
                 varw=12,
             varlabel=,
                 catw=,
             trtlabel=,
              topline=no,
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
             pgbrkpos=before,
             trtspace=4,
                trtw1=,
                trtw2=,
                trtw3=,
                trtw4=,
                trtw5=,
                trtw6=,
                trtw7=,
                trtw8=,
                trtw9=,
               indent=4,
                split=@,
             headskip=yes,
             breakvar=_breakvar,
             breakpos=after,
            spantotal=yes,
               strlen=,
                  out=,
               odsrtf=,
              odshtml=,
           odshtmlcss=,
               odscsv=,
               odspdf=,
             odsother=
             );

%local i error ls trtwidth repwidth startcol rest numtrt totvar pvalvar
       cwidth cwidths center;

%global _strlen_;



             /*-----------------------------------------*
                  Check we have enough parameters set
              *-----------------------------------------*/
              
%let error=0;

%let ls=%sysfunc(getoption(linesize));
%let center=%sysfunc(getoption(center));

%if %length(&out) and %length(&byvars) %then %do;
  %let out=;
  %put WARNING: (unicatrep) out= parameter value not allowed with byvars=;
%end;

%if not %length(&style) %then %let style=1;
%if not %length(&strlen) %then %let strlen=&_strlen_;
%if not %length(&strlen) %then %let strlen=11;

%if not %length(&varw) %then %let varw=12;
%if not %length(&varlabel) %then %let varlabel=" ";

%if not %length(&catw) %then %let catw=0;
%if not %length(&catlabel) %then %let catlabel=" ";

%if not %length(&headskip) %then %let headskip=yes;
%let headskip=%upcase(%substr(&headskip,1,1));
%if "&headskip" EQ "Y" %then %let headskip=headskip;
%else %let headskip=;

%if not %length(&topline) %then %let topline=no;
%let topline=%upcase(%substr(&topline,1,1));

%if not %length(&total) %then %let total=yes;
%let total=%upcase(%substr(&total,1,1));

%if not %length(&pvalues) %then %let pvalues=yes;
%let pvalues=%upcase(%substr(&pvalues,1,1));

%if not %length(&pageline) %then %let pageline=no;
%let pageline=%upcase(%substr(&pageline,1,1));

%if not %length(&endline) %then %let endline=no;
%let endline=%upcase(%substr(&endline,1,1));

%if not %length(&pvalues) %then %let pvalues=no;
%let pvalues=%upcase(%substr(&pvalues,1,1));

%if not %length(&spantotal) %then %let spantotal=yes;
%let spantotal=%upcase(%substr(&spantotal,1,1));

%if not %length(&trtspace) %then %let trtspace=4;

%if not %length(&indent) %then %let indent=0;

%if not %length(&split) %then %let split=@;

%if not %length(&breakvar) %then %let breakvar=_breakvar;

%if not %length(&dsin) %then %do;
  %let error=1;
  %put ERROR: (unicatrep) No input dataset assigned to dsin=;
%end;

%if not %length(&pgbrkpos) %then %let pgbrkpos=before;

%if &error %then %goto error;


             /*-----------------------------------------*
                        Calculate report width
              *-----------------------------------------*/

%let cwidths=&_trtcwidths_;
%if "&total" EQ "Y" %then %let cwidths=&cwidths &_trttotcwidth_;

%do i=1 %to 9;
  %if not %length(&&trtw&i) %then %do;
    %let cwidth=%scan(&cwidths,&i,%str( ));
    %if &cwidth GT &strlen %then %let trtw&i=&cwidth;
    %else %let trtw&i=&strlen;
  %end;
%end;

%let totvar=;

%if "&total" EQ "Y" %then %do;
  %if %varnum(&dsin,&_trttotvar_) %then %let totvar=&_trttotvar_;
%end;

%let pvalvar=;

%if "&pvalues" EQ "Y" %then %do;
  %if %varnum(&dsin,&_trtpvalvar_) %then %let pvalvar=&_trtpvalvar_;
%end;

%let numtrt=%words(&_trtvarlist_ &totvar);


%let trtwidth=0;
%do i=1 %to &numtrt;
  %let trtwidth=%eval(&trtwidth+&trtspace+&&trtw&i);
%end;

%if %length(&pvalvar) %then %let trtwidth=%eval(&trtwidth+&trtspace+8);

%if "&style" NE "2" %then %let rest=%eval(&ls-&trtwidth-&indent);
%else %let rest=%eval(&ls-&trtwidth-2-&varw);


%if &catw EQ 0 %then %let catw=&rest;
%else %if &rest LT &catw %then %let catw=&rest;


%if "&style" EQ "2" %then %let repwidth=%eval(&catw+&trtwidth+2+&varw);
%else %let repwidth=%eval(&catw+&trtwidth+&indent);


%if &center EQ NOCENTER %then %let startcol=1;
%else %let startcol=%eval((&ls-&repwidth)/2 + 1);


%if "&style" NE "2" %then %do;
  data _unicatrep;
    length _varlabel $ &repwidth;
    set &dsin;
    _breakvar=_varord;
    if _varlabel=" " or _varlabel="A0"x 
      then _breakvar=_varord-1;
  run;
%end;
%else %do;
  data _unicatrep;
    set &dsin;
    _breakvar=_varord;
    _varlabel=translate(_varlabel," ","A0"x);
  run;
%end;



%if %length(&byvars) %then %do;
  proc sort data=_unicatrep;
    by &byvars;
  run;
%end;


             /*-----------------------------------------*
                             Produce report
              *-----------------------------------------*/

%if %length(&odsrtf) %then %do;
  ods rtf &odsrtf ;
%end;

%if %length(&odshtml) %then %do;
  ods html &odshtml ;
%end;

%if %length(&odshtmlcss) %then %do;
  ods html &odshtmlcss ;
%end;

%if %length(&odscsv) %then %do;
  ods html &odscsv ;
%end;

%if %length(&odspdf) %then %do;
  ods pdf &odspdf ;
%end;

%if %length(&odsother) %then %do;
  ods &odsother ;
%end;


proc report missing headline &headskip nowd split="&split" data=_unicatrep
  %if %length(&out) %then %do;
    out=&out
  %end;
  ;

  %if %length(&byvars) %then %do;
    by &byvars;
  %end; 
 
  columns
  %if "&topline" EQ "Y" %then %do;
    ( "___" " " 
  %end;

  _page &breakvar _varord _varlabel _statord 
  
  %if &indent GT 0 and "&style" NE "2" %then %do;
    _indent 
  %end;
  
  _statlabel 
  
  %if %length(&trtlabel) %then %do;
    %if "&spantotal" EQ "Y" %then %do;
      ( &trtlabel &_trtvarlist_ &totvar )
    %end;
    %else %do;
      ( &trtlabel &_trtvarlist_ ) &totvar
    %end;
  %end;
  %else %do;
    &_trtvarlist_ &totvar
  %end;

  &pvalvar

  %if "&topline" EQ "Y" %then %do;
    )
  %end;
  ;

  define _page / order noprint;
  define &breakvar / order order=internal noprint;
  define _varord / order order=internal noprint;
  %if "&style" EQ "2" %then %do;
    define _varlabel / &varlabel order width=&varw flow spacing=0;
  %end;
  %else %do;
    define _varlabel / order noprint;
  %end;
  define _statord / order order=internal noprint;
  %if &indent GT 0 and "&style" NE "2" %then %do;
    define _indent / " " order width=&indent spacing=0;
  %end;
  %if "&style" EQ "2" %then %do;
    define _statlabel / &catlabel order width=&catw flow spacing=2;
  %end;
  %else %do;
    define _statlabel / &catlabel order width=&catw flow spacing=0;
  %end;
  %do i=1 %to %words(&_trtvarlist_);
    define %scan(&_trtvarlist_,&i,%str( )) / width=&&trtw&i center display
spacing=&trtspace;
  %end;
  %if %length(&totvar) %then %do;
    define &totvar / width=&&trtw&i center display spacing=&trtspace;
    %let i=%eval(&i+1);
  %end;
  %if %length(&pvalvar) %then %do;
    define &pvalvar / width=8 center display spacing=&trtspace;
  %end;
  %if &indent gt 0 and "&style" NE "2" %then %do;
    compute before _varlabel;
      line @&startcol _varlabel $char&repwidth..;
    endcomp;
  %end;
  %if "&pageline" EQ "Y" or %length(&pageline1) or %length(&pageline2) 
     or %length(&pageline3) or %length(&pageline4) %then %do;
    compute after _page;
      %if "&pageline" EQ "Y" %then %do;
        line &repwidth*'_';
      %end;
      %do i=1 %to 9;
        %if %length(&&pageline&i) %then %do;
          line @&startcol &&pageline&i;
        %end;
      %end;
    endcomp;
  %end;
  %if "&endline" EQ "Y" or %length(&endline1) or %length(&endline2) 
     or %length(&endline3) or %length(&endline4) %then %do;
    compute after;
      %if "&endline" EQ "Y" %then %do;
        line &repwidth*'_';
      %end;
      %do i=1 %to 9;
        %if %length(&&endline&i) %then %do;
          line @&startcol &&endline&i;
        %end;
      %end;
    endcomp;
  %end;

  break &breakpos &breakvar / skip;
  break &pgbrkpos _page / page;
run;

%if %length(&odsrtf) %then %do;
  ods rtf close;
%end;

%if %length(&odshtml) %then %do;
  ods html close;
%end;

%if %length(&odshtmlcss) %then %do;
  ods htmlcss close;
%end;

%if %length(&odscsv) %then %do;
  ods csv close;
%end;

%if %length(&odspdf) %then %do;
  ods pdf close;
%end;

%if %length(&odsother) %then %do;
  ods %scan(&odsother,1,%str( )) close;
%end;


             /*-----------------------------------------*
                                  Exit
              *-----------------------------------------*/

%goto skip;
%error:
%put ERROR: (unicatrep) Leaving macro due to error(s) listed;
%skip:
%mend;
