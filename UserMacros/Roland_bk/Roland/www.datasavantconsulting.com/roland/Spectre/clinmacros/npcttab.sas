/*<pre><b>
/ Program      : npcttab.sas
/ Version      : 10.31
/ Author       : Roland Rashleigh-Berry
/ Date         : 29-May-2015
/ Purpose      : Clinical reporting macro to produce tables showing "n", the
/                percentage and optionally, the number of events.
/ SubMacros    : %quotelst %words %varlen %zerogrid %npctpvals %attrn %qdequote
/                %varfmt %sysfmtlist %verifyb %commas %sortedby %match %nodup
/                %mvarlist %mvarvalues %varlistn %nlobs %attrc %removew
/                %hasvarsc %varnum %splitvar (assumes %popfmt already run)
/ Notes        : Observations for the total of all treatment arms will be
/                generated inside this macro so do not set this up in the
/                input dataset.
/
/                If you do not specify ordering variables then the levels will
/                be displayed in descending subject frequency count for the
/                total column (even if total column is not displayed).
/
/ Usage        : See tutorial with demonstrations on the Spectre web site. After
/                completing the tutorial you will be able to learn more about the
/                capabilities of this macro by reading this header.
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Input dataset (where clause allowed). Note that all the data
/                   in this dataset (with any where clause applied) will be used
/                   to calculate counts and percentages so you should only
/                   provide it with the data you want to see these counts and
/                   percentages for. There is no need to "collapse" multiple
/                   records into single records for the percentages since these
/                   are based on unique subject counts. However, it is important
/                   to make sure multiple records are collapsed if the number of
/                   events has been requested.
/ msglevel=X        Message level to use inside this macro for notes and 
/                   information written to the log. By default, both Notes and
/                   Information are suppressed. Use msglevel=N or I for more
/                   information.
/ dsall             Optional dataset for displaying all levels present. The 
/                   level variables in this dataset must be identical to those
/                   in the dsin= dataset. If the high level or mid level
/                   variables are missing from this dataset then they will be 
/                   added using what is found in the input dataset so you can
/                   just specify a dataset containing low level terms if you
/                   wish.
/ alllowlvl=no      This takes effect so long as dsall= is null and if set to
/                   "yes" (no quotes) will create a dsall= dataset with just the
/                   lower level terms in it as found in the input data. If you
/                   are sure that all the lower level terms are in the data then
/                   using this parameter is easier than setting up a dsall=  
/                   dataset containing the lower terms.
/ style=1           This is the default layout style to use but you should
/                   always set this value as the default value may change from
/                   time to time.
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
/                             This style is NOT IMPLEMENTED YET and if you
/                             specify it then style=1 is used instead.
/                     Style=3 is for combining all the levels in the same column
/                             and the levels will be indented with spaces (non-
/                             breaking spaces for ODS output) as per the indent=
/                             parameter setting. Terms that flow onto following
/                             lines can have a "hanging indent" according to the
/                             hindent= parameter setting. Note that you need to
/                             specify the column label to the style3lbl= as it
/                             will not use the normal labels. This style uses
/                             the %splitvar macro that currently only works for
/                             Western character sets such that one letter takes
/                             up one byte. See the %splitvar macro header for
/                             more information.
/ usecolon=yes      By default, use a colon as an indentation marker when
/                   splitting text.
/ double=no         By default, do not throw blank lines between rows.
/ midskip=yes       By default, throw a blank line between mid-level terms
/ highskip=no       By default, do not throw a blank line between high-level
/                   terms.
/ filtercode        SAS code you specify to drop observations and do minor
/                   reformatting before printing is done. If this code
/                   contains commas then enclose in quotes (the quotes will be
/                   dropped from the start and end before the code is executed).
/                   You can have multiple lines of sas code if you end each line
/                   with a semicolon. For serious editing you should do this in
/                   a macro defined to extmacro= .
/ extmacro          External macro to call (no % sign) and will typically be
/                   used to include extra stats values to add to the report.
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
/ dspop=_popfmt     Name of population dataset used for calculating percentages
/ uniqueid          List of variables that uniquely identify a subject
/                   (defaults to &_uniqueid_ set in %popfmt).
/ trtvar            Treatment group variable (defaults to &_trtvar_ set in
/                   %popfmt) which must be a coded numeric variable or a short
/                   coded character variable (typically one or two bytes with no
/                   spaces).
/ trtfmt            (optional) format to apply to the treatment variable
/ trtalign=c        Default alignment of treatment column headers is centred
/ odsescapechar="°" ODS escape character (quoted)
/ trtlabel          (quoted) Treatment arm label. Default is not to show a
/                   treatment label.
/ odstrtlabel       ODS non-listing output label for treatment arms (defaults to
/                   value of trtlabel= ). Note that column underlines defined
/                   using "--" that work for ascii output do not work for ODS
/                   output. Assuming "^" is the ODS escape character then to
/                   achieve a spanning underline for ODS output then use the
/                   following method where both the ascii form and ODS form are
/                   shown as examples (works for SAS 9.2 or later)
/              trtlabel="Treatment Arm" "__"
/           odstrtlabel='^{style [borderbottomwidth=1 borderbottomcolor=black]
/                        Treatment Arm}'
/ topline=yes       Default is to show a line at the top of the report for ascii
/                   output. Non-listing ODS output will not show this line.
/ toplabel          Default is not to have a label at the top of the table but
/                   should be quoted if required.
/ spacing=2         Default spacing is 2 between the lowlvl terms and treatments
/ trtspace=4        Default spacing is 4 between treatment arms
/ byvars            (optional) by variables
/ highlvl           High level variable (optional)
/ highlvlord        (optional) variable to order high level terms
/ pageon            Values of the highest level variable to force page throws.
/                   These should be separated by spaces. Strings should be
/                   enclosed in quotes. The in: function is used internally 
/                   so string values need only be start values.
/                   example:    "Muscul" "Hepa"
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
/ hindent=0         The number of columns to leave blank for style=3 reports 
/                   when a term flows onto following lines (a "hanging indent").
/                   For already indented terms then this value will be added to
/                   the existing indent.
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
/                   parts and each part should be quoted. If this is left blank
/                   then the macro will generate it from any existing labels
/                   supplied and failing that it will use the variable labels.
/ trtord            If lowlvlord not specified then this is the treatment group
/                   value used for ordering lowlvl items which defaults to
/                   whata is defined to _trttotstr_ .
/ trttotval         Extra observations are created for the total of all 
/                   treatment groups and the default value is _trttotstr_.
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
/ fisherid=^        Symbol to suffix formatted p-values for the Fisher exact
/                   test.
/ chisqid=~         Symbol to suffix formatted p-values for the Chi-square test
/ trendid           Symbol to use to suffix p-values for the Cochran-Armitage
/                   Trend Test.
/ nodata=nodata     Name of macro to call to produce a report if there is no
/                   data. This would normally put out a "NO DATA" message.
/ pgbrkpos          Page breaking position (no quotes - defaults to "before")
/ pctsign=no        By default, do not show the percent sign for percentages
/ pctfmt=5.1        Default format for the percentage
/ pctcompress=no    Whether to compress the percentage
/ npctord=npct      By default display N before PCT values. Set to pctn to
/                   reverse this order.
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
/ tfmacro           Name of macro (no % sign) containing titles and footnotes
/                   code to be enacted before any output is produced, if set.
/                   You will be able to use the "repwidth" macro variable which
/                   is the width of the report in columns if you use this
/                   parameter and reference "repwidth" in your macro code.
/ odstfmacro        Name of macro (no % sign) containing titles and footnotes
/                   code to be enacted before any ODS non-listing output is
/                   produced, if set. If not used then the macro defined to
/                   tfmacro= will be in effect.
/ spanrows=yes      Applies to sas v9.2 and later. Default is to enable the
/                   "spanrows" option for "proc report". You should leave this
/                   set to "yes" (no quotes) unless you have a clear need.
/ eventsort=yes     By default, use the event count as a secondary sort key.
/ debug=no          By default, do not keep the work datasets created by this
/                   macro and activate mprint.
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
/                   ============================================================
/                   Note that giving incorrect parameter values to fonts or any
/                   other values used in a style() statement in proc report can
/                   result in extremely confusing log error messages, usually
/                   shown as a missing round bracket sign as shown below.
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
/ font_weight_other=bold    Weight of font to use for columns other than 
/                   the calculated stats.
/ font_face_other=times     Font to use for ODS output for columns other
/                   than the calculated stats.
/ font_style_other=roman    Font style (italic, roman or slant) to use for ODS 
/                   output for columns other than the calculated stats.
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
/ compskip=yes      (no quotes) By default, throw a blank line after a mid
/                   level term for ODS reports. For ascii output, compskip=no
/                   will always be in effect.
/ compskippos=after (no quotes) By default, throw the skip line after the mid
/                   level term.
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
/ dsparam           Name of parameter dataset. This can EITHER be a "flat"
/                   dataset with variable names matching parameter names OR a
/                   Name-Value pair "tall" dataset (both Name and Value must be
/                   character variables and be called "Name" and "Value" in the
/                   input dataset) with the contents of Name matching a parameter
/                   name and Value its value. "Tall" datasets are suited to the
/                   metadata-driven use of this macro. In both cases, variables
/                   should be character variables. Numeric values can be used
/                   but they must be supplied as characters. Note that parameter
/                   values that are normally supplied in quotes such as 'Courier'
/                   must be enclosed in extra quotes such as Value="'Courier'"
/                   when building the parameter dataset.
/
/                   You can use dataset modifiers when specifying the input
/                   dataset and these modifiers will be applied to create the
/                   internal work dataset "_dsparam". Do not call your parameter
/                   dataset "_dsparam" as this is reserved for use inside this
/                   macro and will be deleted.
/
/ listallparams=no  By default, do not list all the parameters and their values
/                   that this macro has put into effect. Parameter dataset
/                   settings are always listed. Note that parameter values are
/                   often abbreviated to upper case first character inside this
/                   macro such as "no" becoming "N" and "yes" becoming "Y".
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Mar06         Version 4.0 with three level reporting and level
/                      parameter name changes.
/ rrb  08May06         Set _str=" " when total population and _count are 0
/ rrb  14Jul06         Header tidy
/ rrb  13Feb07         "macro called" message added
/ rrb  08Mar07         Use %qdequote for parameter quote checks for v4.1
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
/ rrb  26Apr08         debug=no and keepmidlvlmin=yes parameters added
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
/ rrb  11Sep08         font_weight_stats= parameter added and problems resolving
/                      these parameters fixed.
/ rrb  16Nov08         _combtext length increased to 256 as well as length of
/                      some variables used for spanning the report increased
/                      from 200 to 256. Default style changed back from 3 to 1.
/                      These changes implemented in version 8.3.
/ rrb  10Feb09         Some problems with sort order of main results dataset
/                      fixed in v8.4
/ rrb  11May09         prerepcode= and postrepcode= parameters added plus
/                      fisherid= and chisqid= made consistent with %unistats
/                      for v8.5
/ rrb  18Jun09         tfmacro= parameter added for v8.6
/ rrb  10Jul09         Ascii output created seperately from ODS non-listing
/                      output. Parameters prerepcode= and postrepcode= renamed
/                      to odsprerepcode= and odspostrepcode= . Parameter
/                      odstrtlabel= added. Default changed to topline=yes but
/                      this will only be shown for ascii output (v9.0)
/ rrb  11Jul09         odstfmacro= parameter added (v9.1)
/ rrb  12Jul09         dsparam= parameter added (v9.2)
/ rrb  13Jul09         listallparams= parameter added plus parameter dataset
/                      handling changed slightly (v9.3)
/ rrb  30Aug09         odsescapechar= parameter added plus header tidy (v9.4)
/ rrb  10Sep09         %unquote() used with %qdequote() (v9.5)
/ rrb  13Sep09         asis=on put into effect for columns (v9.6)
/ rrb  12Oct09         Calls to %dequote changed to calls to %qdequote due to
/                      macro renaming (v9.7)
/ rrb  08Nov09         New parameter pageon= added (v9.8)
/ rrb  15Nov09         Warning message about BY variable length now avoided
/                      plus length limit equal to report width on displayed
/                      higher term now limited to non-ODS output only (v9.9)
/ rrb  23Jan10         More ODS parameters used in %unistats added (v10.0)
/ rrb  24Jan10         Variable _combtext2 added for better style=3 ODS
/                      indentation of the combined categories when proportional
/                      text is used (v10.1)
/ rrb  24Jan10         PDF output generated separately due to problems with
/                      column widths (v10.2)
/ rrb  24Jan10         compskip= and associated parameters added from %unicatrep
/                      to throw a line after a mid level term (v10.3)
/ rrb  18Nov10         Added npctord= parameter to allow change of order for
/                      displaying N and PCT values (v10.4)
/ rrb  06Feb11         Bug with unresolved pvalue macro variable fixed (v10.5)
/ rrb  08May11         Code tidy
/ rrb  17May11         Name-Value pair datasets allowed as parameter datasets
/                      in addition to "flat" parameter datasets (v10.6)
/ rrb  24May11         filtercode=, extmacro= and msglevel= parameter
/                      processing added (v10.7)
/ rrb  26May11         Keep event counts in output dataset and added double=
/                      parameter for throwing blank lines between items (v10.8)
/ rrb  27May11         pageline= and endline= parameters added (v10.9)
/ rrb  31May11         Bug with pageline handling fixed (v10.10)
/ rrb  05Jun11         pagevar= parameter removed as not used and superseded by
/                      the pageon= parameter (v10.11)
/ rrb  23Jun11         Bug in anywhen=after processing fixed (v10.12)
/ rrb  12Jul11         trtalign= parameter added (v10.13)
/ rrb  17Jul11         Added hindent= parameter and better flow for ascii text
/                      for style=3 reports (v10.14)
/ rrb  17Jul11         Allow three-level reporting for style=3 (v10.15)
/ rrb  22Jul11         Improved dsall processing to add high level or mid level
/                      variables if missing (v10.16)
/ rrb  22Jul11         alllowlvl= and dsallonly= processing added (v10.17)
/ rrb  23Jul11         Bug in alllowlvl= processing fixed (v10.18)
/ rrb  19Aug11         Changed call to %splitvar for renamed parameter (v10.19)
/ rrb  06Oct11         midskip= and highskip= parameters added (v10.20)
/ rrb  13Oct11         Now odsescapechar="°" the same as %unistats (v10.21)
/ rrb  24Oct11         Minor bug positioning compute block line fixed (v10.22)
/ rrb  28Oct11         hindent= default value changed from 1 to 0 (v10.23)
/ rrb  30Oct11         style3lbl now automatically generated if blank (v10.24)
/ rrb  31Oct11         Incorrect (pcpttab) changed to (npcttab) and bug with
/                      style3 "repeat" use fixed (v10.25)
/ rrb  03Nov11         "repeat" use bug refix (v10.26)
/ rrb  03Nov11         99 defaults for trtord= and trttotval= changed so that it
/                      uses what is defined to _trttotstr_ as this was causing a
/                      problem for character treatment arms. nlen= and nevlen=
/                      values will now be corrected if too small (v10.27)
/ rrb  12Dec11         Bug with setting style 3 label fixed (v10.28)
/ rrb  26Dec11         Header updated to explain that style=3 currently only
/                      works correctly for Western character sets.
/ rrb  30Dec11         msglevel= processing changed (v10.29)
/ rrb  20Jul12         Internally defined macro names now start with "_npct" and
/                      all macros matching that pattern are deleted from 
/                      work.sasmacr at macro close using %delmac (v10.30)
/ rrb  14Sep14         Use of "keyword" dropped for boolean options (v10.31)
/ rrb  29May15         Header description for dsin= parameter updated
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: npcttab v10.31;

%macro npcttab(dsin=,
           msglevel=X,
             double=no,
            midskip=yes,
           highskip=no,
              dsall=,
          dsallonly=no,
          alllowlvl=no,
              dspop=_popfmt,
           uniqueid=,
             trtvar=,
             trtfmt=,
         filtercode=,
           extmacro=,
      odsescapechar="°",
           trtlabel=,
        odstrtlabel=,
            topline=yes,
           toplabel=,
            spacing=2,
           trtspace=4,
             byvars=,
            highlvl=,
         highlvlord=,
             pageon=,
             midlvl=,
          midlvlord=,
             lowlvl=,
          lowlvlord=,
            lowlvlw=0,
            style3w=0,
               nlen=3,
              style=1,
           usecolon=yes,
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
           trtalign=c,
             indent=3,
            hindent=0,
         highlvllbl=,
          midlvllbl=,
          lowlvllbl=,
          style3lbl=,
             trtord=,
          trttotval=,
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
           pvalcolw=8,
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
           pgbrkpos=,
            pctsign=no,
            pctwarn=yes,
             pctfmt=5.1,
        pctcompress=no,
            npctord=npct,
             odsrtf=,
            odshtml=,
         odshtmlcss=,
             odscsv=,
             odspdf=,
         odslisting=,
           odsother=,
            tfmacro=,
         odstfmacro=,
          eventsort=yes,
           debug=no,
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
            spanrows=yes,
     font_face_stats=times,
   font_weight_stats=medium,
     font_face_other=times,
    font_style_other=roman,
   font_weight_other=bold,
       report_border=no,
       header_border=no,
       column_border=no,
        lines_border=no,
               rules=none,
         cellspacing=0,
         cellpadding=0,
      outputwidthpct=calc,
   background_header=white,
   foreground_header=black,
    background_stats=white,
    foreground_stats=black,
    background_other=white,
    foreground_other=black,
           header_ul=yes,
           report_ul=yes,
           report_ol=yes,
              linepx=1,
             linecol=black,
            compskip=yes,
         compskippos=after,
         compskip_ul=no,
          compskippx=1,
         compskipcol=black,
       odsprerepcode=,
      odspostrepcode=,
             dsparam=,
       listallparams=no,
                asis=off
           );


  %local parmlist;


  %*- get a list of parameters for this macro -;
  %let parmlist=%mvarlist(npcttab);

  %*- remove the macro variable name "parmlist" from this list -;
  %let parmlist=%removew(&parmlist,parmlist);


  %local errflag err wrn ls i totvar strlen numtrt trtwidth startcol
         repwidth rest trtinlist val var pvalds pvalvar cwidth cwidths
         fwidth fwidths pcttrtlist newmidlvl newhighlvl newlowlvl
         indentmid indentlow highfmt midfmt lowfmt center pctnfmt
         denomsortvars pctaction varlist2 badvars suppvars savopts
         pagevar pagevar2 dsallmiss maxcnt maxev;

  %let err=ERR%str(OR);
  %let wrn=WAR%str(NING);
  %let errflag=0;

  %if not %length(&msglevel) %then %let msglevel=X;
  %let msglevel=%upcase(%substr(&msglevel,1,1));
  %if "&msglevel" NE "N" and "&msglevel" NE "I" %then %let msglevel=X;

  %let savopts=%sysfunc(getoption(msglevel,keyword)) %sysfunc(getoption(notes));
  %if "&msglevel" EQ "N" or "&msglevel" EQ "I" %then %do;
    options msglevel=&msglevel;
  %end;
  %else %do;
    options nonotes;
  %end;



             /*-----------------------------------------*
                      Parameter dataset handling
              *-----------------------------------------*/


  %if %length(&dsparam) %then %do;

    *-- handle possible dataset modifiers --;
    data _dsparam;
      set &dsparam;
    run;
 
    %if %hasvarsc(_dsparam,name value) %then %do;
      *-- we have a Name-Value pair dataset so transpose it to a "flat" dataset --;
      proc transpose data=_dsparam(keep=name value) out=_dsparam(drop=_name_);
        var value;
        id name;
      run;
 
      %if %varnum(_dsparam,_label_) %then %do;
        *-- drop the _label_ --;
        data _dsparam,
          set _dsparam:
          drop _label_;
        run;
      %end;
    %end;

    %if %nlobs(_dsparam) NE 1 %then %do;
      %let errflag=1;
      %put &err: (npcttab) The parameter dataset dsparam=&dsparam should have one;
      %put &err: (npcttab) observation but this dataset has %nlobs(_dsparam) observations.;
      %put &err: (npcttab) Checking of this dataset will continue but it can not be used.;
      %put;
    %end;

    %let varlist2=%varlistn(_dsparam);
    %if %length(&varlist2) %then %do;
      %let errflag=1;
      %put &err: (npcttab) Numeric variables are not allowed in the parameter dataset ;
      %put &err: (npcttab) dsparam=&dsparam but the following numeric variables exist:;
      %put &err: (npcttab) &varlist2;
      %put;
    %end;

    %if %varnum(_dsparam,dsparam) %then %do;
      %let errflag=1;
      %put &err: (npcttab) The variable DSPARAM is present in the parameter dataset;
      %put &err: (npcttab) dsparam=&dsparam but use of this variable inside a;
      %put &err: (npcttab) parameter dataset is not allowed.;
      %put;
    %end;

    proc contents noprint data=_dsparam out=_unicont(keep=name);
    run;

    data _null_;
      length badvars $ 2000;
      retain badvars ;
      set _unicont end=last;
      name=upcase(name);
      if name not in (%quotelst(&parmlist)) then badvars=trim(badvars)||" "||name;
      if last then call symput('badvars',trim(left(badvars)));
    run;

    %if %length(&badvars) %then %do;
      %let errflag=1;
      %put &err: (npcttab) The following list of variables in dsparam=&dsparam;
      %put &err: (npcttab) do not match any of the macro parameter names so the;
      %put &err: (npcttab) parameter dataset will not be used:;
      %put &err: (npcttab) &badvars;
      %put;
    %end;

    proc datasets nolist;
      delete _unicont;
    run;
    quit;

    %if &errflag %then %goto exit;

    *- the parameter dataset is good so call symput all the variables -;
    data _null_;
      set _dsparam;
      array _char {*} _character_;
      length __y $ 32;
      do __i=1 to dim(_char);
        __y=vname(_char(__i));
        call symput(__y,trim(left(_char(__i))));
      end;
    run;

    %let varlist2=%varlist(_dsparam);

    proc datasets nolist;
      delete _dsparam;
    run;
    quit;

    %put MSG: (npcttab) The following macro parameters and their values were;
    %put MSG: (npcttab) set as the result of use of the dsparam=&dsparam;
    %put MSG: (npcttab) parameter dataset:;
    %mvarvalues(&varlist2);
    %put;

  %end;



      /*-----------------------------*
           check parameter settings
       *-----------------------------*/ 


  %global _strlen_;

  %if not %length(&trtord) %then %let trtord=&_trttotstr_;
  %if not %length(&trttotval) %then %let trttotval=&_trttotstr_;

  %if not %length(&midskip) %then %let midskip=yes;
  %let midskip=%upcase(%substr(&midskip,1,1));

  %if not %length(&highskip) %then %let highskip=no;
  %let highskip=%upcase(%substr(&highskip,1,1));

  %if not %length(&dsallonly) %then %let dsallonly=no;
  %let dsallonly=%upcase(%substr(&dsallonly,1,1));

  %if not %length(&alllowlvl) %then %let alllowlvl=no;
  %let alllowlvl=%upcase(%substr(&alllowlvl,1,1));

  %if not %length(&indent) %then %let indent=3;
  %if not %length(&hindent) %then %let hindent=0;

  %if %length(%sysfunc(compress(&indent,1234567890))) %then %do;
    %put &err: (npcttab) Expecting a positive interger for indent=&indent;
    %let errflag=1;
  %end;
  %if %length(%sysfunc(compress(&hindent,1234567890))) %then %do;
    %put &err: (npcttab) Expecting a positive interger for hindent=&hindent;
    %let errflag=1;
  %end;

  %if not %length(&trtalign) %then %let trtalign=c;
  %let trtalign=%upcase(%substr(&trtalign,1,1));
  %if &trtalign=C %then %let trtalign=center;
  %else %if &trtalign=R %then %let trtalign=right;
  %else %let trtalign=left;

  %if not %length(&pageline) %then %let pageline=no;
  %let pageline=%upcase(%substr(&pageline,1,1));
 
  %if not %length(&endline) %then %let endline=no;
  %let endline=%upcase(%substr(&endline,1,1));

  %if not %length(&double) %then %let double=no;
  %let double=%upcase(%substr(&double,1,1));

  %if not %length(&npctord) %then %let npctord=npct;
  %let npctord=%upcase(%substr(&npctord,1,1));

  %if not %length(&compskip) %then %let compskip=yes;
  %let compskip=%upcase(%substr(&compskip,1,1));

  %if not %length(&compskippos) %then %let compskippos=after;

  %if not %length(&asis) %then %let asis=on;

  %if not %length(&pvalcolw) %then %let pvalcolw=8;

  %if not %length(&listallparams) %then %let listallparams=no;
  %let listallparams=%upcase(%substr(&listallparams,1,1));

  %let suppvars=&highlvl &midlvl &lowlvl;

  %let pagevar=;  %*- this parameter disabled with v10.11 -;
  %if NOT %length(&pagevar) %then %do;
    %if NOT %length(&pageon) %then %do;
      %let pagevar2=_PAGE_;
    %end;
    %else %do;
      %let pagevar=_page;
      %let pagevar2=_page;
    %end;
  %end;
  %else %let pagevar2=&pagevar;

  %if not %length(&odstrtlabel) %then %let odstrtlabel=&trtlabel;

  %if not %length(&font_face_stats) %then %let font_face_stats=times;
  %if not %length(&font_weight_stats) %then %let font_weight_stats=medium;
  %if not %length(&font_face_other) %then %let font_face_other=times;
  %if not %length(&font_style_other) %then %let font_style_other=roman;
  %if not %length(&font_weight_other) %then %let font_weight_other=bold;

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
    %let errflag=1;
    %put &err: (npcttab) Style must be 1, 2 or 3 (unquoted) but you have style=&style;
  %end;


  %if %length(&dsdenom) %then %let denomsortvars=%sortedby(&dsdenom);

  %if not %length(&pctcompress) %then %let pctcompress=no;
  %let pctcompress=%upcase(%substr(&pctcompress,1,1));

  %if not %length(&denomshow) %then %let denomshow=yes;
  %let denomshow=%upcase(%substr(&denomshow,1,1));

  %if not %length(&keepmidlvlmin) %then %let keepmidlvlmin=yes;
  %let keepmidlvlmin=%upcase(%substr(&keepmidlvlmin,1,1));

  %if not %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));
  %if "&debug" EQ "Y" %then %do;
    options mprint;
  %end;

  %if not %length(&eventsort) %then %let eventsort=no;
  %let eventsort=%upcase(%substr(&eventsort,1,1));

  %if not %length(&pctsign) %then %let pctsign=no;
  %let pctsign=%upcase(%substr(&pctsign,1,1));

  %if not %length(&pctwarn) %then %let pctwarn=yes;
  %let pctwarn=%upcase(%substr(&pctwarn,1,1));

  %if "&pctwarn" EQ "N" %then %do;
    %put &wrn: (npcttab) Percent > 100.01 checks disabled;
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
    %let errflag=1;
    %put &err: (npcttab) Format supplied to pctfmt=&pctfmt not valid;
  %end;
  %else %if "%substr(&pctnfmt,1,1)" EQ "." %then %do;
    %let errflag=1;
    %put &err: (npcttab) No format length supplied to pctfmt=&pctfmt;
  %end;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (npcttab) No input dataset name specified for dsin=;
  %end;

  %if not %length(&dspop) %then %do;
    %let errflag=1;
    %put &err: (npcttab) No population dataset specified for dspop=;
  %end;

  %if not %length(&lowlvl) %then %do;
    %let errflag=1;
    %put &err: (npcttab) No low level variable specified for lowlvl=;
  %end;

  %if not %length(&trtord) %then %do;
    %let errflag=1;
    %put &err: (npcttab) No treatment arm ordering value specified for trtord=;
  %end;

  %if not %length(&trttotval) %then %do;
    %let errflag=1;
    %put &err: (npcttab) No treatment arm total value specified for trttotval=;
  %end;

  %if not %length(&anylowlvl) %then %do;
    %let errflag=1;
    %put &err: (npcttab) No label specified for the combination of all low level terms for anylowlvl=;
  %end;

  %if not %length(&minpct.&mincount.&minpctany.&mincountany) %then %let anywhen=before;
  %if not %length(&anywhen) %then %let anywhen=before;
  %let anywhen=%upcase(%substr(&anywhen,1,1));

  %if ("&anywhen" NE "B" and "&anywhen" NE "A") %then %do;
    %let errflag=1;
    %put &err: (npcttab) You must set anywhen=before or anywhen=after;
  %end;

  %if not %length(&pvaltrtlist) %then %let pvaltrtlist=ne &trttotval;
  %else %let pvaltrtlist=in (&pvaltrtlist);

  %if not %length(&rules) %then %let rules=none;
  %if not %sysfunc(indexw(NONE ALL COLS ROWS GROUPS,%upcase(&rules))) %then %do;
    %let errflag=1;
    %put &err: (npcttab) Rules parameter value can only be none, all, cols, rows, groups. You put rules=&rules;
  %end;

  %if &errflag %then %goto exit;



      /*-----------------------------*
           check parameter quoting
       *-----------------------------*/ 

  %*- make sure the following is quoted -;


  %let anylowlvl="%unquote(%qdequote(&anylowlvl))";


  %*- make sure these are NOT quoted -;

  %if %length(&highlvllbl) %then %let highlvllbl=%unquote(%qdequote(&highlvllbl));

  %if %length(&midlvllbl) %then %let midlvllbl=%unquote(%qdequote(&midlvllbl));

  %if %length(&lowlvllbl) %then %let lowlvllbl=%unquote(%qdequote(&lowlvllbl));


  %if &style EQ 3 and not %length(&style3lbl) %then %do;
    %let style3lbl=;
    %if %length(&highlvl) %then %do;
      %if %length(&highlvllbl) %then %let style3lbl="&highlvllbl";
      %else %let style3lbl="%varlabel(%scan(&dsin,1,%str(%()),&highlvl)";
    %end;
    %if %length(&midlvl) %then %do;
      %if %length(&midlvllbl) %then %let style3lbl=&style3lbl "&midlvllbl";
      %else %do;
        %if &indentmid EQ 0 %then %let style3lbl=&style3lbl
