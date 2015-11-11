/*<pre><b>
/ Program      : npcttab.sas
/ Version      : 8.1
/ Author       : Roland Rashleigh-Berry
/ Date         : 09-May-2008
/ Purpose      : Clinical reporting macro to produce tables showing "n", the
/                percentage and optionally the number of events.
/ SubMacros    : %quotelst %words %varlen %zerogrid %npctpvals %attrn %dequote
/                %varfmt %sysfmtlist %verifyb %commas %sortedby %match %nodup
/                %attrc %removew (assumes %popfmt already run)
/ Notes        : This macro is NO LONGER SUPPORTED on a free basis. Maintenance
/                on it is time-consuming and the author does not have the free
/                time to do this. You can use it for free but suggestions for 
/                enhancements from free users will be ignored and bugs reported
/                by free users may take a long time to get resolved or perhaps
/                never will be. Bugs normally only get fixed when the author
/                encounters them while using this macro. A support contract is
/                possible and is especially important if you intend to run 
/                this or any of the other clinical reporting macros in a
/                production environment. Some major changes might be made to
/                this macro in the future and only those with a support
/                contract with me will be given consideration on how the change
/                might effect their use of this macro in the workplace.
/
/                Observations for the total of all treatment arms will be
/                generated inside this macro so do not set this up in the
/                input dataset.
/
/                If you do not specify ordering variables then the levels will
/                be displayed in descending subject frequency count for the
/                total column (even if not displayed).
/
/                Paging is difficult for this macro so the mid level term might
/                be shown right at the bottom of the page and the corresponding
/                low level terms on the following page. This is difficult to
/                solve programmatically using "proc report" because even if the
/                number of titles and footnotes is known and whether a "by line"
/                is being used and how many lines are required for the column
/                headings then you have to know if any low level terms will
/                "flow" and so take up extra lines. No attempt is made to solve
/                this problem inside this macro but a pagevar= and pgbrkpos=
/                parameter can be set for a paging variable and its break
/                position for if you have set up a paging variable in the input
/                data. Of course, this does not apply to non-paginated ODS
/                output such as ODS HTML.
/
/ Usage        : See tutorial with demonstrations on this web site
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Name of input dataset
/ dsall             Optional dataset for displaying all levels present. The 
/                   level variables in this dataset must be identical to those
/                   in the dsin= dataset.
/ style=3           This is the default layout style to use.
/                     Style=1 is for indented terms and is most suitable for
/                             ascii output. It is the original style and the 
/                             most reliable. It should handle three-level
/                             reports well.
/                     Style=2 is for each level term to appear in its own column
/                             but because these terms can be long it can cause
/                             data values to be "pushed down" where these terms
/                             flow. This option is only good for ODS output and
/                             should only be used for sas v9.2 or later with
/                             the parameter spanrows=yes set for this macro.
/                             This style is NOT IMPLEMENTED YET.
/                     Style=3 is for combining all the levels in the same column
/                             and the levels will be indented with non-breaking 
/                             spaces as per the indent= parameter setting. You
/                             should use this for ODS output only because 
/                             the proportional text used will hopefully avoid
/                             the higher levels terms "flowing". If text flows
/                             then indentation is not preserved and the report 
/                             can look messy. For this style, the anylowlvl= 
/                             term will get overwritten by the mid level term.
/                             This style has only recently been implemented and
/                             ONLY WORKS FOR TWO-LEVEL REPORTS.
/ dspop=_popfmt     Name of population dataset used for calculating percentages
/ uniqueid          List of variables that uniquely identify a subject
/                   (defaults to &_uniqueid_ set in %popfmt).
/ trtvar            Treatment group variable (defaults to &_trtvar_ set in
/                   %popfmt) which must be a coded numeric variable or a short
/                   coded character variable (typically one or two bytes with no
/                   spaces).
/ trtfmt            (optional) format to apply to the treatment variable
/ trtlabel          (quoted) Default is not to show a treatment label
/ topline=no        Default is not to show a line at the top of the report. This
/                   is the best setting for ODS RTF tables and the like.
/ toplabel          Default is not to have a label at the top of the table but
/                   should be quoted if required.
/ spacing=2         Default spacing is 2 between the lowlvl terms and treatments
/ trtspace=4        Default spacing is 4 between treatment arms
/ byvars            (optional) by variables
/ highlvl           High level variable (optional)
/ highlvlord        (optional) variable to order high level terms
/ midlvl            Mid level variable (optional)
/ midlvlord         (optional) variable to order mid level terms
/ lowlvl            Low level variable
/ lowlvlord         (optional) variable to order low level terms
/ lowlvlw=0         Column width for lowlvl items. If 0 then it is automatically
/                   calculated to fit the page.
/ style3w=0         Column width for the style 3 report where all level terms
/                   are in the same column. If 0 then it is automatically
/                   calculated to fit the page.
/ nlen=3            Default digit length for the "n" count is 3. 
/ trtw1-19          You can specify individual column widths for the treatment
/                   arms. If left blank then this will be calculated for you.
/ trtsp1-19         You can specify individual column spacing for the treatment
/                   arms. If left blank then this will be filled in from the
/                   spacing= parameter setting (for the first treatment arm)
/                   and the trtspace= setting for the others.
/ indent=3          Default indentation of the level terms is 3 characters
/ highlvllbl        Label for the high level terms (must be a single line quoted
/                   or unquoted for style=1 reports but for style=2 reports it 
/                   can have several parts and each part must be quoted).
/ midlvllbl         Label for the mid level terms (must be a single line quoted
/                   or unquoted for style=1 reports but for style=2 reports it 
/                   can have several parts and each part must be quoted).
/ lowlvllbl         Label for the low level terms (must be a single line quoted
/                   or unquoted for style=1 reports but for style=2 reports it 
/                   can have several parts and each part must be quoted).
/ style3lbl         This is the column label to use for style 3, where all the
/                   information shares the same column. It can have several 
/                   parts and each part should be quoted.
/ trtord=99         If lowlvlord not specified then this is the treatment group
/                   value used for ordering lowlvl items.
/ trttotval=99      Extra observationbs are created for the total of all 
/                   treatment groups and the default value is 99.
/ total=yes         Default is to show the total for all treatment arms
/ anylowlvl="ANY AE"       Default displayed string for combined low level
/                   terms (required and must be quoted). If not wanted then it
/                   must still be specified but dropped in the droplowlvl= list.
/ toplowlvl         Defaults to whatever anylowlvl= is set to. This causes the
/                   lowlvl term to be displayed first in the midlvl group.
/                   Only set this if you are setting up your own effective
/                   anylowlvl= term in the input data.
/ anywhen=before    This affects how the "any lowlvl" is calculated. If
/ (anywhen=after)   "before" (default) then it will be calculated before any
/                   minimum percentage is applied to the display. If "after"
/                   then first the lowlvl terms to display are determined and
/                   then the "any" counts and percentages are based on just
/                   those lowlvl terms that will be displayed. You should make
/                   sure that the label supplied to anylowlvl= makes it clear
/                   what method is used. If no minimum percentage or minimum
/                   count is supplied then "anywhen=before" will override
/                   whatever is specified to this parameter.
/ droplowlvl        Low level value(s) to drop from table (quoted and separate
/                   with spaces if more than one). You can use this to create
/                   a total with your data by repeating each observation with
/                   the higher level terms set to say what you want such as
/                   "Total of subjects with adverse events" and set your low
/                   level term to "XXX", for example, and then specify to drop
/                   "XXX" to this parameter.
/ split=@           Split character for proc report (no quotes)
/ headskip=yes      Default is to skip a line at the top if proc report output
/ spantotal=yes     Default is for the treament label to span the total column
/ minpct            Minimum percentage value (in trtord= arm) to display
/ mincount          Minimum patient count (in trtord= arm) to display
/ minpctany         Minimum percentage value in any treatment arm to display
/ mincountany       Minimum patient count in any treatment arm to display
/ print=yes         By default, allow this macro to print the report
/ events=no         By default, do not display the number of events
/ nevlen            Digit length for the number of events. Defaults to the
/                   nlen= setting if not used.
/ dsout=_npcttab    Output dataset name if not printing (no modifiers)
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
/ pcttrt            If set to a list of values (separated by spaces, not commas)
/                   will calculate the percentage only for those treatment arm
/                   values. Will be ignored if event counts were requested.
/ pvalues=no        By default, do not calculate p-values
/ usetest           Set to C (Chi-square) or F (Fisher's exact) to override
/                   decision of macro to select Chi-square or Fisher's exact
/                   test based on expected cell counts. Can also be set to T2,
/                   T1L or T1R for the two-sided, one-sided-left or 
/                   one-sided-right Cochran-Armitage Trend test.
/ pvalkeep          Only keep p-values that satisfy this condition (e.g. <0.05)
/ pvalfmt=p63val.   Default format to use for p-values (uses 6.3 or <0.001)
/ pvalvar=TRT9999   Name for p-value variable
/ pvallbl="p-value" Label for p-value variable
/ pvaltrtlist       List of treatment arm values (separated by spaces) used for
/                   p-value calculation (defaults to not using the value
/                   assigned to trttotval= ).
/ chisqid=^         Character to use to identify the Chi-square test that is
/                   added at the end of the character p-value (no quotes)
/ fisherid=~        Character to use to identify the Fisher exact test that is
/                   added at the end of the character p-value (no quotes)
/ trendid           Character to use to identify the Cochran-Armitage Trend Test
/                   that is added at the end of the character p-value (unquoted)
/ nodata=nodata     Name of macro to call to produce a report if there is no
/                   data. This would normally put out a "NO DATA" message.
/ pagevar           Page-breaking variable if set up in input data
/ pgbrkpos          Page breaking position (no quotes - defaults to "before")
/ pctsign=no        By default, do not show the percent sign for percentages
/ pctfmt=5.1        Default format for the percentage
/ pctcompress=no    Whether to compress the percentage
/ pctwarn=yes       By default, put out a warning message if a percentage is
/                   greater than 100.01
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
/ odslisting        Allows you to specify a file= statement
/ odsother          Works the same way as odsrtf but you have to supply the
/                   destination word as the first word.
/ spanrows=yes      Applies to sas v9.2 and later. Default is to enable the
/                   "spanrows" option for "proc report". You should leave this
/                   set to "yes" (no quotes) unless you have a clear need.
/ eventsort=yes     By default, use the event count as a secondary sort key.
/ keepwork=no       By default, do not keep the work datasets created by this
/                   macro.
/ keepmidlvlmin=no  By default, do not keep the mid-level term where the 
/                   percentage or count meets the minimum criteria but there are
/                   no low level terms that meet the criteria.
/ dsdenom           Dataset to use for the denominator for calculating
/                   percentages. Setting this overrides the pctcalc= process.
/                   The denominator value must be held in the variable _total.
/                   The sort order of this dataset will be used for the merge
/                   but if no sort order is known then a matching of variable 
/                   names will be done. Note that if you have "by" variables
/                   then these should normally be in this dataset as well.
/ denomshow=yes     By default, show the denominator value (ddd) held in the
/                   dsdenom dataset as part of the display string. The digits
/                   will be trimmed and will have one space on each side. A 
/                   slash will precede it as shown below.
/                   nnn / ddd (pct)
/ byrowvar          This is for when you want to show a "by" variable as a row
/                   following the variable you are analyzing.
/ byroword          Ordering variable for byrowvar if needed
/ byrowlabel        Label for byrowvar
/ byrowalign        Alignment of byrow (left/center/right)
/ byrowfmt          Format for byrow variable
/ byroww            Width for byrowvar
/ font_face_stats=Courier   Font to use for ODS output of the calculated stats
/                   values. For correct alignment of the decimal point for non-
/                   paired stats for MS Office then this must be set to
/                   "Courier" (no quotes).
/ font_face_other=Times     Font to use for ODS output for columns other
/                   than the calculated stats.
/ font_weight_other=Bold    Weight of font to use for columns other than 
/                   the calculated stats.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Mar06         Version 4.0 with three level reporting and level
/                      parameter name changes.
/ rrb  08May06         Set _str=" " when total population and _count are 0
/ rrb  14Jul06         Header tidy
/ rrb  13Feb07         "macro called" message added
/ rrb  08Mar07         Use %dequote for parameter quote checks for v4.1
/ rrb  09Mar07         Allow use of formatted level variables for v5.0
/ rrb  10Mar07         dsall= parameter and processing added for v6.0
/ rrb  11Mar07         80 column limit strictly enforced on header
/ rrb  21Mar07         Added support for the "nocenter" option
/ rrb  30Mar07         Bug fixed with trtlabel and toplabel
/ rrb  03May07         pctsign=no parameter added to allow users to force the
/                      display of the percent sign if required.
/ rrb  16May07         pctfmt=5.1 parameter added to allow users to change the
/                      percent format.
/ rrb  17May07         Further checking of pctfmt= value added (v6.5)
/ rrb  30jul07         Header tidy
/ rrb  01Sep07         pctwarn=yes parameter added
/ rrb  18Sep07         odsrtf= parameter added
/ rrb  19Sep07         odshtml= and odspdf= parameters added
/ rrb  21Sep07         odsother= parameter added
/ rrb  23Sep07         Header tidy
/ rrb  30Sep07         topline=no is now the default which is better suited to
/                      ODS output.
/ rrb  10Nov07         Bug fixed to allow $ and $CHAR formats
/ rrb  27Jan08         odshtmlcss= and odscsv= parameters added and logic
/                      changed for when print=no so that other ods output is
/                      still produced.
/ rrb  15Mar08         odslisting= parameter added
/ rrb  16Mar08         "ods listing" statement used to free ods listing file
/ rrb  26Mar08         Bug in handling $ and $CHAR formats fixed
/ rrb  10Apr08         spanrows= parameter added
/ rrb  26Apr08         style=3 , style3w= , style3lbl= and eventsort= 
/                      parameters added for this major upgrade to v7.0
/ rrb  26Apr08         keepwork=no and keepmidlvlmin=yes parameters added
/ rrb  26Apr08         Duplicate style 3 label parameter removed
/ rrb  30Apr08         dsdenom= and denomshow= parameters added
/ rrb  30Apr08         pctcompress= and byrow= parameters added for v8.0
/ rrb  08May08         style(COLUMN)={HTMLSTYLE="mso-number-format:'\@'"} added
/                      to proc report call so that MS Office treats the cells as
/                      text-formatted cells. The same can be achieved using
/                      headtext="<style> td {mso-number-format:\@}</style>"
/                      in the ODS statement but it is hard to remember.
/ rrb  09May08         font_face_stats=, font_face_other= and font_weight_other=
/                      parameters added.
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: npcttab v8.1;

%macro npcttab(dsin=,
              dsall=,
              dspop=_popfmt,
           uniqueid=,
             trtvar=,
             trtfmt=,
           trtlabel=,
            topline=no,
           toplabel=,
            spacing=2,
           trtspace=4,
             byvars=,
            highlvl=,
         highlvlord=,
             midlvl=,
          midlvlord=,
             lowlvl=,
          lowlvlord=,
            lowlvlw=0,
            style3w=0,
               nlen=3,
              style=3,
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
             indent=3,
         highlvllbl=,
          midlvllbl=,
          lowlvllbl=,
          style3lbl=,
             trtord=99,
          trttotval=99,
              total=yes,
            anylowlvl="ANY AE",
            toplowlvl=,
            anywhen=before,
           droplowlvl=,
              split=@,
           headskip=yes,
          spantotal=yes,
             minpct=,
           mincount=,
          minpctany=,
        mincountany=,
              print=yes,
             events=no,
             nevlen=,
              dsout=_npcttab,
         trtvarlist=,
             pcttrt=,
            pvalues=no,
            usetest=,
           pvalkeep=,
            pvalvar=_pvalue,
            pvalfmt=p63val.,
            pvalstr=TRT9999,
            pvallbl="p-value",
        pvaltrtlist=,
           fisherid=^,
            chisqid=~,
            trendid=,
             nodata=nodata,
            pagevar=,
           pgbrkpos=,
            pctsign=no,
            pctwarn=yes,
             pctfmt=5.1,
        pctcompress=no,
             odsrtf=,
            odshtml=,
         odshtmlcss=,
             odscsv=,
             odspdf=,
         odslisting=,
           odsother=,
           spanrows=yes,
          eventsort=yes,
           keepwork=no,
      keepmidlvlmin=no,
            dsdenom=,
          denomshow=yes,
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
           font_face=Courier
           );


    /*-----------------------------*
         check parameter settings
     *-----------------------------*/ 

