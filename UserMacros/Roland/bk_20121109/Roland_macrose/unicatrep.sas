/*<pre><b>
/ Program      : unicatrep.sas
/ Version      : 4.24
/ Author       : Roland Rashleigh-Berry
/ Date         : 02-Jun-2008
/ Purpose      : Clinical reporting macro to produce a report from the dataset
/                output from the %unistats macro of treatment-transposed
/                categories counts and statistics.
/ SubMacros    : %words %removew (assumes %popfmt and %titles already run)
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
/ print=yes         If set to "no" (no quotes) the .lst output will be
/                   suppressed. This is in case you just want ODS output.
/ catlabel=" "      For a print, the default is for no category column label
/ varlabel=" "      For a print, the default is for no variable column label
/ total=yes         By default, print the total for all treatment groups if it
/                   exists in the input dataset.
/ pvalues=yes       By default, print the pvalues as a treatment column if it
/                   exists in the input dataset.
/ varw=12           Width of variable label column for style=2 reports
/ catw              By default this macro will assign a category column width
/                   to meet the page width.
/ trtlabel          Label for combined category counts and stats
/ topline=no        Default is not to show a line at the top of the report. This
/                   is the best setting for ODS RTF tables and the like.
/ pageline=no       Default is not to show a line under the report on each page
/ pageline1-9       Additional lines (in quotes) to show at the bottom of each
/                   page.
/ endline=no        Default is not to show a line under the report at the end
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
/ odslisting        Allows you to specify a file= statement to pass through to
/                   the %unicatrep macro.
/ odsother          Works the same way as odsrtf but you have to supply the
/                   destination word as the first word.
/ byrowvar          This is for when you want to show a "by" variable as a row
/                   following the variable you are analyzing.
/ byroword          Ordering variable for byrowvar if needed
/ byrowlabel        Label for byrowvar
/ byrowalign        Alignment of byrow (left/center/right)
/ byrowfmt          Format for byrow variable
/ byroww            Width for byrowvar
/ byrow2var         Second byrow variable
/ byrow2ord         Second byrow ordering variable if needed
/ byrow2label       Second byrow label
/ byrow2align       Second byrow alignment (left/center/right)
/ byrow2fmt         Second byrow format
/ byrow2w           Width for byrow2var
/ compskip=no       (no quotes) By default, do not use a compute block for line
/                   skips. Set this to "yes" only for non-paging ODS output such
/                   as html so that you get an effect like "break after / skip"
/                   showing blank lines in the output. Never set to "yes" for
/                   paginated output.
/ byrowfirst=no     (no quotes) Default is not to display the variable declared
/                   to byrowvar= as the first column.
/ trtvarlist        You should not need to use this except in special situations
/                   where you want to specify labels to go with the transposed 
/                   treatment variables in the proc report call at the end of
/                   this macro such as in this example:
/              trtvarlist=("__ DRUG 1 __" TRT1 TRT2) ("__ DRUG 2 __" TRT3 TRT4)
/                   You need to know what treatment variables there are and
/                   this will be put in the log by the %popfmt macro. If you
/                   are specifying column widths (usually not required) then if
/                   you change the natural order of these TRT variables then the
/                   trtw(n)= value that acts on a variable is the one that you
/                   would use if the natural order had not been changed.
/                   ============================================================
/                   Note that the following parameters apply to ODS output only
/ spanrows=yes      Applies to sas v9.2 and later. Default is to enable the
/                   "spanrows" option for "proc report". You should leave this
/                   set to "yes" (no quotes) unless you have a clear need.
/ font_face_stats=Courier   Font to use for ODS output of the calculated stats
/                   values. For correct alignment of the decimal point for non-
/                   paired stats for MS Office then this must be set to
/                   "Courier" (no quotes).
/ font_weight_stats=bold    Weight of font to use for stats columns 
/                   (choice of light, medium or bold).
/ font_weight_other=bold    Weight of font to use for columns other than 
/                   the calculated stats.
/ font_face_other=Times     Font to use for ODS output for columns other
/                   than the calculated stats.
/ font_style_other=roman    Font style (italic or roman) to use for ODS output
/                   for columns other than the calculated stats.
/ font_weight_other=bold    Weight of font to use for columns other than 
/                   the calculated stats (choice of light, medium or bold).
/ report_border=no  Whether to draw a border around the report
/ header_border=no  Whether to draw a border around the column headers
/ column_border=no  Whether to draw a border around the cells in the report
/ lines_border=no   Whether to draw a border around the computed lines in the 
/                   report.
/ rules=none        Ruler lines to use in the report must be set to one of the
/                   following: none, all, cols, rows, groups.
/ cellspacing=0     Spacing between cells
/ cellpadding=0     Padding between cells
/ outputwidthpct=calc    Integer percentage of the ODS output width to use. 
/                   Default is "calc" (no quotes) for the %unistats macro to 
/                   calculate a suitable value itself (ReportWidth*2/3).
/                   Set to null (nothing) for ODS to do automatic sizing. This
/                   won't look nice as there will be insufficient space between
/                   columns with the default cellspacing=0. Set to whatever
/                   integer percentage you like, otherwise. If this is set to
/                   anything other than null then the column widths for ascii
/                   reports are used to calculate percentages for individual
/                   columns (if these are available).
/                   ============================================================
/                   Colors for the different parts of the table
/ background_header=white
/ foreground_header=black
/ background_stats=white
/ foreground_stats=black
/ background_other=white
/ foreground_other=black
/                   ============================================================
/                   Whether to draw underlines (_ul) or overlines (_ol) for
/                   different parts of the report.
/ header_ul=yes
/ report_ul=yes
/ report_ol=yes
/ linepx=1          Width of drawn line in pixels
/ linecol=black     Color of drawn line
/ compskip_ul=no    Default is not to underline the compskip extra lines
/ compskippx=1      Width in pixels of the compskip underlines
/ compskipcol=black   Color of the compskip underlines
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
/ rrb  27Jan08         varlabel=, odshtmlcss=, odscsv= and print=yes parameters
/                      added and trtlabel= now defaults to null.
/ rrb  02Feb08         byrow*= and compskip= parameters added
/ rrb  03Feb08         More byrow*= parameters added
/ rrb  03Feb08         Allow style=1 for byrow= parameters
/ rrb  09Feb08         compskip=no is now the default
/ rrb  10Feb08         Column layout bug fixed
/ rrb  15Mar08         odslisting= parameter added
/ rrb  16Mar08         "ods listing" statement used to free ods listing file
/ rrb  17Mar08         byrowfirst= parameter added and breakvar= and breakpos=
/                      parameters removed.
/ rrb  18Mar08         trtvarlist= parameter added
/ rrb  22Mar08         "flow" added to byrow columns
/ rrb  08May08         style(COLUMN)={HTMLSTYLE="mso-number-format:'\@'"} added
/                      to proc report call so that MS Office treats the cells as
/                      text-formatted cells. The same can be achieved using
/                      headtext="<style> td {mso-number-format:\@}</style>"
/                      in the ODS statement but it is hard to remember.
/ rrb  09May08         font_face_stats=, font_face_other= and font_weight_other=
/                      parameters added.
/ rrb  09May08         report_border=, header_border=, column_border=, rules=
/                      cellspacing= and lines_border= parameters added.
/ rrb  11May08         compskippos= and outputwidthpct= parameters added
/ rrb  11May08         foreground and background parameters added
/ rrb  12May08         _ul and _ol parameters added
/ rrb  13May08         font_style_other= and font_weight_stats parameters added
/ rrb  14May08         cellwidth applied to "indent" column
/ rrb  14May08         Cellwidth algorith changed for all fields to take into
/                      account column spacing in the ascii version.
/ rrb  14May08         font_weight_stats= default changed to bold and 
/                      outputwidthpct= default changed to calc.
/ rrb  18May08         compskip_ul= compskippx= compskipcol= paremeters added
/ rrb  19May08         Border suppressed for computed variable label lines
/ rrb  02Jun08         spanrows= parameter added
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: unicatrep v4.24;

%macro unicatrep(dsin=,
               byvars=,
                style=1,
                print=yes,
             catlabel=" ",
             varlabel=" ",
                total=yes,
              pvalues=yes,
                 varw=12,
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
            spantotal=yes,
               strlen=,
                  out=,
               odsrtf=,
              odshtml=,
           odshtmlcss=,
               odscsv=,
               odspdf=,
           odslisting=,
             odsother=,
             byrowvar=,
             byroword=,
           byrowlabel=" ",
           byrowalign=,
             byrowfmt=,
               byroww=,
            byrow2var=,
            byrow2ord=,
          byrow2label=" ",
          byrow2align=,
            byrow2fmt=,
              byrow2w=,
             compskip=no,
          compskippos=after,
           byrowfirst=no,
           trtvarlist=,
             spanrows=yes,
      font_face_stats=Courier,
    font_weight_stats=bold,
      font_face_other=Times,
     font_style_other=roman,
    font_weight_other=bold,
    background_header=white,
    foreground_header=black,
     background_stats=white,
     foreground_stats=black,
     background_other=white,
     foreground_other=black,
        report_border=yes,
        header_border=yes,
        column_border=yes,
         lines_border=no,
                rules=none,
          cellspacing=0,
          cellpadding=0,
            header_ul=yes,
            report_ul=yes,
            report_ol=yes,
               linepx=1,
              linecol=black,
       outputwidthpct=calc,
          compskip_ul=no,
           compskippx=1,
          compskipcol=black
                );

%local i error ls trtwidth repwidth startcol rest numtrt totvar pvalvar
       cwidth cwidths center;

%global _strlen_;

%if not %length(&spanrows) %then %let spanrows=yes;
%let spanrows=%upcase(%substr(&spanrows,1,1));
%if "&spanrows" EQ "Y" and 
  %sysevalf( %scan(&sysver,1,.).%scan(&sysver,2,.) GE 9.2 ) 
  %then %let spanrows=spanrows;
%else %let spanrows=;

%if not %length(&linepx) %then %let linepx=1;

%if not %length(&compskip_ul) %then %let compskip_ul=no;
%if not %length(&header_ul) %then %let header_ul=yes;
%if not %length(&report_ul) %then %let report_ul=yes;
%if not %length(&report_ol) %then %let report_ol=yes;

%let compskip_ul=%upcase(%substr(&compskip_ul,1,1));
%let header_ul=%upcase(%substr(&header_ul,1,1));
%let report_ul=%upcase(%substr(&report_ul,1,1));
%let report_ol=%upcase(%substr(&report_ol,1,1));


%if not %length(&compskippos) %then %let compskippos=after;
%if %upcase(&compskippos) EQ BEFORE %then %let headskip=no;

%if not %length(&cellspacing) %then %let cellspacing=0;
%if not %length(&rules) %then %let rules=none;

%if not %length(&report_border) %then %let report_border=no;
%if not %length(&header_border) %then %let header_border=no;
%if not %length(&column_border) %then %let column_border=no;
%if not %length(&lines_border) %then %let lines_border=no;

%let report_border=%upcase(%substr(&report_border,1,1));
%let header_border=%upcase(%substr(&header_border,1,1));
%let column_border=%upcase(%substr(&column_border,1,1));
%let lines_border=%upcase(%substr(&lines_border,1,1));


%if not %length(&font_face_stats) %then %let font_face_stats=Courier;
%if not %length(&font_face_other) %then %let font_face_other=Times;
%if not %length(&font_style_other) %then %let font_style_other=roman;
%if not %length(&font_weight_stats) %then %let font_weight_stats=bold;
%if not %length(&font_weight_other) %then %let font_weight_other=bold;

%*- make sure byroword and byrowvar are not in the by variables list -;
%if %length(&byvars) and %length(&byrowvar) %then
  %let byvars=%removew(&byvars,&byrowvar);

%if %length(&byvars) and %length(&byroword) %then
  %let byvars=%removew(&byvars,&byroword);

%*- make sure byrow2ord and byrow2var are not in the by variables list -;
%if %length(&byvars) and %length(&byrow2var) %then
  %let byvars=%removew(&byvars,&byrow2var);

%if %length(&byvars) and %length(&byrow2ord) %then
  %let byvars=%removew(&byvars,&byrow2ord);


             /*-----------------------------------------*
                  Check we have enough parameters set
              *-----------------------------------------*/
              
