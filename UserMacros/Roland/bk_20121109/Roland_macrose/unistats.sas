/*<pre><b>
/ Program      : unistats.sas
/ Version      : 6.12
/ Author       : Roland Rashleigh-Berry
/ Date         : 02-Jun-2008
/ Purpose      : Clinical reporting macro to calculate proc univariate
/                statistics and category counts with percentages with optional
/                pvalues and optionally print a report.
/ SubMacros    : %unimap %words %fmtord %vartype %varfmt %unipvals %quotelst
/                %zerogrid %allfmtvals %unicatrep %varlen %dequote %verifyb
/                %quotecnt %quotescan %noquotes %unicat2word %sortedby %match
/                %nodup %attrc %eqsuff (assumes %popfmt already run)
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
/                The values for nfmt=, stdfmt=, minfmt=, maxfmt= and meanfmt=
/                have to be set to keep decimal point alignment the same.
/                In this way, if nfmt=3. then meanfmt=5.1 (a length of 5) for
/                the extra decimal point and decimal place. Note that meanfmt
/                is the default format for all stats values without a known
/                format and not just the mean.
/
/                The formats nfmt=, minfmt= etc. will be applied to all numeric
/                variables. To adjust them individually (compared to these
/                settings) you can end the variable with /+1 (no spaces) to add
/                one decimal place to all values (has no effect on nfmt=) or
/                /-1 to substract one decimal place. /+2 will add two decimal
/                places etc.. If you ask for statistics name transposed data then
/                no adjustment will be done as only one format can be applied.
/                It only works for treatment arm transposed data and the maximum
/                length allowed for any format is the length of catnfmt= plus 8.
/                An additional "m" in the decimal place adjust will make the min
/                and max values use the same format as mean.
/
/                A global macro variable _statkeys_ is created that maps the
/                labels supplied to stats= to their resulting variable names.
/
/                You can request output datasets from this macro. The contents
/                of these datasets are described below.
/
/                These are the variables in the dsout= dataset (stats)
/                -----------------------------------------------------
/                &byvars: whatever you defined to the byvars= parameter
/                &trtvar: whatever you defined to the trtvar= parameter
/                _page: Will be all 1 unless variables have been assigned to the
/                       page1/2/..vars= parameters
/                _varord: A sequence number for the variables defined to varlist=
/                _vartype: "C" or "N" depending whether the variable is numeric
/                         or categorical. Note that numeric variables can be
/                         categorical depending on the assigned format.
/                _varname: The name of the variable
/                _varlabel: The label of the variable.
/                _dpadj:   Decimal point adjustment
/                _minmaxadj: Make decimal points of min and max the same as mean
/                _statord: A sequence number for the statistic (or category).
/                          If catn= has a value then the sequence number for it
/                          will be 0.5
/                _statname: The name of the statistic (or category value)
/                _statlabel: The label of the statistic (or category). For stats
/                         this will be as you defined it for the stats= parameter.
/                _value: Value of the statistic (or count of the category)
/                _pct: Percentage for category (for stats it will be missing)
/                _dummy=0: Dummy variable you can use to "flatten" a proc report
/                          by declaring it "group noprint" after the "across"
/                          variables have followed other "group" variables.
/
/
/                These are the variables in the dspout= dataset (pvalues)
/                --------------------------------------------------------
/                &byvars: whatever you defined to the byvars= parameter
/                &trtvar=9999: or whatever value assing to ptrtval=
/                _page: Will be all 1 unless variables have been assigned to the
/                       page1/2/..vars= parameters
/                _varord: A sequence number for the variables defined to varlist=
/                _vartype: "C" or "N" depending whether the variable is numeric
/                         or categorical. Note that numeric variables can be
/                         categorical depending on the assigned format.
/                _varname: The name of the variable
/                _varlabel: The label of the variable.
/                _pvalue: p-value
/                _test: Test used CHISQ/FISHER/ANOVA
/                _statord=1 for categorical variables (or 0.5 if catn= is set)
/                           and for numeric variables it is the value
/                           corresponding to the MEAN statistic.
/                _statname: The name of the statistic (or category value)
/                _statlabel: The label of the statistic (or category). For stats
/                         this will be as you defined it for the stats= parameter
/                _dummy=0
/
/
/                These are the variables in the dstrantrt= dataset
/                       (treatment variable transposed data)
/                -------------------------------------------------
/                &byvars: whatever you defined to the byvars= parameter
/                _page: Will be all 1 unless variables have been assigned to the
/                       page1/2/..vars= parameters.
/                _varord: A sequence number for the variables defined to varlist=
/                _vartype: "C" or "N" depending whether the variable is numeric
/                         or categorical. Note that numeric variables can be
/                         categorical depending on the assigned format.
/                _varname: The name of the variable
/                _varlabel: The label of the variable
/                _dpadj:   Decimal point adjustment
/                _minmaxadj: Make decimal points of min and max the same as mean
/                _statord: A sequence number for the statistic (or category).
/                          If catn= has a value then the sequence number for it
/                          will be 0.5
/                _statname: The name of the statistic (or category value)
/                _statlabel: The label of the statistic (or category). For stats
/                         this will be as you defined it for the stats= parameter
/                _dummy=0
/                _indent='        '
/                TRT1, TRT2, TRT3, etc.: character formatted value(s) with
/                         variable names that are constructed using the prefix
/                         defined to tranpref= followed by actual treatment arm
/                         values.
/
/                Output order for the above dataset will be in the order
/                variables have been listed above.
/
/
/                These are the variables in the dstranstat= dataset
/                         (statistic name transposed data)
/                --------------------------------------------------
/                &byvars: whatever you defined to the byvars= parameter
/                &trtvar: whatever you defined to the trtvar= parameter
/                _page: Will be all 1 unless variables have been assigned to the
/                       page1/2/..vars= parameters.
/                _varord: A sequence number for the variables defined to varlist=
/                _vartype: "C" or "N" depending whether the variable is numeric
/                         or categorical. Note that numeric variables can be
/                         categorical depending on the assigned format.
/                _varname: The name of the variable
/                _varlabel: The label of the variable
/                _dpadj:   Decimal point adjustment
/                _minmaxadj: Make decimal points of min and max the same as mean
/                N, MIN, MEAN, MAX etc. or whatever you defined to the stats=
/                        parameter. Note that the variable names follow the
/                        proc univariate naming conventions which are as follows:
/                        N, MIN, MEAN, MAX, STD, P1, P5, P10, Q1, MEDIAN, Q3, P90,
/                        P95, P99 and the labels of these variables will be the
/                        actual strings supplied to the stats= parameter.
/
/                Output order for the above dataset will be in the order
/                variables have been listed above.
/
/ Usage        : %unistats(dsin=means,dsout=out,dspout=pout,trtvar=tmt,
/                varlist=val,stats=n mean min max std,pvarlist=val);
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Input dataset
/ varlist           Variables to calculate stats/category counts for. Decimal
/                   places can be adjusted by following the variable name with
/                   /+1 etc. (add 1 decimal place), /m (make mean, max and min
/                   have the same number of decimal places) and a variable label
/                   can be declared in the form var1="variable one". If you
/                   define variable labels then you must enclose the list in
/                   %str() so that the equals signs don't get confused with
/                   parameter assignments.
/ pvarlist          Variables to calculate pvalues for (must also be defined to
/                   varlist= )
/ pvalues=yes       This gets passed onto the %unicatrep macro to tell it
/                   whether to show a pvalues column or not if the variable
/                   exists in its input dataset.
/ nparvarlist       Variables that require a p-value based on a non-parametric
/                   test (must also be defined to varlist= and pvarlist=).
/ exactvarlist      Variables defined to nparvarlist= that require a p-value
/                   based on a non-parameteric exact test.
/ chisqvarlist      Categorical variables for the Chi-square test (must also be
/                   defined to varlist= and pvarlist=)
/ fishervarlist     Categorical variables for the Fisher's exact test (must also
/                   be defined to varlist= and pvarlist=)
/ pvaltrtlist       List of treatment arm values (separated by spaces) used for
/                   p-value calculation (defaults to not using the value
/                   assigned to _trttotstr_).
/ ptrtval=9999      Dummy additional treatment group to assign to the pvalue
/                   dataset.
/ npvalstat=MEAN    Statistic keyword to merge numeric pvalues with. Note that
/                   for merging with paired statistic labels then the first
/                   keyword should be used.
/ adjcntrvar        Variable representing the centre to be used in adjustment
/                   for centre effects in PROC GLM call. Only one variable
/                   allowed. Terms will be generated in the model statement
/                   for modelform=short as:
/                     model response=trtcd centre /ss1 ss2 ss3 ss4;
/                   or for modelform=long as:
/                     model response=trtcd centre trtcd*centre /ss1 ss2 ss3 ss4;
/                   You can use this parameter for a variable other than a
/                   centre but note that whatever variable you choose, if it is
/                   not a categorical or dichotomous variable suitable for use
/                   in the CLASS statement of a PROC GLM call then you will need
/                   to use the glmclass= parameter to supply the correct call.
/ cntrwarn=yes      By default, warn if a centre effect and/or centre-by-
/                   treatment effect is significant. For the short model as
/                   described for the adjcntrvar= parameter, use the centre term.
/                   For the long model, use the centre and centre-by-treatment
/                   effect term.
/ cntrcond=LE 0.05  Condition for significance to apply to the centre effect
/ intercond=LE 0.1  Condition for significance to apply to the treatment*centre
/                   interaction.
/ statsopdest         Default is not to write the glm output to any destination.
/                   You can set this to PRINT or a file such that PROC PRINTTO
/                   understands it. Note that setting it to LOG will not work.
/ errortype=3       Default is to select the error type 3 (Hypothesis type)
/                   treatment arm p-value from the ModelANOVA ODS dataset that
/                   is output from the GLM procedure.
/ modelform=short   Default is to generate the short form of the model statement
/                   as described in the adjcntrvar= parameter description.
/ dsmodelanova      Dataset to append the ModelANOVA datasets to generated by
/                   PROC GLM.
/ hovwarn=yes       Issue a warning message where the homogeneity of variances
/                   shows a significant difference. This will only be done for
/                   one-way ANOVA so if adjcntrvar= is set then the hov*=
/                   parameters will be ignored. A NOTE statement will be
/                   generated where appropriate if a warning is not issued.
/ hovcond=LE 0.05   Condition for meeting HoV significance
/ hovtest=Levene    HoV test to use. You can choose between OBRIEN, BF and
/                   Levene, Levene(type=square) and Levene(type=abs). Levene and
/                   Levene(type=square) are the same. The Bartlett test is not
/                   supported.
/ welch=no          By default, do not calculate ANOVA p-values using the Welch
/                   test for one-way ANOVA where the HoV condition for
/                   significance is met. If Welch is used then the hovtest
/                   defined to hovtest= will be employed in the MEANS statement.
/                   ---------------------------------------------------------
/                   For the following glm*= parameters it is possible to enclose
/                   your code in single quotes and then you can use &respvar 
/                   (the response variable) and &trtvar (the treatment variable)
/                   in your code without causing syntax errors.
/ glmclass          GLM CLASS statement used to override the generated form.
/                   The start word CLASS and ending semicolon will be generated.
/ glmmodel          GLM MODEL statement used to override the generated form.
/                   The start word MODEL and ending semicolon will be generated.
/ glmmeans          GLM MEANS statement used to override the generated form.
/                   The start word MEANS and ending semicolon will be generated.
/ glmweight         GLM WEIGHT statement that can be added as an extra. The
/                   start word WEIGHT and ending semicolon will be generated.
/ stats             List of stats labels separated by spaces (allows for
/                   footnote flags at end for unpaired statistics). These will
/                   be mapped to statistics keywords and if not possible an
/                   error message will be issued. You are allowed to pair stats
/                   labels such as "Mean(SD)" and in this case the values will
/                   be combined using the extra characters in the string as the
/                   delimiters. Although, for paired stats, no spaces are
/                   allowed, a space will be substituted for the "^" character
/                   to allow you to add spaces to improve layout. Although, for
/                   single statistics, an attempt is made to align all values
/                   with the decimal point, this can not be done for paired
/                   statistics. Note that for paired statistics you might have
/                   to choose a value for mincolw= to prevent truncation of the
/                   second displayed value or you could increase the length of
/                   the format assigned to catnfmt= . This is explained in the
/                   notes below.
/ trtvar            Treatment arm variable (defaults to &_trtvar_ set up in the
/                   %popfmt macro but must be set if %popfmt not called) which
/                   must be a coded numeric variable or a short coded character
/                   variable (typically one or two bytes with no spaces).
/ trtfmt            Treatment arm format (defaults to &_trtfmt_ set up in the
/                   %popfmt macro but must be set if %popfmt not called).
/ total=no          By default, do not show total for all treatment arms
/ byvars            By variable(s)
/ dsout=_unistats   Output dataset (no modifiers - defaults to _unistats). If
/                   you rename this then do not use an underscore prefix
/                   otherwise it could be deleted.
/ dspout=_pvalues   P-value output dataset name (no modifiers - defaults to
/                   _pvalues)
/ dstrantrt         Dataset name for treatment arm transposed data
/                   (no modifiers).
/ dstranstat        Dataset name for statistic transposed data (no modifiers)
/ unicatrep=no      By default, do not produce a report for treatment arm
/                   transposed data.
/ print=yes         This is passed on to %unicatrep and if set to "no" (no
/                   quotes) the .lst output will be suppressed. This is in
/                   case you just want ODS output.
/ unicatstyle=1     Style to use for the %unicatrep macro. 1=indented
/                   2=separate columns.
/ varw=12           Width of variable label column for unicatstyle=2
/ unistatrep=no     By default, do not produce a report for statistic name
/                   transposed data (REPORT NOT AVAILABLE YET).
/ spantotal=yes     For when unicatrep is called, trtlabel spans the total
/                   column as well, if there.
/ tranpref=TRT      Prefix for transposed treatment arm variable names
/ missing=yes       By default, display counts of categorical values that are
/                   missing using what is defined to misstxt= as the name.
/ misstxt=Not Recorded     Text for missing categoricals
/ misspct=no        By default, do not calculate and show percentages for
/                   missing value categories. If set to "no" (the default)
/                   then p-values will not be based on the missing category
/                   count. For these missing values to not feature in the
/                   percentage values for non-missing categories, use 
/                   pctcalc=cat so that the percentage is based on the non-
/                   missing category count.
/ nopctcatlist      Extra categories to exclude from the percentage calculation
/                   and p-value calculations. The items should be quoted and
/                   separated by spaces. Item text should match the case before
/                   any lowercasing is done by this macro.
/ catn              By default, do not show the "N" category count. Set this to
/                   "n", "N" or "n(missing)" (not quoted) to activate it. Note
/                   that if a left round bracket is detected then the number of
/                   missing values will be shown in round brackets following
/                   the "n" count. Although free text is allowed, the second
/                   part of the expression will be shown as the number of
/                   missing values. No other statistic is possible.
/ varordadd=0       Optional number to add to _varord sequence values. You
/                   would only use this if you were making multiple calls to
/                   %unistats and bringing together the output datasets.
/                   -----------------------------------------------------
/                   Note that the following three parameters determine the
/                   minimum width of the columns for when %unicatrep is called,
/                   although you can override this by setting mincolw= .
/                   The minimum width of the column is the length of the 
/                   catnfmt plus the pctfmt plus 3 (plus 1 if pctsign=yes).
/                   If you are using paired stats labels then you can either
/                   set mincolw= to a suitable value or increase the catnfmt
/                   format length to avoid columns for the paired stats being
/                   truncated.
/ catnfmt=3.        Format for category counts for tranposed data
/ pctfmt=5.1        By default, use the 5.1 format to display percentages. You
/                   must give this format a length for a user format.
/ pctsign=no        By default, do not show the percent sign for percentages
/                   --------------------------------------------------------
/                   Note that you would normally set nfmt= to the same as 
/                   catfmt= and make sure the other formats that follow it
/                   match such that the number of digits to the left of the
/                   decimal point matches that for nfmt= .
/ nfmt=3.           Format for N statistic for tranposed data
/ stdfmt=6.2        Format for STD statistic for tranposed data
/ minfmt=5.1        Format for MIN statistic for tranposed data
/ maxfmt=5.1        Format for MAX statistic for tranposed data
/ meanfmt=5.1       Format for MEAN statistic and ALL OTHER statistics for
/                   tranposed data.
/ pvalfmt=p63val.   Default format (created inside this macro) for p-value
/                   statistic for tranposed data (6.3 unless <0.001 or >0.999)
/ pvalmisstxt=" n/a"  (quoted) Used in the internal p63val. format for assigning
/                   a string when the p-value has a missing value.
/ pvalids=yes       By default, attach p-value ids to the end of p-values as per
/                   the list defined below.
/ fisherid=^        Symbol to suffix formatted p-values for the Fisher exact
/                   test.
/ chisqid=~         Symbol to suffix formatted p-values for the Chi-square test
/ cmhid=$           Symbol to suffix formatted p-values for the CMH test
/ anovaid=#         Symbol to suffix formatted p-values for the ANOVA
/ nparid=°          Symbol to suffix formatted p-values for the non-parametric
/                   Kruskal-Wallis test (or Wilcoxon rank sum test).
/                   ----------------------------------------------------------
/                   The following parameters allow you to control page breaks
/                   so that you can keep blocks of stats together. Suppose you
/                   were showing age race and sex and sex got its stats split
/                   part on page one and the rest on page two then you could
/                   specify "page1vars=age race, page2vars=sex," and so force
/                   all the sex stats onto page two.
/ page1vars         Page 1 marked variables for a future print
/ page2vars         Page 2 marked variables for a future print
/ page3vars         Page 3 marked variables for a future print
/ page4vars         Page 4 marked variables for a future print
/ page5vars         Page 5 marked variables for a future print
/ page6vars         Page 6 marked variables for a future print
/ page7vars         Page 7 marked variables for a future print
/ page8vars         Page 8 marked variables for a future print
/ page9vars         Page 9 marked variables for a future print
/ catlabel=" "      For a print the default is for no category column label
/ varlabel=" "      For a print the default is for no variable column label
/ catw              By default this macro will assign a category column width
/                   to meet the page width.
/ trtlabel          Label for combined category counts and stats
/ topline=no        Default is not to show a line at the top of the report. This
/                   is the best setting for ODS RTF tables and the like.
/ pageline=no       Default is not to show a line under the report on each page
/ pageline1-9       Additional lines (in quotes) to show at the bottom of each
/                   page.
/ endline=no        Default is not to show a line under the end of the report.
/                   This is the best setting for ODS RTF tables and the like.
/ endline1-9        Additional lines (in quotes) to show at end of report
/ pgbrkpos=before   Page break position defaults to before. This will allow
/                   the endline1-9 to be put after the last item is displayed.
/                   If set to "after" (no quotes) then endline1-9 will be forced
/                   onto a new page.
/ trtspace=4        Default spaces to leave between treatment arm columns
/ trtw1-9           Widths for each treatment column. If left blank then this
/                   will be calculated for you.
/ indent=4          Spaces to indent categories for report
/ split=@           Split character (no quotes) for proc report if requested
/ pctcalc=pop       By default, category percentages are calculated on the basis
/                   of treatment arm population. This can be changed to "cat"
/                   (no quotes) to calculate percentages based on total category
/                   counts.
/ allcatvars        List of variables (separated by spaces) for which all
/                   categories belonging to a format are displayed.
/ allcat=no         By default, do not show all the possible format values
/                   for categorical variables. If set to yes then this
/                   overrides the allcatvars= setting.
/ lowcasevarlist    For categorical variables, make sure the second character
/                   onwards are displayed as lower case.
/ dpalign=yes       Default is to align the decimal point for descriptive
/                   statistics using the "A0"x character (non-breaking space).
/                   Set this to "no" (no quotes) to disable this action.
/ pctwarn=yes       By default, put out a warning message if a percentage is
/                   greater than 100.01
/ out               Named output dataset from proc report if required when
/                   %unicatrep macro is called.
/ wordtabdest       Destination for a Word-type table of cell values to copy and
/                   paste into Word and turn into a table. This only works for
/                   where you have treatment columns like %unicatrep reports.
/                   Note that you can use the odsrtf= parameter to give you RTF
/                   tables suitable for inclusion into Word documents. RTF
/                   tables can easily be manipulated and edited by word
/                   processors.
/ wordtabdlim=';'   Delimiter to use for Word-type table of cell values (must be
/                   quoted).
/ odsrtf            Give the "file='filename' style=style" (unquoted) to create
/                   RTF output. This will be passed to the %unicatrep macro.
/                   "ods rtf   ;" and "ods rtf close;" will be automatically
/                   generated. If you want to suppress the plain text output
/                   then use the setting print=no. Use of topline=no (the
/                   default) is advised if producing non-listing ODS output.
/ odshtml           Works the same way as odsrtf
/ odshtmlcss        Works the same way as odsrtf
/ odscsv            Works the same way as odsrtf
/ odspdf            Works the same way as odsrtf
/ odslisting        Allows you to specify a file= statement to pass through to
/                   the %unicatrep macro.
/ odsother          Works the same way as odsrtf but you have to supply the
/                   destination word as the first word.
/ tfmacro           Name of macro (no % sign) containing titles and footnotes
/                   settings to be enacted near the end of the macro if set and
/                   will typically be used to include calculated p-values in
/                   footnotes such as _pvalue1_ , _pvalue2_ etc. Use pvalues=no
/                   to suppress the pvalues column in %unicatrep output if you
/                   are displaying all the pvalues in footnotes.
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
/ nbspaces=no       By default, do not translate normal spaces to non-breaking
/                   spaces. Setting it to "yes" (no quotes) can be useful for
/                   maintaining alignment and forcing excel to treat cell
/                   contents as text. This will be applied to stats output only.
/                   To apply to other variables, use filtercode= and translate
/                   spaces to "A0"x in the code you supply.
/ compskip=no       (no quotes) By default, do not use a compute block for line
/                   skips. Set this to "yes" only for non-paging ODS output such
/                   as html so that you get an effect like "break after / skip"
/                   showing blank lines in the output. Never set to "yes" for
/                   paginated output.
/ compskippos=before  When to throw the line skips
/ byrowfirst=no     (no quotes) Default is not to display the variable declared
/                   to byrowvar= as the first column when %unicatrep called.
/ mincolw           Minimum width of the treatment columns. If you are using
/                   paired stats then you can set this to a value to avoid
/                   truncation.
/ trtvarlist        You should not need to use this except in special situations
/                   where you want to specify labels to go with the transposed 
/                   treatment variables in the proc report call at the end of
/                   the %unicatrep macro such as in this example:
/              trtvarlist=("__ DRUG 1 __" TRT1 TRT2) ("__ DRUG 2 __" TRT3 TRT4)
/                   You need to know what treatment variables there are and
/                   this will be put in the log by the %popfmt macro. If you
/                   are specifying column widths (usually not required) then if
/                   you change the natural order of these TRT variables then the
/                   trtw(n)= value that acts on a variable is the one that you
/                   would use if the natural order had not been changed.
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
/ addnpct=no        By default, do not add a string to the end of a categorical
/                   variable label that indicates that the statistics are of the
/                   "n (%)" type. Note that if all the variables are categorical
/                   variables it is best to signify this in a title or add it
/                   using the freesuff= parameter of the %popfmt macro.
/ addnpctstr=", n (%)"    (quoted) String to add to the trimmed end of a
/                   categorical variable label to indicate that the statistics
/                   are of the "n (%)" type.
/ filtercode        SAS code you specify to drop observations and do minor
/                   reformatting before %unicatrep is called. If this code
/                   contains commas then enclose in quotes (the quotes will be
/                   dropped from the start and end before the code is executed).
/                   Using this parameter might be easier than deferring the call
/                   to %unicatrep and editing the dataset before calling
/                   %unicatrep but for serious editing you should use the latter
/                   method.
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
/ rrb  12Jul05         v1.1 - parameters spantotal, breakvar, breakpos and
/                      pageline2-5 added.
/ rrb  13Jul05         v2.0 allcatvars= and allcat= parameters added so that all
/                      categories belonging to a format are displayed for these
/                      variables.
/ rrb  09Jan06         v3.0 ability to adjust decimal places for numeric
/                      variables added and numeric p-values have a _statord
/                      value corresponding to the _statord of the MEAN.
/ rrb  24Jan06         Parameters nparvarlist=, chisqvarlist=, fishervarlist=
/                      added to define type of p-value to calculate for listed
/                      variables and pvatrtrlist= added so that treatment arm
/                      values for the p-value calculation can be specified.
/ rrb  25Jan06         Global macro variables _pvalue1_ etc. set up to contain
/                      pvalues.
/ rrb  30Jan06         lowcasevarlist= added and additional "m" allowed in
/                      decimal places adjust to make min amd max the same format
/                      as mean.
/ rrb  03Feb06         Default trtvar=
/ rrb  04May06 RRB001  Make pvartrtlist= default setting dependent on whether
/                      pvarlist is set and put note in for trtfmt= to say it
/                      must be set if %popfmt not called.
/ rrb  04May06         Only plug gaps with zeroes if treatment arm population
/                      not zero.
/ rrb  04May06         Logic of plugging gaps with zeroes altered to use local
/                      macro variable "plug".
/ rrb  07Jul06         Bug fix for catn=N processing plus some header tidies
/ rrb  10Jul06         misspct=yes bug fixed.
/ rrb  11Jul06 RRB002  _statord=1 set to get pvalues to merge with other data.
/ rrb  14Jul06         More header tidies
/ rrb  22Jul06         Do not lowercase _statlabel if set to "&misstxt"
/ rrb  26Aug06         v 3.1 has nopctcatlist= added so that no percentages are
/                      calculated for these categories nor p-values.
/ rrb  23Sep06         v 3.2 has pvalmisstxt=" n/a" added
/ rrb  09Oct06 RRB003  Problem with missing fmtord. format fixed and minor
/                      change to definition of p63val format.
/ rrb  13Feb07         "macro called" message added
/ rrb  12Mar07         Default now pctcalc=pop rather than pctcalc=cat (v3.3)
/ rrb  19Mar07         Add dpalign=yes parameter so that this action can be
/                      disabled if required.
/ rrb  20Mar07         Handling of character trtvar corrected (v3.5)
/ rrb  21Mar07         Add STDMEAN handling and fix pvalue merge bug for
/                      categorical variables (v3.6)
/ rrb  23Mar07         catnfmt= parameter can now have a format longer than
/                      three characters (v4.0)
/ rrb  24Mar07         Use "A0"x instead of "FE"x for the decimal point 
/                      alignment character (v4.1)
/ rrb  25Mar07         _strlen_ set up to keep the string length for transposed
/                      treatment variables for %unicatrep deferred calls (v4.2)
/ rrb  02May07         pctsign=no parameter added to allow users to force the
/                      display of the percent sign for category percentages if
/                      required.
/ rrb  16May07         pctfmt=5.1 parameter added to allow users to change the
/                      percent format.
/ rrb  17May07         Further checking of pctfmt= value added (v4.5)
/ rrb  28May07         Allow the variable list to have variable labels attached
/                      in the form var1="variable one" and apply these labels
/                      to the output dataset. If followed by /n then the
/                      variable will be treated as numeric for numeric
/                      variables with a user format applied (v4.6)
/ rrb  30Jul07         Header tidy
/ rrb  01Sep07         pctwarn=yes parameter added
/ rrb  16Sep07         Added out= parameter to name the kept dataset created by
/                      proc report to pass through to the %unicatrep macro, if
/                      called.
/ rrb  16Sep07         wordtabdest= and wordtabdlim= parameters added
/ rrb  18Sep07         unicatstyle= , varw= and odsrtf= parameters added
/ rrb  19Sep07         odshtml= and odspdf= parameters added
/ rrb  21Sep07         odsother= parameter added
/ rrb  23Sep07         Header tidy
/ rrb  24Sep07         tfmacro= and pvalues=yes parameters added
/ rrb  30Sep07         topline=no is now the default which is better suited to
/                      ODS output.
/ rrb  30Dec07         Delete _unidsin dataset just before creating new one and
/                      fixed bug with _popfmt_ incorrectly assigned as a label
/                      when trtfmt= set to otherwise.
/ rrb  30Dec07         Use nfmt as a format for the NMISS statistic
/ rrb  31Dec07         Mapping of statistic labels to keywords and formats is
/                      displayed in log as a "note" statement. Keywords that
/                      start with "STD" will have the stdfmt= format applied.
/ rrb  31Dec07         Bug fixed with NMISS format when decimal points adjusted
/ rrb  05Jan08         Decimal point alignment bug in "fillstr:" routine fixed
/ rrb  06Jan08         New parameters adjcntrvar= and statsopdest= added for pass
/                      through to %unipvals for adjustment for centre effects.
/ rrb  06Jan08         Added errortype= , modelform= and dsmodelanova= for
/                      pass-through to %unipvals for adjustment for centre
/                      effects.
/ rrb  07Jan08         hovwarn=, hovcond=, hovtest= amd welch= added for pass-
/                      through to %unipvals to test and warn for homogeneity of
/                      variances significant difference for one-way ANOVA and to
/                      calculate using Welch test. welchid=§ added in this macro
/                      to give a symbol to a Welch p-value.
/ rrb  08Jan08         Added cntrwarn=, cntrcond= and cntrerrtype= for pass-
/                      through to %unipvals for centre effect warning.
/ rrb  08Jan08         cntrerrtype= removed. cntrcond= value changed and 
/                      intercond=0.1 added.
/ rrb  13Jan08         dsmodelanova= dataset now deleted using proc datasets.
/                      ftestid= replaced by anovaid=. cntrwarn= processing
/                      changed.
/ rrb  13Jan08         Added cmhid= and support for the CMH test
/ rrb  14Jan08         glmclass=, glmmodel=, glmmeans= and glmweight= added so
/                      the user can override the statements generated by the
/                      %unipvals macro for the main glm call.
/ rrb  19Jan08         Added a note on use of glm*= parameters
/ rrb  19Jan08         Keep all variables in input dataset and pass all
/                      variables to %unipvals.
/ rrb  20Jan08         Decimal places adjusted for a number of statistics
/                      keywords.
/ rrb  26Jan08         Bug fixed with character format being like $3. in %cat
/ rrb  02Feb08         v5.0 allows for paired stats= words like "Mean(SD)" and
/                      enhances the catn= value so that the number of missing
/                      values can be shown. trtlabel= now defaults to null.
/                      pvalids=yes added to allow suppression of all p-value ids
/                      in the output. odshtmlcss= and odscsv= parameters added.
/                      print=yes parameter added for pass-through to %unicatrep.
/                      pluggaps= parameter added. byrow*= and compskip=
/                      parameters added for pass-through to %unicatrep.
/                      nbspaces= added to allow all spaces to be changed to non-
/                      breaking spaces so that html output does not drop leading
/                      spaces and convert multiple spaces to single spaces.
/ rrb  03Feb08         More byrow*= parameters added
/ rrb  09Feb08         compskip=no is now the default plus explanation of how to
/                      increase column length for when paired stats are used has
/                      been added to the header.
/ rrb  10Feb08         mincolw= parameter added
/ rrb  15Feb08         "^" now translated into a space when used in a delimiter
/                      for paired stats. A space no longer automatically added
/                      before a "(" and after a ";".
/ rrb  17Feb08         Added comments in header for page1vars= etc. parameters
/ rrb  23Feb08         byvars= generated where this is null but byrow*=
/                      parameters used.
/ rrb  24Feb08         Numeric pvalue stat defined to npvalstat= is merged on
/                      the first stat of a paired stat.
/ rrb  11Mar08         misspct= explanation updated in header
/ rrb  13Mar08         Mispelling of SKEWNESS corrected in code
/ rrb  15Mar08         odslisting= parameter added
/ rrb  17Mar08         byrowfirst= parameter added and breakvar= and breakpos=
/                      parameters removed.
/ rrb  19Mar08         trtvarlist= parameter added
/ rrb  20Mar08         Where paired stats are both missing then show as blank
/                      and not show delimiters.
/ rrb  25Mar08         If first of paired stats is "N" and this is missing but 
/                      second of pair is not missing then show "N" as "0".
/ rrb  25Mar08         For variables defined with a negative adjustment for
/                      decimal places then the processing has changed such
/                      that the min, max and sum can show zero decimal points in
/                      addition to the variables that are counts (N, NMISS etc.)
/                      but all other statistics must show at least one decimal
/                      point.
/ rrb  23Apr08         Header changed to indicate that this macro is no longer
/                      supported for free users (v6.0)
/ rrb  30Apr08         dsdenom= and denomshow= parameters added and glmopdest=
/                      replaced by statsopdest= .
/ rrb  07May08         filtercode= parameter added
/ rrb  09May08         font_face_stats= and font_face_other= parameter added
/ rrb  09May08         report_border=, header_border=, column_border=, rules=
/                      cellspacing= and lines_border= parameters added.
/ rrb  11May08         compskippos=, cellpadding= and outputwidthpct= parameters
/                      added.
/ rrb  11May08         foreground and background parameters added
/ rrb  12May08         _ul and _ol parameters added
/ rrb  12May08         byvars2= parameter added for %unipvals call
/ rrb  13May08         font_style_other= and font_weight_stats parameters added
/ rrb  14May08         font_weight_stats= default changed to bold and 
/                      outputwidthpct= default changed to calc.
/ rrb  18May08         compskip_ul= compskippx= compskipcol= parameters added
/ rrb  21May08         addnpct= and addnpctstr= parameters added
/ rrb  02Jun08         spanrows= parameter added
/===============================================================================
/ No guarantee as to the suitability or accuracy of this code is given or
/ implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: unistats v6.12;

%macro unistats(dsin=,
             varlist=,
            pvarlist=,
             pvalues=yes,
         nparvarlist=,
        exactvarlist=,
        chisqvarlist=,
       fishervarlist=,
         pvaltrtlist=,
             ptrtval=9999,
           npvalstat=MEAN,
          adjcntrvar=,
            cntrwarn=yes,
            cntrcond=LE 0.05,
           intercond=LE 0.1,
         statsopdest=,
           errortype=3,
           modelform=short,
        dsmodelanova=,
             hovwarn=yes,
             hovcond=LE 0.05,
             hovtest=Levene,
               welch=no,
            glmclass=,
            glmmodel=,
            glmmeans=,
           glmweight=,
               stats=,
              trtvar=,
              trtfmt=,
               total=no,
              byvars=,
               dsout=_unistats,
              dspout=_pvalues,
           dstrantrt=,
          dstranstat=,
           unicatrep=no,
               print=yes,
         unicatstyle=1,
                varw=12,
          unistatrep=no,
           spantotal=yes,
            tranpref=TRT,
             missing=yes,
             misstxt=Not Recorded,
             misspct=no,
        nopctcatlist=,
                catn=,
           varordadd=0,
             catnfmt=3.,
                nfmt=3.,
              stdfmt=6.2,
              minfmt=5.1,
              maxfmt=5.1,
             meanfmt=5.1,
              pctfmt=5.1,
             pvalfmt=p63val.,
         pvalmisstxt=" n/a",
             pvalids=yes,
            fisherid=^,
             chisqid=~,
             anovaid=#,
               cmhid=$,
             welchid=§,
              nparid=°,
           page1vars=,
           page2vars=,
           page3vars=,
           page4vars=,
           page5vars=,
           page6vars=,
           page7vars=,
           page8vars=,
           page9vars=,
            catlabel=" ",
            varlabel=" ",
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
             pctcalc=pop,
          allcatvars=,
              allcat=no,
      lowcasevarlist=,
             dpalign=yes,
             pctsign=no,
             pctwarn=yes,
                 out=,
         wordtabdest=,
         wordtabdlim=';',
              odsrtf=,
             odshtml=,
          odshtmlcss=,
              odscsv=,
              odspdf=,
          odslisting=,
            odsother=,
             tfmacro=,
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
            pluggaps=yes,
            nbspaces=no,
            compskip=no,
         compskippos=after,
          byrowfirst=no,
             mincolw=,
          trtvarlist=,
          filtercode=,
             dsdenom=,
           denomshow=yes,
             addnpct=no,
          addnpctstr=", n (%)",
            spanrows=yes,
     font_face_stats=Courier,
   font_weight_stats=bold,
     font_face_other=Times,
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
        compskip_ul=no,
         compskippx=1,
        compskipcol=black
               );

%local i error j pg allvars var usefmtord fmt ls trtvartype libname memname plug
       trtformat statfmts stat dpadj minmaxadj lowcase varlist2 usetest exact
       strlen pctnfmt varlist3 varlist4 varlist5 forcenum denomsortvars;

%global _statkeys_ _strlen_;
%let _statkeys_=;

%global _misstxt_;
%let _misstxt_=&misstxt;

%*- we need this to get round the "BY-line truncated" bug in "proc univariate" -;
%let ls=%sysfunc(getoption(linesize));


             /*-----------------------------------------*
                  Check we have enough parameters set
              *-----------------------------------------*/