%local error ls i totvar strlen numtrt trtwidth startcol repwidth rest 
       trtinlist val var pvalds pvalvar cwidth cwidths fwidth fwidths 
       pcttrtlist newmidlvl newhighlvl newlowlvl indentmid indentlow
       highfmt midfmt lowfmt center pctnfmt denomsortvars pctaction;

%global _strlen_;
   
%let error=0;


%if not %length(&font_face_stats) %then %let font_face_stats=Courier;
%if not %length(&font_face_other) %then %let font_face_other=Times;
%if not %length(&font_weight_other) %then %let font_weight_other=Bold;

%if not %length(&byvars) %then %let byvars=&byroword &byrowvar &byrow2ord &byrow2var;

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

%if not %length(&byrowlabel) %then %let byrowlabel=" ";
%if not %length(&byrow2label) %then %let byrow2label=" ";

%if not %length(&style) %then %let style=1;

%if not (&style=1 or &style=2 or &style=3) %then %do;
  %let error=1;
  %put ERROR: (npcttab) Style must be 1, 2 or 3 (unquoted) but you have style=&style;
%end;


%if %length(&dsdenom) %then %let denomsortvars=%sortedby(&dsdenom);

%if not %length(&pctcompress) %then %let pctcompress=no;
%let pctcompress=%upcase(%substr(&pctcompress,1,1));