%let error=0;

%let ls=%sysfunc(getoption(linesize));
%let center=%sysfunc(getoption(center));

%if not %length(&byrowalign) %then %let byrowalign=left;
%else %if %upcase(%substr(&byrowalign,1,1)) EQ L %then %let byrowalign=left;
%else %if %upcase(%substr(&byrowalign,1,1)) EQ C %then %let byrowalign=center;
%else %if %upcase(%substr(&byrowalign,1,1)) EQ R %then %let byrowalign=right;
%else %let byrowalign=left;

%if not %length(&byrow2align) %then %let byrow2align=left;
%else %if %upcase(%substr(&byrow2align,1,1)) EQ L %then %let byrow2align=left;
%else %if %upcase(%substr(&byrow2align,1,1)) EQ C %then %let byrow2align=center;
%else %if %upcase(%substr(&byrow2align,1,1)) EQ R %then %let byrow2align=right;
%else %let byrow2align=left;

%if %length(&out) and %length(&byvars) %then %do;
  %let out=;
  %put WARNING: (unicatrep) out= parameter value not allowed with byvars=;
%end;


%if not %length(&style) %then %let style=1;
%if not %length(&strlen) %then %let strlen=&_strlen_;
%if not %length(&strlen) %then %let strlen=11;


%if not %length(&varw) %then %let varw=12;
%if not %length(&catw) %then %let catw=0;