%let error=0;

%if not %length(&mincolw) %then %let mincolw=0;

%if not %length(&addnpct) %then %let addnpct=no;
%let addnpct=%upcase(%substr(&addnpct,1,1));

%if %length(&dsdenom) %then %let denomsortvars=%sortedby(&dsdenom);

%if not %length(&denomshow) %then %let denomshow=yes;
%let denomshow=%upcase(%substr(&denomshow,1,1));

%if not %length(&pluggaps) %then %let pluggaps=yes;
%let pluggaps=%upcase(%substr(&pluggaps,1,1));

%if not %length(&nbspaces) %then %let nbspaces=no;
%let nbspaces=%upcase(%substr(&nbspaces,1,1));

%if not %length(&pctsign) %then %let pctsign=no;
%let pctsign=%upcase(%substr(&pctsign,1,1));

%if not %length(&pctwarn) %then %let pctwarn=yes;
%let pctwarn=%upcase(%substr(&pctwarn,1,1));

%if "&pctwarn" EQ "N" %then %do;
  %put WARNING: (unistats) Percent > 100.01 checks disabled;
%end;

%if not %length(&pctfmt) %then %let pctfmt=5.1;
%let pctnfmt=%substr(&pctfmt,%verifyb(&pctfmt,0123456789.)+1);


