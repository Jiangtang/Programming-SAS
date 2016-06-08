/*<pre><b>
/ Program      : unicatrep.sas
/ Version      : 6.7
/ Author       : Roland Rashleigh-Berry
/ Date         : 12-Dec-2011
/ Purpose      : Clinical reporting macro to produce a report from the dataset
/                output from the %unistats macro of treatment-transposed
/                categories counts and statistics.
/ SubMacros    : %words %removew (assumes %popfmt and %titles already run)
/ Notes        : This macro is normally called directly from %unistats assuming
/                the unicatrep=yes setting.
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
/ stat0lbl="Value"  Label for the stat column 0
/ stat1lbl="p-value" Label for the stat column 1
/ stat2-9lbl=" "    Label for the stat columns 2-9
/ stat0-9w=8        Width of the stats columns 0-9
/ statalign=c       Default alignment of stats columns is center
/ stat0-9align      Alignment of stats columns 0-9
/ showstat0=no      Default action for showing the statistics value column
/ showstat1=yes     Default action for showing the pvalue column
/ varw=12           Width of variable label column for style=2 reports
/ catw              By default this macro will assign a category column width
/                   to meet the page width.
/ has0obs           This will be set to Y by %unistats if the original input 
/                   dataset had zero observations.
/ nodata=nodata     Name of macro to call to produce a report if there is no
/                   data. This would normally put out a "NO DATA" message.
/ odsescapechar="°" ODS escape character (quoted)
/ trtlabel          Label for combined category counts and stats
/ trtalign=c        Default alignment of treatment column headers is centred
/ odstrtlabel       ODS non-listing output label for combined category counts and
/                   stats (defaults to value of trtlabel= ). Note that column 
/                   underlines defined using "--" that work for ascii output do
/                   not work for ODS output. Assuming "°" is the ODS escape
/                   character then to achieve a spanning underline for ODS output
/                   then use the following method where both the ascii form and
/                   ODS form are shown as examples (works for SAS 9.2 or later)
/              trtlabel="Treatment Arm" "__"
/           odstrtlabel='°{style [borderbottomwidth=1 borderbottomcolor=black]
/                        Treatment Arm}'
/ topline=yes       Default is to show a line at the top of the report for ascii
/                   output. Non-listing ODS output will not show this line.
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
/ endline=no        Default is not to show a line under the report at the end
/ endline1-15       Additional lines (in quotes) to show at end of report
/ endmacro          Name of macro (no starting "%") to assign the end line
/                   values instead of setting them manually. This macro will be
/                   called in a "proc report" compute block so it must not
/                   contain any data step or procedure boundaries in any code
/                   it calls and must resolve to something that is syntactically
/                   correct for compute block processing. You can have 
/                   parameter settings in the macro call.
/ pgbrkpos=before   Page break position defaults to "before". This will allow
/                   the endline1-9 to be put after the last item is displayed.
/                   If set to "after" (no quotes) then endline1-9 will be forced
/                   onto a new page.
/ spacing=2         Default spacing is 2 between the categories and treatments
/ trtspace=4        Default spaces to leave between treatment arms
/ trtw1-19          Widths for each treatment column. If left blank then this
/                   will be calculated for you.
/ trtsp1-19         You can specify individual column spacing for the treatment
/                   arms. If left blank then this will be filled in from the
/                   spacing= parameter setting (for the first treatment arm)
/                   and the trtspace= setting for the others.
/ indent=4          Spaces to indent categories for report
/ split=@           Split character (no quotes) for proc report if requested
/ headskip=yes      Skip a line at the top
/ spantotal=yes     Include total column under trtlabel
/ out               Named output dataset from proc report if required
/ odsrtf            Give the "file='filename' style=style" (unquoted) to create
/                   rtf output. "ods rtf   ;" and "ods rtf close;" will be
/                   automatically generated. If you want to suppress the plain
/                   text output then use print=no
/ odshtml           Works the same way as odsrtf
/ odshtmlcss        Works the same way as odsrtf
/ odscsv            Works the same way as odsrtf
/ odspdf            Works the same way as odsrtf
/ odslisting        Allows you to specify a file= statement to pass through to
/                   the %unicatrep macro.
/ odsother          Works the same way as odsrtf but you have to supply the
/                   destination word as the first word.
/ tfmacro           Name of macro (no % sign) containing titles and footnotes
/                   code to be enacted before any output is produced.
/                   this parameter and reference "repwidth" in your macro code.
/ odstfmacro        Name of macro (no % sign) containing titles and footnotes
/                   code to be enacted before any ODS non-listing output is
/                   produced, if set. If not used then the macro defined to
/                   tfmacro= will be in effect.
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
/ compskip=yes      (no quotes) By default, throw a blank line after a mid
/                   level term for ODS reports. For ascii output, compskip=no
/                   will always be in effect.
/ compskippos=after (no quotes) By default, throw the skip line after the mid
/                   level term.
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
/                   ============================================================
/                   Note that giving incorrect parameter values to fonts or any
/                   other values used in a style() statement in proc report can
/                   result in extremely confusing log error messages, usually
/                   shown as a missing round bracket sign as explained here.
/                     ERROR 79-322: Expecting a (.
/                     ERROR 76-322: Syntax error, statement will be ignored.
/                   http://support.sas.com/kb/2/457.html
/                   There is nothing wrong with this macro if this happens. You 
/                   just need to get your values right. Whatever style()
/                   statement causes an error message is the one that contains
/                   an incorrect value. Check in the SAS documentation for the
/                   values you are allowed to use. It won't be font weight or
/                   style causing the problem as correct values for these are
/                   enforced by this macro.
/ font_face_stats=times   Font to use for ODS output of the calculated stats
/                   values. For correct alignment of the decimal point for non-
/                   paired stats for MS Office then this should be set to
/                   "Courier" (no quotes). If your font face contains more than
/                   one word then use quotes (e.g. "courier new"). Also use
/                   quotes if you are specifying a search order for fonts such
/                   as "arial, helvetica".
/ font_weight_stats=medium    Weight of font to use for stats columns 
/                   (choice of light, medium or bold enforced by this macro).
/ font_weight_other=medium    Weight of font to use for columns other than 
/                   the calculated stats.
/ font_face_other=times     Font to use for ODS output for columns other
/                   than the calculated stats.
/ font_style_other=roman    Font style (italic, roman or slant) to use for ODS 
/                   output for columns other than the calculated stats.
/ font_weight_other=medium    Weight of font to use for columns other than 
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
/                   ============================================================
/                   Note that you can insert code for the following two
/                   parameters that will apply immediately before and
/                   immediately after the "proc report" step. ENCLOSE YOUR CODE
/                   IN SINGLE QUOTES. Enclosed SINGLE quotes will be removed by
/                   the macro before code execution. Note that you are
/                   responsible for including all semicolons and "run"
/                   statements required for correct code syntax.
/ odsprerepcode     Code to execute immediately before the "proc report" step
/                   for ODS non-listing output (enclose in single quotes).
/ odspostrepcode    Code to execute immediately after the "proc report" step
/                   for ODS non-listing output (enclose in single quotes).
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
/ rrb  30Jul08         Add checking for font weights
/ rrb  31Jul08         Added checking for font_style_other=
/ rrb  31Jul08         Added checking for rules=
/ rrb  03Aug08         Changed default to font_weight_stats=medium
/ rrb  11Sep08         Changed default to font_weight_stats=medium in code
/ rrb  01Jun09         prerepcode= and postrepcode= parameters added for v4.30
/ rrb  18Jun09         tfmacro= parameter added plus header tidy for v4.31
/ rrb  22Jun09         "proc report" call enclosed in a macro with a topline=
/                      parameter so that it can be called separately for listing
/                      output where a topline is required but the topline will
/                      be suppressed for all other ODS output. ods listing close
/                      will be used if the odslisting= parameter is set. 
/                      prerepcode= and postrepcode= parameters renamed as
/                      odsprerepcode= and odspostrepcode= and default changed
/                      to topline=yes (v5.0)
/ rrb  03Jul09         Ascii output now created separately from ODS non-listing
/                      output in all cases (v5.1)
/ rrb  04Jul09         New parameter odstrtlabel= added (v5.2)
/ rrb  10Jul09         topline=yes now default in code when not specified (v5.3)
/ rrb  11Jul09         odstfmacro= parameter added (v5.4)
/ rrb  02Aug09         Parameter stat1w=8 added (v5.5)
/ rrb  27Aug09         odstrtvarlist= parameter added and compskip=no enforced
/                      for ascii output. compskip=yes is now the default. (v5.6)
/ rrb  30Aug09         odsescapechar= parameter added plus header tidy (v5.7)
/ rrb  10Sep09         asis=on put into effect for columns  (v5.8)
/ rrb  04Nov09         asis=off is now a parameter and the default. Font weights
/                      are now all medium. Stats font changed from Courier to 
/                      Arial (v5.9)
/ rrb  13Jan10         Call to tfmacro made earlier in case it adds a pvalue
/                      variable to the output dataset (v5.10)
/ rrb  23Jan10         Column widths for ODS output adjusted and font_face_stats
/                      changed to Times (v5.11)
/ rrb  24Jan10         PDF output created separately due to problems with
/                      controlling column widths (v5.12)
/ rrb  01Nov10         showstat0=no parameter added (by default do not show
/                      stats values with p-values). This statistics value is a
/                      regulatory requirement for China's SFDA (v5.13)
/ rrb  07Nov10         odsescapechar changed to "§" (v5.14)
/ rrb  16Nov10         tfmacro= call now made later and should only be used for
/                      setting titles and footnotes. The data manipulation
/                      functionality has been moved to the extmacro= call in 
/                      %unistats (v5.15)
/ rrb  21Nov10         odsescapechar changed to "°" (v5.16)
/ rrb  13Mar11         Stats columns changed to STAT1, STAT2 etc. (v6.0)
/ rrb  08May11         Code tidy
/ rrb  25May11         pageline= and endline= parameters extended to 15 (was 9)
/                      and pagemacro= and endmacro= parameters added (v6.1)
/ rrb  01Jun11         Minor bug in pageline handling fixed (v6.2)
/ rrb  12Jul11         Added trtalign= parameter (v6.3)
/ rrb  23Jul11         spacing= and trtsp1-15= parameters added (v6.4)
/ rrb  26Jul11         Limit for trtw= and trtsp= parameters increased from
/                      15 to 19 (v6.5)
/ rrb  17Sep11         has0obs= and nodata= processing added (v6.6)
/ rrb  12Dec11         Used &startcol to position pageline and endline (v6.7)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/
 
%put MACRO CALLED: unicatrep v6.7;
 
%macro unicatrep(dsin=,
               byvars=,
                style=1,
                print=yes,
              has0obs=,
               nodata=nodata,
             catlabel=" ",
             varlabel=" ",
                total=yes,
            showstat0=no,
            showstat1=yes,
               stat0w=6,
               stat1w=8,
               stat2w=8,
               stat3w=8,
               stat4w=8,
               stat5w=8,
               stat6w=8,
               stat7w=8,
               stat8w=8,
               stat9w=8,
              stat0lbl="Value",
             stat1lbl="p-value",
             stat2lbl=" ",
             stat3lbl=" ",
             stat4lbl=" ",
             stat5lbl=" ",
             stat6lbl=" ",
             stat7lbl=" ",
             stat8lbl=" ",
             stat9lbl=" ",
            statalign=c,
           stat0align=,
           stat1align=,
           stat2align=,
           stat3align=,
           stat4align=,
           stat5align=,
           stat6align=,
           stat7align=,
           stat8align=,
           stat9align=,
                 varw=12,
                 catw=,
        odsescapechar="°",
             trtlabel=,
          odstrtlabel=,
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
             endmacro=,
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
               trtw10=,
               trtw11=,
               trtw12=,
               trtw13=,
               trtw14=,
               trtw15=,
               trtw16=,
               trtw17=,
               trtw18=,
               trtw19=,
              spacing=2,
               trtsp1=,
               trtsp2=,
               trtsp3=,
               trtsp4=,
               trtsp5=,
               trtsp6=,
               trtsp7=,
               trtsp8=,
               trtsp9=,
              trtsp10=,
              trtsp11=,
              trtsp12=,
              trtsp13=,
              trtsp14=,
              trtsp15=,
              trtsp16=,
              trtsp17=,
              trtsp18=,
              trtsp19=,
             trtalign=c,
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
              tfmacro=,
           odstfmacro=,
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
             compskip=yes,
          compskippos=after,
           byrowfirst=no,
           trtvarlist=,
        odstrtvarlist=,
             spanrows=yes,
      font_face_stats=times,
    font_weight_stats=medium,
      font_face_other=times,
     font_style_other=roman,
    font_weight_other=medium,
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
          compskipcol=black,
        odsprerepcode=,
       odspostrepcode=,
                 asis=off
                );
 
  %local i errflag err ls trtwidth repwidth startcol rest numtrt totvar statvars
        cwidth cwidths center pagevar maxpage ;
  %let err=ERR%str(OR);
  %global _strlen_;


             /*-----------------------------------------*
                  Check we have enough parameters set
              *-----------------------------------------*/
              
  %let errflag=0;
 
  %let pagevar=_page;

  %if not %length(&trtalign) %then %let trtalign=c;
  %let trtalign=%upcase(%substr(&trtalign,1,1));
  %if &trtalign=C %then %let trtalign=center;
  %else %if &trtalign=R %then %let trtalign=right;
  %else %let trtalign=left;

  %if not %length(&statalign) %then %let statalign=c;
  %let statalign=%upcase(%substr(&statalign,1,1));
  %if &statalign NE C and &statalign NE R %then %let statalign=L;

  %do i=1 %to 9;
    %if not %length(&&stat&i.align) %then %let stat&i.align=&statalign;
    %else %let stat&i.align=%upcase(%substr(&&stat&i.align));
    %if &&stat&i.align=C %then %let stat&i.align=center;
    %else %if &&stat&i.align=R %then %let stat&i.align=right;
    %else %let stat&i.align=left;
  %end;

  %if not %sysfunc(indexw(LIGHT MEDIUM BOLD,%upcase(&font_weight_stats))) %then %do;
    %let errflag=1;
    %put &err: (unicatrep) Font weights can only be light, medium or bold. You put font_weight_stats=&font_weight_stats;
  %end;
 
  %if not %sysfunc(indexw(LIGHT MEDIUM BOLD,%upcase(&font_weight_other))) %then %do;
    %let errflag=1;
    %put &err: (unicatrep) Font weights can only be light, medium or bold. You put font_weight_other=&font_weight_other;
  %end;
 
  %if not %sysfunc(indexw(ITALIC ROMAN SLANT,%upcase(&font_style_other))) %then %do;
    %let errflag=1;
    %put &err: (unicatrep) Font styles can only be italic, roman or slant. You put font_style_other=&font_style_other;
  %end;
 
  %if not %sysfunc(indexw(NONE ALL COLS ROWS GROUPS,%upcase(&rules))) %then %do;
    %let errflag=1;
    %put &err: (unicatrep) Rules parameter value can only be none, all, cols, rows, groups. You put rules=&rules;
  %end;
 
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
    %put &err: (unicatrep) out= parameter value not allowed with byvars=;
  %end;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (unicatrep) No input dataset assigned to dsin=;
  %end;

  %if &errflag %then %goto exit;



             /*-----------------------------------------*
                   Default missing parameter values
              *-----------------------------------------*/

 
  %if not %length(&asis) %then %let asis=off;
 
  %if not %length(&odstrtvarlist) %then %let odstrtvarlist=&trtvarlist;
 
  %if not %length(&odstrtlabel) %then %let odstrtlabel=&trtlabel;
 
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
 
 
  %if not %length(&font_face_stats) %then %let font_face_stats=times;
  %if not %length(&font_weight_stats) %then %let font_weight_stats=medium;
  %if not %length(&font_face_other) %then %let font_face_other=Times;
  %if not %length(&font_style_other) %then %let font_style_other=roman;
  %if not %length(&font_weight_other) %then %let font_weight_other=medium;
 
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
 
  %if not %length(&topline) %then %let topline=yes;
  %let topline=%upcase(%substr(&topline,1,1));
 
  %if not %length(&total) %then %let total=yes;
  %let total=%upcase(%substr(&total,1,1));
 
  %if not %length(&showstat1) %then %let showstat1=yes;
  %let showstat1=%upcase(%substr(&showstat1,1,1));

  %if not %length(&showstat0) %then %let showstat0=no;
  %let showstat0=%upcase(%substr(&showstat0,1,1));
 
  %if not %length(&pageline) %then %let pageline=no;
  %let pageline=%upcase(%substr(&pageline,1,1));
 
  %if not %length(&endline) %then %let endline=no;
  %let endline=%upcase(%substr(&endline,1,1));
 
  %if not %length(&spantotal) %then %let spantotal=yes;
  %let spantotal=%upcase(%substr(&spantotal,1,1));
 
  %if not %length(&print) %then %let print=yes;
  %let print=%upcase(%substr(&print,1,1));
 
  %if not %length(&compskip) %then %let compskip=yes;
  %let compskip=%upcase(%substr(&compskip,1,1));
 
  %if not %length(&byrowfirst) %then %let byrowfirst=no;
  %let byrowfirst=%upcase(%substr(&byrowfirst,1,1));

  %if not %length(&spacing) %then %let spacing=2; 

  %if not %length(&trtspace) %then %let trtspace=4;
 
  %if not %length(&indent) %then %let indent=0;
 
  %if not %length(&split) %then %let split=@;
 
 
  %if not %length(&pgbrkpos) %then %let pgbrkpos=before;
  

 
 
             /*-----------------------------------------*
                        Calculate report width
              *-----------------------------------------*/

 
  %let cwidths=&_trtcwidths_;
  %if "&total" EQ "Y" %then %let cwidths=&cwidths &_trttotcwidth_;
 
  %if not %length(&byroww) %then %let byroww=12;
  %if not %length(&byrow2w) %then %let byrow2w=12;
 
 
  %do i=1 %to 19;
    %if not %length(&&trtw&i) %then %do;
      %let cwidth=%scan(&cwidths,&i,%str( ));
      %if &cwidth GT &strlen %then %let trtw&i=&cwidth;
      %else %let trtw&i=&strlen;
    %end;
  %end;

  %do i=1 %to 19;
    %if &i EQ 1 and not %length(&trtsp1) %then %let trtsp1=&spacing;
    %else %if not %length(&&&trtsp&i) %then %let trtsp&i=&trtspace;
  %end;
 
  %let totvar=;
 
  %if "&total" EQ "Y" %then %do;
    %if %varnum(&dsin,&_trttotvar_) %then %let totvar=&_trttotvar_;
  %end;
 

  %let numtrt=%words(&_trtvarlist_ &totvar);
 
 
  %let trtwidth=0;
  %do i=1 %to &numtrt;
    %let trtwidth=%eval(&trtwidth+&&trtsp&i+&&trtw&i);
  %end;

  %do i=0 %to 9;
    %if %varnum(&dsin,STAT&i) %then %do;
      %if &i EQ 0 %then %do;
        %if &showstat0 EQ Y %then %do;
          %let trtwidth=%eval(&trtwidth+&trtspace+&&stat&i.w);
          %let statvars=&statvars STAT&i;
        %end;
      %end;
      %else %if &i EQ 1 %then %do;
        %if &showstat1 EQ Y %then %do;
          %let trtwidth=%eval(&trtwidth+&trtspace+&&stat&i.w);
          %let statvars=&statvars STAT&i;
        %end;
      %end;
      %else %do;
        %let trtwidth=%eval(&trtwidth+&trtspace+&&stat&i.w);
        %let statvars=&statvars STAT&i;
      %end;
    %end;
  %end;


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
 
  %put NOTE: (unicatrep) repwidth=&repwidth columns;
 
  %if %length(&outputwidthpct) %then %do;
    %if %upcase(%substr(&outputwidthpct,1,1)) EQ C 
       %then %let outputwidthpct=%eval(&repwidth*2/3);
  %end;
 
  %if %sysevalf(&outputwidthpct GT 100) %then %let outputwidthpct=100;
 
  %put NOTE: (unicatrep) outputwidthpct=&outputwidthpct% of available width;
 
  %if &center EQ NOCENTER %then %let startcol=1;
  %else %let startcol=%eval((&ls-&repwidth)/2 + 1);
 
  %if "&style" NE "2" %then %do;
    data _unicatrep;
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

  *- find out how many pages are used -; 
  proc sql noprint;
    select max(_page) into :maxpage from _unicatrep;
  quit;

  *- if only one page requested then break on page end -;
  %if &maxpage=1 %then %let pagevar=_PAGE_;
 
 
 
             /*-----------------------------------------*
                       Define "proc report" macro
              *-----------------------------------------*/
 
  %macro _unirep(topline=,trtlabel=,compskip=,trtvarlist=,PDF=N);

    %if &has0obs EQ Y and %length(&nodata) %then %do;
      %&nodata
    %end;
    %else %do;
 
      proc report missing headline &headskip nowd split="&split" data=_unicatrep &spanrows
 
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
 
        style(COLUMN)={asis=&asis
                   %if &column_border NE Y %then %do;
                     HTMLSTYLE="border:none%str(;) mso-number-format:'\@'"
                   %end;
                   %else %do;
                     HTMLSTYLE="mso-number-format:'\@'"
                   %end;
                   background=&background_stats foreground=&foreground_stats
                   font_face=&font_face_stats font_weight=&font_weight_stats}
 
        style(HEADER)=[background=&background_header foreground=&foreground_header
                   %if "&header_ul" EQ "Y" %then %do;
                     HTMLSTYLE="border-bottom:&linepx.px solid &linecol;border-left:none;border-right:none;border-top:none; mso-number-format:'\@'"
                   %end;
                   %else %if "&header_border" NE "Y" %then %do;
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
             &_trtvarlist_ &totvar ) &statvars
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
             &_trtvarlist_ ) &totvar &statvars
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
            style(COLUMN)=[cellwidth=%eval(70*&indent/&repwidth)% ]
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
          define %scan(&_trtvarlist_,&i,%str( )) / width=&&trtw&i center display spacing=&&trtsp&i &trtalign
          %if %length(&outputwidthpct) %then %do;
            %if &PDF NE Y %then %do;
              style(COLUMN)=[cellwidth=%eval(45*(&&trtw&i+&trtspace)/&repwidth)% ]
            %end;
          %end;
          ;
        %end;
        %if %length(&totvar) %then %do;
          define &totvar / width=&&trtw&i center display spacing=&trtspace &trtalign
          %if %length(&outputwidthpct) %then %do;
            %if &PDF NE Y %then %do;
              style(COLUMN)=[cellwidth=%eval(45*(&&trtw&i+&trtspace)/&repwidth)% ]
            %end;
          %end;
          ;
          %let i=%eval(&i+1);
        %end;

        %do i=0 %to 9;
          %if %varnum(&dsin,STAT&i) %then %do;
            %if &i EQ 0 %then %do;
              %if &showstat0 EQ Y %then %do;
                define STAT&i / width=&&stat&i.w &&STAT&i.align &&STAT&i.LBL display spacing=&trtspace
                %if %length(&outputwidthpct) %then %do;
                  %if &PDF NE Y %then %do;
                    style(COLUMN)=[cellwidth=%eval(45*(&&stat&i.w+&trtspace)/&repwidth)% ]
                  %end;
                %end;
              %end;
            %end;
            %else %if &i EQ 1 %then %do;
              %if &showstat1 EQ Y %then %do;
                define STAT&i / width=&&stat&i.w &&STAT&i.align &&STAT&i.LBL display spacing=&trtspace
                %if %length(&outputwidthpct) %then %do;
                  %if &PDF NE Y %then %do;
                    style(COLUMN)=[cellwidth=%eval(45*(&&stat&i.w+&trtspace)/&repwidth)% ]
                  %end;
                %end;
              %end;
            %end;
            %else %do;
              define STAT&i / width=&&stat&i.w &&STAT&i.align &&STAT&i.LBL display spacing=&trtspace
              %if %length(&outputwidthpct) %then %do;
                %if &PDF NE Y %then %do;
                  style(COLUMN)=[cellwidth=%eval(45*(&&stat&i.w+&trtspace)/&repwidth)% ]
                %end;
              %end;
            %end;
            ;
          %end;
        %end;



        %if &indent gt 0 and "&style" NE "2" %then %do;
          compute before _varlabel / style(LINES)=[HTMLSTYLE="border:none"];
            line @&startcol _varlabel $char&repwidth.. ;
          endcomp;
        %end;
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
    %end;
 
  %mend _unirep;
 
 
 
             /*-----------------------------------------*
                             Produce report
              *-----------------------------------------*/
 
  
  %*- call titles and footnotes macro if set -;
  %if %length(&tfmacro) %then %do;
    %&tfmacro;
  %end;
 
  %if "&print" EQ "N" %then %do;
    ods listing close;
  %end;
  %else %do;
    ods listing &odslisting;
  %end;
 
  %if "&print" EQ "Y" %then %do;
    %_unirep(topline=&topline,trtlabel=&trtlabel,compskip=no,trtvarlist=&trtvarlist);
    ods listing close;
  %end;
 
 
  %if %length(&odsrtf) or %length(&odshtml) or %length(&odshtmlcss) 
   or %length(&odscsv) or %length(&odspdf) or %length(&odsother) %then %do;
 
 
    %*- call ODS titles and footnotes macro if set -;
    %if %length(&odstfmacro) %then %do;
      %&odstfmacro;
    %end;
 
    %if %length(&odsescapechar) %then %do;
      ODS escapechar=&odsescapechar;
    %end;
 
    %*- strip start and trailing single quotes of odsprerepcode if present -;
    %if %length(&odsprerepcode) %then %do;
      %if %qsubstr(&odsprerepcode,1,1) EQ %str(%') and %qsubstr(&odsprerepcode,%length(&odsprerepcode),1) EQ %str(%')
        %then %do;