%if not %length(&denomshow) %then %let denomshow=yes;
%let denomshow=%upcase(%substr(&denomshow,1,1));

%if not %length(&keepmidlvlmin) %then %let keepmidlvlmin=yes;
%let keepmidlvlmin=%upcase(%substr(&keepmidlvlmin,1,1));

%if not %length(&keepwork) %then %let keepwork=no;
%let keepwork=%upcase(%substr(&keepwork,1,1));

%if not %length(&eventsort) %then %let eventsort=no;
%let eventsort=%upcase(%substr(&eventsort,1,1));

%if not %length(&pctsign) %then %let pctsign=no;
%let pctsign=%upcase(%substr(&pctsign,1,1));

%if not %length(&pctwarn) %then %let pctwarn=yes;
%let pctwarn=%upcase(%substr(&pctwarn,1,1));

%if "&pctwarn" EQ "N" %then %do;
  %put WARNING: (npcttab) Percent > 100.01 checks disabled;
%end;

%*- if a high level variable specified but no mid one -;
%*- then shift high level values down to mid ones.    -;
%if %length(&highlvl) and not %length(&midlvl) %then %do;
  %let midlvl=&highlvl;
  %let midlvlord=&highlvlord;
  %let midlvllbl=&highlvllbl;
  %let highlvl=;
  %let highlvlord=;
  %let highlvllbl=;
%end;


%*- set indentation values -;
%if %length(&midlvl) %then %let indentlow=&indent;
%else %let indentlow=0;
%if %length(&highlvl) %then %let indentmid=&indent;
%else %let indentmid=0;


%if not %length(&pctfmt) %then %let pctfmt=5.1;
%let pctnfmt=%substr(&pctfmt,%verifyb(&pctfmt,0123456789.)+1);

%if not %length(&pctnfmt) or not %index(&pctnfmt,.) %then %do;
  %let error=1;
  %put ERROR: (npcttab) Format supplied to pctfmt=&pctfmt not valid;
%end;
%else %if "%substr(&pctnfmt,1,1)" EQ "." %then %do;
  %let error=1;
  %put ERROR: (npcttab) No format length supplied to pctfmt=&pctfmt;
%end;

%if not %length(&dsin) %then %do;
  %let error=1;
  %put ERROR: (npcttab) No input dataset name specified for dsin=;
%end;

%if not %length(&dspop) %then %do;
  %let error=1;
  %put ERROR: (npcttab) No population dataset specified for dspop=;
%end;

%if not %length(&lowlvl) %then %do;
  %let error=1;
  %put ERROR: (npcttab) No low level variable specified for lowlvl=;
%end;

%if not %length(&trtord) %then %do;
  %let error=1;
  %put ERROR: (npcttab) No treatment arm ordering value specified for trtord=;
%end;

%if not %length(&trttotval) %then %do;
  %let error=1;
  %put ERROR: (npcttab) No treatment arm total value specified for trttotval=;
%end;

%if not %length(&anylowlvl) %then %do;
  %let error=1;
  %put ERROR: (npcttab) No label specified for the combination of all low level terms for anylowlvl=;
%end;

%if not %length(&minpct.&mincount.&minpctany.&mincountany) %then %let anywhen=before;
%if not %length(&anywhen) %then %let anywhen=before;
%let anywhen=%upcase(%substr(&anywhen,1,1));

%if ("&anywhen" NE "B" and "&anywhen" NE "A") %then %do;
  %let error=1;
  %put ERROR: (npcttab) You must set anywhen=before or anywhen=after;
%end;

%if not %length(&pvaltrtlist) %then %let pvaltrtlist=ne &trttotval;
%else %let pvaltrtlist=in (&pvaltrtlist);

%if &error %then %goto error;



    /*-----------------------------*
         check parameter quoting
     *-----------------------------*/ 

%*- make sure the following is quoted -;


%let anylowlvl="%dequote(&anylowlvl)";


%*- make sure these are NOT quoted -;

%if %length(&highlvllbl) %then %let highlvllbl=%dequote(&highlvllbl);

%if %length(&midlvllbl) %then %let midlvllbl=%dequote(&midlvllbl);

%if %length(&lowlvllbl) %then %let lowlvllbl=%dequote(&lowlvllbl);



    /*-----------------------------*
        assign parameter defaults
     *-----------------------------*/

%let ls=%sysfunc(getoption(linesize));
%let center=%sysfunc(getoption(center));

%if not %length(&uniqueid) %then %do;
  %let uniqueid=&_uniqueid_;
  %put NOTE: (npcttab) Defaulting to uniqueid=&uniqueid;
%end;

%if not %length(&trtvar) %then %do;
  %let trtvar=&_trtvar_;
  %put NOTE: (npcttab) Defaulting to trtvar=&trtvar;
%end;

%if not %length(&dsout) %then %let dsout=_npcttab;

%if not %length(&toplowlvl) %then %let toplowlvl=&anylowlvl;

%if not %length(&trtfmt) %then %do;
  %if %length(&pcttrt) %then %let trtfmt=&_poptfmt_;
  %else %let trtfmt=&_popfmt_;
%end;

%if not %length(&spacing) %then %let spacing=2;

%if not %length(&trtspace) %then %let trtspace=4;

%if not %length(&lowlvlw) %then %let lowlvlw=0;

%if not %length(&events) %then %let events=no;
%let events=%upcase(%substr(&events,1,1));