%if not %length(&pctnfmt) or not %index(&pctnfmt,.) %then %do;
  %let error=1;
  %put ERROR: (unistats) Format supplied to pctfmt=&pctfmt not valid;
%end;
%else %if "%substr(&pctnfmt,1,1)" EQ "." %then %do;
  %let error=1;
  %put ERROR: (unistats) No format length supplied to pctfmt=&pctfmt;
%end;


%if not %length(&pctcalc) %then %let pctcalc=pop;
%let pctcalc=%upcase(&pctcalc);

%if "&pctcalc" NE "CAT" and "&pctcalc" NE "POP" %then %do;
  %let error=1;
  %put ERROR: (unistats) You have pctcalc=&pctcalc but only CAT or POP are allowed;
%end;

%if not %length(&unicatrep) %then %let unicatrep=no;
%let unicatrep=%upcase(%substr(&unicatrep,1,1));

%if ("&unicatrep" EQ "Y" or %length(&wordtabdest))
  and not %length(&dstrantrt) %then %let dstrantrt=_unitran;

%if "&unistatrep" EQ "Y" and not %length(&dstranstat)
  %then %let dstrantrt=_unitranstat;

%if not %length(&minfmt) %then %let minfmt=&maxfmt;

%if not %length(&dsin) %then %do;
  %let error=1;
  %put ERROR: (unistats) No input dataset assigned to dsin=;