%if not %length(&catlabel) %then %let catlabel=" ";

%if not %length(&byrowlabel) %then %let byrowlabel=" ";
%if not %length(&byrow2label) %then %let byrow2label=" ";

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

%if not %length(&print) %then %let print=yes;
%let print=%upcase(%substr(&print,1,1));

%if not %length(&compskip) %then %let compskip=no;
%let compskip=%upcase(%substr(&compskip,1,1));

%if not %length(&byrowfirst) %then %let byrowfirst=no;
%let byrowfirst=%upcase(%substr(&byrowfirst,1,1));

%if not %length(&trtspace) %then %let trtspace=4;

%if not %length(&indent) %then %let indent=0;

%if not %length(&split) %then %let split=@;



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

%if not %length(&byroww) %then %let byroww=12;
%if not %length(&byrow2w) %then %let byrow2w=12;


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

%if %length(&byrowvar) %then %let rest=%eval(&rest-&byroww-2);
%if %length(&byrow2var) %then %let rest=%eval(&rest-&byrow2w-2);

%if &catw EQ 0 %then %let catw=&rest;
%else %if &rest LT &catw %then %let catw=&rest;

%if "&style" EQ "2" %then %let repwidth=%eval(&catw+&trtwidth+2+&varw);
%else %let repwidth=%eval(&catw+&trtwidth+&indent);