%if not %length(&nlen) %then %let nlen=3;
%if not %length(&nevlen) %then %let nevlen=&nlen;

%if not %length(&spanrows) %then %let spanrows=yes;
%let spanrows=%upcase(%substr(&spanrows,1,1));
%if "&spanrows" EQ "Y" and 
  %sysevalf( %scan(&sysver,1,.).%scan(&sysver,2,.) GE 9.2 ) 
  %then %let spanrows=spanrows;
%else %let spanrows=;


%*----- work out the display length -----;
%*- add 3 for the space and round brackets -;
%let strlen=%eval(&nlen+3);
%*- add the length of the percent format -;
%let strlen=%eval(&strlen+%scan(&pctnfmt,1,.));
%*- add for a space and the event count if that is specified -;
%if "&events" EQ "Y" %then %let strlen=%eval(&strlen+1+&nevlen);
%*- if displaying percent sign then add 1 to the length -;
%if "&pctsign" EQ "Y" %then %let strlen=%eval(&strlen+1);
%*- if displaying denominator then add more -;
%if %length(&dsdenom) and "&denomshow" EQ "Y" 
  %then %let strlen=%eval(&strlen+&nlen+3);
%let _strlen_=&strlen;

%let cwidths=&_trtcwidths_;
%if "&total" EQ "Y" %then %let cwidths=&cwidths &_trttotcwidth_;

%let fwidths=&_trtfwidths_;
%if "&total" EQ "Y" %then %let fwidths=&fwidths &_trttotfwidth_;

%*- if percentages shown for certain trt only then make a list of the vars -;
%if %length(&pcttrt) %then %do;
  %do i=1 %to %words(&pcttrt);
    %let pcttrtlist=&pcttrtlist