%end;

%if not %length(&varlist) %then %do;
  %let error=1;
  %put ERROR: (unistats) No variable list assigned to varlist=;
%end;
%else %do;
  %*- set varlist3 to varlist but with labels and equals signs removed -;
  %let varlist3=%sysfunc(compress(%noquotes(%str(&varlist)),=));
  %*- set up varlist2 without decimal point adjust -;
  %let varlist2=;
  %do i=1 %to %words(&varlist3);
    %if %length(&pvarlist) %then %do;
      %global _pvalue&i._;
      %let _pvalue&i._=;
    %end;
    %let var=%scan(&varlist3,&i,%str( ));
    %*- drop the decimal point modifier if there is one -;
    %let varlist2=&varlist2 %scan(&var,1,/);
  %end;
  %if not %length(&page1vars) %then %do;
    %let page1vars=&varlist2;
    %let page2vars=;
    %let page3vars=;
    %let page4vars=;
    %let page5vars=;
    %let page6vars=;
    %let page7vars=;
    %let page8vars=;
    %let page9vars=;
  %end;
%end;


%if not %length(&dsout) %then %do;
  %let error=1;
  %put ERROR: (unistats) No output dataset assigned to dsout=;
%end;

%if not %length(&trtvar) %then %do;
  %let trtvar=&_trtvar_;
  %put NOTE: (unistats) Defaulting trtvar=&trtvar;