"%varlabel(%scan(&dsin,1,%str(%()),&midlvl)";
        %else %let style3lbl=&style3lbl
"%sysfunc(repeat(%str( ),%eval(&indentmid-1)))%varlabel(%scan(&dsin,1,%str(%()),&midlvl)";
      %end;
    %end;
    %if %length(&lowlvl) %then %do;
      %if %length(&lowlvllbl) %then %let style3lbl=&style3lbl "&lowlvllbl";
      %else %do;
        %if %eval(&indentmid+&indentlow) EQ 0 %then %let style3lbl=&style3lbl
"%varlabel(%scan(&dsin,1,%str(%()),&lowlvl)";
        %else %let style3lbl=&style3lbl
"%sysfunc(repeat(%str( ),%eval(&indentmid+&indentlow-1)))%varlabel(%scan(&dsin,1,%str(%()),&lowlvl)";
      %end;
    %end;
  %end;


        /*-----------------------------*
            assign parameter defaults
         *-----------------------------*/

  %let ls=%sysfunc(getoption(linesize));
  %let center=%sysfunc(getoption(center));

  %if not %length(&cellspacing) %then %let cellspacing=0;


  %if not %length(&report_border) %then %let report_border=no;
  %if not %length(&header_border) %then %let header_border=no;
  %if not %length(&column_border) %then %let column_border=no;
  %if not %length(&lines_border) %then %let lines_border=no;

  %let report_border=%upcase(%substr(&report_border,1,1));
  %let header_border=%upcase(%substr(&header_border,1,1));
  %let column_border=%upcase(%substr(&column_border,1,1));
  %let lines_border=%upcase(%substr(&lines_border,1,1));

  %if not %length(&uniqueid) %then %do;
    %let uniqueid=&_uniqueid_;
    %put NOTE: (npcttab) Defaulting to uniqueid=&uniqueid;
    %put;
  %end;

  %if not %length(&trtvar) %then %do;
    %let trtvar=&_trtvar_;
    %put NOTE: (npcttab) Defaulting to trtvar=&trtvar;
    %put;
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


  %let cwidths=&_trtcwidths_;
  %if "&total" EQ "Y" %then %let cwidths=&cwidths &_trttotcwidth_;

  %let fwidths=&_trtfwidths_;
  %if "&total" EQ "Y" %then %let fwidths=&fwidths &_trttotfwidth_;

  %*- if percentages shown for certain trt only then make a list of the vars -;
  %if %length(&pcttrt) %then %do;
    %do i=1 %to %words(&pcttrt);
      %let pcttrtlist=&pcttrtlist &_trtpref_%sysfunc(compress(%scan(&pcttrt,&i,%str( )),%str(%'%")));
    %end;
  %end;



  %if not %length(&topline) %then %let topline=yes;
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

  %if %length(&highlvllbl) %then %let highlvllbl=%unquote(%qdequote(&highlvllbl));
  %if %length(&midlvllbl) %then %let midlvllbl=%unquote(%qdequote(&midlvllbl));
  %if %length(&lowlvllbl) %then %let lowlvllbl=%unquote(%qdequote(&lowlvllbl));

  %if not %length(&pvalues) %then %let pvalues=no;
  %let pvalues=%upcase(%substr(&pvalues,1,1));

  %if not %length(&pgbrkpos) %then %let pgbrkpos=before;


  %if "&listallparams" EQ "Y" %then %do;
    %put MSG: (npcttab) The complete list of macro parameters and their values;
    %put MSG: (npcttab) that this macro has put into effect is as follows:;
    %mvarvalues(&parmlist);
    %put;
  %end;


      /*-----------------------------*
          dsall initial processing
       *-----------------------------*/

  %if %length(&dsall) or "&alllowlvl" EQ "Y" %then %do;

    *-- Find out if we are missing the high or mid level variables in the      --;
    *-- dsall dataset and add them from the input dataset if that is the case. --;

    %let dsallmiss=;

    %if %length(&dsall) %then %do;
      data _npctdsall;
        set &dsall;
      run;
    %end;
    %else %do;
      %let dsall=_npctdsall;
      proc summary nway missing data=&dsin;
        class &lowlvl;
        output out=_npctdsall(drop=_type_ _freq_);
      run;
    %end;

    %if %length(&highlvl) %then %do;
      %if not %varnum(_npctdsall,&highlvl) and not %varnum(_npctdsall,&midlvl) %then %let dsallmiss=&highlvl &midlvl;
      %else %if not %varnum(_npctdsall,&highlvl) %then %let dsallmiss=&highlvl;
    %end;
    %else %if %length(&midlvl) %then %do;
      %if not %varnum(_npctdsall,&midlvl) %then %let dsallmiss=&midlvl;
    %end;

    %if %length(&dsallmiss) %then %do;
      proc summary nway missing data=&dsin;
        class &dsallmiss;
        output out=_npctmiss(drop=_type_ _freq_);
      run;

      data _npctdsall;
        set _npctmiss;
        do __i=1 to __nobs;
          set _npctdsall point=__i nobs=__nobs;
          output;
        end;
      run;

      proc sort data=_npctdsall;
        by &highlvl &midlvl &lowlvl;
      run;


      %if "&debug" EQ "Y" %then %do;
      %end;
      %else %do;
        proc datasets nolist;
          delete _npctmiss;
        run;
        quit;
      %end;
    %end;

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

  proc sort data=_npctdsin;
    by &highlvl &midlvl &lowlvl;
  run;

  %if %length(&dsall) and "&dsallonly" EQ "Y" %then %do;
    data _npctdsin;
      merge _npctdsall(in=_all) _npctdsin(in=_data);
      by &highlvl &midlvl &lowlvl;
      if _all and _data;
    run;
  %end;

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
      $ 256; *-was 200 -;
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
        $ 256; *-was 200 -;
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

  proc sql noprint;
    select max(_events) into: maxev separated by " " from _npctevmidlvl;
  quit;
  %if &nevlen LT %length(&maxev) %then %let nevlen=%length(&maxev);
 
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

  proc sql noprint;
    select max(_count) into: maxcnt separated by " " from _npctmidlvl;
  quit;
  %if &nlen LT %length(&maxcnt) %then %let nlen=%length(&maxcnt);

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
  *- (and dsall) dataset here. -;

  data _npctlowlvl;
    set _npctmidlvl(drop=_midlvlord _midlvlevord)
        _npctlowlvl;
    _lowlvlord=1/_count;
  run;

  %if %length(&dsall) %then %do;
    data _npctdsall;
      set _npctmidlvl(drop=_midlvlord _midlvlevord)
      _npctdsall;
    run;
  %end;


  *- sort ready for a merge with zero values -;
  proc sort data=_npctlowlvl;
    by &trtvar &byvars &highlvlord &newhighlvl 
       &midlvlord &newmidlvl &lowlvlord &newlowlvl;
  run;



      /*-----------------------------*
             Create a zero grid
       *-----------------------------*/

  %if %length(&dsall) %then %do;
    %zerogrid(zerovar=_count,dsout=_zerogrid,
    var1=&trtvar,ds1=&dspop,
    %if %length(&byvars) %then %do;
      var2=&byvars,ds2=_npctlowlvl,
    %end;
    var3=&highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl,
    ds3=_npctdsall)
  %end;
  %else %do;
    %zerogrid(zerovar=_count,dsout=_zerogrid,
    var1=&trtvar,ds1=&dspop,
    var2=&byvars &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl,
    ds2=_npctlowlvl)
  %end;

  *- add extra required variables -;
  data _zerogrid;
    retain _events 0 _lowlvlord _lowlvlevord 99;
    set _zerogrid;
  run;



      /*-----------------------------*
         Merge on top of zero values
       *-----------------------------*/

  data _npctlowlvl;
    merge _zerogrid _npctlowlvl;
    by &trtvar &byvars &highlvlord &newhighlvl 
       &midlvlord &newmidlvl &lowlvlord &newlowlvl;
  run;



      /*-----------------------------*
            Work out some lengths
       *-----------------------------*/

  %if not %length(&nlen) %then %let nlen=3;
  %if not %length(&nevlen) %then %let nevlen=&nlen;
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

  %*- set default lengths for widths -;
  %do i=1 %to 19;
    %if not %length(&&trtw&i) %then %do;
      %let var=%scan(&_trtvarlist_,&i,%str( ));
      %let cwidth=%scan(&cwidths,&i,%str( ));
      %let fwidth=%scan(&fwidths,&i,%str( ));
      %let trtw&i=&strlen;
      %if &cwidth GT &&trtw&i %then %let trtw&i=&cwidth;
      %if %length(&pcttrt) and not %index(%quotelst(%upcase(&pcttrtlist)),"%upcase(&var)") %then %do;
        %let trtw&i=&nlen;
        %if &fwidth GT &&trtw&i %then %let trtw&i=&fwidth;
      %end;
    %end;
  %end;


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
        put "WAR" "NING: (npcttab) _pct GT 100.01 " (_all_) (=);
      %end;
      %if "&events" EQ "Y" %then %do;
        %if "&pctsign" EQ "Y" %then %do;
          %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
            %if "&npctord" EQ "P" %then %do;
              _str=&pctaction||"% ("||put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||") "||put(_events,&nevlen..);
            %end;
            %else %do;
              _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||" ("||&pctaction||"%) "||put(_events,&nevlen..);
            %end;
          %end;
          %else %do;
            %if "&npctord" EQ "P" %then %do;
              _str=&pctaction||"% ("||put(_count,&nlen..)||") "||put(_events,&nevlen..);
            %end;
            %else %do;
              _str=put(_count,&nlen..)||" ("||&pctaction||"%) "||put(_events,&nevlen..);
            %end;
          %end;
        %end;
        %else %do;
          %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
            %if "&npctord" EQ "P" %then %do;
              _str=&pctaction||" ("||put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||") "||put(_events,&nevlen..);
            %end;
            %else %do;
              _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||" ("||&pctaction||") "||put(_events,&nevlen..);
            %end;
          %end;
          %else %do;
            %if "&npctord" EQ "P" %then %do;
              _str=&pctaction||" ("||put(_count,&nlen..)||") "||put(_events,&nevlen..);
            %end;
            %else %do;
              _str=put(_count,&nlen..)||" ("||&pctaction||") "||put(_events,&nevlen..);
            %end;
          %end;
        %end;
      %end;
      %else %do;
        %if %length(&pcttrt) %then %do;
          %if "&pctsign" EQ "Y" %then %do;
            %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
              %if "&npctord" EQ "P" %then %do;
                if &trtvar in (&pcttrt) then _str=&pctaction||" ("||put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||")";
              %end;
              %else %do;
                if &trtvar in (&pcttrt) then _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||" ("||&pctaction||"%)";
              %end;
            %end;
            %else %do;
              %if "&npctord" EQ "P" %then %do;
                if &trtvar in (&pcttrt) then _str=&pctaction||" ("||put(_count,&nlen..)||")";
              %end;
              %else %do;
                if &trtvar in (&pcttrt) then _str=put(_count,&nlen..)||"("||&pctaction||"%)";
              %end;
            %end;
            else _str=put(_count,&nlen..);
          %end;
          %else %do;
            %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
              %if "&npctord" EQ "P" %then %do;
                if &trtvar in (&pcttrt) then _str=&pctaction||" ("||put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||")";
              %end;
              %else %do;
                if &trtvar in (&pcttrt) then _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||" ("||&pctaction||")";
              %end;
            %end;
            %else %do;
              %if "&npctord" EQ "P" %then %do;
                if &trtvar in (&pcttrt) then _str=&pctaction||" ("||put(_count,&nlen..)||")";
              %end;
              %else %do;
                if &trtvar in (&pcttrt) then _str=put(_count,&nlen..)||"("||&pctaction||")";
              %end;
            %end;
            else _str=put(_count,&nlen..);
          %end;
        %end;
        %else %do;
          %if "&pctsign" EQ "Y" %then %do;
            %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
              %if "&npctord" EQ "P" %then %do;
                _str=&pctaction||"% ("||put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||")";
              %end;
              %else %do;
                _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||" ("||&pctaction||"%)";
              %end;
            %end;
            %else %do;
              %if "&npctord" EQ "P" %then %do;
                _str=&pctaction||"% ("||put(_count,&nlen..)||")";
              %end;
              %else %do;
                _str=put(_count,&nlen..)||" ("||&pctaction||"%)";
              %end;
            %end;
          %end;
          %else %do;
            %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
              %if "&npctord" EQ "P" %then %do;
                _str=&pctaction||" ("||put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||")";
              %end;
              %else %do;
                _str=put(_count,&nlen..)||' / '||trim(left(put(_total,8.)))||" ("||&pctaction||")";
              %end;
            %end;
            %else %do;
              %if "&npctord" EQ "P" %then %do;
                _str=&pctaction||" ("||put(_count,&nlen..)||")";
              %end;
              %else %do;
                _str=put(_count,&nlen..)||" ("||&pctaction||")";
              %end;
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
  run;

  *- transpose _pct -;
  proc transpose prefix=_PCT data=_npctlowlvl out=_npctpct(drop=_name_);
    by &byvars &highlvlord &newhighlvl &midlvlord 
       &newmidlvl &lowlvlord &newlowlvl ;
    var _pct;
    id &trtvar;
  run;


  *- transpose _events -;
  proc transpose prefix=_EVE data=_npctlowlvl out=_npcteve(drop=_name_);
    by &byvars &highlvlord &newhighlvl &midlvlord 
       &newmidlvl &lowlvlord &newlowlvl ;
    var _events;
    id &trtvar;
  run;

  *- Merge the transposed datasets back together -;
  *- and add the pvalue dataset (if created).    -;
  data &dsout;
    merge _npctstr _npctcnt _npctpct _npcteve &pvalds;
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

    proc sort data=&dsout;
      by &byvars &newhighlvl &newmidlvl;
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
    proc sort nodupkey data=&dsout(keep=&byvars &newhighlvl &newmidlvl &newlowlvl)
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

    proc sort data=&dsout;
      by &byvars &highlvlord &newhighlvl &newmidlvl;
    run;

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

    proc sort data=&dsout;
      by &byvars &highlvlord &newhighlvl &midlvlord &newmidlvl &newlowlvl;
    run;

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



     /*-----------------------------------------*
              Manipulate output dataset 
      *-----------------------------------------*/

    %*-- apply filter code if any --;
    %if %length(&filtercode) %then %do;
      data &dsout;
        set &dsout;
        %unquote(%qdequote(&filtercode));
      run;
    %end;


    %*- call external data manipulation macro if set -;
    %if %length(&extmacro) %then %do;
      %&extmacro;
    %end;



     /*-----------------------------------------*
            Call titles and footnotes macro
      *-----------------------------------------*/


  %*- call titles and footnotes macro if set -;
  %if %length(&tfmacro) %then %do;
    %&tfmacro;
  %end;



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

  %if &style NE 3 %then %let rest=%eval(&ls-&trtwidth-&indentlow-&indentmid);
  %else %let rest=%eval(&ls-&trtwidth);

  %if %length(&byrowvar) %then %let rest=%eval(&rest-&byroww-2);
  %if %length(&byrow2var) %then %let rest=%eval(&rest-&byrow2w-2);

  %if &lowlvlw=0 %then %let lowlvlw=&rest;
  %else %if &rest LT &lowlvlw %then %let lowlvlw=&rest;

  %if &style3w=0 %then %let style3w=&rest;
  %else %if &rest LT &style3w %then %let style3w=&rest;


  %*- report width below is only meaningful and correct for style=1 and style=3 output -;
  %if &style NE 3 %then %let repwidth=%eval(&lowlvlw+&trtwidth+&indentlow+&indentmid);
  %else %let repwidth=%eval(&trtwidth+&style3w);


  %if &center EQ NOCENTER %then %let startcol=1;
  %else %let startcol=%eval((&ls-&repwidth)/2 + 1);

  %put NOTE: (npcttab) ls=&ls repwidth=&repwidth startcol=&startcol;
  %put;

  %if %length(&outputwidthpct) %then %do;
    %if %upcase(%substr(&outputwidthpct,1,1)) EQ C 
       %then %let outputwidthpct=%eval(&repwidth*1/1);
  %end;

  %if %sysevalf(&outputwidthpct GT 100) %then %let outputwidthpct=100;

  %put NOTE: (npcttab) outputwidthpct=&outputwidthpct% of available width;



          /*---------------------------------*
                Set some variable lengths
           *---------------------------------*/

  proc sort data=&dsout;
    by &byvars &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl;
  run;


  *- midlvl variable can not be longer than the report width -;
  data &dsout;
    retain _page 1;
    %if &style EQ 3 %then %do;
      length _combtxt _combtext2 $ 256; *-was %eval(&ls-&trtwidth) -;
    %end;
    length &_trtvarlist_ 
      %if "&total" EQ "Y" %then %do;
        &_trttotvar_ 
      %end;
      $ &strlen
      %if "&pvalues" EQ "Y" %then %do;
        &pvalstr $ 8
      %end;
    ;
    retain _indent '        ';
    set &dsout;
    by &byvars &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl;
    %if &style EQ 3 %then %do;
      if &newlowlvl=&anylowlvl then do;
        _combtxt=&newmidlvl;
        _combtext2=_combtxt;
      end;
      else do;
        _combtxt =repeat(" ",&indentlow-1)||&newlowlvl;
        _combtext2=repeat("A0"x,&indentlow*2.5-1)||&newlowlvl;
      end;
      %if %length(&highlvl) %then %do;
        _combtxt=repeat(" ",&indentlow-1)||_combtxt;
        _combtext2=repeat("A0"x,&indentlow*2.5-1)||_combtext2;
      %end;
      %splitvar(_combtxt,_combtext,&style3w,split=&split,hindent=&hindent,usecolon=&usecolon);
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
    %if %length(&pageon) %then %do;
      if first.%scan(&suppvars,1) and %scan(&suppvars,1) in: (&pageon) then _page=_page+1;
    %end;
  run;

  %if &style EQ 3 and %length(&highlvl) %then %do;

    data &dsout;
      set &dsout;
      by &byvars &highlvlord &newhighlvl &midlvlord &newmidlvl &lowlvlord &newlowlvl;
      array _trt &_trtpref_:;
      if first.&newhighlvl then do;
        output;
        _combtxt=&newhighlvl;
        _combtext2=&newhighlvl;
        link splitvar;
        _primord=_primord-0.001;
        do over _trt;
          _trt=" ";
        end;
        output;
      end;
      else output;
      return;
      splitvar:
        %splitvar(_combtxt,_combtext,&style3w,split=&split,hindent=&hindent,usecolon=&usecolon);
      return;
    run;
  %end;


             /*-----------------------------------------*
                       Define "proc report" macro
              *-----------------------------------------*/

  %macro _npctrep(topline=,trtlabel=,combtext=_combtext,PDF=N,compskip=);

    proc report nowd missing headline &headskip split="&split" spacing=&spacing &spanrows data=&dsout

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
               
    ;

      %if %length(&byvars) %then %do;
        by &byvars;
      %end; 
 
      columns
      %if "&topline" EQ "Y" %then %do;
        ( "___" " "
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
        &combtext
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

        style(COLUMN)=[cellwidth=%eval(52*(&indentlow+&indentmid)/&repwidth)% ]
       ;

      %end;

      define _primord / order order=internal noprint;

      define &lowlvlord / order order=internal noprint;

      %if "&eventsort" EQ "Y" %then %do;
        define _lowlvlevord / order=internal noprint;
      %end;


      %if &style NE 3 %then %do;

        define &newlowlvl / order spacing=0 width=&lowlvlw flow

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

     /**   style(COLUMN)=[cellwidth=%eval(100*(&lowlvlw)/&repwidth)% ]   **/

      ;

      %end;

      %else %do;

        define &combtext / order
        %if not %length(&byrowvar) %then %do;
          spacing=0
        %end;
        %else %do;
          spacing=2
        %end;
    
        width=&style3w flow

        %if %length(&style3lbl) %then %do;
          &style3lbl
        %end;
        %else %do;
          " "
        %end;
        style(COLUMN)={asis=&asis font_face=&font_face_other font_weight=&font_weight_other}
        ;

      %end;

  
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
      %end;
      %if %length(&pvalstr) %then %do;
        define &pvalstr / &pvallbl width=&pvalcolw center display spacing=&trtspace
        %if %length(&outputwidthpct) %then %do;
          %if &PDF NE Y %then %do;
            style(COLUMN)=[cellwidth=%eval(45*(&pvalcolw+&trtspace)/&repwidth)% ]
          %end;
        %end;
        ;
      %end;

      %if &indentmid gt 0 and &style ne 3 %then %do;
        compute before &newhighlvl;
          line @&startcol &highlvl $char400.;
        endcomp;
      %end;

      %if &indentlow gt 0 and &style ne 3 %then %do;
        compute before &newmidlvl;
          line @%eval(&startcol+&indentmid) &midlvl $char400.;
        endcomp;
      %end;

      %if &midskip EQ Y %then %do;
        %if &compskip EQ Y %then %do;
          compute &compskippos &newmidlvl;
            line " ";
          endcomp;
        %end;
        %else %do;
          break after &newmidlvl / skip;
        %end;
      %end;

      %if &highskip EQ Y %then %do;
        %if &compskip EQ Y %then %do;
          compute after &newhighlvl;
            line " ";
          endcomp;
        %end;
        %else %do;
          break after &newhighlvl / skip;
        %end;
      %end;

      %if "&double" EQ "Y" %then %do;
        %if &compskip EQ Y %then %do;
          compute after &newlowlvl;
            line " ";
          endcomp;
        %end;
        %else %do;
          break after &newlowlvl / skip;
        %end;
      %end;

      %if %length(&pagevar) %then %do;
        break &pgbrkpos &pagevar / page;
      %end;

      %if "&pageline" EQ "Y" or %length(&pageline1.&pageline2.&pageline3.&pageline4) 
        or %length(&pagemacro) %then %do;
        compute after &pagevar2;
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

  %mend _npctrep;



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

  %if "&print" EQ "Y" %then %do;
    %_npctrep(topline=&topline,trtlabel=&trtlabel,compskip=N);
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

    %*- strip start and trailing single quotes of prerepcode if present -;
    %if %length(&odsprerepcode) %then %do;
      %if %qsubstr(&odsprerepcode,1,1) EQ %str(%') 
       and %qsubstr(&odsprerepcode,%length(&odsprerepcode),1) EQ %str(%')
        %then %do;
%unquote(%qsubstr(&odsprerepcode,2,%length(&odsprerepcode)-2))
        %end;
      %else %do;
&odsprerepcode
      %end;
    %end;


    %if %length(&odspdf) %then %do;
      ods pdf &odspdf;
      %_npctrep(topline=N,trtlabel=&odstrtlabel,combtext=_combtext2,PDF=Y,compskip=&compskip);
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


    %_npctrep(topline=N,trtlabel=&odstrtlabel,combtext=_combtext2,compskip=&compskip);


    %*- strip start and trailing single quotes of postrepcode if present -;
    %if %length(&odspostrepcode) %then %do;
      %if %qsubstr(&odspostrepcode,1,1) EQ %str(%') 
       and %qsubstr(&odspostrepcode,%length(&odspostrepcode),1) EQ %str(%')
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

    %if %length(&odsother) %then %do;
      ods %scan(&odsother,1,%str( )) close;
    %end;

  %end;



    /*-----------------------------*
             Tidy up and exit
     *-----------------------------*/

  ods listing;

  %if "&debug" EQ "Y" %then %do;
  %end;
  %else %do;
    proc datasets nolist;
      delete _npctdsin _npcthighlvl _npctmidlvl _npctlowlvl 
             _npctstr _npctcnt _npctpct _npcteve &pvalds
        _npctevhighlvl _npctevmidlvl _npctevlowlvl _zerogrid

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
  %exit: %put &err: (npcttab) Leaving macro due to problem(s) listed;
  %skip:

  %delmac(\_npct:);

  options &savopts;

%mend npcttab;