%unquote(%qsubstr(&odsprerepcode,2,%length(&odsprerepcode)-2))
        %end;
      %else %do;
&odsprerepcode
      %end;
    %end;
 
    %if %length(&odspdf) %then %do;
      ods pdf &odspdf;
      %_unirep(topline=N,trtlabel=&odstrtlabel,compskip=&compskip,trtvarlist=&odstrtvarlist,PDF=Y);
      ods pdf close;
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
 
    %if %length(&odsother) %then %do;
      ods &odsother ;
    %end;

 
    %_unirep(topline=N,trtlabel=&odstrtlabel,compskip=&compskip,trtvarlist=&odstrtvarlist);
 
 
    %*- strip start and trailing single quotes of odspostrepcode if present -;
    %if %length(&odspostrepcode) %then %do;
      %if %qsubstr(&odspostrepcode,1,1) EQ %str(%') and %qsubstr(&odspostrepcode,%length(&odspostrepcode),1) EQ %str(%')
        %then %do;
%unquote(%qsubstr(&odspostrepcode,2,%length(&odspostrepcode)-2))
        %end;
      %else %do;
&odspostrepcode
      %end;
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
 
  %end; 
 
 
 
             /*-----------------------------------------*
                                  Exit
              *-----------------------------------------*/
 
  ods listing;

 
  %goto skip;
  %exit: %put &err: (unicatrep) Leaving macro due to problem(s) listed;
  %skip:


%mend unicatrep;