%end;

%if not %length(&total) %then %let total=no;
%let total=%upcase(%substr(&total,1,1));

%if not %length(&misstxt) %then %let misstxt=Not Recorded;

%if not %length(&missing) %then %let missing=yes;
%let missing=%upcase(%substr(&missing,1,1));

%if not %length(&misspct) %then %let misspct=no;
%let misspct=%upcase(%substr(&misspct,1,1));

%if not %length(&allcat) %then %let allcat=no;
%let allcat=%upcase(%substr(&allcat,1,1));

%if "&missing" EQ "N" %then %let misspct=N;

%if not %length(&varordadd) %then %let varordadd=0;

%if %length(&pvarlist) %then %do;  /* RRB001 */
  %if not %length(&pvaltrtlist) %then %let pvaltrtlist=ne &_trttotstr_;
  %else %let pvaltrtlist=in (&pvaltrtlist);
%end;

%if not %length(&trtfmt) %then %let trtfmt=&_popfmt_;

%if not %length(&dpalign) %then %let dpalign=yes;
%let dpalign=%upcase(%substr(&dpalign,1,1));

%if not %length(&pvalids) %then %let pvalids=yes;
%let pvalids=%upcase(%substr(&pvalids,1,1));


%if &error %then %goto error;


%*- set varlist4 to varlist but with the labels removed -;
%if %quotecnt(&varlist) %then %do;
  %let varlist4=%noquotes(%str(&varlist));
  %*- set varlist5 to the variables with labels defined -;
  %let varlist5=;
  %do i=1 %to %words(&varlist4);
    %let var=%scan(&varlist4,&i,%str( ));
    %let var=%scan(&var,1,/);
    %if "%substr(&var,%length(&var),1)" EQ "="
      %then %let varlist5=&varlist5 %substr(&var,1,%length(&var)-1);
  %end;
  %if %words(&varlist5) NE %quotecnt(&varlist) %then %do;
    %let error=1;
    %put ERROR: (unistats) Number of variable labels=%quotecnt(&varlist) does not;
    %put ERROR: (unistats) match with variable count with labels=%words(&varlist5);
    %put ERROR: (unistats) for varlist=&varlist;
  %end;
%end;


%*----- work out the category display length -----;
%if not %length(&catnfmt) %then %let catnfmt=3.;
%*- add 3 for the space and round brackets -;
%let strlen=%eval(%scan(&catnfmt,1,.)+3);
%*- add the length of the percent format -;
%let strlen=%eval(&strlen+%scan(&pctnfmt,1,.));
%*- if displaying percent sign then add 1 to the length -;
%if "&pctsign" EQ "Y" %then %let strlen=%eval(&strlen+1);
%*- if displaying denominator then add more -;
%if %length(&dsdenom) and "&denomshow" EQ "Y" 
  %then %let strlen=%eval(&strlen+%scan(&catnfmt,1,.)+3);
%if &strlen LE &mincolw %then %let strlen=&mincolw;
%let _strlen_=&strlen;


%*- make sure the ModelANOVA append dataset is deleted -;
%if %length(&dsmodelanova) %then %do;
  %if %sysfunc(exist(&dsmodelanova)) %then %do;
    proc datasets nolist
      %if %index(&dsmodelanova,.) %then %do;
        lib=%scan(&dsmodelanova,1,.)
      %end;
      ;
      delete %scan(&dsmodelanova,-1,.);
    run;
    quit;
  %end;
%end;

             /*-----------------------------------------*
                    Check stat labels map to keywords
              *-----------------------------------------*/

%if %length(&stats) %then %do;
  %let _statkeys_=%unimap(&stats);
  %if not %length(&_statkeys_) %then %goto error;
  %put NOTE: (unistats) The following labels defined to stats: &stats;
  %put NOTE: (unistats) were mapped to the following keywords: &_statkeys_;
%end;


             /*-----------------------------------------*
                  Pair stats keywords to their format
              *-----------------------------------------*/

%let statfmts=;
%if %length(&stats) %then %do;
  %do i=1 %to %words(&_statkeys_);
    %let stat=%scan(&_statkeys_,&i,%str( ));
    %let statfmts=&statfmts &stat;
    %if "&stat" EQ "N" %then %let statfmts=&statfmts &nfmt;
    %else %if "&stat" EQ "NMISS" %then %let statfmts=&statfmts &nfmt;
    %else %if "&stat" EQ "NOBS" %then %let statfmts=&statfmts &nfmt;
    %else %if %index(&stat,STD) EQ 1 %then %let statfmts=&statfmts &stdfmt;
    %else %if "&stat" EQ "KURTOSIS" %then %let statfmts=&statfmts &stdfmt;
    %else %if "&stat" EQ "SKEWNESS" %then %let statfmts=&statfmts &stdfmt;
    %else %if "&stat" EQ "MIN" %then %let statfmts=&statfmts &minfmt;
    %else %if "&stat" EQ "MAX" %then %let statfmts=&statfmts &maxfmt;
    %else %if "&stat" EQ "SUM" %then %let statfmts=&statfmts &maxfmt;
    %else %let statfmts=&statfmts &meanfmt;
  %end;
  %put NOTE: (unistats) and have been assigned formats as follows: &statfmts;
%end;


             /*-----------------------------------------*
                    Check all variables are present
              *-----------------------------------------*/


%if not %length(&byvars) %then %let byvars=&byroword &byrowvar &byrow2ord &byrow2var;

%let allvars=&trtvar &byvars &adjcntrvar &varlist2;


%*- delete _unidsin dataset if it exists -;
%if %sysfunc(exist(_unidsin)) %then %do;
  proc datasets nolist;
    delete _unidsin;
  run;
  quit;
%end;


*- this data step in case input dataset has attached clauses -;
data _unidsin;
  set &dsin;
  %if %length(&trtfmt) %then %do;
    format &trtvar &trtfmt ;
  %end;
run;


%*- generate total for all treatment arms if requested -;
%if "&total" EQ "Y" %then %do;
  data _unidsin;
    set _unidsin;
    output;
    &trtvar=&_trttotstr_;
    output;
  run;
%end;


%*- check all variables are in input dataset -;
%do i=1 %to %words(&allvars);
  %let var=%scan(&allvars,&i,%str( ));
  %if not %varnum(_unidsin,&var) %then %do;
    %let error=1;
    %put ERROR: (unistats) Variable "&var" not in input dataset;
  %end;
%end;

%if &error %then %goto error;


%*- if any variables labels found then apply to dataset -;
%if %quotecnt(&varlist) %then %do;
  *- can not use "proc datasets" due to weird label syntax -;
  data _unidsin;
    set _unidsin;
    label
    %do i=1 %to %words(&varlist5);
      %let var=%scan(&varlist5,&i,%str( ));
      &var=%unquote(%quotescan(%str(&varlist),&i))
    %end;
    ;
  run;
%end;


%*- store the treatment variable type (C/N) -;
%let trtvartype=%vartype(_unidsin,&trtvar);

%*- store the treatment format -;
%let trtformat=%varfmt(_unidsin,&trtvar);



     /*===========================================================*
      *===========================================================*
             Define macro to process CATegorical variables
      *===========================================================*
      *===========================================================*/