&_trtpref_%sysfunc(compress(%scan(&pcttrt,&i,%str( )),%str(%'%")));
  %end;
%end;


%*- set default lengths for widths -;
%do i=1 %to 19;
  %if not %length(&&trtw&i) %then %do;
    %let var=%scan(&_trtvarlist_,&i,%str( ));
    %let cwidth=%scan(&cwidths,&i,%str( ));
    %let fwidth=%scan(&fwidths,&i,%str( ));
    %let trtw&i=&strlen;
    %if &cwidth GT &&trtw&i %then %let trtw&i=&cwidth;
    %if %length(&pcttrt) and not
%index(%quotelst(%upcase(&pcttrtlist)),"%upcase(&var)") %then %do;
      %let trtw&i=&nlen;
      %if &fwidth GT &&trtw&i %then %let trtw&i=&fwidth;
    %end;
  %end;
%end;


%if not %length(&topline) %then %let topline=no;
%let topline=%substr(%upcase(&topline),1,1);

%if not %length(&split) %then %let split=@;


%if not %length(&headskip) %then %let headskip=yes;
%let headskip=%upcase(%substr(&headskip,1,1));
%if "&headskip" EQ "Y" %then %let headskip=headskip;
%else %let headskip=;


%if not %length(&total) %then %let total=yes;
%let total=%substr(%upcase(&total),1,1);

%if not %length(&spantotal) %then %let spantotal=yes;
%let spantotal=%upcase(%substr(&spantotal,1,1));

%if not %length(&print) %then %let print=yes;
%let print=%upcase(%substr(&print,1,1));

%if %length(&highlvllbl) %then %let highlvllbl=%dequote(&highlvllbl);
%if %length(&midlvllbl) %then %let midlvllbl=%dequote(&midlvllbl);
%if %length(&lowlvllbl) %then %let lowlvllbl=%dequote(&lowlvllbl);

%if not %length(&pvalues) %then %let pvalues=no;
%let pvalues=%upcase(%substr(&pvalues,1,1));

%if not %length(&pgbrkpos) %then %let pgbrkpos=before;



    /*-----------------------------*
        dsall initial processing
     *-----------------------------*/

%if %length(&dsall) %then %do;
  proc sort nodupkey data=&dsall out=_npctdsall;
    by &highlvlord &highlvl &midlvlord &midlvl &lowlvlord &lowlvl;
  run;
%end;



    /*-----------------------------*
          set up new variables
     *-----------------------------*/

*- This version of npcttab allows you to specify formatted variables  -;
*- which it will automatically resolve into its uncoded form in a new -;
*- variable and this is where the processing is done. -;

*- keep only the needed variables -;
data _npctdsin;
  set &dsin;
  keep &byvars &trtvar &uniqueid 
       &highlvlord &highlvl &midlvlord &midlvl &lowlvlord &lowlvl;
run;


%*- default the new variable names to the old ones -;
%let newhighlvl=&highlvl;
%let newmidlvl=&midlvl;
%let newlowlvl=&lowlvl;


%*- find out if a user format is applied to these variables -;
%if %length(&highlvl) %then %do;
  %let highfmt=%varfmt(_npctdsin,&highlvl);
  %if not %index("" %sysfmtlist, "%sysfunc(compress(&highfmt,1234567890.))") 
    %then %let newhighlvl=__highlvl;
%end;
%if %length(&midlvl) %then %do;
  %let midfmt=%varfmt(_npctdsin,&midlvl);
  %if not %index("" %sysfmtlist, "%sysfunc(compress(&midfmt,1234567890.))")
    %then %let newmidlvl=__midlvl;
%end;
%if %length(&lowlvl) %then %do;
  %let lowfmt=%varfmt(_npctdsin,&lowlvl);
  %if not %index("" %sysfmtlist, "%sysfunc(compress(&lowfmt,1234567890.))")
    %then %let newlowlvl=__lowlvl;
%end;




*- do for input data -;
data _npctdsin;
  %*- decode any of these variables if need be -;
  %if ("&newhighlvl" NE "&highlvl") or ("&newmidlvl" NE "&midlvl") 
   or ("&newlowlvl" NE "&lowlvl") %then %do;
    length
    %if ("&newhighlvl" NE "&highlvl") %then &newhighlvl ;
    %if ("&newmidlvl" NE "&midlvl") %then &newmidlvl ;
    %if ("&newlowlvl" NE "&lowlvl") %then &newlowlvl ;
    $ 200;
  %end;
  set _npctdsin;
  %if ("&newhighlvl" NE "&highlvl") %then %do;
    &newhighlvl=put(&highlvl,&highfmt.);
  %end;
  %if ("&newmidlvl" NE "&midlvl") %then %do;
    &newmidlvl=put(&midlvl,&midfmt.);
  %end;
  %if ("&newlowlvl" NE "&lowlvl") %then %do;
    &newlowlvl=put(&lowlvl,&lowfmt.);
  %end;
  keep &byvars &trtvar &uniqueid 
       &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl;
  *- cancel all formats except for by variables -;
  format &trtvar &uniqueid &highlvlord &newhighlvl &midlvlord &newmidlvl
         &lowlvlord &newlowlvl;
run;



%if %length(&dsall) %then %do;
  *- do for dsall data -;
  data _npctdsall;
    %*- decode any of these variables if need be -;
    %if ("&newhighlvl" NE "&highlvl") or ("&newmidlvl" NE "&midlvl") 
     or ("&newlowlvl" NE "&lowlvl") %then %do;
      length
      %if ("&newhighlvl" NE "&highlvl") %then &newhighlvl ;
      %if ("&newmidlvl" NE "&midlvl") %then &newmidlvl ;
      %if ("&newlowlvl" NE "&lowlvl") %then &newlowlvl ;
      $ 200;
    %end;
    set _npctdsall;
    %if ("&newhighlvl" NE "&highlvl") %then %do;
      &newhighlvl=put(&highlvl,&highfmt.);
    %end;
    %if ("&newmidlvl" NE "&midlvl") %then %do;
      &newmidlvl=put(&midlvl,&midfmt.);
    %end;
    %if ("&newlowlvl" NE "&lowlvl") %then %do;
      &newlowlvl=put(&lowlvl,&lowfmt.);
    %end;
    *- cancel all the formats -;
    format &highlvlord &newhighlvl &midlvlord &newmidlvl 
           &lowlvlord &newlowlvl;
  run;
%end;




    /*-----------------------------*
          add dummy variables
     *-----------------------------*/

*- if all level variables not present then set up dummy variables -;

%if not %length(&highlvl) or not %length(&midlvl) %then %do;
  %if not %length(&highlvl) %then %let newhighlvl=_dummyhigh;
  %if not %length(&midlvl) %then %let newmidlvl=_dummymid;

  data _npctdsin;
    %if not %length(&highlvl) %then %do;
      retain &newhighlvl "DUMMY";
    %end;
    %if not %length(&midlvl) %then %do;
      retain &newmidlvl "DUMMY";
    %end;
    set _npctdsin;
  run;

  %if %length(&dsall) %then %do;
    data _npctdsall;
      %if not %length(&highlvl) %then %do;
        retain &newhighlvl "DUMMY";
      %end;
      %if not %length(&midlvl) %then %do;
        retain &newmidlvl "DUMMY";
      %end;
      set _npctdsall;
    run;
  %end;

%end;



    /*-----------------------------*
        add total treatment group
     *-----------------------------*/

*- This is calculated even if not going to be displayed since it is  -;
*- possibly to be used as the treatment arm to base the ordering by. -;
data _npctdsin;
  set _npctdsin;
  output;
  &trtvar=&trttotval;
  output;
run;



    /*-----------------------------*
        in case there is no data
     *-----------------------------*/

%if %attrn(_npctdsin,nobs) EQ 0 and %length(&nodata) %then %do;
  %&nodata
  %goto skip;
%end;



    /*-----------------------------*
       sort ready for filter step
     *-----------------------------*/

*- sort ready for the filter step if needed -;
proc sort data=_npctdsin;
  by &byvars &newhighlvl &newmidlvl &newlowlvl &trtvar;
run;

%goto skipfilter;



    /*-----------------------------*
        filter for anywhen=after
     *-----------------------------*/

%filter:

*- If anywhen=after is set then only keep those terms that will -;
*- be displayed and repeat all the steps to calculate the count -;
*- and percentage for anylowlvl plus the default ordering variables. -;
data _npctdsin;
  merge _npctfilter(in=_filter) _npctdsin(in=_data);
  by &byvars &newhighlvl &newmidlvl &newlowlvl;
  if _filter and _data;
run;



%skipfilter:



    /*-----------------------------*
          summarise for events
     *-----------------------------*/


*- low level events -;
proc summary nway missing data=_npctdsin;
  by &byvars;
  class &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl &trtvar;
  output out=_npctevlowlvl(drop=_type_ rename=(_freq_=_events));
run;

data _npctevlowlvl;
  set _npctevlowlvl;
  _lowlvlevord=1/_events;
run;

  
*- mid level events -;
proc summary nway missing data=_npctdsin;
  by &byvars;
  class &highlvlord &newhighlvl &midlvlord &newmidlvl &trtvar;
  output out=_npctevmidlvl(drop=_type_ rename=(_freq_=_events));
run;
 
data _npctevmidlvl;
  set _npctevmidlvl;
  _midlvlevord=1/_events;
run;


*- high level events -;
proc summary nway missing data=_npctdsin;
  by &byvars;
  class &highlvlord &newhighlvl &trtvar;
  output out=_npctevhighlvl(drop=_type_ rename=(_freq_=_events));
run;

data _npctevhighlvl;
  set _npctevhighlvl;
  _highlvlevord=1/_events;
run;





    /*-----------------------------*
          get rid of duplicates
     *-----------------------------*/

*- This part gets ready for the unique subject counts by dropping -;
*- duplicate records for the subjects. -;

proc sort nodupkey data=_npctdsin
                    out=_npctlowlvl;
  by &byvars &trtvar &uniqueid 
     &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl;
run;

proc sort nodupkey data=_npctdsin(drop=&lowlvlord &newlowlvl)
                    out=_npctmidlvl;
  by &byvars &trtvar &uniqueid 
     &highlvlord &newhighlvl &midlvlord &newmidlvl;
run;

proc sort nodupkey data=_npctdsin(drop=&midlvlord &newmidlvl &lowlvlord &newlowlvl)
                    out=_npcthighlvl;
  by &byvars &trtvar &uniqueid 
     &highlvlord &newhighlvl;
run;



    /*-----------------------------*
      summarise for unique subjects
     *-----------------------------*/

*- Summarise for unique subjects and put the total in _count. -;
*- Merge in the event counts. -;

*- Low Level -;
proc summary nway missing data=_npctlowlvl;
  by &byvars;
  class &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl &trtvar;
  output out=_npctlowlvl(drop=_type_ rename=(_freq_=_count));
run;

data _npctlowlvl;
  merge _npctevlowlvl _npctlowlvl;
  by &byvars &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl &trtvar;
run;



*- Mid Level -;
proc summary nway missing data=_npctmidlvl;
  by &byvars;
  class &highlvlord &newhighlvl &midlvlord &newmidlvl &trtvar;
  output out=_npctmidlvl(drop=_type_ rename=(_freq_=_count));
run;

data _npctmidlvl;
  merge _npctevmidlvl _npctmidlvl;
  by &byvars &highlvlord &newhighlvl &midlvlord &newmidlvl &trtvar;
run;



*- High Level -;
proc summary nway missing data=_npcthighlvl;
  by &byvars;
  class &highlvlord &newhighlvl &trtvar;
  output out=_npcthighlvl(drop=_type_ rename=(_freq_=_count));
run;

data _npcthighlvl;
  merge _npctevhighlvl _npcthighlvl;
  by &byvars &highlvlord &newhighlvl &trtvar;
run;



data _npcthighlvl;
  set _npcthighlvl;
  _highlvlord=1/_count;
run;


*- Set up the anylowlvl term for later inclusion -;
*- in with the rest of low level terms -;
data _npctmidlvl;
  length &newlowlvl %varlen(_npctlowlvl,&newlowlvl);
  retain &newlowlvl &anylowlvl;
  set _npctmidlvl;
  _midlvlord=1/_count;
run;



    /*-----------------------------*
             Add in anylowlvl
     *-----------------------------*/

*- Note that the anylowlvl term gets added to the _npctlowlvl -;
*- dataset here. -;

data _npctlowlvl;
  set _npctmidlvl(drop=_midlvlord _midlvlevord)
      _npctlowlvl;
  _lowlvlord=1/_count;
run;


*- sort ready for a merge with zero values -;
proc sort data=_npctlowlvl;
  by &trtvar &byvars &highlvlord &newhighlvl 
     &midlvlord &newmidlvl &lowlvlord &newlowlvl;
run;



    /*-----------------------------*
           Create a zero grid
     *-----------------------------*/

%if %length(&dsall) %then %do;
  %zerogrid(zerovar=_count,
  var1=&trtvar,ds1=&dspop,
  %if %length(&byvars) %then %do;
    var2=&byvars,ds2=_npctlowlvl,
  %end;
  var3=&highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl,
  ds3=_npctdsall)
%end;
%else %do;
  %zerogrid(zerovar=_count,
  var1=&trtvar,ds1=&dspop,
  var2=&byvars &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl,
  ds2=_npctlowlvl)
%end;

*- add extra required variables -;
data zerogrid;
  retain _events 0 _lowlvlord _lowlvlevord 99;
  set zerogrid;
run;



    /*-----------------------------*
       Merge on top of zero values
     *-----------------------------*/

data _npctlowlvl;
  merge zerogrid _npctlowlvl;
  by &trtvar &byvars &highlvlord &newhighlvl 
     &midlvlord &newmidlvl &lowlvlord &newlowlvl;
run;



    /*-----------------------------*
          calculate percentages
     *-----------------------------*/



%if %length(&dsdenom) %then %do;
  %if not %length(&denomsortvars) %then %do;
    %let denomsortvars=%match(%varlist(_npctlowlvl),%varlist(&dsdenom));
    proc sort data=&dsdenom out=_npctdenom;
      by &denomsortvars;
    run;
  %end;
  %else %do;
    data _npctdenom;
      set &dsdenom;
    run;
  %end;
  proc sort data=_npctlowlvl;
    by &denomsortvars;
  run;
%end;


%if "&pctcompress" EQ "Y" %then %let pctaction=compress(put(_pct,&pctfmt));
%else %let pctaction=put(_pct,&pctfmt);


*- Merge with the population or the denominator dataset -;
data _npctlowlvl;
  length _str $ &strlen _idlabel $ 120;
  %if %length(&dsdenom) %then %do;
    merge _npctdenom _npctlowlvl(in=_npct);
    by &denomsortvars;
  %end;
  %else %do;
    merge &dspop _npctlowlvl(in=_npct);
    by &trtvar;
  %end;
  if _npct;
  if _total in (.,0) and _count EQ 0 then do;
    _pct=0;
    _str=" ";
  end;
  else do;
    _pct=100*_count/_total;
    %if "&pctwarn" NE "N" %then %do;
    if _pct GT 100.01 then 
      put "WARNING: (npcttab) _pct GT 100.01 " (_all_) (=);
    %end;
    %if "&events" EQ "Y" %then %do;
      %if "&pctsign" EQ "Y" %then %do;
        %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
          _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||" ("||&pctaction||"%) "||put(_events,&nevlen..);
        %end;
        %else %do;
          _str=put(_count,&nlen..)||" ("||&pctaction||"%) "||put(_events,&nevlen..);
        %end;
      %end;
      %else %do;
        %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
          _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||" ("||&pctaction||") "||put(_events,&nevlen..);
        %end;
        %else %do;
          _str=put(_count,&nlen..)||" ("||&pctaction||") "||put(_events,&nevlen..);
        %end;
      %end;
    %end;
    %else %do;
      %if %length(&pcttrt) %then %do;
        %if "&pctsign" EQ "Y" %then %do;
          %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
            if &trtvar in (&pcttrt) then _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||"("||&pctaction||"%)";
          %end;
          %else %do;
            if &trtvar in (&pcttrt) then _str=put(_count,&nlen..)||"("||&pctaction||"%)";
          %end;
          else _str=put(_count,&nlen..);
        %end;
        %else %do;
          %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
            if &trtvar in (&pcttrt) then _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||"("||&pctaction||")";
          %end;
          %else %do;
            if &trtvar in (&pcttrt) then _str=put(_count,&nlen..)||"("||&pctaction||")";
          %end;
          else _str=put(_count,&nlen..);
        %end;
      %end;
      %else %do;
        %if "&pctsign" EQ "Y" %then %do;
          %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
            _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||" ("||&pctaction||"%)";
          %end;
          %else %do;
            _str=put(_count,&nlen..)||" ("||&pctaction||"%)";
          %end;
        %end;
        %else %do;
          %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
            _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||" ("||&pctaction||")";
          %end;
          %else %do;
            _str=put(_count,&nlen..)||" ("||&pctaction||")";
          %end;
        %end;
      %end;
    %end;
  end;
  _idlabel=put(&trtvar,&trtfmt);
  *- cancel possible treatment variable format picked up from dspop dataset -;
  format &trtvar;
run;


 
    /*-----------------------------*
           calculate p-values
     *-----------------------------*/

%if "&pvalues" EQ "Y" %then %do;

  data _forpvals;
    set _npctlowlvl(where=(&trtvar &pvaltrtlist));
    _response=1;
    output;
    _response=0;
    _count=_total-_count;
    output;
  run;

  proc sort data=_forpvals;
    by &byvars &highlvlord &newhighlvl 
       &midlvlord &newmidlvl &lowlvlord &newlowlvl &trtvar;
  run;


  %if %attrn(_forpvals,nobs) GT 0 %then %do;
    %let pvalds=_pvalues;
    %npctpvals(dsin=_forpvals,
               byvars=&byvars &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl,
               trtvar=&trtvar,respvar=_response,countvar=_count,usetest=&usetest,
               pvalvar=&pvalvar,pvallbl=&pvallbl,pvalstr=&pvalstr,pvalfmt=&pvalfmt,
               pvalkeep=&pvalkeep,chisqid=&chisqid,fisherid=&fisherid,trendid=&trendid)
  %end;
  %else %let pvalds=;
  
  proc datasets nolist;
    delete _forpvals;
  run;
  quit;
  
    
%end;
%else %do;

  %*- setting this to null makes the "proc report" logic easier -;
  %let pvalstr=;

%end;



    /*-----------------------------*
               Transpose
     *-----------------------------*/
  
proc sort data=_npctlowlvl;
  by &byvars &highlvlord &newhighlvl &midlvlord 
     &newmidlvl &lowlvlord &newlowlvl &trtvar;
run;

*- transpose _str -;
proc transpose prefix=&_trtpref_ data=_npctlowlvl out=_npctstr(drop=_name_);
  by &byvars &highlvlord &newhighlvl &midlvlord 
     &newmidlvl &lowlvlord &newlowlvl ;
  var _str;
  id &trtvar;
  idlabel _idlabel;
run;

*- transpose _count -;
proc transpose prefix=_CNT data=_npctlowlvl out=_npctcnt(drop=_name_);
  by &byvars &highlvlord &newhighlvl &midlvlord 
     &newmidlvl &lowlvlord &newlowlvl ;
  var _count;
  id &trtvar;
  idlabel _idlabel;
run;

*- transpose _pct -;
proc transpose prefix=_PCT data=_npctlowlvl out=_npctpct(drop=_name_);
  by &byvars &highlvlord &newhighlvl &midlvlord 
     &newmidlvl &lowlvlord &newlowlvl ;
  var _pct;
  id &trtvar;
  idlabel _idlabel;
run;

*- Merge the transposed datasets back together -;
*- and add the pvalue dataset (if created).    -;
data &dsout;
  merge _npctstr _npctcnt _npctpct &pvalds;
  by &byvars &highlvlord &newhighlvl &midlvlord 
     &newmidlvl &lowlvlord &newlowlvl ;
run;



    /*-----------------------------*
          minpct= and mincount=
     *-----------------------------*/

%if %length(&minpct) or %length(&mincount) %then %do;

  *- minpct= and mincount= only apply to the treatment arm value -;
  *- specified to trtord= (by default the total of all treatment -;
  *- groups) so select on these. -;
  data &dsout;
    set &dsout;
    %if %length(&mincount) %then %do;
      if _cnt%sysfunc(compress(&trtord,%str(%'%"))) >= &mincount;
    %end;
    %if %length(&minpct) %then %do;
      if _pct%sysfunc(compress(&trtord,%str(%'%"))) >= &minpct;
    %end;   
  run;


%end;



    /*-----------------------------*
       minpctany= and mincountany=
     *-----------------------------*/

%if %length(&minpctany) or %length(&mincountany) %then %do;

  %*- Get a list of all the treatment values -;
  %let trtinlist=&_trtinlist_;
  %if "&total" EQ "Y" %then %let trtinlist=&trtinlist &_trttotstr_;

  *- Find the maximum _count and _pct for any displayed treatment -;
  *- arm, select of this and drop at the end. -;
  data &dsout;
    set &dsout;
     _count=max(0
    %do i=1 %to %words(&trtinlist);
      %let val=%sysfunc(compress(%scan(&trtinlist,&i,%str( )),%str(%'%")));
      , _cnt&val
    %end;
    );
    _pct=max(0
    %do i=1 %to %words(&trtinlist);
      %let val=%sysfunc(compress(%scan(&trtinlist,&i,%str( )),%str(%'%")));
      , _pct&val
    %end;
    );    
    %if %length(&mincountany) %then %do;
      if _count >= &mincountany;
    %end;
    %if %length(&minpctany) %then %do;
      if _pct >= &minpctany;
    %end;   
    drop _pct _count;
  run;

%end;



    /*-----------------------------*
             Keepmidlvlmin
     *-----------------------------*/

%if "&keepmidlvlmin" EQ "N" %then %do;
  proc summary nway missing data=&dsout;
    class &byvars &newhighlvl &newmidlvl;
    output out=_npctkeepmid(drop=_type_);
  run;

  data _npctkeepmid;
    set _npctkeepmid;
    if _freq_=1 then delete;
    drop _freq_;
  run;

  data &dsout;
    merge _npctkeepmid(in=_mid) &dsout;
    by &byvars &newhighlvl &newmidlvl;
    if _mid;
  run;

%end;



    /*-----------------------------*
         anywhen=after processing
     *-----------------------------*/

%if "&anywhen" EQ "A" %then %do;

  *- If anywhen=after then the anylvl3 count and percentage -;
  *- are based on only the terms being displayed so at this -;
  *- point find out what those terms are and branch back to -;
  *- near the start of the macro and select only those terms. -;
  proc sort nodupkey data=&dsout(keep=&byvars &newmidlvl &newlowlvl)
             out=_npctfilter;
    by &byvars &newhighlvl &newmidlvl &newlowlvl;
  run;
  
  %*- reset so that we do not do this a second time -;
  %let anywhen=B;
  %goto filter;

%end;



    /*-----------------------------------*
       Add _highlvlord ordering variable
     *-----------------------------------*/

%if not %length(&highlvlord) %then %do;

  data &dsout;
    merge _npcthighlvl(in=_highlvl keep=&byvars &trtvar
                         &newhighlvl _highlvlord _highlvlevord
                   where=(&trtvar=&trtord))
          &dsout(in=_tran);
    by &byvars &newhighlvl;
    if _tran;
    if not _highlvl then do;
      _highlvlord=9999;
      _highlvlevord=9999;
    end;
    drop &trtvar;
  run;

%end;



    /*----------------------------------*
       Add _midlvlord ordering variable
     *----------------------------------*/

%if not %length(&midlvlord) %then %do;

  data &dsout;
    merge _npctmidlvl(in=_midlvl keep=&byvars &highlvlord &newhighlvl 
                         &newmidlvl _midlvlord _midlvlevord &trtvar
                   where=(&trtvar=&trtord))
          &dsout(in=_tran);
    by &byvars &highlvlord &newhighlvl &newmidlvl;
    if _tran;
    if not _midlvl then do;
      _midlvlord=9999;
      _midlvlevord=9999;
    end;
    drop &trtvar;
  run;

%end;



    /*----------------------------------*
       Add _lowlvlord ordering variable
     *----------------------------------*/

%if not %length(&lowlvlord) %then %do;

  data &dsout;
    merge _npctlowlvl(in=_lowlvl 
                  keep=&byvars &highlvlord &newhighlvl &trtvar
                       &midlvlord &newmidlvl &newlowlvl _lowlvlord _lowlvlevord
                 where=(&trtvar=&trtord))
          &dsout(in=_tran);
    by &byvars &highlvlord &newhighlvl &midlvlord &newmidlvl &newlowlvl;
    if _tran;
    if not _lowlvl then do;
      _lowlvlord=9999;
      _lowlvlevord=9999;
    end;
    drop &trtvar;
  run;

%end;



    /*----------------------------------*
       Set default ordering variables
     *----------------------------------*/

%if not %length(&highlvlord) %then %let highlvlord=_highlvlord;
%if not %length(&midlvlord)  %then %let midlvlord=_midlvlord;
%if not %length(&lowlvlord)  %then %let lowlvlord=_lowlvlord;



    /*-----------------------------*
          Calculate report width
     *-----------------------------*/

%*- This is done here so the report width can be applied -;
%*- to the midlvl and highlvl variable in a length statement -;
%*- to make sure it is not too long for the report. -;

%let totvar=;
%if "&total" EQ "Y" %then %let totvar=&_trttotvar_;

%if not %length(&byroww) %then %let byroww=12;
%if not %length(&byrow2w) %then %let byrow2w=12;


%let numtrt=%words(&_trtvarlist_ &totvar);
%do i=1 %to &numtrt;
  %if &i EQ 1 and not %length(&trtsp1) %then %let trtsp1=&spacing;
  %else %if not %length(&&&trtsp&i) %then %let trtsp&i=&trtspace;
%end;
%let trtwidth=0;
%do i=1 %to &numtrt;
  %let trtwidth=%eval(&trtwidth+&&trtsp&i+&&trtw&i);
%end;

%if "&pvalues" EQ "Y" %then %let trtwidth=%eval(&trtwidth+&trtspace+8);

%let rest=%eval(&ls-&trtwidth-&indentlow-&indentmid);

%if %length(&byrowvar) %then %let rest=%eval(&rest-&byroww-2);
%if %length(&byrow2var) %then %let rest=%eval(&rest-&byrow2w-2);

%if &lowlvlw=0 %then %let lowlvlw=&rest;
%else %if &rest LT &lowlvlw %then %let lowlvlw=&rest;

%if &style3w=0 %then %let style3w=&rest;
%else %if &rest LT &style3w %then %let style3w=&rest;


%*- report width below is only meaningful and correct for style=1 output -;
%let repwidth=%eval(&lowlvlw+&trtwidth+&indentlow+&indentmid);


%if &center EQ NOCENTER %then %let startcol=1;
%else %let startcol=%eval((&ls-&repwidth)/2 + 1);



    /*---------------------------------*
       Limit length of midlvl variable
     *---------------------------------*/


*- midlvl variable can not be longer than the report width -;
data &dsout;
  %if &style EQ 3 %then %do;
    length _combtext $ %eval(&ls-&trtwidth);
  %end;
  length &_trtvarlist_ 
    %if "&total" EQ "Y" %then %do;
      &_trttotvar_ 
    %end;
    $ &strlen
    %if "&pvalues" EQ "Y" %then %do;
      &_trtpvalvar_ $ 8
    %end;
    &newhighlvl $ &repwidth
    &newmidlvl $ %eval(&repwidth-&indentmid)
  ;
  retain _indent '        ';
  set &dsout;
  %if &style EQ 3 %then %do;
    if &newlowlvl=&anylowlvl then _combtext=&newmidlvl;
    else _combtext=repeat("A0"x,&indentlow-1)||&newlowlvl;
  %end;
  %if %length(&droplowlvl) %then %do;
    if &newlowlvl in (&droplowlvl) 
    %if &style=3 %then %do;
      and &newlowlvl NE &anylowlvl
    %end;
    then delete;
  %end;
  if &newlowlvl=&toplowlvl then _primord=0;
  else _primord=1;
run;



    /*-----------------------------*
            Produce the report
     *-----------------------------*/


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


proc report nowd missing headline &headskip split="&split" spacing=&spacing
&spanrows data=&dsout

  style(COLUMN)={font_face=&font_face_stats HTMLSTYLE="mso-number-format:'\@'"}
  style(LINES)={font_face=&font_face_other font_weight=&font_weight_other HTMLSTYLE="mso-number-format:'\@'"}

;

  %if %length(&byvars) %then %do;
    by &byvars;
  %end; 
 
  columns
  %if "&topline" EQ "Y" %then %do;
    ( "___" 
  %end;

  &pagevar &byroword &byrowvar &byrow2ord &byrow2var

           &highlvlord
 
           %if "&eventsort" EQ "Y" %then %do;
             _highlvlevord
           %end;

           &newhighlvl 
           &midlvlord 

           %if "&eventsort" EQ "Y" %then %do;
             _midlvlevord
           %end;

           &newmidlvl 
           _primord
           &lowlvlord 

           %if "&eventsort" EQ "Y" %then %do;
             _lowlvlevord
           %end;

  %if &style=3 %then %do;
    _combtext
  %end;

  %else %do;
    %if &indentlow GT 0 %then %do;
      _indent 
    %end;
  
    &newlowlvl 
  %end;
  
  (&toplabel 
 
  %if %length(&trtlabel) %then %do;
    %if "&spantotal" EQ "Y" %then %do;
      ( &trtlabel 
        %if %length(&trtvarlist) %then %do;
          &trtvarlist )
        %end;
        %else %do;
          &_trtvarlist_ &totvar ) &pvalstr
        %end;
    %end;
    %else %do;
      ( &trtlabel
        %if %length(&trtvarlist) %then %do;
          &trtvarlist )
        %end;
        %else %do; 
          &_trtvarlist_ ) &totvar &pvalstr
        %end;
    %end;
  %end;
  %else %do;
     %if %length(&trtvarlist) %then %do;
       &trtvarlist
     %end;
     %else %do;
       &_trtvarlist_ &totvar &pvalstr
     %end;
  %end;
    )

  %if "&topline" EQ "Y" %then %do;
    )
  %end;
  ;

  %if %length(&pagevar) %then %do;
    define &pagevar / order order=internal noprint;
  %end;

  %if %length(&byroword) %then %do;
    define &byroword / order order=internal noprint;
  %end;

  %if %length(&byrowvar) %then %do;
    define &byrowvar / order order=internal &byrowlabel width=&byroww &byrowalign flow spacing=0
           %if %length(&byrowfmt) %then f=&byrowfmt ;
           style(COLUMN)={font_face=&font_face_other font_weight=&font_weight_other}   
      ;
  %end;


  %if %length(&byrow2ord) %then %do;
    define &byrow2ord / order order=internal noprint;
  %end;

  %if %length(&byrow2var) %then %do;
    define &byrow2var / order order=internal &byrow2label width=&byrow2w &byrow2align flow spacing=2
           %if %length(&byrow2fmt) %then f=&byrow2fmt ;   
           style(COLUMN)={font_face=&font_face_other font_weight=&font_weight_other}
      ;
  %end;

  define &highlvlord / order order=internal noprint;

  %if "&eventsort" EQ "Y" %then %do;
    define _highlvlevord / order=internal noprint;
  %end;

  define &newhighlvl / order noprint;

  define &midlvlord / order order=internal noprint;

  %if "&eventsort" EQ "Y" %then %do;
    define _midlvlevord / order=internal noprint;
  %end;

  define &newmidlvl / order noprint;

  %if &indentlow GT 0 and &style NE 3 %then %do;
    define _indent / order spacing=0 width=%eval(&indentlow+&indentmid)

    %if %length(&highlvllbl) %then %do;
      %if %length(&highlvllbl) LE %eval(&indentlow+&indentmid) %then %do;
        "&highlvllbl" 
      %end;
      %else %do;
        "%substr(&highlvllbl,1,%eval(&indentmid+&indentlow))" 
      %end;
      %if %length(&midlvllbl) %then %do;
        %if %length(&midlvllbl) LE &indentlow %then %do;
          "%sysfunc(repeat(%str( ),%eval(&indentmid-1)))&midlvllbl" 
        %end;
        %else %do;
          "%sysfunc(repeat(%str( ),%eval(&indentmid-1)))%substr(&midlvllbl,1,&indent)" 
        %end;
        %if %length(&lowlvllbl) %then %do;
          " "
        %end;
      %end;
      %else %do;
        " " 
      %end;
    %end;

    %else %if %length(&midlvllbl) %then %do;
      %if %length(&midlvllbl) LE &indentlow %then %do;
        "&midlvllbl" 
      %end;
      %else %do;
        "%substr(&midlvllbl,1,&indentlow)" 
      %end;
      %if %length(&lowlvllbl) %then %do;
        " "
      %end;
    %end;

    %else %do;
      " " 
    %end;

    ;
  %end;

  define _primord / order order=internal noprint;

  define &lowlvlord / order order=internal noprint;

  %if "&eventsort" EQ "Y" %then %do;
    define _lowlvlevord / order=internal noprint;
  %end;


  %if &style NE 3 %then %do;

    define &newlowlvl / order width=&lowlvlw flow spacing=0

    %if &indentlow GT 0 %then %do;
      %if %length(&highlvllbl) GT %eval(&indentlow+&indentmid) %then %do;
        "%substr(&highlvllbl,&indentlow+&indentmid+1)"
        %if %length(&midlvllbl) GT &indentlow %then %do;
          "%substr(&midlvllbl,&indentlow+1)"
        %end;
        %else %do;
         " "
        %end;
        %if %length(&lowlvllbl) %then %do;
          "&lowlvllbl"
        %end;
      %end;
      %else %if %length(&midlvllbl) GT &indentlow %then %do;
        "%substr(&midlvllbl,&indentlow+1)"
        %if %length(&lowlvllbl) %then %do;
          "&lowlvllbl"
        %end;
      %end;
      %else %do;
        %if %length(&lowlvllbl) %then %do;
          "&lowlvllbl"
        %end;
        %else %do;
          " "
        %end;
      %end;
    %end;

    %else %do;
      %if %length(&lowlvllbl) %then %do;
        "&lowlvllbl"
      %end;
      %else %do;
        " "
      %end;
    %end;
    ;

  %end;

  %else %do;

    define _combtext / order width=&style3w flow 
    %if not %length(&byrowvar) %then %do;
      spacing=0
    %end;
    %else %do;
      spacing=2
    %end;

    %if %length(&style3lbl) %then %do;
      &style3lbl
    %end;
    %else %do;
      " "
    %end;
    style(COLUMN)={font_face=&font_face_other font_weight=&font_weight_other}
    ;

  %end;

  
  %do i=1 %to %words(&_trtvarlist_);
    define %scan(&_trtvarlist_,&i,%str( )) / width=&&trtw&i center display spacing=&&trtsp&i;
  %end;
  %if %length(&totvar) %then %do;
    define &totvar / width=&&trtw&i center display spacing=&trtspace;
  %end;
  %if %length(&pvalstr) %then %do;
    define &pvalstr / &pvallbl width=8 center display spacing=&trtspace;
  %end;

  %if &indentmid gt 0 and &style ne 3 %then %do;
    compute before &newhighlvl;
      line @&startcol &highlvl $char&repwidth..;
    endcomp;
  %end;

  %if &indentlow gt 0 and &style ne 3 %then %do;
    compute before &newmidlvl;
      line @%eval(&startcol+&indentmid) &midlvl $char%eval(&repwidth-&indentmid).;
    endcomp;
  %end;

  break after &newmidlvl / skip;

  %if %length(&pagevar) %then %do;
    break &pgbrkpos &pagevar / _page_;
  %end;

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





    /*-----------------------------*
             Tidy up and exit
     *-----------------------------*/


%if "&keepwork" EQ "Y" %then %do;
%end;
%else %do;
  proc datasets nolist;
    delete _npctdsin _npcthighlvl _npctmidlvl _npctlowlvl 
           _npctstr _npctcnt _npctpct &pvalds
      _npctevhighlvl _npctevmidlvl _npctevlowlvl

    %if %length(&keepmidlvlmin) %then %do;
      _npctkeepmid
    %end;

    %if %length(&dsall) %then %do;
      _npctdsall
    %end;
    %if "&print" EQ "Y" %then %do;
      &dsout
    %end;
    ;
  run;
  quit;
%end;

%goto skip;
%error: %put ERROR: (npcttab) Leaving macro due to error(s) listed;
%skip:
%mend;