%if %length(&byrowvar) %then %let repwidth=%eval(&repwidth+&byroww+2);
%if %length(&byrow2var) %then %let repwidth=%eval(&repwidth+&byrow2w+2);

%if %length(&outputwidthpct) %then %do;
  %if %upcase(%substr(&outputwidthpct,1,1)) EQ C 
     %then %let outputwidthpct=%eval(&repwidth*2/3);
%end;

%if %sysevalf(&outputwidthpct GT 100) %then %let outputwidthpct=100;

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

%if "&print" EQ "N" %then %do;
  ods listing close;
%end;
%else %do;
  ods listing &odslisting;
%end;

%if %length(&odsrtf) %then %do;
  ods rtf &odsrtf ;
%end;

%if %length(&odshtml) %then %do;
  ods html &odshtml ;
%end;

%if %length(&odshtmlcss) %then %do;
  ods htmlcss &odshtmlcss ;
%end;

%if %length(&odscsv) %then %do;
  ods csv &odscsv ;
%end;

%if %length(&odspdf) %then %do;
  ods pdf &odspdf ;
%end;

%if %length(&odsother) %then %do;
  ods &odsother ;
%end;


proc report missing headline &headskip nowd split="&split" data=_unicatrep &spanrows
  %if %length(&out) %then %do;
    out=&out
  %end;

  style(REPORT)=[cellspacing=&cellspacing cellpadding=&cellpadding rules=&rules 
                 background=white foreground=black 
                 %if &report_ul EQ Y and &report_ol EQ Y %then %do;
                   HTMLSTYLE="border-left:none;border-right:none;border-bottom:&linepx.px solid &linecol;border-top:&linepx.px solid &linecol"
                 %end;
                 %else %if &report_ul EQ Y %then %do;
                   HTMLSTYLE="border-left:none;border-right:none;border-bottom:&linepx.px solid &linecol;border-top:none"
                 %end;
                 %else %if &report_ol EQ Y %then %do;
                   HTMLSTYLE="border-left:none;border-right:none;border-top:&linepx.px solid &linecol;border-bottom:none"
                 %end;
                 %else %if &report_border NE Y %then %do;
                   HTMLSTYLE="border:none"
                 %end;
                 %if %length(&outputwidthpct) %then %do;
                   outputwidth=&outputwidthpct%
                 %end;
                 ]

  style(HEADER)=[background=&background_header foreground=&foreground_header
                 %if &header_ul EQ Y %then %do;
                   HTMLSTYLE="border-bottom:&linepx.px solid &linecol;border-left:none;border-right:none;border-top:none; mso-number-format:'\@'"
                 %end;
                 %else %if &header_border NE Y %then %do;
                   HTMLSTYLE="border:none; mso-number-format:'\@'"
                 %end;
                 %else %do;
                   HTMLSTYLE="mso-number-format:'\@'"
                 %end;
                 ]

  style(COLUMN)=[background=&background_stats foreground=&foreground_stats
                 font_face=&font_face_stats font_weight=&font_weight_stats
                 %if &column_border NE Y %then %do;
                   HTMLSTYLE="border:none; mso-number-format:'\@'"
                 %end;
                 %else %do;
                   HTMLSTYLE="mso-number-format:'\@'"
                 %end;
                 ]

  style(LINES)=[background=&background_other foreground=&foreground_other
                font_face=&font_face_other font_style=&font_style_other font_weight=&font_weight_other 
                %if &lines_border NE Y %then %do;
                  %if &compskip_ul EQ Y %then %do;
                    HTMLSTYLE="border-bottom:&compskippx.px solid &compskipcol;border-left:none;border-right:none;border-top:none; mso-number-format:'\@'"
                  %end;
                  %else %do;
                    HTMLSTYLE="border:none; mso-number-format:'\@'"
                  %end;
                %end;
                %else %do;
                  HTMLSTYLE="mso-number-format:'\@'"
                %end;
                ]

  ;

  %if %length(&byvars) %then %do;
    by &byvars;
  %end; 
 
  columns
  %if "&topline" EQ "Y" %then %do;
    ( "___" " " 
  %end;

  _page
  
  %if &indent GT 0 and "&style" NE "2" %then %do;
    _indent 
  %end;

  %if "&byrowfirst" EQ "Y" %then %do;
    &byroword &byrowvar _breakvar _varord _varlabel &byrow2ord &byrow2var _statord  _statlabel 
  %end;
  %else %do;  
    _breakvar _varord _varlabel &byroword &byrowvar &byrow2ord &byrow2var _statord  _statlabel 
  %end;

  %if "&spantotal" EQ "Y" %then %do;
    ( 
     %if %length(&trtlabel) %then %do;
       &trtlabel
     %end;
     %if %length(&trtvarlist) %then %do;
       &trtvarlist )
     %end;
     %else %do;
       &_trtvarlist_ &totvar ) &pvalvar
     %end;
  %end;
  %else %do;
    (
     %if %length(&trtlabel) %then %do;
       &trtlabel 
     %end;
     %if %length(&trtvarlist) %then %do;
       &trtvarlist )
     %end;
     %else %do;
       &_trtvarlist_ ) &totvar &pvalvar
     %end;
  %end;

  %if "&topline" EQ "Y" %then %do;
    )
  %end;
  ;

  define _page / order noprint;
  define _breakvar / order order=internal noprint;
  %if &indent GT 0 and "&style" NE "2" %then %do;
    define _indent / &varlabel order width=&indent spacing=0
    %if %length(&outputwidthpct) %then %do;
      style(COLUMN)=[cellwidth=%eval(100*&indent/&repwidth)% ]
    %end;
    ;
  %end;
  define _varord / order order=internal noprint;
  %if "&style" EQ "2" %then %do;
    define _varlabel / &varlabel order width=&varw flow 
                       style(COLUMN)=[background=&background_other foreground=&foreground_other
                                      font_face=&font_face_other font_weight=&font_weight_other
                                      font_style=&font_style_other
                                      %if %length(&outputwidthpct) %then %do;
                                        cellwidth=%eval(100*(&varw+2)/&repwidth)%
                                      %end;
                            ]
    %if "&byrowfirst" NE "Y" %then %do;
      spacing=0                       
    %end;
    ;
  %end;
  %else %do;
    define _varlabel / order noprint;
  %end;
  %if %length(&byroword) %then %do;
    define &byroword / order order=internal noprint;
  %end;
  %if %length(&byrowvar) %then %do;
    define &byrowvar / &byrowlabel order order=internal width=&byroww flow
           %if %length(&byrowfmt) %then %do;
             f=&byrowfmt
           %end;
           &byrowalign
           %if "&style" EQ "2" and "&byrowfirst" NE "Y" %then %do;
             spacing=2
           %end;
           %else %do;
             spacing=0
           %end;
           style(COLUMN)=[background=&background_other foreground=&foreground_other
                          font_face=&font_face_other font_weight=&font_weight_other
                          font_style=&font_style_other
                          %if %length(&outputwidthpct) %then %do;
                            cellwidth=%eval(100*(&byroww+2)/&repwidth)%
                          %end;
                         ]
                          
           ;
  %end;
  %if %length(&byrow2ord) %then %do;
    define &byrow2ord / order order=internal noprint;
  %end;
  %if %length(&byrow2var) %then %do;
    define &byrow2var / &byrow2label order order=internal width=&byrow2w flow 
           %if %length(&byrow2fmt) %then %do;
             f=&byrow2fmt
           %end;
           spacing=2 &byrow2align
           style(COLUMN)=[background=&background_other foreground=&foreground_other
                          font_face=&font_face_other font_weight=&font_weight_other
                          font_style=&font_style_other
                          %if %length(&outputwidthpct) %then %do;
                            cellwidth=%eval(100*(&byrow2w+2)/&repwidth)%
                          %end;
                         ]
                          
           ;
  %end;
  define _statord / order order=internal noprint;

  define _statlabel / &catlabel order width=&catw flow 
         style(COLUMN)=[background=&background_other foreground=&foreground_other
                        font_face=&font_face_other font_weight=&font_weight_other
                        font_style=&font_style_other]
  %if "&style" EQ "2" %then %do;
    spacing=2
  %end;
  %else %do;
    %if not %length(&byrowvar) %then %do;
      spacing=0
    %end;
    %else %do;
      spacing=2
    %end;
  %end;
  ;

  %do i=1 %to %words(&_trtvarlist_);
    define %scan(&_trtvarlist_,&i,%str( )) / width=&&trtw&i center display spacing=&trtspace
    %if %length(&outputwidthpct) %then %do;
      style(COLUMN)=[cellwidth=%eval(100*(&&trtw&i+&trtspace)/&repwidth)% ]
    %end;
    ;
  %end;
  %if %length(&totvar) %then %do;
    define &totvar / width=&&trtw&i center display spacing=&trtspace
    %if %length(&outputwidthpct) %then %do;
      style(COLUMN)=[cellwidth=%eval(100*(&&trtw&i+&trtspace)/&repwidth)% ]
    %end;
    ;
    %let i=%eval(&i+1);
  %end;
  %if %length(&pvalvar) %then %do;
    define &pvalvar / width=8 center display spacing=&trtspace
    %if %length(&outputwidthpct) %then %do;
      style(COLUMN)=[cellwidth=%eval(100*(8+&trtspace)/&repwidth)% ]
    %end;
    ;
  %end;
  %if &indent gt 0 and "&style" NE "2" %then %do;
    compute before _varlabel / style(LINES)=[HTMLSTYLE="border:none"];
      line @&startcol _varlabel $char&repwidth.. ;
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


  %*------------ Line breaking control --------------;

  %if %length(&byrow2var) %then %do;
    %if &compskip EQ Y %then %do;
      compute &compskippos &byrow2var;
        line " ";
      endcomp;
    %end;
    %else %do;
      break after &byrow2var / skip;
    %end;
  %end;
  %else %if %length(&byrowvar) and "&byrowfirst" NE "Y" %then %do;
    %if &compskip EQ Y %then %do;
      compute &compskippos &byrowvar;
        line " ";
      endcomp;
    %end;
    %else %do;
      break after &byrowvar / skip;
    %end;
  %end;
  %else %do;
    %if &compskip EQ Y %then %do;
      compute &compskippos _breakvar;
        line " ";
      endcomp;
    %end;
    %else %do;
      break after _breakvar / skip;
    %end;
  %end;
  break &pgbrkpos _page / page;
run;


%if "&print" EQ "N" or %length(&odslisting) %then %do;
  ods listing;
%end;

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