%macro cat(var,varnum,page,lowcase);

  %local allfmtvals fmt varlen sortord;

  %let allfmtvals=N;
  %if %index(%quotelst(%upcase(&allcatvars)),"%upcase(&var)")
      or "&allcat" EQ "Y" %then %let allfmtvals=Y;

  %let fmt=%varfmt(_unidsin,&var);
  %if not %length(%sysfunc(compress(&fmt,$1234567890.))) %then %do;
    %let fmt=;
    %let allfmtvals=N;
  %end;

  %let varlen=%varlen(_unidsin,&var,nodollar);

  %if "%vartype(_unidsin,&var)" EQ "C" %then %do;
    %if "%substr(&fmt%str(     ),1,5)" EQ "$CHAR"
     or not %length(%sysfunc(compress(&fmt,$123456789.)))
     %then %let usefmtord=0;
  %end;

  %if %length(&fmt) %then %do;
    %fmtord(&fmt);
  %end;

  data _unistatc;
    length _statname $ 160
           _varname $ 32
           _varlabel $ 80
           _dpadj $ 2
           _minmaxadj $ 1
           ;
    retain _page &page _varord %eval(&varnum+&varordadd) _vartype "C"
           _varname "&var" _dpadj " " _minmaxadj " ";
    set _unidsin;
    _varlabel=vlabel(&var);
    %if "&addnpct" EQ "Y" %then %do;
      _varlabel=trim(_varlabel)||&addnpctstr;
    %end;
    _fmt=vformat(&var);
    _vtype=vtype(&var);
    if _fmt ne ' ' then do;
      if _vtype='C' then do;
        if &var NE ' ' then _statname=putc(&var,_fmt);
        else _statname="&misstxt";
      end;
      else do;
        if &var NE . then _statname=putn(&var,_fmt);
        else _statname="&misstxt";
      end;
    end;
    else _statname=&var;
  run;


  %*- if this is one of the pvalue variables then process -;
  %if %index(%quotelst(%upcase(&pvarlist)),"%upcase(&var)") %then %do;
    data __pin;
      set _unistatc(where=(1=1
           %if "&missing" EQ "Y" and "&misspct" EQ "N" %then %do;
             and _statname not in ("&misstxt" &nopctcatlist)
           %end;
           ));
    run;
    %let usetest=;
    %if %index(%quotelst(%upcase(&chisqvarlist)),"%upcase(&var)")
      %then %let usetest=C;
    %else %if %index(%quotelst(%upcase(&fishervarlist)),"%upcase(&var)")
      %then %let usetest=F;
    %unipvals(dsin=__pin(where=(&trtvar &pvaltrtlist)),
            dsout=__pout,trtvar=&trtvar,respvar=&var,type=C,usetest=&usetest,
            adjcntrvar=&adjcntrvar,statsopdest=&statsopdest,errortype=&errortype,
            modelform=&modelform,dsmodelanova=&dsmodelanova,
            hovwarn=&hovwarn,hovcond=&hovcond,hovtest=&hovtest,welch=&welch,
            cntrwarn=&cntrwarn,cntrcond=&cntrcond,intercond=&intercond,
            byvars=&byvars,byvars2=_page _varord _vartype _varname _varlabel _dpadj _minmaxadj);

    proc append base=&dspout data=__pout;
    run;
    proc datasets nolist;
      delete __pin __pout;
    run;
    quit;
  %end;


  *- count of non-missing values -;
  proc summary nway missing data=_unistatc
    %if "&misspct" EQ "N" %then %do;
      (where=(_statname not in ("&misstxt" &nopctcatlist)))
    %end;
    ;
    class &byvars &trtvar;
    id _page _varord _vartype _varname _varlabel;
    output out=_unistatt(drop=_type_ rename=(_freq_=_total));
  run;


  *- count of missing values -;
  proc summary nway missing data=_unistatc
    %if "&misspct" EQ "N" %then %do;
      (where=(_statname EQ "&misstxt"))
    %end;
    ;
    class &byvars &trtvar;
    id _page _varord _vartype _varname _varlabel;
    output out=_unistatm(drop=_type_ rename=(_freq_=_pct));
  run;


  %if &pctcalc EQ CAT %then %let sortord=&byvars &trtvar;
  %else %if &pctcalc EQ POP %then %let sortord=&trtvar &byvars;


  proc summary nway missing data=_unistatc;
    class &sortord _statname;
    id _page _varord _vartype _varname _varlabel _dpadj _minmaxadj;
    output out=_unistatc(drop=_type_ rename=(_freq_=_value));
  run;


  %if "&allfmtvals" EQ "Y" %then %do;

    %allfmtvals(var=&var,length=&varlen,fmt=&fmt,dsout=_uniallfmt,decodevar=_statname,decodelen=160)
    %zerogrid(dsout=_unizero,var1=&sortord _page _varord _vartype _varname _varlabel _dpadj _minmaxadj,
              ds1=_unistatc,var2=_statname,ds2=_uniallfmt,zerovar=_value)

    data _unistatc;
      merge _unizero _unistatc;
      by &sortord _statname;
    run;

    proc datasets nolist;
      delete _unizero _uniallfmt;
    run;
    quit;

  %end;



  %if %length(&dsdenom) %then %do;
    %if not %length(&denomsortvars) %then %do;
      %let denomsortvars=%match(%varlist(_unistatc),%varlist(&dsdenom));
      proc sort data=&dsdenom out=_unidenom;
        by &denomsortvars;
      run;
    %end;
    %else %do;
      data _unidenom;
        set &dsdenom;
      run;
    %end;
    proc sort data=_unistatc;
      by &denomsortvars;
    run;
  %end;



  data _unistatc;
    length _statlabel $ 160;
    retain _dummy 0;
    %if %length(&dsdenom) %then %do;
      merge _unidenom _unistatc;
      by &denomsortvars;
    %end;
    %else %if &pctcalc EQ CAT %then %do;
      merge _unistatt _unistatc;
      by &byvars &trtvar;
    %end;
    %else %if &pctcalc EQ POP %then %do;
      merge _popfmt _unistatc(in=_data);
      by &trtvar;
      if _data;
      format &trtvar &trtformat;
    %end;
    _statlabel=_statname;
    %if "&lowcase" EQ "Y" %then %do;
      if _statname NE "&misstxt" then
        _statlabel=substr(_statlabel,1,1)||lowcase(substr(_statlabel,2));
    %end;
    if _statname in ("&misstxt" &nopctcatlist) then do;
      if _statname EQ "&misstxt" then _statord=999;
      else do;
        %if %length(&fmt) %then %do;
          _statord=input(_statname,fmtord.);
        %end;
        %else %do;
          _statord=1; *- RRB003 -;
        %end;
      end;
      _pct=.;
      %if "&misspct" EQ "Y" %then %do;
        _pct=100*_value/_total;
        %if "&pctwarn" NE "N" %then %do;
        if _pct GT 100.01 then 
          put "WARNING: (unistats) _pct GT 100.01 " (_all_) (=);
        %end;
      %end;
    end;
    else do;
      %if %length(&fmt) %then %do;
        _statord=input(_statname,fmtord.);
      %end;
      %else %do;
        _statord=1; *- RRB002 -;
      %end;
      if _total in (.,0) then _pct=.;
      else _pct=100*_value/_total;
      %if "&pctwarn" NE "N" %then %do;
      if _pct GT 100.01 then 
        put "WARNING: (unistats) _pct GT 100.01 " (_all_) (=);
      %end;
    end;
  run;


  proc sort data=_unistatc;
    by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj _statord _statname;
  run;

  %if %length(&catn) %then %do;
    *- merge the missing count with the total count -;
    data _unistatt;
      merge _unistatt _unistatm;
      by &byvars &trtvar _page _varord _vartype _varname _varlabel;
      if _total=. then _total=0;
      if _pct=. then _pct=0;
    run;
    data _unistatt;
      length _statlabel _statname $ 160 _dpadj $ 2 _minmaxadj $ 1;
      retain _statord 0.5  _statname "N" _statlabel "&catn" _total .
            _dummy 0 _vartype "C" _dpadj " " _minmaxadj " ";
      set _unistatt(rename=(_total=_value));
    run;

    proc append base=&dsout data=_unistatt;
    run;
  %end;

  proc append base=&dsout data=_unistatc
  %if "&missing" EQ "N" %then %do;
    (where=(_statname ne "&misstxt"))
  %end;
  ;
  run;

  proc datasets nolist;
    delete _unistatc _unistatt _unistatm;
  run;
  quit;

%mend cat;



     /*===========================================================*
      *===========================================================*
               Define macro to process NUMeric variables
      *===========================================================*
      *===========================================================*/

%macro num(var,varnum,page,dpadj,minmaxadj);
  %local i ;

  data _unistatn;
    length _varlabel $ 80
           _varname $ 32
           _dpadj $ 2
           _minmaxadj $ 1
           ;
    retain _page &page _varord %eval(&varnum+&varordadd) _vartype "N"
    _varname "&var" _dpadj "&dpadj" _minmaxadj "&minmaxadj";
    set _unidsin;
    _varlabel=vlabel(&var);
  run;


  %*- if this is one of the pvalue variables then process -;
  %if %index(%quotelst(%upcase(&pvarlist)),"%upcase(&var)") %then %do;
    data __pin;
      set _unistatn;
    run;
    %let usetest=;
    %if %index(%quotelst(%upcase(&nparvarlist)),"%upcase(&var)")
      %then %let usetest=N; %*- N=non-parametric test -;
    %if %index(%quotelst(%upcase(&exactvarlist)),"%upcase(&var)")
      %then %let exact=yes;
    %unipvals(dsin=__pin(where=(&trtvar &pvaltrtlist)),
            dsout=__pout,trtvar=&trtvar,respvar=&var,type=N,usetest=&usetest,
            exact=&exact,adjcntrvar=&adjcntrvar,statsopdest=&statsopdest,
            errortype=&errortype,modelform=&modelform,dsmodelanova=&dsmodelanova,
            hovwarn=&hovwarn,hovcond=&hovcond,hovtest=&hovtest,welch=&welch,
            cntrwarn=&cntrwarn,cntrcond=&cntrcond,intercond=&intercond,
            glmclass=&glmclass,glmmodel=&glmmodel,glmmeans=&glmmeans,
            glmweight=&glmweight,
            byvars=&byvars,byvars2=_page _varord _vartype _varname _varlabel _dpadj _minmaxadj);
    proc append base=&dspout data=__pout;
    run;
    proc datasets nolist;
      delete __pin __pout;
    run;
    quit;
  %end;


  *- fix for "BYline truncated" bug is to set linesize to max -;
  options ls=max;

  proc univariate noprint data=_unistatn;
    by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj;
    var &var;
    output out=_unistatn
    %do i=1 %to %words(&_statkeys_);
      %scan(&_statkeys_,&i,%str( ))%str(=)%scan(&_statkeys_,&i,%str( ))
    %end;
    ;
  run;

  *- reset linesize -;
  options ls=&ls;

  proc transpose data=_unistatn out=_unistatn(drop=_label_
                                            rename=(col1=_value));
    by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj;
    var &_statkeys_;
  run;

  data _unistatn;
    retain _pct _total . _dummy 0;
    length _statname _statlabel $ 160;
    set _unistatn;
    _statname=_name_;
    _statlabel=put(_statname,$_statlb.);
    _statord=input(_statname,_stator.);
    drop _name_;
  run;

  proc sort data=_unistatn;
    by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj _statord _statname;
  run;

  proc append base=&dsout data=_unistatn;
  run;

  proc datasets nolist;
    delete _unistatn;
  run;
  quit;

%mend num;


             /*-----------------------------------------*
                        Create required formats
              *-----------------------------------------*/

proc format;
  value p63val
  low-<0.001="<0.001"
  0.999<-high=">0.999"
  .=&pvalmisstxt
  OTHER=[6.3]
  ;
  invalue _stator
  %do i=1 %to %words(&_statkeys_);
    "%scan(&_statkeys_,&i,%str( ))"=&i
  %end;
  ;
  value $_statlb
  %do i=1 %to %words(&_statkeys_);
    "%scan(&_statkeys_,&i,%str( ))"="%scan(&_statlabs_,&i,%str( ))"
  %end;
  ;
run;


             /*-----------------------------------------*
                      Start processing the data
              *-----------------------------------------*/


proc sort data=_unidsin;
  by &byvars &trtvar;
run;



*- get rid of the append base datasets if they exist -;
proc datasets nolist;
  delete &dsout
  %if %length(&pvarlist) %then %do;
    &dspout
  %end;
  ;
run;
quit;



%do i=1 %to %words(&varlist3);
  %let var=%scan(&varlist3,&i,%str( ));
  %*- see if it had a decimal point adjust added -;
  %let dpadj=%upcase(%scan(&var,2,/));
  %*- see if treat-as-numeric is being asked for -;
  %let forcenum=0;
  %if %index(&dpadj,N) GT 0 %then %do;
    %let forcenum=1;
    %let dpadj=%sysfunc(compress(&dpadj,N));
  %end;
  %if %index(&dpadj,M) GT 0 %then %do;
    %let minmaxadj=M;
    %let dpadj=%sysfunc(compress(&dpadj,M));
  %end;
  %else %let minmaxadj=;

  %if %length(&dpadj) %then %do;
    %if "%substr(&dpadj,1,1)" NE "+"
    and "%substr(&dpadj,1,1)" NE "-"
      %then %let dpadj=+&dpadj;
  %end;
  %*- drop decimal point adjust from variable name -;
  %let var=%scan(&var,1,/);
  %let pg=99;
  %do j=1 %to 9;
    %if %index(%quotelst(%upcase(&&page&j.vars)),"%upcase(&var)") %then %do;
      %let pg=&j;
      %let j=99;
    %end;
  %end;
  %if ("%vartype(_unidsin,&var)" EQ "C")
   or ("%vartype(_unidsin,&var)" EQ "N" and not &forcenum and
      ("%substr(%varfmt(_unidsin,&var)%str(    ),1,4)" NE "BEST"
      and %length(%sysfunc(compress(%varfmt(_unidsin,&var),0123456789.)))))
   %then %do;
     %let lowcase=N;
     %if %index(%quotelst(%upcase(&lowcasevarlist)),"%upcase(&var)") %then %let lowcase=Y;
     %cat(&var,&i,&pg,&lowcase);
   %end;
   %else %num(&var,&i,&pg,&dpadj,&minmaxadj);
%end;



             /*-----------------------------------------*
                   Add extra info to pvalues dataset
              *-----------------------------------------*/

%if %length(&pvarlist) %then %do;

  proc sort nodupkey data=&dsout(keep=&byvars _page _varord _varname _varlabel _vartype
                                      _dpadj _minmaxadj _statord _statname _statlabel _dummy)
                      out=_pvalextra;
    by &byvars _page _varord _varname _varlabel _dpadj _minmaxadj _statord;
  run;


  *- we need to include the lowest value of _statord for the categorical variables -;
  data _pvalstatord;
    set _pvalextra(where=(_vartype="C"));
    by &byvars _page _varord _varname _varlabel _dpadj _minmaxadj;
    if first._minmaxadj;
    drop _statname _statlabel _dummy;
  run;

  *- sort ready for a merge to add _statord for categorical variables -;
  proc sort data=&dspout;
    by &byvars _page _varord _varname _varlabel _dpadj _minmaxadj;
  run;

  *- merge the lowest _statord value in for categorical variables -;
  data &dspout;
    merge &dspout(in=_p) _pvalstatord;
    by &byvars _page _varord _varname _varlabel _dpadj _minmaxadj;
    if _p;
  run;

  *- for numeric variables match with "mean" if possible or set _statord=1 -; 
  data &dspout;
    retain &trtvar &ptrtval;
    set &dspout;
    if _vartype="N" then do;
      _statord=input("%upcase(&npvalstat)",_stator.);
      if _statord=. then _statord=1;
    end;
    format &trtvar &trtfmt;
  run;

  *- merge the extra variable in -;
  data &dspout;
    merge _pvalextra &dspout(in=_p);
    by &byvars _page _varord _varname _varlabel _dpadj _minmaxadj _statord;
    if _p;
  run;

  *- delete working datasets -;
  proc datasets nolist;
    delete _pvalextra _pvalstatord;
  run;
  quit;

%end;



             /*-----------------------------------------*
                            Final output sort
              *-----------------------------------------*/

proc sort data=&dsout;
  by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj _statord _statname _statlabel;
run;

%if %length(&pvarlist) %then %do;
  proc sort data=&dspout;
    by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj _statord _statname _statlabel;
  run;
%end;



         /*---------------------------------------------------*
             Transpose the unistats data using statistic name
          *---------------------------------------------------*/

%if %length(&dstranstat) %then %do;
  proc transpose data=&dsout out=&dstranstat(drop=_name_);
    by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj;
    var _value;
    id _statname;
    idlabel _statlabel;
  run;

  %let libname=%scan(&dstranstat,-2,.);
  %if not %length(&libname) %then %let libname=work;
  %let memname=%scan(&dstranstat,-1,.);

  *- assign the correct formats to the stats variables -;
  %if %length(&stats) %then %do;
    proc datasets nolist lib=&libname;
      modify &memname;
      format &statfmts;
    run;
    quit;
  %end;

%end;


         /*---------------------------------------------------*
             Transpose the unistats data using treatment arm
          *---------------------------------------------------*/

%if %length(&dstrantrt) %then %do;

  %if %length(&pvarlist) %then %do;
    *- format the p-values -;
    data __pval;
      length _pvalstr $ 8 _pvalmacvar $ &strlen _idlabel $ 120;
      set &dspout;
      _pvalmacvar="_pvalue"||compress(put(_varord,4.))||"_";
      _pvalstr=put(_pvalue,&pvalfmt);
      call symput(_pvalmacvar,trim(put(_pvalue,&pvalfmt)));
      %if "&pvalids" NE "N" %then %do;
        if _test="FISHER" then _pvalstr=trim(_pvalstr)||"&fisherid";
        else if _test="CHISQ" then _pvalstr=trim(_pvalstr)||"&chisqid";
        else if _test="CMH" then _pvalstr=trim(_pvalstr)||"&cmhid";
        else if _test="ANOVA" then _pvalstr=trim(_pvalstr)||"&anovaid";
        else if _test="WELCH" then _pvalstr=trim(_pvalstr)||"&welchid";
        else if _test="NPAR1WAY" then _pvalstr=trim(_pvalstr)||"&nparid";
      %end;
      _idlabel=put&trtvartype(&trtvar,vformat(&trtvar));
      drop _test _pvalue _pvalmacvar;
    run;
  %end;

  %if %length(&pvarlist) %then %do;
    %put MSG: (unistats) The following p-value global macro variables have;
    %put MSG: (unistats) been set up and can be resolved in your code.;
    %put MSG: (unistats) The index number corresponds to the _varord value.;
    %do i=1 %to %words(&varlist);
      %put _pvalue&i._=&&_pvalue&i._;
    %end;
    %put;
  %end;

  data &dstrantrt;
    length _idlabel $ 120 _tempfmt $ 4 _str $ &strlen
           ;
    set &dsout;
    if _vartype="C" then do;
      if (_statname in ("&misstxt" &nopctcatlist) and "&misspct" NE "Y")
        then _str=put(_value,&catnfmt);
      else if _statord=0.5 then do;
        if not index("&catn",'(') then _str=put(_value,&catnfmt);
        else _str=put(_value,&catnfmt)||' ('||trim(left(put(_pct,&catnfmt)))||')';
      end;
      else do;
       %if "&pctsign" EQ "Y" %then %do;
         %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
           _str=put(_value,&catnfmt)||' / '||trim(left(put(_total, 8.)))||" ("||put(_pct,&pctfmt)||'%)';
         %end;
         %else %do;
           _str=put(_value,&catnfmt)||' ('||put(_pct,&pctfmt)||'%)';
         %end;
       %end;
       %else %do;
         %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
           _str=put(_value,&catnfmt)||' / '||trim(left(put(_total, 8.)))||" ("||put(_pct,&pctfmt)||')';
         %end;
         %else %do;
           _str=put(_value,&catnfmt)||' ('||put(_pct,&pctfmt)||')';
         %end;
       %end;
      end;
    end;
    else if _vartype="N" then do;
      %if %length(&pvarlist) %then %do;
        if _pvalstr ne ' ' then _str=_pvalstr;
        else do;
      %end;
          if _dpadj=" " then do;
            if _statname="N" then _str=put(_value,&nfmt);
            else if _statname="NMISS" then _str=put(_value,&nfmt);
            else if _statname="NOBS" then _str=put(_value,&nfmt);
            else if _statname=:"STD" then _str=put(_value,&stdfmt);
            else if _statname="KURTOSIS" then _str=put(_value,&stdfmt);
            else if _statname="SKEWNESS" then _str=put(_value,&stdfmt);
            else if _statname="MIN" then do;
              if _minmaxadj NE "M" then _str=put(_value,&minfmt);
              else _str=put(_value,&meanfmt);
            end;
            else if _statname="MAX" then do;
              if _minmaxadj NE "M" then _str=put(_value,&maxfmt);
              else _str=put(_value,&meanfmt);
            end;
            else if _statname="SUM" then do;
              if _minmaxadj NE "M" then _str=put(_value,&maxfmt);
              else _str=put(_value,&meanfmt);
            end;
            else _str=put(_value,&meanfmt);
          end;
          else do;
            _tempadj=input(_dpadj,2.);
            if _statname="N" then _str=put(_value,&nfmt);
            else if _statname="NMISS" then _str=put(_value,&nfmt);
            else if _statname="NOBS" then _str=put(_value,&nfmt);
            else if _statname=:"STD" or _statname in ("KURTOSIS" "SKEWNESS") then do;
              _tempfmt="&stdfmt";
              link fillstr;
            end;
            else if _statname="MIN" then do;
              if _minmaxadj NE "M" then _tempfmt="&minfmt";
              else _tempfmt="&meanfmt";
              link fillstr;
            end;
            else if _statname="MAX" then do;
              if _minmaxadj NE "M" then _tempfmt="&maxfmt";
              else _tempfmt="&meanfmt";
              link fillstr;
            end;
            else if _statname="SUM" then do;
              if _minmaxadj NE "M" then _tempfmt="&maxfmt";
              else _tempfmt="&meanfmt";
              link fillstr;
            end;
            else do;
              _tempfmt="&meanfmt";
              link fillstr;
            end;
          end;
      %if %length(&pvarlist) %then %do;
        end;
      %end;
    end;
    %if &nbspaces EQ Y %then %do;
      _str=translate(_str,"A0"x," ");
    %end;
    %else %if &dpalign EQ Y %then %do;
      if substr(_str,&strlen,1)=' ' then substr(_str,&strlen,1)="A0"x;
    %end;
    _idlabel=put&trtvartype(&trtvar,vformat(&trtvar));
    return;
    fillstr:
      if input(scan(_tempfmt,2,"."),2.) not in (.,0) then do;
        if _tempadj GT 0 then _tempfmt=compress(put(input(scan(_tempfmt,1,"."),2.)+_tempadj,2.))||"."||compress(put(input(scan(_tempfmt,2,"."),2.)+_tempadj,2.));
        else do;
          if input(scan(_tempfmt,2,"."),2.)+_tempadj LE 0 then do;
            if _statname in ("MIN", "MAX", "SUM") then _tempfmt="&nfmt";
            else _tempfmt="&meanfmt";
          end;
          else _tempfmt=compress(put(input(scan(_tempfmt,1,"."),2.)+_tempadj,2.))||"."||compress(put(input(scan(_tempfmt,2,"."),2.)+_tempadj,2.));
        end;
      end;
      else do;
        if _tempadj GT 0 then _tempfmt=compress(put(input(scan(_tempfmt,1,"."),2.)+1+_tempadj,2.))||"."||compress(put(_tempadj,2.));
      end;
      _str=putn(_value,_tempfmt);
    return;
    drop _tempfmt _tempadj;
  run;


  *- sort and combine values for combined stats labels such as "Mean(SD)" -;
  proc sort data=&dstrantrt;
    by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj _statlabel _statord;
  run;

  data &dstrantrt;
    length _newstr _skelolabel $ &strlen 
           _delim1 _delim2 $ 4
           _holdstatname $ 160
           _holdstatord 8
           ;
    retain _newstr _holdstatname " " _holdstatord .;
    set &dstrantrt;
    by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj _statlabel;
    if first._statlabel and last._statlabel then output;
    else do;
      if first._statlabel then do;
        _newstr=left(translate(_str," ","A0"x));
        _holdstatname=_statname;
        _holdstatord=_statord;
      end;
      if last._statlabel and not first._statlabel then do;
        *- set "N" value to zero if this is missing -;
        if _holdstatname="N" and _newstr=" " then _newstr="0";
        _skelolabel=translate(upcase(_statlabel)," ","ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.");
        _delim1=left(scan(_skelolabel,1," "));
        _delim2=left(scan(_skelolabel,2," "));
        _str=translate(_str," ","A0"x);
        if not (_newstr=" " and _str=" ") then
          _str=trim(_newstr)||trim(_delim1)||trim(left(_str))||_delim2;
        else _str=" ";
        _statname=_holdstatname;
        _statord=_holdstatord;
        *- translate hat character to a space -;
        _str=translate(_str," ","^");
        _newstr=" ";
        output;
      end;
    end;
    drop _newstr _skelolabel _delim1 _delim2 _holdstatname _holdstatord;

  proc sort data=&dstrantrt;
    by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj _statord _statname _statlabel;
  run;



  data &dstrantrt;
    length _str $ &strlen;
    %if %length(&pvarlist) %then %do;
      merge __pval &dstrantrt;
      by &byvars &trtvar _page _varord _vartype _varname _varlabel _dpadj _minmaxadj _statord _statname _statlabel;
      if _pvalstr ne " " then _str=_pvalstr;
    %end;
    %else %do;
      set &dstrantrt;
    %end;
    *- translate hat character to a space -;
    if _vartype="N" then _statlabel=translate(_statlabel," ","^");
  run;



  *- sort ready for a transpose... -;
  proc sort data=&dstrantrt;
    by &byvars _page _varord _vartype _varname _varlabel _dpadj _minmaxadj _statord _statname _statlabel &trtvar;
  run;


  *- ...and then transpose -;
  proc transpose data=&dstrantrt prefix=&tranpref out=&dstrantrt(drop=_name_);
    by &byvars _page _varord _vartype _varname _varlabel _dpadj _minmaxadj _statord _statname _statlabel;
    var _str;
    id &trtvar;
    idlabel _idlabel;
    format &trtvar ;
  run;


  *- plug the gaps -;
  data &dstrantrt;
    length &_trtvarlist_ $ &strlen;
    retain _dummy 0 _indent '        ';
    set &dstrantrt;
    %if "&pluggaps" EQ "Y" %then %do;
      %do i=1 %to &_trtnum_;
        %*- only plug gaps for when a treatment arm has a non-zero population -;
        %if "%scan(&_trttotals_,&i,%str( ))" NE "0" %then %do;
          *- test if we have spaces in this treatment arm column -;
          if %scan(&_trtvarlist_,&i,%str( )) EQ " " then do;
            if _vartype="C" then do;
              if (_statname in (" " &nopctcatlist) or (_statname="&misstxt" and "&misspct" EQ "N")) then do;
                %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt);
              end;
              else if _statname="N" then do;
                *- for where you have a count combined with a missing count -;
                if scan(_statlabel,2) EQ " " then %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt);
                else %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt)||" (0)";
              end;
              else do;
                %if "&pctsign" EQ "Y" %then %do;
                  %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt)||" ("||put(0,&pctfmt)||"%)";
                %end;
                %else %do;
                  %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt)||" ("||put(0,&pctfmt)||")";
                %end;
              end;
              %if &nbspaces EQ Y %then %do;
                %scan(&_trtvarlist_,&i,%str( ))=translate(%scan(&_trtvarlist_,&i,%str( )),"A0"x," ");
              %end;
              %else %if &dpalign EQ Y %then %do;
                if substr(%scan(&_trtvarlist_,&i,%str( )),vlength(%scan(&_trtvarlist_,&i,%str( ))),1) EQ " "
                then substr(%scan(&_trtvarlist_,&i,%str( )),vlength(%scan(&_trtvarlist_,&i,%str( ))),1)="A0"x;
              %end;
            end;   /* end of _vartype="C" */
            else do; /* for _vartype="N" only plug the N or N(missing) value */
              if _statname="NMISS" and scan(_statlabel,2) NE " " then 
                %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt)||" (0)";
              else if _statname="N" then do;
                %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt);
                %if &nbspaces EQ Y %then %do;
                  %scan(&_trtvarlist_,&i,%str( ))=translate(%scan(&_trtvarlist_,&i,%str( )),"A0"x," ");
                %end;
                %else %if &dpalign EQ Y %then %do;
                  if substr(%scan(&_trtvarlist_,&i,%str( )),vlength(%scan(&_trtvarlist_,&i,%str( ))),1)=" "
                  then substr(%scan(&_trtvarlist_,&i,%str( )),vlength(%scan(&_trtvarlist_,&i,%str( ))),1)="A0"x;
                %end;
              end;
            end;
          end;
        %end;
      %end;
    %end;
    label
    %do i=1 %to &_trtnum_;
      %scan(&_trtvarlist_,&i,%str( ))="%sysfunc(put&trtvartype(%dequote(%scan(&_trtinlist_,&i,%str( ))),
        &trtfmt))"
    %end;
    ;
  run;


  %*-- apply filter code if any --;
  %if %length(&filtercode) %then %do;
    data &dstrantrt;
      set &dstrantrt;
      %dequote(&filtercode);
    run;
  %end;


  *- final sort -;
  proc sort data=&dstrantrt;
    by &byvars _page _varord _vartype _varname _varlabel _dpadj _minmaxadj
       _statord _statname _statlabel _dummy _indent;
  run;


  %if %length(&pvarlist) %then %do;
    proc datasets nolist;
      delete __pval;
    run;
    quit;
  %end;

%end;

             /*-----------------------------------------*
                Call titles and footnotes macro if set
              *-----------------------------------------*/

%if %length(&tfmacro) %then %do;
  %&tfmacro;
%end;


             /*-----------------------------------------*
                Call reporting macro if unicatrep is set
              *-----------------------------------------*/

%if "&unicatrep" EQ "Y" %then %do;

%unicatrep(dsin=&dstrantrt,byvars=&byvars,
catlabel=&catlabel,catw=&catw,spantotal=&spantotal,pageline=&pageline,endline=&endline,
pageline1=&pageline1,pageline2=&pageline2,pageline3=&pageline3,pageline4=&pageline4,
pageline5=&pageline5,pageline6=&pageline6,pageline7=&pageline7,pageline8=&pageline8,
pageline9=&pageline9,pgbrkpos=&pgbrkpos,total=&total,strlen=&strlen,varlabel=&varlabel,
endline1=&endline1,endline2=&endline2,endline3=&endline3,endline4=&endline4,endline5=&endline5,
endline6=&endline6,endline7=&endline7,endline8=&endline8,endline9=&endline9,
trtlabel=&trtlabel,topline=&topline,trtspace=&trtspace,style=&unicatstyle,print=&print,
trtw1=&trtw1,trtw2=&trtw2,trtw3=&trtw3,trtw4=&trtw4,trtw5=&trtw5,trtw6=&trtw6,
trtw7=&trtw7,trtw8=&trtw8,trtw9=&trtw9,indent=&indent,split=&split,out=&out,varw=&varw,
odsrtf=&odsrtf,odshtml=&odshtml,odspdf=&odspdf,odsother=&odsother,odshtmlcss=&odshtmlcss,
odscsv=&odscsv,odslisting=&odslisting,pvalues=&pvalues,compskip=&compskip,
byrowvar=&byrowvar,byroword=&byroword,byrowlabel=&byrowlabel,compskippos=&compskippos,
byrowalign=&byrowalign,byrowfmt=&byrowfmt,byroww=&byroww,
byrow2var=&byrow2var,byrow2ord=&byrow2ord,byrow2label=&byrow2label,
byrow2align=&byrow2align,byrow2fmt=&byrow2fmt,byrow2w=&byrow2w,
byrowfirst=&byrowfirst,trtvarlist=&trtvarlist,font_face_stats=&font_face_stats,
font_face_other=&font_face_other,font_weight_other=&font_weight_other,
report_border=&report_border,header_border=&header_border,
column_border=&column_border,lines_border=&lines_border,rules=&rules,
cellspacing=&cellspacing,cellpadding=&cellpadding,outputwidthpct=&outputwidthpct,
background_header=&background_header,foreground_header=&foreground_header,
background_stats=&background_stats,foreground_stats=&foreground_stats,
background_other=&background_other,foreground_other=&foreground_other,
header_ul=&header_ul,report_ul=&report_ul,report_ol=&report_ol,
linepx=&linepx,linecol=&linecol,font_style_other=&font_style_other,
font_weight_stats=&font_weight_stats,compskip_ul=&compskip_ul,
compskippx=&compskippx,compskipcol=&compskipcol,spanrows=&spanrows);

%end;

             /*-----------------------------------------*
                  Call conversion-to-Word-table macro
              *-----------------------------------------*/

%if %length(&wordtabdest) %then %do;

%unicat2word(dsin=&dstrantrt,dest=&wordtabdest,dlim=&wordtabdlim,total=&total)

%end;


             /*-----------------------------------------*
                                  Exit
              *-----------------------------------------*/

%goto skip;
%error:
%put ERROR: (unistats) Leaving macro due to error(s) listed;
%skip:
%mend;
